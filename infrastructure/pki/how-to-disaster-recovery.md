---
title: "How to Execute PKI Disaster Recovery"
status: "draft"
last_updated: "2026-03-17"
audience: "Infrastructure Engineers"
document_type: "how-to"
domain: "infrastructure"
platform: "PKI"
---

# How to Execute PKI Disaster Recovery

This guide covers recovering the PKI infrastructure from failure scenarios ranging from a single issuing CA outage to a complete primary site loss or root CA compromise. It also covers DR testing protocols and business continuity procedures during a PKI outage.

## Recovery Objectives

| Component | Recovery Point Objective (RPO) | Recovery Time Objective (RTO) |
|---|---|---|
| Root CA | 24 hours | 72 hours |
| Issuing CAs | 1 hour | 4 hours |
| OCSP Services | 15 minutes | 1 hour |
| CRL Distribution | 1 hour | 2 hours |
| Certificate Database | 1 hour | 4 hours |
| Key Vault (HSM) | Real-time (geo-replicated) | 1 hour |

These objectives are aligned with [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requirements for mission-critical cryptographic infrastructure. If your organisation is subject to the [PSPF](https://www.protectivesecurity.gov.au/), review the protective marking requirements for recovery documentation.

## DR Architecture

The PKI DR architecture uses geo-replicated components across Australia East (primary) and Australia Southeast (DR site):

```mermaid
graph TB
    subgraph "Primary Site - Australia East"
        PROD_ROOT[Azure Private CA<br/>Root CA]
        PROD_KV[Key Vault<br/>Primary HSM]
        PROD_ICA1[Issuing CA 01<br/>Active]
        PROD_ICA2[Issuing CA 02<br/>Active]
        PROD_SQL[SQL Cluster<br/>Primary]
    end

    subgraph "DR Site - Australia Southeast"
        DR_ROOT[Azure Private CA<br/>Standby]
        DR_KV[Key Vault<br/>Replicated HSM]
        DR_ICA3[Issuing CA 03<br/>Standby]
        DR_SQL[SQL Cluster<br/>Secondary]
    end

    subgraph "Backup Infrastructure"
        VAULT[Recovery Services Vault]
        STORAGE[Backup Storage<br/>GRS]
        ARCHIVE[Long-term Archive<br/>Cool Storage]
    end

    PROD_ROOT -.->|Geo-replication| DR_ROOT
    PROD_KV   -.->|Auto-failover|   DR_KV
    PROD_SQL  -.->|Always On AG|    DR_SQL
    PROD_ICA1 -->|Backup| VAULT
    PROD_ICA2 -->|Backup| VAULT
    VAULT -->|Daily|   STORAGE
    STORAGE -->|Monthly| ARCHIVE
```

## Scenario 1: Single Issuing CA Failure

A single issuing CA failure is handled by the load balancer — traffic continues to the surviving CA. This scenario covers restoring the failed CA to full operation.

### Detect the Failure

```powershell
function Test-CAAvailability {
    param([string]$CAServer)

    $tests = @{
        ServiceRunning     = $false
        NetworkReachable   = $false
        CertificateIssuance = $false
        DatabaseAccessible = $false
    }

    $tests.NetworkReachable   = (Test-Connection -ComputerName $CAServer -Count 2 -Quiet)
    $tests.ServiceRunning     = try {
        (Get-Service -ComputerName $CAServer -Name CertSvc -ErrorAction Stop).Status -eq "Running"
    } catch { $false }
    $tests.DatabaseAccessible = try {
        Invoke-Command -ComputerName $CAServer -ScriptBlock {
            Test-Path "C:\Windows\System32\CertLog\company.edb"
        } -ErrorAction Stop
    } catch { $false }
    $tests.CertificateIssuance = if ($tests.ServiceRunning) {
        try {
            (Get-Certificate -Template "Company-Computer-Authentication" `
                -CertStoreLocation "Cert:\LocalMachine\My" `
                -Url "https://$CAServer/certsrv" -ErrorAction Stop).Status -eq "Issued"
        } catch { $false }
    } else { $false }

    $failureType = if (-not $tests.NetworkReachable)    { "Network" }
                  elseif (-not $tests.ServiceRunning)   { "Service" }
                  elseif (-not $tests.DatabaseAccessible) { "Database" }
                  elseif (-not $tests.CertificateIssuance) { "Issuance" }
                  else { "None" }

    return @{ Status = if ($failureType -eq "None") {"Healthy"} else {"Failed"}
              Type = $failureType; Tests = $tests }
}
```

### Recover Based on Failure Type

**Service failure (CA service stopped or crashed):**

```powershell
function Recover-CAServiceFailure {
    param([string]$FailedCA)

    # Attempt service restart
    try {
        Restart-Service -ComputerName $FailedCA -Name CertSvc -Force
        Start-Sleep -Seconds 15
        if ((Get-Service -ComputerName $FailedCA -Name CertSvc).Status -eq "Running") {
            Write-Host "$FailedCA: Service recovered by restart" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "$FailedCA: Service restart failed — $_" -ForegroundColor Red
    }

    # Check and start dependencies
    foreach ($dep in @("RPCSS","EventLog","W32Time")) {
        $depSvc = Get-Service -ComputerName $FailedCA -Name $dep -ErrorAction SilentlyContinue
        if ($depSvc -and $depSvc.Status -ne "Running") {
            Start-Service -ComputerName $FailedCA -Name $dep
            Write-Host "$FailedCA: Started dependency $dep"
        }
    }

    # Retry service start after dependencies
    Start-Service -ComputerName $FailedCA -Name CertSvc -ErrorAction SilentlyContinue
    $status = (Get-Service -ComputerName $FailedCA -Name CertSvc).Status
    Write-Host "$FailedCA: CertSvc status after dependency check: $status"
    return $status -eq "Running"
}
```

**Database failure (ESENT corruption):**

```powershell
function Recover-CADatabaseFailure {
    param([string]$FailedCA, [string]$BackupPath)

    Stop-Service -ComputerName $FailedCA -Name CertSvc -Force

    $repairResult = Invoke-Command -ComputerName $FailedCA -ScriptBlock {
        # Check database integrity
        $integrity = esentutl /g "C:\Windows\System32\CertLog\company.edb"

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Database integrity check failed — attempting repair"
            esentutl /p "C:\Windows\System32\CertLog\company.edb" /o

            if ($LASTEXITCODE -ne 0) {
                Write-Host "Repair failed — restore from backup required"
                return "RestoreRequired"
            }
            return "Repaired"
        }
        return "Healthy"
    }

    if ($repairResult -eq "RestoreRequired") {
        # Find the most recent valid backup
        $latestBackup = Get-ChildItem "$BackupPath\$FailedCA\*\Database" |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if ($latestBackup) {
            Invoke-Command -ComputerName $FailedCA -ScriptBlock {
                param($backupDb)
                Copy-Item "$backupDb\*.edb" "C:\Windows\System32\CertLog\" -Force
                Copy-Item "$backupDb\*.log" "C:\Windows\System32\CertLog\" -Force
                Write-Host "Database restored from backup"
            } -ArgumentList $latestBackup.FullName
        } else {
            throw "No valid backup found at $BackupPath\$FailedCA — manual intervention required"
        }
    }

    Start-Service -ComputerName $FailedCA -Name CertSvc
    Write-Host "$FailedCA: CertSvc restarted after database recovery"
}
```

**Network failure:** Redirect load balancer traffic to the surviving CA immediately, then raise a network incident for the infrastructure team. Re-add the recovered CA to the load balancer pool once network connectivity is restored and a full availability test passes.

### Validate Recovery

```powershell
$verification = Test-CAAvailability -CAServer $FailedCA
if ($verification.Status -eq "Healthy") {
    Write-Host "$FailedCA recovered — all checks pass" -ForegroundColor Green
    # Re-add to load balancer pool
    Update-NetScalerVirtualServer -VServer "VS_PKI_Services" -AddServer "$($FailedCA -replace 'PKI-ICA-0','10.50.1.1'):443"
} else {
    Write-Host "$FailedCA recovery incomplete — failure type: $($verification.Type)" -ForegroundColor Red
    Write-Host "Escalate to PKI team lead. Consider failing over to DR site."
}
```

## Scenario 2: Complete Primary Site Failure

A complete primary site failure requires activating the DR site in Australia Southeast. This procedure requires written authorisation from the PKI team lead or security officer.

```powershell
function Start-CompleteSiteFailover {
    param(
        [switch]$Emergency = $false,
        [string]$AuthorisedBy
    )

    if (-not $Emergency) {
        $confirm = Read-Host "Type 'FAILOVER' to proceed with complete site failover"
        if ($confirm -ne "FAILOVER") {
            Write-Host "Failover cancelled" -ForegroundColor Yellow
            return
        }
    }

    Write-Host "=== SITE FAILOVER INITIATED ===" -ForegroundColor Red
    Write-Host "Authorised by: $AuthorisedBy  Time: $(Get-Date)"

    # Step 1: Fail over Azure Key Vault to DR region
    Start-AzKeyVaultFailover -VaultName "KV-PKI-RootCA-Prod"
    Write-Host "Key Vault failover initiated"

    # Step 2: Activate standby Private CA in Australia Southeast
    Set-AzPrivateCA -Name "Company-Root-CA-G2" -Location "australiasoutheast" -Status "Active"
    Write-Host "Azure Private CA activated in DR site"

    # Step 3: Start the DR issuing CA
    Start-VM -Name "PKI-ICA-03-DR"
    # Allow 5 minutes for VM to boot and services to start
    $timeout = (Get-Date).AddMinutes(5)
    do { Start-Sleep -Seconds 15
    } while ((Get-Service -ComputerName "PKI-ICA-03" -Name CertSvc -ErrorAction SilentlyContinue).Status `
             -ne "Running" -and (Get-Date) -lt $timeout)
    Write-Host "DR Issuing CA started"

    # Step 4: Fail over SQL Always On Availability Group
    Invoke-SqlCmd -ServerInstance "SQL-DR-CLUSTER" -Query "ALTER AVAILABILITY GROUP [PKI-AG] FAILOVER;"
    Write-Host "SQL Always On AG failed over to DR"

    # Step 5: Update DNS to DR site IPs (TTL 5 minutes for rapid rollback)
    foreach ($record in @(
        @{Name="pki";  NewIP="10.51.1.10"},
        @{Name="ca";   NewIP="10.51.1.10"},
        @{Name="ocsp"; NewIP="10.51.1.30"}
    )) {
        Remove-DnsServerResourceRecord -ZoneName "company.com.au" `
            -Name $record.Name -RRType "A" -Force
        Add-DnsServerResourceRecordA -ZoneName "company.com.au" `
            -Name $record.Name -IPv4Address $record.NewIP -TimeToLive 00:05:00
    }
    Write-Host "DNS updated to DR site"

    # Step 6: Update load balancers to DR backends
    Update-NetScalerVirtualServer -VServer "VS_PKI_Services" `
        -BackendServers @("10.51.1.10:443","10.51.1.11:443")
    Update-F5Pool -Pool "pool_pki_services" `
        -Members @(@{Address="10.51.1.10";Port=443},@{Address="10.51.1.11";Port=443})
    Write-Host "Load balancers updated to DR site"

    # Step 7: Validate DR site
    $drChecks = @(
        (Test-NetConnection "10.51.1.10" -Port 443).TcpTestSucceeded,
        (Test-NetConnection "ocsp.company.com.au" -Port 80).TcpTestSucceeded,
        ((Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl" -ErrorAction SilentlyContinue).StatusCode -eq 200)
    )

    if ($drChecks -notcontains $false) {
        Write-Host "DR SITE FAILOVER COMPLETED SUCCESSFULLY" -ForegroundColor Green
        Send-MailMessage -To @("management@company.com.au","it-all@company.com.au") `
            -Subject "[PKI DR] Failover to Australia Southeast completed" `
            -Body "PKI services are now running from the DR site. All services validated." `
            -SmtpServer "smtp.company.com.au"
    } else {
        Write-Host "DR site validation FAILED — investigate before declaring success" -ForegroundColor Red
    }
}
```

## Scenario 3: Root CA Compromise

A root CA compromise is a critical security incident. Act immediately — do not wait for confirmation.

### Immediate Containment Steps

1. **Isolate the compromised CA** — block all network access to the root CA server at the firewall level
2. **Revoke all certificates issued by the compromised CA** — this invalidates the entire certificate hierarchy
3. **Publish an emergency CRL** — distribute immediately to all accessible CRL distribution points
4. **Notify the security team and management** — this is a reportable incident under the [PSPF](https://www.protectivesecurity.gov.au/) if government systems are affected

```powershell
# CRITICAL: Execute in sequence without interruption
function Start-RootCACompromiseRecovery {
    Write-Host "=== CRITICAL: ROOT CA COMPROMISE RECOVERY ===" -ForegroundColor Red

    # 1. Block network access to root CA
    # Execute firewall block via network team — this cannot be scripted safely
    Write-Host "ACTION REQUIRED: Contact network team immediately to block PKI-ROOT-CA from all networks"

    # 2. Revoke all certificates issued by the compromised root
    $compromisedCerts = certutil -view -restrict "Issuer=Company Root CA G2,Disposition=20" `
        -out "SerialNumber" csv | Select-String -Pattern "^[0-9a-f]"

    foreach ($line in $compromisedCerts) {
        $serial = $line.ToString().Trim().Trim('"')
        certutil -revoke $serial "CACompromise"
    }

    # 3. Publish emergency CRL
    foreach ($ca in @("PKI-ICA-01","PKI-ICA-02")) {
        Invoke-Command -ComputerName $ca -ScriptBlock { certutil -CRL }
    }
    Write-Host "Emergency CRL published on all issuing CAs"

    # 4. Preserve forensic evidence — do not modify any files on the compromised CA
    Write-Host "ACTION REQUIRED: Initiate forensic imaging of PKI-ROOT-CA before any further changes"

    Write-Host "`nNext step: Deploy Emergency Root CA (see Step 5 below)"
}
```

### Deploy a New Root CA

After containment and forensic preservation, deploy a new root CA:

```powershell
# Generate a new root CA key in HSM — this requires two PKI administrators present
# The key ceremony must be documented (see how-to-deploy-foundation.md, Step 6)

# After new root CA is operational, re-issue all subordinate CAs
foreach ($ca in @("PKI-ICA-01","PKI-ICA-02","PKI-ICA-03")) {
    # Generate new CA CSR
    Invoke-Command -ComputerName $ca -ScriptBlock {
        Stop-Service CertSvc
        # Remove old CA certificate and request new one from the new root
        # This requires manual steps in the CA management console
        certutil -setreg CA\CACertHash ""
        # Submit new CSR to the new root CA via Azure Private CA portal
    }
}
```

### Deploy New Root to All Endpoints

Push the new root CA certificate to all managed devices immediately via an emergency GPO:

```powershell
# Create a high-priority GPO to distribute the new root certificate
$emergencyGPO = New-GPO -Name "PKI-Emergency-Root-Certificate" -Comment "Emergency root CA replacement"

# Link at the domain level with highest priority to ensure rapid propagation
New-GPLink -Name $emergencyGPO.DisplayName -Target "DC=company,DC=local" -LinkEnabled Yes -Order 1

# Force GP update across all reachable machines
Invoke-Command -ComputerName (Get-ADComputer -Filter * | Select-Object -First 500).Name -ScriptBlock {
    gpupdate /force
} -ThrottleLimit 50 -ErrorAction SilentlyContinue

Write-Host "Emergency GPO created and linked. Allow up to 90 minutes for full propagation."
```

If devices are managed by Intune, deploy the new root certificate as a Trusted Certificate profile through the [Intune admin centre](https://intune.microsoft.com) under Devices > Configuration profiles.

## Scenario 4: Ransomware Attack

A ransomware attack affecting PKI servers requires isolation before any recovery steps.

### Isolate Affected Systems

```powershell
function Isolate-CompromisedPKIServers {
    param([string[]]$AffectedServers)

    foreach ($server in $AffectedServers) {
        # Disable all network adapters on the affected server
        Invoke-Command -ComputerName $server -ScriptBlock {
            Get-NetAdapter | Disable-NetAdapter -Confirm:$false
            Get-Service | Stop-Service -Force
            Write-Host "$env:COMPUTERNAME: Network disabled and services stopped"
        } -ErrorAction SilentlyContinue

        Write-Host "$server isolated"
    }
    Write-Host "All affected servers isolated. Do NOT reconnect until forensic imaging is complete."
}
```

### Restore from Clean Backups

```powershell
function Restore-PKIFromBackup {
    param(
        [string]$Server,
        [datetime]$AttackTime,
        [string]$BackupPath = "\\Backup\PKI\CA"
    )

    # Find the last clean backup before the attack
    $cleanBackup = Get-ChildItem "$BackupPath\$Server\*" |
        Where-Object { $_.LastWriteTime -lt $AttackTime } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $cleanBackup) {
        throw "No pre-attack backup found for $Server at $BackupPath. Manual rebuild required."
    }

    Write-Host "Restoring $Server from backup: $($cleanBackup.Name) ($(($AttackTime - $cleanBackup.LastWriteTime).TotalHours.ToString('F1')) hours before attack)"

    # Restore CA database
    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($backupFolder)
        Stop-Service CertSvc -Force

        # Restore database files
        Copy-Item "$backupFolder\Database\*.edb" "C:\Windows\System32\CertLog\" -Force
        Copy-Item "$backupFolder\Database\*.log" "C:\Windows\System32\CertLog\" -Force

        # Verify database integrity
        $result = esentutl /g "C:\Windows\System32\CertLog\company.edb"
        if ($LASTEXITCODE -ne 0) {
            throw "Database integrity check failed after restore"
        }

        # Restore configuration
        reg import "$backupFolder\CertSvc-Registry.reg"

        Start-Service CertSvc
        Write-Host "CA service restarted after restore"
    } -ArgumentList $cleanBackup.FullName
}
```

After restoration, revoke any certificates that may have been issued between the attack time and the restore point, as those issuances may have been attacker-initiated:

```powershell
# Revoke certificates issued during the attack window
$suspectCerts = certutil -view -restrict "NotBefore>=$($AttackTime.ToString('MM/dd/yyyy HH:mm'))" `
    -out "SerialNumber,Requester" csv

foreach ($line in $suspectCerts | Select-String "^[0-9a-f]") {
    $serial = $line.ToString().Split(',')[0].Trim().Trim('"')
    certutil -revoke $serial "KeyCompromise"
    Write-Host "Revoked suspect certificate: $serial"
}
certutil -CRL
```

## CA Database Backup and Restoration

### Restore CA Database Component

```powershell
function Restore-PKIComponent {
    param(
        [ValidateSet("Database","Configuration","Templates","CompleteCA")]
        [string]$Component,
        [string]$Server,
        [string]$BackupPath,
        [datetime]$PointInTime
    )

    $backup = Get-ChildItem "$BackupPath\$Server\*" |
        Where-Object { $_.LastWriteTime -le $PointInTime } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $backup) {
        throw "No backup found at or before $PointInTime"
    }

    switch ($Component) {
        "Database" {
            Stop-Service -ComputerName $Server -Name CertSvc
            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($backupFiles)
                # Preserve current database before overwriting
                Copy-Item "C:\Windows\System32\CertLog\*" "E:\CertData\PreRestore" -Recurse -Force

                Copy-Item "$backupFiles\Database\*.edb" "C:\Windows\System32\CertLog\" -Force
                Copy-Item "$backupFiles\Database\*.log" "C:\Windows\System32\CertLog\" -Force

                esentutl /g "C:\Windows\System32\CertLog\company.edb"
                if ($LASTEXITCODE -ne 0) { throw "Database integrity check failed after restore" }
            } -ArgumentList $backup.FullName
            Start-Service -ComputerName $Server -Name CertSvc
        }

        "Configuration" {
            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($configBackup)
                reg import "$configBackup\CertSvc-Registry.reg"
                certutil -restoreCA "$configBackup"
            } -ArgumentList $backup.FullName
            Restart-Service -ComputerName $Server -Name CertSvc
        }

        "Templates" {
            # Restore templates from CSV export
            $templates = Import-Csv "$($backup.FullName)\Templates.csv" -ErrorAction SilentlyContinue
            if ($templates) {
                Write-Host "Template list backup found — manual re-creation may be required for full restore"
                $templates | Format-Table Name, DisplayName -AutoSize
            }
            # Force AD replication to propagate any template changes
            (Get-ADDomainController -Filter *) | ForEach-Object {
                repadmin /syncall $_.HostName /AeD
            }
        }

        "CompleteCA" {
            Write-Host "Complete CA restoration — stopping all services"
            Stop-Service -ComputerName $Server -Name CertSvc,W3SVC -Force

            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($fullBackup)
                wbadmin start recovery -version:$fullBackup `
                    -itemType:App -items:CertificateServices `
                    -recoverytarget:originallocation -quiet
            } -ArgumentList $backup.Name

            # Then restore database and configuration on top
            Restore-PKIComponent -Component "Database"      -Server $Server -BackupPath $BackupPath -PointInTime $PointInTime
            Restore-PKIComponent -Component "Configuration" -Server $Server -BackupPath $BackupPath -PointInTime $PointInTime

            Start-Service -ComputerName $Server -Name CertSvc,W3SVC
        }
    }

    # Log restoration event
    @{
        Date        = Get-Date
        Server      = $Server
        Component   = $Component
        BackupUsed  = $backup.FullName
        PointInTime = $PointInTime
        Success     = $true
    } | Export-Csv -Path "C:\DR\RestoreLog.csv" -Append -NoTypeInformation

    Write-Host "Restoration of $Component on $Server completed"
}
```

## DR Testing Protocols

DR testing must be performed at a minimum quarterly, as required by the [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) for critical infrastructure.

### Tabletop Exercise (Monthly)

Walk the DR team through each failure scenario using the documented procedures. Record:
- Expected RTO for each scenario based on current procedures
- Any gaps in the documented steps
- Team members who are unclear on their responsibilities
- Dependencies on third parties (Azure support, hardware vendors)

No systems are changed during a tabletop exercise.

### Partial Failover Test (Quarterly)

Test failover in an isolated environment using cloned VMs:

```powershell
function Start-PartialDRTest {
    param([string]$TestCoordinator)

    Write-Host "=== PARTIAL DR TEST ===" -ForegroundColor Cyan
    Write-Host "Coordinator: $TestCoordinator  Date: $(Get-Date -Format 'yyyy-MM-dd')"

    # Create an isolated test network to avoid impacting production
    # Clone PKI-ICA-01 and PKI-ICA-02 to the test network
    # Simulate failure of the first clone
    # Execute the single CA recovery procedure (Scenario 1)
    # Measure the time taken from failure detection to service restoration
    # Compare against the 4-hour RTO target
    # Clean up test environment

    $testResult = @{
        TestType        = "Partial"
        Coordinator     = $TestCoordinator
        Date            = Get-Date
        Scenario        = "Single CA Failure"
        TargetRTO       = "4 hours"
        # ActualRTO populated after test
        Issues          = @()
    }

    # Record and report test results
    $testResult | ConvertTo-Json | Set-Content "C:\DR\Tests\DRTest-$(Get-Date -Format 'yyyyMMdd').json"
    Write-Host "Test results saved. Review Issues array for improvement areas."
}
```

### Full Failover Test (Annually)

A full failover test requires a scheduled maintenance window approved by the change advisory board. During the test:

1. Record the initial production state
2. Execute a planned failover to the DR site
3. Validate all certificate operations from the DR site (issuance, OCSP, CRL)
4. Measure actual RTO and compare against objectives
5. Fail back to production
6. Confirm production state matches the pre-test snapshot

Document all deviations from expected RTOs and update procedures accordingly.

## Business Continuity During PKI Outage

While PKI recovery is in progress, communicate to application teams:

- **Certificate validation:** Clients with cached CRLs or OCSP responses can continue to validate certificates for the duration of the cache lifetime (typically 8–24 hours)
- **New certificate issuance:** Suspended until issuing CAs are recovered — coordinate with application teams on priority order for new certificate requests
- **VPN and remote access:** May be disrupted if certificate-based authentication is the only factor — ensure backup authentication methods are in place
- **Domain controller authentication:** Kerberos does not depend on PKI in standard configurations, but smart card logon and LDAP over SSL will be affected

Establish a bridge call for all application owners at the 30-minute mark if PKI services are not restored within that window. Update stakeholders every 30 minutes thereafter.

### Emergency Certificate Issuance

If the primary issuing CAs are unavailable, activate the DR issuing CA (`PKI-ICA-03`) to issue emergency certificates for critical systems:

```powershell
# Activate DR issuing CA for emergency issuance
Invoke-Command -ComputerName "PKI-ICA-03" -ScriptBlock {
    Set-Service -Name CertSvc -StartupType Automatic
    Start-Service -Name CertSvc
    Write-Host "PKI-ICA-03 activated for emergency certificate issuance"
}

# Verify it is issuing certificates
Get-Certificate -Template "Company-Web-Server" `
    -DnsName "emergency-test.company.com.au" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -Url "https://pki-ica-03.company.local/certsrv"
```

## Recovery Validation

After completing any recovery procedure, run this validation sequence before declaring the PKI fully operational:

```powershell
function Test-PKIRecoveryComplete {
    param([string]$CAServer)

    $checks = @{
        ServiceRunning     = (Get-Service -ComputerName $CAServer -Name CertSvc).Status -eq "Running"
        CertificateIssuance = $false
        OCSPResponding     = (Test-NetConnection "ocsp.company.com.au" -Port 80).TcpTestSucceeded
        CRLAccessible      = try {
            (Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl").StatusCode -eq 200
        } catch { $false }
        DatabaseIntegrity  = $false
    }

    # Test certificate issuance
    try {
        $cert = Get-Certificate -Template "Company-Computer-Authentication" `
            -CertStoreLocation "Cert:\LocalMachine\My" `
            -Url "https://$CAServer/certsrv" -ErrorAction Stop
        $checks.CertificateIssuance = $cert.Status -eq "Issued"
    } catch { }

    # Verify database integrity
    $checks.DatabaseIntegrity = Invoke-Command -ComputerName $CAServer -ScriptBlock {
        $result = esentutl /g "C:\Windows\System32\CertLog\company.edb" 2>&1
        return $LASTEXITCODE -eq 0
    }

    $allPassed = $checks.Values -notcontains $false
    Write-Host "`n=== Recovery Validation ===" -ForegroundColor Cyan
    $checks.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $(if ($_.Value) {'PASS'} else {'FAIL'})" `
            -ForegroundColor $(if ($_.Value) {"Green"} else {"Red"})
    }
    Write-Host "Overall: $(if ($allPassed) {'RECOVERY COMPLETE'} else {'RECOVERY INCOMPLETE — INVESTIGATE FAILURES'})" `
        -ForegroundColor $(if ($allPassed) {"Green"} else {"Red"})

    return $allPassed
}
```

## Related Resources

- [AD CS backup and restore](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/back-up-and-restore-the-certification-authority)
- [Azure Key Vault disaster recovery and geo-redundancy](https://learn.microsoft.com/en-us/azure/key-vault/general/disaster-recovery-guidance)
- [Azure Private CA high availability and disaster recovery](https://learn.microsoft.com/en-us/azure/private-ca/disaster-recovery)
- [Azure Site Recovery overview](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview)
- [SQL Server Always On Availability Groups](https://learn.microsoft.com/en-us/sql/database-engine/availability-groups/windows/always-on-availability-groups-sql-server)
- [Windows Server Backup (wbadmin)](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wbadmin)
- [ESENT database utilities (esentutl)](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/esentutl)
- [Intune Trusted Certificate profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-trusted-root)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [PSPF — Protective Security Policy Framework](https://www.protectivesecurity.gov.au/)
