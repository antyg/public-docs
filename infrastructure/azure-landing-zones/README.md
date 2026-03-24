---
title: "Azure Landing Zones"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# Azure Landing Zones

## Purpose

This directory contains documentation for Azure landing zone architecture, design, and configuration. It covers the [Microsoft Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) landing zone model, management group hierarchy, subscription organisation, network topology, identity integration, and policy-driven governance for enterprise-scale Azure environments.

## Content

### Explanation

Understanding-oriented documents covering concepts and design rationale.

| Document | Description |
|----------|-------------|
| [Landing Zone Architecture](explanation-landing-zone-architecture.md) | CAF landing zone conceptual architecture; management group hierarchy; subscription design; hub-spoke vs Virtual WAN; identity integration; Azure Policy governance; Defender for Cloud and Sentinel security baseline |

### Reference

Information-oriented documents for factual lookup and configuration specifications.

| Document | Description |
|----------|-------------|
| [Landing Zone Configuration Reference](reference-landing-zone-configuration.md) | Management group hierarchy table; subscription naming conventions and tagging requirements; Azure Policy assignments by scope; network address space allocation; RBAC assignments; diagnostic settings; resource provider registration; Connectivity subscription resources |

## Planned Expansion

Future content to be added to this directory:

- **how-to-deploy-landing-zone.md** — Step-by-step guide for deploying the management group hierarchy, platform subscriptions, and initial policy assignments
- **how-to-onboard-application-subscription.md** — Procedure for adding a new application landing zone subscription under the Corp or Online management group
- **how-to-configure-hub-network.md** — Deploying the Connectivity subscription hub VNet, Azure Firewall, and gateway resources
- **reference-policy-initiative-library.md** — Full catalogue of approved Azure Policy initiatives and their management group assignments
- **explanation-hybrid-connectivity.md** — ExpressRoute and VPN gateway design patterns for on-premises connectivity

<!-- TODO: Add how-to guides and policy library reference once deployment templates are finalised -->

## Relationship to Other Content

| Domain | Relationship |
|--------|-------------|
| [infrastructure/terraform/](../terraform/) | Terraform modules and workflows are used to deploy the landing zone resources defined in this directory |
| [infrastructure/pki/](../pki/) | Certificate services deployed in the Identity platform subscription depend on landing zone network and RBAC foundations |
| [networking/](../../networking/) | Azure Firewall and ExpressRoute/VPN gateway resources in the Connectivity subscription are detailed in the networking domain |
| [identity/](../../identity/) | Entra ID, PIM, and Conditional Access governance referenced in landing zone architecture are detailed in the identity domain |
| [security/](../../security/) | Microsoft Defender for Cloud and Microsoft Sentinel integration are detailed in the security domain |

## Navigation

- Parent: [Infrastructure Documentation](../README.md)
- Sibling: [terraform/](../terraform/), [pki/](../pki/)
- Domain root: [antyg-public Documentation Library](../../README.md)

---

**Australian English** | **Last Updated**: 2026-03-16
