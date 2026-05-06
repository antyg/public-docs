---
title: "macOS"
status: "planned"
last_updated: "2026-03-16"
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

## Content Index

| Topic                        | Path                                                                          | Type        | Status  |
| ---------------------------- | ----------------------------------------------------------------------------- | ----------- | ------- |
| macOS Management Concepts    | [explanation-macos-management.md](explanation-macos-management.md)            | Explanation | Planned |
| macOS Configuration Reference | [reference-macos-configuration.md](reference-macos-configuration.md)         | Reference   | Planned |

### macOS Management Concepts

Seed outline covering the key macOS endpoint management mechanisms: Apple
Business Manager integration (MDM token, VPP, Managed Apple IDs), Automated
Device Enrolment (ADE, supervision, ACME certificate protocol), Configuration
Profiles (device restrictions, system extensions, PPPC, Platform SSO,
preference files), Application Deployment (PKG, DMG, VPP, shell scripts),
FileVault Encryption Management (escrow, key rotation, Company Portal
self-service), Compliance Policies, and macOS Update Management (deferral,
Rapid Security Response, forced installation).

### macOS Configuration Reference

Seed outline covering macOS configuration lookup material: enrolment method
comparison table (ADE, Direct Enrolment, User Enrolment, Device Enrolment),
configuration profile payload types (all MDM payload identifiers surfaced in
Intune), FileVault escrow settings reference, compliance policy settings matrix,
and VPP licensing configuration (device-based vs user-based licensing).

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
**[`../ios/device-capture-toolkit/`](../ios/device-capture-toolkit/README.md)**

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

**Last Updated**: March 2026
**Maintainer**: antyg
**Status**: Planned — seed outlines added; substantive content to be authored
