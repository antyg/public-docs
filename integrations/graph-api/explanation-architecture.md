---
title: "Microsoft Graph API Architecture"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "explanation"
domain: "integrations"
platform: "Microsoft Graph API"
---

# Microsoft Graph API Architecture

## Scope

This document explains the architectural model of Microsoft Graph API: what it is, why it is structured the way it is, how the permissions model works, how rate limiting is enforced, and what paging patterns reveal about the underlying data model. It is intended to build understanding, not to provide step-by-step instructions.

For practical how-to guidance, see [how-to/authenticate.md](../how-to/authenticate.md) and [how-to/common-operations.md](../how-to/common-operations.md).

---

## What Microsoft Graph API Is

Microsoft Graph API is a unified REST API gateway to data and services across the Microsoft cloud. It presents a single endpoint (`https://graph.microsoft.com`) as the entry point to resources that span many underlying services:

| Underlying service | Graph resource examples |
|-------------------|------------------------|
| Microsoft Entra ID (Azure AD) | Users, groups, applications, service principals, devices |
| Microsoft Intune | Managed devices, compliance policies, configuration profiles |
| Microsoft Defender | Security alerts, incidents, secure score |
| Exchange Online | Mail, calendar, contacts |
| SharePoint Online | Sites, lists, document libraries |
| Microsoft Teams | Teams, channels, messages |
| Microsoft 365 | Reports, usage analytics, audit logs |

