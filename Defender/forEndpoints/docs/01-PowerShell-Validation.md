# Method 1: PowerShell Local/Remote Validation

## Overview

PowerShell-based validation leverages the built-in Defender module ([`Get-MpComputerStatus`][1]) and remote execution capabilities to check MDE deployment status across single or multiple devices. This method is ideal for domain-joined Windows environments.

## Capabilities

- ✅ Check local device MDE status
- ✅ Query multiple remote devices simultaneously
- ✅ Validate antivirus engine status
- ✅ Check real-time protection state
- ✅ Verify tamper protection configuration
- ✅ Review signature update status
- ✅ Assess service health

## Prerequisites

### Local Execution

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator privileges on local device
- Defender module (built-in on Windows 10/11, Server 2016+)

### Remote Execution

- Administrator credentials for target devices
- WinRM enabled on target devices
- Network connectivity on port 5985 (HTTP) or 5986 (HTTPS) [2]
- PowerShell Remoting enabled: `Enable-PSRemoting -Force` [2]
- Firewall rules allowing WinRM traffic

## Key Cmdlets

### Get-MpComputerStatus

Primary cmdlet for retrieving Microsoft Defender status information.[1]

#### Syntax

```powershell
Get-MpComputerStatus [-CimSession <CimSession[]>] [-ThrottleLimit <Int32>] [-AsJob]
```

#### Key Properties for MDE Validation

The [AMRunningMode][3] property indicates antivirus operational compatibility with third-party solutions.

| Property                        | Type     | Description                 | Valid States                         |
| ------------------------------- | -------- | --------------------------- | ------------------------------------ |
| `AMRunningMode`                 | String   | Antivirus operational mode  | Normal, Passive, SxS, EDR Block Mode |
| `AMServiceEnabled`              | Boolean  | Defender service status     | True = Enabled                       |
| `AntivirusEnabled`              | Boolean  | Antivirus protection active | True = Active                        |
| `RealTimeProtectionEnabled`     | Boolean  | Real-time scanning status   | True = Enabled                       |
| `BehaviorMonitorEnabled`        | Boolean  | Behavior monitoring status  | True = Enabled                       |
| `IoavProtectionEnabled`         | Boolean  | IE/Edge downloads scanning  | True = Enabled                       |
| `IsTamperProtected`             | Boolean  | Tamper protection status    | True = Protected                     |
| `TamperProtectionSource`        | String   | Tamper protection source    | ATP, Intune, Local                   |
| `AMEngineVersion`               | String   | Antivirus engine version    | e.g., 1.1.24010.10                   |
| `AMProductVersion`              | String   | Platform version            | e.g., 4.18.24010.7                   |
| `AntivirusSignatureVersion`     | String   | Signature database version  | e.g., 1.403.3117.0                   |
| `AntivirusSignatureLastUpdated` | DateTime | Last signature update time  | Recent = Healthy                     |
| `QuickScanStartTime`            | DateTime | Last quick scan timestamp   |                                      |
| `QuickScanEndTime`              | DateTime | Quick scan completion time  |                                      |
| `FullScanStartTime`             | DateTime | Last full scan timestamp    |                                      |
| `ComputerState`                 | Int      | Overall computer state      | 0 = Healthy                          |

## Validation Criteria

### MDE Installed

```powershell
$status = Get-MpComputerStatus
$installed = $status -ne $null -and $status.AMServiceEnabled -eq $true
```

### MDE Functional

```powershell
$functional = $status.AMRunningMode -eq 'Normal' -and
              $status.RealTimeProtectionEnabled -eq $true -and
              $status.BehaviorMonitorEnabled -eq $true
```

### Tamper Protection Enabled via MDE

```powershell
$tamperProtected = $status.IsTamperProtected -eq $true -and
                   $status.TamperProtectionSource -eq 'ATP'
```

### Signatures Up-to-Date

```powershell
$signatureAge = (Get-Date) - $status.AntivirusSignatureLastUpdated
$upToDate = $signatureAge.TotalHours -lt 24
```

## Local Device Validation

### Basic Status Check

```powershell
Get-MpComputerStatus | Select-Object AMRunningMode, AMServiceEnabled,
    RealTimeProtectionEnabled, BehaviorMonitorEnabled, IsTamperProtected
```

