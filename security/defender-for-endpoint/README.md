# Microsoft Defender for Endpoint

**Status**: SUBSTANTIVE — Content will be migrated from existing documentation

This folder will contain comprehensive documentation for Microsoft Defender for Endpoint (formerly Microsoft Defender ATP), covering endpoint detection and response (EDR), threat and vulnerability management, and automated investigation and remediation.

## Current Content (Pre-Migration)

The existing documentation library contains approximately **382KB** of Defender for Endpoint content organised into:

### Validation Method Guides (8 Documents, ~182KB)

Comprehensive deployment validation using multiple verification approaches:

1. **PowerShell Validation** — Local machine cmdlets, registry checks, service status
2. **Microsoft Graph API Validation** — Tenant-wide inventory, compliance queries, onboarding status
3. **Console Validation** — Microsoft 365 Defender portal verification
4. **Registry Validation** — Direct registry key inspection for onboarding state
5. **KQL Validation** — Advanced hunting queries for deployment verification
6. **Client Analyzer Validation** — Microsoft's official connectivity diagnostic tool
7. **WMI/CIM Validation** — Windows Management Instrumentation queries
8. **Multi-Method Comparison** — Choosing the right validation approach for different scenarios

### Primary Validation Scripts (~148KB)

Production-ready PowerShell scripts for deployment validation:

- **Get-MDEStatus.ps1** — Comprehensive local machine status (service, sense, onboarding, connectivity)
- **Export-MDEInventoryFromGraph.ps1** — Tenant-wide inventory export using Microsoft Graph API
- **Test-MDEConnectivity.ps1** — Connectivity testing to Defender for Endpoint cloud services
- **Get-MDEOnboardingStatus.ps1** — Onboarding state verification (registry + service + sense)
- **Get-MDEComplianceStatus.ps1** — Security baseline compliance reporting
- **Get-MDEThreatStatus.ps1** — Active threat and alert status
- **Invoke-MDEValidation.ps1** — Orchestration script running all validation methods

All scripts include:
- Australian region endpoint defaults
- Comprehensive error handling
- Detailed logging
- Graph API authentication (device code flow)
- Output formatting (console, CSV, JSON)

### Azure Workbook for Deployment Validation (~52KB)

- **MDE-Deployment-Validation.workbook** — Azure Monitor Workbook ARM template
- Visual deployment status dashboard
- Multi-subscription support
- Onboarding progress tracking
- Compliance posture visualisation
- Alert and threat summary

### Integration Documentation

- **Defender for Cloud Integration** — Unified cloud and endpoint security
- **Microsoft Sentinel Integration** — Advanced hunting, incident correlation
- **Intune Integration** — Configuration profiles, compliance policies, deployment automation
- **Graph API Examples** — Automated inventory management, reporting, alerting

## Scope

Microsoft Defender for Endpoint provides:

### Endpoint Detection and Response (EDR)

- **Behavioural Sensors** — In-kernel sensor collecting and processing OS signals
- **Cloud Security Analytics** — Behavioural signals translated to insights, detections, and response recommendations
- **Threat Intelligence** — Microsoft threat intelligence and third-party sources
- **Advanced Hunting** — KQL-based threat hunting across 30 days of raw endpoint data
- **Automated Investigation** — AI-driven investigation and remediation
- **Response Actions** — Isolate device, collect investigation package, run antivirus scan, block/allow files

### Threat and Vulnerability Management

- **Continuous Discovery** — Software inventory, vulnerability assessment, misconfigurations
- **Risk-Based Prioritisation** — Threat context, exploit availability, business impact
- **Remediation Tracking** — Remediation activities, exceptions, SLA monitoring
- **Security Baselines** — CIS benchmarks, Microsoft security baselines, custom configurations

### Attack Surface Reduction

- **ASR Rules** — Configurable rules blocking malicious behaviours
- **Network Protection** — Block connections to malicious domains and IP addresses
- **Web Protection** — Protect against phishing, malware distribution sites
- **Controlled Folder Access** — Ransomware protection for designated folders
- **Device Control** — USB and removable media policies
- **Application Control** — Allow/block application execution (via App Control for Business integration)

### Next-Generation Protection

- **Real-Time Protection** — On-access scanning and monitoring
- **Cloud-Delivered Protection** — Near-instant detection using Microsoft cloud
- **Tamper Protection** — Prevent unauthorised changes to security settings
- **PUA Protection** — Potentially unwanted application blocking

## Australian Context

The documentation includes Australian-specific configurations:

