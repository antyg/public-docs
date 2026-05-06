---
title: "Tutorial: Validating MDE Deployment Using PowerShell"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers and administrators validating MDE on Windows devices"
document_type: "tutorial"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Tutorial: Validating MDE Deployment Using PowerShell

---

## What You Will Accomplish

By the end of this tutorial you will have:

1. Validated MDE deployment status on a local device using `Get-MpComputerStatus`
2. Extended the check to a remote device using PowerShell remoting
3. Run a bulk validation across multiple devices from a CSV file using `Get-MDEStatus.ps1`
4. Interpreted the key output properties to determine device health

This tutorial covers Windows 10/11 and Windows Server 2016 and later. For Windows 7 or Server 2008 R2, see the [WMI/CIM reference](reference-wmi-cim-reference.md).

---

## Prerequisites

### Local Validation

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator privileges on the local device
- Defender module (built-in on Windows 10/11 and Server 2016+)

### Remote Validation

All local prerequisites, plus:

- Administrator credentials for each target device
- [WinRM enabled](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management) on target devices (port 5985 HTTP or 5986 HTTPS)
- PowerShell Remoting enabled: run `Enable-PSRemoting -Force` as administrator on each target

### Bulk Validation

All remote prerequisites, plus:

- `Get-MDEStatus.ps1` from the [scripts folder](../scripts/README.md)
- For parallel execution: PowerShell 7+ (PS 5.1 falls back to sequential)

---

## Step 1 — Validate the Local Device

Run the following command as administrator:

```powershell
Get-MpComputerStatus | Select-Object AMRunningMode, AMServiceEnabled,
    RealTimeProtectionEnabled, BehaviorMonitorEnabled, IsTamperProtected,
    TamperProtectionSource, AntivirusSignatureVersion, AntivirusSignatureLastUpdated
```

[`Get-MpComputerStatus`](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus) is the primary Defender module cmdlet. It queries the local Defender engine directly.

### Interpreting the Output

| Property | Healthy Value | Concern |
|----------|--------------|---------|
| `AMRunningMode` | `Normal` | `Passive` = third-party AV active; `EDR Block Mode` = no AV but EDR running |
| `AMServiceEnabled` | `True` | `False` = Defender service disabled |
| `RealTimeProtectionEnabled` | `True` | `False` = real-time scanning off |
| `BehaviorMonitorEnabled` | `True` | `False` = behavioural monitoring off |
| `IsTamperProtected` | `True` | `False` = security settings can be changed without MDE |
| `TamperProtectionSource` | `ATP` or `Intune` | `Local` = not managed centrally |
| `AntivirusSignatureLastUpdated` | Within 24 hours | Older = signatures stale |

A fully healthy device shows `AMRunningMode = Normal`, all Boolean properties `True`, and signatures updated within the last 24 hours.

---

## Property Reference

The following table covers all 16 properties returned by [`Get-MpComputerStatus`](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus) that are relevant to MDE validation:

| Property | Type | Description | Valid States / Notes |
|----------|------|-------------|----------------------|
| `AMRunningMode` | String | Antivirus operational mode | `Normal`, `Passive`, `SxS`, `EDR Block Mode` |
| `AMServiceEnabled` | Boolean | Defender service status | `True` = enabled |
| `AntivirusEnabled` | Boolean | Antivirus protection active | `True` = active |
| `RealTimeProtectionEnabled` | Boolean | Real-time scanning status | `True` = enabled |
| `BehaviorMonitorEnabled` | Boolean | Behaviour monitoring status | `True` = enabled |
| `IoavProtectionEnabled` | Boolean | IE/Edge download scanning | `True` = enabled |
| `IsTamperProtected` | Boolean | Tamper protection status | `True` = protected |
| `TamperProtectionSource` | String | Tamper protection enforcement source | `ATP`, `Intune`, `Local` |
| `AMEngineVersion` | String | Antivirus engine version | e.g., `1.1.24010.10` |
| `AMProductVersion` | String | Platform version | e.g., `4.18.24010.7` |
| `AntivirusSignatureVersion` | String | Signature database version | e.g., `1.403.3117.0` |
| `AntivirusSignatureLastUpdated` | DateTime | Last signature update timestamp | Recent = healthy; >24 h = stale |
| `QuickScanStartTime` | DateTime | Last quick scan start timestamp | |
| `QuickScanEndTime` | DateTime | Last quick scan completion timestamp | |
| `FullScanStartTime` | DateTime | Last full scan start timestamp | |
| `ComputerState` | Int | Overall computer health state | `0` = healthy |

`AMRunningMode` is the most important property for MDE validation — check it first before assessing any other status. A device in `Passive` or `EDR Block Mode` requires different interpretation than one in `Normal` mode ([Microsoft Defender Antivirus compatibility](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)).

---

### Validation Criteria Patterns

Use these reusable patterns to evaluate status properties programmatically:

