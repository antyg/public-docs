# Method 2: Graph API Validation

## Overview

[Microsoft Graph API][1] provides programmatic access to MDE device inventory, including onboarding status, health state, risk scores, and detailed device information. This method is ideal for centralized reporting, automation, and organization-wide validation.

## Capabilities

- ✅ Query all devices in organization
- ✅ Filter by onboarding status
- ✅ Check device health state
- ✅ Retrieve risk scores and exposure levels
- ✅ Export device inventory to CSV/JSON
- ✅ Identify devices that can be onboarded
- ✅ Historical device data access
- ✅ Automated compliance reporting

## Prerequisites

### Authentication Requirements

- [Azure AD App Registration][2] with API permissions:
  - `SecurityEvents.Read.All` (Application permission) **OR**
  - [`Machine.Read.All`][3] (Application permission) **OR**
  - [`Machine.ReadWrite.All`][3] (Delegated permission)
- Client Secret or Certificate for app authentication
- Tenant ID, Client ID, and Client Secret

### Role Requirements

- Security Administrator
- Security Reader
- Global Reader
- Or custom role with Microsoft Defender permissions

### PowerShell Module

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

Install the [Microsoft Graph PowerShell SDK][4] to interact with Microsoft Graph APIs.

## API Endpoints

### Primary Endpoint: List Machines

```text
GET https://api.security.microsoft.com/api/machines
```

The [machines API endpoint][3] provides access to device inventory data.

### Supported Query Parameters

- `$filter` - Filter results by property values[3]
- `$top` - Limit number of results (max 10,000) [3]
- `$skip` - Skip specified number of results[3]
- `$orderby` - Sort results by property[3]
- `$select` - Return specific properties only[3]

### Rate Limits

- **100 calls per minute**[3]
- **1,500 calls per hour**[3]
- Exceeding limits returns HTTP 429 (Too Many Requests) [3]

## Device Properties

The following properties are available from the [machine resource type][5] for validating device status:

### Key Properties for Validation

| Property           | Type     | Description               | Example Values                                |
| ------------------ | -------- | ------------------------- | --------------------------------------------- |
| `id`               | String   | Unique machine identifier | "1a2b3c4d5e6f..."                             |
| `computerDnsName`  | String   | Device FQDN               | "workstation01.contoso.com"                   |
| `osPlatform`       | String   | Operating system platform | "Windows10", "Windows11"                      |
| `osVersion`        | String   | OS version details        | "10.0.19045.3803"                             |
| `onboardingStatus` | String   | MDE onboarding state      | See values below                              |
| `healthStatus`     | String   | Device health state       | "Active", "Inactive", "ImpairedCommunication" |
| `riskScore`        | String   | Risk assessment           | "None", "Low", "Medium", "High"               |
| `exposureLevel`    | String   | Exposure level            | "None", "Low", "Medium", "High"               |
| `lastSeen`         | DateTime | Last communication time   | "2025-10-16T10:30:00Z"                        |
| `aadDeviceId`      | String   | Azure AD device ID        | "a1b2c3d4-..."                                |
| `machineTags`      | Array    | Custom tags               | ["Production", "Finance"]                     |
| `rbacGroupId`      | Int      | RBAC group identifier     | 123                                           |
| `version`          | String   | MDE agent version         | "10.8xxx"                                     |

### Onboarding Status Values

| Status               | Meaning                             | Action Required                  |
| -------------------- | ----------------------------------- | -------------------------------- |
| `Onboarded`          | Successfully onboarded to MDE       | None - Healthy state             |
| `CanBeOnboarded`     | Device discovered but not onboarded | Deploy onboarding package        |
| `Unsupported`        | OS not supported by MDE             | Upgrade OS or document exception |
| `InsufficientInfo`   | Cannot determine eligibility        | Investigate device registration  |
| `UnknownFutureValue` | Reserved for future values          | Contact Microsoft Support        |

### Health Status Values

| Status                              | Meaning                       | Typical Cause                    |
| ----------------------------------- | ----------------------------- | -------------------------------- |
| `Active`                            | Device communicating normally | Healthy state                    |
| `Inactive`                          | No communication >7 days      | Device offline or decommissioned |
| `ImpairedCommunication`             | Intermittent communication    | Network issues, service problems |
| `NoSensorData`                      | Sensor not reporting          | SENSE service stopped            |
| `NoSensorDataImpairedCommunication` | Combined issues               | Multiple problems                |

