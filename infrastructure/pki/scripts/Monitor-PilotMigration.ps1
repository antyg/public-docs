# Monitor-PilotMigration.ps1
# Real-time monitoring and validation of pilot migration

param(
    [string]$MonitoringDuration = "24:00:00"  # 24 hours
)

$endTime = (Get-Date).Add([TimeSpan]::Parse($MonitoringDuration))

# Initialize monitoring metrics
$metrics = @{
    CertificateErrors  = @()
    ConnectivityIssues = @()
    PerformanceMetrics = @()
    UserComplaints     = @()
}

# Start monitoring loop
while ((Get-Date) -lt $endTime) {
    Clear-Host
    Write-Host "=== Pilot Migration Monitoring Dashboard ===" -ForegroundColor Cyan
    Write-Host "Current Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "Monitoring Until: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
    Write-Host ""

    # Query migration status from database
    $migrationStatus = Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Database "PKI_Migration" -Query @"
        SELECT
            Status,
            COUNT(*) as Count
        FROM MigrationTracking
        WHERE Wave = 'Pilot'
        GROUP BY Status
"@

    Write-Host "Migration Status:" -ForegroundColor Yellow
    foreach ($status in $migrationStatus) {
        $color = switch ($status.Status) {
            "Completed" { "Green" }
            "InProgress" { "Yellow" }
            "Failed" { "Red" }
            default { "Gray" }
        }
        Write-Host "  $($status.Status): $($status.Count)" -ForegroundColor $color
    }

    # Check certificate validation
    Write-Host "`nCertificate Validation:" -ForegroundColor Yellow

    $pilotDevices = Import-Csv "C:\Migration\Pilot\PilotGroup.csv"
    $validationErrors = @()

    foreach ($device in $pilotDevices | Get-Random -Count 10) {
        # Sample 10 devices
        try {
            $validation = Invoke-Command -ComputerName $device.ComputerName -ScriptBlock {
                $certs = Get-ChildItem Cert:\LocalMachine\My |
                Where-Object { $_.Issuer -like "*Company Issuing CA*" }

                $results = @()
                foreach ($cert in $certs) {
                    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
                    $chainResult = $chain.Build($cert)

                    $results += @{
                        Subject       = $cert.Subject
                        Valid         = $chainResult
                        Expires       = $cert.NotAfter
                        DaysRemaining = ($cert.NotAfter - (Get-Date)).Days
                    }
                }
                return $results
            }

            foreach ($result in $validation) {
                if (-not $result.Valid) {
                    $validationErrors += @{
                        Device      = $device.ComputerName
                        Certificate = $result.Subject
                        Issue       = "Chain validation failed"
                        Time        = Get-Date
                    }
                }
            }
        } catch {
            $validationErrors += @{
                Device = $device.ComputerName
                Issue  = "Unable to validate: $_"
                Time   = Get-Date
            }
        }
    }

    if ($validationErrors.Count -gt 0) {
        Write-Host "  Validation Errors: $($validationErrors.Count)" -ForegroundColor Red
        $metrics.CertificateErrors += $validationErrors
    } else {
        Write-Host "  All sampled certificates valid ✓" -ForegroundColor Green
    }

    # Check service connectivity
    Write-Host "`nService Connectivity:" -ForegroundColor Yellow

    $services = @(
        @{Name = "Domain Authentication"; Test = { Test-NetConnection -ComputerName "dc01.company.local" -Port 389 } },
        @{Name = "File Services"; Test = { Test-Path "\\fileserver\share" } },
        @{Name = "Web Services"; Test = { Test-NetConnection -ComputerName "intranet.company.local" -Port 443 } },
        @{Name = "Email Services"; Test = { Test-NetConnection -ComputerName "exchange.company.local" -Port 443 } }
    )

    foreach ($service in $services) {
        $result = & $service.Test
        if ($result) {
            Write-Host "  $($service.Name): Online ✓" -ForegroundColor Green
        } else {
            Write-Host "  $($service.Name): Failed ✗" -ForegroundColor Red
            $metrics.ConnectivityIssues += @{
                Service = $service.Name
                Time    = Get-Date
            }
        }
    }

    # Check help desk tickets
    Write-Host "`nHelp Desk Metrics:" -ForegroundColor Yellow

    $tickets = Get-ServiceNowIncidents -Category "PKI" -CreatedAfter (Get-Date).AddHours(-1)
    $criticalTickets = $tickets | Where-Object { $_.Priority -le 2 }

    Write-Host "  New Tickets (1hr): $($tickets.Count)" -ForegroundColor $(if ($tickets.Count -gt 5) { "Red" } else { "Green" })
    Write-Host "  Critical Issues: $($criticalTickets.Count)" -ForegroundColor $(if ($criticalTickets.Count -gt 0) { "Red" } else { "Green" })

    if ($criticalTickets.Count -gt 0) {
        foreach ($ticket in $criticalTickets) {
            Write-Host "    - $($ticket.ShortDescription)" -ForegroundColor Yellow
        }
    }

    # Performance metrics
    Write-Host "`nPerformance Metrics:" -ForegroundColor Yellow

    $perfMetrics = @{
        CertIssuanceTime   = (Measure-CertificateIssuanceTime).TotalSeconds
        OCSPResponseTime   = (Measure-OCSPResponseTime).TotalMilliseconds
        CRLDownloadTime    = (Measure-CRLDownloadTime).TotalSeconds
        AuthenticationTime = (Measure-AuthenticationTime).TotalSeconds
    }

    Write-Host "  Cert Issuance: $([Math]::Round($perfMetrics.CertIssuanceTime, 2))s" -ForegroundColor $(if ($perfMetrics.CertIssuanceTime -gt 30) { "Red" } else { "Green" })
    Write-Host "  OCSP Response: $([Math]::Round($perfMetrics.OCSPResponseTime, 0))ms" -ForegroundColor $(if ($perfMetrics.OCSPResponseTime -gt 500) { "Red" } else { "Green" })
    Write-Host "  CRL Download: $([Math]::Round($perfMetrics.CRLDownloadTime, 2))s" -ForegroundColor $(if ($perfMetrics.CRLDownloadTime -gt 5) { "Red" } else { "Green" })
    Write-Host "  Authentication: $([Math]::Round($perfMetrics.AuthenticationTime, 2))s" -ForegroundColor $(if ($perfMetrics.AuthenticationTime -gt 2) { "Red" } else { "Green" })

    $metrics.PerformanceMetrics += $perfMetrics

    # Alert on critical issues
    if ($validationErrors.Count -gt 5 -or $criticalTickets.Count -gt 0) {
        Send-AlertNotification -Priority "High" -Message "Pilot migration issues detected"
    }

    # Sleep before next check
    Start-Sleep -Seconds 300  # Check every 5 minutes
}

# Generate monitoring report
$monitoringReport = @{
    Duration                = $MonitoringDuration
    TotalCertificateErrors  = $metrics.CertificateErrors.Count
    TotalConnectivityIssues = $metrics.ConnectivityIssues.Count
    AverageIssuanceTime     = ($metrics.PerformanceMetrics.CertIssuanceTime | Measure-Object -Average).Average
    AverageOCSPTime         = ($metrics.PerformanceMetrics.OCSPResponseTime | Measure-Object -Average).Average
}

$monitoringReport | ConvertTo-Json | Out-File "C:\Migration\Pilot\MonitoringReport-$(Get-Date -Format 'yyyyMMdd').json"

Write-Host "`nMonitoring completed. Report saved." -ForegroundColor Green
