---
title: "Autopilot Architecture Diagrams"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Autopilot Architecture Diagrams

Mermaid diagrams depicting Windows Autopilot service architecture, deployment flows, and service boundary handoffs. All diagrams use the colour scheme defined in the legend below.

For service ownership details and boundary definitions, see the [Service Boundaries and Handoffs reference](Service-Boundaries-and-Handoffs.md). For the official service overview, see [Windows Autopilot overview — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/overview).

## Colour Legend

| Category | Fill Colour | Stroke Colour | Usage |
|----------|------------|--------------|-------|
| Device / Client | Deep Blue (`#1e3a5f` / `#0d47a1`) | Light Blue (`#4fc3f7` / `#64b5f6`) | End user devices, OOBE, ESP |
| Cloud Services | Deep Purple (`#4a148c`) | Light Purple (`#ba68c8`) | Microsoft cloud services (Intune, Entra ID, Autopilot service) |
| Security | Deep Red (`#7f1e1e` / `#b71c1c`) | Light Red (`#ef5350`) | Security services (Defender, Conditional Access, DLP) |
| On-Premises | Deep Brown (`#5d4037` / `#bf360c`) | Orange (`#ff9800` / `#ff7043`) | Hybrid infrastructure (AD, DC, Intune Connector) |
| Supporting | Deep Green (`#2e4e1f` / `#1b5e20`) | Light Green (`#8bc34a` / `#66bb6a`) | Supporting services (DNS, NTP, CRL) |
| Data Flow | Deep Pink (`#880e4f`) | Light Pink (`#ec407a`) | Data types and flow indicators |
| DMZ / Neutral | Deep Amber (`#5d4e37`) | Yellow (`#ffc107`) | DMZ, proxy, and neutral zone services |

## Service Integration Architecture

### High-Level Service Architecture

Depicts all service layers involved in a Windows Autopilot deployment, including optional hybrid and co-management paths. Source: [Windows Autopilot requirements — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/requirements).

