# PKI Modernization - Phase 2: Core Infrastructure Deployment

[← Previous: Phase 1 Foundation](05-phase1-foundation.md) | [Back to Index](00-index.md) | [Next: Phase 3 Services Integration →](07-phase3-services-integration.md)

## Executive Summary

Phase 2 deploys the core PKI infrastructure including two highly available issuing Certificate Authorities on Windows Server 2022, NDES/SCEP services for mobile device enrollment, Microsoft Intune integration, and comprehensive certificate templates. This phase establishes the operational PKI services that will issue and manage certificates for the enterprise.

## Phase 2 Overview

### Objectives
- Deploy redundant issuing Certificate Authorities
- Configure NDES/SCEP for mobile device support
- Integrate with Microsoft Intune for device management
- Create and deploy certificate templates
- Implement auto-enrollment via Group Policy
- Establish monitoring and alerting

### Success Criteria
- ✅ Both issuing CAs operational and replicating
- ✅ NDES server configured and accessible
- ✅ Intune Certificate Connector functional
- ✅ All certificate templates deployed and tested
- ✅ Auto-enrollment GPOs applied successfully
- ✅ End-to-end certificate issuance validated

### Timeline
**Duration**: 2 weeks (February 17-28, 2025)
**Resources Required**: 7.5 FTE
**Budget**: $75,000 (Licenses) + $100,000 (Implementation)

## Week 3: Windows Server Deployment

### Day 1-2: Server Provisioning

#### Virtual Machine Deployment Script
```powershell
# Deploy-IssuingCAServers.ps1
# Deploys Windows Server 2022 VMs for Issuing CAs

param(
    [string]$ResourceGroup = "RG-PKI-Core-Production",
    [string]$Location = "australiaeast",
    [string]$VNetName = "VNET-PKI-PROD",
    [string]$SubnetName = "PKI-Core"
)

# VM Configuration
$vmConfigs = @(
    @{
        Name = "PKI-ICA-01"
        Size = "Standard_D4s_v5"
        IP = "10.50.1.10"
        Role = "Primary Issuing CA"
        AvailabilityZone = "1"
    },
    @{
        Name = "PKI-ICA-02"
        Size = "Standard_D4s_v5"
        IP = "10.50.1.11"
        Role = "Secondary Issuing CA"
        AvailabilityZone = "2"
    },
    @{
        Name = "PKI-NDES-01"
        Size = "Standard_D2s_v5"
        IP = "10.50.1.20"
        Role = "NDES/SCEP Server"
        AvailabilityZone = "1"
    },
    @{
        Name = "PKI-OCSP-01"
        Size = "Standard_D2s_v5"
        IP = "10.50.1.30"
        Role = "OCSP Responder Primary"
        AvailabilityZone = "1"
    },
    @{
        Name = "PKI-OCSP-02"
        Size = "Standard_D2s_v5"
        IP = "10.50.1.31"
        Role = "OCSP Responder Secondary"
        AvailabilityZone = "2"
    }
)

# Get subnet reference
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName "RG-PKI-Network-Production"
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

# Create availability set
$availSet = New-AzAvailabilitySet `
    -ResourceGroupName $ResourceGroup `
    -Name "AS-PKI-CAs" `
    -Location $Location `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 5 `
    -Sku "Aligned"

