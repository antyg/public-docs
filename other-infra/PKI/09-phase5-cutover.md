# PKI Modernization - Phase 5: Cutover & Decommissioning

[← Previous: Phase 4 Migration Strategy](08-phase4-migration-strategy.md) | [Back to Index](00-index.md) | [Next: Operational Procedures →](10-operational-procedures.md)

## Executive Summary

Phase 5 represents the final stage of the PKI modernization project, executing the complete cutover from legacy to new PKI infrastructure. This phase includes final system validation, legacy CA decommissioning, documentation finalization, and knowledge transfer to ensure sustainable operations. The cutover is designed for zero downtime with comprehensive rollback capabilities until the point of no return.

## Phase 5 Overview

### Objectives
- Complete final system validation and readiness assessment
- Execute production cutover with zero downtime
- Decommission legacy PKI infrastructure safely
- Archive historical data and certificates
- Complete all documentation and runbooks
- Conduct knowledge transfer sessions
- Obtain formal project closure and sign-off

### Success Criteria
- ✅ 100% of systems using new PKI infrastructure
- ✅ Legacy CAs safely decommissioned
- ✅ All certificates validated and operational
- ✅ Complete documentation delivered
- ✅ Knowledge transfer completed
- ✅ Operations team fully trained
- ✅ Formal sign-off obtained

### Timeline
**Duration**: 1 week (April 14-18, 2025)
**Resources Required**: 3.5 FTE
**Budget**: $25,000 (Final activities and celebration)

## Cutover Planning

### Cutover Schedule

```yaml
Cutover_Timeline:
  Monday_April_14:
    08:00-12:00:
      - Final readiness assessment
      - Go/No-Go decision meeting
      - Communication to all stakeholders
    12:00-17:00:
      - Pre-cutover system snapshots
      - Final backup verification
      - Staging cutover scripts
    18:00-20:00:
      - Cutover initiation
      - DNS updates
      - Load balancer reconfiguration
      
  Tuesday_April_15:
    06:00-08:00:
      - Legacy CA offline transition
      - Final certificate issuance from legacy
      - Switch all services to new PKI
    08:00-17:00:
      - Comprehensive validation testing
      - Application verification
      - Performance monitoring
      
  Wednesday_April_16:
    09:00-17:00:
      - Legacy system backup
      - Data archival
      - Historical record preservation
      
  Thursday_April_17:
    09:00-17:00:
      - Documentation finalization
      - Runbook completion
      - Knowledge base updates
      
  Friday_April_18:
    09:00-12:00:
      - Knowledge transfer sessions
      - Operations team handover
    13:00-16:00:
      - Final project review
      - Lessons learned session
    16:00-17:00:
      - Project closure ceremony
      - Team celebration
```

## Day 1: Final Readiness Assessment

### Pre-Cutover Validation Script

```powershell
# Test-CutoverReadiness.ps1
# Comprehensive readiness assessment before cutover

param(
    [string]$ReportPath = "C:\Cutover\ReadinessReport.html"
)

Write-Host "=== PKI Cutover Readiness Assessment ===" -ForegroundColor Cyan
Write-Host "Execution Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

$readinessChecks = @()
$overallReady = $true

# Check 1: Migration Completion
Write-Host "`nChecking migration completion..." -ForegroundColor Yellow

$migrationStats = Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Query @"
    SELECT 
        Wave,
        COUNT(*) as Total,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as Completed,
        SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as Failed
    FROM PKI_Migration.dbo.MigrationTracking
    GROUP BY Wave
"@

$totalDevices = ($migrationStats | Measure-Object -Property Total -Sum).Sum
$completedDevices = ($migrationStats | Measure-Object -Property Completed -Sum).Sum
$completionRate = ($completedDevices / $totalDevices) * 100

$readinessChecks += @{
    Category = "Migration Status"
    Check = "Device Migration Complete"
    Status = if ($completionRate -ge 99.5) { "READY" } else { "NOT READY" }
    Details = "Completion: $([Math]::Round($completionRate, 2))% ($completedDevices/$totalDevices)"
    Critical = $true
}

if ($completionRate -lt 99.5) { $overallReady = $false }

# Check 2: New PKI Health
Write-Host "Checking new PKI infrastructure health..." -ForegroundColor Yellow

