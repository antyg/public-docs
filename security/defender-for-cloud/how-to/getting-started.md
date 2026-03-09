---
title: "Getting Started with Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Getting Started with Microsoft Defender for Cloud

---

## Overview

This guide walks through enabling Microsoft Defender for Cloud on an Azure subscription, enabling Defender plans for workload protection, configuring auto-provisioning of monitoring agents, and reviewing your first security recommendations. Completing these steps establishes a functional security baseline and prepares the environment for deeper configuration.

**Time to complete**: 30–60 minutes
**Prerequisites**: Azure subscription with Owner or Contributor and Security Admin role assignments

---

## Step 1: Open Defender for Cloud and Enable Foundational CSPM

The [Foundational CSPM tier](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-cloud-security-posture-management) is free and activates automatically when you first open Defender for Cloud on a subscription.

1. Sign in to the [Azure portal](https://portal.azure.com)
2. Search for **Microsoft Defender for Cloud** in the top search bar and select it
3. If prompted, select **Get started** — this activates Foundational CSPM assessment on the current subscription

Defender for Cloud will begin assessing your subscription's resources against the [Microsoft Cloud Security Benchmark (MCSB)](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction). The initial assessment typically completes within 15–30 minutes for subscriptions with fewer than 500 resources.

> **Australian note**: At this point, no data has left your subscription. Foundational CSPM operates by querying Azure Resource Graph — your resource configurations are assessed in place. If you are establishing a Log Analytics workspace for security data, choose **Australia East** (New South Wales) or **Australia Southeast** (Victoria) to satisfy data residency requirements under the [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712).

---

## Step 2: Review Your Secure Score and Initial Recommendations

After the initial assessment:

1. In Defender for Cloud, select **Posture Management** > **Secure score**
2. Review the overall percentage — this is your current proportion of implemented security controls relative to the maximum achievable
3. Select **Improve your secure score** to see the recommendations list
4. Recommendations are grouped into [security controls](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls) — logical clusters such as "Enable MFA", "Remediate vulnerabilities", "Restrict unauthorised network access"

Each recommendation shows:
- **Max score increase** — the Secure Score points you gain by completing it
- **Affected resources** — which specific resources need remediation
- **Remediation steps** — instructions to fix the issue, often including a quick-fix button for automated remediation

Focus first on recommendations flagged as **High** severity with a high max score increase — these deliver the greatest security improvement per unit of effort.

---

## Step 3: Enable Defender Plans for Workload Protection

Foundational CSPM provides posture assessment but not runtime threat detection. To enable active protection, you need to enable [Defender plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans).

1. In Defender for Cloud, select **Environment settings**
2. Expand your Azure tenant and select the subscription you want to configure
3. Select **Defender plans**
4. You will see a grid of all available Defender plans with their current state (On/Off)

Enable plans selectively based on your workload inventory:

| If you have | Enable |
|-------------|--------|
| Azure VMs or on-premises servers | Defender for Servers (Plan 1 or Plan 2) |
| Azure SQL, PostgreSQL, MySQL, Cosmos DB | Defender for Databases |
| Azure Blob Storage, Azure Files, ADLS Gen2 | Defender for Storage |
| AKS clusters or container registries | Defender for Containers |
| Azure Key Vault | Defender for Key Vault |
| Azure App Service apps | Defender for App Service |

5. Toggle each relevant plan to **On**
6. For **Defender for Servers**, select the plan tier:
   - **Plan 1** (~$5 USD/server/month) — vulnerability assessment, Just-in-Time VM access, adaptive application controls
   - **Plan 2** (~$15 USD/server/month) — all Plan 1 capabilities plus Defender for Endpoint integration (EDR) and 500 GB free Log Analytics ingestion per server per month
7. Select **Save** to apply changes

> **Cost note**: Plans are billed per protected resource per month. The [Defender for Cloud pricing page](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/) lists current rates. For Australian government procurement, validate current pricing through your Microsoft licensing agreement or volume licensing reseller.

---

## Step 4: Configure Auto-Provisioning of Monitoring Agents

Defender for Servers and Defender for Databases require monitoring agents on protected resources. Auto-provisioning deploys and maintains these agents automatically.

1. In **Environment settings**, select your subscription
2. Select **Auto provisioning**
3. Review the list of available extensions and their current state:

| Extension | Required for |
|-----------|-------------|
| Log Analytics agent (MMA) or Azure Monitor Agent (AMA) | Server threat detection, security event collection |
| Microsoft Defender for Endpoint integration | Defender for Servers Plan 2 (EDR capabilities) |
| Vulnerability assessment solution | Vulnerability scanning recommendations |
| Guest Configuration agent | VM OS security configuration assessment |

4. Toggle **Log Analytics agent** (or **Azure Monitor Agent** — AMA is the current-generation replacement) to **On**
5. Select your Log Analytics workspace:
   - Select an existing workspace in an Australian region, or
   - Allow Defender for Cloud to create a default workspace (it will use the same region as the subscription's primary region)
6. Toggle **Microsoft Defender for Endpoint integration** to **On** if you have enabled Defender for Servers Plan 2
7. Select **Save**

Auto-provisioning will deploy the agent to all existing and future VMs in scope. Allow 30–60 minutes for agents to deploy across large VM fleets.

---

## Step 5: Connect Multi-Cloud Environments (Optional)

If your organisation uses AWS or GCP in addition to Azure, you can extend Defender for Cloud's CSPM coverage to those environments.

1. In Defender for Cloud, select **Environment settings**
2. Select **Add environment** > **Amazon Web Services** or **Google Cloud Platform**
3. Follow the connector wizard — this creates a cross-account IAM role (AWS) or service account (GCP) that grants Defender for Cloud read access to resource configurations
4. Select which Defender plans to extend to the connected cloud account

Multi-cloud connectors provide a unified [Secure Score](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls) and [regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) across your entire cloud estate.

---

## Step 6: Set Up Email Notifications

Configure Defender for Cloud to send alerts to your security team.

1. In **Environment settings**, select your subscription
2. Select **Email notifications**
3. Enter the email address(es) that should receive security alerts
4. Select the minimum alert severity to trigger notifications (recommended: **High**)
5. Enable **Also notify subscription owners** if appropriate for your governance model
6. Select **Save**

---

## Verify Your Configuration

After completing these steps, confirm:

- [ ] Defender for Cloud is open on the target subscription
- [ ] Foundational CSPM has completed its initial assessment (Secure Score is populated)
- [ ] At least one Defender plan is enabled and showing **On**
- [ ] Auto-provisioning is configured and agents are deploying to VMs
- [ ] Email notifications are configured for High severity alerts
- [ ] Log Analytics workspace is in an Australian region (Australia East or Australia Southeast)

---

## Next Steps

- Configure your workload-specific Defender plan settings — see [Configure Workload Protection](configure-workload-protection.md)
- Add the ACSC Essential Eight and ISM regulatory compliance standards — see [Compliance and Governance](compliance-and-governance.md)
- Understand what Defender for Cloud detected and why — see [Threat Protection Methodology](../explanation/threat-protection-methodology.md)

---

## Related Resources

- [Quickstart: Enable Defender for Cloud — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/get-started)
- [Defender plans overview — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans)
- [Auto provisioning — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/monitoring-components)
- [Secure Score — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls)
- [Defender for Cloud pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Privacy Act 1988](https://www.legislation.gov.au/Series/C2004A03712)
