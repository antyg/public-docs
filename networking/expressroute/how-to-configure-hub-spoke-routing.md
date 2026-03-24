---
title: "How to Configure ExpressRoute Hub-and-Spoke Routing"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "how-to"
domain: "networking"
platform: "Azure ExpressRoute"
---

# How to Configure ExpressRoute Hub-and-Spoke Routing

This guide covers the practical steps for configuring VNet peering and spoke subnet route tables in a hub-and-spoke topology with ExpressRoute and Azure Firewall.

---

## Prerequisites

- Hub VNet with Azure Firewall deployed in AzureFirewallSubnet
- ExpressRoute Virtual Network Gateway deployed in GatewaySubnet (/27 or larger)
- ExpressRoute circuit provisioned and connected to the gateway
- One or more spoke VNets created

---

## Configure Hub VNet Peering

For each spoke VNet, create a peering connection from the hub:

| Setting | Value | Rationale |
|---------|-------|-----------|
| Allow Gateway Transit | **Enabled** | Shares the hub's ExpressRoute gateway with the spoke |
| Allow Forwarded Traffic | Enabled | Permits traffic forwarded by Azure Firewall to reach the spoke |

**Reference**: [Configure VNet Peering with Gateway Transit](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-peering-gateway-transit)

---

## Configure Spoke VNet Peering

For each spoke VNet, create a peering connection to the hub:

| Setting | Value | Rationale |
|---------|-------|-----------|
| Use Remote Gateways | **Enabled** | Routes on-premises traffic through the hub's ExpressRoute gateway |
| Allow Forwarded Traffic | **Enabled** | Accepts traffic forwarded via Azure Firewall from the hub |

**Constraint**: "Use Remote Gateways" can only be enabled when the hub VNet has an active gateway. If the gateway is not yet provisioned, peering creation will fail.

---

## Configure Spoke Subnet Route Tables

Each spoke subnet requires a dedicated route table that steers all traffic through Azure Firewall in the hub.

### Create the Route Table

Create a route table with BGP propagation disabled. Disabling propagation ensures that BGP-learned routes from ExpressRoute do not bypass the firewall.

| Setting | Value |
|---------|-------|
| Address prefix | `0.0.0.0/0` |
| Next hop type | Virtual Appliance |
| Next hop IP | Azure Firewall private IP |
| Propagate gateway routes | **Disabled** |

### PowerShell Example

```powershell
# Create route table with BGP propagation disabled
$routeTableSpoke = New-AzRouteTable `
  -Name 'UDR-Spoke' `
  -ResourceGroupName $ResourceGroup `
  -Location $Location `
  -DisableBgpRoutePropagation

# Add default route to Azure Firewall
Add-AzRouteConfig `
  -Name "ToFirewall" `
  -RouteTable $routeTableSpoke `
  -AddressPrefix 0.0.0.0/0 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress $AzfwPrivateIP | Set-AzRouteTable
```

**Reference**: [Tutorial: Deploy Azure Firewall in Hybrid Network (PowerShell)](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)

### Associate Route Table

Associate the route table with each spoke subnet. All subnets in the spoke that require firewall inspection must use this route table.

---

## Validate the Configuration

After configuring peering and route tables:

1. **Check effective routes** on a spoke VM NIC — confirm `0.0.0.0/0` shows Azure Firewall as next hop
2. **Test connectivity** from spoke VM to on-premises host — traffic should appear in Azure Firewall logs
3. **Test connectivity** from on-premises to spoke VM — confirm GatewaySubnet UDR steers traffic through the firewall
4. **Verify symmetry** — both directions must traverse the firewall to avoid asymmetric routing

---

## Related Resources

- [Configure VNet Peering with Gateway Transit](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-peering-gateway-transit)
- [Tutorial: Deploy Azure Firewall in Hybrid Network](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)
- [Azure Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
