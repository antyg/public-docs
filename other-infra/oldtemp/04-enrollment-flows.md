# PKI Modernization - Certificate Enrollment Flows

[← Previous: PKI Hierarchy](03-pki-hierarchy.md) | [Back to Index](00-index.md) | [Next: Phase 1 Foundation →](05-phase1-foundation.md)

## Certificate Enrollment Flows Overview

This document details the various certificate enrollment flows for different device types and use cases, including mobile devices, Azure services, and code signing certificates.

## Mobile Device Certificate Enrollment via Intune

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

### Mobile Enrollment Prerequisites

| Component | Requirement | Configuration |
|-----------|-------------|---------------|
| Intune License | Microsoft Intune or EMS E3+ | Per-user licensing |
| NDES Server | Windows Server 2019/2022 | Domain-joined |
| Certificate Connector | Latest version | Installed on NDES server |
| Network Access | HTTPS 443 | NDES to Intune |
| Certificate Template | Mobile device template | Published to CA |

### Supported Mobile Platforms

| Platform | Enrollment Method | Certificate Store | Key Storage |
|----------|------------------|------------------|-------------|
| iOS 14+ | SCEP | Device keychain | Secure Enclave |
| Android 10+ | SCEP | Android keystore | Hardware-backed |
| Windows 10/11 Mobile | SCEP | Computer store | TPM 2.0 |

## Azure Services Certificate Automation Flow

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

    subgraph "Azure Services - Australia East"
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

### Azure Certificate Automation Configuration

| Service | Integration Method | Renewal Trigger | Binding Method |
|---------|-------------------|-----------------|----------------|
| App Service | Key Vault reference | 30 days before expiry | Automatic |
| Application Gateway | Key Vault integration | Policy-based | Listener update |
| API Management | Managed identity | 30 days before expiry | Custom domain |
| AKS | Cert-manager | Annotation-based | Ingress controller |
| Azure Front Door | Managed certificate | 30 days before expiry | Automatic |

## Code Signing Certificate Management Flow

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

### Code Signing Request Process

1. **Request Initiation**
   - User submits request via self-service portal
   - Specifies purpose and justification
   - Selects validity period (1 or 2 years)

2. **Approval Workflow**
   - Manager approval for standard requests
   - Security team approval for extended validity
   - Automatic approval for pre-approved teams

3. **Certificate Generation**
   - Key pair generated in Azure Key Vault HSM
   - CSR submitted to issuing CA
   - Certificate bound to non-exportable key

4. **Usage and Monitoring**
   - All signing operations logged
   - Monthly usage reports generated
   - Anomaly detection for unusual activity

## Windows Domain Computer Auto-Enrollment

```mermaid
flowchart TB
    subgraph "Group Policy Application"
        GP[GPO: Auto-Enrollment]
        GP --> COMP[Domain Computer]
    end
    
    subgraph "Enrollment Process"
        COMP --> CHECK{Certificate<br/>Needed?}
        CHECK -->|Yes| REQ[Generate CSR]
        CHECK -->|No| WAIT[Wait for Next Cycle]
        REQ --> CA[Submit to CA]
        CA --> TEMP[Apply Template]
        TEMP --> ISSUE[Issue Certificate]
        ISSUE --> INST[Install Certificate]
        INST --> LOG[Log Success]
    end
    
    subgraph "Renewal Process"
        INST --> MON[Monitor Expiry]
        MON --> RENEW{80% Lifetime?}
        RENEW -->|Yes| REQ
        RENEW -->|No| WAIT
    end
```

### Auto-Enrollment Configuration

| Setting | Value | Location |
|---------|-------|----------|
| Policy Setting | Enabled | Computer Configuration > Policies > Windows Settings > Security Settings |
| Renew Expired | Enabled | Auto-enrollment properties |
| Update Templates | Enabled | Auto-enrollment properties |
| Process User Certs | Optional | User Configuration (if needed) |
| Renewal Threshold | 80% of lifetime | Certificate template setting |

## Server Certificate Manual Enrollment

### Web Server Certificate Request Process