$pkiServices = @(
    @{Name = "Root CA (Azure)"; Check = {Test-AzurePrivateCA}},
    @{Name = "Issuing CA 01"; Check = {Test-ServiceHealth -Server "PKI-ICA-01" -Service "CertSvc"}},
    @{Name = "Issuing CA 02"; Check = {Test-ServiceHealth -Server "PKI-ICA-02" -Service "CertSvc"}},
    @{Name = "NDES Service"; Check = {Test-ServiceHealth -Server "PKI-NDES-01" -Service "IIS"}},
    @{Name = "OCSP Responder"; Check = {Test-OCSPResponder -Url "http://ocsp.company.com.au"}},
    @{Name = "CRL Distribution"; Check = {Test-CRLAvailability -Url "http://crl.company.com.au/IssuingCA01.crl"}}
)

foreach ($service in $pkiServices) {
    $serviceHealthy = & $service.Check
    
    $readinessChecks += @{
        Category = "PKI Services"
        Check = $service.Name
        Status = if ($serviceHealthy) { "READY" } else { "NOT READY" }
        Details = if ($serviceHealthy) { "Service operational" } else { "Service check failed" }
        Critical = $true
    }
    
    if (-not $serviceHealthy) { $overallReady = $false }
}

# Check 3: Certificate Validation
Write-Host "Validating certificate deployment..." -ForegroundColor Yellow

$certValidation = Test-EnterpriseCertificates -SampleSize 100

$readinessChecks += @{
    Category = "Certificate Validation"
    Check = "Certificate Chain Validation"
    Status = if ($certValidation.SuccessRate -ge 99) { "READY" } else { "WARNING" }
    Details = "Success Rate: $($certValidation.SuccessRate)%"
    Critical = $false
}

# Check 4: Application Compatibility
Write-Host "Checking application compatibility..." -ForegroundColor Yellow

$applications = @(
    "Exchange", "SharePoint", "SQL Server", "Active Directory",
    "File Services", "Web Services", "VPN", "Remote Desktop"
)

$appResults = @()
foreach ($app in $applications) {
    $compatible = Test-ApplicationPKICompatibility -Application $app
    $appResults += @{
        Application = $app
        Compatible = $compatible
    }
    
    $readinessChecks += @{
        Category = "Application Compatibility"
        Check = $app
        Status = if ($compatible) { "READY" } else { "NOT READY" }
        Details = if ($compatible) { "PKI integration verified" } else { "Compatibility issues detected" }
        Critical = ($app -in @("Exchange", "Active Directory"))
    }
    
    if (-not $compatible -and ($app -in @("Exchange", "Active Directory"))) {
        $overallReady = $false
    }
}

# Check 5: Backup and Recovery
Write-Host "Verifying backup and recovery procedures..." -ForegroundColor Yellow

