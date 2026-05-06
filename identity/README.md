---
title: "Identity and Access Management"
status: "published"
last_updated: "2026-03-09"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Identity and Access Management

**Scope**: Identity and Access Management platforms, authentication, authorisation, directory services, and identity governance

---

## Purpose

This domain contains documentation, research, and technical guidance for Identity and Access Management (IAM) systems. It serves as the central knowledge base for authentication strategies, directory services, identity governance, and access control mechanisms across multiple IAM platforms.

---

## Content Overview

The identity domain consolidates research and implementation guidance for:

- **Authentication and authorisation** patterns and best practices
- **Directory services** configuration and management
- **Identity platform-specific** documentation (Entra ID, Okta, Ping Identity, etc.)
- **Identity governance** frameworks and lifecycle management
- **Password and credential** policies based on current security research

This folder bridges theoretical security frameworks (see `../security/frameworks/`) with practical IAM implementation across enterprise platforms.

---

## Folder Structure

### Subfolders

| Folder | Status | Description |
|--------|--------|-------------|
| `password-policy/` | Substantive | Research on password expiration policies, NIST guidance, and modern authentication approaches |
| `entra-id/` | Substantive | Microsoft Entra ID (formerly Azure AD) configuration, management, and architecture |
| `conditional-access/` | Seeded | Conditional Access policies, risk-based authentication, and Zero Trust implementation |
| `mfa/` | Seeded | Multi-factor authentication strategies, FIDO2, passwordless authentication |
| `okta/` | Seeded | Okta platform configuration, workflows, and integration patterns |
| `ping-identity/` | Seeded | Ping Identity platform documentation |

### Planned Expansion

Future subfolders will include:

- `identity-governance/` (planned) — Joiner/Mover/Leaver processes, access reviews, entitlement management

---

## Migrated Content

This domain includes content originally developed as part of the identity platform research collection (legacy IDP workstream):

- **Password policy research** → `password-policy/`
  - Comprehensive analysis of password expiration policies with NIST SP 800-63B citations
  - Microsoft security guidance integration
  - Academic research supporting modern credential management

---

## Relationship to Other Domains

- **`../security/identity-protection/`** — Microsoft Entra ID Protection: identity risk detection, investigation workflows, and risk-based Conditional Access integration. Housed in `security/` because its core concern is threat detection and SOC operations, not identity configuration.
- **`../security/frameworks/`** — Defines control requirements; identity/ provides implementation patterns
- **`../compliance/`** — Bridges frameworks with technology; uses identity/ docs for IAM-specific alignment guidance
- **`../infrastructure/`** — Azure-native identity services (Entra ID integration with Azure resources)
- **`../endpoints/`** — Endpoint authentication and identity integration for device management

---

## Audience

- Identity and Access Management architects
- Security engineers implementing authentication systems
- Platform administrators managing directory services
- Compliance teams validating identity controls

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
