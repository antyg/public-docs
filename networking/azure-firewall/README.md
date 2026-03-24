---
title: "Azure Firewall Documentation"
status: "draft"
last_updated: "2026-03-09"
audience: "Network Engineers"
document_type: "readme"
domain: "networking"
---

# Azure Firewall Documentation

## Purpose

This folder contains implementation guides and best practices for Azure Firewall deployment, configuration, and integration with hybrid network infrastructure.

## Content

Documentation restructured into Diátaxis quadrants with inline citations to Microsoft Learn.

### Explanation

- [Traffic Architecture](explanation-traffic-architecture.md) — Traffic flow patterns, forced tunnelling concepts, defence-in-depth with NSGs, hub-and-spoke integration

### How-To Guides

- [Configure Routing](how-to-configure-routing.md) — UDR configuration for workload subnets, GatewaySubnet, route propagation, VNet peering, forced tunnelling
- [Troubleshoot Routing](how-to-troubleshoot.md) — Validation tools, common issues, diagnostic workflow

### Reference

- [Configuration Reference](reference-configuration.md) — Internet connectivity requirements, NSG rules, route propagation quick reference, deployment checklist, best practices

## Key Technologies

- **Azure Firewall**: Managed cloud-based network security service (Layer 3-4-7)
- **User-Defined Routes (UDR)**: Custom routing tables for traffic steering through the firewall
- **Network Security Groups (NSG)**: Subnet/NIC-level packet filtering for microsegmentation
- **Forced Tunnelling**: Routing internet-bound traffic through on-premises inspection

## Relationship to Other Content

- [networking/expressroute/](../expressroute/) — ExpressRoute circuit configuration and peering (routing integration documented here)
- infrastructure/azure-landing-zones/ — Landing zone network topology (planned)
- security/ — Network security controls and compliance frameworks

## Navigation

- Parent: [networking/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)

---

**Australian English** | **Last Updated**: 2026-02-09
