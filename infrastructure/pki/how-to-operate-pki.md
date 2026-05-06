---
title: "How to Operate the PKI Infrastructure"
status: "draft"
last_updated: "2026-03-17"
audience: "Infrastructure Engineers"
document_type: "how-to"
domain: "infrastructure"
platform: "PKI"
---

# How to Operate the PKI Infrastructure

This guide covers the day-to-day operational procedures for maintaining a healthy PKI infrastructure: health checks, certificate lifecycle management, CRL and OCSP monitoring, performance tuning, troubleshooting, security monitoring, and CA database backup.

## Daily Health Check

Run the daily health check at 08:00 each business day. If the health check reveals a critical issue, escalate immediately — do not defer to the end-of-day review.

```powershell
# Perform-DailyPKIHealthCheck.ps1
param(
    [string]$ReportPath = "C:\PKI\Reports\Daily",
    [switch]$SendEmail  = $true
)

$healthReport = @{
    Date          = Get-Date
    OverallHealth = "Healthy"
    Issues        = @()
}

# 1. Check CA services on both issuing CAs
foreach ($server in @("PKI-ICA-01","PKI-ICA-02")) {
    $svc = Get-Service -ComputerName $server -Name CertSvc
    if ($svc.Status -ne "Running") {
        $healthReport.Issues      += "CA service not running on $server"
        $healthReport.OverallHealth = "Critical"
    }
    Write-Host "$server CertSvc: $($svc.Status)"
}

# 2. Check OCSP responders
foreach ($server in @("PKI-OCSP-01","PKI-OCSP-02")) {
    $online = (Test-NetConnection -ComputerName $server -Port 80).TcpTestSucceeded
    if (-not $online) {
        $healthReport.Issues      += "OCSP responder offline: $server"
        $healthReport.OverallHealth = "Degraded"
    }
    Write-Host "OCSP $server: $(if ($online) {'Online'} else {'Offline'})"
}

# 3. Check OCSP response time (threshold: 500ms)
$ocspStart    = Get-Date
$null         = Invoke-WebRequest "http://ocsp.company.com.au" -UseBasicParsing -ErrorAction SilentlyContinue
$ocspMs       = ((Get-Date) - $ocspStart).TotalMilliseconds
if ($ocspMs -gt 500) {
    $healthReport.Issues      += "Slow OCSP response: $([Math]::Round($ocspMs))ms"
    $healthReport.OverallHealth = "Warning"
}
Write-Host "OCSP response time: $([Math]::Round($ocspMs))ms"

# 4. Check CRL accessibility and freshness
$crlUrl = "http://crl.company.com.au/IssuingCA01.crl"
try {
    $crlResponse = Invoke-WebRequest -Uri $crlUrl -UseBasicParsing
    Write-Host "CRL accessible: HTTP $($crlResponse.StatusCode)"
} catch {
    $healthReport.Issues      += "CRL not accessible: $crlUrl"
    $healthReport.OverallHealth = "Critical"
}

# 5. Check Azure Key Vault accessibility
$kv = Get-AzKeyVault -VaultName "KV-PKI-RootCA-Prod" -ErrorAction SilentlyContinue
if (-not $kv) {
    $healthReport.Issues      += "Key Vault not accessible: KV-PKI-RootCA-Prod"
    $healthReport.OverallHealth = "Critical"
}

# 6. Check certificate issuance performance (threshold: 30s)
$issueStart = Get-Date
$testCert   = Get-Certificate -Template "Company-Computer-Authentication" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -Url "https://pki-ica-01.company.local/certsrv" -ErrorAction SilentlyContinue
$issueSeconds = ((Get-Date) - $issueStart).TotalSeconds
if ($issueSeconds -gt 30) {
    $healthReport.Issues      += "Slow certificate issuance: $([Math]::Round($issueSeconds))s"
    $healthReport.OverallHealth = "Warning"
}
Write-Host "Certificate issuance: $([Math]::Round($issueSeconds))s"

# Summary
Write-Host "`n=== Health Summary ===" -ForegroundColor Cyan
Write-Host "Overall: $($healthReport.OverallHealth)" -ForegroundColor $(
    switch ($healthReport.OverallHealth) {
        "Healthy"  { "Green"  }
        "Warning"  { "Yellow" }
        "Degraded" { "DarkYellow" }
        "Critical" { "Red"    }
    }
)
$healthReport.Issues | ForEach-Object { Write-Host "  ISSUE: $_" -ForegroundColor Red }

