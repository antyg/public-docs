# Configure-AutoEnrollment-Policy.ps1
# Configure Auto-Enrollment GPO for PKI certificates

param(
    [Parameter(Mandatory=$true)]
    [string]$GPOName = "PKI-AutoEnrollment-Policy"
)

# Configure Auto-Enrollment GPO
Write-Host "Configuring Auto-Enrollment GPO: $GPOName" -ForegroundColor Cyan

# Computer Configuration
Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7
# Value 7 = Enroll certificates + Renew expired + Update pending + Remove revoked

Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationPercent" -Type DWord -Value 10

Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationStoreNames" -Type MultiString -Value @("MY","Root","CA")

# User Configuration
Set-GPRegistryValue -Name $GPOName -Key "HKCU\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7

Write-Host "Auto-Enrollment GPO configuration completed successfully" -ForegroundColor Green