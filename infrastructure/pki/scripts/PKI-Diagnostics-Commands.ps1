# PKI-Diagnostics-Commands.ps1
# Collection of diagnostic commands for PKI troubleshooting

# Windows Diagnostics
Write-Host "=== Windows PKI Diagnostics ===" -ForegroundColor Cyan

# Check auto-enrollment status
Write-Host "`nTesting auto-enrollment..." -ForegroundColor Yellow
certutil -pulse

# View enrollment events
Write-Host "`nRetrieving enrollment events..." -ForegroundColor Yellow
Get-WinEvent -LogName Application | Where-Object { $_.Id -in @(19, 20, 21) } | Select-Object -First 10 | Format-Table

# Test CA connectivity
Write-Host "`nTesting CA connectivity..." -ForegroundColor Yellow
certutil -ping -config "PKI-ICA-01.company.local\Company Issuing CA 01"

# View certificate templates
Write-Host "`nListing available certificate templates..." -ForegroundColor Yellow
certutil -CATemplates

# Check certificate cache - Machine store
Write-Host "`nMachine certificate store contents..." -ForegroundColor Yellow
certutil -store -machine My | Select-String "Subject|Issuer|Serial|NotAfter" | ForEach-Object { $_.Line.Trim() }

# Check certificate cache - User store
Write-Host "`nUser certificate store contents..." -ForegroundColor Yellow
certutil -store -user My | Select-String "Subject|Issuer|Serial|NotAfter" | ForEach-Object { $_.Line.Trim() }

# Linux Diagnostics
Write-Host "`n=== Linux PKI Diagnostics ===" -ForegroundColor Cyan

# Check certificate enrollment (example commands)
Write-Host @"
Linux diagnostic commands (run on Linux systems):

# Check certificate enrollment
openssl s_client -connect ca.company.com.au:443 -showcerts

# Test SCEP enrollment
curl -v https://ndes.company.com.au/certsrv/mscep/mscep.dll

# View certificate details
openssl x509 -in cert.pem -text -noout

# Verify certificate chain
openssl verify -CAfile ca-chain.pem cert.pem
"@ -ForegroundColor Gray

# Additional Windows diagnostics
Write-Host "`n=== Additional Windows Diagnostics ===" -ForegroundColor Cyan

# Check certificate template permissions
Write-Host "`nChecking certificate template permissions..." -ForegroundColor Yellow
try {
    Get-ADObject -Filter 'objectClass -eq "pKICertificateTemplate"' -Properties * |
    Select-Object Name, displayName | Format-Table
} catch {
    Write-Host "Could not retrieve template information: $_" -ForegroundColor Red
}

# Check Certificate Services event logs
Write-Host "`nRetrieving Certificate Services events..." -ForegroundColor Yellow
Get-WinEvent -LogName "Microsoft-Windows-CertificationAuthority/Operational" -MaxEvents 10 |
Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap

# Test certificate validation
Write-Host "`nTesting certificate chain validation..." -ForegroundColor Yellow
$testCert = Get-ChildItem Cert:\LocalMachine\My | Select-Object -First 1
if ($testCert) {
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $result = $chain.Build($testCert)
    Write-Host "Chain validation result: $result" -ForegroundColor $(if ($result) { "Green" } else { "Red" })

    if (-not $result) {
        Write-Host "Chain status:" -ForegroundColor Yellow
        foreach ($status in $chain.ChainStatus) {
            Write-Host "  $($status.Status): $($status.StatusInformation)" -ForegroundColor Red
        }
    }
}

# Check CRL and OCSP connectivity
Write-Host "`nTesting CRL distribution points..." -ForegroundColor Yellow
$crlUrls = @(
    "http://crl.company.com.au/IssuingCA01.crl",
    "http://crl.company.com.au/IssuingCA02.crl"
)

foreach ($url in $crlUrls) {
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
        Write-Host "  $url : Accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "  $url : Not accessible ($_)" -ForegroundColor Red
    }
}

Write-Host "`nTesting OCSP responders..." -ForegroundColor Yellow
$ocspUrls = @(
    "http://ocsp.company.com.au",
    "http://ocsp2.company.com.au"
)

foreach ($url in $ocspUrls) {
    try {
        $response = Test-NetConnection -ComputerName ($url -replace 'http://', '') -Port 80
        Write-Host "  $url : $(if($response.TcpTestSucceeded) {'Accessible'} else {'Not accessible'})" -ForegroundColor $(if ($response.TcpTestSucceeded) { "Green" } else { "Red" })
    } catch {
        Write-Host "  $url : Connection failed" -ForegroundColor Red
    }
}

Write-Host "`nDiagnostics completed." -ForegroundColor Green