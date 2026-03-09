---
title: "Ping Identity"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Ping Identity

---

## Purpose

This folder is designated for Ping Identity platform documentation covering PingFederate federation, SAML 2.0 and OpenID Connect integration, SSO configuration, and enterprise identity architecture patterns.

Ping Identity is an enterprise identity and access management platform commonly deployed in large enterprise, government, and financial services environments, particularly where on-premises deployment, fine-grained federation control, or complex attribute transformation is required. PingFederate is the flagship federation server, while PingOne is the cloud-native SaaS delivery.

Ping Identity documentation: [Ping Identity Documentation](https://docs.pingidentity.com/)

---

## Scope

This documentation covers:

- PingFederate as a SAML 2.0 and OpenID Connect Identity Provider (IdP) and Service Provider (SP)
- PingFederate SSO configuration and connection management
- SAML 2.0 and OIDC protocol configuration in Ping Identity environments
- PingFederate integration with Entra ID, Okta, and other cloud IdPs
- PingOne for Workforce — cloud-native identity administration
- PingAccess — policy-based resource protection and adaptive access

This documentation does not cover:

- PingDirectory LDAP administration (see `../../infrastructure/directory-services/` (planned))
- PingAuthorize (fine-grained authorisation engine — planned)
- DaVinci (Ping's no-code orchestration — planned)

---

## Planned Content Structure

> The subdirectories and files below are planned content that has not yet been created. The tree shows the intended structure for future authoring.

```
ping-identity/
├── README.md                              ← this file
├── OUTLINE.md                             ← detailed content outline with citation sources
├── explanation/
│   ├── ping-platform-overview.md          ← product family, deployment models, key concepts
│   └── pingfederate-architecture.md       ← federation topology, adapters, contracts
├── how-to/
│   ├── saml-idp-connection.md             ← configure PingFederate as SAML IdP
│   ├── saml-sp-connection.md              ← configure PingFederate as SAML SP
│   ├── oidc-provider-setup.md             ← configure PingFederate as OIDC provider
│   └── entra-id-integration.md            ← federate PingFederate with Microsoft Entra ID
└── reference/
    ├── saml-oidc-settings-reference.md    ← protocol settings, signing algorithms, binding types
    └── attribute-contract-reference.md    ← attribute contracts and mapping patterns
```

---

## Key Concepts

| Concept | Description | Reference |
|---------|-------------|-----------|
| **PingFederate** | On-premises / private cloud federation server; SAML 2.0, OIDC, OAuth 2.0, WS-Trust | [PingFederate docs](https://docs.pingidentity.com/pingfederate/latest/) |
| **PingOne** | Cloud-native SaaS IAM platform; workforce and customer identity | [PingOne docs](https://docs.pingidentity.com/pingone/latest/) |
| **PingAccess** | Policy-based resource protection and adaptive access gateway | [PingAccess docs](https://docs.pingidentity.com/pingaccess/latest/) |
| **PingDirectory** | High-performance LDAP directory server | [PingDirectory docs](https://docs.pingidentity.com/pingdirectory/latest/) |
| **SP Connection** | PingFederate configuration representing a SAML/OIDC Service Provider | [SP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_sp_connections.html) |
| **IdP Connection** | PingFederate configuration representing an upstream Identity Provider | [IdP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_idp_connections.html) |
| **Attribute Contract** | The set of attributes PingFederate sends to an SP in SAML assertions or OIDC claims | [Attribute contracts](https://docs.pingidentity.com/pingfederate/latest/pf_attribute_contract.html) |
| **Authentication Policy** | PingFederate's policy engine for step-up and adaptive authentication | [Authentication policies](https://docs.pingidentity.com/pingfederate/latest/pf_authentication_policies.html) |
| **Adapter** | PingFederate integration point for authentication sources (HTML Form, LDAP, Kerberos, etc.) | [Adapters overview](https://docs.pingidentity.com/pingfederate/latest/pf_adapters_overview.html) |

---

## SAML and OIDC Protocol Reference

### SAML 2.0 Key Settings

| Setting | PingFederate Options | Recommended |
|---------|---------------------|-------------|
| Signing algorithm | RSA-SHA1, RSA-SHA256, RSA-SHA384, RSA-SHA512 | RSA-SHA256 minimum |
| Digest algorithm | SHA1, SHA256 | SHA256 |
| Assertion encryption | AES-128, AES-256 | AES-256 for sensitive data |
| Binding | POST, Redirect, Artifact | POST (preferred for assertions) |
| NameID format | Unspecified, Email, Transient, Persistent | As required by SP |
| Session timeout | Configurable (minutes) | Align with organisational session policy |

OASIS: [SAML 2.0 specification](https://docs.oasis-open.org/security/saml/v2.0/)

### OIDC Key Settings

| Setting | PingFederate Options | Recommended |
|---------|---------------------|-------------|
| ID token signing | RS256, RS384, RS512, ES256 | RS256 minimum |
| Access token format | Reference token or JWT | JWT for stateless validation |
| PKCE | S256, plain | S256 (mandatory for public clients) |
| Token lifetime | Configurable | Access: 1 hour; Refresh: per policy |

IETF: [OAuth 2.0 Security Best Current Practice (RFC 9700)](https://datatracker.ietf.org/doc/rfc9700/)
OpenID Foundation: [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

---

## Australian Context

PingFederate is deployed in Australian government and financial services environments, particularly where:

- On-premises data residency is required under [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712) obligations or agency information classification
- Complex SAML attribute transformation is required for legacy application SSO
- Integration with legacy systems requiring WS-Trust or Kerberos constrained delegation

[ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) and [Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) MFA requirements apply equally to Ping Identity deployments as to cloud-native platforms. PingFederate supports FIDO2/WebAuthn via PingID MFA integration.

---

## Relationship to Other Domains

- **`../entra-id/`** — Entra ID as a cloud IdP federated from PingFederate, or PingFederate as SP consuming Entra ID tokens
- **`../okta/`** — Okta co-existence or migration patterns involving Ping Identity
- **`../mfa/`** — MFA method requirements and phishing-resistance criteria (platform-agnostic)
- **`../../infrastructure/directory-services/`** (planned) — PingDirectory and LDAP infrastructure

---

## Audience

- **Identity Engineers** — Deploying and configuring PingFederate for enterprise federation
- **Security Architects** — Designing federation architectures involving Ping Identity products
- **Application Developers** — Integrating applications with PingFederate as IdP via SAML or OIDC
- **IAM Administrators** — Day-to-day PingFederate administration and SP/IdP connection management

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
