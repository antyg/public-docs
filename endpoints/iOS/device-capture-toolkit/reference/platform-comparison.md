# Platform Comparison — macOS vs Windows

Capability reference for macOS and Windows hosts running the iOS device capture
toolkit.

---

## Capability Matrix

| Capability                                    | macOS host                                               | Windows host                            |
| --------------------------------------------- | -------------------------------------------------------- | --------------------------------------- |
| **Device syslog capture**                     | ✅ `cfgutil syslog` or `idevicesyslog`                   | ✅ `idevicesyslog`                      |
| **VPN profile snapshots**                     | ✅ `cfgutil get installedProfiles` or `ideviceprovision` | ✅ `ideviceprovision`                   |
| **Device info capture**                       | ✅ `cfgutil get` or `ideviceinfo`                        | ✅ `ideviceinfo`                        |
| **RVI network capture**                       | ✅ `rvictl` + `tcpdump`                                  | ❌ Not available                        |
| **TLS handshake analysis**                    | ✅ Via `.pcap` + Wireshark                               | ❌ Not available                        |
| **Certificate chain validation (wire level)** | ✅ Via `.pcap`                                           | ⚠️ Device logs only                     |
| **MTU / fragmentation diagnostics**           | ✅ Via `.pcap`                                           | ❌ Not available                        |
| **Split-tunnel routing visibility**           | ✅ Via `.pcap`                                           | ❌ Not available                        |
| **DNS query capture**                         | ✅ Via `.pcap`                                           | ⚠️ Device logs only                     |
| **ZCC client crash diagnostics**              | ✅                                                       | ✅                                      |
| **VPN profile configuration analysis**        | ✅                                                       | ✅                                      |
| **Authentication errors (app-level)**         | ✅                                                       | ✅                                      |
| **Setup tool**                                | `setup.sh` (Homebrew)                                    | `Setup-ZCCDiagnostics.ps1` (Chocolatey) |
| **Capture tool**                              | `capture_diagnostics.sh`                                 | `Invoke-ZCCDiagnosticCapture.ps1`       |
| **Sudo / admin required**                     | Yes (tcpdump + rvictl)                                   | Yes (package installation)              |

---

## Why RVI Is macOS-Only

RVI (Remote Virtual Interface) depends on Apple CoreDevice frameworks that are
only present on macOS. The cross-platform `libimobiledevice` library provides
device logging and profile access on Windows but cannot create virtual network
interfaces.

| RVI dependency                          | macOS                                | Windows            |
| --------------------------------------- | ------------------------------------ | ------------------ |
| `rvictl` command                        | ✅ Included with macOS / Xcode tools | ❌ Not available   |
| Apple CoreDevice framework              | ✅                                   | ❌                 |
| Kernel-level virtual interface creation | ✅                                   | ❌                 |
| libimobiledevice network capture        | N/A                                  | ❌ Not implemented |

---

## Diagnostic Decision Guide

Use this table to choose the correct platform for a given ZCC issue.

| Symptom                                      | Recommended host     | Reason                                 |
| -------------------------------------------- | -------------------- | -------------------------------------- |
| VPN tunnel won't establish                   | **macOS**            | Requires TLS handshake packet capture  |
| Intermittent VPN drops                       | **macOS**            | Network-level packet analysis required |
| Certificate validation errors                | **macOS**            | Wire-level cert chain inspection       |
| MTU / fragmentation issues                   | **macOS**            | Packet size analysis in `.pcap`        |
| DNS failures to Zscaler endpoints            | **macOS**            | DNS query / response packets needed    |
| ZCC client app crashes                       | macOS or **Windows** | Device logs sufficient                 |
| ZCC VPN profile misconfiguration             | macOS or **Windows** | Profile snapshot sufficient            |
| SSO / SAML authentication errors (app-level) | macOS or **Windows** | Device logs sufficient                 |
| Initial triage — unknown root cause          | **macOS**            | Captures everything; nothing missed    |

---

## Output File Comparison

| File                              | macOS | Windows |
| --------------------------------- | ----- | ------- |
| `CAPTURE_SUMMARY.txt`             | ✅    | ✅      |
| `system_info.txt`                 | ✅    | ✅      |
| `device_logs.txt`                 | ✅    | ✅      |
| `vpn_profiles_initial_<time>.txt` | ✅    | ✅      |
| `vpn_profiles_final_<time>.txt`   | ✅    | ✅      |
| `device_info_<label>_<time>.txt`  | ✅    | ✅      |
| `zcc_vpn_capture_rvi0.pcap`       | ✅    | ❌      |
| `tcpdump_rvi0.log`                | ✅    | ❌      |

---

## Setup Complexity

| Factor                   | macOS                                             | Windows                     |
| ------------------------ | ------------------------------------------------- | --------------------------- |
| Package manager          | Homebrew (`brew`)                                 | Chocolatey (`choco`)        |
| Primary device tool      | `cfgutil` (Apple Configurator) or `idevicesyslog` | `idevicesyslog` only        |
| Apple driver requirement | Built-in                                          | iTunes or Apple Devices app |
| Sudo / admin for setup   | Required (Homebrew, rvictl)                       | Required (Chocolatey)       |
| Xcode tools              | Not required (rvictl is bundled with macOS)       | N/A                         |

---

**Last Updated**: February 2026
**Maintainer**: antyg