### Comprehensive Status Report

See script: [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1)

#### Usage

```powershell
.\Get-MDEStatus.ps1 -Verbose
```

## Remote Device Validation

### Single Remote Device

```powershell
Invoke-Command -ComputerName WORKSTATION01 -ScriptBlock {
    Get-MpComputerStatus | Select-Object PSComputerName, AMRunningMode,
        RealTimeProtectionEnabled, IsTamperProtected
}
```

### Multiple Remote Devices

See script: [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1)

#### Usage

```powershell
.\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -OutputPath "C:\results.csv"
```

#### CSV Input Format

```csv
Hostname,Notes
WORKSTATION01,Finance Dept
WORKSTATION02,HR Dept
SERVER01,File Server
```

## Advanced Validation Scenarios

### Check MDE vs Third-Party AV Conflict

```powershell
$status = Get-MpComputerStatus

if ($status.AMRunningMode -eq 'Passive') {
    Write-Warning "Defender running in Passive mode - likely third-party AV installed"
} elseif ($status.AMRunningMode -eq 'EDR Block Mode') {
    Write-Information "EDR Block Mode active - MDE blocking threats without full AV"
} elseif ($status.AMRunningMode -eq 'Normal') {
    Write-Host "Defender running in Normal mode - primary AV solution"
}
```

### Validate Cloud Connectivity

Use [MpCmdRun][5] to validate cloud connectivity:

```powershell
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -ValidateMapsConnection
```

**Should Return:** `ValidateMapsConnection successfully established a connection to MAPS` as the output (Healthy)

### Force Signature Update and Verify

Force signature updates using [`Update-MpSignature`][6]:

```powershell
Update-MpSignature -UpdateSource MicrosoftUpdateServer

$status = Get-MpComputerStatus
Write-Host "Signature Version: $($status.AntivirusSignatureVersion)"
Write-Host "Last Updated: $($status.AntivirusSignatureLastUpdated)"
```

## Event Log Validation

### Check for SENSE Service Errors

