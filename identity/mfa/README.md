---
title: "Multi-Factor Authentication (MFA)"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Multi-Factor Authentication (MFA)

---

## Purpose

This folder is designated for multi-factor authentication (MFA) documentation covering authentication methods, registration flows, policy configuration, and operational guidance.

MFA is the single most impactful control for preventing account compromise. The [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) mandates MFA as one of eight prioritised mitigation strategies, with phishing-resistant MFA required at Maturity Level 2 and above.

Microsoft Learn: [How it works: Microsoft Entra multifactor authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks)
ACSC: [Essential Eight — Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

---

## Scope

This documentation covers:

- MFA authentication methods and their security properties (TOTP, FIDO2/WebAuthn, push notifications, SMS, certificate-based)
- MFA registration flows and user onboarding
- MFA policy configuration in Microsoft Entra ID (Authentication Methods policy)
- Phishing resistance and Essential Eight maturity alignment
- MFA for privileged accounts
- MFA helpdesk and recovery procedures

This documentation does not cover:

- Conditional Access policies that enforce MFA (see `../conditional-access/`)
- MFA vendor-specific platform configuration for Okta (see `../okta/`)
- MFA for Ping Identity (see `../ping-identity/`)
- Entra ID Identity Protection risk-based MFA (see `../../security/identity-protection/` — planned)

---

## Planned Content Structure

> The subdirectories and files below are planned content that has not yet been created. The tree shows the intended structure for future authoring.

```
mfa/
├── README.md                              ← this file
├── OUTLINE.md                             ← detailed content outline with citation sources
├── explanation/
│   ├── authentication-factors.md          ← something you know/have/are; factor types
│   ├── phishing-resistance.md             ← why FIDO2 and WHfB resist phishing
│   └── essential-eight-alignment.md       ← ML1/ML2/ML3 method requirements
├── how-to/
│   ├── configure-auth-methods-policy.md   ← Entra ID Authentication Methods policy
│   ├── deploy-microsoft-authenticator.md  ← Authenticator app rollout
│   ├── deploy-fido2-keys.md               ← FIDO2 security key deployment
│   ├── mfa-registration-campaign.md       ← nudge users to register
│   └── mfa-recovery-procedures.md         ← helpdesk reset, TAP issuance
└── reference/
    ├── method-comparison.md               ← method × property matrix (phishing-resistant, offline, etc.)
    └── settings-reference.md              ← Authentication Methods policy settings reference
```

---

## Australian Context

The [ACSC Essential Eight MFA control](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) defines specific requirements by maturity level:

| Maturity Level | Requirement |
|---------------|-------------|
| ML1 | MFA for all users accessing internet-facing services and remote access |
| ML2 | Phishing-resistant MFA for privileged users; MFA for all others |
| ML3 | Phishing-resistant MFA for all users accessing all services |

Phishing-resistant methods per ACSC include: FIDO2 security keys, Windows Hello for Business, certificate-based authentication (hardware-backed). SMS OTP and push notifications (without number matching) are not considered phishing-resistant.

The [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) also mandates MFA for privileged access and remote access scenarios.

---

## Relationship to Other Domains

- **`../conditional-access/`** — MFA enforcement via Conditional Access policies
- **`../entra-id/`** — Entra ID Authentication Methods policy and MFA registration
- **`../okta/`** — Okta-specific MFA configuration
- **`../ping-identity/`** — Ping Identity MFA configuration
- **`../../endpoints/`** — Windows Hello for Business device-side requirements
- **`../../security/frameworks/essential-eight/`** — Essential Eight MFA control alignment

---

## Audience

- **Identity Engineers** — Configuring and deploying MFA at scale
- **Security Architects** — Selecting appropriate MFA methods for Essential Eight and ISM compliance
- **Helpdesk Administrators** — MFA reset and recovery procedures
- **End Users** — MFA registration guides (planned — separate user-facing content)

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
