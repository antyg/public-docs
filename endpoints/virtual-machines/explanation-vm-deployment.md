---
title: "Virtual Machine Deployment — Concepts"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "Azure"
---

# Virtual Machine Deployment — Concepts

Conceptual overview of virtual machine deployment patterns in Azure and on-premises Hyper-V, including Azure Virtual Desktop (AVD) session host management, Windows 365 Cloud PC provisioning, VM security and compliance controls, and monitoring. This document covers the key architectural concepts and platform capabilities relevant to endpoint engineers managing virtualised Windows workloads.

> **TODO**: This is a seed outline. Each section below identifies the topic scope and authoritative source references. Substantive content is to be authored in a future iteration.

---

## Azure VM Deployment Patterns

**[Microsoft Learn — Azure Virtual Machines overview](https://learn.microsoft.com/en-us/azure/virtual-machines/overview)** | **[Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries)**

Azure virtual machines are deployed from OS images. Three primary image sourcing patterns are available:

**Marketplace images** — Microsoft-published and third-party images available from the [Azure Marketplace](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage). These include Windows Server editions, Windows 11 Enterprise multi-session (for AVD), and a range of Linux distributions. Marketplace images are updated regularly and provide a clean baseline with the latest cumulative updates applied at the time of image publication.

**Custom images** — Organisation-specific images built from a marketplace base and customised (applications pre-installed, configuration applied, agents deployed) then captured. Custom images can be stored and versioned in an [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) (formerly Shared Image Gallery) for reuse across regions and subscriptions.

**Custom Image Templates** — [Azure Virtual Desktop custom image templates](https://learn.microsoft.com/en-us/azure/virtual-desktop/custom-image-templates) provide a managed pipeline for building, customising, and distributing session host images for AVD deployments, integrated with the Azure Virtual Desktop service.

Key deployment considerations:

- **VM size selection** — VM sizes are organised into [families](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) targeting different workload profiles (general purpose, compute-optimised, memory-optimised, storage-optimised). Size selection affects vCPU count, RAM, maximum disk throughput, and network bandwidth.
- **Licensing** — Windows Server and Windows client licences are included in the Azure VM hourly rate for pay-as-you-go. [Azure Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing) allows use of on-premises Windows Server licences with Software Assurance to reduce Azure VM costs.
- **Availability** — [Availability Zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview) and [Virtual Machine Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) provide fault tolerance and elastic scaling for VM workloads.

> **TODO**: Author conceptual content explaining: the tradeoffs between marketplace images and custom images (freshness vs consistency); the Azure Compute Gallery versioning model; how image replication across regions works; and the decision framework for choosing VM size families.

---

## Hyper-V Configuration

**[Microsoft Learn — Hyper-V on Windows Server](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-on-windows-server)** | **[Hyper-V on Windows client](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/)**

[Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-on-windows-server) is Microsoft's native hypervisor platform, available on Windows Server (as a role) and Windows 10/11 Pro and Enterprise (as an optional feature). It provides type-1 virtualisation for on-premises and hybrid workloads.

Key configuration areas:

- **Virtual switches** — External (bridged to physical NIC), Internal (host-to-VM communication), and Private (VM-to-VM only) switch types; network isolation architecture for VM segmentation
- **Virtual hard disks** — VHDX format (up to 64 TB); dynamically expanding vs fixed-size; storage placement and performance considerations
- **Generation** — Generation 2 VMs (UEFI-based, Secure Boot, faster boot) vs Generation 1 (BIOS-based, legacy compatibility); Generation 2 is the default for new Windows VMs
- **Checkpoints** — Standard checkpoints (includes memory and device state) vs Production checkpoints (VSS-based, application-consistent); management and retention considerations
- **[Live Migration](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/manage/use-live-migration-without-failover-clustering-to-move-a-virtual-machine)** — zero-downtime VM migration between Hyper-V hosts sharing storage; requires network and Kerberos delegation configuration

> **TODO**: Author conceptual content explaining: Hyper-V networking architecture and switch type selection; storage best practices for VHDX placement on Windows Server; the checkpoint management model and production checkpoint workflow; and how Hyper-V integrates with Azure Arc for hybrid management visibility.

---

## Azure Virtual Desktop

**[Microsoft Learn — Azure Virtual Desktop overview](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview)** | **[Deploy Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop)**

[Azure Virtual Desktop (AVD)](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview) is a cloud-based desktop and app virtualisation service running on Azure infrastructure. Microsoft manages the control plane (brokers, gateways, web access, diagnostics); the customer manages session host VMs, host pools, and user assignments.

Key architectural components:

**[Host pools](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pool)** — A collection of identical session host VMs that deliver desktops or apps to users. Two types:

| Type | Description |
| ---- | ----------- |
| Pooled (multi-session) | Multiple users share session hosts concurrently; Windows 11/10 Enterprise multi-session |
| Personal (persistent) | Each user is assigned a dedicated session host; Windows 11/10 Enterprise single-session |

**Session hosts** — Azure VMs running a supported Windows OS image, registered with a host pool via the AVD agent. Session hosts can be [Entra joined or hybrid joined](https://learn.microsoft.com/en-us/azure/virtual-desktop/azure-ad-joined-session-hosts). Intune can manage AVD session hosts when they are Entra joined.

**[Application groups](https://learn.microsoft.com/en-us/azure/virtual-desktop/manage-app-groups)** — Define what is published to users: full desktop, or individual RemoteApp applications.

**[Scaling plans](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan)** — Automatically start and deallocate session hosts based on schedules and active session thresholds, reducing compute costs outside business hours.

**[FSLogix profile containers](https://learn.microsoft.com/en-us/azure/virtual-desktop/fslogix-containers-azure-files)** — User profile virtualisation using VHD/VHDX containers stored on Azure Files (SMB) or Azure NetApp Files, enabling roaming profiles across pooled session hosts.

> **TODO**: Author conceptual content explaining: the AVD control plane vs data plane separation; how session host lifecycle management works (deallocate vs delete); the Entra join vs hybrid join decision for session hosts and the Intune management implications; FSLogix container sizing and placement strategy; and the AVD connectivity model (reverse connect, no inbound firewall rules required).

---

## Windows 365 Cloud PC

**[Microsoft Learn — Windows 365 overview](https://learn.microsoft.com/en-us/windows-365/enterprise/overview)** | **[Windows 365 provisioning policies](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)**

[Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/overview) is a Software-as-a-Service (SaaS) cloud PC solution. Microsoft provisions, manages, and maintains the underlying Azure VM infrastructure; the organisation manages Cloud PCs through Microsoft Intune using the same policies applied to physical Windows endpoints.

Key distinctions from AVD:

| Dimension | Windows 365 | Azure Virtual Desktop |
| --------- | ----------- | --------------------- |
| Infrastructure management | Microsoft-managed (SaaS) | Customer-managed (PaaS) |
| VM runs in | Microsoft's subscription | Customer's Azure subscription |
| Pricing model | Per-user/month flat rate (Cloud PC SKU) | Consumption-based (VM + storage + network) |
| Personalisation | Persistent (each user has a dedicated Cloud PC) | Pooled or personal |
| Intune management | Full (same as physical device) | Full (Entra joined) |
| Scaling | Fixed SKU per user | Dynamic via scaling plans |

**[Provisioning policies](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)** define how Cloud PCs are created: the Azure network connection used, the OS image applied (gallery image or custom image), and the Cloud PC SKU (vCPU / RAM / storage combination).

**[Azure network connections (ANC)](https://learn.microsoft.com/en-us/windows-365/enterprise/create-azure-network-connection)** link Windows 365 provisioning to an Azure virtual network, enabling Cloud PCs to reach on-premises resources via ExpressRoute or VPN. Provisioning without an ANC (Microsoft-hosted network) is available for internet-only scenarios.

> **TODO**: Author conceptual content explaining: the Cloud PC provisioning workflow from licence assignment to ready state; the role of the Azure network connection and when it is required; image management for Cloud PCs (gallery vs custom images); reprovisioning vs resize workflows; and the Windows 365 link device (physical thin client) integration.

---

## VM Security and Compliance

**[Microsoft Learn — Azure VM security overview](https://learn.microsoft.com/en-us/azure/virtual-machines/security-overview)** | **[Just-in-time VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)**

Security controls for Azure VMs operate across multiple layers:

**Disk encryption** — [Azure Disk Encryption (ADE)](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview) uses BitLocker (Windows) or DM-Crypt (Linux) to encrypt VM OS and data disks. Keys are stored in Azure Key Vault. [Encryption at host](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption#encryption-at-host---end-to-end-encryption-for-your-vm-data) extends encryption to temporary disks and caches. [Confidential disk encryption](https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-vm-overview) is available on supported confidential VM sizes for additional hardware-based isolation.

**Network security** — [Network Security Groups (NSGs)](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) control inbound and outbound traffic at the NIC or subnet level. NSG rules are the primary mechanism for network isolation between VMs and from the internet.

**[Just-in-Time (JIT) access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)** — Microsoft Defender for Cloud feature that blocks management ports (RDP 3389, SSH 22, WinRM 5985/5986) by default and opens them on-demand for approved time-bounded requests. Eliminates persistent exposure of management surfaces to the internet.

**[Trusted Launch](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch)** — Provides Secure Boot, vTPM, and boot integrity monitoring for Azure VMs. Recommended for all new VM deployments. Enables Attestation-based compliance checks in Microsoft Defender for Cloud.

**[Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-servers-introduction)** — Provides vulnerability assessment, security recommendations, threat detection (Defender for Servers), and regulatory compliance reporting for Azure VMs.

> **TODO**: Author conceptual content explaining: the difference between Azure Disk Encryption and server-side encryption (SSE); how JIT access integrates with NSG rules; the Trusted Launch requirements and enablement workflow; and how Defender for Cloud security score and regulatory compliance views apply to VM workloads.

---

## VM Monitoring

**[Microsoft Learn — Azure Monitor for VMs](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)** | **[Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)**

[Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) is the primary observability platform for Azure VMs. Key monitoring capabilities:

**[VM Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)** — Provides pre-built performance charts (CPU, memory, disk, network) and a dependency map showing connections between VMs and external services. Deployed via the Azure Monitor Agent.

**[Azure Monitor Agent (AMA)](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)** — The current generation monitoring agent (replaces the legacy Log Analytics Agent / MMA). Collects performance counters, Windows Event Log, and Syslog data and sends to a Log Analytics workspace. Configured via Data Collection Rules (DCRs).

**[Boot diagnostics](https://learn.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics)** — Captures VM console output and screenshots at boot, enabling diagnosis of boot failures without requiring RDP/SSH connectivity.

**[Diagnostic settings](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)** — Routes VM platform metrics and activity logs to a Log Analytics workspace, storage account, or Event Hub for retention and analysis.

**Alerts** — [Azure Monitor alert rules](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview) can trigger notifications or automated actions (runbooks, Logic Apps) based on metric thresholds or log query results.

> **TODO**: Author conceptual content explaining: the AMA vs legacy MMA migration path and timeline; Data Collection Rule design for multi-VM environments; how VM Insights dependency maps are used for application topology analysis; and how boot diagnostics integrates with VM repair and recovery workflows.

---

## Related Resources

- [Azure Virtual Machines overview](https://learn.microsoft.com/en-us/azure/virtual-machines/overview)
- [Azure VM sizes overview](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries)
- [Azure Hybrid Benefit for Windows Server](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
- [Hyper-V on Windows Server](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-on-windows-server)
- [Azure Virtual Desktop overview](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview)
- [Deploy Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop)
- [AVD host pools](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pool)
- [AVD scaling plans](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan)
- [FSLogix profile containers](https://learn.microsoft.com/en-us/azure/virtual-desktop/fslogix-containers-azure-files)
- [Windows 365 overview](https://learn.microsoft.com/en-us/windows-365/enterprise/overview)
- [Windows 365 provisioning policies](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)
- [Azure network connections for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/create-azure-network-connection)
- [Azure VM security overview](https://learn.microsoft.com/en-us/azure/virtual-machines/security-overview)
- [Azure Disk Encryption overview](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
- [Just-in-time VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)
- [Trusted Launch for Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch)
- [Azure Monitor for VMs (VM Insights)](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
