---
title: "How to Upgrade from ML2 to ML3"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Upgrade from ML2 to ML3

---

## Overview

This guide walks through the steps required to upgrade an Essential Eight implementation from Maturity Level 2 (ML2) to Maturity Level 3 (ML3). ML3 is the highest maturity tier defined by the ACSC. It requires 48-hour patch deployment, phishing-resistant MFA, endpoint detection and response (EDR) integrated with application control, and enterprise-grade privileged access management (PAM).

**Expected duration:** 6–12 months
**Prerequisite:** ML2 must be fully operational and stable for at least six months before beginning this upgrade.

For authoritative ML3 requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

For maturity level definitions, see [reference-maturity-model.md](reference-maturity-model.md).

---

## Before You Begin

Confirm all of the following before proceeding:

| Readiness Check | Required State |
| --- | --- |
| Executive sponsorship | Secured |
| Budget for enterprise solutions | Approved |
| Security operations team | In place |
| Modern OS and application versions | Deployed |
| ML2 fully operational | 6+ months stable |

Do not begin the ML3 upgrade until every check passes. ML3 controls depend on a mature, stable ML2 baseline.

For the ML2 implementation baseline, see [reference-ml2-compliance-report-template.md](reference-ml2-compliance-report-template.md).

---

## Step 1 — Conduct a Gap Analysis

Before deploying anything, assess the gap between your current ML2 state and the ML3 target for each control.

Score each gap area:

- **Red (0–25%):** Major gaps — substantial work required
- **Yellow (26–75%):** Moderate gaps — focused effort needed
- **Green (76–100%):** Minor gaps — ready to proceed

**ML3 transition threshold:**

- Overall readiness of ≥75% across all controls
- No individual control below 50%
- The four critical areas — patching cadence, EDR, phishing-resistant MFA, and enterprise PAM — each at ≥80%

### Gap areas by control

**Application Control (Control 1)**

| Gap Item | Current State (ML2) | Target State (ML3) |
| --- | --- | --- |
| EDR solution | None or basic | EDR solution integrated with application control |
| Behavioural monitoring | Limited | AI-driven behavioural analysis |
| Automated remediation | Manual | Automated isolation and remediation |
| Application control integration | Standalone | Integrated with EDR |

**Patching (Controls 2 and 6)**

| Gap Item | Current State (ML2) | Target State (ML3) |
| --- | --- | --- |
| Patching cadence | Within 2 weeks | Within 48 hours |
| Operational hours | Business hours | 24/7 capability |
| Emergency patching | Ad hoc | Formal emergency patch process |
| Automated testing | 3–7 day pilot | 24-hour accelerated testing pipeline |

**Macro Settings (Control 3)**

| Gap Item | Current State (ML2) | Target State (ML3) |
| --- | --- | --- |
| Trusted Locations | Not strictly enforced | Enforced and audited |
| Macro antivirus scanning | Not configured | Enabled and monitored |

**Restrict Administrative Privileges (Control 5)**

| Gap Item | Current State (ML2) | Target State (ML3) |
| --- | --- | --- |
| PAM solution | Basic JIT only | Enterprise PAM with vaulting and workflows |
| Session recording | Not configured | Full session recording |
| Credential vaulting | Limited | Comprehensive secret management |
| Privileged Access Workstations | Not deployed | Deployed for Tier 0/1 administrators |

**Multi-Factor Authentication (Control 7)**

| Gap Item | Current State (ML2) | Target State (ML3) |
| --- | --- | --- |
| MFA type | SMS or authenticator app | Phishing-resistant MFA (FIDO2, smartcard, or Windows Hello for Business) |
| Token procurement | Not applicable | Hardware tokens for all users |
| Backup authentication | SMS or app | Multiple phishing-resistant credentials per user |

---

## Step 2 — Deploy EDR and Integrate with Application Control

ML3 requires that application control is implemented using EDR or anti-malware solution functionality — not standalone policy alone.