```mermaid
graph LR
    subgraph "End User Device Layer"
        Device[Windows Device<br/>TPM 2.0, UEFI]
        OOBE[Out-of-Box Experience<br/>Windows Setup]
        ESP[Enrollment Status Page<br/>Progress Tracking]
    end

    subgraph "Network Layer"
        Internet[Internet Connection<br/>HTTPS 443]
        VPN[VPN Services<br/>Optional for Hybrid]
        Proxy[Proxy Services<br/>PAC/Direct]
    end

    subgraph "Microsoft Cloud Services"
        subgraph "Core Autopilot Services"
            WAS[Windows Autopilot Service<br/>Device Registration and Profiles]
            WUFB[Windows Update for Business<br/>OS and Driver Updates]
            WNS[Windows Notification Service<br/>Push Notifications]
        end

        subgraph "Identity Services"
            EntraID[Microsoft Entra ID<br/>Identity and Authentication]
            MFA[Multi-Factor Authentication<br/>Security Verification]
            CA[Conditional Access<br/>Policy Enforcement]
            PIM[Privileged Identity Management<br/>Role Elevation]
        end

        subgraph "Device Management"
            Intune[Microsoft Intune<br/>MDM/MAM Services]
            MAM[Mobile Application Management<br/>App Protection]
            ComplianceEngine[Compliance Engine<br/>Policy Evaluation]
            ConfigManager[Configuration Manager<br/>Co-management Optional]
        end

        subgraph "Application Delivery"
            MSStore[Microsoft Store for Business<br/>Store Apps]
            M365Apps[Microsoft 365 Apps<br/>Office Suite]
            EAC[Enterprise App Catalog<br/>2025 Feature]
            AppProxy[Entra ID App Proxy<br/>Legacy App Access]
        end

        subgraph "Security Services"
            Defender[Microsoft Defender for Endpoint<br/>Threat Protection]
            DLP[Data Loss Prevention<br/>Information Protection]
            CloudAppSec[Cloud App Security<br/>CASB Services]
            Sentinel[Microsoft Sentinel<br/>SIEM/SOAR Optional]
        end
    end

    subgraph "On-Premises Infrastructure (Hybrid Only)"
        AD[Active Directory<br/>Domain Services]
        ODJConnector[Intune Connector<br/>Offline Domain Join]
        DC[Domain Controllers<br/>Authentication]
        CA_Internal[Internal Certificate Authority<br/>PKI Services]
        ConfigMgrOnPrem[Configuration Manager<br/>On-Premises]
    end

    subgraph "Supporting Infrastructure"
        DNS[DNS Services<br/>Name Resolution]
        NTP[NTP Services<br/>Time Sync]
        CRL[Certificate Revocation<br/>Validation Services]
        Telemetry[Telemetry Services<br/>Diagnostics]
    end

    Device --> Internet
    Internet --> WAS
    Device --> OOBE
    OOBE --> ESP
    ESP --> Intune

    Device --> EntraID
    EntraID --> MFA
    EntraID --> CA
    CA --> ComplianceEngine

    WAS --> Intune
    Intune --> Device
    Intune --> ComplianceEngine
    ComplianceEngine --> Device

    Intune --> MSStore
    Intune --> M365Apps
    Intune --> EAC
    MSStore --> Device
    M365Apps --> Device
    EAC --> Device

    Device --> Defender
    Defender --> CloudAppSec
    Defender --> Sentinel
    DLP --> Device

    Device --> WUFB
    WUFB --> Device

    ODJConnector --> AD
    ODJConnector --> DC
    ODJConnector --> Intune
    AD --> DC
    Device -.->|Hybrid Only| VPN
    VPN -.-> DC

    Device --> DNS
    Device --> NTP
    Device --> CRL
    Device --> Telemetry

    WNS --> Device
    Intune --> WNS

    ConfigManager -.-> ConfigMgrOnPrem
    ConfigMgrOnPrem -.-> Device

    AppProxy --> AD
    Device --> AppProxy

    CA_Internal -.-> Device
    EntraID --> CA_Internal

    EntraID --> PIM
    PIM --> EntraID

    Intune --> MAM
    MAM --> Device

    Device --> Proxy
    Proxy --> Internet

    classDef deviceClass fill:#0d47a1,stroke:#64b5f6,stroke-width:3px,color:#ffffff
    classDef cloudClass fill:#4a148c,stroke:#ba68c8,stroke-width:2px,color:#ffffff
    classDef securityClass fill:#b71c1c,stroke:#ef5350,stroke-width:2px,color:#ffffff
    classDef onpremClass fill:#5d4037,stroke:#ff9800,stroke-width:2px,stroke-dasharray:5 5,color:#ffffff
    classDef supportClass fill:#1b5e20,stroke:#66bb6a,stroke-width:2px,color:#ffffff
    classDef dataFlowClass fill:#880e4f,stroke:#ec407a,stroke-width:2px,color:#ffffff
    classDef dmzClass fill:#5d4e37,stroke:#ffc107,stroke-width:2px,color:#ffffff

    class Device,OOBE,ESP deviceClass
    class WAS,Intune,EntraID,MSStore,M365Apps,EAC,WUFB,WNS,ConfigManager cloudClass
    class MFA,CA,PIM,Defender,DLP,CloudAppSec,Sentinel,MAM,ComplianceEngine,AppProxy securityClass
    class AD,ODJConnector,DC,CA_Internal,ConfigMgrOnPrem onpremClass
    class DNS,NTP,CRL,Telemetry supportClass
    class Internet dataFlowClass
    class VPN,Proxy dmzClass
```

### Service Dependencies Matrix

Depicts the dependency chain between core, secondary, and conditional services, and the data flow types between them.

