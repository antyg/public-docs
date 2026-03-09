---
title: "How to Implement Essential Eight Controls in Azure"
status: "published"
last_updated: "2026-03-09"
audience: "Security engineers implementing Essential Eight controls using Microsoft Azure and Microsoft 365"
document_type: "how-to"
domain: "security"
---

# How to Implement Essential Eight Controls in Azure

---

## Overview

This guide provides per-control implementation steps for each of the eight Essential Eight strategies, with specific Azure and Microsoft 365 service mappings. Each section identifies the relevant Azure services, the configuration actions required, and the maturity level achieved.

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](../reference/maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model).

---

## Strategy 1 — Application Control

**Objective**: Prevent execution of unapproved applications, scripts, libraries, and installers.

### Azure Services

| Service | Role |
|---------|------|
| [Microsoft Defender Application Control (MDAC / App Control for Business)](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview) | Primary enforcement engine |
| [Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-app-control-policy) | Policy deployment and management |
| [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) | Telemetry and enforcement reporting |

### Implementation Steps

1. **Inventory authorised applications** — Export the software inventory from Intune (**Apps > Monitor > Discovered apps**). Establish an approved application list.

2. **Create an App Control for Business policy** — In Intune, navigate to **Endpoint security > App Control for Business > Create policy**. Start with **Audit mode** before switching to **Enforced mode** to identify gaps without blocking users.

3. **Deploy the policy** — Assign to a pilot device group first. Review audit logs in Microsoft Defender for Endpoint (**Reports > App Control > App Control blocked events**).

4. **Switch to Enforced mode** — After validating the allow list covers all legitimate applications, update the policy to **Enforced** mode.

**ML2 requirement**: Application control must be implemented using a deny-by-default approach on workstations and internet-facing servers. The allow list must be maintained and reviewed at least annually.

---

## Strategy 2 — Patch Applications

**Objective**: Patch or mitigate security vulnerabilities in applications within defined timeframes.

### Azure Services