1. **Generate CSR**
   ```powershell
   # Generate certificate request
   $inf = @"
   [Version]
   Signature="`$Windows NT$"
   
   [NewRequest]
   Subject = "CN=webserver.company.com.au,O=Company,L=Sydney,S=NSW,C=AU"
   KeySpec = 1
   KeyLength = 2048
   Exportable = TRUE
   MachineKeySet = TRUE
   SMIME = FALSE
   UseExistingKeySet = FALSE
   ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
   ProviderType = 12
   RequestType = PKCS10
   KeyUsage = 0xa0
   
   [EnhancedKeyUsageExtension]
   OID=1.3.6.1.5.5.7.3.1 ; Server Authentication
   "@
   
   Set-Content -Path request.inf -Value $inf
   certreq -new request.inf request.req
   ```

2. **Submit to CA**
   - Via web enrollment portal
   - Via MMC certificate snap-in
   - Via certreq command line

3. **Approval and Issuance**
   - CA administrator review (if required)
   - Template compliance check
   - Certificate issuance

4. **Installation**
   ```powershell
   # Accept and install certificate
   certreq -accept certificate.cer
   ```

## SCEP/NDES Enrollment Flow

### Network Device Enrollment

```mermaid
sequenceDiagram
    participant Device as Network Device
    participant NDES as NDES Server
    participant CA as Issuing CA
    participant Admin as Administrator
    
    Admin->>NDES: Request Challenge Password
    NDES->>NDES: Generate One-Time Password
    NDES->>Admin: Return Password
    Admin->>Device: Configure SCEP Profile
    Device->>NDES: SCEP GetCACert
    NDES->>Device: CA Certificate
    Device->>Device: Generate Key Pair
    Device->>NDES: SCEP PKCSReq with Challenge
    NDES->>NDES: Validate Challenge
    NDES->>CA: Submit CSR
    CA->>NDES: Issue Certificate
    NDES->>Device: Return Certificate
    Device->>Device: Install Certificate
```

### SCEP Profile Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| URL | https://ndes.company.com.au/certsrv/mscep/mscep.dll | SCEP endpoint |
| Challenge Type | Dynamic | One-time password |
| Key Size | 2048 bits | RSA key length |
| Hash Algorithm | SHA-256 | Signature hash |
| Subject | CN={{DeviceName}} | Device identifier |
| Validity | 1 year | Certificate lifetime |
| Renewal | 80% | Auto-renewal threshold |

## Certificate Enrollment Protocols Comparison

| Protocol | Use Case | Pros | Cons |
|----------|----------|------|------|
| Auto-Enrollment | Domain computers | Zero-touch, GPO-based | Windows-only |
| SCEP/NDES | Mobile & network devices | Cross-platform | Complex setup |
| Web Enrollment | Manual requests | User-friendly | Manual process |
| CEP/CES | Internet-based | Works over internet | Deprecated |
| EST | IoT devices | Standards-based | Limited support |
| CMPv2 | Complex scenarios | Full-featured | Complex protocol |

## Troubleshooting Common Enrollment Issues

### Issue: SCEP Enrollment Fails

| Symptom | Cause | Resolution |
|---------|-------|------------|
| Challenge rejected | Expired password | Generate new challenge |
| Connection timeout | Firewall blocking | Open port 443 |
| Certificate not trusted | Missing root CA | Deploy root certificate |
| Template not found | Permissions issue | Verify NDES service account |

### Issue: Auto-Enrollment Not Working

| Check Point | Verification Command | Expected Result |
|-------------|---------------------|----------------|
| GPO Applied | `gpresult /h report.html` | Policy listed |
| CA Connectivity | `certutil -ping` | Successful ping |
| Template Permissions | `certutil -CATemplates` | Template visible |
| Event Log | Check Application log | No errors |

### Issue: Azure Certificate Renewal Fails

| Component | Check | Action |
|-----------|-------|--------|
| Key Vault Access | Managed identity permissions | Grant certificate permissions |
| CA Connectivity | Network connectivity to CA | Verify firewall rules |
| Certificate Policy | Policy configuration | Update renewal settings |
| Audit Logs | Key Vault diagnostics | Review error details |

---
[← Previous: PKI Hierarchy](03-pki-hierarchy.md) | [Back to Index](00-index.md) | [Next: Phase 1 Foundation →](05-phase1-foundation.md)