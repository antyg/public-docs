---
title: "Registry, Service, and Event Log Reference — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers and administrators performing local or remote MDE status validation"
document_type: "reference"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Registry, Service, and Event Log Reference — Microsoft Defender for Endpoint

---

## Overview

Direct registry and service validation provides the most authoritative local view of MDE deployment state. Unlike cloud-based methods, registry checks confirm onboarding state immediately after package application — without waiting for cloud synchronisation. This reference covers all registry keys, service names, and event IDs required for local MDE health assessment ([onboarding troubleshooting reference](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)).

---

## Registry Keys

### Primary Onboarding Status

**Path**: `HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status`

This path is the most important registry location for confirming MDE onboarding state ([registry validation reference](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm)).

| Value Name | Type | Healthy State | Description |
|------------|------|--------------|-------------|
| `OnboardingState` | DWORD | `1` | `1` = Onboarded; `0` = Not onboarded |
| `OrgId` | String | Non-empty GUID | Identifies the tenant the device is onboarded to |
| `SenseId` | String | Non-empty GUID | Unique device identifier used for portal correlation |

Check for presence of the parent key to confirm MDE is installed:

```powershell
Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection'
```

Read the onboarding state:

```powershell
$status = Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' `
    -ErrorAction SilentlyContinue

[PSCustomObject]@{
    OnboardingState = $status.OnboardingState   # 1 = onboarded
    OrgId           = $status.OrgId
    SenseId         = $status.SenseId
}
```

### Onboarding Policy (Group Policy / Intune)

**Path**: `HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection`

| Value Name | Type | Description |
|------------|------|-------------|
| `OnboardingInfo` | String | Onboarding blob data applied by Group Policy or Intune |
| `GroupIds` | String | Device group assignments |

Verify that the onboarding blob is present and non-trivial in length:

```powershell
$blob = Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection' `
    -Name OnboardingInfo `
    -ErrorAction SilentlyContinue

if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection') {
    if ($blob.OnboardingInfo -and $blob.OnboardingInfo.Length -gt 100) {
        Write-Host "Onboarding policy configured (blob length: $($blob.OnboardingInfo.Length))" -ForegroundColor Green
    } else {
        Write-Host "OnboardingInfo missing or suspiciously short" -ForegroundColor Yellow
    }
} else {
    Write-Host "Policy registry path not present — onboarding package not applied" -ForegroundColor Red
}
```

If `OnboardingState = 0` and `OnboardingInfo` is empty, the onboarding package has not been delivered. Check Group Policy application (`gpresult /h report.html`) or Intune policy sync status.

### Security Management (Intune Security Configuration)

**Path**: `HKLM:\SOFTWARE\Microsoft\SenseCM`

| Value Name | Type | Healthy State | Description |
|------------|------|--------------|-------------|
| `EnrollmentStatus` | DWORD | `1` | Security Management enrolment state |
| `EnrollmentAuthority` | String | `Intune`, `SCCM` | Management authority for security settings |

This key is populated only on devices using MDE Security Configuration Management ([troubleshoot security config management](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-security-config-mgt)).

---

## Windows Services

### SENSE — MDE Behavioural Sensor

The SENSE service is the core MDE sensor. It collects behavioural signals from the OS kernel and transmits them to the MDE cloud service.

| Attribute | Value |
|-----------|-------|
| Service name | `SENSE` |
| Display name | `Windows Defender Advanced Threat Protection Service` |
| Healthy status | `Running` |
| Healthy startup type | `Automatic` |

```powershell
Get-Service -Name SENSE | Select-Object Name, Status, StartType
```

Check startup type via CIM (more reliable than `Get-Service.StartType` on some OS versions):

```powershell
(Get-CimInstance -ClassName Win32_Service -Filter "Name='SENSE'").StartMode
# Expected: Auto
```

### DiagTrack — Connected User Experiences and Telemetry

DiagTrack is required for MDE telemetry upload. If this service is disabled, SENSE cannot transmit data to the cloud ([diagnostic data configuration](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)).

| Attribute | Value |
|-----------|-------|
| Service name | `DiagTrack` |
| Display name | `Connected User Experiences and Telemetry` |
| Healthy status | `Running` |
| Healthy startup type | `Automatic` |

```powershell
# Check both services together
Get-Service -Name SENSE, DiagTrack | Select-Object Name, Status, StartType
```

Expected healthy output:

```text
Name      Status  StartType
----      ------  ---------
SENSE     Running Automatic
DiagTrack Running Automatic
```

If DiagTrack is stopped or set to Manual/Disabled, restore it before troubleshooting SENSE:

```cmd
sc config DiagTrack start= auto
sc start DiagTrack
```

---

## Event Log Reference

### SENSE Operational Log

**Log path**: `Applications and Services Logs\Microsoft\Windows\SENSE\Operational`

Query recent errors:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-SENSE/Operational'
    Level     = 2, 3     # Error=2, Warning=3
    StartTime = (Get-Date).AddDays(-7)
} -MaxEvents 50 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -AutoSize
```

### Key SENSE Event IDs

([MDE event error codes reference](https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes))

| Event ID | Level | Description | Action |
|----------|-------|-------------|--------|
| 5 | Information | Sensor started successfully | Normal — sensor healthy |
| 6 | Information | Sensor stopped | Review if unexpected |
| 7 | Error | Sensor configuration error — onboarding blob missing or invalid | Re-apply onboarding package; check `OnboardingInfo` registry value |
| 15 | Warning | Cloud connectivity issue | Verify firewall/proxy allows MDE endpoints |
| 17 | Error | Onboarding failed | Re-run onboarding script with administrator privileges |
| 30 | Error | Proxy authentication failed | SENSE runs as SYSTEM and cannot use user credentials; configure transparent proxy |
| 35 | Warning | Certificate validation issue | Check SSL/TLS inspection policy; MDE endpoints must not have certificate substituted |

### WDATPOnboarding Events (Application Log)

```powershell
Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'WDATPOnboarding'
    StartTime    = (Get-Date).AddDays(-30)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

