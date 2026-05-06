---
title: "Okta"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Okta

---

## Purpose

This folder is designated for Okta identity platform documentation covering SAML federation, SCIM provisioning, SSO configuration, and application integration patterns.

Okta is a cloud-native identity and access management platform widely deployed as either a primary IdP or as a federation hub between on-premises identity infrastructure and cloud applications. It supports SAML 2.0, OpenID Connect, SCIM 2.0, and proprietary Okta APIs.

Okta documentation: [Okta Developer Docs](https://developer.okta.com/docs/)

---

## Scope

This documentation covers:

- Okta as a SAML 2.0 Identity Provider (IdP) for SaaS applications
- Okta as a SAML 2.0 Service Provider (SP) federated from an enterprise IdP (Entra ID, AD FS)
- SCIM 2.0 provisioning — inbound and outbound
- Single Sign-On (SSO) application integration patterns
- Okta Identity Lifecycle management (Joiner/Mover/Leaver)
- Okta as a secondary IdP alongside Microsoft Entra ID (co-existence patterns)

This documentation does not cover:

- Okta Customer Identity (CIAM / Okta Customer Identity Cloud / Auth0)
- Okta Advanced Server Access (now Okta Privileged Access)
- Vendor integration patterns outside identity scope (see `../../integrations/`)

---

## Planned Content Structure

> The subdirectories and files below are planned content that has not yet been created. The tree shows the intended structure for future authoring.

```
okta/
├── README.md                              ← this file
├── OUTLINE.md                             ← detailed content outline with citation sources
├── explanation/
│   ├── okta-architecture.md               ← org model, Universal Directory, policy framework
│   └── federation-patterns.md             ← Okta as IdP vs SP; co-existence with Entra ID
├── how-to/
│   ├── saml-sp-configuration.md           ← add a SAML 2.0 app to Okta as SP
│   ├── saml-idp-configuration.md          ← configure Okta as IdP for an external SP
│   ├── scim-provisioning.md               ← configure SCIM inbound/outbound provisioning
│   ├── entra-id-federation.md             ← federate Entra ID and Okta (inbound SAML)
│   └── lifecycle-automation.md            ← Joiner/Mover/Leaver workflows
└── reference/
    ├── saml-attribute-mapping.md          ← SAML attribute statements and claim mapping
    └── scim-schema-reference.md           ← SCIM 2.0 user and group schema
```

---

## Key Concepts

| Concept | Description | Reference |
|---------|-------------|-----------|
| **Universal Directory** | Okta's centralised user store — can sync from AD, LDAP, HR systems, or be authoritative | [Okta: Universal Directory](https://help.okta.com/en-us/content/topics/directory/eu-about-universal-directory.htm) |
| **Org** | The tenant unit in Okta — a single isolated Okta instance | [Okta: Orgs](https://developer.okta.com/docs/concepts/okta-organizations/) |
| **SAML IdP** | Okta acting as the identity provider for external SPs | [Okta: SAML 2.0 IdP](https://help.okta.com/en-us/content/topics/security/idp-discovery.htm) |
| **SAML SP** | An external app registered in Okta; Okta manages SSO to it | [Okta: SAML App integrations](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/) |
| **SCIM provisioning** | Automated user/group lifecycle across systems using SCIM 2.0 | [Okta: SCIM provisioning overview](https://developer.okta.com/docs/concepts/scim/) |
| **Okta Verify** | Okta's MFA authenticator app (TOTP and push) | [Okta: Okta Verify](https://help.okta.com/en-us/content/topics/mobile/okta-verify-overview.htm) |
| **Inbound Federation** | External IdP (e.g., Entra ID) authenticating users into Okta | [Okta: Inbound SAML](https://developer.okta.com/docs/guides/add-an-external-idp/saml2/main/) |
| **Lifecycle Management** | Automated provisioning and deprovisioning triggered by HR events | [Okta: Lifecycle Management](https://www.okta.com/products/lifecycle-management/) |

---

## Australian Context

Okta is deployed by Australian government agencies, financial institutions, and enterprises as either a primary IdP or a federation hub. When deploying Okta in Australian government contexts:

- Data residency: Verify Okta cell assignment and confirm Australian data residency requirements under the [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712) and agency-specific data sovereignty requirements
- [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requirements for multi-factor authentication apply regardless of platform
- [Essential Eight MFA requirements](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) are platform-agnostic — Okta deployments must satisfy the same phishing-resistance requirements as Entra ID deployments at ML2+

---

## Relationship to Other Domains

- **`../entra-id/`** — Entra ID as a primary IdP federated into Okta, or Okta federated into Entra ID
- **`../mfa/`** — MFA method selection and phishing-resistance requirements (platform-agnostic)
- **`../conditional-access/`** — Microsoft Conditional Access (compare to Okta's Adaptive MFA / Policy Engine)
- **`../../integrations/`** — Application integration patterns beyond identity

---

## Audience

- **Identity Engineers** — Deploying and configuring Okta for enterprise SSO and provisioning
- **Security Architects** — Designing federated identity architectures involving Okta
- **Application Developers** — Integrating applications with Okta as IdP via SAML or OIDC
- **IAM Administrators** — Day-to-day Okta administration and lifecycle management

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
