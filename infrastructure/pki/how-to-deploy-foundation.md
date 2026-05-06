---
title: "How to Deploy the PKI Foundation"
status: "draft"
last_updated: "2026-03-17"
audience: "Infrastructure Engineers"
document_type: "how-to"
domain: "infrastructure"
platform: "PKI"
---

# How to Deploy the PKI Foundation

This guide covers deploying the Azure-based root CA, configuring HSM-protected key storage, deploying issuing Certificate Authorities on Windows Server 2022, and configuring CRL distribution and OCSP responder services.

## Prerequisites

Before starting deployment, confirm all of the following are in place:

**Azure requirements:**
- Enterprise Agreement or CSP subscription active with a confirmed Subscription ID
- Azure AD tenant configured with Global Administrator access
- Budget approval obtained from Finance
- Network address allocation confirmed (this deployment uses `10.50.0.0/16`)
- Naming conventions approved
- PKI Administrators, PKI Operators, and PKI Auditors security groups created in Entra ID
- MFA and [Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) configured for all admin accounts

**On-premises requirements:**
- Active Directory domain operational (`company.local` in these procedures)
- DNS servers reachable at the designated addresses
- OU path `OU=PKI-Servers,OU=Infrastructure,DC=company,DC=local` created
- Domain Admin credentials available
- ExpressRoute or VPN connectivity to Azure provisioned

**Team access:**
- PKI team members have activated PIM roles
- Network team has confirmed firewall rules for ports 135, 443, 80 (CRL/OCSP), and 389/636 (LDAP)

## Pre-Deployment Checklist

Work through this checklist before running any deployment scripts. All items must be confirmed before proceeding.

