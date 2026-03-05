# Microsoft Defender for Cloud

**Status**: SUBSTANTIVE — Content will be migrated from existing documentation

This folder will contain comprehensive documentation for Microsoft Defender for Cloud (formerly Azure Security Center and Azure Defender), covering cloud security posture management (CSPM) and cloud workload protection platform (CWPP) capabilities.

## Current Content (Pre-Migration)

The existing documentation library contains approximately **948KB** of Defender for Cloud content organised into:

### Sequential Implementation Guides (19 Documents)

A complete learning path following the Diátaxis documentation framework:

- **00-index.md** — Navigation hub and implementation roadmap
- **01** through **18** — Sequential guides covering:
  - Initial setup and onboarding
  - Multi-cloud integration (Azure, AWS, GCP)
  - Security posture assessment
  - Regulatory compliance dashboards
  - Workload protection (VMs, containers, databases, storage, Key Vault)
  - Threat detection and response
  - Integration with Microsoft Sentinel
  - Advanced features (JIT access, adaptive controls, file integrity monitoring)

### PowerShell Scripts

Organised by function:

- **Deployment** — Automated deployment scripts, workspace creation, policy assignment
- **Monitoring** — Status checks, alert retrieval, compliance reporting
- **Planning** — Cost estimation, feature discovery, gap analysis
- **Troubleshooting** — Diagnostic scripts, connectivity testing, agent validation
- **Tutorials** — Step-by-step automation examples

### Azure Policy Configurations

- Custom policy definitions for Defender for Cloud features
- Initiative (policy set) definitions for compliance frameworks
- Policy assignment templates
- Remediation task automation

### Integration Documentation

- **Microsoft Sentinel** — Log forwarding, incident correlation, automated response
- **Defender for Endpoint** — Unified endpoint and cloud workload visibility
- **Azure Monitor** — Metrics, workbooks, custom alerting
- **Logic Apps** — Workflow automation and orchestration

## Scope

Microsoft Defender for Cloud provides:

### Cloud Security Posture Management (CSPM)

- **Security Recommendations** — Actionable guidance to reduce attack surface
- **Secure Score** — Quantified security posture across cloud resources
- **Regulatory Compliance** — Built-in assessments for ISO 27001, PCI DSS, SOC 2, Essential Eight, and others
- **Multi-Cloud Support** — Unified posture management for Azure, AWS, and GCP
- **Attack Path Analysis** — Identify high-risk paths adversaries could exploit
- **Cloud Security Graph** — Contextual risk analysis across cloud estate

### Cloud Workload Protection (CWP)

- **Virtual Machines** — Threat detection, vulnerability assessment, adaptive application controls
- **Containers** — Kubernetes security, container image scanning, runtime protection
- **Databases** — SQL threat detection, vulnerability assessment, sensitive data discovery
- **Storage** — Malware scanning, anomaly detection, access monitoring
- **Key Vault** — Secrets access monitoring, configuration hardening
- **App Service** — Web application threat detection, runtime protection
- **DNS** — DNS analytics and threat detection
- **Resource Manager** — Control plane threat detection

## Australian Context

The documentation includes Australian-specific configurations:

- **Essential Eight Compliance** — Built-in regulatory compliance assessment for ACSC Essential Eight
- **Australian Regions** — Default configurations for Australia East and Australia Southeast
- **ISM Alignment** — Mapping Defender for Cloud recommendations to Australian ISM controls
- **Local Compliance** — Privacy Act, Notifiable Data Breaches scheme considerations

## Post-Migration Organisation

After migration, content will be organised as:

```
defender-for-cloud/
├── README.md (this file)
├── guides/
│   ├── 00-index.md
│   ├── 01-getting-started.md
│   ├── 02-multi-cloud-onboarding.md
│   └── ... (sequential guides 03-18)
├── scripts/
│   ├── deployment/
│   ├── monitoring/
│   ├── planning/
│   ├── troubleshooting/
│   └── tutorials/
├── policies/
│   ├── definitions/
│   ├── initiatives/
│   └── assignments/
└── integration/
    ├── sentinel/
    ├── defender-for-endpoint/
    ├── azure-monitor/
    └── logic-apps/
```

## Relationship to Frameworks

Defender for Cloud provides **technology implementation** for security controls. Framework definitions live in [`../frameworks/`](../frameworks/), and compliance alignment guidance lives in the separate `compliance/` domain.

### Example Workflow

To implement Essential Eight application control using Defender for Cloud's adaptive application controls:

1. **Read requirements** — `../frameworks/essential-eight/` defines Maturity Level 2 application control requirements
2. **Understand technology** — This folder explains how Defender for Cloud's adaptive application controls work
3. **Implement compliance** — `../../compliance/essential-eight/defender-for-cloud/` provides step-by-step configuration to meet ML2 requirements using adaptive controls

## Documentation Framework

The guides follow the **Diátaxis** documentation framework:

- **Tutorials** — Learning-oriented, step-by-step lessons (guides 01-05)
- **How-To Guides** — Task-oriented, practical steps (guides 06-15)
- **Reference** — Information-oriented, technical descriptions (scripts, policies)
- **Explanation** — Understanding-oriented, conceptual clarity (guides 16-18, integration docs)

This structure supports both new users learning Defender for Cloud and experienced practitioners seeking specific implementation guidance.

## Prerequisites

Defender for Cloud documentation assumes:

- **Azure Subscription** — With appropriate permissions (Security Admin, Contributor, or Owner)
- **PowerShell 7+** — For automation scripts
- **Azure PowerShell Module** — Az.Security, Az.Resources, Az.PolicyInsights
- **Multi-Cloud** (optional) — AWS/GCP accounts with cross-cloud connector permissions

Scripts include Australian region defaults and follow PowerShell best practices documented in `../../standards/powershell.md` (repository governance).

## Resources

Official Microsoft resources:
- [Defender for Cloud Documentation](https://learn.microsoft.com/azure/defender-for-cloud/)
- [Secure Score](https://learn.microsoft.com/azure/defender-for-cloud/secure-score-security-controls)
- [Regulatory Compliance](https://learn.microsoft.com/azure/defender-for-cloud/update-regulatory-compliance-packages)
- [Workload Protections](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)

---

**Note**: This is a substantive folder awaiting content migration. The existing documentation library contains ~948KB of guides, scripts, and configurations that will be organised here following the post-migration structure described above.
