---
title: "macOS Endpoint Management — Concepts"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "macOS"
---

# macOS Endpoint Management — Concepts

Conceptual overview of managing macOS devices via Microsoft Intune and Apple Business Manager. This document covers the key management mechanisms, enrolment models, configuration frameworks, and security controls available to endpoint engineers operating a macOS fleet.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive content is to be authored in a future iteration.

---

## Apple Business Manager Integration

**[Microsoft Learn — Apple Business Manager and Intune](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)** | **[Apple Business Manager Help](https://support.apple.com/guide/apple-business-manager/welcome/web)**

[Apple Business Manager (ABM)](https://support.apple.com/guide/apple-business-manager/welcome/web) is Apple's web-based portal for managing organisation-owned Apple devices, Volume Purchase Programme (VPP) app licences, and Managed Apple IDs. ABM is the prerequisite platform for zero-touch Mac management via Automated Device Enrolment.

The integration between ABM and Intune is established through an MDM server token (a `.p7m` file) created in ABM and uploaded to the Intune admin centre. This token authorises Intune to act as the MDM authority for devices assigned to that MDM server in ABM. The token must be renewed annually; Intune will alert administrators approaching the expiry date.

Key ABM capabilities relevant to endpoint management:

- **Device assignment** — new Macs purchased from Apple or Apple Authorised Resellers can be automatically assigned to the organisation's ABM and pre-assigned to an Intune MDM server
- **VPP licensing** — app licences purchased through ABM (now Apps and Books) are synchronised to Intune for assignment and distribution
- **Managed Apple IDs** — federated identity for Apple services using the organisation's Entra ID credentials

> **TODO**: Author conceptual content explaining: the ABM-to-Intune token lifecycle and renewal workflow; how device assignment flows from purchase to ABM to Intune; the relationship between Supervised mode (ADE) and Unsupervised mode (User Enrolment) and the management capabilities each unlocks; and how Managed Apple IDs interact with personal Apple IDs on organisational devices.

---

## Automated Device Enrolment

**[Microsoft Learn — Set Up ADE for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)** | **[macOS Endpoints End-to-End Guide](https://learn.microsoft.com/en-us/mem/intune/solutions/end-to-end-guides/macos-endpoints-get-started)**

[Automated Device Enrolment (ADE)](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) (formerly Device Enrolment Programme / DEP) is Apple's zero-touch enrolment mechanism for organisation-owned Macs assigned through Apple Business Manager. When a device assigned in ABM is powered on for the first time (or after an erase), macOS contacts Apple's activation servers, recognises the device as belonging to the organisation's ABM account, and automatically downloads and installs the assigned Intune MDM enrolment profile — before Setup Assistant completes.

ADE-enrolled Macs are **supervised**, granting Intune access to the full range of MDM capabilities including:

- Kernel extension and system extension management (macOS 11+)
- Software update enforcement
- Lost mode
- Device name management
- Managed Open In (data separation between managed and unmanaged apps)

From macOS 13.1 onwards, ADE uses the **ACME (Automatic Certificate Management Environment)** protocol for the device management certificate, providing improved protection against unauthorised certificate issuance compared to the legacy SCEP-based approach.

Microsoft recommends **Setup Assistant with modern authentication** as the enrolment method for ADE scenarios, which requires users to authenticate with their Entra ID credentials during Setup Assistant before the device is fully provisioned.

Enrolment methods available for macOS, in addition to ADE:

| Method | Use Case | Supervision |
| ------ | -------- | ----------- |
| [ADE (ABM)](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) | Organisation-owned, zero-touch | Supervised |
| [Direct Enrolment (Apple Configurator)](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-configurator-enroll-ios) | Corporate devices without ABM | Supervised |
| [User Enrolment](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-user-enrollment) | BYOD / personal Macs | Unsupervised |
| [Device Enrolment (manual)](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll) | Unmanaged devices without ABM | Unsupervised |

> **TODO**: Author conceptual content explaining: the on-device experience of ADE enrolment vs manual enrolment; what management capabilities are gated behind supervision; the ACME vs SCEP certificate distinction and its security implications; and the guidance on choosing between Setup Assistant modern authentication and Setup Assistant legacy authentication.

---

## Configuration Profiles

**[Microsoft Learn — macOS Configuration Profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)** | **[Settings Catalogue — macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)**

macOS configuration profiles are the primary mechanism for delivering settings to managed Macs. Intune delivers profiles over the MDM channel using Apple's profile specification. Profiles can configure a wide range of macOS subsystems.

Key profile categories for macOS:

- **[Device restrictions](https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos)** — controls for built-in macOS features, iCloud services, screen capture, and user account behaviour
- **[System extensions](https://learn.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos)** — allows or blocks third-party system extensions (network extensions, endpoint security extensions) without user approval prompts
- **[Privacy Preferences Policy Control (PPPC)](https://learn.microsoft.com/en-us/mem/intune/configuration/macos-privacy-preferences-policy-control)** — pre-approves application access to protected macOS resources (Full Disk Access, accessibility, camera, microphone, contacts) using TCC (Transparency, Consent, and Control) configuration profiles
- **[Preference files](https://learn.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos)** — deploys macOS `.plist` preference files to configure third-party application settings
- **[Platform SSO](https://learn.microsoft.com/en-us/mem/intune/configuration/use-enterprise-sso-plug-in-macos-with-intune)** — integrates macOS login with Microsoft Entra ID, enabling passwordless or Entra-credential-based Mac login
- **Wi-Fi and VPN** — network configuration pushed via MDM to avoid manual user configuration

> **TODO**: Author conceptual content explaining: the macOS profile installation model and user-visible experience; how PPPC profiles remove the TCC consent dialogs for deployed applications such as Microsoft Defender; system extension vs kernel extension (kext) history and the migration to system extensions; and the Platform SSO configuration workflow for Entra-integrated Mac login.

---

## Application Deployment

**[Microsoft Learn — Deploy macOS Apps](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos)** | **[macOS Shell Scripts](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)**

Application deployment on macOS via Intune supports multiple package formats and distribution methods:

| Method | Format | Notes |
| ------ | ------ | ----- |
| [LOB app (PKG)](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos) | `.pkg` | Signed and notarised flat packages; most common deployment format |
| [DMG app](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos-dmg) | `.dmg` | Disk image apps; Intune copies the `.app` bundle to /Applications |
| [VPP / Apps and Books](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios) | Mac App Store | Organisation-owned licences from ABM Apps and Books |
| [Microsoft 365 Apps](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add-office365-macos) | Built-in type | Office suite deployment via Intune built-in app type |
| [Shell scripts](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) | `.sh` | Run as root or signed-in user; used for custom installation workflows |
| [Web app](https://learn.microsoft.com/en-us/mem/intune/apps/web-app) | URL | Shortcut to a web application added to the dock or Applications folder |

Shell scripts on macOS run via the Intune Management Agent and can be used for installation steps that exceed what the MDM package deployment channel supports — for example, post-installation configuration, licence activation, or dependency installation.

> **TODO**: Author conceptual content explaining: the PKG signing and notarisation requirement for Intune deployment; how DMG deployment works and its limitations vs PKG; VPP licence assignment (device-based vs user-based licensing); when to use shell scripts vs PKG deployment; and the frequency and retry behaviour of shell script execution.

---

## FileVault Encryption Management

**[Microsoft Learn — Encrypt macOS Devices with FileVault](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault)**

[FileVault](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault) is the macOS full-disk encryption framework using XTS-AES 128-bit encryption. Intune can configure, enforce, and manage FileVault on enrolled Macs through endpoint security disk encryption policies or device configuration profiles.

Key management capabilities:

- **Enforcement** — Intune policy requires FileVault to be enabled; non-compliant devices are flagged in compliance reporting and can be blocked via Conditional Access
- **Recovery key escrow** — Intune retrieves and stores the personal recovery key generated during FileVault enablement; keys are accessible to authorised administrators in the Intune admin centre
- **Key rotation** — administrators can trigger recovery key rotation for individual devices; rotated keys are automatically escrowed back to Intune
- **Company Portal self-service** — end users can retrieve their own FileVault recovery key by signing in to the Company Portal website

User-approved device enrolment is required for Intune to manage FileVault on macOS devices enrolled without ADE.

> **TODO**: Author conceptual content explaining: the difference between user-interactive, deferred, and Setup Assistant FileVault enablement modes; how recovery key escrow timing works and how to verify escrow success; the RBAC permissions required to view or rotate recovery keys; and how FileVault management integrates with macOS compliance policies and Conditional Access.

---

## Compliance Policies

**[Microsoft Learn — macOS Compliance Settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)**

[macOS compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os) evaluate device state against conditions required for access to organisational resources. Key macOS compliance settings include:

- Minimum and maximum macOS version
- FileVault encryption required
- Firewall enabled
- Gatekeeper (allow only apps from App Store, or App Store and identified developers)
- System Integrity Protection (SIP) enabled
- Password policy (complexity, minimum length, expiry)
- Mobile Threat Defence risk score threshold

> **TODO**: Author conceptual content explaining: which compliance settings require Supervised enrolment; evaluation timing differences between macOS and iOS/iPadOS compliance; how compliance results feed into Conditional Access policies; and common compliance policy design patterns for macOS fleets.

---

## macOS Update Management

**[Microsoft Learn — macOS Software Update Policies](https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos)**

Intune provides [software update policies for macOS](https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos) that control when devices install macOS updates, including:

- **Managed Software Update** — configures update cadence and enforces installation of pending updates
- **Update deferral** — delays the visibility of software updates to end users for a configurable number of days (up to 90 days for major releases on Supervised devices)
- **Rapid Security Response** — Apple's mechanism for delivering critical security fixes outside the normal update cycle; manageable via Intune update policies
- **Forced installation** — deadline-based enforcement that installs pending updates after a configured period regardless of user action

> **TODO**: Author conceptual content explaining: the distinction between user-deferred and admin-enforced update models; how Rapid Security Response updates are handled differently from full OS updates; the supervision requirement for deferral control; and the interaction between Intune update policies and native macOS Software Update settings.

---

## Related Resources

- [Set up Automated Device Enrolment for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)
- [macOS endpoints end-to-end guide](https://learn.microsoft.com/en-us/mem/intune/solutions/end-to-end-guides/macos-endpoints-get-started)
- [macOS enrolment methods overview](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)
- [macOS device configuration profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)
- [Settings Catalogue for macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)
- [Privacy Preferences Policy Control (PPPC)](https://learn.microsoft.com/en-us/mem/intune/configuration/macos-privacy-preferences-policy-control)
- [System extensions for macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/kernel-extensions-overview-macos)
- [Platform SSO for macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/use-enterprise-sso-plug-in-macos-with-intune)
- [Deploy macOS LOB apps (PKG)](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos)
- [macOS shell scripts in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)
- [VPP apps for macOS](https://learn.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios)
- [Encrypt macOS devices with FileVault](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices-filevault)
- [macOS compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-mac-os)
- [macOS software update policies](https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos)
- [Apple Business Manager Help](https://support.apple.com/guide/apple-business-manager/welcome/web)