```mermaid
graph LR
    subgraph "Service Dependencies Matrix"
        subgraph "Primary Dependencies"
            AutopilotCore[Autopilot Core<br/>Registration and Profiles]
            IntuneCore[Intune Core<br/>Device Management]
            EntraCore[Entra ID Core<br/>Authentication]
        end

        subgraph "Secondary Dependencies"
            ComplianceService[Compliance Service<br/>Policy Engine]
            AppDelivery[App Delivery<br/>Win32, Store, LOB]
            SecurityServices[Security Services<br/>Defender, DLP]
        end

        subgraph "Conditional Dependencies"
            HybridServices[Hybrid Services<br/>Domain Join]
            CoMgmtServices[Co-Management<br/>ConfigMgr Integration]
            ProxyServices[App Proxy<br/>Legacy Access]
        end

        subgraph "Data Flow Types"
            DeviceData[Device Data<br/>Hardware Hash, Serial]
            UserData[User Data<br/>Identity, Credentials]
            PolicyData[Policy Data<br/>Config, Compliance]
            AppData[Application Data<br/>Packages, Settings]
            SecurityData[Security Data<br/>Threats, Compliance]
        end
    end

    AutopilotCore --> IntuneCore
    AutopilotCore --> EntraCore
    IntuneCore --> EntraCore

    IntuneCore --> ComplianceService
    IntuneCore --> AppDelivery
    IntuneCore --> SecurityServices
    ComplianceService --> EntraCore

    HybridServices -.-> EntraCore
    HybridServices -.-> IntuneCore
    CoMgmtServices -.-> IntuneCore
    ProxyServices -.-> EntraCore

    DeviceData --> AutopilotCore
    UserData --> EntraCore
    PolicyData --> IntuneCore
    PolicyData --> ComplianceService
    AppData --> AppDelivery
    SecurityData --> SecurityServices

    ComplianceService -->|Compliance State| EntraCore
    SecurityServices -->|Risk Score| EntraCore
    SecurityServices -->|Threat Data| ComplianceService

    classDef coreClass fill:#1b5e20,stroke:#66bb6a,stroke-width:3px,color:#ffffff
    classDef secondaryClass fill:#0d47a1,stroke:#42a5f5,stroke-width:2px,color:#ffffff
    classDef conditionalClass fill:#bf360c,stroke:#ff7043,stroke-width:2px,stroke-dasharray:5 5,color:#ffffff
    classDef dataClass fill:#880e4f,stroke:#ec407a,stroke-width:1px,color:#ffffff

    class AutopilotCore,IntuneCore,EntraCore coreClass
    class ComplianceService,AppDelivery,SecurityServices secondaryClass
    class HybridServices,CoMgmtServices,ProxyServices conditionalClass
    class DeviceData,UserData,PolicyData,AppData,SecurityData dataClass
```

## Deployment Flow Diagrams

### User-Driven Mode: Phase 1 — Initial Boot and Network Connection

Duration approximately 0–60 seconds. Covers system initialisation, basic OS setup, and network connectivity establishment. Source: [Windows Autopilot user-driven mode — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/user-driven).

```mermaid
sequenceDiagram
    autonumber

    participant User as End User
    participant Device as Windows Device
    participant OOBE as OOBE Experience
    participant Network as Network Services

    rect rgb(26, 42, 58)
        Note over Device: Phase 1: Initial Boot and Network (0-60s)
        User->>Device: Power On Device
        Device->>Device: UEFI/BIOS POST
        Device->>Device: Boot Windows Setup
        Device->>OOBE: Launch Out-of-Box Experience

        OOBE->>User: Display Region Selection
        User->>OOBE: Select Region
        OOBE->>User: Display Keyboard Layout
        User->>OOBE: Select Keyboard

        OOBE->>User: Request Network Connection
        User->>OOBE: Connect to Network (Wi-Fi/Ethernet)
        Device->>Network: Establish Internet Connection
        Network->>Device: Connection Confirmed

        Device->>Network: Sync System Time (NTP - UDP 123)
        Network->>Device: Time Synchronised
        Device->>Network: Check Windows Updates
        Network->>Device: Critical Updates Available
        Device->>Device: Install Critical Updates (if required)

        Note over Device: Phase 1 Complete - Network Ready
    end
```

### User-Driven Mode: Phase 2 — Device Registration and Profile Discovery

Duration approximately 10–30 seconds. Covers hardware hash calculation, Autopilot service lookup, and profile retrieval. Source: [Windows Autopilot deployment profiles — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/profiles).

