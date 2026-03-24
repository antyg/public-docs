---
title: "Virtual Machine Configuration Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Azure"
---

# Virtual Machine Configuration Reference

Reference lookup for Azure virtual machine configuration, AVD host pool parameters, Windows 365 Cloud PC SKUs, storage types, and backup options. This document is structured for quick lookup of configuration parameters and capability comparisons.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive reference tables are to be authored in a future iteration.

---

## VM Size Families and Use Cases

**[Microsoft Learn — Azure VM sizes overview](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)** | **[VM size families](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview)**

Azure VM sizes are organised into families targeting specific workload profiles. Each family contains multiple size tiers varying in vCPU count, RAM, and storage throughput.

> **TODO**: Build a reference table covering the key VM size families relevant to endpoint and virtualised desktop workloads. Include columns: family name, optimisation type, typical vCPU range, typical RAM range, premium storage support, use cases, and notes (e.g., AMD vs Intel processor, Arm-based). Cover at minimum:

| Family | Optimisation | Typical Use Cases |
| ------ | ------------ | ----------------- |
| [B-series (Bsv2)](https://learn.microsoft.com/en-us/azure/virtual-machines/bsv2-series) | Burstable / general purpose | Dev/test, small VDI, low-CPU-baseline workloads |
| [D-series (Dsv5, Ddsv5)](https://learn.microsoft.com/en-us/azure/virtual-machines/dv5-dsv5-series) | General purpose | Production workloads, VDI session hosts, web servers |
| [E-series (Esv5, Edsv5)](https://learn.microsoft.com/en-us/azure/virtual-machines/ev5-esv5-series) | Memory-optimised | In-memory databases, large caches, analytics |
| [F-series (Fsv2)](https://learn.microsoft.com/en-us/azure/virtual-machines/fsv2-series) | Compute-optimised | CPU-intensive apps, batch processing, gaming servers |
| [L-series (Lsv3)](https://learn.microsoft.com/en-us/azure/virtual-machines/lsv3-series) | Storage-optimised | NoSQL databases, data warehousing, big data |
| [N-series (NVsv4)](https://learn.microsoft.com/en-us/azure/virtual-machines/nvv4-series) | GPU (visualisation) | GPU-accelerated VDI, graphics-intensive AVD workloads |

For AVD session host sizing guidance, also refer to [Azure Virtual Desktop workload requirements](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites#session-host-virtual-machine-sizing-guidance).

---

## Storage Types

**[Microsoft Learn — Azure managed disk types](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types)** | **[Premium SSD v2](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssd-v2)**

Azure provides four managed disk types with different performance and cost profiles. The appropriate disk type depends on IOPS, throughput, latency requirements, and cost sensitivity.

> **TODO**: Build a reference table comparing all four disk types across: disk type name, max disk size, max IOPS, max throughput (MBps), latency, supported use (OS disk / data disk), host caching support, zone redundancy support, and cost tier. Use data from the [managed disk types reference](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types).

Summary of disk types:

| Type | Latency | IOPS | Throughput | Notes |
| ---- | ------- | ---- | ---------- | ----- |
| [Ultra Disk](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#ultra-disks) | Sub-millisecond | Up to 400,000 | Up to 10,000 MBps | Data disks only; performance configurable without VM restart |
| [Premium SSD v2](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) | Sub-millisecond | Up to 80,000 (provisioned) | Up to 1,200 MBps | Data disks only; independently provisioned IOPS and throughput |
| [Premium SSD](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssds) | Single-digit ms | Up to 20,000 | Up to 900 MBps | OS and data disks; host caching supported |
| [Standard SSD](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssds) | Low ms | Up to 6,000 | Up to 750 MBps | OS and data disks; consistent latency vs Standard HDD |
| [Standard HDD](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-hdds) | Variable ms | Up to 2,000 | Up to 500 MBps | Dev/test, infrequently accessed data |

For AVD session hosts, Premium SSD or Standard SSD (for pooled hosts) is recommended. Ultra Disk and Premium SSD v2 are data-disk-only; OS disks must use Premium SSD or lower.

---

## AVD Host Pool Configuration Parameters

**[Microsoft Learn — Create a host pool](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pool)** | **[AVD scaling plans](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan)**

> **TODO**: Build a reference table documenting all configurable parameters when creating or updating an AVD host pool. Include columns: parameter name, allowed values, default, and notes. Cover:

**Host pool properties:**

| Parameter | Options | Notes |
| --------- | ------- | ----- |
| Host pool type | Pooled / Personal | Pooled = multi-session shared; Personal = dedicated per user |
| Load balancing algorithm | Breadth-first / Depth-first | Breadth-first distributes users across hosts; Depth-first fills one host before using next |
| Max session limit | Integer (pooled only) | Maximum concurrent sessions per session host VM |
| Validation environment | Yes / No | Receives AVD service updates before production pools |
| [Start VM on connect](https://learn.microsoft.com/en-us/azure/virtual-desktop/start-virtual-machine-connect) | Enabled / Disabled | Automatically powers on deallocated VMs when a user connects |
| RDP properties | See [RDP property reference](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-properties) | Audio, display, device redirection, connection experience settings |
| [Agent update schedule](https://learn.microsoft.com/en-us/azure/virtual-desktop/agent-overview) | Default / Custom maintenance window | Controls when AVD agent and side-by-side stack updates apply |

**Scaling plan parameters (pooled pools):**

- Schedule type (weekdays / weekend)
- Ramp-up start time and load balancing algorithm
- Minimum percentage of hosts during ramp-up
- Peak hours start time and load balancing algorithm
- Peak minimum percentage of hosts
- Ramp-down start time
- Minimum active hosts during ramp-down
- Off-peak minimum percentage of hosts
- Forced logoff grace period

---

## Windows 365 Cloud PC SKU Comparison

**[Microsoft Learn — Windows 365 Enterprise](https://learn.microsoft.com/en-us/windows-365/enterprise/overview)** | **[Windows 365 service description](https://learn.microsoft.com/en-us/windows-365/enterprise/service-description)**

> **TODO**: Build a reference table listing available Windows 365 Cloud PC SKUs with columns: SKU name, vCPUs, RAM (GB), storage (GB), recommended use case, and licence name. Include both Windows 365 Enterprise and Windows 365 Business tiers where applicable.

Key SKU tiers to document (values subject to change — verify current SKUs at [Windows 365 service description](https://learn.microsoft.com/en-us/windows-365/enterprise/service-description)):

- 2 vCPU / 4 GB RAM / 128 GB storage — light productivity (web, Office)
- 2 vCPU / 8 GB RAM / 128 GB storage — standard productivity
- 4 vCPU / 16 GB RAM / 128 GB storage — moderate workloads
- 8 vCPU / 32 GB RAM / 256 GB storage — power users, developers
- 16 vCPU / 64 GB RAM / 512 GB storage — heavy development, data workloads

Also document: Frontline SKUs (shared, shift-based access), GPU SKUs for graphics workloads, and the Windows 365 Switch feature allowing users to move between Cloud PC and local PC.

---

## Backup and Disaster Recovery Options

**[Microsoft Learn — Azure Backup for VMs](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction)** | **[Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview)**

> **TODO**: Build a reference table comparing backup and DR options available for Azure VMs. Include columns: solution name, recovery objective type (backup / DR replication), RPO, RTO, supported VM types, cost model, and notes.

Options to document:

| Solution | Type | Primary Use Case |
| -------- | ---- | ---------------- |
| [Azure Backup (VM backup)](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction) | Backup | Application-consistent VM snapshots; retained in Recovery Services vault |
| [Azure Backup — Enhanced policy](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-enhanced-policy) | Backup | Hourly backup frequency; supports Trusted Launch and Ultra Disk |
| [Azure Site Recovery (ASR)](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview) | Disaster recovery | Continuous replication to secondary region; failover/failback |
| [Azure VM snapshots](https://learn.microsoft.com/en-us/azure/virtual-machines/snapshot-copy-managed-disk) | Point-in-time copy | Quick restore point before changes; not a substitute for backup |
| [Disk-level backup (AzCopy / managed disk export)](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-export-import-private-links) | Manual export | Offline copy; long-term archival |

Key parameters for Azure Backup VM policy:

- Backup frequency (daily, hourly via Enhanced policy)
- Retention: daily, weekly, monthly, yearly recovery points
- Consistency type (application-consistent via VSS, crash-consistent fallback)
- Cross-region restore (secondary region copy for geo-redundancy)
- Soft delete (14-day retention after backup item deletion, enabled by default)

---

## Related Resources

- [Azure VM sizes overview](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Azure managed disk types](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types)
- [Ultra Disk](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#ultra-disks)
- [Premium SSD v2](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssd-v2)
- [Create an AVD host pool](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pool)
- [AVD scaling plans](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan)
- [AVD RDP properties reference](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-properties)
- [Windows 365 Enterprise overview](https://learn.microsoft.com/en-us/windows-365/enterprise/overview)
- [Windows 365 service description](https://learn.microsoft.com/en-us/windows-365/enterprise/service-description)
- [Windows 365 provisioning policies](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)
- [Azure Backup for VMs](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction)
- [Azure Site Recovery overview](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview)
- [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries)
- [Trusted Launch for Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch)
