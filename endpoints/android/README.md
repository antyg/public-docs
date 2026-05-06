---
title: "Android"
status: "planned"
last_updated: "2026-03-09"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
platform: "Android"
---

# Android

## Overview

Android device management via Android Enterprise, covering the full spectrum
of deployment scenarios: fully managed corporate-owned devices (COBO), work
profile BYOD, dedicated/kiosk devices, and corporate-owned with work profile
(COPE). Documentation spans enrolment, application management, compliance, and
platform-specific configuration for Android in Microsoft-managed environments.

---

## Planned Content

The following topics are planned for this section:

- **Android Enterprise Enrolment**: Zero-touch enrolment, QR code provisioning,
  NFC bump, DPC identifier enrolment, and Google account-driven enrolment modes
- **Fully Managed Devices (COBO)**: Corporate-owned device policies, kiosk
  launcher configuration, and lock-task mode for dedicated devices
- **Work Profile (BYOD)**: Personal device enrolment, work profile separation,
  cross-profile data transfer controls, and managed Google Play app delivery
- **Corporate-Owned with Work Profile (COPE)**: Hybrid corporate/personal
  device management policies
- **App Protection Policies**: MAM-without-enrolment for BYOD scenarios where
  full device enrolment is not appropriate
- **Compliance Policies**: Android-specific compliance definitions and
  conditional access integration
- **Android Update Management**: OS update policies, patch level enforcement,
  and update deferral windows
- **OEM-Specific Configuration**: Samsung Knox management, OEMConfig policies,
  and hardware-specific management extensions
- **Managed Google Play**: App approval, distribution, and private app
  publishing workflows

---

## Technologies

- Microsoft Intune (MEM) — Android Enterprise management platform
- Android Enterprise — Google's enterprise management framework
- Managed Google Play — enterprise app distribution
- Samsung Knox — OEM device management APIs and Knox Mobile Enrolment
- OEMConfig — hardware-specific configuration schema
- Zero-Touch Enrolment — Google's automated provisioning programme
- Microsoft Authenticator — broker app for conditional access on Android

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Planned — no content published yet
