---
title: "Conditional Access"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Conditional Access

---

## Purpose

This folder is designated for Microsoft Entra ID Conditional Access documentation. Conditional Access is Microsoft's Zero Trust policy engine — it evaluates signals from users, devices, locations, and applications to make real-time access control decisions.

Conditional Access is the primary mechanism for implementing risk-based authentication and is a core component of an [Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) compliant MFA deployment.

Microsoft Learn: [What is Conditional Access?](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)

---

## Scope

This documentation covers:

- Conditional Access policy design and components (assignments, conditions, grant controls, session controls)
- Named locations and trusted IP ranges
- Device compliance integration (Intune)
- Sign-in risk and user risk policies (Entra ID Protection)
- Policy templates and Microsoft-recommended baselines
- Exclusions, break-glass accounts, and policy testing

This documentation does not cover:

- Entra ID Identity Protection configuration (see `../../security/identity-protection/` — planned)
- Intune device compliance policy setup (see `../../endpoints/intune/`)
- MFA method configuration (see `../mfa/`)

---

## Planned Content

The following files are planned for future authoring. None have been created yet.

**Explanation**
- *(planned)* `explanation-how-conditional-access-works.md` — signal evaluation, policy engine, decision flow
- *(planned)* `explanation-zero-trust-architecture.md` — Conditional Access in Zero Trust context

**How-To**
- *(planned)* `how-to-create-mfa-policy.md` — require MFA for all users (Microsoft baseline)
- *(planned)* `how-to-require-compliant-device.md` — device compliance grant control
- *(planned)* `how-to-block-legacy-authentication.md` — block Basic Auth and legacy protocols
- *(planned)* `how-to-named-locations.md` — trusted IPs, country-based policies
- *(planned)* `how-to-test-and-validate-policies.md` — What If tool, report-only mode

**Reference**
- *(planned)* `reference-policy-components.md` — all conditions and controls documented
- *(planned)* `reference-microsoft-baseline-policies.md` — Microsoft-recommended policy templates

---

## Australian Context

The [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) Multi-Factor Authentication control at Maturity Level 2 and above requires MFA for all users accessing internet-facing services. Conditional Access is the mechanism for enforcing this requirement in Microsoft Entra ID tenants.

The [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requires risk-based access controls for privileged users. Conditional Access sign-in risk policies satisfy this requirement for cloud-based identity.

---

## Relationship to Other Domains

- **`../entra-id/`** — Entra ID tenant context and prerequisite configuration
- **`../mfa/`** — MFA methods configured via Authentication Methods policy; enforced via Conditional Access
- **`../password-policy/`** — Conditional Access as a compensating control for password policy changes
- **`../../endpoints/intune/`** — Device compliance policies referenced by Conditional Access grant controls
- **`../../security/identity-protection/`** — Risk signals consumed by Conditional Access (planned)

---

## Audience

- **Identity Engineers** — Designing and implementing Conditional Access policy sets
- **Security Architects** — Aligning Conditional Access with Zero Trust and Essential Eight requirements
- **M365 Administrators** — Managing day-to-day Conditional Access policy administration
- **Compliance Officers** — Verifying Conditional Access satisfies ISM and Essential Eight MFA obligations

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
