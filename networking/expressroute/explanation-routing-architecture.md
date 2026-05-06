---
title: "ExpressRoute Routing Architecture"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "explanation"
domain: "networking"
platform: "Azure ExpressRoute"
---

# ExpressRoute Routing Architecture

This document explains the routing concepts underpinning Azure ExpressRoute connectivity: BGP session architecture, route exchange mechanics, default route behaviour, and hub-and-spoke topology integration.

---

## BGP Route Exchange

Azure ExpressRoute uses [Border Gateway Protocol (BGP)](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing) as the dynamic routing protocol for exchanging routes between on-premises networks and Azure. BGP enables automatic route learning — when a new subnet is added to either side, the route is advertised and learned without manual configuration.

### Autonomous System Numbers

| Party | AS Number | Notes |
|-------|-----------|-------|
| Microsoft (all peering types) | AS 12076 | Fixed — Azure public, Azure private, and Microsoft peering |
| Customer / Provider | 16-bit or 32-bit ASN | Customer-assigned or provider-assigned |
| Private AS numbers | Allowed with Microsoft Peering | Requires manual validation by Microsoft |

**Reference**: [Azure ExpressRoute Routing Requirements](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing)

### Peering Types

ExpressRoute supports three peering configurations, each establishing separate BGP sessions:

- **Azure Private Peering**: Connects to Azure VNets (IaaS/PaaS with VNet integration). This is the peering type used for hybrid firewall architectures.
- **Microsoft Peering**: Connects to Microsoft 365 and Azure PaaS services via public endpoints.
- **Azure Public Peering** (deprecated): Replaced by Microsoft Peering.

Each peering type maintains independent BGP sessions with distinct route advertisements.

---

## Default Route Behaviour

Default route (`0.0.0.0/0`) handling varies by peering type:

| Peering Type | Accepts Default Route? | Notes |
|--------------|----------------------|-------|
| Azure Private Peering | **Yes** | On-premises can advertise `0.0.0.0/0` to attract Azure traffic |
| Azure Public Peering | **No** | Provider must filter default routes |
| Microsoft Peering | **No** | Provider must filter default routes |

When a default route is advertised via private peering, Azure VNets with route propagation enabled will learn it. This can conflict with Azure Firewall — see [How to Configure Azure Firewall Routing](../azure-firewall/how-to-configure-routing.md) for mitigation strategies.

**Important**: ExpressRoute gateways cannot be configured as transit routers. They are strictly ingress/egress points for their connected VNets and peered VNets.

**Reference**: [ExpressRoute Routing — Default Routes](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing)

---

## Route Limits

ExpressRoute enforces [route advertisement limits](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing) per peering type:

| Peering Type | Standard Limit | With Premium Add-On |
|-------------|---------------|---------------------|
| Azure Private Peering (IPv4) | 4,000 prefixes | 10,000 prefixes |
| Azure Private Peering (IPv6) | 100 prefixes | 100 prefixes |
| Microsoft Peering | 200 prefixes per BGP session | 200 prefixes per BGP session |

**Recommendation**: Summarise on-premises routes to the largest address ranges possible. Advertising individual /32 or /24 routes consumes prefix limits rapidly.

---

## Hub-and-Spoke Topology

In a [hub-and-spoke architecture](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps), the ExpressRoute gateway sits in the hub VNet alongside Azure Firewall. Spoke VNets connect to the hub via VNet peering with gateway transit enabled.

### How Gateway Transit Works

1. The ExpressRoute gateway in the hub learns on-premises routes via BGP
2. Hub VNet peering is configured with **Allow Gateway Transit**
3. Spoke VNet peering is configured with **Use Remote Gateways** and **Allow Forwarded Traffic**
4. Spoke VNets inherit the hub's gateway-learned routes (if route propagation is enabled on spoke subnets)
5. UDRs on spoke subnets override inherited routes, forcing traffic through Azure Firewall

### Traffic Path

```
On-Premises --> ExpressRoute Gateway (Hub) --> Azure Firewall (Hub) --> Spoke VNet
Spoke VNet --> Azure Firewall (Hub) --> ExpressRoute Gateway (Hub) --> On-Premises
```

Both directions traverse the firewall, ensuring symmetric inspection. This requires UDRs on both the GatewaySubnet (for inbound steering) and spoke subnets (for outbound steering).

### Peering Configuration Summary

| VNet | Setting | Value |
|------|---------|-------|
| Hub | Allow Gateway Transit | Enabled |
| Spoke | Use Remote Gateways | Enabled |
| Spoke | Allow Forwarded Traffic | Enabled |

---

## Related Resources

- [Azure ExpressRoute Routing Requirements](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing)
- [ExpressRoute About Virtual Network Gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
- [Tutorial: Deploy Azure Firewall in Hybrid Network](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)
- [Virtual Network Gateways Routing in Azure — Cloud Trooper Blog](https://blog.cloudtrooper.net/2023/02/06/virtual-network-gateways-routing-in-azure/)
