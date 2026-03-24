---
title: "Microsoft Graph API Error Codes Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "reference"
domain: "integrations"
platform: "Microsoft Graph API"
---

# Microsoft Graph API Error Codes Reference

## Scope

This document is a lookup reference for HTTP status codes, Graph-specific error codes, throttling responses, and the Graph error response structure. It does not provide error handling implementation guidance (see [how-to/common-operations.md](../how-to/common-operations.md)) or architectural context (see [explanation/architecture.md](../explanation/architecture.md)).

---

## Error Response Structure

All Graph API error responses follow a consistent JSON envelope:

```json
{
  "error": {
    "code": "ErrorCode",
    "message": "Human-readable description of the error.",
    "innerError": {
      "date": "2026-03-16T10:00:00",
      "request-id": "a1b2c3d4-...",
      "client-request-id": "e5f6g7h8-..."
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `error.code` | Machine-readable error identifier. Use this for programmatic handling. |
| `error.message` | Human-readable description. Content may change; do not parse programmatically. |
| `error.innerError` | Additional diagnostic detail. Present only when additional context is available. |
| `innerError.date` | Timestamp of the error on the server. |
| `innerError.request-id` | Server-side request identifier. Include when raising a support case. |
| `innerError.client-request-id` | Client-supplied request identifier from the `client-request-id` header. |

For the full error response schema, see [Microsoft Graph error responses and resource types](https://learn.microsoft.com/en-us/graph/errors).

---

## HTTP Status Codes

### 2xx — Success

| Code | Name | Common Cause |
|------|------|-------------|
| 200 | OK | Successful GET, PATCH, or POST (action) |
| 201 | Created | Resource created via POST |
| 202 | Accepted | Long-running operation accepted; poll the operation URL |
| 204 | No Content | Successful DELETE; no response body |

---

### 4xx — Client Errors

| Code | Name | Common Cause |
|------|------|-------------|
| 400 | Bad Request | Malformed request body, invalid query parameter, unsupported OData syntax |
| 401 | Unauthorized | Missing, expired, or invalid Bearer token |
| 403 | Forbidden | Valid token but insufficient permissions; admin consent not granted |
| 404 | Not Found | Resource does not exist, or the caller lacks permission to see it |
| 405 | Method Not Allowed | HTTP method not supported on this endpoint |
| 409 | Conflict | Resource already exists; duplicate key |
| 410 | Gone | Resource has been permanently removed |
| 411 | Length Required | `Content-Length` header required |
| 412 | Precondition Failed | ETag conflict on conditional request |
| 413 | Request Entity Too Large | Request body exceeds size limit |
| 415 | Unsupported Media Type | `Content-Type` header missing or incorrect |
| 422 | Unprocessable Entity | Request is syntactically correct but semantically invalid |
| 423 | Locked | Resource is locked by another operation |
| 429 | Too Many Requests | Rate limit exceeded — throttling in effect |

---

### 5xx — Server Errors

| Code | Name | Common Cause |
|------|------|-------------|
| 500 | Internal Server Error | Unexpected server-side error; safe to retry with backoff |
| 501 | Not Implemented | Requested feature is not supported |
| 502 | Bad Gateway | Upstream service unavailable |
| 503 | Service Unavailable | Temporary overload or maintenance; retry with backoff |
| 504 | Gateway Timeout | Upstream service timed out |
| 507 | Insufficient Storage | Storage quota exceeded |

For the full HTTP status code reference, see [Microsoft Graph error responses](https://learn.microsoft.com/en-us/graph/errors#http-status-codes).

---

## Graph-Specific Error Codes

### Authentication and Authorisation

| Code | HTTP | Description |
|------|------|-------------|
| `InvalidAuthenticationToken` | 401 | Access token is missing, expired, malformed, or issued for the wrong resource |
| `CompactToken parsing failed` | 401 | Access token cannot be decoded |
| `AccessDenied` | 403 | Insufficient permissions; app registration lacks the required permission scope |
| `Authorization_RequestDenied` | 403 | Caller does not have permission to perform the operation on this resource |
| `ConsentRequired` | 403 | Admin consent has not been granted for the required permission |

---

### Resource Errors

| Code | HTTP | Description |
|------|------|-------------|
| `ResourceNotFound` | 404 | The requested resource does not exist |
| `ItemNotFound` | 404 | Item not found within a collection |
| `ObjectConflict` | 409 | Object with the same key already exists |
| `NameAlreadyExists` | 409 | Object name conflict |
| `RequestBodyRead` | 400 | Request body cannot be parsed |
| `BadRequest` | 400 | Generic invalid request |
| `InvalidArgument` | 400 | A provided argument value is invalid |

---

### Throttling and Service Availability

| Code | HTTP | Description |
|------|------|-------------|
| `TooManyRequests` | 429 | Throttled — check `Retry-After` header |
| `ServiceUnavailable` | 503 | Service temporarily unavailable — retry with backoff |
| `GatewayTimeout` | 504 | Request timed out at the gateway layer |
| `RequestTimeout` | 504 | Request took too long to complete |
| `Timeout` | 503 | Operation timeout |

For the full error code catalogue, see [Microsoft Graph error codes](https://learn.microsoft.com/en-us/graph/errors#error-codes).

---

## Throttling

Graph API enforces per-tenant, per-application, and per-resource throttle limits to ensure service stability.

### Throttling Response

When throttled, Graph returns `HTTP 429 Too Many Requests` with a `Retry-After` header:

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 60
Content-Type: application/json

{
  "error": {
    "code": "TooManyRequests",
    "message": "Too many requests, please retry later."
  }
}
```

