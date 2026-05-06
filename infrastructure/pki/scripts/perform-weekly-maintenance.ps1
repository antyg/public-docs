# Perform-WeeklyMaintenance.ps1
# Weekly PKI maintenance tasks

function Start-WeeklyPKIMaintenance {
    param(
        [switch]$SendReport = $true
    )

    $maintenanceLog = @()

    Write-Host "=== PKI Weekly Maintenance ===" -ForegroundColor Cyan
    Write-Host "Start Time: $(Get-Date)" -ForegroundColor Gray

    # Task 1: CRL Publication
    Write-Host "`nPublishing CRLs..." -ForegroundColor Yellow
    foreach ($ca in @("PKI-ICA-01", "PKI-ICA-02")) {
        Invoke-Command -ComputerName $ca -ScriptBlock {
            certutil -CRL
        }
        $maintenanceLog += "CRL published on $ca"
    }

    # Task 2: Database Maintenance
    Write-Host "Running database maintenance..." -ForegroundColor Yellow
    foreach ($ca in @("PKI-ICA-01", "PKI-ICA-02")) {
        Invoke-Command -ComputerName $ca -ScriptBlock {
            # Backup database
            Backup-CARoleService -Path "C:\Backup\Weekly" -DatabaseOnly

            # Compact database
            Stop-Service CertSvc
            esentutl /p "C:\Windows\System32\CertLog\company.edb"
            Start-Service CertSvc
        }
        $maintenanceLog += "Database maintenance completed on $ca"
    }

    # Task 3: Certificate Cleanup
    Write-Host "Cleaning up expired certificates..." -ForegroundColor Yellow
    $expiredCerts = Get-ExpiredCertificates
    foreach ($cert in $expiredCerts) {
        Archive-Certificate -Certificate $cert
        Remove-Certificate -Certificate $cert
    }
    $maintenanceLog += "Archived $($expiredCerts.Count) expired certificates"

    # Task 4: Log Rotation
    Write-Host "Rotating logs..." -ForegroundColor Yellow
    Compress-Archive -Path "C:\PKI\Logs\*.log" `
        -DestinationPath "C:\PKI\Archive\Logs-$(Get-Date -Format 'yyyyMMdd').zip"
    Get-ChildItem "C:\PKI\Logs\*.log" | Remove-Item
    $maintenanceLog += "Logs rotated and archived"

    # Task 5: Performance Optimization
    Write-Host "Optimizing performance..." -ForegroundColor Yellow
    Optimize-CAPerformance
    $maintenanceLog += "Performance optimization completed"

    # Task 6: Security Audit
    Write-Host "Running security audit..." -ForegroundColor Yellow
    $auditResults = Start-PKISecurityAudit
    $maintenanceLog += "Security audit completed: $($auditResults.IssueCount) issues found"

    # Generate report
    if ($SendReport) {
        Send-MaintenanceReport -Log $maintenanceLog -Recipients @(
            "pki-team@company.com.au",
            "operations@company.com.au"
        )
    }

    Write-Host "`nWeekly maintenance completed!" -ForegroundColor Green
    return $maintenanceLog
}