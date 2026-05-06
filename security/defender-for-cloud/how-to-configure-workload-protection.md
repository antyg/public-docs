---
title: "Configure Workload Protection in Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Configure Workload Protection in Microsoft Defender for Cloud

---

## Overview

This guide covers enabling and configuring specific [Defender plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans) for each workload type. Enabling a plan activates runtime threat detection for that resource category. Each plan has plan-specific settings that affect what is monitored and how alerts are generated.

**Prerequisites**: Defender for Cloud enabled on the subscription (see [Getting Started](getting-started.md)). Security Admin role on the subscription.

---

## Defender for Servers

[Defender for Servers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan) protects Azure VMs, Azure Arc-enabled servers (on-premises and other clouds), and AWS/GCP compute instances connected via cloud connectors.

### Choose a Plan Tier

| | Plan 1 (~$5 USD/server/month) | Plan 2 (~$15 USD/server/month) |
|-|-------------------------------|-------------------------------|
| Vulnerability assessment (Qualys or Microsoft TVM) | Yes | Yes |
| Just-in-Time VM access | Yes | Yes |
| Adaptive application controls | Yes | Yes |
| File integrity monitoring | Yes | Yes |
| Network map | Yes | Yes |
| Defender for Endpoint (EDR) integration | No | Yes |
| Threat and vulnerability management (TVM) | No | Yes |
| 500 GB free Log Analytics ingestion/server/month | No | Yes |
| OS-level threat detection (process, network, file events) | No | Yes |

**Recommendation for Australian government**: Plan 2 is appropriate for production servers handling OFFICIAL: Sensitive or above data, or any internet-facing server. Plan 1 is sufficient for isolated development or test servers.

### Enable and Configure

1. In Defender for Cloud > **Environment settings**, select your subscription
2. Under **Defender plans**, set **Servers** to **On**
3. Select the plan tier (Plan 1 or Plan 2)
4. Select **Save**

### Configure Just-in-Time VM Access

[Just-in-Time (JIT) VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview) restricts RDP (3389) and SSH (22) ports at the network security group level, opening them only on-demand for approved requests with time-limited access windows.

1. In Defender for Cloud > **Workload protections** > **Just-in-time VM access**
2. Select **Not configured** tab to see VMs eligible for JIT
3. Select one or more VMs and select **Enable JIT on [N] VMs**
4. Review the default port rules (RDP 3389, SSH 22, WinRM 5985/5986) and adjust to your environment
5. Set maximum request time (recommended: 3 hours maximum per session)
6. Select **Save**

Users can then request access via Defender for Cloud, Azure PowerShell, or the Azure portal. Each approved request is logged with the requesting user's identity, duration, and source IP.

### Configure File Integrity Monitoring

