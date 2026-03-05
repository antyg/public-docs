# Microsoft Entra ID

**Domain**: Identity → Entra ID
**Status**: Seeded
**Platform**: Microsoft Entra ID (formerly Azure Active Directory)

---

## Purpose

This folder is designated for Microsoft Entra ID documentation, configuration guidance, and implementation patterns. Entra ID is Microsoft's cloud-native identity and access management service, serving as the identity platform for Azure, Microsoft 365, and thousands of SaaS applications.

---

## Planned Content Scope

### Core Entra ID Topics

- **Tenant Management**
  - Tenant configuration and organisation structure
  - Custom domains and branding
  - Tenant-level policies and settings

- **User and Group Management**
  - User provisioning and lifecycle management
  - Group types (security, Microsoft 365, dynamic membership)
  - Administrative units and delegation

- **Application Registrations**
  - App registration and service principal configuration
  - OAuth 2.0 and OpenID Connect flows
  - API permissions and consent frameworks
  - Multi-tenant applications

- **Hybrid Identity**
  - Azure AD Connect / Entra Connect configuration
  - Synchronisation topologies and filtering
  - Password hash sync vs. pass-through authentication
  - Hybrid Azure AD join patterns

---

## Relationship to Sibling Folders

- **`../password-policy/`** — Entra ID password policy implementation aligns with research findings
- **`../conditional-access/` (planned)** — Entra ID Conditional Access policies (may become dedicated sibling)
- **`../mfa/` (planned)** — Entra ID MFA configuration and authentication methods

**Note**: Authentication and Conditional Access may be promoted to dedicated sibling folders under `identity/` due to their cross-platform applicability (not exclusive to Entra ID).

---

## Relationship to Other Domains

- **`../../infrastructure/`** — Azure resource integration with Entra ID (managed identities, RBAC, Entra Domain Services)
- **`../../endpoints/`** — Endpoint authentication and identity integration for device management
- **`../../compliance/`** — Entra ID configuration to meet Essential Eight, ISM, and other framework requirements
- **`../../security/frameworks/`** — Identity control requirements that Entra ID must satisfy

---

## Future Content Development

As Entra ID documentation matures, content may include:

- Configuration walkthroughs for common scenarios
- Security baselines and hardening guides
- Integration patterns with external identity providers
- Governance and lifecycle automation
- Monitoring and diagnostics approaches
- Migration patterns (on-premises AD → Entra ID)

---

## Audience

- **Identity Architects** — Designing Entra ID tenant structures and policies
- **Azure Administrators** — Configuring Entra ID for Azure resource access
- **M365 Administrators** — Managing user identities and authentication
- **Application Developers** — Integrating applications with Entra ID authentication

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