## Authentication Methods

### Method A: Using App Registration (Recommended for Automation)

#### Step 1: Create App Registration

1. Navigate to Azure Portal → Azure Active Directory → App registrations
2. Click "New registration"
3. Name: "MDE-DeviceInventory-Reader"
4. Click "Register"

#### Step 2: Configure API Permissions

1. Go to "API permissions"
2. Click "Add a permission" → "APIs my organization uses"
3. Search for "WindowsDefenderATP" → Select "Machine.Read.All"
4. Click "Add permissions"
5. Click "Grant admin consent"

#### Step 3: Create Client Secret

1. Go to "Certificates & secrets"
2. Click "New client secret"
3. Description: "MDE Validation Script"
4. Expires: 12 months (or per policy)
5. Click "Add"
6. **Copy secret value immediately** (not shown again)

#### Step 4: Collect Required Information

- Tenant ID: From Azure AD → Overview
- Client ID: From App registration → Overview
- Client Secret: From step 3

### Method B: Using Delegated Permissions (Interactive)

#### PowerShell

```powershell
Connect-MgGraph -Scopes "Machine.Read.All"
```

Use the [Connect-MgGraph cmdlet][6] for interactive authentication with delegated permissions.

## PowerShell Query Examples

### Connect with App Registration

```powershell
$TenantId = "your-tenant-id"
$ClientId = "your-client-id"
$ClientSecret = "your-client-secret"

$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://api.securitycenter.microsoft.com/.default"
    Client_Id     = $ClientId
    Client_Secret = $ClientSecret
}

$Response = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Body $Body

$Token = $Response.access_token
```

### Query All Devices

```powershell
$Headers = @{
    Authorization = "Bearer $Token"
}

$Uri = "https://api.security.microsoft.com/api/machines"
$Devices = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
$Devices.value | Select-Object computerDnsName, onboardingStatus, healthStatus
```

### Filter by Onboarding Status

```powershell
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=onboardingStatus eq 'Onboarded'"
$OnboardedDevices = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
```

### Filter by Health Status

```powershell
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=healthStatus eq 'Active'"
$ActiveDevices = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
```

### Find Devices That Can Be Onboarded

```powershell
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=onboardingStatus eq 'CanBeOnboarded'"
$CanOnboard = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
```

### Check Specific Device by Name

```powershell
$DeviceName = "WORKSTATION01"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=computerDnsName eq '$DeviceName'"
$Device = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
```

### Pagination for Large Results

```powershell
$AllDevices = @()
$Uri = "https://api.security.microsoft.com/api/machines?`$top=5000"

do {
    $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
    $AllDevices += $Response.value
    $Uri = $Response.'@odata.nextLink'
} while ($Uri)

Write-Host "Total devices: $($AllDevices.Count)"
```

## Advanced Filtering

### Multiple Conditions (AND)

```powershell
$Filter = "onboardingStatus eq 'Onboarded' and healthStatus eq 'Active'"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
```

### Multiple Conditions (OR)

```powershell
$Filter = "healthStatus eq 'Inactive' or healthStatus eq 'ImpairedCommunication'"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
```

### Last Seen Within Time Range

```powershell
$SevenDaysAgo = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")
$Filter = "lastSeen gt $SevenDaysAgo"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
```

### Risk Score Filtering

```powershell
$Filter = "riskScore eq 'High' and onboardingStatus eq 'Onboarded'"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
```

### OS Platform Filtering

```powershell
$Filter = "osPlatform eq 'Windows10'"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
```

## Validation Workflows

### Validate Devices from CSV

See script: [Export-MDEInventoryFromGraph.ps1](../scripts/Export-MDEInventoryFromGraph.ps1)

#### Usage

```powershell
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "your-tenant-id" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -CsvPath "C:\devices.csv" `
    -OutputPath "C:\mde-status-report.csv"
```

#### Expected Output (CSV)

```csv
Hostname,OnboardingStatus,HealthStatus,LastSeen,RiskScore,ExposureLevel,AgentVersion
WORKSTATION01,Onboarded,Active,2025-10-16T10:30:00Z,Low,None,10.8240
WORKSTATION02,CanBeOnboarded,,,,,
SERVER01,Onboarded,Inactive,2025-10-01T08:15:00Z,Medium,Low,10.8230
```