- [ ] Azure subscription ID recorded
- [ ] Target regions confirmed: Australia East (primary), Australia Southeast (DR)
- [ ] Resource group naming convention approved
- [ ] HSM SKU availability confirmed in Australia East ([Azure Dedicated HSM availability](https://learn.microsoft.com/en-us/azure/dedicated-hsm/overview))
- [ ] Certificate policy documented and approved
- [ ] CRL distribution URLs registered in DNS (`crl.company.com.au`, `ocsp.company.com.au`, `aia.company.com.au`)
- [ ] Windows Server 2022 licences available for 5 VMs (2x CA, 1x NDES, 2x OCSP)
- [ ] Service account passwords prepared and stored in secrets manager
- [ ] Backup storage account provisioned
- [ ] Change request approved for production network changes

## Step 1: Provision Azure Resource Groups and Governance

Connect to Azure and set the subscription context:

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"
```

Create the four PKI resource groups. Each group receives a CanNotDelete resource lock to prevent accidental removal:

```powershell
$resourceGroups = @(
    @{ Name = "RG-PKI-Core-Production";     Location = "australiaeast" },
    @{ Name = "RG-PKI-KeyVault-Production"; Location = "australiaeast" },
    @{ Name = "RG-PKI-Network-Production";  Location = "australiaeast" },
    @{ Name = "RG-PKI-Monitor-Production";  Location = "australiaeast" }
)

foreach ($rg in $resourceGroups) {
    New-AzResourceGroup -Name $rg.Name -Location $rg.Location -Force
    New-AzResourceLock -LockLevel CanNotDelete `
        -LockName "PKI-Protection-Lock" `
        -ResourceGroupName $rg.Name `
        -LockNotes "Protected PKI infrastructure - deletion requires approval"
}
```

Apply tags to all resource groups covering Environment, Department, CostCenter, Owner, Compliance (`ACSC-ISM`), BusinessCriticality, and DR objectives (RPO 1 hour, RTO 4 hours).

## Step 2: Configure Azure RBAC

Create a custom role for PKI administrators, then assign roles to the three security groups:

```powershell
# Assign PKI Infrastructure Administrator role to PKI-Administrators group
$pkiAdmins = (Get-AzADGroup -DisplayName "PKI-Administrators").Id
New-AzRoleAssignment -ObjectId $pkiAdmins `
    -RoleDefinitionName "PKI Infrastructure Administrator" `
    -ResourceGroupName "RG-PKI-Core-Production"

# Assign Contributor to PKI-Operators
$pkiOps = (Get-AzADGroup -DisplayName "PKI-Operators").Id
New-AzRoleAssignment -ObjectId $pkiOps `
    -RoleDefinitionName "Contributor" `
    -ResourceGroupName "RG-PKI-Core-Production"

# Assign Reader to PKI-Auditors
$pkiAudit = (Get-AzADGroup -DisplayName "PKI-Auditors").Id
New-AzRoleAssignment -ObjectId $pkiAudit `
    -RoleDefinitionName "Reader" `
    -ResourceGroupName "RG-PKI-Core-Production"
```

The custom `PKI Infrastructure Administrator` role must include `Microsoft.KeyVault/vaults/delete` and `Microsoft.KeyVault/vaults/purge` in its `NotActions` to prevent accidental key vault deletion. See [Azure custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles) for role definition syntax.

## Step 3: Deploy the Virtual Network

Deploy the PKI virtual network with address space `10.50.0.0/16` in Australia East, with DNS servers pointing to your domain controllers and Azure DNS (`168.63.129.16`):

```powershell
$virtualNetwork = New-AzVirtualNetwork `
    -Name "VNET-PKI-PROD" `
    -ResourceGroupName "RG-PKI-Network-Production" `
    -Location "australiaeast" `
    -AddressPrefix "10.50.0.0/16" `
    -DnsServer @("10.10.10.10", "10.10.10.11", "168.63.129.16") `
    -EnableDdosProtection $true
```

Create subnets with their Network Security Groups. The HSM subnet requires a delegation to `Microsoft.HardwareSecurityModules/dedicatedHSMs`:

| Subnet | Address Prefix | Purpose |
|---|---|---|
| PKI-Core | 10.50.1.0/24 | Issuing CAs and core services |
| PKI-HSM | 10.50.2.0/24 | Dedicated HSM (delegated subnet) |
| PKI-Management | 10.50.3.0/24 | Management and jump hosts |
| PKI-Services | 10.50.4.0/24 | NDES, OCSP, web enrollment |
| PKI-Web | 10.50.5.0/24 | Public-facing CRL/OCSP endpoints |
| AzureBastionSubnet | 10.50.250.0/24 | Azure Bastion |
| AzureFirewallSubnet | 10.50.254.0/24 | Azure Firewall |
| GatewaySubnet | 10.50.255.0/24 | ExpressRoute/VPN gateway |

Configure NSG rules to allow port 443 inbound from corporate networks to PKI-Core, port 80 inbound from any to PKI-Web (CRL/OCSP), and LDAP (389/636) from PKI-Core to your domain controllers. See [Azure Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) for rule syntax.

## Step 4: Deploy Azure Key Vault with HSM Protection

Create the Key Vault with soft-delete and purge protection enabled. These settings are required by the ACSC ISM for cryptographic key material and cannot be disabled once set:

```powershell
$keyVault = New-AzKeyVault `
    -Name "KV-PKI-RootCA-Prod" `
    -ResourceGroupName "RG-PKI-KeyVault-Production" `
    -Location "australiaeast" `
    -Sku "Premium" `
    -EnableSoftDelete `
    -EnablePurgeProtection `
    -EnabledForDeployment `
    -EnabledForTemplateDeployment
```

Grant the PKI Administrators group Key, Secret, and Certificate management permissions:

```powershell
Set-AzKeyVaultAccessPolicy `
    -VaultName "KV-PKI-RootCA-Prod" `
    -ObjectId (Get-AzADGroup -DisplayName "PKI-Administrators").Id `
    -PermissionsToKeys @("create","get","list","sign","unwrapKey","wrapKey","verify","backup","restore") `
    -PermissionsToCertificates @("create","get","list","update","import","delete","backup","restore","managecontacts","manageissuers")
```

See [Azure Key Vault best practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices) for additional hardening guidance.

## Step 5: Deploy Azure Private CA (Root CA)

Configure [Azure Private CA](https://learn.microsoft.com/en-us/azure/private-ca/overview) as the HSM-protected root Certificate Authority. The root CA private key never leaves the HSM.

Create the Private CA service in the `RG-PKI-KeyVault-Production` resource group, Australia East:

```powershell
$rootCA = New-AzPrivateCA `
    -ResourceGroupName "RG-PKI-KeyVault-Production" `
    -Name "Company-Root-CA-G2" `
    -Location "australiaeast" `
    -KeyVaultId $keyVault.ResourceId `
    -KeyVaultKeyId "https://KV-PKI-RootCA-Prod.vault.azure.net/keys/RootCA-G2" `
    -Subject "CN=Company Root CA G2,O=Company Australia,C=AU" `
    -ValidityInMonths 120 `
    -SigningAlgorithm "SHA256WITHRSA" `
    -KeySize 4096
```

Root CA validity is set to 10 years (120 months). Issuing CA certificates will be issued with a maximum validity of 5 years. See [CA hierarchy planning](https://learn.microsoft.com/en-us/azure/private-ca/ca-hierarchy) for sizing guidance.

## Step 6: Conduct the Key Ceremony

The key ceremony must be conducted with at least two PKI administrators present and must be recorded in the PKI audit log. Follow these steps in sequence:

1. Confirm the HSM is operational and attestation reports are clean — check the Azure portal under Key Vault > Keys
2. Generate the root CA key pair in the HSM using the Azure portal or the PowerShell cmdlet above
3. Record the key thumbprint and store it in the PKI operations register
4. Export the root CA certificate (public key only) for distribution: navigate to Azure portal > Private CA > Download CA certificate
5. Both administrators sign the ceremony record with the date, time, key algorithm (RSA 4096), and key identifier
6. Store the signed ceremony record in the PKI document archive

The private key is HSM-resident only. No export of the private key is possible or permitted.

## Step 7: Provision Windows Server VMs for Issuing CAs

Deploy five Windows Server 2022 VMs across Availability Zones 1 and 2:

```powershell
$vmConfigs = @(
    @{ Name = "PKI-ICA-01";  Size = "Standard_D4s_v5"; IP = "10.50.1.10"; Zone = "1" },
    @{ Name = "PKI-ICA-02";  Size = "Standard_D4s_v5"; IP = "10.50.1.11"; Zone = "2" },
    @{ Name = "PKI-NDES-01"; Size = "Standard_D2s_v5"; IP = "10.50.1.20"; Zone = "1" },
    @{ Name = "PKI-OCSP-01"; Size = "Standard_D2s_v5"; IP = "10.50.1.30"; Zone = "1" },
    @{ Name = "PKI-OCSP-02"; Size = "Standard_D2s_v5"; IP = "10.50.1.31"; Zone = "2" }
)
```

Each VM requires:
- OS disk: Premium LRS, 128 GB
- Data disk: Premium LRS, 256 GB (for CA database on `E:\CertData`)
- Accelerated networking enabled
- Boot diagnostics enabled

After provisioning, run base configuration on all servers:

```powershell
$servers = @("PKI-ICA-01", "PKI-ICA-02", "PKI-NDES-01", "PKI-OCSP-01", "PKI-OCSP-02")

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        Set-TimeZone -Id "AUS Eastern Standard Time"
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

        # Install required features
        Install-WindowsFeature -Name Web-Server,Web-Common-Http,Web-Mgmt-Tools `
            -IncludeManagementTools
        Install-WindowsFeature -Name RSAT-AD-PowerShell,RSAT-DNS-Server

        # Initialise data disk and create PKI directory structure
        Get-Disk | Where-Object PartitionStyle -eq 'raw' |
            Initialize-Disk -PartitionStyle GPT -PassThru |
            New-Partition -AssignDriveLetter -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel "CA-Data" -Confirm:$false

        foreach ($dir in @("E:\CertData","E:\CertData\Database","E:\CertData\Logs",
                           "E:\CertData\Backup","E:\CertData\Templates","E:\CertData\CRL")) {
            New-Item -ItemType Directory -Path $dir -Force
        }

        # Enable certification services auditing
        auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable
        auditpol /set /subcategory:"Object Access" /success:enable /failure:enable
    }
}
```

## Step 8: Domain-Join the PKI Servers

Join all five servers to the domain and place them in the PKI-Servers OU:

```powershell
$domain     = "company.local"
$ouPath     = "OU=PKI-Servers,OU=Infrastructure,DC=company,DC=local"
$credential = Get-Credential -Message "Enter Domain Admin credentials"

foreach ($server in @("10.50.1.10","10.50.1.11","10.50.1.20","10.50.1.30","10.50.1.31")) {
    Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
        param($domain, $ou, $cred, $name)
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
            -ServerAddresses "10.10.10.10","10.10.10.11"
        Add-Computer -DomainName $domain -OUPath $ou `
            -Credential $cred -NewName $name -Restart -Force
    } -ArgumentList $domain, $ouPath, $credential, $serverName
}
```

Wait for servers to restart, then verify domain membership:

```powershell
foreach ($server in @("PKI-ICA-01","PKI-ICA-02","PKI-NDES-01","PKI-OCSP-01","PKI-OCSP-02")) {
    $result = Test-ComputerSecureChannel -Server $server
    Write-Host "$server domain join: $(if ($result) {'OK'} else {'FAILED'})"
}
```

## Step 9: Install AD CS on Issuing CA Servers

Install the AD CS role on both issuing CA servers and generate certificate signing requests (CSRs):

```powershell
# Run on PKI-ICA-01
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    Install-WindowsFeature -Name AD-Certificate,ADCS-Cert-Authority,`
        ADCS-Web-Enrollment,ADCS-Online-Cert -IncludeManagementTools

    Import-Module ADCSDeployment

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
}
```

Repeat for `PKI-ICA-02` with CA common name `Company Issuing CA 02`. Each install generates a CSR file (`C:\ICA01.req`, `C:\ICA02.req`) that must be signed by the root CA.

Copy CSRs to the management workstation:

```powershell
Copy-Item -FromSession $session -Path "C:\ICA01.req" -Destination "C:\PKI\Requests\ICA01.req"
Copy-Item -FromSession $session2 -Path "C:\ICA02.req" -Destination "C:\PKI\Requests\ICA02.req"
```

## Step 10: Submit CSRs to the Root CA and Install Certificates

Submit both CSRs to Azure Private CA through the portal or API, then install the returned certificates on each issuing CA server:

```powershell
# On PKI-ICA-01 after receiving the signed certificate
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    # Install issuing CA certificate
    certutil -installCert "C:\PKI\Certificates\ICA01.crt"

    # Add root CA to trusted root store
    certutil -addstore -f Root "C:\PKI\Certificates\RootCA-G2.crt"

    # Start CA service
    Start-Service CertSvc

    # Configure Active Directory integration
    certutil -setreg CA\DSConfigDN "CN=Configuration,DC=company,DC=local"
    certutil -setreg CA\DSDomainDN "DC=company,DC=local"

    # Configure CRL publication schedule: base 7 days, delta 1 day, overlap 2 days
    certutil -setreg CA\CRLPeriodUnits 7
    certutil -setreg CA\CRLPeriod "Days"
    certutil -setreg CA\CRLDeltaPeriodUnits 1
    certutil -setreg CA\CRLDeltaPeriod "Days"
    certutil -setreg CA\CRLOverlapUnits 2
    certutil -setreg CA\CRLOverlapPeriod "Days"

    # Configure AIA and CDP distribution points
    certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\System32\CertSrv\CertEnroll\%1_%3%4.crt`n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11`n2:http://aia.company.com.au/%1_%3%4.crt"
    certutil -setreg CA\CRLPublicationURLs "65:C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl`n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10`n6:http://crl.company.com.au/%3%8%9.crl"

    # Enable all audit events
    certutil -setreg CA\AuditFilter 127

    Restart-Service CertSvc

    # Publish initial CRL
    certutil -CRL
}
```

Repeat on `PKI-ICA-02`.

## Step 11: Deploy OCSP Responders

Deploy the Online Responder role on both OCSP servers to provide real-time certificate status. OCSP is required by the [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) for environments where CRL latency is unacceptable:

```powershell
Invoke-Command -ComputerName "PKI-OCSP-01" -ScriptBlock {
    Install-WindowsFeature -Name ADCS-Online-Cert -IncludeManagementTools
    Import-Module ADCSDeployment
    Install-ADCSOnlineResponder -Force

    # Configure OCSP revocation configuration
    # Open OCSP snap-in and create revocation configuration pointing to ICA01
    # OCSP signing certificate is auto-enrolled using Company-OCSP-Signing template
}
```

Configure the OCSP signing certificate template with a short validity (2 weeks) and auto-enrolment for the PKI-Servers group. Place the OCSP URL (`http://ocsp.company.com.au`) in the Authority Information Access extension of all issued certificates.

## Step 12: Configure CRL Distribution Infrastructure

Ensure the CRL distribution point is accessible from both internal networks and the internet. The HTTP CRL endpoint must be resolvable externally for any certificate that may be validated outside the corporate network.

Configure IIS on PKI-ICA-01 to serve CRL files from `C:\Windows\System32\CertSrv\CertEnroll\`:

```powershell
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    Import-Module WebAdministration

    # Create a virtual directory for CRL files
    New-WebVirtualDirectory -Site "Default Web Site" `
        -Name "CRL" `
        -PhysicalPath "C:\Windows\System32\CertSrv\CertEnroll"

    # Allow directory browsing for CRL retrieval
    Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse `
        -Name enabled -Value $true `
        -PSPath "IIS:\Sites\Default Web Site\CRL"
}
```

Verify CRL publication by downloading the CRL file from the HTTP endpoint after the initial `certutil -CRL` run:

```powershell
Invoke-WebRequest -Uri "http://crl.company.com.au/IssuingCA01.crl" -Method Get
```

## Step 13: Deploy Certificate Templates

Create and publish certificate templates on both issuing CAs. The minimum required templates for initial operation are:

| Template Name | Purpose | Validity | Auto-Enrol |
|---|---|---|---|
| Company-User-Authentication | User logon | 1 year | Yes |
| Company-User-Email | S/MIME | 1 year | Yes |
| Company-Computer-Authentication | Machine auth | 2 years | Yes |
| Company-Domain-Controller | DC certificates | 3 years | Yes |
| Company-Web-Server | TLS/SSL | 1 year | No |
| Company-OCSP-Signing | OCSP responder | 2 weeks | Yes |
| Company-Mobile-Device | SCEP/NDES | 2 years | No |
| Company-Code-Signing | Code signing | 1 year | No |

Publish templates to each issuing CA:

```powershell
$templates = @(
    "Company-User-Authentication", "Company-User-Email",
    "Company-Computer-Authentication", "Company-Domain-Controller",
    "Company-Web-Server", "Company-OCSP-Signing",
    "Company-Mobile-Device", "Company-Code-Signing"
)

foreach ($server in @("PKI-ICA-01", "PKI-ICA-02")) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        param($templates)
        foreach ($t in $templates) { certutil -SetCATemplates +$t }
        Restart-Service CertSvc
    } -ArgumentList (,$templates)
}
```

## Step 14: Configure Auto-Enrolment GPOs

Create GPOs to configure automatic certificate enrolment for computers and users. See [Certificate Auto-Enrollment](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/certificate-auto-enrollment) for policy details.

```powershell
Import-Module GroupPolicy