```mermaid
sequenceDiagram
    autonumber

    participant Device as Windows Device
    participant OOBE as OOBE Experience
    participant WAS as Autopilot Service
    participant User as End User

    rect rgb(58, 42, 26)
        Note over Device: Phase 2: Device Registration Check (10-30s)
        Device->>Device: Calculate Hardware Hash
        Device->>WAS: Send Device Identifier (Serial + Model + Hardware Hash)
        WAS->>WAS: Lookup Device Registration

        alt Device Registered for Autopilot
            WAS->>Device: Return Autopilot Profile (Mode, Join Type, Settings)
            Device->>OOBE: Apply Autopilot Configuration
            OOBE->>User: Display Organisation Branding
            Note over OOBE: Autopilot Profile Applied
        else Device Not Registered
            WAS->>Device: No Profile Found
            Device->>OOBE: Continue Standard OOBE
            Note over OOBE: Manual Setup Required
        end

        Note over WAS: Phase 2 Complete - Profile Retrieved
    end
```

### User-Driven Mode: Phase 3 — Authentication and Directory Join

Duration approximately 30–120 seconds. Covers user authentication, Azure AD join, and MDM enrolment. Source: [Windows Autopilot user-driven Microsoft Entra join — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/azure-ad-join-workflow).

```mermaid
sequenceDiagram
    autonumber

    participant User as End User
    participant OOBE as OOBE Experience
    participant EntraID as Microsoft Entra ID
    participant Device as Windows Device
    participant Intune as Microsoft Intune

    rect rgb(26, 58, 26)
        Note over Device: Phase 3: Authentication and Enrolment (30-120s)

        alt User-Driven Mode
            OOBE->>User: Display Organisation Sign-in Page
            User->>OOBE: Enter Credentials (user@domain.com)
            OOBE->>EntraID: Authenticate User
            EntraID->>EntraID: Validate Credentials

            alt MFA Required
                EntraID->>User: Request MFA Verification
                User->>EntraID: Provide MFA (Authenticator/SMS/FIDO2)
                EntraID->>EntraID: Validate MFA
            end

            EntraID->>OOBE: Authentication Success + Token

        else Self-Deploying Mode
            OOBE->>Device: Use Device Identity
            Device->>EntraID: Authenticate with Device Certificate (TPM)
            EntraID->>Device: Device Authentication Success
        end

        OOBE->>EntraID: Request Azure AD Join
        EntraID->>EntraID: Create Device Object
        EntraID->>Device: Azure AD Join Certificate
        Device->>Device: Store Certificate in TPM

        Device->>Intune: Initiate MDM Enrolment
        Intune->>Device: Send Enrolment Configuration
        Device->>Intune: Complete Enrolment
        Intune->>Device: Enrolment Success

        Note over Intune: Phase 3 Complete - Device Enrolled
    end
```

### Self-Deploying Mode Flow

Fully automated deployment with no user interaction. Requires TPM 2.0 for device attestation. Source: [Windows Autopilot self-deploying mode — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/self-deploying).

```mermaid
flowchart TD
    Boot([Device Powers On])
    Hash[Calculate Hardware Hash<br/>TPM 2.0 Device Attestation]
    Lookup[Autopilot Service Lookup<br/>Profile Retrieval]
    DeviceAuth[Device Authentication<br/>TPM Certificate - No User Input]
    EntraJoin[Microsoft Entra ID Join<br/>Device Identity Creation]
    MDMEnroll[Intune MDM Enrolment<br/>Management Registration]
    ESP[Enrollment Status Page<br/>All Apps and Policies]
    Ready([Device Ready - Kiosk or Shared])

    Boot --> Hash
    Hash --> Lookup
    Lookup --> DeviceAuth
    DeviceAuth --> EntraJoin
    EntraJoin --> MDMEnroll
    MDMEnroll --> ESP
    ESP --> Ready

    classDef deviceStep fill:#0d47a1,stroke:#64b5f6,stroke-width:2px,color:#ffffff
    classDef cloudStep fill:#4a148c,stroke:#ba68c8,stroke-width:2px,color:#ffffff
    classDef milestone fill:#1b5e20,stroke:#66bb6a,stroke-width:3px,color:#ffffff

    class Boot,Hash,Ready milestone
    class Lookup,DeviceAuth deviceStep
    class EntraJoin,MDMEnroll,ESP cloudStep
```

