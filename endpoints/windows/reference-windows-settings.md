---
title: "Windows Settings Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Windows"
---

# Windows Settings Reference

Reference lookup for Windows endpoint management settings in Microsoft Intune. This document is structured for quick lookup of settings categories, policy parameters, and version-specific configuration details.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive reference tables are to be authored in a future iteration.

---

## Settings Catalogue Categories

**[Microsoft Learn — Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)**

The [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) organises Windows CSP settings into named categories. The categories below represent the primary groupings relevant to endpoint management.

> **TODO**: Build a reference table listing: category name, description, typical use cases, and cross-reference to the underlying CSP namespace. Cover at minimum: Accounts, BitLocker, Browser (Edge), Defender, Delivery Optimisation, Device Health Attestation, Device Lock, Experience, Firewall, Local Policies Security Options, Microsoft Entra, Privacy, Start, System, Update, and Windows Hello for Business.

Key [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) references:

- [BitLocker CSP settings](https://learn.microsoft.com/en-us/windows/client-management/mdm/bitlocker-csp)
- [Policy CSP — overview](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-configuration-service-provider)
- [Windows Firewall CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/firewall-csp)
- [Defender CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/defender-csp)
- [Windows Hello for Business CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/passportforwork-csp)

---

## ADMX-Backed Policy Reference

**[Microsoft Learn — Administrative Templates in Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows)** | **[Ingesting Third-Party ADMX](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-import-custom)**

[Administrative Templates (ADMX)](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows) in Intune expose Group Policy-equivalent settings backed by Microsoft-published ADMX files. Third-party ADMX files (for example, Chrome or Zoom) can be [ingested into Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-import-custom) to extend coverage.

> **TODO**: Build a reference table listing: built-in ADMX policy areas included in Intune Administrative Templates, key policies within each area, equivalent Settings Catalogue path where one exists, and notes on which settings are deprecated or replaced. Also list third-party ADMX templates commonly used in enterprise environments.

---

## Compliance Policy Settings Matrix

**[Microsoft Learn — Windows Compliance Settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)**

The table below will document all configurable settings in a Windows compliance policy.

> **TODO**: Build a reference table with columns: Setting name, Description, Supported Windows editions, Evaluation timing (boot-time vs runtime), Non-compliance impact, and Notes (e.g., TPM dependency, reboot requirement). Cover all settings from the [Windows compliance settings reference](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows).

Categories to cover:

- Device Health (Secure Boot, Code Integrity, BitLocker, Windows Health Attestation)
- Device Properties (OS version min/max, device type restrictions)
- Configuration Manager Compliance (co-management scenarios)
- System Security (encryption, password policy, firewall, TPM, Defender status)
- Microsoft Defender for Endpoint (risk score threshold)

---

## Security Baseline Versions and Settings

**[Microsoft Learn — Security Baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)** | **[Default Windows Baseline Settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-mdm-all)**

> **TODO**: Build a reference table listing current and prior versions of each available security baseline, the release date of each version, the number of settings changed from the prior version, and the recommended upgrade path. Cross-reference with the full settings list at the Microsoft Learn links above.

Current baselines available in Intune:

| Baseline | Current Version | Settings Reference |
| -------- | --------------- | ------------------ |
| [Windows Security Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) | See MS Learn for current | [All settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-mdm-all) |
| [Defender for Endpoint Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender) | See MS Learn for current | [Settings list](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender) |
| [Microsoft Edge Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-edge) | See MS Learn for current | [Settings list](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-edge) |
| [Microsoft 365 Apps Baseline](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-v2-office-settings) | See MS Learn for current | [Settings list](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-v2-office-settings) |

---

## Windows Update Ring Configuration Parameters

**[Microsoft Learn — Update Ring Policy Settings](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-ring-policy-settings)** | **[Feature Update Policy](https://learn.microsoft.com/en-us/intune/device-updates/windows/feature-update-policy)**

The table below will document all configurable parameters in a Windows Update ring policy.

> **TODO**: Build a reference table with columns: Parameter name, Category (Update Ring vs Feature Update), Valid values / range, Default value, and Notes. Cover all parameters from the [Update Ring Policy Settings reference](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-ring-policy-settings), including:

- Servicing channel (General Availability, Windows Insider)
- Feature update deferral (0–365 days)
- Quality update deferral (0–30 days)
- Feature update deadline (2–30 days)
- Quality update deadline (2–30 days)
- Grace period (0–7 days)
- Automatic update behaviour
- Restart deadline and user experience settings
- Pause duration (maximum 35 days)
- Delivery Optimisation settings

For [Autopatch](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq) environments, document the service-managed update group configuration and the distinction between Autopatch-managed policies and admin-created update rings.

---

## Related Resources

- [Settings Catalogue](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)
- [Administrative Templates (ADMX) in Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-windows)
- [Ingest custom ADMX files](https://learn.microsoft.com/en-us/mem/intune/configuration/administrative-templates-import-custom)
- [Windows compliance settings reference](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create-windows)
- [Security baselines overview](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)
- [Default Windows Security Baseline settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-mdm-all)
- [Defender for Endpoint Baseline settings](https://learn.microsoft.com/en-us/mem/intune/protect/security-baseline-settings-defender)
- [Update Ring Policy Settings](https://learn.microsoft.com/en-us/intune/device-updates/windows/update-ring-policy-settings)
- [Feature Update policies](https://learn.microsoft.com/en-us/intune/device-updates/windows/feature-updates)
- [Windows Autopatch FAQ](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq)
- [Policy CSP overview](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-configuration-service-provider)
- [BitLocker CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/bitlocker-csp)
- [Group Policy Analytics](https://learn.microsoft.com/en-us/mem/intune/configuration/group-policy-analytics)