## Device Health API (Antivirus Details)

### Endpoint for AV Health Export

```text
GET https://api.securitycenter.microsoft.com/api/deviceavinfo
```

The [device antivirus health export API][7] provides detailed antivirus status information.

### Key AV Properties

| Property             | Description            | Values                                |
| -------------------- | ---------------------- | ------------------------------------- |
| `avMode`             | Antivirus mode         | 0=Active, 1=Passive, 2=Disabled, etc. |
| `avEngineVersion`    | Engine version         | "1.1.24010.10"                        |
| `avSignatureVersion` | Signature version      | "1.403.3117.0"                        |
| `avPlatformVersion`  | Platform version       | "4.18.24010.7"                        |
| `fullScanResult`     | Last full scan status  | 0=Success                             |
| `quickScanResult`    | Last quick scan status | 0=Success                             |

### Export AV Health Data

```powershell
$Uri = "https://api.securitycenter.microsoft.com/api/deviceavinfo"
$AVInfo = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
$AVInfo.value | Export-Csv "av-health-export.csv" -NoTypeInformation
```

## Troubleshooting

### Issue: 401 Unauthorized

**Cause:** Invalid token or expired credentials

**Resolution:** Verify token validity and re-authenticate if expired.

```powershell
Verify $Token is not null
Check token expiration: (ConvertFrom-Json ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Token.Split('.')[1])))).exp
Re-authenticate if expired
```

### Issue: 403 Forbidden

**Cause:** Insufficient API permissions

**Resolution:** Verify Machine.Read.All permission granted and admin consent provided.

1. Verify "Machine.Read.All" granted in App Registration
2. Ensure admin consent provided
3. Check user/app has Security Reader role minimum

### Issue: 429 Too Many Requests

**Cause:** Rate limit exceeded

**Resolution:** Implement retry logic with exponential backoff.

```powershell
Start-Sleep -Seconds 60  # Wait 1 minute
Implement retry logic with exponential backoff
Reduce query frequency
```

### Issue: Empty Results for Known Devices

**Cause:** RBAC filtering or device not in MDE inventory

**Resolution:** Verify device onboarding status and check RBAC group assignments.

1. Verify device actually onboarded in portal
2. Check RBAC group assignments
3. Use delegated permissions to test if RBAC-related

### Issue: OnboardingStatus = "InsufficientInfo"

**Cause:** Device metadata incomplete

**Resolution:** Check Azure AD registration and verify device appears in Endpoint Manager.

1. Check if device Azure AD registered
2. Verify device appears in Endpoint Manager
3. May require manual onboarding

## Output Interpretation

### Healthy Device

```json
{
  "id": "1a2b3c4d5e6f...",
  "computerDnsName": "WORKSTATION01.contoso.com",
  "osPlatform": "Windows11",
  "onboardingStatus": "Onboarded",
  "healthStatus": "Active",
  "riskScore": "None",
  "exposureLevel": "None",
  "lastSeen": "2025-10-16T10:30:00Z",
  "version": "10.8240.0"
}
```

### Device Requiring Attention

```json
{
  "id": "7g8h9i0j1k2l...",
  "computerDnsName": "SERVER05.contoso.com",
  "osPlatform": "WindowsServer2019",
  "onboardingStatus": "Onboarded",
  "healthStatus": "ImpairedCommunication",
  "riskScore": "High",
  "exposureLevel": "Medium",
  "lastSeen": "2025-10-10T14:22:00Z",
  "version": "10.8100.0"
}
```

**Actions:** Check network connectivity, update agent, review security alerts

### Discovered Unmanaged Device

```json
{
  "id": "m3n4o5p6q7r8...",
  "computerDnsName": "LAPTOP99.contoso.com",
  "osPlatform": "Windows10",
  "onboardingStatus": "CanBeOnboarded",
  "healthStatus": null,
  "riskScore": null,
  "exposureLevel": null,
  "lastSeen": null,
  "version": null
}
```

**Actions:** Deploy MDE onboarding package

## Integration with Other Methods

### Combine with PowerShell Validation

1. Query Graph API for device list
2. Use [Method 1: PowerShell](./01-PowerShell-Validation.md) for detailed local checks
3. Compare results for discrepancies

### Cross-Reference with Advanced Hunting

