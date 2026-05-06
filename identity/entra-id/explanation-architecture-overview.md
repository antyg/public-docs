---
title: "Microsoft Entra ID — Architecture Overview"
status: "published"
last_updated: "2026-03-08"
audience: "Identity architects, Azure administrators, M365 administrators"
document_type: "explanation"
domain: "identity"
---

# Microsoft Entra ID — Architecture Overview

---

## What Is Microsoft Entra ID?

[Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis) (formerly Azure Active Directory) is Microsoft's cloud-native identity and access management (IAM) service. It is the identity platform underpinning Azure, Microsoft 365, and thousands of integrated SaaS applications.

Entra ID provides:

- **Authentication** — Who are you? Verifying user and application identities
- **Authorisation** — What can you do? Controlling access to resources
- **Identity lifecycle** — Provisioning, deprovisioning, and governing identities from creation to removal
- **Federation** — Extending trust to external identity providers (Okta, Ping Identity, AD FS)
- **Hybrid identity** — Bridging on-premises Active Directory with cloud services

---

## Entra ID vs. Active Directory Domain Services

Entra ID is a cloud-native IAM service and is distinct from on-premises Active Directory Domain Services (AD DS). Understanding the difference is essential for hybrid identity planning.

| Aspect                       | Entra ID                        | Active Directory DS                      |
| ---------------------------- | ------------------------------- | ---------------------------------------- |
| **Architecture**             | Cloud-native, multi-tenant SaaS | On-premises, hierarchical                |
| **Protocol**                 | OAuth 2.0, OIDC, SAML 2.0       | Kerberos, NTLM, LDAP                     |
| **Query language**           | Microsoft Graph REST API        | LDAP queries                             |
| **Organisational structure** | Flat — no OUs or GPOs           | Hierarchical OUs, Group Policy           |
| **Management**               | Entra admin centre, Graph API   | Active Directory Users & Computers, GPOs |
| **Device management**        | Entra join, Intune              | Domain join, Group Policy                |
| **On-premises sync**         | Entra Connect (optional)        | Native                                   |

Microsoft Learn: [Compare Active Directory to Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/compare-azure-ad-to-ad)

---

## Tenant Architecture

A **tenant** is a dedicated, isolated instance of Entra ID for an organisation. Every Microsoft 365 or Azure subscription is associated with exactly one Entra ID tenant.

Key tenant concepts:

- **Primary domain** — The initial `onmicrosoft.com` domain assigned at tenant creation; custom domains are added and verified separately
- **Tenant ID** — A globally unique GUID identifying the tenant
- **Directory** — The container for all users, groups, applications, and devices in the tenant
- **Administrative units** — Scoped management boundaries within a tenant, enabling delegation without full tenant admin rights

### Multi-Tenant Topologies

Some organisations operate multiple Entra ID tenants (e.g., separate tenants per subsidiary or regulatory boundary). Cross-tenant access is managed via [B2B collaboration](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b) and [Cross-Tenant Synchronisation](https://learn.microsoft.com/en-us/entra/identity/multi-tenant-organizations/cross-tenant-synchronization-overview).

---

## Identity Types

| Identity Type         | Description                                       | Example                                    |
| --------------------- | ------------------------------------------------- | ------------------------------------------ |
| **User**              | Human identity with credentials                   | Employee, guest, external collaborator     |
| **Service principal** | Application identity in a specific tenant         | App registration instantiated in tenant    |
| **Managed identity**  | Azure-resource identity, no credential management | Azure VM, Function App accessing Key Vault |
| **Device**            | Registered or joined device identity              | Entra-joined Windows 11 workstation        |

Microsoft Learn: [Identity fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/identity-fundamental-concepts)

---

## Authentication Protocols

Entra ID supports modern authentication protocols. Legacy authentication protocols (Basic Auth, NTLM over the internet) are progressively deprecated.

| Protocol                                                                                                        | Use Case                                          | Status                                          |
| --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------- |
| [OAuth 2.0](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)                 | Delegated access — apps acting on behalf of users | Preferred                                       |
| [OpenID Connect (OIDC)](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc)            | User sign-in and identity tokens                  | Preferred                                       |
| [SAML 2.0](https://learn.microsoft.com/en-us/entra/identity-platform/saml-protocol-reference)                   | Enterprise SSO with SaaS applications             | Supported for federated apps                    |
| [WS-Federation](https://learn.microsoft.com/en-us/entra/identity-platform/reference-claims-mapping-policy-type) | Legacy federation (ADFS)                          | Supported, not recommended for new integrations |
| Basic Authentication                                                                                            | Username/password over HTTP                       | Deprecated and blocked                          |

---

## Directory Synchronisation Architecture

For organisations with on-premises Active Directory, [Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect) synchronises identities from on-premises AD to Entra ID.

**Sync topologies:**

- **Single forest, single tenant** — Most common; one AD forest syncing to one Entra ID tenant
- **Multiple forests, single tenant** — Multiple AD forests consolidated into one Entra ID tenant
- **Staging server** — Secondary sync server in passive mode for disaster recovery

**Authentication methods for hybrid environments:**

- **Password Hash Sync (PHS)** — Hash of the on-premises password hash synchronised to Entra ID; authentication happens in the cloud
- **Pass-Through Authentication (PTA)** — Authentication redirected to on-premises AD via lightweight agents; no password hashes in cloud
- **Federation (AD FS)** — Authentication redirected entirely to on-premises AD FS infrastructure

Microsoft Learn: [Choose the right authentication method](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/choose-ad-authn)

---

## Licensing Tiers

Entra ID is available in multiple tiers. Feature availability varies by licence.

| Feature Area                         | Entra ID Free           | Entra ID P1              | Entra ID P2 |
| ------------------------------------ | ----------------------- | ------------------------ | ----------- |
| Basic user/group management          | Yes                     | Yes                      | Yes         |
| SSO (up to 10 apps)                  | Yes                     | Unlimited                | Unlimited   |
| MFA                                  | Yes (security defaults) | Yes (Conditional Access) | Yes         |
| Conditional Access                   | No                      | Yes                      | Yes         |
| Self-Service Password Reset          | Cloud only              | Yes (hybrid writeback)   | Yes         |
| Identity Protection (risk detection) | No                      | No                       | Yes         |
| Privileged Identity Management (PIM) | No                      | No                       | Yes         |
| Access Reviews                       | No                      | No                       | Yes         |
| Entitlement Management               | No                      | No                       | Yes         |

Microsoft Learn: [Microsoft Entra ID licensing](https://learn.microsoft.com/en-us/entra/fundamentals/licensing)

---

## Related Resources

- [Microsoft Entra ID documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [Microsoft Entra fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)
- [Compare Entra ID to AD DS](https://learn.microsoft.com/en-us/entra/fundamentals/compare-azure-ad-to-ad)
- [Identity fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/identity-fundamental-concepts)
- [Microsoft Entra admin centre](https://entra.microsoft.com/)
- [ACSC — Essential Eight: Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
