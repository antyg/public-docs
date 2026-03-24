# Install-NDES.ps1
# Configures NDES/SCEP server for mobile device enrollment

Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {

    # Install IIS and NDES role
    Install-WindowsFeature -Name ADCS-Device-Enrollment, Web-Server, Web-Common-Http, Web-Filtering, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter -IncludeManagementTools

    # Create NDES service account
    Import-Module ActiveDirectory
    $password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

    New-ADUser -Name "svc-NDES" `
        -UserPrincipalName "svc-NDES@company.local" `
        -Path "OU=Service-Accounts,DC=company,DC=local" `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -CannotChangePassword $true

    # Add to IIS_IUSRS group
    Add-ADGroupMember -Identity "IIS_IUSRS" -Members "svc-NDES"

    # Configure NDES
    Install-ADCSNetworkDeviceEnrollmentService `
        -ApplicationPoolIdentity `
        -RAName "Company-NDES-RA" `
        -RACountry "AU" `
        -RACompany "Company Australia" `
        -RACity "Sydney" `
        -RAState "NSW" `
        -CAConfig "PKI-ICA-01.company.local\Company Issuing CA 01" `
        -Force

    # Configure IIS for NDES
    Import-Module WebAdministration

    # Configure application pool
    Set-ItemProperty -Path "IIS:\AppPools\SCEP" -Name processIdentity.identityType -Value SpecificUser
    Set-ItemProperty -Path "IIS:\AppPools\SCEP" -Name processIdentity.userName -Value "company\svc-NDES"
    Set-ItemProperty -Path "IIS:\AppPools\SCEP" -Name processIdentity.password -Value "P@ssw0rd123!"

    # Configure NDES registry settings
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "EncryptionTemplate" -Value "Company-Mobile-Device"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "GeneralPurposeTemplate" -Value "Company-Mobile-Device"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "SignatureTemplate" -Value "Company-Mobile-Device"

    # Configure password cache
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP\UseSinglePassword" -Name "UseSinglePassword" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "PasswordMax" -Value 100
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "PasswordLength" -Value 16
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP" -Name "PasswordValidity" -Value 60  # minutes

    # Restart IIS
    iisreset /restart

    Write-Host "NDES configured successfully!" -ForegroundColor Green
}