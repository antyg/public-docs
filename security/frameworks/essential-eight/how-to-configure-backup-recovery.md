---
title: "How to Configure Backup and Recovery"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Configure Backup and Recovery

---

## Overview

This guide walks through the configuration steps required to meet the [ACSC Essential Eight Strategy 8 — Regular Backups](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) requirements. It covers backup architecture, scope, encryption, access control, immutability, and verification — the elements that determine maturity level compliance under the [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

This guide assumes:

- You have identified the systems in scope and their criticality tier (see [System Classification](#classify-systems-by-criticality-tier) below).
- You have a backup solution available. Common options include Azure Backup, Microsoft 365 Backup, Azure Site Recovery, and third-party products such as Veeam or Commvault.
- You have the necessary permissions to configure backup policies and access controls in your chosen platform.

---

## Step 1 — Classify Systems by Criticality Tier

Assign every in-scope system to one of three tiers before configuring backup schedules. Tier determines frequency, retention, and RTO/RPO targets.

| Tier | Definition | Examples |
|------|-----------|---------|
| Critical | Systems essential for business operations | Domain controllers, email servers, core databases, file servers |
| Important | Systems supporting business operations | Application servers, web servers, departmental file shares |
| Standard | General workstations and non-critical systems | User workstations, test and development systems |

---

## Step 2 — Configure Backup Schedules and Retention

Apply the following schedule and retention settings per tier.

### Critical Systems

| Backup type | Frequency | Retention |
|------------|-----------|-----------|
| Files and data | Hourly or continuous | 30 days (daily), 90 days (weekly), 12 months (monthly), 7 years (yearly) |
| System state | Daily | As above |
| Configuration | On change, plus daily | As above |

- Recovery Time Objective (RTO): 4 hours
- Recovery Point Objective (RPO): 1 hour

### Important Systems

| Backup type | Frequency | Retention |
|------------|-----------|-----------|
| Files and data | Daily | 14 days (daily), 60 days (weekly), 6 months (monthly), 3 years (yearly) |
| System state | Weekly | As above |
| Configuration | Weekly | As above |

- RTO: 8 hours
- RPO: 24 hours

### Standard Systems

| Backup type | Frequency | Retention |
|------------|-----------|-----------|
| User data | Daily (if stored locally) | 7 days (daily), 30 days (weekly), 90 days (monthly) |
| System state | Weekly | As above |
| Configuration | Monthly | As above |

- RTO: 24 hours
- RPO: 24 hours

---

## Step 3 — Define Backup Scope

Configure your backup jobs to include the following categories. Exclude the items listed under "Do not include".

### Include

**Operating system level**

- System state and boot files
- Operating system files
- Registry (Windows) or configuration files (Linux/macOS)
- User profiles
- Security policies
- Certificates and keys

**Application level**

- Application data and databases
- Configuration files
- Critical log files

**Data level**

- User files and shared network drives
- Email data (mailboxes)
- Database files
- Virtualisation files (VMs, containers)

**Infrastructure level**

- Active Directory databases
- DNS and DHCP configurations
- Network device configurations
- Firewall rules and policies

### Do Not Include

- Temporary files and caches
- Application installation media available from the vendor
- Operating system installation files
- Swap and page files
- Recycle bins and browser caches

---

## Step 4 — Select a Backup Method

Choose a backup method appropriate to each system's RPO requirement.

| Method | Description | Best for |
|--------|-------------|---------|
| Full | Complete copy of all selected data at a point in time | Weekly or monthly baseline |
| Incremental | Changes since the last backup (full or incremental) | Daily or hourly between fulls |
| Differential | Changes since the last full backup | When faster restore than incremental is needed |
| Continuous Data Protection (CDP) | Real-time or near-real-time capture | Critical systems with RPO under 1 hour |

For most environments, a full backup weekly combined with daily incrementals satisfies Essential Eight requirements for Important and Standard systems. Critical systems with sub-hourly RPO requirements should use CDP or application-native log shipping.

---

## Step 5 — Implement the 3-2-1-1-0 Architecture

The 3-2-1-1-0 rule is the recommended architecture for ransomware resilience:

- **3** copies of data
- **2** different storage media types
- **1** copy off-site
- **1** copy offline or immutable
- **0** errors in backup verification

Configure your environment to maintain:

1. A primary backup on fast local or regional storage for rapid recovery.
2. A replicated copy in a geographically separate location or cloud region.
3. An immutable or air-gapped copy that cannot be modified or deleted by ransomware (see Step 7).

---

## Step 6 — Configure Backup Encryption

### Encryption in Transit

- Require TLS 1.2 or higher for all network-based backup transfers.
- Use encrypted tunnels (IPsec or equivalent) for site-to-site replication.

### Encryption at Rest

- Apply AES-256 encryption at the backup destination.
- Store encryption keys separately from backup data, using a dedicated key management service where available.
- For tape media, use hardware-encrypted LTO drives.

**Azure Backup** applies AES-256 encryption by default for both in-transit and at-rest data in Recovery Services vaults. Verify that customer-managed keys (CMK) are configured if your security policy requires it.

**Veeam and third-party tools** typically offer encryption as a configurable option on the backup job. Enable it explicitly — do not rely on defaults.

---

## Step 7 — Configure Immutable and Air-Gapped Backups

Immutable backups are a hard requirement at Maturity Level 2 and above under the Essential Eight.

### Cloud Object Lock (Azure Blob / S3-compatible)

Configure time-based immutability on the backup storage container. The backup tool cannot delete or overwrite data until the retention period expires.

- In Azure, enable **immutable blob storage** with a time-based retention policy on the Recovery Services vault storage account.
- Set the retention period to match your compliance requirements (minimum 30 days for daily backups of critical systems).

### Air-Gapped Copies

Maintain at least one copy that is physically or logically isolated from your production network:

- **Removable media** (external drives, LTO tape) — disconnect immediately after each backup window.
- **Isolated network segment** — no routing from production; connect only during scheduled backup windows.
- **Offline cloud tier** — some cloud providers offer vault-lock features that prevent deletion even by administrators.

Implement a rotation schedule that moves copies progressively offline:

- Daily sets: rotated on-site, disconnected after backup
- Monthly copies: moved off-site
- Quarterly and annual copies: moved to long-term storage

---

## Step 8 — Configure Backup Access Controls

Apply separation of duties across backup roles. No single individual should be able to both manage backup configuration and delete audit logs.

| Role | Permissions | MFA required |
|------|------------|-------------|
| Backup Administrator | Configure policies, schedule jobs | Yes |
| Backup Operator | Run manual backups, view logs | Yes |
| Recovery Administrator | Restore data, manage recovery points | Yes |
| Security Administrator | View audit logs, manage encryption keys | Yes |
| Read-Only Auditor | View backup status and reports | Yes |

Key principles:

- Restore operations for critical systems require dual approval.
- Backup administrators must not have permission to delete audit logs.
- All access to backup systems must be logged and reviewed.

In Azure Backup, use Azure role-based access control (RBAC) to assign the built-in **Backup Contributor**, **Backup Operator**, and **Backup Reader** roles to separate accounts or groups.

---

## Step 9 — Configure Backup Verification

Backups that are never tested cannot be relied upon during an incident.

### Automated Daily Checks

Configure alerting for:

- Backup job completion status
- Data integrity verification failures
- Storage capacity exceeding 80% (warning) or 90% (critical)
- Backup age exceeding the RPO threshold

### Scheduled Test Restores

| System tier | Frequency | Method |
|------------|-----------|--------|
| Critical | Monthly | Full restoration to isolated environment |
| Important | Quarterly | Full restoration to isolated environment |
| Standard | Annually | Full restoration to isolated environment |

**Test restore process:**

1. Select the system to test.
2. Document the pre-restore state.
3. Perform restoration to an isolated (non-production) environment.
4. Verify all data, services, and application functionality.
5. Confirm security controls are active post-restore.
6. Document results, including any gaps or failures.
7. Update recovery procedures if issues are identified.

---

## Step 10 — Configure Monitoring and Alerting

Set up alerts that correspond to the following thresholds.

### Critical alerts (immediate response required)

- Backup job failure
- Storage capacity above 90%
- Backup integrity check failure
- Ransomware detection in backup data
- Unauthorised backup deletion attempt
- Encryption key access outside scheduled windows

### Warning alerts (respond within 1 hour)

- Backup job runtime exceeding expected duration
- Storage capacity above 80%
- Backup age exceeding RPO
- Replication lag above threshold

In Azure Monitor, configure diagnostic settings on your Recovery Services vault to route backup alerts to a Log Analytics workspace and action group. Enable the built-in **Backup Reports** workbook for ongoing visibility.

---

## Step 11 — Establish a Recovery Procedure

### Recovery Priority Order

| Priority | Systems | Target RTO |
|----------|---------|-----------|
| 1 — Immediate | Domain controllers, core network, critical applications, email | 4 hours |
| 2 — Urgent | File servers, databases, application servers, web services | 8 hours |
| 3 — Standard | User workstations, non-critical applications, dev systems | 24 hours |

### Recovery Phases

**Phase 1: Assessment (0–30 minutes)**

1. Identify affected systems and the scope of data loss.
2. Determine the cause (ransomware, accidental deletion, hardware failure).
3. Identify the last known-good recovery point.
4. Verify the backup is available and accessible.
5. Obtain required approvals.
6. Notify stakeholders.

**Phase 2: Preparation (30 minutes – 1 hour)**

1. Isolate affected systems if malware is suspected.
2. Prepare the recovery environment.
3. Verify the restoration destination.
4. Gather required credentials.

**Phase 3: Recovery (1–4 hours)**

1. Initiate the restoration.
2. Monitor progress and address errors immediately.
3. Verify data integrity during recovery.
4. Document each step taken.

**Phase 4: Verification (1–2 hours)**

1. Confirm the system boots and all services start.
2. Validate data completeness.
3. Test application functionality.
4. Verify security controls are active.
5. Confirm network connectivity.

**Phase 5: Post-Recovery (2–4 hours)**

1. Document all recovery activities.
2. Conduct a lessons-learned session.
3. Update recovery procedures based on findings.
4. Notify users that systems are restored.
5. Monitor for recurring issues.
6. Complete the incident report.

---

## Step 12 — Maintain Audit Evidence

Retain the following documentation to support Essential Eight compliance assessments:

- Backup schedules and current policy configuration
- Backup success and failure logs
- Test restore results with dates and outcomes
- Recovery time metrics (actual vs. target)
- Backup configuration change history
- Access logs for backup systems and storage
- Encryption key management records

### Review Schedule

| Frequency | Activities |
|-----------|-----------|
| Monthly | Verify all critical systems are backed up; check completion rates; validate off-site copies; test a random file restoration; review access logs |
| Quarterly | Conduct a full system restoration test; validate RTO/RPO compliance; audit backup security controls; verify encryption |
| Annually | Comprehensive disaster recovery test; review and update backup policies; assess capacity; update documentation |

---

## Implementation Options

The configuration steps above are platform-agnostic. The following tools are commonly used to implement them.

| Option | Platform support | Notes |
|--------|-----------------|-------|
| **Azure Backup** | Azure VMs, on-premises Windows/Linux (via MARS agent), SQL Server, SAP HANA | Native Azure integration; geo-redundant storage; immutable vault support |
| **Microsoft 365 Backup** | Exchange Online, SharePoint Online, OneDrive | Microsoft-native; point-in-time restore for M365 workloads |
| **Azure Site Recovery** | Azure VMs, on-premises VMs (Hyper-V and VMware), physical servers | Replication and orchestrated failover; suitable for DR site requirements |
| **Veeam Backup & Replication** | VMware, Hyper-V, physical, cloud | Immutable backup to object storage; granular recovery options |
| **Commvault / Veritas NetBackup** | Enterprise-scale, multi-platform | Suitable for large or heterogeneous environments |

Regardless of tool, the same controls apply: encryption, immutability, access separation, verified test restores, and offline copies.

---

## Related Resources

- [how-to-implement-regular-backups.md](how-to-implement-regular-backups.md) — Strategy 8 implementation walkthrough
- [reference-maturity-model.md](reference-maturity-model.md) — Essential Eight Maturity Model reference
- [reference-glossary.md](reference-glossary.md) — Terminology and definitions

### ACSC References

- [ACSC Essential Eight — Regular Backups](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/regular-backups)
- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Ransomware Profile](https://www.cyber.gov.au/resources-business-and-government/threats/ransomware)
