# Capture ZCC Diagnostics on Windows

Capture ZCC (Zscaler Client Connector) device-side diagnostics from a
USB-connected iOS device on a Windows host. This procedure captures device
syslog and VPN profile snapshots.

> **⚠ Network capture not available:** Windows does not support RVI (Remote
> Virtual Interface). This procedure captures **device logs and VPN profiles
> only** — no network packet data. For VPN tunnel-level diagnostics including
> TLS handshake analysis, use a macOS host. See
> [`capture-zcc-diagnostics-macos.md`](capture-zcc-diagnostics-macos.md).

**Prerequisite:** Complete [`setup-windows.md`](setup-windows.md) before
starting. libimobiledevice must be installed and the iOS device trusted.

---

## What This Capture Collects

| File                              | Content                                         |
| --------------------------------- | ----------------------------------------------- |
| `device_logs.txt`                 | Live iOS device syslog (ZCC client events)      |
| `vpn_profiles_initial_<time>.txt` | VPN / MDM profiles before reproducing the issue |
| `vpn_profiles_final_<time>.txt`   | VPN / MDM profiles after issue reproduction     |
| `device_info_<label>_<time>.txt`  | iOS device information                          |
| `system_info.txt`                 | Windows PC and connected device information     |
| `CAPTURE_SUMMARY.txt`             | Session summary with RVI limitation notice      |

**Not captured on Windows:**

| File                        | Reason                               |
| --------------------------- | ------------------------------------ |
| `zcc_vpn_capture_rvi*.pcap` | RVI is macOS-only                    |
| `tcpdump_*.log`             | Network packet capture not available |

---

## Steps

### 1. Open PowerShell and navigate to the scripts directory

```powershell
cd C:\path\to\device-capture-toolkit\scripts\windows
```

---

### 2. Start the capture

```powershell
.\Invoke-ZCCDiagnosticCapture.ps1
```

To specify a custom output directory:

```powershell
.\Invoke-ZCCDiagnosticCapture.ps1 -OutputDirectory "C:\ZCC_Diagnostics"
```

The script displays an RVI limitation notice and prompts for confirmation before
proceeding. Review the notice and answer **`y`** to continue with device-side
capture only.

The script:

1. Creates a timestamped output directory at `scripts\windows\logs\<timestamp>\`
2. Captures system information
3. Starts live device syslog capture as a background PowerShell job
4. Captures an initial VPN profile snapshot

---

### 3. Reproduce the ZCC issue

With the capture running, reproduce the issue on the iOS device:

1. Open ZCC on the iPhone.
2. Attempt to connect or disconnect the VPN.
3. If the VPN is intermittently failing, attempt the connection multiple times.
4. Note the **exact time** when the error occurs — this helps locate relevant
   entries in `device_logs.txt`.

The terminal displays:

```text
✅ Diagnostic capture is now ACTIVE

  1️⃣  Reproduce the ZCC VPN connection issue
  2️⃣  Attempt to connect/disconnect VPN multiple times
  3️⃣  Note the exact time when errors occur
  4️⃣  Press Ctrl+C when you have captured the issue
```

---

### 4. Stop the capture

Press **Ctrl+C** once the issue has been reproduced.

The cleanup handler:

1. Stops the background device log capture job
2. Captures a final VPN profile snapshot labelled `final`
3. Generates `CAPTURE_SUMMARY.txt`
4. Opens the output directory in Explorer

---

### 5. Review the captured output

**Search `device_logs.txt` for ZCC errors:**

```powershell
Select-String -Path "device_logs.txt" -Pattern "error|failed|fault" -Context 2

# Find VPN-related events
Select-String -Path "device_logs.txt" -Pattern "vpn|tunnel|zscaler" `
    -CaseSensitive:$false

# Find authentication issues
Select-String -Path "device_logs.txt" -Pattern "auth|credential|certificate" `
    -CaseSensitive:$false
```

**Compare VPN profile snapshots:**

```powershell
Compare-Object `
    (Get-Content "vpn_profiles_initial_*.txt") `
    (Get-Content "vpn_profiles_final_*.txt")
```

---

## Output Directory Structure

```text
scripts\windows\logs\20260220_143022\
├── CAPTURE_SUMMARY.txt
├── system_info.txt
├── device_logs.txt
├── vpn_profiles_initial_143022.txt
├── device_info_initial_143022.txt
├── vpn_profiles_final_143445.txt
└── device_info_final_143445.txt
```

---

## Escalating to macOS for Network-Level Diagnostics

If the device logs do not reveal the root cause, escalate to a macOS host for
full network capture. Issues that require macOS:

- VPN tunnel won't establish — need to see TLS handshake
- Intermittent VPN drops — network-level packet analysis required
- Certificate chain validation failures at wire level
- MTU/fragmentation problems
- DNS resolution failures to Zscaler endpoints

See [`capture-zcc-diagnostics-macos.md`](capture-zcc-diagnostics-macos.md) for
the macOS capture procedure.

---

## Troubleshooting

For issues during this procedure, see
[`../troubleshooting/capture-issues.md`](../troubleshooting/capture-issues.md).

---

**Last Updated**: February 2026
**Maintainer**: antyg
