---
title: "How to Implement Regular Backups"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement Regular Backups

---

## Overview

This guide provides goal-oriented steps for implementing the Regular Backups strategy — Control 8 of the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). It covers the full progression from Maturity Level 1 through Maturity Level 3, guiding you from establishing daily backups with basic restoration testing through to continuous, immutable, and offsite-protected backup operations.

Regular Backups is rated **Critical** priority in the Essential Eight. Its primary purpose is ensuring that critical data, systems, and configurations can be recovered following a cyber security incident — particularly ransomware or destructive attacks. Without tested, accessible backups, recovery from such events is impractical or impossible.

For maturity level requirements and definitions, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

### Prerequisites

Before implementing Regular Backups, confirm the following:

- You have identified the systems and data stores in scope
- You have backup infrastructure or a cloud backup service available (see service options in each section below)
- You have documented or can define a Recovery Point Objective (RPO) and Recovery Time Objective (RTO) for each critical system
- You have storage capacity planned for at least the minimum retention period

### Recovery Objectives

Define these two values for each system before configuring any backup policy:

| Objective | Definition | Example |
|-----------|------------|---------|
| **RPO** (Recovery Point Objective) | Maximum acceptable data loss, expressed as time | 24 hours — lose no more than one day of data |
| **RTO** (Recovery Time Objective) | Maximum acceptable restoration time | 4 hours — system must be recoverable within 4 hours |

RPO drives backup frequency. RTO drives your choice of backup technology and restoration approach. Document these values — they are required evidence for compliance assessments.

---

## Maturity Level 1 — Daily Backups with Restoration Testing

ML1 requires that important data, software, and configuration settings are backed up, and that restoration is tested periodically.

### Step 1 — Classify Critical Data and Systems

1. Identify all data stores and systems that are business-critical or contain important information.
2. Classify each by sensitivity and business impact:
   - **Tier 1 (Critical):** Operational databases, identity systems, domain controllers, configuration repositories
   - **Tier 2 (Important):** File shares, email archives, application data
   - **Tier 3 (Standard):** Development environments, non-sensitive systems
3. Document the RPO and RTO for each Tier 1 and Tier 2 system.
4. Record this classification — it forms the scope boundary for your backup policy.

### Step 2 — Select a Backup Solution

Choose a backup solution appropriate to your environment:

