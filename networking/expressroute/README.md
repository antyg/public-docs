---
title: "ExpressRoute"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "readme"
domain: "networking"
---

# ExpressRoute

## Purpose

Azure ExpressRoute documentation covering routing architecture, hub-and-spoke integration with Azure Firewall, circuit provisioning concepts, and high availability patterns for private connectivity to Azure.

## Content

### Routing (Migrated)

Routing content restructured into Diataxis quadrants:

- [Routing Architecture](explanation-routing-architecture.md) — BGP concepts, route exchange, default route behaviour, hub-and-spoke topology (explanation)
- [Configure Hub-and-Spoke Routing](how-to-configure-hub-spoke-routing.md) — VNet peering settings, spoke subnet route tables, validation steps (how-to)
- [Routing Requirements Reference](reference-routing-requirements.md) — BGP session config, route limits, peering types, gateway transit requirements (reference)

### Deployment (Seed)

Structured outlines for future substantive content:

- [Deployment Overview](explanation-deployment-overview.md) — Circuit provisioning models, connectivity options, peering architecture, high availability, monitoring (explanation, planned)

## Planned Expansion

Future content to be developed from seed outlines:

- Circuit provisioning tutorial (step-by-step walkthrough)
- Peering configuration how-to guide
- Monitoring and troubleshooting how-to guide
- ExpressRoute Global Reach configuration guide

## Relationship to Other Content

- [networking/azure-firewall/](../azure-firewall/) — Azure Firewall routing integration (UDRs, forced tunnelling)
- networking/vpn/ — VPN and ExpressRoute can coexist on the same VNet
- infrastructure/azure-landing-zones/ — Landing zone connectivity patterns (planned)

## Navigation

- Parent: [networking/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)
