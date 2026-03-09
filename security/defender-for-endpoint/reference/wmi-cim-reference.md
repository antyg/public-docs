---
title: "WMI/CIM Reference — Microsoft Defender Status Queries"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers querying Defender status via WMI or CIM, particularly on legacy systems or in WMI-aware tooling environments"
document_type: "reference"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# WMI/CIM Reference — Microsoft Defender Status Queries

---

## Overview

Windows Management Instrumentation (WMI) and Common Information Model (CIM) provide low-level query interfaces for Microsoft Defender status. The WMI/CIM approach is most useful when the Defender PowerShell module (`Get-MpComputerStatus`) is unavailable — primarily on Windows 7, Server 2008 R2 with ESU, or in automation systems that natively use WMI ([WMI overview](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi)).

For Windows 10/11 and Server 2016+, prefer [PowerShell validation](../tutorials/powershell-validation.md) using `Get-MpComputerStatus` — it is faster, more complete, and does not require namespace or class name knowledge.

---

## When to Use WMI/CIM

### Use WMI/CIM When

1. **Legacy systems** — Windows 7 or Server 2008 R2 with ESU, where the Defender PowerShell module is unavailable
2. **Cross-platform queries** — Querying Windows devices from a Linux or macOS management host via CIM over WSMan
3. **Minimal dependencies** — The environment cannot install additional PowerShell modules and WMI is available by default
4. **WMI-aware monitoring systems** — Integration with SCCM, System Center Operations Manager, or other platforms that natively consume WMI
5. **DCOM environments** — WinRM is disabled by policy but DCOM (TCP 135 + dynamic RPC) is permitted

### Do Not Use WMI/CIM When

1. **Modern Windows (10/11 or Server 2016+) with the Defender module available** — Use [PowerShell validation](../tutorials/powershell-validation.md) with `Get-MpComputerStatus` instead; it is faster and more complete
2. **Organisation-wide reporting** — Use [Graph API validation](../tutorials/graph-api-validation.md), which does not require per-device network connectivity
3. **Onboarding status confirmation** — WMI does not expose `OnboardingState`; use [registry and service validation](registry-service-reference.md) for definitive onboarding checks

---

## WMI Namespace

All Defender WMI classes reside in a single namespace:

```text
root\Microsoft\Windows\Defender
```

Verify the namespace exists before querying (confirms Defender is installed):

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows -ClassName __NAMESPACE |
    Where-Object Name -eq 'Defender'
```

---

## WMI Class Reference

### MSFT_MpComputerStatus — Overall Defender Status

Primary class for Defender health assessment ([MSFT_MpComputerStatus reference](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus)).

| Property | Type | Description | Healthy Value |
|----------|------|-------------|--------------|
| `AMRunningMode` | String | Antivirus operational mode | `Normal` |
| `AMServiceEnabled` | Boolean | Defender service enabled | `True` |
| `AntivirusEnabled` | Boolean | Antivirus active | `True` |
| `RealTimeProtectionEnabled` | Boolean | Real-time scanning | `True` |
| `BehaviorMonitorEnabled` | Boolean | Behaviour monitoring | `True` |
| `IoavProtectionEnabled` | Boolean | Download and attachment scanning | `True` |
| `IsTamperProtected` | Boolean | Tamper protection active | `True` |
| `TamperProtectionSource` | String | Tamper protection management source | `ATP` or `Intune` |
| `AMEngineVersion` | String | Antivirus engine version | Current |
| `AMProductVersion` | String | Platform version | Current |
| `AntivirusSignatureVersion` | String | Signature database version | Current |
| `AntivirusSignatureLastUpdated` | DateTime | Last signature update | Within 24 hours |
| `ComputerState` | Int | Overall state | `0` = Healthy |

**AMRunningMode values** ([Defender antivirus compatibility](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)):

| Value | Meaning |
|-------|---------|
| `Normal` | Defender running as primary antivirus |
| `Passive` | Third-party AV active; Defender in passive mode |
| `SxS` | Limited periodic scanning |
| `EDR Block Mode` | No AV present; EDR block mode active |

**TamperProtectionSource values** ([tamper protection reference](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)):

| Value | Meaning |
|-------|---------|
| `ATP` | Managed by MDE |
| `Intune` | Managed by Intune policy |
| `Local` | Locally configured |
| `Unknown` | Source undetermined |

### MSFT_MpPreference — Defender Configuration

([MSFT_MpPreference reference](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/dn455323(v=vs.85)))

Key properties for auditing configuration:

| Property | Description |
|----------|-------------|
| `ExclusionPath` | Excluded file/folder paths |
| `ExclusionExtension` | Excluded file extensions |
| `ExclusionProcess` | Excluded processes |
| `ScanScheduleDay` | Scheduled scan day |
| `ScanScheduleTime` | Scheduled scan time |
| `DisableRealtimeMonitoring` | Real-time monitoring override |

### MSFT_MpSignature — Signature Information

([MSFT_MpSignature reference](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpsignature))

| Property | Description |
|----------|-------------|
| `SignatureVersion` | Current signature version |
| `LastUpdated` | Last signature update timestamp |

### MSFT_MpThreat — Threat Detections

| Property | Description |
|----------|-------------|
| `ThreatName` | Threat name |
| `SeverityID` | Severity level (0=Unknown, 1=Low, 2=Medium, 4=High, 5=Severe) |
| `InitialDetectionTime` | When first detected |
| `ProcessName` | Process associated with threat |

---

## CIM vs. WMI Cmdlets

Use CIM cmdlets (PowerShell 3.0+) in preference to WMI cmdlets for all new work. CIM uses the WS-Management (WSMan) protocol, which is faster, supports persistent sessions, and is the [recommended approach](https://learn.microsoft.com/en-us/powershell/scripting/samples/getting-wmi-objects--get-ciminstance-).

| Aspect | CIM (`Get-CimInstance`) | WMI (`Get-WmiObject`) |
|--------|------------------------|----------------------|
| Protocol | WSMan (port 5985/5986) | DCOM (port 135 + dynamic) |
| Session reuse | Yes (`New-CimSession`) | No |
| Cross-platform | Yes (with OMI on Linux) | Windows only |
| PowerShell version | 3.0+ | 1.0+ |
| Recommended | Yes | Legacy/fallback only |

---

## Query Patterns

### Local Status Query (CIM — Recommended)

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus |
    Select-Object AMRunningMode, AMServiceEnabled, RealTimeProtectionEnabled,
                  BehaviorMonitorEnabled, IsTamperProtected, TamperProtectionSource,
                  AntivirusSignatureVersion, AntivirusSignatureLastUpdated
```

