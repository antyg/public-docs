# Test-CertificateIssuance.ps1
# Validates complete certificate issuance workflow

function Test-CertificateIssuance {
    $testResults = @()

    # Test 1: Manual certificate request
    Write-Host "Test 1: Manual Certificate Request" -ForegroundColor Cyan

    $cert = Get-Certificate -Template "Company-Web-Server" `
        -DnsName "test.company.com.au" `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -Url "https://pki-ica-01.company.local/certsrv"

    if ($cert.Status -eq "Issued") {
        $testResults += @{Test = "Manual Request"; Result = "PASSED" }
        Write-Host "✓ Manual certificate request successful" -ForegroundColor Green
    } else {
        $testResults += @{Test = "Manual Request"; Result = "FAILED" }
        Write-Host "✗ Manual certificate request failed" -ForegroundColor Red
    }

    # Test 2: Auto-enrollment
    Write-Host "`nTest 2: Auto-Enrollment" -ForegroundColor Cyan

    # Trigger auto-enrollment
    certutil -pulse
    Start-Sleep -Seconds 10

    $autoCerts = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*$env:COMPUTERNAME*" -and $_.NotBefore -gt (Get-Date).AddMinutes(-5) }

    if ($autoCerts.Count -gt 0) {
        $testResults += @{Test = "Auto-Enrollment"; Result = "PASSED" }
        Write-Host "✓ Auto-enrollment successful - $($autoCerts.Count) certificates" -ForegroundColor Green
    } else {
        $testResults += @{Test = "Auto-Enrollment"; Result = "FAILED" }
        Write-Host "✗ Auto-enrollment failed" -ForegroundColor Red
    }

    # Test 3: SCEP enrollment
    Write-Host "`nTest 3: SCEP/NDES Enrollment" -ForegroundColor Cyan

    $scepUrl = "https://ndes.company.com.au/certsrv/mscep/mscep.dll"
    $response = Invoke-WebRequest -Uri "$scepUrl?operation=GetCACert" -Method Get

    if ($response.StatusCode -eq 200) {
        $testResults += @{Test = "SCEP Endpoint"; Result = "PASSED" }
        Write-Host "✓ SCEP endpoint accessible" -ForegroundColor Green
    } else {
        $testResults += @{Test = "SCEP Endpoint"; Result = "FAILED" }
        Write-Host "✗ SCEP endpoint not accessible" -ForegroundColor Red
    }

    # Test 4: CRL accessibility
    Write-Host "`nTest 4: CRL Distribution" -ForegroundColor Cyan

    $crlUrl = "http://crl.company.com.au/IssuingCA01.crl"
    $crlResponse = Invoke-WebRequest -Uri $crlUrl -Method Get

    if ($crlResponse.StatusCode -eq 200) {
        $testResults += @{Test = "CRL Distribution"; Result = "PASSED" }
        Write-Host "✓ CRL accessible" -ForegroundColor Green

        # Verify CRL validity
        $crlFile = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllBytes($crlFile, $crlResponse.Content)

        $crlInfo = certutil -dump $crlFile
        if ($crlInfo -match "Next Update") {
            Write-Host "✓ CRL is valid" -ForegroundColor Green
        }
    } else {
        $testResults += @{Test = "CRL Distribution"; Result = "FAILED" }
        Write-Host "✗ CRL not accessible" -ForegroundColor Red
    }

    # Test 5: OCSP responder
    Write-Host "`nTest 5: OCSP Responder" -ForegroundColor Cyan

    $ocspUrl = "http://ocsp.company.com.au"
    # This would require an actual OCSP request
    # Simplified test for endpoint availability

    $ocspResponse = Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80

    if ($ocspResponse.TcpTestSucceeded) {
        $testResults += @{Test = "OCSP Responder"; Result = "PASSED" }
        Write-Host "✓ OCSP responder accessible" -ForegroundColor Green
    } else {
        $testResults += @{Test = "OCSP Responder"; Result = "FAILED" }
        Write-Host "✗ OCSP responder not accessible" -ForegroundColor Red
    }

    # Generate summary report
    Write-Host "`n========== Test Summary ==========" -ForegroundColor Cyan
    $passedTests = ($testResults | Where-Object { $_.Result -eq "PASSED" }).Count
    $totalTests = $testResults.Count

    Write-Host "Passed: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

    foreach ($result in $testResults) {
        $color = if ($result.Result -eq "PASSED") { "Green" } else { "Red" }
        Write-Host "$($result.Test): $($result.Result)" -ForegroundColor $color
    }

    return $testResults
}

# Run tests
$results = Test-CertificateIssuance

# Export results
$results | Export-Csv -Path "C:\PKI\TestResults\Phase2-Validation-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
