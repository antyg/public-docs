---
title: "How to Configure Patch Management"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Configure Patch Management

---

## Overview

This guide explains how to establish patch management infrastructure and processes to satisfy the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) requirements for Strategies 2 (Patch Applications) and 6 (Patch Operating Systems). It covers tooling selection, deployment ring design, patch source validation, exception handling, emergency patching, and compliance monitoring.

For authoritative maturity level requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

For strategy-specific implementation steps, see:

- [How to Implement Patch Applications](how-to-implement-patch-applications.md) — Strategy 2
- [How to Implement Patch Operating Systems](how-to-implement-patch-operating-systems.md) — Strategy 6

---

## Before You Begin

Confirm the following before proceeding:

- An asset inventory exists covering all workstations, servers, and devices in scope.
- Vulnerability severity classifications are agreed across the security and operations teams.
- A test environment mirroring production configuration is available for patch validation.
- Maintenance windows are agreed with application owners for production deployments.
- A patch management tool has been selected or is already in use.

---

## Step 1 — Select a Patch Management Tool

Choose a tool appropriate for your environment. The following options cover common deployment patterns.

### Windows-Centric Environments

| Tool | Use Case |
| ---- | -------- |
| Windows Server Update Services (WSUS) | On-premises centralised update management for Windows OS and Microsoft products |
| Microsoft Endpoint Configuration Manager (SCCM / ConfigMgr) | Full patch lifecycle management with software deployment and comprehensive reporting |
| Microsoft Intune with Windows Update for Business (WUfB) | Cloud-native management for Entra-joined and co-managed devices |
| Azure Update Manager | Hybrid and multi-cloud OS patching for Azure VMs and Arc-connected servers |

**Recommended practice for WSUS:**

- Synchronise updates daily from Microsoft Update.
- Create computer groups aligned to deployment rings (see Step 3).
- Enable automatic approval rules for critical and security updates after ring testing.
- Run cleanup tasks monthly to remove superseded updates and maintain database health.

**Recommended practice for SCCM:**

- Create separate software update groups per calendar month.
- Use maintenance windows scoped to device collections to prevent unscheduled restarts.
- Deploy in phased sequences aligned to deployment rings.
- Monitor the update compliance dashboard to track ring-by-ring rollout status.

**Recommended practice for Intune WUfB:**

- Configure update rings with graduated deferral periods (see Step 3).
- Use quality update deferrals for ML3 environments that require additional soak time.
- Enable Windows Update for Business reports for compliance visibility across the tenant.

### Multi-Platform and Third-Party Patching

For environments that include Linux, macOS, or a broad third-party application catalogue, supplement Microsoft tooling with a multi-platform patch manager:

- **Ivanti Patch Management** — Supports Windows, Linux, and macOS with third-party application patching.
- **ManageEngine Patch Manager Plus** — Comprehensive patching across platforms with agent-based deployment.
- **Automox** — Cloud-native patch management designed for distributed workforces.
- **SolarWinds Patch Manager** — Enterprise-scale patching integrated with SolarWinds monitoring.

**Selection criteria:**

- Platform coverage required (Windows, Linux, macOS).
- Third-party application catalogue breadth.
- Reporting and compliance evidence capabilities.
- Automation and scheduling flexibility.
- Integration with existing SIEM or vulnerability management tooling.

---

## Step 2 — Configure Patch Sources and Validate Integrity

### Trusted Patch Sources

Only retrieve patches from vendor-authorised sources. Reject patches that cannot be signature-verified.

| Platform | Primary Source | Validation Method |
| -------- | -------------- | ----------------- |
| Windows OS | Windows Update / WSUS | Authenticode digital signature |
| Windows applications | Vendor website or Microsoft Store | Authenticode digital signature |
| Linux (Debian/Ubuntu) | Official APT repositories | GPG signature |
| Linux (RHEL/CentOS) | Official YUM/DNF repositories | GPG signature |
| macOS | Apple Software Update / App Store | Apple code signature |
| Microsoft 365 | Office CDN or SCCM distribution point | Authenticode digital signature |
| Web browsers | Vendor auto-update or managed distribution | Authenticode digital signature |
| Adobe products | Adobe Update Server | Authenticode digital signature |

