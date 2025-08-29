# Comprehensive certificate validation script
# Test-EnterprisePKI.ps1

function Test-EnterprisePKI {
    $results = @()

    # Test NetScaler certificates
    $nsTests = @(
        @{Name = "Portal VIP"; URL = "https://portal.company.com"; ExpectedCN = "*.company.com" },
        @{Name = "API Gateway"; URL = "https://api.company.com"; ExpectedCN = "*.company.com" },
        @{Name = "Admin Interface"; URL = "https://admin.company.com:443"; ClientCert = $true }
    )

    foreach ($test in $nsTests) {
        $result = Test-SSLCertificate @test
        $results += $result
    }

    # Test Zscaler integration
    $zsTests = @(
        @{Name = "ZPA Portal"; URL = "https://company.privateaccess.zscaler.com"; ExpectedCA = "Zscaler" },
        @{Name = "ZIA Gateway"; URL = "https://gateway.zscaler.net"; SSLInspection = $true }
    )

    foreach ($test in $zsTests) {
        $result = Test-ZscalerCertificate @test
        $results += $result
    }

    # Test firewall certificates
    $fwTests = @(
        @{Name = "Palo Alto Mgmt"; URL = "https://fw-mgmt.company.com"; ExpectedCN = "fw-mgmt.company.com" },
        @{Name = "GlobalProtect"; URL = "https://vpn.company.com"; ClientCert = $true }
    )

    foreach ($test in $fwTests) {
        $result = Test-FirewallCertificate @test
        $results += $result
    }

    # Generate report
    $results | Export-Csv -Path ".\PKI-Test-Results-$(Get-Date -Format 'yyyyMMdd').csv"

    # Create HTML dashboard
    $html = $results | ConvertTo-Html -Head @"
<style>
    body { background-color: #1e1e1e; color: #e0e0e0; font-family: Arial; }
    table { border-collapse: collapse; width: 100%; }
    th { background-color: #2e4053; color: #4db8ff; padding: 10px; }
    td { padding: 8px; border: 1px solid #34495e; }
    .pass { color: #52be80; }
    .fail { color: #ec7063; }
</style>
"@

    $html | Out-File ".\PKI-Dashboard.html"

    return $results
}

# Execute comprehensive test
$testResults = Test-EnterprisePKI

# Alert on failures
$failures = $testResults | Where-Object { $_.Status -eq "Failed" }
if ($failures.Count -gt 0) {
    Send-MailMessage -To "security@company.com" `
        -Subject "PKI Test Failures Detected" `
        -Body ($failures | Format-Table | Out-String) `
        -SmtpServer "smtp.company.com"
}
