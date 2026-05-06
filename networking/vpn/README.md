---
title: "VPN Gateway"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "readme"
domain: "networking"
---

# VPN Gateway

## Purpose

Azure VPN Gateway documentation covering site-to-site, point-to-site, and VNet-to-VNet connectivity: tunnelling protocols, authentication methods, gateway SKU selection, and high availability patterns.

## Content

Structured seed outlines with citation frameworks for future substantive content:

### Explanation

- [VPN Gateway Architecture](explanation-vpn-architecture.md) — Connection types (S2S, P2S, VNet-to-VNet), tunnelling protocols, authentication methods, gateway SKUs, high availability (planned)

### Reference

- [Gateway Configuration Reference](reference-gateway-configuration.md) — Subnet requirements, IPsec/IKE parameters, P2S configuration, S2S device requirements (planned)

## Planned Expansion

Future content to be developed from seed outlines:

- How-to: Configure site-to-site VPN with BGP
- How-to: Configure point-to-site VPN with Azure AD authentication
- How-to: Set up VPN and ExpressRoute coexistence
- Reference: Validated VPN device compatibility list
- Tutorial: End-to-end S2S VPN deployment walkthrough

## Relationship to Other Content

- [networking/expressroute/](../expressroute/) — VPN and ExpressRoute coexistence on the same VNet
- [networking/azure-firewall/](../azure-firewall/) — Routing VPN traffic through Azure Firewall
- security/ — VPN security standards and compliance (NIST SP 800-77, ISM controls)

## Navigation

- Parent: [networking/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)
