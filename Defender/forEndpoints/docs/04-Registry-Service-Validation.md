# Method 4: Registry and Service Validation

## Overview

Direct validation of MDE installation and onboarding status via Windows registry keys, services, and event logs. This method provides definitive local status checks and is essential for troubleshooting onboarding issues[1].

## Capabilities

- ✅ Verify MDE installation presence
- ✅ Check onboarding state definitively
- ✅ Validate SENSE service status
- ✅ Confirm DiagTrack service configuration
- ✅ Review event log errors
- ✅ Validate cloud connectivity configuration
- ✅ Check organizational identifiers

## Prerequisites

- Administrator privileges (local or remote)
- Windows 10 1607+ or Windows Server 2016+[2]
- Registry read access
- Event Viewer access (for log validation)

## Registry Keys

### Primary Onboarding Registry Location

**Path:** [`HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status`][3]

The following key values are available for validating onboarding status and device identifiers[3]:

#### Key Values

| Value Name        | Type   | Description                    | Healthy State   |
| ----------------- | ------ | ------------------------------ | --------------- |
| `OnboardingState` | DWORD  | Onboarding status              | `1` = Onboarded |
| `OrgId`           | String | Organization identifier (GUID) | Non-empty GUID  |
| `SenseId`         | String | Unique device identifier       | Non-empty GUID  |

### Policy Registry Location

**Path:** [`HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection`][3]

The policy registry location contains onboarding blob data and device group configurations[3]:

#### Key Values

| Value Name       | Type   | Description              |
| ---------------- | ------ | ------------------------ |
| `OnboardingInfo` | String | Onboarding blob data     |
| `GroupIds`       | String | Device group assignments |

### Security Management Registry Location

**Path:** [`HKLM:\SOFTWARE\Microsoft\SenseCM`][4]

The Security Management registry location provides enrollment status for managed devices[4]:

#### Key Values

| Value Name            | Type   | Description                    | Values             |
| --------------------- | ------ | ------------------------------ | ------------------ |
| `EnrollmentStatus`    | DWORD  | Security Management enrollment | `1` = Enrolled     |
| `EnrollmentAuthority` | String | Management authority           | Intune, SCCM, etc. |

## PowerShell Registry Validation

### Check Onboarding Status

```powershell
$OnboardingStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -Name OnboardingState -ErrorAction SilentlyContinue

if ($OnboardingStatus.OnboardingState -eq 1) {
    Write-Host "Device is onboarded" -ForegroundColor Green
} else {
    Write-Host "Device is NOT onboarded" -ForegroundColor Red
}
```

### Retrieve Organization ID

```powershell
$OrgInfo = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue

Write-Host "Organization ID: $($OrgInfo.OrgId)"
Write-Host "Sense ID: $($OrgInfo.SenseId)"
```

### Check if MDE Installation Exists

```powershell
$MDEInstalled = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection"

if ($MDEInstalled) {
    Write-Host "MDE registry keys present" -ForegroundColor Green
} else {
    Write-Host "MDE NOT installed" -ForegroundColor Red
}
```

### Validate Onboarding Blob

```powershell
$OnboardingBlob = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection" -Name OnboardingInfo -ErrorAction SilentlyContinue

if ($OnboardingBlob.OnboardingInfo) {
    Write-Host "Onboarding policy configured" -ForegroundColor Green
    Write-Host "Blob length: $($OnboardingBlob.OnboardingInfo.Length) bytes"
} else {
    Write-Host "Onboarding policy NOT configured" -ForegroundColor Yellow
}
```

### Remote Registry Check

```powershell
$ComputerName = "WORKSTATION01"

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    $Status = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OnboardingState = $Status.OnboardingState
        OrgId = $Status.OrgId
        SenseId = $Status.SenseId
    }
}
```

## Service Validation

### SENSE Service (MDE Behavioral Sensor)

The [SENSE service][5] is the behavioral sensor that powers Microsoft Defender for Endpoint.

**Service Name:** [`SENSE`][5]
**Display Name:** [`Windows Defender Advanced Threat Protection Service`][5]
**Description:** Behavioral sensor that powers Microsoft Defender for Endpoint[5]

### DiagTrack Service (Diagnostic Data)

