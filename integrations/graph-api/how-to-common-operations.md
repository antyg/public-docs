---
title: "How To: Common Microsoft Graph API Operations"
status: "draft"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "how-to"
domain: "integrations"
platform: "Microsoft Graph API"
---

# How To: Common Microsoft Graph API Operations

## Scope

This guide covers the practical steps for common Microsoft Graph API operations: querying users and groups, managing devices, retrieving security data, accessing mail, and using batch requests. Examples use both PowerShell (Graph SDK) and direct REST calls.

This guide assumes authentication is already established. For authentication setup, see [how-to/authenticate.md](authenticate.md).

---

## Query Users

### Get a Single User

```powershell
# PowerShell SDK
Get-MgUser -UserId 'user@contoso.com' -Select 'displayName,mail,accountEnabled,userPrincipalName'
```

```python
# Python — REST
import requests
headers = {"Authorization": f"Bearer {access_token}"}
r = requests.get(
    "https://graph.microsoft.com/v1.0/users/user@contoso.com",
    params={"$select": "displayName,mail,accountEnabled,userPrincipalName"},
    headers=headers
)
print(r.json())
```

### List All Users (with Paging)

```powershell
# PowerShell SDK — automatically handles paging
Get-MgUser -All -Select 'displayName,userPrincipalName,accountEnabled' -ConsistencyLevel eventual
```

```python
# Python — manual paging loop
url = "https://graph.microsoft.com/v1.0/users"
params = {"$select": "displayName,userPrincipalName,accountEnabled", "$top": "100"}
all_users = []

while url:
    r = requests.get(url, params=params, headers=headers)
    data = r.json()
    all_users.extend(data.get("value", []))
    url = data.get("@odata.nextLink")
    params = {}  # nextLink already contains query parameters

print(f"Total users: {len(all_users)}")
```

### Filter Users

```powershell
# PowerShell SDK — filter by account state
Get-MgUser -Filter "accountEnabled eq false" -ConsistencyLevel eventual -CountVariable total
Write-Host "Disabled accounts: $total"

# Filter by department
Get-MgUser -Filter "department eq 'Engineering'" -Select 'displayName,mail'
```

For the full list of supported query parameters, see [List users — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/user-list).

---

## Query Groups

### List All Groups

```powershell
# PowerShell SDK
Get-MgGroup -All -Select 'displayName,id,groupTypes,mailEnabled,securityEnabled'
```

### Get Group Members

```powershell
# PowerShell SDK
Get-MgGroupMember -GroupId 'group-object-id' -All
```

### Check if User is in Group

```powershell
# PowerShell SDK — check transitive membership
$params = @{
    memberId = 'user-object-id'
}
Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/groups/group-object-id/checkMemberObjects" `
    -Body (@{ ids = @('group-object-id') } | ConvertTo-Json)
```

For the full list of group query operations, see [List groups — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/group-list).

---

## Query Intune Managed Devices

### List All Managed Devices

```powershell
# PowerShell SDK
Get-MgDeviceManagementManagedDevice -All `
    -Select 'deviceName,operatingSystem,complianceState,lastSyncDateTime,userDisplayName'
```

```python
# Python — REST
url = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
params = {
    "$select": "deviceName,operatingSystem,complianceState,lastSyncDateTime",
    "$top": "100"
}
devices = []
while url:
    r = requests.get(url, params=params, headers=headers)
    data = r.json()
    devices.extend(data.get("value", []))
    url = data.get("@odata.nextLink")
    params = {}
```

### Filter by Compliance State

```powershell
# Get non-compliant devices
Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'noncompliant'" -All `
    -Select 'deviceName,userDisplayName,lastSyncDateTime'
```

For the full managed device schema, see [List managed devices — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/intune-devices-manageddevice-list).

---

## Query Security Data

### List Security Alerts

```powershell
# PowerShell SDK — requires SecurityAlert.Read.All
Invoke-MgGraphRequest -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/security/alerts_v2?`$filter=severity eq 'high'&`$top=50"
```

```python
# Python — REST
r = requests.get(
    "https://graph.microsoft.com/v1.0/security/alerts_v2",
    params={"$filter": "severity eq 'high'", "$top": "50"},
    headers=headers
)
alerts = r.json().get("value", [])
```

### Retrieve Sign-In Logs

```powershell
# PowerShell SDK — requires AuditLog.Read.All
Get-MgAuditLogSignIn -Filter "createdDateTime ge 2026-03-01" -Top 100 `
    -Select 'userDisplayName,userPrincipalName,appDisplayName,status,createdDateTime'
```

For the full sign-in log schema and supported filters, see [List signIns — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/signin-list).

---

## Access Mail

### Read Messages from a Mailbox

```powershell
# Delegated — reads the signed-in user's mail
Get-MgUserMessage -UserId 'me' -Top 10 `
    -Select 'subject,from,receivedDateTime,isRead'

# Application — reads a specific user's mail (requires Mail.Read application permission)
Get-MgUserMessage -UserId 'user@contoso.com' -Top 10 `
    -Select 'subject,from,receivedDateTime'
```

### Send Mail

```powershell
# PowerShell SDK — send a message as a user
$message = @{
    message = @{
        subject = "Test message from Graph API"
        body = @{
            contentType = "Text"
            content     = "This message was sent via Microsoft Graph API."
        }
        toRecipients = @(
            @{ emailAddress = @{ address = "recipient@contoso.com" } }
        )
    }
}

Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/sender@contoso.com/sendMail" `
    -Body ($message | ConvertTo-Json -Depth 10)