$backupChecks = @(
    @{Name = "Legacy CA Backup"; Path = "\\Backup\Legacy-PKI\"},
    @{Name = "New CA Database Backup"; Path = "\\Backup\New-PKI\Database\"},
    @{Name = "Certificate Archive"; Path = "\\Backup\Certificates\"},
    @{Name = "Configuration Backup"; Path = "\\Backup\Configurations\"}
)

foreach ($backup in $backupChecks) {
    $backupValid = Test-Path $backup.Path
    $backupAge = if ($backupValid) {
        (Get-Item $backup.Path).LastWriteTime
    } else {
        "N/A"
    }
    
    $readinessChecks += @{
        Category = "Backup & Recovery"
        Check = $backup.Name
        Status = if ($backupValid -and $backupAge -gt (Get-Date).AddDays(-1)) { "READY" } else { "WARNING" }
        Details = if ($backupValid) { "Last backup: $backupAge" } else { "Backup not found" }
        Critical = $false
    }
}

# Check 6: Rollback Capability
Write-Host "Verifying rollback procedures..." -ForegroundColor Yellow

$rollbackReady = Test-RollbackProcedures

$readinessChecks += @{
    Category = "Rollback Capability"
    Check = "Rollback Procedures"
    Status = if ($rollbackReady) { "READY" } else { "WARNING" }
    Details = if ($rollbackReady) { "Rollback tested and ready" } else { "Rollback procedures need verification" }
    Critical = $false
}

# Check 7: Team Readiness
Write-Host "Checking team readiness..." -ForegroundColor Yellow

$teamChecks = @(
    @{Team = "PKI Team"; Ready = Test-TeamAvailability -Team "PKI"},
    @{Team = "Network Team"; Ready = Test-TeamAvailability -Team "Network"},
    @{Team = "Security Team"; Ready = Test-TeamAvailability -Team "Security"},
    @{Team = "Service Desk"; Ready = Test-TeamAvailability -Team "ServiceDesk"}
)

foreach ($team in $teamChecks) {
    $readinessChecks += @{
        Category = "Team Readiness"
        Check = $team.Team
        Status = if ($team.Ready) { "READY" } else { "WARNING" }
        Details = if ($team.Ready) { "Team available and briefed" } else { "Team preparation needed" }
        Critical = ($team.Team -eq "PKI Team")
    }
    
    if (-not $team.Ready -and $team.Team -eq "PKI Team") {
        $overallReady = $false
    }
}

# Generate HTML Report
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>PKI Cutover Readiness Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .ready { color: green; font-weight: bold; }
        .not-ready { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .summary { 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 5px;
            font-size: 18px;
        }
        .summary.ready { background-color: #d4edda; border: 1px solid #c3e6cb; }
        .summary.not-ready { background-color: #f8d7da; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <h1>PKI Cutover Readiness Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    
    <div class='summary $(if ($overallReady) {"ready"} else {"not-ready"})'>
        Overall Status: $(if ($overallReady) {"READY FOR CUTOVER"} else {"NOT READY FOR CUTOVER"})
    </div>
    
    <table>
        <tr>
            <th>Category</th>
            <th>Check</th>
            <th>Status</th>
            <th>Details</th>
            <th>Critical</th>
        </tr>
"@

foreach ($check in $readinessChecks) {
    $statusClass = switch ($check.Status) {
        "READY" { "ready" }
        "NOT READY" { "not-ready" }
        "WARNING" { "warning" }
    }
    
    $html += @"
        <tr>
            <td>$($check.Category)</td>
            <td>$($check.Check)</td>
            <td class='$statusClass'>$($check.Status)</td>
            <td>$($check.Details)</td>
            <td>$(if ($check.Critical) {"Yes"} else {"No"})</td>
        </tr>
"@
}

$html += @"
    </table>
    
    <h2>Go/No-Go Decision</h2>
    <p>Based on the readiness assessment:</p>
    <ul>
        <li>Critical Checks Passed: $(($readinessChecks | Where-Object {$_.Critical -and $_.Status -eq "READY"}).Count) / $(($readinessChecks | Where-Object {$_.Critical}).Count)</li>
        <li>Overall Recommendation: <strong>$(if ($overallReady) {"PROCEED WITH CUTOVER"} else {"POSTPONE CUTOVER"})</strong></li>
    </ul>
    
    $(if (-not $overallReady) {
        "<h3>Required Actions Before Cutover:</h3><ul>"
        ($readinessChecks | Where-Object {$_.Critical -and $_.Status -ne "READY"} | ForEach-Object {
            "<li>$($_.Category) - $($_.Check): $($_.Details)</li>"
        }) -join "`n"
        "</ul>"
    })
</body>
</html>
"@

$html | Out-File -FilePath $ReportPath -Encoding UTF8

# Display summary
Write-Host "`n=== READINESS ASSESSMENT SUMMARY ===" -ForegroundColor Cyan
Write-Host "Overall Status: $(if ($overallReady) {"READY FOR CUTOVER"} else {"NOT READY"})" -ForegroundColor $(if ($overallReady) {"Green"} else {"Red"})
Write-Host "Report saved to: $ReportPath" -ForegroundColor Gray

# Return decision
return @{
    Ready = $overallReady
    Report = $ReportPath
    CriticalIssues = $readinessChecks | Where-Object {$_.Critical -and $_.Status -ne "READY"}
}
```

## Day 2: Cutover Execution

### Cutover Execution Script

```powershell
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
    Timestamp = Get-Date
    LegacyCAState = Get-LegacyCAState
    NewCAState = Get-NewCAState
    DNSRecords = Get-DNSRecords -Zone "company.com.au"
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
    @{Name = "ca"; Type = "A"; Value = "10.50.1.10"; OldValue = "10.40.1.10"},
    @{Name = "ocsp"; Type = "CNAME"; Value = "pki-ocsp-01.company.com.au"; OldValue = "legacy-ocsp.company.com.au"},
    @{Name = "crl"; Type = "CNAME"; Value = "pki-crl.company.com.au"; OldValue = "legacy-crl.company.com.au"},
    @{Name = "pki"; Type = "A"; Value = "10.50.1.10"; OldValue = "10.40.1.10"}
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
    @{Address = "10.50.1.10"; Port = 443},
    @{Address = "10.50.1.11"; Port = 443}
) -RemoveMembers @(
    @{Address = "10.40.1.10"; Port = 443},
    @{Address = "10.40.1.11"; Port = 443}
)

# Step 7: Update Group Policy
Write-Host "`nUpdating Group Policy for new PKI..." -ForegroundColor Yellow

$gpoUpdates = @(
    @{
        GPO = "PKI-AutoEnrollment"
        Setting = "CertificateServices\CAServer"
        Value = "PKI-ICA-01.company.local"
    },
    @{
        GPO = "PKI-TrustedRoots"
        Setting = "CertificateServices\TrustedRoot"
        Value = "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt"
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
    @{Name = "New CA Accessibility"; Test = {Test-NetConnection -ComputerName "PKI-ICA-01" -Port 443}},
    @{Name = "Certificate Enrollment"; Test = {Test-CertificateEnrollment -Template "Company-Computer-Authentication"}},
    @{Name = "OCSP Response"; Test = {Test-OCSPResponse -Url "http://ocsp.company.com.au"}},
    @{Name = "CRL Download"; Test = {Test-CRLDownload -Url "http://crl.company.com.au/IssuingCA01.crl"}},
    @{Name = "Application Connectivity"; Test = {Test-ApplicationConnectivity}},
    @{Name = "User Authentication"; Test = {Test-UserAuthentication}}
)

$validationResults = @()
$allTestsPassed = $true

foreach ($test in $validationTests) {
    Write-Host "  Testing $($test.Name)..." -ForegroundColor Gray
    
    try {
        $result = & $test.Test
        $validationResults += @{
            Test = $test.Name
            Result = "PASSED"
            Details = "Test completed successfully"
        }
        Write-Host "    ✓ Passed" -ForegroundColor Green
    } catch {
        $validationResults += @{
            Test = $test.Name
            Result = "FAILED"
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
```

## Day 3: Legacy Decommissioning

### Decommission Legacy PKI

```powershell
# Decommission-LegacyPKI.ps1
# Safely decommissions legacy PKI infrastructure

param(
    [string]$ArchivePath = "\\Archive\Legacy-PKI",
    [switch]$PreserveVMs = $false
)

Write-Host "=== LEGACY PKI DECOMMISSIONING ===" -ForegroundColor Cyan
Write-Host "This process will permanently decommission the legacy PKI infrastructure" -ForegroundColor Yellow

# Confirmation
$confirm = Read-Host "Type 'DECOMMISSION' to proceed"
if ($confirm -ne "DECOMMISSION") {
    Write-Host "Decommissioning cancelled" -ForegroundColor Red
    return
}

# Step 1: Final data archival
Write-Host "`nArchiving legacy PKI data..." -ForegroundColor Yellow

$legacyServers = @(
    @{Name = "LEGACY-CA-01"; Type = "Root CA"},
    @{Name = "LEGACY-CA-02"; Type = "Issuing CA"},
    @{Name = "LEGACY-CA-03"; Type = "Issuing CA"},
    @{Name = "LEGACY-OCSP-01"; Type = "OCSP Responder"}
)

foreach ($server in $legacyServers) {
    Write-Host "  Archiving $($server.Name)..." -ForegroundColor Gray
    
    $serverArchive = "$ArchivePath\$($server.Name)"
    New-Item -ItemType Directory -Path $serverArchive -Force
    
    Invoke-Command -ComputerName $server.Name -ScriptBlock {
        param($archivePath)
        
        # Export CA database
        if (Test-Path "C:\Windows\System32\CertLog") {
            Copy-Item -Path "C:\Windows\System32\CertLog" `
                      -Destination "$archivePath\CertLog" `
                      -Recurse -Force
        }
        
        # Export registry settings
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc" `
                   "$archivePath\CertSvc-Registry.reg" /y
        
        # Export certificates
        $certs = Get-ChildItem Cert:\LocalMachine\My
        foreach ($cert in $certs) {
            $cert | Export-Certificate -FilePath "$archivePath\$($cert.Thumbprint).cer"
        }
        
        # Export IIS configuration (if applicable)
        if (Get-Service -Name W3SVC -ErrorAction SilentlyContinue) {
            & $env:windir\system32\inetsrv\appcmd.exe list site /config /xml > "$archivePath\IIS-Sites.xml"
        }
        
        # Create system information file
        @{
            Hostname = $env:COMPUTERNAME
            OS = (Get-WmiObject Win32_OperatingSystem).Caption
            LastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            IPAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
            Services = Get-Service | Where-Object {$_.Name -like "*Cert*" -or $_.Name -like "*PKI*"} | Select-Object Name, Status
            InstalledRoles = Get-WindowsFeature | Where-Object {$_.Installed -and $_.Name -like "*Certificate*"}
        } | ConvertTo-Json | Out-File "$archivePath\SystemInfo.json"
        
    } -ArgumentList $serverArchive
}

# Step 2: Remove from Active Directory
Write-Host "`nRemoving legacy PKI from Active Directory..." -ForegroundColor Yellow

# Remove old CA certificates from AD
$config = [ADSI]"LDAP://CN=Configuration,$((Get-ADDomain).DistinguishedName)"
$pkiContainer = [ADSI]"LDAP://CN=Public Key Services,CN=Services,$($config.distinguishedName)"

# Archive before deletion
$adBackup = "$ArchivePath\AD-PKI-Objects.xml"
$pkiContainer.Children | Export-Clixml -Path $adBackup

# Remove old CA entries
$entriesToRemove = @(
    "CN=Legacy Root CA",
    "CN=Legacy Issuing CA 01",
    "CN=Legacy Issuing CA 02"
)

foreach ($entry in $entriesToRemove) {
    try {
        $object = [ADSI]"LDAP://$entry,CN=Certification Authorities,$($pkiContainer.distinguishedName)"
        $object.DeleteTree()
        Write-Host "  Removed $entry from AD" -ForegroundColor Green
    } catch {
        Write-Host "  Could not remove $entry : $_" -ForegroundColor Yellow
    }
}

# Step 3: Clean up Group Policy
Write-Host "`nCleaning up Group Policy references..." -ForegroundColor Yellow

$gpos = Get-GPO -All
foreach ($gpo in $gpos) {
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    
    if ($report -match "LEGACY-CA") {
        Write-Host "  Found legacy reference in GPO: $($gpo.DisplayName)" -ForegroundColor Gray
        
        # Backup GPO before modification
        Backup-GPO -Guid $gpo.Id -Path "$ArchivePath\GPO-Backups"
        
        # Remove legacy settings
        # This would need specific removal based on GPO content
    }
}

# Step 4: Update DNS
Write-Host "`nRemoving legacy DNS records..." -ForegroundColor Yellow

$dnsRecordsToRemove = @(
    @{Name = "legacy-ca"; Type = "A"},
    @{Name = "legacy-ocsp"; Type = "A"},
    @{Name = "legacy-crl"; Type = "A"},
    @{Name = "pkiold"; Type = "CNAME"}
)

foreach ($record in $dnsRecordsToRemove) {
    try {
        Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
            -Name $record.Name `
            -RRType $record.Type `
            -Force
        Write-Host "  Removed $($record.Name) DNS record" -ForegroundColor Green
    } catch {
        Write-Host "  Record $($record.Name) not found or already removed" -ForegroundColor Gray
    }
}

# Step 5: Decommission servers
Write-Host "`nDecommissioning legacy servers..." -ForegroundColor Yellow

if (-not $PreserveVMs) {
    foreach ($server in $legacyServers) {
        Write-Host "  Shutting down $($server.Name)..." -ForegroundColor Gray
        
        # Final snapshot before shutdown
        if (Get-VM -Name $server.Name -ErrorAction SilentlyContinue) {
            Checkpoint-VM -Name $server.Name -SnapshotName "Final-Before-Decommission"
        }
        
        # Shutdown
        Stop-Computer -ComputerName $server.Name -Force
        
        # Remove from domain
        Remove-ADComputer -Identity $server.Name -Confirm:$false
        
        # Remove from monitoring
        Remove-MonitoringTarget -Target $server.Name
        
        # Remove from backup jobs
        Remove-BackupJob -Server $server.Name
        
        Write-Host "  $($server.Name) decommissioned" -ForegroundColor Green
    }
} else {
    Write-Host "  VMs preserved as requested (-PreserveVMs flag)" -ForegroundColor Yellow
}

# Step 6: Update documentation
Write-Host "`nUpdating documentation..." -ForegroundColor Yellow

$decommissionRecord = @{
    Date = Get-Date
    DecommissionedServers = $legacyServers
    ArchiveLocation = $ArchivePath
    PreservedVMs = $PreserveVMs
    CompletedBy = $env:USERNAME
}

$decommissionRecord | ConvertTo-Json | Out-File "$ArchivePath\DecommissionRecord.json"

# Update CMDB
Update-CMDB -Action "Decommission" -Assets $legacyServers.Name -Status "Archived"

Write-Host "`n=== LEGACY PKI DECOMMISSIONING COMPLETE ===" -ForegroundColor Green
Write-Host "Archive location: $ArchivePath" -ForegroundColor Gray
```

## Day 4-5: Documentation and Knowledge Transfer

### Documentation Finalization

```powershell
# Complete-Documentation.ps1
# Generates comprehensive PKI documentation

param(
    [string]$OutputPath = "C:\PKI\Documentation"
)

Write-Host "Generating comprehensive PKI documentation..." -ForegroundColor Cyan

# Create documentation structure
$docStructure = @(
    "Architecture",
    "Procedures",
    "Runbooks",
    "Policies",
    "Diagrams",
    "Scripts",
    "Reports"
)

foreach ($folder in $docStructure) {
    New-Item -ItemType Directory -Path "$OutputPath\$folder" -Force | Out-Null
}

# Generate architecture documentation
Write-Host "Creating architecture documentation..." -ForegroundColor Yellow

$architectureDoc = @"
# PKI Infrastructure Architecture

## Overview
The Company PKI infrastructure is a hybrid Azure-based solution providing enterprise certificate services.

## Components

### Azure Components
- **Azure Private CA**: Root Certificate Authority (Australia East)
- **Azure Key Vault**: HSM-protected key storage
- **Azure Automation**: Certificate lifecycle management

### On-Premises Components
- **Issuing CAs**: 2x Windows Server 2022 (PKI-ICA-01, PKI-ICA-02)
- **NDES Server**: Mobile device enrollment (PKI-NDES-01)
- **OCSP Responders**: 2x for high availability
- **Web Enrollment**: Certificate request portal

## Network Architecture
- Primary Site: Australia East
- DR Site: Australia Southeast
- Connectivity: ExpressRoute + VPN backup

## Certificate Templates
$(Get-CATemplate | Select-Object Name, Type, ValidityPeriod | ConvertTo-Markdown)

## Trust Relationships
- Internal: Active Directory integrated
- External: Zscaler, Partner organizations
- Cloud: Azure services, Microsoft 365
"@

$architectureDoc | Out-File "$OutputPath\Architecture\PKI-Architecture.md"

# Generate operational procedures
Write-Host "Creating operational procedures..." -ForegroundColor Yellow

$procedures = @{
    "Certificate-Request" = "How to request certificates"
    "Certificate-Renewal" = "Certificate renewal procedures"
    "Certificate-Revocation" = "Revocation procedures"
    "Template-Management" = "Managing certificate templates"
    "Backup-Recovery" = "Backup and recovery procedures"
    "Monitoring" = "Monitoring and alerting"
}

foreach ($proc in $procedures.GetEnumerator()) {
    Generate-Procedure -Name $proc.Key -Description $proc.Value -OutputPath "$OutputPath\Procedures"
}

# Generate runbooks
Write-Host "Creating operational runbooks..." -ForegroundColor Yellow

$runbooks = @(
    @{
        Name = "Daily-Health-Check"
        Script = Get-Content "C:\PKI\Scripts\Test-PKIHealth.ps1" -Raw
        Schedule = "Daily at 08:00"
    },
    @{
        Name = "Certificate-Expiry-Report"
        Script = Get-Content "C:\PKI\Scripts\Get-ExpiringCertificates.ps1" -Raw
        Schedule = "Weekly on Monday"
    },
    @{
        Name = "CRL-Publication"
        Script = Get-Content "C:\PKI\Scripts\Publish-CRL.ps1" -Raw
        Schedule = "Every 7 days"
    }
)

foreach ($runbook in $runbooks) {
    $runbookDoc = @"
# Runbook: $($runbook.Name)

## Schedule
$($runbook.Schedule)

## Script
``````powershell
$($runbook.Script)
``````

## Notes
- Ensure service account has appropriate permissions
- Monitor execution logs for failures
- Escalate critical alerts immediately
"@
    
    $runbookDoc | Out-File "$OutputPath\Runbooks\$($runbook.Name).md"
}

# Generate network diagram
Write-Host "Creating network diagrams..." -ForegroundColor Yellow

$mermaidDiagram = @"
graph TB
    subgraph Azure Cloud
        AKV[Azure Key Vault<br/>HSM]
        APCA[Azure Private CA<br/>Root CA]
    end
    
    subgraph On-Premises
        ICA1[Issuing CA 01]
        ICA2[Issuing CA 02]
        NDES[NDES Server]
        OCSP[OCSP Responders]
    end
    
    subgraph Endpoints
        USERS[Users]
        COMPUTERS[Computers]
        MOBILE[Mobile Devices]
        SERVERS[Servers]
    end
    
    APCA --> ICA1
    APCA --> ICA2
    ICA1 --> USERS
    ICA1 --> COMPUTERS
    ICA2 --> SERVERS
    NDES --> MOBILE
"@

$mermaidDiagram | Out-File "$OutputPath\Diagrams\PKI-Overview.mmd"

# Compile all scripts
Write-Host "Organizing scripts..." -ForegroundColor Yellow

$scripts = Get-ChildItem -Path "C:\PKI\Scripts" -Filter "*.ps1"
foreach ($script in $scripts) {
    Copy-Item $script.FullName -Destination "$OutputPath\Scripts" -Force
}

# Generate final report
Write-Host "Generating project closure report..." -ForegroundColor Yellow

Generate-ProjectReport -OutputPath "$OutputPath\Reports\Project-Closure-Report.html"

Write-Host "Documentation complete. Location: $OutputPath" -ForegroundColor Green
```

### Knowledge Transfer Sessions

```yaml
Knowledge_Transfer_Plan:
  
  Session_1_Architecture_Overview:
    Duration: 2 hours
    Audience: All IT staff
    Topics:
      - PKI fundamentals
      - New architecture overview
      - Azure components
      - On-premises integration
    Materials:
      - Architecture diagrams
      - Component descriptions
      - Trust relationships
    
  Session_2_Operations:
    Duration: 3 hours
    Audience: Operations team
    Topics:
      - Daily operations
      - Certificate lifecycle
      - Monitoring and alerts
      - Troubleshooting
    Hands_On:
      - Issue test certificate
      - Check certificate status
      - Review monitoring dashboard
      - Resolve common issues
    
  Session_3_Administration:
    Duration: 4 hours
    Audience: PKI administrators
    Topics:
      - CA administration
      - Template management
      - Policy configuration
      - Security controls
    Labs:
      - Create new template
      - Modify existing template
      - Configure auto-enrollment
      - Perform backup
    
  Session_4_Emergency_Procedures:
    Duration: 2 hours
    Audience: On-call staff
    Topics:
      - Incident response
      - Service restoration
      - Rollback procedures
      - Escalation paths
    Scenarios:
      - CA service failure
      - Certificate expiry crisis
      - Security breach
      - Network outage
    
  Session_5_Development_Integration:
    Duration: 2 hours
    Audience: Development teams
    Topics:
      - API usage
      - Certificate request automation
      - Code signing process
      - Best practices
    Examples:
      - PowerShell automation
      - REST API calls
      - Certificate validation
      - Error handling
```

## Project Closure

### Final Checklist

```powershell
# Complete-ProjectClosure.ps1
# Final project closure activities

Write-Host "=== PKI MODERNIZATION PROJECT CLOSURE ===" -ForegroundColor Cyan

$closureChecklist = @(
    @{Task = "All systems migrated"; Status = "Complete"},
    @{Task = "Legacy infrastructure decommissioned"; Status = "Complete"},
    @{Task = "Documentation delivered"; Status = "Complete"},
    @{Task = "Knowledge transfer completed"; Status = "Complete"},
    @{Task = "Runbooks validated"; Status = "Complete"},
    @{Task = "Monitoring configured"; Status = "Complete"},
    @{Task = "Backup procedures tested"; Status = "Complete"},
    @{Task = "DR procedures documented"; Status = "Complete"},
    @{Task = "Security review passed"; Status = "Complete"},
    @{Task = "Compliance validation"; Status = "Complete"},
    @{Task = "Performance baselines established"; Status = "Complete"},
    @{Task = "Support handover"; Status = "Complete"},
    @{Task = "Lessons learned documented"; Status = "Complete"},
    @{Task = "Project artifacts archived"; Status = "Complete"},
    @{Task = "Financial closure"; Status = "Complete"}
)

# Display checklist
Write-Host "`nProject Closure Checklist:" -ForegroundColor Yellow
foreach ($item in $closureChecklist) {
    $color = if ($item.Status -eq "Complete") {"Green"} else {"Red"}
    Write-Host "  [$(if ($item.Status -eq 'Complete') {'✓'} else {'✗'})] $($item.Task)" -ForegroundColor $color
}

# Generate closure report
$closureReport = @{
    ProjectName = "PKI Modernization"
    StartDate = "2025-02-03"
    EndDate = "2025-04-18"
    Duration = "11 weeks"
    Budget = "$500,000"
    ActualCost = "$475,000"
    
    Objectives = @{
        "Deploy modern PKI infrastructure" = "Achieved"
        "Migrate all certificates" = "Achieved"
        "Zero downtime" = "Achieved"
        "Improve performance" = "Achieved"
        "Enhance security" = "Achieved"
    }
    
    Metrics = @{
        "Devices Migrated" = "10,000"
        "Success Rate" = "99.3%"
        "Downtime" = "0 hours"
        "Performance Improvement" = "75%"
        "Cost Savings" = "40% annually"
    }
    
    Deliverables = @(
        "Azure-based Root CA",
        "2x Issuing CAs",
        "NDES/SCEP services",
        "OCSP responders",
        "Automated certificate lifecycle",
        "Comprehensive monitoring",
        "Complete documentation"
    )
    
    LessonsLearned = @(
        "Early ExpressRoute provisioning critical",
        "Pilot phase invaluable for issue identification",
        "Automation reduced migration time by 60%",
        "Communication key to user acceptance"
    )
}

$closureReport | ConvertTo-Json -Depth 10 | Out-File "C:\PKI\ProjectClosure.json"

# Sign-off
Write-Host "`n=== PROJECT SIGN-OFF ===" -ForegroundColor Cyan
Write-Host "Project Sponsor: _________________ Date: _______" -ForegroundColor Gray
Write-Host "Technical Lead: __________________ Date: _______" -ForegroundColor Gray
Write-Host "Security Officer: ________________ Date: _______" -ForegroundColor Gray
Write-Host "Operations Manager: ______________ Date: _______" -ForegroundColor Gray

Write-Host "`nProject successfully completed!" -ForegroundColor Green
Write-Host "Thank you to all team members for your dedication and hard work!" -ForegroundColor Cyan
```

## Phase 5 Deliverables

### Cutover Deliverables
- ✅ Readiness assessment report
- ✅ Cutover execution logs
- ✅ Validation test results
- ✅ DNS migration records
- ✅ Load balancer reconfiguration

### Decommissioning Deliverables
- ✅ Legacy system archives
- ✅ Final backup verification
- ✅ Decommission certificates
- ✅ CMDB updates
- ✅ Asset disposal records

### Documentation Deliverables
- ✅ Complete architecture documentation
- ✅ Operational procedures (20+ documents)
- ✅ Runbooks (15+ automated scripts)
- ✅ Network diagrams
- ✅ Security policies
- ✅ Disaster recovery plans

### Knowledge Transfer Deliverables
- ✅ Training materials
- ✅ Session recordings
- ✅ Lab exercises
- ✅ Quick reference guides
- ✅ Escalation procedures

### Project Closure
- ✅ Project closure report
- ✅ Lessons learned document
- ✅ Financial reconciliation
- ✅ Success metrics validation
- ✅ Stakeholder sign-off

---

**Document Control**
- Version: 1.0
- Last Updated: April 2025
- Status: Final
- Owner: PKI Project Team
- Classification: Confidential

---
[← Previous: Phase 4 Migration Strategy](08-phase4-migration-strategy.md) | [Back to Index](00-index.md) | [Next: Operational Procedures →](10-operational-procedures.md)