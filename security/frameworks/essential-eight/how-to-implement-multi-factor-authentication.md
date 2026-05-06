---
title: "How to Implement Multi-Factor Authentication"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Multi-Factor Authentication

---

## Overview

This guide provides goal-oriented steps for implementing Multi-Factor Authentication (MFA) as defined by the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model). It covers progression from Maturity Level 1 through to Maturity Level 3, including MFA method selection, Conditional Access policy configuration, phishing-resistant authentication, and hardware token deployment.

MFA is the seventh Essential Eight control. It directly mitigates credential-based attacks including password spraying, phishing, and adversary-in-the-middle techniques. For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Prerequisites

Before beginning MFA implementation, confirm the following are in place:

- An identity provider capable of enforcing MFA (for example, [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks))
- Administrator access to configure authentication methods and Conditional Access policies
- A communication plan for notifying affected users
- Emergency access (break-glass) accounts created and credentials stored securely — these accounts must be excluded from MFA policies but monitored closely
- An understanding of any legacy applications in scope that may not support modern authentication

For cross-control dependencies, see the [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md).

---

## Maturity Level 1 — MFA for Important Data Repositories

**Objective**: Require MFA when users access important data repositories (cloud services, remote access, sensitive business systems).

**Estimated duration**: 6–10 weeks

### Step 1 — Select MFA authentication methods (1 week)

Assess which authentication methods are appropriate for your organisation. Options include:

| Method | Notes |
|--------|-------|
| [Microsoft Authenticator](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-phone) — push notification or number matching | Recommended for most users; reduces MFA fatigue when number matching is enabled |
| SMS or voice call | Accessible but less secure; acceptable as a fallback only |
| [FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless) | Phishing-resistant; required for ML3 (see below) |
| [Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/) | Certificate or key-based; phishing-resistant; suitable for domain-joined devices |

Register MFA methods in Entra ID under **Security > Authentication methods > Policies**. Enable at minimum one app-based method (Microsoft Authenticator or FIDO2) for all users.

### Step 2 — Enforce MFA for administrators first (1–2 weeks)

Enforce MFA for all privileged accounts before rolling out to general users. This validates the configuration without broad user impact.

