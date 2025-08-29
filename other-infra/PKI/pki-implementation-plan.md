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

### Detailed Certificate Flow through Security Appliances

```mermaid
sequenceDiagram
    %% Dark mode friendly colors
    autonumber
    participant Client
    participant Zscaler
    participant Firewall as Firewall<br/>(Palo Alto)
    participant NetScaler
    participant Proxy as Reverse Proxy<br/>(F5 BIG-IP)
    participant ICA as Issuing CA
    participant OCSP
    participant App as Application<br/>Server

    Note over Client,App: SSL/TLS Certificate Validation Flow through Security Stack

    Client->>Zscaler: HTTPS Request
    Zscaler->>Zscaler: SSL Inspection
    Zscaler->>OCSP: Certificate Status Check
    OCSP-->>Zscaler: Valid/Revoked Status

    alt Certificate Valid
        Zscaler->>Firewall: Forward Request
        Firewall->>Firewall: Deep Packet Inspection
        Firewall->>NetScaler: SSL Offload Request
        NetScaler->>NetScaler: Decrypt SSL
        NetScaler->>NetScaler: Apply WAF Rules
        NetScaler->>Proxy: Forward to Proxy

        opt Client Certificate Required
            Proxy->>Client: Request Client Cert
            Client->>Proxy: Present Certificate
            Proxy->>OCSP: Validate Client Cert
            OCSP-->>Proxy: Validation Result
        end

        Proxy->>App: Backend Request (Re-encrypted)
        App->>App: Process Request
        App-->>Proxy: Response
        Proxy-->>NetScaler: Response
        NetScaler-->>Firewall: Re-encrypt Response
        Firewall-->>Zscaler: Forward Response
        Zscaler-->>Client: HTTPS Response
    else Certificate Invalid
        Zscaler-->>Client: Block - Certificate Error
    end
```

### NetScaler Certificate Management Architecture

```mermaid
graph LR
    %% Define styles for dark mode
    classDef nsStyle fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0
    classDef certStyle fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef vipStyle fill:#4a235a,stroke:#f39c12,stroke-width:2px,color:#e0e0e0

    subgraph "NetScaler Certificate Configuration"
        subgraph "Certificate Store"
            NSROOT[Root CA Cert<br/>Company Root CA]:::certStyle
            NSINT[Intermediate Certs<br/>Issuing CA 01/02]:::certStyle
            NSSSL[SSL Certificates<br/>*.company.com]:::certStyle
            NSCLIENT[Client CA Certs<br/>For mTLS]:::certStyle
        end

        subgraph "Virtual Servers (VIPs)"
            VIP1[VIP: Portal<br/>10.20.1.100:443<br/>SSL Offload]:::vipStyle
            VIP2[VIP: API Gateway<br/>10.20.1.101:443<br/>SSL Bridge]:::vipStyle
            VIP3[VIP: Admin<br/>10.20.1.102:443<br/>Client Cert Auth]:::vipStyle
        end

        subgraph "SSL Profiles"
            PROF1[Frontend SSL<br/>TLS 1.2/1.3<br/>Strong Ciphers]:::nsStyle
            PROF2[Backend SSL<br/>Re-encrypt<br/>Internal Certs]:::nsStyle
            PROF3[Client Auth<br/>Mandatory mTLS<br/>OCSP Check]:::nsStyle
        end

        subgraph "Certificate Policies"
            POL1[Cert Expiry Alert<br/>30 days warning]:::nsStyle
            POL2[Auto-Renewal<br/>Via Key Vault API]:::nsStyle
            POL3[CRL Update<br/>Every 4 hours]:::nsStyle
        end
    end

    NSROOT --> NSINT
    NSINT --> NSSSL
    NSSSL --> VIP1
    NSSSL --> VIP2
    NSCLIENT --> VIP3

    VIP1 --> PROF1
    VIP2 --> PROF1
    VIP2 --> PROF2
    VIP3 --> PROF3

    PROF1 --> POL1
    PROF2 --> POL2
    PROF3 --> POL3
```

### Zscaler Integration with PKI

