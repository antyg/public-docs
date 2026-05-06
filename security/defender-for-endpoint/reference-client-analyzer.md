---
title: "MDE Client Analyzer Reference"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers diagnosing MDE deployment failures or preparing support cases"
document_type: "reference"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# MDE Client Analyzer Reference

---

## What It Is

The [MDE Client Analyzer](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer) (`MDEClientAnalyzer.cmd`) is Microsoft's official diagnostic tool for troubleshooting Defender for Endpoint deployment and operational issues. It performs comprehensive health checks, cloud connectivity validation, proxy analysis, and log collection, producing an HTML report and a compressed `.cab` file suitable for submission to Microsoft Customer Support Services.

Use the Client Analyzer when other validation methods (PowerShell, registry, portal) have identified a problem but have not pinpointed the root cause. It is not suitable for bulk validation — use [Get-MDEStatus.ps1](../scripts/README.md) for that purpose.

---

## Prerequisites

- Windows 10 1607+ or Windows Server 2016+ ([MDE minimum requirements](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/minimum-requirements))
- Local administrator privileges (or run via PsExec as SYSTEM)
- At least 1 GB free disk space (for logs and traces)
- Internet connectivity to MDE cloud endpoints (tested during the run)
- [PsExec.exe](https://learn.microsoft.com/en-us/defender-endpoint/download-client-analyzer) (SysInternals) in the same folder as `MDEClientAnalyzer.cmd` — required for cloud connectivity tests

---

## Download and Extract

Official download: [https://aka.ms/MDEAnalyzer](https://aka.ms/MDEAnalyzer) ([run analyzer guide](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows))

The archive extracts to an `MDEClientAnalyzer` folder. Copy `PsExec.exe` into the same folder before running.

---

## Running the Analyzer

### Standard Health Check (Recommended First Step)

```cmd
MDEClientAnalyzer.cmd
```

Execution time: 2–5 minutes. Output is written to `MDEClientAnalyzerResult\` in the same directory.

### Available Flags

| Flag | Purpose | When to Use |
|------|---------|-------------|
| (none) | Standard sensor health, connectivity, registry, event log | Always run first |
| `-h` | Windows Performance Recorder trace for high CPU diagnostics | MsSense.exe or MsMpEng.exe consuming excessive CPU |
| `-c` | Process Monitor (ProcMon) capture for application compatibility | Applications failing after MDE deployment |
| `-a` | Antivirus-specific performance trace | Defender antivirus scanning causing CPU/IO spikes |

Do not run performance trace flags (`-h`, `-a`) on production systems during business hours — they temporarily increase resource usage.

### Flag Detail: -h (Performance Traces — High CPU)

The `-h` flag captures a [Windows Performance Recorder (WPR)](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui) trace covering CPU, memory, disk, and network activity. The trace runs for 60–120 seconds and produces a `.etl` file under `MDEClientAnalyzerResult\Traces\`.

To analyse the trace:
1. Open the `.etl` file in [Windows Performance Analyser (WPA)](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-wprui)
2. Navigate to the CPU Usage graph
3. Identify CPU consumption by process and thread to pinpoint the bottleneck

The resulting `.etl` file can be included in a Microsoft Support case for performance troubleshooting of `MsSense.exe`.

### Flag Detail: -c (Application Compatibility)

The `-c` flag launches [Process Monitor (ProcMon)](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-av-performance-issues-with-procmon) and captures real-time file system operations, registry accesses, process and thread activity, and network activity. Output is a `.pml` log file under `MDEClientAnalyzerResult\Traces\`.

To analyse the capture:
1. Open the `.pml` file in Process Monitor
2. Filter by the problem application's process name
3. Identify blocked or failing file and registry access operations
4. Evaluate whether MDE exclusions are appropriate for confirmed false-positive blocks

### Flag Detail: -a (Antivirus Performance)

The `-a` flag captures an [antivirus-specific performance trace](https://learn.microsoft.com/en-us/defender-endpoint/tune-performance-defender-antivirus) recording scan activity and resource usage by `MsMpEng.exe`. Output is a `.etl` file under `MDEClientAnalyzerResult\Traces\`.

Analyse the trace to identify which files or folders are causing scan delays. These are the primary candidates for antivirus exclusions if confirmed safe.

### Run via Live Response (No RDP Required)

For onboarded devices without WinRM or RDP access ([Live Response guide](https://learn.microsoft.com/en-us/defender-endpoint/live-response)):

1. In the Microsoft Defender portal, navigate to the device page
2. Click **Initiate Live Response Session**
3. Upload `MDEClientAnalyzer.cmd` and `PsExec.exe` to the device
4. Run: `MDEClientAnalyzer.cmd`
5. Download the generated `.cab` file and review the HTML report locally

---

## Output Structure

```text
MDEClientAnalyzerResult/
├── MDEClientAnalyzer.htm          # Main HTML report (open in browser)
├── MDEClientAnalyzer.xml          # Machine-readable results
├── MDEClientAnalyzer.cab          # Compressed log bundle for Microsoft Support
├── Logs/
│   ├── SENSE-Operational.evtx    # SENSE event log export
│   ├── Registry-ATP.txt          # Registry key exports
│   ├── Services.txt              # Service configuration snapshot
│   └── Connectivity.txt          # Connectivity test results
└── Traces/                        # Only present when -h, -c, or -a used
    └── Performance.etl or ProcessMonitor.pml
```

---

## Interpreting the HTML Report

The report is divided into sections ([analyzer report guide](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)):

| Section | What It Shows |
|---------|--------------|
| Summary | Overall Pass/Fail health status |
| Onboarding State | Registry key validation (`OnboardingState`, `OrgId`) |
| Service Status | SENSE and DiagTrack service state and startup type |
| Connectivity Tests | Reachability of MDE cloud endpoints |
| Event Log Errors | Recent SENSE operational log errors |
| Configuration Issues | Misconfigurations detected |
| Recommendations | Specific remediation steps |

### Status Indicators

| Indicator | Meaning |
|-----------|---------|
| Pass | Check completed successfully |
| Warning | Non-critical issue — review the recommendation |
| Fail | Critical issue requiring remediation |
| Info | Informational only |

---

## Common Findings and Remediation

### Connectivity Failure

```text
FAIL: TCP Connection to au-v20.events.endpoint.security.microsoft.com:443 timed out
```

Actions:
1. Verify the URL is in the firewall outbound allowlist
2. Test manually: `Test-NetConnection au-v20.events.endpoint.security.microsoft.com -Port 443`
3. Check proxy configuration: `netsh winhttp show proxy`
4. Review SSL/TLS inspection policies — MDE endpoints must not have their certificates substituted

([MDE connectivity verification](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity))

### Proxy Authentication Required

```text
WARNING: Proxy requires authentication
NOTE: SENSE service runs as SYSTEM and cannot use user credentials
```

SENSE cannot authenticate to proxies using user credentials. Options:

- Configure proxy bypass for all MDE endpoint URLs
- Use a transparent proxy (no authentication)
- Provide direct internet access for MDE endpoints

### OnboardingState = 0

```text
FAIL: Device NOT onboarded (OnboardingState = 0)
```

Actions:
1. Download the onboarding script from the MDE portal (Settings > Endpoints > Onboarding)
2. Run as administrator on the device
3. Verify DiagTrack service is running: `Start-Service DiagTrack`
4. Re-run the analyzer after 5 minutes

### Event ID 7 — Configuration Error

```text
FAIL: Event ID 7 detected — Onboarding blob missing or invalid
```

Actions:
1. Group Policy: `gpupdate /force`, then verify `HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection\OnboardingInfo`
2. Intune: Trigger a manual policy sync (Company Portal > Sync)
3. Manual: Re-run the onboarding script

---

## Escalating to Microsoft Support

Before raising a support case, run the analyzer and collect the `.cab` file. Include this file in the support case — it significantly reduces the time to resolution by providing Microsoft CSS with all required diagnostic data ([data collection guide](https://learn.microsoft.com/en-us/defender-endpoint/data-collection-analyzer)).

Run with the appropriate additional flag if the issue is performance-related:

```cmd
# High CPU from MsSense.exe
MDEClientAnalyzer.cmd -h

# Application compatibility issues after MDE deployment
MDEClientAnalyzer.cmd -c
```

---

## Related Resources

- [MDE Client Analyzer overview](https://learn.microsoft.com/en-us/defender-endpoint/overview-client-analyzer)
- [Run the client analyzer on Windows](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)
- [Analyzer report interpretation](https://learn.microsoft.com/en-us/defender-endpoint/analyzer-report)
- [MDE data collection guide](https://learn.microsoft.com/en-us/defender-endpoint/data-collection-analyzer)
- [Verify connectivity to MDE service URLs](https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity)
- [MDE Live Response](https://learn.microsoft.com/en-us/defender-endpoint/live-response)
- [Registry and service reference](registry-service-reference.md)
- [Validation methods overview](explanation-validation-methods-overview.md)
