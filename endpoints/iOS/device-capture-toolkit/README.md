# iOS / iPadOS Device Capture Toolkit

**Status**: ✅ Published

## Overview

Host-machine tooling for capturing comprehensive iOS/iPadOS device diagnostics
from a USB-connected Mac or Windows workstation. Designed for ZCC (Zscaler
Client Connector) VPN troubleshooting — captures device-side logs, VPN profile
snapshots, and (on macOS) full network packet capture via RVI.

---

## When to Use This Toolkit

| Scenario                                                  | Use This Toolkit | Use Instead                                                                          |
| --------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ |
| ZCC VPN fails to connect or drops                         | ✅               | —                                                                                    |
| ADE enrolment fails or stalls                             | ✅               | —                                                                                    |
| App authentication issues (ZCC, SSO)                      | ✅               | —                                                                                    |
| Admin-initiated diagnostic collection from Intune console | ❌               | [`../intune/ios-diagnostic-logging/`](../../intune/ios-diagnostic-logging/README.md) |
| Company Portal upload of device logs                      | ❌               | [`../intune/ios-diagnostic-logging/`](../../intune/ios-diagnostic-logging/README.md) |

---

## Platform Capability Summary

| Capability                          | macOS host             | Windows host     |
| ----------------------------------- | ---------------------- | ---------------- |
| Device syslog capture               | ✅                     | ✅               |
| VPN profile snapshots               | ✅                     | ✅               |
| Network packet capture (RVI)        | ✅ Full device traffic | ❌ Not available |
| TLS handshake analysis              | ✅                     | ❌               |
| ZCC split-tunnel routing visibility | ✅                     | ❌               |

For a complete comparison, see [`reference/platform-comparison.md`](reference/platform-comparison.md).

---

## Folder Structure

| Path                                              | Diataxis Type   | Content                                              |
| ------------------------------------------------- | --------------- | ---------------------------------------------------- |
| `how-to/setup-macos.md`                           | How-to          | Prepare a Mac host for diagnostic capture            |
| `how-to/setup-windows.md`                         | How-to          | Prepare a Windows host for diagnostic capture        |
| `how-to/capture-zcc-diagnostics-macos.md`         | How-to          | Run a ZCC diagnostic capture session on macOS        |
| `how-to/capture-zcc-diagnostics-windows.md`       | How-to          | Run a ZCC diagnostic capture session on Windows      |
| `reference/concepts.md`                           | Reference       | RVI, cfgutil, idevicesyslog, ZCC log scope           |
| `reference/platform-comparison.md`                | Reference       | macOS vs Windows capability matrix                   |
| `reference/script-reference.md`                   | Reference       | Script inventory, parameters, output files           |
| `troubleshooting/capture-issues.md`               | Troubleshooting | Device not detected, RVI failures, permission errors |
| `scripts/macos/setup.sh`                          | Script asset    | macOS environment setup and RVI initialisation       |
| `scripts/macos/capture_diagnostics.sh`            | Script asset    | macOS ZCC diagnostic capture                         |
| `scripts/windows/Setup-ZCCDiagnostics.ps1`        | Script asset    | Windows environment setup                            |
| `scripts/windows/Invoke-ZCCDiagnosticCapture.ps1` | Script asset    | Windows ZCC diagnostic capture                       |

---

## Quick Start

### macOS (full capability — includes network capture)

```bash
cd scripts/macos
chmod +x setup.sh capture_diagnostics.sh
./setup.sh
sudo ./capture_diagnostics.sh
```

### Windows (device logs only — no network capture)

```powershell
# Run as Administrator
cd scripts\windows
.\Setup-ZCCDiagnostics.ps1
.\Invoke-ZCCDiagnosticCapture.ps1
```

---

## Relationship to Intune Diagnostic Logging

This toolkit and the Intune admin center diagnostics are complementary — not
alternatives:

- **This toolkit** — requires physical USB connection to the device; captures
  raw syslog, VPN profiles, and (on macOS) full network packets. Used for
  deep-level VPN and enrolment troubleshooting.
- **Intune admin center** — remote, agentless, no physical access required;
  collects structured diagnostic bundles from enrolled managed devices. Used for
  day-to-day support and MAM app protection diagnostics.

See [`../../intune/ios-diagnostic-logging/`](../../intune/ios-diagnostic-logging/README.md)
for the Intune admin center approach.

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Published