```mermaid
flowchart TB
    %% Define styles for dark mode
    classDef zsStyle fill:#0a4d68,stroke:#00bfff,stroke-width:2px,color:#e0e0e0
    classDef pkiStyle fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0
    classDef flowStyle fill:#4a235a,stroke:#f39c12,stroke-width:2px,color:#e0e0e0

    subgraph "Zscaler Cloud Security Platform"
        subgraph "Zscaler Internet Access (ZIA)"
            ZSIA[SSL Inspection<br/>Policy Engine]:::zsStyle
            ZSCA[Custom CA Cert<br/>For Inspection]:::zsStyle
            ZSVAL[Certificate<br/>Validation Service]:::zsStyle
        end

        subgraph "Zscaler Private Access (ZPA)"
            ZPACON[App Connectors<br/>Client Certs Required]:::zsStyle
            ZPACLIENT[ZPA Client<br/>Device Certificates]:::zsStyle
            ZPAPOL[Access Policies<br/>Cert-based Auth]:::zsStyle
        end

        subgraph "Zscaler Certificate Management"
            ZSCERT[Certificate Store<br/>Trusted CAs]:::zsStyle
            ZSAPI[API Integration<br/>Cert Updates]:::zsStyle
            ZSLOG[Certificate<br/>Audit Logs]:::zsStyle
        end
    end

    subgraph "Enterprise PKI Integration"
        ICA[Issuing CA]:::pkiStyle
        SCEP[SCEP/NDES<br/>Mobile Certs]:::pkiStyle
        KV[Azure Key Vault<br/>Cert Repository]:::pkiStyle
        OCSP[OCSP Responder<br/>Status Service]:::pkiStyle
    end

    subgraph "Certificate Flows"
        FLOW1[User Device<br/>Authentication]:::flowStyle
        FLOW2[SSL Inspection<br/>Bypass List]:::flowStyle
        FLOW3[Certificate<br/>Pinning Exceptions]:::flowStyle
    end

    %% Integration paths
    ICA -->|Issue Certs| ZPACLIENT
    SCEP -->|Mobile Certs| ZPACLIENT
    KV -->|API Sync| ZSAPI
    ZSAPI -->|Update| ZSCERT

    ZSIA -->|Validate| ZSVAL
    ZSVAL -->|OCSP Query| OCSP
    ZSCA -->|Custom CA| FLOW2

    ZPACLIENT -->|mTLS| ZPACON
    ZPACON -->|Verify| ZSCERT
    ZPAPOL -->|Check| ZSCERT

    FLOW1 --> ZSIA
    FLOW1 --> ZPACLIENT
    FLOW2 --> ZSCA
    FLOW3 --> ZSVAL

    ZSLOG -->|Audit| FLOW1
    ZSLOG -->|Audit| FLOW2
    ZSLOG -->|Audit| FLOW3
```

### Firewall Certificate Inspection Architecture

```mermaid
graph TB
    %% Define styles for dark mode
    classDef fwStyle fill:#7b241c,stroke:#ec7063,stroke-width:2px,color:#e0e0e0
    classDef zoneStyle fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef policyStyle fill:#2e4053,stroke:#82e0aa,stroke-width:2px,color:#e0e0e0

    subgraph "Palo Alto Firewall - Certificate Architecture"
        subgraph "Security Zones"
            UNTRUST[Untrust Zone<br/>Internet Facing]:::zoneStyle
            DMZ[DMZ Zone<br/>Security Services]:::zoneStyle
            TRUST[Trust Zone<br/>Internal Network]:::zoneStyle
            MGMT[Management Zone<br/>PKI Services]:::zoneStyle
        end

        subgraph "SSL Decryption Policies"
            DEC1[Inbound Inspection<br/>Decrypt & Forward]:::policyStyle
            DEC2[Outbound Inspection<br/>Forward Proxy]:::policyStyle
            BYPASS[Bypass Rules<br/>Banking/Healthcare]:::policyStyle
        end

        subgraph "Certificate Management"
            FWCA[FW CA Certificate<br/>For SSL Decrypt]:::fwStyle
            TRUST_CA[Trusted CA Store<br/>Company Root CA]:::fwStyle
            CRL_CACHE[CRL Cache<br/>4-hour refresh]:::fwStyle
            CERT_PROF[Certificate Profiles<br/>Validation Rules]:::fwStyle
        end

        subgraph "Integration Points"
            OCSP_CLIENT[OCSP Client<br/>Real-time Check]:::fwStyle
            SYSLOG[Syslog Forward<br/>Certificate Events]:::fwStyle
            SNMP[SNMP Traps<br/>Cert Expiry Alerts]:::fwStyle
        end
    end

    UNTRUST -->|SSL Traffic| DEC1
    TRUST -->|SSL Traffic| DEC2
    DEC1 --> FWCA
    DEC2 --> FWCA
    DEC1 --> BYPASS
    DEC2 --> BYPASS

    FWCA --> TRUST_CA
    TRUST_CA --> CRL_CACHE
    TRUST_CA --> CERT_PROF

    CERT_PROF --> OCSP_CLIENT
    CRL_CACHE --> MGMT
    OCSP_CLIENT --> MGMT

    CERT_PROF --> SYSLOG
    CERT_PROF --> SNMP

    DMZ -.->|Certificate Services| MGMT
```

## Detailed Implementation Steps for Network Security Integration

### PHASE 3A: NetScaler Certificate Configuration (Week 5)

#### Day 26: NetScaler SSL Certificate Deployment

