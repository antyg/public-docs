# PKI Modernization - Comprehensive Implementation Plan with Network Infrastructure

## Project Timeline Overview

```mermaid
gantt
    title PKI Modernization Implementation Timeline
    dateFormat YYYY-MM-DD
    section Phase 1 - Foundation
    Azure Setup           :a1, 2025-09-01, 7d
    Network Config        :a2, after a1, 5d
    Key Vault Setup       :a3, after a1, 3d
    Root CA Deploy        :a4, after a3, 5d

    section Phase 2 - Core Infrastructure
    AD CS Deploy          :b1, after a4, 7d
    NDES Setup           :b2, after b1, 5d
    Intune Integration   :b3, after b2, 5d
    Template Creation    :b4, after b1, 10d

    section Phase 3 - Services Integration
    Code Sign Setup      :c1, after b4, 5d
    SCCM Integration     :c2, after b4, 7d
    Azure Services       :c3, after b4, 7d
    NetScaler Config     :c5, after b4, 5d
    Zscaler Integration  :c6, after b4, 5d
    Automation Deploy    :c4, after c2, 10d

    section Phase 4 - Migration
    Pilot Migration      :d1, after c4, 14d
    Production Wave 1    :d2, after d1, 14d
    Production Wave 2    :d3, after d2, 14d

    section Phase 5 - Cutover
    Final Migration      :e1, after d3, 7d
    Old CA Decom        :e2, after e1, 3d
    Documentation       :e3, after e1, 5d
```

## Complete Network Architecture with Security Appliances

### Enterprise PKI Infrastructure with Security Layers

```mermaid
graph TB
    %% Define styles for dark mode
    classDef azureNode fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef onpremNode fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0
    classDef securityNode fill:#4a235a,stroke:#f39c12,stroke-width:2px,color:#e0e0e0
    classDef networkNode fill:#17202a,stroke:#e74c3c,stroke-width:2px,color:#e0e0e0
    classDef endpointNode fill:#1c2833,stroke:#aab7b8,stroke-width:2px,color:#e0e0e0
    classDef zscalerNode fill:#0a4d68,stroke:#00bfff,stroke-width:2px,color:#e0e0e0

    subgraph "Internet & Cloud Security"
        INET[Internet]:::networkNode
        ZSC[Zscaler Cloud<br/>SSL Inspection<br/>Certificate Validation]:::zscalerNode
        ZPA[Zscaler ZPA<br/>Private Access<br/>Client Certificates]:::zscalerNode
    end

    subgraph "Azure Cloud Infrastructure"
        AKV[Azure Key Vault<br/>HSM-Protected]:::azureNode
        APCA[Azure Private CA<br/>Root Certificate Authority]:::azureNode
        AFD[Azure Front Door<br/>SSL Termination]:::azureNode
        AAPPGW[Azure App Gateway<br/>WAF + SSL]:::azureNode
        AKV -.->|Stores Root Keys| APCA
        AKV -->|SSL Certs| AFD
        AKV -->|SSL Certs| AAPPGW
    end

    subgraph "DMZ - Perimeter Security"
        FW1[Perimeter Firewall<br/>Palo Alto<br/>SSL Decrypt]:::networkNode
        FW2[Internal Firewall<br/>Checkpoint<br/>Certificate Inspection]:::networkNode
        NS1[NetScaler ADC 1<br/>Primary<br/>SSL Offload]:::securityNode
        NS2[NetScaler ADC 2<br/>Secondary<br/>SSL Offload]:::securityNode
        PROXY1[Forward Proxy<br/>Squid/BlueCoat<br/>SSL Inspection]:::securityNode
        PROXY2[Reverse Proxy<br/>F5 BIG-IP<br/>Client Cert Auth]:::securityNode
    end

    subgraph "On-Premises PKI Core"
        ICA1[Issuing CA 01<br/>Windows Server 2022<br/>10.50.1.10]:::onpremNode
        ICA2[Issuing CA 02<br/>Windows Server 2022<br/>10.50.1.11]:::onpremNode
        NDES[NDES/SCEP Server<br/>Intune Connected<br/>10.50.1.20]:::onpremNode
        OCSP[OCSP Responder<br/>High Availability<br/>10.50.1.30]:::onpremNode
        VA[Validation Authority<br/>Certificate Status<br/>10.50.1.40]:::onpremNode
    end

    subgraph "Certificate Services"
        CS[Code Signing<br/>Service]:::securityNode
        SCCM[SCCM<br/>Auto-Enrollment]:::securityNode
        WEB[Web Enrollment<br/>Service]:::securityNode
        INTUNE[Intune<br/>SCEP Connector]:::securityNode
    end

    subgraph "End Entities"
        WIN[Windows<br/>Devices]:::endpointNode
        MOB[Mobile<br/>Devices]:::endpointNode
        SRV[Servers &<br/>Services]:::endpointNode
        DEV[Developer<br/>Workstations]:::endpointNode
        IOT[IoT Devices<br/>802.1X]:::endpointNode
    end

    %% Internet connectivity
    INET --> ZSC
    ZSC --> FW1
    INET --> ZPA
    ZPA --> MOB

    %% Azure connectivity
    APCA -->|Issues Sub-CA Cert| ICA1
    APCA -->|Issues Sub-CA Cert| ICA2
    AFD --> NS1
    AAPPGW --> NS2

    %% DMZ flows
    FW1 --> NS1
    FW1 --> NS2
    NS1 --> PROXY2
    NS2 --> PROXY2
    PROXY1 --> FW2
    PROXY2 --> FW2

    %% Internal PKI flows
    FW2 --> ICA1
    FW2 --> ICA2
    ICA1 --> NDES
    ICA2 --> NDES
    ICA1 --> CS
    ICA1 --> SCCM
    ICA1 --> WEB
    ICA2 --> CS
    ICA2 --> SCCM
    ICA2 --> WEB
    ICA1 --> OCSP
    ICA2 --> OCSP
    OCSP --> VA

    %% Service connections
    NDES --> INTUNE
    INTUNE -->|SCEP| MOB
    SCCM -->|Auto-Enroll| WIN
    WEB -->|Manual| SRV
    CS -->|Code Sign| DEV

    %% Certificate validation flows
    NS1 -.->|OCSP Check| OCSP
    NS2 -.->|OCSP Check| OCSP
    PROXY1 -.->|CRL Check| VA
    PROXY2 -.->|CRL Check| VA
    FW1 -.->|Cert Validation| OCSP
    FW2 -.->|Cert Validation| OCSP
    ZSC -.->|External OCSP| OCSP

    %% IoT and 802.1X
    IOT -->|EAP-TLS| NS1
```

