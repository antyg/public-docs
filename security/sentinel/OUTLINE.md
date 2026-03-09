---
title: "Microsoft Sentinel — Content Outline"
status: "planned"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Microsoft Sentinel — Content Outline

This document defines the planned documentation structure for the Microsoft Sentinel section. Each section lists the content to be authored and the authoritative citation sources.

---

## Section 1 — Data Connectors

**Goal**: Comprehensive reference for connecting data sources to Microsoft Sentinel.

### 1.1 — Microsoft Native Connectors

Content to cover:
- Microsoft Entra ID (sign-in logs, audit logs, provisioning logs, Identity Protection alerts)
- Microsoft Defender XDR (incidents, alerts, advanced hunting data)
- Microsoft Defender for Endpoint (device events, alerts)
- Microsoft Defender for Cloud (security alerts, regulatory compliance)
- Microsoft Defender for Cloud Apps (activity logs, alerts)
- Microsoft 365 (Exchange, SharePoint, Teams activity via Office 365 Management Activity API)
- Azure Activity (subscription-level operations)
- Azure Firewall diagnostics

Citation sources:
- [Microsoft Sentinel data connectors reference](https://learn.microsoft.com/en-us/azure/sentinel/data-connectors-reference)
- [Connect Microsoft Entra ID to Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/connect-azure-active-directory)
- [Connect Microsoft Defender XDR to Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/connect-microsoft-365-defender)

### 1.2 — Syslog and CEF Connectors

Content to cover:
- Azure Monitor Agent (AMA) deployment for log forwarding
- CEF format requirements and forwarder VM sizing
- Linux Syslog connector configuration
- Common sources: Palo Alto, Fortinet, Cisco ASA, F5
- Troubleshooting data flow gaps

Citation sources:
- [Syslog and CEF via AMA](https://learn.microsoft.com/en-us/azure/sentinel/connect-cef-ama)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)

### 1.3 — Custom and REST API Connectors

Content to cover:
- Logs Ingestion API — architecture and authentication
- Data Collection Rules (DCRs) and Data Collection Endpoints (DCEs)
- Codeless Connector Framework (CCF) for partner solutions
- Migration from deprecated HTTP Data Collector API (deprecated: September 30, 2026)

Citation sources:
- [Logs Ingestion API](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview)
- [Codeless Connector Framework](https://learn.microsoft.com/en-us/azure/sentinel/create-codeless-connector)
- [Data Collection Rules overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)

### 1.4 — Content Hub Solutions

Content to cover:
- What Content Hub solutions are (bundled connectors + rules + workbooks + playbooks)
- Installing and managing solutions
- Key solutions: Microsoft 365 Defender, Entra ID, Azure Activity, Defender for Cloud
- Community solutions vs. Microsoft-maintained solutions

Citation sources:
- [Microsoft Sentinel Content Hub](https://learn.microsoft.com/en-us/azure/sentinel/sentinel-solutions-catalog)
- [Discover and manage Sentinel content](https://learn.microsoft.com/en-us/azure/sentinel/sentinel-solutions-deploy)

---

## Section 2 — Analytics Rules

**Goal**: Guide to building, managing, and tuning Sentinel detection rules.

### 2.1 — Rule Types and Selection

Content to cover:
- Scheduled vs. NRT vs. Microsoft Security vs. Anomaly vs. Fusion vs. Threat Intelligence
- When to use each rule type
- Rule severity levels and their meaning for triage
- Alert grouping strategies (group alerts into incidents vs. one incident per alert)

Citation sources:
- [Detect threats with built-in analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-built-in)
- [Create custom analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-custom)

### 2.2 — Writing KQL Detection Queries

Content to cover:
- KQL fundamentals for security analysts (project, where, summarize, join, let)
- Key Sentinel tables: SignInLogs, SecurityAlert, OfficeActivity, DeviceEvents, AzureActivity
- Time window selection and alert threshold tuning
- Entity mapping for incident enrichment (user, host, IP, URL)
- MITRE ATT&CK tactic and technique tagging

Citation sources:
- [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- [Sentinel tables reference](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/tables-category)
- [Map data fields to entities](https://learn.microsoft.com/en-us/azure/sentinel/map-data-fields-to-entities)
- [MITRE ATT&CK coverage in Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/mitre-coverage)

### 2.3 — Rule Management and Tuning

Content to cover:
- Importing rules from GitHub community and Content Hub
- Testing rules before enabling (simulated data, test incidents)
- Tuning false positives with watchlists and exclusions
- Rule versioning and change management
- Export rules as ARM templates for deployment to multiple workspaces

Citation sources:
- [Manage analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/manage-analytics-rule-templates)
- [Use watchlists in Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/watchlists)

---

## Section 3 — Workbooks

**Goal**: Reference for security monitoring dashboards in Microsoft Sentinel.

### 3.1 — Built-In Workbooks

Content to cover:
- Overview of workbooks included with Microsoft and partner solutions
- Key workbooks: Microsoft Entra ID (sign-in analytics), Defender for Cloud Apps, Azure Activity
- Workspace Health workbook — monitoring data ingestion gaps
- Connector health monitoring

Citation sources:
- [Monitor your data with workbooks](https://learn.microsoft.com/en-us/azure/sentinel/monitor-your-data)
- [Visualise collected data](https://learn.microsoft.com/en-us/azure/sentinel/get-visibility)

### 3.2 — Custom Workbook Development

Content to cover:
- Azure Monitor Workbook authoring basics
- KQL queries in workbooks
- Parameter controls for interactive filtering
- Publishing workbooks to Sentinel gallery

Citation sources:
- [Azure Monitor Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)
- [Create and use Sentinel workbooks](https://learn.microsoft.com/en-us/azure/sentinel/monitor-your-data)

---

## Section 4 — Automation and SOAR

**Goal**: Guide to automating security operations with Sentinel playbooks and automation rules.

### 4.1 — Automation Rules

Content to cover:
- Automation rule triggers (incident created, incident updated, alert created)
- Available actions: assign, change status, change severity, add tag, suppress, run playbook
- Ordering and priority of automation rules
- Using automation rules for triage and routing without playbooks

Citation sources:
- [Automate incident handling with automation rules](https://learn.microsoft.com/en-us/azure/sentinel/automate-incident-handling-with-automation-rules)

### 4.2 — Playbooks (Logic Apps)

Content to cover:
- Playbook triggers: incident trigger vs. alert trigger vs. entity trigger
- Common playbook patterns: enrich incident (IP geolocation, user details), notify Teams/email, contain (isolate device, disable user, block IP)
- Microsoft Sentinel connector actions in Logic Apps
- Managed Identity authentication for playbooks
- Playbook permissions and Sentinel Playbook Operator role

Citation sources:
- [Automate threat response with playbooks](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks)
- [Microsoft Sentinel playbook templates](https://learn.microsoft.com/en-us/azure/sentinel/use-playbook-templates)
- [Authenticate playbooks to Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/authenticate-playbooks-to-sentinel)

### 4.3 — SOAR Use Cases

Content to cover:
- MFA fatigue (push bombing) detection and auto-disable playbook
- Risky user auto-remediation (password reset, session revoke)
- Phishing email — auto-purge from mailboxes, block sender
- Compromised device — auto-isolate via Defender for Endpoint
- Incident enrichment — auto-add threat intel, geolocation, user context

Citation sources:
- [Sentinel SOAR playbook samples (GitHub)](https://github.com/Azure/Azure-Sentinel/tree/master/Playbooks)
- [Defender for Endpoint response actions via API](https://learn.microsoft.com/en-us/defender-endpoint/respond-machine-alerts)

---

## Section 5 — Hunting Queries

**Goal**: KQL-based proactive threat hunting reference for SOC analysts.

### 5.1 — Hunting Fundamentals

Content to cover:
- What proactive hunting is vs. reactive detection
- Hypothesis-driven hunting methodology
- Using MITRE ATT&CK as a hunting framework
- Bookmarking and promoting hunting results to incidents

Citation sources:
- [Hunt for threats with Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/hunting)
- [MITRE ATT&CK in Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/mitre-coverage)

### 5.2 — Common Hunting Scenarios

Content to cover:
- Identity hunting: impossible travel, MFA anomalies, service account abuse, consent grants
- Endpoint hunting: LOLBins (living-off-the-land binaries), PowerShell encoded commands, lateral tool transfer
- Network hunting: DNS beaconing, unusual outbound connections, data exfiltration volume
- Cloud hunting: anomalous Azure resource creation, privilege escalation, unusual API calls

Citation sources:
- [Azure Sentinel hunting queries (GitHub)](https://github.com/Azure/Azure-Sentinel/tree/master/Hunting%20Queries)
- [Threat hunting with KQL in Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

### 5.3 — Livestream and Notebooks

Content to cover:
- Sentinel Livestream — continuous query execution and alerting
- Jupyter notebooks for advanced hunting (machine learning, statistical analysis)
- Azure ML integration with Sentinel

Citation sources:
- [Use Sentinel Livestream](https://learn.microsoft.com/en-us/azure/sentinel/livestream)
- [Jupyter notebooks in Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/notebooks)

---

## Section 6 — Incident Management

**Goal**: SOC workflows for investigating and managing Sentinel incidents.

### 6.1 — Incident Triage and Investigation

Content to cover:
- Incident queue — filtering, sorting, priority assignment
- Incident investigation page — timeline, entities, bookmarks, comments
- Investigation graph — visualising entity relationships
- Escalation paths and SLA management

Citation sources:
- [Investigate incidents with Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/investigate-incidents)
- [Navigate and investigate incidents](https://learn.microsoft.com/en-us/azure/sentinel/incident-investigation)

### 6.2 — Unified Incident Management with Defender XDR

Content to cover:
- Sentinel + Defender XDR unified incident experience in the Defender portal
- Bidirectional sync of incidents between Sentinel and Defender XDR
- Microsoft Defender portal transition timeline (March 31, 2027)

Citation sources:
- [Microsoft Sentinel in the Microsoft Defender portal](https://learn.microsoft.com/en-us/azure/sentinel/microsoft-sentinel-defender-portal)
- [Unified security operations platform](https://learn.microsoft.com/en-us/defender-xdr/unified-security-operations-platform)

### 6.3 — Metrics and Reporting

Content to cover:
- Efficiency workbook — MTTA, MTTR, analyst performance
- Incident closure reasons and classification taxonomy
- Custom KQL queries for SOC reporting
- Microsoft Sentinel workspace health and data ingestion reporting

Citation sources:
- [Sentinel SOC optimisation](https://learn.microsoft.com/en-us/azure/sentinel/soc-optimization/soc-optimization-access)
- [Workspace health workbook](https://learn.microsoft.com/en-us/azure/sentinel/monitor-data-connector-health)