### Local Status Query (WMI — Legacy)

```powershell
Get-WmiObject -Namespace root/Microsoft/Windows/Defender -Class MSFT_MpComputerStatus |
    Select-Object AMRunningMode, AMServiceEnabled, RealTimeProtectionEnabled
```

### Single Remote Device (CIM Session)

```powershell
$session = New-CimSession -ComputerName 'WORKSTATION01'

$status = Get-CimInstance -CimSession $session `
    -Namespace root/Microsoft/Windows/Defender `
    -ClassName MSFT_MpComputerStatus

$status | Select-Object PSComputerName, AMRunningMode, RealTimeProtectionEnabled,
                         IsTamperProtected, AntivirusSignatureLastUpdated

Remove-CimSession $session
```

Always call `Remove-CimSession` after use to release the connection ([Remove-CimSession reference](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/remove-cimsession)).

### Multiple Remote Devices (Bulk CIM)

```powershell
$computers = @('WORKSTATION01', 'WORKSTATION02', 'SERVER01')
$sessions  = New-CimSession -ComputerName $computers

Get-CimInstance -CimSession $sessions `
    -Namespace root/Microsoft/Windows/Defender `
    -ClassName MSFT_MpComputerStatus |
    Select-Object PSComputerName, AMRunningMode, AntivirusEnabled,
                  RealTimeProtectionEnabled, AntivirusSignatureLastUpdated |
    Format-Table -AutoSize

Remove-CimSession $sessions
```

### CSV-Driven Bulk Validation

When the device list comes from a CSV file (for example, an export from SCCM or a spreadsheet), use `Import-Csv` to drive the session loop. Each device is queried independently with its own `New-CimSession` so that a single unreachable host does not abort the entire run. Results are written to a CSV for further analysis.

```powershell
$devices = Import-Csv 'C:\devices.csv'   # CSV must have a 'Hostname' column
$results = @()

foreach ($device in $devices) {
    try {
        $session = New-CimSession -ComputerName $device.Hostname -ErrorAction Stop

        $status = Get-CimInstance -CimSession $session `
            -Namespace root/Microsoft/Windows/Defender `
            -ClassName MSFT_MpComputerStatus `
            -ErrorAction Stop

        $results += [PSCustomObject]@{
            Hostname                  = $device.Hostname
            AMRunningMode             = $status.AMRunningMode
            AMServiceEnabled          = $status.AMServiceEnabled
            RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
            IsTamperProtected         = $status.IsTamperProtected
            SignatureVersion          = $status.AntivirusSignatureVersion
            LastUpdated               = $status.AntivirusSignatureLastUpdated
            Status                    = 'Success'
            Error                     = ''
        }

        Remove-CimSession $session
    }
    catch {
        $results += [PSCustomObject]@{
            Hostname                  = $device.Hostname
            AMRunningMode             = $null
            AMServiceEnabled          = $null
            RealTimeProtectionEnabled = $null
            IsTamperProtected         = $null
            SignatureVersion          = $null
            LastUpdated               = $null
            Status                    = 'Failed'
            Error                     = $_.Exception.Message
        }
    }
}

$results | Export-Csv 'C:\defender-status-wmi.csv' -NoTypeInformation
```

The `Status` and `Error` columns distinguish reachable devices from those that failed due to network issues, WinRM being unavailable, or access denied.

### Signature Age Check

```powershell
$status = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
$age    = (Get-Date) - $status.AntivirusSignatureLastUpdated

