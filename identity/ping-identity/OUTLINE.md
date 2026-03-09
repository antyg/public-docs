---
title: "Ping Identity — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Ping Identity — Content Outline

**Citation Sources**: See §7 below

---

## 1. Ping Platform Overview (Explanation)

### 1.1 Product Family

| Product | Deployment | Primary Use Case |
|---------|-----------|-----------------|
| PingFederate | On-premises or private cloud | Enterprise federation server; SAML 2.0, OIDC, OAuth 2.0, WS-Trust, WS-Federation |
| PingOne | Cloud SaaS | Cloud-native IAM; workforce and customer identity |
| PingAccess | On-premises or cloud | Policy-based resource protection; adaptive access gateway |
| PingDirectory | On-premises or cloud | High-performance LDAP directory; user data store |
| PingAuthorize | On-premises or cloud | Fine-grained authorisation engine; externalisable policy |
| PingID | SaaS (MFA) | MFA service integrating with PingFederate and PingOne |
| DaVinci | SaaS (orchestration) | No-code identity orchestration; journey builder |

**Citation**: [Ping Identity — Product documentation](https://docs.pingidentity.com/)

### 1.2 Deployment Models

- **On-premises**: PingFederate deployed in customer data centre; full control of infrastructure and data residency
- **Hybrid**: PingFederate on-premises with PingOne cloud management console
- **Cloud**: PingOne SaaS; no infrastructure management required
- **PingFederate containers**: Docker and Kubernetes deployment supported via Ping DevOps tooling

**Citation**: [PingFederate — Getting started](https://docs.pingidentity.com/pingfederate/latest/pf_getting_started.html)

---

## 2. PingFederate Architecture (Explanation)

### 2.1 Federation Topology

PingFederate acts as a federation hub — it can simultaneously be:
- IdP to external SPs (issuing SAML assertions and OIDC tokens)
- SP to external IdPs (consuming SAML assertions from upstream IdPs)
- OAuth 2.0 Authorisation Server (issuing access tokens)
- OAuth 2.0 Resource Server (validating tokens)

**Citation**: [PingFederate — Architecture overview](https://docs.pingidentity.com/pingfederate/latest/pf_about_pingfederate.html)

### 2.2 Adapters

Adapters are PingFederate's integration points for authentication sources. They abstract the authentication mechanism from the federation protocol layer.

Common adapters:
- HTML Form adapter — username/password login form
- Kerberos adapter — Windows Integrated Authentication (WIA) for domain-joined clients
- LDAP adapter — authenticate against LDAP/AD
- PingID adapter — MFA via PingID (FIDO2, push, TOTP)
- OpenToken adapter — token-based SSO for legacy apps

**Citation**: [PingFederate — Adapters overview](https://docs.pingidentity.com/pingfederate/latest/pf_adapters_overview.html)

### 2.3 Attribute Contracts

An attribute contract defines the set of attributes PingFederate includes in outbound assertions and tokens. Each SP connection has its own attribute contract defining what the SP receives.

- Source attributes come from adapters, LDAP data stores, JDBC data stores, or custom plugins
- Attribute fulfillment maps source attributes to contract attributes
- Masking and encoding options available per attribute

**Citation**: [PingFederate — Attribute contracts](https://docs.pingidentity.com/pingfederate/latest/pf_attribute_contract.html)

---

## 3. SAML IdP Connection (How-to)

### 3.1 Configure PingFederate as SAML IdP

Navigation: PingFederate admin console → Identity Provider → SP Connections → Create New

Required SP metadata inputs:
- Entity ID (SP)
- ACS (Assertion Consumer Service) URL
- Encryption certificate (if assertion encryption required)
- Signing requirements

IdP-side configuration:
- Select adapter (authentication source)
- Configure attribute contract and fulfillment
- Set signature algorithm (RSA-SHA256 minimum)
- Set NameID format

**Citation**: [PingFederate — Creating SP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_sp_connections.html)

### 3.2 SP Metadata Exchange

Export PingFederate IdP metadata for upload to the SP:

Navigation: PingFederate → Identity Provider → SP Connections → [connection] → Export Metadata

The metadata XML contains: EntityID, SSO binding URLs, signing certificate, NameID formats supported.

**Citation**: [PingFederate — Managing SP metadata](https://docs.pingidentity.com/pingfederate/latest/pf_sp_metadata.html)

---

## 4. SAML SP Connection (How-to)

### 4.1 Configure PingFederate as SAML SP

Use case: An upstream IdP (Entra ID, Okta, ADFS) issues SAML assertions to PingFederate, which then issues tokens to downstream applications.

Navigation: PingFederate admin console → Service Provider → IdP Connections → Create New

Required IdP metadata inputs:
- IdP Entity ID
- SSO service URL (redirect or POST binding)
- IdP signing certificate

SP-side configuration:
- Select target adapter or SP connection to proxy to
- Map incoming SAML attributes to PingFederate session attributes
- Configure authentication policy contract

**Citation**: [PingFederate — Creating IdP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_idp_connections.html)

---

## 5. OIDC Provider Setup (How-to)

### 5.1 Configure PingFederate as OIDC Provider

PingFederate's OAuth 2.0 Authorisation Server capabilities include OIDC Provider support. This enables modern applications to use OIDC for authentication instead of SAML.

Navigation: PingFederate → OAuth Server → OpenID Connect Policy Management → Add Policy

Configure:
- ID token signing algorithm (RS256 minimum)
- ID token lifetime
- Claims: which user attributes to include in ID token and UserInfo endpoint response
- PKCE enforcement (required for public clients)

**Citation**: [PingFederate — OpenID Connect](https://docs.pingidentity.com/pingfederate/latest/pf_openid_connect.html)

### 5.2 Client Registration

Register OAuth 2.0 / OIDC clients in PingFederate:

Navigation: PingFederate → OAuth Server → Clients → Add Client

Configure:
- Client ID and credentials (secret or certificate)
- Redirect URIs (exact match required)
- Grant types (authorisation code only for web apps)
- PKCE requirement

**Citation**: [PingFederate — OAuth client management](https://docs.pingidentity.com/pingfederate/latest/pf_managing_oauth_clients.html)

---

## 6. Entra ID Integration (How-to)

### 6.1 Federate PingFederate with Microsoft Entra ID

#### Pattern 1: PingFederate as IdP, Entra ID as SP

Use case: On-premises PingFederate authenticates users; Entra ID (and M365/Azure) trusts PingFederate assertions.

This is a **federated domain** pattern in Entra ID — the custom domain is configured as federated, not managed. Authentication for that domain's users is redirected to PingFederate.

Steps:
1. Configure PingFederate as SAML IdP with Entra ID-specific SP connection
2. In Entra ID, convert the domain to federated using `Convert-MgDomainToFederated` or Entra Connect federation configuration
3. Configure Entra ID SP metadata in PingFederate

**Citation**: [Microsoft Learn — Configure PingFederate with Entra ID](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-compatibility)
**Citation**: [PingFederate — Azure AD integration guide](https://docs.pingidentity.com/pingfederate/latest/pf_azure_ad_integration.html)

#### Pattern 2: Entra ID as IdP, PingFederate as SP

Use case: Entra ID authenticates users; PingFederate acts as SP to consume Entra ID SAML assertions and proxy to legacy on-premises applications.

Steps:
1. Register PingFederate as enterprise app in Entra ID (SAML-based SSO)
2. Configure Entra ID to issue SAML assertions with required attributes
3. Configure PingFederate IdP connection pointing to Entra ID
4. Map Entra ID claims to PingFederate attributes for downstream app access

**Citation**: [Microsoft Learn — SAML-based SSO](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-saml-single-sign-on)

---

## 7. Citation Sources

### Ping Identity Documentation

- [Ping Identity documentation hub](https://docs.pingidentity.com/)
- [PingFederate — Getting started](https://docs.pingidentity.com/pingfederate/latest/pf_getting_started.html)
- [PingFederate — Architecture](https://docs.pingidentity.com/pingfederate/latest/pf_about_pingfederate.html)
- [PingFederate — Adapters overview](https://docs.pingidentity.com/pingfederate/latest/pf_adapters_overview.html)
- [PingFederate — Attribute contracts](https://docs.pingidentity.com/pingfederate/latest/pf_attribute_contract.html)
- [PingFederate — SP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_sp_connections.html)
- [PingFederate — IdP connections](https://docs.pingidentity.com/pingfederate/latest/pf_creating_idp_connections.html)
- [PingFederate — OpenID Connect](https://docs.pingidentity.com/pingfederate/latest/pf_openid_connect.html)
- [PingFederate — OAuth client management](https://docs.pingidentity.com/pingfederate/latest/pf_managing_oauth_clients.html)

### Microsoft Learn

- [PingFederate compatibility with Entra ID](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-compatibility)
- [SAML-based SSO for enterprise applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-saml-single-sign-on)

### Standards

- [SAML 2.0 specification](https://docs.oasis-open.org/security/saml/v2.0/)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [OAuth 2.0 Security Best Current Practice (RFC 9700)](https://datatracker.ietf.org/doc/rfc9700/)
- [OAuth 2.1 draft](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/)

### Australian Regulatory

- [ACSC — Essential Eight: Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712)