Before Graph API, each service had its own API endpoint and authentication model. Graph consolidates them behind a single authenticated entry point with a consistent OAuth 2.0 model. For a comprehensive introduction, see the [Overview of Microsoft Graph](https://learn.microsoft.com/en-us/graph/overview).

---

## API Version Architecture

Graph publishes two API surfaces simultaneously:

**v1.0** — The generally available surface. Microsoft commits to backward compatibility for v1.0 endpoints. Breaking changes (removals, renames) follow a minimum 36-month deprecation window. This is the correct surface for production workloads.

**Beta** — A preview surface containing new features not yet promoted to GA. Beta endpoints may change schema, rename properties, or be removed without notice. Beta exists for evaluation and development only. Microsoft does not support production use of beta.

The dual-surface model allows Microsoft to evolve the API rapidly in beta while maintaining stability guarantees for production consumers on v1.0. See [Microsoft Graph versioning, support, and breaking change policies](https://learn.microsoft.com/en-us/graph/versioning-and-support) for deprecation timelines and compatibility guarantees.

---

## Permissions Model

Graph API uses OAuth 2.0 scopes to enforce access control. The permissions model has three dimensions:

### Dimension 1 — Permission Type

**Delegated permissions** represent what a signed-in user allows the application to do on their behalf. The access is bounded by both the application's permissions and the user's own access rights. An application with `User.Read.All` delegated permission cannot read a user's data if the signed-in user does not have directory read access.

**Application permissions** represent what the application itself can do, with no user present. This is the model for background services and daemons. Application permissions are granted to the application identity (service principal) and require administrator consent for every permission.

### Dimension 2 — Scope Breadth

Permissions are scoped to minimise access:

| Scope suffix | Meaning |
|-------------|---------|
| `.Read` | Read access to the caller's own data only |
| `.Read.All` | Read access across all instances of the resource |
| `.ReadWrite` | Read and write access to the caller's own data |
| `.ReadWrite.All` | Read and write access across all instances |
| `.ReadBasic.All` | Read a limited set of properties across all instances (more restricted than `.Read.All`) |

### Dimension 3 — Consent

Before an application can use a permission, consent must be recorded in the tenant:

- **User consent** — The signed-in user approves delegated permissions that are not flagged as requiring admin consent. Typically applies to user-scoped permissions like `User.Read`.
- **Admin consent** — A tenant administrator approves permissions on behalf of all users, or approves application permissions. Required for any `.All` scoped permission and any permission that accesses data across multiple users.

The principle of least privilege applies: request only the permissions your application requires and no more. For the full model, see [Permissions and consent in the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview).

---

## Rate Limiting Architecture

Graph API enforces throttling to protect service reliability across all tenants. The throttle limits operate at multiple levels simultaneously:

| Level | Description |
|-------|-------------|
| Per application per tenant | Requests from a specific app in a specific tenant |
| Per tenant | Total requests across all apps in a tenant |
| Per resource | Some resources (mailboxes, SharePoint sites) have their own per-resource limits |
| Per service | Underlying services (Exchange, SharePoint) enforce their own limits, which propagate to Graph |

When a request is throttled, Graph returns `HTTP 429 Too Many Requests` with a `Retry-After` header specifying the number of seconds to wait before retrying.

The correct response to a 429 is to pause for exactly the duration in `Retry-After` and retry the single failed request. Do not retry immediately, do not reduce the page size, and do not terminate the session — the token remains valid through a throttling event.

For `HTTP 503 Service Unavailable` and `HTTP 504 Gateway Timeout`, apply exponential backoff because no `Retry-After` header is guaranteed. See the [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling) for per-service rate limits.

---

## Paging Model

Graph API returns large collections in pages rather than returning all records in a single response. This is a consequence of the underlying services having their own result set limits and to protect service performance.

The paging mechanism uses OData `@odata.nextLink`:

- The first response contains a `value` array and, when more pages exist, an `@odata.nextLink` property.
- `@odata.nextLink` is a complete URL (including all original query parameters and a server-generated continuation token).
- The client must issue a GET to `@odata.nextLink` verbatim — the continuation token encodes server state and must not be modified.
- When `@odata.nextLink` is absent from a response, the current page is the last page.

The `$top` parameter sets the requested page size but the server may return fewer results than requested. Some resources have a maximum page size (e.g., 999 for users). Requesting `$top=999` is the conventional approach to maximise page size and reduce the number of round trips. See [Paging Microsoft Graph data in your app](https://learn.microsoft.com/en-us/graph/paging) for resource-specific page size limits.

---

## Delta Queries

Delta queries allow clients to efficiently track changes to a resource over time without retrieving the entire collection on each poll. The mechanism is:

1. Issue an initial delta query (e.g., `GET /users/delta`). Graph returns the full current state plus a `@odata.deltaLink`.
2. Store the `@odata.deltaLink`.
3. On subsequent calls, issue a GET to the stored `@odata.deltaLink`. Graph returns only the changes since the previous delta call.

Delta queries are suited to synchronisation scenarios — maintaining a local cache of users or devices that stays in sync with the directory without full re-enumeration on each cycle. See [Use delta query to track changes in Microsoft Graph data](https://learn.microsoft.com/en-us/graph/delta-query-overview) for supported resources and limitations.

---

## Consistency Levels

Some Graph resources support two consistency models:

**Default consistency** — Responses are served from replicated data stores and may reflect a state that is several seconds behind the authoritative copy. Appropriate for most read operations.

**Eventual consistency** (`ConsistencyLevel: eventual` header) — Required for advanced query capabilities including `$count`, `$search`, and certain `$filter` operators (`not`, `endsWith`, lambda operators). The tradeoff is that results may not reflect the very latest writes. The `$count=true` parameter combined with `ConsistencyLevel: eventual` is required to return accurate total counts for large collections. See [Advanced query capabilities on Azure AD directory objects](https://learn.microsoft.com/en-us/graph/aad-advanced-queries) for supported operators per resource.

---

## Batch Request Model

The `$batch` endpoint accepts a JSON document containing up to 20 individual request objects and returns a JSON document containing a response object for each. This reduces the number of HTTP round trips when multiple independent calls are needed.

Key characteristics of the batch model:

- **Independence** — Each request in the batch executes independently. A 404 on one request does not fail the others.
- **Ordering** — Response ordering is not guaranteed to match request ordering. Use the `id` field to correlate.
- **Throttling** — Each request in the batch counts against the same throttle limits as a standalone request. Batching does not bypass or expand rate limits.
- **Dependencies** — A `dependsOn` array can declare ordering dependencies between requests in the same batch (e.g., create user before assigning licence). See [Combine multiple requests using JSON batching](https://learn.microsoft.com/en-us/graph/json-batching) for the full batch schema.

---

## PowerShell SDK Architecture

The Microsoft Graph PowerShell SDK is a generated SDK that wraps every v1.0 and beta Graph API endpoint as a PowerShell cmdlet. Key architectural points:

- **Module structure** — The SDK is split into sub-modules by service area (e.g., `Microsoft.Graph.Users`, `Microsoft.Graph.DeviceManagement`). Installing `Microsoft.Graph` installs all sub-modules.
- **Authentication** — Authentication is handled by `Microsoft.Graph.Authentication`, which uses the MSAL.NET library internally. `Connect-MgGraph` stores the session token in the PowerShell session.
- **Paging** — The `-All` parameter instructs the SDK to automatically follow `@odata.nextLink` and aggregate all pages into a single result. Without `-All`, only the first page is returned.
- **Profiles** — The SDK supports both v1.0 and beta profiles. Switch using `Select-MgProfile -Name beta`. The default is v1.0.
- **Generated cmdlets** — All cmdlets follow the pattern `{Verb}-Mg{ResourcePath}` (e.g., `Get-MgUser`, `New-MgGroup`, `Remove-MgDevice`). See the [Microsoft Graph PowerShell SDK overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview) for installation and module selection.

---

## Related Resources

### Microsoft Official Documentation

- [Overview of Microsoft Graph](https://learn.microsoft.com/en-us/graph/overview)
- [Microsoft Graph versioning, support, and breaking change policies](https://learn.microsoft.com/en-us/graph/versioning-and-support)
- [Permissions and consent in the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/permissions-consent-overview)
- [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)
- [Paging Microsoft Graph data in your app](https://learn.microsoft.com/en-us/graph/paging)
- [Use delta query to track changes](https://learn.microsoft.com/en-us/graph/delta-query-overview)
- [Advanced query capabilities on Azure AD directory objects](https://learn.microsoft.com/en-us/graph/aad-advanced-queries)
- [Combine multiple requests using JSON batching](https://learn.microsoft.com/en-us/graph/json-batching)
- [Microsoft Graph PowerShell SDK overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)

### Related Documents

- [Endpoint Reference](../reference/endpoints.md)
- [Authentication Reference](../reference/authentication.md)
- [Error Codes Reference](../reference/error-codes.md)
- [How To: Authenticate](../how-to/authenticate.md)
- [How To: Common Operations](../how-to/common-operations.md)
- [MSAL Redirect URI Specification](../msal-redirect-uri-requirements.md)
