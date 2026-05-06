---
title: "How to Troubleshoot Azure Firewall Routing"
status: "draft"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "how-to"
domain: "networking"
platform: "Azure Firewall"
---

# How to Troubleshoot Azure Firewall Routing

This guide covers validation tools and common issue resolution for Azure Firewall routing in hybrid environments with ExpressRoute.

---

## Validation Tools

### Effective Routes

View the effective route table on each VM's network interface to confirm that UDRs are applied correctly.

**Portal path**: Virtual Machine --> Networking --> Network Interface --> Effective Routes

This shows the combined result of system routes, BGP-learned routes, and UDRs after priority resolution. Confirm that `0.0.0.0/0` shows Azure Firewall's private IP as the next hop for workload VMs.

**Reference**: [View Effective Routes](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)

### Network Watcher: Next Hop

Test the next hop for a specific destination IP address from a specific VM. This validates that your UDR configuration is steering traffic as intended without sending actual application traffic.

**Portal path**: Network Watcher --> Next Hop --> Select VM, source IP, destination IP

### Network Watcher: Connection Troubleshoot

Send test packets from a source VM to a destination to verify end-to-end connectivity through the firewall. This confirms both routing and firewall rules are configured correctly.

---

## Common Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| Cannot connect to spoke VMs from on-premises | Route propagation disabled on GatewaySubnet | Enable propagate gateway routes on GatewaySubnet |
| Traffic bypassing firewall | No UDR on workload subnets | Add `0.0.0.0/0` UDR pointing to Azure Firewall private IP |
| Azure Firewall loses internet connectivity | Default route learned via BGP conflicts with firewall operations | Add `0.0.0.0/0` UDR on AzureFirewallSubnet with next hop type Internet |
| Asymmetric routing | Incorrect or incomplete UDR configuration | Verify UDRs on both GatewaySubnet and workload subnets — both directions must traverse the firewall |
| Spoke VMs cannot reach on-premises | "Use Remote Gateways" not enabled on spoke peering | Enable "Use Remote Gateways" on spoke VNet peering and "Allow Gateway Transit" on hub peering |
| Forced tunnelling breaks DNAT | DNAT not supported with forced tunnelling unless Management NIC is enabled | Enable Management NIC on Azure Firewall deployment |

---

## Diagnostic Workflow

1. **Check effective routes** on the source VM's NIC — confirm next hop for destination is Azure Firewall
2. **Check effective routes** on the destination VM's NIC — confirm return path also traverses the firewall (no asymmetry)
3. **Check Azure Firewall logs** — confirm the firewall sees the traffic and is not dropping it via a rule
4. **Check NSG flow logs** — confirm NSGs on source and destination subnets are not blocking the traffic
5. **Use Network Watcher Next Hop** — validate routing decisions for specific source/destination pairs
6. **Check route propagation settings** — confirm disabled on workload subnets, enabled on GatewaySubnet
7. **Check VNet peering settings** — confirm gateway transit and forwarded traffic are enabled

---

## Related Resources

- [Azure Firewall Logs and Metrics](https://learn.microsoft.com/en-us/azure/firewall/logs-and-metrics)
- [Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/)
- [Create, Change, or Delete Azure Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)
- [Firewall Routing Configuration through ExpressRoute](https://learn.microsoft.com/en-us/answers/questions/1387335/how-to-fix-this-firewall-routing-configuration-thr)
