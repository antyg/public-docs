---
title: "Microsoft Graph API Authentication Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "reference"
domain: "integrations"
platform: "Microsoft Graph API"
---

# Microsoft Graph API Authentication Reference

## Scope

This document is a lookup reference for Microsoft Graph API authentication methods, OAuth 2.0 flows, MSAL libraries, token types, and token management. It does not provide step-by-step setup instructions (see [how-to/authenticate.md](../how-to/authenticate.md)) or redirect URI specifications (see [msal-redirect-uri-requirements.md](../msal-redirect-uri-requirements.md)).

---

## Authentication Foundation

All Microsoft Graph API requests require a valid OAuth 2.0 access token issued by the Microsoft identity platform (Azure AD / Microsoft Entra ID). The token is passed as a Bearer token in the `Authorization` request header:

```http
Authorization: Bearer {access_token}
```

MSAL (Microsoft Authentication Library) is the recommended library for acquiring tokens. ADAL (Azure Active Directory Authentication Library) reached end of support in June 2023 and must not be used for new implementations. For a full overview, see [Authentication and authorisation basics for Microsoft Graph](https://learn.microsoft.com/en-us/graph/auth/auth-concepts).

---

## OAuth 2.0 Flows

### Client Credentials Flow (App-Only)

| Property | Value |
|----------|-------|
| Permission type | Application |
| User context | None — acts as the application identity |
| Redirect URI required | No |
| Admin consent required | Yes — for all application permissions |
| Typical use | Background services, daemons, unattended automation |

The client authenticates directly to the token endpoint using either a client secret or a certificate credential. No user is present in the flow. See the [OAuth 2.0 client credentials flow on the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow) for full implementation details.

---

### Authorisation Code Flow with PKCE (Delegated)

| Property | Value |
|----------|-------|
| Permission type | Delegated |
| User context | Signed-in user — access is scoped to what the user can access |
| Redirect URI required | Yes — loopback (`http://localhost`) for desktop scripts |
| Admin consent required | Required for admin-scoped delegated permissions |
| Typical use | Interactive applications, scripts run by a user |

PKCE (Proof Key for Code Exchange) is required for public clients (desktop apps, scripts). PKCE prevents authorisation code interception attacks. For full details, see the [OAuth 2.0 authorisation code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow) reference.

---

### Device Code Flow (Delegated)

| Property | Value |
|----------|-------|
| Permission type | Delegated |
| User context | Signed-in user |
| Redirect URI required | No |
| Allow public client flows | Must be enabled on app registration |
| Typical use | Headless scripts, SSH sessions, CI environments where a browser is unavailable |

The user authenticates on a separate device by visiting a URL and entering a code. The script polls the token endpoint until the user completes authentication. For implementation details, see the [OAuth 2.0 device authorisation grant flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code) reference.

---

### On-Behalf-Of Flow (Delegated)

| Property | Value |
|----------|-------|
| Permission type | Delegated |
| User context | Propagated user identity through a service layer |
| Use case | Middle-tier API that calls Graph on behalf of a user who authenticated to it |

For implementation guidance, see [Microsoft identity platform and OAuth 2.0 On-Behalf-Of flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-on-behalf-of-flow).

---

### Integrated Windows Authentication (Delegated)

| Property | Value |
|----------|-------|
| Permission type | Delegated |
| User context | Currently signed-in Windows domain user |
| Redirect URI required | No |
| Allow public client flows | Must be enabled |
| Requirement | Domain-joined device; federated tenant (ADFS or seamless SSO) |
| Typical use | Enterprise scripts running as the current domain user without prompting |

For requirements and constraints, see [Integrated Windows Authentication](https://learn.microsoft.com/en-us/entra/msal/dotnet/acquiring-tokens/desktop-mobile/integrated-windows-authentication) in the MSAL.NET documentation.

---

## Credential Types

### Client Secret

- A string credential generated in the app registration.
- Maximum validity: 24 months (recommended: 12 months or less).
- Must be stored securely — never in source code, logs, or version control.
- Rotate before expiry; the identity platform issues a warning email 30 and 60 days before expiry. For steps, see [Add a client secret](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app#add-a-client-secret) in the app registration quickstart.

---

### Certificate Credential

- A public/private key pair. The certificate public key is uploaded to the app registration; the private key remains with the client.
- Preferred over client secrets for production automation — certificates cannot be copied from the portal.
- Self-signed certificates are acceptable for non-production; use a CA-issued certificate in production environments.
- Validity period: up to 2 years; rotate before expiry. See [Certificate credentials for application authentication](https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials) for full configuration guidance.

---

### Federated Identity Credential (Workload Identity Federation)

- Allows external identity providers (GitHub Actions, Azure Kubernetes Service, etc.) to authenticate without a secret or certificate.
- The external OIDC token is exchanged for a Microsoft identity platform token.
- Eliminates secret management for CI/CD pipelines in supported environments. See [Workload identity federation](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation) for supported providers and configuration.

---

## MSAL Libraries

| Platform | Library | Package |
|----------|---------|---------|
| PowerShell (Graph SDK) | `Microsoft.Graph.Authentication` module | `Install-Module Microsoft.Graph.Authentication` |
| .NET / PowerShell (low-level) | MSAL.NET (`Microsoft.Identity.Client`) | NuGet: `Microsoft.Identity.Client` |
| Python | MSAL for Python | `pip install msal` |
| JavaScript / Node.js | `@azure/msal-node` | npm: `@azure/msal-node` |
| Java | MSAL4J | Maven: `com.microsoft.azure:msal4j` |

MSAL.PS (a separate PowerShell wrapper for MSAL.NET) is deprecated. Use `Microsoft.Graph.Authentication` (part of the Graph PowerShell SDK) for PowerShell-based Graph API access. For a platform comparison, see the [Microsoft Authentication Library (MSAL) overview](https://learn.microsoft.com/en-us/entra/identity-platform/msal-overview).

---

## Token Types

| Token | Lifetime | Purpose |
|-------|---------|---------|
| Access token | 1 hour (default) | Authorises individual API requests |
| Refresh token | 90 days (sliding window) | Obtains new access tokens without re-authentication |
| ID token | 1 hour | Contains user identity claims; used by the client, not sent to Graph |

Access tokens are non-renewable. When an access token expires, MSAL uses a cached refresh token to silently acquire a new access token. For lifetime configuration details, see [Refresh tokens in the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/refresh-tokens).

---

## Token Scopes

Scopes define the permissions requested from the user or admin. They are specified at token acquisition time.

| Scope format | Example | Meaning |
|-------------|---------|---------|
| Resource + permission | `https://graph.microsoft.com/User.Read` | Read the current user's profile |
| Shorthand (Graph SDK) | `User.Read` | Graph SDK resolves the full URI automatically |
| `.default` scope | `https://graph.microsoft.com/.default` | Request all permissions pre-consented on the app registration (client credentials flow) |
| `openid profile email` | — | Standard OIDC scopes for ID token claims |
| `offline_access` | — | Requests a refresh token |

For the full scope reference and consent model, see [Permissions and consent in the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview).

---

## Token Caching

MSAL maintains an in-memory token cache by default. For long-running processes or scripts, implement persistent token caching to avoid repeated interactive authentication.

| Cache type | Suitable for |
|-----------|-------------|
| In-memory (default) | Short-lived processes; single script runs |
| File-based | Desktop applications; persistent across sessions |
| Distributed (Redis, SQL) | Web apps; multiple instances sharing cache |

The Graph PowerShell SDK manages its own token cache within the PowerShell session. Tokens persist until `Disconnect-MgGraph` is called or the session ends. For persistent cache implementation, see [Token cache serialisation in MSAL.NET](https://learn.microsoft.com/en-us/entra/msal/dotnet/how-to/token-cache-serialization).

---

## Managed Identity

Managed identities eliminate the need for stored credentials in Azure-hosted workloads. The Azure platform issues and rotates the credential automatically.

| Type | Description |
|------|-------------|
| System-assigned | Tied to a specific Azure resource; deleted when the resource is deleted |
| User-assigned | Independent lifecycle; can be assigned to multiple resources |

To use a managed identity with Graph API, the identity must be granted application permissions via Graph API (not the portal). Managed identities cannot be granted delegated permissions. For setup guidance, see [Use a managed identity to call Microsoft Graph](https://learn.microsoft.com/en-us/graph/auth/azure-managed-identity).

---

## WAM (Web Account Manager)

Microsoft Graph PowerShell SDK v2.34.0 and later enable WAM (Windows Web Account Manager) by default on Windows. WAM provides a native Windows authentication broker experience.

When WAM is active, the app registration must include a WAM broker redirect URI:

```
ms-appx-web://Microsoft.AAD.BrokerPlugin/{client_id}
```

For full redirect URI requirements, see [msal-redirect-uri-requirements.md](../msal-redirect-uri-requirements.md).

---

## Related Resources

### Microsoft Official Documentation

- [Authentication and authorisation basics for Microsoft Graph](https://learn.microsoft.com/en-us/graph/auth/auth-concepts)
- [Microsoft Authentication Library (MSAL) overview](https://learn.microsoft.com/en-us/entra/identity-platform/msal-overview)
- [Choose an authentication provider](https://learn.microsoft.com/en-us/graph/sdks/choose-authentication-providers)
- [OAuth 2.0 client credentials flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow)
- [OAuth 2.0 authorisation code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)
- [OAuth 2.0 device authorisation grant flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code)
- [Permissions and consent overview](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview)
- [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Use a managed identity to call Microsoft Graph](https://learn.microsoft.com/en-us/graph/auth/azure-managed-identity)

### Related Documents

- [Endpoint Reference](endpoints.md)
- [Error Codes Reference](error-codes.md)
- [How To: Authenticate](../how-to/authenticate.md)
- [MSAL Redirect URI Specification](../msal-redirect-uri-requirements.md)
- [Explanation: Architecture](../explanation/architecture.md)