```bash
# NetScaler CLI Configuration
# SSH to NetScaler primary node

# 1. Upload Root and Intermediate certificates
add ssl certKey CompanyRootCA -cert "/nsconfig/ssl/CompanyRootCA.crt" -inform PEM
add ssl certKey CompanyIntCA01 -cert "/nsconfig/ssl/IssuingCA01.crt" -inform PEM
add ssl certKey CompanyIntCA02 -cert "/nsconfig/ssl/IssuingCA02.crt" -inform PEM

# 2. Link certificate chain
link ssl certKey CompanyIntCA01 CompanyRootCA
link ssl certKey CompanyIntCA02 CompanyRootCA

# 3. Create SSL certificate for services
add ssl certKey Wildcard-Company-2024 \
    -cert "/nsconfig/ssl/wildcard.company.com.crt" \
    -key "/nsconfig/ssl/wildcard.company.com.key" \
    -inform PEM \
    -expiryMonitor ENABLED \
    -notificationPeriod 30

# 4. Link server certificate to intermediate
link ssl certKey Wildcard-Company-2024 CompanyIntCA01

# 5. Create SSL profiles with strong ciphers
add ssl profile SSL-Profile-Frontend -eRSA ENABLED -eRSACount 1000 \
    -sessReuse ENABLED -sessTimeout 120 \
    -tls1 DISABLED -tls11 DISABLED -tls12 ENABLED -tls13 ENABLED \
    -HSTS ENABLED -maxage 31536000 -includeSubdomains YES

# 6. Configure OCSP responder
add ssl ocspResponder OCSP-Responder \
    -url "http://ocsp.company.com/ocsp" \
    -cache ENABLED \
    -cacheTimeout 30 \
    -batchingDepth 5 \
    -batchingDelay 10

# 7. Bind OCSP to certificate
set ssl certKey Wildcard-Company-2024 -ocspResponder OCSP-Responder

# 8. Configure client certificate authentication
add ssl certKey ClientCA-Company -cert "/nsconfig/ssl/ClientCA.crt" -inform PEM
add ssl policy ClientCert-Policy -rule "CLIENT.SSL.CLIENT_CERT.EXISTS" \
    -action ALLOW

# 9. Create virtual server with SSL
add lb vserver VS-Portal-SSL SSL 10.20.1.100 443 \
    -persistenceType SOURCEIP -timeout 120
bind lb vserver VS-Portal-SSL Wildcard-Company-2024
bind lb vserver VS-Portal-SSL -policyName ClientCert-Policy -priority 100
set ssl vserver VS-Portal-SSL -sslProfile SSL-Profile-Frontend

# 10. Enable SSL session reuse
set ssl parameter -defaultProfile ENABLED -denySSLReneg NONSECURE \
    -insertionEncoding UTF-8 -quantumSize 8192
```

#### Day 27: NetScaler Automation Integration

```powershell
# PowerShell script for NetScaler certificate automation
# Integrate with Azure Key Vault

function Update-NetScalerCertificate {
    param(
        [string]$NSIPAddress,
        [string]$Username,
        [string]$Password,
        [string]$KeyVaultName,
        [string]$CertificateName
    )

    # Get certificate from Azure Key Vault
    $cert = Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $CertificateName
    $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $CertificateName
    $certBytes = [Convert]::FromBase64String($secret.SecretValueText)

    # Extract certificate and key
    $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certCollection.Import($certBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

    # Connect to NetScaler
    $nsSession = Connect-NetScaler -IPAddress $NSIPAddress -Username $Username -Password $Password

    # Upload new certificate
    $certPath = "/nsconfig/ssl/$CertificateName.crt"
    $keyPath = "/nsconfig/ssl/$CertificateName.key"

    Upload-NetScalerFile -Session $nsSession -Path $certPath -Content $cert.Certificate
    Upload-NetScalerFile -Session $nsSession -Path $keyPath -Content $cert.PrivateKey

    # Update certificate binding
    $cmd = "update ssl certKey $CertificateName -cert $certPath -key $keyPath"
    Invoke-NetScalerCommand -Session $nsSession -Command $cmd

    # Save configuration
    Save-NetScalerConfig -Session $nsSession
}

# Schedule as Azure Automation Runbook
$schedule = New-AzAutomationSchedule `
    -AutomationAccountName "AA-PKI-Automation" `
    -Name "NetScaler-Cert-Update" `
    -StartTime (Get-Date).AddDays(1) `
    -MonthInterval 1 `
    -DaysOfMonth 15
```

### PHASE 3B: Zscaler PKI Integration (Week 5)

#### Day 28: Zscaler Certificate Configuration

```python
# Python script for Zscaler API integration
import requests
import json
from cryptography import x509
from cryptography.hazmat.backends import default_backend
import base64