| Service | Role |
|---------|------|
| [Microsoft Intune — Managed Apps](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add) | Microsoft application deployment and updates |
| [Intune Win32 App deployment](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management) | Third-party application patching |
| [Microsoft Defender Vulnerability Management](https://learn.microsoft.com/en-us/defender-vulnerability-management/defender-vulnerability-management) | Vulnerability discovery and prioritisation |

### Implementation Steps

1. **Enable Defender Vulnerability Management** — Navigate in Microsoft Defender XDR to **Vulnerability management > Dashboard**. Review the **Top vulnerable software** view.

2. **Configure application deployment in Intune** — Deploy Microsoft applications (Office, Edge) via Microsoft Store for Business or Win32 apps with automatic update settings.

3. **Monitor unpatched applications** — Use Defender Vulnerability Management's **Security recommendations** view to identify applications with known vulnerabilities.

4. **Set patching SLAs** — Document your patch timelines aligned to ML2 requirements (see [maturity model reference](../reference/maturity-model.md)).

**ML2 requirement**: Applications with critical vulnerabilities must be patched within 48 hours on internet-facing services; 2 weeks on workstations and non-internet-facing servers.

---

## Strategy 3 — Configure Microsoft Office Macro Settings

**Objective**: Disable Microsoft Office macros from the internet and restrict macro execution to digitally signed macros from trusted publishers.

### Azure Services

| Service | Role |
|---------|------|
| [Attack Surface Reduction (ASR) rules via Intune](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction) | Macro blocking enforcement |
| [Microsoft Purview — Sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps) | Data classification integrated with macro policies |
| [Office Cloud Policy Service (OCPS)](https://learn.microsoft.com/en-us/deployoffice/admincenter/overview-office-cloud-policy-service) | Tenant-wide Office policy enforcement |

### Implementation Steps

1. **Enable ASR rule: Block Office applications from creating child processes** — In Intune, navigate to **Endpoint security > Attack surface reduction > Create policy (Windows 10 and later > Attack Surface Reduction Rules)**. Enable the following rules:
   - `Block Office communication application from creating child processes` — Set to **Block**
   - `Block Office applications from injecting code into other processes` — Set to **Block**
   - `Block Win32 API calls from Office macros` — Set to **Block**

2. **Configure macro settings via OCPS** — In Microsoft 365 admin centre, navigate to **Apps > Policies for Microsoft 365 Apps**. Create a policy to:
   - Set **Trust access to the VBA project object model** to **Disabled**
   - Set **Block macros from running in Office files from the Internet** to **Enabled**
   - Set macro security level to **Disable all macros except digitally signed macros**

3. **Establish a trusted publisher list** — For organisations requiring macros, configure the Trusted Publishers list in the Office Trust Center settings deployed via OCPS or Group Policy.

**ML2 requirement**: Macros that are not digitally signed must be prevented from executing. Macros from internet-sourced files must be blocked.

---

## Strategy 4 — User Application Hardening

**Objective**: Disable risky features in office productivity suites and web browsers.

### Azure Services

| Service | Role |
|---------|------|
| [Microsoft Intune — Configuration profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles) | Browser and application hardening policies |
| [Microsoft Edge security baseline](https://learn.microsoft.com/en-us/deployedge/security-baseline) | Browser hardening via Intune |
| [ASR rules](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction) | Office application hardening |

### Implementation Steps

1. **Deploy Microsoft Edge security baseline** — In Intune, navigate to **Endpoint security > Security baselines > Microsoft Edge Baseline**. Create and assign a baseline policy. Review and adjust:
   - Disable Java (not available in Chromium-based Edge by default)
   - Enable SmartScreen
   - Restrict browser extensions to approved list

2. **Disable Office features** — Via OCPS or Intune configuration profiles, disable:
   - Flash (deprecated and removed in Office 365, verify removal)
   - ActiveX controls in Excel, Word (set to **Disable all controls without notification** where appropriate)
   - OLE packages (via ASR rule: **Block Office applications from creating executable content**)

3. **Harden PDF readers** — If Adobe Acrobat is deployed, configure Protected Mode and Protected View via Intune configuration profile (Administrative Templates).

**ML2 requirement**: Web browsers and office productivity suites must not process content from internet zone via Java, web advertisements, and other risky content types.

---

## Strategy 5 — Restrict Administrative Privileges

**Objective**: Limit users with privileged access to operating systems and applications to those who require it. Use just-in-time (JIT) privileged access.

### Azure Services

| Service | Role |
|---------|------|
| [Microsoft Entra Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) | JIT access for Entra ID and Azure roles |
| [Microsoft Entra ID — Privileged access workstations](https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-deployment) | Dedicated PAW devices |
| [Local Administrator Password Solution (LAPS)](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview) | Managed local administrator passwords |

### Implementation Steps

1. **Enable PIM for Entra ID roles** — Navigate to **Microsoft Entra admin centre > Identity Governance > Privileged Identity Management > Microsoft Entra roles**. Convert all Global Administrator assignments from **Active** to **Eligible**.

2. **Configure PIM settings per role** — For each sensitive role, configure:
   - **Require justification on activation** — Enabled
   - **Require approval** — Enabled for Global Administrator (select at least two approvers)
   - **Maximum activation duration** — 4–8 hours
   - **Require MFA on activation** — Enabled

3. **Enable Microsoft Entra LAPS** — Navigate to **Microsoft Entra admin centre > Devices > Local Administrator Password Solution (LAPS)**. Enable for joined devices. Configure:
   - **Password age** — Maximum 30 days
   - **Administrator account managed** — Built-in Administrator

4. **Audit privileged account usage** — Enable [PIM audit logs](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-use-audit-log) and create alerts for privilege escalation in Microsoft Sentinel.

**ML2 requirement**: Privileged access must be time-limited. Privileged accounts must not be used for web browsing or email. Separate accounts for privileged and unprivileged activity.

---

## Strategy 6 — Patch Operating Systems

**Objective**: Patch or mitigate security vulnerabilities in operating systems within defined timeframes.

### Azure Services

| Service | Role |
|---------|------|
| [Windows Update for Business via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) | Windows patch management |
| [Defender Vulnerability Management](https://learn.microsoft.com/en-us/defender-vulnerability-management/defender-vulnerability-management) | OS vulnerability discovery |
| [Azure Update Manager](https://learn.microsoft.com/en-us/azure/update-manager/overview) | Azure VM patch management |

### Implementation Steps

1. **Configure Windows Update rings in Intune** — Navigate to **Devices > Windows > Update rings for Windows 10 and later**. Create two rings:
   - **Pilot ring** (10% of devices): Quality deferral 0 days, Feature deferral 0 days
   - **Production ring** (remaining devices): Quality deferral 5 days, Feature deferral 14 days

2. **Enable expedite for critical updates** — For critical vulnerabilities, use [expedited Windows quality updates](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-expedite-updates) to override deferral periods.

3. **Configure Azure VMs** — In Azure Update Manager (**Azure portal > Update Manager**), create a **Maintenance configuration** with a weekly schedule for security patches.

4. **Monitor patch compliance** — In Intune, check **Devices > Monitor > Windows Update compliance** report. Target 95% compliance within required timeframes.

**ML2 requirement**: Operating system patches with critical or high-severity CVEs must be applied within 48 hours on internet-facing services; 2 weeks on workstations and non-internet-facing servers. End-of-life operating systems must not be present in the environment.

---

## Strategy 7 — Multi-Factor Authentication

**Objective**: Require MFA for all users accessing data repositories, remote access infrastructure, and privileged operations.

### Azure Services

| Service | Role |
|---------|------|
| [Microsoft Entra MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks) | MFA enforcement |
| [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | Risk-based and blanket MFA policies |
| [Authentication Strengths](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview) | Phishing-resistant MFA enforcement |

### Implementation Steps

1. **Create MFA policy for all users** — In Microsoft Entra admin centre, navigate to **Protection > Conditional Access > New policy**:
   - **Users**: All users (exclude break-glass accounts)
   - **Cloud apps**: All cloud apps
   - **Grant**: Require multifactor authentication

2. **Require phishing-resistant MFA for privileged users** — Create a second Conditional Access policy:
   - **Users**: Members of all privileged roles
   - **Grant**: Require authentication strength — **Phishing-resistant MFA**
   - Phishing-resistant methods: FIDO2 security keys, Windows Hello for Business, certificate-based authentication

3. **Block legacy authentication** — Create a Conditional Access policy:
   - **Conditions > Client apps**: Enable legacy authentication clients
   - **Grant**: Block access

4. **Register users for MFA** — Enable the [combined security information registration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-registration-mfa-sspr-combined) and use a Conditional Access policy to enforce registration for all users.

**ML2 requirement**: MFA must be enforced for all users for all remote access and for privileged actions. Phishing-resistant MFA must be used by privileged users.

---

## Strategy 8 — Regular Backups

**Objective**: Maintain recoverable copies of critical data. Test restoration processes regularly.

### Azure Services

| Service | Role |
|---------|------|
| [Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview) | Azure VM, SQL, file share backups |
| [Microsoft 365 Backup](https://learn.microsoft.com/en-us/microsoft-365/backup/backup-overview) | Exchange, SharePoint, OneDrive backups |
| [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview) | Disaster recovery for Azure workloads |

### Implementation Steps

1. **Configure Azure Backup** — In Azure portal, navigate to **Backup centre > + Backup**. Configure backup policies for:
   - Azure VMs (daily snapshots, 30-day retention minimum)
   - Azure Files shares
   - Azure SQL databases

2. **Enable Microsoft 365 Backup** — In Microsoft 365 admin centre, navigate to **Settings > Microsoft 365 Backup**. Enable backup for:
   - Exchange Online (mailboxes)
   - SharePoint Online (sites)
   - OneDrive for Business (user accounts)

3. **Configure backup immutability** — Enable [immutable vault settings](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept) in Azure Backup Recovery Services vault to protect backups from ransomware deletion.

4. **Test restoration** — Conduct quarterly restoration tests. Document the restoration process, test results, and recovery time objectives (RTO) and recovery point objectives (RPO).

**ML2 requirement**: Backups of important data, software, and configuration settings must be performed and retained for at least 3 months. Backups must be tested at least quarterly. Backup access must be restricted to accounts with backup-specific roles only.

---

## Related Resources

- [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight and ISM Mapping (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20and%20ISM%20mapping%20(October%202024).pdf)
- [Microsoft Learn — Essential Eight compliance](https://learn.microsoft.com/en-au/compliance/essential-eight/e8-overview)
- [Essential Eight Assessment Guidance Package](https://www.cyber.gov.au/acsc/view-all-content/news/essential-eight-assessment-guidance-package)
- [Maturity Model Reference](../reference/maturity-model.md)
