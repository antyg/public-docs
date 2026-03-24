---
title: "Intune Platform Capabilities — Reference Matrix"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Microsoft Intune"
---

# Intune Platform Capabilities — Reference Matrix

Platform-by-platform reference for Microsoft Intune feature availability. Use this document to determine which management capabilities apply to a specific operating system before designing enrolment or policy architecture.

Sources: [Supported devices and browsers](https://learn.microsoft.com/en-us/mem/intune/fundamentals/supported-devices-browsers) | [Device enrolment guide](https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-enrollment) | [Manage devices overview](https://learn.microsoft.com/en-us/mem/intune/remote-actions/device-management)

---

## Enrolment Methods by Platform

| Enrolment Method | Windows | iOS/iPadOS | macOS | Android Enterprise | Linux |
| ---------------- | :-----: | :--------: | :---: | :----------------: | :---: |
| [User-driven / manual](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-enroll) | Yes | Yes | Yes | Yes | Yes |
| [Automatic MDM enrolment (Entra join)](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-enroll) | Yes | — | — | — | — |
| [Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/overview) | Yes | — | — | — | — |
| [Apple ADE (zero-touch)](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) | — | Yes | Yes | — | — |
| [Apple Configurator](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-configurator-enroll-ios) | — | Yes | — | — | — |
| [Android Enterprise — Fully Managed](https://learn.microsoft.com/en-us/mem/intune/enrollment/android-fully-managed-enroll) | — | — | — | Yes | — |
| [Android Enterprise — Work Profile](https://learn.microsoft.com/en-us/mem/intune/enrollment/android-work-profile-enroll) | — | — | — | Yes | — |
| [Android Enterprise — Dedicated (kiosk)](https://learn.microsoft.com/en-us/mem/intune/enrollment/android-kiosk-enroll) | — | — | — | Yes | — |
| [Bulk enrolment / provisioning package](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-bulk-enroll) | Yes | — | — | Yes | — |
| [Group Policy / co-management](https://learn.microsoft.com/en-us/mem/configmgr/comanage/overview) | Yes | — | — | — | — |

---

## Configuration Profile Types by Platform

Configuration profiles deliver settings to devices via the [device configuration profile](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles) workflow. Availability of profile types varies by platform.

| Profile Type | Windows | iOS/iPadOS | macOS | Android Enterprise | Linux |
| ------------ | :-----: | :--------: | :---: | :----------------: | :---: |
| [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) | Yes | Yes | Yes | Yes | — |
| [Administrative Templates (ADMX)](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows) | Yes | — | — | — | — |
| Device restrictions | Yes | Yes | Yes | Yes | — |
| Endpoint protection | Yes | — | Yes | — | — |
| [System extensions (macOS)](https://learn.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos) | — | — | Yes | — | — |
| [Privacy Preferences Policy Control (PPPC)](https://learn.microsoft.com/en-us/mem/intune/configuration/macos-privacy-preferences-policy-control) | — | — | Yes | — | — |
| Wi-Fi | Yes | Yes | Yes | Yes | Yes |
| VPN | Yes | Yes | Yes | Yes | — |
| Certificate (SCEP / PKCS) | Yes | Yes | Yes | Yes | — |
| Email | Yes | Yes | Yes | Yes | — |
| Shared multi-user device | Yes | Yes | — | Yes | — |
| [Custom OMA-URI](https://learn.microsoft.com/en-us/mem/intune/configuration/custom-settings-windows-10) | Yes | Yes | — | Yes | — |
| [Preference file (macOS)](https://learn.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos) | — | — | Yes | — | — |
| [Kiosk / single-app mode](https://learn.microsoft.com/en-us/mem/intune/configuration/kiosk-settings) | Yes | Yes | — | Yes | — |
| [Platform SSO (macOS)](https://learn.microsoft.com/en-us/mem/intune/configuration/use-enterprise-sso-plug-in-macos-with-intune) | — | — | Yes | — | — |

---

## Compliance Policy Settings by Platform

[Compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started) evaluate device state. Available settings differ by platform.

| Compliance Setting | Windows | iOS/iPadOS | macOS | Android Enterprise | Linux |
| ------------------ | :-----: | :--------: | :---: | :----------------: | :---: |
| Minimum OS version | Yes | Yes | Yes | Yes | Yes |
| Maximum OS version | Yes | Yes | Yes | Yes | — |
| [BitLocker / FileVault encryption required](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices) | Yes | — | Yes | — | — |
| [TPM required](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows) | Yes | — | — | — | — |
| Jailbreak / root detection | — | Yes | — | Yes | — |
| [Windows Health Attestation (Secure Boot, Code Integrity)](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows) | Yes | — | — | — | — |
| [Microsoft Defender Antivirus status](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows) | Yes | — | — | — | — |
| Gatekeeper enabled | — | — | Yes | — | — |
| SIP (System Integrity Protection) | — | — | Yes | — | — |
| PIN / passcode required | Yes | Yes | — | Yes | — |
| [Mobile Threat Defence integration](https://learn.microsoft.com/en-us/mem/intune/protect/mobile-threat-defense) | Yes | Yes | Yes | Yes | — |
| [Conditional Access — device-based](https://learn.microsoft.com/en-us/mem/intune/protect/conditional-access-intune-common-ways-use) | Yes | Yes | Yes | Yes | Yes |

---

## App Deployment Methods by Platform

[App management](https://learn.microsoft.com/en-us/mem/intune/apps/app-management) in Intune supports multiple deployment methods. Availability varies by platform.

| App Deployment Method | Windows | iOS/iPadOS | macOS | Android Enterprise | Linux |
| --------------------- | :-----: | :--------: | :---: | :----------------: | :---: |
| [Win32 (.intunewin)](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management) | Yes | — | — | — | — |
| Microsoft 365 Apps (built-in) | Yes | — | — | — | — |
| [Microsoft Store apps](https://learn.microsoft.com/en-us/mem/intune/apps/store-apps-microsoft) | Yes | — | — | — | — |
| [LOB / enterprise app](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-ios) | Yes | Yes | Yes | Yes | — |
| [VPP / Volume Purchase (Apple)](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios) | — | Yes | Yes | — | — |
| [Managed Google Play](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add-android-for-work) | — | — | — | Yes | — |
| [PKG / DMG (macOS)](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos) | — | — | Yes | — | — |
| [Shell scripts (macOS)](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) | — | — | Yes | — | — |
| [PowerShell scripts (Windows)](https://learn.microsoft.com/en-us/mem/intune/apps/intune-management-extension) | Yes | — | — | — | — |
| [Web app / web link](https://learn.microsoft.com/en-us/mem/intune/apps/web-app) | Yes | Yes | Yes | Yes | — |
| [App protection policies (MAM)](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policies) | Yes | Yes | Yes | Yes | — |
| [App configuration policies](https://learn.microsoft.com/en-us/mem/intune/apps/app-configuration-policies-overview) | Yes | Yes | Yes | Yes | — |

---

## Security Baseline Availability by Platform

[Security baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) are preconfigured policy sets based on Microsoft security team recommendations. They are currently available for Windows only.

| Baseline | Platform | Notes |
| -------- | -------- | ----- |
| [Windows Security Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) | Windows | Multiple versioned instances; covers ~350+ settings |
| [Microsoft Defender for Endpoint Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender) | Windows | Optimised for physical devices; not recommended for VMs/VDI |
| [Microsoft Edge Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-edge) | Windows | Browser hardening settings |
| [Microsoft 365 Apps for Enterprise Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-v2-office-settings) | Windows | Office application hardening |

For macOS, iOS/iPadOS, and Android Enterprise, Microsoft-provided security baselines are not currently available in Intune. Equivalent hardening is achieved through configuration profiles, compliance policies, and endpoint security policies targeting those platforms.

---

## Additional Feature Availability

| Feature | Windows | iOS/iPadOS | macOS | Android Enterprise | Linux |
| ------- | :-----: | :--------: | :---: | :----------------: | :---: |
| [Windows LAPS (local admin password)](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview) | Yes | — | Yes | — | — |
| [Endpoint Privilege Management](https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview) | Yes | — | — | — | — |
| [Remote Help](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remote-help) | Yes | — | — | — | — |
| [Endpoint Analytics / Proactive Remediation](https://learn.microsoft.com/en-us/mem/analytics/overview) | Yes | — | — | — | — |
| [Windows Update for Business / Autopatch](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) | Yes | — | — | — | — |
| [Software update policies](https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-ios) | — | Yes | Yes | Yes | — |
| [Device wipe / retire / reset](https://learn.microsoft.com/en-us/mem/intune/remote-actions/devices-wipe) | Yes | Yes | Yes | Yes | Yes |
| [BitLocker recovery key escrow](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices) | Yes | — | — | — | — |
| [FileVault recovery key escrow](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault) | — | — | Yes | — | — |

---

## Related Resources

- [Supported devices and browsers — Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/supported-devices-browsers)
- [Device enrolment guide for Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-enrollment)
- [Device compliance overview](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)
- [Configuration profiles overview](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)
- [Security baselines in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)
- [App management overview](https://learn.microsoft.com/en-us/mem/intune/apps/app-management)
- [Windows compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)
- [macOS compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)
- [iOS/iPadOS compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-ios)
- [Android Enterprise compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-android-for-work)
- [Manage Linux devices in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-platform-linux)
