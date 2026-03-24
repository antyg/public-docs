---
title: "How to Execute the PKI Production Cutover"
status: "draft"
last_updated: "2026-03-17"
audience: "Infrastructure Engineers"
document_type: "how-to"
platform: "PKI"
domain: "infrastructure"
---

# How to Execute the PKI Production Cutover

This guide covers the full production cutover from a legacy PKI to the new Azure-based infrastructure. It includes readiness assessment, the cutover execution sequence, DNS and load balancer migration, validation testing, legacy decommissioning, and rollback procedures.

## Prerequisites

All of the following must be satisfied before scheduling the cutover window:

- All certificate migration waves completed with at least 99.5% success rate
- Both new issuing CAs (`PKI-ICA-01`, `PKI-ICA-02`) operational and validated
- NDES/SCEP services functional and confirmed by Intune connector health check
- OCSP responders returning valid responses for both issuing CAs
- CRL distribution endpoints reachable from all network segments
- Load balancer configurations prepared but not yet applied
- DNS change requests approved and ready to execute
- Final backup of legacy CAs completed within the last 24 hours
- Rollback procedures tested in a non-production environment
- All application teams notified of the maintenance window
- Service desk briefed and staffed for increased call volume
- PKI team, network team, security team, and service desk all confirmed available

**Point of no return:** Once the legacy CA services are stopped and DNS records are updated, certificates issued by the legacy CAs cannot be renewed through the old infrastructure. Ensure the migration completion rate meets the threshold before crossing this point.

## Cutover Schedule

The standard cutover window spans two business days:

| Day | Time | Activity |
|---|---|---|
| Day 1 | 08:00–12:00 | Final readiness assessment and go/no-go decision |
| Day 1 | 12:00–17:00 | Pre-cutover snapshots, final backup verification, script staging |
| Day 1 | 18:00–20:00 | Cutover initiation: DNS updates, load balancer reconfiguration |
| Day 2 | 06:00–08:00 | Legacy CA offline transition, final certificate issuance from legacy, service switch |
| Day 2 | 08:00–17:00 | Comprehensive validation testing, application verification, performance monitoring |
| Day 3 | 09:00–17:00 | Legacy system backup, data archival, historical record preservation |
| Day 4 | 09:00–17:00 | Documentation finalisation, runbook completion |
| Day 5 | 09:00–12:00 | Knowledge transfer and operations handover |

## Step 1: Run the Readiness Assessment

Run the readiness assessment script on the morning of Day 1. Do not proceed to the go/no-go decision without a complete report.

```powershell
# Test-CutoverReadiness.ps1
param([string]$ReportPath = "C:\Cutover\ReadinessReport.html")

$overallReady   = $true
$readinessChecks = @()

# Check 1: Migration completion rate
$migrationStats   = Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Query @"
    SELECT Wave,
           COUNT(*) as Total,
           SUM(CASE WHEN Status='Completed' THEN 1 ELSE 0 END) as Completed
    FROM PKI_Migration.dbo.MigrationTracking GROUP BY Wave
"@
$total            = ($migrationStats | Measure-Object -Property Total     -Sum).Sum
$completed        = ($migrationStats | Measure-Object -Property Completed -Sum).Sum
$completionRate   = ($completed / $total) * 100

$readinessChecks += @{
    Category = "Migration Status"
    Check    = "Device Migration Complete"
    Status   = if ($completionRate -ge 99.5) { "READY" } else { "NOT READY" }
    Details  = "Completion: $([Math]::Round($completionRate,2))% ($completed/$total)"
    Critical = $true
}
if ($completionRate -lt 99.5) { $overallReady = $false }

# Check 2: PKI service health
$pkiServices = @(
    @{ Name = "Issuing CA 01";   Server = "PKI-ICA-01";  Service = "CertSvc" },
    @{ Name = "Issuing CA 02";   Server = "PKI-ICA-02";  Service = "CertSvc" },
    @{ Name = "NDES Service";    Server = "PKI-NDES-01"; Service = "W3SVC" },
    @{ Name = "OCSP Responder";  Url    = "http://ocsp.company.com.au" }
)

foreach ($svc in $pkiServices) {
    $healthy = if ($svc.Server) {
        (Get-Service -ComputerName $svc.Server -Name $svc.Service).Status -eq "Running"
    } else {
        (Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80).TcpTestSucceeded
    }
    $readinessChecks += @{
        Category = "PKI Services"; Check = $svc.Name
        Status   = if ($healthy) { "READY" } else { "NOT READY" }
        Critical = $true
    }
    if (-not $healthy) { $overallReady = $false }
}

# Check 3: Backup freshness
foreach ($backup in @("\\Backup\Legacy-PKI\","\\Backup\New-PKI\Database\")) {
    $exists  = Test-Path $backup
    $fresh   = $exists -and ((Get-Item $backup).LastWriteTime -gt (Get-Date).AddDays(-1))
    $readinessChecks += @{
        Category = "Backup & Recovery"; Check = "Backup at $backup"
        Status   = if ($fresh) { "READY" } else { "WARNING" }
        Critical = $false
    }
}

# Display summary
$notReady = $readinessChecks | Where-Object { $_.Critical -and $_.Status -ne "READY" }
Write-Host "Overall: $(if ($overallReady) {'READY FOR CUTOVER'} else {'NOT READY'})"
$notReady | ForEach-Object { Write-Host "  BLOCKER: $($_.Check) - $($_.Status)" -ForegroundColor Red }
```