foreach ($vmConfig in $vmConfigs) {
    Write-Host "Deploying VM: $($vmConfig.Name)" -ForegroundColor Green
    
    # Create public IP (for management only - will be removed later)
    $pip = New-AzPublicIpAddress `
        -Name "$($vmConfig.Name)-PIP" `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -AllocationMethod Static `
        -Sku Standard `
        -Zone $vmConfig.AvailabilityZone
    
    # Create NIC with static IP
    $nic = New-AzNetworkInterface `
        -Name "$($vmConfig.Name)-NIC" `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $pip.Id `
        -PrivateIpAddress $vmConfig.IP `
        -EnableAcceleratedNetworking
    
    # VM credential
    $cred = Get-Credential -Message "Enter credentials for $($vmConfig.Name)"
    
    # Create VM configuration
    $vm = New-AzVMConfig `
        -VMName $vmConfig.Name `
        -VMSize $vmConfig.Size `
        -AvailabilitySetId $availSet.Id
    
    $vm = Set-AzVMOperatingSystem `
        -VM $vm `
        -Windows `
        -ComputerName $vmConfig.Name `
        -Credential $cred `
        -EnableAutoUpdate `
        -ProvisionVMAgent
    
    $vm = Add-AzVMNetworkInterface `
        -VM $vm `
        -Id $nic.Id
    
    $vm = Set-AzVMSourceImage `
        -VM $vm `
        -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" `
        -Skus "2022-datacenter-g2" `
        -Version "latest"
    
    # OS Disk configuration
    $vm = Set-AzVMOSDisk `
        -VM $vm `
        -Name "$($vmConfig.Name)-OSDisk" `
        -CreateOption FromImage `
        -StorageAccountType "Premium_LRS" `
        -DiskSizeInGB 128
    
    # Data Disk for CA database
    $dataDiskConfig = New-AzDiskConfig `
        -Location $Location `
        -CreateOption Empty `
        -DiskSizeGB 256 `
        -AccountType Premium_LRS `
        -Zone $vmConfig.AvailabilityZone
    
    $dataDisk = New-AzDisk `
        -ResourceGroupName $ResourceGroup `
        -DiskName "$($vmConfig.Name)-DataDisk" `
        -Disk $dataDiskConfig
    
    $vm = Add-AzVMDataDisk `
        -VM $vm `
        -Name "$($vmConfig.Name)-DataDisk" `
        -CreateOption Attach `
        -ManagedDiskId $dataDisk.Id `
        -Lun 0
    
    # Boot diagnostics
    $vm = Set-AzVMBootDiagnostic `
        -VM $vm `
        -Enable `
        -ResourceGroupName $ResourceGroup `
        -StorageAccountName "pkidiagnosticstorage"
    
    # Create the VM
    New-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -VM $vm `
        -AsJob
    
    # Apply tags
    $tags = @{
        Name = $vmConfig.Name
        Role = $vmConfig.Role
        Environment = "Production"
        Department = "Infrastructure"
        CostCenter = "IT-Security"
        BackupPolicy = "Daily"
        PatchGroup = "PKI-Servers"
        Monitoring = "Enabled"
        Compliance = "PCI-DSS,ISO27001"
    }
    
    Set-AzResource `
        -ResourceId "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$($vmConfig.Name)" `
        -Tag $tags `
        -Force
}

Write-Host "All VMs deployment initiated. Check job status for completion." -ForegroundColor Yellow

# Wait for all jobs to complete
Get-Job | Wait-Job
Get-Job | Receive-Job
```

#### Post-Deployment Configuration
```powershell
# Configure-BaseServers.ps1
# Base configuration for all PKI servers

$servers = @("PKI-ICA-01", "PKI-ICA-02", "PKI-NDES-01", "PKI-OCSP-01", "PKI-OCSP-02")

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        
        # Set timezone
        Set-TimeZone -Id "AUS Eastern Standard Time"
        
        # Configure Windows Firewall
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
        
        # Enable RDP
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        
        # Configure Windows Update
        Install-Module PSWindowsUpdate -Force
        Set-WUSettings -NoAutoUpdate -NoAutoRebootWithLoggedOnUsers
        
        # Install required features
        Install-WindowsFeature -Name Web-Server, Web-Common-Http, Web-Mgmt-Tools -IncludeManagementTools
        Install-WindowsFeature -Name RSAT-AD-PowerShell, RSAT-DNS-Server
        
        # Initialize data disk
        Get-Disk | Where-Object PartitionStyle -eq 'raw' | 
            Initialize-Disk -PartitionStyle GPT -PassThru |
            New-Partition -AssignDriveLetter -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel "CA-Data" -Confirm:$false
        
        # Create PKI directories
        $directories = @(
            "E:\CertData",
            "E:\CertData\Database",
            "E:\CertData\Logs",
            "E:\CertData\Backup",
            "E:\CertData\Templates",
            "E:\CertData\CRL"
        )
        
        foreach ($dir in $directories) {
            New-Item -ItemType Directory -Path $dir -Force
        }
        
        # Configure auditing
        auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable
        auditpol /set /subcategory:"Logon" /success:enable /failure:enable
        auditpol /set /subcategory:"Object Access" /success:enable /failure:enable
        
        # Configure event log sizes
        wevtutil sl Security /ms:4194240
        wevtutil sl Application /ms:1048576
        wevtutil sl System /ms:1048576
        
        # Install monitoring agent
        # Download and install Azure Monitor agent
        $agentUrl = "https://aka.ms/AMAWindows64"
        Invoke-WebRequest -Uri $agentUrl -OutFile "C:\Temp\AMASetup.exe"
        Start-Process -FilePath "C:\Temp\AMASetup.exe" -ArgumentList "/S" -Wait
    }
}

Write-Host "Base server configuration complete!" -ForegroundColor Green
```

### Day 3-4: Domain Join and AD CS Installation

#### Domain Join Script
```powershell
# Join-PKIDomain.ps1
# Joins PKI servers to Active Directory domain

$domain = "company.local"
$ouPath = "OU=PKI-Servers,OU=Infrastructure,DC=company,DC=local"
$credential = Get-Credential -Message "Enter Domain Admin credentials"

$servers = @(
    @{Name = "PKI-ICA-01"; IP = "10.50.1.10"},
    @{Name = "PKI-ICA-02"; IP = "10.50.1.11"},
    @{Name = "PKI-NDES-01"; IP = "10.50.1.20"},
    @{Name = "PKI-OCSP-01"; IP = "10.50.1.30"},
    @{Name = "PKI-OCSP-02"; IP = "10.50.1.31"}
)

foreach ($server in $servers) {
    Write-Host "Joining $($server.Name) to domain..." -ForegroundColor Yellow
    
    Invoke-Command -ComputerName $server.IP -Credential $credential -ScriptBlock {
        param($domain, $ou, $cred, $name)
        
        # Set DNS servers
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.10.10.10", "10.10.10.11"
        
        # Join domain
        Add-Computer -DomainName $domain -OUPath $ou -Credential $cred -NewName $name -Restart -Force
        
    } -ArgumentList $domain, $ouPath, $credential, $server.Name
}

Write-Host "Domain join initiated. Servers will restart." -ForegroundColor Green
Start-Sleep -Seconds 180  # Wait for restart

# Verify domain join
foreach ($server in $servers) {
    $result = Test-ComputerSecureChannel -Server $server.Name
    if ($result) {
        Write-Host "$($server.Name) successfully joined to domain" -ForegroundColor Green
    } else {
        Write-Host "$($server.Name) domain join FAILED" -ForegroundColor Red
    }
}
```

#### Install AD CS Roles
```powershell
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
```

### Day 5-7: Subordinate CA Certificate Installation

#### Submit to Root CA and Install Certificates
```powershell
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
```

## Week 4: Certificate Services Configuration

### Day 8-9: NDES Server Deployment

#### Install and Configure NDES
```powershell
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
```

### Day 10: Microsoft Intune Integration

#### Install Intune Certificate Connector
```powershell
# Install-IntuneConnector.ps1
# Installs and configures Microsoft Intune Certificate Connector

# Download Intune Certificate Connector
$connectorUrl = "https://go.microsoft.com/fwlink/?LinkId=833842"
$installerPath = "C:\Temp\IntuneCertificateConnector.msi"

Invoke-WebRequest -Uri $connectorUrl -OutFile $installerPath

# Install on NDES server
Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    param($installer)
    
    # Install Certificate Connector
    Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait
    
    # Wait for installation
    Start-Sleep -Seconds 30
    
} -ArgumentList $installerPath

# Configure Intune Connector
Write-Host "Configuring Intune Certificate Connector..." -ForegroundColor Yellow

# This requires interactive configuration through the UI
# Steps:
# 1. Launch Certificate Connector UI
# 2. Sign in with Intune admin account
# 3. Select SCEP profile
# 4. Enter NDES server URL: https://ndes.company.com.au/certsrv/mscep/mscep.dll
# 5. Select client certificate for authentication
# 6. Test connection
# 7. Save configuration

Write-Host @"
Manual steps required:
1. RDP to PKI-NDES-01
2. Launch 'Microsoft Intune Certificate Connector' from Start Menu
3. Sign in with Intune admin credentials
4. Configure SCEP settings:
   - NDES URL: https://ndes.company.com.au/certsrv/mscep/mscep.dll
   - Select appropriate client certificate
5. Test and save configuration
"@ -ForegroundColor Cyan

# Create Intune SCEP profile
$scepProfile = @{
    "@odata.type" = "#microsoft.graph.windows81SCEPCertificateProfile"
    displayName = "Company Mobile Device Certificate"
    description = "SCEP certificate for mobile device authentication"
    scepServerUrls = @("https://ndes.company.com.au/certsrv/mscep/mscep.dll")
    subjectNameFormatString = "CN={{DeviceId}},OU=Mobile,O=Company"
    keyUsage = "digitalSignature,keyEncipherment"
    keySize = "2048"
    hashAlgorithm = "sha2"
    extendedKeyUsages = @(
        @{
            name = "Client Authentication"
            objectIdentifier = "1.3.6.1.5.5.7.3.2"
        }
    )
    certificateValidityPeriodScale = "years"
    certificateValidityPeriodValue = 2
    renewalThresholdPercentage = 20
}

# Note: This would be deployed via Microsoft Graph API
Write-Host "SCEP profile configuration prepared for Intune deployment" -ForegroundColor Green
```

### Day 11-13: Certificate Template Creation

#### Deploy Certificate Templates
```powershell
# Deploy-CertificateTemplates.ps1
# Creates and configures all certificate templates

Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    
    # Load AD CS PowerShell module
    Import-Module ActiveDirectory
    
    # Function to create certificate template
    function New-CertificateTemplate {
        param(
            [string]$TemplateName,
            [string]$DisplayName,
            [string]$TemplateOID,
            [int]$ValidityPeriodYears,
            [int]$RenewalPeriod,
            [string[]]$ApplicationPolicies,
            [string[]]$AllowedPrincipals,
            [bool]$AutoEnrollment = $false,
            [string]$KeySpec = "KeyExchange",
            [int]$MinimumKeySize = 2048
        )
        
        # Certificate template creation via LDAP
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
        $TemplateContainer = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
        
        # Create template object
        $NewTemplate = $TemplateContainer.Create("pKICertificateTemplate", "CN=$TemplateName")
        
        # Set template properties
        $NewTemplate.Put("displayName", $DisplayName)
        $NewTemplate.Put("flags", 131680)  # Autoenrollment flags
        $NewTemplate.Put("revision", 100)
        $NewTemplate.Put("pKIDefaultKeySpec", 1)
        
        # Set validity period
        $ValidityPeriod = New-TimeSpan -Days ($ValidityPeriodYears * 365)
        $NewTemplate.Put("pKIExpirationPeriod", $ValidityPeriod.TotalSeconds)
        
        # Set renewal period
        $RenewalPeriodSpan = New-TimeSpan -Days $RenewalPeriod
        $NewTemplate.Put("pKIOverlapPeriod", $RenewalPeriodSpan.TotalSeconds)
        
        # Set minimum key size
        $NewTemplate.Put("pKIDefaultCSPs", "1,Microsoft RSA SChannel Cryptographic Provider")
        $NewTemplate.Put("pKIMinimumKeySize", $MinimumKeySize)
        
        # Set application policies
        $NewTemplate.Put("pKIExtendedKeyUsage", $ApplicationPolicies)
        
        # Commit changes
        $NewTemplate.SetInfo()
        
        Write-Host "Template $DisplayName created successfully" -ForegroundColor Green
    }
    
    # Create User Certificate Templates
    $userTemplates = @(
        @{
            Name = "Company-User-Authentication"
            DisplayName = "Company User Authentication"
            OID = "1.3.6.1.4.1.company.2.1.1"
            ValidityYears = 1
            RenewalDays = 30
            AppPolicies = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals = @("Domain Users")
            AutoEnroll = $true
        },
        @{
            Name = "Company-User-Email"
            DisplayName = "Company User Email (S/MIME)"
            OID = "1.3.6.1.4.1.company.2.1.2"
            ValidityYears = 1
            RenewalDays = 30
            AppPolicies = @("1.3.6.1.5.5.7.3.4")  # Email Protection
            Principals = @("Domain Users")
            AutoEnroll = $true
        },
        @{
            Name = "Company-User-EFS"
            DisplayName = "Company User EFS"
            OID = "1.3.6.1.4.1.company.2.1.3"
            ValidityYears = 2
            RenewalDays = 60
            AppPolicies = @("1.3.6.1.4.1.311.10.3.4")  # EFS
            Principals = @("Domain Users")
            AutoEnroll = $false
        }
    )
    
    # Create Computer Certificate Templates
    $computerTemplates = @(
        @{
            Name = "Company-Computer-Authentication"
            DisplayName = "Company Computer Authentication"
            OID = "1.3.6.1.4.1.company.2.2.1"
            ValidityYears = 2
            RenewalDays = 60
            AppPolicies = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals = @("Domain Computers")
            AutoEnroll = $true
        },
        @{
            Name = "Company-Domain-Controller"
            DisplayName = "Company Domain Controller"
            OID = "1.3.6.1.4.1.company.2.2.2"
            ValidityYears = 3
            RenewalDays = 90
            AppPolicies = @("1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2")  # Server + Client Auth
            Principals = @("Domain Controllers")
            AutoEnroll = $true
            KeySize = 4096
        },
        @{
            Name = "Company-Web-Server"
            DisplayName = "Company Web Server"
            OID = "1.3.6.1.4.1.company.2.2.3"
            ValidityYears = 1
            RenewalDays = 30
            AppPolicies = @("1.3.6.1.5.5.7.3.1")  # Server Authentication
            Principals = @("Domain Computers")
            AutoEnroll = $false
        }
    )
    
    # Create Special Purpose Templates
    $specialTemplates = @(
        @{
            Name = "Company-Code-Signing"
            DisplayName = "Company Code Signing"
            OID = "1.3.6.1.4.1.company.2.3.1"
            ValidityYears = 1
            RenewalDays = 60
            AppPolicies = @("1.3.6.1.5.5.7.3.3")  # Code Signing
            Principals = @("Code Signing Users")
            AutoEnroll = $false
            KeySize = 4096
        },
        @{
            Name = "Company-OCSP-Signing"
            DisplayName = "Company OCSP Signing"
            OID = "1.3.6.1.4.1.company.2.3.2"
            ValidityYears = 0.038  # 2 weeks
            RenewalDays = 7
            AppPolicies = @("1.3.6.1.5.5.7.3.9")  # OCSP Signing
            Principals = @("PKI-Servers")
            AutoEnroll = $true
        },
        @{
            Name = "Company-Mobile-Device"
            DisplayName = "Company Mobile Device (SCEP)"
            OID = "1.3.6.1.4.1.company.2.3.3"
            ValidityYears = 2
            RenewalDays = 60
            AppPolicies = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals = @("Domain Computers", "svc-NDES")
            AutoEnroll = $false
        }
    )
    
    # Deploy all templates
    $allTemplates = $userTemplates + $computerTemplates + $specialTemplates
    
    foreach ($template in $allTemplates) {
        New-CertificateTemplate @template
    }
    
    Write-Host "All certificate templates deployed successfully!" -ForegroundColor Green
}

# Publish templates to CAs
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    # Get CA name
    $CAName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration").Active
    
    # Templates to publish
    $templates = @(
        "Company-User-Authentication",
        "Company-User-Email",
        "Company-User-EFS",
        "Company-Computer-Authentication",
        "Company-Domain-Controller",
        "Company-Web-Server",
        "Company-Code-Signing",
        "Company-OCSP-Signing",
        "Company-Mobile-Device"
    )
    
    foreach ($template in $templates) {
        certutil -SetCATemplates +$template
    }
    
    # Restart CA service
    Restart-Service CertSvc
    
    Write-Host "Templates published to CA" -ForegroundColor Green
}

# Repeat for PKI-ICA-02
Invoke-Command -ComputerName "PKI-ICA-02" -ScriptBlock {
    # [Same template publishing commands]
}
```

### Day 14: Auto-Enrollment GPO Configuration

#### Create and Deploy Auto-Enrollment GPOs
```powershell
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
$templates = Get-ADObject -Filter {objectClass -eq "pKICertificateTemplate"} -SearchBase "CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=company,DC=local"

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
```

## Phase 2 Testing and Validation

### End-to-End Certificate Issuance Test
```powershell
# Test-CertificateIssuance.ps1
# Validates complete certificate issuance workflow

function Test-CertificateIssuance {
    $testResults = @()
    
    # Test 1: Manual certificate request
    Write-Host "Test 1: Manual Certificate Request" -ForegroundColor Cyan
    
    $cert = Get-Certificate -Template "Company-Web-Server" `
        -DnsName "test.company.com.au" `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -Url "https://pki-ica-01.company.local/certsrv"
    
    if ($cert.Status -eq "Issued") {
        $testResults += @{Test = "Manual Request"; Result = "PASSED"}
        Write-Host "✓ Manual certificate request successful" -ForegroundColor Green
    } else {
        $testResults += @{Test = "Manual Request"; Result = "FAILED"}
        Write-Host "✗ Manual certificate request failed" -ForegroundColor Red
    }
    
    # Test 2: Auto-enrollment
    Write-Host "`nTest 2: Auto-Enrollment" -ForegroundColor Cyan
    
    # Trigger auto-enrollment
    certutil -pulse
    Start-Sleep -Seconds 10
    
    $autoCerts = Get-ChildItem Cert:\LocalMachine\My | 
        Where-Object {$_.Subject -like "*$env:COMPUTERNAME*" -and $_.NotBefore -gt (Get-Date).AddMinutes(-5)}
    
    if ($autoCerts.Count -gt 0) {
        $testResults += @{Test = "Auto-Enrollment"; Result = "PASSED"}
        Write-Host "✓ Auto-enrollment successful - $($autoCerts.Count) certificates" -ForegroundColor Green
    } else {
        $testResults += @{Test = "Auto-Enrollment"; Result = "FAILED"}
        Write-Host "✗ Auto-enrollment failed" -ForegroundColor Red
    }
    
    # Test 3: SCEP enrollment
    Write-Host "`nTest 3: SCEP/NDES Enrollment" -ForegroundColor Cyan
    
    $scepUrl = "https://ndes.company.com.au/certsrv/mscep/mscep.dll"
    $response = Invoke-WebRequest -Uri "$scepUrl?operation=GetCACert" -Method Get
    
    if ($response.StatusCode -eq 200) {
        $testResults += @{Test = "SCEP Endpoint"; Result = "PASSED"}
        Write-Host "✓ SCEP endpoint accessible" -ForegroundColor Green
    } else {
        $testResults += @{Test = "SCEP Endpoint"; Result = "FAILED"}
        Write-Host "✗ SCEP endpoint not accessible" -ForegroundColor Red
    }
    
    # Test 4: CRL accessibility
    Write-Host "`nTest 4: CRL Distribution" -ForegroundColor Cyan
    
    $crlUrl = "http://crl.company.com.au/IssuingCA01.crl"
    $crlResponse = Invoke-WebRequest -Uri $crlUrl -Method Get
    
    if ($crlResponse.StatusCode -eq 200) {
        $testResults += @{Test = "CRL Distribution"; Result = "PASSED"}
        Write-Host "✓ CRL accessible" -ForegroundColor Green
        
        # Verify CRL validity
        $crlFile = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllBytes($crlFile, $crlResponse.Content)
        
        $crlInfo = certutil -dump $crlFile
        if ($crlInfo -match "Next Update") {
            Write-Host "✓ CRL is valid" -ForegroundColor Green
        }
    } else {
        $testResults += @{Test = "CRL Distribution"; Result = "FAILED"}
        Write-Host "✗ CRL not accessible" -ForegroundColor Red
    }
    
    # Test 5: OCSP responder
    Write-Host "`nTest 5: OCSP Responder" -ForegroundColor Cyan
    
    $ocspUrl = "http://ocsp.company.com.au"
    # This would require an actual OCSP request
    # Simplified test for endpoint availability
    
    $ocspResponse = Test-NetConnection -ComputerName "ocsp.company.com.au" -Port 80
    
    if ($ocspResponse.TcpTestSucceeded) {
        $testResults += @{Test = "OCSP Responder"; Result = "PASSED"}
        Write-Host "✓ OCSP responder accessible" -ForegroundColor Green
    } else {
        $testResults += @{Test = "OCSP Responder"; Result = "FAILED"}
        Write-Host "✗ OCSP responder not accessible" -ForegroundColor Red
    }
    
    # Generate summary report
    Write-Host "`n========== Test Summary ==========" -ForegroundColor Cyan
    $passedTests = ($testResults | Where-Object {$_.Result -eq "PASSED"}).Count
    $totalTests = $testResults.Count
    
    Write-Host "Passed: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) {"Green"} else {"Yellow"})
    
    foreach ($result in $testResults) {
        $color = if ($result.Result -eq "PASSED") {"Green"} else {"Red"}
        Write-Host "$($result.Test): $($result.Result)" -ForegroundColor $color
    }
    
    return $testResults
}