## Architecture Diagrams

### Overall PKI Hierarchy and Trust Relationships

```mermaid
graph TB
    %% Define styles for dark mode
    classDef azureNode fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef onpremNode fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0
    classDef serviceNode fill:#4a235a,stroke:#f39c12,stroke-width:2px,color:#e0e0e0
    classDef endpointNode fill:#1c2833,stroke:#aab7b8,stroke-width:2px,color:#e0e0e0

    subgraph "Azure Cloud"
        AKV[Azure Key Vault<br/>HSM-Protected]:::azureNode
        APCA[Azure Private CA<br/>Root Certificate Authority]:::azureNode
        AKV -.->|Stores Root Keys| APCA
    end

    subgraph "On-Premises Infrastructure"
        ICA1[Issuing CA 01<br/>Windows Server 2022]:::onpremNode
        ICA2[Issuing CA 02<br/>Windows Server 2022]:::onpremNode
        NDES[NDES/SCEP Server<br/>Intune Connected]:::onpremNode
        OCSP[OCSP Responder<br/>High Availability]:::onpremNode
    end

    subgraph "Certificate Services"
        CS[Code Signing<br/>Service]:::serviceNode
        SCCM[SCCM<br/>Auto-Enrollment]:::serviceNode
        WEB[Web Enrollment<br/>Service]:::serviceNode
    end

    subgraph "End Entities"
        WIN[Windows<br/>Devices]:::endpointNode
        MOB[Mobile<br/>Devices]:::endpointNode
        SRV[Servers &<br/>Services]:::endpointNode
        DEV[Developer<br/>Workstations]:::endpointNode
    end

    APCA -->|Issues Sub-CA Cert| ICA1
    APCA -->|Issues Sub-CA Cert| ICA2
    ICA1 --> NDES
    ICA2 --> NDES
    ICA1 --> CS
    ICA1 --> SCCM
    ICA1 --> WEB
    ICA2 --> CS
    ICA2 --> SCCM
    ICA2 --> WEB
    ICA1 --> OCSP
    ICA2 --> OCSP

    NDES -->|SCEP Protocol| MOB
    SCCM -->|Auto-Enroll| WIN
    WEB -->|Manual Request| SRV
    CS -->|Code Sign Cert| DEV
```

### Certificate Enrollment Flow - Mobile Devices via Intune

```mermaid
sequenceDiagram
    %% Dark mode friendly colors
    autonumber
    participant MD as Mobile Device
    participant INT as Intune
    participant CON as SCEP Connector
    participant NDES as NDES Server
    participant ICA as Issuing CA
    participant AKV as Azure Key Vault

    Note over MD,AKV: Mobile Device Certificate Enrollment Flow

    MD->>INT: Device Enrollment
    INT->>INT: Apply Certificate Profile
    INT->>CON: Request Certificate
    CON->>NDES: SCEP Challenge Request
    NDES->>NDES: Generate Challenge Password
    NDES->>CON: Return Challenge
    CON->>INT: Challenge Response
    INT->>MD: Push SCEP Profile
    MD->>NDES: Certificate Request (CSR)
    NDES->>ICA: Submit to CA
    ICA->>ICA: Process Template
    ICA->>NDES: Issue Certificate
    NDES->>MD: Return Certificate
    MD->>MD: Install Certificate

    opt Certificate Backup
        ICA->>AKV: Archive Certificate
        AKV->>AKV: Store in HSM
    end

    MD->>INT: Report Success
    INT->>INT: Update Compliance
```

### Azure Services Certificate Automation Flow

