---
title: "Microsoft Sentinel"
status: "draft"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Microsoft Sentinel

---

## Overview

Microsoft Sentinel is a cloud-native Security Information and Event Management (SIEM) and Security Orchestration, Automation, and Response (SOAR) platform built on Azure. It provides intelligent security analytics and threat intelligence across the enterprise, enabling threat detection, investigation, hunting, and response at cloud scale.

Sentinel ingests data from across your entire environment — Microsoft services, third-party solutions, on-premises infrastructure, and custom sources — into a single platform for unified analysis and response. It is built on [Azure Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview), which provides the underlying query and storage capabilities.

Source: [Microsoft Sentinel overview](https://learn.microsoft.com/en-us/azure/sentinel/overview)

---

## Scope

This documentation covers Microsoft Sentinel deployment, configuration, and operations for security teams using Microsoft Azure. It addresses:

- Data connector configuration for Microsoft and third-party sources
- Analytics rules for threat detection
- Workbooks for security monitoring dashboards
- Automation and SOAR through playbooks and automation rules
- Threat hunting with KQL queries
- Incident management and investigation workflows

It does not cover Microsoft Defender XDR (formerly Microsoft 365 Defender) standalone deployment, Azure Monitor alerting outside of security operations, or Log Analytics workspace configuration for non-security workloads.

---

## Core Capabilities

### Data Ingestion

Sentinel aggregates security telemetry through [data connectors](https://learn.microsoft.com/en-us/azure/sentinel/connect-data-sources). Connector types include:

| Connector Type | Examples | Collection Method |
|---------------|----------|------------------|
| **Microsoft native** | Microsoft Entra ID, Defender for Endpoint, Defender for Cloud, Microsoft 365 | Direct API integration — one-click enablement |
| **Azure Diagnostics** | Azure Activity logs, Azure Firewall, NSG flow logs | Diagnostic settings to Log Analytics |
| **Syslog / CEF** | Linux hosts, network appliances, third-party security tools | Azure Monitor Agent (AMA) on a forwarder |
| **REST API / Logic Apps** | Custom sources, SaaS applications | Logs Ingestion API or Data Collection Rules |
| **Community / Marketplace** | Partner solutions in Content Hub | Solution-specific connectors |

Source: [Microsoft Sentinel data connectors reference](https://learn.microsoft.com/en-us/azure/sentinel/data-connectors-reference)

**Important**: The legacy HTTP Data Collector API is deprecated and will not be supported after September 30, 2026. New integrations must use the [Logs Ingestion API](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview) or [Codeless Connector Framework (CCF)](https://learn.microsoft.com/en-us/azure/sentinel/create-codeless-connector).

### Threat Detection — Analytics Rules

[Analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-built-in) define the conditions under which Sentinel creates incidents. Rule types:

| Rule Type | Description | Best For |
|-----------|-------------|----------|
| **Scheduled** | KQL query runs on a schedule; alerts on matching results | Custom detections, tuned queries |
| **NRT (Near Real-Time)** | Query runs every minute; minimal latency | High-priority detections requiring fast response |
| **Microsoft Security** | Forwards alerts from Defender products as incidents | Simple integration of Defender XDR alerts |
| **Anomaly** | ML-based detection of unusual behaviour | Detecting deviations from baseline without predefined rules |
| **Fusion** | Correlates low-fidelity signals into high-confidence incidents | Advanced multi-stage attack detection |
| **Threat Intelligence** | Matches ingested IOCs against log data | IOC-based detection from threat intel feeds |

### Security Monitoring — Workbooks

[Sentinel workbooks](https://learn.microsoft.com/en-us/azure/sentinel/monitor-your-data) are interactive Azure Monitor dashboards visualising security data from Log Analytics. They provide:

- Real-time and historical security posture views
- Data connector health monitoring
- Incident metrics and mean time to respond (MTTR) tracking
- Custom operational dashboards for SOC teams

Pre-built workbooks are included with most Sentinel content solutions in the Content Hub.

### Automation — SOAR

Sentinel provides two automation mechanisms:

| Mechanism | Technology | Use Case |
|-----------|-----------|---------|
| **Automation rules** | Native Sentinel rules engine | Triage, assignment, tag, and suppress incidents based on conditions; trigger playbooks |
| **Playbooks** | Azure Logic Apps | Enrichment, notification, containment actions; integrate with external APIs and services |

Source: [Automate incident handling with automation rules](https://learn.microsoft.com/en-us/azure/sentinel/automate-incident-handling-with-automation-rules); [Automate threat response with playbooks](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks)

### Threat Hunting

Sentinel's [hunting queries](https://learn.microsoft.com/en-us/azure/sentinel/hunting) allow analysts to proactively search for threats across ingested data using [Kusto Query Language (KQL)](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/). Key features:

- Pre-built hunting queries from Microsoft and the community (GitHub: [Azure-Sentinel](https://github.com/Azure/Azure-Sentinel))
- **Livestream** — Run a query continuously and get notified when results appear
- **Bookmarks** — Save interesting query results during investigations for correlation

### Incident Management

Sentinel consolidates alerts into [incidents](https://learn.microsoft.com/en-us/azure/sentinel/incident-investigation) — tracked investigations with a timeline, evidence, comments, and assigned analyst. Incidents include:

- Automatically correlated alerts from multiple analytics rules
- Entity enrichment (user, device, IP reputation)
- Investigation graph for visualising relationships between entities
- Integration with Microsoft Defender XDR for unified incident management

---

## Portal Transition Notice

After **March 31, 2027**, Microsoft Sentinel will be available only in the [Microsoft Defender portal](https://security.microsoft.com). The Azure portal experience will be redirected. Microsoft recommends planning the transition to the unified Defender portal for a unified security operations experience.

Source: [Microsoft Sentinel in the Microsoft Defender portal](https://learn.microsoft.com/en-us/azure/sentinel/microsoft-sentinel-defender-portal)

---

## Deployment Prerequisites

| Requirement | Details |
|-------------|---------|
| Azure subscription | Required; Sentinel billed per GB ingested (pay-as-you-go or commitment tiers) |
| Log Analytics workspace | Sentinel is enabled on top of an existing or new workspace |
| Workspace region | Select a region appropriate for data residency requirements; Australian regions available (Australia East, Australia Southeast) |
| Permissions | Microsoft Sentinel Contributor role to enable and configure; Reader role for read-only access |
| Licences | Microsoft Sentinel is licensed per GB ingested; certain Microsoft data connectors included at no extra cost with Microsoft 365 E5 / Microsoft Defender plans |

Source: [Quickstart: Onboard Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/quickstart-onboard)

---

## Australian Considerations

- **Data residency**: Deploy the Log Analytics workspace in **Australia East** (Sydney) or **Australia Southeast** (Melbourne) to keep security telemetry within Australian borders. Verify that all connected data sources route to the Australian workspace.
- **Essential Eight alignment**: Sentinel directly supports [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) Strategy 7 (MFA monitoring) and provides detection capabilities supporting all eight strategies through analytics rules.
- **ISM logging requirements**: The [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) specifies log retention requirements (typically 7 years for sensitive government information). Configure Log Analytics workspace [data retention settings](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure) accordingly.

---

## Related Resources

- [Microsoft Sentinel documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
- [Microsoft Sentinel overview](https://learn.microsoft.com/en-us/azure/sentinel/overview)
- [Quickstart: Onboard Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/quickstart-onboard)
- [Microsoft Sentinel data connectors](https://learn.microsoft.com/en-us/azure/sentinel/connect-data-sources)
- [Microsoft Sentinel analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-built-in)
- [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- [Azure Sentinel GitHub community](https://github.com/Azure/Azure-Sentinel)
- [ACSC ISM — Audit and logging](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
