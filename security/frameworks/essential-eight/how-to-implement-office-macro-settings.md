---
title: "How to Implement Office Macro Settings"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Office Macro Settings

---

## Overview

This guide provides per-maturity-level implementation steps for configuring Microsoft Office macro settings as part of the ACSC Essential Eight. Macro-based attacks remain one of the most prevalent delivery mechanisms for malware. Restricting macro execution reduces the attack surface by preventing untrusted, internet-sourced code from running in Office applications.

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

### Prerequisites

- Microsoft 365 Apps for Enterprise (or Microsoft Office 2016+) deployed across managed endpoints
- A policy management mechanism in place — Group Policy (GPO), Microsoft Intune (including Office Cloud Policy Service), or equivalent MDM/configuration management tooling
- Office ADMX administrative templates imported into your Group Policy environment (if using GPO)
- Inventory of business-critical macros, their sources, and their owners

### Scope

This guide covers macro execution controls for Microsoft Office applications (Word, Excel, PowerPoint, Access, Outlook). It does not cover macro signing infrastructure setup, VBA code review practices, or non-Office scripting environments.

---

## Maturity Level 1 — Block Macros from the Internet

**Objective**: Prevent Office applications from executing macros sourced from the internet (files with the Mark of the Web).

**Estimated implementation time**: 2–4 weeks
**Ongoing effort**: 2–3 hours per week

### Step 1 — Assess Current Macro Usage

Before deploying any policy, establish a baseline to avoid breaking business-critical workflows.

1. Survey teams and business units to identify which users rely on macros.
2. Document each macro's source (local share, SharePoint, external email attachment, vendor-supplied file).
3. Classify each macro as:
   - **Trusted local** — stored on a verified internal network path
   - **Trusted cloud** — stored on an internal SharePoint or OneDrive tenant (note: files downloaded from SharePoint/OneDrive carry the Mark of the Web by default)
   - **Untrusted / internet-sourced** — received via email, downloaded from an external site, or origin unknown
4. Record business justification for any macro that must continue to run.

### Step 2 — Deploy Macro Policy via GPO or Intune

**Option A — Group Policy (GPO)**