```mermaid
flowchart LR
    %% Define styles for dark mode
    classDef azureStyle fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef processStyle fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0
    classDef alertStyle fill:#7b241c,stroke:#ec7063,stroke-width:2px,color:#e0e0e0

    subgraph "Azure Key Vault Certificate Lifecycle"
        MON[Certificate Monitor<br/>30-day threshold]:::processStyle
        POL[Certificate Policy<br/>Auto-Renewal Rules]:::processStyle
        REQ[Renewal Request<br/>Generated CSR]:::processStyle
        CA[Azure Private CA<br/>or Issuing CA]:::azureStyle
        NEW[New Certificate<br/>Issued]:::processStyle
        KV[Key Vault<br/>Certificate Store]:::azureStyle
    end

    subgraph "Azure Services"
        APP[App Services]:::azureStyle
        AGW[Application Gateway]:::azureStyle
        API[API Management]:::azureStyle
        AKS[AKS Ingress]:::azureStyle
    end

    MON -->|Expiry Detected| POL
    POL -->|Trigger Renewal| REQ
    REQ -->|Submit CSR| CA
    CA -->|Issue Cert| NEW
    NEW -->|Store| KV
    KV -->|Auto-Bind| APP
    KV -->|Auto-Bind| AGW
    KV -->|Auto-Bind| API
    KV -->|Cert-Manager| AKS

    MON -.->|Alert if Failed| ALERT[Operations Team]:::alertStyle
```

### Code Signing Certificate Management Flow

```mermaid
stateDiagram-v2
    [*] --> Request: Developer/IT Requests Code Signing Cert

    Request --> Approval: Submit via Portal
    Approval --> Denied: Manager Rejects
    Approval --> Approved: Manager Approves

    Denied --> [*]: End Process

    Approved --> Template: Select Template Type

    state Template {
        [*] --> DevTemplate: Developer Role
        [*] --> ITOpsTemplate: IT Operations Role
        DevTemplate --> Generate: 1 Year Validity
        ITOpsTemplate --> Generate: 2 Year Validity + Trust Mgmt
    }

    Generate --> KeyVault: Generate Key Pair

    state KeyVault {
        [*] --> CreateKey: Non-Exportable Key
        CreateKey --> StoreHSM: Store in HSM
        StoreHSM --> CSR: Generate CSR
    }

    CSR --> IssuingCA: Submit to CA
    IssuingCA --> Certificate: Issue Certificate
    Certificate --> BindKey: Bind to Key Vault Key
    BindKey --> Active: Certificate Active

    state Active {
        [*] --> InUse: Available for Signing
        InUse --> Monitor: Usage Monitoring
        Monitor --> Renew: 30 Days Before Expiry
        Renew --> Generate: Auto-Renewal
        Monitor --> Revoke: Security Event
        Revoke --> [*]: Certificate Revoked
    }

    Active --> Archive: After Expiry
    Archive --> [*]: End Lifecycle
```

## Detailed Implementation Plan

### PHASE 1: Foundation Setup (Weeks 1-2)

#### Week 1: Azure Infrastructure Preparation

**Day 1-2: Azure Subscription and Governance**
```powershell
# 1. Create Resource Groups
New-AzResourceGroup -Name "RG-PKI-Core" -Location "East US"
New-AzResourceGroup -Name "RG-PKI-KeyVault" -Location "East US"
New-AzResourceGroup -Name "RG-PKI-Networking" -Location "East US"

# 2. Assign RBAC Roles
$pkiAdminGroup = "PKI-Administrators"
New-AzADGroup -DisplayName $pkiAdminGroup -MailEnabled $false -SecurityEnabled $true

# 3. Apply Azure Policy for compliance
$policyDef = Get-AzPolicyDefinition -Name "Allowed-Locations"
New-AzPolicyAssignment -Name "PKI-Location-Policy" -PolicyDefinition $policyDef
```

**Day 3-4: Network Configuration**
```powershell
# Create Virtual Network for PKI
$vnet = New-AzVirtualNetwork -Name "VNET-PKI" `
    -ResourceGroupName "RG-PKI-Networking" `
    -Location "East US" `
    -AddressPrefix "10.50.0.0/16"

# Create Subnets
Add-AzVirtualNetworkSubnetConfig -Name "Subnet-PKI-Core" `
    -VirtualNetwork $vnet -AddressPrefix "10.50.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "Subnet-PKI-HSM" `
    -VirtualNetwork $vnet -AddressPrefix "10.50.2.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" `
    -VirtualNetwork $vnet -AddressPrefix "10.50.255.0/24"

# Configure NSG Rules
$nsgRules = @(
    @{Name="Allow-HTTPS"; Protocol="Tcp"; SourcePortRange="*";
      DestinationPortRange="443"; Access="Allow"; Priority=100}
    @{Name="Allow-RPC"; Protocol="Tcp"; SourcePortRange="*";
      DestinationPortRange="135"; Access="Allow"; Priority=110}
    @{Name="Allow-CRL"; Protocol="Tcp"; SourcePortRange="*";
      DestinationPortRange="80"; Access="Allow"; Priority=120}
)
```

**Day 5: Azure Key Vault Setup**
```powershell
# Create Premium Key Vault with HSM
$keyVault = New-AzKeyVault -Name "KV-PKI-RootCA" `
    -ResourceGroupName "RG-PKI-KeyVault" `
    -Location "East US" `
    -Sku "Premium" `
    -EnabledForDeployment `
    -EnabledForTemplateDeployment `
    -EnablePurgeProtection

# Configure Access Policies
Set-AzKeyVaultAccessPolicy -VaultName "KV-PKI-RootCA" `
    -ObjectId (Get-AzADGroup -DisplayName "PKI-Administrators").Id `
    -PermissionsToKeys all `
    -PermissionsToCertificates all `
    -PermissionsToSecrets all

# Create HSM-protected keys for Root CA
Add-AzKeyVaultKey -VaultName "KV-PKI-RootCA" `
    -Name "RootCA-SigningKey" `
    -Destination "HSM" `
    -KeyOps sign,verify `
    -Size 4096
```

