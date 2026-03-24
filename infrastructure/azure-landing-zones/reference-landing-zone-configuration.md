---
title: "Landing Zone Configuration Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "reference"
domain: "infrastructure"
platform: "Azure"
---

# Landing Zone Configuration Reference

Factual configuration data for Azure landing zone deployments. For conceptual background and design rationale see [Landing Zone Architecture](explanation-landing-zone-architecture.md).

---

## Management Group Hierarchy

<!-- TODO: Populate with actual tenant management group names and IDs once organisational design is finalised -->

| Level | Management Group Name | Parent | Purpose |
|-------|-----------------------|--------|---------|
| 0 | Tenant Root Group | — | Auto-created root; no direct policy assignments |
| 1 | `<OrgRoot>` | Tenant Root Group | Organisation-wide governance scope |
| 2 | Platform | `<OrgRoot>` | Shared platform subscriptions |
| 2 | Landing Zones | `<OrgRoot>` | Application workload subscriptions |
| 2 | Sandbox | `<OrgRoot>` | Developer experimentation; no production data |
| 2 | Decommissioned | `<OrgRoot>` | Subscriptions pending cancellation |
| 3 | Identity | Platform | AD DS, Entra Connect, DNS |
| 3 | Management | Platform | Log Analytics, Automation, monitoring |
| 3 | Connectivity | Platform | Hub VNets, Firewall, VPN/ER gateways |
| 3 | Corp | Landing Zones | Connected workloads (on-premises access required) |
| 3 | Online | Landing Zones | Internet-facing workloads |

---

## Subscription Naming Conventions

<!-- TODO: Confirm naming pattern with platform team before publishing -->

Recommended pattern: `<org>-<environment>-<workload>-<sequence>`

| Token | Values | Example |
|-------|--------|---------|
| `<org>` | Organisation abbreviation (3–5 chars) | `cntso` |
| `<environment>` | `prod`, `nonprod`, `dev`, `sandbox` | `prod` |
| `<workload>` | Short workload identifier | `connectivity` |
| `<sequence>` | Zero-padded integer | `001` |

Example: `cntso-prod-connectivity-001`

### Tagging Requirements

All subscriptions and resource groups MUST carry the following tags:

| Tag Key | Required | Values | Purpose |
|---------|----------|--------|---------|
| `environment` | Yes | `Production`, `NonProduction`, `Development`, `Sandbox` | Environment classification |
| `workload` | Yes | Free text | Workload identifier for cost allocation |
| `owner` | Yes | UPN of responsible engineer | Operational accountability |
| `cost-centre` | Yes | Finance cost centre code | Chargeback |
| `data-classification` | Yes | `Official`, `Protected`, `Sensitive` | PSPF classification alignment |
| `managed-by` | Yes | `Platform`, `Application` | Distinguishes platform vs application ownership |

---

## Azure Policy Assignments by Management Group Scope

<!-- TODO: Define the full policy initiative library. The entries below are representative examples. -->

| Scope | Initiative / Policy | Effect | Justification |
|-------|--------------------|-----------------------|---------------|
| `<OrgRoot>` | Allowed locations | Deny | Restrict resource deployment to approved Azure regions |
| `<OrgRoot>` | Require a tag on resource groups | Deny | Enforce mandatory tagging on all resource groups |
| `<OrgRoot>` | Configure diagnostic settings to Log Analytics | DeployIfNotExists | Centralise audit logs for ACSC ISM compliance |
| Platform/Connectivity | Azure Firewall threat intelligence mode | Audit/Deny | Detect and block known malicious IP/domain traffic |
| Platform/Connectivity | Deny public IP except in approved subnets | Deny | Restrict uncontrolled internet egress |
| Landing Zones/Corp | Enforce private endpoints for PaaS | Deny | Prevent data exfiltration via public PaaS endpoints |
| Landing Zones/Corp | Require Azure Defender for Servers | DeployIfNotExists | Ensure workload protection on all VMs |
| Landing Zones/Online | WAF policy required on Application Gateway | Deny | Mandate WAF in Prevention mode for internet-facing apps |
| Sandbox | Allow resource creation but enforce budget alerts | Audit | Permit experimentation within cost guardrails |

---

## Network Address Space Allocation

<!-- TODO: Replace placeholder CIDRs with confirmed organisational IP plan. Co-ordinate with network team before publishing. -->

| Segment | CIDR | Purpose |
|---------|------|---------|
| Hub VNet (primary region) | `10.0.0.0/16` | Shared connectivity hub |
| AzureFirewallSubnet | `10.0.0.0/26` | Azure Firewall (minimum /26) |
| GatewaySubnet | `10.0.1.0/27` | VPN and/or ExpressRoute gateways |
| AzureBastionSubnet | `10.0.2.0/26` | Azure Bastion (minimum /26 required) |
| Hub management subnet | `10.0.3.0/28` | Jump hosts, management VMs |
| Corp spoke range | `10.1.0.0/14` | Address space reserved for Corp landing zone spokes |
| Online spoke range | `10.5.0.0/14` | Address space reserved for Online landing zone spokes |
| Platform Identity spoke | `10.9.0.0/24` | Identity subscription VNet |
| Platform Management spoke | `10.9.1.0/24` | Management subscription VNet |
| Reserved (future use) | `10.10.0.0/8` | Reserved for future expansion and additional regions |
| On-premises summary routes | `172.16.0.0/12` | Summarised on-premises advertisement via VPN/ExpressRoute |

