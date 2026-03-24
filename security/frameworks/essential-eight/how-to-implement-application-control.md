---
title: "How to Implement Application Control"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Application Control

---

## Overview

Application control prevents unauthorised software from executing on your endpoints and servers. Under the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight), it is the first and highest-priority mitigation strategy because it directly interrupts the most common attack chain: an adversary delivers a malicious executable, script, or library and runs it on a victim system.

This guide walks through the practical steps to implement application control at each maturity level — from initial inventory through to enforced allowlisting across your full estate. Follow these steps to achieve Maturity Level 1 (ML1), then progress to ML2 and ML3.

For background on maturity level requirements and assessment criteria, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md). For a cross-control overview of the implementation approach, see [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md).

For authoritative ACSC requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

### Prerequisites

- An up-to-date asset inventory covering all workstations and servers in scope
- A software discovery mechanism (endpoint management platform, vulnerability scanner, or equivalent)
- An endpoint management platform capable of deploying and enforcing policies (Microsoft Intune, Group Policy, or equivalent)
- A defined exception request and approval process with a nominated approver

### Scope at Each Maturity Level

| Maturity Level | Minimum Scope |
|---|---|
| ML1 | All workstations |
| ML2 | All workstations and internet-facing servers |
| ML3 | All workstations and all servers; comprehensive allowlisting with advanced logging |

Start with workstations. Adding servers to scope before your workstation policy is stable will increase exception volume and slow the rollout.

### Technology Options

Application control on Windows can be implemented using:

- **App Control for Business (formerly Windows Defender Application Control / WDAC)** — kernel-enforced, recommended for all new deployments
- **AppLocker** — rules-based, available on Windows 10/11 Enterprise and Windows Server; appropriate where WDAC is not yet viable
- **Hybrid** — WDAC on workstations, AppLocker on servers where WDAC is not yet supported

Whichever technology you use, policies are typically deployed via Microsoft Intune (cloud-managed) or Group Policy (domain-joined environments). For guidance on choosing between these delivery mechanisms, see [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md).

---

## Maturity Level 1

**Objective**: Prevent execution of unapproved applications on all workstations using a deny-by-default allowlist policy.

**Estimated time to ML1**: 8–12 weeks.

### Step 1 — Build an Application Inventory

Discover every executable, script, installer, and library running across your workstations before you write a single rule. Policies built without a complete inventory block legitimate software, which generates excessive exceptions and erodes trust in the control.

1. Run a software discovery scan across all workstations in scope.
2. Export the full installed application list and running process inventory.
3. For each application, record: publisher, signing status (signed/unsigned), version, and business owner.
4. Identify which applications are business-critical and which are candidates for removal.
5. Flag unsigned applications — these require hash-based or path-based rules rather than publisher rules and need additional justification.

Document your approved application list. This list is the foundation of your allowlist policy and must be maintained going forward.

### Step 2 — Choose Your Rule Strategy

Use the most restrictive rule type your applications support:

| Rule Type | When to Use | Risk Level |
|---|---|---|
| Publisher (certificate) rule | Application is signed by a trusted publisher | Lowest |
| File hash rule | Application is unsigned or publisher rule is not available | Medium — hash changes on every update |
| Path rule | Only as a last resort for controlled directories | Highest — avoid where possible |

For signed applications, create publisher rules scoped to the specific publisher and product name. Avoid overly broad publisher rules (e.g., allowing everything signed by Microsoft) without additional constraints. For unsigned internal applications, create hash rules and establish a process to update hashes when the application is updated.

