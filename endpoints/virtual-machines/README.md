---
title: "Virtual Machines"
status: "planned"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
---

# Virtual Machines

## Overview

Azure virtual machine deployment, Hyper-V configuration, and virtualised endpoint management including Azure Virtual Desktop (AVD) and Windows 365 Cloud PC.

---

## Content Index

| Topic                          | Path                                                                        | Type        | Status  |
| ------------------------------ | --------------------------------------------------------------------------- | ----------- | ------- |
| VM Deployment Concepts         | [explanation-vm-deployment.md](explanation-vm-deployment.md)                | Explanation | Planned |
| VM Configuration Reference     | [reference-vm-configuration.md](reference-vm-configuration.md)              | Reference   | Planned |

### VM Deployment Concepts

Seed outline covering virtual machine deployment patterns and management concepts: Azure VM Deployment Patterns (marketplace images, custom images, Azure Compute Gallery), Hyper-V Configuration (virtual switches, VHDX, Generation 2, Live Migration), Azure Virtual Desktop (host pools, session hosts, application groups, scaling plans, FSLogix profile containers), Windows 365 Cloud PC (provisioning policies, Azure network connections, SaaS vs PaaS comparison with AVD), VM Security and Compliance (Azure Disk Encryption, NSGs, Just-in-Time access, Trusted Launch, Defender for Cloud), and VM Monitoring (Azure Monitor Agent, VM Insights, boot diagnostics, alert rules).

### VM Configuration Reference

Seed outline covering virtual machine configuration lookup material: VM size families and use cases (B, D, E, F, L, N series), storage types comparison (Ultra Disk, Premium SSD v2, Premium SSD, Standard SSD, Standard HDD), AVD host pool configuration parameters (pool type, load balancing, scaling plan schedules), Windows 365 Cloud PC SKU comparison, and backup and disaster recovery options (Azure Backup, Azure Site Recovery, VM snapshots).

---

## Planned Content

- Azure VM deployment and configuration automation
- Hyper-V networking and storage best practices
- Azure Virtual Desktop session host management
- Windows 365 Cloud PC provisioning and policies
- VM security and compliance configuration

---

## Technologies

- Microsoft Azure — cloud platform for VM hosting and management
- Azure Virtual Desktop (AVD) — managed virtual desktop and app virtualisation service
- Windows 365 — SaaS Cloud PC solution managed via Microsoft Intune
- Hyper-V — Microsoft native hypervisor for on-premises and client virtualisation
- Azure Compute Gallery — versioned image storage and replication
- FSLogix — user profile virtualisation for AVD pooled environments
- Azure Monitor / VM Insights — observability and performance monitoring
- Azure Backup / Azure Site Recovery — data protection and disaster recovery
- Microsoft Defender for Cloud — VM security posture management
- Microsoft Intune — device management for Entra-joined AVD session hosts and Cloud PCs

---

**Last Updated**: March 2026
**Maintainer**: antyg
**Status**: Planned — seed outlines added; substantive content to be authored