```powershell
$status = Get-MpComputerStatus

# Installed: Defender service is present and enabled
$installed = ($null -ne $status) -and ($status.AMServiceEnabled -eq $true)

# Functional: running in Normal mode with real-time and behavioural monitoring active
$functional = $status.AMRunningMode -eq 'Normal' -and
              $status.RealTimeProtectionEnabled -eq $true -and
              $status.BehaviorMonitorEnabled -eq $true

# Tamper protection enforced by MDE (ATP)
$tamperProtected = $status.IsTamperProtected -eq $true -and
                   $status.TamperProtectionSource -eq 'ATP'

# Signatures current (within 24 hours)
$signatureAge = (Get-Date) - $status.AntivirusSignatureLastUpdated
$upToDate     = $signatureAge.TotalHours -lt 24

if ($installed -and $functional -and $tamperProtected -and $upToDate) {
    Write-Output 'Healthy: all validation criteria met'
} else {
    Write-Warning "Not fully healthy — Installed: $installed | Functional: $functional | Tamper: $tamperProtected | Signatures current: $upToDate"
}
```

---

## Step 2 — Confirm the Onboarding State via Registry

`Get-MpComputerStatus` does not expose the `OnboardingState` registry value directly. Run this alongside Step 1 for a definitive onboarding confirmation ([registry reference](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)):

```powershell
$reg = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -ErrorAction SilentlyContinue

[PSCustomObject]@{
    OnboardingState = $reg.OnboardingState   # 1 = Onboarded, 0 = Not onboarded
    OrgId           = $reg.OrgId             # Should match your tenant GUID
    SenseId         = $reg.SenseId           # Unique device identifier
}
```

`OnboardingState = 1` with a non-empty `OrgId` is the most authoritative local confirmation that the device has been onboarded to MDE.

---

## Step 3 — Validate a Remote Device

Use `Invoke-Command` to run the same checks remotely. WinRM must be enabled on the target:

```powershell
$targetDevice = 'WORKSTATION01'

Invoke-Command -ComputerName $targetDevice -ScriptBlock {
    $status = Get-MpComputerStatus
    $reg    = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        ComputerName              = $env:COMPUTERNAME
        AMRunningMode             = $status.AMRunningMode
        RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
        IsTamperProtected         = $status.IsTamperProtected
        TamperProtectionSource    = $status.TamperProtectionSource
        OnboardingState           = $reg.OnboardingState
        OrgId                     = $reg.OrgId
        SignatureLastUpdated      = $status.AntivirusSignatureLastUpdated
    }
}
```

If WinRM is not enabled, run the following on the target device as administrator and retry:

```powershell
Enable-PSRemoting -Force
```

---

## Step 4 — Validate Multiple Devices from a CSV

For bulk validation, use `Get-MDEStatus.ps1`. This script implements an intelligent fallback chain: CIM/WSMan (preferred) → WMI/DCOM → Registry → Service. It handles PowerShell 7+ parallel execution and falls back to sequential processing on PowerShell 5.1.

### Prepare the Device List

Create a CSV file with a `Hostname` column:

```csv
Hostname,Notes
WORKSTATION01,Finance
WORKSTATION02,HR
SERVER01,File Server
```

### Run Bulk Validation

```powershell
# Basic bulk validation
..\scripts\Get-MDEStatus.ps1 -CsvPath '.\devices.csv' -OutputPath '.\mde-results.csv'

# With explicit credentials (non-domain environments)
$cred = Get-Credential
..\scripts\Get-MDEStatus.ps1 -CsvPath '.\devices.csv' -OutputPath '.\mde-results.csv' -Credential $cred -ThrottleLimit 20
```

### Review Unhealthy Devices

```powershell
Import-Csv '.\mde-results.csv' |
    Where-Object { $_.HealthStatus -ne 'Healthy' } |
    Format-Table Hostname, HealthStatus, ValidationMethod, OnboardingState, ErrorMessage -AutoSize
```

### Health Status Values

`Get-MDEStatus.ps1` maps raw data to these `HealthStatus` values:

| Status | Meaning |
|--------|---------|
| `Healthy` | All checks pass — onboarded, functional, signatures current |
| `Passive` | Third-party AV detected; Defender running in passive/EDR mode |
| `RealTimeProtectionDisabled` | Real-time protection turned off |
| `OutdatedSignatures` | Signature age exceeds 24 hours |
| `NotOnboarded` | `OnboardingState` is not 1 |
| `NotInstalled` | MDE components not found |
| `SenseServiceNotRunning` | SENSE service stopped |
| `ValidationFailed` | Could not connect or query the device |
| `Offline` | Device unreachable on the network |

---

## Step 5 — Force a Specific Validation Method

If the default fallback chain selects an unexpected method, override it:

```powershell
# Force CIM/WSMan (fastest, modern systems)
..\scripts\Get-MDEStatus.ps1 -ComputerName 'SERVER01' -PreferredMethod CIM

# Force Registry (works when WMI/CIM unavailable)
..\scripts\Get-MDEStatus.ps1 -ComputerName 'SERVER01' -PreferredMethod Registry

# Force WMI/DCOM (legacy systems)
..\scripts\Get-MDEStatus.ps1 -ComputerName 'LEGACY-PC' -PreferredMethod WMI
```