### Validating Patch Integrity Before Deployment

Before deploying any manually acquired patch, verify the following:

1. Confirm the digital signature is valid and the signer certificate matches the expected vendor.
2. Compare the file hash (SHA-256) against the value published in the vendor's security bulletin.
3. Verify the patch was retrieved from the vendor's official distribution channel.
4. Review the release notes for prerequisites and known deployment issues.
5. Check the vendor's support forums and community resources for early reports of deployment problems.

---

## Step 3 — Design Deployment Rings

Deployment rings limit blast radius by exposing patches to progressively larger populations before broad rollout. Every environment should have at minimum three rings.

| Ring | Population | Timing |
| ---- | ---------- | ------ |
| Ring 0 — Pilot | IT staff, 2–5% of devices | Immediately after validation testing |
| Ring 1 — Early Adopters | Representative business users, 10–20% of devices | T+24 hours after Ring 0 success |
| Ring 2 — Broad Deployment | Remaining devices | T+48–72 hours after Ring 1 success |

**Emergency patching exception**: For actively exploited vulnerabilities, compress the ring timeline as described in Step 7.

**For Intune WUfB**, configure rings as update rings with the following deferral structure:

| Ring | Quality Update Deferral | Feature Update Deferral |
| ---- | ----------------------- | ----------------------- |
| Ring 0 | 0 days | 0 days |
| Ring 1 | 2 days | 30 days |
| Ring 2 | 5 days | 60 days |

Adjust deferral periods to your target patch SLA at the applicable maturity level.

---

## Step 4 — Apply ACSC Essential Eight Patching Timeframes

Configure your patch management tooling to enforce the timeframes below. Use SLA tracking in your patch management tool or ITSM platform to alert when systems approach breach.

### Strategy 6 — Patch Operating Systems

| Vulnerability Type | ML1 | ML2 | ML3 |
| ------------------ | --- | --- | --- |
| Extreme risk (actively exploited) | Within 48 hours | Within 48 hours | Within 48 hours |
| Internet-facing services — all security patches | Within 1 month | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| All other systems — all security patches | Within 1 month | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |

### Strategy 2 — Patch Applications

| Application Category | ML1 | ML2 | ML3 |
| -------------------- | --- | --- | --- |
| Internet-facing applications | Within 2 weeks | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| Office productivity suites | Within 2 weeks | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| Web browsers | Within 2 weeks | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| Email clients | Within 2 weeks | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| PDF software | Within 2 weeks | Within 2 weeks | Within 48 hours where feasible, otherwise 2 weeks |
| Java Runtime Environment | As practical | Within 48 hours | Within 48 hours where feasible, otherwise 2 weeks |
| Unsupported applications | Document and plan removal | Remove or isolate | No unsupported software permitted |

Source: [ACSC Essential Eight Maturity Model — October 2024](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)

---

## Step 5 — Configure Platform-Specific Patching

### Windows — Local Group Policy or Intune Configuration Profile

To configure automatic update download with managed approval, set the following registry value via Group Policy or a custom Intune configuration profile (OMA-URI):

```
Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
Name: AUOptions
Value: 3  (Auto download, notify for install)
```

To prevent forced restarts during business hours, configure active hours:

```
Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
Name: SetActiveHours  Value: 1
Name: ActiveHoursStart  Value: 6
Name: ActiveHoursEnd    Value: 22
```

For Intune-managed devices, configure these settings through a Windows Update Ring or a Settings Catalogue profile rather than direct registry injection.

### Linux — Unattended Security Updates

**Ubuntu / Debian:**

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

Confirm that `/etc/apt/apt.conf.d/50unattended-upgrades` includes the security origin:

```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
```

**RHEL / CentOS / Rocky Linux:**

```bash
sudo dnf install dnf-automatic
sudo systemctl enable --now dnf-automatic-install.timer
```

Edit `/etc/dnf/automatic.conf` and set `upgrade_type = security` to restrict automatic updates to security classifications only.

### Microsoft 365 Apps — Update Channel Selection