All spoke VNets MUST be peered to the hub with `UseRemoteGateway: true` and `AllowGatewayTransit: false` on the hub side.

---

## RBAC Role Assignments by Management Group Level

<!-- TODO: Map role assignments to Entra ID groups once group naming convention is confirmed -->

| Management Group | Role | Principal Type | Purpose |
|-----------------|------|----------------|---------|
| `<OrgRoot>` | Management Group Reader | Platform team security group | Read-only visibility across all scopes |
| `<OrgRoot>` | Resource Policy Contributor | Platform automation service principal | Policy assignment automation |
| Platform | Owner (via PIM) | Platform team security group | Full platform management (JIT) |
| Landing Zones | Contributor (via PIM) | Application team security groups | Workload resource management (JIT) |
| Landing Zones | Reader | Application team security groups | Persistent read access for application teams |
| Landing Zones | Cost Management Reader | Finance service group | Cost and budget visibility |
| Sandbox | Contributor | Developer security group | Unrestricted dev experimentation within sandbox scope |

All Owner, Contributor, and User Access Administrator assignments at management group scope MUST be configured as eligible (not permanent) in [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure).

---

## Diagnostic Settings and Log Destinations

All Azure resources MUST forward diagnostic logs to the centralised Log Analytics workspace in the Management subscription.

| Resource Type | Log Category | Retention (days) | Destination |
|--------------|-------------|-----------------|-------------|
| Subscription Activity Log | All categories | 90 | Log Analytics (Management) |
| Azure Firewall | `AzureFirewallApplicationRule`, `AzureFirewallNetworkRule`, `AzureFirewallDnsProxy` | 90 | Log Analytics (Management) |
| Azure Firewall | `AzureFirewallThreatIntel` | 365 | Log Analytics (Management) |
| VPN Gateway | `GatewayDiagnosticLog`, `TunnelDiagnosticLog` | 90 | Log Analytics (Management) |
| ExpressRoute Gateway | `GatewayDiagnosticLog`, `PeeringRouteLog` | 90 | Log Analytics (Management) |
| NSG Flow Logs | Flow log version 2 | 90 | Storage Account (Network team) |
| Key Vault | `AuditEvent` | 365 | Log Analytics (Management) |
| Entra ID | Sign-in logs, Audit logs | 90 | Log Analytics (Management) |

Retention requirements align with [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) Control ISM-0988 (minimum 7-year retention for high-value logs archived to cold storage).

<!-- TODO: Define archival policy for logs exceeding Log Analytics retention limits (export to Azure Storage Archive tier) -->

---

## Resource Provider Registration Requirements

The following resource providers MUST be registered on each subscription before workload deployment. Registration is idempotent and is enforced via Azure Policy `DeployIfNotExists` at the relevant management group scope.

<!-- TODO: Validate this list against current subscription templates and remove any providers no longer required -->

| Resource Provider | Required On | Purpose |
|------------------|-------------|---------|
| `Microsoft.Network` | All | Virtual networks, NSGs, load balancers |
| `Microsoft.Compute` | Landing Zones, Platform/Identity | Virtual machines, VM scale sets |
| `Microsoft.KeyVault` | All | Secret and certificate management |
| `Microsoft.OperationalInsights` | Platform/Management | Log Analytics workspaces |
| `Microsoft.Insights` | All | Diagnostic settings, metrics, alerts |
| `Microsoft.Security` | All | Defender for Cloud |
| `Microsoft.Authorization` | All | RBAC, policy assignments |
| `Microsoft.ManagedIdentity` | All | User-assigned managed identities |
| `Microsoft.Storage` | Platform/Management, Landing Zones | Storage accounts for boot diagnostics and state |
| `Microsoft.RecoveryServices` | Landing Zones/Corp | Azure Backup and Site Recovery |

---

## Connectivity Subscription Resources

The Connectivity subscription hosts shared network infrastructure consumed by all landing zones.

<!-- TODO: Add resource names, resource group names, and region configuration once deployment templates are defined -->

| Resource | SKU / Tier | Purpose |
|----------|-----------|---------|
| Hub Virtual Network | Standard | Primary connectivity hub; peering origin for all spokes |
| Azure Firewall | Premium | Centralised north-south and east-west traffic inspection; TLS inspection |
| Firewall Policy | Premium | IDPS rules, TLS inspection policy, application/network rule collections |
| VPN Gateway | VpnGw2AZ (Zone Redundant) | Site-to-site VPN for on-premises or partner connectivity |
| ExpressRoute Gateway | ErGw2AZ (Zone Redundant) | High-bandwidth dedicated on-premises connectivity |
| Azure Bastion | Standard | Secure RDP/SSH to VMs without public IP exposure |
| Azure DDoS Protection | Network Protection | DDoS mitigation for public-facing resources |
| Private DNS Zones | — | Centralised private DNS resolution for PaaS private endpoints |
| Route Table (Hub) | — | UDRs forcing spoke-originated traffic to Azure Firewall |

All gateway resources MUST be deployed zone-redundant where available in the target Azure region.

---

## Related Resources

### Microsoft Documentation

- [Azure landing zone documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Management group overview](https://learn.microsoft.com/en-us/azure/governance/management-groups/overview)
- [Azure Policy overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Azure Firewall Premium features](https://learn.microsoft.com/en-us/azure/firewall/premium-features)
- [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Azure Monitor diagnostic settings](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)

### Australian Security Frameworks

- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