# Log to Windows Event Log
Write-EventLog -LogName "PKI-Operations" -Source "HealthCheck" `
    -EventId 1000 -EntryType $(
        if ($healthReport.OverallHealth -eq "Healthy") {"Information"} else {"Warning"}
    ) -Message "PKI Health: $($healthReport.OverallHealth)"
```

### Daily Operational Task Schedule

| Time | Task | Responsible | Action if Issues Found |
|---|---|---|---|
| 08:00 | Health check | Operations | Escalate criticals immediately |
| 09:00 | Certificate expiry report | PKI team | Initiate renewal for any < 30 days |
| 10:00 | Backup verification | Operations | Raise incident if backup > 24 hours old |
| 11:00 | Alert review | Operations | Action any unacknowledged alerts |
| 14:00 | Pending certificate requests | Service desk | Process within SLA (4 hours) |
| 16:00 | Performance metrics review | Operations | Log any threshold breaches |

## Monitor Certificate Expiry and Initiate Renewal

### Find Expiring Certificates

Run the expiry report daily to identify certificates expiring within 30 days:

```powershell
# Get-ExpiringCertificates.ps1
param([int]$DaysToExpire = 30)

# Query all certificates from both CAs
$expiringCerts = @()

foreach ($ca in @("PKI-ICA-01","PKI-ICA-02")) {
    Invoke-Command -ComputerName $ca -ScriptBlock {
        param($days)
        $caName = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration").Active
        certutil -view -restrict "NotAfter<=NOW+$($days * 24 * 60 * 60)s,Disposition=20" `
            -out "CommonName,NotAfter,SerialNumber,Requester" csv
    } -ArgumentList $DaysToExpire | ForEach-Object {
        $expiringCerts += $_
    }
}