---

## Alternative: Third-Party AV Detection

When `AMRunningMode` returns `Passive`, a third-party antivirus product is likely registered as the primary AV. Use the `root/SecurityCenter2` WMI namespace to identify it:

```powershell
Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntivirusProduct |
    Select-Object displayName, productState, pathToSignedProductExe
```

The `productState` field is a hex-encoded value. Decode the protection and update state:

```powershell
$avProducts = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntivirusProduct

foreach ($av in $avProducts) {
    $state     = [Convert]::ToString($av.productState, 16).PadLeft(6, '0')
    $enabled   = $state.Substring(2, 2) -eq '10'
    $upToDate  = $state.Substring(4, 2) -eq '00'

    [PSCustomObject]@{
        DisplayName = $av.displayName
        Enabled     = $enabled
        SignaturesUpToDate = $upToDate
        ProductState       = $av.productState
    }
}
```

If a third-party AV is registered and Defender is in `Passive` mode, verify that MDE EDR capabilities remain active. If the passive mode is unintentional, uninstall the third-party product and confirm Defender returns to `Normal` mode.

---

## Advanced Patterns

### Parallel Execution for Bulk Validation

PowerShell 7+ supports `ForEach-Object -Parallel` for concurrent remote queries. Use `-ThrottleLimit` to control simultaneous connections — 10 to 20 is appropriate for most domain environments:

```powershell
$devices = Import-Csv '.\devices.csv'

$results = $devices | ForEach-Object -Parallel {
    $hostname = $_.Hostname
    try {
        $result = Invoke-Command -ComputerName $hostname -ScriptBlock {
            $status = Get-MpComputerStatus
            [PSCustomObject]@{
                ComputerName              = $env:COMPUTERNAME
                AMRunningMode             = $status.AMRunningMode
                RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
                IsTamperProtected         = $status.IsTamperProtected
                SignatureLastUpdated      = $status.AntivirusSignatureLastUpdated
            }
        } -ErrorAction Stop
        $result
    } catch {
        [PSCustomObject]@{
            ComputerName = $hostname
            AMRunningMode = 'Error'
            Error         = $_.Exception.Message
        }
    }
} -ThrottleLimit 10

$results | Export-Csv '.\mde-results.csv' -NoTypeInformation
```

PowerShell 5.1 does not support `-Parallel`. On 5.1, use the `Get-MDEStatus.ps1` script which handles sequential fallback automatically.

### CIM Session Reuse

When running multiple queries against the same device, establish a CIM session once and reuse it. This avoids the overhead of re-authenticating for each query:

```powershell
$session = New-CimSession -ComputerName 'WORKSTATION01'

# Reuse the same session for multiple queries
$mpStatus  = Get-MpComputerStatus -CimSession $session
$mpPrefs   = Get-MpPreference -CimSession $session

Remove-CimSession $session
```

CIM sessions use WSMan (port 5985/5986) by default, which is faster and more firewall-friendly than DCOM. For legacy systems that only support DCOM, specify `-SessionOption (New-CimSessionOption -Protocol Dcom)`.

---

## Best Practices

- **Check `AMRunningMode` first** — before evaluating any other property, confirm the running mode. A device in `Passive` or `EDR Block Mode` requires a different remediation path than one in `Normal` mode.
- **Use a 24-hour signature age threshold** — signatures older than 24 hours indicate an update service problem. Alert on this before the device becomes vulnerable.
- **Pair with a registry check for onboarding confirmation** — `Get-MpComputerStatus` does not expose `OnboardingState`. Always complement it with a registry query (see Step 2) for a definitive onboarding result.
- **Use CIM sessions for repeated queries** — when querying the same device more than once in a session, create a `CimSession` and reuse it to avoid repeated authentication overhead.
- **Set a conservative throttle limit** — for domain-wide bulk validation, start with `-ThrottleLimit 10` and increase only if network and target capacity supports it. Too high a value causes WinRM connection exhaustion.
- **Log all results with timestamps** — validation outputs are only useful as an audit trail if they include the date and time the check ran. Always include a `CheckedAt = (Get-Date)` field in bulk result objects.

---

## Troubleshooting

**"Access Denied" running the script**

Check execution policy and run as administrator:

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Remote validation fails with "WinRM cannot complete the operation"**

Enable WinRM on the target device and verify network connectivity:

```powershell
# On target device (run as administrator)
Enable-PSRemoting -Force

# Verify from source
Test-WSMan -ComputerName 'WORKSTATION01'
```

**`OnboardingState` is 1 but device not visible in portal**

Synchronisation from local to cloud takes 5–30 minutes. If the device still does not appear after 30 minutes, run the [MDE Client Analyzer](reference-client-analyzer.md) to check connectivity.

---

## Related Resources

- [Get-MpComputerStatus cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus)
- [MDE troubleshoot onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- [Enable PowerShell Remoting](https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands)
- [WinRM installation and configuration](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)
- [Validation methods overview](explanation-validation-methods-overview.md)
- [Registry and service reference](reference-registry-service-reference.md)
