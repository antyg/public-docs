---
title: "macOS Configuration Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "macOS"
---

# macOS Configuration Reference

Reference lookup for macOS endpoint management configuration in Microsoft Intune and Apple Business Manager. This document is structured for quick lookup of enrolment method comparison, configuration profile payload types, encryption settings, compliance parameters, and app licensing.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive reference tables are to be authored in a future iteration.

---

## Enrolment Method Comparison

**[Microsoft Learn — macOS Enrolment Overview](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)** | **[Set Up ADE for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)**

> **TODO**: Build a reference table comparing all available macOS enrolment methods across the following dimensions: method name, prerequisite (ABM required / Apple Configurator / none), supervision state (supervised / unsupervised), user interaction required during enrolment, MDM certificate type (ACME / SCEP), supported management capabilities unlocked, and recommended use case.

Methods to cover:

| Method | MS Learn Reference |
| ------ | ------------------ |
| Automated Device Enrolment (ADE) via ABM | [device-enrollment-program-enroll-macos](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) |
| Direct Enrolment (Apple Configurator) | [apple-configurator-enroll-ios](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-configurator-enroll-ios) |
| User Enrolment (BYOD) | [macos-user-enrollment](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-user-enrollment) |
| Device Enrolment (manual, Company Portal) | [macos-enroll](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll) |

Note: From macOS 13.1, ADE uses ACME for certificate issuance. [ACME provides improved protection](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) against unauthorised MDM certificate issuance compared to the legacy SCEP approach.

---

## Configuration Profile Payload Types

**[Apple Developer — Profile Payload Keys](https://developer.apple.com/documentation/devicemanagement/profile-specific_payload_keys)** | **[Microsoft Learn — macOS Configuration Profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)**

macOS MDM configuration profiles are composed of one or more typed payloads. Each payload type configures a specific macOS subsystem.

> **TODO**: Build a reference table listing: payload type identifier (e.g., `com.apple.applicationaccess`), common name, what it configures, the Intune profile type that delivers it, and whether it requires supervised enrolment. Cover all payload types surfaced in the [Intune macOS Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) and [device restriction profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos).

Key payload types to document:

- `com.apple.applicationaccess` — Device restrictions (App Store, iCloud, screen recording)
- `com.apple.security.firewall` — Application firewall configuration
- `com.apple.syspolicy.kernel-extension-policy` — Kernel extension allow-listing
- `com.apple.system-extension-policy` — System extension allow-listing
- `com.apple.TCC.configuration-profile-policy` — Privacy Preferences Policy Control (PPPC / Full Disk Access)
- `com.apple.wifi.managed` — Wi-Fi network configuration
- `com.apple.vpn.managed` — VPN configuration
- `com.apple.security.scep` / `com.apple.security.pkcsmessage` — Certificate provisioning
- `com.apple.loginwindow` — Login window configuration
- `com.apple.ManagedClient.preferences` — Preference file delivery (per-app plist settings)
- `com.apple.extensiblesso` — Enterprise SSO (Platform SSO / Kerberos SSO)
- `com.apple.sofwareupdate` — Software update deferral and enforcement

---

## FileVault Escrow Settings

**[Microsoft Learn — Encrypt macOS Devices with FileVault](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault)** | **[Endpoint Security Disk Encryption Profile Settings](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-disk-encryption-profile-settings)**

> **TODO**: Build a reference table documenting all configurable parameters in the Intune macOS FileVault endpoint security policy and device configuration profile. Include columns: setting name, allowed values, default value, and notes. Cover:

- Enable FileVault (Yes / Not configured)
- Recovery key type (Personal recovery key / Institutional key)
- Escrow location description (user-visible text shown during key escrow)
- Number of times allowed to bypass (0 = forced; 1–n = deferred; -1 = indefinite deferral)
- Hide recovery key (prevents user from viewing the personal recovery key during setup)
- Disable prompt at sign-out
- Enable recovery key rotation (frequency)
- Personal recovery key rotation in months

Policy delivery options:

| Policy Type | Path in Intune Admin Centre | Notes |
| ----------- | --------------------------- | ----- |
| [Endpoint security disk encryption](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-disk-encryption-profile-settings) | Endpoint security > Disk encryption | Recommended path |
| [Device configuration — Endpoint protection](https://learn.microsoft.com/en-us/mem/intune/configuration/endpoint-protection-macos) | Devices > Configuration > Endpoint protection | Legacy path |
| [Settings Catalogue — Full Disk Encryption](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) | Devices > Configuration > Settings Catalogue | CSP-native path |

---

## Compliance Policy Settings Matrix

**[Microsoft Learn — macOS Compliance Settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)**

> **TODO**: Build a reference table documenting all configurable settings in a macOS compliance policy. Include columns: setting name, category, allowed values, supervision required (yes/no), and evaluation notes. Cover all settings from the [macOS compliance settings reference](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os).

Categories to document:

- **Device Health** — System Integrity Protection (SIP), Gatekeeper configuration
- **Device Properties** — minimum OS version, maximum OS version, operating system build version
- **System Security** — password required, simple passwords, minimum password length, password type, maximum password age, password reuse prevention, maximum minutes of inactivity, screen lock timeout, FileVault encryption required, firewall enabled, firewall block all incoming connections, stealth mode enabled
- **Microsoft Defender for Endpoint** — machine risk score threshold

---

## VPP Licensing Configuration

**[Microsoft Learn — VPP Apps in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios)** | **[Manage Volume Purchased macOS Apps](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-macos)**

[Volume Purchase Programme (VPP)](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios) licences are purchased through Apple Business Manager (Apps and Books) and synchronised to Intune via the ABM MDM token. Both device-based and user-based licensing models are available.

> **TODO**: Build a reference table comparing VPP licensing models for macOS:

| Dimension | Device-Based Licensing | User-Based Licensing |
| --------- | ---------------------- | -------------------- |
| Licence assignment target | Device | User (Managed Apple ID required) |
| Supervision required | No | No |
| User interaction for installation | None (silent) | Company Portal or user approval |
| Licence recovery on unenrolment | Automatic | Requires revocation |
| Shared device support | Yes | Limited |
| Intune assignment type supported | Required, Available | Required, Available |

Key VPP management operations to document: token sync frequency, licence availability reporting, licence revocation workflow, and handling of apps purchased outside ABM (without VPP licence).

---

## Related Resources

- [macOS enrolment overview](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)
- [Set up ADE for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)
- [macOS device configuration profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)
- [macOS device restrictions](https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos)
- [Privacy Preferences Policy Control (PPPC)](https://learn.microsoft.com/en-us/mem/intune/configuration/macos-privacy-preferences-policy-control)
- [System extensions for macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos)
- [Encrypt macOS devices with FileVault](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault)
- [Endpoint security disk encryption profile settings](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-disk-encryption-profile-settings)
- [macOS compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)
- [VPP apps in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios)
- [macOS software update policies](https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos)
- [Apple Developer — Profile Payload Keys](https://developer.apple.com/documentation/devicemanagement/profile-specific_payload_keys)
- [Apple Business Manager Help](https://support.apple.com/guide/apple-business-manager/welcome/web)
