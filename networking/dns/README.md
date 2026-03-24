---
title: "DNS Architecture"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "readme"
domain: "networking"
---

# DNS Architecture

## Purpose

DNS architecture documentation for hybrid cloud environments: resolution flows between on-premises and Azure, Private DNS zones, Azure DNS Private Resolver, and conditional forwarding strategies.

## Content

Structured seed outlines with citation frameworks for future substantive content:

### Explanation

- [Hybrid DNS Architecture](explanation-hybrid-dns-architecture.md) — Resolution flows, Private DNS zones, Azure DNS Private Resolver, conditional forwarding, DNS security (planned)

### Reference

- [Azure DNS Zones Reference](reference-azure-dns-zones.md) — Zone types, Private DNS configuration, auto-registration, Private Link DNS zones, public DNS records (planned)

## Planned Expansion

Future content to be developed from seed outlines:

- How-to: Configure Azure DNS Private Resolver (inbound and outbound endpoints)
- How-to: Set up conditional forwarding for hybrid DNS
- How-to: Configure Private DNS zones for Private Endpoints
- Reference: Complete Private Link DNS zone catalogue
- Tutorial: End-to-end hybrid DNS deployment walkthrough

## Relationship to Other Content

- networking/expressroute/ — DNS resolution across ExpressRoute circuits
- identity/ — Active Directory DNS integration
- infrastructure/ — Landing zone DNS design patterns (planned)

## Navigation

- Parent: [networking/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)
