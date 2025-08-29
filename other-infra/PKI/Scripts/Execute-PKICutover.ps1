# Execute-PKICutover.ps1
# Main cutover execution script

param(
    [switch]$Force,
    [string]$LogPath = "C:\Cutover\Logs"
)

# Initialize cutover log
$cutoverLog = "$LogPath\Cutover-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Start-Transcript -Path $cutoverLog

Write-Host "=== PKI CUTOVER EXECUTION ===" -ForegroundColor Cyan
Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

# Step 1: Final readiness check
if (-not $Force) {
    Write-Host "`nPerforming final readiness check..." -ForegroundColor Yellow
    $readiness = Test-CutoverReadiness

    if (-not $readiness.Ready) {
        Write-Host "System not ready for cutover. Use -Force to override." -ForegroundColor Red
        Stop-Transcript
        return
    }
}

# Step 2: Create point-of-no-return snapshot
Write-Host "`nCreating point-of-no-return snapshot..." -ForegroundColor Yellow

$snapshot = @{
    Timestamp          = Get-Date
    LegacyCAState      = Get-LegacyCAState
    NewCAState         = Get-NewCAState
    DNSRecords         = Get-DNSRecords -Zone "company.com.au"
    LoadBalancerConfig = Export-LoadBalancerConfig
}

$snapshot | Export-Clixml -Path "$LogPath\PreCutoverSnapshot.xml"

# Step 3: Notify all stakeholders
Write-Host "`nSending cutover notifications..." -ForegroundColor Yellow

Send-CutoverNotification -Recipients @(
    "it-all@company.com.au",
    "management@company.com.au",
    "servicedesk@company.com.au"
) -Message "PKI Cutover commencing. Estimated duration: 2 hours"

# Step 4: Stop legacy certificate issuance
Write-Host "`nStopping legacy certificate issuance..." -ForegroundColor Yellow

$legacyCAs = @("LEGACY-CA-01", "LEGACY-CA-02")

foreach ($ca in $legacyCAs) {
    Write-Host "  Stopping CA service on $ca..." -ForegroundColor Gray

    Invoke-Command -ComputerName $ca -ScriptBlock {
        # Stop certificate service
        Stop-Service -Name CertSvc -Force

        # Disable service to prevent accidental start
        Set-Service -Name CertSvc -StartupType Disabled

        # Export final CRL
        certutil -CRL

        # Backup CA database
        $backupPath = "\\Backup\Legacy-PKI\$env:COMPUTERNAME-Final"
        New-Item -ItemType Directory -Path $backupPath -Force

        Backup-CARoleService -Path $backupPath -DatabaseOnly
    }
}

# Step 5: Update DNS records
Write-Host "`nUpdating DNS records to new PKI..." -ForegroundColor Yellow

$dnsUpdates = @(
    @{Name = "ca"; Type = "A"; Value = "10.50.1.10"; OldValue = "10.40.1.10" },
    @{Name = "ocsp"; Type = "CNAME"; Value = "pki-ocsp-01.company.com.au"; OldValue = "legacy-ocsp.company.com.au" },
    @{Name = "crl"; Type = "CNAME"; Value = "pki-crl.company.com.au"; OldValue = "legacy-crl.company.com.au" },
    @{Name = "pki"; Type = "A"; Value = "10.50.1.10"; OldValue = "10.40.1.10" }
)

foreach ($record in $dnsUpdates) {
    Write-Host "  Updating $($record.Name).$($record.Type) record..." -ForegroundColor Gray

    # Remove old record
    Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
        -Name $record.Name `
        -RRType $record.Type `
        -Force

    # Add new record
    switch ($record.Type) {
        "A" {
            Add-DnsServerResourceRecordA -ZoneName "company.com.au" `
                -Name $record.Name `
                -IPv4Address $record.Value
        }
        "CNAME" {
            Add-DnsServerResourceRecordCName -ZoneName "company.com.au" `
                -Name $record.Name `
                -HostNameAlias $record.Value
        }
    }
}

# Clear DNS cache across domain controllers
$dcs = Get-ADDomainController -Filter *
foreach ($dc in $dcs) {
    Invoke-Command -ComputerName $dc.HostName -ScriptBlock {
        Clear-DnsServerCache
    }
}

# Step 6: Update load balancer configurations
Write-Host "`nReconfiguring load balancers..." -ForegroundColor Yellow