class ZscalerPKIIntegration:
    def __init__(self, cloud, api_key, username, password):
        self.base_url = f"https://zsapi.{cloud}.net/api/v1"
        self.api_key = api_key
        self.username = username
        self.password = password
        self.session = None

    def authenticate(self):
        """Authenticate to Zscaler API"""
        auth_url = f"{self.base_url}/authenticatedSession"

        # Obfuscate credentials
        timestamp = str(int(time.time() * 1000))
        obfuscated_password = self.obfuscate_password(timestamp)

        payload = {
            "apiKey": self.api_key,
            "username": self.username,
            "password": obfuscated_password,
            "timestamp": timestamp
        }

        response = requests.post(auth_url, json=payload)
        if response.status_code == 200:
            self.session = response.cookies.get('JSESSIONID')
            return True
        return False

    def upload_intermediate_ca(self, cert_path):
        """Upload intermediate CA certificate to Zscaler"""
        url = f"{self.base_url}/sslSettings/intermediateCaCert"

        with open(cert_path, 'rb') as f:
            cert_data = f.read()

        cert = x509.load_pem_x509_certificate(cert_data, default_backend())

        payload = {
            "certificate": base64.b64encode(cert_data).decode('utf-8'),
            "description": f"Company Issuing CA - {cert.subject.rfc4514_string()}",
            "certificateUsage": "INTERMEDIATE_CA"
        }

        headers = {'Cookie': f'JSESSIONID={self.session}'}
        response = requests.post(url, json=payload, headers=headers)

        return response.json()

    def configure_ssl_inspection_policy(self):
        """Configure SSL inspection exemptions for certificate services"""
        url = f"{self.base_url}/sslSettings/exemptedUrls"

        exemptions = [
            {"url": "ocsp.company.com", "description": "Company OCSP Responder"},
            {"url": "crl.company.com", "description": "Company CRL Distribution"},
            {"url": "pki.company.com", "description": "PKI Web Enrollment"},
            {"url": "*.digicert.com", "description": "DigiCert Services"},
            {"url": "*.microsoft.com/pki/*", "description": "Microsoft PKI Services"}
        ]

        headers = {'Cookie': f'JSESSIONID={self.session}'}

        for exemption in exemptions:
            response = requests.post(url, json=exemption, headers=headers)
            print(f"Added exemption for {exemption['url']}: {response.status_code}")

    def configure_client_certificate_policy(self):
        """Configure ZPA client certificate requirements"""
        url = f"{self.base_url}/clientCertificate/profiles"

        profile = {
            "name": "Company-Device-Certificate",
            "description": "Company managed device certificates",
            "certificateAttributes": {
                "cn": "*.company.com",
                "ou": "IT Department",
                "o": "Company Inc"
            },
            "validationRules": [
                {"type": "OCSP", "url": "http://ocsp.company.com/ocsp"},
                {"type": "CRL", "url": "http://crl.company.com/crl/IssuingCA01.crl"}
            ],
            "requireStrictValidation": True
        }

        headers = {'Cookie': f'JSESSIONID={self.session}'}
        response = requests.post(url, json=profile, headers=headers)

        return response.json()

# Execute Zscaler configuration
zscaler = ZscalerPKIIntegration(
    cloud="zscaler.net",
    api_key="YOUR_API_KEY",
    username="admin@company.com",
    password="secure_password"
)

if zscaler.authenticate():
    zscaler.upload_intermediate_ca("/path/to/IssuingCA01.crt")
    zscaler.configure_ssl_inspection_policy()
    zscaler.configure_client_certificate_policy()
```

### PHASE 3C: Firewall Certificate Integration (Week 6)

#### Day 29: Palo Alto Firewall PKI Configuration

```bash
# Palo Alto PAN-OS Configuration
# Via CLI or Panorama

# 1. Import CA certificates
request certificate fetch ca-certificate url "http://pki.company.com/CompanyRootCA.crt"
request certificate fetch ca-certificate url "http://pki.company.com/IssuingCA01.crt"

# 2. Configure certificate profile for validation
set shared certificate-profile Company-Cert-Profile \
    CA CompanyRootCA \
    ocsp-url "http://ocsp.company.com/ocsp" \
    crl-receive-url "http://crl.company.com/crl/IssuingCA01.crl" \
    block-unknown-cert yes \
    block-timeout-cert yes \
    block-expired-cert yes

# 3. Create SSL decryption profile
set shared ssl-decryption ssl-forward-proxy Company-Forward-Proxy \
    strip-alpn yes \
    block-client-cert no \
    block-expired-certificate yes \
    block-untrusted-issuer yes \
    block-unknown-cert yes

# 4. Configure SSL decryption policy
set rulebase decryption rules SSL-Decrypt-Policy \
    from any to any \
    source any destination any \
    service any application any \
    decrypt-type ssl-forward-proxy \
    profile Company-Forward-Proxy \
    log-start yes log-end yes

