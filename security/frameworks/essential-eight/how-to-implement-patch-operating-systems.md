---
title: "How to Implement Patch Operating Systems"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Patch Operating Systems

---

## Overview

Patch Operating Systems is one of the eight Essential Eight mitigation strategies published by the [Australian Cyber Security Centre (ACSC)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). It requires organisations to apply operating system security patches within defined timeframes, maintain a current inventory of all operating systems in the environment, and eliminate or isolate systems running unsupported OS versions.

Unpatched operating systems are among the most reliably exploited attack surfaces in enterprise environments. Adversaries routinely weaponise publicly disclosed vulnerabilities within hours of patch release. Meeting the ACSC timeframes closes this window before exploitation occurs at scale.

This guide provides goal-oriented steps for implementing Patch Operating Systems at each maturity level. It covers:

- Building an OS inventory and establishing baseline patch compliance
- Deploying and configuring automated patch management tooling
- Defining patch rings and maintenance windows
- Meeting ACSC-mandated patching timeframes at ML1, ML2, and ML3
- Handling legacy and unsupported operating systems
- Collecting compliance evidence for audit

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

**Prerequisites:**

- Patch management infrastructure in place or selected (see tooling options below)
- Change management process established for patch deployment
- Network connectivity between managed endpoints and patch distribution points
- Administrative access to endpoint management consoles

**Tooling options — choose what fits your environment:**

| Platform | Tooling Options |
|---|---|
| Windows (cloud-managed) | Microsoft Intune with Windows Update for Business (WUfB) |
| Windows (on-premises) | Windows Server Update Services (WSUS), Microsoft Configuration Manager (SCCM/ConfigMgr) |
| Windows (hybrid) | Azure Update Manager, Intune co-management with SCCM |
| macOS | Microsoft Intune, Jamf Pro |
| Linux | Native package managers (apt, yum, dnf), Ansible, Azure Update Manager |
| Multi-platform | Azure Update Manager (supports Windows and Linux Azure VMs and Arc-enabled servers) |

---

## Maturity Level 1

**ACSC requirement**: Patch operating systems within 48 hours when a critical security vulnerability exists and there is no patch available, or within 2 weeks when a patch is available. Operating systems that are no longer supported by vendors must not be used.

**Time to achieve ML1**: 4–8 weeks
**Ongoing effort**: 6–10 hours per week

### Step 1 — Build an OS Inventory

Before any patching programme can be measured or managed, you need a complete, accurate record of every operating system in scope.

1. Enumerate all endpoints, servers, and virtual machines across the environment.
2. Record for each system: OS name, version, build number, current patch level, and support status.
3. Flag any systems running operating system versions that have reached end-of-life or end-of-support with their vendor.
4. Document the inventory in a configuration management database (CMDB) or equivalent asset register.

**Acceptance criteria:** Every managed system appears in the inventory with a documented OS version and patch level.

### Step 2 — Retire or Isolate Unsupported Operating Systems

ML1 prohibits the use of operating systems no longer supported by their vendor. Address these before progressing.

1. Review the flagged systems from Step 1.
2. For each unsupported OS, choose one of:
   - **Upgrade**: Migrate to a supported OS version on the same hardware or a replacement.
   - **Decommission**: Retire the system if it no longer serves a business function.
   - **Isolate**: Where upgrade or decommission is not immediately feasible, place the system on a network segment with no connectivity to production systems and document a formal risk acceptance with a defined remediation date.
3. Do not retain unsupported systems in production without explicit risk acceptance and compensating controls.

**Acceptance criteria:** No unsupported OS versions exist in production without documented risk acceptance and network isolation.

### Step 3 — Deploy Automated Patch Management

Manual patching at scale is unreliable and does not meet ACSC timeframes. Automate patch deployment across all managed systems.

**Windows — Intune with Windows Update for Business:**

1. In the Intune admin centre, navigate to **Devices > Windows > Update rings for Windows 10 and later**.
2. Create an update ring policy targeting your managed Windows devices.
3. Set the **Quality update deferral period** to 0 days for the production ring (critical patches deploy immediately).
4. Configure **Active hours** to limit reboots to maintenance windows.
5. Assign the policy to device groups aligned with your ring structure (see Step 4).

**Windows — WSUS:**

1. Configure WSUS to synchronise daily.
2. Enable automatic approval rules for **Critical** and **Security** update classifications.
3. Set approval deadlines to enforce deployment within 48 hours of approval for critical classifications.
4. Configure client-side Group Policy to point to the WSUS server and set the detection/download/install schedule.

**Windows — Azure Update Manager:**

1. Enable Update Manager on target subscriptions in the Azure portal.
2. Create a maintenance configuration with a schedule that meets the 48-hour window.
3. Assign the maintenance configuration to machines via policy or direct assignment.

**macOS — Intune:**

1. In the Intune admin centre, navigate to **Devices > macOS > Update policies for macOS**.
2. Create an update policy and set the **Update type** to install critical updates immediately.
3. Assign to macOS device groups.

**Linux:**

