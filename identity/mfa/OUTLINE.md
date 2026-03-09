---
title: "MFA — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# MFA — Content Outline

**Citation Sources**: See §7 below

---

## 1. Authentication Factors (Explanation)

### 1.1 The Three Factor Types

- Something you know: memorised secrets (passwords, PINs)
- Something you have: possession factors (hardware tokens, mobile devices, smart cards)
- Something you are: biometric factors (fingerprint, face, iris)
- MFA requires at least two different factor types in a single authentication event

**Citation**: [NIST SP 800-63B-4 — Authentication Factor Types](https://pages.nist.gov/800-63-4/sp800-63b.html)

### 1.2 Authentication Methods Taxonomy

| Method | Factor Type | Phishing Resistant | Offline Capable | ACSC E8 ML |
|--------|------------|-------------------|-----------------|------------|
| FIDO2 / WebAuthn security key | Possession + biometric | Yes | No | ML2+ |
| Windows Hello for Business | Possession + biometric | Yes | No | ML2+ |
| Certificate-based auth (hardware) | Possession | Yes | No | ML2+ |
| Microsoft Authenticator (passkey) | Possession + biometric | Yes | No | ML2+ |
| Microsoft Authenticator (number match push) | Possession | Reduced risk | No | ML1+ |
| TOTP (third-party authenticator) | Possession | No | Yes | ML1+ |
| SMS OTP | Possession | No | No | Not recommended |
| Voice call OTP | Possession | No | No | Not recommended |
| Temporary Access Pass | Time-limited | N/A | No | Onboarding only |

**Citation**: [Microsoft Learn — Authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)
**Citation**: [ACSC — Essential Eight MFA](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

---

## 2. Phishing Resistance (Explanation)

### 2.1 What Makes an MFA Method Phishing-Resistant

- Phishing attacks intercept one-time codes (TOTP, SMS) in real time via adversary-in-the-middle proxy
- Phishing-resistant methods bind credentials cryptographically to the specific origin (relying party) at registration time
- Even if a user interacts with a phishing site, the credential cannot be presented to the legitimate site
- FIDO2/WebAuthn and WHfB use public key cryptography bound to the relying party ID — no credential reuse across origins

**Citation**: [Microsoft Learn — Phishing-resistant MFA methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
**Citation**: [FIDO Alliance — How FIDO Works](https://fidoalliance.org/how-fido-works/)
**Citation**: [W3C — WebAuthn Level 2](https://www.w3.org/TR/webauthn-2/)

### 2.2 Number Matching and Additional Context

Microsoft Authenticator number matching reduces (but does not eliminate) MFA fatigue attacks by requiring users to match a number displayed on the sign-in page in the app notification. This is not phishing-resistant — an adversary-in-the-middle attack can still forward the number match challenge.

**Citation**: [Microsoft Learn — Number matching in Microsoft Authenticator](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-number-match)

---

## 3. Essential Eight MFA Alignment (Explanation)

### 3.1 Maturity Level Requirements

| ML | User Scope | Service Scope | Method Requirement |
|----|-----------|--------------|-------------------|
| ML1 | All users | Internet-facing services, remote access | Any MFA |
| ML2 | Privileged users | All services | Phishing-resistant |
| ML2 | All other users | Internet-facing services | Any MFA |
| ML3 | All users | All services | Phishing-resistant |

**Citation**: [ACSC — Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

### 3.2 Mapping Entra ID Methods to E8 Levels

- FIDO2 security keys → ML2/ML3 (phishing-resistant)
- Windows Hello for Business → ML2/ML3 (phishing-resistant)
- Certificate-based authentication (hardware-backed) → ML2/ML3 (phishing-resistant)
- Microsoft Authenticator passkey → ML2/ML3 (phishing-resistant)
- Microsoft Authenticator push (number match) → ML1 only
- TOTP → ML1 only
- SMS → Not compliant at any level (avoid)

**Citation**: [Microsoft Learn — Authentication strengths and E8](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

---

## 4. Authentication Methods Policy Configuration (How-to)

### 4.1 Configure Authentication Methods Policy

Navigation: Microsoft Entra admin centre → Protection → Authentication methods → Policies

- Enable/disable each method per policy
- Target methods to specific groups (enable FIDO2 for pilot group before broad rollout)
- Configure Microsoft Authenticator settings: number matching, additional context

**Citation**: [Microsoft Learn — Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-authentication-methods-manage)

### 4.2 Migrate from Legacy MFA Policy

Two MFA control planes existed historically: per-user MFA (legacy) and Authentication Methods policy (current). Migration steps to consolidate to the modern policy.

**Citation**: [Microsoft Learn — Migrate to Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-number-match)

---

## 5. Deployment Patterns (How-to)

### 5.1 Microsoft Authenticator Rollout

- Enable in Authentication Methods policy
- Configure registration campaign (nudge users at sign-in)
- Enable number matching (required; Microsoft enforced this in 2023)
- Monitor registration via Authentication Methods Activity report

**Citation**: [Microsoft Learn — Microsoft Authenticator overview](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-authenticator-app)

### 5.2 FIDO2 Security Key Deployment

- Enable FIDO2 in Authentication Methods policy
- Configure FIDO2 settings: key restrictions (allow/block specific AAGUID), self-service registration
- User registration: Security info page (mysecurityinfo.microsoft.com)
- Helpdesk considerations: lost key recovery via Temporary Access Pass

**Citation**: [Microsoft Learn — Enable FIDO2 security key sign-in](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-security-key)

### 5.3 Registration Campaign

The registration campaign feature nudges users to register MFA methods at sign-in without blocking access immediately.

Navigation: Microsoft Entra admin centre → Protection → Authentication methods → Registration campaign

**Citation**: [Microsoft Learn — Registration campaign](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-registration-campaign)

---

## 6. Recovery Procedures (How-to)

### 6.1 Temporary Access Pass (TAP)

A TAP is a time-limited, one-time code issued by an administrator to allow a user to sign in without their MFA method — used for onboarding and recovery.

- Issue TAP: Entra admin centre → Users → select user → Authentication methods → Add authentication method → Temporary Access Pass
- TAP is single-use or multi-use (configurable), time-limited (1–30 days configurable)
- After TAP use, user must register a new MFA method

**Citation**: [Microsoft Learn — Temporary Access Pass](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-temporary-access-pass)

### 6.2 Helpdesk MFA Reset

Helpdesk admins with Authentication Administrator role can delete a user's registered MFA methods, forcing re-registration at next sign-in.

**Citation**: [Microsoft Learn — Delete authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods-manage)

---

## 7. Citation Sources

### Microsoft Learn

- [MFA overview](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks)
- [Authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)
- [Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-authentication-methods-manage)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Number matching](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-number-match)
- [FIDO2 security key sign-in](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-security-key)
- [Microsoft Authenticator overview](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-authenticator-app)
- [Registration campaign](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-registration-campaign)
- [Temporary Access Pass](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-temporary-access-pass)

### Standards and Specifications

- [NIST SP 800-63B-4 — Authentication Guidelines (July 2025)](https://pages.nist.gov/800-63-4/sp800-63b.html)
- [FIDO Alliance — How FIDO Works](https://fidoalliance.org/how-fido-works/)
- [W3C — Web Authentication Level 2](https://www.w3.org/TR/webauthn-2/)
- [TOTP RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)

### Australian Regulatory

- [ACSC — Essential Eight: Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