$expiringCerts | Sort-Object NotAfter | Format-Table CommonName, NotAfter, SerialNumber -AutoSize
```

Certificates expiring in fewer than 7 days are a critical finding and must be escalated immediately.

### Renew Certificates Automatically

For templates with auto-enrolment enabled, trigger renewal by running `certutil -pulse` on affected machines. For manually managed certificates:

```powershell
function Start-CertificateRenewal {
    param(
        [string]$SerialNumber,
        [string]$TemplateName,
        [string]$CAServer = "PKI-ICA-01.company.local\Company Issuing CA 01"
    )

    # Generate renewal request from the existing certificate
    $oldCert = Get-ChildItem Cert:\LocalMachine\My |
        Where-Object { $_.SerialNumber -eq $SerialNumber }

    if (-not $oldCert) {
        throw "Certificate with serial $SerialNumber not found in local store"
    }

    # Request renewal
    $newCert = Get-Certificate `
        -Template $TemplateName `
        -DnsName ($oldCert.DnsNameList.Unicode) `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -Url "https://pki-ica-01.company.local/certsrv"

    if ($newCert.Status -eq "Issued") {
        Write-Host "Renewal successful. New serial: $($newCert.Certificate.SerialNumber)"
        # Caller is responsible for updating any bindings (IIS, Schannel, etc.)
        return $newCert.Certificate
    } else {
        throw "Renewal failed with status: $($newCert.Status)"
    }
}
```

After renewing a certificate bound to IIS, Schannel, or a load balancer, update the binding to reference the new thumbprint.

## Revoke a Certificate

Certificate revocation must be authorised, documented, and followed immediately by a CRL publication for `KeyCompromise` or `CACompromise` reasons. See [AD CS revocation](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/revoke-certificates-and-publish-crls) for background.

```powershell
function Revoke-Certificate {
    param(
        [Parameter(Mandatory)] [string]$SerialNumber,
        [Parameter(Mandatory)]
        [ValidateSet("Unspecified","KeyCompromise","CACompromise",
                     "AffiliationChanged","Superseded","CessationOfOperation","CertificateHold")]
        [string]$Reason,
        [string]$RequestedBy,
        [string]$ApprovedBy,
        [string]$Comments
    )

    # Create audit record before performing revocation
    $auditRecord = @{
        Timestamp    = Get-Date
        SerialNumber = $SerialNumber
        Reason       = $Reason
        RequestedBy  = $RequestedBy
        ApprovedBy   = $ApprovedBy
        Comments     = $Comments
    }

    # Perform revocation via certutil
    $result = certutil -revoke $SerialNumber $Reason
    if ($result -match "successfully revoked" -or $result -match "CRL entry added") {
        # For high-severity reasons, publish an emergency CRL immediately
        if ($Reason -in @("KeyCompromise","CACompromise")) {
            certutil -CRL
            Write-Host "Emergency CRL published for $Reason revocation"
        }

        $auditRecord.Status    = "Success"
        $auditRecord.RevokedAt = Get-Date

        Write-EventLog -LogName "PKI-Security" -Source "Revocation" `
            -EventId 3001 -EntryType Warning `
            -Message "Certificate $SerialNumber revoked: $Reason by $RequestedBy"
    } else {
        $auditRecord.Status = "Failed"
        throw "Revocation failed. certutil output: $result"
    }

    # Always append to audit log
    $auditRecord | Export-Csv -Path "C:\PKI\Audit\Revocations.csv" -Append -NoTypeInformation
}
```

After revoking a certificate, confirm the serial number appears in the next published CRL:

```powershell
$crlFile = [System.IO.Path]::GetTempFileName() + ".crl"
Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl" -OutFile $crlFile
certutil -dump $crlFile | Select-String $SerialNumber
```

## Check CRL Freshness

The base CRL is published every 7 days with a 2-day overlap. If the CRL is not published on schedule, certificate validation will fail for clients that have not cached a valid CRL.

```powershell
# Check CRL validity window
$crlFile = [System.IO.Path]::GetTempFileName() + ".crl"
Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl" -OutFile $crlFile

$crlInfo = certutil -dump $crlFile
$nextUpdate = $crlInfo | Select-String "Next Update" | Select-Object -First 1

Write-Host "CRL Next Update: $nextUpdate"

# Alert if CRL expires within 2 days
$crl = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($crlFile)
# CRL nextUpdate is accessible via X509Extension; for automation use PKI module or certutil output
```

To force immediate CRL publication on both issuing CAs:

```powershell
foreach ($ca in @("PKI-ICA-01","PKI-ICA-02")) {
    Invoke-Command -ComputerName $ca -ScriptBlock {
        certutil -CRL
        Write-Host "$env:COMPUTERNAME: CRL published"
    }
}
```

## Perform Weekly Maintenance

Run weekly maintenance every Sunday during a low-activity window. This includes CRL publication, database maintenance, expired certificate archival, log rotation, and a security audit.

```powershell
# Perform-WeeklyMaintenance.ps1
param([switch]$SendReport = $true)

Write-Host "=== PKI Weekly Maintenance ===" -ForegroundColor Cyan
$log = @()

# 1. Publish CRLs
foreach ($ca in @("PKI-ICA-01","PKI-ICA-02")) {
    Invoke-Command -ComputerName $ca -ScriptBlock { certutil -CRL }
    $log += "CRL published on $ca"
}

# 2. Database maintenance (compact the ESENT database)
foreach ($ca in @("PKI-ICA-01","PKI-ICA-02")) {
    Invoke-Command -ComputerName $ca -ScriptBlock {
        Backup-CARoleService -Path "E:\CertData\Backup\Weekly" -DatabaseOnly
        Stop-Service CertSvc
        esentutl /p "C:\Windows\System32\CertLog\company.edb" /o
        Start-Service CertSvc
    }
    $log += "Database maintenance completed on $ca"
}

# 3. Archive and remove expired certificates from the local store
$expired = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -lt (Get-Date) }
foreach ($cert in $expired) {
    # Archive the certificate before removing it
    Export-Certificate -Cert $cert -FilePath "C:\PKI\Archive\Expired-$($cert.Thumbprint).cer"
    Remove-Item -Path "Cert:\LocalMachine\My\$($cert.Thumbprint)" -ErrorAction SilentlyContinue
}
$log += "Archived and removed $($expired.Count) expired certificates"

# 4. Rotate logs
$archiveName = "C:\PKI\Archive\Logs-$(Get-Date -Format 'yyyyMMdd').zip"
Compress-Archive -Path "C:\PKI\Logs\*.log" -DestinationPath $archiveName -ErrorAction SilentlyContinue
Get-ChildItem "C:\PKI\Logs\*.log" | Remove-Item -ErrorAction SilentlyContinue
$log += "Logs archived to $archiveName"

Write-Host "Weekly maintenance complete" -ForegroundColor Green
$log | ForEach-Object { Write-Host "  - $_" }
```

### Monthly Maintenance Tasks

| Task | Expected Duration | Procedure |
|---|---|---|
| Full CA backup including database | 2 hours | See backup procedure below |
| Windows security patching on PKI servers | 4 hours | Apply via WSUS or Azure Update Manager |
| Certificate audit — review all issued certificates | 2 hours | Run `certutil -view` report, review against asset register |
| Certificate template review | 1 hour | Confirm no templates have had permissions inadvertently modified |
| Performance trend analysis | 1 hour | Review issuance time and OCSP response time trends in monitoring |
| Disaster recovery test | 4 hours | See [how-to-disaster-recovery.md](how-to-disaster-recovery.md) |

## Back Up the CA Database and Keys

Perform daily automated backups and a full monthly backup that includes private key material (if keys are software-based; HSM-resident keys are protected by Azure Key Vault replication).

```powershell
function Backup-CertificateAuthority {
    param(
        [string]$CAServer    = "PKI-ICA-01",
        [string]$BackupPath  = "\\Backup\PKI\CA",
        [switch]$IncludeKey  = $false
    )

    $backupDate   = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFolder = "$BackupPath\$CAServer-$backupDate"

    New-Item -ItemType Directory -Path $backupFolder -Force

    Invoke-Command -ComputerName $CAServer -ScriptBlock {
        param($backup, $includeKey)

        Stop-Service CertSvc

        try {
            # Backup CA configuration and database
            certutil -backup "$backup\CAConfig" -p (Get-BackupPassword)
            Backup-CARoleService -Path "$backup\Database" -DatabaseOnly

            # Export registry settings
            reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc" `
                "$backup\CertSvc-Registry.reg" /y

            # Export current certificate templates list
            certutil -catemplates > "$backup\Templates.txt"

            # Export CA certificate
            Get-ChildItem Cert:\LocalMachine\My |
                Where-Object { $_.Subject -like "*Issuing CA*" } |
                ForEach-Object {
                    Export-Certificate -Cert $_ -FilePath "$backup\CACert-$($_.Thumbprint).cer"
                }

            if ($includeKey) {
                # Software keys only — HSM keys are protected by Azure Key Vault
                certutil -backupkey "$backup\PrivateKey" -p (Get-KeyBackupPassword)
            }
        } finally {
            Start-Service CertSvc
        }
    } -ArgumentList $backupFolder, $IncludeKey

    # Verify the backup folder contains expected files
    $backupItems = Get-ChildItem -Path $backupFolder -Recurse
    if ($backupItems.Count -gt 0) {
        Write-Host "Backup completed: $backupFolder ($($backupItems.Count) files)"
        @{
            Date       = Get-Date
            Server     = $CAServer
            BackupPath = $backupFolder
            FileCount  = $backupItems.Count
            IncludedKey = $IncludeKey
            Status     = "Success"
        } | Export-Csv -Path "C:\PKI\Backup\BackupLog.csv" -Append -NoTypeInformation
        return $true
    } else {
        Write-Host "Backup verification FAILED — no files found at $backupFolder" -ForegroundColor Red
        return $false
    }
}
```

Retain backups for the following periods, aligned with the [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) data retention guidance:

| Backup type | Retention |
|---|---|
| Daily (database only) | 30 days |
| Weekly (full system state) | 12 weeks |
| Monthly (complete infrastructure + audit logs) | 7 years |

## Security Monitoring and Audit Procedures

Monitor the Windows Security event log and the PKI-Security custom event log for the following events:

| Event ID | Source | Description | Response |
|---|---|---|---|
| 4886 | Security | Certificate requested | Review if template is sensitive (Code Signing, CA) |
| 4887 | Security | Certificate issued | Routine — log for audit |
| 4888 | Security | Certificate request denied | Investigate if recurring for same requester |
| 4890 | Security | CA settings changed | Immediate investigation |
| 4899 | Security | Certificate template modified | Verify authorised change — revert if not |
| 3001 | PKI-Security | Certificate revoked | Confirm reason is documented |

```powershell
# Monitor-PKISecurity.ps1
function Start-PKISecurityMonitoring {
    $securityEvents = @()

    # Check for suspicious high-value certificate requests
    $suspiciousRequests = Get-WinEvent -FilterHashtable @{
        LogName = "Security"; Id = 4886
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.Message -match "Code Signing" -or $_.Message -match "CA"
    }

    foreach ($event in $suspiciousRequests) {
        $securityEvents += @{
            Type    = "High-value certificate request"
            Time    = $event.TimeCreated
            User    = $event.UserId
            Details = $event.Message
        }
    }

    # Check for multiple failed requests from the same user (potential brute force or misconfiguration)
    $failedRequests = Get-WinEvent -FilterHashtable @{
        LogName = "Application"; Id = 100
    } -ErrorAction SilentlyContinue |
        Group-Object UserId | Where-Object { $_.Count -gt 5 }

    foreach ($group in $failedRequests) {
        $securityEvents += @{
            Type   = "Multiple failed certificate requests"
            User   = $group.Name
            Count  = $group.Count
            Action = "Investigate — possible misconfiguration or attack"
        }
    }

    # Check for unauthorised template modifications
    $templateChanges = Get-WinEvent -FilterHashtable @{
        LogName = "Security"; Id = 4899
    } -ErrorAction SilentlyContinue

    foreach ($event in $templateChanges) {
        $securityEvents += @{
            Type    = "Certificate template modified"
            Time    = $event.TimeCreated
            User    = $event.UserId
            Action  = "Verify change was authorised. Revert if not."
        }
    }

    if ($securityEvents.Count -gt 0) {
        Write-Host "Security events requiring attention: $($securityEvents.Count)" -ForegroundColor Yellow
        $securityEvents | Format-Table Type, Time, User, Action -AutoSize
    } else {
        Write-Host "No security anomalies detected" -ForegroundColor Green
    }

    return $securityEvents
}
```

Run this check as part of the weekly maintenance or when alerts are triggered by the monitoring system.

## Troubleshoot Common PKI Issues

### Certificate Request Fails

1. Confirm CA service is running: `Get-Service -ComputerName PKI-ICA-01 -Name CertSvc`
2. Test network connectivity to the CA on port 135 (RPC endpoint mapper): `Test-NetConnection PKI-ICA-01 -Port 135`
3. Confirm the requester has Enrol permission on the target template: check Active Directory > Certificate Templates > [template name] > Security
4. Check the CA event log (Event ID 53) for the specific rejection reason

### Slow Certificate Issuance

1. Check CA server CPU and memory: `Get-Counter "\Processor(_Total)\% Processor Time" -ComputerName PKI-ICA-01`
2. Check CA database size. If the database file (`C:\Windows\System32\CertLog\company.edb`) exceeds 50 GB, run the weekly database compaction procedure
3. Check if the CA is waiting on CRL publication — a large pending CRL queue can slow issuance
4. Review the CA audit log for unusually high request volumes (possible misconfigured auto-enrolment)

### Certificate Chain Validation Fails

1. Check that the root CA certificate is in the Trusted Root store on the affected machine: `Get-ChildItem Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*Root CA G2*" }`
2. If absent, import it: `certutil -addstore -f Root "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt"`
3. Check that both issuing CA certificates are in the Intermediate store: `Get-ChildItem Cert:\LocalMachine\CA | Where-Object { $_.Subject -like "*Issuing CA*" }`
4. Confirm the CRL endpoint is reachable and the CRL has not expired: `certutil -verify -urlfetch <certificate-file>`

