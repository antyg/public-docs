---
title: "How to Map NIST CSF 2.0 to Azure Services"
status: "published"
last_updated: "2026-03-09"
audience: "Security architects and engineers implementing NIST CSF 2.0 using Microsoft Azure and Microsoft 365"
document_type: "how-to"
domain: "security"
---

# How to Map NIST CSF 2.0 to Azure Services

---

## Overview

This guide provides a function-by-function mapping of NIST CSF 2.0 outcomes to specific Azure and Microsoft 365 services. Use this as a reference when selecting controls to satisfy each CSF outcome in your environment.

For the authoritative CSF subcategory definitions, refer to the [NIST CSF 2.0 Functions Reference](reference-nist-csf-functions.md) or the [NIST CSF 2.0 publication (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf).

For Microsoft's official NIST CSF compliance documentation, see [Microsoft — NIST CSF compliance](https://learn.microsoft.com/en-us/compliance/regulatory/offering-nist-csf).

---

## GV — Govern

The Govern function establishes cybersecurity risk management strategy, policy, roles, and oversight. Azure and Microsoft 365 support Govern outcomes through governance tooling and compliance management platforms.

| CSF Category | Azure/Microsoft Service | Notes |
|-------------|------------------------|-------|
| GV.OC — Organisational Context | [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager-overview) | Use Compliance Manager to document regulatory obligations and map to controls |
| GV.RM — Risk Management Strategy | [Microsoft Defender for Cloud — Regulatory Compliance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) | View compliance posture against multiple frameworks simultaneously |
| GV.RR — Roles, Responsibilities, Authorities | [Microsoft Entra ID — Role-Based Access Control (RBAC)](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/overview) | Formalise security responsibilities through role assignments |
| GV.PO — Policy | [Microsoft Purview — Information Protection policies](https://learn.microsoft.com/en-us/purview/information-protection) | Enforce data handling policies through technical controls |
| GV.OV — Oversight | [Microsoft Secure Score](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score) | Monitor security posture trend over time; report to leadership |
| GV.SC — Supply Chain Risk Management | [Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/overview) | Manage third-party identity and access; assess supplier risk |

### Key Actions

1. **Establish a baseline policy** — Document your cybersecurity policy in Compliance Manager and assign it to responsible owners.
2. **Enable Secure Score** — Navigate to [Microsoft Defender portal](https://security.microsoft.com) > **Secure Score**. Review current score and recommended actions.
3. **Map regulatory obligations** — In Compliance Manager, add relevant regulations (Australian Privacy Act, ISM, Essential Eight) and review the pre-built control mappings.

---

## ID — Identify

The Identify function requires understanding your organisation's assets, risks, suppliers, and vulnerabilities.

| CSF Category | Azure/Microsoft Service | Notes |
|-------------|------------------------|-------|
| ID.AM — Asset Management | [Microsoft Defender for Endpoint — Device inventory](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview) | Complete device inventory with OS, patch status, risk score |
| ID.AM — Software inventory | [Microsoft Intune — Discovered apps](https://learn.microsoft.com/en-us/mem/intune/apps/app-discovered-apps) | Software inventory across managed devices |
| ID.AM — Cloud asset inventory | [Microsoft Defender for Cloud — Asset inventory](https://learn.microsoft.com/en-us/azure/defender-for-cloud/asset-inventory) | All Azure resources with security posture |
| ID.RA — Risk Assessment | [Microsoft Defender Vulnerability Management](https://learn.microsoft.com/en-us/defender-vulnerability-management/defender-vulnerability-management) | CVE-based risk scoring per asset |
| ID.RA — Threat intelligence | [Microsoft Defender Threat Intelligence](https://learn.microsoft.com/en-us/defender/threat-intelligence/what-is-microsoft-defender-threat-intelligence-defender-ti) | Threat actor profiles and indicators of compromise |
| ID.SC — Supply Chain Risk | [Microsoft Entra Permissions Management](https://learn.microsoft.com/en-us/entra/permissions-management/overview) | Identify over-privileged third-party identities |

### Key Actions

1. **Enable Defender for Endpoint** — Onboard all devices to gain a unified device and software inventory.
2. **Activate Defender Vulnerability Management** — Navigate to [Microsoft Defender portal](https://security.microsoft.com) > **Vulnerability management > Dashboard**. Review the vulnerability exposure score and top recommendations.
3. **Inventory Azure resources** — In Defender for Cloud, open **Asset inventory**. Filter by resource type and review security health state for each.

---

## PR — Protect

The Protect function implements safeguards to limit the impact of cybersecurity events. This is the largest function and maps most directly to the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) controls.

| CSF Category | Azure/Microsoft Service | Essential Eight Alignment |
|-------------|------------------------|--------------------------|
| PR.AA — Identity Management and Authentication | [Microsoft Entra MFA + Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | Strategy 7 — Multi-Factor Authentication |
| PR.AA — Privileged access | [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) | Strategy 5 — Restrict Administrative Privileges |
| PR.AT — Awareness and Training | [Microsoft Viva Learning](https://learn.microsoft.com/en-us/viva/learning/overview-viva-learning) | — |
| PR.DS — Data Security | [Microsoft Purview — Data Loss Prevention (DLP)](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp) | — |
| PR.DS — Encryption | [Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview); [BitLocker via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices) | — |
| PR.IR — Technology Infrastructure Resilience | [Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview); [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview) | Strategy 8 — Regular Backups |
| PR.PS — Platform Security | [Microsoft Defender Application Control](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview) | Strategy 1 — Application Control |
| PR.PS — Patch management | [Windows Update for Business via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) | Strategies 2, 6 — Patch Applications/OS |

### Key Actions

1. **Implement Conditional Access MFA** — Create a policy requiring MFA for all users accessing all cloud apps. This satisfies PR.AA-03 (users authenticated before access is permitted).

2. **Enable DLP policies** — In Microsoft Purview, navigate to **Data Loss Prevention > Policies**. Create policies for sensitive data types (Tax File Numbers, bank account numbers) to satisfy PR.DS data security outcomes.

3. **Configure disk encryption** — In Intune, navigate to **Endpoint security > Disk encryption > Create policy**. Enable BitLocker for Windows devices and FileVault for macOS devices. This satisfies PR.DS-01 (data-at-rest is protected).

---

## DE — Detect

The Detect function identifies cybersecurity events in a timely manner through continuous monitoring.

| CSF Category | Azure/Microsoft Service | Notes |
|-------------|------------------------|-------|
| DE.AE — Adverse Event Analysis | [Microsoft Sentinel — Analytics rules](https://learn.microsoft.com/en-us/azure/sentinel/detect-threats-built-in) | Correlate signals across all data sources |
| DE.AE — Anomaly detection | [Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection) | Risk-based detection for identity anomalies |
| DE.CM — Continuous Monitoring | [Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | Security posture monitoring across Azure resources |
| DE.CM — Network monitoring | [Azure Network Watcher](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview); [Microsoft Defender for IoT](https://learn.microsoft.com/en-us/azure/defender-for-iot/overview) | Traffic analysis and anomaly detection |
| DE.CM — Log management | [Microsoft Sentinel — Log Analytics workspace](https://learn.microsoft.com/en-us/azure/sentinel/overview) | Centralised log collection and analysis |

### Key Actions

1. **Deploy Microsoft Sentinel** — Create a Log Analytics workspace and enable Microsoft Sentinel. Connect Microsoft data sources: Entra ID, Microsoft 365, Defender for Endpoint, Defender for Cloud.

2. **Enable built-in analytics rules** — In Sentinel, navigate to **Analytics > Rule templates**. Enable rules for high-confidence detections: **Suspicious sign-in activity**, **Multiple password reset attempts**, **Rare application consent**.

3. **Configure Entra ID Protection** — Navigate to **Microsoft Entra admin centre > Protection > Identity Protection**. Enable user risk policy and sign-in risk policy.

---

## RS — Respond

The Respond function defines actions taken when a cybersecurity incident is detected.

| CSF Category | Azure/Microsoft Service | Notes |
|-------------|------------------------|-------|
| RS.MA — Incident Management | [Microsoft Sentinel — Incidents](https://learn.microsoft.com/en-us/azure/sentinel/incident-investigation) | Centralised incident management and investigation |
| RS.AN — Incident Analysis | [Microsoft Defender XDR — Incidents](https://learn.microsoft.com/en-us/defender-xdr/incidents-overview) | Unified incident view across all Defender products |
| RS.CO — Incident Reporting | [Microsoft Sentinel — Playbooks (Logic Apps)](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks) | Automated incident notification to stakeholders |
| RS.MI — Incident Mitigation | [Microsoft Defender for Endpoint — Response actions](https://learn.microsoft.com/en-us/defender-endpoint/respond-machine-alerts) | Isolate, collect investigation packages, run antivirus scan |

### Key Actions

1. **Create incident response playbooks** — In Microsoft Sentinel, navigate to **Automation > Create playbook**. Build a playbook that notifies your security team via Microsoft Teams when a high-severity incident is created. This satisfies RS.CO-02 (incidents are reported to appropriate authorities and stakeholders).

2. **Configure automated response** — Create automation rules in Sentinel to automatically assign incidents, tag them by category, and trigger enrichment playbooks.

---

## RC — Recover

The Recover function restores capabilities and services affected by a cybersecurity incident.

| CSF Category | Azure/Microsoft Service | Notes |
|-------------|------------------------|-------|
| RC.RP — Incident Recovery Plan | [Azure Site Recovery — Recovery plans](https://learn.microsoft.com/en-us/azure/site-recovery/recovery-plan-overview) | Documented and automated recovery orchestration |
| RC.RP — Backup restoration | [Azure Backup — Restore](https://learn.microsoft.com/en-us/azure/backup/backup-azure-restore-windows-server) | Point-in-time restoration of VMs, files, databases |
| RC.CO — Incident Recovery Communication | [Microsoft Teams — Crisis communication template](https://learn.microsoft.com/en-us/microsoftteams/platform/samples/app-templates) | Coordinated communication during recovery |

### Key Actions

1. **Create a recovery plan in Azure Site Recovery** — Navigate to **Azure portal > Recovery Services vault > Recovery Plans**. Create a plan that documents VM recovery order for your critical workloads. Test the plan with a planned failover (no production impact).

2. **Test backup restoration** — Monthly, perform a test restoration from Azure Backup to a test environment. Document results against your Recovery Time Objective (RTO) and Recovery Point Objective (RPO).

---

## Related Resources

- [NIST CSF 2.0 (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)
- [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters)
- [Microsoft — NIST CSF compliance documentation](https://learn.microsoft.com/en-us/compliance/regulatory/offering-nist-csf)
- [Microsoft Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager-overview)
- [NIST CSF 2.0 Functions Reference](reference-nist-csf-functions.md)
- [NIST CSF Evolution — 1.1 to 2.0](explanation-nist-csf-evolution.md)
