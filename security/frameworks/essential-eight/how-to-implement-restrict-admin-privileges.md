---
title: "How to Implement Restrict Administrative Privileges"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Restrict Administrative Privileges

---

## Overview

This guide provides goal-oriented implementation steps for the ACSC Essential Eight strategy **Restrict Administrative Privileges**, structured by maturity level (ML1 through ML3). It covers the separation of administrative accounts, privileged access management (PAM), just-in-time (JIT) access, Privileged Access Workstations (PAWs), and break-glass procedures.

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

This strategy has dependencies on identity management infrastructure and role-based access control (RBAC). Confirm the following before starting:

- An identity provider is in place and operational (e.g., Microsoft Entra ID for cloud-joined or hybrid environments).
- An inventory of all current administrative accounts and privileged role assignments exists or can be generated.
- A change management process is in place to handle user impact from privilege removal.
- An exception handling workflow exists for legitimate edge cases (e.g., legacy application compatibility).

**Priority:** Critical — administrative accounts are a primary target in credential-based attacks. This control is among the highest-impact mitigations in the Essential Eight.

**Complexity:** High — requires sustained coordination across IT operations, application owners, and end users.

**Estimated time to ML1:** 8–12 weeks.

---

## Maturity Level 1

### Objective

Restrict administrative privileges to specific users and tasks. Standard users must not hold administrative rights on their daily-use accounts.

---

### Step 1 — Conduct an administrative access review

1. Generate a full list of all accounts holding local administrator rights on endpoints, and all accounts assigned privileged roles in directory and cloud services.
2. For each account, document the business justification for the privilege assignment. Challenge any assignment that cannot be justified.
3. Identify accounts where administrative privileges are granted as a matter of convenience rather than operational need.
4. Produce a signed-off register of accounts approved for continued administrative access, with named responsible owners.

**Tools:** Microsoft Entra ID role assignments (Entra admin centre > Roles and administrators), local administrator group enumeration via endpoint management tooling (e.g., Microsoft Intune account protection policies or Local Administrator Password Solution (LAPS)).

---

### Step 2 — Implement separate administrative accounts

1. Create dedicated administrative accounts that are distinct from each user's standard daily-use account. A consistent naming convention aids auditing — a common pattern is a prefix such as `adm-` followed by the username (e.g., `adm-jsmith`).
2. Enforce the use of these dedicated accounts for all privileged activities. Standard accounts must not be used to perform administrative tasks.
3. Ensure dedicated administrative accounts are not licensed for productivity applications (e.g., email, Teams) to reduce the attack surface exposed by those accounts.
4. Apply strong authentication requirements to all administrative accounts. At minimum, require phishing-resistant MFA.

**Tools:** Microsoft Entra ID, Active Directory Users and Computers (on-premises), Microsoft Intune (Conditional Access policy scoped to admin accounts).

---

### Step 3 — Remove local administrator rights from standard users (phased)

Removing local administrator rights typically generates significant support demand. A phased rollout reduces risk.

1. **Pilot phase (weeks 1–2):** Remove local admin rights from a small, co-operative pilot group. Identify applications and workflows that break without local admin access.
2. **Remediation phase (weeks 3–4):** For each identified break, provide an alternative — deploy software via endpoint management tooling, create self-service portal entries, or engage application vendors.
3. **Broad rollout (weeks 5–8):** Remove local admin rights from remaining users in staged waves, by department or device group. Maintain a fast-track exception process for genuine operational blockers.
4. Document all exceptions with business justification and a scheduled review date. Exceptions are not permanent.

**Tools:** Microsoft Intune (account protection profiles, endpoint privilege management), LAPS for managed local administrator credentials.

---

### Step 4 — Log and monitor all administrative activity

1. Enable audit logging for all administrative account sign-ins and privileged actions.
2. Configure alerts for anomalous administrative activity — sign-ins from unusual locations, sign-ins outside business hours, bulk permission changes, and role escalations.
3. Retain administrative activity logs in accordance with your organisation's log retention policy and the [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requirements.
4. Assign ownership for reviewing administrative activity alerts.

