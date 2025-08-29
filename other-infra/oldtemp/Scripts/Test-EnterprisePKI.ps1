# Comprehensive certificate validation script
# Test-EnterprisePKI.ps1

function Test-SSLCertificate {
    param(
        [string]$Name,
        [string]$URL,
        [string]$ExpectedCN,
        [bool]$ClientCert = $false
    )

    $result = @{
        Name               = $Name
        URL                = $URL
        Status             = "Unknown"
        CertificateSubject = ""
        ExpiryDays         = 0
        ChainValid         = $false
        OCSPStatus         = ""
        Errors             = @()
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $request.ServerCertificateValidationCallback = { $true }

        if ($ClientCert) {
            $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -match "CN=.*" }
            if ($cert) {
                $request.ClientCertificates.Add($cert[0])
            }
        }

        $response = $request.GetResponse()
        $certificate = $request.ServicePoint.Certificate

        $result.CertificateSubject = $certificate.Subject
        $result.ExpiryDays = ($certificate.GetExpirationDateString() - (Get-Date)).Days

        if ($ExpectedCN -and $certificate.Subject -notmatch $ExpectedCN) {
            $result.Errors += "Certificate CN mismatch"
        }

        if ($result.ExpiryDays -lt 30) {
            $result.Errors += "Certificate expiring soon"
        }

        $result.Status = if ($result.Errors.Count -eq 0) { "Pass" } else { "Fail" }

    } catch {
        $result.Status = "Fail"
        $result.Errors += $_.Exception.Message
    }

    return $result
}

function Test-ZscalerCertificate {
    param(
        [string]$Name,
        [string]$URL,
        [string]$ExpectedCA,
        [bool]$SSLInspection = $false
    )

    $result = @{
        Name              = $Name
        URL               = $URL
        Status            = "Unknown"
        IssuerCA          = ""
        InspectionEnabled = $false
        Errors            = @()
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $request.ServerCertificateValidationCallback = {
            param($sender, $certificate, $chain, $errors)

            $result.IssuerCA = $certificate.Issuer
            if ($SSLInspection) {
                $result.InspectionEnabled = $certificate.Issuer -match "Zscaler"
            }

            return $true
        }

        $response = $request.GetResponse()
        $result.Status = "Pass"

        if ($ExpectedCA -and $result.IssuerCA -notmatch $ExpectedCA) {
            $result.Errors += "Unexpected CA issuer"
            $result.Status = "Fail"
        }

    } catch {
        $result.Status = "Fail"
        $result.Errors += $_.Exception.Message
    }

    return $result
}

function Test-FirewallCertificate {
    param(
        [string]$Name,
        [string]$URL,
        [string]$ExpectedCN,
        [bool]$ClientCert = $false
    )

    # Similar to Test-SSLCertificate but with firewall-specific checks
    $result = Test-SSLCertificate -Name $Name -URL $URL -ExpectedCN $ExpectedCN -ClientCert $ClientCert

    # Additional firewall-specific validations
    if ($URL -match "fw-mgmt") {
        # Check management interface specific requirements
        if ($result.CertificateSubject -notmatch "OU=Network Security") {
            $result.Errors += "Missing Network Security OU"
            $result.Status = "Fail"
        }
    }

    return $result
}

