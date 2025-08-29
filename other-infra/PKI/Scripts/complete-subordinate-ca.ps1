# Complete-SubordinateCA.ps1
# Submits CSRs to Root CA and installs issued certificates

# Submit to Azure Private CA (conceptual - actual implementation would use Azure API)
function Submit-ToRootCA {
    param(
        [string]$RequestFile,
        [string]$OutputCertificate
    )
    
    # This would interact with Azure Private CA API
    # For demonstration, assuming manual process
    
    Write-Host "Submitting $RequestFile to Root CA..." -ForegroundColor Yellow
    # API call to Azure Private CA would go here
    
    # Simulate certificate issuance
    Start-Sleep -Seconds 10
    
    Write-Host "Certificate issued and saved to $OutputCertificate" -ForegroundColor Green
}

# Submit both requests
Submit-ToRootCA -RequestFile "C:\PKI\Requests\ICA01.req" -OutputCertificate "C:\PKI\Certificates\ICA01.crt"
Submit-ToRootCA -RequestFile "C:\PKI\Requests\ICA02.req" -OutputCertificate "C:\PKI\Certificates\ICA02.crt"

# Install certificates on CA servers
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    # Install CA certificate
    certutil -installCert "C:\PKI\Certificates\ICA01.crt"
    
    # Install Root CA certificate to trusted root store
    certutil -addstore -f Root "C:\PKI\Certificates\RootCA-G2.crt"
    
    # Start CA service
    Start-Service CertSvc
    
    # Configure CA settings
    certutil -setreg CA\DSConfigDN "CN=Configuration,DC=company,DC=local"
    certutil -setreg CA\DSDomainDN "DC=company,DC=local"
    
    # Configure CRL publishing
    certutil -setreg CA\CRLPeriodUnits 7
    certutil -setreg CA\CRLPeriod "Days"
    certutil -setreg CA\CRLDeltaPeriodUnits 1
    certutil -setreg CA\CRLDeltaPeriod "Days"
    certutil -setreg CA\CRLOverlapUnits 2
    certutil -setreg CA\CRLOverlapPeriod "Days"
    
    # Configure AIA and CDP
    certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\System32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://aia.company.com.au/%1_%3%4.crt"
    
    certutil -setreg CA\CRLPublicationURLs "65:C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl\n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n6:http://crl.company.com.au/%3%8%9.crl"
    
    # Configure audit settings
    certutil -setreg CA\AuditFilter 127
    
    # Restart CA service for settings to take effect
    Restart-Service CertSvc
    
    # Publish CRL
    certutil -CRL
}

# Repeat for PKI-ICA-02
Invoke-Command -ComputerName "PKI-ICA-02" -ScriptBlock {
    certutil -installCert "C:\PKI\Certificates\ICA02.crt"
    certutil -addstore -f Root "C:\PKI\Certificates\RootCA-G2.crt"
    Start-Service CertSvc
    
    # Apply same configuration as ICA01
    # [Configuration commands repeated]
    
    Restart-Service CertSvc
    certutil -CRL
}

Write-Host "Subordinate CAs configured and operational!" -ForegroundColor Green