**Tools:** Microsoft Entra ID sign-in logs, Microsoft Entra audit logs, Microsoft Sentinel (for alerting and retention), Entra ID Protection (risk-based sign-in detection).

---

### Step 5 — Establish a quarterly access review cadence

1. Schedule a quarterly review of all accounts holding administrative privileges.
2. During each review, confirm the business justification for each privileged assignment remains valid.
3. Revoke any assignments that are no longer required.
4. Document the review outcome and retain evidence for audit purposes.

---

### ML1 Success Criteria

- Fewer than 5% of users hold administrative privileges.
- 100% of administrators use a dedicated administrative account separate from their standard account.
- All administrative activity is logged and monitored.
- A quarterly access review process is in place and evidenced.

---

## Maturity Level 2

### Objective

Implement just-in-time (JIT) administrative access using a Privileged Access Management (PAM) solution. Standing administrative privileges are eliminated in favour of time-limited, audited elevations.

---

### Step 1 — Deploy a PAM solution

Select and deploy a PAM capability that supports JIT elevation, time-limited access, and approval workflows. Implementation options include:

- **Microsoft Entra Privileged Identity Management (PIM):** Provides JIT role activation, approval workflows, time-bound assignments, and activation alerts for Entra ID and Azure roles. Requires Microsoft Entra ID P2 licensing.
- **Third-party PAM platforms:** CyberArk, BeyondTrust, Delinea, and similar products provide PAM capabilities for hybrid environments including on-premises systems and non-Microsoft platforms.

Configure the PAM solution to:

1. Convert all permanent privileged role assignments to **eligible** (not active) assignments.
2. Require activation requests for all privileged role use, with a maximum activation window appropriate to the task (commonly 1–4 hours).
3. Require MFA re-authentication at activation time, regardless of existing session state.
4. Route high-impact role activations (e.g., Global Administrator, Privileged Role Administrator) through an approval workflow with a named approver.

---

### Step 2 — Audit all privileged actions during elevated sessions

1. Enable session-level auditing for all PAM-managed elevations. Each activation must produce a log entry recording who activated, which role, for what stated reason, and for how long.
2. Retain activation logs alongside standard administrative audit logs.
3. Review activation logs as part of the quarterly access review.

---

### Step 3 — Enforce Privileged Access Workstations for sensitive roles

For roles with the highest blast radius (e.g., Global Administrator, Domain Administrator, security operations roles), implement Privileged Access Workstations (PAWs):

