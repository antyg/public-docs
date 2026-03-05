# iOS / iPadOS

**Status**: 🟡 Seeded — `device-capture-toolkit/` published

## Overview

iOS and iPadOS device management covering corporate-owned supervised devices
(via Automated Device Enrolment), BYOD app-protection scenarios (MAM without
enrolment), and host-machine diagnostic tooling for deep device capture.
Documentation spans the full device lifecycle: enrolment, configuration,
compliance, application management, and diagnostic log collection.

---

## Published Content

| Topic                  | Path                                                          | Type                         | Status         |
| ---------------------- | ------------------------------------------------------------- | ---------------------------- | -------------- |
| Device Capture Toolkit | [`device-capture-toolkit/`](device-capture-toolkit/README.md) | How-to + Reference + Scripts | ✅ Published   |

### Device Capture Toolkit

Host-machine tooling for capturing comprehensive iOS/iPadOS device diagnostics
from a USB-connected Mac or Windows workstation. Covers:

- RVI (Remote Virtual Interface) network packet capture — full device traffic
  including ZCC (Zscaler Client Connector) VPN, Wi-Fi, and cellular
- Device syslog capture via Apple Configurator (`cfgutil`) or `libimobiledevice`
- MDM profile snapshots at configurable checkpoints during ADE enrolment
- ZCC VPN client log extraction from the device
- Cross-platform: macOS scripts (full capability including network capture)
  and Windows PowerShell scripts (device logs only — no RVI on Windows)

**Relationship to Intune admin center diagnostics**: The device capture toolkit
is the complementary host-machine approach. For admin center, Company Portal,
and MAM-initiated diagnostic collection workflows, see
[`../intune/ios-diagnostic-logging/`](../intune/ios-diagnostic-logging/README.md).

---

## Planned Content

The following topics are planned for this section:

- **Automated Device Enrolment (ADE / DEP)**: Supervised device configuration
  via Apple Business Manager — enrolment profiles, supervision, restrictions
- **User Enrolment**: BYOD enrolment for personal devices with managed Apple IDs
- **App Protection Policies**: MAM-without-enrolment for BYOD app data protection
- **Configuration Profiles**: iOS-specific settings, restrictions, and passcode
  policies deployed via Intune
- **Compliance Policies**: Device compliance definitions and conditional access
  integration for iOS/iPadOS
- **iOS / iPadOS Update Management**: Supervised update enforcement, deferral
  windows, and rapid security response deployment
- **Apple Business Manager Integration**: ABM setup, VPP app licensing, and
  device assignment workflows
- **Corporate vs BYOD Management Strategies**: Decision framework and
  architectural guidance for mixed device ownership environments

---

## Relationship to Sibling Sections

| Section                               | Relationship                                                                        |
| ------------------------------------- | ----------------------------------------------------------------------------------- |
| [`../intune/`](../intune/README.md)   | iOS/iPadOS management is delivered via Intune — Intune-specific workflows live here |
| [`../MacOS/`](../MacOS/README.md)     | macOS is the primary host platform for the device capture toolkit scripts           |
| [`../Windows/`](../Windows/README.md) | Windows is the secondary host platform for device capture (limited capability)      |
| [`../Android/`](../Android/README.md) | Parallel platform documentation for Android Enterprise management                   |

---

## Technologies

- Microsoft Intune (MEM) — policy delivery, compliance, MAM
- Apple Business Manager (ABM) — device assignment, VPP licensing
- Automated Device Enrolment (ADE / DEP) — supervised zero-touch provisioning
- Apple Configurator (`cfgutil`) — device log capture and syslog streaming
- `libimobiledevice` (`idevicesyslog`) — open-source iOS device communication
- `rvictl` — Remote Virtual Interface for full-device network packet capture
- Zscaler Client Connector (ZCC) — VPN client whose diagnostics the toolkit captures
- `tcpdump` / Wireshark — packet capture and analysis
- PowerShell 5.1 / 7+ — Windows-side diagnostic scripts

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Seeded — `device-capture-toolkit/` published; management content planned
