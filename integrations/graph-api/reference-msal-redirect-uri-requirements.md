---
title: "MSAL Redirect URI Specification — Graph API App Registrations"
status: "published"
last_updated: "2026-03-09"
audience: "Developers"
document_type: "reference"
domain: "integrations"
---

# MSAL Redirect URI Specification — Graph API App Registrations

---

## Scope

This document specifies the redirect URIs required for Microsoft Entra app registrations used with locally-executed Graph API scripts (PowerShell, Python, .NET). It covers which URIs are required, which are rejected, and why the requirements changed. It does not cover mobile app development, web application redirect URIs, or server-side daemon deployment beyond URI requirements.

---

## Deprecation History

| Date             | Change                                                                                                                                                            | Impact                                                                                                                                                                             | Replacement                                                                                                      |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Jun 2023         | [ADAL end of support](https://learn.microsoft.com/en-us/entra/identity-platform/msal-migration)                                                                   | All ADAL-based scripts must migrate to MSAL                                                                                                                                        | MSAL libraries (`Microsoft.Identity.Client`, `msal` for Python, `Microsoft.Graph.Authentication` for PowerShell) |
| Aug 2022         | [Azure CLI removed `urn:ietf:wg:oauth:2.0:oob`](https://github.com/Azure/azure-cli/issues/23256) from its app registration                                        | First-party signal: OOB URI no longer supported                                                                                                                                    | `http://localhost`                                                                                               |
| MSAL.NET 4.61+   | [`urn:ietf:wg:oauth:2.0:oob` rejected](https://learn.microsoft.com/en-us/answers/questions/2235867/how-to-fix-only-loopback-redirect-uri-is-supported) on desktop | Interactive auth fails: _"Only loopback redirect uri is supported"_                                                                                                                | `http://localhost`                                                                                               |
| MSAL.NET current | [`msal{client_id}://auth` rejected](https://github.com/AzureAD/microsoft-authentication-library-for-dotnet/issues/4805) on desktop                                | Mobile-only custom URL scheme; same loopback error on Windows                                                                                                                      | `http://localhost`                                                                                               |
| Dec 2024         | [Graph PowerShell SDK v2.34.0](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/3419) enables WAM by default                                       | `Connect-MgGraph` requires broker URI registered; [`Set-MgGraphOption -EnableLoginByWAM $false` ineffective](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/3489) | `ms-appx-web://Microsoft.AAD.BrokerPlugin/{client_id}`                                                           |
| Ongoing          | [MSAL.PS module deprecated](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands)                                                  | Wrapper module no longer maintained                                                                                                                                                | `Microsoft.Graph.Authentication` module                                                                          |

---

## Redirect URI Specification

| Redirect URI                                                   | Status          | Platform Scope                        | Auth Flows                                                                                      | Notes                                                                                                                                                                                                       |
| -------------------------------------------------------------- | --------------- | ------------------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ms-appx-web://Microsoft.AAD.BrokerPlugin/{client_id}`         | **Required**    | Windows (`Connect-MgGraph` v2.34.0+)  | WAM broker                                                                                      | Replace `{client_id}` with Application (client) ID. Not set in MSAL code — must be registered in app registration. WAM enabled by default; cannot currently be disabled.                                    |
| `http://localhost`                                             | **Required**    | .NET Core/.NET 5+, Python, PowerShell | Interactive (system browser)                                                                    | MSAL opens system browser, listens on random port. Port ignored for matching per [RFC 8252](https://datatracker.ietf.org/doc/html/rfc8252) — register once without port. HTTP permitted for localhost only. |
| `https://login.microsoftonline.com/common/oauth2/nativeclient` | **Recommended** | .NET Framework (WPF, WinForms)        | Interactive (embedded browser)                                                                  | MSAL intercepts internally; URI never navigated to in a real browser. Works in any cloud. Default for .NET Framework via `WithDefaultRedirectUri()`.                                                        |
| `msauth.<bundle.id>://auth`                                    | **Recommended** | macOS (Swift/Obj-C) only              | macOS native                                                                                    | Not applicable to Windows desktop or PowerShell.                                                                                                                                                            |
| `msal{client_id}://auth`                                       | **Recommended** | iOS, Android, Electron only           | Mobile interactive                                                                              | Custom URL scheme routed by mobile OS. Rejected on Windows/PowerShell with loopback error.                                                                                                                  |
| `urn:ietf:wg:oauth:2.0:oob`                                    | **Supported**   | legacy ADAL                           | Was ADAL default                                                                                | Rejected by current MSAL.NET.                                                                                                                                                                               |
| _(none required)_                                              | —               | All platforms                         | Device code, Integrated Windows Auth, ROPC, Client credentials (secret, certificate, federated) | No redirect URI needed. Client credentials authenticate server-to-server via token endpoint. Device code, IWA, and ROPC require **Allow public client flows = Yes**.                                        |

---

## App Registration Requirements

### Platform and Settings

| Setting                       | Value                           | Applies When                                                                   |
| ----------------------------- | ------------------------------- | ------------------------------------------------------------------------------ |
| **Platform type**             | Mobile and desktop applications | All locally-executed script scenarios                                          |
| **Allow public client flows** | Yes                             | Device code flow, Integrated Windows Auth, ROPC, or any public client scenario |

### Portal Configuration

Configure via **Entra admin centre** > **Identity** > **Applications** > **App registrations** > _{your app}_ > **Authentication**.

For step-by-step instructions, see [How to add a redirect URI to your application](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri).

---

## Localhost Matching Rules

Behaviour defined by [RFC 8252 §7.3](https://datatracker.ietf.org/doc/html/rfc8252#section-7.3) and enforced by the Microsoft identity platform:

| Rule                              | Detail                                                                                                                                                              |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **HTTP permitted**                | `http://localhost` is the only non-HTTPS redirect URI allowed. All other origins require HTTPS.                                                                     |
| **Port ignored**                  | `http://localhost`, `http://localhost:1234`, `http://localhost:8080` all match a single `http://localhost` registration. MSAL selects an available port at runtime. |
| **Do not register port variants** | One `http://localhost` entry is sufficient. Use path segments to differentiate flows (e.g., `/interactive`, `/callback`).                                           |
| **IPv6 not supported**            | `[::1]` is not supported. Use `127.0.0.1` or `localhost`.                                                                                                           |
| **`127.0.0.1` preferred**         | Avoids firewall and DNS resolution issues. `localhost` is widely supported but may resolve differently on some systems.                                             |

---

## Related Resources

### Microsoft Official Documentation

- [Redirect URI (reply URL) restrictions and best practices](https://learn.microsoft.com/en-us/entra/identity-platform/reply-url)
- [How to add a redirect URI to your application](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri)
- [Register desktop apps that call web APIs](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-desktop-app-registration)
- [Configure desktop apps that call web APIs](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-desktop-app-configuration)
- [Default reply URI (MSAL.NET)](https://learn.microsoft.com/en-us/entra/msal/dotnet/how-to/default-reply-uri)
- [MSAL client application configuration](https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-application-configuration)
- [Public and confidential client applications (MSAL)](https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-applications)
- [OAuth 2.0 client credentials flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow)
- [Migrate applications to MSAL](https://learn.microsoft.com/en-us/entra/identity-platform/msal-migration)
- [Authentication flow support in MSAL](https://learn.microsoft.com/en-us/entra/identity-platform/msal-authentication-flows)
- [Microsoft Graph PowerShell authentication commands](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands)

### GitHub Issues and Change Notices

- [Azure CLI — `urn:ietf:wg:oauth:2.0:oob` removal (August 2022)](https://github.com/Azure/azure-cli/issues/23256)
- [MSAL.NET — Loopback redirect URI rejection for `msal{client_id}://auth`](https://github.com/AzureAD/microsoft-authentication-library-for-dotnet/issues/4805)
- [Microsoft Graph PowerShell SDK — WAM interactive browser issue](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/3419)
- [Connect-MgGraph — WAM cannot be disabled via `Set-MgGraphOption`](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/3489)

### Standards

- [RFC 8252 — OAuth 2.0 for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