#### Week 2: Azure Private CA Deployment

**Day 6-7: Deploy Azure Managed Private CA**
```bash
# Azure CLI deployment
az pki ca create \
    --resource-group "RG-PKI-Core" \
    --name "CompanyRootCA" \
    --subject "CN=Company Root CA, O=Company, C=US" \
    --validity-in-months 240 \
    --key-vault-id "/subscriptions/{sub-id}/resourceGroups/RG-PKI-KeyVault/providers/Microsoft.KeyVault/vaults/KV-PKI-RootCA"

# Configure CA Certificate Policy
az pki ca certificate-policy create \
    --ca-name "CompanyRootCA" \
    --resource-group "RG-PKI-Core" \
    --policy-file ca-policy.json
```

**ca-policy.json:**
```json
{
  "keyProperties": {
    "keyType": "RSA-HSM",
    "keySize": 4096,
    "reuseKey": false,
    "exportable": false
  },
  "certificateProperties": {
    "certificateType": "RootCA",
    "subject": "CN=Company Root CA, O=Company, C=US",
    "validity": {
      "validityInMonths": 240
    },
    "keyUsage": ["keyCertSign", "cRLSign"],
    "extendedKeyUsage": []
  },
  "x509CertificateProperties": {
    "basicConstraints": {
      "certificateAuthority": true,
      "pathLenConstraint": 2
    }
  }
}
```

**Day 8-9: Configure CRL Distribution Points**
```powershell
# Setup Azure Storage for CRL hosting
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName "RG-PKI-Core" `
    -Name "pkicrlstorage" `
    -Location "East US" `
    -SkuName "Standard_GRS" `
    -Kind "StorageV2"

# Create blob container for CRL
$ctx = $storageAccount.Context
New-AzStorageContainer -Name "crl" -Context $ctx -Permission Blob

# Configure CDN for global CRL distribution
$cdnProfile = New-AzCdnProfile `
    -ResourceGroupName "RG-PKI-Core" `
    -ProfileName "PKI-CDN" `
    -Location "East US" `
    -Sku "Standard_Microsoft"
```

**Day 10: Backup and DR Configuration**
```powershell
# Configure Azure Backup for Key Vault
$vault = Get-AzRecoveryServicesVault -Name "RSV-PKI"
Set-AzRecoveryServicesBackupProperty -Vault $vault `
    -BackupStorageRedundancy GeoRedundant

# Enable soft delete and purge protection
Update-AzKeyVault -VaultName "KV-PKI-RootCA" `
    -EnableSoftDelete $true `
    -SoftDeleteRetentionInDays 90 `
    -EnablePurgeProtection $true
```

### PHASE 2: Core Infrastructure Deployment (Weeks 3-4)

#### Week 3: AD CS Subordinate CA Setup

**Day 11-12: Deploy Issuing CA VMs**
```powershell
# VM deployment script for Issuing CA 01
$vmConfig = New-AzVMConfig -VMName "PKI-ICA-01" -VMSize "Standard_D4s_v3"
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig `
    -Windows -ComputerName "PKI-ICA-01" `
    -Credential $cred -ProvisionVMAgent

$vmConfig = Set-AzVMSourceImage -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2022-datacenter-g2" `
    -Version "latest"

# Add data disk for CA database
$vmConfig = Add-AzVMDataDisk -VM $vmConfig `
    -Name "PKI-ICA-01-Data" `
    -DiskSizeInGB 256 `
    -CreateOption Empty `
    -Lun 0

New-AzVM -ResourceGroupName "RG-PKI-Core" `
    -Location "East US" `
    -VM $vmConfig
```

**Day 13: Install AD CS Role**
```powershell
# Remote PowerShell to ICA-01
Enter-PSSession -ComputerName PKI-ICA-01

# Install AD CS with all components
Install-WindowsFeature -Name AD-Certificate, `
    ADCS-Cert-Authority, `
    ADCS-Web-Enrollment, `
    ADCS-Online-Responder `
    -IncludeManagementTools

# Configure CA
Install-AdcsCertificationAuthority `
    -CAType EnterpriseSubordinateCA `
    -CACommonName "Company Issuing CA 01" `
    -KeyLength 4096 `
    -HashAlgorithmName SHA256 `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -DatabaseDirectory "E:\CADatabase" `
    -LogDirectory "E:\CALogs" `
    -ValidityPeriod Years `
    -ValidityPeriodUnits 10 `
    -Force
```

**Day 14-15: Configure Certificate Templates**
```powershell
# Create custom certificate templates
$templateNames = @(
    "Company-User-Certificate",
    "Company-Computer-Certificate",
    "Company-Web-Server",
    "Company-Code-Signing",
    "Company-Mobile-Device",
    "Company-SCCM-Client"
)

foreach ($template in $templateNames) {
    # Duplicate existing template
    $sourceTemplate = Get-CATemplate -Name "Computer"
    $newTemplate = New-CATemplate -SourceTemplate $sourceTemplate `
        -DisplayName $template

    # Configure template settings
    Set-CATemplate -Name $template `
        -ValidityPeriod "Years" `
        -ValidityPeriodUnits 2 `
        -RenewalPeriod "Weeks" `
        -RenewalPeriodUnits 6
}