1. Configure the appropriate package manager to receive security updates automatically (e.g., `unattended-upgrades` for Debian/Ubuntu, `dnf-automatic` for RHEL/Fedora).
2. Restrict automatic upgrades to the security channel only to avoid unplanned package changes.
3. Schedule a maintenance window for the automatic service restart after patching.

**Acceptance criteria:** Automated patching is active for at least 90% of managed systems.

### Step 4 — Establish Patch Rings

Patch rings reduce the risk of a defective patch causing widespread disruption by staging deployment across device populations.

| Ring | Population | Deployment trigger |
|---|---|---|
| Ring 0 — Pilot | IT team devices (24 hours post-release) | Automatic on release |
| Ring 1 — Early | Broader pilot group, ~10% of estate (48 hours post-release) | Automatic after Ring 0 soak |
| Ring 2 — Production | All remaining systems | Critical: within 48 hours; extreme risk with no patch: within 2 weeks |

Configure ring membership in your patch management tooling using device groups or collection membership.

**Acceptance criteria:** All devices assigned to a ring; Ring 2 deployment completes within the ACSC timeframe.

### Step 5 — Establish Testing and Rollback Procedures

1. Before approving patches to Ring 2, validate them on Ring 0 for at least 24 hours.
2. Document any compatibility issues discovered during Ring 0 or Ring 1 soak periods.
3. Define a rollback procedure for each platform — for Windows this typically means uninstalling the update via Intune, WSUS, or the Windows Update agent.
4. Maintain rollback capability for at least 30 days after patch deployment.

**Acceptance criteria:** A written rollback procedure exists and has been tested at least once.

### Step 6 — Configure Compliance Monitoring

1. Create compliance policies or reports in your patch management tooling that show the patch status of every managed system.
2. Set alerts for systems that have not received a critical patch within 48 hours of release.
3. Review the compliance report weekly and remediate non-compliant systems promptly.
4. Target and maintain patch compliance above 95%.

**Acceptance criteria:** Weekly compliance reports produced; non-compliant systems remediated within one business day of alert.

---

## Maturity Level 2

**ACSC requirement**: Patch operating systems within 48 hours when a vulnerability is being actively exploited, or within 2 weeks for all other vulnerabilities. Operating systems that are no longer supported by vendors must not be used.

ML2 tightens the timeframe for actively exploited vulnerabilities and expects broader coverage including server workloads, not just workstations.

**Prerequisites:** Full ML1 compliance validated.

### Step 1 — Validate ML1 Completeness

Before implementing ML2 enhancements, confirm that every ML1 requirement is fully met:

1. Run a full compliance report across all platforms.
2. Confirm no unsupported OS versions remain in production.
3. Confirm patch compliance exceeds 95% for all device populations.
4. Resolve any outstanding ML1 gaps before proceeding.

### Step 2 — Expand Coverage to Servers

ML2 expects the patching programme to cover all operating systems in the environment, including servers, not only user workstations.

1. Bring all server workloads into scope in your patch management tooling.
2. Create separate patch rings for servers, with maintenance windows that respect application change windows (e.g., weekend nights, low-traffic periods).
3. Coordinate with application owners to schedule server reboots within the 48-hour window for actively exploited vulnerabilities.
4. Use Azure Update Manager or SCCM maintenance windows for server ring management.

**Acceptance criteria:** Server patch compliance visible in the same compliance dashboard as workstations, meeting the same timeframes.

### Step 3 — Integrate with Threat Intelligence for Active Exploitation Signals

ML2 requires distinguishing between actively exploited vulnerabilities (48-hour response) and all other vulnerabilities (2-week response). This distinction requires a signal source.