**Go/no-go criteria:**
- All critical checks must show READY
- Migration completion rate must be >= 99.5%
- All PKI services must be running
- At least one backup must be fresher than 24 hours

If any critical check fails, resolve it before proceeding. Do not override with `-Force` unless you have explicit written authorisation from the security officer and PKI team lead.

## Step 2: Create the Pre-Cutover Snapshot

Before making any changes, capture the current state of all systems. This snapshot enables rollback if the cutover must be aborted:

```powershell
$snapshot = @{
    Timestamp        = Get-Date
    LegacyCAState    = Get-Service -ComputerName "LEGACY-CA-01","LEGACY-CA-02" -Name CertSvc |
                         Select-Object MachineName, Status
    NewCAState       = Get-Service -ComputerName "PKI-ICA-01","PKI-ICA-02" -Name CertSvc |
                         Select-Object MachineName, Status
    DNSRecords       = @(
        Resolve-DnsName "ca.company.com.au"   -Type A,
        Resolve-DnsName "ocsp.company.com.au" -Type CNAME,
        Resolve-DnsName "crl.company.com.au"  -Type CNAME
    )
}
$snapshot | Export-Clixml -Path "C:\Cutover\Logs\PreCutoverSnapshot.xml"
Write-Host "Snapshot saved to C:\Cutover\Logs\PreCutoverSnapshot.xml"
```

Confirm the snapshot file exists and contains the expected server states before proceeding.

## Step 3: Notify Stakeholders

Send the cutover commencement notification:

```powershell
Send-MailMessage `
    -To @("it-all@company.com.au","management@company.com.au","servicedesk@company.com.au") `
    -Subject "[PKI Cutover] Commencing now - estimated duration 2 hours" `
    -Body "PKI Cutover commencing. All certificate services will remain available throughout. Estimated completion: $(Get-Date (Get-Date).AddHours(2) -Format 'HH:mm')." `
    -SmtpServer "smtp.company.com.au"
```

## Step 4: Stop Legacy Certificate Issuance

Stop the `CertSvc` service on all legacy CAs and set startup type to Disabled to prevent accidental restart. Export a final CRL from each before stopping:

```powershell
$legacyCAs = @("LEGACY-CA-01", "LEGACY-CA-02")

foreach ($ca in $legacyCAs) {
    Invoke-Command -ComputerName $ca -ScriptBlock {
        # Publish a final CRL before going offline
        certutil -CRL

        # Stop and disable the CA service
        Stop-Service -Name CertSvc -Force
        Set-Service  -Name CertSvc -StartupType Disabled

        # Take a final backup
        $backupPath = "\\Backup\Legacy-PKI\$env:COMPUTERNAME-Final"
        New-Item -ItemType Directory -Path $backupPath -Force
        Backup-CARoleService -Path $backupPath -DatabaseOnly

        Write-Host "$env:COMPUTERNAME: CertSvc stopped and disabled. Final backup at $backupPath"
    }
}
```

Verify services are stopped:

```powershell
foreach ($ca in $legacyCAs) {
    $status = (Get-Service -ComputerName $ca -Name CertSvc).Status
    Write-Host "$ca CertSvc: $status"
}
```

## Step 5: Update DNS Records

Update DNS to point PKI service names at the new infrastructure. TTL is set to 5 minutes to allow rapid rollback if needed:

```powershell
$dnsUpdates = @(
    @{ Name = "ca";   Type = "A";     NewValue = "10.50.1.10"; OldValue = "10.40.1.10" },
    @{ Name = "ocsp"; Type = "CNAME"; NewValue = "pki-ocsp-01.company.com.au"; OldValue = "legacy-ocsp.company.com.au" },
    @{ Name = "crl";  Type = "CNAME"; NewValue = "pki-crl.company.com.au";     OldValue = "legacy-crl.company.com.au" },
    @{ Name = "pki";  Type = "A";     NewValue = "10.50.1.10"; OldValue = "10.40.1.10" }
)

foreach ($record in $dnsUpdates) {
    Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
        -Name $record.Name -RRType $record.Type -Force

    if ($record.Type -eq "A") {
        Add-DnsServerResourceRecordA -ZoneName "company.com.au" `
            -Name $record.Name -IPv4Address $record.NewValue -TimeToLive 00:05:00
    } else {
        Add-DnsServerResourceRecordCName -ZoneName "company.com.au" `
            -Name $record.Name -HostNameAlias $record.NewValue -TimeToLive 00:05:00
    }
    Write-Host "Updated DNS: $($record.Name) -> $($record.NewValue)"
}

# Flush DNS cache on all domain controllers
Get-ADDomainController -Filter * | ForEach-Object {
    Invoke-Command -ComputerName $_.HostName -ScriptBlock { Clear-DnsServerCache }
}
```

## Step 6: Reconfigure Load Balancers

Switch load balancer backend pools from legacy CA servers to the new issuing CAs:

**NetScaler:**

```powershell
Update-NetScalerVirtualServer -VServer "VS_PKI_Services" `
    -BackendServers @("10.50.1.10:443","10.50.1.11:443") `
    -RemoveServers  @("10.40.1.10:443","10.40.1.11:443")
```

**F5 BIG-IP:**

```powershell
Update-F5Pool -Pool "pool_pki_services" `
    -Members       @(@{Address="10.50.1.10";Port=443},@{Address="10.50.1.11";Port=443}) `
    -RemoveMembers @(@{Address="10.40.1.10";Port=443},@{Address="10.40.1.11";Port=443})
```

Confirm the new pool members show as Active in the load balancer management console before proceeding.

## Step 7: Update Group Policy

Update the PKI auto-enrolment GPOs to reference the new CA:

```powershell
Set-GPRegistryValue -Name "PKI-AutoEnrollment" `
    -Key "HKLM\Software\Policies\Microsoft\SystemCertificates" `
    -ValueName "CertificateServices\CAServer" `
    -Value "PKI-ICA-01.company.local" -Type String

Set-GPRegistryValue -Name "PKI-TrustedRoots" `
    -Key "HKLM\Software\Policies\Microsoft\SystemCertificates" `
    -ValueName "CertificateServices\TrustedRoot" `
    -Value "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt" -Type String

# Force GP update across a sample of workstations to confirm propagation
Invoke-Command -ComputerName (Get-ADComputer -Filter * | Select-Object -First 20).Name -ScriptBlock {
    gpupdate /force
} -ThrottleLimit 10
```

## Step 8: Run Cutover Validation Tests

Run all validation tests before declaring the cutover successful. All tests must pass:

```powershell
$validationTests = @(
    @{
        Name = "New CA Accessibility"
        Test = { Test-NetConnection -ComputerName "PKI-ICA-01" -Port 443 |
                   Select-Object -ExpandProperty TcpTestSucceeded }
    },
    @{
        Name = "Certificate Enrolment"
        Test = {
            $c = Get-Certificate -Template "Company-Computer-Authentication" `
                -CertStoreLocation "Cert:\LocalMachine\My" `
                -Url "https://pki-ica-01.company.local/certsrv"
            $c.Status -eq "Issued"
        }
    },
    @{
        Name = "OCSP Response"
        Test = { (Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80).TcpTestSucceeded }
    },
    @{
        Name = "CRL Download"
        Test = { (Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl").StatusCode -eq 200 }
    },
    @{
        Name = "DNS Resolution for PKI Services"
        Test = { [bool](Resolve-DnsName "ca.company.com.au" -Type A -ErrorAction SilentlyContinue) }
    }
)

$allPassed = $true
foreach ($test in $validationTests) {
    try {
        $result = & $test.Test
        Write-Host "$($test.Name): $(if ($result) {'PASSED'} else {'FAILED'})" `
            -ForegroundColor $(if ($result) {"Green"} else {"Red"})
        if (-not $result) { $allPassed = $false }
    } catch {
        Write-Host "$($test.Name): FAILED - $_" -ForegroundColor Red
        $allPassed = $false
    }
}

