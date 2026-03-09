---
title: "macOS"
status: "planned"
last_updated: "2026-03-09"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
platform: "macOS"
---

# macOS

## Overview

macOS device management via Microsoft Endpoint Manager (Intune) and Apple
Business Manager, covering Mac enrolment, configuration profiles, application
deployment, FileVault encryption, and compliance enforcement. macOS also serves
as the primary host platform for the iOS/iPadOS device capture toolkit —
documented under the iOS section.

---

## Planned Content

The following topics are planned for this section:

- **Device Enrolment Methods**: Automated Device Enrolment (ADE) for
  organisation-owned Macs, User Enrolment for BYOD, and direct Device
  Enrolment for unmanaged devices
- **Configuration Profiles**: macOS-specific settings delivered via Intune —
  restrictions, preferences, login window, and system extension policies
- **Application Deployment**: Managed PKG distribution, `.dmg` app deployment,
  shell script delivery, and Mac App Store VPP licensing
- **FileVault Encryption**: Enabling FileVault via Intune, personal recovery
  key escrow, and institutional key management
- **Compliance Policies**: macOS compliance definitions including OS version
  requirements, encryption state, Gatekeeper, and SIP enforcement
- **Conditional Access for macOS**: Device-based and app-based conditional
  access policies targeting managed Mac endpoints
- **Privacy Preferences Policy Control (PPPC)**: Managing macOS privacy
  permissions via configuration profiles to pre-approve app access to
  protected system resources
- **macOS Update Management**: Managed software update policies, deferral
  configuration, and rapid security response deployment

---

## macOS as a Diagnostic Host Platform

macOS is the **only** platform that supports full iOS/iPadOS network packet
capture via RVI (Remote Virtual Interface). When troubleshooting iOS device
issues — including ZCC VPN connectivity, ADE enrolment, and app authentication
flows — a Mac running `rvictl`, Apple Configurator (`cfgutil`), and `tcpdump`
provides capabilities unavailable on Windows.

For host-machine tooling to capture iOS/iPadOS device diagnostics from a
connected Mac, see:
**[`../iOS/device-capture-toolkit/`](../iOS/device-capture-toolkit/README.md)**

Key macOS tools used in iOS diagnostic capture:

- `rvictl` — creates Remote Virtual Interface for full-device packet capture
- `cfgutil` (Apple Configurator) — device syslog and profile capture
- `idevicesyslog` (libimobiledevice) — alternative device log streaming
- `tcpdump` — network traffic capture on RVI interfaces

---

## Technologies

- Microsoft Intune (MEM) — macOS MDM management platform
- Apple Business Manager (ABM) — device assignment and VPP licensing
- Automated Device Enrolment (ADE) — zero-touch Mac provisioning
- Apple Configurator (`cfgutil`) — device management and syslog capture
- `libimobiledevice` — open-source iOS/macOS device communication tooling
- `rvictl` — Remote Virtual Interface controller for iOS device capture
- FileVault — macOS full-disk encryption
- Gatekeeper and System Integrity Protection (SIP) — macOS security features
- Privacy Preferences Policy Control (PPPC) — macOS privacy framework

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Planned — management content; `../iOS/device-capture-toolkit/` covers macOS-hosted iOS diagnostics
