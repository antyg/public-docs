---
title: "Windows"
status: "planned"
last_updated: "2026-03-09"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
platform: "Windows"
---

# Windows

## Overview

Windows 10 and Windows 11 endpoint management via Microsoft Endpoint Manager
(Intune), covering configuration profiles, compliance policy enforcement,
security baselines, update management, and Group Policy migration to cloud-native
settings catalogue. Windows also serves as a secondary host platform for
iOS/iPadOS device diagnostic capture — documented under the iOS section.

---

## Planned Content

The following topics are planned for this section:

- **Configuration Profiles and Settings Catalogue**: Windows-specific settings
  delivered via Intune — administrative templates (ADMX ingestion), endpoint
  protection, device restrictions, and custom OMA-URI policies
- **Compliance Policies**: Windows compliance definitions including BitLocker
  encryption, TPM requirements, OS version thresholds, Windows Health
  Attestation, and Microsoft Defender status
- **Security Baselines**: Microsoft-recommended security configuration baselines
  deployed via Intune — Windows Security Baseline, Defender for Endpoint
  baseline, and Edge baseline
- **Windows Update for Business**: Feature update rings, quality update
  deferral policies, Windows Autopatch, and expedited update deployment
- **Group Policy Migration**: Mapping existing GPO settings to Intune
  configuration profiles and settings catalogue equivalents
- **Endpoint Privilege Management**: Local administrator password solution
  (LAPS), privilege elevation workflows, and least-privilege configurations
- **PowerShell and Graph API Automation**: Scripted management of Windows
  endpoints via Intune Graph API, including bulk operations and reporting

---

## Windows as a Diagnostic Host Platform

Windows can run PowerShell-based iOS/iPadOS diagnostic capture scripts,
enabling device log collection from a USB-connected iOS device without a Mac.

**Critical limitation**: Windows does not support RVI (Remote Virtual Interface)
— full-device network packet capture is not available on Windows. The
PowerShell scripts capture device-side logs only. For complete diagnostic
capture including network traffic, a macOS host is required.

For Windows-platform host tooling to capture iOS/iPadOS diagnostics, see:
**[`../iOS/device-capture-toolkit/`](../iOS/device-capture-toolkit/README.md)**

| Capability                   | Windows host     | macOS host             |
| ---------------------------- | ---------------- | ---------------------- |
| Device syslog capture        | ✅               | ✅                     |
| MDM profile snapshots        | ✅               | ✅                     |
| ZCC log extraction           | ✅               | ✅                     |
| Network packet capture (RVI) | ❌ Not available | ✅ Full device traffic |

---

## Technologies

- Microsoft Intune (MEM) — Windows MDM and MAM management platform
- Windows Autopilot — zero-touch device provisioning (see [`../autopilot/`](../autopilot/README.md))
- Group Policy and ADMX — legacy policy framework migrating to settings catalogue
- Windows Update for Business / Windows Autopatch — cloud-native update management
- BitLocker — Windows full-disk encryption managed via Intune
- Windows Hello for Business — passwordless authentication
- Microsoft Defender for Endpoint — endpoint threat protection integration
- PowerShell 5.1 / 7+ — automation and scripted device management
- Microsoft Graph API — programmatic Intune and endpoint management access

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Planned — management content; `../iOS/device-capture-toolkit/` covers Windows-hosted iOS diagnostics
