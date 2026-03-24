---
title: "How to Configure Azure Firewall Routing"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "how-to"
domain: "networking"
platform: "Azure Firewall"
---

# How to Configure Azure Firewall Routing

This guide covers the practical steps for configuring User-Defined Routes (UDRs) and route propagation settings to steer all traffic through Azure Firewall in a hybrid environment with ExpressRoute.

---

## Prerequisites

Before configuring routing:

- Azure Firewall deployed in the hub VNet's AzureFirewallSubnet
- Azure Firewall private IP address noted (used as next hop in all UDRs)
- ExpressRoute circuit provisioned and connected to a Virtual Network Gateway
- GatewaySubnet created (/27 or larger, as [recommended by Microsoft](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#gwsub))

---

## Configure Workload Subnet UDRs

Create a route table for workload subnets that forces all traffic through Azure Firewall.

**Route table settings:**

| Setting | Value | Rationale |
|---------|-------|-----------|
| Address prefix | `0.0.0.0/0` | Catches all traffic not matched by more specific routes |
| Next hop type | Virtual Appliance | Directs traffic to Azure Firewall |
| Next hop IP | Azure Firewall private IP | The firewall's inspection interface |
| Propagate gateway routes | **Disabled** | Prevents BGP routes from bypassing the firewall |

Disabling [gateway route propagation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#border-gateway-protocol) on workload subnets is critical — without this, BGP-learned routes from ExpressRoute would allow traffic to bypass the firewall entirely.

Associate this route table with every workload subnet that requires firewall inspection.

**Reference**: [Create, Change, or Delete Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)

---

## Configure GatewaySubnet UDR

The GatewaySubnet requires different routing rules to steer on-premises-to-Azure traffic through the firewall.

**GatewaySubnet constraints:**

- `0.0.0.0/0` UDRs are **not supported** on GatewaySubnet
- Route propagation **must be enabled** (the gateway will not function without it)
- Use specific VNet address prefixes instead of the default route

**Route table settings:**

| Setting | Value | Rationale |
|---------|-------|-----------|
| Address prefix | VNet CIDR (e.g., `10.0.0.0/16`) | Catches traffic destined for Azure VNet addresses |
| Next hop type | Virtual Appliance | Directs traffic to Azure Firewall |
| Next hop IP | Azure Firewall private IP | The firewall's inspection interface |
| Propagate gateway routes | **Enabled** | Required for gateway operation |

Associate this route table with the GatewaySubnet.

**Reference**: [ExpressRoute About Virtual Network Gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#gwsub)

---

## Handle BGP-Advertised Default Routes

If your on-premises network advertises a default route (`0.0.0.0/0`) via BGP through ExpressRoute, it will be learned by the AzureFirewallSubnet — potentially breaking Azure Firewall's internet connectivity.

Three mitigation options:

1. **Override with UDR**: Create a `0.0.0.0/0` UDR on AzureFirewallSubnet with next hop type "Internet"
2. **Stop advertising**: Configure your on-premises gateway to stop advertising the default route
3. **Enable forced tunnelling**: Deploy Azure Firewall with the Management NIC enabled (see [Forced Tunnelling](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling))

Option 1 is the least disruptive — it uses UDR priority to override the BGP-learned route without changing on-premises router configuration.

**Reference**: [Azure Firewall FAQ — Forced Tunnelling](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq#is-forced-tunneling-chaining-to-a-network-virtual-appliance-supported)

---

## Configure Route Propagation

Route propagation controls whether BGP-learned routes from ExpressRoute or VPN gateways are injected into a subnet's effective route table.

### Enable Route Propagation On

| Subnet | Reason |
|--------|--------|
| GatewaySubnet | **Required** — gateway will not function without BGP route injection |
| Subnets needing direct on-premises route visibility | Only when not using Azure Firewall for that traffic path |

### Disable Route Propagation On

| Subnet | Reason |
|--------|--------|
| Workload subnets routed through Azure Firewall | Prevents BGP routes from bypassing firewall UDRs |
| Spoke VNet subnets in hub-and-spoke topology | All traffic should traverse the hub firewall |

**Reference**: [Propagate Gateway Routes Configuration](https://learn.microsoft.com/en-us/answers/questions/1373116/propagate-gateway-routes-azure)

---

## Configure Hub-and-Spoke VNet Peering

When using a hub-and-spoke topology with Azure Firewall in the hub:

### Hub VNet Peering Settings

- **Allow Gateway Transit**: Enabled (shares the ExpressRoute gateway with spokes)

### Spoke VNet Peering Settings

- **Use Remote Gateways**: Enabled (uses the hub's ExpressRoute gateway)
- **Allow Forwarded Traffic**: Enabled (permits traffic forwarded by Azure Firewall)

### Spoke Subnet Route Table

Create a route table for each spoke subnet with BGP propagation disabled:

| Setting | Value |
|---------|-------|
| Address prefix | `0.0.0.0/0` |
| Next hop type | Virtual Appliance |
| Next hop IP | Azure Firewall private IP |
| Propagate gateway routes | **Disabled** |

**Reference**: [Tutorial: Deploy Azure Firewall in Hybrid Network (PowerShell)](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)

---

## Enable Forced Tunnelling

To route all internet-bound traffic through an on-premises firewall:

1. Deploy Azure Firewall with [forced tunnelling mode](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling) enabled
2. A Management NIC with a dedicated public IP is provisioned automatically
3. Configure the AzureFirewallSubnet route table to point `0.0.0.0/0` to your on-premises NVA
4. The data path operates without a public IP — all internet traffic tunnels to on-premises

**Constraint**: DNAT rules are not supported with forced tunnelling unless the Management NIC is enabled.

---

## Related Resources

- [Azure Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Create, Change, or Delete Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)
- [Azure Firewall Forced Tunnelling](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling)
- [Deploy Azure Firewall in Hybrid Network](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)
- [ExpressRoute Virtual Network Gateways](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
