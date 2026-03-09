---
title: "Essential Eight Maturity Model Reference"
status: "published"
last_updated: "2026-03-09"
audience: "Security architects, auditors, and compliance officers"
document_type: "reference"
domain: "security"
---

# Essential Eight Maturity Model Reference

**Source**: [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model)

---

## Overview

The Essential Eight Maturity Model defines three maturity levels for each of the eight mitigation strategies. This reference document provides a concise specification of requirements at each level, paired with the primary Azure and Microsoft 365 service that satisfies each requirement.

Maturity Level 0 (ML0) indicates that the strategy is not implemented or is implemented so poorly that an ML1 rating cannot be achieved.

---

## Maturity Level Definitions

| Level | Description | Target Audience |
|-------|-------------|-----------------|
| **ML1** | Partly addresses targeted cyber attacks from lower-sophistication adversaries. Minimum controls aligned to the most common threat vectors. | Organisations beginning their Essential Eight journey |
| **ML2** | Addresses targeted cyber attacks from mid-tier adversaries. Broad coverage of the most common techniques. **ACSC recommended minimum.** | All Australian government entities and regulated organisations |
| **ML3** | Addresses targeted cyber attacks from sophisticated adversaries. Complete coverage, including advanced persistent threats. | High-value targets, entities holding sensitive government information |

