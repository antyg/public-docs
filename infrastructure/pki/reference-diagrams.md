---
title: "PKI Modernisation — Architecture Diagrams"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "reference"
domain: "infrastructure"
---

# PKI Modernisation — Architecture Diagrams

## CA Hierarchy and Trust Model

```mermaid
graph TD
    subgraph Azure["Azure (Australia East)"]
        ROOT["Company-Root-CA<br/>Offline / Air-gapped<br/>RSA 4096 / SHA-256<br/>Validity: 20 years<br/>Key: Azure Key Vault HSM"]
        KV["Azure Key Vault<br/>Premium SKU / HSM<br/>FIPS 140-2 Level 3"]
        ROOT -.->|"key stored in"| KV
    end

    subgraph OnPrem["On-Premises / Azure (Issuing Tier)"]
        ICA1["Company-Issuing-CA-01<br/>Active-Active pair<br/>RSA 4096 / SHA-256<br/>Validity: 5 years"]
        ICA2["Company-Issuing-CA-02<br/>Active-Active pair<br/>RSA 4096 / SHA-256<br/>Validity: 5 years"]
    end

    subgraph EndEntities["End-Entity Certificates"]
        COMP["Computer<br/>Authentication"]
        USER["User<br/>Authentication"]
        SERVER["Web / Server<br/>TLS"]
        CODE["Code<br/>Signing"]
        OCSP["OCSP Responder<br/>Signing"]
    end

    ROOT -->|"signs"| ICA1
    ROOT -->|"signs"| ICA2
    ICA1 -->|"issues"| COMP
    ICA1 -->|"issues"| USER
    ICA2 -->|"issues"| SERVER
    ICA2 -->|"issues"| CODE
    ICA1 -->|"issues"| OCSP
```

---

## Network Topology

```mermaid
graph LR
    subgraph AUE["Azure Australia East (Primary)"]
        direction TB
        APCA["Azure Private CA"]
        AKV["Azure Key Vault HSM"]
        BLOB["Azure Blob Storage<br/>(CRL / AIA)"]
        AGW["Application Gateway<br/>(NDES / SCEP)"]
        OCSP_AZ["OCSP Responder"]
    end

    subgraph AUSE["Azure Australia Southeast (DR)"]
        direction TB
        BLOB_DR["Azure Blob Storage<br/>(CRL / AIA — replica)"]
        OCSP_DR["OCSP Responder (DR)"]
    end

    subgraph ONPREM["On-Premises"]
        direction TB
        ICA["Issuing CA 01/02<br/>Windows Server 2022"]
        NDES["NDES Server<br/>(SCEP endpoint)"]
        AD["Active Directory<br/>(templates / GPO)"]
        NSC["NetScaler ADC<br/>(SSL offload)"]
        F5["F5 BIG-IP<br/>(SSL profiles)"]
    end

    subgraph CLIENTS["Clients / Devices"]
        WIN["Windows<br/>Autoenrollment"]
        MOB["Mobile (Intune<br/>/ SCEP)"]
        IOT["IoT Devices<br/>(EST)"]
        SRV["Servers<br/>(Manual / API)"]
    end

    ONPREM <-->|"ExpressRoute 50 Mbps<br/>VPN 10 Mbps (backup)"| AUE
    AUE <-->|"Geo-replication"| AUSE
    CLIENTS -->|"TCP 443 SCEP"| AGW
    CLIENTS -->|"TCP 443 OCSP"| OCSP_AZ
    CLIENTS -->|"TCP 80 CRL"| BLOB
    ICA -->|"Publish CRL"| BLOB
    ICA -->|"RPC"| NDES
    WIN -->|"GPO / RPC"| AD
```

---

## Certificate Enrollment Flow — Windows Autoenrollment

```mermaid
sequenceDiagram
    participant C as Windows Client
    participant AD as Active Directory
    participant CA as Issuing CA
    participant CRL as CRL/OCSP

    C->>AD: Query certificate templates (LDAP 389)
    AD-->>C: Return template list + permissions
    C->>C: Evaluate: renewal needed?
    C->>CA: Certificate request (RPC/DCOM)
    CA->>CA: Validate request against template policy
    CA->>CA: Sign certificate
    CA-->>C: Issued certificate
    C->>C: Install certificate in store
    C->>CRL: Verify chain (OCSP/CRL)
    CRL-->>C: Good / Revoked / Unknown
```

---

## Certificate Enrollment Flow — SCEP (NDES / Intune)

```mermaid
sequenceDiagram
    participant D as Mobile Device / IoT
    participant INT as Intune
    participant NDES as NDES Server
    participant CA as Issuing CA

    INT->>D: Push SCEP profile
    D->>NDES: GetCACert (HTTP GET)
    NDES-->>D: CA certificate chain
    D->>D: Generate key pair (CSR)
    D->>NDES: PKIOperation: PKCSReq (HTTPS POST)
    NDES->>CA: Submit certificate request (RPC)
    CA->>CA: Validate, sign certificate
    CA-->>NDES: Issued certificate
    NDES-->>D: PKIOperation: CertRep (issued cert)
    D->>D: Install certificate
```

---

## Certificate Enrollment Flow — EST (IoT / Linux)

```mermaid
sequenceDiagram
    participant C as EST Client (IoT / Linux)
    participant EST as EST Server
    participant CA as Issuing CA

    C->>EST: GET /.well-known/est/cacerts (TLS)
    EST-->>C: CA certificate bundle (PKCS#7)
    C->>C: Generate key pair and CSR
    C->>EST: POST /.well-known/est/simpleenroll (TLS + client auth)
    EST->>CA: Forward CSR
    CA-->>EST: Signed certificate
    EST-->>C: Certificate (PKCS#7)
    C->>C: Extract and install certificate
```

