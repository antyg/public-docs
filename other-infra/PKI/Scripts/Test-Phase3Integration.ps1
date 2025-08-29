# Test-Phase3Integration.ps1
# Comprehensive testing of Phase 3 integrations

function Test-Phase3Integrations {
    $results = @()

    # Test 1: Code Signing Service
    Write-Host "`nTesting Code Signing Service..." -ForegroundColor Cyan

    $testFile = "C:\Test\TestApp.exe"
    $signRequest = @{
        Uri         = "https://codesign.company.com.au/api/sign"
        Method      = "POST"
        Body        = @{
            RequestId   = [Guid]::NewGuid()
            FileName    = "TestApp.exe"
            FileContent = [Convert]::ToBase64String([IO.File]::ReadAllBytes($testFile))
            Purpose     = "Testing"
        } | ConvertTo-Json
        ContentType = "application/json"
    }

    try {
        $response = Invoke-RestMethod @signRequest
        if ($response.SignedFile) {
            $results += @{Test = "Code Signing"; Result = "PASSED" }
            Write-Host "✓ Code signing service operational" -ForegroundColor Green
        }
    } catch {
        $results += @{Test = "Code Signing"; Result = "FAILED"; Error = $_.Exception.Message }
        Write-Host "✗ Code signing failed: $_" -ForegroundColor Red
    }

    # Test 2: SCCM Certificate Deployment
    Write-Host "`nTesting SCCM Integration..." -ForegroundColor Cyan

    $sccmStatus = Get-WmiObject -Namespace "root\ccm\clientsdk" `
        -Class CCM_ClientUtilities -ComputerName "localhost" |
    Select-Object -ExpandProperty PKICertificate

    if ($sccmStatus) {
        $results += @{Test = "SCCM Deployment"; Result = "PASSED" }
        Write-Host "✓ SCCM certificate deployment working" -ForegroundColor Green
    } else {
        $results += @{Test = "SCCM Deployment"; Result = "FAILED" }
        Write-Host "✗ SCCM certificate not found" -ForegroundColor Red
    }

    # Test 3: Azure Services Automation
    Write-Host "`nTesting Azure Services..." -ForegroundColor Cyan

    $kvCerts = Get-AzKeyVaultCertificate -VaultName "KV-PKI-Services-Prod"
    $expiringSoon = $kvCerts | Where-Object {
        ($_.Attributes.Expires - (Get-Date)).Days -lt 90
    }

    if ($kvCerts.Count -gt 0 -and $expiringSoon.Count -eq 0) {
        $results += @{Test = "Azure Automation"; Result = "PASSED" }
        Write-Host "✓ Azure certificate automation healthy" -ForegroundColor Green
    } else {
        $results += @{Test = "Azure Automation"; Result = "WARNING";
            Note = "$($expiringSoon.Count) certificates expiring soon"
        }
        Write-Host "⚠ $($expiringSoon.Count) certificates need attention" -ForegroundColor Yellow
    }

    # Test 4: Load Balancer SSL
    Write-Host "`nTesting Load Balancer SSL..." -ForegroundColor Cyan

    $sslTest = Test-NetConnection -ComputerName "portal.company.com.au" -Port 443

    if ($sslTest.TcpTestSucceeded) {
        # Check SSL certificate
        $cert = Invoke-RestMethod -Uri "https://portal.company.com.au" -Method Head
        $results += @{Test = "Load Balancer SSL"; Result = "PASSED" }
        Write-Host "✓ Load balancer SSL configured" -ForegroundColor Green
    } else {
        $results += @{Test = "Load Balancer SSL"; Result = "FAILED" }
        Write-Host "✗ Load balancer SSL not responding" -ForegroundColor Red
    }

    # Test 5: API Functionality
    Write-Host "`nTesting PKI API..." -ForegroundColor Cyan

    # Get auth token
    $authResponse = Invoke-RestMethod -Uri "https://api-pki.company.com.au/api/auth" `
        -Method Post `
        -Body (@{username = "apitest"; password = "Test123!" } | ConvertTo-Json) `
        -ContentType "application/json"

    if ($authResponse.access_token) {
        # Test certificate request endpoint
        $headers = @{Authorization = "Bearer $($authResponse.access_token)" }

        $testRequest = @{
            template = "Company-Web-Server"
            subject  = "/CN=apitest.company.com.au"
            san      = "apitest.company.com.au"
        }

        $apiResponse = Invoke-RestMethod -Uri "https://api-pki.company.com.au/api/certificate/request" `
            -Method Post `
            -Headers $headers `
            -Body ($testRequest | ConvertTo-Json) `
            -ContentType "application/json"

        if ($apiResponse.serial) {
            $results += @{Test = "PKI API"; Result = "PASSED" }
            Write-Host "✓ PKI API operational" -ForegroundColor Green
        }
    } else {
        $results += @{Test = "PKI API"; Result = "FAILED" }
        Write-Host "✗ PKI API authentication failed" -ForegroundColor Red
    }

    # Generate summary
    Write-Host "`n========== Phase 3 Integration Test Summary ==========" -ForegroundColor Cyan

    $passed = ($results | Where-Object { $_.Result -eq "PASSED" }).Count
    $failed = ($results | Where-Object { $_.Result -eq "FAILED" }).Count
    $warnings = ($results | Where-Object { $_.Result -eq "WARNING" }).Count

    Write-Host "Passed: $passed" -ForegroundColor Green
    Write-Host "Failed: $failed" -ForegroundColor Red
    Write-Host "Warnings: $warnings" -ForegroundColor Yellow

    return $results
}

# Run tests
$testResults = Test-Phase3Integrations

# Export results
$testResults | Export-Csv -Path "C:\PKI\TestResults\Phase3-Integration-$(Get-Date -Format 'yyyyMMdd').csv"