# Publish templates to CA
Add-CATemplate -Name "Company-User-Certificate" -Force
Add-CATemplate -Name "Company-Computer-Certificate" -Force
# ... continue for all templates
```

#### Week 4: SCEP/NDES Configuration

**Day 16-17: Deploy NDES Server**
```powershell
# Install NDES role
Install-WindowsFeature -Name ADCS-Device-Enrollment `
    -IncludeManagementTools

# Configure NDES
Install-AdcsNetworkDeviceEnrollmentService `
    -ServiceAccountName "DOMAIN\svc-ndes" `
    -ServiceAccountPassword $securePassword `
    -RAName "Company-NDES-RA" `
    -RACountry "US" `
    -RACompany "Company" `
    -SigningProviderName "Microsoft Strong Cryptographic Provider" `
    -SigningKeyLength 2048 `
    -EncryptionProviderName "Microsoft Strong Cryptographic Provider" `
    -EncryptionKeyLength 2048 `
    -CAConfig "PKI-ICA-01.domain.com\Company Issuing CA 01"
```

**Day 18: Install Intune Certificate Connector**
```powershell
# Download and install Microsoft Intune Connector
$connectorUrl = "https://download.microsoft.com/download/[latest-version]/MicrosoftIntuneCertificateConnector.msi"
Invoke-WebRequest -Uri $connectorUrl -OutFile "C:\Temp\IntuneConnector.msi"

# Install silently
Start-Process msiexec.exe -ArgumentList "/i C:\Temp\IntuneConnector.msi /quiet" -Wait

# Configure connector
# This requires GUI interaction - document steps:
# 1. Launch Certificate Connector
# 2. Sign in with Intune admin account
# 3. Select SCEP tab
# 4. Enable SCEP service
# 5. Verify connection status
```

**Day 19-20: Configure Intune SCEP Profiles**
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Create SCEP certificate profile for iOS
$iosSCEPProfile = @{
    "@odata.type" = "#microsoft.graph.iosSCEPCertificateProfile"
    displayName = "iOS Device Certificate"
    description = "SCEP certificate for iOS devices"
    certificateStore = "DeviceCertificate"
    certificateValidityPeriodScale = "Years"
    certificateValidityPeriodValue = 2
    extendedKeyUsages = @(
        @{
            name = "Client Authentication"
            objectIdentifier = "1.3.6.1.5.5.7.3.2"
        }
    )
    keySize = "2048"
    keyUsage = @("digitalSignature", "keyEncipherment")
    renewalThresholdPercentage = 20
    scepServerUrls = @("https://ndes.company.com/certsrv/mscep/mscep.dll")
    subjectAlternativeNameType = "emailAddress"
    subjectNameFormat = "CN={{DeviceId}}"
}

New-MgDeviceManagementDeviceConfiguration -BodyParameter $iosSCEPProfile
```

### PHASE 3: Services Integration (Weeks 5-6)

#### Week 5: Code Signing Infrastructure

**Day 21-22: Setup Code Signing Service**
```powershell
# Create Azure Key Vault for Code Signing
$codeSignVault = New-AzKeyVault -Name "KV-CodeSign" `
    -ResourceGroupName "RG-PKI-Core" `
    -Location "East US" `
    -Sku "Premium"

# Create code signing certificate policies
$devPolicy = New-AzKeyVaultCertificatePolicy `
    -SubjectName "CN=Developer Code Signing" `
    -IssuerName "Company Issuing CA 01" `
    -ValidityInMonths 12 `
    -KeyType "RSA" `
    -KeySize 2048 `
    -KeyNotExportable `
    -KeyUsage "DigitalSignature" `
    -Ekus "1.3.6.1.5.5.7.3.3"  # Code Signing

$opsPolicy = New-AzKeyVaultCertificatePolicy `
    -SubjectName "CN=IT Operations Code Signing" `
    -IssuerName "Company Issuing CA 01" `
    -ValidityInMonths 24 `
    -KeyType "RSA" `
    -KeySize 4096 `
    -KeyNotExportable `
    -KeyUsage "DigitalSignature" `
    -Ekus "1.3.6.1.5.5.7.3.3"
```

**Day 23: Configure Signing Automation**
```powershell
# Create Azure Function for code signing
$functionApp = New-AzFunctionApp `
    -Name "FA-CodeSign-Service" `
    -ResourceGroupName "RG-PKI-Core" `
    -StorageAccount "pkicodesignstorage" `
    -Runtime "PowerShell" `
    -RuntimeVersion "7.2" `
    -FunctionsVersion 4 `
    -Location "East US"

# Deploy signing function code
Publish-AzWebApp -ResourceGroupName "RG-PKI-Core" `
    -Name "FA-CodeSign-Service" `
    -ArchivePath ".\CodeSignFunction.zip"

# Grant function access to Key Vault
$functionIdentity = (Get-AzFunctionApp -Name "FA-CodeSign-Service").Identity
Set-AzKeyVaultAccessPolicy -VaultName "KV-CodeSign" `
    -ObjectId $functionIdentity.PrincipalId `
    -PermissionsToCertificates get,list `
    -PermissionsToKeys sign,verify
```