1. Ensure the [Microsoft 365 Apps ADMX templates](https://www.microsoft.com/en-au/download/details.aspx?id=49030) are imported into your Group Policy Central Store.
2. Create or edit a GPO scoped to managed workstations.
3. Navigate to: `User Configuration > Administrative Templates > Microsoft Office 2016 > Security Settings > Trust Center`
4. Configure the following settings for each relevant application (Word, Excel, PowerPoint):

   | Setting | Value |
   |---------|-------|
   | Block macros from running in Office files from the Internet | **Enabled** |
   | VBA Macro Notification Settings | **Disable all macros with notification** (or **Disable all macros without notification** for stricter enforcement) |

5. Link and enforce the GPO across all workstation OUs.

**Option B — Microsoft Intune (Settings Catalogue or OCPS)**

Using the **Settings Catalogue**:

1. In the Intune admin centre, navigate to **Devices > Configuration profiles > Create profile**.
2. Select **Windows 10 and later** and **Settings catalogue**.
3. Search for and add the following settings under the **Microsoft Office** category:

   | Setting | Value |
   |---------|-------|
   | Block macros from running in Office files from the Internet (Word/Excel/PowerPoint) | **Enabled** |
   | VBA Macro Notification Settings | **Disable all macros with notification** |

4. Assign the profile to the relevant device or user groups.

Using the **Office Cloud Policy Service (OCPS)**:

1. Navigate to [config.office.com](https://config.office.com) or **Apps > Policies for Microsoft 365 Apps** in the Intune admin centre.
2. Create a new policy configuration scoped to the appropriate security group.
3. Search for and configure the same macro settings as above.
4. Save and publish the policy.

> **Note on SharePoint and OneDrive**: Files opened directly from SharePoint Online or OneDrive in the browser do not carry the Mark of the Web. However, files downloaded and then opened locally do. Clarify with your organisation which access patterns apply, and communicate clearly to users.

### Step 3 — Configure Trusted Locations (if required)

If business-critical macros must continue to run, place the source files in a declared trusted location rather than creating broad exceptions.

1. Identify the UNC path or local path where trusted macro-enabled files are stored.
2. Via GPO or Intune, add the path under: `Trust Center > Trusted Locations > Add new location`.
3. Document each trusted location with a business justification, approver, and review date.
4. Do not mark locations as trusted unless the source is fully controlled by your organisation.

> Trusted locations bypass the Mark of the Web check. Each trusted location represents a risk acceptance decision and must be recorded in your exception register.

### Step 4 — Enable Macro Logging

Enable logging to create an evidence trail of macro blocking activity.

1. Via GPO, navigate to: `User Configuration > Administrative Templates > Microsoft Office 2016 > Security Settings`
2. Enable **Macro Runtime Scan Scope** to log macro execution attempts.
3. Forward Office event logs (Application log, source: Microsoft Office Alerts) to your SIEM or centralised log platform.

### Step 5 — Communicate with Users

User communication reduces helpdesk load and prevents circumvention attempts.

1. Notify users before the policy is enforced, explaining what will change and why.
2. Publish guidance on how to request a trusted location exception.
3. Provide a contact point for macro-related issues.

### ML1 Verification

| Check | Evidence |
|-------|----------|
| Policy deployed to 100% of managed endpoints | GPO/Intune compliance report showing full coverage |
| Macros from internet-sourced files are blocked | Test by opening a macro-enabled file with Mark of the Web — macro should be blocked |
| Trusted locations documented and justified | Exception register with path, owner, justification, and review date |
| Macro blocking events are logged | SIEM events or exported Office event log entries showing blocked macro attempts |
| Users notified | Communication record (email, intranet post, or service desk article) |

---

## Maturity Level 2 — Disable Macros Except from Trusted Locations

**Objective**: Macros are disabled by default across the organisation. Only macros stored in explicitly declared, organisation-controlled trusted locations are permitted to execute.

**Prerequisite**: ML1 controls fully implemented and verified.
**Estimated implementation time**: 6–12 months from ML1 achievement
**Ongoing effort**: 3–5 hours per week

### Step 1 — Review and Rationalise the Trusted Locations List

Before tightening policy, audit the existing trusted locations established at ML1.

1. Review every trusted location in your exception register.
2. Confirm each path is still in active use, is organisation-controlled, and has a current business justification.
3. Remove or archive trusted locations that are no longer required.
4. Ensure all remaining trusted locations are read-only from user perspective where possible.

### Step 2 — Change Policy to Disable All Macros Without Exception (Except Trusted Locations)

Update the macro policy to shift from "block from internet" to "disable all except trusted locations".

**Via GPO**:

1. Edit the existing macro GPO.
2. Navigate to: `User Configuration > Administrative Templates > Microsoft Office 2016 > Security Settings > Trust Center`
3. For each application, change **VBA Macro Notification Settings** to **Disable all macros except digitally signed macros** or **Disable all macros without notification**, depending on whether you intend to use digital signatures at this level.
4. Verify that **Block macros from running in Office files from the Internet** remains enabled.

**Via Intune Settings Catalogue or OCPS**:

1. Update the existing configuration profile or OCPS policy.
2. Set **VBA Macro Notification Settings** to **Disable all macros without notification** (or the digitally-signed equivalent).
3. Confirm trusted location settings remain in place.

### Step 3 — Enforce Trusted Location Controls

At ML2, the trusted location list becomes the primary control boundary.

1. Restrict write access to trusted location paths to administrators only — users must not be able to place files there without approval.
2. Implement a formal change management process for adding or modifying trusted locations.
3. Schedule quarterly reviews of the trusted locations register.

### Step 4 — Test Business Continuity

Before full enforcement, validate that all approved workflows continue to function.

1. Run user acceptance testing (UAT) with representatives from each business unit that relies on macros.
2. Document any workflows that break and resolve them through trusted location configuration or macro migration.
3. Keep a rollback plan available for the first 2–4 weeks post-enforcement.

### Step 5 — Update Monitoring

At ML2, the monitoring posture should shift from reactive to proactive.

1. Create alerts for any attempt to execute a macro outside a trusted location (these should now be rare and may indicate policy bypass attempts).
2. Review macro blocking logs weekly and investigate anomalies.

### ML2 Verification

| Check | Evidence |
|-------|----------|
| All macros disabled except from trusted locations | Test macro execution from a non-trusted path — must be blocked |
| Trusted locations list reviewed and rationalised | Updated exception register with review date |
| Write access to trusted paths is restricted | Access control review output or Intune/GPO configuration evidence |
| Quarterly trusted location review scheduled | Calendar entry or change management record |
| Monitoring alerts configured | SIEM alert rule definitions or log query screenshots |

---

## Maturity Level 3 — Publisher Trust Verification and Code Signing

**Objective**: Macros that are permitted to execute must be digitally signed by a trusted publisher. Code signing provides cryptographic assurance of macro origin and integrity.

**Prerequisite**: ML2 controls fully implemented and verified.
**Estimated implementation time**: 8–16 months from ML2 achievement
**Ongoing effort**: 5–8 hours per week

### Step 1 — Establish a Macro Code Signing Process

1. Obtain or designate a code signing certificate for macro signing:
   - Preferred: an internal PKI certificate from your organisation's Certificate Authority
   - Acceptable: a commercial code signing certificate from a trusted CA
2. Restrict access to the signing certificate and private key to authorised personnel only.
3. Document the signing process: who may sign, under what approval, and how signed macros are distributed.

### Step 2 — Sign All Approved Macros

1. For each macro in the trusted locations register, open the VBA editor in the relevant Office application.
2. Use **Tools > Digital Signature** to apply the organisational code signing certificate.
3. Re-sign macros whenever the macro code is modified.
4. Record the signer, signing date, and certificate thumbprint in the macro register.

### Step 3 — Configure Policy to Require Digital Signatures

**Via GPO**:

1. Navigate to: `User Configuration > Administrative Templates > Microsoft Office 2016 > Security Settings > Trust Center`
2. Set **VBA Macro Notification Settings** to **Disable all macros except digitally signed macros**.
3. Ensure the signing certificate's CA is trusted on all endpoints (deployed via Group Policy or Intune certificate profile).

**Via Intune**:

1. Update the configuration profile to require digitally signed macros.
2. Deploy the signing CA certificate as a trusted root or intermediate via a certificate profile.

### Step 4 — Manage Trusted Publishers

1. Via GPO or Intune, configure the **Trusted Publishers** list to include only your organisation's macro signing certificate.
2. Prevent users from adding publishers to the trusted list: enable **Prevent users from modifying the Trusted Publishers list**.
3. Review the trusted publishers list at least annually.

### Step 5 — Implement Change Control for Macro Updates

At ML3, any macro modification requires re-signing, which should be gated by a formal change process.

1. Define a change request template for macro modifications.
2. Require sign-off from the business owner and a security review before re-signing.
3. Maintain a version history for each signed macro.

### ML3 Verification

| Check | Evidence |
|-------|----------|
| All permitted macros are digitally signed | Open a macro-enabled file from a trusted location — confirm signature prompt or silent acceptance based on trusted publisher config |
| Unsigned macros are blocked | Test with an unsigned macro-enabled file from a trusted location — must be blocked |
| Trusted publishers list configured and locked | GPO/Intune configuration screenshot; confirm users cannot add publishers |
| Signing certificate deployed to all endpoints | Intune or GPO certificate deployment confirmation |
| Macro change control process documented | Change management process document with version history examples |

---

## Common Challenges

### Business-Critical Macros Break After Policy Deployment

**Cause**: Macros sourced from paths not declared as trusted locations, or files carrying the Mark of the Web.

**Resolution**: Do not create broad exceptions. Instead, identify the specific file source, establish whether it qualifies as a trusted location, and if so, add the path to the trusted locations register with documented justification. For cloud-sourced files, consider whether the workflow can be redesigned to avoid macro dependency.

### SharePoint and OneDrive Files Are Unexpectedly Blocked

**Cause**: Files downloaded from SharePoint Online or OneDrive to a local drive carry the Mark of the Web, even if the tenant is organisation-controlled.

**Resolution**: Educate users on the distinction between files opened directly in the browser (no Mark of the Web) versus files downloaded and opened locally. For files that must run macros locally, consider declaring a specific SharePoint document library path as a trusted location, subject to your organisation's risk appetite.

### User Workarounds (Unblocking Files Manually)

**Cause**: Users right-click files and select "Unblock" in file properties to remove the Mark of the Web, bypassing the macro policy.

**Resolution**: This behaviour should be detected via endpoint monitoring. Consider using Attack Surface Reduction (ASR) rules in Microsoft Defender for Endpoint to block the `Win32k` macro-from-internet vector directly at the process level, independently of the Office Trust Center setting. Log and investigate unblocking events.

### Macro Policy Not Applying to All Users

**Cause**: GPO not linked or scoped correctly; Intune policy assignment gap; OCPS not synced.

**Resolution**: Audit policy coverage using Intune compliance reports or `gpresult /r` on a sample of endpoints. Confirm the policy is applied under both User Configuration and Computer Configuration as appropriate for your deployment.

---

## Compliance Evidence

The following evidence artefacts are required to demonstrate compliance at audit:

| Artefact | Description |
|----------|-------------|
| Macro policy configuration | GPO settings export, Intune configuration profile JSON, or OCPS policy screenshot |
| Endpoint coverage report | Report showing 100% of managed endpoints have the policy applied |
| Trusted locations register | Documented list of trusted paths with owner, justification, and review date |
| Macro blocking event logs | SIEM export or Office event log entries showing blocked macro attempts |
| User communication record | Evidence that users were notified of the macro policy |
| Exception register | Record of any approved exceptions with business justification and expiry |

For the full compliance report template, see [ML1 Compliance Report Template](reference-ml1-compliance-report-template.md).

---

## Related Resources

### ACSC Authoritative Sources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Restricting Office Macros](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration/system-hardening/restricting-microsoft-office-macros)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)

### Microsoft Documentation

- [Microsoft — Plan for macro settings in Microsoft 365 Apps](https://learn.microsoft.com/en-au/deployoffice/security/internet-macros-blocked)
- [Microsoft — Office ADMX Administrative Templates](https://www.microsoft.com/en-au/download/details.aspx?id=49030)
- [Microsoft — Office Cloud Policy Service overview](https://learn.microsoft.com/en-au/deployoffice/admincenter/overview-office-customization-tool)
- [Microsoft — Trusted locations for Office files](https://support.microsoft.com/en-au/office/add-remove-or-change-a-trusted-location-7ee1cdc2-483e-4cbb-bcbe-f5c5c83d37b1)
- [Microsoft — Defender for Endpoint Attack Surface Reduction rules](https://learn.microsoft.com/en-au/defender-endpoint/attack-surface-reduction-rules-reference)

### Library Cross-References

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md)
- [How to Upgrade from ML1 to ML2](how-to-upgrade-ml1-to-ml2.md)