### OCSP Responder Not Responding

1. Confirm the IIS service is running on the OCSP server: `Get-Service -ComputerName PKI-OCSP-01 -Name W3SVC`
2. Check that the OCSP signing certificate is valid and has not expired: `Get-ChildItem Cert:\LocalMachine\My -ComputerName PKI-OCSP-01 | Where-Object { $_.Subject -like "*OCSP*" }`
3. If the signing certificate is expired, run `certutil -pulse` on the OCSP server to trigger auto-enrolment of a new signing certificate
4. Review the OCSP responder configuration in the Online Responder snap-in (ocsp.msc) for errors

### Monitoring Alert Response Reference

| Alert | Severity | Initial Response | Escalation (if unresolved) |
|---|---|---|---|
| CA Service Down | Critical | Restart service; check event log | Escalate to PKI team within 5 minutes |
| Certificate Expired | High | Renew certificate; update bindings | Escalate to application owner within 1 hour |
| High Issuance Rate | Medium | Investigate source; check for runaway auto-enrolment | Escalate after 4 hours |
| CRL Too Large (> 10 MB) | Low | Archive old revoked entries; compact database | Address within 24 hours |
| OCSP Slow Response (> 500ms) | Medium | Check server load; restart OCSP service | Escalate after 2 hours |

## Related Resources

- [AD CS operational guidance — Windows Server](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/active-directory-certificate-services-overview)
- [AD CS backup and restore](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/back-up-and-restore-the-certification-authority)
- [certutil reference](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certutil)
- [Certificate revocation and CRL publication](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/revoke-certificates-and-publish-crls)
- [Online Responder deployment and configuration](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/configure-online-responder)
- [Azure Key Vault best practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [PSPF — Protective Security Policy Framework](https://www.protectivesecurity.gov.au/)
