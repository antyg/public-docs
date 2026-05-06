---
title: "Security Architecture: Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "explanation"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Security Architecture: Microsoft Defender for Cloud

---

## Overview

Microsoft Defender for Cloud is a [Cloud-Native Application Protection Platform (CNAPP)](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) that unifies two historically separate security disciplines: Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP). Understanding how these disciplines relate — and how Defender for Cloud implements them — is essential for designing effective cloud security architecture in Australian enterprise and government environments.

---

## CSPM vs CWPP: Two Complementary Disciplines

### Cloud Security Posture Management (CSPM)

CSPM answers the question: *is my environment configured securely?*

It operates by continuously assessing the configuration of cloud resources against security policies and compliance frameworks. The output is a set of [recommendations](https://learn.microsoft.com/en-us/azure/defender-for-cloud/recommendations-reference) — prioritised, actionable findings that describe misconfiguration risks. These recommendations aggregate into a [Secure Score](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls), a single percentage metric representing the proportion of achievable security controls that have been implemented.

CSPM is preventive by nature. It does not detect active threats — it identifies conditions that increase attack surface or reduce resilience before an incident occurs.

Defender for Cloud offers CSPM in two tiers:

| Tier | Cost | Key Capabilities |
|------|------|-----------------|
| Foundational CSPM | Free (included with Azure subscription) | Security recommendations, Secure Score, regulatory compliance dashboard, asset inventory |
| [Defender CSPM](https://learn.microsoft.com/en-us/azure/defender-for-cloud/tutorial-enable-cspm-plan) | ~$5 USD per billable resource per month | Attack path analysis, cloud security graph, agentless scanning, data security posture management (DSPM), governance rules |

### Cloud Workload Protection Platform (CWPP)

CWPP answers the question: *are my workloads under active threat?*

It operates at runtime, monitoring the behaviour of compute resources, data services, and cloud management planes to detect anomalous activity consistent with attack patterns. The output is [security alerts](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-overview) — time-stamped, evidence-backed detections that describe what was observed, why it is suspicious, and what to investigate.

CWPP is detective and responsive by nature. It operates in real time, not against a configuration baseline.

---

## Defender Plans: Per-Workload Protection

CWPP capabilities are delivered through [Defender plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans), each targeting a specific workload type. Plans are enabled per subscription and priced per protected resource.

| Defender Plan | Protects | Key Capabilities |
|--------------|---------|-----------------|
| [Defender for Servers Plan 1](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan) | Azure and on-premises VMs | Vulnerability assessment, Just-in-Time VM access, adaptive application controls, file integrity monitoring |
| [Defender for Servers Plan 2](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan) | Azure and on-premises VMs | All Plan 1 capabilities plus Defender for Endpoint integration (EDR), threat and vulnerability management, 500 GB free Log Analytics ingestion |
| [Defender for Databases](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-databases-introduction) | Azure SQL, Cosmos DB, PostgreSQL, MySQL, MariaDB | SQL injection detection, anomalous access alerts, sensitive data discovery, vulnerability assessment |
| [Defender for Storage](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction) | Azure Blob Storage, Azure Files, ADLS Gen2 | Malware scanning, sensitive data discovery, anomalous access detection |
| [Defender for Containers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction) | AKS, Arc-enabled Kubernetes, container registries | Image vulnerability scanning, runtime threat detection, Kubernetes security posture assessment |
| [Defender for Key Vault](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-key-vault-introduction) | Azure Key Vault | Anomalous access alerts, credential theft detection, unusual geographic access |
| [Defender for App Service](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-app-service-introduction) | Azure App Service | Web application threat detection, dangling DNS detection |
| [Defender for Resource Manager](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-resource-manager-introduction) | Azure management plane | Suspicious ARM operations, privilege escalation detection, unusual resource deployments |
| [Defender for DNS](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-dns-introduction) | Azure-native DNS resolution | DNS tunnelling, cryptomining via DNS, malicious domain communication |

---

## Multi-Cloud Architecture

Defender for Cloud is not limited to Azure. It extends CSPM and, for supported workloads, CWPP to AWS and GCP through native connectors.

- **[AWS connector](https://learn.microsoft.com/en-us/azure/defender-for-cloud/quickstart-onboard-aws)**: Provides CSPM assessments for AWS accounts using AWS Security Hub findings and native Defender for Cloud policies. Defender for Servers and Defender for Containers can protect AWS EC2 instances and EKS clusters.
- **[GCP connector](https://learn.microsoft.com/en-us/azure/defender-for-cloud/quickstart-onboard-gcp)**: Provides CSPM assessments for GCP projects. Defender for Servers can protect GCP Compute Engine instances.

Multi-cloud coverage uses a unified [regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) and single Secure Score for the aggregated cloud estate, enabling consistent posture visibility regardless of which cloud hosts a given workload.

---

## Integration with the Microsoft E5 Security Stack

Defender for Cloud is one component within a broader Microsoft security ecosystem. Organisations with [Microsoft 365 E5](https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-defender) licensing gain complementary capabilities that interact with Defender for Cloud:

| E5 Component | Role alongside Defender for Cloud |
|-------------|----------------------------------|
| [Microsoft Defender for Endpoint (MDE)](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/) | Defender for Servers Plan 2 automatically provisions MDE on protected VMs, providing EDR telemetry that feeds into Defender for Cloud alerts |
| [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview) | SIEM platform that ingests Defender for Cloud alerts and security data; enables advanced analytics, automated response, and long-term retention |
| [Microsoft Defender XDR](https://learn.microsoft.com/en-us/microsoft-365/security/defender/) | Cross-workload incident correlation portal that surfaces Defender for Cloud alerts alongside endpoint, identity, and email signals |
| [Microsoft Entra ID (formerly Azure AD)](https://learn.microsoft.com/en-us/entra/identity/) | Provides identity signals; Defender for Cloud recommendations include Entra-specific controls such as MFA enablement and Conditional Access gaps |

The integration between Defender for Cloud and Sentinel is particularly significant for Australian government agencies: Sentinel's [data residency controls](https://learn.microsoft.com/en-us/azure/sentinel/geographical-availability-data-residency) allow all security log data to remain within Australian Azure regions, satisfying obligations under the [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712) and data sovereignty requirements under the [PSPF](https://www.protectivesecurity.gov.au/).

---

## How the Foundational CSPM Free Tier Works

The Foundational CSPM tier is automatically enabled when Defender for Cloud is opened on a subscription. It requires no agents and performs agentless assessment of Azure resource configurations using [Azure Resource Graph](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview) queries. Every Azure resource in scope is evaluated against built-in security policies derived from the [Microsoft Cloud Security Benchmark (MCSB)](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction), which maps to controls from NIST SP 800-53, CIS Benchmarks, ISO 27001, and the ACSC Essential Eight.

The result is a live Secure Score and a prioritised recommendations list — at no additional cost — making it the logical starting point for any organisation beginning its Defender for Cloud journey.

---

## Related Resources

- [Defender for Cloud overview — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Defender CSPM plan — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/tutorial-enable-cspm-plan)
- [Defender plans overview — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans)
- [Microsoft Cloud Security Benchmark — Microsoft Learn](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction)
- [Multi-cloud security — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-multicloud-security-get-started)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
