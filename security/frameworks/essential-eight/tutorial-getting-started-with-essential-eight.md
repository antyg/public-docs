---
title: "Getting Started with the Essential Eight in Azure"
status: "published"
last_updated: "2026-03-09"
audience: "Security engineers and IT administrators beginning Essential Eight adoption"
document_type: "tutorial"
domain: "security"
---

# Getting Started with the Essential Eight in Azure

---

## Overview

This tutorial walks you through your first Essential Eight implementation steps using Microsoft Azure and Microsoft 365 services. By the end, you will have completed an initial assessment of your environment, mapped your existing Azure controls to the Essential Eight, and prioritised your implementation roadmap.

The [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) is a baseline set of eight mitigation strategies that the Australian Signals Directorate (ASD) recommends as the minimum security baseline for Australian organisations. The ACSC recommends all organisations achieve Maturity Level 2 (ML2) across all eight strategies.

---

## Before You Begin

You need:

- An Azure Active Directory (Microsoft Entra ID) tenant with at least **Microsoft Entra ID P1** licences (P2 recommended for full risk-based controls)
- An **Intune** subscription for device management controls
- **Global Administrator** or **Security Administrator** role in your tenant
- Familiarity with the Microsoft Entra admin centre and Intune admin centre portals

---

## Step 1 — Understand the Eight Strategies

The Essential Eight comprises eight prioritised mitigation strategies. Familiarise yourself with each strategy and its primary Azure mapping before you begin:

