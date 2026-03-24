---
title: "Azure DNS Zones Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Network Engineers"
document_type: "reference"
domain: "networking"
platform: "Azure DNS"
---

# Azure DNS Zones Reference

Quick-lookup reference for Azure DNS zone types, Private DNS zone configuration, and public DNS zone management.

---

## Zone Types

| Zone Type | Scope | Use Case |
|-----------|-------|----------|
| [Public DNS zone](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records) | Internet-facing | Hosting public domain records (A, CNAME, MX, TXT) |
| [Private DNS zone](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview) | VNet-scoped | Internal name resolution, Private Endpoint records |

---

## Private DNS Zone Configuration

### Virtual Network Links

| Setting | Options | Notes |
|---------|---------|-------|
| Registration enabled | True / False | Auto-registers VM hostnames in the zone |
| Link count limit | Up to 1,000 VNets per zone | Each link connects a VNet to the zone |

### Auto-Registration

When a VNet link has registration enabled:

- VMs in the linked VNet automatically get A records created
- Records are removed when VMs are deallocated or deleted
- Only one registration-enabled link per VNet is supported

<!-- TODO: Document auto-registration constraints, TTL defaults, conflict resolution when multiple zones are linked -->

**Reference**: [Azure Private DNS Auto-Registration](https://learn.microsoft.com/en-us/azure/dns/private-dns-autoregistration)

---

## Common Private Link DNS Zones

<!-- TODO: Complete table of privatelink zones for Azure services:

| Azure Service | Private DNS Zone Name |
|--------------|----------------------|
| Blob Storage | privatelink.blob.core.windows.net |
| Azure SQL | privatelink.database.windows.net |
| Key Vault | privatelink.vaultcore.azure.net |
| Azure Files | privatelink.file.core.windows.net |
| Cosmos DB | privatelink.documents.azure.com |
| Container Registry | privatelink.azurecr.io |
-->

**Reference**: [Azure Private Endpoint DNS Configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)

---

## Public DNS Zone Records

| Record Type | Purpose | Example |
|------------|---------|---------|
| A | IPv4 address mapping | `www` --> `203.0.113.10` |
| AAAA | IPv6 address mapping | `www` --> `2001:db8::1` |
| CNAME | Canonical name alias | `www` --> `contoso.azurewebsites.net` |
| MX | Mail exchange | `@` --> `mail.contoso.com` |
| TXT | Text records (SPF, DKIM, verification) | `@` --> `v=spf1 include:spf.protection.outlook.com` |
| NS | Name server delegation | Auto-managed by Azure DNS |
| SOA | Start of authority | Auto-managed by Azure DNS |

**Reference**: [DNS Zones and Records](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records)

---

## Related Resources

- [Azure DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/)
- [Azure Private DNS Overview](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
- [Private Endpoint DNS Configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- [DNS Zones and Records](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records)