**Day 24-25: SCCM Integration**
```powershell
# Configure SCCM for auto-enrollment
# On SCCM Primary Site Server
$siteCode = "PS1"
$siteServer = "SCCM-PRIMARY"

# Import SCCM PowerShell module
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location "$siteCode`:"

# Create certificate profile for SCCM clients
New-CMCertificateProfileScep `
    -Name "SCCM Client Authentication Certificate" `
    -Description "Auto-renewing certificate for SCCM clients" `
    -CertificateTemplateName "Company-SCCM-Client" `
    -CertificateStore "Personal" `
    -HashAlgorithm "SHA256" `
    -KeySize 2048 `
    -KeyStorageProvider "Microsoft Software Key Storage Provider" `
    -RenewalThresholdPercentage 20 `
    -ScepServerUrl @("https://ndes.company.com/certsrv/mscep/mscep.dll")

# Create deployment
Start-CMCertificateProfileDeployment `
    -CertificateProfileName "SCCM Client Authentication Certificate" `
    -CollectionName "All Desktop and Server Clients" `
    -GenerateAlert $true `
    -ParameterValue 90  # Alert at 90% compliance
```

#### Week 6: Azure Services Integration

**Day 26-27: Configure Azure Key Vault Certificate Automation**
```powershell
# Setup certificate lifecycle policies for Azure services
$webServerPolicy = @{
    IssuerName = "Company Issuing CA 01"
    SubjectName = "CN=*.company.com"
    DnsNames = @("*.company.com", "*.api.company.com")
    ValidityInMonths = 12
    RenewAtPercentageLifetime = 80
    KeyType = "RSA"
    KeySize = 2048
    ReuseKeyOnRenewal = $false
}

# Create certificate with auto-renewal
$cert = Add-AzKeyVaultCertificate `
    -VaultName "KV-PKI-Core" `
    -Name "Wildcard-Company-2024" `
    -CertificatePolicy $webServerPolicy

# Configure App Service certificate binding
$webApp = Get-AzWebApp -Name "CompanyWebApp"
New-AzWebAppSSLBinding `
    -WebApp $webApp `
    -CertificateThumbprint $cert.Thumbprint `
    -SslState "SniEnabled"
```

**Day 28: Setup Monitoring and Alerting**
```powershell
# Create Log Analytics Workspace
$workspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName "RG-PKI-Core" `
    -Name "LA-PKI-Monitoring" `
    -Location "East US" `
    -Sku "PerGB2018"

# Configure diagnostic settings for Key Vault
Set-AzDiagnosticSetting `
    -ResourceId $keyVault.ResourceId `
    -WorkspaceId $workspace.ResourceId `
    -Enabled $true `
    -Category "AuditEvent" `
    -MetricCategory "AllMetrics"

# Create alert rules
$alertRule = New-AzScheduledQueryRule `
    -ResourceGroupName "RG-PKI-Core" `
    -Location "East US" `
    -Name "Certificate-Expiry-Alert" `
    -Description "Alert when certificates expire within 30 days" `
    -Query @"
        AzureDiagnostics
        | where ResourceType == "VAULTS"
        | where OperationName == "CertificateNearExpiry"
        | project TimeGenerated, Resource, Properties_s
"@ `
    -Frequency 60 `
    -TimeWindow 60 `
    -Severity 2
```

**Day 29-30: Automation Runbooks**
```powershell
# Create Automation Account
$automationAccount = New-AzAutomationAccount `
    -ResourceGroupName "RG-PKI-Core" `
    -Name "AA-PKI-Automation" `
    -Location "East US" `
    -Plan "Basic"

# Import certificate renewal runbook
$runbookName = "Renew-ExpiringCertificates"
Import-AzAutomationRunbook `
    -AutomationAccountName "AA-PKI-Automation" `
    -ResourceGroupName "RG-PKI-Core" `
    -Path ".\Runbooks\Renew-ExpiringCertificates.ps1" `
    -Type "PowerShell" `
    -Name $runbookName

# Schedule runbook
$schedule = New-AzAutomationSchedule `
    -AutomationAccountName "AA-PKI-Automation" `
    -ResourceGroupName "RG-PKI-Core" `
    -Name "Daily-Certificate-Check" `
    -StartTime (Get-Date).AddDays(1) `
    -DayInterval 1

Register-AzAutomationScheduledRunbook `
    -AutomationAccountName "AA-PKI-Automation" `
    -ResourceGroupName "RG-PKI-Core" `
    -RunbookName $runbookName `
    -ScheduleName "Daily-Certificate-Check"
```

### PHASE 4: Migration Execution (Weeks 7-10)

#### Week 7-8: Pilot Migration

**Day 31-35: Pilot Group Setup**
```powershell
# Create pilot groups
$pilotGroups = @(
    "PKI-Pilot-Users",
    "PKI-Pilot-Computers",
    "PKI-Pilot-Servers"
)

