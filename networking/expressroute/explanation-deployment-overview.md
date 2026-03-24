---
title: "ExpressRoute Deployment Overview"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "explanation"
domain: "networking"
platform: "Azure ExpressRoute"
---

# ExpressRoute Deployment Overview

Comprehensive overview of Azure ExpressRoute deployment concepts: circuit provisioning models, connectivity options, peering architecture, and high availability patterns.

---

## Circuit Provisioning

### Connectivity Models

Azure ExpressRoute supports three [connectivity models](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-connectivity-models) for establishing private connectivity between on-premises infrastructure and Azure:

- **Co-location at a cloud exchange**: Direct Layer 2 or managed Layer 3 cross-connections via an exchange provider's infrastructure. Suitable for organisations with existing presence at a colocation facility.
- **Point-to-point Ethernet connection**: Dedicated fibre links between on-premises sites and Azure. Provides guaranteed bandwidth and latency characteristics.
- **Any-to-any (IPVPN) network**: Integration with existing MPLS WAN infrastructure. Azure becomes another site on the enterprise WAN fabric.

### Circuit SKUs

<!-- TODO: Document Standard vs Premium SKU comparison, bandwidth tiers (50 Mbps to 10 Gbps), metered vs unlimited data plans -->

### Provisioning Workflow

<!-- TODO: Step-by-step provisioning process — provider coordination, service key generation, circuit validation, peering configuration -->

---

## Peering Architecture

### Private Peering

Private peering connects to Azure Virtual Networks, providing access to IaaS VMs, PaaS services with VNet integration, and internal load balancers. This is the primary peering type for hybrid enterprise connectivity.

- Supports up to 4,000 IPv4 prefixes (10,000 with Premium)
- Accepts default route advertisements from on-premises
- Used for Azure Firewall integration scenarios (see [Routing Architecture](explanation-routing-architecture.md))

### Microsoft Peering

Microsoft peering connects to Microsoft 365 services and Azure PaaS public endpoints. Traffic flows over the ExpressRoute circuit rather than the public internet.

- Requires route filters to select which Microsoft service prefixes to receive
- Supports up to 200 prefixes per BGP session
- Does not accept default route advertisements

**Reference**: [ExpressRoute Peering Configuration](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-howto-routing-portal-resource-manager)

---

## High Availability

### Redundancy Patterns

<!-- TODO: Document dual-circuit designs, zone-redundant gateways, ExpressRoute Global Reach for cross-circuit connectivity, BFD (Bidirectional Forwarding Detection) for fast failover -->

### ExpressRoute Global Reach

[ExpressRoute Global Reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-global-reach) enables direct connectivity between on-premises networks connected to different ExpressRoute circuits, without routing traffic through Azure VNets. This creates a private backbone between geographically distributed sites.

<!-- TODO: Configuration requirements, supported regions, use cases -->

---

## Monitoring and Diagnostics

### Circuit Health

<!-- TODO: Document ExpressRoute circuit metrics (BitsInPerSecond, BitsOutPerSecond, BGP availability), Azure Monitor integration, alerting patterns -->

### Connection Monitoring

<!-- TODO: Document Connection Monitor (Network Watcher), ExpressRoute Monitor (Log Analytics), BGP session diagnostics -->

**Reference**: [Monitor ExpressRoute Circuits](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-monitoring-metrics-alerts)

---

## Related Resources

- [Azure ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/)
- [ExpressRoute Connectivity Models](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-connectivity-models)
- [ExpressRoute Global Reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-global-reach)
- [Monitor ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-monitoring-metrics-alerts)
- [ExpressRoute FAQ](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-faqs)
