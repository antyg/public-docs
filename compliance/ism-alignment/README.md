---
title: "ISM Alignment"
status: "planned"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "explanation"
domain: "compliance"
---

# ISM Alignment

---

## Purpose

This folder contains alignment guides that map the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) controls to specific configurations across the Microsoft technology stack — Azure, Microsoft 365, Entra ID, Intune, Microsoft Defender, and Microsoft Sentinel.

The ISM is published by the [Australian Cyber Security Centre (ACSC)](https://www.cyber.gov.au/) and defines information security requirements for Australian Government systems. ISM controls use obligation language (Must, Should, Could) and are organised into topic-based control groups covering the full lifecycle of system security — from governance and physical security through to cloud services and cryptography.

This alignment guide answers **how** ISM control obligations are met using the Microsoft products commonly deployed in Australian government and enterprise environments. It does not reproduce ISM control text — practitioners must consult the [current ISM release](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) directly.

---

## Scope

### In Scope

- Mapping ISM controls to Microsoft technology capabilities, organised by ISM control topic group
- Identifying the specific product features, policy settings, and configuration parameters that satisfy each ISM control obligation
- Documenting the evidence artefacts produced by each configuration for use in system security plans and assessments
- Noting partial satisfaction and compensating controls where a single product does not fully address a control
- Covering Must-obligation controls as the primary focus; Should-obligation controls included where Microsoft technology provides direct implementation guidance

### Out of Scope

- ISM control text — see the [current ISM release](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) directly
- System security plan (SSP) authoring — this guide informs SSP evidence but does not replace it
- Non-Microsoft technology stacks
- Physical security controls and personnel security controls (no Microsoft technology alignment applicable)
- PROTECTED-level system design architecture — referenced where relevant, but detailed PROTECTED system design is out of scope for this seed

---

## ISM Control Structure

The ISM organises controls into topic groups. This alignment guide follows the same structure, focusing on topic groups where Microsoft technology provides direct implementation:

| ISM Topic Group | Microsoft Technology Coverage |
|----------------|------------------------------|
| **Guidelines for Cyber Security Roles** | Entra ID (role-based access), PIM, Conditional Access |
| **Guidelines for Information Security Documentation** | Microsoft 365 (SharePoint, Information Protection), Purview |
| **Guidelines for System Hardening** | Intune (configuration profiles), Defender for Endpoint (ASR, exploit protection), Azure Policy |
| **Guidelines for Authentication** | Entra ID, Conditional Access, MFA (FIDO2, Windows Hello for Business) |
| **Guidelines for Access Control** | Entra ID (RBAC, PIM), Conditional Access, Intune (device compliance) |
| **Guidelines for System Monitoring** | Microsoft Sentinel, Defender for Endpoint (EDR), Defender for Cloud (CSPM), Azure Monitor |
| **Guidelines for Software Development** | Azure DevOps, GitHub Advanced Security, Defender for Cloud (DevSecOps) |
| **Guidelines for Database Systems** | Defender for Cloud (database protection), Microsoft Purview (data classification) |
| **Guidelines for Email** | Microsoft 365 (Exchange Online Protection, Defender for Office 365) |
| **Guidelines for Networking** | Azure Firewall, Azure DDoS Protection, Azure Virtual Network, Private Endpoints |
| **Guidelines for Cloud Services** | Defender for Cloud (CSPM), Azure Policy, Microsoft 365 Secure Score |
| **Guidelines for Enterprise Mobility** | Intune (device enrolment, compliance policies, app protection) |
| **Guidelines for Cryptography** | Azure Key Vault, BitLocker (via Intune), Azure Disk Encryption |
| **Guidelines for Data Transfers** | Microsoft Purview (data loss prevention), Information Protection, Exchange Online mail flow rules |

---

## ISM Obligation Language

ISM controls use the following obligation terms, as defined in the [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism):

| Term | Meaning |
|------|---------|
| **Must** | Mandatory requirement — must be implemented to meet the control |
| **Should** | Recommended — should be implemented unless there is a documented reason not to |
| **Could** | Optional — may be implemented where applicable |

This alignment guide prioritises **Must** controls. **Should** controls are included where Microsoft technology provides a direct and commonly implemented solution.

---

## Relationship to Essential Eight

The ISM incorporates the [Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) as a baseline control set. ISM controls in the system hardening, authentication, and access control topic groups overlap substantially with Essential Eight strategies. Where an ISM control is directly addressed by an Essential Eight alignment guide, this folder references [`essential-eight-alignment/`](../essential-eight-alignment/README.md) rather than duplicating the guidance.

---

## Planned Alignment Guides

Content development will follow the structure below as alignment guides are authored:

> The subdirectories and files below are planned content that has not yet been created. The tree shows the intended structure for future authoring.

```
ism-alignment/
├── README.md                              ← This file (scope, ISM structure, methodology)
├── OUTLINE.md                             ← Detailed control-by-control mapping outline
├── system-hardening/
│   ├── os-hardening.md                    ← OS configuration, Intune profiles, ACSC hardening guides
│   ├── application-hardening.md           ← Application control, macro settings, browser hardening
│   └── office-hardening.md                ← Microsoft 365 hardening
├── authentication/
│   ├── mfa-controls.md                    ← Entra ID auth methods, phishing-resistant MFA
│   └── privileged-access.md              ← PIM, LAPS, privileged access workstations
├── access-control/
│   ├── rbac-alignment.md                  ← Entra ID RBAC, Conditional Access
│   └── identity-lifecycle.md              ← Provisioning, access reviews, offboarding
├── system-monitoring/
│   ├── audit-logging.md                   ← Sentinel, Defender, Azure Monitor log collection
│   └── intrusion-detection.md             ← Defender for Endpoint EDR, Sentinel analytics
├── cloud-services/
│   ├── cspm-alignment.md                  ← Defender for Cloud, Azure Policy, Secure Score
│   └── cloud-identity-controls.md         ← Entra ID tenant configuration, PIM for cloud
├── email/
│   └── email-security.md                  ← Defender for Office 365, EOP, DMARC/DKIM/SPF
├── enterprise-mobility/
│   └── mobile-device-management.md        ← Intune enrolment, compliance, app protection
└── cryptography/
    └── encryption-controls.md             ← BitLocker, Azure Disk Encryption, Key Vault
```

See [`OUTLINE.md`](./OUTLINE.md) for the detailed control mapping that will guide content development.

---

## Related Resources

### ACSC ISM Publications

- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)
- [ACSC Cloud Security Guidance](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/cloud-security)

### Australian Regulatory Frameworks

- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [Privacy Act 1988 — OAIC](https://www.oaic.gov.au/privacy/the-privacy-act)

### Framework and Methodology Reference

- [security/frameworks/essential-eight/](../../security/frameworks/essential-eight/README.md) — Essential Eight control definitions
- [compliance/essential-eight-alignment/](../essential-eight-alignment/README.md) — Essential Eight alignment guides (cross-referenced where ISM controls overlap)
- [compliance/alignment-bridge/](../alignment-bridge/README.md) — Alignment bridge concept and mapping methodology

---

**Australian English** is used throughout this documentation.
