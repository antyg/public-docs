---
title: "Microsoft Intune (MEM)"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
platform: "Microsoft Intune"
---

# Microsoft Intune (MEM)

Microsoft Intune (also referred to as Microsoft Endpoint Manager) documentation for administrators. Covers device enrolment, app management, configuration profiles, compliance policies, diagnostic logging, and troubleshooting.

---

## Published Content

| Topic                         | Path                                                        | Type                                 | Status       |
| ----------------------------- | ----------------------------------------------------------- | ------------------------------------ | ------------ |
| iOS/iPadOS Diagnostic Logging | [ios-diagnostic-logging/](ios-diagnostic-logging/README.md) | How-to + Reference + Troubleshooting | Published |
| OCPS Cross-Reference          | [reference-ocps-cross-reference.md](reference-ocps-cross-reference.md)          | Cross-reference stub                 | Published |

> **Note**: "Policies for Microsoft 365 Apps" visible in the Intune console at Apps > Policies for Microsoft 365 Apps is **not an Intune-native feature** — it is a pass-through to the Office Cloud Policy Service (OCPS). Full OCPS documentation is maintained in [microsoft-365/apps-admin/](../../microsoft-365/apps-admin/README.md).

---

## Draft Content

| Topic                           | Path                                                                          | Type        | Status |
| ------------------------------- | ----------------------------------------------------------------------------- | ----------- | ------ |
| Endpoint Management Overview    | [explanation-endpoint-management.md](explanation-endpoint-management.md)      | Explanation | Draft  |
| Platform Capabilities Reference | [reference-platform-capabilities.md](reference-platform-capabilities.md)      | Reference   | Draft  |

### Endpoint Management Overview

Conceptual overview of Microsoft Intune as an endpoint management platform. Covers MEM architecture, the Graph API backend, the Intune Management Extension, MDM vs MAM, all enrolment types (user-driven, bulk, ADE, Autopilot), platform support matrix, and the four management channels: configuration profiles, compliance policies, security baselines, and app deployment.

### Platform Capabilities Reference

Platform-by-platform capability matrix showing which Intune features are available on each supported operating system. Tables cover enrolment methods, configuration profile types, compliance policy settings, app deployment methods, security baseline availability, and additional feature availability across Windows, iOS/iPadOS, macOS, Android Enterprise, and Linux.

---

## Planned Content

The following topics are planned for this section:

- Device enrolment workflows (iOS/iPadOS, Windows, macOS, Android)
- App deployment and management
- Configuration profiles and settings catalogue
- Compliance policies and conditional access integration
- Security baselines
- PowerShell and Graph API automation
- Platform-specific administration guides

---

## Document Information

| Field               | Value                                                                                |
| ------------------- | ------------------------------------------------------------------------------------ |
| Platform scope      | iOS/iPadOS, Windows, macOS, Android, Linux                                           |
| Section status      | Draft — conceptual and reference content added; platform-specific guides planned     |
| Related domains     | [DOM13 — Platform & Infrastructure Documentation](https://github.com/antyg/clauding) |
| Editorial standards | [antyg-public CLAUDE.md](../../CLAUDE.md)                                            |
