---
title: "Entra ID Service Overview"
status: "published"
last_updated: "2026-03-08"
audience: "Identity Architects, Azure Administrators, M365 Administrators"
document_type: "reference"
domain: "identity"
---

# Entra ID Service Overview

---

## Scope

This document is a factual reference for Microsoft Entra ID service capabilities, licence tiers, supported identity types, authentication protocols, and key API endpoints. It does not contain configuration instructions — those are in the `how-to-` prefixed files at the topic root.

---

## Service Identity

| Attribute                 | Value                                                                                          |
| ------------------------- | ---------------------------------------------------------------------------------------------- |
| Product name              | Microsoft Entra ID                                                                             |
| Former name               | Azure Active Directory (Azure AD) — rebranded October 2023                                     |
| Service type              | Cloud-native Identity and Access Management (IAM)                                              |
| Vendor                    | Microsoft Corporation                                                                          |
| Primary portal            | [https://entra.microsoft.com](https://entra.microsoft.com)                                     |
| Legacy portal             | [https://aad.portal.azure.com](https://aad.portal.azure.com) (redirects to Entra admin centre) |
| Microsoft Learn reference | [What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)     |

---

## Licence Tiers

| Tier                | Included With                        | Key Capabilities                                                                                                  |
| ------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| Entra ID Free       | Microsoft 365, Azure subscription    | User/group management, SSO (up to 10 apps), SSPR (cloud-only), MFA (security defaults)                            |
| Entra ID P1         | Microsoft 365 E3, EMS E3, standalone | Conditional Access, hybrid identity (Entra Connect), SSPR (hybrid), dynamic groups, group-based licensing         |
| Entra ID P2         | Microsoft 365 E5, EMS E5, standalone | Identity Protection (risk-based CA), Privileged Identity Management (PIM), entitlement management, access reviews |
| Entra ID Governance | Add-on to P1 or P2                   | Advanced lifecycle workflows, entitlement management, Entra ID Governance dashboard                               |

Reference: [Microsoft Learn — Entra ID licence comparison](https://www.microsoft.com/en-au/security/business/microsoft-entra-pricing)

---

## Supported Identity Types

| Identity Type     | Description                                                                                    |
| ----------------- | ---------------------------------------------------------------------------------------------- |
| Cloud user        | User account created directly in Entra ID; no on-premises directory required                   |
| Synchronised user | Account synchronised from on-premises Active Directory via Microsoft Entra Connect             |
| Guest user (B2B)  | External user invited to collaborate via Azure AD B2B; authenticates with their home directory |
| Service principal | Identity representing an application or automated service; used for app-to-app authentication  |
| Managed identity  | Azure-managed service principal for Azure resources; eliminates credential management          |
| Workload identity | Broader term for service principals and managed identities used in workload authentication     |

Reference: [Microsoft Learn — Identity types in Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/identity-fundamental-concepts)

---

## Authentication Protocols

| Protocol                      | Use case                                                    | Supported by Entra ID                               |
| ----------------------------- | ----------------------------------------------------------- | --------------------------------------------------- |
| OAuth 2.0                     | Delegated authorisation for APIs and applications           | Yes                                                 |
| OpenID Connect (OIDC)         | Federated authentication for web and mobile apps            | Yes                                                 |
| SAML 2.0                      | Enterprise SSO for SaaS applications                        | Yes                                                 |
| WS-Federation                 | Legacy enterprise federation (ADFS, passive flows)          | Yes                                                 |
| Kerberos                      | On-premises domain authentication via Entra Domain Services | Yes (via Entra Domain Services)                     |
| NTLM                          | Legacy Windows authentication                               | No — blocked by default                             |
| Basic Authentication          | Username/password over HTTP                                 | No — deprecated and blocked                         |
| Legacy authentication clients | Office 2010, IMAP, POP3, SMTP auth                          | Blocked by security defaults and Conditional Access |

Reference: [Microsoft Learn — Authentication protocols](https://learn.microsoft.com/en-us/entra/identity-platform/authentication-vs-authorization)

---

## Authentication Methods

| Method                                    | Type                | Phishing-resistant | Requires P1/P2 |
| ----------------------------------------- | ------------------- | ------------------ | -------------- |
| Microsoft Authenticator (push)            | MFA                 | No                 | No             |
| Microsoft Authenticator (number matching) | MFA                 | Partial            | No             |
| FIDO2 security key                        | Passwordless MFA    | Yes                | No             |
| Windows Hello for Business                | Passwordless MFA    | Yes                | No             |
| Certificate-based authentication (CBA)    | Passwordless MFA    | Yes                | No             |
| Temporary Access Pass (TAP)               | Onboarding/recovery | No                 | No             |
| SMS OTP                                   | MFA                 | No                 | No             |
| Voice call                                | MFA                 | No                 | No             |
| OATH TOTP hardware token                  | MFA                 | No                 | No             |
| OATH TOTP software token                  | MFA                 | No                 | No             |
| Password                                  | Primary credential  | No                 | No             |

Reference: [Microsoft Learn — Authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)

For Essential Eight MFA requirements (ML1–ML3), see [`../mfa/README.md`](../../mfa/README.md) and [ACSC Essential Eight — Multifactor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Hybrid Identity Options

| Method                        | Abbreviation | How it works                                                          | Password hash in cloud |
| ----------------------------- | ------------ | --------------------------------------------------------------------- | ---------------------- |
| Password Hash Synchronisation | PHS          | Password hashes synced to Entra ID; authentication performed in cloud | Yes                    |
| Pass-Through Authentication   | PTA          | Authentication forwarded to on-premises AD via lightweight agent      | No                     |
| Federation (ADFS)             | —            | Authentication delegated to on-premises ADFS or third-party IdP       | No                     |

Microsoft recommends PHS for most organisations due to resilience (no on-premises agent dependency) and Entra ID Identity Protection integration.

Reference: [Microsoft Learn — Choose the right authentication method](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/choose-ad-authn)

---

## Key Service Endpoints

| Endpoint                                         | Purpose                                               |
| ------------------------------------------------ | ----------------------------------------------------- |
| `https://login.microsoftonline.com/{tenant-id}/` | OAuth 2.0 / OIDC token endpoint                       |
| `https://graph.microsoft.com/v1.0/`              | Microsoft Graph API (current version)                 |
| `https://graph.microsoft.com/beta/`              | Microsoft Graph API (beta — not production-supported) |
| `https://entra.microsoft.com`                    | Entra admin centre portal                             |
| `https://myaccount.microsoft.com`                | User self-service portal                              |
| `https://myapps.microsoft.com`                   | My Apps portal (SSO launchpad)                        |
| `https://mysignins.microsoft.com`                | Sign-in history self-service                          |

---

## Built-In Directory Roles (Selected)

| Role                             | Privilege level | Primary use                                                      |
| -------------------------------- | --------------- | ---------------------------------------------------------------- |
| Global Administrator             | Highest         | Full tenant management; must be break-glass or PIM-eligible only |
| Privileged Role Administrator    | High            | Manages role assignments; can elevate to Global Admin            |
| User Administrator               | Medium          | User and group lifecycle management                              |
| Application Administrator        | Medium          | App registrations and enterprise application management          |
| Conditional Access Administrator | Medium          | Conditional Access policy management                             |
| Security Administrator           | Medium          | Security policies, Identity Protection, Defender for Cloud Apps  |
| Authentication Administrator     | Medium          | Authentication method policies; can reset non-admin MFA          |
| Helpdesk Administrator           | Low             | Password resets for non-admin users                              |
| Reports Reader                   | Read-only       | Sign-in and audit log access                                     |
| Global Reader                    | Read-only       | Read all configuration; cannot make changes                      |

Full role reference: [Microsoft Learn — Entra ID built-in roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)

---

## PowerShell Modules

| Module               | Version         | Use                                                                   |
| -------------------- | --------------- | --------------------------------------------------------------------- |
| Microsoft.Graph      | Current         | Preferred — Graph SDK for all Entra ID operations via Microsoft Graph |
| Microsoft.Graph.Beta | Current         | Beta Graph API access — not for production automation                 |
| AzureAD              | v2 (deprecated) | Legacy — Microsoft ended support; migrate to Microsoft.Graph          |
| MSOnline             | v1 (deprecated) | Legacy — Microsoft ended support; migrate to Microsoft.Graph          |

Install: `Install-Module Microsoft.Graph -Scope CurrentUser`

Reference: [Microsoft Learn — Get started with Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started)

---

## Related Resources

- [Microsoft Learn — Entra ID fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/)
- [Microsoft Learn — Entra ID built-in roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)
- [Microsoft Learn — Authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)
- [Microsoft Learn — Hybrid identity](https://learn.microsoft.com/en-us/entra/identity/hybrid/)
- [Microsoft Graph API reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Microsoft Learn — Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/)
- [ACSC — Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [Entra admin centre](https://entra.microsoft.com)
