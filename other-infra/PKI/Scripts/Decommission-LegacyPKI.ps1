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
    @{Name = "LEGACY-CA-01"; Type = "Root CA" },
    @{Name = "LEGACY-CA-02"; Type = "Issuing CA" },
    @{Name = "LEGACY-CA-03"; Type = "Issuing CA" },
    @{Name = "LEGACY-OCSP-01"; Type = "OCSP Responder" }
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
            Hostname       = $env:COMPUTERNAME
            OS             = (Get-WmiObject Win32_OperatingSystem).Caption
            LastBootTime   = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            IPAddress      = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress
            Services       = Get-Service | Where-Object { $_.Name -like "*Cert*" -or $_.Name -like "*PKI*" } | Select-Object Name, Status
            InstalledRoles = Get-WindowsFeature | Where-Object { $_.Installed -and $_.Name -like "*Certificate*" }
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
    @{Name = "legacy-ca"; Type = "A" },
    @{Name = "legacy-ocsp"; Type = "A" },
    @{Name = "legacy-crl"; Type = "A" },
    @{Name = "pkiold"; Type = "CNAME" }
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
    Date                  = Get-Date
    DecommissionedServers = $legacyServers
    ArchiveLocation       = $ArchivePath
    PreservedVMs          = $PreserveVMs
    CompletedBy           = $env:USERNAME
}

$decommissionRecord | ConvertTo-Json | Out-File "$ArchivePath\DecommissionRecord.json"

# Update CMDB
Update-CMDB -Action "Decommission" -Assets $legacyServers.Name -Status "Archived"

Write-Host "`n=== LEGACY PKI DECOMMISSIONING COMPLETE ===" -ForegroundColor Green
Write-Host "Archive location: $ArchivePath" -ForegroundColor Gray
