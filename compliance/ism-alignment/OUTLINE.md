---
title: "ISM Alignment — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "readme"
domain: "compliance"
---

# ISM Alignment — Content Outline

---

## Purpose

This outline maps ISM control topic groups to Microsoft technology documentation and ACSC publications that will underpin ISM alignment guide content. It serves as the authoring blueprint for the per-topic alignment guides to be developed under this folder.

ISM controls are referenced by topic group and control identifier (e.g., ISM-1173). Practitioners must consult the [current ISM release](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) directly for authoritative control text — this outline records the mapping intent, not the control text itself.

---

## System Hardening

### OS Hardening

**ISM Topic**: Guidelines for System Hardening — Operating Systems

| Field | Detail |
|-------|--------|
| **Control focus** | Operating system configuration hardened; standard user accounts used for standard tasks; auto-run and autoplay disabled; host-based firewall enabled |
| **Primary technology** | Intune (Windows configuration profiles, security baselines), Defender for Endpoint (attack surface reduction) |
| **Secondary technology** | Azure Policy (guest configuration for Azure VMs), Defender for Cloud (OS recommendations) |
| **Layer 3 reference** | `endpoints/intune/` (security baselines, configuration profiles), `security/defender-for-endpoint/` (ASR, exploit protection), `security/defender-for-cloud/` (OS hardening recommendations) |
| **Evidence artefact** | Intune device configuration compliance report, Defender for Endpoint device compliance status, Defender for Cloud OS recommendations report |
| **ACSC hardening guides** | ACSC publishes hardening guides for Windows 10/11 and Windows Server — [ACSC hardening guides](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration) should be used as the control decomposition source alongside ISM control text |
| **Caveats** | Intune security baselines implement Microsoft-recommended defaults which closely align with ACSC hardening guides but require gap analysis against ISM-specific requirements |

### Application Hardening

**ISM Topic**: Guidelines for System Hardening — Applications

| Field | Detail |
|-------|--------|
| **Control focus** | Applications hardened; unnecessary features disabled; application control enforced; software registered to the organisation |
| **Primary technology** | Defender for Endpoint (WDAC application control, ASR rules), Intune (WDAC policy deployment, app configuration) |
| **Layer 3 reference** | `security/defender-for-endpoint/` (application control, ASR), `endpoints/intune/` (app deployment, configuration) |
| **Evidence artefact** | WDAC event log (enforcement events), Intune app compliance report, Defender for Endpoint device control report |
| **Cross-reference** | Essential Eight Strategy 1 (Application Control) — see [`essential-eight-alignment/OUTLINE.md`](../essential-eight-alignment/OUTLINE.md) |

### Microsoft 365 Hardening

**ISM Topic**: Guidelines for System Hardening — Enterprise Mobility and Online Services

| Field | Detail |
|-------|--------|
| **Control focus** | Unused Microsoft 365 services disabled; tenant configuration hardened; external sharing restricted; legacy authentication blocked |
| **Primary technology** | Microsoft 365 admin centre (service configuration), Entra ID (legacy authentication block), Conditional Access (authentication policies) |
| **Layer 3 reference** | `identity/entra-id/` (tenant configuration), `identity/conditional-access/` (legacy auth block policy) |
| **Evidence artefact** | Entra ID Conditional Access policy export (legacy auth block), Microsoft Secure Score recommendations report |
| **Caveats** | Legacy authentication blocking may impact line-of-business applications using basic auth — requires application inventory and migration planning before enforcement |

---

## Authentication

### Multi-Factor Authentication Controls

**ISM Topic**: Guidelines for Authentication

| Field | Detail |
|-------|--------|
| **Control focus** | MFA required for remote access, privileged accounts, and internet-facing services; phishing-resistant MFA required for privileged users (Must); phishing-resistant MFA for all users at higher classification |
| **Primary technology** | Entra ID (authentication methods policy), Conditional Access (MFA enforcement, authentication strength), FIDO2 security keys, Windows Hello for Business |
| **Layer 3 reference** | `identity/mfa/`, `identity/conditional-access/`, `identity/entra-id/` |
| **Evidence artefact** | Authentication strength policy export, Conditional Access policy export, Entra ID MFA registration report, sign-in log (authentication method per session) |
| **Cross-reference** | Essential Eight Strategy 7 (Multi-Factor Authentication) — see [`essential-eight-alignment/OUTLINE.md`](../essential-eight-alignment/OUTLINE.md) |
| **Caveats** | Microsoft Authenticator push notification does not meet phishing-resistant criteria; FIDO2 and Windows Hello for Business do — policy must distinguish by user population and account type |

### Privileged Access Controls

**ISM Topic**: Guidelines for Authentication — Privileged Access