These events record the onboarding package execution. Absence of events indicates the onboarding script has not run on this device.

---

## Connectivity Validation

Test MDE cloud endpoint connectivity from PowerShell:

```powershell
# Australian MDE endpoint (commands channel)
Test-NetConnection -ComputerName 'edr-aus.au.endpoint.security.microsoft.com' -Port 443

# Telemetry endpoint
Test-NetConnection -ComputerName 'au-v20.events.endpoint.security.microsoft.com' -Port 443
```

Validate MDE cloud connectivity using the built-in tool:

```powershell
& 'C:\Program Files\Windows Defender\MpCmdRun.exe' -ValidateMapsConnection
```

([Verify connectivity to MDE reference](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity))

---

## Quick Reference Commands

```powershell
# Check onboarding state (single line)
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status').OnboardingState

# Check both services
Get-Service -Name SENSE, DiagTrack | Select-Object Name, Status, StartType

# Last 20 SENSE operational events (errors and warnings)
Get-WinEvent -LogName 'Microsoft-Windows-SENSE/Operational' -MaxEvents 20 |
    Where-Object LevelDisplayName -in 'Error', 'Warning'

# Restart SENSE service
Restart-Service -Name SENSE

# Force connectivity validation
& 'C:\Program Files\Windows Defender\MpCmdRun.exe' -ValidateMapsConnection
```

---

## Healthy vs. Problem Configuration

### Healthy

```text
Registry:
  HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection  -- EXISTS
  OnboardingState = 1
  OrgId           = <non-empty GUID>
  SenseId         = <non-empty GUID>

Services:
  SENSE     -- Running  (Automatic)
  DiagTrack -- Running  (Automatic)

Event Log (last 7 days):
  SENSE errors: 0
  Last Event ID 5: recent
```

### Problem — Not Onboarded

```text
Registry:
  OnboardingState = 0          <- onboarding package not applied or failed
  OrgId           = (empty)

Action: Re-run onboarding script; verify DiagTrack is running
```

### Problem — Connectivity Failure

```text
Event Log:
  Event ID 15 (Warning): Cloud connectivity issue
  Event ID 30 (Error): Proxy authentication failed

Action: Check proxy config; verify MDE endpoint URLs are in firewall allowlist;
        run MDE Client Analyzer for detailed diagnosis
```

#### Firewall and Proxy URL Allowlist

Event ID 15 indicates MDE cannot reach its cloud endpoints. The following wildcard patterns must be permitted outbound on port 443 in both firewall and proxy policy ([verify connectivity to MDE service URLs](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)):

| Pattern | Purpose |
|---------|---------|
| `*.blob.core.windows.net` | Agent update packages and threat intelligence |
| `*.microsoft.com` | MDE cloud services and licensing |
| `*.endpoint.security.microsoft.com` | Endpoint detection and response channel |
| `crl.microsoft.com` | Certificate revocation list |
| `ctldl.windowsupdate.com` | Certificate trust list download |

For environments that require an explicit proxy, configure WinHTTP system-wide proxy so that the SENSE service (which runs as SYSTEM) can reach MDE endpoints:

```cmd
netsh winhttp set proxy proxy-server="proxy.contoso.com:8080" bypass-list="<local>"
```

Verify the current WinHTTP proxy configuration with:

```cmd
netsh winhttp show proxy
```

After configuring the proxy, restart the SENSE service and monitor for Event ID 15 recurrence.

---

## Bulk Validation

For validating MDE status across multiple remote machines simultaneously, use parallel PSSession execution with per-machine error handling. This approach scales to hundreds of devices without serial bottlenecks.

```powershell
$Devices = Import-Csv 'devices.csv'   # Column: Hostname

$Results = $Devices | ForEach-Object -Parallel {
    $Computer = $_.Hostname

    try {
        $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop

        $Status = Invoke-Command -Session $Session -ScriptBlock {
            $reg = Get-ItemProperty `
                -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' `
                -ErrorAction SilentlyContinue

            $cim = Get-CimInstance -ClassName Win32_Service -Filter "Name='SENSE'" `
                -ErrorAction SilentlyContinue

            [PSCustomObject]@{
                ComputerName    = $env:COMPUTERNAME
                Onboarded       = ($reg.OnboardingState -eq 1)
                OrgId           = $reg.OrgId
                SenseRunning    = ($cim.State -eq 'Running')
                SenseStartMode  = $cim.StartMode
            }
        }

        Remove-PSSession $Session
        $Status
    }
    catch {
        [PSCustomObject]@{
            ComputerName    = $Computer
            Onboarded       = $null
            OrgId           = $null
            SenseRunning    = $null
            SenseStartMode  = $null
            Error           = $_.Exception.Message
        }
    }
} -ThrottleLimit 10

$Results | Export-Csv 'bulk-validation-results.csv' -NoTypeInformation
```

Set `-ThrottleLimit` based on network capacity. For WinRM-constrained environments, CIM sessions (`New-CimSession`) may be substituted for PSSessions where only registry and service data are required — CIM sessions use DCOM as a fallback transport when WS-Man is unavailable.

---

## Related Resources

- [MDE troubleshoot onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- [MDE event error codes](https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes)
- [Verify connectivity to MDE service URLs](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- [Configure Windows diagnostic data](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)
- [Get-Service cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service)
- [MDE Client Analyzer reference](client-analyzer.md)
- [WMI/CIM reference](wmi-cim-reference.md)
