# Networking Documentation

## Purpose

This domain contains network infrastructure documentation covering Azure networking services, on-premises network infrastructure, hybrid connectivity patterns, firewall configurations, routing protocols, and DNS architecture.

## Scope

The networking domain encompasses:

- **Azure Networking**: Virtual networks, subnets, network security groups, application gateways, load balancers, and Azure networking services
- **Hybrid Connectivity**: ExpressRoute, VPN gateways, site-to-site connections, point-to-site VPN configurations
- **Firewall Infrastructure**: Azure Firewall, network virtual appliances, perimeter security, traffic inspection
- **Routing and Traffic Management**: User-defined routes, BGP configuration, route tables, traffic flow analysis
- **DNS Services**: Azure DNS, private DNS zones, conditional forwarding, DNS security
- **Network Security**: Network security groups, application security groups, DDoS protection, WAF policies

## Current Structure

### Subfolders

- **azure-firewall/**: Azure Firewall implementation guides, ExpressRoute integration, routing best practices

### Planned Expansion

Future expansion of this domain will include:

- **expressroute/**: ExpressRoute circuit configuration, peering documentation, BGP routing guides
- **dns/**: DNS zone configuration, private DNS integration, conditional forwarding policies
- **vpn/**: VPN gateway configuration, site-to-site and point-to-site documentation
- **nsg/**: Network security group design patterns, rule management, traffic analysis
- **load-balancing/**: Load balancer and application gateway configuration guides
- **vnet/**: Virtual network design, subnet planning, address space management

## Relationship to Other Domains

This domain works closely with:

- **infrastructure/**: Network infrastructure supports landing zone design and PKI certificate distribution
- **identity/**: Network connectivity enables authentication flows and directory service access
- **security/**: Network security groups, firewall policies, and perimeter security controls
- **endpoints/**: Network connectivity for device management and policy delivery

## Content Standards

Documentation in this domain should:

- Include network diagrams using standard notation
- Specify IP addressing schemes and CIDR notation
- Document firewall rules with source, destination, port, and protocol
- Include routing tables with next-hop information
- Provide both Azure Portal and PowerShell/CLI examples
- Cover security considerations and compliance requirements
- Include troubleshooting procedures and validation steps

## Navigation

- Parent: [antyg-public Documentation Library](../README.md)
- Sibling Domains: [identity/](../identity/), [infrastructure/](../infrastructure/), [security/](../security/)

---

**Australian English** | **Last Updated**: 2026-02-09