# 5. Add SSL decryption exemptions
set rulebase decryption rules No-Decrypt-PKI \
    from any to any \
    source any destination [ ocsp.company.com crl.company.com pki.company.com ] \
    service any application any \
    action no-decrypt \
    log-start yes

# 6. Configure certificate for management interface
request certificate generate name Mgmt-Interface-Cert \
    certificate-name "CN=fw-mgmt.company.com" \
    algorithm RSA rsa-nbits 2048 \
    digest sha256 \
    signed-by external

# 7. Configure OCSP responder settings
set deviceconfig system ocsp-responder CompanyOCSP \
    url "http://ocsp.company.com/ocsp" \
    certificate-profile Company-Cert-Profile

# 8. Enable certificate status monitoring
set deviceconfig system certificate-monitoring enabled yes \
    notification-email security@company.com \
    expiry-threshold 30

# 9. Configure syslog for certificate events
set shared log-settings syslog PKI-Events \
    server PKI-Syslog server 10.50.1.50 \
    facility LOG_LOCAL3 \
    port 514 \
    format BSD

# 10. Commit configuration
commit description "PKI Integration - Certificate Management"
```

#### Day 30: F5 BIG-IP Certificate Management

```tcl
# F5 BIG-IP TMSH Configuration Script

# 1. Import certificates and keys
tmsh install sys crypto cert CompanyRootCA from-local-file /var/tmp/CompanyRootCA.crt
tmsh install sys crypto cert IssuingCA01 from-local-file /var/tmp/IssuingCA01.crt
tmsh install sys crypto cert wildcard.company.com from-local-file /var/tmp/wildcard.crt
tmsh install sys crypto key wildcard.company.com from-local-file /var/tmp/wildcard.key

# 2. Create certificate chain
tmsh create sys crypto cert-chain company-chain \
    certs add { wildcard.company.com IssuingCA01 CompanyRootCA }

# 3. Create client SSL profile with OCSP
tmsh create ltm profile client-ssl Company-ClientSSL \
    cert wildcard.company.com \
    key wildcard.company.com \
    chain company-chain \
    ciphers "ECDHE+RSA+AES256:ECDHE+RSA+AES128:!MD5:!EXPORT:!DES:!DHE:!EDH:!RC4:!ADH:!SSLv3:!TLSv1" \
    options { dont-insert-empty-fragments no-tlsv1 no-tlsv1.1 } \
    ocsp-stapling enabled

# 4. Create server SSL profile for backend
tmsh create ltm profile server-ssl Company-ServerSSL \
    cert wildcard.company.com \
    key wildcard.company.com \
    ciphers "DEFAULT" \
    secure-renegotiation require

# 5. Configure OCSP responder
tmsh create ltm auth ocsp-responder CompanyOCSP \
    url http://ocsp.company.com/ocsp \
    signer wildcard.company.com

# 6. Create certificate validation profile
tmsh create ltm auth cert-ldap Company-Cert-Validation \
    servers add { 10.50.1.40 } \
    search-base "dc=company,dc=com" \
    search-filter "(objectClass=pkiUser)"

# 7. Configure client certificate authentication
tmsh create ltm auth ssl-cc-ldap Company-Client-Cert \
    cert-validation Company-Cert-Validation \
    cert-map { cert-subject-cn }

# 8. Create iRule for certificate inspection
tmsh create ltm rule Certificate-Logging {
    when CLIENTSSL_CLIENTCERT {
        if {[SSL::cert count] > 0} {
            set subject [X509::subject [SSL::cert 0]]
            set issuer [X509::issuer [SSL::cert 0]]
            set serial [X509::serial_number [SSL::cert 0]]
            log local0. "Client Certificate: Subject=$subject Issuer=$issuer Serial=$serial"

            # Check certificate validity
            set notafter [X509::not_after [SSL::cert 0]]
            set now [clock seconds]
            set expire_days [expr {($notafter - $now) / 86400}]

            if {$expire_days < 30} {
                log local0.warning "Certificate expiring soon: $subject expires in $expire_days days"
            }
        }
    }
}

# 9. Apply to virtual server
tmsh create ltm virtual VS-Portal-443 \
    destination 10.20.1.103:443 \
    ip-protocol tcp \
    profiles add { Company-ClientSSL { context clientside } Company-ServerSSL { context serverside } } \
    rules { Certificate-Logging } \
    source-address-translation { type automap } \
    pool Portal-Pool

# 10. Configure automatic certificate renewal via iControl REST
tmsh create sys application service PKI-Auto-Renewal \
    template f5.http \
    variables add { \
        renewal_script { value {
            # Script to check and renew certificates
            # Integrates with Azure Key Vault API
        }}
    }