Start with [Microsoft's recommended driver block rules](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/design/microsoft-recommended-driver-block-rules) and [user mode block rules](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/design/applications-that-can-bypass-app-control) as your baseline deny list.

### Step 3 — Deploy in Audit Mode

Do not enforce policies until they have been validated in audit mode. Enforcing untested policies blocks legitimate applications and undermines confidence in the control.

1. Create your allowlist policy in audit mode.
2. Deploy to a representative pilot group (recommended: the IT team first).
3. Monitor audit logs for 2–4 weeks. Collect all would-be block events.
4. For each blocked item, determine whether it is:
   - A legitimate application that needs to be added to the allowlist
   - A redundant or unapproved application that should remain blocked
5. Refine the policy to resolve all legitimate gaps.
6. Repeat the audit cycle with a broader pilot group before enforcing.

Communicate with users during the audit phase. Let them know what is being monitored and how to report if a business application appears in the blocked list.

### Step 4 — Enable Enforcement (Phased Rollout)

Enforce the policy in waves to limit the blast radius of any missed applications.

1. Enforce on the IT pilot group first. Stabilise for 1–2 weeks.
2. Expand to a broader representative sample (approximately 10–20% of workstations).
3. Monitor exception requests. Resolve legitimate gaps within 4 business hours.
4. Roll out to all remaining workstations in batches of 20–30%.
5. Once 100% coverage is achieved, confirm enforcement via your endpoint management compliance reports.

Maintain a rapid exception process throughout the rollout. Slow exception resolution is the primary cause of enforcement rollbacks.

### Step 5 — Validate ML1 Compliance

Before claiming ML1, verify:

- All workstations have the application control policy applied and enforced (not just deployed).
- The exception rate (legitimate applications incorrectly blocked) is below 5%.
- An exception register is in place and exceptions are reviewed.
- Event logs capture blocked application execution attempts.
- Policy documents and configuration exports are available for audit.

**Evidence to collect for ML1 audit:**
- Application control policy document (WDAC XML or AppLocker export)
- Endpoint management compliance report showing policy deployment coverage
- Event log samples showing blocked execution events
- Exception register

---

## Maturity Level 2

**Objective**: Extend application control to internet-facing servers and maintain the allowlist through a formal review process.

**Estimated time from ML1 to ML2**: 6–12 months.

### Step 1 — Extend Scope to Internet-Facing Servers

Repeat the inventory, audit-mode, and enforcement sequence for all internet-facing servers. Server environments typically have:

- More complex dependencies (services, scheduled tasks, scripts)
- Longer audit periods required before enforcement
- Greater potential impact from incorrect blocks

Prioritise servers with the highest exposure: web servers, reverse proxies, mail gateways, and remote access infrastructure.

### Step 2 — Implement Deny-by-Default Across All Workstations and Internet-Facing Servers

Confirm that your policies use a deny-by-default posture. Any executable, script, library, or installer not explicitly permitted must be blocked. Review your policies for any overly permissive rules (e.g., allow-all path rules, overly broad publisher rules) introduced during the ML1 rollout and tighten them.

### Step 3 — Establish a Formal Allowlist Review Process

The ACSC requires that the allowlist is maintained and reviewed at least annually at ML2. Implement:

- A change management process for adding new applications to the allowlist
- An annual review of the allowlist to remove applications that are no longer required
- A documented approval workflow for exception requests (request, justification, approval, time-limit, review date)

### Step 4 — Validate ML2 Compliance

Before claiming ML2, verify:

- Application control is enforced on all workstations and all internet-facing servers.
- A deny-by-default policy is in place (no open path rules or unrestricted publisher rules).
- The allowlist has been reviewed within the last 12 months.
- The exception register is current.

**Additional evidence to collect for ML2 audit:**
- Evidence of server-scope coverage (compliance reports for server groups)
- Allowlist review records with dates and approvals
- Updated exception register with business justification per entry

---

## Maturity Level 3

**Objective**: Comprehensive allowlisting across all workstations and servers with advanced logging and alerting.

**Estimated time from ML2 to ML3**: 12–18 months.

### Step 1 — Extend Scope to All Servers

Extend application control enforcement to all servers in your estate — not only internet-facing servers. This includes internal application servers, file servers, and database servers.

Apply the same audit-mode, phased-enforcement approach used for workstations and internet-facing servers. The audit period for internal servers may be longer due to batch processes, scheduled tasks, and maintenance scripts that run infrequently.

### Step 2 — Implement Comprehensive Allowlisting

At ML3, the ACSC expects that allowlisting is comprehensive — not just covering user-executed applications, but also:

- Scripts (PowerShell, VBScript, JScript, batch files)
- Compiled HTML applications (.chm)
- Dynamic-link libraries (DLLs) and drivers
- Installers

Review your policies to confirm all these file types are in scope. Consider enabling [Windows Script Host restrictions](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/design/script-enforcement) and [PowerShell Constrained Language Mode](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes) to reinforce script control.

### Step 3 — Implement Advanced Logging and Alerting

At ML3, blocked execution attempts must generate alerts reviewed in a timely manner. Implement:

- Centralised log collection for application control block events from all endpoints and servers
- Alerting rules that flag high-frequency or high-severity block events (e.g., repeated blocks on a single endpoint may indicate active attack activity)
- Integration with your SIEM or security operations workflow so that alerts are triaged within your defined SLA

Microsoft Defender for Endpoint surfaces application control block events in [Advanced Hunting](https://learn.microsoft.com/en-us/defender-endpoint/advanced-hunting-overview) under the `DeviceEvents` table (`ActionType == "AppControlCodeIntegrityPolicyBlocked"`).

### Step 4 — Validate ML3 Compliance

Before claiming ML3, verify:

- Application control is enforced on all workstations and all servers (not only internet-facing).
- Scripts, DLLs, and installers are in scope — not only executables.
- Block events are centrally logged and generate alerts.
- Alerts are reviewed and actioned within your defined SLA.
- The allowlist review cadence is maintained and documented.

**Additional evidence to collect for ML3 audit:**
- Server coverage compliance reports (all servers, not only internet-facing)
- Evidence that scripts and DLLs are in scope (policy configuration extract)
- SIEM or log management configuration showing centralised collection of block events
- Alerting rule configuration and evidence of alert triage activity

---

## Common Challenges

### Unsigned Internal Applications

Legacy line-of-business applications are often unsigned. Options, in order of preference:

1. Request the vendor provide a signed version.
2. Sign the application internally using a code-signing certificate from your PKI.
3. Create file hash rules — update hashes as part of your change management process for that application.
4. Use a path rule scoped to a locked-down directory as a last resort, with compensating controls (restrict write access to the path).

### Frequently Updated Applications

Applications that update frequently (browsers, security agents) break hash rules on every update. Use publisher (certificate) rules for these applications. Verify that the publisher certificate is specific enough — a rule allowing anything signed by a given publisher may be overly broad if that publisher distributes many products.

### User Resistance and Productivity Impact

Users who cannot run a required application will find workarounds. Address this by:

- Communicating the change clearly before enforcement, with a named contact for exceptions.
- Committing to a fast exception SLA (4 business hours is a reasonable target for initial rollout).
- Publishing a self-service request process so users know exactly what to do.
- Running a sufficient audit-mode period so that the vast majority of business applications are in the allowlist before enforcement begins.

### Policy Conflicts

Multiple application control policies deployed to the same device can conflict. Test all policies in a non-production environment before broad deployment. Use your endpoint management platform's policy conflict detection where available.

---

## Verification

After completing each maturity level, run the following verification checks:

| Check | How to Verify |
|---|---|
| Policy is deployed to target devices | Endpoint management compliance report — filter by policy name, confirm 100% of in-scope devices show "Compliant" |
| Policy is enforced (not audit-only) | Review policy configuration — confirm enforcement mode, not audit mode |
| Block events are being generated | Query endpoint event logs or SIEM for recent block events — absence may indicate audit-only mode |
| Exception register is current | Review exception register — confirm each entry has a business justification, approval date, and review date |
| Allowlist covers scripts (ML3) | Review policy XML or rules export — confirm script enforcement is enabled |
| Centralised logging active (ML3) | Query SIEM for block events from application control — confirm events are flowing from all in-scope systems |

---

## Related Resources

### ACSC

- [Essential Eight — Application Control](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/application-control)
- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)

### Microsoft

- [App Control for Business overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview)
- [Deploy App Control for Business with Microsoft Intune](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/deployment/deploy-appcontrol-policies-using-intune)
- [Microsoft recommended block rules](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/design/microsoft-recommended-driver-block-rules)
- [AppLocker overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/applocker/applocker-overview)
- [Advanced Hunting — DeviceEvents](https://learn.microsoft.com/en-us/defender-endpoint/advanced-hunting-overview)

### This Library

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md)