foreach ($group in $pilotGroups) {
    New-ADGroup -Name $group `
        -GroupScope Global `
        -GroupCategory Security `
        -Path "OU=PKI,OU=Groups,DC=company,DC=com"
}

# Add pilot members (10% of environment)
$users = Get-ADUser -Filter * | Select-Object -First 50
Add-ADGroupMember -Identity "PKI-Pilot-Users" -Members $users

# Configure GPO for pilot auto-enrollment
$gpo = New-GPO -Name "PKI-Pilot-AutoEnrollment"
Set-GPRegistryValue -Name "PKI-Pilot-AutoEnrollment" `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
    -ValueName "AEPolicy" `
    -Value 7 `
    -Type DWord

New-GPLink -Name "PKI-Pilot-AutoEnrollment" `
    -Target "OU=Pilot,OU=Computers,DC=company,DC=com"
```

**Day 36-40: Pilot Certificate Deployment**
```powershell
# Script to migrate pilot certificates
$pilotComputers = Get-ADGroupMember -Identity "PKI-Pilot-Computers"

foreach ($computer in $pilotComputers) {
    Invoke-Command -ComputerName $computer.Name -ScriptBlock {
        # Backup existing certificates
        $certs = Get-ChildItem Cert:\LocalMachine\My
        $certs | Export-Certificate -FilePath "C:\CertBackup\$($_.Thumbprint).cer"

        # Request new certificate
        $inf = @"
[Version]
Signature="`$Windows NT$"

[NewRequest]
Subject = "CN=$env:COMPUTERNAME.company.com"
KeySpec = 1
KeyLength = 2048
Exportable = FALSE
MachineKeySet = TRUE
SMIME = FALSE
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

        Set-Content -Path "C:\request.inf" -Value $inf
        certreq -new "C:\request.inf" "C:\request.req"
        certreq -submit -config "PKI-ICA-01\Company Issuing CA 01" "C:\request.req" "C:\newcert.cer"
        certreq -accept "C:\newcert.cer"
    }
}
```

#### Week 9-10: Production Migration

**Day 41-45: Wave 1 Production Migration**
```powershell
# Production migration script with rollback capability
$wave1Systems = Import-Csv ".\Wave1-Systems.csv"