### Pre-Provisioning (White Glove) Flow

Two-phase deployment: technician phase pre-stages device; user phase completes personalisation. Source: [Windows Autopilot pre-provisioned deployment — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/pre-provision).

```mermaid
flowchart TD
    subgraph "Technician Phase (IT / OEM / Reseller)"
        TBoot([Device Boot - Technician])
        TProfile[Retrieve Autopilot Profile<br/>White Glove Enabled]
        TAuth[Technician or Device Authentication<br/>Entra ID Join]
        TEnroll[Intune MDM Enrolment]
        TESP[Device ESP Phase<br/>Policies, Certificates, Win32 Apps]
        TSeal[Reseal Device<br/>Return to OOBE State]
    end

    subgraph "User Phase (End User)"
        UBoot([Device Boot - End User])
        UAuth[User Authentication<br/>Credentials + MFA]
        UESP[User ESP Phase<br/>User Apps and Settings Only]
        UReady([Device Ready for Use])
    end

    TBoot --> TProfile
    TProfile --> TAuth
    TAuth --> TEnroll
    TEnroll --> TESP
    TESP --> TSeal
    TSeal --> UBoot
    UBoot --> UAuth
    UAuth --> UESP
    UESP --> UReady

    classDef techStep fill:#5d4037,stroke:#ff9800,stroke-width:2px,color:#ffffff
    classDef userStep fill:#0d47a1,stroke:#64b5f6,stroke-width:2px,color:#ffffff
    classDef milestone fill:#1b5e20,stroke:#66bb6a,stroke-width:3px,color:#ffffff

    class TBoot,TSeal,UBoot,UReady milestone
    class TProfile,TAuth,TEnroll,TESP techStep
    class UAuth,UESP userStep
```

## Service Boundary Diagrams

These diagrams clarify the distinct responsibilities of Windows Autopilot, Microsoft Entra ID, and Microsoft Intune. A common misconception is that Autopilot manages and configures devices — in reality Autopilot is a device discovery and redirection service with a scope of approximately 60–90 seconds. Source: [Windows Autopilot overview — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/overview).

### Service Responsibility Matrix

| Responsibility Area | Windows Autopilot | Microsoft Entra ID | Microsoft Intune |
|--------------------|-------------------|-------------------|-----------------|
| Device discovery | Primary owner | Not involved | Not involved |
| Device registration | Initiates only | Primary owner | Not involved |
| User authentication | Not involved | Primary owner | Not involved |
| Device authentication | Not involved | Primary owner | Not involved |
| Device join (Entra / Hybrid) | Not involved | Primary owner | Not involved |
| MDM enrolment | Not involved | Initiates only | Primary owner |
| Policy application | Not involved | Not involved | Primary owner |
| Security configuration | Not involved | Not involved | Primary owner |
| Application deployment | Not involved | Not involved | Primary owner |
| Compliance evaluation | Not involved | Stores results | Primary owner |
| Ongoing management | Not involved | Not involved | Primary owner |

### Complete Service Handoff Sequence

Depicts the full handoff chain from device boot through to ongoing Intune management. Source: [Windows Autopilot deployment — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/windows-autopilot).

