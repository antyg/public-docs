---
title: "ExpressRoute Routing Requirements Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "reference"
domain: "networking"
platform: "Azure ExpressRoute"
---

# ExpressRoute Routing Requirements Reference

Quick-lookup reference for ExpressRoute BGP session configuration, route limits, peering requirements, and default route behaviour.

---

## BGP Session Configuration

| Parameter | Value |
|-----------|-------|
| Microsoft AS number | 12076 (all peering types) |
| Supported customer ASN | 16-bit and 32-bit |
| Private AS numbers | Allowed with Microsoft Peering (manual validation required) |
| Protocol | BGP (Border Gateway Protocol) |

**Reference**: [Azure ExpressRoute Routing Requirements](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing)

---

## Route Limits

| Peering Type | Protocol | Standard Limit | With Premium |
|-------------|----------|----------------|--------------|
| Azure Private Peering | IPv4 | 4,000 prefixes | 10,000 prefixes |
| Azure Private Peering | IPv6 | 100 prefixes | 100 prefixes |
| Microsoft Peering | IPv4/IPv6 | 200 prefixes per BGP session | 200 prefixes per BGP session |

**Recommendation**: Summarise on-premises routes to the largest CIDR blocks possible to conserve prefix limits.

---

## Default Route Behaviour

| Peering Type | Accepts `0.0.0.0/0`? | Action Required |
|-------------|----------------------|-----------------|
| Azure Private Peering | Yes | Filter or override with UDR if Azure Firewall is deployed |
| Microsoft Peering | No | Provider must filter default routes |
| Azure Public Peering (deprecated) | No | Provider must filter default routes |

---

## Peering Type Comparison

| Peering Type | Connects To | Use Case |
|-------------|-------------|----------|
| Azure Private Peering | Azure VNets (IaaS, PaaS with VNet integration) | Hybrid connectivity, firewall integration |
| Microsoft Peering | Microsoft 365, Azure PaaS public endpoints | SaaS and PaaS access over private circuit |

---

## Gateway Transit Requirements

| Component | Setting | Mandatory |
|-----------|---------|-----------|
| Hub VNet peering | Allow Gateway Transit | Yes (for spoke gateway sharing) |
| Spoke VNet peering | Use Remote Gateways | Yes (requires active hub gateway) |
| Spoke VNet peering | Allow Forwarded Traffic | Yes (for firewall-forwarded traffic) |
| GatewaySubnet | Route propagation | Must be Enabled |
| GatewaySubnet | `0.0.0.0/0` UDR | **Not supported** |
| GatewaySubnet | VNet CIDR UDR | Supported (point to firewall) |
| Spoke subnets | Route propagation | Should be Disabled (forces UDR path) |

---

## ExpressRoute Constraints

| Constraint | Detail |
|-----------|--------|
| No transit routing | ExpressRoute gateways cannot act as transit routers between on-premises networks |
| GatewaySubnet size | /27 or larger recommended |
| Forced tunnelling interaction | Default routes via BGP can break Azure Firewall internet access — override required |
| Coexistence | ExpressRoute and [site-to-site VPN can coexist](https://learn.microsoft.com/en-us/azure/expressroute/how-to-configure-coexisting-gateway-portal) on the same VNet |

---

## Related Resources

- [Azure ExpressRoute Routing Requirements](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-routing)
- [ExpressRoute About Virtual Network Gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
- [Configure ExpressRoute and Site-to-Site Coexisting Connections](https://learn.microsoft.com/en-us/azure/expressroute/how-to-configure-coexisting-gateway-portal)
- [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/)