| Field | Detail |
|-------|--------|
| **Control focus** | Privileged accounts separate from standard accounts; privileged access workstations (PAWs) or equivalent; credential storage hardened; local admin accounts managed |
| **Primary technology** | Entra ID PIM (just-in-time privileged access), Intune (LAPS — Local Administrator Password Solution), Conditional Access (privileged access policy) |
| **Layer 3 reference** | `identity/entra-id/` (PIM, role management), `identity/conditional-access/`, `endpoints/intune/` (LAPS) |
| **Evidence artefact** | PIM role activation audit log, LAPS configuration report, Conditional Access sign-in log for privileged accounts |
| **Cross-reference** | Essential Eight Strategy 5 (Restrict Administrative Privileges) |
| **Caveats** | PIM requires Entra ID P2; LAPS for Entra ID-joined devices requires Windows 11 22H2 or Windows 10 22H2 with April 2023 update |

---

## Access Control

### Role-Based Access Control

**ISM Topic**: Guidelines for Access Control

| Field | Detail |
|-------|--------|
| **Control focus** | Access to systems based on least privilege; role-based access control implemented; access reviewed regularly |
| **Primary technology** | Entra ID (RBAC role assignments, access reviews), Conditional Access (device compliance enforcement) |
| **Layer 3 reference** | `identity/entra-id/` (role assignments, access reviews), `identity/conditional-access/` |
| **Evidence artefact** | Entra ID access review completion report, role assignment export, Conditional Access policy compliance report |
| **Caveats** | Entra ID access reviews require Entra ID Governance (P2 or Governance add-on) licensing |

### Identity Lifecycle Management

**ISM Topic**: Guidelines for Access Control — Identity Management

| Field | Detail |
|-------|--------|
| **Control focus** | User accounts created, modified, and deprovisioned following documented process; orphaned accounts removed; accounts validated regularly |
| **Primary technology** | Entra ID (lifecycle workflows, HR-driven provisioning), Entra ID Governance (access reviews, entitlement management) |
| **Layer 3 reference** | `identity/entra-id/` (user lifecycle, provisioning) |
| **Evidence artefact** | Entra ID lifecycle workflow audit log, access review completion report, stale account report (last sign-in date) |

---

## System Monitoring

### Audit Logging and Log Management

**ISM Topic**: Guidelines for System Monitoring — Event Logging

| Field | Detail |
|-------|--------|
| **Control focus** | Event logs collected and retained; logs protected from modification; log review procedures in place; central logging implemented |
| **Primary technology** | Microsoft Sentinel (log collection, SIEM), Azure Monitor (diagnostic settings), Defender for Endpoint (device event logs forwarded) |
| **Secondary technology** | Defender for Cloud (security event collection), Entra ID (sign-in and audit logs to Sentinel) |
| **Layer 3 reference** | `security/sentinel/`, `security/defender-for-cloud/` (log collection), `security/defender-for-endpoint/` (device telemetry) |
| **Evidence artefact** | Sentinel workspace data connector status report, Log Analytics retention policy configuration, Azure Monitor diagnostic settings export |
| **Caveats** | Log retention requirements under ISM vary by system classification; Sentinel workspace retention configuration must align with ISM-specified minimum retention periods |

### Intrusion Detection and Response

**ISM Topic**: Guidelines for System Monitoring — Intrusion Detection and Prevention

| Field | Detail |
|-------|--------|
| **Control focus** | Intrusion detection capability implemented; alerts reviewed; incident response procedures in place |
| **Primary technology** | Defender for Endpoint (EDR, behavioural detection), Microsoft Sentinel (analytics rules, incident management), Defender for Cloud (cloud threat detection) |
| **Layer 3 reference** | `security/defender-for-endpoint/`, `security/sentinel/`, `security/defender-for-cloud/` |
| **Evidence artefact** | Defender for Endpoint alert queue, Sentinel incident report, Defender for Cloud security alert export |

---

## Cloud Services

### Cloud Security Posture Management

**ISM Topic**: Guidelines for Cloud Services

| Field | Detail |
|-------|--------|
| **Control focus** | Cloud services assessed before use; security responsibilities understood; configuration monitored continuously; shared responsibility model documented |
| **Primary technology** | Defender for Cloud (CSPM, Secure Score, regulatory compliance), Azure Policy (configuration governance) |
| **Layer 3 reference** | `security/defender-for-cloud/` (CSPM, regulatory compliance dashboard, Azure Policy integration) |
| **Evidence artefact** | Defender for Cloud regulatory compliance report (ISM or custom standard), Secure Score history, Azure Policy compliance report |
| **Caveats** | ISM does not currently have a built-in regulatory compliance standard in Defender for Cloud; a custom assessment must be created mapping ISM controls to Defender for Cloud recommendations |

### Cloud Identity and Access

**ISM Topic**: Guidelines for Cloud Services — Identity

| Field | Detail |
|-------|--------|
| **Control focus** | Cloud administrator accounts protected; break-glass (emergency access) accounts maintained and monitored; tenant configuration reviewed |
| **Primary technology** | Entra ID (emergency access accounts, PIM for global admin), Conditional Access (admin MFA enforcement), Sentinel (emergency access account monitoring) |
| **Layer 3 reference** | `identity/entra-id/`, `identity/conditional-access/`, `security/sentinel/` |
| **Evidence artefact** | Emergency access account sign-in alert (Sentinel), global admin role assignment report, Conditional Access admin policy export |