# Save configuration
tmsh save sys config
```

## Network Security Certificate Monitoring Dashboard

```mermaid
graph TB
    %% Define styles for dark mode
    classDef monitorStyle fill:#1e3a5f,stroke:#4db8ff,stroke-width:2px,color:#e0e0e0
    classDef alertStyle fill:#7b241c,stroke:#ec7063,stroke-width:2px,color:#e0e0e0
    classDef healthyStyle fill:#0e6251,stroke:#52be80,stroke-width:2px,color:#e0e0e0

    subgraph "Certificate Monitoring Dashboard"
        subgraph "Real-time Monitoring"
            MON1[NetScaler<br/>5 Certs<br/>✓ All Valid]:::healthyStyle
            MON2[Zscaler<br/>3 Certs<br/>⚠ 1 Expiring]:::alertStyle
            MON3[Palo Alto FW<br/>8 Certs<br/>✓ All Valid]:::healthyStyle
            MON4[F5 BIG-IP<br/>12 Certs<br/>✓ All Valid]:::healthyStyle
            MON5[Azure Services<br/>25 Certs<br/>✓ Auto-Renewed]:::healthyStyle
        end

        subgraph "Certificate Metrics"
            MET1[Total Certificates<br/>Active: 2,847]:::monitorStyle
            MET2[Expiring < 30 days<br/>Count: 47]:::alertStyle
            MET3[Auto-Renewed<br/>This Month: 156]:::healthyStyle
            MET4[Failed Renewals<br/>Count: 2]:::alertStyle
        end

        subgraph "OCSP/CRL Status"
            OCSP1[OCSP Responder<br/>Uptime: 99.99%<br/>Avg Response: 45ms]:::healthyStyle
            CRL1[CRL Distribution<br/>Last Update: 2h ago<br/>Next: 2h]:::healthyStyle
        end

        subgraph "Compliance Status"
            COMP1[TLS Version<br/>100% TLS 1.2+]:::healthyStyle
            COMP2[Key Strength<br/>98% RSA-2048+]:::healthyStyle
            COMP3[Certificate Validity<br/>100% Valid Chain]:::healthyStyle
            COMP4[HSM Protection<br/>100% Code Sign]:::healthyStyle
        end
    end

    MON2 -->|Alert| MET2
    MET2 -->|Trigger| AUTO[Auto-Renewal<br/>Process]:::monitorStyle
    MET4 -->|Escalate| TEAM[Security Team<br/>Notification]:::alertStyle
```

## Complete Network Segment Certificate Requirements

### Network Segmentation and Certificate Matrix

| Network Segment | IP Range | Certificate Type | Issuing CA | Validity | Key Size | Special Requirements |
|-----------------|----------|------------------|------------|----------|----------|----------------------|
| **Internet Edge** | | | | | | |
| Zscaler Cloud | N/A | SSL Inspection CA | Zscaler CA | 10 years | RSA-4096 | Custom root for inspection |
| Azure Front Door | N/A | Public SSL | DigiCert | 1 year | RSA-2048 | Public trusted, CAA records |
| **DMZ - Perimeter** | 10.20.0.0/16 | | | | | |
| NetScaler VIPs | 10.20.1.0/24 | Wildcard SSL | ICA-01 | 2 years | RSA-2048 | OCSP stapling enabled |
| F5 BIG-IP | 10.20.2.0/24 | SAN Certificate | ICA-01 | 2 years | RSA-2048 | Multiple FQDNs |
| Palo Alto FW | 10.20.3.0/24 | Mgmt + Decrypt CA | ICA-02 | 3 years | RSA-4096 | HSM-backed decrypt cert |
| Forward Proxy | 10.20.4.0/24 | Proxy CA | ICA-02 | 5 years | RSA-4096 | Chain validation required |
| **Internal Zones** | | | | | | |
| Corporate LAN | 10.10.0.0/16 | Computer Certs | ICA-01 | 2 years | RSA-2048 | Auto-enrollment GPO |
| Server Farm | 10.30.0.0/16 | Server Auth | ICA-01 | 2 years | RSA-2048 | IIS, Apache, Nginx |
| Database Tier | 10.40.0.0/16 | SQL TLS | ICA-02 | 3 years | RSA-2048 | Force encryption |
| PKI Core | 10.50.0.0/16 | Infrastructure | Root CA | 10 years | RSA-4096 | Offline root, HSM |
| **Special Purpose** | | | | | | |
| IoT Devices | 10.60.0.0/16 | 802.1X EAP-TLS | ICA-01 | 5 years | ECC-P256 | Low computational overhead |
| VoIP Phones | 10.70.0.0/16 | SCEP Enrolled | NDES | 3 years | RSA-2048 | Cisco ISE integration |
| Wireless | 10.80.0.0/16 | RADIUS/EAP | ICA-01 | 2 years | RSA-2048 | NPS/FreeRADIUS |
| VPN Users | Dynamic | User Certificates | ICA-01 | 1 year | RSA-2048 | Smart card compatible |

## Automation Scripts for Network Appliances

### Universal Certificate Deployment Script

```powershell
# Master certificate deployment script for all network appliances
# Save as Deploy-CertificateToAppliances.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$CertificatePath,

    [Parameter(Mandatory=$true)]
    [string]$PrivateKeyPath,

    [Parameter(Mandatory=$true)]
    [ValidateSet("NetScaler", "F5", "PaloAlto", "Zscaler", "All")]
    [string]$TargetAppliance,

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".\appliance-config.json"
)

