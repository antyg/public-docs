---
title: "Validation Methods Overview — Choosing the Right Approach"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers and analysts selecting a validation approach for MDE deployment verification"
document_type: "explanation"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Validation Methods Overview — Choosing the Right Approach

---

## Why Multiple Validation Methods Exist

Microsoft Defender for Endpoint exposes its deployment state through several independent data planes: the Windows registry, Windows services, the Defender module, WMI/CIM, the Microsoft Graph Security API, the Microsoft 365 Defender portal, and Advanced Hunting telemetry. Each plane has different scope, access requirements, and latency characteristics.

No single method answers every question. A device can appear onboarded in the registry but not yet appear in the portal (replication lag). A device can show healthy via Graph API but have a stopped SENSE service locally. Understanding which plane to query — and why — is the foundation of reliable MDE deployment validation.

---

## The Seven Validation Methods

| Method | Scope | Auth Required | Speed | Primary Use Case |
|--------|-------|---------------|-------|-----------------|
| [PowerShell (local/remote)](tutorial-powershell-validation.md) | Single device / bulk CSV | Windows auth (WinRM) | Fast | Domain environments, bulk validation |
| [Microsoft Graph Security API](tutorial-graph-api-validation.md) | Organisation-wide | App registration (OAuth 2.0) | Medium | Centralised reporting, automation |
| [Security Console (portal)](how-to-console-validation.md) | Organisation-wide | Portal role | Manual | Ad-hoc checks, visual verification |
| [Registry and Service](reference-registry-service-reference.md) | Single device | Local/remote admin | Fast | Troubleshooting, definitive local state |
| [Advanced Hunting KQL](how-to-advanced-hunting-kql.md) | Organisation-wide | Portal + AH permissions | Fast (query) | Historical analysis, compliance reporting |
| [MDE Client Analyzer](reference-client-analyzer.md) | Single device | Local admin | Slow | Deep diagnostics, Microsoft Support cases |
| [WMI/CIM](reference-wmi-cim-reference.md) | Single device / bulk | Windows auth (DCOM/WSMan) | Fast | Legacy systems, WMI-aware tooling |

---

## Method Comparison: What Each Can and Cannot Confirm

### What PowerShell (`Get-MpComputerStatus`) Confirms

- Antivirus engine status (`AMRunningMode`: Normal, Passive, EDR Block Mode)
- Real-time protection state
- Tamper protection status and source (ATP, Intune, Local)
- Signature version and age
- Service health (SENSE, DiagTrack)

PowerShell via the [Defender module](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus) is the fastest programmatic method for Windows 10/11 and Server 2016+. It does not directly expose the `OnboardingState` registry value — pair it with a registry check for definitive onboarding confirmation.

### What the Graph Security API Confirms

- `onboardingStatus`: Onboarded, CanBeOnboarded, Unsupported, InsufficientInfo
- `healthStatus`: Active, Inactive, ImpairedCommunication, NoSensorData
- Risk score and exposure level
- Last seen timestamp from the cloud perspective
- Agent version (`version` field)

The [machines API](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines) reflects the cloud-side view. It is authoritative for organisation-wide compliance reporting and the source of truth for devices that appear in the Microsoft 365 Defender portal. Synchronisation from local state to cloud typically takes 5–30 minutes.

### What the Registry Confirms

- `OnboardingState = 1` is the most definitive local proof that an onboarding package has been applied and the device has registered with MDE ([troubleshooting reference](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding))
- `OrgId` — confirms which tenant the device is onboarded to
- `SenseId` — unique device identifier for correlation with portal records

Registry validation requires local or remote administrator access. It cannot confirm cloud-side replication or whether the device is actively communicating.

### What Advanced Hunting Confirms

- Historical telemetry across the last 30 days ([Advanced Hunting overview](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview))
- Devices not actively reporting (onboarded but silent)
- Onboarding trends over time
- OS platform distribution and agent version spread

Advanced Hunting operates on data already ingested by the MDE cloud service. It cannot report on devices that have never communicated with the service.

### What the MDE Client Analyzer Confirms

- Root cause of connectivity failures (DNS, TCP, HTTPS, certificate chain)
- Proxy configuration issues (including authentication requirements not supported by SENSE)
- Detailed service configuration and event log analysis
- Performance bottlenecks (with `-h` and `-a` flags)

The [Client Analyzer](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer) (`MDEClientAnalyzer.cmd`) is Microsoft's official diagnostic tool. Use it when other methods identify a problem but do not pinpoint the cause. Not suitable for bulk validation — it performs deep inspection of a single device and produces an HTML report.

---

## Decision Matrix