1. In the [Entra admin centre](https://entra.microsoft.com), navigate to **Protection > Conditional Access > Policies**.
2. Create a new policy targeting the **Directory roles** group (Global Administrator, Privileged Role Administrator, and equivalent privileged roles).
3. Under **Grant**, select **Require multifactor authentication**.
4. Set policy state to **Report-only** first, then move to **On** after validating sign-in logs.

Confirm administrators can complete the MFA challenge before proceeding. Document the break-glass account exclusion in your access policy.

### Step 3 — Roll out MFA to all users (phased, 4–8 weeks)

Deploy MFA to general users in phases to limit helpdesk impact and give users time to register.

1. Communicate the rollout schedule, registration deadline, and support contact to all users.
2. Enable the [combined security information registration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-registration-mfa-sspr-combined) experience so users can register MFA and self-service password reset in one step (**Entra admin centre > Identity > Users > User settings > Manage user feature settings**).
3. Create Conditional Access policies enforcing MFA for each target system or application group. Phase by department or risk tier.
4. Monitor registration progress via **Entra admin centre > Identity > Users > Authentication methods > Registration and reset events**.
5. Assist users who have not registered before the enforcement date. Provide multiple method options to accommodate varying device access.

### Step 4 — Configure Conditional Access for important data repositories (2–3 weeks)

Conditional Access is the enforcement mechanism for MFA in Entra ID. Create policies covering:

- All cloud applications tagged as important data repositories
- VPN and remote access gateways (where supported by the identity provider)
- Sign-in risk conditions where applicable (requires Entra ID P2 or Microsoft 365 E5)

For each policy, navigate to **Protection > Conditional Access > Policies > New policy** and configure:

| Setting | Value |
|---------|-------|
| Users | All users (exclude break-glass accounts) |
| Target resources | Selected cloud apps (or All cloud apps for broad coverage) |
| Conditions | Optionally scope by sign-in risk or location |
| Grant | Require multifactor authentication |

### Step 5 — Validate and document ML1 completion

Confirm the following before claiming ML1 compliance:

- All user accounts are enrolled in at least one MFA method (report: **Entra admin centre > Identity > Users > Authentication methods > User registration details**)
- MFA is enforced via Conditional Access for all designated important data repositories
- MFA adoption is monitored via sign-in logs and reported to security stakeholders
- Emergency access procedures are documented and the break-glass account process has been tested

**ML1 success criteria:**

- 100% of users enrolled in MFA
- MFA enforced for all access to important data repositories
- MFA adoption monitored and reported
- Emergency access procedures documented and tested

---

## Maturity Level 2 — MFA for All Internet-Facing Services

**Objective**: Extend MFA enforcement from important data repositories to all internet-facing services.

**Estimated duration**: 6–12 months after achieving ML1

**Key enhancement from ML1**: Broaden the Conditional Access policy scope from designated important data repositories to all internet-facing services — including web portals, APIs with user-interactive authentication, and any external-facing service that authenticates against the identity provider.

### Step 1 — Inventory all internet-facing services

Produce a complete list of services accessible from the internet that authenticate users through your identity provider. Include:

- Cloud productivity and collaboration platforms
- Web-based management portals
- Remote access services (VPN, Remote Desktop Gateway, virtual desktop infrastructure)
- Partner-facing portals
- Third-party SaaS applications federated with Entra ID

Review Entra ID's **Enterprise applications** list and cross-reference with network egress logs to identify any gaps.

### Step 2 — Extend Conditional Access coverage

Update existing Conditional Access policies or create additional policies to cover all identified internet-facing services. For broad coverage:

1. Create a policy targeting **All cloud apps** with MFA as the grant condition.
2. Use exclusions carefully — exclude only break-glass accounts and service accounts that cannot support MFA (and apply compensating controls to those accounts).
3. Use **Named locations** to scope policies if some on-premises services are excluded at this maturity level.

### Step 3 — Address legacy authentication

Legacy authentication protocols (SMTP AUTH, basic authentication, older Exchange ActiveSync clients) do not support MFA challenge. At ML2, block legacy authentication for all users.

1. In Conditional Access, create a policy targeting **All users** with the condition **Client apps: Exchange ActiveSync clients and Other clients**.
2. Set the grant to **Block access**.
3. Review sign-in logs for legacy authentication attempts before enforcing (**Sign-ins > Filter: Client app = Other clients**).

### Step 4 — Validate ML2 completion

- MFA enforced for all internet-facing services (not limited to important data repositories)
- Legacy authentication blocked for all users
- Conditional Access policy coverage reviewed and documented

---

## Maturity Level 3 — Phishing-Resistant MFA for All Access

**Objective**: Require phishing-resistant MFA for all access, including on-premises resources. Standard push-notification or SMS MFA is no longer sufficient for ML3.

**Estimated duration**: 8–16 months after achieving ML2

**Key enhancement from ML2**: Replace or supplement standard MFA with phishing-resistant methods (FIDO2 security keys or Windows Hello for Business) and extend enforcement to on-premises resources.

### Step 1 — Plan phishing-resistant method deployment

Select the phishing-resistant method appropriate to your environment:

| Method | Best for | Notes |
|--------|----------|-------|
| [FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-phone) | Shared workstations, high-privilege accounts, kiosk scenarios | Requires physical key procurement and distribution logistics |
| [Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/) | Domain-joined or Entra-joined Windows devices | Biometric or PIN-based; tied to the device; no additional hardware required for most users |
| [Certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-certificate-based-authentication) | Environments with an existing PKI | Smart card or derived credential; phishing-resistant by design |

For most Microsoft 365 environments, Windows Hello for Business is the lowest-friction path for device-bound users, with FIDO2 keys for shared or privileged scenarios.

### Step 2 — Enable phishing-resistant methods in Entra ID

1. Navigate to **Security > Authentication methods > Policies**.
2. Enable **FIDO2 security key** and configure allowed key restrictions if required.
3. Enable **Windows Hello for Business** (configured via Intune or Group Policy for device provisioning — see [Microsoft Learn: Windows Hello for Business deployment](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-deployment-guide)).

For Windows Hello for Business via Intune:
- Navigate to **Devices > Configuration profiles > Create profile**.
- Platform: **Windows 10 and later**, Profile type: **Identity protection**.
- Enable Windows Hello for Business and configure PIN complexity and biometric settings.

### Step 3 — Enforce phishing-resistant MFA via Conditional Access

Create Conditional Access policies that require phishing-resistant authentication strength, not just any MFA method:

1. In Conditional Access, navigate to **Authentication strengths** (under **Security > Authentication methods > Authentication strengths**).
2. Create or use the built-in **Phishing-resistant MFA** strength (FIDO2 + Windows Hello for Business + certificate-based authentication).
3. Update your Conditional Access policies to use **Require authentication strength > Phishing-resistant MFA** in the Grant control rather than the generic **Require multifactor authentication** setting.

### Step 4 — Extend MFA to on-premises resources

ML3 requires MFA for all access, including on-premises systems. Options depend on your on-premises infrastructure:

- **Entra ID Kerberos + Windows Hello for Business**: Enables passwordless sign-in to on-premises Active Directory resources from Entra-joined devices. See [Entra ID Kerberos documentation](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-security-key-on-premises).
- **Entra Private Access / Application Proxy with Conditional Access**: Broker on-premises applications through Entra ID so that Conditional Access policies (including MFA strength requirements) apply.
- **Network Policy Server (NPS) extension for Entra MFA**: Enforce Entra MFA for RADIUS-authenticated services (VPN, RD Gateway). See [NPS extension documentation](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-nps-extension).

### Step 5 — Validate ML3 completion

- Phishing-resistant MFA enforced for all users accessing all systems (cloud and on-premises)
- No users able to satisfy MFA requirements using SMS, voice call, or standard push notification alone
- Authentication strength policies documented and reviewed
- Hardware token or Windows Hello for Business provisioning complete for all users

---

## Common Challenges

| Challenge | Resolution |
|-----------|------------|
| User resistance to MFA enrolment | Emphasise the security benefit in user communications. Offer multiple authentication method options. Set a firm registration deadline with helpdesk support during the enrolment window. |
| Mobile phone coverage gaps for SMS fallback | Ensure at least one non-SMS method is available (Authenticator app or FIDO2 key). SMS should be a fallback only, not a primary method. |
| Legacy applications that do not support modern authentication | Identify these during the ML1 inventory phase. Plan migration or accept residual risk with documented compensating controls. Block legacy authentication protocols progressively as applications migrate. |
| Break-glass account management | Exclude break-glass accounts from MFA Conditional Access policies. Store credentials in a physically secured location. Audit all sign-ins against break-glass accounts via alerts. |
| FIDO2 key logistics | Procure keys in advance of the ML3 rollout phase. Establish a provisioning and replacement process. Consider Windows Hello for Business as the primary path for device-bound users to reduce key distribution overhead. |

---

## Verification

Use the following checks to verify MFA implementation at each maturity level.

### Evidence to collect for audit

- MFA policy documentation (Conditional Access policy export or equivalent)
- Conditional Access configuration screenshots or exports
- User registration report showing 100% enrolment (**Entra admin centre > Identity > Users > Authentication methods > User registration details**)
- MFA usage logs (sign-in logs filtered by MFA requirement)
- For ML3: Authentication strength policy configuration and phishing-resistant method provisioning records

### Automated verification

The [ACSC Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide) describes the evidence and testing requirements an assessor will apply. Review this guide when preparing for formal assessment.

---

## Related Resources

### ACSC

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [ACSC Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/multi-factor-authentication)
- [ACSC Implementing Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism/cyber-security-guidelines/guidelines-identity-management)

### This library

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md)