| Channel | Cadence | Recommended Use |
| ------- | ------- | --------------- |
| Current Channel | Monthly, mid-month | Environments that prioritise fastest security updates |
| Monthly Enterprise Channel | Monthly, second Tuesday | Balance of security currency and predictability (recommended) |
| Semi-Annual Enterprise Channel | Twice yearly | Legacy compatibility environments only |

For Essential Eight compliance, the Monthly Enterprise Channel is the recommended minimum. The Semi-Annual Enterprise Channel does not meet the two-week patching SLA for ML1 and above.

### Web Browsers

- Enable automatic background updates for Chrome, Edge, and Firefox via Group Policy or MDM policy.
- For Edge, deploy `Update/UpdateDefault` policy set to `1` (automatic updates) via Intune or Group Policy.
- For Chrome, configure via the [Chrome Enterprise Bundle](https://chromeenterprise.google/browser/download/) with `AutoUpdateCheckPeriodMinutes` set to a value no greater than 43200 (30 days).
- Verify that no policy setting blocks or disables browser auto-update — this is a common misconfiguration.

---

## Step 6 — Manage Unsupported Software

At ML2 and above, unsupported software must be removed or isolated. The following examples represent commonly encountered end-of-life products.

| Product | End of Support | Required Action (ML1) | Required Action (ML2+) |
| ------- | -------------- | --------------------- | ---------------------- |
| Windows 10 | October 2025 | Document, create upgrade plan | Upgrade to Windows 11 or isolate |
| Windows Server 2016 | January 2027 | Document, create upgrade plan | Upgrade before EOS |
| Internet Explorer 11 | June 2022 | Migrate to Edge or Chrome | Remove |
| Adobe Flash Player | December 2020 | Remove completely | Remove completely |
| Java 8 (public) | December 2020 | Upgrade to Java 11+ | Upgrade to Java 11+ |
| Office 2016 / 2019 | October 2025 | Plan migration to M365 | Migrate before EOS |

If unsupported software cannot be removed, apply the following compensating controls and document the exception formally:

1. Place the system on an isolated network segment with no internet access.
2. Restrict access to the minimum set of users with a documented business need.
3. Implement enhanced endpoint monitoring and alerting.
4. Obtain written risk acceptance from the appropriate risk owner.
5. Set a decommission date no more than 12 months from the acceptance date and track it.

---

## Step 7 — Establish an Emergency Patching Process

Emergency patching applies when a vulnerability is being actively exploited in the wild, a vendor releases an out-of-cycle critical bulletin, or a wormable vulnerability is announced. Under the ACSC Essential Eight, extreme risk vulnerabilities require patching within 48 hours regardless of maturity level.

### Emergency Response Timeline

| Phase | Timeframe | Actions |
| ----- | --------- | ------- |
| Initial assessment | 0–4 hours | Confirm the vulnerability applies to your environment, identify affected systems and versions |
| Emergency testing | 4–24 hours | Rapid validation on representative pilot systems, document any compatibility issues |
| Emergency deployment | 24–48 hours | Deploy to critical and internet-facing systems first using expedited change approval |
| Post-deployment monitoring | 48–72 hours | Verify installation across all affected systems, monitor event logs for issues, remediate failures |

### Expedited Change Approval

Define and document an expedited change approval path before an incident occurs. Typically this involves:

- A pre-authorised emergency change type in the ITSM platform requiring security lead sign-off only.
- Notification to application owners rather than consent, with a defined objection window of two hours or less.
- Mandatory post-implementation review within five business days.

---

## Step 8 — Implement Verification and Compliance Reporting

### Post-Deployment Verification Checklist

After each patch cycle, verify:

- [ ] Patch installation confirmed on all in-scope systems.
- [ ] System restarts completed where required.
- [ ] Critical services and applications functional.
- [ ] No unexpected errors in Windows Event Log or equivalent.
- [ ] Compliance report generated and retained as audit evidence.
- [ ] Failed installations investigated and remediation tracked.

### Key Compliance Metrics

| Metric | ML1 Target | ML2 Target | ML3 Target |
| ------ | ---------- | ---------- | ---------- |
| Extreme risk patch deployment | 95% within 48 hours | 98% within 48 hours | 99% within 48 hours |
| High severity patch deployment | 95% within 2 weeks | 98% within 2 weeks | 98% within 1 week |
| Overall patch compliance | 90% | 95% | 98% |
| Mean time to patch | < 14 days | < 7 days | < 3 days |
| Failed patch installations | < 2% | < 1% | < 0.5% |

### Reporting Cadence

| Frequency | Report Content |
| --------- | -------------- |
| Daily | Critical patch status, failed installations, systems requiring immediate attention |
| Weekly | Patch compliance by device group, outstanding vulnerabilities, active exceptions |
| Monthly | Executive compliance dashboard, trend analysis, exception register review |
| Quarterly | Audit evidence package, process review, tool effectiveness assessment |

Retain patch compliance reports and audit evidence for a minimum of 12 months. Evidence should include approval records, deployment schedules, compliance snapshots, and records of any exceptions granted.

---

## Step 9 — Manage Patch Exceptions

### Exception Criteria

Exceptions to standard patching SLAs may be granted for:

- Vendor-confirmed incompatibility between a patch and a business-critical application.
- Planned system decommission within 90 days where patching is not cost-effective.
- Technical constraints that prevent patch deployment (e.g., hardware compatibility, no vendor support for patching mechanism).

Exceptions are not permitted at ML3 for extreme risk vulnerabilities.

### Exception Documentation Requirements

Every exception record must capture:

| Field | Description |
| ----- | ----------- |
| System or application | Affected asset identifier |
| Patch detail | KB article, CVE, or bulletin reference |
| Business justification | Specific reason the standard timeline cannot be met |
| Risk assessment | CVSS score, exploitability, business impact |
| Compensating controls | Network isolation, enhanced monitoring, access restrictions applied |
| Expiry date | Date by which the exception must be resolved or formally reviewed |
| Approver | Name and role of the risk owner granting acceptance |

Review active exceptions monthly. Any exception exceeding 90 days requires escalation to the CISO or equivalent risk owner.

---

## Step 10 — Rollback a Failed Patch Deployment

Trigger rollback when any of the following conditions are met:

- A business-critical system becomes unresponsive or fails to boot after patching.
- Widespread application failures are reported across the patched population.
- A security control (antivirus, EDR, firewall) is disabled by the patch.
- Data corruption is detected post-patch.

### Windows — Rollback Methods

Remove a specific update using WUSA:

```
wusa /uninstall /kb:XXXXXXX /quiet /norestart
```

Remove a specific update using DISM:

```
DISM /Online /Remove-Package /PackageName:Package_for_KBXXXXXXX
```

For Intune-managed devices, use the **Windows Update** blade in the Intune admin centre to pause the update ring or deploy an uninstall policy.

For SCCM-managed devices, set the deployment to **Required – Uninstall** and target the affected collection.

### Linux — Rollback Methods

**Ubuntu / Debian:**

```bash
sudo apt remove <package-name>
sudo apt install <package-name>=<previous-version>
```

**RHEL / CentOS:**

```bash
sudo dnf history list
sudo dnf history undo <transaction-id>
```

### Documenting Rollback Events

All rollback events must be recorded as incidents in the ITSM platform with the following detail:

- Patch reference (KB, CVE, or bulletin).
- Affected systems and count.
- Symptom description and discovery time.
- Rollback method applied and time to restore.
- Root cause analysis (to be completed within five business days).
- Decision on whether to re-test and redeploy or seek an alternative fix.

---

## Related Resources

### ACSC Authoritative Guidance

- [Essential Eight Maturity Model — ACSC](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [Essential Eight — Strategy 2: Patch Applications — ACSC](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/patch-applications)
- [Essential Eight — Strategy 6: Patch Operating Systems — ACSC](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/patch-operating-systems)
- [Information Security Manual (ISM) — ACSC](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)

### Related How-To Guides

- [How to Implement Patch Applications](how-to-implement-patch-applications.md) — Strategy 2 step-by-step implementation
- [How to Implement Patch Operating Systems](how-to-implement-patch-operating-systems.md) — Strategy 6 step-by-step implementation

### Reference Material

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
