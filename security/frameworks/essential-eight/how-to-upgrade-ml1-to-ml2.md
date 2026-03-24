---
title: "How to Upgrade from ML1 to ML2"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Upgrade from ML1 to ML2

---

## Overview

This guide walks through the steps required to advance an organisation's Essential Eight posture from Maturity Level 1 (ML1) to Maturity Level 2 (ML2). It is structured as a phased implementation guide covering gap assessment, infrastructure changes, control-by-control actions, validation, and documentation requirements.

For maturity level definitions and the requirements that underpin each level, see [reference-maturity-model.md](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model) on cyber.gov.au.

**Estimated duration:** 3–6 months
**Estimated effort:** 200–400 hours (varies with organisation size)
**Primary challenges:** Patching automation, application inventory management, privileged access management (PAM) implementation

---

## Before You Begin

Complete the following before starting the ML2 transition:

- Confirm your ML1 baseline is fully implemented and documented. Use [reference-ml1-compliance-report-template.md](reference-ml1-compliance-report-template.md) to assess current state.
- Identify a security engineer or project lead to own the transition.
- Obtain budget and change-management approval for the infrastructure items (patching automation, PAM solution).
- Brief your helpdesk team — expanded MFA rollout will generate support requests.

---

## Phase 1: Assess Gaps (Weeks 1–2)

### Step 1: Score your current ML1 implementation

Work through the gap items below. Score each item:

- **0** — Not started
- **1** — Partially implemented
- **2** — Fully implemented

| Control | Gap Item | Score (0–2) |
|---------|----------|-------------|
| Control 1 | Maintained application inventory exists | |
| Control 1 | Application approval process defined with an owner | |
| Control 1 | Exception workflow documented | |
| Controls 2 & 6 | Automated patch deployment operational | |
| Controls 2 & 6 | Deployment rings configured | |
| Controls 2 & 6 | Rollback procedures documented and tested | |
| Control 5 | PAM solution deployed | |
| Control 5 | Just-in-time (JIT) access policies configured | |
| Control 5 | Privileged account lifecycle automated | |
| Control 7 | All internet-facing services catalogued | |
| Control 7 | MFA enforced for internet-facing services | |
| Control 7 | MFA user enrolment ≥95% for in-scope services | |

**Readiness thresholds:**

| Score | Recommendation |
|-------|----------------|
| 80%+ (20+ points) | Ready to begin ML2 transition |
| 60–79% (15–19 points) | Address critical gaps first (patching and PAM) |
| <60% (<15 points) | Strengthen ML1 implementation before proceeding |

### Step 2: Identify critical path items

Three items have the longest lead time and block the most controls. Confirm whether each is in place before proceeding:

1. **Patching automation** — blocks Controls 2 and 6. If not deployed, start here before anything else.
2. **PAM solution** — blocks Control 5. Integration with your identity infrastructure typically requires the most planning time.
3. **Application inventory** — blocks Control 1. Data gathering is time-consuming; begin it in parallel with infrastructure work.

### Step 3: Produce a gap analysis report

Document current state, target state, effort estimate, and priority for every gap item identified. This report becomes the project plan input for Phase 2.

---

## Phase 2: Build Automation Infrastructure (Weeks 3–8)

### Step 4: Deploy patching automation

ML2 requires patches applied within **2 weeks** of release. Manual patching cannot meet this timeline.

**Actions:**

1. Select and deploy a patch management solution appropriate to your environment (e.g., Microsoft Intune, Windows Server Update Services, or a third-party platform).
2. Configure deployment rings. A five-ring model is recommended:

   | Ring | Purpose | Size | Deployment window |
   |------|---------|------|-------------------|
   | Ring 0 — IT pilot | Early testing | 5–10 devices | Days 1–3 |
   | Ring 1 — Broader pilot | Representative sample | ~5% of devices | Days 4–7 |
   | Ring 2 — Production wave 1 | Early production | ~25% of devices | Days 8–10 |
   | Ring 3 — Production wave 2 | Main production | ~50% of devices | Days 11–13 |
   | Ring 4 — Final wave | Remaining devices | ~20% of devices | Day 14 |

3. Configure quality update deferrals (3–7 days) and enforce a 7-day deadline for security updates in production rings.
4. Define rollback triggers per ring (e.g., >2% failure rate in Ring 1, >5% in Rings 2–3).
5. Set maintenance windows outside business-critical hours.
6. Configure automated compliance reporting.

**Do not declare this step complete until Ring 0 and Ring 1 have achieved ≥95% compliance for three consecutive patch cycles.**

### Step 5: Deploy a PAM solution for just-in-time access

ML2 requires just-in-time (JIT) administration — administrators no longer hold standing privileged access.

**Actions:**

