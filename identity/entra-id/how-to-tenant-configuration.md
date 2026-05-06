---
title: "How to Configure an Entra ID Tenant"
status: "published"
last_updated: "2026-03-08"
audience: "Azure administrators, identity engineers"
document_type: "how-to"
domain: "identity"
---

# How to Configure an Entra ID Tenant

---

## Overview

This guide covers the essential configuration steps for a new or existing Microsoft Entra ID tenant — custom domains, security defaults vs. Conditional Access, company branding, and tenant-level security settings.

---

## 1. Add and Verify a Custom Domain

By default, your tenant uses an `onmicrosoft.com` domain. Adding a custom domain allows users to sign in with your organisation's email address.

**Navigate to**: Microsoft Entra admin centre → Identity → Settings → Domain names → Add custom domain

Steps:

1. Enter your domain name (e.g., `contoso.com.au`)
2. Copy the TXT record provided
3. Add the TXT record to your DNS provider
4. Return to Entra admin centre and select **Verify**
5. Once verified, set as **Primary** if required

Microsoft Learn: [Add your custom domain name](https://learn.microsoft.com/en-us/entra/fundamentals/add-custom-domain)

---

## 2. Configure Company Branding

Company branding customises the Entra ID sign-in page with your organisation's logo and colours.

**Navigate to**: Microsoft Entra admin centre → Identity → User experiences → Company branding

Configure:

- **Sign-in page background image** — Recommended 1920×1080px, max 300KB
- **Banner logo** — Appears on sign-in page; recommended 280×60px, max 10KB
- **Username hint text** — Replaces the default "<someone@example.com>" placeholder
- **Sign-in page text** — Custom text displayed below the sign-in form

Microsoft Learn: [Add branding to your organisation's sign-in page](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-customize-branding)

---

## 3. Configure Security Defaults vs. Conditional Access

**Security Defaults** provide baseline protection for free-tier tenants. **Conditional Access** provides granular, policy-based control and requires Entra ID P1 or P2 licensing.

### Security Defaults (free tier)

Security Defaults enforce:

- MFA registration for all users
- MFA required for administrators on every sign-in
- MFA required for users when risk is detected
- Block of legacy authentication protocols

**Navigate to**: Microsoft Entra admin centre → Identity → Overview → Properties → Manage security defaults

Security Defaults are recommended for organisations that cannot deploy Conditional Access. They are mutually exclusive with Conditional Access — you cannot run both simultaneously.

Microsoft Learn: [Security defaults in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)

### Conditional Access (P1/P2)

Conditional Access policies replace Security Defaults and provide granular control. See the dedicated [`conditional-access/`](../../conditional-access/README.md) domain for full guidance.

---

## 4. Configure Tenant-Level Password Policy

For cloud-only users, configure the password expiration policy:

**Navigate to**: Microsoft 365 admin centre → Settings → Org settings → Security & privacy → Password policy

Recommended setting: **Passwords never expire**

For rationale and implementation detail, see [`password-policy/`](../../password-policy/README.md).

Microsoft Learn: [Set the password expiration policy](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)

---

## 5. Configure Self-Service Password Reset (SSPR)

SSPR allows users to reset their own passwords without a helpdesk call, reducing operational overhead.

**Navigate to**: Microsoft Entra admin centre → Protection → Password reset

Configure:

- **Self service password reset enabled**: All (recommended) or Selected group
- **Authentication methods required**: 2 (for higher assurance)
- **Authentication methods available**: Mobile app code, Email, Mobile phone, Office phone
- **Registration**: Require users to register on sign-in

Microsoft Learn: [Tutorial: Enable self-service password reset](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr)

---

## 6. Configure User Settings

**Navigate to**: Microsoft Entra admin centre → Identity → Users → User settings

Review and configure:

- **App registrations** — Whether non-admin users can register applications (recommended: No)
- **LinkedIn account connections** — Disable if not required
- **External collaboration settings** — Control who can invite guests

Microsoft Learn: [Default user permissions](https://learn.microsoft.com/en-us/entra/fundamentals/users-default-permissions)

---

## 7. Configure Diagnostic Settings (Audit Logging)

Entra ID generates sign-in logs, audit logs, and provisioning logs. Route these to a SIEM or Log Analytics workspace for retention and analysis.

**Navigate to**: Microsoft Entra admin centre → Identity → Monitoring & health → Diagnostic settings → Add diagnostic setting

Configure:

- **Log categories**: AuditLogs, SignInLogs, NonInteractiveUserSignInLogs, ServicePrincipalSignInLogs, RiskyUsers, UserRiskEvents
- **Destination**: Log Analytics workspace or Microsoft Sentinel workspace

Microsoft Learn: [Integrate Entra ID logs with Azure Monitor](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs)

---

## Related Resources

- [Microsoft Entra admin centre](https://entra.microsoft.com/)
- [Entra ID fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)
- [Add custom domain](https://learn.microsoft.com/en-us/entra/fundamentals/add-custom-domain)
- [Security defaults](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)
- [Self-service password reset](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr)
- [Entra ID monitoring](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/)
- [ACSC — Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
