# Configure Auto-Enrollment GPO
$GPOName = "PKI-AutoEnrollment-Policy"

# Computer Configuration
Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7
# Value 7 = Enroll certificates + Renew expired + Update pending + Remove revoked

Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationPercent" -Type DWord -Value 10

Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationStoreNames" -Type MultiString -Value @("MY", "Root", "CA")

# User Configuration
Set-GPRegistryValue -Name $GPOName -Key "HKCU\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7