[File Integrity Monitoring (FIM)](https://learn.microsoft.com/en-us/azure/defender-for-cloud/file-integrity-monitoring-overview) tracks changes to Windows registry keys, Windows files, and Linux files and generates alerts when monitored items change.

1. In Defender for Cloud > **Workload protections** > **File integrity monitoring**
2. Select a Log Analytics workspace
3. Select **Enable** for each VM or VM group
4. Review the default monitored paths — Windows includes `C:\Windows\System32`, `C:\Program Files`; Linux includes `/bin`, `/sbin`, `/boot`
5. Add organisation-specific paths (application configuration directories, audit log locations) using **Edit settings**

---

## Defender for Databases

[Defender for Databases](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-databases-introduction) covers Azure SQL Database, SQL Managed Instance, Azure Database for PostgreSQL, MySQL, MariaDB, and Azure Cosmos DB.

### Enable

1. In **Environment settings** > **Defender plans**, set **Databases** to **On**
2. Select **Select types** to enable protection for specific database engines
3. Select **Save**

Enabling Defender for Databases at the subscription level automatically protects all existing and future databases of the selected types within that subscription.

### Enable Vulnerability Assessment

[SQL Vulnerability Assessment](https://learn.microsoft.com/en-us/azure/defender-for-sql/sql-vulnerability-assessment-rules) scans databases for misconfigurations, excessive permissions, and sensitive data exposure. It is included with Defender for Databases.

1. Navigate to a protected SQL database in the Azure portal
2. Under **Security**, select **Microsoft Defender for Cloud**
3. Select **Vulnerability assessment** > **Scan**
4. Review findings by severity — findings include remediation scripts for each issue

Set up a recurring scan by selecting **Periodic recurring scans** and configuring email recipients for scan reports.

---

## Defender for Storage

[Defender for Storage](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction) protects Azure Blob Storage, Azure Files, and Azure Data Lake Storage Gen2.

### Enable

1. In **Environment settings** > **Defender plans**, set **Storage** to **On**
2. Select **Save**

### Configure Malware Scanning

[On-upload malware scanning](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-malware-scan) uses Microsoft Defender Antivirus to scan blobs as they are uploaded. This requires the Defender for Storage plan (not the legacy per-transaction pricing model).

1. Navigate to a storage account in the Azure portal
2. Under **Security + networking**, select **Microsoft Defender for Cloud**
3. Select **Settings** and enable **Malware scanning**
4. Configure the scan cap (default: 5,000 GB/month per storage account) to manage costs
5. Optionally configure an Event Grid topic to receive scan results as events for downstream automation

### Configure Sensitive Data Discovery

[Sensitive data threat detection](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-data-sensitivity) classifies data in storage accounts and raises the severity of alerts when suspicious access involves containers holding sensitive data (PII, credentials, health records).

This feature activates automatically when Defender CSPM is enabled alongside Defender for Storage — no additional configuration is required.

---

## Defender for Containers

[Defender for Containers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction) protects AKS clusters, Azure Container Registry (ACR), and Arc-enabled Kubernetes clusters.

### Enable

1. In **Environment settings** > **Defender plans**, set **Containers** to **On**
2. Select **Save**

### Configure Kubernetes Security Posture Assessment

Defender for Containers automatically assesses AKS cluster configurations against the [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes) and generates recommendations (for example, "Kubernetes clusters should not grant ADMIN privileges", "Pod Security Standards should enforce restricted policy").

These recommendations appear in the main **Recommendations** list and contribute to Secure Score.

### Configure Container Image Scanning

[Container image vulnerability scanning](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-container-registries-introduction) scans images in Azure Container Registry and identifies OS and language package vulnerabilities.

Scanning occurs:
- When an image is pushed to ACR (trigger: push event)
- When a previously clean image is reassessed after new vulnerability data is published (periodic rescan)

No additional configuration is required once the plan is enabled. Scan results appear as recommendations in the form "Container registry images should have vulnerability findings resolved".

### Configure Runtime Threat Detection

Runtime threat detection for AKS requires the **Defender profile** (a DaemonSet) to be deployed to the cluster. Deploy it using:

```powershell
az aks update --enable-defender --resource-group <rg-name> --name <cluster-name>
```

Or enable it via the Azure portal under the AKS cluster > **Microsoft Defender for Cloud** > **Settings**.

---

## Defender for Key Vault

[Defender for Key Vault](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-key-vault-introduction) monitors access patterns to Key Vault instances and generates alerts for anomalous behaviour such as:

- Access from unusual geographic locations or IP addresses
- High volume of operations indicative of enumeration
- Access by an application that has not previously accessed the vault
- Suspicious permission listing (reconnaissance for credential theft)

### Enable

1. In **Environment settings** > **Defender plans**, set **Key Vault** to **On**
2. Select **Save**

No plan-specific configuration is required. Protection is applied to all Key Vault instances in the subscription automatically.

---

## Verify Plan Status Across Subscriptions

For organisations managing multiple subscriptions, use [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) to enforce Defender plan enablement at the management group level.

The built-in policy initiative **"Configure Microsoft Defender for Cloud plans"** can be assigned to a management group to audit or enforce that each Defender plan is enabled across all child subscriptions. This prevents new subscriptions from being created without protection and surfaces existing gaps in the Defender for Cloud compliance view.

---

## Related Resources

- [Defender for Servers plan comparison — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan)
- [Just-in-Time VM access — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview)
- [Defender for Databases — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-databases-introduction)
- [Defender for Storage — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction)
- [Defender for Containers — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction)
- [Defender for Key Vault — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-key-vault-introduction)
- [Defender for Cloud pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)
- [ACSC Essential Eight — application control](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-explained)
