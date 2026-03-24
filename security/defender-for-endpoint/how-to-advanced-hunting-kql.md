---
title: "How to Use Advanced Hunting KQL for MDE Deployment Verification"
status: "published"
last_updated: "2026-03-08"
audience: "Security operations analysts and engineers using KQL to verify MDE deployment and hunt threats"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# How to Use Advanced Hunting KQL for MDE Deployment Verification

---

## When to Use This Guide

Advanced Hunting is the right tool when you need:

- Historical analysis across 30 days of endpoint telemetry
- Organisation-wide deployment status queries without API setup
- Time-series onboarding trends for compliance reporting
- Detection of devices that have gone silent after onboarding
- Cross-referencing onboarding state with OS platform and agent version

Advanced Hunting operates on data already ingested by MDE. It cannot report on devices that have never communicated with the service, and it cannot confirm local registry or service state. For local device validation, see the [PowerShell tutorial](tutorial-powershell-validation.md).

---

## Prerequisites

- Access to [https://security.microsoft.com](https://security.microsoft.com)
- One of the following roles ([permissions reference](https://learn.microsoft.com/en-us/defender-endpoint/basic-permissions)):
  - Security Administrator
  - Security Operator
  - Security Reader with Advanced Hunting permissions
- Basic familiarity with [Kusto Query Language (KQL)](https://learn.microsoft.com/en-us/kusto/query/)

---

## Accessing Advanced Hunting

1. Navigate to [https://security.microsoft.com](https://security.microsoft.com)
2. Click **Hunting** in the left navigation
3. Click **Advanced hunting**

Direct URL: [https://security.microsoft.com/v2/advanced-hunting](https://security.microsoft.com/v2/advanced-hunting)

Results can be exported to Excel (display limit: 100,000 rows per query). For programmatic access to the same data, use the [Graph API tutorial](tutorial-graph-api-validation.md).

---

## Primary Tables for MDE Validation

### DeviceInfo

The [DeviceInfo table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table) is the primary source for device inventory and onboarding status. Key fields:

| Field | Description |
|-------|-------------|
| `Timestamp` | When the record was ingested |
| `DeviceId` | Unique device identifier |
| `DeviceName` | Device FQDN |
| `OnboardingStatus` | `Onboarded`, `Can be onboarded`, `Unsupported` |
| `OSPlatform` | Operating system platform |
| `OSVersion` | Full OS version string |
| `ClientVersion` | MDE sensor/agent version |
| `IsAzureADJoined` | Whether device is Entra ID joined |

### DeviceProcessEvents

The [DeviceProcessEvents table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table) contains process execution telemetry. Use it to confirm a device is actively reporting data — a device that shows as onboarded in DeviceInfo but has no recent process events may have a stopped SENSE service.

### DeviceNetworkInfo

The [DeviceNetworkInfo table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicenetworkinfo-table) contains network adapter configuration and IP address assignments. Use it to correlate device names with IP addresses when investigating portal export data.

---

## Deployment Verification Queries

### 1 — Find Devices That Can Be Onboarded

Identifies discoverable devices not yet enrolled in MDE. These are the highest-priority targets for deployment teams.

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

The `arg_max(Timestamp, *)` pattern selects the most recent record per device, avoiding duplicate rows from multiple daily snapshots. The `isempty(MergedToDeviceId)` filter excludes devices that have been merged into another entry ([DeviceInfo schema reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)).

---

### 2 — Check Onboarding Status for Specific Devices

Validates a named list of devices. Replace the array contents with your target hostnames.

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

The `in~` operator performs case-insensitive matching. Use a 7-day window rather than 1 day to catch devices that communicate infrequently.

---

### 3 — Organisation-Wide Onboarding Compliance Summary

Calculates the distribution of onboarding statuses across all discovered devices.

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where isempty(MergedToDeviceId)
| summarize Count = count() by OnboardingStatus
| extend Percentage = round(Count * 100.0 / toscalar(
    DeviceInfo
    | where Timestamp > ago(1d)
    | summarize arg_max(Timestamp, *) by DeviceId
    | where isempty(MergedToDeviceId)
    | count
), 1)
| sort by Count desc
```

Expected output for a healthy deployment:

```text
OnboardingStatus     Count   Percentage
Onboarded            4523    92.2
Can be onboarded      325     6.6
Unsupported            60     1.2
```

---

### 4 — Onboarded Devices with No Recent Telemetry

Identifies onboarded devices that have stopped generating process telemetry — a strong signal that the SENSE service has stopped or the device has been decommissioned.

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
| project DeviceName, OnboardingStatus, InactiveDays = "7+"
| sort by DeviceName asc
```

For each device returned, check the SENSE service status using the [registry and service reference](reference-registry-service-reference.md) and consider running the [MDE Client Analyzer](reference-client-analyzer.md).

---

### 5 — 30-Day Onboarding Trend

Tracks onboarding progress over time. Useful for compliance reporting and demonstrating deployment velocity to stakeholders.

```kql
DeviceInfo
| where Timestamp > ago(30d)
| summarize arg_max(Timestamp, *) by DeviceId, bin(Timestamp, 1d)
| summarize
    OnboardedCount       = countif(OnboardingStatus == "Onboarded"),
    CanBeOnboardedCount  = countif(OnboardingStatus == "Can be onboarded"),
    UnsupportedCount     = countif(OnboardingStatus == "Unsupported")
    by Date = bin(Timestamp, 1d)
| project Date, OnboardedCount, CanBeOnboardedCount, UnsupportedCount
| sort by Date asc
```

Run this query and click **Chart** in the results to visualise the trend. Export to Excel for inclusion in compliance reports.

---

### 6 — Onboarding Status by OS Platform

Identifies OS-specific onboarding gaps — for example, whether Windows Server devices have lower onboarding rates than Windows 10/11 workstations.

```kql
DeviceInfo
| where Timestamp > ago(1d)
| summarize arg_max(Timestamp, *) by DeviceId
| where isempty(MergedToDeviceId)
| summarize DeviceCount = count() by OSPlatform, OnboardingStatus
| sort by OSPlatform asc, OnboardingStatus asc
```

---

### 7 — Devices with Outdated MDE Agent Versions

Identifies the spread of MDE agent versions across onboarded devices. Large version disparity may indicate update delivery issues.

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

---

### 8 — Devices Not Seen in the Last 7 Days

Finds devices that were active within the past 30 days but have not reported in the past 7 days — potentially decommissioned or experiencing connectivity issues.

```kql
let RecentDevices = DeviceInfo
    | where Timestamp > ago(7d)
    | summarize by DeviceId;
DeviceInfo
| where Timestamp between (ago(30d) .. ago(7d))
| summarize arg_max(Timestamp, *) by DeviceId
| where OnboardingStatus == "Onboarded"
| join kind=leftanti RecentDevices on DeviceId
| project DeviceName, OSPlatform, OSVersion, LastSeen = Timestamp
| sort by LastSeen asc
```

---

### 9 — Cross-Reference with Network Discovery (SeenBy)

Identifies which onboarded devices discovered a given unmanaged device via network discovery. This uses the `SeenBy()` MDE-specific invocation function, which is not standard KQL — it is available only within the Advanced Hunting context of Microsoft Defender XDR.

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

**Purpose:** For each unmanaged device, identify which enrolled MDE devices observed it on the network.

**Use case:** Network segmentation analysis — if an unmanaged device is only observed by devices in a particular subnet or VLAN, prioritise onboarding within that segment first.

---

## Compliance Reporting Workflow

For monthly compliance reports:

1. Run query 3 (compliance summary) — capture percentage onboarded
2. Run query 5 (30-day trend) — export chart as evidence of deployment progress
3. Run query 6 (by OS platform) — identify any platform-specific gaps requiring remediation
4. Run query 4 (silent devices) — confirm no onboarded devices have lost connectivity
5. Export all results to Excel and attach to the compliance record

### Validate a Device List and Identify Missing Devices

When validating a specific list of hostnames (e.g., from an asset register or CSV export), this query returns MDE status for matched devices and produces explicit "Not Found in MDE" rows for devices absent from the portal — eliminating the need to diff two separate exports manually.

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
        DeviceName        = tostring(DeviceName),
        OnboardingStatus  = "Not Found in MDE",
        OSPlatform        = "",
        LastSeen          = datetime(null),
        IsAzureADJoined   = bool(null)
)
| sort by DeviceName asc
```

Replace the `DeviceList` array with hostnames from your asset register. Devices present in MDE appear with their actual `OnboardingStatus`; devices not found in MDE appear with `OnboardingStatus = "Not Found in MDE"`.

### Weekly Compliance Report with ComplianceRate

This query produces an executive-ready compliance summary that excludes unsupported devices from the compliance denominator — giving a meaningful rate that reflects actionable deployment coverage rather than total device inventory.

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
    OnboardedCount        = countif(OnboardingStatus == "Onboarded"),
    CanBeOnboardedCount   = countif(OnboardingStatus == "Can be onboarded"),
    UnsupportedCount      = countif(OnboardingStatus == "Unsupported"),
    InsufficientInfoCount = countif(OnboardingStatus == "InsufficientInfo")
| extend
    TotalDevices          = TotalDevices,
    OnboardedPercent      = round(OnboardedCount * 100.0 / TotalDevices, 2),
    CanBeOnboardedPercent = round(CanBeOnboardedCount * 100.0 / TotalDevices, 2),
    ComplianceRate        = round(OnboardedCount * 100.0 / (TotalDevices - UnsupportedCount), 2)
| project
    ReportDate            = now(),
    TotalDevices,
    OnboardedCount,
    OnboardedPercent,
    CanBeOnboardedCount,
    CanBeOnboardedPercent,
    UnsupportedCount,
    InsufficientInfoCount,
    ComplianceRate
```

`ComplianceRate` divides onboarded devices by `TotalDevices - UnsupportedCount`, which is the correct denominator for reporting — unsupported devices cannot be onboarded and should not reduce the compliance score. `InsufficientInfoCount` is surfaced separately for triage. Schedule this query weekly and compare `ComplianceRate` across reporting periods to demonstrate deployment velocity.

---

## Query Performance

The KQL engine evaluates operators in the order they are written. Placing filters late in the pipeline means earlier operators process far more rows than necessary. Time filters and aggregations should always appear as early as possible.

### Inefficient (slow)

```kql
DeviceInfo
| where DeviceName contains "WORKSTATION"
| where Timestamp > ago(30d)
| summarize arg_max(Timestamp, *) by DeviceId
```

This scans the full `DeviceInfo` table for all time before applying the time filter, then filters on device name across the full 30-day dataset.

### Optimised (fast)

```kql
DeviceInfo
| where Timestamp > ago(1d)          // time filter first — reduces scan immediately
| summarize arg_max(Timestamp, *) by DeviceId  // aggregate early — reduces row count
| where DeviceName contains "WORKSTATION"       // name filter on far fewer rows
```

**Key principle:** Apply time filters and `summarize arg_max()` as early as possible. Every operator after them works on a smaller dataset. This matters most when the query is approaching the 10-minute timeout ([Advanced Hunting limits](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-limits)).

---

## Related Resources

- [Advanced Hunting overview](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)
- [Advanced Hunting schema tables](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)
- [DeviceInfo table reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)
- [DeviceProcessEvents table reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table)
- [KQL quick reference](https://learn.microsoft.com/en-us/kusto/query/kql-quick-reference)
- [ACSC Essential Eight — patch operating systems maturity model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [Validation methods overview](explanation-validation-methods-overview.md)
- [Azure Workbook for MDE](config/README.md)
- [Microsoft 365 Defender Hunting Queries — community sample library](https://github.com/microsoft/Microsoft-365-Defender-Hunting-Queries)
