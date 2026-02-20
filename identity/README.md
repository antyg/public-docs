# Identity and Access Management

**Domain**: Identity
**Status**: Substantive
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

### Current Subfolders

| Folder | Status | Description |
|--------|--------|-------------|
| `password-policy/` | Substantive | Research on password expiration policies, NIST guidance, and modern authentication approaches |
| `entra-id/` | Seeded | Microsoft Entra ID (formerly Azure AD) configuration and management |

### Planned Expansion

Future subfolders will include:

- `conditional-access/` — Conditional Access policies, risk-based authentication, and Zero Trust implementation
- `mfa/` — Multi-factor authentication strategies, FIDO2, passwordless authentication
- `okta/` — Okta platform configuration, workflows, and integration patterns
- `ping/` — Ping Identity platform documentation
- `identity-governance/` — Joiner/Mover/Leaver processes, access reviews, entitlement management

---

## Migrated Content

This domain receives content from the legacy `other-infra/IDP/` structure:

- **Password policy research** (43KB document) → `password-policy/`
  - Comprehensive analysis of password expiration policies with NIST SP 800-63B citations
  - Microsoft security guidance integration
  - Academic research supporting modern credential management

---

## Relationship to Other Domains

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
