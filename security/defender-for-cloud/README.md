---
title: "Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Microsoft Defender for Cloud

---

## Purpose

Microsoft Defender for Cloud is Microsoft's unified [Cloud-Native Application Protection Platform (CNAPP)](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction), combining Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP) capabilities. It provides continuous security assessment, regulatory compliance monitoring, and threat protection across Azure, on-premises, and multi-cloud environments.

---

## Scope

### Covered

- Cloud Security Posture Management (CSPM) — Secure Score, recommendations, attack path analysis
- Cloud Workload Protection — Servers, databases, storage, containers, Key Vault, App Service
- Multi-cloud security — AWS and GCP connector integration
- Regulatory compliance dashboard — Essential Eight, ISM, PCI DSS, ISO 27001, NIST
- Automation and API integration — Azure Policy, Logic Apps, PowerShell
- Australian context — Essential Eight compliance assessment, ISM alignment, Australian region configuration

### Not Covered

- Microsoft Defender for Endpoint (endpoint management) — see [`security/defender-for-endpoint/`](../defender-for-endpoint/README.md)
- Microsoft Sentinel (SIEM/SOAR) — see [`security/sentinel/`](../sentinel/README.md)
- Microsoft 365 Defender (cross-product XDR portal) — see `security/microsoft-365-defender/` (planned)
- Compliance framework definitions — see [`compliance/`](../../compliance/README.md)

---

## Content Structure

```
defender-for-cloud/
├── README.md                           (this file)
├── configuration/
│   └── azure-policy-initiatives.json   (Azure Policy initiative — government baseline, compliance mappings)
├── explanation/
│   ├── security-architecture.md        (CSPM vs CWPP, Defender plans, E5 integration)
│   └── threat-protection-methodology.md (detection philosophy, signals, alert correlation)
├── how-to/
│   ├── getting-started.md              (enable Defender for Cloud, first recommendations)
│   ├── configure-workload-protection.md (enable Defender plans per workload type)
│   └── compliance-and-governance.md    (regulatory compliance dashboard, E8, ISM, policies)
├── reference/
│   ├── api-and-automation.md           (REST API, Azure Policy, Logic Apps, PowerShell)
│   └── pricing-and-licensing.md        (Defender plan pricing, SKU comparison, E5 value)
└── scripts/
    ├── README.md                       (script index — deployment, monitoring, planning, troubleshooting)
    ├── Deploy-DefenderFoundation.ps1   (foundational CSPM, compliance frameworks, Log Analytics)
    ├── DefenderForCloudScripts.psm1    (PowerShell module manifest and loader)
    ├── Deployment/                     (6 scripts — enterprise, government SOC, DevSecOps, discovery)
    ├── Monitoring/                     (2 scripts — incident response playbooks, threat hunting)
    ├── Planning/                       (4 scripts — risk assessment, ROI, E5 coverage, DCU planning)
    ├── Troubleshooting/                (2 scripts — diagnostics, API retry wrapper)
    └── Tutorials/                      (3 scripts — prerequisites, guided setup, config export)
```

---

## Key Concepts

| Concept | Description | Reference |
|---------|-------------|-----------|
| [Secure Score](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls) | Quantified measure of security posture across Azure resources, expressed as a percentage of maximum achievable score | Microsoft Learn |
| [Recommendations](https://learn.microsoft.com/en-us/azure/defender-for-cloud/recommendations-reference) | Actionable, prioritised findings that improve Secure Score when remediated | Microsoft Learn |
| [Regulatory Compliance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) | Built-in dashboard mapping Azure resource configurations to framework controls (Essential Eight, ISM, PCI DSS, ISO 27001) | Microsoft Learn |
| [Defender Plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans) | Per-workload protection plans (Servers, Databases, Storage, Containers, Key Vault, App Service, DNS, Resource Manager) | Microsoft Learn |
| [Foundational CSPM](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-cloud-security-posture-management) | Free tier — security assessments, Secure Score, and compliance dashboard included with every Azure subscription | Microsoft Learn |
| [Defender CSPM](https://learn.microsoft.com/en-us/azure/defender-for-cloud/tutorial-enable-cspm-plan) | Paid tier ($5/billable resource/month) — adds attack path analysis, cloud security graph, agentless scanning, data security posture management | Microsoft Learn |
| [CWPP](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | Cloud Workload Protection Platform — runtime threat detection and response across servers, containers, databases, and storage | Microsoft Learn |
| [Attack Path Analysis](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-attack-path) | Identifies multi-step paths adversaries could exploit to reach high-value resources; requires Defender CSPM | Microsoft Learn |
| [Cloud Security Graph](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-attack-path) | Graph-based asset relationship model underpinning attack path analysis and contextual risk scoring | Microsoft Learn |

---

## Australian Context

### Essential Eight Compliance Assessment

The [regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) includes a built-in assessment for the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). Defender for Cloud recommendations map directly to Essential Eight controls, enabling:

- Automated technical control assessment (patch applications, configure macro settings, application hardening)
- Secure Score contribution from Essential Eight control implementation
- Evidence generation for Commonwealth reporting under the [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)

### ISM Alignment

The [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) is the primary Australian government security control framework. Defender for Cloud recommendations align with ISM controls in areas including:

- System monitoring and logging (ISM controls in the System Monitoring chapter)
- Patch management (ISM patch application controls)
- Access control (ISM privileged access and multi-factor authentication controls)
- Vulnerability management (ISM vulnerability scanning controls)

### Australian Regions

Microsoft Azure operates data centres in **Australia East** (New South Wales) and **Australia Southeast** (Victoria). Log Analytics workspaces, security data, and Defender for Cloud assessments can be configured to store data within Australia to support:

- [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712) data residency requirements
- Notifiable Data Breaches (NDB) scheme obligations under Part IIIC of the Privacy Act
- Agency-specific data sovereignty requirements under the PSPF

---

## Relationship to Other Domains

| Domain | Relationship |
|--------|-------------|
| [`security/frameworks/essential-eight/`](../frameworks/essential-eight/README.md) | Framework definitions — Defender for Cloud provides the technology implementation |
| [`compliance/essential-eight-alignment/`](../../compliance/essential-eight-alignment/README.md) | Step-by-step compliance alignment — maps Defender recommendations to E8 maturity levels |
| [`security/sentinel/`](../sentinel/README.md) | Microsoft Sentinel ingests Defender for Cloud alerts; provides SIEM/SOAR on top of Defender signals |
| [`identity/conditional-access/`](../../identity/conditional-access/README.md) | Conditional Access policies complement Defender for Cloud's Just-in-Time VM access and identity-based recommendations |
| [`endpoints/intune/`](../../endpoints/intune/README.md) | Intune manages endpoint compliance; Defender for Endpoint (Plan 2, included in Defender for Servers Plan 2) provides EDR |

---

## Related Resources

### Microsoft Learn

- [Defender for Cloud overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Cloud Security Posture Management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-cloud-security-posture-management)
- [Defender plans reference](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans)
- [Regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard)
- [Attack path analysis](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-attack-path)
- [Defender for Cloud pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)

### Australian Regulatory

- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712)
- [Notifiable Data Breaches scheme](https://www.oaic.gov.au/privacy/notifiable-data-breaches)
