---
title: "Azure Firewall Configuration Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "reference"
domain: "networking"
platform: "Azure Firewall"
---

# Azure Firewall Configuration Reference

Quick-lookup reference for Azure Firewall deployment requirements, NSG integration rules, and a complete configuration checklist for hybrid environments with ExpressRoute.

---

## Internet Connectivity Requirements

Azure Firewall **must** have direct internet connectivity for management and operations. This is a non-negotiable [architectural requirement](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq#is-forced-tunneling-chaining-to-a-network-virtual-appliance-supported).

| Requirement | Detail |
|-------------|--------|
| Internet access | Direct outbound connectivity from AzureFirewallSubnet |
| BGP default route conflict | If `0.0.0.0/0` is learned via BGP, override with UDR (next hop: Internet) on AzureFirewallSubnet |
| Forced tunnelling alternative | Deploy with Management NIC for management-plane internet access |

---

## NSG Integration Rules

| Rule | Rationale |
|------|-----------|
| Apply NSGs to every workload subnet | [Defence-in-depth](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq) — NSGs complement firewall inspection |
| Use NSGs for microsegmentation | Control east-west traffic between subnets within the same VNet |
| Do **not** apply NSG to AzureFirewallSubnet | [Managed service](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-firewall-security-baseline) — platform NIC-level NSGs are applied automatically |
| Do **not** apply NSG to GatewaySubnet | Or use extreme caution — NSGs can break gateway connectivity |
| Use [Service Tags](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview) | Simplify rule management for Azure service traffic |
| Use Application Security Groups (ASGs) | Group VMs logically for easier rule management |
| Start with least privilege | Allow only necessary traffic; audit regularly |

### NSG and Forced Tunnelling Interaction

When forced tunnelling propagates a `0.0.0.0/0` route to spoke VNets via the gateway:

- Traffic for non-peered VNets may be sent to the gateway
- Default NSG rules block this traffic (it does not match the `VirtualNetwork` [service tag](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview))
- Associate an NSG with every subnet to maintain explicit control over these flows

---

## Route Propagation Quick Reference

| Subnet Type | Propagate Gateway Routes | Reason |
|-------------|------------------------|--------|
| GatewaySubnet | **Enabled** (mandatory) | Gateway requires BGP route injection to function |
| AzureFirewallSubnet | Enabled (default) | Override BGP default with UDR if needed |
| Workload subnets | **Disabled** | Forces traffic through firewall UDRs |
| Spoke subnets (hub-and-spoke) | **Disabled** | All traffic via hub firewall |

---

## Configuration Checklist

### Prerequisites

- [ ] ExpressRoute circuit provisioned and configured
- [ ] Azure Firewall deployed in hub VNet's AzureFirewallSubnet
- [ ] GatewaySubnet created (/27 or larger)
- [ ] ExpressRoute Virtual Network Gateway created

### Azure Firewall

- [ ] Azure Firewall private IP address documented
- [ ] If using forced tunnelling: Management NIC enabled during deployment
- [ ] If BGP advertises default route: `0.0.0.0/0` UDR on AzureFirewallSubnet with next hop Internet

### GatewaySubnet Route Table

- [ ] Route table created and associated with GatewaySubnet
- [ ] UDR: VNet address range --> Azure Firewall private IP (Virtual Appliance)
- [ ] Propagate gateway routes: **Enabled**

### Workload Subnet Route Tables

- [ ] Route table(s) created for workload subnets
- [ ] UDR: `0.0.0.0/0` --> Azure Firewall private IP (Virtual Appliance)
- [ ] Propagate gateway routes: **Disabled**

### NSG Configuration

- [ ] NSGs applied to all workload subnets
- [ ] Inbound/outbound rules configured per least privilege
- [ ] No NSG on AzureFirewallSubnet
- [ ] No NSG on GatewaySubnet (or applied with caution)

### VNet Peering (Hub-and-Spoke)

- [ ] Hub: "Allow Gateway Transit" enabled
- [ ] Spoke: "Use Remote Gateways" enabled
- [ ] Spoke: "Allow Forwarded Traffic" enabled

### Validation

- [ ] Effective routes checked on workload VM NICs
- [ ] Routes show Azure Firewall as next hop for `0.0.0.0/0`
- [ ] Connectivity tested: on-premises to Azure VMs
- [ ] Connectivity tested: Azure VMs to on-premises
- [ ] Azure Firewall logs confirm traffic flow
- [ ] [Network Watcher Next Hop](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table) validates routing

---

## Best Practices Summary

### Routing

1. Always enable route propagation on GatewaySubnet
2. Disable route propagation on workload subnets routed through the firewall
3. Never add `0.0.0.0/0` UDR to GatewaySubnet (unsupported)
4. Use specific VNet CIDR prefixes for GatewaySubnet UDRs
5. Document all UDRs for troubleshooting

### Azure Firewall

1. Ensure direct internet connectivity from AzureFirewallSubnet
2. Override BGP default routes if they conflict with firewall operations
3. Use forced tunnelling mode when on-premises inspection is mandated by policy
4. Monitor Azure Firewall metrics and logs via [Azure Monitor](https://learn.microsoft.com/en-us/azure/firewall/logs-and-metrics)
5. Deploy across [availability zones](https://learn.microsoft.com/en-us/azure/firewall/deploy-availability-zone-powershell) for high availability

### NSGs

1. Apply NSGs to every subnet for defence-in-depth
2. Use NSGs for microsegmentation, not internet filtering (that is the firewall's role)
3. Use Service Tags and ASGs to simplify management
4. Audit NSG rules regularly for overly permissive entries

---

## Related Resources

- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/)
- [Azure Firewall FAQ](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq)
- [Azure Firewall Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-firewall-security-baseline)
- [Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Network Security Groups Overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Deploy Azure Firewall in Hybrid Network](https://learn.microsoft.com/en-us/azure/firewall/tutorial-hybrid-ps)
- [ExpressRoute and Azure Firewall Configuration](https://learn.microsoft.com/en-us/answers/questions/860533/express-route-and-azure-firewall)
