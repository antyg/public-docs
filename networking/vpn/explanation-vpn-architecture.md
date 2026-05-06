---
title: "VPN Gateway Architecture"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "explanation"
domain: "networking"
platform: "Azure VPN Gateway"
---

# VPN Gateway Architecture

Overview of Azure VPN Gateway architecture: connection types, tunnelling protocols, authentication methods, and high availability patterns for secure connectivity to Azure virtual networks.

---

## Connection Types

Azure VPN Gateway supports three connection types, each serving different connectivity scenarios:

### Site-to-Site (S2S)

[Site-to-site VPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) connects an on-premises network to an Azure VNet over an IPsec/IKE tunnel. The on-premises side requires a VPN device (hardware or software) with a public-facing IP address.

- Suitable for branch office connectivity, disaster recovery sites, development environments
- Supports BGP for dynamic route exchange
- Multiple S2S connections supported per gateway (multi-site)
- Can coexist with ExpressRoute on the same VNet

### Point-to-Site (P2S)

[Point-to-site VPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about) connects individual client devices to an Azure VNet. No on-premises VPN device required — the connection originates from each client machine.

- Suitable for remote workers, administrators, small teams
- Supports multiple authentication methods (certificate, RADIUS, Azure AD)
- Native VPN clients available for Windows, macOS, Linux, iOS, Android
- OpenVPN protocol support for cross-platform compatibility

### VNet-to-VNet

VNet-to-VNet connections link two Azure VNets over an IPsec/IKE tunnel through Azure backbone. An alternative to VNet peering when encryption is required or when VNets are in different Azure AD tenants.

---

## Tunnelling Protocols

| Protocol | Use Case | Notes |
|----------|----------|-------|
| IKEv2 | S2S and P2S | Recommended for most scenarios. [NIST SP 800-77](https://csrc.nist.gov/publications/detail/sp/800-77/rev-1/final) compliant |
| OpenVPN | P2S | Cross-platform, firewall-friendly (TCP/UDP 443) |
| SSTP | P2S (Windows only) | SSL-based, traverses most firewalls |
| IPsec | S2S | Underlying encryption for IKEv1/IKEv2 tunnels |

<!-- TODO: Document custom IPsec/IKE policy parameters — encryption algorithms, integrity algorithms, DH groups, SA lifetimes -->

---

## Authentication Methods

### Site-to-Site Authentication

| Method | Description |
|--------|-------------|
| Pre-shared key (PSK) | Symmetric key configured on both VPN device and Azure gateway |
| Certificate-based | X.509 certificates for device authentication |

### Point-to-Site Authentication

| Method | Description |
|--------|-------------|
| [Azure AD authentication](https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-tenant) | Entra ID integration — supports MFA and Conditional Access |
| Certificate-based | Self-signed root CA with client certificates |
| RADIUS | Integration with existing RADIUS/NPS infrastructure |

<!-- TODO: Document Azure AD authentication setup, certificate generation workflow, RADIUS integration architecture -->

---

## Gateway SKUs

<!-- TODO: Document SKU comparison table:

| SKU | Max S2S Tunnels | Max P2S Connections | Aggregate Throughput | BGP Support | Zone Redundant |
|-----|----------------|--------------------|--------------------|-------------|----------------|
| VpnGw1 | 30 | 250 | 650 Mbps | Yes | No |
| VpnGw2 | 30 | 500 | 1 Gbps | Yes | No |
| VpnGw3 | 30 | 1,000 | 1.25 Gbps | Yes | No |
| VpnGw1AZ | 30 | 250 | 650 Mbps | Yes | Yes |
| VpnGw2AZ | 30 | 500 | 1 Gbps | Yes | Yes |
| VpnGw3AZ | 30 | 1,000 | 1.25 Gbps | Yes | Yes |
-->

**Reference**: [VPN Gateway SKUs](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsku)

---

## High Availability

<!-- TODO: Document HA patterns:
  - Active-active gateway mode
  - Zone-redundant gateway deployment
  - Dual-tunnel S2S with BGP failover
  - ExpressRoute + VPN coexistence for failover
-->

---

## Related Resources

- [Azure VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)
- [VPN Gateway Settings](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings)
- [Point-to-Site VPN Overview](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about)
- [Site-to-Site VPN Tutorial](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal)
- [NIST SP 800-77 Rev. 1 — Guide to IPsec VPNs](https://csrc.nist.gov/publications/detail/sp/800-77/rev-1/final)
- [ISO/IEC 27001 — Information Security Management](https://www.iso.org/standard/27001)
