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
    Check    = "Device Migration Complete"
    Status   = if ($completionRate -ge 99.5) { "READY" } else { "NOT READY" }
    Details  = "Completion: $([Math]::Round($completionRate, 2))% ($completedDevices/$totalDevices)"
    Critical = $true
}

if ($completionRate -lt 99.5) { $overallReady = $false }

# Check 2: New PKI Health
Write-Host "Checking new PKI infrastructure health..." -ForegroundColor Yellow

$pkiServices = @(
    @{Name = "Root CA (Azure)"; Check = { Test-AzurePrivateCA } },
    @{Name = "Issuing CA 01"; Check = { Test-ServiceHealth -Server "PKI-ICA-01" -Service "CertSvc" } },
    @{Name = "Issuing CA 02"; Check = { Test-ServiceHealth -Server "PKI-ICA-02" -Service "CertSvc" } },
    @{Name = "NDES Service"; Check = { Test-ServiceHealth -Server "PKI-NDES-01" -Service "IIS" } },
    @{Name = "OCSP Responder"; Check = { Test-OCSPResponder -Url "http://ocsp.company.com.au" } },
    @{Name = "CRL Distribution"; Check = { Test-CRLAvailability -Url "http://crl.company.com.au/IssuingCA01.crl" } }
)

foreach ($service in $pkiServices) {
    $serviceHealthy = & $service.Check

    $readinessChecks += @{
        Category = "PKI Services"
        Check    = $service.Name
        Status   = if ($serviceHealthy) { "READY" } else { "NOT READY" }
        Details  = if ($serviceHealthy) { "Service operational" } else { "Service check failed" }
        Critical = $true
    }

    if (-not $serviceHealthy) { $overallReady = $false }
}

# Check 3: Certificate Validation
Write-Host "Validating certificate deployment..." -ForegroundColor Yellow

$certValidation = Test-EnterpriseCertificates -SampleSize 100

$readinessChecks += @{
    Category = "Certificate Validation"
    Check    = "Certificate Chain Validation"
    Status   = if ($certValidation.SuccessRate -ge 99) { "READY" } else { "WARNING" }
    Details  = "Success Rate: $($certValidation.SuccessRate)%"
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
        Compatible  = $compatible
    }

    $readinessChecks += @{
        Category = "Application Compatibility"
        Check    = $app
        Status   = if ($compatible) { "READY" } else { "NOT READY" }
        Details  = if ($compatible) { "PKI integration verified" } else { "Compatibility issues detected" }
        Critical = ($app -in @("Exchange", "Active Directory"))
    }

    if (-not $compatible -and ($app -in @("Exchange", "Active Directory"))) {
        $overallReady = $false
    }
}

# Check 5: Backup and Recovery
Write-Host "Verifying backup and recovery procedures..." -ForegroundColor Yellow

$backupChecks = @(
    @{Name = "Legacy CA Backup"; Path = "\\Backup\Legacy-PKI\" },
    @{Name = "New CA Database Backup"; Path = "\\Backup\New-PKI\Database\" },
    @{Name = "Certificate Archive"; Path = "\\Backup\Certificates\" },
    @{Name = "Configuration Backup"; Path = "\\Backup\Configurations\" }
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
        Check    = $backup.Name
        Status   = if ($backupValid -and $backupAge -gt (Get-Date).AddDays(-1)) { "READY" } else { "WARNING" }
        Details  = if ($backupValid) { "Last backup: $backupAge" } else { "Backup not found" }
        Critical = $false
    }
}

# Check 6: Rollback Capability
Write-Host "Verifying rollback procedures..." -ForegroundColor Yellow

$rollbackReady = Test-RollbackProcedures

$readinessChecks += @{
    Category = "Rollback Capability"
    Check    = "Rollback Procedures"
    Status   = if ($rollbackReady) { "READY" } else { "WARNING" }
    Details  = if ($rollbackReady) { "Rollback tested and ready" } else { "Rollback procedures need verification" }
    Critical = $false
}

# Check 7: Team Readiness
Write-Host "Checking team readiness..." -ForegroundColor Yellow

$teamChecks = @(
    @{Team = "PKI Team"; Ready = Test-TeamAvailability -Team "PKI" },
    @{Team = "Network Team"; Ready = Test-TeamAvailability -Team "Network" },
    @{Team = "Security Team"; Ready = Test-TeamAvailability -Team "Security" },
    @{Team = "Service Desk"; Ready = Test-TeamAvailability -Team "ServiceDesk" }
)

foreach ($team in $teamChecks) {
    $readinessChecks += @{
        Category = "Team Readiness"
        Check    = $team.Team
        Status   = if ($team.Ready) { "READY" } else { "WARNING" }
        Details  = if ($team.Ready) { "Team available and briefed" } else { "Team preparation needed" }
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
Write-Host "Overall Status: $(if ($overallReady) {"READY FOR CUTOVER"} else {"NOT READY"})" -ForegroundColor $(if ($overallReady) { "Green" } else { "Red" })
Write-Host "Report saved to: $ReportPath" -ForegroundColor Gray

# Return decision
return @{
    Ready          = $overallReady
    Report         = $ReportPath
    CriticalIssues = $readinessChecks | Where-Object { $_.Critical -and $_.Status -ne "READY" }
}