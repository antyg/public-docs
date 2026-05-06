---
title: "Windows Endpoint Management — Concepts"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "Windows"
---

# Windows Endpoint Management — Concepts

Conceptual overview of managing Windows 10 and Windows 11 endpoints via Microsoft Intune. This document covers the key management mechanisms, policy frameworks, and security controls available to endpoint engineers operating a cloud-native or hybrid Windows fleet.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive content is to be authored in a future iteration.

---

## Configuration Profiles and Settings Catalogue

**[Microsoft Learn — Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)** | **[Administrative Templates (ADMX)](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows)**

The [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) is the primary policy authoring surface for Windows configuration in Intune. It provides a searchable, CSP-native interface to thousands of individual settings across categories including security, browser, Microsoft 365 Apps, Windows Update, and platform features.

Prior to the Settings Catalogue, Windows policy was delivered primarily via [Administrative Templates (ADMX ingestion)](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows), which replicated the on-premises Group Policy ADMX experience inside Intune. ADMX-backed policies remain supported and are still required for third-party applications that publish ADMX templates.

Additional profile types available for Windows include:

- **Device restrictions** — controls for hardware features, app access, and user experience
- **Endpoint protection** — Windows Defender, firewall, and attack surface reduction rules
- **Custom OMA-URI** — direct CSP node addressing for settings not yet exposed in the catalogue

> **TODO**: Author conceptual content explaining: how Settings Catalogue profiles differ from ADMX profiles, how CSP paths map to registry keys, when to use each profile type, and the policy conflict resolution model.

---

## Compliance Policies

**[Microsoft Learn — Windows Compliance Settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)**

[Compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started) evaluate device state against a defined set of conditions. Devices that fail compliance are marked non-compliant and can be blocked from accessing organisational resources via [Conditional Access](https://learn.microsoft.com/en-us/mem/intune/protect/conditional-access-intune-common-ways-use).

Key compliance settings for Windows endpoints include:

- **[BitLocker encryption](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)** — verifies BitLocker is active on the OS drive using Windows Device Health Attestation; requires a reboot after encryption completes before the device reports compliant
- **[TPM version](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)** — enforces minimum TPM 1.2 or 2.0; devices without a compatible TPM report as non-compliant
- **OS version thresholds** — minimum and maximum build number constraints for Windows 10 and Windows 11
- **[Windows Health Attestation](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)** — Secure Boot state, Code Integrity, Early Launch Antimalware
- **Microsoft Defender Antivirus status** — real-time protection, signature currency, threat agent status

> **TODO**: Author conceptual content explaining: how compliance evaluation timing works (boot-time vs real-time), the relationship between compliance policies and Conditional Access, the non-compliance action model (grace periods, notifications, wipe), and how multiple compliance policies are resolved when assigned to the same device.

---

## Security Baselines

**[Microsoft Learn — Security Baselines Overview](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)** | **[Defender for Endpoint Baseline Settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender)**

[Security baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) are versioned, preconfigured policy collections that encode Microsoft's recommended security configuration for Windows. They are informed by the Microsoft security team's engagement with enterprise customers and agencies including NIST and the US Department of Defense.

Available baselines include:

| Baseline | Scope |
| -------- | ----- |
| [Windows Security Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) | Core OS hardening — ~350+ settings |
| [Microsoft Defender for Endpoint Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender) | Defender product hardening; not recommended for VMs/VDI |
| [Microsoft Edge Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-edge) | Browser security hardening |
| [Microsoft 365 Apps for Enterprise Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-v2-office-settings) | Office application hardening |

Baselines are versioned; the most recent version should be used for new deployments. Older baseline instances can be updated in-place. Baseline settings that conflict with separately assigned configuration profiles may require deliberate conflict resolution.

> **TODO**: Author conceptual content explaining: how baselines differ from custom configuration profiles, the versioning model and update workflow, how to identify and resolve conflicts between baseline settings and other policies, and when to customise vs accept defaults.

---

## Windows Update for Business

**[Microsoft Learn — Windows Update Management Overview](https://learn.microsoft.com/en-us/intune/device-updates/windows/)** | **[Update Rings Policy Settings](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-ring-policy-settings)**

[Windows Update for Business](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) is the cloud-native mechanism for controlling when Windows devices receive quality and feature updates. Intune surfaces this through two complementary policy types:

**[Update Rings](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-rings)** — General update policy covering deferral periods, deadlines, restart behaviour, and user experience settings. Quality update deferral: 0–30 days. Feature update deferral: 0–365 days.

**[Feature Update Policies](https://learn.microsoft.com/en-us/intune/device-updates/windows/feature-updates)** — Controls which Windows version devices are offered and enforces that version until the policy is changed. Microsoft recommends using feature update policies rather than feature update deferrals in update rings to avoid unnecessary complexity.

**[Windows Autopatch](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq)** — A managed cloud service built on the same feature update and quality update policy surface. Autopatch adds service-managed capabilities: dynamic device grouping, phased rollouts, health monitoring, safeguard holds, and deployment reporting. Autopatch-managed devices should not have custom update rings assigned in parallel.

> **TODO**: Author conceptual content explaining: the relationship between deferral periods, deadlines, and grace periods; how safeguard holds work; the Autopatch deployment group model; how Autopatch differs from manual update ring management; and expedited update deployment for critical security patches.

---

## Group Policy Migration

**[Microsoft Learn — Group Policy Analytics](https://learn.microsoft.com/en-us/mem/intune/configuration/group-policy-analytics)** | **[Migrate GPOs to Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/group-policy-analytics-migrate)**

[Group Policy Analytics](https://learn.microsoft.com/en-us/mem/intune/configuration/group-policy-analytics) is the Intune tool for assessing existing GPOs and mapping them to equivalent Intune Settings Catalogue policies. GPOs exported from Active Directory (as XML, under 4 MB) can be imported into Intune for analysis.

The tool identifies:

- Settings with a direct Settings Catalogue equivalent (migratable)
- Settings that are deprecated or not supported in MDM
- Settings that require custom OMA-URI as an alternative

The migration function generates a Settings Catalogue profile pre-populated with all migratable settings from the imported GPO, which can then be reviewed, adjusted, and deployed via standard Intune policy assignment.

> **TODO**: Author conceptual content explaining: the cloud-native vs hybrid AD device management dichotomy; how to prioritise GPOs for migration; handling unsupported settings with OMA-URI fallbacks; and the phased migration approach for production environments transitioning from on-premises Group Policy.

---

## Endpoint Privilege Management

**[Microsoft Learn — Windows LAPS Overview](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview)** | **[Endpoint Privilege Management](https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview)**

Managing local administrator access on Windows endpoints is a critical security control. Intune provides two related but distinct mechanisms:

**[Windows LAPS (Local Administrator Password Solution)](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview)** — Manages a single designated local administrator account per device. Intune LAPS policies configure password complexity and length, rotation schedule, and backup destination (Microsoft Entra ID or on-premises Active Directory). Password viewing and manual rotation are available to authorised administrators via the Intune admin centre. On Windows 11 24H2, LAPS supports Automatic Account Management for simplified account lifecycle control.

**[Endpoint Privilege Management (EPM)](https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview)** — Part of the Intune Suite. Enables standard users to request or receive temporary elevation for specific applications or tasks, without granting persistent local administrator rights. EPM enforces least-privilege across the Windows fleet while preserving the ability for users to perform necessary elevated operations.

> **TODO**: Author conceptual content explaining: the LAPS backup directory model and recovery key access workflow; how LAPS and EPM complement each other in a least-privilege architecture; EPM elevation rule types (automatic vs user-confirmed); and the licensing requirements for EPM (Intune Suite or Intune Plan 2).

---

## Related Resources

- [Settings Catalogue — Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)
- [Administrative Templates (ADMX) in Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows)
- [Windows compliance settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)
- [Security baselines in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)
- [Windows Security Baseline settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-mdm-all)
- [Defender for Endpoint Baseline settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender)
- [Windows Update Management overview](https://learn.microsoft.com/en-us/intune/device-updates/windows/)
- [Update Rings policy settings](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-ring-policy-settings)
- [Feature Update policies](https://learn.microsoft.com/en-us/intune/device-updates/windows/feature-updates)
- [Windows Autopatch FAQ](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq)
- [Group Policy Analytics](https://learn.microsoft.com/en-us/mem/intune/configuration/group-policy-analytics)
- [Windows LAPS in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview)
- [Endpoint Privilege Management overview](https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview)