# Load configuration
$config = Get-Content $ConfigFile | ConvertFrom-Json

function Deploy-ToNetScaler {
    param($cert, $key, $config)

    $nsSession = Connect-NetScaler -IPAddress $config.NetScaler.IP `
        -Username $config.NetScaler.Username `
        -Password (ConvertTo-SecureString $config.NetScaler.Password -AsPlainText -Force)

    # Upload certificate files
    $certName = [System.IO.Path]::GetFileNameWithoutExtension($cert)
    Upload-NetScalerFile -Session $nsSession -Path "/nsconfig/ssl/$certName.crt" -LocalFile $cert
    Upload-NetScalerFile -Session $nsSession -Path "/nsconfig/ssl/$certName.key" -LocalFile $key

    # Create certificate object
    $cmd = "add ssl certKey $certName -cert /nsconfig/ssl/$certName.crt -key /nsconfig/ssl/$certName.key"
    Invoke-NetScalerCommand -Session $nsSession -Command $cmd

    # Update bindings
    foreach ($vserver in $config.NetScaler.VirtualServers) {
        $cmd = "bind ssl vserver $vserver -certkeyName $certName"
        Invoke-NetScalerCommand -Session $nsSession -Command $cmd
    }

    Save-NetScalerConfig -Session $nsSession
    Write-Host "Successfully deployed certificate to NetScaler" -ForegroundColor Green
}

function Deploy-ToF5 {
    param($cert, $key, $config)

    # F5 iControl REST API
    $headers = @{
        'Content-Type' = 'application/json'
        'Authorization' = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($config.F5.Username):$($config.F5.Password)"))
    }

    $certContent = Get-Content $cert -Raw
    $keyContent = Get-Content $key -Raw

    # Upload certificate
    $certBody = @{
        name = "wildcard-company-$(Get-Date -Format 'yyyy')"
        cert = $certContent
        key = $keyContent
    } | ConvertTo-Json

    $uri = "https://$($config.F5.IP)/mgmt/tm/sys/crypto/cert"
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $certBody -SkipCertificateCheck

    Write-Host "Successfully deployed certificate to F5 BIG-IP" -ForegroundColor Green
}

function Deploy-ToPaloAlto {
    param($cert, $key, $config)

    # Generate API key
    $authUri = "https://$($config.PaloAlto.IP)/api/?type=keygen&user=$($config.PaloAlto.Username)&password=$($config.PaloAlto.Password)"
    $authResponse = Invoke-RestMethod -Uri $authUri -Method Get -SkipCertificateCheck
    $apiKey = $authResponse.response.result.key

    # Import certificate
    $certContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($cert))
    $keyContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($key))

    $importUri = "https://$($config.PaloAlto.IP)/api/?type=import&category=certificate"
    $importUri += "&certificate-name=wildcard-company&format=pem&key=$apiKey"

    $body = @{
        certificate = $certContent
        private_key = $keyContent
    }

    Invoke-RestMethod -Uri $importUri -Method Post -Body $body -SkipCertificateCheck

    # Commit configuration
    $commitUri = "https://$($config.PaloAlto.IP)/api/?type=commit&key=$apiKey"
    Invoke-RestMethod -Uri $commitUri -Method Get -SkipCertificateCheck

    Write-Host "Successfully deployed certificate to Palo Alto firewall" -ForegroundColor Green
}