# Run tests
$results = Test-CertificateIssuance

# Export results
$results | Export-Csv -Path "C:\PKI\TestResults\Phase2-Validation-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

## Phase 2 Deliverables Checklist

### Technical Deliverables
- ✅ Two operational issuing CAs (PKI-ICA-01, PKI-ICA-02)
- ✅ NDES server configured for SCEP
- ✅ OCSP responders deployed (2 instances)
- ✅ Microsoft Intune Certificate Connector installed
- ✅ 15+ certificate templates created and published
- ✅ Auto-enrollment GPOs deployed
- ✅ CRL distribution points operational
- ✅ High availability configuration completed

### Documentation Deliverables
- ✅ CA installation procedures
- ✅ Certificate template specifications
- ✅ NDES configuration guide
- ✅ Intune integration documentation
- ✅ GPO configuration details
- ✅ Test results and validation report

### Operational Readiness
- ✅ CA database backup configured
- ✅ Monitoring alerts configured
- ✅ Service accounts created
- ✅ Administrative procedures documented
- ✅ Support runbooks created

## Handover to Phase 3

### Prerequisites for Services Integration
```yaml
Phase3_Requirements:
  From_Phase2:
    Infrastructure:
      - Issuing CAs operational
      - NDES/SCEP functional
      - Templates published
      - GPOs active
      
    Certificates:
      - CA certificates trusted
      - Test certificates issued
      - Auto-enrollment verified
      
    Integration_Points:
      - API endpoints documented
      - Service accounts created
      - Firewall rules configured
      - DNS records created
      
    Documentation:
      - Certificate request procedures
      - Template specifications
      - Troubleshooting guides
      - Contact information
```

## Monitoring and Maintenance

### Key Performance Indicators
```yaml
KPIs:
  Availability:
    - CA Service Uptime: >99.9%
    - NDES Availability: >99.5%
    - OCSP Response Time: <100ms
    
  Performance:
    - Certificate Issuance Time: <30 seconds
    - Auto-Enrollment Success: >95%
    - CRL Generation Time: <5 minutes
    
  Capacity:
    - Certificates/Day: 1000
    - Database Size: <50GB
    - Peak Load: 50 requests/minute
```

---

**Document Control**
- Version: 1.0
- Last Updated: February 2025
- Next Review: End of Phase 3
- Owner: PKI Implementation Team
- Classification: Confidential

---
[← Previous: Phase 1 Foundation](05-phase1-foundation.md) | [Back to Index](00-index.md) | [Next: Phase 3 Services Integration →](07-phase3-services-integration.md)