1. Export Graph API results
2. Run [Method 5: Advanced Hunting KQL](./05-Advanced-Hunting-KQL.md) query
3. Identify devices with telemetry gaps

### Escalate to Client Analyzer

For devices with `ImpairedCommunication` or `NoSensorData`:

- Use [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)

## Script Reference

All scripts for this method:

- [Export-MDEInventoryFromGraph.ps1](../scripts/Export-MDEInventoryFromGraph.ps1) - CSV validation with Graph API
- [Export-MDEInventoryFromGraph.ps1](../scripts/Export-MDEInventoryFromGraph.ps1) - Full inventory export (run without parameters)
- [Export-MDEInventoryFromGraph.ps1](../scripts/Export-MDEInventoryFromGraph.ps1) - Discover unmanaged devices (use -OnlyUnmanaged switch)

## Limitations

- ❌ Requires app registration and permissions setup
- ❌ Rate limits restrict rapid bulk queries
- ❌ Cannot validate local service status directly
- ❌ RBAC may filter results based on user/app permissions
- ⚠️ Slight delay between device state change and API reflection (minutes)

## Best Practices

1. ✅ Use app registration (not delegated) for automation
2. ✅ Implement pagination for organizations >5,000 devices
3. ✅ Cache token (valid 60 minutes) to avoid re-authentication
4. ✅ Implement retry logic with exponential backoff
5. ✅ Monitor rate limits and throttle requests accordingly
6. ✅ Schedule exports during off-peak hours
7. ✅ Rotate client secrets every 6-12 months
8. ✅ Use `$select` to retrieve only needed properties (performance)
9. ✅ Log all API calls for compliance audit trail

## Compliance Reporting Examples

### Generate Weekly Onboarding Status Report

```powershell
$Report = @()
$AllDevices = # ... (query all devices)

$Report += [PSCustomObject]@{
    TotalDevices = $AllDevices.Count
    Onboarded = ($AllDevices | Where-Object onboardingStatus -eq 'Onboarded').Count
    CanBeOnboarded = ($AllDevices | Where-Object onboardingStatus -eq 'CanBeOnboarded').Count
    Unsupported = ($AllDevices | Where-Object onboardingStatus -eq 'Unsupported').Count
    Active = ($AllDevices | Where-Object healthStatus -eq 'Active').Count
    Inactive = ($AllDevices | Where-Object healthStatus -eq 'Inactive').Count
}

$Report | Export-Csv "MDE-Weekly-Report-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
```

### Identify High-Risk Onboarded Devices

```powershell
$Filter = "onboardingStatus eq 'Onboarded' and riskScore eq 'High'"
$Uri = "https://api.security.microsoft.com/api/machines?`$filter=$Filter"
$HighRisk = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers

$HighRisk.value | Select-Object computerDnsName, riskScore, exposureLevel, lastSeen |
    Export-Csv "high-risk-devices.csv" -NoTypeInformation
```

## Next Steps

- For manual verification: [Method 3: Security Console](./03-Security-Console-Manual.md)
- For local troubleshooting: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
- For historical analysis: [Method 5: Advanced Hunting KQL](./05-Advanced-Hunting-KQL.md)

## References

1. [Microsoft Graph Security API Overview](https://learn.microsoft.com/en-us/graph/security-concept-overview)
2. [Microsoft Defender for Endpoint App Registration](https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-webapp)
3. [Microsoft Defender for Endpoint Machines API](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines)
4. [Microsoft Graph PowerShell SDK Installation](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
5. [Microsoft Defender for Endpoint Machine Resource](https://learn.microsoft.com/en-us/defender-endpoint/api/machine)
6. [Connect-MgGraph PowerShell Cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/connect-mggraph?view=graph-powershell-1.0)
7. [Microsoft Defender for Endpoint Device Health Export API](https://learn.microsoft.com/en-us/defender-endpoint/api/device-health-export-antivirus-health-report-api)

[1]: https://learn.microsoft.com/en-us/graph/security-concept-overview
[2]: https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-webapp
[3]: https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
[4]: https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
[5]: https://learn.microsoft.com/en-us/defender-endpoint/api/machine
[6]: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/connect-mggraph?view=graph-powershell-1.0
[7]: https://learn.microsoft.com/en-us/defender-endpoint/api/device-health-export-antivirus-health-report-api
