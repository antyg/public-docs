---
title: "Microsoft Intune — Endpoint Management Overview"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "Microsoft Intune"
---

# Microsoft Intune — Endpoint Management Overview

Microsoft Intune is a cloud-based endpoint management platform that enables organisations to manage and secure devices, applications, and data across multiple operating system platforms. It is the primary MDM and MAM service within the [Microsoft Endpoint Manager](https://learn.microsoft.com/en-us/mem/endpoint-manager-overview) product family, operating entirely from Microsoft-managed cloud infrastructure with no on-premises gateway requirement.

---

## Architecture

### Cloud Service Model

Intune operates as a Software-as-a-Service (SaaS) platform hosted in Microsoft Azure. Administrators interact with the service through the [Intune admin centre](https://intune.microsoft.com) (a web-based portal) or programmatically via the [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/use-the-api). There are no on-premises servers to deploy or maintain.

The platform integrates natively with:

- **Microsoft Entra ID** (formerly Azure Active Directory) — for identity, device registration, and Conditional Access policy enforcement
- **Microsoft Configuration Manager** — for [co-management scenarios](https://learn.microsoft.com/en-us/mem/configmgr/comanage/overview) where on-premises SCCM and cloud-based Intune share workload responsibilities
- **Microsoft Defender for Endpoint** — for threat signal sharing and device compliance integration
- **Microsoft Purview** — for data loss prevention policy integration

### Graph API Backend

All Intune management operations are ultimately expressed as calls to the [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/overview). The Intune admin centre is itself a consumer of Graph. This means that any management action available in the portal can be scripted or automated using the Graph `deviceManagement` namespace. Policy assignments, compliance queries, device actions (wipe, retire, sync), and reporting are all accessible via Graph endpoints.

### Management Extension

The [Intune Management Extension (IME)](https://learn.microsoft.com/en-us/mem/intune/apps/intune-management-extension) is a lightweight agent deployed to Windows devices. It enables capabilities that extend beyond the standard Windows MDM channel, including:

- PowerShell script execution
- Win32 application deployment
- Windows 10/11 custom compliance script evaluation
- Proactive remediation scripts (Endpoint Analytics)

The IME does not replace MDM — it supplements it for tasks that the native MDM channel does not support.

---

## Device Management vs Application Management

Intune supports two conceptually distinct management paradigms. Organisations may use either independently, or combine them for defence-in-depth protection.

### Mobile Device Management (MDM)

[MDM](https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune) is device-centric. A device is enrolled into Intune, receives an MDM certificate, and is then subject to policies that control the device itself — configuration profiles, compliance policies, security baselines, update rings, and device-targeted app deployments.

MDM is appropriate for organisation-owned devices where the organisation wishes to assert full management authority over the operating system and its configuration.

### Mobile Application Management (MAM)

[MAM](https://learn.microsoft.com/en-us/mem/intune/apps/app-management) is user-centric and data-centric. App protection policies target managed applications and govern how organisational data may be handled within those apps — independently of whether the device is enrolled in MDM.

MAM is the primary management model for BYOD (Bring Your Own Device) scenarios. Organisational data within protected apps (for example, Outlook or Teams) is isolated and controlled without the organisation needing any authority over the device itself.

### Combined MDM + MAM

On enrolled devices, MDM and MAM can be layered. MDM controls the device configuration; app protection policies enforce data handling within managed apps. This is the recommended configuration for corporate-owned mobile devices handling sensitive data.

---

## Enrolment Types

The method by which a device is enrolled determines the degree of management authority Intune has over it. [Enrolment method selection](https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-enrollment) depends on device ownership model, platform, and user experience requirements.

### User-Driven Enrolment

The user initiates enrolment by signing in with an organisational account or by manually installing the Company Portal application. This is the standard model for BYOD and for corporate devices where the device is already in the hands of the end user.

On Windows, user-driven enrolment is most commonly triggered via [Automatic MDM enrolment](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-enroll) when a device joins Microsoft Entra ID.

### Bulk Enrolment

[Bulk enrolment](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-bulk-enroll) uses a provisioning package (created with Windows Configuration Designer) to enrol devices without user interaction. It is suited to kiosk, shared-device, and large-scale deployment scenarios where individual user-driven setup is impractical.

### Apple Automated Device Enrolment (ADE)

[ADE](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos) (formerly Device Enrolment Program / DEP) enables zero-touch enrolment for Apple devices purchased through or assigned to Apple Business Manager (ABM) or Apple School Manager (ASM). Devices are pre-associated with an Intune MDM token before they reach the end user. Upon first power-on, Setup Assistant automatically enrols the device — no user intervention required. ADE produces supervised devices, unlocking the full range of MDM management capabilities on iOS/iPadOS and macOS.

### Windows Autopilot

[Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/overview) is Microsoft's equivalent of zero-touch deployment for Windows. Devices are pre-registered with Autopilot (via hardware hash), and Autopilot profiles are assigned in Intune. When the end user powers on the device and connects to the internet, Autopilot detects the device, downloads the assigned profile, and guides the user (or completes enrolment automatically in self-deploying mode) into a fully configured, Intune-enrolled state.

Autopilot deployment modes include:

| Mode | Description |
| ---- | ----------- |
| [User-Driven (Entra join)](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/azure-ad-join-autopilot-profile) | User signs in; device joins Entra ID |
| [User-Driven (Hybrid join)](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/hybrid-azure-ad-join-autopilot-profile) | Device joins both on-premises AD and Entra ID |
| [Self-Deploying](https://learn.microsoft.com/en-us/autopilot/self-deploying) | No user interaction; device provisions itself |
| [Pre-Provisioning](https://learn.microsoft.com/en-us/autopilot/pre-provision) | Technician pre-stages the device; user completes setup |
| [Existing Devices](https://learn.microsoft.com/en-us/autopilot/existing-devices) | Re-images existing Windows devices into Autopilot flow |

---

## Platform Support Matrix

Intune manages a [broad range of operating systems and versions](https://learn.microsoft.com/en-us/mem/intune/fundamentals/supported-devices-browsers). Key platform support as of 2026:

| Platform | Supported Versions / Notes |
| -------- | -------------------------- |
| **Windows** | Windows 10 (including LTSC 2019/2021), Windows 11, Windows 11 LTSC 2024 |
| **iOS/iPadOS** | iOS/iPadOS 17.x and later required for app protection policies |
| **macOS** | macOS 13.x and later recommended; ADE requires macOS 13.1+ for ACME protocol |
| **Android Enterprise** | Android 10.0+ for user-based management; 8.0+ for userless methods |
| **Linux** | Ubuntu 22.04 LTS — compliance and Conditional Access via Microsoft Edge |

Windows 10 reached end of mainstream support on 14 October 2025. Enrolment remains technically permitted in Intune, but eligibility for all features is not guaranteed on unsupported OS versions.

---

## Management Channels

Once a device is enrolled, Intune delivers policy and configuration through several distinct channels:

### Configuration Profiles

[Configuration profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles) are the primary mechanism for pushing settings to devices. They cover device restrictions, Wi-Fi and VPN credentials, email configuration, certificates, endpoint protection, system extensions, and much more.

On Windows, the [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) provides a searchable interface to thousands of individual CSP settings, replacing the older Administrative Templates (ADMX) experience for most scenarios.

### Compliance Policies

[Compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started) evaluate device state against a defined set of conditions — BitLocker encryption, minimum OS version, jailbreak/root detection, Defender status, and similar signals. Devices that fail compliance are marked non-compliant and can be blocked from accessing organisational resources via Conditional Access.

### Security Baselines

[Security baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) are preconfigured collections of Windows security settings recommended by the Microsoft security team and informed by engagement with agencies including NIST and the US Department of Defense. Available baselines include the Windows Security Baseline, Microsoft Defender for Endpoint Baseline, and Microsoft Edge Baseline. Each baseline is versioned and can be updated independently.

### App Deployment

[App management in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/app-management) supports multiple deployment models:

- **Required** — application is silently installed without user interaction
- **Available** — application appears in Company Portal for user self-service installation
- **Uninstall** — application is removed from targeted devices

Supported app types include Microsoft Store apps, Win32 (.intunewin packages), LOB (line-of-business) apps, web links, managed Apple VPP apps, and Android Enterprise managed apps.

---

## Related Resources

- [What is Microsoft Intune?](https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune)
- [Microsoft Endpoint Manager overview](https://learn.microsoft.com/en-us/mem/endpoint-manager-overview)
- [Supported devices and browsers — Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/supported-devices-browsers)
- [Device enrolment guide for Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-enrollment)
- [Windows Autopilot overview](https://learn.microsoft.com/en-us/autopilot/overview)
- [Set up Automated Device Enrolment for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)
- [App management in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/apps/app-management)
- [Security baselines in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)
- [Compliance policies in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)
- [Configuration profiles overview](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)
- [Microsoft Graph API — deviceManagement](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