1. Select a privileged access management platform suitable for your identity infrastructure (e.g., Microsoft Entra Privileged Identity Management or an equivalent vendor solution).
2. Enumerate all privileged roles in scope. For each role, define:
   - Maximum activation duration
   - Whether approval is required
   - Whether a written justification is required
   - Whether MFA must be satisfied at activation

   Example role configuration:

   | Role | Activation duration | Approval required | Justification required |
   |------|---------------------|-------------------|------------------------|
   | Global administrator | 4 hours | Yes | Yes |
   | Security administrator | 8 hours | No | Yes |
   | Directory role administrator | 8 hours | No | Yes |
   | Helpdesk administrator | 8 hours | No | No |

3. Remove permanent role assignments. Replace with eligible assignments in the PAM platform.
4. Configure alert notifications for role activations and weekly access reviews.
5. Provide administrators with a step-by-step activation guide before go-live.
6. Deploy to a test set of administrators first; validate the activation workflow before production rollout.

**Target:** Average activation time under 5 minutes. If the process takes longer, friction will drive workaround behaviour.

### Step 6: Build and validate your application inventory

ML2 requires that allowed executables are validated against a maintained application control list.

**Actions:**

1. Run your application control solution in **audit mode** for a minimum of 4–6 weeks. Do not enforce before this step — you will disrupt the business if you skip it.
2. Collect execution data from audit logs, software metering, and asset management systems. User surveys may be needed to surface shadow IT.
3. Categorise each application as: approved, pending review, or blocked.
4. Define and document an application approval workflow with a named owner and a clear process for requesting exceptions.
5. Build the approved application list. Validate it against your application control policy configuration.
6. Document the exception register.

**Target:** Fewer than 5% of execution attempts blocked after enforcement begins.

---

## Phase 3: Deploy Enhanced Controls (Weeks 9–16)

### Step 7: Extend automated patching to production

1. Expand patching through Rings 2–4 using the ring strategy from Step 4.
2. Monitor compliance dashboards daily during rollout.
3. Invoke rollback procedures immediately if a ring exceeds its failure rate threshold.
4. Do not advance to the next ring until the current ring meets the ≥95% compliance target.

**Target:** ≥95% of all systems patched within 2 weeks of release.

### Step 8: Activate JIT access in production

1. Activate JIT access for all privileged roles identified in Step 5.
2. Confirm zero standing privileged access remains — no accounts should hold permanent elevated role assignments.
3. Monitor the PAM audit log for the first 2–4 weeks. Look for unusual activation patterns, emergency access requests, or attempts to use service accounts as workarounds.
4. Conduct an access review at the 4-week mark.

### Step 9: Enforce application control validation

1. Switch from audit mode to enforcement mode once the application inventory is validated (Step 6).
2. Activate the exception workflow so legitimate requests can be processed without disrupting the business.
3. Monitor blocked execution attempts daily for the first 2 weeks. Triage each block — add to approved list if legitimate, confirm block if not.

### Step 10: Block Java applets in browsers

ML2 adds Java blocking to the browser hardening requirements from ML1 (which already block web advertisements and Flash content).

**Actions:**

1. Identify whether any business applications require Java applets in a browser. Test this before enforcing.
2. Configure browser policies to block Java plugin execution across all managed browsers.
3. If Java is required for a specific application, document the exception, obtain approval, and scope the exception as narrowly as possible (specific URL or device group, not organisation-wide).
4. Verify that ML1 browser controls (ad blocking, Flash blocking) remain in place — do not inadvertently remove them during this step.

### Step 11: Extend MFA to internet-facing services

ML1 requires MFA for privileged users and remote access. ML2 extends this to all users accessing internet-facing services and important data repositories.

**Actions:**

1. Catalogue all internet-facing services in your environment. Common categories include:

   | Service type | Examples |
   |-------------|---------|
   | Web-based email | Outlook on the web, webmail |
   | Collaboration platforms | SharePoint Online, Teams web client |
   | CRM and line-of-business cloud apps | Dynamics 365, Salesforce |
   | Cloud storage | OneDrive, SharePoint document libraries |
   | Remote access | SSL VPN, Always On VPN (already ML1) |

2. For each service, confirm the MFA enforcement mechanism (e.g., Conditional Access policy, application-level MFA setting, or federated identity provider policy).
3. Communicate the change to affected users at least 2 weeks before enforcement. Include enrolment instructions.
4. Roll MFA out by service criticality — start with services where disruption impact is lowest.
5. Brief the helpdesk before each wave. Ensure they can support MFA enrolment and account recovery.

**Target:** MFA enforced for all catalogued internet-facing services, with user enrolment ≥95%.

---

## Phase 4: Validate and Harden (Weeks 17–20)

### Step 12: Validate all controls against ML2 criteria

Work through the following checklist. Every item must be confirmed before claiming ML2 compliance.

#### Control 1 — Application Control

- [ ] Application control policies deployed to all workstations
- [ ] Maintained application inventory documented and current
- [ ] Allowed executables validated against the approved application list
- [ ] Application approval process operational with a named owner
- [ ] ≥95% of execution attempts are approved applications
- [ ] Exception register documented and followed

