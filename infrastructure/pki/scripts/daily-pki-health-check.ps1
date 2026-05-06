# Perform-DailyPKIHealthCheck.ps1
# Daily health check for PKI infrastructure

param(
    [string]$ReportPath = "C:\PKI\Reports\Daily",
    [switch]$SendEmail = $true
)

function Test-PKIHealth {
    Write-Host "=== PKI Daily Health Check ===" -ForegroundColor Cyan
    Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

    $healthReport = @{
        Date          = Get-Date
        OverallHealth = "Healthy"
        Services      = @()
        Certificates  = @()
        Performance   = @()
        Issues        = @()
    }

    # Check CA Services
    Write-Host "`nChecking CA Services..." -ForegroundColor Yellow

    $caServers = @("PKI-ICA-01", "PKI-ICA-02")
    foreach ($server in $caServers) {
        $service = Get-Service -ComputerName $server -Name CertSvc

        $healthReport.Services += @{
            Server  = $server
            Service = "Certificate Services"
            Status  = $service.Status
            Healthy = ($service.Status -eq "Running")
        }

        if ($service.Status -ne "Running") {
            $healthReport.Issues += "CA Service not running on $server"
            $healthReport.OverallHealth = "Degraded"
        }
    }

    # Check OCSP Responders
    $ocspServers = @("PKI-OCSP-01", "PKI-OCSP-02")
    foreach ($server in $ocspServers) {
        $response = Test-OCSPResponder -Server $server

        $healthReport.Services += @{
            Server  = $server
            Service = "OCSP Responder"
            Status  = if ($response) { "Online" } else { "Offline" }
            Healthy = $response
        }
    }

    # Check Certificate Expiration
    Write-Host "Checking certificate expiration..." -ForegroundColor Yellow

    $expiringCerts = Get-ExpiringCertificates -DaysToExpire 30

    foreach ($cert in $expiringCerts) {
        $healthReport.Certificates += @{
            Subject    = $cert.Subject
            Issuer     = $cert.Issuer
            ExpiresIn  = ($cert.NotAfter - (Get-Date)).Days
            Thumbprint = $cert.Thumbprint
        }

        if (($cert.NotAfter - (Get-Date)).Days -lt 7) {
            $healthReport.Issues += "Certificate expiring soon: $($cert.Subject)"
            $healthReport.OverallHealth = "Warning"
        }
    }

    # Check Performance Metrics
    Write-Host "Checking performance metrics..." -ForegroundColor Yellow

    $perfMetrics = @{
        IssuanceTime     = (Measure-CertificateIssuanceTime).TotalSeconds
        OCSPResponseTime = (Measure-OCSPResponseTime).TotalMilliseconds
        CRLSize          = (Get-CRLSize).MB
        DatabaseSize     = (Get-CADatabaseSize).GB
    }

    $healthReport.Performance = $perfMetrics

    if ($perfMetrics.IssuanceTime -gt 30) {
        $healthReport.Issues += "Slow certificate issuance: $($perfMetrics.IssuanceTime)s"
    }

    if ($perfMetrics.OCSPResponseTime -gt 500) {
        $healthReport.Issues += "Slow OCSP response: $($perfMetrics.OCSPResponseTime)ms"
    }

    # Check Azure Key Vault
    Write-Host "Checking Azure Key Vault..." -ForegroundColor Yellow

    $keyVault = Get-AzKeyVault -VaultName "KV-PKI-RootCA-Prod"
    if ($keyVault.VaultUri) {
        $healthReport.Services += @{
            Server  = "Azure"
            Service = "Key Vault"
            Status  = "Available"
            Healthy = $true
        }
    } else {
        $healthReport.Issues += "Key Vault not accessible"
        $healthReport.OverallHealth = "Critical"
    }

    # Generate Report
    $reportFile = "$ReportPath\PKI-Health-$(Get-Date -Format 'yyyyMMdd').html"
    ConvertTo-PKIHealthReport -Report $healthReport -OutputPath $reportFile

    # Send Email if requested
    if ($SendEmail) {
        Send-PKIHealthReport -Report $healthReport -Recipients @(
            "pki-team@company.com.au",
            "operations@company.com.au"
        )
    }

    # Display Summary
    Write-Host "`n=== Health Check Summary ===" -ForegroundColor Cyan
    Write-Host "Overall Health: $($healthReport.OverallHealth)" -ForegroundColor $(
        switch ($healthReport.OverallHealth) {
            "Healthy" { "Green" }
            "Warning" { "Yellow" }
            "Degraded" { "Orange" }
            "Critical" { "Red" }
        }
    )

    if ($healthReport.Issues.Count -gt 0) {
        Write-Host "`nIssues Found:" -ForegroundColor Yellow
        foreach ($issue in $healthReport.Issues) {
            Write-Host "  - $issue" -ForegroundColor Red
        }
    }

    return $healthReport
}

# Run health check
$health = Test-PKIHealth

# Log to event log
Write-EventLog -LogName "PKI-Operations" -Source "HealthCheck" `
    -EventId 1000 -EntryType $(
    if ($health.OverallHealth -eq "Healthy") { "Information" }
    else { "Warning" }
) -Message "PKI Health Status: $($health.OverallHealth)"
