---
title: "Essential Eight Control-Technology Mapping"
status: "draft"
last_updated: "2026-03-23"
audience: "Compliance Officers"
document_type: "reference"
domain: "compliance"
---

# Essential Eight Control-Technology Mapping

---

## Scope

This document maps each of the eight ACSC Essential Eight mitigation strategies to the Microsoft technologies that address them, across Maturity Levels 1, 2, and 3. It covers:

- Per-strategy technology mapping (control to primary Microsoft product and configuration area)
- Shared technology platform coverage
- Licensing requirements by maturity level
- Infrastructure prerequisites (Active Directory, Entra ID, network, storage)

This document does not cover:

- Control-to-control dependencies or implementation sequencing — see [`../../security/frameworks/essential-eight/reference-cross-reference-matrix.md`](../../security/frameworks/essential-eight/reference-cross-reference-matrix.md)
- Maturity level definitions — see [`../../security/frameworks/essential-eight/reference-maturity-model.md`](../../security/frameworks/essential-eight/reference-maturity-model.md)
- Term definitions — see [`../../security/frameworks/essential-eight/reference-glossary.md`](../../security/frameworks/essential-eight/reference-glossary.md)
- Step-by-step configuration procedures — see how-to guides in product domains

For the parent alignment guide, see [`../essential-eight-alignment/README.md`](../essential-eight-alignment/README.md).

ACSC control definitions and maturity level requirements are published at [cyber.gov.au](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). This document does not reproduce that material.

---

## Per-Strategy Technology Mapping

The following table maps each Essential Eight mitigation strategy to its primary Microsoft technology and the relevant configuration area at each maturity level.

| Strategy | ML1 — Primary Technology | ML1 — Configuration Area | ML2 — Primary Technology | ML2 — Configuration Area | ML3 — Primary Technology | ML3 — Configuration Area |
|---|---|---|---|---|---|---|
| **1. Application Control** | Windows Defender Application Control (WDAC) or AppLocker | Allowlist policy deployment via GPO or Intune | WDAC or AppLocker with centralised management | Policy management and validated application inventory | Microsoft Defender for Endpoint (MDE) | EDR integration, behavioural blocking |
| **2. Patch Applications** | Windows Server Update Services (WSUS) or manual patching | Update approval and deployment schedules | WSUS or Microsoft Intune | Automated deployment rings, compliance reporting | Intune with advanced automation | Sub-48-hour deployment pipelines, exception management |
| **3. Configure Microsoft Office Macro Settings** | Group Policy Objects (GPO) or Intune | Office macro policy settings | GPO or Intune with monitoring | Macro execution logging, policy compliance reporting | GPO or Intune with antivirus integration | Trusted Locations enforcement, macro antivirus scanning |
| **4. User Application Hardening** | GPO or Intune | Browser security policies, Flash and Java blocking | GPO or Intune with web filtering | Web content filtering, enhanced browser configuration | GPO or Intune with Microsoft Defender SmartScreen | Advanced web protection, exploit guard policies |
| **5. Restrict Administrative Privileges** | Active Directory (AD) groups, just-in-time (JIT) access | Privileged group membership, role separation | Microsoft Entra Privileged Identity Management (PIM) — basic | JIT activation, privileged access review | Microsoft Entra PIM — enterprise, Privileged Access Management (PAM) solution | Access reviews, identity governance, PAW enforcement |
| **6. Patch Operating Systems** | WSUS or Windows Update | Update approval, deployment scheduling | WSUS or Intune | Automated deployment rings, OS compliance baselines | Intune with advanced automation | Sub-48-hour deployment pipelines, Windows Autopatch |
| **7. Multi-Factor Authentication** | Microsoft Entra ID (basic MFA) | Per-user MFA enablement | Microsoft Entra ID with Conditional Access | Conditional Access policies, MFA for internet-facing services | Microsoft Entra ID with FIDO2/WebAuthn | Phishing-resistant authenticators, hardware security keys |
| **8. Regular Backups** | Windows Server Backup or basic backup solution | Backup schedule, quarterly restore testing | Azure Backup or enterprise backup solution | Offsite storage, geographic redundancy, quarterly testing | Enterprise backup with immutable storage | Immutable vaults, air-gapped copies, lifecycle management |

