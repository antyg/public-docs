---
title: "Pricing and Licensing Reference: Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "reference"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Pricing and Licensing Reference: Microsoft Defender for Cloud

---

## Overview

Microsoft Defender for Cloud uses a two-tier pricing model: a free foundational tier (included with every Azure subscription) and paid Defender plans priced per protected resource per month. This reference documents the plan pricing structure, what is included versus what requires a paid plan, and the licensing interaction with Microsoft 365 E5.

> **Currency and accuracy note**: Prices shown are approximate USD figures based on [Microsoft's published pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/) as of the document date. Verify current pricing through the Azure portal pricing calculator or your Microsoft licensing agreement. Australian government organisations should obtain pricing through their volume licensing reseller or Microsoft account team.

---

## Foundational CSPM (Free Tier)

The Foundational CSPM tier is **included at no additional cost** with every Azure subscription. It activates automatically when Defender for Cloud is first opened on a subscription.

**Included capabilities**:

- Security recommendations based on the [Microsoft Cloud Security Benchmark (MCSB)](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction)
- [Secure Score](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls) — aggregated posture metric across all subscription resources
- [Regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) — built-in assessment for Essential Eight, ISM, PCI DSS, ISO 27001, NIST, CIS Benchmarks, and 50+ other frameworks
- Asset inventory — real-time discovery and classification of all Azure resources
- Basic threat detection via Azure Activity Log analysis

**Not included in Foundational CSPM**:

- Runtime threat detection for workloads (requires Defender plans)
- Attack path analysis (requires Defender CSPM paid tier)
- Agentless vulnerability scanning (requires Defender CSPM or Defender for Servers Plan 2)
- Data security posture management (requires Defender CSPM)

---

## Defender CSPM (Paid CSPM Tier)

**Approximate cost**: ~$5 USD per billable resource per month

A billable resource is an Azure resource counted by Azure Resource Graph when Defender CSPM is enabled. Not all resource types are billable — Microsoft publishes the [resource types that count toward billing](https://learn.microsoft.com/en-us/azure/defender-for-cloud/tutorial-enable-cspm-plan).

**Additional capabilities over Foundational CSPM**:

| Capability | Description |
|-----------|-------------|
| [Attack path analysis](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-attack-path) | Identifies multi-step exploitation paths adversaries could use to reach high-value resources |
| [Cloud security graph](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-attack-path) | Asset relationship model enabling contextual risk queries |
| Agentless VM scanning | Vulnerability and secret scanning without deploying an agent |
| Data security posture management (DSPM) | Classifies sensitive data in storage and databases; raises alert severity for sensitive data exposure |
| Governance rules | Assigns ownership and due dates to recommendations |
| Code-to-cloud contextual security | Maps cloud resource risks back to source code repositories |

---

## Defender Plans: Per-Workload Pricing

### Defender for Servers

| Plan | Approximate Cost | Key Included Capabilities |
|------|-----------------|--------------------------|
| [Plan 1](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan) | ~$5 USD/server/month | Vulnerability assessment, Just-in-Time VM access, adaptive application controls, file integrity monitoring, network map |
| [Plan 2](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan) | ~$15 USD/server/month | All Plan 1 capabilities, Defender for Endpoint integration (EDR), threat and vulnerability management, 500 GB free Log Analytics ingestion per server per month |

A "server" counts as: an Azure VM, an Azure Arc-enabled on-premises server, an AWS EC2 instance connected via cloud connector, or a GCP Compute Engine instance connected via cloud connector.

### Defender for Databases

**Approximate cost**: ~$15 USD per database server instance per month

Covers: Azure SQL Database, Azure SQL Managed Instance, Azure Database for PostgreSQL, Azure Database for MySQL, Azure Database for MariaDB, Azure Cosmos DB, Azure Synapse Analytics.

Capabilities: SQL injection detection, anomalous access alerts, database activity monitoring, sensitive data discovery, vulnerability assessment.

### Defender for Storage

**Approximate cost**: ~$10 USD per storage account per month (activity-based monitoring) plus per-GB malware scanning costs where enabled.

Covers: Azure Blob Storage, Azure Files, Azure Data Lake Storage Gen2.

Capabilities: Malware scanning on upload, sensitive data discovery, anomalous access detection, hash reputation-based threat detection.

### Defender for Containers

**Approximate cost**: ~$7 USD per vCore per month (for AKS clusters and Arc-enabled Kubernetes).

Covers: Azure Kubernetes Service (AKS), Azure Container Registry (ACR), Arc-enabled Kubernetes clusters, AWS EKS, GCP GKE.

Capabilities: Container image vulnerability scanning, Kubernetes security posture assessment (CIS benchmark), runtime threat detection, supply chain security.

### Defender for Key Vault

**Approximate cost**: ~$0.02 USD per 10,000 operations (transaction-based pricing)

Capabilities: Anomalous access detection, geographic anomaly alerts, credential enumeration detection.

### Defender for App Service

**Approximate cost**: ~$15 USD per App Service plan per month

Capabilities: Web application threat detection, dangling DNS detection, unusual activity alerts.

### Defender for Resource Manager

**Approximate cost**: ~$4 USD per subscription per month

Capabilities: Azure management plane threat detection, suspicious ARM operations, privilege escalation detection.

### Defender for DNS

**Approximate cost**: ~$0.70 USD per million queries per month

Capabilities: DNS tunnelling detection, cryptomining via DNS, malicious domain communication detection.

---

## Microsoft 365 E5 Licensing Interaction

[Microsoft 365 E5](https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-defender) licensing includes [Microsoft Defender for Endpoint (MDE) Plan 2](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/microsoft-defender-endpoint). This has a direct pricing interaction with Defender for Servers:

**If your organisation has M365 E5 or MDE Plan 2 licensing**:

- Enabling **Defender for Servers Plan 2** on the subscription allows Defender for Cloud to automatically onboard those VMs to the MDE tenant provisioned by your M365/MDE licence
- You **do not pay twice** for MDE coverage: the Defender for Servers Plan 2 fee covers the Azure-side integration and cloud workload threat detection; the MDE licence you already hold covers the endpoint EDR capability
- This is the most cost-effective configuration for organisations with E5 licensing

**If your organisation does not have M365 E5 or MDE licensing**:

- Defender for Servers Plan 2 still provisions an MDE licence for the protected servers, included in the Plan 2 per-server price
- This means Defender for Servers Plan 2 effectively bundles EDR for cloud VMs without requiring a separate MDE licence

---

## SKU Comparison Summary

| Capability | Foundational CSPM | Defender CSPM | Servers P1 | Servers P2 |
|-----------|:-----------------:|:-------------:|:----------:|:----------:|
| Security recommendations | Yes | Yes | Yes | Yes |
| Secure Score | Yes | Yes | Yes | Yes |
| Regulatory compliance dashboard | Yes | Yes | Yes | Yes |
| Attack path analysis | No | Yes | No | No |
| Agentless VM scanning | No | Yes | No | Yes |
| Runtime threat detection (OS-level) | No | No | No | Yes |
| Vulnerability assessment | No | No | Yes | Yes |
| Just-in-Time VM access | No | No | Yes | Yes |
| Defender for Endpoint integration | No | No | No | Yes |
| 500 GB free Log Analytics/server | No | No | No | Yes |
| Data security posture management | No | Yes | No | No |
| Governance rules | No | Yes | No | No |

---

## Cost Management Tips

- Use the [Defender for Cloud pricing calculator](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/) to estimate monthly costs before enabling plans
- Start with Foundational CSPM on all subscriptions — this is free and provides immediate value
- Enable paid Defender plans selectively based on workload risk classification, starting with production internet-facing resources
- Use [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/) to set budget alerts on Defender for Cloud spend
- For Defender for Storage, configure malware scanning caps per storage account to prevent unexpected per-GB charges from high-volume upload scenarios

---

## Related Resources

- [Defender for Cloud pricing — Microsoft](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)
- [Defender for Cloud pricing FAQ — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/faq-defender-for-servers)
- [Defender for Servers plan selection — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan)
- [Azure Cost Management — Microsoft Learn](https://learn.microsoft.com/en-us/azure/cost-management-billing/)
- [Microsoft 365 E5 overview — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-defender)
- [Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