Source: [ACSC Essential Eight Maturity Model FAQ (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20FAQ%20(October%202024).pdf)

---

## Strategy 1 — Application Control

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Application control implemented on workstations. Prevents execution of executables not in the allow list. | [App Control for Business (MDAC) via Intune](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview) |
| ML1 | Allowed list covers user profile directories and temp directories. | App Control for Business — path rules |
| ML2 | Application control implemented on internet-facing servers. | App Control for Business — server policy |
| ML2 | Application control implemented on non-internet-facing servers. | App Control for Business — server policy |
| ML2 | Allowed list validated using a hash-based rule system or verified publisher signature. | MDAC publisher rules or hash rules |
| ML2 | Application control events logged to a SIEM. | [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/connect-windows-security-events) |
| ML3 | Application control rule sets are audited and maintained at least monthly. | Intune compliance reports + manual review |
| ML3 | Allowed list blocks all unsigned scripts and unrecognised DLLs. | WDAC with script enforcement |

---

## Strategy 2 — Patch Applications

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Applications with known critical CVEs are patched within one month on workstations. | [Intune Win32 app deployment](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management); [Defender Vulnerability Management](https://learn.microsoft.com/en-us/defender-vulnerability-management/defender-vulnerability-management) |
| ML1 | Applications that are no longer supported by vendors are removed. | Intune — discovered apps inventory |
| ML2 | Internet-facing applications: critical patches applied within 48 hours. | Defender Vulnerability Management — expedited remediation |
| ML2 | Workstations: critical patches applied within 2 weeks. | Intune — Windows Update for Business |
| ML2 | Non-internet-facing servers: critical patches applied within 1 month. | Azure Update Manager |
| ML3 | Applications are patched within 48 hours of release for all criticalities on internet-facing services. | Intune expedited updates; Defender Vulnerability Management |
| ML3 | Automated scanning and enforcement of patch compliance. | Defender Vulnerability Management + Sentinel automation |

---

## Strategy 3 — Configure Microsoft Office Macro Settings

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Microsoft Office macros are disabled for users who do not require them. | [Office Cloud Policy Service (OCPS)](https://learn.microsoft.com/en-us/deployoffice/admincenter/overview-office-cloud-policy-service) |
| ML1 | Macros from the internet are blocked. | [ASR rule: Block macros from Office files downloaded from internet](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference) |
| ML2 | Only digitally signed macros from trusted publishers are permitted. | OCPS — Trust only digitally signed macros |
| ML2 | Antivirus scanning of macros is enabled. | [Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows) |
| ML2 | Macro execution events are logged. | Defender for Endpoint — Advanced Hunting |
| ML3 | Allowed publisher list is reviewed and maintained at least annually. | Manual process with OCPS |
| ML3 | Macro logging is sent to SIEM and monitored. | Microsoft Sentinel |

---

## Strategy 4 — User Application Hardening

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Web browsers do not process Java from internet zone. | [Microsoft Edge security baseline](https://learn.microsoft.com/en-us/deployedge/security-baseline) via Intune |
| ML1 | Web browsers do not process web advertisements from internet zone. | Edge — ad blocking policy |
| ML1 | Internet Explorer 11 is disabled or removed. | Intune configuration profile — IE mode settings |
| ML2 | Microsoft Office does not process content from internet zone. | OCPS + ASR rules |
| ML2 | PDF software does not process content from internet zone. | Intune — Adobe Acrobat Protected Mode policy |
| ML2 | PowerShell is configured to use Constrained Language Mode or disabled for users who do not require it. | [AppLocker or WDAC for PowerShell CLM](https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/jea/overview) |
| ML3 | .NET Framework is secured and unnecessary features are removed. | Intune — Windows feature management |
| ML3 | All hardening events are logged to SIEM. | Microsoft Sentinel |

---

## Strategy 5 — Restrict Administrative Privileges

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Privileged accounts are not used for web browsing or email. | [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) — separate admin accounts |
| ML1 | Privileged access is reviewed periodically. | [Microsoft Entra access reviews](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview) |
| ML2 | Just-in-time access is implemented for privileged accounts. | Microsoft Entra PIM — eligible assignments |
| ML2 | Privileged accounts must use phishing-resistant MFA. | [Conditional Access — Authentication Strengths](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview) |
| ML2 | Local administrator passwords are unique and managed. | [Microsoft Entra LAPS](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview) |
| ML2 | Privileged access activities are logged. | Entra ID audit logs → Microsoft Sentinel |
| ML3 | Privileged Access Workstations (PAWs) are used for all privileged access. | [Privileged Access Workstation deployment](https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-deployment) |
| ML3 | Standing privileged access does not exist (except break-glass accounts). | PIM — all roles eligible only |

---

## Strategy 6 — Patch Operating Systems

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Operating system patches applied within 1 month on workstations and servers. | [Windows Update for Business via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) |
| ML1 | End-of-life operating systems are not used. | Intune device compliance policy — OS version |
| ML2 | Internet-facing services: critical OS patches applied within 48 hours. | Intune expedited updates |
| ML2 | Workstations and non-internet-facing servers: critical patches within 2 weeks. | Intune update rings |
| ML2 | OS patch compliance is monitored and reported. | [Intune Windows Update compliance report](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-compliance-reports) |
| ML3 | OS patches applied within 48 hours of release across all systems. | Intune + Azure Update Manager — expedited policies |
| ML3 | OS patching is automated with validation before deployment. | Intune + Azure Update Manager — maintenance windows |

---

## Strategy 7 — Multi-Factor Authentication

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | MFA is required for all users accessing internet-facing services. | [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) |
| ML1 | MFA is required for all users accessing remote access infrastructure. | Conditional Access — all cloud apps policy |
| ML2 | MFA is required for all users accessing all systems. | Conditional Access — all users, all apps |
| ML2 | Phishing-resistant MFA is required for privileged users. | [Authentication Strengths — Phishing-resistant MFA](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview) |
| ML2 | Legacy authentication is blocked. | Conditional Access — block legacy authentication clients |
| ML2 | MFA events are logged. | Microsoft Entra sign-in logs → Microsoft Sentinel |
| ML3 | Phishing-resistant MFA is required for all users (not only privileged). | Conditional Access — phishing-resistant strength for all users |
| ML3 | MFA bypass attempts are alerted and investigated. | Microsoft Sentinel — MFA anomaly analytics rules |

**Phishing-resistant MFA methods** (ML2 privileged / ML3 all users):
- FIDO2 security keys
- Windows Hello for Business
- Certificate-based authentication (CBA)

Source: [Microsoft — Authentication methods and phishing resistance](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

---

## Strategy 8 — Regular Backups

| Maturity | Requirement | Azure/Microsoft Service |
|----------|-------------|------------------------|
| ML1 | Backups of important data are performed and retained for at least 3 months. | [Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview); [Microsoft 365 Backup](https://learn.microsoft.com/en-us/microsoft-365/backup/backup-overview) |
| ML1 | Backup accounts are separate from standard accounts. | Azure Backup — RBAC: Backup Operator role |
| ML2 | Backups are tested at least quarterly (partial restoration). | Azure Backup — Test failover; documented test evidence |
| ML2 | Backup storage is in a different location or account to the production systems. | Azure Backup — Geo-redundant storage (GRS) |
| ML2 | Backups cannot be modified or deleted by production accounts. | [Azure Backup immutable vaults](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept) |
| ML2 | Privileged access to backup systems uses separate credentials. | Entra PIM — Backup Operator role |
| ML3 | Full restoration is tested at least annually. | Azure Site Recovery — planned failover test |
| ML3 | Backup integrity is continuously monitored and alerted. | Azure Backup — backup health alerts |

---

## ISM Mapping

The Essential Eight maps to controls in the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism). For the complete mapping see the [Essential Eight Maturity Model and ISM Mapping (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20and%20ISM%20mapping%20(October%202024).pdf).

---

## Related Resources

- [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model)
- [Essential Eight Maturity Model FAQ (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20FAQ%20(October%202024).pdf)
- [Essential Eight and ISM Mapping (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20and%20ISM%20mapping%20(October%202024).pdf)
- [ACSC Assessment Guidance Package](https://www.cyber.gov.au/acsc/view-all-content/news/essential-eight-assessment-guidance-package)
- [Microsoft Learn — Essential Eight compliance](https://learn.microsoft.com/en-au/compliance/essential-eight/e8-overview)
- [How to Implement Essential Eight Controls](../how-to/implement-e8-controls.md)
