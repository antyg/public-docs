---
title: "Essential Eight Alignment — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "readme"
domain: "compliance"
---

# Essential Eight Alignment — Content Outline

---

## Purpose

This outline maps each of the eight Essential Eight mitigation strategies to the Microsoft technology documentation and ACSC publications that will underpin alignment guide content. It serves as the authoring blueprint for the per-strategy alignment guides to be developed under this folder.

Each entry identifies:

- The ACSC control intent (cited from authoritative source)
- The primary Microsoft technologies that address the control
- The specific Layer 3 documentation sections to reference
- The evidence artefacts the configuration produces
- Known gaps or caveats

---

## Strategy 1: Application Control

**ACSC Control Intent**: Prevent execution of unapproved/malicious programs including .exe, DLL, scripts, and installers. Adversaries who cannot execute code cannot compromise systems. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1 Alignment

| Field                    | Detail                                                                                                     |
| ------------------------ | ---------------------------------------------------------------------------------------------------------- |
| **Requirement**          | Application control applied to user profiles and temporary directories for standard users                  |
| **Primary technology**   | Defender for Endpoint — Windows Defender Application Control (WDAC)                                        |
| **Secondary technology** | Intune — WDAC policy deployment via OMA-URI                                                                |
| **Layer 3 reference**    | `security/defender-for-endpoint/` (application control policies section)                                   |
| **Evidence artefact**    | Defender for Endpoint — Device configuration compliance report; WDAC audit log events (Event ID 3076/3077) |
| **Caveats**              | ML1 permits allowlisting by publisher certificate — less restrictive than ML2 hash-based control           |

### ML2 Alignment

| Field                    | Detail                                                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Requirement**          | Application control applied to all users; allowlisting by publisher certificate, path, or hash; maintained and validated                   |
| **Primary technology**   | Defender for Endpoint (WDAC enforcement mode), Intune (WDAC policy deployment)                                                             |
| **Secondary technology** | Defender for Cloud (adaptive application controls for server workloads)                                                                    |
| **Layer 3 reference**    | `security/defender-for-endpoint/`, `security/defender-for-cloud/`, `endpoints/intune/`                                                     |
| **Evidence artefact**    | WDAC enforcement event logs, Intune device compliance report, Defender for Cloud adaptive controls report                                  |
| **Caveats**              | Defender for Cloud adaptive application controls apply to Azure VMs, not endpoint devices; separate controls required per environment type |

### ML3 Alignment

| Field                  | Detail                                                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Requirement**        | Application control applied to all users and administrators, validated regularly; DLL control in addition to executable control |
| **Primary technology** | Defender for Endpoint (WDAC with DLL rules), Intune                                                                             |
| **Layer 3 reference**  | `security/defender-for-endpoint/`                                                                                               |
| **Evidence artefact**  | WDAC DLL enforcement event logs, Defender for Endpoint advanced hunting queries                                                 |
| **Caveats**            | DLL-level application control requires careful policy testing to avoid blocking legitimate software                             |

---

## Strategy 2: Patch Applications

**ACSC Control Intent**: Patch or mitigate vulnerabilities in internet-facing applications within 48 hours (critical), and other applications within two weeks. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1–ML3 Alignment

| Field                    | Detail                                                                                                                                                           |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Requirement**          | Applications patched within defined timeframes based on vulnerability severity; unsupported applications removed                                                 |
| **Primary technology**   | Defender for Endpoint (software vulnerability inventory, TVM), Intune (app update policies), Azure Update Manager                                                |
| **Secondary technology** | Defender for Cloud (vulnerability assessment for cloud workloads)                                                                                                |
| **Layer 3 reference**    | `security/defender-for-endpoint/` (threat and vulnerability management), `security/defender-for-cloud/` (vulnerability assessment)                               |
| **Evidence artefact**    | Defender Vulnerability Management dashboard (software inventory, CVE exposure), Intune app compliance report, Defender for Cloud vulnerability assessment report |
| **Caveats**              | Patching timeframe evidence requires correlation of vulnerability discovery date with patch deployment date — requires log retention and reporting configuration |

---

## Strategy 3: Configure Microsoft Office Macro Settings

**ACSC Control Intent**: Prevent Office macros from executing unless explicitly authorised; block macros from the internet; log macro execution. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1–ML3 Alignment

