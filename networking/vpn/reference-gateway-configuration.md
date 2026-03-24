---
title: "VPN Gateway Configuration Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "reference"
domain: "networking"
platform: "Azure VPN Gateway"
---

# VPN Gateway Configuration Reference

Quick-lookup reference for Azure VPN Gateway configuration parameters, IPsec/IKE policy settings, and authentication requirements.

---

## Gateway Subnet Requirements

| Parameter | Requirement |
|-----------|-------------|
| Subnet name | `GatewaySubnet` (fixed — Azure will not accept any other name) |
| Minimum size | /29 (8 IPs) |
| Recommended size | /27 (32 IPs) — allows for future growth and coexisting gateways |
| NSGs | Not recommended on GatewaySubnet |
| UDRs | Supported with constraints (see [Azure Firewall routing integration](../azure-firewall/how-to-configure-routing.md)) |

**Reference**: [VPN Gateway Settings — Gateway Subnet](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub)

---

## Default IPsec/IKE Parameters

### IKEv2 Phase 1 (Main Mode)

<!-- TODO: Document default IKE Phase 1 parameters:
  - Encryption: AES256
  - Integrity: SHA256
  - DH Group: DHGroup2 (1024-bit) — consider DHGroup14 (2048-bit) for stronger security
  - SA Lifetime: 28,800 seconds (8 hours)
-->

### IKEv2 Phase 2 (Quick Mode)

<!-- TODO: Document default IPsec Phase 2 parameters:
  - Encryption: AES256
  - Integrity: SHA256
  - PFS Group: None (default) — recommend PFS2048
  - SA Lifetime: 3,600 seconds (1 hour) / 102,400,000 KB
-->

**Reference**: [About Cryptographic Requirements and Azure VPN Gateways](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-compliance-crypto)

---

## Point-to-Site Configuration

### Address Pool

| Parameter | Requirement |
|-----------|-------------|
| Address space | Private CIDR block (e.g., `172.16.0.0/24`) |
| Overlap restriction | Must not overlap with VNet address space or on-premises networks |
| Size | Determines maximum concurrent P2S connections from the pool |

### Protocol Selection

| Protocol | Port | Platform Support | Firewall Traversal |
|----------|------|-----------------|-------------------|
| IKEv2 | UDP 500, 4500 | Windows, macOS | Moderate |
| OpenVPN | TCP/UDP 443 | All platforms | Excellent |
| SSTP | TCP 443 | Windows only | Excellent |

### Authentication Requirements

| Method | Prerequisites |
|--------|--------------|
| Azure AD | Azure VPN Enterprise Application registered, OpenVPN protocol |
| Certificate | Root CA certificate uploaded to gateway, client certificates issued |
| RADIUS | RADIUS server reachable from GatewaySubnet, NPS policy configured |

---

## Site-to-Site Configuration

### On-Premises VPN Device Requirements

| Parameter | Requirement |
|-----------|-------------|
| Public IP | Static public IPv4 address (or Dynamic DNS with policy-based) |
| IKE version | IKEv2 recommended (IKEv1 supported for policy-based) |
| NAT-T | Required if device is behind NAT |

<!-- TODO: Document validated VPN device list link, BGP configuration parameters (ASN, peering IP) -->

**Reference**: [About VPN Devices for Site-to-Site Connections](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices)

---

## Related Resources

- [VPN Gateway Settings](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings)
- [Cryptographic Requirements](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-compliance-crypto)
- [VPN Devices for S2S Connections](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices)
- [P2S VPN Configuration](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about)