# NetScaler reconfiguration
Update-NetScalerVirtualServer -VServer "VS_PKI_Services" -BackendServers @(
    "10.50.1.10:443",  # New ICA01
    "10.50.1.11:443"   # New ICA02
) -RemoveServers @(
    "10.40.1.10:443",  # Legacy CA01
    "10.40.1.11:443"   # Legacy CA02
)

# F5 reconfiguration
Update-F5Pool -Pool "pool_pki_services" -Members @(
    @{Address = "10.50.1.10"; Port = 443 },
    @{Address = "10.50.1.11"; Port = 443 }
) -RemoveMembers @(
    @{Address = "10.40.1.10"; Port = 443 },
    @{Address = "10.40.1.11"; Port = 443 }
)

# Step 7: Update Group Policy
Write-Host "`nUpdating Group Policy for new PKI..." -ForegroundColor Yellow

$gpoUpdates = @(
    @{
        GPO     = "PKI-AutoEnrollment"
        Setting = "CertificateServices\CAServer"
        Value   = "PKI-ICA-01.company.local"
    },
    @{
        GPO     = "PKI-TrustedRoots"
        Setting = "CertificateServices\TrustedRoot"
        Value   = "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt"
    }
)

foreach ($update in $gpoUpdates) {
    Set-GPRegistryValue -Name $update.GPO `
        -Key "HKLM\Software\Policies\Microsoft\SystemCertificates" `
        -ValueName $update.Setting `
        -Value $update.Value `
        -Type String
}

# Force GP update across domain
Invoke-Command -ComputerName (Get-ADComputer -Filter * | Select-Object -First 100).Name -ScriptBlock {
    gpupdate /force
} -ThrottleLimit 20

# Step 8: Validate cutover
Write-Host "`nValidating cutover success..." -ForegroundColor Yellow

$validationTests = @(
    @{Name = "New CA Accessibility"; Test = { Test-NetConnection -ComputerName "PKI-ICA-01" -Port 443 } },
    @{Name = "Certificate Enrollment"; Test = { Test-CertificateEnrollment -Template "Company-Computer-Authentication" } },
    @{Name = "OCSP Response"; Test = { Test-OCSPResponse -Url "http://ocsp.company.com.au" } },
    @{Name = "CRL Download"; Test = { Test-CRLDownload -Url "http://crl.company.com.au/IssuingCA01.crl" } },
    @{Name = "Application Connectivity"; Test = { Test-ApplicationConnectivity } },
    @{Name = "User Authentication"; Test = { Test-UserAuthentication } }
)

$validationResults = @()
$allTestsPassed = $true

foreach ($test in $validationTests) {
    Write-Host "  Testing $($test.Name)..." -ForegroundColor Gray

    try {
        $result = & $test.Test
        $validationResults += @{
            Test    = $test.Name
            Result  = "PASSED"
            Details = "Test completed successfully"
        }
        Write-Host "    ✓ Passed" -ForegroundColor Green
    } catch {
        $validationResults += @{
            Test    = $test.Name
            Result  = "FAILED"
            Details = $_.Exception.Message
        }
        Write-Host "    ✗ Failed: $_" -ForegroundColor Red
        $allTestsPassed = $false
    }
}

# Step 9: Decision point
if (-not $allTestsPassed) {
    Write-Host "`nCUTOVER VALIDATION FAILED!" -ForegroundColor Red
    Write-Host "Initiating rollback procedure..." -ForegroundColor Yellow

    # Rollback procedure
    Start-CutoverRollback -Snapshot $snapshot

    Stop-Transcript
    throw "Cutover failed - rollback initiated"
}

# Step 10: Finalize cutover
Write-Host "`nFinalizing cutover..." -ForegroundColor Yellow

# Mark legacy PKI as decommissioned
Set-LegacyPKIStatus -Status "Decommissioned" -Timestamp (Get-Date)

# Update CMDB
Update-CMDB -Service "PKI" -Status "Migrated" -NewInfrastructure "Azure-based PKI"

# Send success notification
Send-CutoverNotification -Recipients @(
    "it-all@company.com.au",
    "management@company.com.au"
) -Message "PKI Cutover completed successfully. All services operational on new infrastructure."

Write-Host "`n=== CUTOVER COMPLETED SUCCESSFULLY ===" -ForegroundColor Green
Write-Host "End Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

Stop-Transcript

# Generate cutover report
Generate-CutoverReport -ValidationResults $validationResults -OutputPath "$LogPath\CutoverReport.html"