| Field                  | Detail                                                                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Requirement**        | Macros disabled for users who do not require them; macros from internet blocked for all users; macro signing requirements enforced at ML2/ML3                            |
| **Primary technology** | Microsoft 365 cloud policy service (OCPS), Intune (Attack Surface Reduction rules), Defender for Endpoint (ASR rule: Block Office macros from Win32 API calls)           |
| **Layer 3 reference**  | `security/defender-for-endpoint/` (ASR rules), `endpoints/intune/` (OCPS configuration)                                                                                  |
| **Evidence artefact**  | Defender for Endpoint ASR rule report, Intune device configuration compliance report, Microsoft 365 admin centre policy assignment report                                |
| **Caveats**            | OCPS macro settings apply to Microsoft 365 Apps; separate policy required for on-premises Office installations; ASR rules require Defender for Endpoint Plan 1 or higher |

---

## Strategy 4: User Application Hardening

**ACSC Control Intent**: Configure web browsers, PDF viewers, and Microsoft Office to block ads, Java, Flash, and other risky content from the internet. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1–ML3 Alignment

| Field                  | Detail                                                                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Requirement**        | Internet Explorer 11 disabled; web advertisement blocking enabled; Java disabled from internet for browsers; Flash disabled; PowerShell constrained language mode at ML3 |
| **Primary technology** | Intune (configuration profiles — Microsoft Edge policy, PowerShell execution policy), Defender for Endpoint (web content filtering, exploit protection)                  |
| **Layer 3 reference**  | `security/defender-for-endpoint/` (web protection, exploit protection), `endpoints/intune/` (Edge policy profiles)                                                       |
| **Evidence artefact**  | Intune device configuration report, Defender for Endpoint web protection report, exploit protection settings export                                                      |
| **Caveats**            | Internet Explorer 11 was removed from Windows 10 21H2+ and Windows 11; IE mode in Edge requires separate policy; Java browser plugin deprecated in modern browsers       |

---

## Strategy 5: Restrict Administrative Privileges

**ACSC Control Intent**: Limit users with privileged access; use separate accounts for privileged tasks; privileged accounts cannot browse the web or access email. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1 Alignment

| Field                  | Detail                                                                                    |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| **Requirement**        | Privileged accounts not used for unprivileged tasks; local administrator accounts managed |
| **Primary technology** | Entra ID (role assignment review), Intune (Local Administrator Password Solution — LAPS)  |
| **Layer 3 reference**  | `identity/entra-id/`, `endpoints/intune/`                                                 |
| **Evidence artefact**  | Entra ID privileged role assignment report, Intune LAPS configuration report              |

### ML2 Alignment

| Field                  | Detail                                                                                                                                         |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Requirement**        | Just-in-time privileged access; privileged access workstations (PAWs) or equivalent isolation; Privileged Identity Management (PIM)            |
| **Primary technology** | Entra ID Privileged Identity Management (PIM), Conditional Access (privileged access policy), Intune (PAW device profile)                      |
| **Layer 3 reference**  | `identity/entra-id/`, `identity/conditional-access/`                                                                                           |
| **Evidence artefact**  | PIM audit log (role activation history), Conditional Access named location and compliance report, Entra ID sign-in log for privileged accounts |
| **Caveats**            | PIM requires Entra ID P2 licensing; Conditional Access privileged access requires careful policy design to avoid lockout                       |

### ML3 Alignment

| Field                  | Detail                                                                                                |
| ---------------------- | ----------------------------------------------------------------------------------------------------- |
| **Requirement**        | Privileged access management solution; credentials stored in PAM vault; all privileged actions logged |
| **Primary technology** | Entra ID PIM, Microsoft Sentinel (privileged access audit), Azure Key Vault (credential management)   |
| **Layer 3 reference**  | `identity/entra-id/`, `security/sentinel/`                                                            |
| **Evidence artefact**  | PIM audit trail, Sentinel privileged access workbook, Key Vault access log                            |

---

## Strategy 6: Patch Operating Systems

**ACSC Control Intent**: Patch or mitigate vulnerabilities in operating systems within 48 hours (internet-facing, critical) or two weeks (other). Unsupported operating systems not used. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1–ML3 Alignment

| Field                    | Detail                                                                                                                                                             |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Requirement**          | OS patches deployed within defined timeframes; OS version currency enforced; unsupported OS versions removed                                                       |
| **Primary technology**   | Intune (Windows Update for Business, update rings), Azure Update Manager (Azure VMs), Defender for Cloud (OS vulnerability assessment)                             |
| **Secondary technology** | Defender for Endpoint (OS version and patch status inventory)                                                                                                      |
| **Layer 3 reference**    | `security/defender-for-cloud/` (OS vulnerability assessment), `security/defender-for-endpoint/` (device inventory), `endpoints/intune/` (update rings)             |
| **Evidence artefact**    | Intune Windows Update compliance report (patch level by device), Defender for Cloud OS recommendations report, Defender for Endpoint device inventory (OS version) |
| **Caveats**              | Azure Update Manager covers Azure VMs; Intune covers enrolled endpoints; separate processes required for non-enrolled or non-Azure workloads                       |