```mermaid
flowchart TD
    subgraph "Device Boot and Discovery"
        DeviceBoot[Device Powers On<br/>OOBE Starts]
        HardwareHash[Calculate Hardware Hash<br/>Device Identification]
    end

    subgraph "Windows Autopilot Service (60-90 seconds)"
        AutopilotLookup[Device Registration Lookup<br/>Hardware Hash to Profile]
        ProfileAssignment[Profile Assignment<br/>Deployment Configuration]
        OOBECustomization[OOBE Customisation<br/>Branding and Experience]
        AutopilotHandoff[HANDOFF TO ENTRA ID<br/>Authentication Required]
    end

    subgraph "Microsoft Entra ID Service (30-120 seconds)"
        UserAuth[User Authentication<br/>Credentials and MFA]
        DeviceAuth[Device Authentication<br/>Certificate and Trust]
        AADJoin[Azure AD Join<br/>Device Identity Creation]
        ConditionalAccess[Conditional Access<br/>Policy Evaluation]
        EntraHandoff[HANDOFF TO INTUNE<br/>Management Required]
    end

    subgraph "Microsoft Intune Service (Ongoing)"
        MDMEnrollment[MDM Enrolment<br/>Management Registration]
        PolicyApplication[Policy Application<br/>Configuration and Security]
        AppDeployment[Application Deployment<br/>Software Installation]
        ComplianceEnforcement[Compliance Enforcement<br/>Ongoing Monitoring]
        OngoingManagement[Ongoing Management<br/>Lifecycle Operations]
    end

    DeviceBoot --> HardwareHash
    HardwareHash --> AutopilotLookup
    AutopilotLookup --> ProfileAssignment
    ProfileAssignment --> OOBECustomization
    OOBECustomization --> AutopilotHandoff

    AutopilotHandoff --> UserAuth
    UserAuth --> DeviceAuth
    DeviceAuth --> AADJoin
    AADJoin --> ConditionalAccess
    ConditionalAccess --> EntraHandoff

    EntraHandoff --> MDMEnrollment
    MDMEnrollment --> PolicyApplication
    PolicyApplication --> AppDeployment
    AppDeployment --> ComplianceEnforcement
    ComplianceEnforcement --> OngoingManagement

    classDef autopilotService fill:#ff9800,stroke:#f57c00,stroke-width:3px,color:#ffffff
    classDef entraService fill:#4a148c,stroke:#ba68c8,stroke-width:3px,color:#ffffff
    classDef intuneService fill:#0d47a1,stroke:#64b5f6,stroke-width:3px,color:#ffffff
    classDef handoff fill:#d32f2f,stroke:#ef5350,stroke-width:4px,color:#ffffff
    classDef device fill:#1b5e20,stroke:#66bb6a,stroke-width:2px,color:#ffffff

    class AutopilotLookup,ProfileAssignment,OOBECustomization autopilotService
    class UserAuth,DeviceAuth,AADJoin,ConditionalAccess entraService
    class MDMEnrollment,PolicyApplication,AppDeployment,ComplianceEnforcement,OngoingManagement intuneService
    class AutopilotHandoff,EntraHandoff handoff
    class DeviceBoot,HardwareHash device
```

### Service Communication Sequence (API-Level)

Depicts the API endpoint ownership for each service handoff. Source: [Windows Autopilot requirements — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/requirements).

```mermaid
sequenceDiagram
    autonumber

    participant Device as Windows Device
    participant Autopilot as Windows Autopilot Service
    participant Entra as Microsoft Entra ID
    participant Intune as Microsoft Intune

    Note over Device, Intune: Service Handoff Sequence

    rect rgb(255, 152, 0, 0.1)
        Note over Device, Autopilot: Windows Autopilot Scope (60-90 seconds)
        Device->>Autopilot: Hardware Hash + Device Info
        Autopilot->>Autopilot: Lookup Device Registration
        Autopilot->>Device: Return Deployment Profile
        Device->>Device: Apply OOBE Customisation
        Autopilot->>Device: HANDOFF - Redirect to login.microsoftonline.com
    end

    rect rgb(74, 20, 140, 0.1)
        Note over Device, Entra: Microsoft Entra ID Scope (30-120 seconds)
        Device->>Entra: Authentication Request (OAuth2)
        Entra->>Entra: Validate User Credentials + MFA
        Entra->>Entra: Evaluate Conditional Access Policies
        Entra->>Device: Authentication Success + Tokens
        Device->>Entra: Request Azure AD Join
        Entra->>Entra: Create Device Object + Certificate
        Entra->>Device: Device Certificate + Identity
        Entra->>Device: HANDOFF - Redirect to enrollment.manage.microsoft.com
    end

    rect rgb(13, 71, 161, 0.1)
        Note over Device, Intune: Microsoft Intune Scope (Ongoing)
        Device->>Intune: MDM Enrolment Request
        Intune->>Device: Enrolment Configuration
        Device->>Intune: Complete Enrolment
        Intune->>Device: Send Security Policies
        Intune->>Device: Send Configuration Profiles
        Intune->>Device: Deploy Applications
        Intune->>Device: Evaluate Compliance
        Note over Device, Intune: ONGOING - Continuous management and monitoring
    end
```

