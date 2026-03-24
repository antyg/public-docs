---
title: "Microsoft Entra ID"
status: "draft"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Microsoft Entra ID

---

## Purpose

This folder contains authoritative documentation for Microsoft Entra ID — Microsoft's cloud-native identity and access management (IAM) service. Entra ID is the identity platform for Azure, Microsoft 365, and thousands of SaaS applications.

Content is structured per the [Diátaxis framework](https://diataxis.fr/): explanation (architecture understanding), how-to (implementation guides), and reference (configuration tables and API reference).

Microsoft Learn: [What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)

---

## Content Structure

| Prefix | Diátaxis Type | Content |
|--------|--------------|---------|
| `explanation-` | Explanation | Architecture overview, identity types, protocol reference |
| `how-to-` | How-to | Tenant configuration, user/group management, app registrations, directory sync |
| `reference-` | Reference | Configuration tables, role reference, PowerShell commands, Graph API endpoints |

---

## Key Documents

| Document | Description |
|----------|-------------|
| [`explanation-identity-architecture.md`](explanation-identity-architecture.md) | Entra ID role in identity architecture — tenant model, hybrid identity, control plane, Australian compliance mapping |
| [`explanation-architecture-overview.md`](explanation-architecture-overview.md) | Entra ID architecture — tenant model, identity types, authentication protocols, licensing tiers |
| [`how-to-configure-tenant-basics.md`](how-to-configure-tenant-basics.md) | Tenant setup — custom domains, company branding, security defaults, diagnostic settings, SSPR, user settings |
| [`how-to-tenant-configuration.md`](how-to-tenant-configuration.md) | Configure custom domains, company branding, security defaults, SSPR, diagnostic settings |
| [`how-to-user-group-management.md`](how-to-user-group-management.md) | User provisioning and lifecycle, group types, dynamic membership rules, role assignment |
| [`how-to-app-registrations.md`](how-to-app-registrations.md) | App registration, OAuth 2.0 flows, API permissions, client credentials, app roles |
| [`how-to-directory-synchronisation.md`](how-to-directory-synchronisation.md) | Entra Connect deployment, authentication method selection (PHS/PTA/Federation), sync filtering |
| [`reference-entra-id-service-overview.md`](reference-entra-id-service-overview.md) | Service capabilities reference — licence tiers, identity types, protocols, authentication methods, endpoints, roles, PowerShell modules |
| [`reference-configuration-reference.md`](reference-configuration-reference.md) | Tenant settings, authentication methods, built-in roles, sync attributes, Graph API and PowerShell reference |

---

## Relationship to Sibling Folders

- **`../password-policy/`** — Password policy guidance and research; Entra ID implementation details
- **`../conditional-access/`** — Conditional Access policies (cross-platform; not exclusive to Entra ID)
- **`../mfa/`** — MFA configuration and authentication methods

---

## Relationship to Other Domains

- **`../../infrastructure/`** — Azure resource integration (managed identities, RBAC, Entra Domain Services)
- **`../../endpoints/`** — Endpoint authentication and device identity (Entra join, Intune)
- **`../../compliance/`** — Entra ID configuration to meet Essential Eight, ISM, and other framework requirements
- **`../../security/frameworks/`** — Identity control requirements that Entra ID must satisfy

---

## Audience

- **Identity Architects** — Designing Entra ID tenant structures and hybrid identity topologies
- **Azure Administrators** — Configuring Entra ID for Azure resource access
- **M365 Administrators** — Managing user identities and authentication policies
- **Application Developers** — Integrating applications with Entra ID via OAuth 2.0 and OIDC

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