#### Controls 2 & 6 — Patching

- [ ] Automated patching solution deployed
- [ ] Deployment rings configured and operational
- [ ] ≥95% of systems patched within 2 weeks of release
- [ ] Pilot testing process documented with defined success criteria
- [ ] Rollback procedures documented and tested
- [ ] Compliance monitoring and reporting automated

#### Control 3 — Macro Settings

- [ ] ML1 configuration verified and maintained (no change required for ML2)

#### Control 4 — User Application Hardening

- [ ] Java applets blocked in all managed browsers
- [ ] ML1 controls (ad blocking, Flash blocking) remain in place
- [ ] No business disruption from Java blocking; exceptions documented if applicable

#### Control 5 — Administrative Privileges

- [ ] PAM solution deployed and operational
- [ ] JIT access implemented for all privileged roles
- [ ] Zero standing privileged access
- [ ] Average privilege activation time <5 minutes
- [ ] All privileged actions logged
- [ ] Access reviews conducted and documented

#### Control 7 — Multi-Factor Authentication

- [ ] All internet-facing services identified and catalogued
- [ ] MFA enforced for all identified services
- [ ] User enrolment rate ≥95%
- [ ] Helpdesk trained on MFA support
- [ ] MFA bypass exceptions documented and approved

#### Control 8 — Regular Backups

- [ ] ML1 configuration verified and maintained (no change required for ML2)

### Step 13: Remediate gaps

For each checklist item not yet satisfied, log a remediation task, assign an owner, and set a target date. Re-validate after each remediation is complete.

### Step 14: Gather and retain compliance evidence

Collect and retain documentation sufficient to demonstrate ML2 compliance to auditors or assessors.

| Control | Evidence to retain | Minimum retention |
|---------|-------------------|-------------------|
| Control 1 | Application inventory, approval records, exception register | 3 years |
| Controls 2 & 6 | Patching compliance reports, ring deployment logs | 2 years |
| Control 5 | JIT access logs, access reviews | 3 years |
| Control 7 | MFA enrolment records, policy configurations | 3 years |
| All | Configuration exports, policy screenshots | Current year + 1 year |

Use [reference-ml2-compliance-report-template.md](reference-ml2-compliance-report-template.md) to structure your compliance report.

### Step 15: Consider independent validation

Consider one or more of the following validation approaches before formally claiming ML2:

- **Internal audit** — your organisation's internal audit function reviews evidence against ACSC criteria.
- **Third-party security assessment** — an independent assessor validates controls against real-world attack scenarios.
- **Penetration test** — validates that controls hold under active exploitation attempts.

For official assessment pathways, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model) guidance.

---

## Common Problems and How to Avoid Them

### Patching deadlines missed after transition

**Cause:** Organisations attempt to accelerate manual patching without first deploying automation.

**Fix:** Deploy patching automation and prove ≥95% compliance in the pilot ring for three consecutive cycles before committing to the ML2 timeline. Do not advance rings until each ring meets the target.

### Application control blocks disrupt the business

**Cause:** Application inventory built from asset management data only, missing shadow IT and user-installed applications.

**Fix:** Run audit mode for a minimum of 4–6 weeks and collect data from multiple sources before enforcing. Analyse blocked execution attempts before switching enforcement on.

### Administrators work around JIT access

**Cause:** JIT activation process is slow or requires excessive approvals, creating friction that incentivises workarounds.

**Fix:** Keep the standard activation path under 5 minutes. Reserve approval requirements for the most sensitive roles only (e.g., global administrator). Involve administrators in the PAM design before rollout.

### MFA scope unclear — services missed or users over-prompted

**Cause:** "Internet-facing services" is not defined, leading to inconsistent policy application.

**Fix:** Produce a formal service catalogue. Define explicit inclusion criteria. Use risk-based policy where available to reduce unnecessary prompts for low-risk sessions on managed devices.

### Business disruption from rushing deployment

**Cause:** Controls deployed to production without adequate pilot testing.

**Fix:** Maintain a non-production test environment. Never advance a control to production until the pilot meets all defined success criteria. Define rollback procedures before enforcement, not after.

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/business-government/asds-cyber-security-frameworks/essential-eight/essential-eight-maturity-model) — Authoritative ML1 and ML2 requirements
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — Framework overview and supporting guidance
- [reference-maturity-model.md](reference-maturity-model.md) — Maturity level definitions for this library
- [reference-glossary.md](reference-glossary.md) — Term definitions
- [reference-ml1-compliance-report-template.md](reference-ml1-compliance-report-template.md) — ML1 baseline assessment template
- [reference-ml2-compliance-report-template.md](reference-ml2-compliance-report-template.md) — ML2 target assessment template
- [how-to-upgrade-ml2-to-ml3.md](how-to-upgrade-ml2-to-ml3.md) — Next upgrade path
