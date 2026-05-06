---
title: "Azure Firewall Traffic Architecture"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "explanation"
domain: "networking"
platform: "Azure Firewall"
---

# Azure Firewall Traffic Architecture

This document explains the traffic flow patterns and architectural concepts for Azure Firewall deployments integrated with ExpressRoute in hybrid cloud environments. It covers bidirectional traffic flow design, forced tunnelling concepts, and defence-in-depth layering with Network Security Groups.

---

## Traffic Flow Architecture

Azure Firewall serves as the central inspection point for all traffic in a hybrid network. The architecture ensures that both Azure-to-on-premises and on-premises-to-Azure traffic passes through the firewall for inspection.

### Azure to On-Premises Flow

All traffic originating from Azure workload subnets destined for on-premises networks follows this path:

```
Workload Subnets --> Azure Firewall --> ExpressRoute Gateway --> On-Premises
```

This flow is achieved by placing a [User-Defined Route (UDR)](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview) with a `0.0.0.0/0` default route on all workload subnets, pointing to Azure Firewall's private IP address as the next hop. The UDR overrides the default system route that would otherwise send traffic directly to the internet or via BGP-learned routes.

### On-Premises to Azure Flow

Traffic arriving from on-premises through the ExpressRoute gateway must also traverse the firewall:

```
On-Premises --> ExpressRoute Gateway --> Azure Firewall --> Workload Subnets
```

This requires a UDR on the [GatewaySubnet](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#gwsub) using the VNet address range (not `0.0.0.0/0`, which is unsupported on GatewaySubnet) pointing to Azure Firewall's private IP. The GatewaySubnet UDR intercepts traffic after the ExpressRoute gateway decapsulates it, steering it through the firewall before delivery to the destination subnet.

### Route Priority

Azure evaluates routes in a strict [priority hierarchy](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview):

1. **User-Defined Routes** (highest priority)
2. **BGP routes** (from ExpressRoute or VPN gateways)
3. **System routes** (lowest priority)

This hierarchy is what makes UDR-based traffic steering work — UDRs always take precedence over BGP-advertised routes from on-premises.

---

## Forced Tunnelling

[Forced tunnelling](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling) is an architecture pattern where all internet-bound traffic is routed through an on-premises firewall or network virtual appliance (NVA) for inspection before reaching the internet. This pattern is common in organisations with strict security policies requiring centralised internet egress control.

### When Forced Tunnelling Applies

Forced tunnelling is appropriate when:

- Security policy mandates that all internet-bound traffic passes through on-premises inspection
- Regulatory requirements demand centralised traffic logging at a physical location
- The organisation operates a mature on-premises security stack (proxy, IPS/IDS, DLP) that cannot be replicated in Azure

### Management NIC Architecture

When forced tunnelling is enabled on Azure Firewall, a **Management NIC** is automatically provisioned with a dedicated public IP address. This management interface is used exclusively by the Azure platform for firewall operations (health probes, updates, telemetry). The data path — the interface handling customer traffic — can then operate without a public IP, allowing all data-plane traffic to be tunnelled to on-premises.

This dual-NIC model ensures the firewall remains manageable even when the data path is fully tunnelled.

### SNAT Behaviour

With forced tunnelling configured, internet-bound traffic is [SNATed](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling) to one of the firewall's private IP addresses in AzureFirewallSubnet. This masks the original source IP from the on-premises firewall. To disable this behaviour for specific traffic, add `0.0.0.0/0` to the Azure Firewall's private IP address ranges configuration.

**Important**: DNAT (Destination NAT for inbound traffic) is not supported when forced tunnelling is enabled unless the Management NIC is also enabled.

---

## Defence-in-Depth: Azure Firewall and NSGs

Azure Firewall and [Network Security Groups (NSGs)](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) operate at different layers and serve complementary roles in a defence-in-depth strategy:

| Layer | Component | Capability |
|-------|-----------|------------|
| Layer 3-4 | NSGs | Subnet or NIC-level packet filtering by IP, port, protocol |
| Layer 3-4-7 | Azure Firewall | Centralised filtering with FQDN rules, threat intelligence, TLS inspection |

NSGs provide **microsegmentation** — controlling traffic between subnets within the same VNet. Azure Firewall provides **macro-segmentation** — controlling traffic between VNets, to/from the internet, and to/from on-premises networks.

### AzureFirewallSubnet Exception

Azure Firewall is a [managed service with platform-level protection](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-firewall-security-baseline). The platform applies NIC-level NSGs automatically (not visible to administrators). Subnet-level NSGs on AzureFirewallSubnet are neither required nor recommended — they are disabled to prevent service interruption.

---

## Hub-and-Spoke Integration

In a [hub-and-spoke topology](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps), Azure Firewall sits in the hub VNet alongside the ExpressRoute gateway. Spoke VNets peer with the hub and route all traffic through the firewall.

Key architectural decisions:

- **Hub VNet**: Hosts Azure Firewall and ExpressRoute gateway. VNet peering with spokes has "Allow Gateway Transit" enabled.
- **Spoke VNets**: Peer with hub using "Use Remote Gateways" and "Allow Forwarded Traffic". Each spoke's route table points `0.0.0.0/0` to the firewall.
- **Route propagation**: Disabled on spoke subnets (forces UDR usage) but enabled on GatewaySubnet (required for gateway operation).

This pattern centralises security inspection while allowing spoke VNets to communicate with on-premises networks via the hub's ExpressRoute gateway.

---

## Related Resources

### Architecture

- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/)
- [Azure Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Tutorial: Deploy Azure Firewall in Hybrid Network](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)

### Forced Tunnelling

- [Azure Firewall Forced Tunnelling](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling)
- [Azure Firewall FAQ](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq)

### Network Security

- [Azure Firewall Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-firewall-security-baseline)
- [Network Security Groups Overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