The [DiagTrack service][6] is required for MDE telemetry upload.

**Service Name:** [`DiagTrack`][6]
**Display Name:** [`Connected User Experiences and Telemetry`][6]
**Description:** Required for MDE telemetry upload[6]

### Check Service Status (PowerShell)

```powershell
Get-Service -Name SENSE, DiagTrack | Select-Object Name, Status, StartType
```

#### Healthy Output

```text
Name      Status  StartType
----      ------  ---------
SENSE     Running Automatic
DiagTrack Running Automatic
```

### Check Service Status (Command Line)

```cmd
sc query SENSE
sc qc SENSE
```

#### Healthy Output

```text
SERVICE_NAME: SENSE
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 4  RUNNING
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
```

### Verify Service Startup Type

Check the SENSE service startup configuration using [Get-Service][7]:

```powershell
$SenseService = Get-Service -Name SENSE
$SenseStartType = (Get-WmiObject Win32_Service -Filter "Name='SENSE'").StartMode

if ($SenseStartType -eq 'Auto') {
    Write-Host "SENSE service set to Automatic startup" -ForegroundColor Green
} else {
    Write-Host "WARNING: SENSE service startup type is $SenseStartType" -ForegroundColor Yellow
}
```

### Start/Restart Services

Manage MDE services using [PowerShell service management cmdlets][7]:

```powershell
Start-Service -Name SENSE
Start-Service -Name DiagTrack

Restart-Service -Name SENSE
```

### Check Service Dependencies

Examine service dependencies using [Get-Service][7]:

```powershell
Get-Service -Name SENSE -DependentServices
Get-Service -Name SENSE -RequiredServices
```

## Event Log Validation

### SENSE Operational Log

**Event Log Path:** [`Applications and Services Logs\Microsoft\Windows\SENSE\Operational`][8]

### PowerShell Event Log Queries

#### Check for SENSE Errors (Last 7 Days)

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-SENSE/Operational'
    Level = 2,3  # Error (2) and Warning (3)
    StartTime = (Get-Date).AddDays(-7)
} -MaxEvents 50 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -AutoSize
```

#### Check SENSE Service Start Events

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-SENSE/Operational'
    Id = 5  # Service started successfully
    StartTime = (Get-Date).AddDays(-30)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Message
```

### Key SENSE Event IDs

The following event IDs are critical for monitoring SENSE service health and troubleshooting connectivity issues[8]:

| Event ID | Level       | Description                  | Action                      |
| -------- | ----------- | ---------------------------- | --------------------------- |
| **5**    | Information | Sensor started successfully  | Normal - sensor healthy     |
| **6**    | Information | Sensor stopped               | Review if unexpected        |
| **7**    | Error       | Sensor configuration error   | Check registry keys         |
| **15**   | Warning     | Cloud connectivity issue     | Validate proxy/firewall     |
| **17**   | Error       | Onboarding failed            | Re-run onboarding script    |
| **30**   | Error       | Proxy authentication failed  | Configure proxy credentials |
| **35**   | Warning     | Certificate validation issue | Check certificate chain     |

### Check Onboarding Events in Application Log

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    ProviderName = 'WDATPOnboarding'
    StartTime = (Get-Date).AddDays(-30)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

## Comprehensive Validation Script

See script: [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1)

### Usage

```powershell
.\Get-MDEStatus.ps1 -ComputerName WORKSTATION01
```

### Output Example

```text
Computer Name         : WORKSTATION01
MDE Installed         : True
Onboarding State      : 1 (Onboarded)
Organization ID       : 12345678-1234-1234-1234-123456789012
Sense ID              : abcd1234-5678-90ab-cdef-1234567890ab
SENSE Service Status  : Running
SENSE Service Startup : Automatic
DiagTrack Status      : Running
Recent SENSE Errors   : 0
Last SENSE Error      : None
Validation Result     : HEALTHY
```

## Validation Criteria Summary

### MDE Installed

- ✅ Registry key exists: [`HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection`][3]
- ✅ [SENSE service][5] exists

### MDE Onboarded

- ✅ [`OnboardingState`][3] = `1`
- ✅ [`OrgId`][3] is non-empty GUID
- ✅ [`SenseId`][3] is non-empty GUID
- ✅ [Onboarding policy][3] configured (OnboardingInfo present)

