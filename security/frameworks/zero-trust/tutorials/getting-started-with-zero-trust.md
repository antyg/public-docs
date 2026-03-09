---
title: "Getting Started with Zero Trust in Azure"
status: "published"
last_updated: "2026-03-09"
audience: "Security engineers and IT administrators beginning Zero Trust adoption using Microsoft Azure and Microsoft 365"
document_type: "tutorial"
domain: "security"
---

# Getting Started with Zero Trust in Azure

---

## Overview

This tutorial walks you through the first phase of Zero Trust adoption for a Microsoft-centric environment. By the end, you will have completed your identity foundation — the starting point of every Zero Trust deployment — with phishing-resistant MFA, Conditional Access policies, and privileged access controls configured and active.

Zero Trust is a security model based on three principles: **verify explicitly**, **use least privilege access**, and **assume breach**. It replaces the traditional "trust the network perimeter" model with continuous verification of every access request, regardless of where it originates. For the authoritative Microsoft definition, see [Zero Trust Guidance Center](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview).

The [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview) organises Zero Trust deployment into six pillars: identities, endpoints, data, applications, infrastructure, and networks. This tutorial covers the **identities** pillar — the highest-priority starting point.

---

## Before You Begin

You need:

- Microsoft Entra ID with at least **Microsoft Entra ID P1** licences (P2 recommended for full risk-based capabilities)
- **Global Administrator** or **Security Administrator** role
- Access to the [Microsoft Entra admin centre](https://entra.microsoft.com) and [Microsoft Defender portal](https://security.microsoft.com)
- A list of your most privileged accounts (Global Administrators, Privileged Role Administrators)

---

## Step 1 — Understand Zero Trust Principles in Practice

Before making changes, understand how each Zero Trust principle translates to specific technical actions:

| Principle | What It Means in Practice | Primary Microsoft Control |
|-----------|--------------------------|--------------------------|
| **Verify Explicitly** | Every access request authenticated and authorised using all available signals (identity, device, location, risk) | [Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) |
| **Use Least Privilege** | Users and services have only the access they need, for only as long as they need it | [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure); RBAC |
| **Assume Breach** | Design systems as if the attacker is already inside; segment, monitor, and minimise blast radius | [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview); [Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender) |

---

## Step 2 — Assess Your Identity Foundation

### 2a — Review Current Authentication Methods

In [Microsoft Entra admin centre](https://entra.microsoft.com), navigate to **Protection > Authentication methods > Policies**. Check:

- Which authentication methods are enabled (SMS, email OTP, FIDO2, Windows Hello for Business, Authenticator app)
- Whether phishing-resistant methods (FIDO2, Windows Hello for Business, certificate-based authentication) are enabled

### 2b — Check for Legacy Authentication

In Microsoft Entra admin centre, navigate to **Identity > Monitoring & health > Sign-in logs**. Filter by:
- **Client app**: Exchange ActiveSync, Other clients

Any successful sign-ins from these clients indicate legacy authentication is in use and must be addressed — legacy protocols cannot satisfy MFA challenges and are a primary attack vector.

### 2c — Audit Privileged Accounts

Navigate to **Identity > Roles & admins > Roles & admins**. For each high-privileged role (Global Administrator, Privileged Role Administrator, Security Administrator):

- Count the number of permanent (active) members
- Note which accounts are not using phishing-resistant MFA
- Identify any shared or service accounts with privileged roles

Zero Trust requires that every privileged action be tied to a specific, verified identity. Shared accounts and service accounts with permanent privileged roles must be remediated.

---

## Step 3 — Eliminate Passwords as the Sole Authentication Factor

The "verify explicitly" principle requires more than passwords. Passwords are compromised constantly — [Microsoft analyses 78 trillion security signals per day](https://www.microsoft.com/en-us/security/blog/2024/10/15/microsoft-digital-defense-report-2024-report/) and sees over 600 million identity attacks daily.

### 3a — Enable the Microsoft Authenticator App

Navigate to **Protection > Authentication methods > Policies > Microsoft Authenticator**. Enable the policy and configure:

- **Authentication mode**: Any (allows both push notifications and passwordless phone sign-in)
- **Show application name in push and passwordless notifications**: Enabled
- **Show geographic location in push and passwordless notifications**: Enabled

Showing application name and location in notifications helps users recognise and reject MFA fatigue (push bombing) attacks.

### 3b — Enable FIDO2 Security Keys

Navigate to **Protection > Authentication methods > Policies > FIDO2 security key**. Enable for privileged users. Configure:

- **Enforce attestation**: Enabled (ensures only hardware-backed keys are accepted)
- **Restrict specific keys**: Configure an allowlist of approved FIDO2 key brands

FIDO2 keys and Windows Hello for Business are the two phishing-resistant MFA methods required for the highest Zero Trust assurance levels.

---

## Step 4 — Implement Conditional Access Policies

Conditional Access is the Zero Trust policy engine for identity — it evaluates every access request and grants, blocks, or challenges based on signals.

### 4a — Create a Baseline MFA Policy

In Microsoft Entra admin centre, navigate to **Protection > Conditional Access > Policies > New policy**:

- **Name**: ZT-001 — Require MFA for All Users
- **Users**: All users; **Exclude**: Break-glass accounts (2 accounts maximum)
- **Target resources**: All cloud apps
- **Grant**: Require multifactor authentication
- **Session**: Sign-in frequency — 1 hour (for sensitive apps)

### 4b — Require Phishing-Resistant MFA for Privileged Users

Create a second policy:

- **Name**: ZT-002 — Require Phishing-Resistant MFA for Privileged Roles
- **Users**: Select all directory roles with privileged access
- **Target resources**: All cloud apps
- **Grant**: Require authentication strength — **Phishing-resistant MFA**

[Authentication Strengths](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview) are a CSF 2.0-introduced control surface that allows you to specify not just "MFA required" but *which type* of MFA is acceptable.

### 4c — Block Legacy Authentication

- **Name**: ZT-003 — Block Legacy Authentication
- **Users**: All users
- **Conditions > Client apps**: Enable both **Exchange ActiveSync clients** and **Other clients**
- **Grant**: Block access

### 4d — Enable Report-Only Mode First

Before enforcing any new Conditional Access policy, set it to **Report-only** for 48–72 hours. Review sign-in logs to identify users who would be blocked. This prevents accidental lockouts.

Navigate to **Monitoring > Sign-in logs** and filter by **Conditional Access: Report-only — Failure** to see impact.

---

## Step 5 — Enable Privileged Identity Management

[Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) implements just-in-time (JIT) access — the core mechanism for "use least privilege" in the identity pillar.

### 5a — Convert Permanent Assignments to Eligible

Navigate to **Identity Governance > Privileged Identity Management > Microsoft Entra roles**. For each privileged role:

1. Click the role > **Assignments**
2. Identify accounts with **Permanent Active** assignments
3. Remove the permanent assignment
4. Add the account as **Eligible** with a maximum activation duration of 4–8 hours

Keep a maximum of **two break-glass accounts** with permanent Global Administrator access. These must be cloud-only accounts (not synced from on-premises), using FIDO2 keys, and stored in a secured location. See [Microsoft — Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access).

### 5b — Configure PIM Activation Requirements

For Global Administrator and Privileged Role Administrator roles, configure:

- **Require justification on activation**: Yes
- **Require ticket information on activation**: Yes (reference incident/change request number)
- **Require approval to activate**: Yes — assign at least two approvers
- **Require Azure MFA**: Yes

---

## Step 6 — Verify Your Identity Foundation

After completing Steps 3–5, verify the following before proceeding to the endpoints pillar:

| Check | How to Verify | Pass Criteria |
|-------|--------------|---------------|
| MFA required for all users | Sign-in logs filtered by Conditional Access results | No sign-ins succeed without MFA |
| Phishing-resistant MFA for privileged accounts | Authentication method reports | All privileged accounts registered for FIDO2 or Windows Hello |
| Legacy auth blocked | Sign-in logs filtered by legacy auth clients | Zero successful legacy auth sign-ins |
| No permanent privileged assignments | PIM — Active assignments view | Only break-glass accounts have permanent assignments |

---

## Next Steps

The identity foundation is the prerequisite for all other Zero Trust pillars. Continue with:

- [Implement Zero Trust Pillars](../how-to/implement-zero-trust-pillars.md) — All six pillars (endpoints, data, apps, infrastructure, network)
- [Zero Trust Maturity Assessment](../reference/zero-trust-maturity.md) — Assess your maturity against the CISA Zero Trust Maturity Model v2.0
- [Zero Trust Principles Explained](../explanation/zero-trust-principles.md) — Verify explicitly, least privilege, assume breach in depth

### Official Resources

- [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview)
- [Microsoft Zero Trust Guidance Center](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview)
- [Zero Trust Assessment Tool](https://microsoft.github.io/zerotrustassessment/)
- [CISA Zero Trust Maturity Model v2.0](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model)
- [NIST SP 800-207 Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