1. Provision dedicated, hardened devices used exclusively for administrative tasks. These devices must not be used for general internet browsing, email, or productivity work.
2. Apply a restrictive Conditional Access policy that requires PAW compliance for activation of sensitive roles in the PAM solution.
3. Harden PAWs in accordance with [ACSC hardening guidance for Windows endpoints](https://www.cyber.gov.au/resources-business-and-government/guidance/hardening-microsoft-windows-10-and-windows-11-workstations).

---

### ML2 Success Criteria

- No standing (permanent active) privileged role assignments remain — all are eligible or time-bound.
- All privileged access is obtained through JIT activation with logged justification.
- Approval workflows are active for the highest-impact roles.
- PAWs are in use for the most sensitive administrative roles.

---

## Maturity Level 3

### Objective

Achieve zero standing privileges. All administrative access is obtained via approval workflows, session recording is active for privileged sessions, and the control is enforced across all systems including on-premises infrastructure.

---

### Step 1 — Eliminate all remaining standing privileges

1. Audit all systems — cloud, on-premises, hybrid, and third-party SaaS — for any remaining standing administrative access.
2. Migrate all remaining standing assignments to JIT or approval-gated models. No account should hold an always-active privileged role.
3. For on-premises systems, extend the PAM solution or implement equivalent controls (e.g., Microsoft LAPS for local administrator accounts, group-managed service accounts (gMSA) for service identity).

---

### Step 2 — Implement session recording for privileged sessions

1. Configure the PAM solution (or a dedicated session recording capability) to record terminal sessions, RDP sessions, and command-line activity during elevated access windows.
2. Store session recordings in a tamper-resistant location.
3. Establish a process for reviewing session recordings as part of incident investigations and periodic audits.

**Tools:** Entra PIM does not natively provide session recording — third-party PAM platforms (CyberArk, BeyondTrust) or Azure Bastion with session recording provide this capability.

---

### Step 3 — Implement and test break-glass emergency access

Break-glass accounts provide last-resort emergency access when normal administrative pathways are unavailable (e.g., PAM system outage, identity provider failure).

1. Create a minimum of two break-glass accounts in Microsoft Entra ID. These accounts must not be associated with any individual user and must be excluded from all Conditional Access policies (including MFA requirements).
2. Assign break-glass accounts the Global Administrator role as a permanent assignment — this is a deliberate exception to the zero-standing-privileges model, documented and justified.
3. Store break-glass credentials in a physically secured location (e.g., sealed envelope in a safe) and maintain a digital copy in an offline secure vault.
4. Configure an alert that fires immediately on any sign-in from a break-glass account. Break-glass sign-ins must trigger an incident response process.
5. Test break-glass access at least annually to confirm credentials remain valid and the emergency procedure is understood.

For guidance on break-glass account design, see the [Microsoft Entra emergency access accounts guidance](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access).

---

### Step 4 — Enforce the control across all platforms

Extend PAM and JIT controls to cover:

- On-premises Active Directory domain administrator accounts.
- Cloud infrastructure platforms (Azure, AWS, GCP) with native PIM or equivalent.
- Third-party SaaS applications with administrative consoles.
- Network infrastructure management accounts (switches, firewalls, routers).
- Database administrative accounts.

---

### ML3 Success Criteria

- Zero standing privileges across all systems — no always-active privileged role assignments outside break-glass accounts.
- Session recording is active and retained for all privileged sessions.
- Approval workflows are in place for all role activations above a defined risk threshold.
- Break-glass procedures are documented, tested, and alerting is confirmed operational.
- The control scope covers all systems, not only cloud platforms.

---

## Common Challenges

| Challenge | Recommended approach |
|-----------|---------------------|
| Developers require administrative access to perform their work | Provide isolated development environments with scoped administrative rights. Do not grant production administrative access to resolve a development workflow problem. |
| Legacy applications require local administrator rights to run | Work with the application vendor to remediate. In the interim, use endpoint privilege management tooling (e.g., Intune Endpoint Privilege Management) to elevate specific application processes without granting broad local admin rights to the user account. |
| Support staff push back on JIT workflows due to friction | Invest in automation to reduce the number of activation steps. Pre-approve common, low-risk role requests. Use approval auto-approval windows for well-understood tasks. |
| Service accounts require administrative rights | Replace service accounts with managed identities (in Azure) or group-managed service accounts (on-premises). Ensure service account passwords are managed by LAPS or equivalent and rotated automatically. |
| PAM system outage blocks all administrative access | This is the break-glass scenario. Confirm break-glass procedures are tested and accessible before deploying zero-standing-privilege controls. |

---

## Compliance Evidence

When preparing for audit against the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model), retain the following artefacts:

- Administrative access policy, approved and dated.
- Register of all users holding administrative privileges, with documented business justification for each.
- Evidence of separate administrative accounts for all privileged users.
- PAM activation logs covering at minimum the prior 12 months.
- Quarterly access review records (sign-off, date, scope, revocations made).
- Break-glass account procedure document and last test date.
- Conditional Access policy configuration screenshots or exports scoped to privileged accounts.

---

## Related Resources

### ACSC

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight — Restrict Administrative Privileges](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/restrict-administrative-privileges)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Hardening Microsoft Windows 10 and Windows 11 Workstations](https://www.cyber.gov.au/resources-business-and-government/guidance/hardening-microsoft-windows-10-and-windows-11-workstations)

### Related Documents in This Library

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md)