| Scenario | Recommended Method | Reason |
|----------|--------------------|--------|
| Validate a single device is onboarded | Registry check + PowerShell | Fastest definitive answer; no cloud dependency |
| Validate 100+ devices from a CSV list | PowerShell ([`Get-MDEStatus.ps1`](../scripts/Get-MDEStatus.ps1)) | Bulk parallel execution; covers fallback chain (CIM → WMI → Registry → Service) |
| Generate a tenant-wide compliance report | Graph Security API | Authoritative cloud view; supports pagination for large tenants |
| Find devices visible on network but not onboarded | Security Console or Advanced Hunting KQL | Device Discovery surfaces `CanBeOnboarded` devices; KQL enables time-based analysis |
| Diagnose why a device shows misconfigured in portal | MDE Client Analyzer | Provides connectivity, proxy, certificate, and service diagnostics |
| Historical onboarding trend for the past 30 days | Advanced Hunting KQL | Only method with time-series historical data |
| Query Defender status on a Windows 7 / Server 2008 R2 device | WMI/CIM | Defender module (`Get-MpComputerStatus`) requires Windows 10/Server 2016+ |
| Manual ad-hoc check without scripting | Security Console (portal) | No setup; immediate visual confirmation |

---

## Validation Confidence Hierarchy

When methods return conflicting results, resolve conflicts using this priority order:

1. **Registry `OnboardingState`** — most authoritative for local onboarding state; directly reflects the onboarding package application
2. **SENSE service status** — confirms the sensor is operational; a stopped SENSE service means no telemetry flows regardless of registry state
3. **Graph API `onboardingStatus`** — authoritative for cloud-side state; may lag local state by up to 30 minutes after onboarding
4. **`Get-MpComputerStatus`** — confirms Defender engine health; does not directly expose onboarding state
5. **Security Console** — reflects Graph API data with additional processing lag; suitable for confirmation, not first-line diagnosis
6. **Advanced Hunting `DeviceInfo`** — reflects ingested telemetry; devices silent for 7+ days may show stale data

---

## Prerequisite Summary

| Method | Minimum Requirements |
|--------|---------------------|
| PowerShell (local) | Administrator on local device; Windows 10/11 or Server 2016+ |
| PowerShell (remote) | WinRM enabled on target; administrator credentials; port 5985 or 5986 |
| Graph Security API | Azure AD App Registration; `Machine.Read.All` permission; admin consent granted |
| Security Console | Browser; Security Reader role minimum |
| Advanced Hunting | Security Reader + Advanced Hunting permissions |
| Registry (local) | Administrator on local device |
| Registry (remote) | WinRM enabled; administrator credentials |
| MDE Client Analyzer | Local administrator; 1 GB free disk; PsExec for connectivity tests |
| WMI/CIM (local) | Standard user (read-only WMI); PowerShell 3.0+ |
| WMI/CIM (remote) | Administrator credentials; DCOM (port 135) or WSMan (port 5985) |

---

## Troubleshooting Decision Tree

Use this flow when a device is not appearing in the Microsoft 365 Defender portal or its status is unclear:

```text
Device Not Showing in Portal?
├─ Check Installed → Use Registry/Service method
│  ├─ Not Installed → Deploy MDE agent
│  └─ Installed → Continue
├─ Check Onboarded → Use PowerShell method
│  ├─ Not Onboarded → Run onboarding script
│  └─ Onboarded → Continue
└─ Check Functional → Use MDE Client Analyzer
   ├─ Service Issues → Restart SENSE service
   ├─ Connectivity Issues → Check firewall/proxy
   └─ Event Log Errors → Review SENSE operational log
```

### Common Issues and Resolutions

| Symptom | Recommended Method | Resolution |
|---------|--------------------|------------|
| Device not in portal | Security Console (Method 3) | Verify onboarding script executed |
| `onboardingStatus = "CanBeOnboarded"` | Graph Security API | Deploy onboarding package |
| SENSE service stopped | Registry and Service | Restart service; check dependencies |
| Cloud connectivity failure | MDE Client Analyzer | Review proxy and firewall settings |
| Outdated signatures | PowerShell | Run `Update-MpSignature`; validate cloud connectivity |
| High event log error count | Registry and Service | Run MDE Client Analyzer for full diagnostics |

### CSV Input Format

All bulk validation scripts accept a CSV file with the following structure:

```csv
Hostname,Notes
WORKSTATION01,Finance Department
WORKSTATION02,HR Department
SERVER01,Domain Controller
```

Requirements:

- Header row must include a `Hostname` column (case-insensitive)
- Optional `Notes` column for reference information
- One device per row
- Supports both FQDN and NetBIOS names

---

## Related Resources

- [MDE troubleshooting onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- [Advanced Hunting schema tables](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)
- [MDE machines API reference](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines)
- [MDE Client Analyzer overview](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer)
- [Defender module — Get-MpComputerStatus](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus)
- [ACSC Essential Eight — patch operating systems](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