### MDE Functional

- ✅ [SENSE service][5] status = `Running`
- ✅ [SENSE service][5] startup type = `Automatic`
- ✅ [DiagTrack service][6] status = `Running`
- ✅ No critical errors in [SENSE operational log][8] (last 7 days)
- ✅ Recent [Event ID 5][8] (sensor start) within last restart period

## Remote Bulk Validation

### Validate Multiple Devices from CSV

See script: [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1)

#### Usage

```powershell
.\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -OutputPath "C:\service-status.csv"
```

### Parallel Remote Execution

```powershell
$Devices = Import-Csv "devices.csv"

$Results = $Devices | ForEach-Object -Parallel {
    $Computer = $_.Hostname

    try {
        $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop

        $Status = Invoke-Command -Session $Session -ScriptBlock {
            $Onboarded = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue).OnboardingState -eq 1
            $SenseRunning = (Get-Service -Name SENSE -ErrorAction SilentlyContinue).Status -eq 'Running'

            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Onboarded = $Onboarded
                SenseRunning = $SenseRunning
            }
        }

        Remove-PSSession $Session
        $Status
    }
    catch {
        [PSCustomObject]@{
            ComputerName = $Computer
            Onboarded = $null
            SenseRunning = $null
            Error = $_.Exception.Message
        }
    }
} -ThrottleLimit 10

$Results | Export-Csv "bulk-validation-results.csv" -NoTypeInformation
```

## Troubleshooting

### Issue: OnboardingState = 0 or Not Present

**Cause:** [Device not onboarded][1]

**Resolution:** Run onboarding script and verify DiagTrack service is running.

1. Run onboarding script from MDE portal
2. Verify [DiagTrack service][6] running
3. Check [network connectivity to MDE endpoints][9]
4. Review Application event log for WDATPOnboarding errors

### Issue: SENSE Service Not Found

**Cause:** [MDE not installed or installation failed][5]

**Resolution:** Verify OS compatibility and install/reinstall MDE agent.

1. Verify [OS compatibility][2] (Windows 10 1607+, Server 2016+)
2. Install/reinstall MDE agent
3. Check Windows Update for sensor package

### Issue: SENSE Service Stopped or Failed to Start

**Cause:** [Service crash, dependency failure, or misconfiguration][5]

**Resolution:** Start DiagTrack and SENSE services, then review event log for errors.

```powershell
Start-Service -Name DiagTrack
Start-Service -Name SENSE
Get-WinEvent -LogName 'Microsoft-Windows-SENSE/Operational' -MaxEvents 10
```

Review event log for [specific error codes][8]

### Issue: DiagTrack Service Disabled

**Cause:** [Group Policy or manual configuration][6]

**Resolution:** Set DiagTrack service to automatic startup and start the service.

```cmd
sc config DiagTrack start= auto
sc start DiagTrack
```

### Issue: Event ID 15 (Cloud Connectivity)

**Cause:** [Firewall blocking, proxy misconfiguration, or DNS issues][8]

**Resolution:** Verify URLs whitelisted and configure proxy if applicable.

1. Verify [URLs whitelisted][9]: `*.blob.core.windows.net`, `*.microsoft.com`, `crl.microsoft.com`
2. Configure proxy if applicable
3. Test [connectivity][9]: `Test-NetConnection -ComputerName au.vortex-win.data.microsoft.com -Port 443`

### Issue: Event ID 30 (Proxy Authentication)

**Cause:** [Proxy requires authentication][8]

**Resolution:** Configure proxy settings with authentication support.

```cmd
netsh winhttp set proxy proxy-server="proxy.contoso.com:8080" bypass-list="<local>"
```

Or configure system proxy with authentication

## Output Interpretation

### Healthy Configuration

```text
Registry Keys:
  HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection - EXISTS
  OnboardingState = 1
  OrgId = 12345678-1234-1234-1234-123456789012
  SenseId = abcd1234-5678-90ab-cdef-1234567890ab

Services:
  SENSE - Running (Automatic)
  DiagTrack - Running (Automatic)

Event Log:
  Recent SENSE errors: 0
  Last successful start: 2025-10-16 08:00:00
```

### Problem Configuration