Query the [SENSE service][4] operational log for errors:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-SENSE/Operational'
    Level = 2,3  # Error and Warning
    StartTime = (Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -AutoSize
```

**Common Event IDs:**[4]

- **Event ID 5**: Microsoft Defender for Endpoint service failed to connect to the server
- **Event ID 6**: Microsoft Defender for Endpoint service isn't onboarded
- **Event ID 7**: Microsoft Defender for Endpoint service failed to read onboarding parameters
- **Event ID 15**: Microsoft Defender for Endpoint can't start command channel

### Check Onboarding Events

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    ProviderName = 'WDATPOnboarding'
    StartTime = (Get-Date).AddDays(-30)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, Message
```

## Performance Considerations

### Parallel Remote Execution

```powershell
$devices = Import-Csv "devices.csv"
$devices | ForEach-Object -Parallel {
    $result = Invoke-Command -ComputerName $_.Hostname -ScriptBlock {
        Get-MpComputerStatus | Select-Object PSComputerName, AMRunningMode
    } -ErrorAction SilentlyContinue
    $result
} -ThrottleLimit 10
```

### Using CIM Sessions (Faster for Multiple Queries)

```powershell
$session = New-CimSession -ComputerName WORKSTATION01
Get-MpComputerStatus -CimSession $session
Get-MpComputerStatus -CimSession $session  # Reuses session
Remove-CimSession $session
```

## Troubleshooting

### Issue: "Get-MpComputerStatus : Operation failed"

**Cause:** Defender service not running or corrupt installation

**Resolution:** Restart the Windows Defender service to restore functionality.

Restart the [Windows Defender service][7]:

```powershell
Start-Service -Name WinDefend
Get-Service -Name WinDefend | Restart-Service
```

### Issue: Remote execution fails with access denied

**Cause:** Insufficient permissions or WinRM disabled

**Resolution:** Verify WinRM connectivity and enable PowerShell remoting.

```powershell
Test-WSMan -ComputerName WORKSTATION01
Enable-PSRemoting -Force  # Run on target device
```

### Issue: "AMRunningMode" shows "Passive"

**Cause:** Third-party antivirus detected

**Resolution:** Verify third-party AV presence and determine appropriate action.

1. Verify third-party AV presence: `Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct`
2. If intentional, ensure MDE EDR capabilities still active
3. If not intentional, uninstall third-party AV

### Issue: Outdated signatures (>48 hours old)

**Cause:** Update service connection failure

**Resolution:** Force signature update and validate cloud connectivity.

```powershell
Update-MpSignature -UpdateSource MicrosoftUpdateServer -Verbose
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -ValidateMapsConnection
```

## Output Interpretation

### Healthy MDE Configuration

```text
AMRunningMode              : Normal
AMServiceEnabled           : True
AntivirusEnabled           : True
RealTimeProtectionEnabled  : True
BehaviorMonitorEnabled     : True
IsTamperProtected          : True
TamperProtectionSource     : ATP
AntivirusSignatureVersion  : 1.403.3117.0
AntivirusSignatureLastUpdated : 10/16/2025 2:30:15 AM
ComputerState              : 0
```

### Problematic MDE Configuration

```text
AMRunningMode              : Passive
AMServiceEnabled           : True
AntivirusEnabled           : False
RealTimeProtectionEnabled  : False
BehaviorMonitorEnabled     : False
IsTamperProtected          : False
AntivirusSignatureLastUpdated : 9/1/2025 8:00:00 AM  # 45 days old!
ComputerState              : 4
```

## Integration with Other Methods

### Combine with Registry Validation

After PowerShell check, validate onboarding state using [registry inspection][8]:

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -Name OnboardingState -ErrorAction SilentlyContinue
```

See: [Method 4: Registry/Service Validation](./04-Registry-Service-Validation.md)

### Escalate to Client Analyzer

If `ComputerState` ≠ 0 or errors in event log:

```powershell
.\MDEClientAnalyzer.cmd
```

See: [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)

## Script Reference

All scripts for this method:

- [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1) - Intelligent multi-method validation (local and bulk)

## Limitations

- ❌ Cannot determine Graph API onboarding status
- ❌ Requires WinRM/direct access to each device
- ❌ Limited to Windows devices only
- ❌ No historical trending data
- ⚠️ Firewall/network issues may cause false negatives

## Best Practices

1. ✅ Use CIM sessions for repeated queries to same device
2. ✅ Implement parallel execution for large device lists (10-20 concurrent)
3. ✅ Always check `AMRunningMode` before assessing functionality
4. ✅ Log all results with timestamps for audit trail
5. ✅ Combine with registry checks for definitive onboarding state
6. ✅ Schedule regular validation (weekly recommended)
7. ✅ Alert on devices with signatures >24 hours old

## Next Steps

- For organization-wide status: [Method 2: Graph API Validation](./02-Graph-API-Validation.md)
- For deep diagnostics: [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)
- For manual verification: [Method 3: Security Console](./03-Security-Console-Manual.md)

## References

1. [Get-MpComputerStatus PowerShell Cmdlet](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps)
2. [Default Ports for WS-Management and PowerShell Remoting](https://learn.microsoft.com/en-us/archive/blogs/wmi/new-default-ports-for-ws-management-and-powershell-remoting)
3. [Microsoft Defender Antivirus Compatibility](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)
4. [Defender for Endpoint Event Error Codes](https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes)
5. [Microsoft Defender Antivirus Command Line Arguments](https://learn.microsoft.com/en-us/defender-endpoint/command-line-arguments-microsoft-defender-antivirus)
6. [Update-MpSignature PowerShell Cmdlet](https://learn.microsoft.com/en-us/powershell/module/defender/update-mpsignature?view=windowsserver2025-ps)
7. [Microsoft Defender Antivirus on Windows](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows)
8. [Troubleshoot Microsoft Defender for Endpoint Onboarding](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)

[1]: https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps
[2]: https://learn.microsoft.com/en-us/archive/blogs/wmi/new-default-ports-for-ws-management-and-powershell-remoting
[3]: https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility
[4]: https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes
[5]: https://learn.microsoft.com/en-us/defender-endpoint/command-line-arguments-microsoft-defender-antivirus
[6]: https://learn.microsoft.com/en-us/powershell/module/defender/update-mpsignature?view=windowsserver2025-ps
[7]: https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows
[8]: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
