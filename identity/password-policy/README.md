# Password Policy Research

**Domain**: Identity → Password Policy
**Status**: Substantive
**Content Source**: Migrated from `other-infra/IDP/`

---

## Purpose

This folder contains comprehensive research and technical guidance on password policies, with particular focus on the security implications of password expiration requirements. The content challenges traditional password management practices and provides evidence-based recommendations aligned with modern security standards.

---

## Content Overview

### Primary Document

**Password Expiration Policy Research** (~43KB)

A substantive research document examining why mandatory password expiration is counterproductive to security objectives. The document synthesises guidance from:

- **NIST SP 800-63B** — Digital Identity Guidelines
- **Microsoft Security** — Modern authentication guidance and Entra ID best practices
- **Academic Research** — Studies on user behaviour and password security
- **Industry Standards** — Current thinking from security organisations

### Key Arguments

The research demonstrates that password expiration policies:

- Encourage predictable password patterns (incremental changes)
- Reduce password complexity as users compensate for memorisation burden
- Increase helpdesk load and operational overhead
- Contradict modern security standards (NIST, Microsoft, NCSC)
- Are less effective than threat detection and credential monitoring

---

## Technologies Covered

- **Azure AD / Microsoft Entra ID** — Password policy configuration and modern authentication
- **Hybrid Identity** — On-premises Active Directory synchronisation
- **Multi-Factor Authentication** — Compensating controls for password-based authentication
- **Conditional Access** — Risk-based authentication policies

---

## Relationship to Sibling Folders

- **`../entra-id/`** — Platform-specific implementation of password policies in Entra ID
- **`../mfa/` (planned)** — Compensating controls that reduce reliance on password strength
- **`../conditional-access/` (planned)** — Risk-based policies that supersede time-based expiration

---

## Relationship to Other Domains

- **`../../security/frameworks/`** — Essential Eight, ISM controls on credential management
- **`../../compliance/`** — How to meet framework requirements without password expiration
- **`../../endpoints/`** — Endpoint password policy enforcement and device compliance

---

## Audience

- **Security Architects** — Designing password policies aligned with modern standards
- **Compliance Officers** — Justifying departure from legacy password expiration requirements
- **Identity Engineers** — Implementing evidence-based credential policies
- **Auditors** — Understanding security rationale for policy decisions

---

## Migration Notes

This content was relocated from the legacy `other-infra/IDP/` structure as part of the domain reorganisation. The research document represents significant investment in literature review and standards analysis, and serves as a reference for policy discussions with stakeholders who default to traditional password expiration requirements.

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
