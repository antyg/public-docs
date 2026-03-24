---
title: "Microsoft Graph API Endpoint Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "reference"
domain: "integrations"
platform: "Microsoft Graph API"
---

# Microsoft Graph API Endpoint Reference

## Scope

This document is a lookup reference for Microsoft Graph API endpoint patterns, URI structure, API version selection, and the permissions matrix. It does not provide step-by-step authentication setup (see [how-to/authenticate.md](../how-to/authenticate.md)) or conceptual architecture explanation (see [explanation/architecture.md](../explanation/architecture.md)).

---

## Service Root

All Microsoft Graph REST API requests begin at the service root, as described in the [Microsoft Graph API overview](https://learn.microsoft.com/en-us/graph/overview):

| Version | Base URI | Maturity |
|---------|----------|---------|
| v1.0 | `https://graph.microsoft.com/v1.0` | Generally available — supported for production use |
| beta | `https://graph.microsoft.com/beta` | Preview — schema may change without notice; not recommended for production |

---

## URI Pattern

Graph API URIs follow a consistent hierarchical structure:

```
{serviceRoot}/{version}/{resource}/{resourceId}/{relationship}?{queryParameters}
```

| Segment | Example | Description |
|---------|---------|-------------|
| `serviceRoot` | `https://graph.microsoft.com` | Fixed service root |
| `version` | `v1.0` | API version |
| `resource` | `users` | Top-level resource collection |
| `resourceId` | `{id}` or `{userPrincipalName}` | Individual resource identifier |
| `relationship` | `memberOf` | Navigation property to related resources |
| `queryParameters` | `$select=displayName,mail` | OData query parameters |

Examples:

| Operation | URI |
|-----------|-----|
| List all users | `GET /v1.0/users` |
| Get a single user | `GET /v1.0/users/{id}` |
| Get user's group memberships | `GET /v1.0/users/{id}/memberOf` |
| List Intune managed devices | `GET /v1.0/deviceManagement/managedDevices` |
| List Defender alerts | `GET /v1.0/security/alerts_v2` |
| Send mail | `POST /v1.0/users/{id}/sendMail` |
| Batch request | `POST /v1.0/$batch` |

For the full URI pattern reference, see [Use the Microsoft Graph API](https://learn.microsoft.com/en-us/graph/use-the-api).

---

## v1.0 vs Beta

| Criterion | v1.0 | Beta |
|-----------|------|------|
| Stability guarantee | Yes — breaking changes follow deprecation policy | No — may change at any time |
| Production suitability | Recommended | Not recommended |
| Feature availability | Generally available features only | Preview and GA features |
| Deprecation notice | Minimum 36 months for removed features | None |
| SDK support | Full | Partial |

Use beta endpoints only for accessing preview capabilities during development. Switch to v1.0 before promoting to production. The full policy is documented in [Microsoft Graph versioning, support, and breaking change policies](https://learn.microsoft.com/en-us/graph/versioning-and-support).

---

## Core Resource Catalogue

### Identity and Access

| Resource | v1.0 Path | Description |
|----------|-----------|-------------|
| Users | `/users` | Entra ID user accounts |
| Groups | `/groups` | Microsoft 365 and security groups |
| Service principals | `/servicePrincipals` | App identities in the directory |
| Directory roles | `/directoryRoles` | Entra ID built-in roles |
| Applications | `/applications` | App registrations |
| Devices | `/devices` | Entra ID registered devices |

### Device Management (Intune)

| Resource | v1.0 Path | Description |
|----------|-----------|-------------|
| Managed devices | `/deviceManagement/managedDevices` | Enrolled Intune devices |
| Device compliance policies | `/deviceManagement/deviceCompliancePolicies` | Compliance policy definitions |
| Device configurations | `/deviceManagement/deviceConfigurations` | Configuration profiles |
| Managed apps | `/deviceAppManagement/mobileApps` | Intune app catalogue |
| App protection policies | `/deviceAppManagement/iosManagedAppProtections` | iOS MAM policies |

### Security

| Resource | v1.0 Path | Description |
|----------|-----------|-------------|
| Alerts (v2) | `/security/alerts_v2` | Unified security alerts |
| Incidents | `/security/incidents` | Security incidents |
| Secure score | `/security/secureScores` | Microsoft Secure Score |
| Conditional access policies | `/identity/conditionalAccess/policies` | CA policy definitions |
| Sign-in logs | `/auditLogs/signIns` | Entra ID sign-in audit log |
| Audit logs | `/auditLogs/directoryAudits` | Directory audit events |

### Collaboration

| Resource | v1.0 Path | Description |
|----------|-----------|-------------|
| Mail messages | `/users/{id}/messages` | User mailbox messages |
| Mail folders | `/users/{id}/mailFolders` | Mailbox folder hierarchy |
| Calendar events | `/users/{id}/calendar/events` | Calendar events |
| Teams | `/teams` | Microsoft Teams teams |
| Channels | `/teams/{id}/channels` | Teams channels |
| OneDrive files | `/users/{id}/drive/root/children` | OneDrive items |
| SharePoint sites | `/sites` | SharePoint sites |

### Reports

| Resource | v1.0 Path | Description |
|----------|-----------|-------------|
| Office 365 activity | `/reports/getOffice365ActiveUserDetail` | M365 usage reports |
| Sign-in activity | `/reports/getSignInsDetail` | Sign-in reports |
| Device compliance | `/reports/deviceComplianceDeviceActivity` | Intune compliance reports |

For the complete resource catalogue, see the [Microsoft Graph REST API v1.0 reference](https://learn.microsoft.com/en-us/graph/api/overview).

---

## OData Query Parameters

Graph API supports OData v4 query parameters for filtering, selecting, and shaping responses.

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `$select` | Return only specified properties | `$select=displayName,mail,userPrincipalName` |
| `$filter` | Filter result set | `$filter=accountEnabled eq true` |
| `$top` | Limit result count (max 999 for most resources) | `$top=50` |
| `$skip` | Skip N results (offset pagination) | `$skip=100` |
| `$orderby` | Sort results | `$orderby=displayName asc` |
| `$expand` | Include related resources inline | `$expand=memberOf` |
| `$count` | Include total count in response | `$count=true` |
| `$search` | Full-text search (requires `ConsistencyLevel: eventual` header) | `$search="displayName:Alex"` |

Not all parameters are supported on every resource. Consult the individual resource reference page for supported parameters, or see [Use query parameters to customise responses](https://learn.microsoft.com/en-us/graph/query-parameters) for the full OData parameter reference.

---

## Paging

Graph API returns large result sets across multiple pages. The response body includes an `@odata.nextLink` property when additional pages exist.

| Property | Type | Description |
|----------|------|-------------|
| `value` | Array | Current page of results |
| `@odata.nextLink` | String | URL to retrieve the next page; absent when on the last page |
| `@odata.count` | Integer | Total count of matching items (only present when `$count=true`) |

Pagination pattern:

1. Issue initial request with `$top` to set page size.
2. Check response for `@odata.nextLink`.
3. Issue GET to `@odata.nextLink` URL (preserves filters and select).
4. Repeat until `@odata.nextLink` is absent.

For full details on the paging mechanism, see [Paging Microsoft Graph data in your app](https://learn.microsoft.com/en-us/graph/paging).

---

## Permissions Matrix

Graph API permissions are scoped by resource and operation type. Each permission follows the pattern `{Resource}.{Action}.{Constraint}`.

| Permission format | Example | Meaning |
|-------------------|---------|---------|
| `{Resource}.Read` | `User.Read` | Read the signed-in user's profile (delegated) |
| `{Resource}.Read.All` | `User.Read.All` | Read all users in the directory |
| `{Resource}.ReadWrite.All` | `User.ReadWrite.All` | Read and write all users |
| `{Resource}.ReadBasic.All` | `User.ReadBasic.All` | Read limited properties of all users |

### Permission Types

| Type | Description | Context |
|------|-------------|---------|
| **Delegated** | Acts on behalf of a signed-in user; limited to what the user can access | Interactive applications |
| **Application** | Acts as the application with no user context; requires admin consent | Background services, daemons |

### Common Permissions by Domain

| Domain | Typical Permissions |
|--------|---------------------|
| User management | `User.Read.All`, `User.ReadWrite.All`, `Directory.Read.All` |
| Group management | `Group.Read.All`, `Group.ReadWrite.All`, `GroupMember.Read.All` |
| Intune devices | `DeviceManagementManagedDevices.Read.All`, `DeviceManagementConfiguration.Read.All` |
| Mail access | `Mail.Read`, `Mail.ReadBasic`, `Mail.Send` |
| Security alerts | `SecurityAlert.Read.All`, `SecurityIncident.Read.All` |
| Audit logs | `AuditLog.Read.All`, `Directory.Read.All` |
| Conditional Access | `Policy.Read.All`, `Policy.ReadWrite.ConditionalAccess` |

Admin consent is required for most `.All` scoped application permissions. Delegated permissions for basic user data typically require only user consent. For the full permissions catalogue, see the [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference).

---

## HTTP Methods

| Method | Semantics | Common Use |
|--------|-----------|------------|
| `GET` | Read resource(s) | Retrieve user, list devices, query groups |
| `POST` | Create resource or invoke action | Create group, send mail, create subscription |
| `PATCH` | Partial update | Update user properties, modify policy |
| `PUT` | Replace resource | Replace file content, update permissions |
| `DELETE` | Remove resource | Delete user, remove group member |

For semantics and usage details, see [HTTP methods in Microsoft Graph](https://learn.microsoft.com/en-us/graph/use-the-api#http-methods).

---

## Batch Requests

The `$batch` endpoint allows combining up to 20 individual requests into a single HTTP call.

- Endpoint: `POST https://graph.microsoft.com/v1.0/$batch`
- Maximum requests per batch: 20
- Responses may arrive in any order; use the `id` field to correlate

For full batch request semantics, see [Combine multiple requests in one HTTP call using JSON batching](https://learn.microsoft.com/en-us/graph/json-batching).

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Graph REST API v1.0 reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Use query parameters to customise responses](https://learn.microsoft.com/en-us/graph/query-parameters)
- [Paging Microsoft Graph data in your app](https://learn.microsoft.com/en-us/graph/paging)
- [JSON batching](https://learn.microsoft.com/en-us/graph/json-batching)
- [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Microsoft Graph versioning, support, and breaking change policies](https://learn.microsoft.com/en-us/graph/versioning-and-support)

### Related Documents

- [Authentication Reference](authentication.md)
- [Error Codes Reference](error-codes.md)
- [How To: Authenticate](../how-to/authenticate.md)
- [How To: Common Operations](../how-to/common-operations.md)
- [Explanation: Architecture](../explanation/architecture.md)
- [MSAL Redirect URI Specification](../msal-redirect-uri-requirements.md)
