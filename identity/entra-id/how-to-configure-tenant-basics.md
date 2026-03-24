---
title: "How-To: Configure Entra ID Tenant Basics"
status: "published"
last_updated: "2026-03-08"
audience: "Azure Administrators, M365 Administrators, Identity Architects"
document_type: "how-to"
domain: "identity"
---

# How-To: Configure Entra ID Tenant Basics

---

## Scope

This guide covers the foundational configuration steps for a new or existing Microsoft Entra ID tenant: custom domain registration, company branding, security defaults, and diagnostic settings. It does not cover user or group provisioning, app registrations, or Conditional Access policy design — those are documented in separate how-to guides in this folder.

---

## Prerequisites

Before proceeding, confirm:

- Global Administrator or at minimum Privileged Role Administrator access to the target tenant
- A verified DNS zone for the custom domain (e.g., hosted in Azure DNS or an external registrar)
- Licences assigned: at minimum Entra ID Free for basic configuration; Entra ID P1 for Conditional Access; Entra ID P2 for Identity Protection and Privileged Identity Management
- Decision made on authentication method (cloud-only, Password Hash Synchronisation, Pass-Through Authentication, or federation) — see [`how-to/directory-synchronisation.md`](directory-synchronisation.md)

---

## 1. Add and Verify a Custom Domain

By default, every Entra ID tenant uses the `.onmicrosoft.com` domain (e.g., `contoso.onmicrosoft.com`). Adding a custom domain (e.g., `contoso.com.au`) enables user principal names (UPNs) and email addresses to reflect the organisation's identity.

**Portal path**: Entra admin centre > Identity > Settings > Domain names > Add custom domain

Steps:

1. Enter the domain name and select **Add domain**.
2. Entra ID presents a TXT or MX DNS record for verification.
3. Add the DNS record at your registrar or DNS zone.
4. Return to the portal and select **Verify**. DNS propagation may take up to 72 hours, though typically completes within minutes for Azure DNS.
5. Once verified, set the domain as **Primary** if it will be the default UPN suffix.

Reference: [Microsoft Learn — Add your custom domain](https://learn.microsoft.com/en-us/entra/fundamentals/add-custom-domain)

---

## 2. Configure Company Branding

Company branding customises the Entra ID sign-in experience with the organisation's logo, background image, and colours. This applies to all Microsoft 365, Azure, and registered application sign-in flows.

**Portal path**: Entra admin centre > User experiences > Company branding > Customise

Required assets:

| Asset | Recommended dimensions | Format |
|---|---|---|
| Banner logo | 280 × 60 px | PNG or JPG, transparent background preferred |
| Square logo | 240 × 240 px | PNG or JPG |
| Background image | 1920 × 1080 px | PNG or JPG, ≤ 300 KB |
| Sign-in page text | Plain text, ≤ 1024 characters | — |

Localised branding variants can be added per language code to support multilingual organisations.

Reference: [Microsoft Learn — Customise the sign-in experience](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-customize-branding)

---

## 3. Review Security Defaults

Security defaults are a baseline set of identity security controls enabled by default in new Entra ID tenants. They enforce MFA registration for all users, require MFA for administrators on every sign-in, and block legacy authentication protocols.

**Portal path**: Entra admin centre > Identity > Overview > Properties > Manage security defaults

Decision criteria:

| Scenario | Recommendation |
|---|---|
| New tenant, no Conditional Access licences | Keep security defaults enabled |
| Tenant with Entra ID P1/P2 licences | Disable security defaults and implement Conditional Access policies instead |
| Hybrid tenant with legacy authentication required | Disable security defaults with care; use named location exclusions in Conditional Access |

Security defaults and Conditional Access are mutually exclusive — enabling Conditional Access requires disabling security defaults first.

Reference: [Microsoft Learn — What are security defaults?](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)

---

## 4. Configure Diagnostic Settings

Entra ID audit and sign-in logs MUST be routed to a Log Analytics workspace or storage account for retention and security operations. Without this configuration, sign-in history is retained for only 7 days (free tenants) or 30 days (P1/P2 tenants).

**Portal path**: Entra admin centre > Identity > Monitoring & health > Diagnostic settings > Add diagnostic setting

Recommended log categories to export:

| Log category | Purpose |
|---|---|
| AuditLogs | Directory change events — user/group/role/app modifications |
| SignInLogs | Interactive user sign-in events |
| NonInteractiveUserSignInLogs | Service account and silent token acquisition |
| ServicePrincipalSignInLogs | App-to-app authentication events |
| ManagedIdentitySignInLogs | Managed identity authentication events |
| RiskyUsers | Identity Protection risk signals |
| UserRiskEvents | Risk detections per sign-in |

For Australian government organisations, log retention MUST align with the [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requirement for audit log retention (minimum 7 years for protected information).

Reference: [Microsoft Learn — Entra ID diagnostic settings](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/howto-configure-diagnostic-settings)

---

## 5. Configure User Settings

Review the default user settings to restrict self-service capabilities appropriate to the organisation's security posture.

**Portal path**: Entra admin centre > Identity > Users > User settings

Key settings to review:

| Setting | Default | Recommended for regulated orgs |
|---|---|---|
| Users can register applications | Yes | No — restrict to administrators |
| Restrict access to Entra admin centre | No | Yes |
| Users can create security groups | Yes | Review based on IT policy |
| Users can create Microsoft 365 groups | Yes | Review based on governance policy |
| Guest user access restrictions | Collaboration | Apply stricter restrictions per PSPF requirements |

Reference: [Microsoft Learn — Default user permissions](https://learn.microsoft.com/en-us/entra/fundamentals/users-default-permissions)

---

## 6. Configure Self-Service Password Reset (SSPR)

SSPR reduces helpdesk calls by enabling users to reset their own passwords. It requires at minimum one authentication method registered per user (e.g., Microsoft Authenticator, email, phone).

**Portal path**: Entra admin centre > Protection > Password reset

Scope options:

- **None** — SSPR disabled for all users
- **Selected** — Enabled for a specific group (recommended for phased rollout)
- **All** — Enabled for all users

SSPR requires Entra ID P1 licence for non-administrator accounts in hybrid environments. It is included at all licence tiers for cloud-only tenants.

Reference: [Microsoft Learn — How SSPR works](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks)

---

## Related Resources

- [Microsoft Learn — Entra ID fundamental concepts](https://learn.microsoft.com/en-us/entra/fundamentals/)
- [Microsoft Learn — Add a custom domain](https://learn.microsoft.com/en-us/entra/fundamentals/add-custom-domain)
- [Microsoft Learn — Customise company branding](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-customize-branding)
- [Microsoft Learn — Security defaults](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)
- [Microsoft Learn — Entra ID diagnostic settings](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/howto-configure-diagnostic-settings)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Entra admin centre](https://entra.microsoft.com)