if (-not $allPassed) {
    Write-Host "`nVALIDATION FAILED. Initiating rollback." -ForegroundColor Red
    # See rollback procedure below
}
```

## Step 9: Decommission the Legacy PKI

Only proceed with decommissioning after the validation tests pass and a 24-hour observation period has confirmed stable operations.

```powershell
param(
    [string]$ArchivePath = "\\Archive\Legacy-PKI",
    [switch]$PreserveVMs = $false
)

$confirm = Read-Host "Type 'DECOMMISSION' to proceed"
if ($confirm -ne "DECOMMISSION") { return }

$legacyServers = @(
    @{ Name = "LEGACY-CA-01"; Type = "Root CA" },
    @{ Name = "LEGACY-CA-02"; Type = "Issuing CA" },
    @{ Name = "LEGACY-CA-03"; Type = "Issuing CA" },
    @{ Name = "LEGACY-OCSP-01"; Type = "OCSP Responder" }
)

foreach ($server in $legacyServers) {
    $serverArchive = "$ArchivePath\$($server.Name)"
    New-Item -ItemType Directory -Path $serverArchive -Force

    Invoke-Command -ComputerName $server.Name -ScriptBlock {
        param($archivePath)

        # Export CA database
        if (Test-Path "C:\Windows\System32\CertLog") {
            Copy-Item "C:\Windows\System32\CertLog" "$archivePath\CertLog" -Recurse -Force
        }

        # Export registry settings
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc" `
            "$archivePath\CertSvc-Registry.reg" /y

        # Export all local machine certificates
        Get-ChildItem Cert:\LocalMachine\My | ForEach-Object {
            Export-Certificate -Cert $_ -FilePath "$archivePath\$($_.Thumbprint).cer"
        }

        # Capture system information
        @{
            Hostname    = $env:COMPUTERNAME
            OS          = (Get-WmiObject Win32_OperatingSystem).Caption
            IPAddresses = (Get-NetIPAddress -AddressFamily IPv4 |
                            Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress
        } | ConvertTo-Json | Set-Content "$archivePath\SystemInfo.json"

    } -ArgumentList $serverArchive
}
```

### Remove Legacy PKI Entries from Active Directory

Archive the AD PKI objects before removal:

```powershell
$configDN = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
$pkiContainer = [ADSI]"LDAP://CN=Public Key Services,CN=Services,$configDN"

# Archive
$pkiContainer.Children | Export-Clixml -Path "$ArchivePath\AD-PKI-Objects.xml"

# Remove legacy CA entries
foreach ($entry in @("CN=Legacy Root CA","CN=Legacy Issuing CA 01","CN=Legacy Issuing CA 02")) {
    try {
        $obj = [ADSI]"LDAP://$entry,CN=Certification Authorities,$($pkiContainer.distinguishedName)"
        $obj.DeleteTree()
        Write-Host "Removed $entry from Active Directory"
    } catch {
        Write-Host "Could not remove $entry : $_" -ForegroundColor Yellow
    }
}
```

### Remove Legacy DNS Records

```powershell
foreach ($record in @(
    @{Name="legacy-ca";   Type="A"},
    @{Name="legacy-ocsp"; Type="A"},
    @{Name="legacy-crl";  Type="A"},
    @{Name="pkiold";      Type="CNAME"}
)) {
    Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
        -Name $record.Name -RRType $record.Type -Force -ErrorAction SilentlyContinue
    Write-Host "Removed DNS record: $($record.Name)"
}
```

### Shut Down Legacy Servers

```powershell
if (-not $PreserveVMs) {
    foreach ($server in $legacyServers) {
        # Take a final VM snapshot before shutdown
        Checkpoint-VM -Name $server.Name -SnapshotName "Final-Before-Decommission" `
            -ErrorAction SilentlyContinue

        Stop-Computer  -ComputerName $server.Name -Force
        Remove-ADComputer -Identity $server.Name -Confirm:$false
        Write-Host "$($server.Name) decommissioned"
    }
}
```

## Rollback Procedure

If the cutover validation fails, execute rollback immediately. Rollback reverses DNS, load balancer, and GPO changes, and restarts legacy CA services.

### When to Invoke Rollback

- Any critical validation test fails after DNS cutover
- Application owners report certificate authentication failures
- The PKI team lead determines the new infrastructure is not stable

### Execute Rollback

```powershell
# Restore DNS to legacy CAs
$rollbackDNS = @(
    @{ Name = "ca";   Type = "A";     Value = "10.40.1.10" },
    @{ Name = "ocsp"; Type = "CNAME"; Value = "legacy-ocsp.company.com.au" },
    @{ Name = "crl";  Type = "CNAME"; Value = "legacy-crl.company.com.au" },
    @{ Name = "pki";  Type = "A";     Value = "10.40.1.10" }
)

foreach ($record in $rollbackDNS) {
    Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
        -Name $record.Name -RRType $record.Type -Force

    if ($record.Type -eq "A") {
        Add-DnsServerResourceRecordA -ZoneName "company.com.au" `
            -Name $record.Name -IPv4Address $record.Value
    } else {
        Add-DnsServerResourceRecordCName -ZoneName "company.com.au" `
            -Name $record.Name -HostNameAlias $record.Value
    }
}

# Flush DNS cache
Get-ADDomainController -Filter * | ForEach-Object {
    Invoke-Command -ComputerName $_.HostName -ScriptBlock { Clear-DnsServerCache }
}

# Re-enable and restart legacy CAs
foreach ($ca in @("LEGACY-CA-01","LEGACY-CA-02")) {
    Invoke-Command -ComputerName $ca -ScriptBlock {
        Set-Service  -Name CertSvc -StartupType Automatic
        Start-Service -Name CertSvc
        Write-Host "$env:COMPUTERNAME: CertSvc restarted"
    }
}

# Restore load balancer pools to legacy CAs
Update-NetScalerVirtualServer -VServer "VS_PKI_Services" `
    -BackendServers @("10.40.1.10:443","10.40.1.11:443") `
    -RemoveServers  @("10.50.1.10:443","10.50.1.11:443")

Write-Host "Rollback complete. Validate legacy CA services before notifying stakeholders."
```

After rollback, run the legacy CA validation checks, notify stakeholders, and schedule a post-mortem before reattempting the cutover.

## Operational Handover

After successful cutover and the 24-hour observation period, complete the operational handover:

1. Update the CMDB to reflect the new PKI infrastructure
2. Archive all cutover logs and validation reports in the PKI document store
3. Update monitoring dashboards to reflect new server names and alert thresholds
4. Remove legacy CA entries from backup jobs
5. Schedule the first post-cutover full backup of the new CAs
6. Confirm on-call rotation covers PKI for the first 4 weeks post-cutover
7. Obtain formal sign-off from the project sponsor, technical lead, security officer, and operations manager

## Validation

Confirm a healthy post-cutover state by running a daily health check (see [how-to-operate-pki.md](how-to-operate-pki.md)) on the morning after cutover and comparing results against the baseline established during Phase 2 testing.

## Troubleshooting

**Certificate enrolment fails immediately after DNS cutover**
Clients may still be resolving the old DNS name from cache. Wait for TTL expiry (5 minutes with the TTL set during cutover), or run `ipconfig /flushdns` on affected clients. If failures persist after TTL expiry, check that the DNS update completed on all domain controllers.

**Legacy CA service will not restart during rollback**
Check the Windows Application event log for errors. If the service database is locked, restart the server. If the service was set to Disabled as part of the cutover, set it back to Automatic before attempting to start: `Set-Service -Name CertSvc -StartupType Automatic`.

**Load balancer not routing to new CAs**
Confirm the new CA servers are passing the load balancer health check. Check that port 443 is accepting connections on both `PKI-ICA-01` and `PKI-ICA-02`. Review the load balancer event log for pool member state transitions.

**Group Policy not pointing to new CA**
Run `gpupdate /force` on an affected workstation and then `gpresult /R` to confirm the updated GPO is applied. If the GPO is not being received, check that the GPO link is enabled and the workstation OU is within the link's scope.

## Related Resources

- [AD CS CA configuration with certutil](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certutil)
- [AD CS backup and restore](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/back-up-and-restore-the-certification-authority)
- [Azure Private CA overview](https://learn.microsoft.com/en-us/azure/private-ca/overview)
- [Windows DNS Server cmdlets](https://learn.microsoft.com/en-us/powershell/module/dnsserver/)
- [Group Policy PowerShell cmdlets](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [PSPF — Protective Security Policy Framework](https://www.protectivesecurity.gov.au/)
