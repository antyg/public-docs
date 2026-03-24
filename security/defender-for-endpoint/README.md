---
title: "Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-08"
audience: "Security engineers, administrators, and analysts managing MDE deployments"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Microsoft Defender for Endpoint

---

## Purpose

Microsoft Defender for Endpoint (MDE) is Microsoft's enterprise [endpoint detection and response (EDR)](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) platform. It provides behavioural-based threat detection, automated investigation and remediation, threat and vulnerability management, and attack surface reduction across Windows, macOS, Linux, iOS, and Android devices.

This domain covers deployment validation, operational methods, and reference material for MDE. It does not cover Defender for Cloud (see `security/defender-for-cloud/`), Intune compliance policies (see `endpoints/intune/`), or framework-to-product compliance mapping (see `compliance/`).

---

## Content Structure

```
defender-for-endpoint/
├── README.md                                          (this file)
├── explanation-validation-methods-overview.md          (comparison of all 7 validation methods)
├── tutorial-powershell-validation.md                   (step-by-step local and remote PowerShell validation)
├── tutorial-graph-api-validation.md                    (step-by-step Graph Security API inventory tutorial)
├── how-to-console-validation.md                        (portal-based verification via Microsoft Defender portal)
├── how-to-advanced-hunting-kql.md                      (KQL queries for deployment verification and hunting)
├── reference-registry-service-reference.md             (registry keys, service names, event IDs)
├── reference-wmi-cim-reference.md                      (WMI class schemas, CIM query patterns)
├── reference-client-analyzer.md                        (MDE Client Analyzer tool reference)
├── scripts/
│   ├── README.md                                      (index of PowerShell automation scripts)
│   ├── Get-MDEStatus.ps1
│   ├── Export-MDEInventoryFromGraph.ps1
│   ├── Test-MDEConnectivity.ps1
│   ├── Get-MDEClientAnalyzer.ps1
│   └── Test-MDEStatusPrerequisites.ps1
└── config/
    ├── README.md                                      (configuration artefacts index)
    ├── MDE-Deployment-Validation-Workbook.json        (Azure Monitor workbook definition)
    └── MDE-Onboarding-Policy-Baseline.json            (MDE onboarding policy settings)
```

---

## Key Concepts

| Concept | Description | Reference |
|---------|-------------|-----------|
| Endpoint Detection and Response (EDR) | Behavioural sensor captures OS signals; cloud analytics generates detections and response recommendations | [MDE overview](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) |
| Attack Surface Reduction (ASR) Rules | Configurable rules blocking malicious behavioural patterns before execution | [ASR rules overview](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction) |
| Threat and Vulnerability Management (TVM) | Continuous software inventory, vulnerability assessment, and risk-based prioritisation | [TVM overview](https://learn.microsoft.com/en-us/defender-endpoint/next-gen-threat-and-vuln-mgt) |
| Advanced Hunting | KQL-based threat hunting across 30 days of raw endpoint telemetry | [Advanced Hunting](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview) |
| Device Inventory | Organisation-wide device list with onboarding status, health state, and risk scores | [Device inventory](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview) |
| Automated Investigation and Response (AIR) | AI-driven investigation triggered by alerts, with automated or manual remediation | [AIR overview](https://learn.microsoft.com/en-us/defender-endpoint/automated-investigations) |
| Response Actions | Isolate device, collect investigation package, run antivirus scan, block files | [Response actions](https://learn.microsoft.com/en-us/defender-endpoint/respond-machine-alerts) |
| Security Baselines | CIS benchmarks and Microsoft security baselines applied as configuration assessments | [Security baselines](https://learn.microsoft.com/en-us/defender-endpoint/configure-machines-security-baseline) |

---

## Validation States

All validation methods in this domain assess the same set of device states, as defined by the [MDE onboarding troubleshooting guide](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding):

| State | Meaning |
|-------|---------|
| **Installed** | SENSE service exists; registry keys present at `HKLM\SOFTWARE\Microsoft\Windows Advanced Threat Protection` |
| **Onboarded** | `OnboardingState` registry value = 1; device appears in Security Console; `onboardingStatus = "Onboarded"` via Graph API |
| **Functional** | SENSE service running; real-time protection enabled; signatures current; no critical SENSE event log errors |
| **Can Be Onboarded** | Device discovered via Device Discovery but not yet onboarded |
| **Unsupported** | OS incompatible with MDE (e.g., Windows 7 without ESU) |

---

## Australian Context

MDE includes Australian-specific regional configuration relevant to all deployments in Australia:

**Regional Endpoints (Gateway Architecture, 2025+)**

| Purpose | Endpoint |
|---------|----------|
| Commands (AUS) | `edr-aus.au.endpoint.security.microsoft.com` |
| Commands (AUE) | `edr-aue.au.endpoint.security.microsoft.com` |
| Cyber Data | `au-v20.events.endpoint.security.microsoft.com` |
| MDAV | `mdav.au.endpoint.security.microsoft.com` |

Scripts in `scripts/` default to Australian (`AU`) region. See [MDE network connectivity requirements](https://learn.microsoft.com/en-us/defender-endpoint/configure-environment) for the full endpoint list.

**Data Residency**: MDE data for Australian tenants is stored in [Australian data centres](https://learn.microsoft.com/en-us/defender-endpoint/data-storage-privacy) (Australia East / Australia Southeast). Verify data residency under Microsoft 365 Admin Centre > Settings > Org Settings > Organisation Profile.

**Essential Eight Alignment**: MDE directly implements several [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) strategies:
- Patch applications and operating systems — TVM identifies and prioritises vulnerabilities
- Restrict administrative privileges — Privileged account alerts and identity integration
- Multi-factor authentication — Conditional Access integration via Entra ID
- Application control — Integration with Windows Defender Application Control (WDAC)

**ISM Controls**: MDE contributes to Australian [Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) controls in the endpoint security and system monitoring categories.

---

## Relationship to Other Domains

| Domain | Relationship |
|--------|--------------|
| `endpoints/intune/` | Intune delivers MDE onboarding packages, configuration profiles, and compliance policies that enforce MDE prerequisites |
| `identity/` | Entra ID Conditional Access can require device health (MDE risk score) as an access condition |
| `security/defender-for-cloud/` | Defender for Cloud extends protection to Azure VMs, containers, and cloud workloads; separate product and separate documentation domain |
| `security/frameworks/` | Framework definitions (Essential Eight, Zero Trust) live here; MDE implements specific controls from those frameworks |
| `compliance/` | Compliance mapping documents (e.g., Essential Eight × MDE) live here; this domain covers product operation |

---

## Related Resources

### Microsoft Learn
- [Microsoft Defender for Endpoint documentation](https://learn.microsoft.com/en-us/defender-endpoint/)
- [MDE minimum requirements](https://learn.microsoft.com/en-us/defender-endpoint/minimum-requirements)
- [Onboarding devices to MDE](https://learn.microsoft.com/en-us/defender-endpoint/onboard-configure)
- [MDE network connectivity requirements](https://learn.microsoft.com/en-us/defender-endpoint/configure-environment)
- [Advanced Hunting schema reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)
- [MDE data storage and privacy](https://learn.microsoft.com/en-us/defender-endpoint/data-storage-privacy)
- [Troubleshoot MDE onboarding issues](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)

### Australian Regulatory
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC — Endpoint Security guidance](https://www.cyber.gov.au/resources-business-and-government/maintaining-devices-and-systems/system-hardening-and-administration/endpoint-hardening)
