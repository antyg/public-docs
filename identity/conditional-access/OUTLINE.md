---
title: "Conditional Access — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Conditional Access — Content Outline

**Citation Sources**: See §8 below

---

## 1. How Conditional Access Works (Explanation)

### 1.1 The Policy Engine

- Signal collection phase: who is the user, what device are they on, what location, what app are they accessing, what risk signals are present
- Policy evaluation: all matching policies are evaluated; most restrictive result wins
- Decision: Allow, Allow with controls (MFA, compliant device), Block
- Session controls applied post-authentication (continuous access evaluation, app-enforced restrictions)

**Citation**: [Microsoft Learn — What is Conditional Access?](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)

### 1.2 Signals and the Zero Trust Model

- Conditional Access as the Zero Trust policy enforcement point
- "Never trust, always verify" — every access request evaluated regardless of network location
- Integration with Microsoft Defender for Endpoint, Intune, and Identity Protection risk signals

**Citation**: [Microsoft Learn — Zero Trust with Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)

---

## 2. Policy Components Reference (Reference)

### 2.1 Assignments — Users and Groups

- All users (with exclusions for break-glass accounts)
- Specific users or groups
- Directory roles (target privileged roles directly)
- Guest and external users
- Workload identities (service principals)

**Citation**: [Microsoft Learn — Conditional Access: Users and groups](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-users-groups)

### 2.2 Assignments — Target Resources

- All cloud apps (broadest scope — recommended for MFA baseline)
- Specific applications (target by app ID)
- User actions (register security information, register or join devices)
- Authentication context (step-up authentication for sensitive operations)
- Global Secure Access (Microsoft Entra Internet Access / Private Access)

**Citation**: [Microsoft Learn — Cloud apps or actions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps)

### 2.3 Conditions

| Condition | Purpose | Key Settings |
|-----------|---------|-------------|
| **Sign-in risk** | Entra ID Protection risk level | Low / Medium / High |
| **User risk** | Entra ID Protection user risk | Low / Medium / High |
| **Device platforms** | OS-specific policies | Windows, macOS, iOS, Android, Linux |
| **Locations** | Named locations (trusted IPs, countries) | Include/exclude named locations |
| **Client apps** | Modern vs. legacy authentication | Browser, mobile apps, desktop apps, Exchange ActiveSync |
| **Filter for devices** | Device attribute-based conditions | Compliant, Entra joined, specific attributes |
| **Insider risk** | Microsoft Purview insider risk level | Elevated, Minor, Moderate, Severe |

**Citation**: [Microsoft Learn — Conditional Access: Conditions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions)

### 2.4 Grant Controls

| Control | Description | Licence Required |
|---------|-------------|-----------------|
| Require multi-factor authentication | MFA via any registered method | Entra ID P1 |
| Require authentication strength | Specific MFA method strength (e.g., phishing-resistant) | Entra ID P1 |
| Require device to be marked as compliant | Intune compliance policy must pass | Entra ID P1 + Intune |
| Require Hybrid Azure AD joined device | Device must be domain-joined and synced | Entra ID P1 |
| Require approved client app | App must be in Microsoft-approved list | Entra ID P1 |
| Require app protection policy | Intune MAM policy must be applied | Entra ID P1 + Intune |
| Require password change | Force password reset for risky users | Entra ID P2 |

**Citation**: [Microsoft Learn — Grant controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-grant)

### 2.5 Session Controls

| Control | Description |
|---------|-------------|
| App-enforced restrictions | SharePoint and Exchange enforce own session controls |
| Conditional Access App Control | Microsoft Defender for Cloud Apps proxy |
| Sign-in frequency | Require re-authentication after configurable period |
| Persistent browser session | Prevent "stay signed in" on shared devices |
| Continuous access evaluation | Real-time revocation of access tokens |
| Customise continuous access evaluation | Strict location enforcement |

**Citation**: [Microsoft Learn — Session controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)

---

## 3. Named Locations (How-to)

- Defining trusted IP ranges (corporate offices, VPN egress IPs)
- Country/region-based locations
- Using named locations in policy conditions (include trusted, exclude untrusted)
- Limitations: IP-based locations are not phishing-resistant; prefer device compliance for strong assurance

**Citation**: [Microsoft Learn — Using the location condition in a Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)

---

## 4. Microsoft Baseline Policy Templates (Reference)

Microsoft publishes recommended Conditional Access policy templates. Key baselines:

| Policy | Purpose | Licence |
|--------|---------|---------|
| Require MFA for admins | All directory roles require MFA | P1 |
| Require MFA for all users | Broad MFA coverage | P1 |
| Require MFA for Azure management | Protect ARM API access | P1 |
| Block legacy authentication | Block Basic Auth, SMTP AUTH, etc. | P1 |
| Require compliant or Entra-joined device | Device compliance for all access | P1 + Intune |
| Require password change for high-risk users | Identity Protection integration | P2 |
| Require MFA for risky sign-ins | Identity Protection integration | P2 |

**Citation**: [Microsoft Learn — Conditional Access policy templates](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)

---

## 5. Essential Eight MFA Alignment (How-to)

### Maturity Level 1

- MFA required for all users accessing internet-facing services
- Implement: "Require MFA for all users" policy scoped to all cloud apps

### Maturity Level 2

- MFA phishing-resistant for privileged users
- Implement: "Require authentication strength: Phishing-resistant MFA" for directory roles
- Acceptable methods: FIDO2 security keys, Windows Hello for Business, certificate-based auth

### Maturity Level 3

- MFA phishing-resistant for all users
- Implement: "Require authentication strength: Phishing-resistant MFA" for all users, all apps

**Citation**: [ACSC — Essential Eight MFA](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
**Citation**: [Microsoft Learn — Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

---

## 6. Policy Testing and Validation (How-to)

### Report-Only Mode

Before enabling a policy, deploy in report-only mode to understand impact without blocking users.

**Citation**: [Microsoft Learn — Report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)

### What If Tool

Simulate a specific sign-in scenario to determine which policies would apply and what controls would be enforced.

**Navigation**: Microsoft Entra admin centre → Protection → Conditional Access → What If

**Citation**: [Microsoft Learn — What If tool](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)

### Break-Glass Accounts

Always exclude break-glass (emergency access) accounts from all Conditional Access policies. Break-glass accounts are cloud-only Global Administrators used only when other admin access is unavailable.

**Citation**: [Microsoft Learn — Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)

---

## 7. Authentication Strength Configuration (Reference)

Authentication strengths define which MFA method combinations are acceptable for a given policy. Built-in strengths:

| Strength | Acceptable Methods | E8 Maturity |
|----------|--------------------|-------------|
| Multifactor authentication | Any MFA combination | ML1 |
| Passwordless MFA | Passkeys, Windows Hello, cert-based auth | ML2 |
| Phishing-resistant MFA | FIDO2 keys, Windows Hello for Business, cert-based auth (hardware) | ML2–ML3 |

**Citation**: [Microsoft Learn — Authentication strengths overview](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

---

## 8. Citation Sources

### Microsoft Learn

- [Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Conditional Access policy components](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)
- [Users and groups condition](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-users-groups)
- [Cloud apps or actions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps)
- [Conditions reference](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions)
- [Grant controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-grant)
- [Session controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)
- [Named locations / location condition](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)
- [Policy templates (common policies)](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)
- [Report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [What If tool](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)
- [Emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

### Australian Regulatory

- [ACSC — Essential Eight: Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