---

## Migration Sequence

```mermaid
sequenceDiagram
    participant PMO as Project Team
    participant PILOT as Pilot Devices (10%)
    participant W1 as Wave 1 Devices (40%)
    participant W2 as Wave 2 Devices (50%)
    participant LEGACY as Legacy CA
    participant NEW as New PKI

    PMO->>PILOT: Deploy new CA trust + SCEP profile
    PILOT->>NEW: Enroll new certificates
    PMO->>PMO: Validate pilot (>99% success)
    PMO->>W1: Deploy new CA trust + SCEP profile
    W1->>NEW: Enroll new certificates
    PMO->>PMO: Validate Wave 1 (>99% success)
    PMO->>W2: Deploy new CA trust + SCEP profile
    W2->>NEW: Enroll new certificates
    PMO->>PMO: Validate Wave 2 (>99% success)
    PMO->>LEGACY: Revoke legacy CA certificate
    LEGACY->>LEGACY: Publish final CRL
    PMO->>LEGACY: Take legacy CA offline
    PMO->>PMO: Project closure
```

---

## Change Control Flow

```mermaid
flowchart LR
    subgraph Standard["Standard Change Control"]
        REQ[Change Request] --> REV[Technical Review]
        REV --> CAB[CAB Assessment]
        CAB --> APP{Approved?}
        APP -->|Yes| SCHED[Schedule Change]
        APP -->|No| REJ[Reject / Revise]
        SCHED --> IMPL[Implement]
        IMPL --> VAL[Validate]
        VAL --> CLOSE[Close Change]
        REJ --> REQ
    end

    subgraph Emergency["Emergency Change"]
        EMER[Emergency Request] --> EAPP[Emergency Approval]
        EAPP --> EIMPL[Emergency Implementation]
        EIMPL --> RETRO[Retrospective CAB]
    end
```

---

## Project Communication Timeline

```mermaid
timeline
    title Communication Milestones

    Week 0  : Project Launch
            : All-hands kickoff
            : Stakeholder briefing

    Week 2  : Foundation Complete
            : Architecture published
            : Security approval communicated

    Week 4  : Core Infrastructure Ready
            : Integration timeline shared
            : Training schedule published

    Week 6  : Pilot Group Notification
            : Pilot participants briefed
            : Support channels activated

    Week 8  : Production Migration Schedule
            : Wave assignments communicated
            : Business continuity plans shared

    Week 10 : Go-Live Preparation
            : Final readiness checklist
            : Cutover timeline confirmed

    Week 11 : Project Completion
            : Success announcement
            : Lessons learned published
```

---

## Certificate Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> Requested: CSR submitted
    Requested --> Pending: Manual approval required
    Requested --> Issued: Auto-approved
    Pending --> Issued: CA Administrator approves
    Pending --> Denied: CA Administrator denies
    Issued --> Valid: Certificate installed
    Valid --> Expired: Validity period elapsed
    Valid --> Revoked: Explicitly revoked
    Valid --> Renewed: Renewal request approved
    Renewed --> Valid: New certificate installed
    Revoked --> [*]: Published to CRL / OCSP
    Expired --> [*]: Archived
    Denied --> [*]
```

---

## Azure Resource Architecture

```mermaid
graph TB
    subgraph AUE["Australia East — Primary"]
        direction TB
        subgraph VNET["PKI Virtual Network (10.100.0.0/16)"]
            subgraph CASUB["CA Subnet (10.100.1.0/24)"]
                VM1["Issuing CA 01<br/>D4s_v5"]
                VM2["Issuing CA 02<br/>D4s_v5"]
                VM3["NDES Server<br/>D4s_v5"]
                VM4["OCSP Responder<br/>D4s_v5"]
            end
            subgraph GWSUB["Gateway Subnet"]
                ER["ExpressRoute GW"]
                VPN["VPN GW"]
            end
        end
        KV["Key Vault Premium<br/>(HSM-backed)"]
        BLOB["Blob Storage<br/>(CRL / AIA)"]
        APCA["Azure Private CA"]
        AGW["Application Gateway<br/>(NDES front-end)"]
    end

    subgraph ONPREM["On-Premises"]
        AD2["Active Directory"]
        CLIENTS2["Client Devices"]
    end

    ONPREM <-->|"ExpressRoute"| ER
    ONPREM <-->|"VPN (backup)"| VPN
    CASUB <-->|"Private Endpoint"| KV
    VM1 & VM2 -->|"Publish CRL"| BLOB
    CLIENTS2 -->|"TCP 443"| AGW
    AGW -->|"Forward"| VM3
```

---

## Related Resources

- [Microsoft Learn — Azure Private CA Architecture](https://learn.microsoft.com/en-us/azure/private-ca/overview)
- [Microsoft Learn — AD CS Design Guide](https://learn.microsoft.com/en-us/windows-server/security/certificates-and-public-key-infrastructure-pki/certification-authority-role)
- [RFC 5280 — Internet X.509 PKI Certificate and CRL Profile](https://datatracker.ietf.org/doc/html/rfc5280)
- [RFC 6960 — X.509 Internet PKI Online Certificate Status Protocol (OCSP)](https://datatracker.ietf.org/doc/html/rfc6960)
- [RFC 7030 — Enrollment over Secure Transport (EST)](https://datatracker.ietf.org/doc/html/rfc7030)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Mermaid Diagram Documentation](https://mermaid.js.org/intro/)

---

Navigation: [PKI README](README.md) | [Parent: infrastructure/](../README.md)