### Throttling Limits

Limits vary by resource type, subscription SKU, and request type. Published limits include:

| Scope | Limit |
|-------|-------|
| Per app per tenant | 10,000 requests per 10 minutes |
| Per app across all tenants (multi-tenant apps) | 1,000,000 requests per 10 minutes |
| Per mailbox for Outlook operations | 10,000 API requests per 10 minutes |
| Per SharePoint site | 1,200 requests per minute |

These are illustrative figures. Actual limits are enforced by Graph and may change. Always implement retry logic based on the `Retry-After` header rather than hardcoded intervals. See [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling) for current published limits and throttling architecture.

---

### Retry Strategy

| Condition | Action |
|-----------|--------|
| `429 Too Many Requests` | Wait for the number of seconds specified in `Retry-After`, then retry |
| `503 Service Unavailable` | Apply exponential backoff starting at 1 second |
| `504 Gateway Timeout` | Retry after 2–5 seconds with exponential backoff |
| `500 Internal Server Error` | Retry up to 3 times with exponential backoff; escalate if persistent |

Exponential backoff formula: `min(base_delay * 2^attempt + jitter, max_delay)`. Use random jitter to avoid thundering herd when multiple workers are retrying simultaneously. For the full error handling guidance, see [Best practices for working with Microsoft Graph](https://learn.microsoft.com/en-us/graph/best-practices-concept#handling-expected-errors).

---

## Useful Request Headers

| Header | Purpose | Example |
|--------|---------|---------|
| `client-request-id` | Client-supplied GUID for correlating requests with responses | `client-request-id: {guid}` |
| `ConsistencyLevel` | Required for advanced queries using `$count`, `$search`, or `$filter` with `not`, `endsWith` | `ConsistencyLevel: eventual` |
| `Prefer: respond-async` | Request asynchronous processing for long-running operations | `Prefer: respond-async` |
| `If-Match` | Conditional request using ETag for optimistic concurrency | `If-Match: "{etag}"` |

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Graph error responses and resource types](https://learn.microsoft.com/en-us/graph/errors)
- [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)
- [Best practices for working with Microsoft Graph](https://learn.microsoft.com/en-us/graph/best-practices-concept)
- [Advanced query capabilities on Azure AD directory objects](https://learn.microsoft.com/en-us/graph/aad-advanced-queries)

### Related Documents

- [Endpoint Reference](endpoints.md)
- [Authentication Reference](authentication.md)
- [How To: Common Operations](../how-to/common-operations.md)
- [Explanation: Architecture](../explanation/architecture.md)
