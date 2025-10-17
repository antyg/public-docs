# Microsoft Defender for Endpoint (MDE) Deployment Validation Methods

## Executive Summary

This documentation provides comprehensive methods to validate Microsoft Defender for Endpoint deployment status on remote hosts. Use these methods to determine if workstations are properly installed, successfully onboarded, and fully functional.

## Validation States

Each validation method checks for these device states:

- ✅ **Installed**: MDE components are present on the system
- ✅ **Onboarded**: Device successfully registered with MDE cloud service
- ✅ **Functional**: All MDE services running and reporting correctly
- ⚠️ **Can Be Onboarded**: Device discovered but not yet onboarded
- ❌ **Unsupported**: Operating system incompatible with MDE
- ❌ **Insufficient Info**: Unable to determine status

## Validation Methods Overview

| Method                                                   | Scope                   | Authentication     | Execution Time | Best For              |
| -------------------------------------------------------- | ----------------------- | ------------------ | -------------- | --------------------- |
| [PowerShell Local/Remote](./01-PowerShell-Validation.md) | Single/Multiple Devices | Windows Auth       | Fast           | Domain environments   |
| [Graph API](./02-Graph-API-Validation.md)                | Organization-wide       | App Registration   | Medium         | Centralized reporting |
| [Security Console](./03-Security-Console-Manual.md)      | Organization-wide       | Admin Portal       | Manual         | Ad-hoc checks         |
| [Registry/Service](./04-Registry-Service-Validation.md)  | Single Device           | Local/Remote Admin | Fast           | Troubleshooting       |
| [Advanced Hunting KQL](./05-Advanced-Hunting-KQL.md)     | Organization-wide       | Portal Access      | Fast           | Historic analysis     |
| [MDE Client Analyzer](./06-MDE-Client-Analyzer.md)       | Single Device           | Local Admin        | Slow           | Deep diagnostics      |
| [WMI/CIM Queries](./07-WMI-CIM-Validation.md)            | Single/Multiple Devices | Windows Auth       | Fast           | Legacy systems        |

## Quick Start

### For Single Device Validation

1. Use [Method 4: Registry/Service Validation](./04-Registry-Service-Validation.md)
2. If issues found, use [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)

### For Bulk Device Validation (CSV Input)

1. Use [PowerShell Script: Bulk Device Validation](../scripts/Get-MDEStatus.ps1)
2. Review output report for devices requiring attention

### For Organization-Wide Status

1. Use [Method 3: Security Console Export](./03-Security-Console-Manual.md)
2. Or use [Method 2: Graph API Export](./02-Graph-API-Validation.md)

## Documentation Structure

### Validation Methods

- [Method 1: PowerShell Local/Remote Validation](./01-PowerShell-Validation.md)
- [Method 2: Graph API Validation](./02-Graph-API-Validation.md)
- [Method 3: Security Console Manual Checks](./03-Security-Console-Manual.md)
- [Method 4: Registry/Service Validation](./04-Registry-Service-Validation.md)
- [Method 5: Advanced Hunting KQL Queries](./05-Advanced-Hunting-KQL.md)
- [Method 6: MDE Client Analyzer Tool](./06-MDE-Client-Analyzer.md)
- [Method 7: WMI/CIM Query Validation](./07-WMI-CIM-Validation.md)

### Scripts

All production-ready scripts referenced in this documentation:

- [Script: Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1) - Intelligent multi-method validation with automatic fallback
- [Script: Export-MDEInventoryFromGraph.ps1](../scripts/Export-MDEInventoryFromGraph.ps1) - Graph API tenant-wide export
- [Script: Test-MDEConnectivity.ps1](../scripts/Test-MDEConnectivity.ps1) - Network connectivity validation

### CSV Input Format

All scripts accept CSV files with this structure:

```csv
Hostname,Notes
WORKSTATION01,Finance Department
WORKSTATION02,HR Department
SERVER01,Domain Controller
```

#### Requirements

- Header row must include `Hostname` column (case-insensitive)
- Optional `Notes` column for reference information
- One device per row
- Supports FQDN or NetBIOS names

## Validation Criteria