function Test-EnterprisePKI {
    $results = @()

    Write-Host "Starting Enterprise PKI Validation..." -ForegroundColor Cyan
    Write-Host "=" * 50

    # Test NetScaler certificates
    Write-Host "`nTesting NetScaler Certificates..." -ForegroundColor Yellow
    $nsTests = @(
        @{Name = "Portal VIP"; URL = "https://portal.company.com"; ExpectedCN = "*.company.com" },
        @{Name = "API Gateway"; URL = "https://api.company.com"; ExpectedCN = "*.company.com" },
        @{Name = "Admin Interface"; URL = "https://admin.company.com:443"; ClientCert = $true }
    )

    foreach ($test in $nsTests) {
        Write-Host "  Testing: $($test.Name)..." -NoNewline
        $result = Test-SSLCertificate @test
        $results += $result

        if ($result.Status -eq "Pass") {
            Write-Host " PASS" -ForegroundColor Green
        } else {
            Write-Host " FAIL" -ForegroundColor Red
            Write-Host "    Errors: $($result.Errors -join ', ')" -ForegroundColor Red
        }
    }

    # Test Zscaler integration
    Write-Host "`nTesting Zscaler Integration..." -ForegroundColor Yellow
    $zsTests = @(
        @{Name = "ZPA Portal"; URL = "https://company.privateaccess.zscaler.com"; ExpectedCA = "Zscaler" },
        @{Name = "ZIA Gateway"; URL = "https://gateway.zscaler.net"; SSLInspection = $true }
    )

    foreach ($test in $zsTests) {
        Write-Host "  Testing: $($test.Name)..." -NoNewline
        $result = Test-ZscalerCertificate @test
        $results += $result

        if ($result.Status -eq "Pass") {
            Write-Host " PASS" -ForegroundColor Green
        } else {
            Write-Host " FAIL" -ForegroundColor Red
            Write-Host "    Errors: $($result.Errors -join ', ')" -ForegroundColor Red
        }
    }

    # Test firewall certificates
    Write-Host "`nTesting Firewall Certificates..." -ForegroundColor Yellow
    $fwTests = @(
        @{Name = "Palo Alto Mgmt"; URL = "https://fw-mgmt.company.com"; ExpectedCN = "fw-mgmt.company.com" },
        @{Name = "GlobalProtect VPN"; URL = "https://vpn.company.com"; ClientCert = $true },
        @{Name = "F5 Management"; URL = "https://f5-mgmt.company.com"; ExpectedCN = "f5-mgmt.company.com" }
    )

    foreach ($test in $fwTests) {
        Write-Host "  Testing: $($test.Name)..." -NoNewline
        $result = Test-FirewallCertificate @test
        $results += $result

        if ($result.Status -eq "Pass") {
            Write-Host " PASS" -ForegroundColor Green
        } else {
            Write-Host " FAIL" -ForegroundColor Red
            Write-Host "    Errors: $($result.Errors -join ', ')" -ForegroundColor Red
        }
    }

    # Test OCSP and CRL endpoints
    Write-Host "`nTesting PKI Infrastructure..." -ForegroundColor Yellow
    $infraTests = @(
        @{Name = "OCSP Responder"; URL = "http://ocsp.company.com/ocsp"; ExpectedCN = "" },
        @{Name = "CRL Distribution"; URL = "http://crl.company.com/crl/IssuingCA01.crl"; ExpectedCN = "" }
    )

    foreach ($test in $infraTests) {
        Write-Host "  Testing: $($test.Name)..." -NoNewline
        try {
            $response = Invoke-WebRequest -Uri $test.URL -Method Head -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Host " PASS" -ForegroundColor Green
                $results += @{
                    Name   = $test.Name
                    URL    = $test.URL
                    Status = "Pass"
                    Errors = @()
                }
            }
        } catch {
            Write-Host " FAIL" -ForegroundColor Red
            $results += @{
                Name   = $test.Name
                URL    = $test.URL
                Status = "Fail"
                Errors = @($_.Exception.Message)
            }
        }
    }

    # Generate summary
    Write-Host "`n" + ("=" * 50)
    Write-Host "Test Summary:" -ForegroundColor Cyan
    $passed = ($results | Where-Object { $_.Status -eq "Pass" }).Count
    $failed = ($results | Where-Object { $_.Status -eq "Fail" }).Count
    $total = $results.Count

    Write-Host "  Total Tests: $total"
    Write-Host "  Passed: $passed" -ForegroundColor Green
    Write-Host "  Failed: $failed" -ForegroundColor Red
    Write-Host "  Success Rate: $([math]::Round(($passed/$total)*100, 2))%"

    # Generate reports
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

    # CSV Report
    $csvPath = ".\PKI-Test-Results-$timestamp.csv"
    $results | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "`nCSV report saved to: $csvPath" -ForegroundColor Green

    # HTML Dashboard
    $htmlPath = ".\PKI-Dashboard-$timestamp.html"
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>PKI Test Dashboard - $timestamp</title>
    <style>
        body {
            background-color: #1e1e1e;
            color: #e0e0e0;
            font-family: 'Segoe UI', Arial, sans-serif;
            padding: 20px;
        }
        h1 {
            color: #4db8ff;
            border-bottom: 2px solid #4db8ff;
            padding-bottom: 10px;
        }
        .summary {
            background-color: #2e4053;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }
        th {
            background-color: #2e4053;
            color: #4db8ff;
            padding: 12px;
            text-align: left;
            border: 1px solid #34495e;
        }
        td {
            padding: 10px;
            border: 1px solid #34495e;
        }
        tr:nth-child(even) { background-color: #2c3e50; }
        tr:hover { background-color: #34495e; }
        .pass {
            color: #52be80;
            font-weight: bold;
        }
        .fail {
            color: #ec7063;
            font-weight: bold;
        }
        .error {
            color: #f39c12;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <h1>Enterprise PKI Test Dashboard</h1>
    <div class="summary">
        <h2>Test Summary</h2>
        <p>Test Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p>Total Tests: $total</p>
        <p><span class="pass">Passed: $passed</span> | <span class="fail">Failed: $failed</span></p>
        <p>Success Rate: $([math]::Round(($passed/$total)*100, 2))%</p>
    </div>
    <table>
        <thead>
            <tr>
                <th>Test Name</th>
                <th>URL/Target</th>
                <th>Status</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
"@

    foreach ($result in $results) {
        $statusClass = if ($result.Status -eq "Pass") { "pass" } else { "fail" }
        $errors = if ($result.Errors.Count -gt 0) { $result.Errors -join "<br/>" } else { "No errors" }
        $html += @"
            <tr>
                <td>$($result.Name)</td>
                <td>$($result.URL)</td>
                <td class="$statusClass">$($result.Status)</td>
                <td class="error">$errors</td>
            </tr>
"@
    }

    $html += @"
        </tbody>
    </table>
</body>
</html>
"@

    $html | Out-File $htmlPath
    Write-Host "HTML dashboard saved to: $htmlPath" -ForegroundColor Green

    # Alert on failures
    if ($failed -gt 0) {
        Write-Host "`nWARNING: $failed tests failed!" -ForegroundColor Red

        # Send email alert if configured
        if (Test-Path ".\email-config.json") {
            $emailConfig = Get-Content ".\email-config.json" | ConvertFrom-Json

            $body = "PKI Test Results:`n`n"
            $body += "Total Tests: $total`n"
            $body += "Passed: $passed`n"
            $body += "Failed: $failed`n`n"
            $body += "Failed Tests:`n"

            $failedTests = $results | Where-Object { $_.Status -eq "Fail" }
            foreach ($test in $failedTests) {
                $body += "  - $($test.Name): $($test.Errors -join ', ')`n"
            }

            Send-MailMessage `
                -To $emailConfig.To `
                -From $emailConfig.From `
                -Subject "PKI Test Failures Detected - $failed Failed" `
                -Body $body `
                -SmtpServer $emailConfig.SmtpServer `
                -Port $emailConfig.Port

            Write-Host "Alert email sent to $($emailConfig.To)" -ForegroundColor Yellow
        }
    }

    return $results
}

# Execute comprehensive test
$testResults = Test-EnterprisePKI
