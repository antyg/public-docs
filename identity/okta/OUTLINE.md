---
title: "Okta — Content Outline"
status: "planned"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Okta — Content Outline

**Citation Sources**: See §7 below

---

## 1. Okta Architecture (Explanation)

### 1.1 Okta Org Model

- An Org is Okta's tenant unit — a single isolated Okta instance with its own Universal Directory, policy engine, and application catalogue
- Org URL pattern: `https://{org}.okta.com` (production) or `https://{org}.oktapreview.com` (sandbox)
- Cell architecture: Okta deploys in geographic cells; data residency depends on cell assignment at org creation
- Admin console: `https://{org}-admin.okta.com`

**Citation**: [Okta — Okta organizations](https://developer.okta.com/docs/concepts/okta-organizations/)

### 1.2 Universal Directory

- Centralised identity store within the org — single source of truth for all user profiles
- Supports custom profile attributes beyond the base schema
- Identity sources: on-premises Active Directory (via Okta AD agent), LDAP, HR systems (Workday, BambooHR), or Okta itself as authoritative
- Profile mastering: defines which source controls each attribute; prevents attribute conflicts when multiple sources are integrated

**Citation**: [Okta — Universal Directory](https://help.okta.com/en-us/content/topics/directory/eu-about-universal-directory.htm)

### 1.3 Policy Framework

- Okta's policy engine evaluates sign-on policies, password policies, and MFA policies
- Policy evaluation: most specific policy matching the user/group/app wins
- Okta Identity Engine (OIE) replaced Classic Engine; OIE provides richer policy orchestration and authentication pipelines

**Citation**: [Okta — Authentication policies](https://help.okta.com/en-us/content/topics/identity-engine/policies/about-auth-policy.htm)

---

## 2. Federation Patterns (Explanation)

### 2.1 Okta as IdP (SP-initiated SSO)

- Okta acts as the identity provider; external SPs (SaaS apps) redirect to Okta for authentication
- Okta presents SAML assertions or OIDC ID tokens to the SP after successful authentication
- Most common pattern for SSO to cloud SaaS applications (Salesforce, ServiceNow, Workday)

**Citation**: [Okta — Build a SAML SSO integration](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/)

### 2.2 Okta as SP (Inbound Federation)

- An external IdP (e.g., Microsoft Entra ID, AD FS) authenticates users; Okta acts as SP
- Used when Entra ID is the primary IdP and Okta provides additional app integrations
- JIT (Just-In-Time) provisioning creates Okta user profiles on first login from external IdP

**Citation**: [Okta — Add an external Identity Provider (SAML)](https://developer.okta.com/docs/guides/add-an-external-idp/saml2/main/)

### 2.3 Okta and Entra ID Co-existence

Two primary patterns:
1. **Entra ID primary, Okta secondary**: Users authenticate to Entra ID; Okta federates inbound from Entra ID for apps not in the Entra ID app gallery
2. **Okta primary, Entra ID SP**: Users authenticate to Okta; Entra ID acts as SP for Azure/M365 access (less common; Entra ID natively supports modern auth)

**Citation**: [Okta — Microsoft Azure Active Directory integration](https://help.okta.com/en-us/content/topics/provisioning/azure/azure-main.htm)

---

## 3. SAML SP Configuration (How-to)

### 3.1 Add a SAML 2.0 Application to Okta

Navigation: Okta Admin → Applications → Applications → Create App Integration → SAML 2.0

Required SP metadata fields:
- Single Sign-On URL (ACS URL)
- Audience URI (SP Entity ID)
- Name ID format
- Attribute statements (user profile attributes to include in assertion)

**Citation**: [Okta — Create a SAML app integration](https://help.okta.com/en-us/content/topics/apps/apps_app_integration_wizard_saml.htm)

### 3.2 Configure Attribute Statements

SAML attribute statements map Okta user profile attributes to SAML assertion attributes consumed by the SP.

Common mappings:
- `user.email` → `email`
- `user.firstName` → `FirstName`
- `user.lastName` → `LastName`
- `user.login` → `username`
- Group membership → `groups` (requires group attribute statement with regex filter)

**Citation**: [Okta — Define attribute statements](https://help.okta.com/en-us/content/topics/apps/apps_app_integration_wizard_saml.htm)

---

## 4. SCIM Provisioning (How-to)

### 4.1 SCIM Overview

SCIM (System for Cross-domain Identity Management) 2.0 automates user and group lifecycle across systems. Okta supports both inbound (provisioning users into Okta) and outbound (provisioning Okta users to downstream apps) SCIM.

IETF: [SCIM 2.0 Core Schema (RFC 7643)](https://datatracker.ietf.org/doc/html/rfc7643)
IETF: [SCIM 2.0 Protocol (RFC 7644)](https://datatracker.ietf.org/doc/html/rfc7644)

### 4.2 Outbound SCIM (Okta → Target App)

- Application must support SCIM 2.0 provisioning API
- Configure in Okta: Application → Provisioning → Integration → Enable API integration
- Configure attribute mappings and provisioning actions (Create, Update, Deactivate)
- Assign users/groups to trigger provisioning

**Citation**: [Okta — Configure provisioning for an app](https://help.okta.com/en-us/content/topics/provisioning/lcm/lcm-provision-deactivate-overview.htm)

### 4.3 Inbound SCIM (HR system → Okta)

HR-driven provisioning: Workday, BambooHR, and other HR systems push user changes to Okta via SCIM or Okta's native HR connectors. Okta then provisions downstream applications.

**Citation**: [Okta — Lifecycle Management](https://www.okta.com/products/lifecycle-management/)

---

## 5. Entra ID Federation (How-to)

### 5.1 Configure Entra ID as Inbound IdP for Okta

Use case: Entra ID is the primary IdP; Okta handles SSO to apps not in the Entra ID app gallery.

Steps:
1. Register Okta as enterprise app in Entra ID (SAML app registration)
2. Configure Entra ID SAML settings: Entity ID, Reply URL (ACS), Signing certificate
3. Configure Okta inbound IdP: upload Entra ID SAML metadata
4. Map Entra ID claims to Okta profile attributes
5. Enable JIT provisioning in Okta for Entra ID-authenticated users

**Citation**: [Okta — Configure SAML 2.0 for Microsoft Azure AD](https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-Microsoft-Office-365.html)
**Citation**: [Microsoft Learn — SAML-based SSO for enterprise applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-saml-single-sign-on)

---

## 6. Lifecycle Automation (How-to)

### 6.1 Joiner/Mover/Leaver Patterns

- **Joiner**: New hire created in HR system → SCIM push to Okta → Okta provisions downstream apps → access granted before day 1
- **Mover**: Role change in HR → attribute update in Okta → dynamic group recalculation → access updated automatically
- **Leaver**: Termination in HR → user deactivated in Okta → all app sessions terminated and accounts deprovisioned

**Citation**: [Okta — Lifecycle Management overview](https://www.okta.com/products/lifecycle-management/)

### 6.2 Okta Workflows

Okta Workflows (no-code automation) can extend lifecycle events with custom logic — e.g., send Slack notification on provisioning, create ServiceNow ticket on access request, delay deprovisioning for offboarding period.

**Citation**: [Okta — Workflows documentation](https://help.okta.com/en-us/content/topics/workflows/workflows-main.htm)

---

## 7. Citation Sources

### Okta Documentation

- [Okta organizations](https://developer.okta.com/docs/concepts/okta-organizations/)
- [Universal Directory](https://help.okta.com/en-us/content/topics/directory/eu-about-universal-directory.htm)
- [Authentication policies (OIE)](https://help.okta.com/en-us/content/topics/identity-engine/policies/about-auth-policy.htm)
- [Build SAML SSO integration](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/)
- [Add external SAML IdP](https://developer.okta.com/docs/guides/add-an-external-idp/saml2/main/)
- [Configure app provisioning](https://help.okta.com/en-us/content/topics/provisioning/lcm/lcm-provision-deactivate-overview.htm)
- [Lifecycle Management](https://www.okta.com/products/lifecycle-management/)
- [SCIM provisioning overview](https://developer.okta.com/docs/concepts/scim/)
- [Okta Workflows](https://help.okta.com/en-us/content/topics/workflows/workflows-main.htm)

### Standards

- [SAML 2.0 specification](https://docs.oasis-open.org/security/saml/v2.0/)
- [SCIM 2.0 Core Schema (RFC 7643)](https://datatracker.ietf.org/doc/html/rfc7643)
- [SCIM 2.0 Protocol (RFC 7644)](https://datatracker.ietf.org/doc/html/rfc7644)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

### Australian Regulatory

- [ACSC — Essential Eight: Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712)
