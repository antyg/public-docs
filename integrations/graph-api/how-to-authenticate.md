---
title: "How To Authenticate with Microsoft Graph API"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "how-to"
domain: "integrations"
platform: "Microsoft Graph API"
---

# How To Authenticate with Microsoft Graph API

## Scope

This guide covers the practical steps to establish authenticated access to Microsoft Graph API from PowerShell and Python. It assumes you have an Entra ID tenant and the permissions to register applications or use an existing registration.

This guide does not reproduce Microsoft Learn portal instructions step by step — it references the authoritative how-to guides from Microsoft for portal tasks and focuses on the code and configuration decisions you make.

---

## Prerequisites

- An Entra ID (Azure AD) tenant
- Permissions to register an application, or an existing app registration with a client ID
- PowerShell 7+ (for PowerShell examples) or Python 3.8+ with `msal` installed (`pip install msal`)

---

## Step 1 — Register an Application

If you do not have an existing app registration, create one:

1. Navigate to **Entra admin centre** > **Identity** > **Applications** > **App registrations** > **New registration**
2. Name the application, select the appropriate supported account type (typically **Single tenant**)
3. For interactive/delegated flows, set the redirect URI to `http://localhost` under **Mobile and desktop applications**

For step-by-step portal navigation, see [Register an application with the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app).

For redirect URI requirements (including WAM broker URIs required by Graph PowerShell SDK v2.34.0+), see [msal-redirect-uri-requirements.md](../msal-redirect-uri-requirements.md).

---

## Step 2 — Choose an Authentication Flow

| Scenario | Recommended Flow | Permission Type |
|----------|-----------------|----------------|
| Background service, no user present | Client credentials | Application |
| Script run interactively by a user | Authorisation code (PKCE) | Delegated |
| Headless environment, SSH session | Device code | Delegated |
| Azure-hosted workload | Managed identity | Application |
| Domain-joined machine, current Windows user | Integrated Windows Auth | Delegated |

For full details on each flow, see [authentication.md](../reference/authentication.md).

---

## Step 3 — Grant Permissions

Permissions must be added to the app registration and consented to before tokens can be acquired.

1. In the app registration, go to **API permissions** > **Add a permission** > **Microsoft Graph**
2. Select **Application permissions** (for client credentials / managed identity) or **Delegated permissions** (for user-context flows)
3. Search for and add the required permissions (e.g., `User.Read.All`, `DeviceManagementManagedDevices.Read.All`)
4. An administrator must click **Grant admin consent** for application permissions and for delegated permissions that require admin consent

