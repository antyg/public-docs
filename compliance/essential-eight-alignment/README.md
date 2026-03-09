---
title: "Essential Eight Alignment"
status: "planned"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "explanation"
domain: "compliance"
---

# Essential Eight Alignment

---

## Purpose

This folder contains alignment guides that map the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) controls to specific configurations across the Microsoft technology stack — Azure, Microsoft 365, Entra ID, Intune, Microsoft Defender, and Microsoft Sentinel.

The Essential Eight defines **what** security outcomes must be achieved across eight mitigation strategies at three maturity levels. This alignment guide answers **how** those outcomes are achieved using the Microsoft products commonly deployed in Australian enterprise and government environments.

---

## Scope

### In Scope

- Mapping each of the eight mitigation strategies (at Maturity Levels 1, 2, and 3) to Microsoft technology capabilities
- Identifying the specific product features, policy settings, and configuration parameters that satisfy each Essential Eight control requirement
- Documenting the evidence artefacts produced by each configuration (compliance reports, audit logs, policy exports) for use in assessments
- Noting partial satisfaction and compensating controls where a single product does not fully address a control

### Out of Scope

- Framework control definitions themselves — see [`security/frameworks/essential-eight/`](../../security/frameworks/essential-eight/README.md)
- Product-specific technical reference — see `security/defender-for-endpoint/`, `security/defender-for-cloud/`, `identity/conditional-access/`, `endpoints/intune/`
- Non-Microsoft technology stacks (third-party endpoint agents, non-Azure cloud providers)
- Maturity Level 0 (non-compliance) — this guide covers achieving maturity levels, not documenting absence of controls

---

## Essential Eight Maturity Mapping Methodology

### Maturity Level Targeting

The [ACSC Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide) defines assessment criteria for each maturity level. This alignment guide targets:

- **ML1** — Partial coverage, addresses most common opportunistic threats
- **ML2** — Broad coverage, protects against most targeted threats (ACSC recommended minimum for Australian government)
- **ML3** — Complete coverage, addresses sophisticated adversaries

Each alignment guide section explicitly states which maturity level its guidance targets. Organisations should implement ML2 as a baseline before pursuing ML3.

### Control-to-Technology Mapping Structure

For each of the eight strategies, alignment content is structured as:

1. **Control intent** — The security outcome the strategy is designed to achieve (cited from ACSC publications)
2. **Microsoft capability** — The product feature(s) that address the control
3. **Configuration** — What must be configured (linking to Layer 3 product documentation)
4. **Evidence** — What auditable evidence the configuration produces
5. **Gaps and caveats** — Where partial satisfaction or additional controls are required

### Australian Regulatory Context

The Essential Eight is the mandated baseline for Australian Government entities under the [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/) and is referenced in the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism). Many state and territory government frameworks also mandate Essential Eight implementation. ML2 is the current ACSC-recommended minimum for government entities.

---

## The Eight Strategies — Technology Coverage Overview

| Strategy | Primary Microsoft Technologies |
|----------|-------------------------------|
| **1. Application Control** | Defender for Endpoint (application control policies), Intune (WDAC deployment), Defender for Cloud (adaptive application controls) |
| **2. Patch Applications** | Intune (app update policies), Azure Update Manager, Defender for Cloud (vulnerability assessment), Defender for Endpoint (software inventory) |
| **3. Configure Microsoft Office Macro Settings** | Intune (Attack Surface Reduction rules, Office policy), Microsoft 365 admin centre (cloud policy service), Defender for Endpoint (ASR reporting) |
| **4. User Application Hardening** | Intune (configuration profiles, ASR rules), Defender for Endpoint (web protection, exploit protection), Microsoft Edge policy |
| **5. Restrict Administrative Privileges** | Entra ID (Privileged Identity Management, role assignments), Conditional Access (privileged access policies), Intune (local admin management) |
| **6. Patch Operating Systems** | Azure Update Manager, Intune (Windows Update for Business), Defender for Cloud (OS vulnerability assessment), Defender for Endpoint (OS inventory) |
| **7. Multi-Factor Authentication** | Entra ID (authentication method policies), Conditional Access (MFA enforcement), Microsoft Authenticator, FIDO2 security keys |
| **8. Regular Backups** | Azure Backup, Microsoft 365 Backup, Azure Site Recovery, Intune (data protection policies for mobile) |

---

## Planned Alignment Guides

Content development will follow the structure below as alignment guides are authored:

> The subdirectories and files below are planned content that has not yet been created. The tree shows the intended structure for future authoring.

```
essential-eight-alignment/
├── README.md                          ← This file (scope, methodology, overview)
├── OUTLINE.md                         ← Detailed control-by-control mapping outline
├── 01-application-control/
│   ├── ml1-alignment.md
│   ├── ml2-alignment.md
│   └── ml3-alignment.md
├── 02-patch-applications/
│   └── ...
├── 03-office-macro-settings/
│   └── ...
├── 04-user-application-hardening/
│   └── ...
├── 05-restrict-admin-privileges/
│   └── ...
├── 06-patch-operating-systems/
│   └── ...
├── 07-multi-factor-authentication/
│   └── ...
└── 08-regular-backups/
    └── ...
```

See [`OUTLINE.md`](./OUTLINE.md) for the detailed control mapping that will guide content development.

---

## Related Resources

### ACSC Essential Eight

- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)
- [Essential Eight Explained](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-explained)

### Australian Regulatory Frameworks

- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)

### Framework Reference

- [security/frameworks/essential-eight/](../../security/frameworks/essential-eight/README.md) — Essential Eight control definitions
- [compliance/alignment-bridge/](../alignment-bridge/README.md) — Alignment bridge concept and methodology

---

**Australian English** is used throughout this documentation.