---

## Email Security

**ISM Topic**: Guidelines for Email

| Field | Detail |
|-------|--------|
| **Control focus** | Email filtering implemented; DMARC, DKIM, and SPF configured; malicious email attachments and links blocked; email encryption available |
| **Primary technology** | Microsoft Defender for Office 365 (anti-phishing, safe attachments, safe links), Exchange Online Protection (EOP), Microsoft Purview Message Encryption |
| **Layer 3 reference** | (email security documentation — to be seeded in future) |
| **Evidence artefact** | Defender for Office 365 threat protection status report, DMARC/DKIM/SPF record publication (verified via DNS), EOP anti-spam policy export |
| **Caveats** | DMARC enforcement (p=reject or p=quarantine) must be validated before enabling — domains with misconfigured SPF/DKIM will lose legitimate email if DMARC is enforced prematurely |

---

## Enterprise Mobility

**ISM Topic**: Guidelines for Enterprise Mobility

| Field | Detail |
|-------|--------|
| **Control focus** | Mobile devices managed; device encryption enforced; remote wipe capability; application management for corporate data |
| **Primary technology** | Intune (device enrolment, compliance policies, configuration profiles, app protection policies — MAM) |
| **Layer 3 reference** | `endpoints/intune/` (device compliance, app protection policies) |
| **Evidence artefact** | Intune device compliance report, app protection policy assignment report, remote wipe audit log |
| **Caveats** | BYOD scenarios use MAM (app protection without enrolment); corporate-owned devices use full MDM enrolment — ISM controls apply differently depending on device ownership model and data classification |

---

## Cryptography

**ISM Topic**: Guidelines for Cryptography

| Field | Detail |
|-------|--------|
| **Control focus** | Data encrypted at rest and in transit; encryption algorithms approved by ACSC; key management implemented; TLS version enforced |
| **Primary technology** | Azure Disk Encryption (VM disk encryption), BitLocker via Intune (endpoint disk encryption), Azure Key Vault (key management), Azure App Service (TLS enforcement) |
| **Layer 3 reference** | `endpoints/intune/` (BitLocker policy), `infrastructure/` (Azure Disk Encryption, Key Vault) |
| **Evidence artefact** | Intune BitLocker encryption status report, Azure Key Vault key rotation audit log, Azure Policy TLS enforcement compliance report |
| **Caveats** | ACSC approves specific cryptographic algorithms via the ISM — verify that Azure and Microsoft 365 cipher suite configurations meet the current ISM-approved algorithm list; ACSC approved algorithms are published in the ISM cryptography topic |

---

## Data Transfers

**ISM Topic**: Guidelines for Data Transfers

| Field | Detail |
|-------|--------|
| **Control focus** | Data transfers controlled and monitored; sensitive data not transferred via unapproved channels; DLP controls implemented |
| **Primary technology** | Microsoft Purview (Data Loss Prevention, Information Protection), Exchange Online (mail flow rules for sensitive data), Defender for Cloud Apps (shadow IT, cloud app control) |
| **Layer 3 reference** | (Purview documentation — to be seeded in future) |
| **Evidence artefact** | Purview DLP policy match report, Information Protection sensitivity label usage report, Defender for Cloud Apps policy alert report |

---

## Citation Sources for Content Development

### ACSC ISM Publications

- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) — Primary control authority; download current release for control text
- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — Overlapping controls for E8 strategies
- [ACSC Hardening Guides](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration) — Windows 10, Windows 11, Windows Server, Microsoft 365 hardening guides aligned to ISM
- [ACSC Cloud Security Guidance](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/cloud-security) — Cloud services-specific ISM guidance

### Microsoft Technology Documentation (Layer 3)

- `security/defender-for-endpoint/` — EDR, application control, ASR, web protection, vulnerability management
- `security/defender-for-cloud/` — CSPM, workload protection, regulatory compliance dashboard
- `security/sentinel/` — SIEM, log collection, analytics rules, incident management
- `security/identity-protection/` — Entra ID Protection, risk-based Conditional Access
- `identity/entra-id/` — Identity platform, role management, PIM, lifecycle workflows
- `identity/conditional-access/` — Access policies, MFA enforcement, device compliance, authentication strength
- `identity/mfa/` — Authentication methods, FIDO2, Windows Hello for Business, certificate-based auth
- `endpoints/intune/` — Device compliance, configuration profiles, LAPS, update rings, app protection, BitLocker

### Australian Regulatory Context

- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/) — Government entity obligations, classification scheme
- [Privacy Act 1988 — OAIC](https://www.oaic.gov.au/privacy/the-privacy-act) — Privacy obligations for systems handling personal information
- [Notifiable Data Breaches scheme](https://www.oaic.gov.au/privacy/notifiable-data-breaches) — Breach notification obligations under the Privacy Act

---

**Australian English** is used throughout this documentation.