| Environment | Recommended Options |
|-------------|---------------------|
| Azure-hosted workloads | [Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview) |
| Microsoft 365 data (Exchange, SharePoint, OneDrive, Teams) | [Microsoft 365 Backup](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/microsoft-365-backup) |
| Azure VMs requiring disaster recovery | [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview) |
| On-premises or hybrid workloads | [Veeam Backup & Replication](https://www.veeam.com/vm-backup-recovery-replication-software.html) or equivalent third-party solution |

Whichever solution you select, verify that it supports:

- Scheduled daily backups
- Offline or immutable storage of backup data (see Step 3)
- Restoration of individual files, folders, and entire systems
- Backup success and failure reporting

### Step 3 — Configure Backup Policies

For each Tier 1 and Tier 2 system identified in Step 1, configure backup schedules aligned to your RPO:

| Backup Type | Minimum Frequency | Retention |
|-------------|-------------------|-----------|
| Incremental or differential backup | Daily | 30 days |
| Full system backup | Weekly | 90 days |
| Archival backup | Monthly | 12 months or as required by business policy |

Configure retention policies explicitly. Unbounded retention leads to storage exhaustion; retention that is too short may leave you unable to recover from an incident discovered weeks after it occurred.

**Immutable and offline storage — ML1 minimum requirement:**

Backups must be stored in a location that cannot be modified or deleted by a ransomware attack or a compromised account:

- **Offline (air-gapped):** Backup media physically disconnected from the network
- **Immutable cloud storage:** Object-lock or write-once storage in Azure Blob Storage, AWS S3, or equivalent

At ML1, at least one copy of each backup must meet this requirement. The [3-2-1 rule](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/publications/essential-eight-explained) (three copies, two different media types, one offsite) is the recommended baseline.

### Step 4 — Establish Monitoring and Alerting

1. Configure your backup solution to send alerts on backup job failure.
2. Review backup logs daily — manually or via a monitoring platform.
3. Establish a process to remediate backup failures within 24 hours.
4. Record the backup success rate. The target is greater than 99% across all protected systems.

### Step 5 — Test Restoration Quarterly

Testing backups is a mandatory ML1 requirement. Untested backups cannot be relied upon during an incident.

Conduct restoration tests at least quarterly:

1. Select a representative sample of protected systems and data stores.
2. Restore files, folders, and at least one full system image to a test environment.
3. Measure actual restoration time and compare against your documented RTO.
4. Record the test date, scope, outcome, and any issues found.
5. Update your restoration runbooks based on findings.

Document each test result. This evidence is required for compliance assessments.

### ML1 Success Criteria

- 100% of Tier 1 and Tier 2 systems backed up daily
- Backup success rate greater than 99%
- All backups stored in offline or immutable storage
- Quarterly restoration tests conducted, with a success rate greater than 95%
- Restoration time within documented RTO for all tested scenarios
- Backup policy document exists and is current

**Estimated time to achieve ML1:** 6–10 weeks

---

## Maturity Level 2 — Automated Testing and Immutable Backups

ML2 extends ML1 by requiring automated restoration testing, enforced immutability, and a higher standard of operational discipline. The frequency and breadth of testing increases, and manual processes are replaced with automated verification.

### Step 1 — Automate Backup Verification

Manual log review is insufficient at ML2. Configure automated verification:

1. Enable built-in integrity verification in your backup solution (checksum validation, consistency checks).
2. Configure automated restoration tests — most enterprise backup platforms support scheduled test restores to isolated environments.
3. Capture test outcomes in a reporting dashboard or log aggregation platform.
4. Alert on any failed integrity check or failed automated restoration test within one hour.

Azure Backup supports [backup health reports](https://learn.microsoft.com/en-us/azure/backup/configure-reports) via Azure Monitor and Log Analytics. Microsoft 365 Backup provides administrative reporting via the Microsoft 365 admin centre.

### Step 2 — Enforce Immutability Across All Backups

At ML2, immutability must be enforced for all backup copies — not just one:

| Platform | Immutability Mechanism |
|----------|------------------------|
| Azure Backup | [Immutable vault](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept) with locked policy |
| Azure Blob Storage | [Immutability policies](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview) (WORM) |
| Veeam | Hardened repository with immutability flag |
| On-premises tape | Write-once media + physical access controls |

Verify that your backup administrator account cannot delete or modify backup data within the retention window. Separation of duties between backup administration and infrastructure administration is a recommended control at this level.

### Step 3 — Expand Scope to All Systems

Review the scope boundary established at ML1. At ML2, backup coverage should extend to all systems — not just Tier 1 and Tier 2:

1. Identify any systems not yet covered by backup policy.
2. Onboard remaining systems to daily backup schedules.
3. Update your classification document to reflect full coverage.

### Step 4 — Increase Restoration Test Frequency

ML2 requires more frequent and broader restoration testing than ML1:

- Test restoration of critical systems at least monthly (automated)
- Conduct full disaster recovery drills at least annually
- Include application-layer restoration (not just file-level) in test scope
- Test restoration from immutable/offline copies specifically — verify the air-gap is genuinely effective

### ML2 Success Criteria

- All systems (not just critical tier) backed up daily
- Backup integrity verified automatically on each backup job
- Automated restoration tests conducted monthly
- All backup storage is immutable — verified by attempting deletion
- Annual disaster recovery drill completed and documented
- Backup administration separated from infrastructure administration

**Estimated time to achieve ML2 from ML1:** 6–12 months

---

## Maturity Level 3 — Continuous Backup, Offsite Storage, and Annual Restoration Drills

ML3 represents the highest level of backup maturity. It requires continuous data protection (near-zero RPO for critical systems), geographically separated offsite storage, and rigorous annual restoration exercises.

### Step 1 — Implement Continuous Data Protection for Critical Systems

Daily backup schedules are insufficient at ML3 for the most critical systems. Implement continuous or near-continuous backup:

| Technology | Description | Applicable Platform |
|------------|-------------|---------------------|
| **Azure Continuous Backup** | Point-in-time restore with sub-hourly granularity | Azure SQL, Azure Cosmos DB, Azure Blobs |
| **Azure Site Recovery** | Continuous replication with RPO as low as 30 seconds | Azure VMs, on-premises VMs |
| **Microsoft 365 Backup** | Near-real-time protection for Exchange, SharePoint, OneDrive | Microsoft 365 |
| **Veeam Continuous Data Protection** | Continuous journal-based protection | On-premises and hybrid VMware/Hyper-V |

Define the RPO target for each Tier 1 system and select the appropriate technology to meet it.

### Step 2 — Implement Geographically Separated Offsite Storage

At ML3, at least one backup copy must be stored in a geographically separated location — separate from both the primary environment and the secondary backup copy:

1. Identify a target region or facility geographically separate from your primary data centre or Azure region.
2. Configure replication of backup data to the offsite location:
   - Azure Backup supports [cross-region restore](https://learn.microsoft.com/en-us/azure/backup/backup-create-recovery-services-vault#set-cross-region-restore) across paired regions
   - Azure Blob Storage supports [geo-redundant storage (GRS)](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy#geo-redundant-storage) and [geo-zone-redundant storage (GZRS)](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy#geo-zone-redundant-storage)
3. Enforce immutability on the offsite copy independently of the primary backup copy.
4. Document the offsite location and confirm that access credentials for the offsite copy are stored separately from the primary environment.

### Step 3 — Conduct Annual Full Restoration Drills

ML3 requires an annual restoration drill that covers the full recovery scenario — not just file or folder restoration:

1. Define the drill scope: which systems, which backup copies (including the offsite copy), and which failure scenarios are being tested.
2. Execute restoration in an isolated environment — do not restore onto production systems.
3. Validate application functionality post-restoration, not just data presence.
4. Measure and record actual RTO against the documented target.
5. Produce a drill report that captures: date, scope, participants, outcomes, gaps identified, and remediation actions.
6. Review and update runbooks based on drill findings before the next annual drill.

Drill reports are key compliance evidence. Store them alongside your backup policy documentation.

### Step 4 — Verify Supply Chain Integrity of Backup Infrastructure

At ML3, the integrity of the backup platform itself must be verified. Confirm:

- Backup software and agents are patched and up to date (aligns with [Essential Eight Patch Applications](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/essential-eight/patch-applications))
- Administrative access to the backup platform requires multi-factor authentication (aligns with [Essential Eight Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/essential-eight/multi-factor-authentication))
- Backup infrastructure logs are captured and retained separately from the systems being backed up

### ML3 Success Criteria

- Continuous data protection implemented for all Tier 1 systems, meeting defined RPO targets
- At least one backup copy stored in a geographically separated, immutable, offsite location
- Annual full restoration drill completed, documented, and reviewed
- Backup platform itself protected with MFA and kept patched
- Backup logs retained independently of the systems they protect

**Estimated time to achieve ML3 from ML2:** 12–18 months

---

## Verification

Use the following checklist to verify compliance at each maturity level before proceeding to an assessment.

### ML1 Verification Checklist

- [ ] Critical data and systems classification document exists and is current
- [ ] RPO and RTO defined for all Tier 1 and Tier 2 systems
- [ ] Daily backups configured and running for all Tier 1 and Tier 2 systems
- [ ] Backup success rate greater than 99% over the past 30 days (evidence: backup reports)
- [ ] At least one backup copy stored offline or in immutable storage
- [ ] Backup failure alerts configured and tested
- [ ] Quarterly restoration test completed within the past 3 months (evidence: test report)
- [ ] Restoration time within documented RTO for tested scenarios

### ML2 Verification Checklist

- [ ] All systems (full scope) covered by daily backup policy
- [ ] Automated backup integrity verification enabled and reporting to central platform
- [ ] All backup storage is immutable — deletion attempt confirmed blocked
- [ ] Automated restoration tests run monthly (evidence: automated test logs)
- [ ] Annual disaster recovery drill completed and documented
- [ ] Backup administration account separated from infrastructure administration

### ML3 Verification Checklist

- [ ] Continuous data protection configured for all Tier 1 systems — RPO confirmed
- [ ] Geographically separated offsite backup copy confirmed as immutable
- [ ] Offsite copy accessible independently of primary environment credentials
- [ ] Annual full restoration drill report on file, including application-layer validation
- [ ] Backup platform patched and protected with MFA
- [ ] Backup logs stored independently of protected systems

---

## Common Challenges

### Backup Storage Capacity

Plan storage growth as data volumes increase. Use incremental or differential backups rather than daily full backups to reduce storage requirements. Implement compression and deduplication where supported by your backup platform. Review retention policies quarterly — retaining data beyond business requirements wastes storage and increases risk.

### Backup Window Constraints

For large data sets, daily full backups may exceed available backup windows. Mitigate by using incremental-forever or continuous data protection approaches. Schedule full backups during low-activity periods. Consider parallel backup streams for independent data sets.

### Restoration Failures

Backup jobs completing successfully does not guarantee that data is restorable. Test regularly. Common causes of restoration failure include:

- Backup data corruption (mitigated by integrity verification)
- Expired or rotated encryption keys (mitigate by storing keys separately and testing key access as part of restoration tests)
- Changed system configuration that prevents restore (mitigate by testing restoration to a clean environment, not just the existing system)
- Backup agent version mismatch after upgrades (mitigate by patching backup agents alongside the systems they protect)

### Disconnected or Air-Gapped Systems

Systems without persistent network access require a different backup approach. Ensure backup agents can operate over intermittent connections or schedule backup jobs to coincide with connectivity windows. For truly air-gapped systems, use offline backup media with a documented chain of custody.

---

## Related Resources

### ACSC Authoritative Guidance

- [ACSC Essential Eight — Regular Backups](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/essential-eight/regular-backups)
- [ACSC Essential Eight Maturity Model (October 2024)](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight Explained](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/publications/essential-eight-explained)
- [ACSC — Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)

### Library Cross-References

- [Essential Eight Maturity Model Reference](reference-maturity-model.md) — Maturity level definitions and per-control requirements
- [Essential Eight Glossary](reference-glossary.md) — Term definitions including RPO, RTO, immutable backup, and air-gap
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md) — Control interdependencies and ISM mapping
- [How to Implement Essential Eight Controls in Azure](how-to-implement-e8-controls.md) — Azure service mappings for all eight controls
- [How to Upgrade from ML1 to ML2](how-to-upgrade-ml1-to-ml2.md) — Progression strategy across all controls

### Backup Platform Documentation

- [Azure Backup Overview](https://learn.microsoft.com/en-us/azure/backup/backup-overview)
- [Azure Backup — Immutable Vault](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept)
- [Azure Backup — Cross-Region Restore](https://learn.microsoft.com/en-us/azure/backup/backup-create-recovery-services-vault#set-cross-region-restore)
- [Azure Site Recovery Overview](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview)
- [Microsoft 365 Backup Overview](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/microsoft-365-backup)
- [Azure Blob Storage Immutability Policies](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview)
- [Azure Storage Redundancy Options](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)
