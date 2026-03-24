---
title: "Azure REST API"
status: "planned"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "readme"
domain: "integrations"
platform: "Microsoft Azure"
---

# Azure REST API

## Scope

This document is a structured seed for Azure REST API integration documentation. It defines the content outline, key topics, and citation anchors for future substantive implementation. Full implementation is deferred to a subsequent work package.

---

## Overview

The Azure REST API provides programmatic access to Azure resource management operations — creating, reading, updating, and deleting resources across Azure subscriptions. Every operation in the Azure portal and Azure CLI is backed by a REST API call. Direct use of the REST API is appropriate when a client library is unavailable, when fine-grained control over request construction is required, or when integrating with non-Microsoft tooling.

The primary entry point for Azure resource management operations is Azure Resource Manager (ARM):

```
https://management.azure.com/
```

Individual services publish their own data-plane APIs at service-specific endpoints (e.g., `https://{storageAccountName}.blob.core.windows.net/` for Azure Blob Storage).

See the [Azure REST API reference](https://learn.microsoft.com/en-us/rest/api/azure/) for the full catalogue of Azure services and their API endpoints.

---

## Content Outline

### 1. REST API Patterns

**Planned content:**

- Resource URI structure: `{endpoint}/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProvider}/{resourceType}/{resourceName}`
- API versioning: every ARM request requires an `api-version` query parameter specifying the exact schema version (e.g., `api-version=2023-09-01`)
- Content negotiation: `Accept: application/json`, `Content-Type: application/json`
- HTTP method semantics for ARM: GET (read), PUT (create or replace), PATCH (partial update), DELETE (remove), POST (actions)
- Idempotency: PUT operations are idempotent by resource URI; use client-generated request IDs for deduplication

Details on [request and response format](https://learn.microsoft.com/en-us/rest/api/azure/#create-the-request) are documented in the Azure REST API reference.

---

### 2. Authentication

**Planned content:**

#### Service Principal (Client Credentials)

Service principals are the recommended identity for automated Azure REST API access. The service principal is created in Entra ID and granted Azure RBAC roles on the target scope (subscription, resource group, or individual resource).

Token endpoint:
```
POST https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token
```

Request body:
```
grant_type=client_credentials
&client_id={client_id}
&client_secret={client_secret}
&scope=https://management.azure.com/.default
```

The returned `access_token` is passed as `Authorization: Bearer {token}` on all subsequent ARM requests. See [how to create a service principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) in the Entra ID portal.

#### Managed Identity

Azure-hosted workloads (VMs, App Service, Azure Functions, AKS pods) can use managed identity to obtain ARM tokens without stored credentials. The Azure Instance Metadata Service (IMDS) endpoint issues tokens automatically:

```
GET http://169.254.169.254/metadata/identity/oauth2/token
    ?api-version=2018-02-01
    &resource=https://management.azure.com/
Metadata: true
```

See [Use managed identity to access Azure Resource Manager](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-use-vm-token) for token acquisition details and supported workload types.

#### User Delegation (Interactive / Delegated)

Interactive user authentication via [authorisation code flow (PKCE)](https://learn.microsoft.com/en-us/rest/api/azure/#authenticate-with-azure-active-directory) with the `https://management.azure.com/user_impersonation` scope. Appropriate for interactive tooling and developer workflows; not for unattended automation.

---

### 3. ARM REST API Structure

**Planned content:**

- **Subscription hierarchy**: All ARM resources exist within a subscription. The subscription ID is a required URI segment.
- **Resource group**: A logical container within a subscription. Resource groups have their own lifecycle; deleting a resource group deletes all contained resources.
- **Resource provider**: Each Azure service registers a resource provider namespace (e.g., `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.Network`). Provider registration must be active in a subscription before resources of that type can be created.
- **Resource type and name**: The specific resource class within the provider (e.g., `virtualMachines`) and the unique resource name.

Full ARM resource URI pattern:
```
/subscriptions/{subscriptionId}
  /resourceGroups/{resourceGroupName}
  /providers/{resourceProvider}
  /{resourceType}/{resourceName}
```

Resource hierarchy supports nested resource types (e.g., `Microsoft.Compute/virtualMachines/{vmName}/extensions/{extensionName}`). See the [Azure Resource Manager overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview) for full details on the subscription/resource-group/provider hierarchy.

---

### 4. Common Operations

**Planned content by service:**

#### Compute (Microsoft.Compute)

| Operation | Method | URI |
|-----------|--------|-----|
| List VMs in resource group | GET | `/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines` |
| Get VM details | GET | `/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vmName}` |
| Start VM | POST | `…/virtualMachines/{vmName}/start` |
| Stop (deallocate) VM | POST | `…/virtualMachines/{vmName}/deallocate` |

#### Storage (Microsoft.Storage)

| Operation | Method | URI |
|-----------|--------|-----|
| List storage accounts | GET | `/subscriptions/{sub}/providers/Microsoft.Storage/storageAccounts` |
| Get storage account | GET | `/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{name}` |
| List storage account keys | POST | `…/storageAccounts/{name}/listKeys` |

#### Networking (Microsoft.Network)

| Operation | Method | URI |
|-----------|--------|-----|
| List virtual networks | GET | `/subscriptions/{sub}/providers/Microsoft.Network/virtualNetworks` |
| Get VNet | GET | `/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{name}` |
| List NSG rules | GET | `…/networkSecurityGroups/{name}/securityRules` |

Full operation listings for each provider are available in the [Azure REST API reference](https://learn.microsoft.com/en-us/rest/api/azure/).

---

### 5. Error Handling

**Planned content:**

- ARM error response structure: `{"error": {"code": "ErrorCode", "message": "...", "details": [...]}}`
- Common ARM error codes:

| Code | HTTP | Description |
|------|------|-------------|
| `AuthorizationFailed` | 403 | Caller lacks the required RBAC role on the target scope |
| `ResourceNotFound` | 404 | Resource does not exist or caller cannot see it |
| `RequestDisallowedByPolicy` | 403 | Azure Policy is blocking the operation |
| `SubscriptionNotRegistered` | 409 | Resource provider not registered in subscription |
| `TooManyRequests` | 429 | ARM throttle limit exceeded |
| `ResourceGroupNotFound` | 404 | Resource group does not exist |
| `InvalidApiVersionParameter` | 400 | The `api-version` parameter is missing or not supported for this resource type |

- Retry logic: ARM throttling uses `Retry-After` header; exponential backoff for 5xx errors
- Long-running operations: ARM returns `202 Accepted` for async operations with an `Azure-AsyncOperation` or `Location` header to poll for completion

See [Troubleshoot ARM template deployment errors](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/common-deployment-errors) for the full error code reference and remediation guidance.

---

### 6. Rate Limits

**Planned content:**

ARM enforces throttle limits per subscription, per resource provider, and per region. Limits reset on a rolling window.

| Scope | Default limit |
|-------|--------------|
| READ operations per subscription per hour | 12,000 |
| WRITE/DELETE operations per subscription per hour | 1,200 |
| Subscription-level reads per 5 minutes | 300 |

Throttled requests receive `HTTP 429 Too Many Requests` with `Retry-After` and `x-ms-ratelimit-remaining-subscription-reads` (or writes) headers that indicate remaining capacity. See [Throttling Azure Resource Manager requests](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling) for current limits and backoff strategies.

---

## Planned Documentation Structure

When this seed is implemented, the folder will expand to include:

```
azure-rest-api/
├── README.md                                    ← this file (hub)
├── reference-arm-resource-types.md              ← resource provider / type catalogue
├── reference-authentication.md                  ← service principal, managed identity, token acquisition
├── reference-error-codes.md                     ← ARM error codes and throttling reference
├── how-to-authenticate.md                       ← acquire ARM token (PowerShell, Python, curl)
├── how-to-query-resources.md                    ← GET patterns, filtering, paging
├── how-to-manage-resources.md                   ← PUT/PATCH/DELETE patterns, async operations
└── explanation-architecture.md                  ← ARM hierarchy, resource providers, RBAC model
```

---

## Related Resources

### Microsoft Official Documentation

- [Azure REST API reference](https://learn.microsoft.com/en-us/rest/api/azure/)
- [Azure Resource Manager overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
- [REST API request and response format](https://learn.microsoft.com/en-us/rest/api/azure/#create-the-request)
- [Authenticate with service principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- [Use managed identity to access Azure Resource Manager](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-use-vm-token)
- [Authenticate interactively with Azure REST API](https://learn.microsoft.com/en-us/rest/api/azure/#authenticate-with-azure-active-directory)
- [Throttling Azure Resource Manager requests](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling)
- [Troubleshoot ARM template deployment errors](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/common-deployment-errors)

### Related Documents

- [Microsoft Graph API](../graph-api/README.md)
- [Power Platform](../power-platform/README.md)