```text
Registry Keys:
  HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection - EXISTS
  OnboardingState = 0  ← NOT ONBOARDED
  OrgId = (empty)
  SenseId = (empty)

Services:
  SENSE - Stopped (Manual)  ← SERVICE NOT RUNNING
  DiagTrack - Running (Automatic)

Event Log:
  Recent SENSE errors: 5
  Last error (Event ID 7): Configuration error - onboarding blob missing
```

## Integration with Other Methods

### Confirm PowerShell Results

After running [Get-MpComputerStatus][10] from [Method 1: PowerShell Validation](./01-PowerShell-Validation.md), confirm the onboarding state via registry:

```powershell
Get-MpComputerStatus  # Returns data
# Now confirm onboarding state
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -Name OnboardingState
```

### Validate Before Graph API Check

Before querying [Method 2: Graph API](./02-Graph-API-Validation.md):

1. Verify local onboarding state
2. Confirm OrgId matches your tenant
3. Check last communication time via SENSE log

### Escalate to Client Analyzer

If registry shows `OnboardingState = 1` but portal doesn't reflect device:

- Use [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md) for detailed diagnostics

## Script Reference

All scripts for this method:

- [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1) - Comprehensive registry, service, and event log validation

## Limitations

- ❌ Requires local or remote admin access to each device
- ❌ Cannot verify cloud-side onboarding status
- ❌ No historical onboarding timeline
- ⚠️ Registry keys may exist even if cloud onboarding incomplete
- ⚠️ Firewall/WinRM issues prevent remote validation

## Best Practices

1. ✅ Always check both registry AND service status
2. ✅ Review [event log for errors][8] before assuming healthy
3. ✅ Verify [OrgId matches your expected tenant ID][3]
4. ✅ Use remote PowerShell for bulk validation (not RDP)
5. ✅ Check [DiagTrack service][6] before troubleshooting SENSE
6. ✅ Document [Event ID patterns][8] for recurring issues
7. ✅ Combine registry check with [Method 1: PowerShell](./01-PowerShell-Validation.md) for complete picture

## Quick Reference Commands

Check service status using [Get-Service cmdlet][7]:

```powershell
# Check onboarding state
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status").OnboardingState

# Check SENSE service
Get-Service -Name SENSE | Select-Object Name, Status, StartType

# Check recent SENSE errors
Get-WinEvent -LogName 'Microsoft-Windows-SENSE/Operational' -MaxEvents 20 | Where-Object LevelDisplayName -in 'Error','Warning'

# Restart SENSE service
Restart-Service -Name SENSE

# Validate cloud connectivity
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -ValidateMapsConnection
```

## Next Steps

- For cloud-side validation: [Method 2: Graph API](./02-Graph-API-Validation.md)
- For local AV status: [Method 1: PowerShell](./01-PowerShell-Validation.md)
- For deep diagnostics: [Method 6: Client Analyzer](./06-MDE-Client-Analyzer.md)
- For portal verification: [Method 3: Security Console](./03-Security-Console-Manual.md)

## References

1. [Troubleshoot Microsoft Defender for Endpoint Onboarding Issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
2. [Minimum Requirements for Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/minimum-requirements)
3. [Configure Endpoints Using SCCM](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm)
4. [Troubleshoot Security Configuration Management](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-security-config-mgt)
5. [Windows Defender Advanced Threat Protection Service](https://learn.microsoft.com/en-us/answers/questions/983229/windows-defender-advanced-threat-protection-servic)
6. [Configure Windows Diagnostic Data in Your Organization](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)
7. [Get-Service PowerShell Cmdlet Reference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service?view=powershell-7.5)
8. [Microsoft Defender for Endpoint Event Error Codes](https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes)
9. [Verify Connectivity to Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
10. [Get-MpComputerStatus PowerShell Cmdlet Reference](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps)

[1]: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
[2]: https://learn.microsoft.com/en-us/defender-endpoint/minimum-requirements
[3]: https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm
[4]: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-security-config-mgt
[5]: https://learn.microsoft.com/en-us/answers/questions/983229/windows-defender-advanced-threat-protection-servic
[6]: https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
[7]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service?view=powershell-7.5
[8]: https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes
[9]: https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity
[10]: https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps
