---
title: "Landing Zone Architecture"
status: "planned"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "explanation"
domain: "infrastructure"
platform: "Azure"
---

# Landing Zone Architecture

This document explains the conceptual architecture underpinning Azure landing zones, covering the [Microsoft Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) hierarchy, subscription design, network topology, identity integration, and governance model. It is understanding-oriented; for configuration values and resource specifications see [Landing Zone Configuration Reference](reference-landing-zone-configuration.md).

---

## Cloud Adoption Framework and Landing Zone Concepts

The [Azure landing zone documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) defines a landing zone as a conceptual architecture that represents scale and maturity across four dimensions: environment, identity, management, and governance. Landing zones are not a single resource — they are a set of Azure subscriptions, management groups, policies, and configurations that form a repeatable, auditable foundation for workload deployment.

The CAF landing zone model addresses two primary concerns:

- **Scale**: the architecture must accommodate growth without requiring architectural rework at each new workload.
- **Governance**: security, compliance, and cost controls must be enforced consistently, regardless of which team deploys a workload.

<!-- TODO: Expand with CAF adoption journey stages (Strategy, Plan, Ready, Adopt, Manage, Govern) and how landing zones fit the Ready phase -->

---

## Management Group Hierarchy Design

Azure management groups provide a governance scope above subscriptions. Policies, RBAC assignments, and diagnostic settings applied at a management group scope are inherited by all subscriptions and resources below it.

The standard CAF-aligned hierarchy uses five levels:

| Level | Name | Purpose |
|-------|------|---------|
| 0 | Tenant Root Group | Auto-created; avoid direct policy assignment here |
| 1 | Intermediate Root (e.g., `Contoso`) | Organisation-wide policies and budgets |
| 2 | Platform | Subscriptions hosting shared platform services |
| 3 | Landing Zones | Subscriptions hosting application workloads |
| 4 | Sandbox | Subscriptions for developer experimentation |

Under the **Platform** management group, three child groups are conventional:

- **Identity**: Active Directory domain controllers, Azure AD Connect, DNS
- **Management**: Log Analytics workspaces, automation accounts, monitoring
- **Connectivity**: Hub virtual networks, firewalls, VPN/ExpressRoute gateways

Under the **Landing Zones** management group, workloads are separated by risk classification:

- **Corp**: Connected workloads requiring access to on-premises or hub network resources
- **Online**: Internet-facing workloads that do not require connectivity to on-premises

A **Decommissioned** management group sits alongside Landing Zones and Platform to hold subscriptions pending cancellation, preventing orphaned resource governance.

<!-- TODO: Add diagram showing full five-level hierarchy with policy inheritance arrows -->

---

## Subscription Organisation Patterns

Each subscription is an Azure billing boundary, an RBAC boundary, and a policy scope. Landing zone design must decide how workloads are distributed across subscriptions.

### Dedicated vs Shared Subscriptions

| Pattern | When to Use | Trade-offs |
|---------|-------------|------------|
| Dedicated per workload | High-value, regulated, or isolated workloads | Higher administrative overhead; cleaner blast radius |
| Shared per environment | Lower-criticality workloads; small teams | Reduced cost; blast radius spans multiple workloads |
| Shared per team | Platform or shared service teams | Resource quotas apply per subscription; monitor limits |

### Workload Isolation

Subscriptions provide a natural isolation boundary for:

- **Resource quotas**: vCPU limits, storage account limits, and public IP limits are enforced per subscription.
- **Cost allocation**: tagging strategies and budgets can be applied at subscription level for precise chargeback.
- **Blast radius containment**: a misconfigured or compromised subscription does not affect resources in sibling subscriptions.
- **Regulatory scope**: subscriptions can be scoped to specific data residency regions or classification tiers.

<!-- TODO: Document subscription naming conventions once organisational standards are confirmed -->

---

## Platform Landing Zone vs Application Landing Zone

The CAF distinguishes two categories:

### Platform Landing Zones

Platform landing zones host shared infrastructure consumed by application landing zones. They are managed centrally by a platform engineering team. Examples:

- Connectivity subscription (hub network, firewall, gateways)
- Identity subscription (domain controllers, certificate services)
- Management subscription (monitoring, patching, automation)

Platform landing zones deploy infrastructure that application teams depend on but should not manage directly. Changes to platform landing zones require change advisory board (CAB) approval and follow platform team governance processes.

### Application Landing Zones

Application landing zones host individual workloads or bounded groups of related services. They receive connectivity, identity, and management services from platform landing zones without owning or operating the underlying infrastructure.

Application teams operate within the guardrails established by the platform team (policies, RBAC, network segmentation) but retain autonomy over their own subscription's resources.

<!-- TODO: Define the platform-to-application handoff model: what the platform team provisions vs what the application team provisions -->

---

## Network Topology Patterns

### Hub-Spoke Topology

In hub-spoke, a central hub virtual network hosts shared network appliances (Azure Firewall, VPN Gateway, ExpressRoute Gateway). Spoke virtual networks are peered to the hub and route traffic through the hub for inspection and egress.

Key characteristics:

- All spoke-to-spoke and spoke-to-on-premises traffic transits the hub firewall
- Spoke virtual networks are isolated from each other by default; communication requires firewall rules
- Network Virtual Appliances (NVAs) or Azure Firewall in the hub enforce east-west and north-south controls
- Hub resources are owned and managed by the connectivity team

Hub-spoke suits organisations that require centralised traffic inspection, have an existing on-premises network connection, or need fine-grained control over inter-spoke communication.

### Azure Virtual WAN

[Azure Virtual WAN](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) is a Microsoft-managed networking service that provides hub-and-spoke connectivity, transitive routing between spokes, and integrated VPN/ExpressRoute without the customer managing individual gateway VMs.

Key characteristics:

- Managed hubs eliminate the need to deploy and patch gateway VMs
- Transitive routing between spokes is built-in (no UDRs required for spoke-to-spoke)
- Integrated with Azure Firewall Manager for policy-based security
- Suited to large-scale or multi-region deployments

<!-- TODO: Document topology selection criteria based on scale, region count, and existing network investment -->

---

## Identity Integration

### Entra ID

Azure landing zones use [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis) as the primary identity plane. All Azure RBAC assignments, Conditional Access policies, and Privileged Identity Management (PIM) roles are anchored to Entra ID identities.

Landing zone governance requires:

- A dedicated break-glass account not subject to Conditional Access, stored in an offline vault
- Emergency access accounts for scenarios where PIM or MFA is unavailable
- Service principals and managed identities used for workload authentication; no shared account passwords for automation

### Hybrid Identity

Organisations with on-premises Active Directory use [Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect) or [Microsoft Entra Cloud Sync](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/what-is-cloud-sync) to synchronise identities. Landing zone design must account for:

- Password hash synchronisation (PHS) vs pass-through authentication (PTA) vs federation
- Staged rollout for hybrid identity migration
- UPN suffix alignment between on-premises AD and Entra ID

### Privileged Access

[Microsoft Entra Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) provides just-in-time (JIT) access for privileged Azure RBAC roles and Entra ID roles. Landing zone governance requires PIM for all Owner, Contributor, and User Access Administrator assignments at management group scope.

<!-- TODO: Define PAW (Privileged Access Workstation) requirements and Tier 0 / Tier 1 / Tier 2 access model -->

---

## Governance: Azure Policy and Management Group-Scoped Controls

[Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) is the primary enforcement mechanism in a landing zone. Policies applied at management group scope cascade to all child subscriptions and resource groups.

Policy effects used in landing zones:

| Effect | Behaviour |
|--------|-----------|
| `Deny` | Prevents non-compliant resource creation or modification |
| `Audit` | Logs non-compliant resources without blocking |
| `DeployIfNotExists` | Deploys a related resource if it does not exist (e.g., diagnostic settings) |
| `Modify` | Adds or modifies tags or properties on existing resources |
| `Append` | Adds fields to a resource request |

Policy initiatives (sets of related policies) are used to enforce baseline controls at each management group level. Examples:

- **Intermediate Root**: require resource locks on critical platform resources; deny resource deployment outside approved Azure regions
- **Platform/Connectivity**: enforce Azure Firewall threat intelligence mode; deny public IP creation except in approved subnets
- **Landing Zones/Corp**: enforce private endpoints for PaaS services; deny public storage account access
- **Landing Zones/Online**: permit limited public ingress; enforce WAF policy on Application Gateway

[Azure Blueprints](https://learn.microsoft.com/en-us/azure/governance/blueprints/overview) (deprecated in favour of Bicep/Terraform + Azure Policy) historically bundled RBAC, policy, and resource group deployments into a versioned artefact. Deployments now favour infrastructure-as-code with policy assignments managed separately.

<!-- TODO: Document the policy initiative library: list approved initiatives, their scope, and justification -->
<!-- TODO: Define the policy exemption process and required approvals -->

---

## Security Baseline

### Microsoft Defender for Cloud

[Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) provides Cloud Security Posture Management (CSPM) and Cloud Workload Protection (CWP) across landing zone subscriptions. Landing zone baseline requirements:

- Defender CSPM enabled on all subscriptions (provides secure score, attack path analysis, cloud security graph)
- Defender plans enabled per workload type: Defender for Servers, Defender for Storage, Defender for SQL, Defender for Key Vault
- Microsoft Cloud Security Benchmark (MCSB) assigned as the default compliance standard
- Auto-provisioning enabled for Log Analytics agent / Azure Monitor Agent on all VMs

Defender for Cloud recommendations are surfaced at management group scope, providing a unified compliance posture across the entire landing zone.

### Microsoft Sentinel Integration

[Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview) is deployed in the management subscription and connected to a centralised Log Analytics workspace. Landing zone subscriptions forward diagnostic logs, activity logs, and Defender alerts to this workspace.

Data connectors relevant to landing zone operations:

- Azure Activity connector (management plane audit logs from all subscriptions)
- Microsoft Defender for Cloud connector (security alerts)
- Entra ID connector (sign-in logs, audit logs)
- Azure Firewall connector (network flow logs)

<!-- TODO: Define data retention requirements per log category and align with ACSC ISM controls for audit log retention -->
<!-- TODO: Document Sentinel analytics rule library and MITRE ATT&CK coverage for landing zone threat scenarios -->

---

## Related Resources

### Microsoft Documentation

- [Microsoft Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Azure landing zone documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Management group overview](https://learn.microsoft.com/en-us/azure/governance/management-groups/overview)
- [Azure Virtual WAN overview](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
- [Microsoft Entra ID fundamentals](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)
- [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Azure Policy overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Microsoft Sentinel overview](https://learn.microsoft.com/en-us/azure/sentinel/overview)

### Australian Security Frameworks

- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
