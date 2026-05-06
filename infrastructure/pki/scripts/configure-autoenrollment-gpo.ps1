# Configure-AutoEnrollmentGPO.ps1
# Creates and configures GPOs for certificate auto-enrollment

Import-Module GroupPolicy
Import-Module ActiveDirectory

# Create GPO for Computer Auto-Enrollment
$computerGPO = New-GPO -Name "PKI-Computer-AutoEnrollment" -Comment "Configures certificate auto-enrollment for computers"

# Configure Computer Configuration settings
Set-GPRegistryValue -Name $computerGPO.DisplayName `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" `
    -Type DWord `
    -Value 7  # Enable all auto-enrollment features

Set-GPRegistryValue -Name $computerGPO.DisplayName `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationPercent" `
    -Type DWord `
    -Value 10

Set-GPRegistryValue -Name $computerGPO.DisplayName `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationStoreNames" `
    -Type MultiString `
    -Value @("MY", "Root", "CA", "Trust")

# Create GPO for User Auto-Enrollment
$userGPO = New-GPO -Name "PKI-User-AutoEnrollment" -Comment "Configures certificate auto-enrollment for users"

# Configure User Configuration settings
Set-GPRegistryValue -Name $userGPO.DisplayName `
    -Key "HKCU\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" `
    -Type DWord `
    -Value 7

Set-GPRegistryValue -Name $userGPO.DisplayName `
    -Key "HKCU\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "OfflineExpirationPercent" `
    -Type DWord `
    -Value 10

# Configure certificate template permissions in AD
$templates = Get-ADObject -Filter { objectClass -eq "pKICertificateTemplate" } -SearchBase "CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=company,DC=local"

foreach ($template in $templates) {
    if ($template.Name -like "Company-*") {
        # Grant auto-enrollment permissions
        $acl = Get-Acl -Path "AD:$($template.DistinguishedName)"

        # Add permissions for Domain Computers
        if ($template.Name -like "*Computer*" -or $template.Name -like "*Domain-Controller*") {
            $sid = (Get-ADGroup "Domain Computers").SID
            $permission = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                $sid,
                "ExtendedRight",
                "Allow",
                [Guid]"0e10c968-78fb-11d2-90d4-00c04f79dc55",  # Enroll
                "None",
                [Guid]"00000000-0000-0000-0000-000000000000"
            )
            $acl.AddAccessRule($permission)

            $autoEnrollPermission = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                $sid,
                "ExtendedRight",
                "Allow",
                [Guid]"a05b8cc2-17bc-4802-a710-e7c15ab866a2",  # AutoEnroll
                "None",
                [Guid]"00000000-0000-0000-0000-000000000000"
            )
            $acl.AddAccessRule($autoEnrollPermission)
        }

        # Add permissions for Domain Users
        if ($template.Name -like "*User*") {
            $sid = (Get-ADGroup "Domain Users").SID
            # [Similar permission additions]
        }

        Set-Acl -Path "AD:$($template.DistinguishedName)" -AclObject $acl
    }
}

# Link GPOs to appropriate OUs
$computerOUs = @(
    "OU=Workstations,DC=company,DC=local",
    "OU=Servers,DC=company,DC=local",
    "OU=Domain Controllers,DC=company,DC=local"
)

foreach ($ou in $computerOUs) {
    New-GPLink -Name $computerGPO.DisplayName -Target $ou -LinkEnabled Yes
}

$userOUs = @(
    "OU=Users,DC=company,DC=local",
    "OU=Administrators,DC=company,DC=local"
)

foreach ($ou in $userOUs) {
    New-GPLink -Name $userGPO.DisplayName -Target $ou -LinkEnabled Yes
}

# Force GP update
Invoke-Command -ComputerName (Get-ADComputer -Filter * -SearchBase "OU=Workstations,DC=company,DC=local").Name -ScriptBlock {
    gpupdate /force
} -ErrorAction SilentlyContinue

Write-Host "Auto-enrollment GPOs created and deployed!" -ForegroundColor Green