| # | Strategy | Primary Azure/Microsoft Control |
|---|----------|---------------------------------|
| 1 | Application Control | [Microsoft Defender Application Control (MDAC)](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview) via Intune |
| 2 | Patch Applications | [Microsoft Intune — Software updates](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) |
| 3 | Configure Microsoft Office Macro Settings | [Attack Surface Reduction (ASR) rules](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction) via Intune |
| 4 | User Application Hardening | ASR rules + Intune configuration profiles |
| 5 | Restrict Administrative Privileges | [Microsoft Entra Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) |
| 6 | Patch Operating Systems | Intune — Windows Update for Business |
| 7 | Multi-Factor Authentication | [Microsoft Entra MFA + Conditional Access](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks) |
| 8 | Regular Backups | [Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview) + [Microsoft 365 Backup](https://learn.microsoft.com/en-us/microsoft-365/backup/backup-overview) |

Read the official [Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model) to understand the specific requirements at each maturity level.

---

## Step 2 — Conduct an Initial Assessment

Before implementing any controls, assess your current state against Maturity Level 1 (ML1) requirements.

### 2a — Use the ASD Cyber Toolbox

The ASD provides two free assessment tools:

- **Essential Eight Maturity Verification Tool (E8MVT)** — Validates configuration against ML1–ML3 requirements
- **Application Control Verification Tool (ACVT)** — Tests application control implementation

Download both from the [Essential Eight Assessment Guidance Package](https://www.cyber.gov.au/acsc/view-all-content/news/essential-eight-assessment-guidance-package).

### 2b — Export Current Entra ID Configuration

Run the following assessment areas in the Microsoft Entra admin centre ([entra.microsoft.com](https://entra.microsoft.com)):

1. **Authentication methods** — Navigate to **Protection > Authentication methods > Policies**. Note which MFA methods are enabled.
2. **Conditional Access** — Navigate to **Protection > Conditional Access > Policies**. Export the policy list.
3. **PIM configuration** — Navigate to **Identity Governance > Privileged Identity Management**. Note which roles have PIM configured.

### 2c — Export Current Intune Configuration

In the Intune admin centre ([intune.microsoft.com](https://intune.microsoft.com)):

1. **Device compliance** — Navigate to **Devices > Compliance policies**. Note which platforms have policies.
2. **Configuration profiles** — Navigate to **Devices > Configuration profiles**. Check for existing ASR and hardening profiles.
3. **Update rings** — Navigate to **Devices > Windows > Update rings for Windows 10 and later**.

Record your findings in a spreadsheet mapping each strategy to: current control, gaps, and estimated effort to reach ML2.

---

## Step 3 — Enable Multi-Factor Authentication (Strategy 7)

MFA is the highest-impact control and the natural starting point. Begin here.

### 3a — Enable Security Defaults (If Starting Fresh)

If your tenant has no Conditional Access policies, [Security Defaults](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults) provides an immediate baseline:

1. In Microsoft Entra admin centre, navigate to **Properties > Manage security defaults**
2. Set **Security defaults** to **Enabled**
3. Click **Save**

Security Defaults enforces MFA registration for all users and blocks legacy authentication. This gets you to partial ML1 for Strategy 7 immediately.

### 3b — Migrate to Conditional Access MFA (For ML2)

ML2 requires phishing-resistant MFA for privileged users. Plan migration from Security Defaults to Conditional Access policies:

1. Create a [Conditional Access policy requiring MFA](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-all-users-mfa) for all users
2. Configure [phishing-resistant authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths) (FIDO2 or Windows Hello for Business) for privileged accounts
3. Disable legacy authentication via a [block legacy authentication policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy-authentication)

---

## Step 4 — Restrict Administrative Privileges (Strategy 5)

### 4a — Audit Current Administrative Accounts

In Microsoft Entra admin centre:

1. Navigate to **Roles & admins > Roles & admins**
2. Click each privileged role (Global Administrator, Privileged Role Administrator, etc.)
3. Export membership lists — identify accounts with standing (always-on) privileged access

### 4b — Enable Privileged Identity Management

[PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) converts standing privileged access to just-in-time access:

1. Navigate to **Identity Governance > Privileged Identity Management**
2. Select **Microsoft Entra roles**
3. Configure **Global Administrator** as eligible (not permanent) for all accounts except a single break-glass account
4. Set approval requirements and maximum activation duration (recommended: 4–8 hours)

---

## Step 5 — Begin Patch Management (Strategies 2 and 6)

### 5a — Configure Windows Update for Business via Intune

1. In Intune admin centre, navigate to **Devices > Windows > Update rings for Windows 10 and later**
2. Create an **Update ring** policy:
   - **Quality update deferral**: 0 days (deploy security patches immediately for ML2)
   - **Feature update deferral**: 0–30 days depending on testing requirements
3. Assign to **All devices** device group

For ML2, operating system patches must be applied within **two weeks** of release. Quality (security) updates must be applied within **48 hours** for internet-facing services.

See the [ACSC Essential Eight Maturity Model and ISM Mapping (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20and%20ISM%20mapping%20(October%202024).pdf) for exact patch timing requirements per maturity level.

---

## Step 6 — Review Your Progress

After completing Steps 3–5, you have addressed the three highest-impact Essential Eight strategies. Record your progress:

| Strategy | Control Implemented | Maturity Level Reached |
|----------|--------------------|-----------------------|
| 5 — Restrict Admin Privileges | PIM enabled for Entra ID roles | ML1 (partial) |
| 7 — MFA | Security Defaults or Conditional Access | ML1–ML2 |
| 2/6 — Patch Management | Update rings configured | ML1 (pending testing) |

---

## Next Steps

Continue with the remaining strategies using the how-to guides:

- [Implement Essential Eight Controls](how-to-implement-e8-controls.md) — Per-control Azure implementation
- [Essential Eight Maturity Model Reference](reference-maturity-model.md) — Exact requirements at ML1, ML2, ML3
- [Why Essential Eight](explanation-why-essential-eight.md) — Framework context and Australian regulatory background

### Official Resources

- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model)
- [Essential Eight Assessment Guidance Package](https://www.cyber.gov.au/acsc/view-all-content/news/essential-eight-assessment-guidance-package)
- [Microsoft Learn — Essential Eight](https://learn.microsoft.com/en-au/compliance/essential-eight/e8-overview)
- [ASD Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