function Deploy-ToZscaler {
    param($cert, $key, $config)

    # Zscaler API implementation
    $baseUrl = "https://zsapi.$($config.Zscaler.Cloud)/api/v1"

    # Authenticate
    $authBody = @{
        apiKey = $config.Zscaler.ApiKey
        username = $config.Zscaler.Username
        password = $config.Zscaler.Password
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json

    $session = Invoke-RestMethod -Uri "$baseUrl/authenticatedSession" -Method Post -Body $authBody

    # Upload certificate
    $certContent = Get-Content $cert -Raw
    $uploadBody = @{
        certificate = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($certContent))
        type = "INTERMEDIATE_CA"
    } | ConvertTo-Json

    $headers = @{
        'Cookie' = "JSESSIONID=$($session.jsessionid)"
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri "$baseUrl/sslSettings/intermediateCaCert" -Method Post -Headers $headers -Body $uploadBody

    Write-Host "Successfully deployed certificate to Zscaler" -ForegroundColor Green
}

# Main execution
try {
    $certificate = Get-Content $CertificatePath
    $privateKey = Get-Content $PrivateKeyPath

    switch ($TargetAppliance) {
        "NetScaler" { Deploy-ToNetScaler -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "F5" { Deploy-ToF5 -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "PaloAlto" { Deploy-ToPaloAlto -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "Zscaler" { Deploy-ToZscaler -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "All" {
            Deploy-ToNetScaler -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToF5 -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToPaloAlto -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToZscaler -cert $CertificatePath -key $PrivateKeyPath -config $config
        }
    }

    Write-Host "`nCertificate deployment completed successfully!" -ForegroundColor Green

} catch {
    Write-Error "Certificate deployment failed: $_"
    exit 1
}
```

### Configuration File (appliance-config.json)

```json
{
    "NetScaler": {
        "IP": "10.20.1.10",
        "Username": "nsadmin",
        "Password": "encrypted_password_here",
        "VirtualServers": [
            "VS-Portal-SSL",
            "VS-API-SSL",
            "VS-Admin-SSL"
        ]
    },
    "F5": {
        "IP": "10.20.2.10",
        "Username": "admin",
        "Password": "encrypted_password_here",
        "Partitions": ["Common", "Production"]
    },
    "PaloAlto": {
        "IP": "10.20.3.10",
        "Username": "admin",
        "Password": "encrypted_password_here",
        "Vsys": "vsys1"
    },
    "Zscaler": {
        "Cloud": "zscaler.net",
        "ApiKey": "api_key_here",
        "Username": "admin@company.com",
        "Password": "encrypted_password_here"
    }
}
```

## Comprehensive Testing Plan

### Certificate Validation Test Matrix

```powershell
# Comprehensive certificate validation script
# Test-EnterprisePKI.ps1

function Test-EnterprisePKI {
    $results = @()

    # Test NetScaler certificates
    $nsTests = @(
        @{Name="Portal VIP"; URL="https://portal.company.com"; ExpectedCN="*.company.com"},
        @{Name="API Gateway"; URL="https://api.company.com"; ExpectedCN="*.company.com"},
        @{Name="Admin Interface"; URL="https://admin.company.com:443"; ClientCert=$true}
    )

    foreach ($test in $nsTests) {
        $result = Test-SSLCertificate @test
        $results += $result
    }

    # Test Zscaler integration
    $zsTests = @(
        @{Name="ZPA Portal"; URL="https://company.privateaccess.zscaler.com"; ExpectedCA="Zscaler"},
        @{Name="ZIA Gateway"; URL="https://gateway.zscaler.net"; SSLInspection=$true}
    )

    foreach ($test in $zsTests) {
        $result = Test-ZscalerCertificate @test
        $results += $result
    }

    # Test firewall certificates
    $fwTests = @(
        @{Name="Palo Alto Mgmt"; URL="https://fw-mgmt.company.com"; ExpectedCN="fw-mgmt.company.com"},
        @{Name="GlobalProtect"; URL="https://vpn.company.com"; ClientCert=$true}
    )

    foreach ($test in $fwTests) {
        $result = Test-FirewallCertificate @test
        $results += $result
    }

    # Generate report
    $results | Export-Csv -Path ".\PKI-Test-Results-$(Get-Date -Format 'yyyyMMdd').csv"

    # Create HTML dashboard
    $html = $results | ConvertTo-Html -Head @"
<style>
    body { background-color: #1e1e1e; color: #e0e0e0; font-family: Arial; }
    table { border-collapse: collapse; width: 100%; }
    th { background-color: #2e4053; color: #4db8ff; padding: 10px; }
    td { padding: 8px; border: 1px solid #34495e; }
    .pass { color: #52be80; }
    .fail { color: #ec7063; }
</style>
"@

    $html | Out-File ".\PKI-Dashboard.html"

    return $results
}

# Execute comprehensive test
$testResults = Test-EnterprisePKI

# Alert on failures
$failures = $testResults | Where-Object {$_.Status -eq "Failed"}
if ($failures.Count -gt 0) {
    Send-MailMessage -To "security@company.com" `
        -Subject "PKI Test Failures Detected" `
        -Body ($failures | Format-Table | Out-String) `
        -SmtpServer "smtp.company.com"
}
```

This comprehensive update includes all network security appliances (NetScaler, Zscaler, Palo Alto, F5), their certificate management configurations, detailed implementation steps, and automation scripts. The diagrams are designed with dark-mode friendly colors and show the complete certificate flow through your security stack.
