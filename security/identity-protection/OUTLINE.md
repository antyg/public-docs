---
title: "Microsoft Entra ID Protection — Content Outline"
status: "planned"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Microsoft Entra ID Protection — Content Outline

This document defines the planned documentation structure for the Microsoft Entra ID Protection section. Each section lists the content to be authored and the authoritative citation sources.

---

## Section 1 — Risk Policies

**Goal**: Comprehensive guide to configuring and managing risk-based access policies.

### 1.1 — Understanding Risk Conditions in Conditional Access

Content to cover:
- Difference between user risk condition and sign-in risk condition in Conditional Access
- How risk levels (low, medium, high) are calculated and updated
- Risk condition evaluation timing — real-time (sign-in risk) vs. aggregated (user risk)
- Combining risk conditions with other Conditional Access conditions (device compliance, location)
- Exclusions: break-glass accounts, service accounts, hybrid join scenarios

Citation sources:
- [Conditional Access — user risk condition](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#user-risk)
- [Conditional Access — sign-in risk condition](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#sign-in-risk)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

### 1.2 — Migrating Legacy ID Protection Policies to Conditional Access

Content to cover:
- Legacy policy retirement timeline (October 1, 2026)
- Step-by-step migration procedure from native ID Protection policies to Conditional Access
- Verifying equivalent coverage after migration
- Common migration pitfalls (user risk policy requiring password change vs. MFA only)

Citation sources:
- [Migrate ID Protection policies to Conditional Access](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Conditional Access policy migration guide](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-migration-mfa)

### 1.3 — Policy Design for Passwordless Environments

Content to cover:
- Risk policy behaviour when users are passwordless (FIDO2, Windows Hello)
- August 2025 detection improvements for passwordless sign-in flows
- Remediation flows for passwordless users with elevated user risk (no password to reset)
- Configuring sign-in risk policies that work with FIDO2 and Windows Hello sign-ins

Citation sources:
- [Passwordless authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless)
- [Microsoft Entra ID Protection overview — August 2025 update](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)

---

## Section 2 — User Risk

**Goal**: Reference for understanding, monitoring, and managing user-level identity risk.

### 2.1 — User Risk Detections Reference

Content to cover:
- Full detection type reference: leaked credentials, threat intelligence, anomalous user activity, suspicious API calls
- Detection source (real-time vs. offline — some detections computed hours after the event)
- Risk detection state lifecycle: active → remediated → dismissed → confirmed compromised
- How individual detections aggregate into overall user risk level

Citation sources:
- [Risk detections reference — user risk](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks#user-risk-detections)
- [User risk levels](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks#risk-levels)

### 2.2 — Risky Users Report — Investigation Workflow

Content to cover:
- Navigating the risky users report (filter by risk level, detection type, date)
- User risk detail view — detection timeline, detection context, raw signal details
- When to confirm compromised vs. dismiss risk vs. block user vs. require password reset
- Documenting risk decisions for audit purposes (ISM and Privacy Act requirements)

Citation sources:
- [Investigate risky users](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-investigate-risk#risky-users-report)
- [Remediate risks in Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock)

### 2.3 — Bulk Risk Remediation

Content to cover:
- Bulk confirm compromised / dismiss / reset password from risky users report
- When bulk remediation is appropriate (post-incident cleanup, phishing campaign response)
- Using Microsoft Graph API for programmatic risk remediation at scale
- Tracking bulk remediation in audit logs

Citation sources:
- [Microsoft Graph API — identity risk](https://learn.microsoft.com/en-us/graph/api/resources/identityprotection-root)
- [Dismiss a user risk](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock#dismiss-user-risk)

---

## Section 3 — Sign-In Risk

**Goal**: Reference for sign-in risk detection, investigation, and policy response.

### 3.1 — Sign-In Risk Detections Reference

Content to cover:
- Full detection type reference: atypical travel, anonymous IP, malware-linked IP, unfamiliar properties, password spray, token issuer anomaly
- Real-time vs. offline detection (some detections available at sign-in time; others computed retrospectively)
- False positive patterns for each detection type (legitimate travel, corporate VPN, new device)
- How sign-in risk level is determined when multiple detections apply

Citation sources:
- [Risk detections reference — sign-in risk](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks#sign-in-risk-detections)
- [What is sign-in risk?](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks#sign-in-risk)

### 3.2 — Risky Sign-Ins Report — Investigation Workflow

Content to cover:
- Navigating the risky sign-ins report (filter by user, detection type, risk level, date range)
- Sign-in detail view — detection context, IP, location, device, authentication method
- Correlating risky sign-ins with user risk detections
- Confirming safe vs. confirming compromised sign-ins and impact on ML model feedback

Citation sources:
- [Investigate risky sign-ins](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-investigate-risk#risky-sign-ins-report)

### 3.3 — Continuous Access Evaluation Integration

Content to cover:
- How Continuous Access Evaluation (CAE) extends sign-in risk enforcement into active sessions
- CAE events that trigger real-time token revocation (user disabled, password changed, risk elevated)
- Configuring CAE in Conditional Access (strict enforcement mode)
- Limitations: not all apps support CAE; fallback behaviour for non-CAE-capable apps

Citation sources:
- [Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation)
- [CAE strict enforcement mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation-strict-enforcement)

---

## Section 4 — Risk Remediation

**Goal**: Playbooks and procedures for remediating compromised identities.

### 4.1 — Self-Service Remediation Flows

Content to cover:
- User experience during risk-based MFA challenge (sign-in risk)
- User experience during password change requirement (user risk)
- SSPR prerequisites and configuration for risk remediation
- Troubleshooting users who cannot complete self-remediation (no registered methods)

Citation sources:
- [Self-service password reset](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks)
- [Risk-based SSPR tutorial](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-risk-based-sspr-mfa)

### 4.2 — Administrator Incident Response Playbook — Compromised Account

Content to cover:
- Step-by-step playbook: detect (ID Protection alert) → contain (disable account, revoke sessions) → investigate (sign-in logs, audit logs, mailbox access) → remediate (password reset, MFA re-registration) → recover (restore access with new credentials) → document (Privacy Act breach assessment)
- Evidence collection for breach notification assessment
- Coordination with Microsoft Sentinel for investigation

Citation sources:
- [Remediate risks and unblock users](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock)
- [Investigate incidents in Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/investigate-incidents)
- [Privacy Act 1988 — Notifiable Data Breaches](https://www.legislation.gov.au/Series/C2004A03712)
- [OAIC — Notifiable Data Breaches scheme](https://www.oaic.gov.au/privacy/notifiable-data-breaches)

### 4.3 — Automated Remediation with Sentinel Playbooks

Content to cover:
- Playbook: High user risk detected → disable account + notify SOC via Teams
- Playbook: High sign-in risk detected → revoke sessions + require MFA + create Sentinel incident
- Playbook: Leaked credentials detected → force password reset + disable legacy auth for user
- Testing and validating automated response playbooks in non-production

Citation sources:
- [Automate responses with Sentinel playbooks](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks)
- [Microsoft Sentinel playbook templates](https://learn.microsoft.com/en-us/azure/sentinel/use-playbook-templates)

---

## Section 5 — Integration with Conditional Access

**Goal**: Guide to integrating ID Protection signals with Conditional Access for adaptive access control.

### 5.1 — Risk-Based Named Locations and Trusted IPs

Content to cover:
- How Named Locations interact with risk detections (trusted locations reduce risk for some detections)
- Configuring corporate IP ranges as trusted — impact on atypical travel and unfamiliar properties detections
- Multi-Factor Authentication trusted IPs vs. Conditional Access Named Locations

Citation sources:
- [Named locations in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)
- [Trusted IPs — MFA service settings](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-mfasettings#trusted-ips)

### 5.2 — Step-Up Authentication Patterns

Content to cover:
- Designing step-up MFA flows for risk elevation mid-session (CAE integration)
- Configuring sign-in frequency to require fresh authentication for sensitive operations
- Authentication context — requiring specific authentication strength for specific applications when risk is elevated
- Combining device compliance requirement with risk condition for layered verification

Citation sources:
- [Authentication context in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#authentication-context)
- [Sign-in frequency control](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime)

### 5.3 — Monitoring Conditional Access Risk Policy Effectiveness

Content to cover:
- Using the Conditional Access insights and reporting workbook
- Tracking sign-ins blocked by risk policy vs. sign-ins challenged by risk policy
- Identifying users who successfully complete risk challenge (policy working as intended)
- Identifying users who cannot complete challenge (blocked — may need admin assistance)
- KQL queries for Sentinel monitoring of risk policy outcomes

Citation sources:
- [Conditional Access insights workbook](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting)
- [Sign-in logs in Sentinel — SignInLogs table](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/signinlogs)
