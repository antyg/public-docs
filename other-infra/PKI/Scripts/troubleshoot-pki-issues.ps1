# Troubleshoot-PKIIssues.ps1
# Automated troubleshooting procedures

function Diagnose-PKIIssue {
    param(
        [string]$Symptom
    )

    switch ($Symptom) {
        "CertificateRequestFailed" {
            Write-Host "Diagnosing certificate request failure..." -ForegroundColor Yellow

            # Check CA service
            $caStatus = Get-Service -ComputerName "PKI-ICA-01" -Name CertSvc
            if ($caStatus.Status -ne "Running") {
                Write-Host "Issue: CA service not running" -ForegroundColor Red
                Write-Host "Resolution: Start CA service" -ForegroundColor Green
                Start-Service -ComputerName "PKI-ICA-01" -Name CertSvc
            }

            # Check template permissions
            $templates = Get-CATemplate
            foreach ($template in $templates) {
                $acl = Get-Acl "AD:$($template.DistinguishedName)"
                # Check permissions
            }

            # Check network connectivity
            $connectivity = Test-NetConnection -ComputerName "PKI-ICA-01" -Port 135
            if (-not $connectivity.TcpTestSucceeded) {
                Write-Host "Issue: Network connectivity problem" -ForegroundColor Red
                Write-Host "Resolution: Check firewall rules and network path" -ForegroundColor Green
            }
        }

        "SlowCertificateIssuance" {
            Write-Host "Diagnosing slow issuance..." -ForegroundColor Yellow

            # Check CA database size
            $dbSize = Get-CADatabaseSize
            if ($dbSize.GB -gt 50) {
                Write-Host "Issue: Large CA database" -ForegroundColor Red
                Write-Host "Resolution: Archive old certificates" -ForegroundColor Green
                Start-CADatabaseMaintenance
            }

            # Check server resources
            $perfCounters = Get-Counter -ComputerName "PKI-ICA-01" `
                -Counter "\Processor(_Total)\% Processor Time",
            "\Memory\Available MBytes"

            if ($perfCounters[0].CookedValue -gt 80) {
                Write-Host "Issue: High CPU usage" -ForegroundColor Red
                Write-Host "Resolution: Investigate processes, consider scaling" -ForegroundColor Green
            }
        }

        "CertificateChainValidationFailed" {
            Write-Host "Diagnosing chain validation failure..." -ForegroundColor Yellow

            # Check root CA certificate
            $rootCA = Get-ChildItem Cert:\LocalMachine\Root |
            Where-Object { $_.Subject -like "*Root CA*" }

            if (-not $rootCA) {
                Write-Host "Issue: Root CA not in trusted store" -ForegroundColor Red
                Write-Host "Resolution: Import root CA certificate" -ForegroundColor Green
                Import-Certificate -FilePath "\\PKI\Certs\RootCA.crt" `
                    -CertStoreLocation Cert:\LocalMachine\Root
            }

            # Check intermediate CAs
            $intermediateCA = Get-ChildItem Cert:\LocalMachine\CA |
            Where-Object { $_.Subject -like "*Issuing CA*" }

            if ($intermediateCA.Count -lt 2) {
                Write-Host "Issue: Missing intermediate CA certificates" -ForegroundColor Red
                Write-Host "Resolution: Import intermediate certificates" -ForegroundColor Green
            }

            # Check CRL accessibility
            $crlUrl = "http://crl.company.com.au/IssuingCA01.crl"
            try {
                $crl = Invoke-WebRequest -Uri $crlUrl -UseBasicParsing
                Write-Host "CRL accessible" -ForegroundColor Green
            } catch {
                Write-Host "Issue: CRL not accessible" -ForegroundColor Red
                Write-Host "Resolution: Check CRL distribution point" -ForegroundColor Green
            }
        }
    }
}