foreach ($system in $wave1Systems) {
    try {
        # Create checkpoint
        Checkpoint-Computer -Description "Pre-PKI-Migration" -ComputerName $system.Name

        # Perform migration
        $result = Invoke-CertificateMigration -ComputerName $system.Name `
            -OldCA "OldRootCA" `
            -NewCA "Company Issuing CA 01" `
            -BackupPath "\\backup\pki\$($system.Name)"

        # Validate new certificate
        $validation = Test-CertificateChain -ComputerName $system.Name
        if (-not $validation.Valid) {
            throw "Certificate chain validation failed"
        }

        # Update tracking
        $system | Add-Member -NotePropertyName "MigrationStatus" -NotePropertyValue "Success"
        $system | Add-Member -NotePropertyName "MigrationDate" -NotePropertyValue (Get-Date)

    } catch {
        # Rollback on failure
        Restore-Computer -RestorePoint $_.CheckpointId -ComputerName $system.Name
        $system | Add-Member -NotePropertyName "MigrationStatus" -NotePropertyValue "Failed"
        $system | Add-Member -NotePropertyName "Error" -NotePropertyValue $_.Exception.Message
    }

    # Export results
    $system | Export-Csv ".\Wave1-Results.csv" -Append
}
```

**Day 46-50: Wave 2 Production Migration**
```powershell
# Continue with remaining systems
$wave2Systems = Import-Csv ".\Wave2-Systems.csv"

# Implement parallel processing for faster migration
$wave2Systems | ForEach-Object -Parallel {
    $system = $_
    # Migration logic here (same as Wave 1)
} -ThrottleLimit 10
```

### PHASE 5: Cutover and Decommissioning (Week 11)

**Day 51-52: Final Validation**
```powershell
# Comprehensive validation script
$validationResults = @()

# Check all certificate chains
$allSystems = Get-ADComputer -Filter *
foreach ($system in $allSystems) {
    $result = Test-CertificateDeployment -ComputerName $system.Name
    $validationResults += $result
}

# Generate validation report
$validationResults | Export-Csv ".\Final-Validation-Report.csv"
$failedSystems = $validationResults | Where-Object {$_.Status -eq "Failed"}

if ($failedSystems.Count -gt 0) {
    Write-Warning "Failed systems detected. Review before proceeding with cutover."
    $failedSystems | Format-Table
}
```

**Day 53: Old Root CA Decommissioning**
```powershell
# Backup old CA database
Backup-CARoleService -Path "\\backup\OldCA" -DatabaseOnly

# Export CA configuration
certutil -backup "\\backup\OldCA\Full" *

# Revoke old root certificate
certutil -revoke "OldRootCA.cer" 1  # 1 = Key Compromise

# Uninstall CA role
Uninstall-AdcsCertificationAuthority -Force

# Archive VM
Stop-AzVM -ResourceGroupName "RG-Legacy" -Name "OLD-ROOT-CA"
$vm = Get-AzVM -ResourceGroupName "RG-Legacy" -Name "OLD-ROOT-CA"
$vm | Set-AzVM -Tag @{Status="Archived"; ArchiveDate=(Get-Date).ToString()}
```

**Day 54-55: Documentation and Handover**
```powershell
# Generate comprehensive documentation
$documentation = @{
    Architecture = Get-PKIArchitecture | ConvertTo-Html
    CertificateTemplates = Get-CATemplate | ConvertTo-Html
    ServiceAccounts = Get-PKIServiceAccounts | ConvertTo-Html
    Procedures = Get-Content ".\PKI-Procedures.md"
    DisasterRecovery = Get-Content ".\PKI-DR-Plan.md"
    Contacts = Import-Csv ".\PKI-Contacts.csv" | ConvertTo-Html
}

# Create documentation package
$documentation | ForEach-Object {
    $_.Value | Out-File ".\Documentation\$($_.Key).html"
}

# Generate knowledge transfer presentation
New-PKIHandoverPresentation -OutputPath ".\PKI-Handover.pptx"
```

## Network Data Flow Diagrams

### Certificate Request Flow - Internal Network

```mermaid
graph LR
    %% Define styles for dark mode
    classDef clientStyle fill:#2c3e50,stroke:#3498db,stroke-width:2px,color:#ecf0f1
    classDef serverStyle fill:#34495e,stroke:#2ecc71,stroke-width:2px,color:#ecf0f1
    classDef securityStyle fill:#7b241c,stroke:#e74c3c,stroke-width:2px,color:#ecf0f1

    subgraph "Client Network - 10.10.0.0/16"
        C1[Windows Client<br/>10.10.1.100]:::clientStyle
        C2[Server<br/>10.10.2.50]:::clientStyle
    end

    subgraph "DMZ - 10.20.0.0/16"
        FW[Firewall<br/>10.20.0.1]:::securityStyle
        PROXY[Reverse Proxy<br/>10.20.1.10]:::securityStyle
    end

    subgraph "PKI Network - 10.50.0.0/16"
        ICA[Issuing CA<br/>10.50.1.10]:::serverStyle
        NDES[NDES Server<br/>10.50.1.20]:::serverStyle
        OCSP[OCSP Responder<br/>10.50.1.30]:::serverStyle
    end

    C1 -->|Port 135/445<br/>RPC| FW
    C2 -->|Port 443<br/>HTTPS| FW
    FW -->|Filtered| ICA
    FW -->|Port 443| PROXY
    PROXY -->|Port 443| NDES
    C1 -->|Port 80<br/>CRL Check| OCSP
    C2 -->|Port 80<br/>OCSP| OCSP
```

### Azure Integration Data Flow

```mermaid
sequenceDiagram
    %% Dark mode friendly
    autonumber
    participant AS as Azure Service
    participant KV as Key Vault
    participant AA as Automation Account
    participant CA as Issuing CA
    participant LOG as Log Analytics

    Note over AS,LOG: Automated Certificate Renewal Flow

    AS->>KV: Check certificate expiry
    KV->>KV: Evaluate policy (30 days)
    KV->>AA: Trigger renewal runbook
    AA->>CA: Generate CSR
    CA->>CA: Validate request
    CA->>AA: Issue certificate
    AA->>KV: Store new certificate
    KV->>AS: Update binding
    AS->>AS: Apply new certificate
    KV->>LOG: Log operation
    AA->>LOG: Log automation result

    opt On Failure
        AA->>LOG: Log error
        LOG->>LOG: Trigger alert
        LOG-->>Admin: Send notification
    end
```

## Post-Implementation Operations

### Daily Operations Checklist

```markdown
## Daily PKI Operations - Checklist

### Morning Checks (9:00 AM)
- [ ] Review overnight certificate issuance logs
- [ ] Check CA service health dashboard
- [ ] Verify OCSP responder availability
- [ ] Review Key Vault backup status
- [ ] Check automation runbook execution history

### Afternoon Checks (2:00 PM)
- [ ] Monitor certificate expiration report
- [ ] Review pending certificate requests
- [ ] Check CRL publication status
- [ ] Verify Intune SCEP connector health
- [ ] Review security alerts

### End of Day (5:00 PM)
- [ ] Export daily certificate issuance report
- [ ] Document any incidents or changes
- [ ] Update ticket queue
- [ ] Verify backup completion
```

### Weekly Maintenance Tasks

```powershell
# Weekly maintenance script
$weeklyTasks = @{
    Monday = {
        # Generate certificate inventory
        Get-CompleteCertificateInventory |
            Export-Excel -Path ".\Reports\Weekly-Inventory.xlsx"
    }
    Wednesday = {
        # Test disaster recovery
        Test-PKIDisasterRecovery -Scenario "ICA-Failure" -DryRun
    }
    Friday = {
        # Performance analysis
        Get-PKIPerformanceMetrics -Days 7 |
            New-PerformanceReport -OutputPath ".\Reports\Weekly-Performance.pdf"
    }
}
```

## Success Criteria and KPIs

### Technical KPIs
- Certificate issuance time: < 30 seconds
- Auto-renewal success rate: > 99%
- System availability: 99.99%
- CRL update frequency: Every 4 hours
- OCSP response time: < 200ms

### Business KPIs
- Certificate-related incidents: -75% reduction
- Manual intervention required: -80% reduction
- Compliance audit findings: Zero critical
- Time to provision new service: -60% reduction
- Cost per certificate: -40% reduction

## Risk Register and Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Azure Private CA outage | Low | High | Maintain offline root backup, implement geo-redundancy |
| Key compromise | Low | Critical | HSM protection, regular key rotation, incident response plan |
| Mass certificate expiry | Medium | High | Automated monitoring, 90-60-30 day alerts, auto-renewal |
| Network connectivity loss | Medium | Medium | ExpressRoute + VPN backup, local CA cache |
| Compliance violation | Low | High | Regular audits, automated compliance checking |

This comprehensive implementation plan provides the complete roadmap for your PKI modernization project with detailed technical steps, automation scripts, and visual representations of all major flows and architectures.