1. Deploy your EDR solution to all workstations, starting with a pilot group of 10–20 devices (IT team), then privileged users, then the general population.
2. Integrate your existing application control policies with the EDR solution so they share telemetry and enforcement.
3. Enable behavioural blocking and AI-driven threat detection in the EDR platform.
4. Configure automated investigation and remediation so that detected threats trigger isolation without manual intervention.
5. Enable Attack Surface Reduction (ASR) rules appropriate to your environment. Start in audit mode, review results, then move to enforcement.
6. Establish Security Operations Centre (SOC) processes for alert triage, incident response, and EDR-specific workflows.
7. Tune ASR rules to reduce false positives before enforcing. Alert fatigue is the leading cause of SOC failure at this control level.

**Target outcomes:**

- EDR deployed to 100% of workstations
- Automated investigation and remediation operational
- Mean time to detect (MTTD) under 1 hour
- Mean time to respond (MTTR) under 4 hours

---

## Step 3 — Establish 48-Hour Patch Deployment

ML3 reduces the patching window from 2 weeks to 48 hours. This requires infrastructure investment before the window can be enforced operationally.

### 3a — Build automated testing infrastructure

1. Design an automated testing pipeline that can validate patches within 4–6 hours across representative device configurations.
2. Implement ring-based deployment:
   - Ring 0: IT devices — automated deployment and testing
   - Ring 1: Pilot group (~5%)
   - Ring 2: 25% of production
   - Ring 3: 50% of production
   - Ring 4: Remaining 25%
3. Configure automated rollback capability so a failed ring triggers immediate rollback without manual intervention.

### 3b — Establish 24/7 operations

1. Create an on-call rotation for patch monitoring outside business hours.
2. Define escalation procedures so on-call staff have clear authority to deploy, pause, or rollback without waiting for approval.
3. Document and test the emergency patch process. This process must handle zero-day vulnerabilities where the standard 48-hour window may not apply.

### 3c — Configure deployment settings

Configure your patch management platform with:
- Quality update deferral: 0 days
- Quality update deadline: 2 days
- Restart grace period: 0 days
- Rollback window: 10 days for quality updates

Do not attempt production cutover until parallel running of the 48-hour process achieves a ≥95% success rate over at least 3 months alongside your existing 2-week process.

**Target outcomes:**

- ≥95% of systems patched within 48 hours
- Automated testing completes in under 6 hours
- Emergency patch process documented, tested quarterly
- Automated rollback functional and tested

---

## Step 4 — Harden Macro Settings

ML3 adds macro antivirus scanning and enforces stricter Trusted Location controls.

1. Enable macro antivirus scanning at the Group Policy or MDM policy level so macros are scanned before execution on all managed devices.
2. Audit all currently configured Trusted Locations. Document each location with a business justification.
3. Remove Trusted Locations that cannot be justified. Target no more than five Trusted Locations per business unit.
4. Block macros from user profile folders — these are user-writable and high risk.
5. Restrict network share Trusted Locations to specific, documented shares only.
6. Configure alerting so that macro execution attempts from non-trusted locations are logged and reviewed.

**Target outcomes:**

- Macro antivirus scanning enabled on all managed devices
- All Trusted Locations documented with business justification
- No more than five Trusted Locations per business unit
- Zero unauthorised macro executions

---

## Step 5 — Verify User Application Hardening

Control 4 has no significant change from ML2 to ML3. The ML2 requirements continue: web advertisements blocked, Flash blocked, Java blocked or constrained.

1. Confirm that all ML2 Control 4 configurations remain in place and have not drifted.
2. If your organisation's threat profile warrants additional investment, consider secure web gateway deployment or browser isolation for high-risk browsing sessions.

No new mandatory configurations are required for ML3 compliance on this control.

---

## Step 6 — Deploy Enterprise PAM

ML3 requires a Privileged Access Management (PAM) solution that goes beyond basic just-in-time access. It must provide credential vaulting, automatic password rotation, session recording, and privileged operating environments.

### 6a — Select and deploy PAM infrastructure