# Computer auto-enrolment
$computerGPO = New-GPO -Name "PKI-Computer-AutoEnrollment"
Set-GPRegistryValue -Name $computerGPO.DisplayName `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7

# User auto-enrolment
$userGPO = New-GPO -Name "PKI-User-AutoEnrollment"
Set-GPRegistryValue -Name $userGPO.DisplayName `
    -Key "HKCU\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" -Type DWord -Value 7

# Link GPOs to OUs
foreach ($ou in @("OU=Workstations,DC=company,DC=local","OU=Servers,DC=company,DC=local")) {
    New-GPLink -Name $computerGPO.DisplayName -Target $ou -LinkEnabled Yes
}
foreach ($ou in @("OU=Users,DC=company,DC=local")) {
    New-GPLink -Name $userGPO.DisplayName -Target $ou -LinkEnabled Yes
}

# Grant auto-enrolment permissions on templates
# Set ExtendedRight "Enroll" (0e10c968-...) and "AutoEnroll" (a05b8cc2-...) on each template object
```

## Validation

Run end-to-end validation after completing all steps:

```powershell
# Verify CA service is running on both issuing CAs
foreach ($server in @("PKI-ICA-01","PKI-ICA-02")) {
    $svc = Get-Service -ComputerName $server -Name CertSvc
    Write-Host "$server CertSvc: $($svc.Status)"
}