```

For additional message options (attachments, CC/BCC, importance), see [Send mail — Microsoft Graph API](https://learn.microsoft.com/en-us/graph/api/user-sendmail).

---

## Use $select to Reduce Response Size

Always request only the properties you need. Graph returns all non-null properties by default, which increases response size and latency.

```powershell
# Without $select — returns 50+ properties per user
Get-MgUser -UserId 'user@contoso.com'

# With $select — returns only the 4 requested properties
Get-MgUser -UserId 'user@contoso.com' -Select 'displayName,mail,accountEnabled,jobTitle'
```

See [Use query parameters — `$select`](https://learn.microsoft.com/en-us/graph/query-parameters#select-parameter) for supported properties per resource type.

---

## Use $filter for Server-Side Filtering

Filter on the server rather than downloading all records and filtering client-side.

```powershell
# Users created in the last 7 days
$cutoff = (Get-Date).AddDays(-7).ToString("o")
Get-MgUser -Filter "createdDateTime ge $cutoff" -ConsistencyLevel eventual

# Devices last synced more than 90 days ago
$cutoff = (Get-Date).AddDays(-90).ToString("o")
Get-MgDeviceManagementManagedDevice -Filter "lastSyncDateTime le $cutoff" -All `
    -Select 'deviceName,userDisplayName,lastSyncDateTime'
```

Note: Some filter operators require the `ConsistencyLevel: eventual` header and `$count=true`. See [Advanced query capabilities](https://learn.microsoft.com/en-us/graph/aad-advanced-queries) for supported operators per resource.

---

## Batch Multiple Requests

JSON batching combines up to 20 requests into a single HTTP call. This is useful when you need to query multiple resources simultaneously and want to reduce round trips.

```powershell
$batchBody = @{
    requests = @(
        @{
            id     = "1"
            method = "GET"
            url    = "/users?`$select=displayName,mail&`$top=5"
        },
        @{
            id     = "2"
            method = "GET"
            url    = "/groups?`$select=displayName,id&`$top=5"
        },
        @{
            id     = "3"
            method = "GET"
            url    = "/deviceManagement/managedDevices?`$select=deviceName,complianceState&`$top=5"
        }
    )
} | ConvertTo-Json -Depth 10

$batchResult = Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/`$batch" `
    -Body $batchBody

# Access each response by ID
$users   = ($batchResult.responses | Where-Object { $_.id -eq '1' }).body.value
$groups  = ($batchResult.responses | Where-Object { $_.id -eq '2' }).body.value
$devices = ($batchResult.responses | Where-Object { $_.id -eq '3' }).body.value
```

Batch requests execute independently — a failure in one request does not fail the entire batch. Check the `status` property of each response. For the full batch schema and dependency syntax, see [Combine multiple requests using JSON batching](https://learn.microsoft.com/en-us/graph/json-batching).

---

## Handle Throttling

Graph API throttles requests when rate limits are exceeded (HTTP 429). Always implement retry logic.

```powershell
function Invoke-GraphWithRetry {
    param(
        [string]$Uri,
        [int]$MaxRetries = 3
    )

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            return Invoke-MgGraphRequest -Method GET -Uri $Uri
        }
        catch {
            $status = $_.Exception.Response.StatusCode.value__
            if ($status -eq 429) {
                $retryAfter = [int]($_.Exception.Response.Headers['Retry-After'] ?? 60)
                Write-Warning "Throttled. Retrying in $retryAfter seconds (attempt $attempt of $MaxRetries)..."
                Start-Sleep -Seconds $retryAfter
            }
            elseif ($status -in 500, 503, 504) {
                $backoff = [Math]::Pow(2, $attempt)
                Write-Warning "Server error $status. Retrying in $backoff seconds..."
                Start-Sleep -Seconds $backoff
            }
            else {
                throw
            }
        }
    }
    throw "Request failed after $MaxRetries attempts."
}
```

For per-service rate limits and best practices, see the [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling).

---

## Error Handling Pattern

```powershell
try {
    $user = Get-MgUser -UserId 'nonexistent@contoso.com' -ErrorAction Stop
}
catch {
    $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
    $code    = $errorDetail.error.code
    $message = $errorDetail.error.message

    switch ($code) {
        'ResourceNotFound'           { Write-Warning "User not found." }
        'Authorization_RequestDenied' { Write-Error "Insufficient permissions: $message" }
        'TooManyRequests'             { Write-Warning "Throttled — implement retry logic." }
        default                       { Write-Error "Graph error [$code]: $message" }
    }
}
```

For full error code reference, see [error-codes.md](../reference/error-codes.md).

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Graph API overview](https://learn.microsoft.com/en-us/graph/overview)
- [Use query parameters to customise responses](https://learn.microsoft.com/en-us/graph/query-parameters)
- [Combine multiple requests using JSON batching](https://learn.microsoft.com/en-us/graph/json-batching)
- [Microsoft Graph throttling guidance](https://learn.microsoft.com/en-us/graph/throttling)
- [Paging Microsoft Graph data in your app](https://learn.microsoft.com/en-us/graph/paging)
- [Best practices for working with Microsoft Graph](https://learn.microsoft.com/en-us/graph/best-practices-concept)

### API References

- [List users](https://learn.microsoft.com/en-us/graph/api/user-list)
- [List groups](https://learn.microsoft.com/en-us/graph/api/group-list)
- [List managed devices](https://learn.microsoft.com/en-us/graph/api/intune-devices-manageddevice-list)
- [List signIns](https://learn.microsoft.com/en-us/graph/api/signin-list)
- [Send mail](https://learn.microsoft.com/en-us/graph/api/user-sendmail)

### Related Documents

- [Endpoint Reference](../reference/endpoints.md)
- [Authentication Reference](../reference/authentication.md)
- [Error Codes Reference](../reference/error-codes.md)
- [How To: Authenticate](authenticate.md)
- [Explanation: Architecture](../explanation/architecture.md)
