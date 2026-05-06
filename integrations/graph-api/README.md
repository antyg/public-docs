---
title: "Microsoft Graph API"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "readme"
domain: "integrations"
---

# Microsoft Graph API

Microsoft Graph API is the unified REST endpoint for programmatic access to Microsoft 365, Entra ID, Intune, Defender, Exchange Online, SharePoint, Teams, and related Microsoft cloud services. All requests are authenticated via OAuth 2.0 tokens issued by the Microsoft identity platform.

---

## Contents of This Folder

### Reference

Factual lookup material — use these when you need to confirm a specific value, code, or behaviour.

| Document | Description |
|----------|-------------|
| [reference-endpoints.md](reference-endpoints.md) | Endpoint catalogue, URI patterns, v1.0 vs beta, OData query parameters, paging model, permissions matrix |
| [reference-authentication.md](reference-authentication.md) | OAuth 2.0 flows, credential types, MSAL libraries, token types, token caching, managed identity |
| [reference-error-codes.md](reference-error-codes.md) | HTTP status codes, Graph-specific error codes, throttling response structure, retry strategy |

### How-To Guides

Goal-oriented guides for accomplishing specific tasks.

| Document | Description |
|----------|-------------|
| [how-to-authenticate.md](how-to-authenticate.md) | Set up MSAL auth, acquire tokens via client credentials, device code, and interactive flows; PowerShell and Python examples |
| [how-to-common-operations.md](how-to-common-operations.md) | Query users, groups, Intune devices, security alerts, mail; use `$select` and `$filter`; batch requests; throttling retry pattern |

### Explanation

Conceptual overviews for understanding how things work and why.

| Document | Description |
|----------|-------------|
| [explanation-architecture.md](explanation-architecture.md) | Graph API architecture, v1.0 vs beta model, permissions model, rate limiting, paging, delta queries, consistency levels, batch model, PowerShell SDK architecture |

### Specifications

| Document | Description |
|----------|-------------|
| [msal-redirect-uri-requirements.md](msal-redirect-uri-requirements.md) | Redirect URI specification for Entra ID app registrations — required URIs, deprecated URIs, WAM broker requirements, localhost matching rules |

---

## Quick Navigation

| Goal | Start here |
|------|-----------|
| Authenticate with client credentials (PowerShell) | [how-to-authenticate.md — Client Credentials](how-to-authenticate.md#powershell--graph-powershell-sdk-recommended) |
| Authenticate with managed identity | [reference-authentication.md — Managed Identity](reference-authentication.md#managed-identity) |
| Look up redirect URI requirements | [reference-msal-redirect-uri-requirements.md](reference-msal-redirect-uri-requirements.md) |
| Find the URI for a Graph resource | [reference-endpoints.md — Core Resource Catalogue](reference-endpoints.md#core-resource-catalogue) |
| Understand permissions needed for an operation | [reference-endpoints.md — Permissions Matrix](reference-endpoints.md#permissions-matrix) |
| Handle a 429 throttling response | [reference-error-codes.md — Retry Strategy](reference-error-codes.md#retry-strategy) |
| Decode a Graph error code | [reference-error-codes.md](reference-error-codes.md) |
| Query all users with paging | [how-to-common-operations.md — Query Users](how-to-common-operations.md#query-users) |
| Batch multiple requests | [how-to-common-operations.md — Batch Multiple Requests](how-to-common-operations.md#batch-multiple-requests) |
| Understand the permissions model | [explanation-architecture.md — Permissions Model](explanation-architecture.md#permissions-model) |
| Understand paging architecture | [explanation-architecture.md — Paging Model](explanation-architecture.md#paging-model) |

---

## Scope of This Folder

This folder covers the Microsoft Graph API itself — the endpoint, authentication, data model, and usage patterns. It is the API-centric foundation.

Technology domains reference this folder for Graph-specific patterns when automating their own workloads:

| Domain | Graph API use |
|--------|--------------|
| `identity/entra-id/` | User provisioning, group management, Conditional Access policies |
| `endpoints/intune/` | Managed device queries, compliance status, configuration policies |
| `security/` | Defender alerts, secure score, audit logs |
| `microsoft-365/` | Mail flow, Teams, SharePoint |

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Graph overview](https://learn.microsoft.com/en-us/graph/overview)
- [Microsoft Graph REST API v1.0 reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Microsoft Authentication Library (MSAL) overview](https://learn.microsoft.com/en-us/entra/identity-platform/msal-overview)
- [Microsoft Graph PowerShell SDK overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)
