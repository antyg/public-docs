---
title: "Microsoft Entra ID Protection"
status: "draft"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Microsoft Entra ID Protection

---

## Overview

Microsoft Entra ID Protection is a cloud-native identity risk management service that uses machine learning to detect, investigate, and remediate identity-based risks. It analyses signals from Microsoft Entra ID, Microsoft Accounts, and gaming (Xbox) — processing trillions of signals to identify compromised identities and risky sign-ins before attackers can exploit them.

ID Protection produces **risk detections** — individual signals of suspicious activity — and aggregates them into **user risk** (the cumulative risk associated with an account) and **sign-in risk** (the risk of a specific authentication event). These risk levels feed directly into [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) to enforce adaptive, risk-based access policies.

Source: [What is Microsoft Entra ID Protection?](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)

---

## Scope

This documentation covers Microsoft Entra ID Protection configuration, risk policy management, investigation workflows, and integration with Conditional Access. It addresses:

- Risk detection types and their significance
- User risk and sign-in risk policy configuration
- Risk-based Conditional Access policies
- Risk remediation workflows (admin and self-service)
- Integration with Microsoft Sentinel for SIEM investigation
- Monitoring and reporting through the ID Protection dashboard

It does not cover Microsoft Entra ID core authentication configuration, Conditional Access policies for non-risk scenarios, or Microsoft Defender XDR identity detections (Microsoft Defender for Identity / MDI).

---

## Licensing

Full ID Protection capabilities require **Microsoft Entra ID P2** or the **Microsoft Entra Suite** licence. A subset of features (limited risk reporting) is available with Microsoft Entra ID P1.

