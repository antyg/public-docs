# Install-ADCS.ps1
# Installs and configures AD CS on Issuing CA servers

# Install CA role on PKI-ICA-01 (Primary)
$session = New-PSSession -ComputerName "PKI-ICA-01" -Credential $credential

Invoke-Command -Session $session -ScriptBlock {
    
    # Install AD CS role
    Install-WindowsFeature -Name AD-Certificate, ADCS-Cert-Authority, ADCS-Web-Enrollment, ADCS-Online-Cert -IncludeManagementTools
    
    # Import AD CS deployment module
    Import-Module ADCSDeployment
    
    # Configure CA
    Install-ADCSCertificationAuthority `
        -CAType EnterpriseSubordinateCA `
        -CACommonName "Company Issuing CA 01" `
        -KeyLength 4096 `
        -HashAlgorithm SHA256 `
        -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
        -DatabaseDirectory "E:\CertData\Database" `
        -LogDirectory "E:\CertData\Logs" `
        -ValidityPeriod Years `
        -ValidityPeriodUnits 10 `
        -Force
    
    # The subordinate CA certificate request will be generated
    # This needs to be signed by the Root CA
    
    Write-Host "CA role installed. Certificate request generated at C:\ICA01.req" -ForegroundColor Yellow
}

# Copy certificate request to local machine
Copy-Item -FromSession $session -Path "C:\ICA01.req" -Destination "C:\PKI\Requests\ICA01.req"

# Repeat for PKI-ICA-02
$session2 = New-PSSession -ComputerName "PKI-ICA-02" -Credential $credential

Invoke-Command -Session $session2 -ScriptBlock {
    
    Install-WindowsFeature -Name AD-Certificate, ADCS-Cert-Authority, ADCS-Web-Enrollment, ADCS-Online-Cert -IncludeManagementTools
    
    Import-Module ADCSDeployment
    
    Install-ADCSCertificationAuthority `
        -CAType EnterpriseSubordinateCA `
        -CACommonName "Company Issuing CA 02" `
        -KeyLength 4096 `
        -HashAlgorithm SHA256 `
        -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
        -DatabaseDirectory "E:\CertData\Database" `
        -LogDirectory "E:\CertData\Logs" `
        -ValidityPeriod Years `
        -ValidityPeriodUnits 10 `
        -Force
}

Copy-Item -FromSession $session2 -Path "C:\ICA02.req" -Destination "C:\PKI\Requests\ICA02.req"

Write-Host "Both CA servers configured. Submit requests to Root CA for signing." -ForegroundColor Green