1. Subscribe to [ACSC Alert and Advisory Service](https://www.cyber.gov.au/about-us/view-all-content/alerts-and-advisories) to receive notifications of vulnerabilities being actively exploited in the Australian context.
2. Monitor the [CISA Known Exploited Vulnerabilities Catalogue](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) as a supplementary signal for active exploitation status.
3. Establish an internal process for triaging incoming CVEs against your OS inventory: when active exploitation is confirmed, trigger the 48-hour ring regardless of the normal ring schedule.
4. Document each triage decision with the CVE identifier, exploitation status determination, deployment date, and outcome.

**Acceptance criteria:** Written triage procedure exists; documented evidence of at least one 48-hour patch deployment triggered by active exploitation signal.

### Step 4 — Tighten Ring 2 Deployment Cadence

Update your ring configuration to reflect the ML2 distinction:

1. For vulnerabilities with confirmed active exploitation: override Ring 2 deferral and deploy within 48 hours.
2. For all other vulnerabilities: deploy to Ring 2 within 2 weeks.
3. Configure alerts to fire when the 48-hour window is at risk (e.g., at 36 hours post-approval with Ring 2 compliance below 100%).

---

## Maturity Level 3

**ACSC requirement**: Patch operating systems within 48 hours for all vulnerabilities, regardless of exploitation status. Operating systems that are no longer supported by vendors must not be used.

ML3 removes the distinction between actively exploited and other vulnerabilities. All security patches must reach the full environment within 48 hours of release.

**Prerequisites:** Full ML2 compliance validated.

### Step 1 — Eliminate the 2-Week Track

1. Update all patch ring policies to remove the 2-week production deferral.
2. Set the maximum deployment timeline for all security patches to 48 hours across all rings.
3. Reduce Ring 0 and Ring 1 soak periods to allow Ring 2 to complete within 48 hours. A workable schedule: Ring 0 at 0–12 hours, Ring 1 at 12–24 hours, Ring 2 at 24–48 hours.

**Acceptance criteria:** No active patch policy has a deferral period exceeding 48 hours for security-classified updates.

### Step 2 — Accelerate Server Patching

The 48-hour universal window applies to servers as well as workstations. This requires tighter coordination with application and infrastructure owners.

1. Establish a standing change advisory process that pre-approves emergency OS patching within the 48-hour window — do not require a full change request for each patch cycle.
2. Configure automated reboot schedules for servers outside production hours but within the 48-hour window.
3. Use rolling restart groups for clustered or highly available services to maintain service continuity while meeting the patching timeframe.

**Acceptance criteria:** Server patch compliance meets the 48-hour window in compliance reports.

### Step 3 — Automate Patch Testing at Scale

Compressing Ring 0 and Ring 1 soak periods to 12–24 hours each requires automated testing to replace manual validation.

1. Implement automated smoke tests that run on Ring 0 systems after patch deployment — validate core OS functions, network connectivity, authentication, and key line-of-business application launch.
2. Configure the ring advancement workflow to gate Ring 1 and Ring 2 deployments on automated test pass results.
3. Define a threshold for automatic ring advancement (e.g., >98% of Ring 0 devices pass smoke tests with no critical failures) and automatic halt with escalation if below threshold.

**Acceptance criteria:** Ring advancement is gated on automated test results; no manual approval step delays the 48-hour timeline.

### Step 4 — Continuous Compliance Verification

At ML3, compliance monitoring shifts from weekly reporting to continuous verification.

1. Configure real-time dashboards showing patch compliance by ring, platform, and time since patch release.
2. Set automated escalation alerts at 36 hours post-release for any system not yet patched.
3. Integrate patch compliance data into your security information and event management (SIEM) platform for correlation with other security signals.

---

## Handling Legacy and End-of-Life Operating Systems

Legacy systems present a recurring challenge in OS patching programmes. The ACSC position at all maturity levels is that unsupported operating systems must not be in use. Where immediate retirement is not feasible, apply the following controls:

| Situation | Required action |
|---|---|
| OS version approaching end-of-support within 12 months | Document upgrade plan with target date; begin testing upgrade path |
| OS version reached end-of-support; upgrade in progress | Network isolation (no internet, limited lateral movement); document formal risk acceptance; set hard decommission date |
| OS version reached end-of-support; no upgrade path | Decommission. If business-critical, isolate to a dedicated VLAN with no trust relationships to production; engage vendor for extended security updates if available |
| Embedded or OT systems with vendor-locked OS | Engage vendor; apply compensating controls (application-layer controls, network micro-segmentation); document explicitly in risk register |

Do not accept risk without a defined and tracked remediation date. Risk acceptances with no expiry date are not compliant with the spirit of the ACSC framework.

---

## Common Challenges

| Challenge | Recommended approach |
|---|---|
| Operational disruption from reboots | Schedule reboots during agreed maintenance windows; use Windows Update for Business active hours; use rolling restart groups for clustered services |
| Patch failures | Monitor for deployment failures in patch management tooling; investigate root cause (disk space, agent health, connectivity); remediate within 24 hours of alert |
| Application compatibility issues | Maintain a compatibility test suite on Ring 0; engage application owners before Ring 2 deployment; use rollback procedures where needed |
| Large, distributed or remote device populations | Ensure device check-in cadence is frequent enough to receive policies; use delivery optimisation or WSUS/distribution points to reduce WAN traffic |
| Unsupported OS retirement blocked by vendors | Escalate to CISO for risk acceptance; document formally; set a non-negotiable decommission date; never accept "no plan" as a status |

---

## Verification and Evidence Collection

Maintain the following evidence to demonstrate compliance at audit:

| Evidence item | Purpose |
|---|---|
| OS inventory with version and patch level | Demonstrates full scope coverage |
| OS patching policy (written) | Demonstrates governance and timeframe commitments |
| Patch management procedures (written) | Demonstrates operational process |
| Patch compliance reports (weekly minimum) | Demonstrates ongoing compliance |
| Evidence of patches deployed within 48 hours (or 2 weeks) for each critical vulnerability | Demonstrates ACSC timeframe adherence |
| Documentation of any unsupported OS with risk acceptance, isolation evidence, and remediation date | Demonstrates exception management |
| Triage records for actively exploited vulnerabilities (ML2+) | Demonstrates correct timeframe selection |

Store evidence in a location accessible to your audit team. At a minimum, retain 12 months of compliance reports.

---

## Related Resources

### ACSC

- [ACSC Essential Eight — Patch Operating Systems](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/patch-operating-systems)
- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Alerts and Advisories](https://www.cyber.gov.au/about-us/view-all-content/alerts-and-advisories)

### This Library

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md)