### Installed Status

- ✅ SENSE service exists[1]
- ✅ Registry keys present at `HKLM\SOFTWARE\Microsoft\Windows Advanced Threat Protection` [1]
- ✅ Defender cmdlets available

### Onboarded Status

- ✅ `OnboardingState` registry value = 1[1]
- ✅ Device appears in Security Console[2]
- ✅ Device accessible via Graph API with `onboardingStatus = "Onboarded"` [3]
- ✅ Recent telemetry in DeviceInfo table[4]

### Functional Status

- ✅ SENSE service running[1]
- ✅ DiagTrack service running (recommended for optimal reporting)[1]
- ✅ No critical errors in SENSE event log[1]
- ✅ Cloud connectivity successful
- ✅ `healthStatus = "Active"` in Graph API[3]
- ✅ Recent signature updates
- ✅ Real-time protection enabled

## Troubleshooting Decision Tree

```text
Device Not Showing in Portal?
├─ Check Installed → Use Method 4 (Registry/Service)
│  ├─ Not Installed → Deploy MDE agent
│  └─ Installed → Continue
├─ Check Onboarded → Use Method 1 (PowerShell)
│  ├─ Not Onboarded → Run onboarding script
│  └─ Onboarded → Continue
└─ Check Functional → Use Method 6 (Client Analyzer)
   ├─ Service Issues → Restart SENSE service
   ├─ Connectivity Issues → Check firewall/proxy
   └─ Event Log Errors → Review SENSE operational log
```

## Common Issues and Resolutions

| Issue                                 | Validation Method | Resolution                          |
| ------------------------------------- | ----------------- | ----------------------------------- |
| Device not in portal                  | Method 3          | Verify onboarding script executed   |
| `OnboardingStatus = "CanBeOnboarded"` | Method 2          | Deploy onboarding package           |
| SENSE service stopped                 | Method 4          | Restart service, check dependencies |
| Cloud connectivity failure            | Method 6          | Review proxy/firewall settings      |
| Outdated signatures                   | Method 1          | Force signature update              |
| High event log errors                 | Method 4          | Run Client Analyzer for diagnostics |

## Prerequisites

### For PowerShell Methods

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator credentials for target devices
- Network access to target devices (WinRM enabled for remote)
- Defender module available (built-in on Windows 10/11/Server 2016+)

### For Graph API Methods

- Azure AD App Registration with permissions[5]:
  - WindowsDefenderATP permissions including machine access
- Microsoft.Graph PowerShell module (for scripts)
- Security Administrator or Global Reader role

### For Security Console Methods

- Access to Microsoft 365 Defender portal (https://security.microsoft.com)[3]
- Security Administrator, Security Reader, or Global Reader role
- Modern web browser

### For Advanced Hunting Methods

- Access to Microsoft 365 Defender portal[3]
- Advanced Hunting permissions
- Understanding of KQL query language

## Version Information

**Documentation Version:** 1.0
**Last Updated:** 2025-10-16
**MDE API Version:** v1.0
**Graph API Version:** v1.0

## Additional Resources

- [Microsoft Defender for Endpoint Documentation](https://learn.microsoft.com/en-us/defender-endpoint/)
- [Troubleshoot MDE Onboarding Issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- [Graph API Machine Resource](https://learn.microsoft.com/en-us/graph/api/resources/machine)
- [Advanced Hunting Schema Reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)

## Support

For issues with these validation methods:

1. Review troubleshooting section in specific method documentation
2. Check Microsoft Defender for Endpoint service health
3. Consult Microsoft Support with diagnostic logs from Client Analyzer[6]

## References

1. [Troubleshoot Microsoft Defender for Endpoint onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
2. [Microsoft 365 Defender portal](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal)
3. [Get machines API](https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines)
4. [DeviceInfo table in the advanced hunting schema](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table)
5. [Create an app to access Microsoft Defender for Endpoint without a user](https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-nativeapp)
6. [Run the client analyzer on Windows](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)

[1]: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
[2]: https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal
[3]: https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
[4]: https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceinfo-table
[5]: https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-nativeapp
[6]: https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows
