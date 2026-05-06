---
title: "Hybrid DNS Architecture"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "explanation"
domain: "networking"
platform: "Azure DNS"
---

# Hybrid DNS Architecture

Overview of DNS architecture patterns for hybrid cloud environments: resolution flows between on-premises and Azure, Private DNS zones, Azure DNS Private Resolver, and conditional forwarding strategies.

---

## DNS Resolution in Hybrid Environments

Hybrid DNS connects two resolution domains: on-premises DNS infrastructure (typically Active Directory-integrated) and Azure DNS services. The architecture must ensure that:

- Azure VMs can resolve on-premises hostnames (e.g., internal AD domain names)
- On-premises clients can resolve Azure Private DNS zone records (e.g., `privatelink.blob.core.windows.net`)
- Public DNS resolution continues to function for internet-facing services
- Private Endpoint DNS records resolve correctly from both sides

### Resolution Flow Patterns

<!-- TODO: Document the three primary resolution flows with diagrams:
  1. Azure VM --> on-premises DNS (via DNS forwarder or Private Resolver outbound endpoint)
  2. On-premises client --> Azure Private DNS zone (via DNS forwarder or Private Resolver inbound endpoint)
  3. Azure VM --> Azure Private DNS zone (automatic via VNet DNS settings)
-->

**Reference**: [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)

---

## Azure Private DNS Zones

[Azure Private DNS zones](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview) provide name resolution within and across Azure Virtual Networks without exposing DNS records to the public internet.

### Key Characteristics

- Linked to one or more VNets via virtual network links
- Support auto-registration of VM hostnames within linked VNets
- Used by Azure Private Endpoints to register `privatelink.*` records
- No custom DNS server infrastructure required for Azure-to-Azure resolution

### Common Private DNS Zones

<!-- TODO: Document the standard privatelink zones for Azure services:
  - privatelink.blob.core.windows.net (Storage)
  - privatelink.database.windows.net (SQL)
  - privatelink.vaultcore.azure.net (Key Vault)
  - Full list from Microsoft documentation
-->

**Reference**: [Azure Private DNS Zone Scenarios](https://learn.microsoft.com/en-us/azure/dns/private-dns-scenarios)

---

## Azure DNS Private Resolver

The [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview) is a managed service that eliminates the need for custom DNS forwarder VMs. It provides:

- **Inbound endpoints**: On-premises clients send DNS queries to the resolver's inbound IP, which resolves against Azure Private DNS zones
- **Outbound endpoints**: Azure VMs send queries for on-premises domains to the resolver, which forwards to on-premises DNS servers via DNS forwarding rulesets

### Architecture Benefits

<!-- TODO: Document advantages over VM-based DNS forwarders:
  - No VM management overhead
  - Built-in high availability (zone-redundant)
  - Scales automatically
  - Integrates with Azure Private DNS zones natively
-->

---

## Conditional Forwarding

Conditional forwarding routes DNS queries for specific domains to designated DNS servers rather than using the default resolution path.

### Common Forwarding Rules

<!-- TODO: Document typical forwarding configurations:
  - On-premises AD domain (e.g., corp.contoso.com) --> on-premises DNS servers
  - Azure privatelink zones --> Azure DNS (168.63.129.16) or Private Resolver inbound
  - External domains --> public DNS or on-premises recursive resolver
-->

---

## DNS Security

<!-- TODO: Document DNS security considerations:
  - DNSSEC status and Azure DNS support
  - DNS query logging and monitoring
  - DNS exfiltration prevention
  - DNS over HTTPS (DoH) / DNS over TLS (DoT) considerations
-->

---

## Related Resources

- [Azure DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/)
- [Azure Private DNS Overview](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
- [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
- [Name Resolution for Resources in Azure Virtual Networks](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances)
- [Private DNS Zone Scenarios](https://learn.microsoft.com/en-us/azure/dns/private-dns-scenarios)