- **Regional Endpoints** — Australia-specific Defender for Endpoint service URLs
- **Data Residency** — Australian data centre storage requirements
- **Essential Eight Alignment** — Defender for Endpoint's role in Essential Eight Maturity Level 2/3 implementation
- **ISM Controls** — Mapping to Australian ISM endpoint security controls
- **Privacy Considerations** — Privacy Act compliance, data collection transparency

All scripts default to Australian regional endpoints and include data residency validation.

## Post-Migration Organisation

After migration, content will be organised as:

```
defender-for-endpoint/
├── README.md (this file)
├── guides/
│   ├── validation/
│   │   ├── powershell-validation.md
│   │   ├── graph-api-validation.md
│   │   ├── console-validation.md
│   │   ├── registry-validation.md
│   │   ├── kql-validation.md
│   │   ├── client-analyzer-validation.md
│   │   ├── wmi-cim-validation.md
│   │   └── multi-method-comparison.md
│   ├── deployment/
│   ├── configuration/
│   └── troubleshooting/
├── scripts/
│   ├── validation/
│   │   ├── Get-MDEStatus.ps1
│   │   ├── Export-MDEInventoryFromGraph.ps1
│   │   ├── Test-MDEConnectivity.ps1
│   │   ├── Get-MDEOnboardingStatus.ps1
│   │   ├── Get-MDEComplianceStatus.ps1
│   │   ├── Get-MDEThreatStatus.ps1
│   │   └── Invoke-MDEValidation.ps1
│   ├── deployment/
│   ├── monitoring/
│   └── response/
├── workbooks/
│   └── MDE-Deployment-Validation.workbook
└── integration/
    ├── defender-for-cloud/
    ├── sentinel/
    └── intune/
```

## Relationship to Frameworks

Defender for Endpoint provides **technology implementation** for endpoint security controls. Framework definitions live in [`../frameworks/`](../frameworks/), and compliance alignment guidance lives in the separate `compliance/` domain.

### Example Workflow

To implement Essential Eight application control using Defender for Endpoint:

1. **Read requirements** — `../frameworks/essential-eight/` defines Maturity Level 2 application control requirements
2. **Understand technology** — This folder explains how Defender for Endpoint's application control integration works
3. **Implement compliance** — `../../compliance/essential-eight/defender-for-endpoint/` provides step-by-step configuration to meet ML2 requirements

Note that Defender for Endpoint integrates with **Windows Defender Application Control** (WDAC, formerly AppLocker) rather than providing native application control. The compliance guidance addresses this integration.

## Validation Philosophy

The validation documentation follows a **multi-method verification** philosophy:

- **Local Validation** — PowerShell, registry, WMI/CIM for single-machine verification
- **Portal Validation** — Microsoft 365 Defender console for visual confirmation
- **API Validation** — Microsoft Graph API for tenant-wide programmatic verification
- **Query Validation** — KQL advanced hunting for data-driven validation
- **Tool Validation** — Microsoft Client Analyzer for official diagnostic confirmation

This approach ensures deployment validation from multiple perspectives, reducing false positives and increasing confidence.

## Prerequisites

Defender for Endpoint documentation assumes:

- **Windows 10/11** or **Windows Server 2016+** (or macOS/Linux/mobile for cross-platform scenarios)
- **Microsoft 365 E5** or **Defender for Endpoint P2** licence
- **PowerShell 7+** — For automation scripts
- **Microsoft.Graph PowerShell Module** — For Graph API validation
- **Appropriate Permissions** — Security Administrator, Global Administrator, or Security Reader

Scripts include comprehensive prerequisite checking and guided authentication flows.

## Australian Regional Endpoints

All documentation and scripts use Australian regional endpoints by default:

- **Service Endpoint**: `https://australia.securitycenter.windows.com`
- **Graph API**: Standard Microsoft Graph endpoints (no regional variance)
- **Data Storage**: Australian data centres (Australia East, Australia Southeast)

Endpoint URLs are configurable for organisations requiring different regions.

## Resources

Official Microsoft resources:
- [Defender for Endpoint Documentation](https://learn.microsoft.com/microsoft-365/security/defender-endpoint/)
- [Onboarding Devices](https://learn.microsoft.com/microsoft-365/security/defender-endpoint/onboard-configure)
- [Advanced Hunting](https://learn.microsoft.com/microsoft-365/security/defender-endpoint/advanced-hunting-overview)
- [Microsoft Graph Security API](https://learn.microsoft.com/graph/api/resources/security-api-overview)

---

**Note**: This is a substantive folder awaiting content migration. The existing documentation library contains ~182KB of validation guides, ~148KB of PowerShell scripts, and ~52KB Azure Workbook that will be organised here following the post-migration structure described above.