---

## Shared Technology Platforms

Several Microsoft technologies serve multiple Essential Eight strategies simultaneously. The table below identifies shared platforms, the strategies they address, prerequisites, and constraints.

| Platform | Strategies Addressed | Prerequisite | Constraint |
|---|---|---|---|
| **Group Policy Objects (GPO)** | 1, 2, 3, 4, 6 | Active Directory Domain Services | On-premises or hybrid joined devices only; no cloud-native coverage |
| **Microsoft Intune** | 1, 2, 3, 4, 6 | Microsoft 365 Business Premium, E3, or E5; or Intune standalone licence | Requires internet connectivity for policy application; device enrolment required |
| **Microsoft Defender for Endpoint (MDE)** | 1 (ML3), 4 (optional) | Microsoft 365 E5 or MDE Plan 2 standalone | Higher licensing cost; requires onboarding and sensor deployment |
| **Microsoft Entra ID** | 5, 7 | Microsoft 365 or standalone Azure licence; P1 for Conditional Access and PIM basic; P2 for advanced PIM and Identity Governance | Requires internet connectivity; hybrid environments require Entra Connect |
| **Microsoft Entra Privileged Identity Management (PIM)** | 5, 7 | Entra ID P2 (included in Microsoft 365 E5 or Azure AD P2 standalone) | P2 required for full JIT activation, access reviews, and identity governance |

---

## Licensing Requirements Matrix

### Per-Strategy Licence Requirements

| Strategy | ML1 Minimum Licence | ML2 Recommended Licence | ML3 Recommended Licence |
|---|---|---|---|
| **1. Application Control** | Windows 10/11 Pro or higher | Windows 10/11 Pro or higher | Microsoft 365 E5 (for MDE integration) |
| **2. Patch Applications** | Any Microsoft 365 plan | Microsoft 365 Business Premium or E3 (Intune included) | Microsoft 365 Business Premium or E3 |
| **3. Configure Macro Settings** | Microsoft 365 Apps for Business or higher | Microsoft 365 Apps for Business or higher | Microsoft 365 Apps for Business or higher |
| **4. User Application Hardening** | Any | Any | Microsoft 365 E5 (optional, for advanced Defender SmartScreen) |
| **5. Restrict Admin Privileges** | Entra ID Free (included with any Microsoft 365 plan) | Entra ID P1 (included in Business Premium, E3, or E5) | Entra ID P2 (included in E5, or standalone Azure AD P2) |
| **6. Patch Operating Systems** | Any | Microsoft 365 Business Premium or E3 (Intune included) | Microsoft 365 Business Premium or E3 |
| **7. Multi-Factor Authentication** | Entra ID Free (basic per-user MFA) | Entra ID P1 (Conditional Access policies) | Entra ID P1 or P2 plus FIDO2 hardware tokens (additional cost) |
| **8. Regular Backups** | Any (Azure Backup is consumption-based) | Azure Backup (consumption-based) | Azure Backup with immutable vault (consumption-based) |

### Licence Bundle Summary by Maturity Level

| Maturity Level | Recommended Bundle | Notable Inclusions | Approximate Cost (per user/month, AUD indicative) |
|---|---|---|---|
| **ML1** | Microsoft 365 Business Basic + Windows 10/11 Pro | Basic MFA, Microsoft 365 Apps, Entra ID Free | Low |
| **ML2** | Microsoft 365 Business Premium | Intune, Entra ID P1, Conditional Access, Defender for Business, Windows licence | Mid |
| **ML3** | Microsoft 365 E5 | Intune, Entra ID P2, PIM, MDE Plan 2, Defender for Cloud Apps, advanced compliance | High |

