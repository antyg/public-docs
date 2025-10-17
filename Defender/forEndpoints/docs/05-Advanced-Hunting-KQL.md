# Method 5: Advanced Hunting KQL Queries

## Overview

Advanced Hunting in Microsoft 365 Defender provides powerful KQL (Kusto Query Language) querying capabilities for analyzing MDE device data, onboarding status, health trends, and historical telemetry[^1](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview). This method excels at organization-wide analysis, trending, and compliance reporting.

## Capabilities

- ✅ Query 30 days of device telemetry history[^2](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)
- ✅ Identify devices that can be onboarded
- ✅ Analyze onboarding trends over time
- ✅ Find devices with stale agent versions
- ✅ Detect communication gaps
- ✅ Generate compliance reports
- ✅ Cross-reference multiple data sources
- ✅ Export results to Excel workbook (100,000 row display limit)[^3](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-results)

## Prerequisites

### Access Requirements

- Microsoft 365 Defender portal: https://security.microsoft.com
- Advanced Hunting permissions[^4](https://learn.microsoft.com/en-us/defender-xdr/m365d-permissions):
  - Security Administrator
  - Security Operator
  - Security Reader
  - Custom role with Advanced Hunting read permissions

### KQL Knowledge

- Basic understanding of Kusto Query Language[^5](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)
- Familiarity with table schemas[^6](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)
- Knowledge of filtering, summarizing, and joining operators[^7](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric)

## Accessing Advanced Hunting

### Navigation Path

1. Navigate to https://security.microsoft.com
2. Click **Hunting** in left navigation
3. Click **Advanced hunting**

**Direct URL:** https://security.microsoft.com/v2/advanced-hunting

## Primary Tables for MDE Validation

### DeviceInfo Table

Contains device inventory information including onboarding status[^8](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table).

#### Schema

- `Timestamp` - Last date and time recorded for the device
- `DeviceId` - Unique identifier for the device
- `DeviceName` - Fully qualified domain name of the device
- `OnboardingStatus` - Indicates device's onboarding status to Microsoft Defender For Endpoint
- `IsAzureADJoined` - Whether device is joined to Microsoft Entra ID
- `JoinType` - Device's Microsoft Entra ID join type
- `OSPlatform` - Specific operating system platform
- `OSVersion` - OS version
- `OSBuild` - OS build version
- `AadDeviceId` - Unique identifier in Microsoft Entra ID
- `ClientVersion` - Version of endpoint agent/sensor

### DeviceNetworkInfo Table

Contains network configuration and connectivity data[^9](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicenetworkinfo-table).

#### Schema

- `Timestamp` - Date and time when the event was recorded
- `DeviceId` - Unique identifier for the device in the service
- `DeviceName` - Fully qualified domain name (FQDN) of the device
- `NetworkAdapterType` - Network adapter type
- `IPAddresses` - JSON array containing all the IP addresses assigned to the adapter
- `MacAddress` - MAC address of the network adapter
- `ConnectedNetworks` - Networks that the adapter is connected to

### DeviceProcessEvents Table

Contains process execution telemetry (indicates active reporting)[^10](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table).

#### Schema

- `Timestamp` - Date and time of event recording
- `DeviceId` - Unique device identifier
- `DeviceName` - Fully qualified domain name of device
- `FileName` - Name of file action was applied to
- `ProcessCommandLine` - Command line used to create process
- `AccountName` - User account name

## KQL Query Examples

### 1. Find Devices That Can Be Onboarded

This query uses the DeviceInfo table[^11](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table) with time filtering[^12](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language), record aggregation[^13](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language), field projection[^14](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language), and sorting operations[^15](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric):

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where OnboardingStatus == "Can be onboarded"
| where isempty(MergedToDeviceId)
| project
    DeviceName,
    OSPlatform,
    OSVersion,
    OnboardingStatus,
    IsAzureADJoined,
    JoinType,
    DeviceCategory,
    LastSeen = Timestamp
| sort by DeviceName asc
```

**Purpose:** Identify discoverable devices not yet onboarded to MDE

#### Output Columns

- Device Name
- OS Platform (Windows 10, Windows 11, etc.)
- OS Version
- Onboarding Status
- Azure AD Join Status
- Join Type
- Device Category
- Last Seen Time

### 2. Check Onboarding Status for Specific Devices

This query demonstrates variable declaration[^16](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language) and case-insensitive filtering[^17](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language):

```kql
let DeviceList = dynamic(["WORKSTATION01", "WORKSTATION02", "SERVER01"]);
DeviceInfo
| where Timestamp > ago(7d)
| summarize arg_max(Timestamp, *) by DeviceId
| where DeviceName in~ (DeviceList)
| project
    DeviceName,
    OnboardingStatus,
    OSPlatform,
    OSVersion,
    LastSeen = Timestamp,
    IsAzureADJoined,
    DeviceCategory
| sort by DeviceName asc
```

**Purpose:** Validate onboarding status for a specific list of devices

**Usage:** Replace `DeviceList` array with your target hostnames[^18](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)

### 3. Devices Onboarded in Last 30 Days

```kql
DeviceInfo
| where Timestamp > ago(30d)
| where OnboardingStatus == "Onboarded"
| summarize FirstOnboarded = min(Timestamp), LastSeen = max(Timestamp) by DeviceId, DeviceName
| where FirstOnboarded > ago(30d)
| project
    DeviceName,
    FirstOnboarded,
    LastSeen,
    DaysSinceOnboarding = datetime_diff('day', now(), FirstOnboarded)
| sort by FirstOnboarded desc
```

**Purpose:** Track recent onboarding activity for compliance reporting

### 4. Onboarded Devices with No Recent Telemetry

This query uses the DeviceProcessEvents table[^19](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table) for activity tracking[^20](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language) and left-outer joins[^21](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language) to identify silent devices:

```kql
let OnboardedDevices = DeviceInfo
    | where Timestamp > ago(1d)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where OnboardingStatus == "Onboarded"
    | project DeviceId, DeviceName, OnboardingStatus;
let ActiveDevices = DeviceProcessEvents
    | where Timestamp > ago(7d)
    | summarize LastActivity = max(Timestamp) by DeviceId;
OnboardedDevices
| join kind=leftouter ActiveDevices on DeviceId
| where isnull(LastActivity)
| project
    DeviceName,
    OnboardingStatus,
    DaysSinceLastActivity = "7+"
| sort by DeviceName asc
```

**Purpose:** Identify onboarded devices not actively reporting telemetry

**Action:** Investigate devices for SENSE service issues or decommissioning

### 5. Onboarding Status Distribution

This query demonstrates aggregation by status[^22](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language) and percentage calculations[^23](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric):

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where isempty(MergedToDeviceId)
| summarize Count = count() by OnboardingStatus
| project
    OnboardingStatus,
    DeviceCount = Count,
    Percentage = round(Count * 100.0 / toscalar(
        DeviceInfo
        | where Timestamp > ago(1d)
        | summarize arg_max(Timestamp, *) by DeviceId
        | where isempty(MergedToDeviceId)
        | count
    ), 2)
| sort by DeviceCount desc
```

**Purpose:** Organizational onboarding compliance overview

#### Output

```text
OnboardingStatus       DeviceCount  Percentage
--------------------  -----------  ----------
Onboarded             4,523        92.15
Can be onboarded      325          6.62
Unsupported           60           1.22
```

### 6. Devices by OS Platform and Onboarding Status

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where isempty(MergedToDeviceId)
| summarize DeviceCount = count() by OSPlatform, OnboardingStatus
| project OSPlatform, OnboardingStatus, DeviceCount
| sort by OSPlatform asc, OnboardingStatus asc
```

**Purpose:** Identify OS-specific onboarding gaps

**Use Case:** Prioritize onboarding efforts by platform

### 7. Devices with Outdated MDE Agent Versions

This query extracts agent version information from the AdditionalFields JSON[^24](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table):

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where OnboardingStatus == "Onboarded"
| extend AgentVersion = tostring(parse_json(AdditionalFields).SenseVersion)
| where isnotempty(AgentVersion)
| summarize DeviceCount = count() by AgentVersion
| sort by AgentVersion asc
```

**Purpose:** Identify devices requiring agent updates

**Note:** MDE agent versions can indicate deployment health

### 8. Time-Series Onboarding Trend (Last 30 Days)

```kql
DeviceInfo
| where Timestamp > ago(30d)
| summarize arg_max(Timestamp, *) by DeviceId, bin(Timestamp, 1d)
| summarize
    OnboardedCount = countif(OnboardingStatus == "Onboarded"),
    CanBeOnboardedCount = countif(OnboardingStatus == "Can be onboarded"),
    UnsupportedCount = countif(OnboardingStatus == "Unsupported")
    by Date = bin(Timestamp, 1d)
| project
    Date,
    OnboardedCount,
    CanBeOnboardedCount,
    UnsupportedCount
| sort by Date asc
```

**Purpose:** Visualize onboarding progress over time

#### Output Time-series data for charting onboarding trends

### 9. Devices Not Seen in Last 7 Days (Potentially Decommissioned)

```kql
let RecentDevices = DeviceInfo
    | where Timestamp > ago(7d)
    | summarize by DeviceId;
DeviceInfo
| where Timestamp between (ago(30d) .. ago(7d))
| summarize arg_max(Timestamp, *) by DeviceId
| where OnboardingStatus == "Onboarded"
| where DeviceId !in (RecentDevices)
| project
    DeviceName,
    OSPlatform,
    LastSeen = Timestamp,
    DaysSinceLastSeen = datetime_diff('day', now(), Timestamp)
| where DaysSinceLastSeen >= 7
| sort by LastSeen desc
```

**Purpose:** Identify stale devices for potential offboarding

**Action:** Verify decommissioning status and clean up inventory

### 10. Cross-Reference with Azure AD Device Data (via Invoke)

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where OnboardingStatus == "Can be onboarded"
| invoke SeenBy()
| project
    DeviceName,
    OnboardingStatus,
    DeviceCategory,
    SeenBy
| mv-expand SeenBy
| project DeviceName, OnboardingStatus, DeviceCategory, ObservingDevice = tostring(SeenBy)
```

**Purpose:** Identify which onboarded devices discovered the unmanaged device

**Use Case:** Network segmentation analysis

## Validation Workflows

### Validate CSV Device List Against MDE

#### Query

```kql
let DeviceList = dynamic(["WORKSTATION01", "WORKSTATION02", "SERVER01"]);
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| extend DeviceNameUpper = toupper(DeviceName)
| where DeviceNameUpper in~ (DeviceList)
| project
    DeviceName,
    OnboardingStatus,
    OSPlatform,
    LastSeen = Timestamp,
    IsAzureADJoined
| union (
    print DeviceName = DeviceList
    | mv-expand DeviceName
    | extend DeviceNameUpper = toupper(tostring(DeviceName))
    | join kind=leftanti (
        DeviceInfo
        | where Timestamp > ago(1d)
        | summarize arg_max(Timestamp, *) by DeviceId
        | extend DeviceNameUpper = toupper(DeviceName)
    ) on DeviceNameUpper
    | project
        DeviceName = tostring(DeviceName),
        OnboardingStatus = "Not Found in MDE",
        OSPlatform = "",
        LastSeen = datetime(null),
        IsAzureADJoined = bool(null)
)
| sort by DeviceName asc
```

**Purpose:** Match CSV list against MDE inventory with "Not Found" entries for missing devices

### Generate Weekly Onboarding Compliance Report

#### Query

```kql
let TotalDevices = toscalar(
    DeviceInfo
    | where Timestamp > ago(1d)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where isempty(MergedToDeviceId)
    | count
);
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where isempty(MergedToDeviceId)
| summarize
    OnboardedCount = countif(OnboardingStatus == "Onboarded"),
    CanBeOnboardedCount = countif(OnboardingStatus == "Can be onboarded"),
    UnsupportedCount = countif(OnboardingStatus == "Unsupported"),
    InsufficientInfoCount = countif(OnboardingStatus == "InsufficientInfo")
| extend
    TotalDevices = TotalDevices,
    OnboardedPercent = round(OnboardedCount * 100.0 / TotalDevices, 2),
    CanBeOnboardedPercent = round(CanBeOnboardedCount * 100.0 / TotalDevices, 2),
    ComplianceRate = round(OnboardedCount * 100.0 / (TotalDevices - UnsupportedCount), 2)
| project
    ReportDate = now(),
    TotalDevices,
    OnboardedCount,
    OnboardedPercent,
    CanBeOnboardedCount,
    CanBeOnboardedPercent,
    UnsupportedCount,
    InsufficientInfoCount,
    ComplianceRate
```

**Purpose:** Executive summary for weekly compliance reporting

#### Output Single-row summary with compliance metrics

## Exporting Results

### Export to CSV

1. Run query in Advanced Hunting
2. Click **Export** button (top right of results)
3. Choose **Export to CSV**
4. Save file locally

#### Limitations

- Maximum 100,000 rows per query display[^25](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-results)
- For larger datasets, use pagination or Graph API[^26](https://learn.microsoft.com/en-us/defender-xdr/api-advanced-hunting)

### Scheduled Query (via Logic Apps)

For recurring exports:

1. Create custom detection rule from query
2. Configure Logic App to run query on schedule
3. Export results to Azure Storage or email

See: [Microsoft Documentation - Automate Advanced Hunting][^27](https://learn.microsoft.com/en-us/defender-xdr/api-advanced-hunting)

## Troubleshooting

### Issue: Query Returns No Results for Known Devices

**Cause:** Device names case-sensitive or device not in DeviceInfo table

**Resolution:** Use case-insensitive operators and verify device onboarding status.

- Use `in~` operator (case-insensitive): `where DeviceName in~ (DeviceList)`[^28](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)
- Verify device onboarded recently (may take 5-30 minutes to appear)
- Check for typos in device names

### Issue: "Query timeout" Error

**Cause:** Query too complex or scanning too much data[^29](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)

**Resolution:** Reduce time range and add filters earlier in query pipeline.

- Reduce time range: `where Timestamp > ago(7d)` instead of `ago(30d)`
- Add filters earlier in query pipeline
- Use `summarize arg_max()` efficiently
- Limit result set with `| take 10000`

### Issue: OnboardingStatus Shows Unexpected Values

**Cause:** Schema changes or new enum values

**Resolution:** Check for UnknownFutureValue and add catch-all cases.

- Check for `UnknownFutureValue` or nulls
- Review Microsoft schema documentation
- Add catch-all case: `| extend Status = iff(isempty(OnboardingStatus), "Unknown", OnboardingStatus)`

### Issue: Devices Appear Duplicated

**Cause:** Multiple DeviceId entries or device renaming

**Resolution:** Filter merged devices and use arg_max for latest records.

- Filter merged devices: `where isempty(MergedToDeviceId)`
- Use `summarize arg_max(Timestamp, *) by DeviceId` to get latest record

## Output Interpretation

### Healthy Organization Profile

```text
OnboardingStatus       DeviceCount  Percentage
--------------------  -----------  ----------
Onboarded             4,950        95.2%
Can be onboarded      200          3.8%
Unsupported           50           1.0%
```

**Assessment:** >90% onboarded is healthy; prioritize "Can be onboarded" devices

### Problematic Organization Profile

```text
OnboardingStatus       DeviceCount  Percentage
--------------------  -----------  ----------
Onboarded             2,100        42.0%
Can be onboarded      2,850        57.0%
Unsupported           50           1.0%
```

**Assessment:** <50% onboarded indicates deployment issues; focus on bulk onboarding

## Integration with Other Methods

### Compare with Graph API Results

1. Export via [Method 2: Graph API](./02-Graph-API-Validation.md)
2. Run KQL query with same device list
3. Compare `OnboardingStatus` values
4. Identify discrepancies (sync delays, RBAC filtering)

### Validate Portal Exports

1. Export from [Method 3: Security Console](./03-Security-Console-Manual.md)
2. Cross-reference device names with KQL query
3. Check for devices present in KQL but missing from portal export

### Historical Trending

1. Use KQL to identify onboarding date
2. Compare with deployment schedule
3. Analyze delays between deployment and first telemetry

## KQL Learning Resources

- [KQL Quick Reference][^30](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- [Advanced Hunting Schema Tables][^31](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)
- [KQL Tutorial][^32](https://learn.microsoft.com/en-us/kusto/query/tutorials/learn-common-operators?view=microsoft-fabric)
- [Advanced Hunting Sample Queries][^33](https://github.com/microsoft/Microsoft-365-Defender-Hunting-Queries)

## Limitations

- ❌ Maximum 30 days historical data retention[^34](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)
- ❌ 100,000 row display limit per query[^35](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)
- ❌ Query timeout after 10 minutes[^36](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)
- ❌ Requires portal access (not scriptable without API)
- ⚠️ Data reflects telemetry received, not real-time device state
- ⚠️ New devices may take 5-30 minutes to appear

## Best Practices

1. ✅ Always use `summarize arg_max(Timestamp, *) by DeviceId` for latest device state[^37](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)
2. ✅ Filter merged devices: `where isempty(MergedToDeviceId)`[^38](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)
3. ✅ Use case-insensitive operators: `in~`, `=~`, `contains_cs`[^39](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)
4. ✅ Limit time range to minimum necessary (performance)[^40](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)
5. ✅ Test queries on small device lists before scaling
6. ✅ Save frequently used queries as "Shared queries" for team access
7. ✅ Document query purpose and expected output in comments
8. ✅ Schedule recurring exports for compliance reporting

## Query Performance Optimization

### Inefficient Query (Slow)

```kql
DeviceInfo
| where DeviceName contains "WORKSTATION"
| where Timestamp > ago(30d)
| summarize arg_max(Timestamp, *) by DeviceId
```

### Optimized Query (Fast)

```kql
DeviceInfo
| where Timestamp > ago(1d)  // Filter time FIRST
| summarize arg_max(Timestamp, *) by DeviceId  // Reduce rows early
| where DeviceName contains "WORKSTATION"  // Filter on fewer rows
```

**Key:** Apply time filters and aggregations early in query pipeline

## Next Steps

- For local validation: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
- For programmatic access: [Method 2: Graph API](./02-Graph-API-Validation.md)
- For deep diagnostics: [Method 6: Client Analyzer](./06-MDE-Client-Analyzer.md)
- For WMI-based queries: [Method 7: WMI/CIM](./07-WMI-CIM-Validation.md)

## References

[^1]: [Overview - Advanced hunting - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

[^2]: [Overview - Advanced hunting - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

[^3]: [Work with advanced hunting query results in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-results)

[^4]: [Manage access to Microsoft Defender XDR with Microsoft Entra global roles - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/m365d-permissions)

[^5]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^6]: [Data tables in the Microsoft Defender XDR advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)

[^7]: [Kusto Query Language (KQL) overview - Kusto | Microsoft Learn](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric)

[^8]: [DeviceInfo table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)

[^9]: [DeviceNetworkInfo table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicenetworkinfo-table)

[^10]: [DeviceProcessEvents table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table)

[^11]: [DeviceInfo table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)

[^12]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^13]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^14]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^15]: [Kusto Query Language (KQL) overview - Kusto | Microsoft Learn](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric)

[^16]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^17]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^18]: [Advanced hunting query best practices in Microsoft Defender XDR - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)

[^19]: [DeviceProcessEvents table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table)

[^20]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^21]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^22]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^23]: [Kusto Query Language (KQL) overview - Kusto | Microsoft Learn](https://learn.microsoft.com/en-us/kusto/query/?view=microsoft-fabric)

[^24]: [DeviceInfo table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)

[^25]: [Work with advanced hunting query results in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-results)

[^26]: [Microsoft Defender XDR advanced hunting API - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/api-advanced-hunting)

[^27]: [Microsoft Defender XDR advanced hunting API - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/api-advanced-hunting)

[^28]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^29]: [Use the advanced hunting query resource report - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)

[^30]: [KQL quick reference | Microsoft Learn](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)

[^31]: [Data tables in the Microsoft Defender XDR advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)

[^32]: [Tutorial: Learn common Kusto Query Language operators - Kusto | Microsoft Learn](https://learn.microsoft.com/en-us/kusto/query/tutorials/learn-common-operators?view=microsoft-fabric)

[^33]: [Microsoft 365 Defender Hunting Queries - GitHub Repository](https://github.com/microsoft/Microsoft-365-Defender-Hunting-Queries)

[^34]: [Overview - Advanced hunting - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

[^35]: [Use the advanced hunting query resource report - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)

[^36]: [Use the advanced hunting query resource report - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)

[^37]: [Advanced hunting query best practices in Microsoft Defender XDR - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)

[^38]: [DeviceInfo table in the advanced hunting schema - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)

[^39]: [Learn the advanced hunting query language in Microsoft Defender - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-language)

[^40]: [Advanced hunting query best practices in Microsoft Defender XDR - Microsoft Defender XDR | Microsoft Learn](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-best-practices)