### Service Dependency Chain

```mermaid
graph TD
    subgraph "Service Dependency Chain"
        AutopilotService[Windows Autopilot<br/>Depends On: None<br/>Provides: Device discovery]
        EntraService[Microsoft Entra ID<br/>Depends On: Autopilot redirect<br/>Provides: Identity and auth]
        IntuneService[Microsoft Intune<br/>Depends On: Entra identity<br/>Provides: Device management]

        AutopilotService --> EntraService
        EntraService --> IntuneService
    end

    subgraph "Optional Services"
        OnPremAD[On-Premises AD<br/>Hybrid Join Support]
        ConfigMgr[Configuration Manager<br/>Co-Management Support]

        OnPremAD -.-> EntraService
        IntuneService -.-> ConfigMgr
    end

    classDef autopilot fill:#ff9800,stroke:#f57c00,stroke-width:2px,color:#ffffff
    classDef entra fill:#4a148c,stroke:#ba68c8,stroke-width:2px,color:#ffffff
    classDef intune fill:#0d47a1,stroke:#64b5f6,stroke-width:2px,color:#ffffff
    classDef optional fill:#757575,stroke:#bdbdbd,stroke-width:1px,stroke-dasharray:5 5,color:#ffffff

    class AutopilotService autopilot
    class EntraService entra
    class IntuneService intune
    class OnPremAD,ConfigMgr optional
```

### Deployment Timeline with Service Boundaries

```mermaid
gantt
    title Service Boundaries and Handoffs Timeline
    dateFormat mm:ss
    axisFormat %M:%S

    section Device Boot
    Power On and UEFI                  :device1, 00:00, 30s
    OOBE Launch                         :device2, after device1, 15s
    Hardware Hash Calculation           :device3, after device2, 15s

    section Windows Autopilot (60-90s)
    Device Registration Lookup          :crit, autopilot1, after device3, 10s
    Profile Discovery and Assignment    :crit, autopilot2, after autopilot1, 15s
    OOBE Customisation and Branding    :autopilot3, after autopilot2, 20s
    Redirect to Authentication          :milestone, handoff1, after autopilot3, 0s

    section Microsoft Entra ID (30-120s)
    User Credential Entry               :entra1, after handoff1, 15s
    User Authentication and MFA         :crit, entra2, after entra1, 30s
    Device Authentication               :entra3, after entra2, 15s
    Azure AD Join Process               :crit, entra4, after entra3, 20s
    Conditional Access Evaluation       :entra5, after entra4, 10s
    Redirect to Device Management       :milestone, handoff2, after entra5, 0s

    section Microsoft Intune (Ongoing)
    MDM Enrolment Initiation            :crit, intune1, after handoff2, 15s
    Security Policy Application         :intune2, after intune1, 120s
    Configuration Profile Deployment    :intune3, after intune2, 60s
    Application Installation            :intune4, after intune3, 600s
    Compliance Evaluation               :intune5, after intune4, 30s
    Ongoing Management Operations       :intune6, after intune5, 2160s
```

## Related Resources

- [Windows Autopilot overview — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/overview)
- [Windows Autopilot user-driven mode — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/user-driven)
- [Windows Autopilot self-deploying mode — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/self-deploying)
- [Windows Autopilot pre-provisioned deployment — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/pre-provision)
- [Windows Autopilot deployment profiles — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/profiles)
- [Microsoft Entra device management — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/devices/)
- [Microsoft Intune device management — Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/)
- [Windows Autopilot requirements — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/requirements)
