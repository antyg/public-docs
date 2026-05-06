---
title: "Threat Protection Methodology: How Defender for Cloud Detects and Responds"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "explanation"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Threat Protection Methodology: How Defender for Cloud Detects and Responds

---

## Overview

Understanding how Microsoft Defender for Cloud detects threats — not just that it does — enables practitioners to make sound architectural decisions, tune detection coverage, and interpret alerts correctly. This document explains the detection philosophy, signal sources, alert correlation model, and investigation workflow that underpin Defender for Cloud's Cloud Workload Protection Platform (CWPP) capabilities.

---

## Detection Philosophy: Cloud-Native Signals First

Traditional security products were designed for on-premises environments where the network perimeter was a meaningful control boundary. Cloud workloads invalidate many of those assumptions: compute is ephemeral, network traffic is encrypted end-to-end, and the management plane (Azure Resource Manager) is itself an attack surface.

Defender for Cloud's threat detection is architected around cloud-native signals rather than network-centric ones. The [Microsoft Threat Intelligence](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-overview#threat-intelligence) team analyses over 65 trillion signals per day across Microsoft's global cloud infrastructure. This telemetry informs detection models in three ways:

1. **Known-bad indicators** — IP addresses, domains, and file hashes associated with observed threat actor infrastructure
2. **Behavioural patterns** — sequences of API calls, process executions, or network connections consistent with known attack techniques mapped to the [MITRE ATT&CK framework](https://attack.mitre.org/)
3. **Anomaly baselines** — statistical models of normal behaviour for a given resource type, subscription, or organisation, against which deviations are scored

---

## Signal Sources by Workload Type

Each [Defender plan](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction#defender-plans) collects signals from the telemetry sources most relevant to its protected workload:

| Workload | Primary Signal Sources |
|----------|----------------------|
| **Servers (Plan 2)** | [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/) agent telemetry (process tree, network connections, file system events), Windows Event Log, Linux auditd, Azure Monitor Agent |
| **Databases** | SQL audit logs, query execution patterns, failed authentication events, administrative action logs |
| **Storage** | Blob access logs, metadata operations, geographic access patterns, file hash reputation |
| **Containers** | Kubernetes API server audit logs, container runtime syscall monitoring, image registry events |
| **Key Vault** | Azure Activity Log, Key Vault diagnostic logs (secret access, key operations, certificate lifecycle) |
| **Resource Manager** | Azure Activity Log — all ARM operations for subscription and resource group scope |
| **DNS** | Azure DNS resolver query logs — domain reputation, query frequency, response patterns |

For on-premises and AWS/GCP workloads protected through the [Azure Arc](https://learn.microsoft.com/en-us/azure/azure-arc/overview) integration, signals are forwarded to Azure via the Arc-enabled server agent, maintaining the same detection models across hybrid environments.

---

## Alert Correlation and Incident Construction

Raw signals become [security alerts](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-overview) when the detection engine identifies a pattern that exceeds a confidence threshold. Each alert contains:

- **Alert type** — a stable identifier mapped to a MITRE ATT&CK tactic and technique
- **Severity** — High, Medium, Low, or Informational, reflecting both the confidence of the detection and the potential business impact
- **Evidence** — the specific signal(s) that triggered the alert (process name, IP address, query text, ARM operation)
- **Affected resource** — the specific Azure resource, VM, database, or storage account involved
- **Recommended remediation** — immediate steps to contain or investigate

When multiple alerts are related — for example, a brute-force authentication alert followed by a credential access alert followed by a lateral movement alert on the same resource — Defender for Cloud correlates them into a single [security incident](https://learn.microsoft.com/en-us/azure/defender-for-cloud/incidents-overview). Incidents provide a unified view of an attack sequence, reducing the cognitive load on analysts who would otherwise need to manually connect individual alerts.

If [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview) is connected to Defender for Cloud, incidents are forwarded to Sentinel where they can be enriched with identity signals from [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/) and email signals from [Defender for Office 365](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/), enabling cross-domain attack reconstruction.

---

## Investigation Workflow

Defender for Cloud structures the investigation process around three phases:

### 1. Triage

Alerts are presented in the [Security alerts](https://learn.microsoft.com/en-us/azure/defender-for-cloud/managing-and-responding-alerts) blade, sorted by severity and time. Each alert page includes the MITRE ATT&CK stage classification (Initial Access, Persistence, Privilege Escalation, Defence Evasion, Credential Access, Discovery, Lateral Movement, Execution, Collection, Exfiltration, Impact), which helps analysts contextualise where in an attack sequence they have entered.

### 2. Investigation

The [investigation map](https://learn.microsoft.com/en-us/azure/defender-for-cloud/investigate-threats-workspace) in Defender for Cloud visualises the relationships between alerted entities — virtual machines, users, IP addresses, URLs, processes — as a graph. Analysts can traverse the graph to understand which resources were involved and what sequence of events occurred. Related alerts within the same incident appear as connected nodes.

For deeper forensic investigation, Defender for Servers Plan 2 integrates with [Microsoft Defender for Endpoint's advanced hunting](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/advanced-hunting-overview), enabling raw telemetry queries in KQL (Kusto Query Language) against a 30-day rolling window of endpoint events.

### 3. Response

Defender for Cloud provides [automated response](https://learn.microsoft.com/en-us/azure/defender-for-cloud/workflow-automation) through integration with Azure Logic Apps. Pre-built playbook templates cover common scenarios:

- Isolate a compromised VM by removing it from all network security groups
- Block a suspicious IP address across Azure Firewall policy
- Notify a security team via email, Teams, or a ticketing system webhook
- Open a ServiceNow or Jira ticket with alert details pre-populated

Automated responses can be scoped to trigger on alerts of specific severity levels or types, enabling a tiered model where High severity alerts trigger immediate containment while Medium alerts trigger notification only.

---

## False Positive Management

No detection system achieves zero false positives. Defender for Cloud provides two mechanisms to suppress expected detections without disabling coverage:

- **[Alert suppression rules](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-suppression-rules)** — suppress alerts matching defined criteria (specific resource, IP address, user account) for a configurable duration. Suppressed alerts are still logged but do not appear in the active alerts queue.
- **[Adaptive application controls](https://learn.microsoft.com/en-us/azure/defender-for-cloud/adaptive-application-controls)** — machine-learning-generated allowlists of expected processes for each VM, which reduce the baseline anomaly score for legitimate scheduled tasks or maintenance scripts that would otherwise generate noise.

Both mechanisms require deliberate configuration and produce an audit trail, satisfying the [ALCOA-C](https://www.fda.gov/media/119267/download) attributable and traceable principles for security operations records.

---

## Australian Government Considerations

The [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requires agencies to implement system monitoring that detects cyber security events and supports incident response. Defender for Cloud's CWPP capabilities directly address ISM controls in the System Monitoring chapter, including requirements for:

- Event log collection and centralised logging (satisfied by Azure Monitor Agent and Log Analytics workspace integration)
- Detection of malicious activity (satisfied by Defender plan threat detection)
- Incident response procedures (supported by Logic Apps automation and Sentinel integration)

For PROTECTED workloads, [Microsoft's IRAP-assessed services](https://learn.microsoft.com/en-us/azure/compliance/offerings/offering-australia-irap) documentation should be consulted to confirm the current assessment scope and classification ceiling for Defender for Cloud services operating in Australian regions.

---

## Related Resources

- [Security alerts overview — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-overview)
- [Security incidents — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/incidents-overview)
- [Alert suppression rules — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-suppression-rules)
- [Workflow automation (Logic Apps) — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/workflow-automation)
- [Investigation map — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/investigate-threats-workspace)
- [MITRE ATT&CK framework](https://attack.mitre.org/)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Microsoft IRAP-assessed services (Australia)](https://learn.microsoft.com/en-us/azure/compliance/offerings/offering-australia-irap)