if ($age.TotalHours -lt 24) {
    Write-Host "Signatures current ($([math]::Round($age.TotalHours, 1)) hours old)"
} else {
    Write-Host "Signatures outdated ($([math]::Round($age.TotalHours, 1)) hours old)" -ForegroundColor Yellow
}
```

### Get Preferences (Exclusion Audit)

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpPreference |
    Select-Object ExclusionPath, ExclusionExtension, ExclusionProcess,
                  ScanScheduleDay, ScanScheduleTime
```

### List Threat Detections

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpThreat |
    Select-Object ThreatName, SeverityID, InitialDetectionTime, ProcessName |
    Sort-Object InitialDetectionTime -Descending |
    Format-Table -AutoSize
```

---

## Limitations

WMI/CIM cannot directly determine MDE cloud onboarding state. The `MSFT_MpComputerStatus` class does not expose the `OnboardingState` registry value. For definitive onboarding confirmation, combine a WMI query with a registry check:

```powershell
$wmiStatus = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
$regStatus = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -ErrorAction SilentlyContinue

if ($wmiStatus.AMServiceEnabled -and $regStatus.OnboardingState -eq 1) {
    Write-Host 'MDE installed and onboarded'
}
```

---

## Troubleshooting

| Error | Cause | Resolution |
|-------|-------|------------|
| `Invalid namespace` | Defender not installed or WMI provider missing | Verify `Get-Service WinDefend`; reinstall Defender |
| `Access is denied` (remote) | Insufficient privileges or firewall blocking WSMan | Verify admin credentials; test `Test-WSMan -ComputerName WORKSTATION01` |
| `The RPC server is unavailable` | WinRM not running on target | Run `Enable-PSRemoting -Force` on target; check TCP 5985 in firewall |
| Properties return `$null` | Defender service not started | `Start-Service WinDefend`; re-query |

---

## WMI/CIM vs. Get-MpComputerStatus

Use this table to select the right query method for a given scenario.

| Aspect | WMI/CIM | `Get-MpComputerStatus` |
|--------|---------|------------------------|
| **Availability** | All Windows versions | Windows 10 / Server 2016+ |
| **Module Required** | No | Defender module |
| **Remote Protocol** | DCOM or WSMan | WSMan (via `Invoke-Command`) |
| **Performance** | Medium | Fast (optimised cmdlet) |
| **Legacy Support** | Yes (Win 7, Server 2008 R2) | No |
| **Complexity** | Higher — requires namespace and class name knowledge | Lower — single cmdlet |
| **Best For** | Legacy systems, WMI-aware automation, DCOM environments | Modern Windows, interactive queries |

([`Get-MpComputerStatus` reference](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus))

---

## Complete Health Check Function

The `Test-DefenderHealthWMI` function encapsulates the WMI validation pattern with parameters, error handling, and structured output suitable for pipeline use or report generation.

```powershell
function Test-DefenderHealthWMI {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    try {
        $session = New-CimSession -ComputerName $ComputerName -ErrorAction Stop

        $status = Get-CimInstance -CimSession $session `
            -Namespace root/Microsoft/Windows/Defender `
            -ClassName MSFT_MpComputerStatus `
            -ErrorAction Stop

        $health = [PSCustomObject]@{
            ComputerName       = $ComputerName
            Installed          = $status.AMServiceEnabled
            Functional         = ($status.AMRunningMode -eq 'Normal' -and $status.RealTimeProtectionEnabled)
            AMRunningMode      = $status.AMRunningMode
            RealTimeProtection = $status.RealTimeProtectionEnabled
            TamperProtected    = $status.IsTamperProtected
            SignatureAgeHours  = [math]::Round(((Get-Date) - $status.AntivirusSignatureLastUpdated).TotalHours, 1)
            SignatureUpToDate  = (((Get-Date) - $status.AntivirusSignatureLastUpdated).TotalHours -lt 24)
        }

        Remove-CimSession $session
        return $health
    }
    catch {
        return [PSCustomObject]@{
            ComputerName       = $ComputerName
            Installed          = $false
            Functional         = $false
            AMRunningMode      = $null
            RealTimeProtection = $null
            TamperProtected    = $null
            SignatureAgeHours  = $null
            SignatureUpToDate  = $null
            Error              = $_.Exception.Message
        }
    }
}

# Example usage
Test-DefenderHealthWMI -ComputerName 'WORKSTATION01'
```

The function returns a consistent object whether the query succeeds or fails, making it safe to use in `foreach` loops and `Export-Csv` pipelines without conditional branching at the call site.

---

## Related Resources

- [MSFT_MpComputerStatus WMI class](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus)
- [MSFT_MpPreference WMI class](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/dn455323(v=vs.85))
- [Get-CimInstance cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance)
- [WinRM installation and configuration](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)
- [Defender antivirus compatibility](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)
- [Tamper protection reference](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)
- [Registry and service reference](registry-service-reference.md)
- [PowerShell validation tutorial](../tutorials/powershell-validation.md)