1. Evaluate enterprise PAM solutions against your organisation's requirements. Common capabilities to assess include session recording, credential vaulting, automatic rotation, and approval workflow support.
2. Deploy PAM server infrastructure, vaults, and connectors. Engage vendor professional services — PAM implementations consistently take longer than estimated.
3. Allocate a minimum of six months for full PAM deployment and adoption.

### 6b — Onboard privileged accounts

1. Discover all privileged accounts across all systems. This step takes 2–4 weeks and commonly reveals accounts that were previously untracked.
2. Onboard accounts to the PAM vault over 4–8 weeks, starting with the highest-privilege accounts (Tier 0).
3. Enable automatic password rotation for all vaulted accounts.
4. Configure and test session recording for all privileged sessions.

### 6c — Deploy Privileged Access Workstations

1. Build hardened workstations for Tier 0 and Tier 1 administrators. These devices must have no internet access, no email access, and must run only administrative tooling.
2. Enable session recording and Credential Guard on all PAWs.
3. Require administrators to use PAWs for all privileged tasks — standard workstations must not be used for Tier 0 or Tier 1 administration.

### 6d — Establish privileged operating environments

1. Create isolated administrative environments (jump servers or equivalent) for accessing management-tier assets.
2. Ensure no privileged credentials are cached outside the PAM vault.

**Target outcomes:**

- 100% of privileged credentials stored in the PAM vault
- Automatic password rotation operational for all vaulted accounts
- Session recording active for all privileged sessions
- PAWs deployed for all Tier 0 and Tier 1 administrators
- Zero cached privileged credentials outside the vault
- Privileged operating environments established and enforced

---

## Step 7 — Deploy Phishing-Resistant MFA

ML3 requires that MFA is phishing-resistant. SMS and standard authenticator app methods do not meet this requirement. Acceptable methods include FIDO2 security keys, smartcards, and Windows Hello for Business.

### 7a — Enable phishing-resistant MFA in your identity platform

1. Enable FIDO2 (or your chosen phishing-resistant method) in your identity provider for all users.
2. Configure the authentication policy to require phishing-resistant MFA for privileged users first, then extend to all users.

### 7b — Procure hardware tokens

1. Procure hardware security keys for all users. Allow for procurement lead time of 4–8 weeks.
2. Provide a minimum of two tokens per user — one primary token and one backup token stored securely.
3. Track token serial numbers against user accounts for revocation and replacement management.

### 7c — Execute phased rollout

1. **Pilot phase:** Enrol the IT team first — approximately 5–10% of users. Validate the enrolment process, helpdesk procedures, and lost token procedures before wider rollout.
2. **Privileged users:** Enrol all privileged users. These accounts are the highest-value targets and should be on phishing-resistant MFA before general population rollout.
3. **General population:** Enrol all remaining users with dedicated user support during the rollout period.
4. Pre-configure tokens where possible before distributing to users to reduce helpdesk load at enrolment.

### 7d — Deprecate legacy MFA

1. Once enrolment reaches ≥95%, disable SMS and authenticator app-based MFA.
2. Confirm that no access paths exist that permit fallback to phishable MFA methods.

**Target outcomes:**

- ≥95% of users enrolled with phishing-resistant MFA
- Each user has a minimum of two tokens or credentials
- SMS and authenticator app MFA deprecated
- Token replacement process documented and operational

---

## Step 8 — Enhance Backup Management

ML3 adds lifecycle management, monthly partial backups, and event-triggered backups to the ML2 quarterly backup baseline.

1. Implement lifecycle policies that automate retention and archival. Configure at minimum:
   - Full backups: quarterly (minimum), retained for 3+ years
   - Partial backups: monthly, retained for 12 months
   - Incremental backups: daily (recommended), retained for 90 days
2. Configure event-triggered backups for the following scenarios:
   - Before major production deployments
   - When a security incident is detected
   - When a regulatory or legal hold is placed
   - When high-value data repositories are modified