---

## Strategy 7: Multi-Factor Authentication

**ACSC Control Intent**: Require multiple verification factors for authentication to systems; privileged users require phishing-resistant MFA; ML3 requires phishing-resistant MFA for all users. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1 Alignment

| Field                  | Detail                                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Requirement**        | MFA for remote access and privileged accounts                                                                  |
| **Primary technology** | Entra ID (authentication methods policy), Conditional Access (MFA enforcement for remote access)               |
| **Layer 3 reference**  | `identity/mfa/`, `identity/conditional-access/`                                                                |
| **Evidence artefact**  | Conditional Access policy export, Entra ID sign-in log (MFA success/failure), Entra ID MFA registration report |

### ML2 Alignment

| Field                  | Detail                                                                                                                                                                                  |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Requirement**        | MFA for all users accessing internet-facing services and privileged accounts; phishing-resistant MFA for privileged users                                                               |
| **Primary technology** | Entra ID (authentication method policy — FIDO2, Windows Hello for Business, certificate-based auth), Conditional Access (MFA for all cloud apps)                                        |
| **Layer 3 reference**  | `identity/mfa/`, `identity/conditional-access/`, `identity/entra-id/`                                                                                                                   |
| **Evidence artefact**  | Conditional Access named policy export (MFA required), Entra ID authentication method registration report, sign-in log (authentication method used per session)                         |
| **Caveats**            | Microsoft Authenticator push notification is not phishing-resistant; FIDO2 and Windows Hello for Business are phishing-resistant — must differentiate in policy for privileged accounts |

### ML3 Alignment

| Field                  | Detail                                                                                                                                                                                          |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Requirement**        | Phishing-resistant MFA for all users accessing all systems                                                                                                                                      |
| **Primary technology** | Entra ID (FIDO2 security keys, Windows Hello for Business, certificate-based authentication), Conditional Access (authentication strength policy)                                               |
| **Layer 3 reference**  | `identity/mfa/`, `identity/conditional-access/`                                                                                                                                                 |
| **Evidence artefact**  | Authentication strength policy export, Conditional Access sign-in log (phishing-resistant method recorded), FIDO2 key registration report                                                       |
| **Caveats**            | FIDO2 phishing-resistant enforcement requires Entra ID P1; authentication strength requires Conditional Access — enforce per-app where phishing-resistant method is unavailable for legacy apps |

---

## Strategy 8: Regular Backups

**ACSC Control Intent**: Perform regular backups of important data, software, and configuration; test restoration; retain backups offline or immutably. ([Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight))

### ML1–ML3 Alignment

| Field                    | Detail                                                                                                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Requirement**          | Regular automated backups; backup restoration tested; backups stored separately from production; ML3 requires offline/immutable backups                                                          |
| **Primary technology**   | Azure Backup (VMs, SQL, files), Microsoft 365 Backup (Exchange Online, SharePoint, OneDrive), Azure Site Recovery (disaster recovery)                                                            |
| **Secondary technology** | Intune (app protection policies — selective wipe and backup for mobile data)                                                                                                                     |
| **Layer 3 reference**    | `infrastructure/` (Azure Backup configuration), `endpoints/intune/` (app protection policies)                                                                                                    |
| **Evidence artefact**    | Azure Backup vault report (backup jobs, last successful backup), Microsoft 365 Backup restore job history, Azure Site Recovery replication health report                                         |
| **Caveats**              | Microsoft 365 Backup requires Microsoft 365 Backup add-on licensing (separate from base M365 licences); immutable backup storage requires Azure Blob Storage with immutability policy configured |

---

## Citation Sources for Content Development

### ACSC Essential Eight Publications

- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — Primary control requirements reference
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide) — Assessment criteria and evidence requirements
- [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents) — Strategic context

### Microsoft Technology Documentation (Layer 3)

- `security/defender-for-endpoint/` — EDR, application control, ASR, web protection, TVM
- `security/defender-for-cloud/` — CSPM, workload protection, vulnerability assessment, regulatory compliance dashboard
- `security/sentinel/` — SIEM, audit log centralisation, privileged access analytics
- `identity/entra-id/` — Identity platform, role management, PIM
- `identity/conditional-access/` — Access policies, MFA enforcement, device compliance
- `identity/mfa/` — Authentication methods, FIDO2, Windows Hello for Business
- `endpoints/intune/` — Device compliance, configuration profiles, LAPS, update rings, app protection

### Australian Regulatory Context

- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) — ISM controls cross-referencing E8 strategies
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/) — Government entity obligations

---

**Australian English** is used throughout this documentation.
