---
title: "How to Implement Patch Applications"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Patch Applications

---

## Overview

This guide provides per-maturity-level implementation steps for the ACSC Essential Eight Patch Applications control. It covers application inventory, patch management tooling, patching schedules, automation, compliance verification, and audit evidence collection.

Patch Applications requires that security vulnerabilities in applications are remediated within defined timeframes. Unpatched applications remain one of the most commonly exploited attack vectors. This control directly reduces exposure by ensuring known vulnerabilities are closed before adversaries can exploit them.

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Prerequisites

Before beginning implementation, confirm the following are in place:

- An asset management system or process capable of recording all installed applications across the estate
- A change management process that covers emergency and scheduled patching
- A patch management tool or platform (see [Step 2](#step-2-deploy-a-patch-management-platform) below for options)
- A non-production environment for patch testing prior to broad deployment
- Defined maintenance windows for systems that cannot tolerate unscheduled restarts

---

## Maturity Level 1

### Objective

Establish a repeatable process to patch applications within 48 hours of a security update being released for vulnerabilities rated as critical or high severity. For applications assessed as presenting extreme risk to the organisation if patched immediately (for example, where patching would cause an outage of a critical service), patching within two weeks is acceptable provided a documented risk decision is made.

---

### Step 1 — Build an Application Inventory

Discover and document all applications installed across the estate before configuring any patching policy. Without an accurate inventory, coverage gaps will remain invisible.

1. Run a discovery scan across all endpoints and servers using your asset management or endpoint management platform. Common options include Microsoft Intune (Apps inventory), Microsoft Configuration Manager (SCCM) software inventory, or a third-party tool such as ManageEngine Desktop Central or Ivanti Neurons.
2. Export the full list of installed applications with version numbers.
3. Identify internet-facing applications and applications that process untrusted data — these carry higher risk and should be prioritised.
4. Document the patch source for each application:
   - Microsoft products: [Microsoft Update Catalogue](https://www.catalog.update.microsoft.com/) or Windows Update
   - Adobe products: Adobe Update Server or Creative Cloud Admin Console
   - Google Chrome / Microsoft Edge: vendor auto-update mechanisms
   - Third-party applications: vendor release pages or integrated patch management
5. Flag any applications that have reached end-of-life with no patch support. These require a separate risk treatment (upgrade, replacement, or isolation).

**Deliverable**: A documented application register that includes vendor, current version, patch source, and risk classification.

---

### Step 2 — Deploy a Patch Management Platform

Select and configure a platform that can deploy application updates to managed endpoints. The platform must be capable of reporting patch compliance status.

**Options:**

| Platform | Best Suited For |
|---|---|
| Microsoft Intune | Cloud-managed or Entra-joined devices; modern management |
| Windows Update for Business | Microsoft application updates on domain-joined or Entra-joined devices |
| Microsoft Configuration Manager (SCCM/ConfigMgr) | On-premises or hybrid environments with existing ConfigMgr infrastructure |
| WSUS (Windows Server Update Services) | On-premises environments; Microsoft products only |
| Ivanti Neurons / Patch for Endpoints | Heterogeneous environments; broad third-party application coverage |
| ManageEngine Patch Manager Plus | Small to medium organisations; cross-platform patching |

**For Microsoft Intune environments:**

1. Navigate to **Devices > Windows > Update rings for Windows 10 and later** in the [Microsoft Intune admin centre](https://intune.microsoft.com/).
2. Create an update ring for each deployment group (pilot, broad production).
3. For third-party application patching, use **Apps > Windows > Add** to deploy updated application packages, or configure the Intune Management Extension to invoke vendor update mechanisms.

**For SCCM/ConfigMgr environments:**

1. Enable Software Update Point and synchronise the Microsoft Update Catalogue.
2. Create Software Update Groups aligned to your patch schedule.
3. Deploy update groups to device collections using maintenance window schedules.
4. For third-party applications, use third-party software update catalogues or integrate a third-party patch content provider.

Regardless of platform, configure **update rings** or **deployment collections** that separate pilot devices from the broader production population. This allows patches to be validated at small scale before full deployment.

---

### Step 3 — Define the Patching Schedule

Establish formal patching timeframes in a documented patch management policy. The policy must specify:

| Severity | Timeframe |
|---|---|
| Critical / actively exploited vulnerabilities | 48 hours from patch availability |
| High severity | 48 hours from patch availability (ML1) |
| Extreme risk exception (documented risk decision required) | Within 2 weeks |
| Medium severity | Within 1 month |
| Low severity | At next scheduled maintenance cycle |

**Key points:**

- The 48-hour clock starts when the vendor publishes the patch, not when your organisation becomes aware of it. Subscribe to vendor security advisories and the [ACSC Alerts and Advisories](https://www.cyber.gov.au/about-us/view-all-content/alerts-and-advisories) feed to minimise detection lag.
- Extreme risk exceptions must be formally documented with a risk owner, rationale, compensating controls, and a commitment to patch within 2 weeks. Do not treat the 2-week window as the default — it applies only to documented exceptional cases.
- Schedule maintenance windows for systems requiring planned restarts. Maintenance windows must not extend beyond the required patching timeframe for critical vulnerabilities.

---

### Step 4 — Enable Automation for Common Applications

Automate patching for applications where the vendor provides reliable auto-update mechanisms. This reduces manual effort and improves time-to-patch for high-coverage applications.

**Applications commonly supporting auto-update:**

- **Google Chrome**: Auto-update is enabled by default. Confirm via Group Policy (`Update/AutoUpdateCheckPeriodMinutes`) or Intune configuration profile that auto-update is not disabled.
- **Microsoft Edge**: Managed via Windows Update or the EdgeUpdate policies. Confirm `Update/UpdateDefault` is set to allow automatic updates.
- **Adobe Acrobat / Adobe Reader**: Configure the Adobe Update Manager via the [Adobe Customisation Wizard](https://www.adobe.com/devnet-docs/acrobatetk/tools/Customization/index.html) or managed update policies.
- **Microsoft 365 Apps (Office)**: Configure the update channel and frequency via [Microsoft 365 Apps admin centre](https://config.office.com/) or Group Policy. Current Channel provides the fastest security update cadence.
- **7-Zip, VLC, and other open-source utilities**: These typically lack enterprise auto-update. Manage via your patch management platform.

**Automation target**: Aim for at least 80 percent of applications receiving patches through automated mechanisms. Document the remainder as requiring manual patching procedures.

---

### Step 5 — Establish a Manual Patching Process for Remaining Applications

For applications not covered by automation, define a repeatable manual process:

1. **Weekly vulnerability scan**: Run authenticated vulnerability scans across the estate using a scanner such as Microsoft Defender Vulnerability Management, Tenable Nessus, or Rapid7 InsightVM.
2. **Triage and prioritise**: Review scan output against the severity-to-timeframe mapping from Step 3.
3. **Test in a non-production environment**: Deploy the patch to a representative non-production system. Verify application functionality. Document the test outcome.
4. **Change control approval**: Raise a change request. For critical vulnerabilities, use the emergency change process — do not let standard change lead times cause a breach of the 48-hour requirement.
5. **Deploy to production**: Deploy via your patch management platform or manual installation, within the required timeframe.
6. **Verify installation**: Confirm the patch is installed and the vulnerability is resolved. Update the patch register.

---

### Verification — ML1

Confirm the following before claiming ML1 compliance:

- [ ] Application inventory is complete and includes version and patch status for all applications
- [ ] A patch management platform is deployed and reporting compliance data
- [ ] The patching policy documents the 48-hour (or 2-week extreme risk) timeframe
- [ ] Critical patches have been deployed within 48 hours in recent history — verify against patch compliance reports
- [ ] Patch compliance rate is at or above 95 percent of managed endpoints
- [ ] Auto-update is enabled for Chrome, Edge, and Microsoft 365 Apps
- [ ] A manual patching process exists and has been exercised

---

## Maturity Level 2

### Objective

ML2 refines the patching requirement for active exploitability. The timeframe distinction between ML1 and ML2 for Patch Applications is subtle but important:

| Condition | ML1 | ML2 |
|---|---|---|
| Vulnerabilities being actively exploited in the wild | 48 hours | 48 hours |
| Other critical / high severity vulnerabilities | 48 hours | Within 2 weeks |

At ML2, you differentiate response timeframes based on active exploitation status. This requires integration with threat intelligence feeds to determine whether a vulnerability is being actively exploited.

---

### Step 1 — Integrate Threat Intelligence for Active Exploitation Awareness

Subscribe to threat intelligence sources that identify whether a vulnerability is being actively exploited:

- [ACSC Alerts and Advisories](https://www.cyber.gov.au/about-us/view-all-content/alerts-and-advisories) — authoritative source for Australian context
- [CISA Known Exploited Vulnerabilities Catalogue](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) — US-origin but widely used for exploitation status
- Vendor security advisories (Microsoft Security Response Centre, Adobe Security Bulletins, etc.)
- Your vulnerability scanner's threat intelligence feed (Defender Vulnerability Management, Tenable, Rapid7)

Establish a daily review process for new vulnerability disclosures. When a vulnerability affecting your estate is disclosed, immediately determine whether it is listed as actively exploited.

---

### Step 2 — Implement Risk-Tiered Patching Queues

Update your patch management process to operate two queues:

**Queue 1 — Active Exploitation (48 hours)**
Vulnerabilities confirmed as being actively exploited in the wild. These require emergency change processes and immediate deployment.

**Queue 2 — Non-Active Exploitation (within 2 weeks)**
Critical and high severity vulnerabilities without confirmed active exploitation. These can follow a standard patching cycle, provided deployment completes within 2 weeks.

Configure your patch management platform to tag or flag patches based on exploitation status and generate alerts when Queue 1 patches are available.

---

### Step 3 — Expand Coverage to Internet-Facing Services

At ML2, extend patching coverage beyond endpoints to all internet-facing services and systems:

- Web servers and reverse proxies
- Remote access solutions (VPN endpoints, Remote Desktop Gateway, Citrix)
- Email platforms and associated components
- Any server directly accessible from the internet

These systems are at greatest risk from exploitation of unpatched vulnerabilities and must be included in patch compliance reporting.

---

### Step 4 — Automate Compliance Reporting

At ML2, manual review of patch status is insufficient. Implement automated compliance dashboards or scheduled reports that show:

- Percentage of endpoints patched within required timeframes
- Unpatched vulnerabilities grouped by severity and exploitation status
- Devices that are out-of-scope (for example, decommissioned but not yet removed from inventory)
- Trend data showing compliance over time

Microsoft Defender Vulnerability Management provides this data within the Intune or Microsoft 365 Defender portals. Third-party scanners provide similar dashboards. Establish a weekly review cadence for these reports.

---

### Verification — ML2

- [ ] Threat intelligence integration is in place to identify actively exploited vulnerabilities
- [ ] Patching queues differentiate between actively exploited (48 hours) and other vulnerabilities (within 2 weeks)
- [ ] Coverage extends to internet-facing services and servers
- [ ] Automated compliance reports are generated and reviewed weekly
- [ ] Evidence of the two-queue model exists in the patch management platform configuration

---

## Maturity Level 3

### Objective

At ML3, the distinction between exploitation status is removed. All critical and high severity vulnerabilities must be patched within 48 hours regardless of whether active exploitation has been observed. This requires a mature, largely automated patching capability with minimal manual intervention.

---

### Step 1 — Achieve Near-Automated Patching for All Applications

Review the full application inventory and eliminate manual patching processes wherever technically feasible:

- **Enterprise patch management platforms**: Ensure all applications are covered by your patch management platform with automated deployment rules.
- **Vendor update integration**: For applications with vendor-managed update services (Chrome Enterprise, Edge, Microsoft 365 Apps), confirm that update policies enforce immediate deployment of security updates without user deferral options.
- **Containerised workloads**: If containers or virtual machines are in use, establish a pipeline to rebuild images and redeploy within 48 hours of a base image patch being released.

Residual manual processes must be documented with justification and subject to enhanced monitoring.

---

### Step 2 — Implement Emergency Patching Capability

The 48-hour requirement for all vulnerabilities at ML3 demands an emergency patching capability that does not depend on scheduled maintenance windows:

1. Establish an emergency patching procedure that bypasses the standard change calendar.
2. Authorise a defined approval pathway (for example, security team lead approval rather than CAB) for emergency patches.
3. Test the emergency patching procedure at least annually to confirm it can meet the 48-hour requirement.
4. Document how emergency patches are handled for systems where 48-hour patching would cause unacceptable service disruption — these cases require a formal compensating control.

---

### Step 3 — Implement Continuous Vulnerability Scanning

At ML3, point-in-time vulnerability scanning is insufficient. Implement continuous or near-real-time scanning:

- Microsoft Defender Vulnerability Management provides continuous discovery and assessment when the Defender for Endpoint sensor is deployed.
- Authenticated network scanning tools (Tenable.io, Rapid7 InsightVM) configured for daily or continuous scanning cadences are also appropriate.

Continuous scanning ensures that newly discovered vulnerabilities are identified and actioned within the 48-hour window from patch availability, rather than being detected only at the next scheduled scan cycle.

---

### Step 4 — Implement Patch Compliance Alerting

Configure automated alerting when patch compliance falls below thresholds:

- Alert immediately when an actively exploited or critical vulnerability is published that affects the estate
- Alert when any managed device exceeds 24 hours without applying a critical patch (providing buffer before the 48-hour deadline)
- Alert when overall patch compliance drops below 98 percent

These alerts should route to the security operations team and trigger a documented response process.

---

### Verification — ML3

- [ ] All critical and high severity vulnerabilities are being patched within 48 hours regardless of exploitation status
- [ ] Patch compliance rate is at or above 98 percent
- [ ] Continuous vulnerability scanning is operational
- [ ] Emergency patching capability has been tested and documented
- [ ] Automated alerting is in place for compliance threshold breaches
- [ ] Coverage extends to all systems including servers, internet-facing services, and endpoints

---

## Audit Evidence

Collect the following evidence to support an Essential Eight assessment against the Patch Applications control:

| Evidence Item | Description |
|---|---|
| Patch management policy | Documented timeframes, scope, exception process, and risk decision framework |
| Patching procedures | Step-by-step procedures for both automated and manual patching |
| Application inventory | Current register showing all applications, versions, and patch status |
| Patch compliance reports | Reports demonstrating percentage of endpoints patched within required timeframes |
| Vulnerability scan reports | Output from authenticated scans showing open and resolved vulnerabilities with dates |
| Evidence of 48-hour patching | Timestamped records showing critical patches deployed within 48 hours of release |
| Extreme risk exception register | Documented risk decisions for any patches deferred beyond 48 hours (ML1/ML2 only) |
| Emergency patching records | Records of emergency change requests and deployment for actively exploited vulnerabilities |

Auditors will look for evidence that the patching timeframes have been met consistently, not just at the point of assessment. Retain patch deployment logs and compliance reports for at least 12 months.

---

## Common Challenges

**Legacy applications that do not support patching**
Applications that are end-of-life or that have no available patch for a known vulnerability require a compensating control strategy. Options include network isolation, application removal, or vendor engagement for a fix. Each unpatched legacy application must be recorded in a risk register with a treatment plan and owner.

**Patches that cause application breakage**
Test patches in a non-production environment before broad deployment. Maintain a rollback procedure for each critical application. Where a patch cannot be applied due to breakage, raise a formal exception and apply mitigating controls (such as network segmentation or blocking of the exploited attack vector) while a resolution is pursued.

**User disruption during patching**
Schedule patch deployments during agreed maintenance windows. For critical patches that must be applied within 48 hours, communicate the planned restart to affected users as early as possible. Avoid allowing user deferral options for security patches — if users can indefinitely defer a restart, the 48-hour requirement cannot be met.

**Third-party applications without enterprise update support**
Applications that lack an enterprise update mechanism require integration into your patch management platform as managed packages, or replacement with alternatives that support managed deployment. Packaging tools such as the Microsoft Win32 Content Prep Tool (for Intune) or ConfigMgr package creation workflows support this.

**Patch compliance tracking across a heterogeneous estate**
A single patch management platform rarely covers all application types across all operating systems. Use a vulnerability scanner as the authoritative source of truth for compliance reporting, as it provides a platform-agnostic view across the estate. Feed scanner output into your SIEM or compliance dashboard.

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Alerts and Advisories](https://www.cyber.gov.au/about-us/view-all-content/alerts-and-advisories)
- [ACSC Essential Eight — Patch Applications](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-explained/patch-applications)
- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md)