# Test certificate request against each CA
$cert = Get-Certificate -Template "Company-Web-Server" `
    -DnsName "test.company.com.au" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -Url "https://pki-ica-01.company.local/certsrv"
Write-Host "Certificate issuance: $($cert.Status)"

# Verify CRL download
$crlResponse = Invoke-WebRequest -Uri "http://crl.company.com.au/IssuingCA01.crl" -Method Get
Write-Host "CRL HTTP status: $($crlResponse.StatusCode)"

# Test OCSP responder reachability
$ocsp = Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80
Write-Host "OCSP reachable: $($ocsp.TcpTestSucceeded)"

# Trigger auto-enrolment and verify certificates appear
certutil -pulse
Start-Sleep -Seconds 15
$autoCerts = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*$env:COMPUTERNAME*" -and
                   $_.NotBefore -gt (Get-Date).AddMinutes(-5) }
Write-Host "Auto-enrolled certificates: $($autoCerts.Count)"
```

Expected results for a healthy deployment:
- Both CA services report `Running`
- Certificate issuance status is `Issued`
- CRL HTTP status is `200`
- OCSP TCP test succeeds
- At least one auto-enrolled certificate is present

## Troubleshooting

**CA service will not start after certificate installation**
Check the Windows Application event log on the CA server for event ID 100 from CertSvc. The most common cause is a mismatch between the installed certificate and the CA's private key. Run `certutil -verifykeys` to confirm key association.