For the full permissions catalogue, see [endpoints.md — Permissions Matrix](../reference/endpoints.md#permissions-matrix).

---

## Step 4 — Acquire a Token

### PowerShell — Graph PowerShell SDK (Recommended)

The Graph PowerShell SDK (`Microsoft.Graph`) handles token acquisition via `Connect-MgGraph`. This is the recommended approach for PowerShell.

**Install the SDK:**

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

**Connect with client credentials (app-only):**

```powershell
$tenantId  = 'your-tenant-id'
$clientId  = 'your-client-id'
$clientSecret = ConvertTo-SecureString 'your-secret' -AsPlainText -Force

$credential = [System.Management.Automation.PSCredential]::new($clientId, $clientSecret)

Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential
```

**Connect with certificate credential (app-only, preferred for production):**

```powershell
Connect-MgGraph -TenantId $tenantId -ClientId $clientId -CertificateThumbprint 'thumbprint'
```

**Connect interactively (delegated, opens browser):**

```powershell
Connect-MgGraph -TenantId $tenantId -ClientId $clientId -Scopes 'User.Read.All', 'Group.Read.All'
```

**Connect with device code (delegated, headless):**

```powershell
Connect-MgGraph -TenantId $tenantId -ClientId $clientId -Scopes 'User.Read.All' -UseDeviceCode
```

**Disconnect when finished:**

```powershell
Disconnect-MgGraph
```

For the full list of authentication cmdlets, see [Microsoft Graph PowerShell authentication commands](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands).

---

### PowerShell — MSAL.NET via Microsoft.Identity.Client (Low-Level)

Use this approach when you need direct control over token acquisition outside the Graph SDK — for example, when calling Graph endpoints via `Invoke-RestMethod`.

```powershell
# Install the MSAL.NET package (requires NuGet or direct DLL load)
# This example assumes Microsoft.Identity.Client is available in the session

$tenantId    = 'your-tenant-id'
$clientId    = 'your-client-id'
$clientSecret = 'your-secret'
$scopes      = @('https://graph.microsoft.com/.default')

$app = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($clientId) `
    .WithClientSecret($clientSecret) `
    .WithAuthority("https://login.microsoftonline.com/$tenantId") `
    .Build()

$tokenResult = $app.AcquireTokenForClient($scopes).ExecuteAsync().Result
$accessToken = $tokenResult.AccessToken

# Use the token with Invoke-RestMethod
$headers = @{ Authorization = "Bearer $accessToken" }
$response = Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users' -Headers $headers
```

For alternative client credential patterns, see [MSAL.NET client credentials](https://learn.microsoft.com/en-us/entra/msal/dotnet/acquiring-tokens/web-apps-apis/client-credential-flows).

---

### Python — MSAL for Python (Client Credentials)

```python
import msal
import requests

tenant_id     = "your-tenant-id"
client_id     = "your-client-id"
client_secret = "your-secret"
scopes        = ["https://graph.microsoft.com/.default"]

app = msal.ConfidentialClientApplication(
    client_id,
    authority=f"https://login.microsoftonline.com/{tenant_id}",
    client_credential=client_secret,
)

result = app.acquire_token_silent(scopes, account=None)
if not result:
    result = app.acquire_token_for_client(scopes=scopes)

if "access_token" in result:
    access_token = result["access_token"]
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get("https://graph.microsoft.com/v1.0/users", headers=headers)
    print(response.json())
else:
    print(result.get("error_description"))
```

For Python daemon application patterns, see [Acquire token with client credentials — MSAL Python](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-daemon-acquire-token).

---

### Python — Device Code Flow (Delegated, Headless)

```python
import msal
import requests

tenant_id = "your-tenant-id"
client_id = "your-client-id"
scopes    = ["User.Read.All"]

app = msal.PublicClientApplication(
    client_id,
    authority=f"https://login.microsoftonline.com/{tenant_id}",
)

flow = app.initiate_device_flow(scopes=scopes)
print(flow["message"])  # Instructs user: visit URL and enter the code

result = app.acquire_token_by_device_flow(flow)

if "access_token" in result:
    headers = {"Authorization": f"Bearer {result['access_token']}"}
    response = requests.get("https://graph.microsoft.com/v1.0/me", headers=headers)
    print(response.json())
```

For the full device code flow specification, see [Device code flow — MSAL Python](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code).

---

## Step 5 — Verify the Connection

After acquiring a token, verify it works by calling the `/me` endpoint (delegated) or the `/users` endpoint (application):

```powershell
# PowerShell SDK — confirm connection context
Get-MgContext

# Invoke-RestMethod — verify token with a simple call
Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users?$top=1' -Headers $headers
```

A successful response confirms the token is valid and the permissions are consented.

---

## Credential Storage

| Storage method | Suitability |
|---------------|-------------|
| Azure Key Vault | Recommended for production automation |
| Environment variables | Suitable for CI/CD pipelines |
| OS credential store (`SecretManagement` module) | Suitable for developer workstations |
| `.env` files | Development only — never commit to source control |
| Hard-coded in script | Forbidden — constitutes a credential exposure risk |

For Azure-hosted workloads, use managed identity to eliminate stored credentials entirely.

---

## Troubleshooting Common Issues

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| `InvalidAuthenticationToken` | Expired or wrong-audience token | Re-acquire token; verify `https://graph.microsoft.com` is the resource |
| `Authorization_RequestDenied` | Missing permission or consent | Add and consent the required permission in the app registration |
| `Only loopback redirect uri is supported` | MSAL version incompatibility | Register `http://localhost` and remove `urn:ietf:wg:oauth:2.0:oob` — see [msal-redirect-uri-requirements.md](../msal-redirect-uri-requirements.md) |
| `WAM` / broker error in Graph SDK | WAM broker URI not registered | Add `ms-appx-web://Microsoft.AAD.BrokerPlugin/{client_id}` — see [msal-redirect-uri-requirements.md](../msal-redirect-uri-requirements.md) |
| `AADSTS50034` | User account does not exist in tenant | Verify the tenant ID and UPN |

---

## Related Resources

### Microsoft Official Documentation

- [Register an application with the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [Microsoft Graph PowerShell authentication commands](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands)
- [MSAL overview](https://learn.microsoft.com/en-us/entra/identity-platform/msal-overview)
- [Choose a Microsoft Graph authentication provider](https://learn.microsoft.com/en-us/graph/sdks/choose-authentication-providers)
- [Acquire token with client credentials](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-daemon-acquire-token)
- [MSAL.NET client credential flows](https://learn.microsoft.com/en-us/entra/msal/dotnet/acquiring-tokens/web-apps-apis/client-credential-flows)
- [Device code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code)

### Related Documents

- [Authentication Reference](../reference/authentication.md)
- [Endpoint Reference](../reference/endpoints.md)
- [Error Codes Reference](../reference/error-codes.md)
- [MSAL Redirect URI Specification](../msal-redirect-uri-requirements.md)
- [Common Operations](common-operations.md)