Source: [Microsoft Entra ID Protection licensing](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection#license-requirements)

---

## How Risk Detection Works

ID Protection continuously evaluates sign-in and account activity against known attack patterns and behavioural baselines. When suspicious activity is detected, it generates a risk detection at one of three levels:

| Risk Level | Description | Typical Response |
|-----------|-------------|-----------------|
| **Low** | Activity is unusual but within a reasonable range; may be legitimate | Log and monitor |
| **Medium** | Activity suggests a meaningful probability of compromise | Require MFA or password change |
| **High** | Activity strongly indicates compromise; immediate action warranted | Block access or require secure password reset + MFA |

Risk levels for both user risk and sign-in risk are evaluated independently. A user can have high user risk (based on accumulated detections over time) while a specific sign-in shows low sign-in risk, or vice versa.

Source: [Risk detections in Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks)

---

## Risk Detection Types

### Sign-In Risk Detections

Sign-in risk detections evaluate the real-time context of an authentication event:

| Detection | Description | Typical Trigger |
|-----------|-------------|----------------|
| **Atypical travel** | Sign-in from location geographically impossible given prior sign-in timing | VPN or legitimate travel edge case; also genuine account sharing |
| **Anonymous IP address** | Sign-in from known anonymous infrastructure (Tor, anonymising proxies) | Attacker concealing origin |
| **Malware-linked IP address** | Sign-in from IP associated with botnet activity | Compromised network egress |
| **Unfamiliar sign-in properties** | Sign-in properties (device, browser, location) differ from established baseline | New device or location — may be legitimate |
| **Password spray** | Multiple accounts targeted with common passwords | Credential stuffing attack |
| **Token issuer anomaly** | Abnormalities in the authentication token itself | Token theft or replay attack |

### User Risk Detections

User risk detections assess the overall compromise likelihood for an account based on accumulated signals over time:

| Detection | Description | Typical Trigger |
|-----------|-------------|----------------|
| **Leaked credentials** | Account credentials found in dark web data breach repositories | Credential breach — account must be treated as compromised |
| **Microsoft Entra threat intelligence** | Microsoft's internal threat intelligence identifies the account as at risk | Attack campaigns targeting known accounts |
| **Anomalous user activity** | Account behaviour deviates significantly from established baseline | Insider threat or persistent access by attacker |
| **Suspicious API calls** | Unusual API activity patterns from the account | Post-compromise reconnaissance or data exfiltration |

Source: [What is risk? — Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks)

**August 2025 update**: Microsoft enhanced detection quality to increase accuracy and reduce ambiguous alerts, with particular improvements for passwordless authentication methods (FIDO2). Administrators receive more reliable risk detections with fewer irrelevant notifications.

---

## Risk Policy Integration with Conditional Access

The recommended approach for enforcing risk-based access policies is through **Conditional Access** — not the legacy ID Protection risk policies (which are retiring October 1, 2026).

### User Risk Policy

Create a Conditional Access policy that triggers when user risk reaches a threshold:

| Setting | Recommended Value |
|---------|-----------------|
| Users | All users (exclude break-glass accounts) |
| Sign-in risk level | Not applicable (use user risk condition) |
| User risk level | High |
| Grant | Require password change (forces secure password reset via SSPR) |
| Session | Sign-in frequency — every time |

This forces high-risk users to reset their password before regaining access. The password reset revokes all active sessions, neutralising any active attacker sessions.

Source: [Configure risk policies in Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

### Sign-In Risk Policy

Create a Conditional Access policy triggered by sign-in risk:

| Setting | Recommended Value |
|---------|-----------------|
| Users | All users |
| Sign-in risk level | Medium or higher |
| Grant | Require multifactor authentication |

This forces re-authentication via MFA for any sign-in flagged as medium or high risk — blocking the attacker while allowing the legitimate user to proceed after verification.

**Legacy policy retirement**: The native ID Protection user risk policy and sign-in risk policy (configured within ID Protection settings) are retiring **October 1, 2026**. All risk-based policies must be migrated to Conditional Access before this date.

Source: [Migrate ID Protection risk policies to Conditional Access](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Risk Remediation

### User Self-Remediation

When a risk-based Conditional Access policy challenges a user, the self-remediation flow:

1. **Sign-in risk** — User completes MFA; successful MFA dismisses the sign-in risk
2. **User risk** — User completes a secure password reset via Self-Service Password Reset (SSPR); password change dismisses user risk and revokes all sessions

Self-remediation reduces SOC workload by allowing users to unblock themselves without administrator intervention. It requires:
- [Microsoft Entra SSPR](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks) enabled
- Conditional Access configured to require password change for high user risk (not just block)

### Administrator Remediation

Administrators can manually remediate risks from the **ID Protection dashboard**:

- **Confirm user compromised** — Promotes user risk to high; triggers policy enforcement
- **Dismiss user risk** — Clears accumulated user risk detections (use after confirming false positive)
- **Confirm sign-in safe** — Marks a specific sign-in detection as a false positive (improves ML model)
- **Block user** — Prevents all sign-ins; use when immediate containment is required

Navigate to [Microsoft Entra admin centre](https://entra.microsoft.com) > **Protection > Identity Protection > Risky users** or **Risky sign-ins**.

---

## Monitoring and Reporting

The ID Protection dashboard provides three primary reports:

| Report | Content | Use Case |
|--------|---------|---------|
| **Risky users** | Users with active risk detections; current risk level; last risky sign-in | Identify accounts requiring investigation or remediation |
| **Risky sign-ins** | Individual sign-in events flagged as risky; detection type, risk level, status | Investigate specific authentication events |
| **Risk detections** | All individual detection events; raw signal details | Deep investigation; false positive analysis |

Navigate to **Protection > Identity Protection** in the [Microsoft Entra admin centre](https://entra.microsoft.com).

Source: [Investigate risk with Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-investigate-risk)

---

## Integration with Microsoft Sentinel

Stream ID Protection risk data to Microsoft Sentinel for:

- Long-term retention beyond the default 30-day report window
- Correlation with other security signals (endpoint, network, application)
- Custom analytics rules and hunting queries on identity risk data
- Automated response playbooks (auto-disable risky users, notify SOC)

Enable the **Microsoft Entra ID** data connector in Sentinel to ingest:
- `SignInLogs` — all sign-in events including risk level
- `AADUserRiskEvents` — individual risk detections
- `AADRiskyUsers` — current risk state per user

Source: [Connect Microsoft Entra ID to Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/connect-azure-active-directory)

---

## Australian Regulatory Context

- **Essential Eight Strategy 7 — MFA**: ID Protection risk-based policies strengthen MFA enforcement by requiring MFA step-up when sign-in risk is elevated — exceeding the basic ML2 MFA requirement of the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- **ISM access control**: The [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requires monitoring for indicators of account compromise; ID Protection directly implements this through continuous risk assessment and alerting
- **Privacy Act 1988 (Cth)**: Compromised identities may constitute a notifiable data breach under the [Australian Privacy Act](https://www.legislation.gov.au/Series/C2004A03712). Integrate ID Protection with incident response procedures to ensure timely breach notification assessment

---

## Related Resources

- [Microsoft Entra ID Protection overview](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- [Risk detections reference](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Investigate risk with ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-investigate-risk)
- [Conditional Access — risk conditions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#user-risk)
- [Microsoft Entra SSPR](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Privacy Act 1988 (Cth)](https://www.legislation.gov.au/Series/C2004A03712)
