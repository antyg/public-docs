# Script Reference

Inventory of published scripts in the `scripts/` directory with parameters,
output files, and requirements.

---

## macOS Scripts

### `scripts/macos/setup.sh`

**Purpose:** Verify prerequisites and prepare the macOS environment for ZCC
diagnostic capture. Checks macOS version, required commands, device logging
tools, RVI capability, connected devices, sudo access, and disk space. Creates
the RVI interface automatically when a device is connected.

**Usage:**

```bash
./setup.sh
```

**Parameters:** None — interactive prompts for Homebrew and libimobiledevice
installation.

**Output:** Console summary only (no files written). Sets `chmod +x` on
`capture_diagnostics.sh`.

**Requirements:**

| Requirement      | Details                                                        |
| ---------------- | -------------------------------------------------------------- |
| macOS version    | 11+ recommended                                                |
| Sudo             | Required for `rvictl -s` (RVI creation)                        |
| Homebrew         | Prompted for installation if missing                           |
| Device logging   | `cfgutil` or `idevicesyslog` (installed if Homebrew available) |
| Connected device | Optional at setup time — can run before connecting             |

**Exit codes:**

| Code | Meaning                                    |
| ---- | ------------------------------------------ |
| `0`  | Setup completed (may include warnings)     |
| `1`  | `log` command not found (hard requirement) |

---

### `scripts/macos/capture_diagnostics.sh`

**Purpose:** Capture ZCC VPN diagnostics from a USB-connected iOS device.
Captures device syslog, VPN profile snapshots at initial and final checkpoints,
network packets via RVI (`tcpdump`), and generates a session summary.

**Usage:**

```bash
sudo ./capture_diagnostics.sh
```

Sudo is required for `tcpdump` network packet capture. The script prompts to
continue without sudo if not elevated.

**Parameters:** None — all configuration is derived from script environment.

**Output directory:** `scripts/macos/logs/<YYYYMMDD_HHmmss>/`

**Output files:**

| File                               | Content                                               |
| ---------------------------------- | ----------------------------------------------------- |
| `system_info.txt`                  | Mac hardware/software profile + connected device list |
| `device_logs.txt`                  | Live iOS device syslog (streams until Ctrl+C)         |
| `vpn_profiles_initial_<time>.txt`  | Installed profiles at capture start                   |
| `device_info_initial_<time>.txt`   | Device type, model, serial, UDID at start             |
| `vpn_profiles_final_<time>.txt`    | Installed profiles at capture stop                    |
| `device_info_final_<time>.txt`     | Device info at capture stop                           |
| `zcc_vpn_capture_<rvi_iface>.pcap` | Full device network traffic (Wireshark format)        |
| `tcpdump_<rvi_iface>.log`          | tcpdump verbose output                                |
| `CAPTURE_SUMMARY.txt`              | Session overview, file descriptions, analysis tips    |

**Requirements:**

| Requirement    | Details                                                |
| -------------- | ------------------------------------------------------ |
| Sudo           | Required for tcpdump                                   |
| Device logging | `cfgutil` (preferred) or `idevicesyslog`               |
| RVI interface  | Created automatically via `rvictl` if device connected |
| tcpdump        | Bundled with macOS                                     |
| rvictl         | Bundled with macOS                                     |

**Signal handling:** `trap cleanup EXIT INT TERM` — cleanup runs on Ctrl+C,
normal exit, or termination signal. Cleanup stops all background processes,
removes RVI interfaces, captures final profile snapshot, and generates summary.

---

## Windows Scripts

### `scripts/windows/Setup-ZCCDiagnostics.ps1`

**Purpose:** Verify prerequisites and prepare the Windows environment for
device-side ZCC diagnostic capture. Checks Windows version, administrator
privileges, Chocolatey, libimobiledevice, and connected iOS devices. Displays
the RVI limitation notice.

**Usage:**

```powershell
# Interactive
.\Setup-ZCCDiagnostics.ps1

# Automatic dependency installation (no prompts)
.\Setup-ZCCDiagnostics.ps1 -InstallDependencies
```

**Parameters:**

| Parameter              | Type   | Default  | Description                                    |
| ---------------------- | ------ | -------- | ---------------------------------------------- |
| `-InstallDependencies` | Switch | `$false` | Install missing dependencies without prompting |

**Output:** Console summary only (no files written).

**Requirements:**

| Requirement     | Details                                                   |
| --------------- | --------------------------------------------------------- |
| PowerShell      | 5.1 or later (`#Requires -Version 5.1`)                   |
| Windows version | 10+ recommended                                           |
| Administrator   | Required for Chocolatey and libimobiledevice installation |
| Apple drivers   | iTunes or Apple Devices app (for USB connectivity)        |

**Exit codes:**

| Code | Meaning                                            |
| ---- | -------------------------------------------------- |
| `0`  | Setup completed or user cancelled                  |
| `1`  | Administrator privileges required for installation |

---

### `scripts/windows/Invoke-ZCCDiagnosticCapture.ps1`

**Purpose:** Capture ZCC device-side diagnostics from a USB-connected iOS
device on Windows. Captures device syslog, VPN profile snapshots, and system
information. Network packet capture is not available on Windows.

**Usage:**

```powershell
# Default output directory
.\Invoke-ZCCDiagnosticCapture.ps1

# Custom output directory
.\Invoke-ZCCDiagnosticCapture.ps1 -OutputDirectory "C:\ZCC_Diagnostics"
```

**Parameters:**

| Parameter          | Type   | Default              | Description                  |
| ------------------ | ------ | -------------------- | ---------------------------- |
| `-OutputDirectory` | String | `.\logs\<timestamp>` | Custom output directory path |

**Output directory:** `scripts\windows\logs\<YYYYMMDD_HHmmss>\` (default)

**Output files:**

| File                              | Content                                             |
| --------------------------------- | --------------------------------------------------- |
| `system_info.txt`                 | Windows PC info + connected device list             |
| `device_logs.txt`                 | Live iOS device syslog (captured as background job) |
| `vpn_profiles_initial_<time>.txt` | Provisioning profiles at capture start              |
| `device_info_initial_<time>.txt`  | Device information at start                         |
| `vpn_profiles_final_<time>.txt`   | Provisioning profiles at capture stop               |
| `device_info_final_<time>.txt`    | Device information at stop                          |
| `CAPTURE_SUMMARY.txt`             | Session overview with RVI limitation notice         |

**Requirements:**

| Requirement      | Details                                            |
| ---------------- | -------------------------------------------------- |
| PowerShell       | 5.1 or later                                       |
| libimobiledevice | `idevicesyslog`, `ideviceinfo`, `ideviceprovision` |
| Apple drivers    | iTunes or Apple Devices app                        |
| Administrator    | Not required for capture (only for setup)          |

**Cleanup handling:** `Register-EngineEvent -SourceIdentifier PowerShell.Exiting`
— stops background log capture job, captures final profile snapshot, generates
summary, and opens output directory on exit.

---

## Script Version History

| Script                            | Version | Notes                           |
| --------------------------------- | ------- | ------------------------------- |
| `setup.sh`                        | 1.0     | Initial release — ZCC VPN focus |
| `capture_diagnostics.sh`          | 1.0     | Initial release — ZCC VPN focus |
| `Setup-ZCCDiagnostics.ps1`        | 1.0     | Initial release                 |
| `Invoke-ZCCDiagnosticCapture.ps1` | 1.0     | Initial release                 |

---

**Last Updated**: February 2026
**Maintainer**: antyg