3. Configure immutable (WORM) storage for backup targets to prevent ransomware from destroying backups.
4. Verify geographic redundancy — backups must be stored in at least one geographically separate location.
5. Test restoration quarterly. A backup that has not been tested is not a backup.

**Target outcomes:**

- Lifecycle policies configured and operational
- Monthly partial backups running
- Event-triggered backups tested
- Immutable storage configured
- Geographic redundancy verified
- Restoration tests completed successfully

---

## Step 9 — Validate ML3 Compliance

Use the following checklist to confirm each control meets ML3 requirements before claiming compliance. Do not mark a control complete until all items are confirmed.

### Control 1 — Application Control with EDR

- EDR deployed to all workstations
- Application control integrated with EDR
- Attack Surface Reduction rules enabled and tuned
- Behavioural blocking operational
- Automated investigation and remediation functional
- SOC processes established
- MTTD under 1 hour; MTTR under 4 hours

### Controls 2 and 6 — 48-Hour Patching

- ≥95% of systems patched within 48 hours
- Automated testing completes in under 6 hours
- 24/7 operations capability established
- Emergency patch process defined and tested quarterly
- Automated rollback functional and tested
- Compliance monitoring operational

### Control 3 — Macro Settings

- Macro antivirus scanning enabled on all managed devices
- Trusted Locations audited and documented
- No more than five Trusted Locations per business unit
- Monitoring and alerting operational
- User awareness training completed

### Control 4 — User Application Hardening

- ML2 configurations confirmed in place (no regression)

### Control 5 — Restrict Administrative Privileges

- Enterprise PAM solution deployed
- 100% of privileged credentials in vault
- Automatic password rotation operational
- Session recording for all privileged sessions
- PAWs deployed for Tier 0 and Tier 1 administrators
- Zero cached privileged credentials
- Privileged operating environments established

### Control 7 — Multi-Factor Authentication

- Phishing-resistant MFA enabled in identity platform
- ≥95% of users enrolled
- Each user has a minimum of two tokens or credentials
- SMS and authenticator app MFA deprecated
- Token management process operational

### Control 8 — Regular Backups

- Lifecycle policies configured
- Partial backups running monthly
- Event-triggered backups operational
- Immutable storage configured
- Geographic redundancy verified
- Restoration tests completed

For the ML3 target assessment template, see [reference-ml3-compliance-report-template.md](reference-ml3-compliance-report-template.md).

---

## Common Pitfalls

### 48-hour patching without adequate automation

Attempting the 48-hour patching window before automated testing infrastructure is mature results in incomplete testing, high rollback rates, and business disruption. Run the 48-hour process in parallel with your existing 2-week process for at least 3 months. Do not cut over until the 48-hour process achieves ≥95% success consistently.

### Underestimating PAM implementation complexity

Enterprise PAM integrates deeply with existing identity systems and requires account discovery, vault onboarding, workflow design, and user training. Allocate a minimum of six months. Engage vendor professional services. Start with the highest-privilege accounts and expand gradually.

### FIDO2 distribution and tracking gaps

Distributing hardware tokens without a serial number tracking system leads to unaccountable tokens and inability to revoke lost keys. Pre-configure tokens before distribution. Provide two tokens per user from day one. Have a documented lost token procedure in place before general rollout begins.

### EDR alert fatigue

An EDR platform deployed without tuning generates high alert volumes. Analysts experiencing alert fatigue miss genuine threats. Tune ASR rules in audit mode before enforcing. Use automated investigation to reduce manual triage load. Regularly review and tune detection rules.

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [reference-maturity-model.md](reference-maturity-model.md) — Maturity level definitions
- [reference-glossary.md](reference-glossary.md) — Term definitions
- [how-to-upgrade-ml1-to-ml2.md](how-to-upgrade-ml1-to-ml2.md) — Previous upgrade path
- [reference-ml2-compliance-report-template.md](reference-ml2-compliance-report-template.md) — ML2 baseline
- [reference-ml3-compliance-report-template.md](reference-ml3-compliance-report-template.md) — ML3 target assessment
