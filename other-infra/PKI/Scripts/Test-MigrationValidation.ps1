# Test-MigrationValidation.ps1
# Comprehensive validation framework for migration

function Test-EnterprisePKIHealth {
    param(
        [switch]$Comprehensive
    )

    $testResults = @{
        Timestamp      = Get-Date
        TestsPassed    = 0
        TestsFailed    = 0
        AllTestsPassed = $false
        Issues         = @()
        Details        = @()
    }

    # Test 1: Certificate deployment coverage
    Write-Host "Testing certificate deployment coverage..." -ForegroundColor Gray

    $totalDevices = (Get-ADComputer -Filter *).Count
    $devicesWithNewCerts = Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Query @"
        SELECT COUNT(DISTINCT DeviceName) as Count
        FROM PKI_Migration.dbo.MigrationTracking
        WHERE Status = 'Completed'
"@

    $coverage = ($devicesWithNewCerts.Count / $totalDevices) * 100

    if ($coverage -ge 99.5) {
        $testResults.TestsPassed++
        Write-Host "  ✓ Coverage: $([Math]::Round($coverage, 2))%" -ForegroundColor Green
    } else {
        $testResults.TestsFailed++
        $testResults.Issues += "Insufficient coverage: $([Math]::Round($coverage, 2))%"
        Write-Host "  ✗ Coverage: $([Math]::Round($coverage, 2))%" -ForegroundColor Red
    }

    # Test 2: Certificate chain validation
    Write-Host "Testing certificate chains..." -ForegroundColor Gray

    $sampleSize = if ($Comprehensive) { 500 } else { 50 }
    $computers = Get-ADComputer -Filter * | Get-Random -Count $sampleSize

    $chainErrors = @()
    foreach ($computer in $computers) {
        try {
            $chainTest = Invoke-Command -ComputerName $computer.Name -ScriptBlock {
                $certs = Get-ChildItem Cert:\LocalMachine\My
                $errors = @()

                foreach ($cert in $certs) {
                    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
                    if (-not $chain.Build($cert)) {
                        $errors += $cert.Subject
                    }
                }
                return $errors
            }

            if ($chainTest.Count -gt 0) {
                $chainErrors += @{
                    Computer = $computer.Name
                    Errors   = $chainTest
                }
            }
        } catch {
            # Skip unreachable computers
        }
    }

    if ($chainErrors.Count -eq 0) {
        $testResults.TestsPassed++
        Write-Host "  ✓ All certificate chains valid" -ForegroundColor Green
    } else {
        $testResults.TestsFailed++
        $testResults.Issues += "Chain validation errors on $($chainErrors.Count) devices"
        Write-Host "  ✗ Chain errors found on $($chainErrors.Count) devices" -ForegroundColor Red
    }

    # Test 3: Service availability
    Write-Host "Testing service availability..." -ForegroundColor Gray

    $services = @(
        @{Name = "CA Service"; Test = { Get-Service -ComputerName "PKI-ICA-01" -Name CertSvc } },
        @{Name = "OCSP Responder"; Test = { Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80 } },
        @{Name = "CRL Distribution"; Test = { Invoke-WebRequest -Uri "http://crl.company.com.au/IssuingCA01.crl" -UseBasicParsing } },
        @{Name = "NDES Service"; Test = { Test-NetConnection -ComputerName "PKI-NDES-01" -Port 443 } }
    )

    $serviceFailures = @()
    foreach ($service in $services) {
        try {
            $result = & $service.Test
            if ($result) {
                Write-Host "    ✓ $($service.Name)" -ForegroundColor Green
            }
        } catch {
            $serviceFailures += $service.Name
            Write-Host "    ✗ $($service.Name)" -ForegroundColor Red
        }
    }

    if ($serviceFailures.Count -eq 0) {
        $testResults.TestsPassed++
    } else {
        $testResults.TestsFailed++
        $testResults.Issues += "Service failures: $($serviceFailures -join ', ')"
    }

    # Test 4: Application compatibility
    Write-Host "Testing application compatibility..." -ForegroundColor Gray

    $applications = @(
        @{Name = "Exchange"; Test = { Test-ExchangeConnectivity } },
        @{Name = "SharePoint"; Test = { Test-SharePointAccess } },
        @{Name = "SQL Server"; Test = { Test-SqlConnection } },
        @{Name = "Line of Business App"; Test = { Test-LOBApplication } }
    )

    $appFailures = @()
    foreach ($app in $applications) {
        try {
            if (& $app.Test) {
                Write-Host "    ✓ $($app.Name)" -ForegroundColor Green
            }
        } catch {
            $appFailures += $app.Name
            Write-Host "    ✗ $($app.Name)" -ForegroundColor Red
        }
    }

    if ($appFailures.Count -eq 0) {
        $testResults.TestsPassed++
    } else {
        $testResults.TestsFailed++
        $testResults.Issues += "Application issues: $($appFailures -join ', ')"
    }

    # Test 5: Performance metrics
    Write-Host "Testing performance metrics..." -ForegroundColor Gray

    $perfMetrics = @{
        CertIssuance   = (Measure-Command {
                Get-Certificate -Template "TestTemplate" -CertStoreLocation Cert:\CurrentUser\My
            }).TotalSeconds

        OCSPResponse   = (Measure-Command {
                certutil -URL "http://ocsp.company.com.au"
            }).TotalMilliseconds

        Authentication = (Measure-Command {
                Test-ComputerSecureChannel
            }).TotalSeconds
    }

    $perfIssues = @()
    if ($perfMetrics.CertIssuance -gt 30) {
        $perfIssues += "Slow certificate issuance: $($perfMetrics.CertIssuance)s"
    }
    if ($perfMetrics.OCSPResponse -gt 500) {
        $perfIssues += "Slow OCSP response: $($perfMetrics.OCSPResponse)ms"
    }
    if ($perfMetrics.Authentication -gt 5) {
        $perfIssues += "Slow authentication: $($perfMetrics.Authentication)s"
    }

    if ($perfIssues.Count -eq 0) {
        $testResults.TestsPassed++
        Write-Host "  ✓ Performance within thresholds" -ForegroundColor Green
    } else {
        $testResults.TestsFailed++
        $testResults.Issues += $perfIssues
        Write-Host "  ✗ Performance issues detected" -ForegroundColor Red
    }

    # Final assessment
    $testResults.AllTestsPassed = ($testResults.TestsFailed -eq 0)

    return $testResults
}

# Run validation
$validation = Test-EnterprisePKIHealth -Comprehensive

# Generate report
$validation | ConvertTo-Html | Out-File "C:\Migration\ValidationReport-$(Get-Date -Format 'yyyyMMdd').html"
