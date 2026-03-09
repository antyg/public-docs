---
title: "Explanation: Entra ID Role in Identity Architecture"
status: "published"
last_updated: "2026-03-08"
audience: "Identity Architects, Security Architects, Technical Decision-Makers"
document_type: "explanation"
domain: "identity"
---

# Explanation: Entra ID Role in Identity Architecture

---

## Scope

This document explains the conceptual role of Microsoft Entra ID within a modern identity architecture. It covers the tenant model, the relationship between Entra ID and on-premises Active Directory, how Entra ID integrates with third-party identity providers (Okta, Ping Identity), and the layered identity control plane. It does not contain configuration instructions.

---

## What Entra ID Is

Microsoft Entra ID is Microsoft's cloud-native Identity and Access Management (IAM) service. It is the identity plane for Microsoft 365, Azure, and thousands of integrated SaaS applications. Every Microsoft cloud service — Exchange Online, SharePoint Online, Azure Resource Manager, Microsoft Intune — authenticates through Entra ID.

Entra ID is not a cloud version of Active Directory. It is a distinct service built around web protocols (OAuth 2.0, OpenID Connect, SAML 2.0) rather than Kerberos and LDAP. The conceptual model is flat (no organisational units, no Group Policy Objects) and cloud-first.

Reference: [Microsoft Learn — Compare Active Directory to Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/compare-azure-ad-to-active-directory)

---

## The Tenant Model

An Entra ID tenant is a dedicated, isolated instance of the Entra ID service associated with an organisation. Each tenant:

- Has a globally unique tenant ID (GUID) and one or more verified domain names
- Is authoritative for the identities it contains — no cross-tenant trust by default
- Is logically isolated from all other tenants — Microsoft cannot see one tenant's data from another

Multi-tenant architectures (e.g., MSPs managing multiple client tenants) use cross-tenant access settings, Azure Lighthouse, or B2B collaboration — they do not share a directory.

Reference: [Microsoft Learn — Entra ID tenancy](https://learn.microsoft.com/en-us/entra/fundamentals/whatis#terminology)

---

## Entra ID in Hybrid Identity Architecture

Most Australian enterprises operating before 2018 built identity on on-premises Active Directory Domain Services (AD DS). Entra ID extends that model into the cloud through hybrid identity:

```
On-premises AD DS
       |
Microsoft Entra Connect (sync agent)
       |
Entra ID tenant
       |
Microsoft 365 / Azure / SaaS applications
```

Entra Connect synchronises user, group, and device objects from AD DS to Entra ID. The synchronised objects can authenticate using three methods:

1. **Password Hash Synchronisation (PHS)** — A hash of the password hash is synchronised to Entra ID. Cloud authentication; no on-premises agent required during authentication. Recommended by Microsoft for resilience.
2. **Pass-Through Authentication (PTA)** — Authentication is forwarded to on-premises AD DS via a lightweight agent. Passwords never leave the organisation's network.
3. **Federation (ADFS)** — Authentication is delegated entirely to on-premises Active Directory Federation Services. Highest complexity; suitable when regulatory requirements prohibit any form of credential in the cloud.

Reference: [Microsoft Learn — What is hybrid identity?](https://learn.microsoft.com/en-us/entra/identity/hybrid/whatis-hybrid-identity)

---

## The Identity Control Plane

Entra ID functions as the identity control plane for the Microsoft cloud. This means:

- **Access policy enforcement** is centralised in Entra ID (Conditional Access), not distributed across individual applications
- **Authentication** occurs at the Entra ID token endpoint before any application receives a request
- **Authorisation** decisions (role assignments, group membership) are stored in Entra ID and propagated to applications via tokens and directory synchronisation
- **Audit** of all authentication and directory change events is centralised in Entra ID logs

This control plane model is why Conditional Access policies in Entra ID can govern access to Exchange Online, SharePoint, Azure, and third-party SaaS applications from a single policy engine. Applications delegate authentication to Entra ID rather than managing credentials themselves.

Reference: [Microsoft Learn — What is Conditional Access?](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)

---

## Relationship to Third-Party Identity Providers

Entra ID can participate in federation with third-party IdPs in two configurations:

### Entra ID as Service Provider (SP)

Third-party IdPs (Okta, Ping Identity, AD FS) act as the authority for authentication. Entra ID trusts tokens issued by the external IdP and grants access based on that trust. This pattern is common in:

- Acquisitions where the acquired entity uses a different IdP
- Enterprises that standardised on Okta before adopting Microsoft cloud services

See [`../okta/README.md`](../../okta/README.md) and [`../ping-identity/README.md`](../../ping-identity/README.md) for integration patterns.

### Entra ID as Identity Provider (IdP)

Entra ID issues tokens that third-party applications and services consume. Applications register in Entra ID and receive tokens via OAuth 2.0 / OIDC. This is the standard model for Microsoft 365 and Azure workloads.

---

## Relationship to Conditional Access and MFA

Entra ID is the platform; Conditional Access and MFA are policy layers built on it:

- **Entra ID** — Stores identities, issues tokens, maintains directory state
- **Conditional Access** — Policy engine that evaluates every sign-in attempt against conditions (user, device, location, risk) and enforces controls (MFA, compliant device, session limits)
- **MFA** — One of several controls that Conditional Access can require; also configurable via per-user MFA settings and authentication method policies

These three layers work together. Entra ID authenticates. Conditional Access authorises. MFA strengthens the authentication signal.

Reference: [Microsoft Learn — Building a Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)

---

## Relationship to Australian Compliance Frameworks

Entra ID is a foundational control for several Australian regulatory and security requirements:

| Framework | Relevant requirement | Entra ID capability |
|---|---|---|
| [Essential Eight — MFA](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model) | ML2: MFA for all users; ML3: phishing-resistant MFA | Authentication method policies, FIDO2, Windows Hello for Business, CBA |
| [Essential Eight — Restrict Admin Privileges](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model) | Privileged accounts are separate from standard accounts | Privileged Identity Management (PIM), Conditional Access for admin roles |
| [ISM — Access Control](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) | Least privilege; separation of duties | Role-based access control (RBAC), PIM, access reviews |
| [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712) | Personal information access controls | Entra ID audit logs, Conditional Access, MFA |
| [PSPF](https://www.protectivesecurity.gov.au/) | Protective marking enforcement, personnel identity assurance | Entitlement management, access reviews, Identity Protection |

---

## Summary: Why Entra ID Matters

For Australian organisations operating Microsoft cloud services, Entra ID is not optional infrastructure — it is the identity fabric that every cloud workload depends on. Security posture, compliance with Essential Eight, and operational efficiency in managing users and access all flow through Entra ID configuration and policy. Understanding its architecture is prerequisite to designing effective identity controls.

---

## Related Resources

- [Microsoft Learn — What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)
- [Microsoft Learn — Compare Active Directory to Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/compare-azure-ad-to-active-directory)
- [Microsoft Learn — What is hybrid identity?](https://learn.microsoft.com/en-us/entra/identity/hybrid/whatis-hybrid-identity)
- [Microsoft Learn — Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [ACSC — Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [OAIC — Privacy Act 1988](https://www.oaic.gov.au/privacy/the-privacy-act)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
