---
title: "How to Register and Configure Applications in Entra ID"
status: "published"
last_updated: "2026-03-08"
audience: "Application developers, identity engineers, Azure administrators"
document_type: "how-to"
domain: "identity"
---

# How to Register and Configure Applications in Entra ID

---

## Overview

App registrations define how an application integrates with Microsoft Entra ID for authentication and authorisation. This guide covers creating app registrations, configuring OAuth 2.0 flows, managing API permissions, and setting up service principals.

---

## Core Concepts

| Concept                         | Description                                                                    |
| ------------------------------- | ------------------------------------------------------------------------------ |
| **App registration**            | The identity definition of an application — exists once in the home tenant     |
| **Service principal**           | The instantiation of an app registration in a specific tenant — the "instance" |
| **Client ID**                   | The unique identifier for the app registration (also called Application ID)    |
| **Tenant ID**                   | The unique identifier for the Entra ID tenant                                  |
| **Client secret / certificate** | Credentials used by confidential clients to authenticate to Entra ID           |
| **Redirect URI**                | The URL to which Entra ID sends the authentication response                    |
| **Scope**                       | A permission being requested by the application                                |

Microsoft Learn: [Application and service principal objects](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)

---

## 1. Create an App Registration

**Navigate to**: Microsoft Entra admin centre → Applications → App registrations → New registration

Configure:

- **Name**: Descriptive application name (e.g., `Contoso HR Portal`)
- **Supported account types**: Choose the appropriate option:
  - _Accounts in this organisational directory only_ — Single-tenant; only users in your tenant
  - _Accounts in any organisational directory_ — Multi-tenant; any Entra ID tenant
  - _Accounts in any directory + Microsoft accounts_ — Multi-tenant + personal accounts
- **Redirect URI**: Select platform (Web, SPA, Mobile) and enter the callback URL

Microsoft Learn: [Register an application with the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)

---

## 2. Configure Authentication — OAuth 2.0 Flows

### Authorisation Code Flow (recommended for web apps)

The authorisation code flow with PKCE is the recommended flow for most applications. Configure the redirect URI under **Authentication → Platform configurations → Web**.

Ensure:

- Redirect URIs use HTTPS (except `localhost` for development)
- **ID tokens** and **Access tokens** are NOT checked under Implicit grant — use auth code flow instead
- **Allow public client flows** is disabled for confidential clients

Microsoft Learn: [OAuth 2.0 authorisation code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)

### Client Credentials Flow (service-to-service, no user)

For daemon applications and background services that authenticate as themselves (not on behalf of a user), use the client credentials flow. This flow requires application permissions (not delegated).

Microsoft Learn: [OAuth 2.0 client credentials flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow)

---

## 3. Manage API Permissions

**Navigate to**: App registration → API permissions → Add a permission

### Delegated permissions

The application acts on behalf of the signed-in user. The user's permissions constrain what the app can do.

Example: `User.Read` — sign in and read the signed-in user's profile.

### Application permissions

The application acts as itself with no signed-in user. These are more powerful and require administrator consent.

Example: `User.Read.All` — read all users' profiles in the tenant.

### Grant admin consent

Application permissions always require admin consent. Delegated permissions may also require it depending on the permission sensitivity.

**Navigate to**: App registration → API permissions → Grant admin consent for [tenant name]

Microsoft Learn: [Permissions and consent in the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview)

---

## 4. Configure Client Credentials

### Client secret (simpler, lower security)

**Navigate to**: App registration → Certificates & secrets → Client secrets → New client secret

- Set a short expiry (12–24 months maximum)
- Store the secret value immediately — it is not retrievable after creation
- Store in Azure Key Vault, not in application configuration files

### Certificate (recommended for production)

Certificates are more secure than client secrets. Use a certificate issued from your PKI or a self-signed certificate for non-production environments.

**Navigate to**: App registration → Certificates & secrets → Certificates → Upload certificate

Microsoft Learn: [Add credentials to your application](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials)

**ACSC ISM alignment**: The [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requires that service accounts use strong credentials and that credentials are rotated regularly. Certificate-based authentication with short validity periods satisfies this more completely than long-lived client secrets.

---

## 5. Configure App Roles

App roles enable role-based access control (RBAC) within your application. Define roles in the app registration manifest; assign them to users and groups via the enterprise application.

**Navigate to**: App registration → App roles → Create app role

Example manifest entry:

```json
{
  "allowedMemberTypes": ["User"],
  "description": "Can read reports",
  "displayName": "Report Reader",
  "isEnabled": true,
  "value": "Reports.Read"
}
```

**Navigate to**: Enterprise applications → [your app] → Users and groups → Add user/group → assign role

Microsoft Learn: [Add app roles to your application](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-app-roles-in-apps)

---

## 6. Service Principals and Enterprise Applications

When an app registration is instantiated in a tenant (either by creation or by admin consent for a multi-tenant app), a **service principal** is created. Service principals appear in:

**Microsoft Entra admin centre → Applications → Enterprise applications**

From the enterprise application, you can:

- Assign users and groups
- Configure single sign-on (SSO)
- Manage provisioning (SCIM)
- Review sign-in activity

Microsoft Learn: [What is application management in Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/what-is-application-management)

---

## Related Resources

- [App registration quickstart](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [Application and service principal objects](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)
- [OAuth 2.0 authorisation code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)
- [Permissions and consent overview](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview)
- [Add credentials to your application](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials)
- [App roles](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-app-roles-in-apps)
- [Enterprise application management](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/what-is-application-management)
- [Microsoft identity platform best practices](https://learn.microsoft.com/en-us/entra/identity-platform/identity-platform-integration-checklist)
- [ACSC — ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