Pricing is subject to Microsoft commercial terms and may vary by agreement type, volume, and region. Refer to [Microsoft 365 Enterprise Plans Comparison](https://www.microsoft.com/en-au/microsoft-365/compare-microsoft-365-enterprise-plans) and [Microsoft Azure Pricing](https://azure.microsoft.com/en-au/pricing/) for current figures.

### Alternative Licensing Configurations

| Configuration | Applicable Maturity | Description |
|---|---|---|
| **On-premises only (GPO + WSUS)** | ML1 | Active Directory and Windows Server Update Services are included with Windows Server licencing. No additional per-user licence required. Limited to domain-joined, on-premises or VPN-connected devices. |
| **Hybrid (GPO for on-premises, Intune for remote)** | ML1–ML2 | GPO manages domain-joined devices; Intune manages cloud-native and remote devices. Requires Business Premium or E3 for Intune. |
| **Standalone Intune** | ML2 | Intune can be licensed separately from the Microsoft 365 suite. Refer to [Microsoft Intune Licensing](https://learn.microsoft.com/en-us/mem/intune/fundamentals/licenses). |
| **MDE Plan 2 standalone** | ML3 | Microsoft Defender for Endpoint Plan 2 can be licensed independently of Microsoft 365 E5. |

---

## Infrastructure Prerequisites

### Active Directory Requirements

| Maturity Level | Requirement |
|---|---|
| **ML1** | Active Directory Domain Services (Windows Server 2016 or later); Group Policy infrastructure; basic AD security configuration |
| **ML2** | All ML1 requirements; Privileged Access Workstations (PAWs) recommended; administrative tier model recommended; regular AD security audits |
| **ML3** | All ML2 requirements; Privileged Access Management solution integrated with AD; enhanced domain controller logging; hardened domain controller configuration |

Active Directory is not required for cloud-native (Entra ID-only) deployments. For hybrid environments, [Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect) is required to synchronise on-premises identities.

### Entra ID Requirements

| Maturity Level | Licence Tier | Required Capabilities |
|---|---|---|
| **ML1** | Entra ID Free | Basic MFA enrolment, user provisioning, self-service password reset |
| **ML2** | Entra ID P1 | Conditional Access policies, group-based licensing, Identity Protection (P2 recommended for risk-based Conditional Access) |
| **ML3** | Entra ID P2 | Privileged Identity Management (PIM), access reviews, identity governance, entitlement management |

Entra ID Free is included with any Microsoft 365 commercial subscription. P1 is included in Microsoft 365 Business Premium, E3, and E5. P2 is included in Microsoft 365 E5 and the Enterprise Mobility + Security E5 bundle, or as [Azure AD P2 standalone](https://azure.microsoft.com/en-au/pricing/details/active-directory/).

### Network Infrastructure Requirements

| Maturity Level | Requirement |
|---|---|
| **ML1** | Standard corporate network; internet connectivity for cloud-managed services; perimeter firewall |
| **ML2** | All ML1 requirements; web filtering or proxy (recommended for browser hardening and macro protection); network segmentation recommended |
| **ML3** | All ML2 requirements; advanced threat protection at the network edge; microsegmentation; isolated network segment for privileged access workstations |

### Storage Infrastructure Requirements (Strategy 8 — Regular Backups)

| Maturity Level | Storage Type | Redundancy | Minimum Retention |
|---|---|---|---|
| **ML1** | Local or network-attached storage | Single copy | 3 months |
| **ML2** | Offsite or cloud storage (e.g., Azure Backup) | Geographic redundancy across separate locations | 3 months |
| **ML3** | Immutable storage (e.g., Azure Backup immutable vault) | Geographic redundancy plus air-gapped or logically isolated copy | 3 months with lifecycle management policy |

Azure Backup immutable vault configuration is documented at [Microsoft Learn — Immutable vault for Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept).

---

## Technology Applicability by Maturity Level

The table below provides a consolidated view of which Microsoft products are required or optional at each maturity level across all eight strategies.

| Microsoft Technology | ML1 | ML2 | ML3 | Strategies Addressed |
|---|---|---|---|---|
| Active Directory Domain Services | Required (on-premises) or optional (cloud-native) | Required (on-premises) or optional | Required (on-premises) or optional | 1, 2, 3, 4, 5, 6 |
| Group Policy Objects (GPO) | Required (on-premises) | Required (on-premises) | Required (on-premises) | 1, 2, 3, 4, 6 |
| Windows Defender Application Control (WDAC) | Required | Required | Required | 1 |
| AppLocker | Alternative to WDAC (Windows 10/11 Pro) | Alternative to WDAC | Not recommended at ML3 | 1 |
| Windows Server Update Services (WSUS) | Required (on-premises) or optional (Intune) | Optional (replaced by Intune) | Not recommended | 2, 6 |
| Microsoft Intune | Optional | Required (for ML2 patching timelines) | Required | 1, 2, 3, 4, 6 |
| Microsoft Defender for Endpoint (MDE) | Not required | Optional enhancement | Required | 1 |
| Microsoft Entra ID Free | Required | Required | Required | 5, 7 |
| Microsoft Entra ID P1 | Not required | Required | Required | 5, 7 |
| Microsoft Entra ID P2 | Not required | Recommended | Required | 5, 7 |
| Microsoft Entra PIM | Not required | Basic (P1) | Full (P2) | 5 |
| Conditional Access | Not required | Required | Required | 7 |
| FIDO2/WebAuthn authenticators | Not required | Not required | Required | 7 |
| Azure Backup | Optional | Recommended | Required (immutable vault) | 8 |
| Windows Autopatch | Not required | Optional | Recommended | 2, 6 |

---

## Related Resources

### ACSC Publications

- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model) — ACSC official maturity model definition
- [Essential Eight Maturity Model and ISM Mapping](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model-and-ism-mapping) — Mapping between Essential Eight and the Information Security Manual
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide) — ACSC guidance on assessing Essential Eight maturity
- [Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) — Australian Government information security controls

### Microsoft Technology Documentation

- [Windows Defender Application Control overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/wdac) — WDAC planning and deployment
- [Microsoft Intune licensing](https://learn.microsoft.com/en-us/mem/intune/fundamentals/licenses) — Intune licence requirements and standalone options
- [Microsoft Entra Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) — PIM configuration and features
- [Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) — Entra ID Conditional Access policies
- [FIDO2 security keys in Entra ID](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-security-key) — Phishing-resistant MFA deployment
- [Microsoft Defender for Endpoint overview](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) — MDE capabilities and onboarding
- [Azure Backup documentation](https://learn.microsoft.com/en-us/azure/backup/backup-overview) — Azure Backup architecture and configuration
- [Immutable vault for Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept) — Immutable storage configuration
- [Windows Autopatch](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-overview) — Automated Windows and Microsoft 365 update management
- [Microsoft 365 Enterprise Plans Comparison](https://www.microsoft.com/en-au/microsoft-365/compare-microsoft-365-enterprise-plans) — E3 and E5 feature and licence comparison
- [Azure Active Directory pricing](https://azure.microsoft.com/en-au/pricing/details/active-directory/) — Entra ID Free, P1, and P2 feature and pricing comparison

### Library Cross-References

- [`../essential-eight-alignment/README.md`](../essential-eight-alignment/README.md) — Parent alignment guide for this compliance domain
- [`../../security/frameworks/essential-eight/reference-cross-reference-matrix.md`](../../security/frameworks/essential-eight/reference-cross-reference-matrix.md) — Framework-side control dependency and sequencing reference
- [`../../security/frameworks/essential-eight/reference-maturity-model.md`](../../security/frameworks/essential-eight/reference-maturity-model.md) — Maturity level definitions and criteria
- [`../../security/frameworks/essential-eight/reference-glossary.md`](../../security/frameworks/essential-eight/reference-glossary.md) — Term definitions for the Essential Eight framework
