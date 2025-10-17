# Method 6: MDE Client Analyzer Tool

## Overview

The Microsoft Defender for Endpoint Client Analyzer (`MDEClientAnalyzer.cmd`) is an official diagnostic tool[^1](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer) that performs comprehensive health checks, connectivity validation, and log collection for troubleshooting MDE deployment and operational issues[^2](https://learn.microsoft.com/en-us/defender-endpoint/data-collection-analyzer). The tool is regularly used by Microsoft Customer Support Services (CSS) to collect information for troubleshooting Microsoft Defender for Endpoint issues[^1](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer).

## Capabilities

- ✅ Comprehensive sensor health diagnostics
- ✅ Cloud connectivity validation
- ✅ Network configuration analysis
- ✅ Proxy/firewall troubleshooting
- ✅ Event log collection and analysis
- ✅ Performance trace generation
- ✅ Application compatibility diagnostics
- ✅ Automated report generation (HTML)

## Prerequisites

### System Requirements

- Windows 10 1607+ or Windows Server 2016+[^3](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/minimum-requirements) [^4](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-server-endpoints)
- Administrator privileges (local or via PsExec)
- Minimum 1 GB free disk space (for logs/traces)
- Internet connectivity for connectivity tests[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)

### Required Tools

- PowerShell 5.1 or higher
- PsExec.exe (SysInternals) - for cloud connectivity checks[^6](https://learn.microsoft.com/en-us/defender-endpoint/download-client-analyzer)
  - Download: https://live.sysinternals.com/PsExec.exe
  - Required only for connectivity validation

### Download Location

#### Official Microsoft Tool

- Download: [https://aka.ms/MDEAnalyzer](https://aka.ms/MDEAnalyzer) [^7](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)
- Extracts to: `MDEClientAnalyzer` folder
- Documentation: [https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer) [^1](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer)

## Running the Client Analyzer

### Basic Sensor Health Check

#### Command

```cmd
MDEClientAnalyzer.cmd
```

##### What it does

- Verifies SENSE service status[^8](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- Checks onboarding state[^9](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm)
- Validates registry configuration[^10](https://learn.microsoft.com/en-us/defender-endpoint/switch-to-mde-phase-2)
- Tests cloud connectivity[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- Collects basic diagnostic logs[^11](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)
- Generates HTML report[^12](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)

**Execution Time:** 2-5 minutes

**Output Location:** `MDEClientAnalyzerResult` subfolder

### View Available Parameters

```cmd
MDEClientAnalyzer.cmd /?
```

#### Parameter Categories

- `-h` - Performance traces (high CPU diagnostics)[^13](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui)
- `-c` - Application compatibility monitoring[^14](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-procmon)
- `-a` - Antivirus performance analysis[^15](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus)
- `-p` - Advanced connectivity tests
- No parameters - Standard sensor health check (recommended)

## Advanced Diagnostic Scenarios

### Performance Issues (High CPU)

**Scenario:** SENSE service (MsSense.exe) consuming high CPU[^8](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)

#### Command

```cmd
MDEClientAnalyzer.cmd -h
```

##### What it does

- Captures Windows Performance Recorder (WPR) trace[^13](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui)
- Records CPU, memory, disk activity
- Generates .etl trace file for analysis[^13](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui)
- Trace duration: 60-120 seconds

#### Analysis

1. Open .etl file in Windows Performance Analyzer (WPA)
2. Analyze CPU usage by process and thread
3. Identify performance bottlenecks

**Use Case:** Submit trace to Microsoft Support for performance troubleshooting

### Application Compatibility Issues

**Scenario:** Applications failing or behaving incorrectly after MDE deployment

#### Command

```cmd
MDEClientAnalyzer.cmd -c
```

##### What it does

- Launches Process Monitor (ProcMon) tool[^14](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-procmon)
- Captures real-time:
  - File system operations
  - Registry accesses
  - Process/thread activity
  - Network activity
- Generates .pml log file[^14](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-procmon)

#### Analysis

1. Open .pml in Process Monitor
2. Filter by problem application
3. Identify blocked file/registry access
4. Create MDE exclusions if appropriate

**Use Case:** Diagnose application conflicts with MDE

### Antivirus Performance Issues

**Scenario:** MsMpEng.exe (Defender Antivirus) consuming high CPU during scans[^15](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus)

#### Command

```cmd
MDEClientAnalyzer.cmd -a
```

##### What it does

- Captures performance trace specific to antivirus operations[^15](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus)
- Records scan activity and resource usage
- Generates .etl trace file[^15](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus)

#### Analysis Identify files/folders causing scan delays for potential exclusions

## Connectivity Validation

### Cloud Connectivity Test

#### Prerequisites

- PsExec.exe in same folder as MDEClientAnalyzer.cmd[^6](https://learn.microsoft.com/en-us/defender-endpoint/download-client-analyzer)
- OR in system PATH
- Local Administrator privileges

#### Automatic Test (Included in Standard Run)

The analyzer automatically tests connectivity to MDE cloud endpoints[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity):

- `*.blob.core.windows.net`[^16](https://learn.microsoft.com/en-us/defender-endpoint/configure-environment)
- `*.microsoft.com`[^16](https://learn.microsoft.com/en-us/defender-endpoint/configure-environment)
- `crl.microsoft.com`
- `*.windowsupdate.com`
- Cloud service endpoints by region (US, EU, UK, etc.)[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)

##### What it validates

- DNS resolution[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- HTTPS connectivity (port 443)[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- Certificate validation[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- Proxy configuration[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- Authentication requirements

### Proxy Configuration Issues

#### Common Findings

- Proxy not configured for WinHTTP
- Proxy requires authentication (not supported by default)
- SSL/TLS inspection blocking certificate validation

#### Remediation Guidance Provided

Analyzer output includes specific netsh commands to configure proxy

##### Example

```cmd
netsh winhttp set proxy proxy-server="proxy.contoso.com:8080" bypass-list="<local>"
```

## Output Analysis

### HTML Report Structure

#### Report Sections

1. **Summary** - Overall health status (Pass/Fail)[^12](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)
2. **Onboarding State** - Registry key validation[^9](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm)
3. **Service Status** - SENSE and DiagTrack service checks[^8](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding) [^17](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
4. **Connectivity Tests** - Cloud endpoint reachability[^5](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
5. **Event Log Errors** - Recent SENSE operational log errors
6. **Configuration Issues** - Misconfigurations detected
7. **Recommendations** - Actionable remediation steps[^12](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)

### Health Status Indicators

| Indicator      | Meaning                            | Action Required          |
| -------------- | ---------------------------------- | ------------------------ |
| ✅ **Pass**    | Check completed successfully       | None                     |
| ⚠️ **Warning** | Non-critical issue detected        | Review recommendation    |
| ❌ **Fail**    | Critical issue requiring attention | Follow remediation steps |
| ℹ️ **Info**    | Informational only                 | None                     |

### Sample Report Findings

#### Healthy Configuration

```text
✅ Onboarding State: Device is onboarded (OrgId: 12345678-...)
✅ SENSE Service: Running (Automatic startup)
✅ DiagTrack Service: Running (Automatic startup)
✅ Cloud Connectivity: All endpoints reachable
✅ Event Log: No errors in last 7 days
✅ Configuration: No issues detected
```

#### Problematic Configuration

```text
❌ Onboarding State: Device NOT onboarded (OnboardingState = 0)
✅ SENSE Service: Running (Automatic startup)
⚠️ DiagTrack Service: Stopped (Manual startup)
❌ Cloud Connectivity: Failed to reach *.blob.core.windows.net
   Recommendation: Verify firewall allows HTTPS to *.blob.core.windows.net
❌ Event Log: 15 errors in last 7 days (Event ID 15 - Connectivity)
⚠️ Configuration: Proxy not configured for WinHTTP
   Recommendation: Run 'netsh winhttp set proxy...'
```

## Log Collection

### Collected Artifacts

#### Standard Run

- Registry exports:
  - `HKLM\SOFTWARE\Microsoft\Windows Advanced Threat Protection`[^10](https://learn.microsoft.com/en-us/defender-endpoint/switch-to-mde-phase-2)
  - `HKLM\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection`[^10](https://learn.microsoft.com/en-us/defender-endpoint/switch-to-mde-phase-2)
- Event logs:
  - SENSE Operational log
  - Windows Defender log
  - Application log (WDATPOnboarding)
- Service configurations (SENSE, DiagTrack)
- Network configuration (proxy, DNS)
- Process list snapshot

#### Performance Trace Run (-h, -a)

- Windows Performance Recorder .etl file
- CPU, memory, disk, network traces
- Process/thread activity

#### Application Compatibility Run (-c)

- Process Monitor .pml file
- File system operations
- Registry operations
- Network operations

### Log Locations

**Output Folder:** `MDEClientAnalyzerResult` (created in same directory as script)

#### Subfolder Structure

```text
MDEClientAnalyzerResult/
├── MDEClientAnalyzer.htm          # Main HTML report
├── MDEClientAnalyzer.xml          # Machine-readable results
├── MDEClientAnalyzer.cab          # Compressed logs (for Microsoft Support)
├── Logs/
│   ├── SENSE-Operational.evtx
│   ├── Registry-ATP.txt
│   ├── Services.txt
│   └── Connectivity.txt
└── Traces/                        # Only if -h, -c, or -a used
    └── Performance.etl or ProcessMonitor.pml
```

## Troubleshooting with Analyzer Results

### Issue: Connectivity Test Failures

#### Analyzer Finding

```text
❌ Connectivity Test Failed: au.vortex-win.data.microsoft.com (Port 443)
Error: The connection has timed out
```

#### Remediation Steps

1. Verify URL in firewall allow list
2. Test manually: `Test-NetConnection au.vortex-win.data.microsoft.com -Port 443`
3. Check proxy configuration: `netsh winhttp show proxy`
4. Review SSL inspection policies (may block certificate validation)

### Issue: Proxy Authentication Required

#### Analyzer Finding

```text
⚠️ Proxy Configuration: Proxy requires authentication
Note: SENSE service runs as SYSTEM and cannot use user credentials
```

#### Remediation Steps

1. Configure proxy bypass for MDE endpoints
2. OR use transparent proxy (no authentication)
3. OR use MDE with direct internet access (no proxy)

**Not Supported:** Authenticated proxy for SENSE service

### Issue: OnboardingState = 0

#### Analyzer Finding

```text
❌ Onboarding State: Device NOT onboarded
Registry Key: HKLM\...\Status\OnboardingState = 0
```

#### Remediation Steps

1. Download onboarding script from MDE portal
2. Run script with administrator privileges
3. Verify DiagTrack service running: `Start-Service DiagTrack`
4. Re-run analyzer after 5 minutes to confirm

### Issue: Event ID 7 (Configuration Error)

#### Analyzer Finding

```text
❌ Event Log Errors Detected
Event ID 7: Sensor configuration error
Message: Onboarding blob missing or invalid
```

#### Remediation Steps

1. Verify onboarding policy applied:
   - Group Policy: `gpupdate /force`
   - Intune: Wait for policy sync or trigger manual sync
   - SCCM: Verify deployment targeted to device
2. Check registry: `HKLM\SOFTWARE\Policies\...\OnboardingInfo`
3. Re-run onboarding script manually

## Remote Execution via Live Response

### Prerequisites

- Device onboarded to MDE
- Live Response enabled in MDE settings[^18](https://learn.microsoft.com/en-us/defender-endpoint/live-response)
- Security Operator role or higher[^18](https://learn.microsoft.com/en-us/defender-endpoint/live-response)

### Steps

1. Navigate to device page in MDE portal[^18](https://learn.microsoft.com/en-us/defender-endpoint/live-response)
2. Click **Initiate Live Response Session**[^18](https://learn.microsoft.com/en-us/defender-endpoint/live-response)
3. Upload MDEClientAnalyzer.cmd to device[^19](https://learn.microsoft.com/en-us/defender-endpoint/api/upload-library)
4. Run analyzer:

   ```cmd
   MDEClientAnalyzer.cmd
   ```

5. Download generated .cab file
6. Extract and review HTML report locally

**Use Case:** Diagnose onboarded devices without RDP/WinRM access[^18](https://learn.microsoft.com/en-us/defender-endpoint/live-response)

## Integration with Other Validation Methods

### After PowerShell Validation Fails

If [Method 1: PowerShell](./01-PowerShell-Validation.md) shows `ComputerState ≠ 0`:

1. Run Client Analyzer for detailed diagnostics
2. Review HTML report for specific errors
3. Apply recommended fixes
4. Re-run PowerShell validation to confirm

### Before Escalating to Microsoft Support

1. Run Client Analyzer with appropriate flags
2. Collect generated .cab file
3. Include .cab in support case for faster resolution

### Validating Connectivity for Bulk Deployment

Before deploying MDE to 1,000+ devices:

1. Run Client Analyzer on pilot devices (5-10)
2. Verify connectivity from each network segment
3. Identify proxy/firewall issues early
4. Apply fixes organization-wide

## Automation Considerations

### Scripted Execution

```powershell
$OutputPath = "C:\MDEAnalyzer"
New-Item -ItemType Directory -Path $OutputPath -Force
Copy-Item "\\share\Tools\MDEClientAnalyzer\*" -Destination $OutputPath -Recurse
Set-Location $OutputPath
& .\MDEClientAnalyzer.cmd

Move-Item ".\MDEClientAnalyzerResult" "C:\Reports\$env:COMPUTERNAME-$(Get-Date -Format 'yyyyMMdd')"
```

### CSV Bulk Validation Workflow

**Not Recommended:** Client Analyzer designed for deep diagnostics, not bulk validation

#### For bulk validation from CSV, use

- [Method 1: PowerShell Validation](./01-PowerShell-Validation.md) with `Get-MDEStatus.ps1`
- [Method 4: Registry/Service Validation](./04-Registry-Service-Validation.md) with `Get-MDEStatus.ps1`

#### Use Client Analyzer only for

- Devices identified as problematic by bulk validation
- Deep diagnostics for escalation to Microsoft Support

## Best Practices

1. ✅ Run without parameters first (standard health check)
2. ✅ Use -h, -c, or -a flags only when diagnosing specific issues
3. ✅ Ensure PsExec.exe available for connectivity tests
4. ✅ Review HTML report before submitting .cab to support
5. ✅ Run analyzer after every configuration change to validate fix
6. ✅ Save analyzer results with timestamps for trending
7. ❌ Don't run performance traces (-h, -a) on production systems during business hours

## Limitations

- ❌ Requires local administrator access
- ❌ Cannot run remotely without Live Response or PSRemoting
- ❌ Performance traces impact system performance temporarily
- ❌ Not suitable for bulk validation (designed for deep diagnostics)
- ⚠️ PsExec requirement may conflict with security policies

## Output Interpretation Guide

### Connectivity Test Results

#### Success

```text
Testing connectivity to https://au.vortex-win.data.microsoft.com
✅ DNS Resolution: Success (IP: 13.107.5.88)
✅ TCP Connection: Success (Port 443)
✅ HTTPS GET: Success (HTTP 200)
✅ Certificate Validation: Success
```

#### Failure

```text
Testing connectivity to https://au-v20.events.data.microsoft.com
✅ DNS Resolution: Success (IP: 13.107.6.171)
❌ TCP Connection: Failed (Connection timeout)
Possible Causes:
- Firewall blocking outbound HTTPS
- Proxy misconfigured
- Network routing issue
```

### SENSE Service Analysis

#### Healthy

```text
Service Name: SENSE
Display Name: Windows Defender Advanced Threat Protection Service
Status: Running
Startup Type: Automatic
Process ID: 4512
Memory Usage: 45 MB
CPU Time: 00:02:15
```

#### Unhealthy

```text
Service Name: SENSE
Display Name: Windows Defender Advanced Threat Protection Service
Status: Stopped
Startup Type: Manual  ← Should be Automatic
Last Exit Code: 1 (ERROR_INVALID_FUNCTION)
```

## Next Steps

- For bulk device validation: [Method 1: PowerShell](./01-PowerShell-Validation.md)
- For registry-level checks: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
- For organization-wide status: [Method 2: Graph API](./02-Graph-API-Validation.md)
- For WMI-based queries: [Method 7: WMI/CIM](./07-WMI-CIM-Validation.md)

## References

[^1]: [Troubleshoot sensor health using Microsoft Defender for Endpoint Client Analyzer](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer)

[^2]: [Data collection for advanced troubleshooting on Windows](https://learn.microsoft.com/en-us/defender-endpoint/data-collection-analyzer)

[^3]: [Minimum requirements for Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/minimum-requirements)

[^4]: [Onboard servers through Microsoft Defender for Endpoint's onboarding experience](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-server-endpoints)

[^5]: [Verify client connectivity to Microsoft Defender for Endpoint service URLs](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)

[^6]: [Download the Microsoft Defender for Endpoint client analyzer](https://learn.microsoft.com/en-us/defender-endpoint/download-client-analyzer)

[^7]: [Run the client analyzer on Windows](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)

[^8]: [Troubleshoot Microsoft Defender for Endpoint onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)

[^9]: [Onboard Windows devices using Configuration Manager](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-sccm)

[^10]: [Migrate to Microsoft Defender for Endpoint - Setup](https://learn.microsoft.com/en-us/defender-endpoint/switch-to-mde-phase-2)

[^11]: [Understand the client analyzer HTML report](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)

[^12]: [Understand the client analyzer HTML report](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)

[^13]: [Troubleshoot Microsoft Defender Antivirus performance issues with WPRUI](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui)

[^14]: [Troubleshoot Microsoft Defender Antivirus performance issues with Process Monitor](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-procmon)

[^15]: [Performance analyzer for Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus)

[^16]: [Configure your network environment to ensure connectivity with Defender for Endpoint service](https://learn.microsoft.com/en-us/defender-endpoint/configure-environment)

[^17]: [Troubleshoot Microsoft Defender for Endpoint onboarding issues - DiagTrack service](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)

[^18]: [Investigate entities on devices using live response in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/live-response)

[^19]: [Upload files to the live response library](https://learn.microsoft.com/en-us/defender-endpoint/api/upload-library)
