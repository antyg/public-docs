# Azure Firewall Documentation

## Purpose

This folder contains implementation guides and best practices for Azure Firewall deployment, configuration, and integration with hybrid network infrastructure.

## Content Overview

This folder receives Azure Firewall documentation migrated from `other-infra/AzFW/`, providing comprehensive guidance on Azure Firewall implementation patterns, particularly focused on integration with ExpressRoute circuits and hybrid connectivity scenarios.

### Migrated Content

**Source**: `other-infra/AzFW/` (17KB)

**Primary Document**: Azure Firewall with ExpressRoute routing guide

The documentation covers:

- **Best Practices**: Azure Firewall deployment patterns with ExpressRoute circuits
- **Routing Configuration**: User-defined routes (UDR) for forced tunnelling and traffic inspection
- **BGP Integration**: Border Gateway Protocol configuration for dynamic route propagation
- **Asymmetric Routing Prevention**: Design patterns to avoid routing asymmetry in hybrid scenarios
- **Traffic Flow Analysis**: Ingress and egress traffic patterns through Azure Firewall
- **High Availability**: Azure Firewall availability zones and redundancy configuration

### Key Technologies

- **Azure Firewall**: Managed cloud-based network security service
- **ExpressRoute**: Private connectivity between on-premises and Azure
- **User-Defined Routes (UDR)**: Custom routing tables for traffic steering
- **Border Gateway Protocol (BGP)**: Dynamic routing protocol for route exchange
- **Network Security**: Layer 3-7 traffic filtering and inspection

## Use Cases

This documentation supports:

1. **Hybrid Network Security**: Centralised egress and ingress filtering for hybrid environments
2. **ExpressRoute Integration**: Routing traffic through Azure Firewall for on-premises connectivity
3. **Hub-and-Spoke Topology**: Azure Firewall as the central security inspection point
4. **Internet Breakout**: Controlled internet egress from Azure and on-premises networks
5. **Traffic Inspection**: Deep packet inspection for east-west and north-south traffic

## Architecture Patterns

The guide addresses several deployment patterns:

- **Forced Tunnelling**: Routing internet-bound traffic through Azure Firewall before egress
- **Transit Routing**: Using Azure Firewall as a transit point between ExpressRoute and VNets
- **Zero-Trust Networking**: Implementing least-privilege access with Azure Firewall rules
- **Availability Zone Deployment**: Multi-zone Azure Firewall for high availability

## Routing Considerations

Key routing topics covered:

- **Route Propagation**: BGP route advertisement from on-premises through ExpressRoute
- **Route Table Design**: UDR configuration for spoke VNets and gateway subnet
- **Next-Hop Configuration**: Setting Azure Firewall as the next hop for specific routes
- **Route Summarisation**: Aggregating routes to reduce routing table complexity
- **Asymmetric Routing Detection**: Identifying and resolving asymmetric traffic flows

## Security Configuration

Documentation includes:

- **Application Rules**: FQDN-based filtering for outbound HTTP/HTTPS traffic
- **Network Rules**: IP address, protocol, and port-based filtering
- **NAT Rules**: Destination NAT for inbound traffic through Azure Firewall
- **Threat Intelligence**: Enabling threat intelligence-based filtering
- **Firewall Policy**: Policy-based management for multi-firewall deployments

## Relationship to Other Content

This content integrates with:

- **networking/expressroute/**: ExpressRoute circuit configuration and peering
- **networking/vnet/**: Virtual network design and subnet planning
- **infrastructure/azure-landing-zones/**: Landing zone network topology
- **operations/monitoring/**: Azure Firewall logging and diagnostics

## Audience

This documentation is intended for:

- Network architects designing hybrid connectivity
- Security engineers implementing network security controls
- Cloud engineers deploying Azure infrastructure
- Operations teams managing Azure Firewall
- Infrastructure teams troubleshooting routing issues

## Navigation

- Parent: [networking/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)

---

**Australian English** | **Last Updated**: 2026-02-09
