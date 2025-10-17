# Method 7: WMI/CIM Query Validation

## Overview

Windows Management Instrumentation (WMI) and Common Information Model (CIM) provide low-level query interfaces for accessing Microsoft Defender status[^1](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5). This method is ideal for legacy systems, scripted automation, and environments where PowerShell Defender module is unavailable.

## Capabilities

- ✅ Query Defender status via WMI/CIM
- ✅ Remote device queries without WinRM
- ✅ Cross-platform compatibility (CIM over WSMan)
- ✅ Legacy system support (Windows 7, Server 2008 R2 with ESU)
- ✅ Alternative to Get-MpComputerStatus
- ✅ DCOM and WSMan protocol support[^2](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

## Prerequisites

### Local Queries

- Windows PowerShell 3.0+ (for CIM cmdlets)[^3](https://learn.microsoft.com/en-us/powershell/scripting/samples/getting-wmi-objects--get-ciminstance-?view=powershell-7.5)
- Standard user privileges (read-only WMI access)

### Remote Queries

- Administrator credentials for target devices
- Network connectivity
- Firewall rules:
  - **DCOM**: TCP 135 + dynamic RPC ports (49152-65535)
  - **WSMan**: TCP 5985 (HTTP) or 5986 (HTTPS)[^4](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

## WMI Namespace and Classes

### Primary Namespace

`root\Microsoft\Windows\Defender`[^5](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus)

### Key WMI Classes

The following WMI classes provide access to overall Defender status[^6](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus), configuration preferences[^7](<https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/dn455323(v=vs.85)>), and signature information[^8](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpsignature):

| Class Name              | Description             | Key Properties                                 |
| ----------------------- | ----------------------- | ---------------------------------------------- |
| `MSFT_MpComputerStatus` | Overall Defender status | AMRunningMode, RealTimeProtectionEnabled, etc. |
| `MSFT_MpPreference`     | Defender configuration  | ExclusionPath, ScanScheduleDay, etc.           |
| `MSFT_MpScan`           | Scan operations         | ScanType, ScanParameters                       |
| `MSFT_MpSignature`      | Signature information   | SignatureVersion, LastUpdated                  |
| `MSFT_MpThreat`         | Threat detections       | ThreatName, SeverityID, ResourcesAffected      |

## CIM vs. WMI Cmdlets

### CIM Cmdlets (Recommended)

- **Protocol**: WSMan (WS-Management)[^9](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)
- **Performance**: Faster, persistent sessions
- **Compatibility**: Cross-platform (Windows, Linux with OMI)
- **Cmdlets**: `Get-CimInstance`[^10](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance?view=powershell-7.5), `New-CimSession`

### WMI Cmdlets (Legacy)

- **Protocol**: DCOM (Distributed COM)
- **Performance**: Slower, no session reuse
- **Compatibility**: Windows only
- **Cmdlets**: `Get-WmiObject`[^11](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5)

**Recommendation:** Use CIM cmdlets unless working with Windows 7/Server 2008 R2

## Local Defender Status Queries

### Get Basic Defender Status (CIM)

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
```

#### Key Properties

- `AMRunningMode` - Antivirus operational mode[^12](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)
- `AMServiceEnabled` - Defender service status
- `AntivirusEnabled` - Antivirus protection active
- `RealTimeProtectionEnabled` - Real-time scanning enabled
- `BehaviorMonitorEnabled` - Behavior monitoring status
- `IsTamperProtected` - Tamper protection enabled[^13](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)

### Get Basic Defender Status (WMI - Legacy)

```powershell
Get-WmiObject -Namespace root/Microsoft/Windows/Defender -Class MSFT_MpComputerStatus
```

### Selective Property Query

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus |
    Select-Object AMRunningMode, AMServiceEnabled, RealTimeProtectionEnabled,
                  AntivirusSignatureVersion, AntivirusSignatureLastUpdated
```

### Check Tamper Protection Status

```powershell
$Status = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
Write-Host "Tamper Protected: $($Status.IsTamperProtected)"
Write-Host "Tamper Source: $($Status.TamperProtectionSource)"
```

**Tamper Protection Sources:**[^14](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)

- `ATP` - Managed by Microsoft Defender for Endpoint
- `Intune` - Managed by Intune policy
- `Local` - Locally configured
- `Unknown` - Source undetermined

## Remote Defender Status Queries

### Using CIM Sessions (Recommended)

```powershell
$ComputerName = "WORKSTATION01"
$Session = New-CimSession -ComputerName $ComputerName

$Status = Get-CimInstance -CimSession $Session `
    -Namespace root/Microsoft/Windows/Defender `
    -ClassName MSFT_MpComputerStatus

$Status | Select-Object PSComputerName, AMRunningMode, RealTimeProtectionEnabled

Remove-CimSession $Session
```

### Multiple Remote Devices

```powershell
$Computers = @("WORKSTATION01", "WORKSTATION02", "SERVER01")
$Sessions = New-CimSession -ComputerName $Computers

$Results = Get-CimInstance -CimSession $Sessions `
    -Namespace root/Microsoft/Windows/Defender `
    -ClassName MSFT_MpComputerStatus |
    Select-Object PSComputerName, AMRunningMode, AntivirusEnabled, RealTimeProtectionEnabled

$Results | Format-Table -AutoSize

Remove-CimSession $Sessions
```

### Legacy WMI Remote Query

```powershell
$ComputerName = "WORKSTATION01"
Get-WmiObject -ComputerName $ComputerName `
    -Namespace root/Microsoft/Windows/Defender `
    -Class MSFT_MpComputerStatus |
    Select-Object PSComputerName, AMRunningMode, RealTimeProtectionEnabled
```

## Bulk Validation from CSV

### Script Example

```powershell
$Devices = Import-Csv "C:\devices.csv"
$Results = @()

foreach ($Device in $Devices) {
    try {
        $Session = New-CimSession -ComputerName $Device.Hostname -ErrorAction Stop

        $Status = Get-CimInstance -CimSession $Session `
            -Namespace root/Microsoft/Windows/Defender `
            -ClassName MSFT_MpComputerStatus `
            -ErrorAction Stop

        $Results += [PSCustomObject]@{
            Hostname = $Device.Hostname
            AMRunningMode = $Status.AMRunningMode
            AMServiceEnabled = $Status.AMServiceEnabled
            RealTimeProtectionEnabled = $Status.RealTimeProtectionEnabled
            IsTamperProtected = $Status.IsTamperProtected
            SignatureVersion = $Status.AntivirusSignatureVersion
            LastUpdated = $Status.AntivirusSignatureLastUpdated
            Status = "Success"
            Error = ""
        }

        Remove-CimSession $Session
    }
    catch {
        $Results += [PSCustomObject]@{
            Hostname = $Device.Hostname
            AMRunningMode = $null
            AMServiceEnabled = $null
            RealTimeProtectionEnabled = $null
            IsTamperProtected = $null
            SignatureVersion = $null
            LastUpdated = $null
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

$Results | Export-Csv "C:\defender-status-wmi.csv" -NoTypeInformation
```

## Validation Criteria

### MDE Installed (via WMI)

```powershell
$Status = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus -ErrorAction SilentlyContinue

if ($Status -and $Status.AMServiceEnabled) {
    Write-Host "Defender service enabled" -ForegroundColor Green
} else {
    Write-Host "Defender service NOT enabled" -ForegroundColor Red
}
```

### MDE Functional

```powershell
$Status = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus

$Functional = $Status.AMRunningMode -eq 'Normal' -and
              $Status.RealTimeProtectionEnabled -eq $true -and
              $Status.BehaviorMonitorEnabled -eq $true

if ($Functional) {
    Write-Host "MDE is functional" -ForegroundColor Green
} else {
    Write-Host "MDE has configuration issues" -ForegroundColor Yellow
}
```

### Signatures Up-to-Date

```powershell
$Status = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus

$SignatureAge = (Get-Date) - $Status.AntivirusSignatureLastUpdated

if ($SignatureAge.TotalHours -lt 24) {
    Write-Host "Signatures up-to-date" -ForegroundColor Green
} else {
    Write-Host "Signatures outdated ($([math]::Round($SignatureAge.TotalHours, 2)) hours old)" -ForegroundColor Yellow
}
```

## Advanced Queries

### Get Defender Preferences (Exclusions, Schedule)

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpPreference |
    Select-Object ExclusionPath, ExclusionExtension, ScanScheduleDay, ScanScheduleTime
```

### List Threat Detections

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpThreat |
    Select-Object ThreatName, SeverityID, InitialDetectionTime, ProcessName |
    Format-Table -AutoSize
```

#### Severity IDs

- `0` - Unknown
- `1` - Low
- `2` - Medium
- `4` - High
- `5` - Severe

### Get Signature Information

```powershell
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus |
    Select-Object AMEngineVersion, AMProductVersion,
                  AntivirusSignatureVersion, NISSignatureVersion,
                  AntivirusSignatureLastUpdated
```

## Troubleshooting

### Issue: "Invalid namespace" Error

#### Error

```text
Get-CimInstance : Invalid namespace
```

**Cause:** Defender not installed or WMI provider missing

**Resolution:** Verify Defender installation and WMI namespace existence.

1. Verify Defender installed: `Get-Service WinDefend`
2. Check namespace exists:

   ```powershell
   Get-CimInstance -Namespace root/Microsoft/Windows -ClassName __NAMESPACE |
       Where-Object Name -eq 'Defender'
   ```

3. Reinstall Defender if missing

### Issue: Access Denied (Remote Query)

#### Error

```text
Get-CimInstance : Access is denied
```

**Cause:** Insufficient privileges or firewall blocking

**Resolution:** Verify administrator credentials and test connectivity.

1. Verify administrator credentials
2. Test connectivity:

   ```powershell
   Test-WSMan -ComputerName WORKSTATION01
   ```

3. Check firewall rules for WSMan (TCP 5985)

### Issue: RPC Server Unavailable

#### Error

```text
New-CimSession : The RPC server is unavailable
```

**Cause:** WinRM service not running or firewall blocking

**Resolution:** Verify WinRM service and enable PowerShell remoting.

1. Verify WinRM service on target:

   ```powershell
   Get-Service -Name WinRM -ComputerName WORKSTATION01
   ```

2. Enable WinRM on target (run locally):

   ```powershell
   Enable-PSRemoting -Force
   ```

3. Check firewall allows TCP 5985

### Issue: Properties Show as $null

**Cause:** Defender service not started or WMI corruption

**Resolution:** Start or restart the Defender service to resolve the issue.

```powershell
Start-Service WinDefend
Restart-Service WinDefend
Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
```

## Comparison: WMI/CIM vs. Get-MpComputerStatus

The following comparison shows WMI/CIM capabilities versus the Get-MpComputerStatus cmdlet[^15](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps):

| Aspect              | WMI/CIM                         | Get-MpComputerStatus       |
| ------------------- | ------------------------------- | -------------------------- |
| **Availability**    | All Windows versions            | Windows 10/Server 2016+    |
| **Module Required** | No                              | Defender module            |
| **Remote Protocol** | DCOM or WSMan                   | WSMan (via Invoke-Command) |
| **Performance**     | Medium                          | Fast (optimized cmdlet)    |
| **Legacy Support**  | Yes (Win7, 2008 R2)             | No                         |
| **Complexity**      | Higher (namespace, class names) | Lower (simple cmdlet)      |
| **Best For**        | Legacy systems, automation      | Modern systems             |

## Output Interpretation

### Healthy Configuration

```text
AMRunningMode                  : Normal
AMServiceEnabled               : True
AntivirusEnabled               : True
RealTimeProtectionEnabled      : True
BehaviorMonitorEnabled         : True
IsTamperProtected              : True
TamperProtectionSource         : ATP
AntivirusSignatureVersion      : 1.403.3117.0
AntivirusSignatureLastUpdated  : 10/16/2025 2:30:00 AM
```

### Problematic Configuration

```text
AMRunningMode                  : Passive
AMServiceEnabled               : True
AntivirusEnabled               : False
RealTimeProtectionEnabled      : False
BehaviorMonitorEnabled         : False
IsTamperProtected              : False
AntivirusSignatureLastUpdated  : 9/1/2025 8:00:00 AM
```

**Action:** Third-party AV detected, Defender in Passive mode[^16](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)

## Integration with Other Methods

### Cross-Validate with Registry

After WMI query, confirm onboarding state:

```powershell
$WMIStatus = Get-CimInstance -Namespace root/Microsoft/Windows/Defender -ClassName MSFT_MpComputerStatus
$RegStatus = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue

if ($WMIStatus.AMServiceEnabled -and $RegStatus.OnboardingState -eq 1) {
    Write-Host "MDE installed and onboarded" -ForegroundColor Green
}
```

See: [Method 4: Registry/Service Validation](./04-Registry-Service-Validation.md)

### Escalate to PowerShell Cmdlet

If WMI query succeeds, use [Method 1: PowerShell](./01-PowerShell-Validation.md) for more detailed information:

```powershell
Get-MpComputerStatus
Get-MpThreatDetection
Get-MpPreference
```

## Script Reference

Production-ready scripts using WMI/CIM:

- [Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1) - Intelligent multi-method validation (supports -PreferredMethod WMI or CIM)

## Best Practices

1. ✅ Prefer CIM cmdlets over WMI cmdlets (better performance)[^17](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5)
2. ✅ Use `New-CimSession` for multiple queries to same device
3. ✅ Always remove CIM sessions after use (`Remove-CimSession`)[^18](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/remove-cimsession?view=powershell-7.4)
4. ✅ Implement error handling for network/permission issues
5. ✅ Use `-ErrorAction SilentlyContinue` for non-existent classes
6. ✅ Combine WMI query with registry validation for complete picture
7. ❌ Don't use WMI for bulk validation on modern systems (use PowerShell cmdlets)

## Limitations

- ❌ Cannot determine MDE onboarding status directly (no OnboardingState property)
- ❌ Less detailed than Get-MpComputerStatus cmdlet
- ❌ Requires WinRM or DCOM connectivity for remote queries
- ❌ No direct Graph API integration
- ⚠️ DCOM protocol may be disabled by security policies
- ⚠️ Namespace availability depends on Defender installation

## Use Cases

### When to Use WMI/CIM Validation

1. **Legacy Systems**: Windows 7, Server 2008 R2 (ESU) where Defender module unavailable
2. **Cross-Platform**: Querying Windows from Linux/macOS via CIM over WSMan
3. **Minimal Dependencies**: No PowerShell module installation required
4. **Automation**: Integration with WMI-aware monitoring systems (SCCM, System Center)
5. **Firewall Restrictions**: WinRM disabled but DCOM allowed

### When NOT to Use WMI/CIM Validation

1. Modern Windows 10/11/Server 2016+ with Defender module → Use [Method 1: PowerShell](./01-PowerShell-Validation.md)
2. Organization-wide reporting → Use [Method 2: Graph API](./02-Graph-API-Validation.md)
3. Onboarding status validation → Use [Method 4: Registry/Service](./04-Registry-Service-Validation.md)

## Example: Complete Health Check

```powershell
function Test-DefenderHealthWMI {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    try {
        $Session = New-CimSession -ComputerName $ComputerName -ErrorAction Stop

        $Status = Get-CimInstance -CimSession $Session `
            -Namespace root/Microsoft/Windows/Defender `
            -ClassName MSFT_MpComputerStatus `
            -ErrorAction Stop

        $Health = [PSCustomObject]@{
            ComputerName = $ComputerName
            Installed = $Status.AMServiceEnabled
            Functional = ($Status.AMRunningMode -eq 'Normal' -and $Status.RealTimeProtectionEnabled)
            AMRunningMode = $Status.AMRunningMode
            RealTimeProtection = $Status.RealTimeProtectionEnabled
            TamperProtected = $Status.IsTamperProtected
            SignatureAge = ((Get-Date) - $Status.AntivirusSignatureLastUpdated).TotalHours
            UpToDate = (((Get-Date) - $Status.AntivirusSignatureLastUpdated).TotalHours -lt 24)
        }

        Remove-CimSession $Session
        return $Health
    }
    catch {
        return [PSCustomObject]@{
            ComputerName = $ComputerName
            Installed = $false
            Functional = $false
            Error = $_.Exception.Message
        }
    }
}

Test-DefenderHealthWMI -ComputerName "WORKSTATION01"
```

## Next Steps

- For modern systems: [Method 1: PowerShell Validation](./01-PowerShell-Validation.md)
- For onboarding verification: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
- For organization-wide status: [Method 2: Graph API](./02-Graph-API-Validation.md)
- For deep diagnostics: [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)

## References

[^1]: [Working with WMI - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5)

[^2]: [Installation and configuration for Windows Remote Management - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

[^3]: [Getting WMI objects with Get-CimInstance - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/samples/getting-wmi-objects--get-ciminstance-?view=powershell-7.5)

[^4]: [Installation and configuration for Windows Remote Management - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

[^5]: [MSFT_MpComputerStatus class | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus)

[^6]: [MSFT_MpComputerStatus class | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus)

[^7]: [MSFT_MpPreference class (Windows) | Microsoft Learn](<https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/dn455323(v=vs.85)>)

[^8]: [MSFT_MpSignature class | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpsignature)

[^9]: [Installation and configuration for Windows Remote Management - Win32 apps | Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

[^10]: [Get-CimInstance (CimCmdlets) - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance?view=powershell-7.5)

[^11]: [Working with WMI - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5)

[^12]: [Microsoft Defender Antivirus compatibility with other security products - Microsoft Defender for Endpoint | Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)

[^13]: [Protect security settings with tamper protection - Microsoft Defender for Endpoint | Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)

[^14]: [Protect security settings with tamper protection - Microsoft Defender for Endpoint | Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)

[^15]: [Get-MpComputerStatus (Defender) | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps)

[^16]: [Microsoft Defender Antivirus compatibility with other security products - Microsoft Defender for Endpoint | Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)

[^17]: [Working with WMI - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi?view=powershell-7.5)

[^18]: [Remove-CimSession (CimCmdlets) - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/remove-cimsession?view=powershell-7.4)
