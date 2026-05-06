---
title: "Tutorial: Querying MDE Device Inventory via Microsoft Graph Security API"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers and developers automating MDE inventory and compliance reporting"
document_type: "tutorial"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Tutorial: Querying MDE Device Inventory via Microsoft Graph Security API

---

## What You Will Accomplish

By the end of this tutorial you will have:

1. Created an Azure AD App Registration with the correct API permissions for MDE device queries
2. Authenticated using OAuth 2.0 client credentials flow
3. Queried the MDE machines API to retrieve device onboarding and health status
4. Exported a tenant-wide device inventory using `Export-MDEInventoryFromGraph.ps1`
5. Filtered for devices that can be onboarded (discovered but not yet protected)

The [Microsoft Graph Security API](https://learn.microsoft.com/en-us/graph/api/resources/security-api-overview) provides the authoritative cloud-side view of MDE device state. It is the data source for the Microsoft 365 Defender portal's device inventory.

---

## Prerequisites

- Azure AD tenant with Global Administrator or Application Administrator access (to create app registration and grant admin consent)
- PowerShell 5.1 or 7+
- Security Reader role or higher in Microsoft 365 Defender
- `Export-MDEInventoryFromGraph.ps1` from the [scripts folder](../scripts/README.md)
- Outbound HTTPS to `login.microsoftonline.com` and `api.security.microsoft.com`

---

## Step 1 — Create the App Registration

The machines API requires an Azure AD App Registration with application-level permissions ([API permissions guide](https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-nativeapp)).

1. Navigate to [Azure Portal](https://portal.azure.com) > **Azure Active Directory** > **App registrations**
2. Click **New registration**
3. Name: `MDE-DeviceInventory-Reader`
4. Account type: **Accounts in this organisational directory only**
5. Click **Register**

### Add API Permissions

1. In the app registration, go to **API permissions**
2. Click **Add a permission** > **APIs my organisation uses**
3. Search for `WindowsDefenderATP`
4. Select **Application permissions** > `Machine.Read.All`
5. Click **Add permissions**
6. Click **Grant admin consent for [your organisation]** — this step requires Global Administrator

### Create a Client Secret

1. Go to **Certificates & secrets** > **New client secret**
2. Description: `MDE Validation`
3. Expiry: 12 months (set a calendar reminder to rotate)
4. Click **Add**
5. Copy the **Value** immediately — it is not shown again

### Collect the Three Required Values

From the app registration **Overview** page:

| Field | Where to Find It |
|-------|-----------------|
| Tenant ID | Azure AD > Overview > Tenant ID |
| Client ID | App registration > Overview > Application (client) ID |
| Client Secret | Certificates & secrets (value copied above) |

---

## Step 2 — Test Authentication

Verify the app registration is correctly configured before running any inventory queries:

```powershell
$tenantId     = 'your-tenant-id'
$clientId     = 'your-client-id'
$clientSecret = 'your-client-secret'

$tokenBody = @{
    grant_type    = 'client_credentials'
    scope         = 'https://api.securitycenter.microsoft.com/.default'
    client_id     = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Body $tokenBody

# Confirm token received
$tokenResponse.access_token.Substring(0, 20) + '...'
```

A truncated token string confirms successful authentication. An error at this step indicates an incorrect tenant ID, client ID, client secret, or missing admin consent.

---

## Step 3 — Query the Machines API

The [machines API endpoint](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines) at `https://api.security.microsoft.com/api/machines` returns all devices visible to the authenticated app:

```powershell
$headers = @{
    Authorization = "Bearer $($tokenResponse.access_token)"
    'Content-Type' = 'application/json'
}

# Retrieve first page (up to 10,000 devices)
$response = Invoke-RestMethod -Method Get `
    -Uri 'https://api.security.microsoft.com/api/machines?$top=100' `
    -Headers $headers

$response.value | Select-Object computerDnsName, onboardingStatus, healthStatus, riskScore, lastSeen
```

### Key Device Properties

The [machine resource type](https://learn.microsoft.com/en-us/defender-endpoint/api/machine) exposes the following fields relevant to deployment validation:

| Property | Description | Example Values |
|----------|-------------|----------------|
| `computerDnsName` | Device FQDN | `workstation01.contoso.com` |
| `onboardingStatus` | MDE enrolment state | `Onboarded`, `CanBeOnboarded`, `Unsupported` |
| `healthStatus` | Cloud communication state | `Active`, `Inactive`, `ImpairedCommunication` |
| `riskScore` | Calculated risk level | `None`, `Low`, `Medium`, `High` |
| `lastSeen` | Last cloud communication | ISO 8601 UTC timestamp |
| `osPlatform` | Operating system | `Windows10`, `Windows11` |
| `version` | MDE agent version | `10.8xxx` |
| `aadDeviceId` | Entra ID device ID | GUID |

### Onboarding Status Values

| Status | Meaning | Action |
|--------|---------|--------|
| `Onboarded` | Successfully enrolled | None — healthy state |
| `CanBeOnboarded` | Discovered but not enrolled | Deploy onboarding package |
| `Unsupported` | OS incompatible with MDE | Upgrade OS or document exception |
| `InsufficientInfo` | Cannot determine eligibility | Investigate device registration |

### Health Status Values

| Status | Meaning | Typical Cause |
|--------|---------|--------------|
| `Active` | Communicating normally | Healthy |
| `Inactive` | No communication for more than 7 days | Device offline or decommissioned |
| `ImpairedCommunication` | Intermittent communication | Network or service issue |
| `NoSensorData` | Sensor not reporting | SENSE service stopped |

---

## Step 4 — Handle Pagination for Large Tenants

The API returns a maximum of 10,000 records per page. For tenants with more than 10,000 devices, use the `@odata.nextLink` field ([OData pagination](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines)):

```powershell
$allDevices = [System.Collections.Generic.List[object]]::new()
$uri = 'https://api.security.microsoft.com/api/machines'

do {
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $allDevices.AddRange($response.value)
    $uri = $response.'@odata.nextLink'
} while ($uri)

Write-Host "Total devices retrieved: $($allDevices.Count)"
```

The API enforces rate limits of [100 calls per minute and 1,500 calls per hour](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines). The pagination loop above will encounter these limits only for tenants with more than 1 million devices.

> **Rate limits**: 100 requests per minute, 1,500 requests per hour. Exceeding either limit returns HTTP 429 (Too Many Requests). Implement retry logic with exponential back-off and honour the `Retry-After` response header.

---

## Step 5 — Export Tenant-Wide Inventory with the Script

`Export-MDEInventoryFromGraph.ps1` wraps authentication, pagination, and export into a single command. It supports three operation modes:

```powershell
# Full tenant inventory export
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId     $tenantId `
    -ClientId     $clientId `
    -ClientSecret $clientSecret `
    -OutputPath   '.\mde-inventory.csv'

# Validate a CSV device list against tenant inventory
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId     $tenantId `
    -ClientId     $clientId `
    -ClientSecret $clientSecret `
    -CsvPath      '.\devices.csv' `
    -OutputPath   '.\mde-comparison.csv'

# Export only devices that can be onboarded (unprotected, discoverable)
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId     $tenantId `
    -ClientId     $clientId `
    -ClientSecret $clientSecret `
    -OnlyUnmanaged `
    -OutputPath   '.\unprotected-devices.csv'
```

The `-OnlyUnmanaged` flag returns only devices with `onboardingStatus = CanBeOnboarded` — the priority list for deployment teams.

---

## Step 6 — Filter and Analyse Results

Once you have the inventory CSV, analyse it in PowerShell:

```powershell
$inventory = Import-Csv '.\mde-inventory.csv'

# Compliance summary
# Exclude Unsupported devices from the denominator — they cannot be onboarded
# and including them artificially depresses the compliance rate.
$total       = $inventory.Count
$unsupported = ($inventory | Where-Object OnboardingStatus -eq 'Unsupported').Count
$eligible    = $total - $unsupported
$onboarded   = ($inventory | Where-Object OnboardingStatus -eq 'Onboarded').Count
$compliance  = if ($eligible -gt 0) { [math]::Round(($onboarded / $eligible) * 100, 1) } else { 0 }
Write-Host "Onboarding compliance: $onboarded / $eligible eligible devices ($compliance%)"
Write-Host "  ($unsupported unsupported devices excluded from denominator)"

# Devices inactive for more than 7 days
$inventory |
    Where-Object { $_.HealthStatus -eq 'Inactive' } |
    Sort-Object LastSeen |
    Select-Object ComputerDnsName, OSPlatform, LastSeen, RiskScore |
    Format-Table -AutoSize

# High-risk onboarded devices
$inventory |
    Where-Object { $_.OnboardingStatus -eq 'Onboarded' -and $_.RiskScore -eq 'High' } |
    Select-Object ComputerDnsName, ExposureLevel, LastSeen
```

---

## Alternative Endpoint: deviceavinfo

The [device antivirus health export API](https://learn.microsoft.com/en-us/defender-endpoint/api/device-health-export-antivirus-health-report-api) provides antivirus-specific status information that is not available through the machines endpoint. Use it when you need to validate AV engine versions, signature currency, or scan results across the fleet.

**Endpoint:**

```text
GET https://api.securitycenter.microsoft.com/api/deviceavinfo
```

### Key AV Properties

| Property | Description | Example Values |
|----------|-------------|----------------|
| `avMode` | Antivirus operating mode | `0` = Active, `1` = Passive, `2` = Disabled |
| `avEngineVersion` | Defender engine version | `1.1.24010.10` |
| `avSignatureVersion` | Signature definition version | `1.403.3117.0` |
| `avPlatformVersion` | Platform version | `4.18.24010.7` |
| `fullScanResult` | Last full scan result code | `0` = Success |
| `quickScanResult` | Last quick scan result code | `0` = Success |

### Export AV Health Data

```powershell
$uri = 'https://api.securitycenter.microsoft.com/api/deviceavinfo'
$avInfo = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
$avInfo.value | Export-Csv 'av-health-export.csv' -NoTypeInformation
```

The same authentication token (obtained in Step 2) is valid for `api.securitycenter.microsoft.com` and `api.security.microsoft.com` — both endpoints accept the same client credentials scope.

---

## Advanced OData Filters

The machines API supports OData `$filter` expressions directly in the query URI, which avoids the need to retrieve the full inventory before filtering. The following patterns cover the most common validation scenarios.

### AND — Multiple Conditions

```powershell
$filter = "onboardingStatus eq 'Onboarded' and healthStatus eq 'Active'"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
```

### OR — Alternative Values

```powershell
$filter = "healthStatus eq 'Inactive' or healthStatus eq 'ImpairedCommunication'"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
```

### Last Seen Within a Time Range

```powershell
$sevenDaysAgo = (Get-Date).AddDays(-7).ToString('yyyy-MM-ddTHH:mm:ssZ')
$filter = "lastSeen gt $sevenDaysAgo"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
```

### Risk Score Filtering

```powershell
$filter = "riskScore eq 'High' and onboardingStatus eq 'Onboarded'"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
```

### OS Platform Filtering

```powershell
$filter = "osPlatform eq 'Windows10'"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
```

Combine OS platform with health state to target a specific fleet segment — for example, all inactive Windows 10 devices:

```powershell
$filter = "osPlatform eq 'Windows10' and healthStatus eq 'Inactive'"
$uri = "https://api.security.microsoft.com/api/machines?`$filter=$filter"
```

See the [OData query reference](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines) for the full set of filterable properties.

---

## Troubleshooting

**Authentication fails with "invalid_client" or 401**

- Verify Tenant ID, Client ID, and Client Secret are copied correctly with no leading/trailing spaces
- Confirm admin consent was granted for `Machine.Read.All`
- Check the client secret has not expired (Azure Portal > App registration > Certificates & secrets)

**Query returns empty `value` array**

- Confirm the app has been granted `Machine.Read.All` at the application level (not delegated)
- Verify at least one device is onboarded to MDE in the tenant
- Check that the authenticated user/app has access to the relevant RBAC device groups in MDE

**Rate limit errors (HTTP 429)**

Add a retry loop with exponential back-off. The `Retry-After` response header specifies the wait time in seconds.

---

## Best Practices

- **Cache the access token.** OAuth 2.0 tokens issued by `login.microsoftonline.com` are valid for 60 minutes. Re-use the same token for all requests within a session rather than requesting a new one per query.
- **Use `$select` to limit response size.** Specifying only the properties you need (e.g., `?$select=computerDnsName,onboardingStatus,healthStatus`) reduces payload size and improves query performance, particularly for large tenants.
- **Rotate client secrets on a schedule.** Client secrets used for automation should be rotated every 6–12 months. Set a calendar reminder at creation time. Secrets that expire silently break scheduled exports.
- **Implement retry logic with exponential back-off.** The API enforces 100 requests per minute and 1,500 per hour. When HTTP 429 is returned, honour the `Retry-After` response header value rather than using a fixed sleep interval.
- **Prefer `$filter` over client-side filtering.** Server-side OData filters (e.g., `?$filter=healthStatus eq 'Inactive'`) reduce the volume of data transferred and avoid retrieving records you will discard.
- **Log all API calls for audit purposes.** Record the timestamp, query URI, result count, and any errors for each invocation. This satisfies compliance requirements and aids troubleshooting.

---

## Related Resources

- [MDE machines API reference](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines)
- [Machine resource type properties](https://learn.microsoft.com/en-us/defender-endpoint/api/machine)
- [Create app registration for MDE API access](https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-nativeapp)
- [Microsoft Graph Security API overview](https://learn.microsoft.com/en-us/graph/api/resources/security-api-overview)
- [MDE API rate limits](https://learn.microsoft.com/en-us/defender-endpoint/api/apis-intro)
- [Validation methods overview](explanation-validation-methods-overview.md)
- [Advanced Hunting KQL how-to](how-to-advanced-hunting-kql.md)