**CSR submission to Azure Private CA returns an error**
Confirm the submitting identity has the `Private CA Certificate Requester` role on the Azure Private CA resource. See [Azure Private CA roles](https://learn.microsoft.com/en-us/azure/private-ca/assign-permissions).

**CRL not reachable from external networks**
Confirm the DNS entry for `crl.company.com.au` resolves to an externally accessible IP address. Confirm IIS is serving the virtual directory with directory browsing enabled and no authentication requirement on the CRL virtual directory.

**Auto-enrolment GPO not applying**
Run `gpresult /R` on an affected workstation to confirm the GPO is being received. Confirm the template has the `AutoEnroll` extended right granted to the appropriate group. Run `certutil -pulse` to trigger enrolment immediately without waiting for the background scheduler.

**OCSP signing certificate not enrolling**
Confirm the `Company-OCSP-Signing` template is published on both issuing CAs and that the OCSP servers are members of the `PKI-Servers` security group. The template must have `AutoEnroll` granted to this group.

## Related Resources

- [Azure Private CA overview](https://learn.microsoft.com/en-us/azure/private-ca/overview)
- [Azure Key Vault best practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Azure Dedicated HSM overview](https://learn.microsoft.com/en-us/azure/dedicated-hsm/overview)
- [AD CS deployment guide — Windows Server](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/active-directory-certificate-services-overview)
- [Certificate Auto-Enrollment in Windows](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/certificate-auto-enrollment)
- [Azure RBAC custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Azure Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Online Responder deployment guide](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/configure-online-responder)
- [Azure Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
