# Infrastructure & Site Architecture — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Significant Gap to No Equivalent (Architectural Paradigm Shift)

---

## Executive Summary

The transition from SCCM infrastructure to Intune represents a **fundamental architectural paradigm shift** rather than a feature-for-feature migration. SCCM's hierarchical on-premises site model (Central Administration Sites, primary sites, secondary sites, distribution points, and boundary groups) has **no equivalent** in Intune's cloud-native flat architecture. While RBAC capabilities achieve **Full Parity** and content distribution provides **Near Parity** through Microsoft's global CDN, the elimination of site hierarchy and collection-based targeting in favor of Entra ID groups and device filters requires complete operational reconceptualization. Organizations must accept that this is not a gap to be filled but a paradigm shift requiring new mental models, new operational processes, and cultural adaptation from infrastructure ownership to cloud service dependency.

---

## Feature Parity Matrix

| SCCM Feature                                                                                                                             | Intune Equivalent                                               | Parity Rating        | Licensing                                             | Notes                                                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | -------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Site Hierarchy** (CAS, primary sites, secondary sites, database replication, file-based replication)                                   | Single-tenant cloud architecture                                | **No Equivalent**    | Intune Plan 1+                                        | PARADIGM SHIFT: Flat cloud tenant replaces multi-tier site infrastructure. No replication, no site-to-site links, no geographical segmentation via hierarchy.                                                                         |
| **Cloud Management Gateway (CMG)**                                                                                                       | Native internet connectivity                                    | **Full Parity**      | Intune Plan 1+                                        | Intune is cloud-native; all clients managed over internet by default. CMG bridge no longer needed.                                                                                                                                    |
| **Distribution Points** (standard, pull, cloud DPs)                                                                                      | Microsoft CDN + Delivery Optimization                           | **Near Parity**      | Intune Plan 1+                                        | Content delivery via Microsoft's global CDN. Delivery Optimization for peer-to-peer. Loss of granular control over content location and fallback paths.                                                                               |
| **Boundary Groups** (content location, site assignment, fallback relationships)                                                          | Automatic Microsoft CDN routing                                 | **Partial**          | Intune Plan 1+                                        | Content location is cloud-based and automatic. No manual boundary group configuration. Limited control over fallback logic and network optimization.                                                                                  |
| **Device Collections** (query-based, direct membership, include/exclude, limiting collections, incremental updates, maintenance windows) | Entra ID dynamic groups + device filters                        | **Near Parity**      | Intune Plan 1+ (Entra ID P1 for dynamic groups)       | Dynamic groups replicate query-based collections. Device filters provide policy-time targeting. **No native maintenance windows** (use deployment rings/policy scheduling instead). Query language shift from WQL to Entra ID syntax. |
| **User Collections**                                                                                                                     | Entra ID user groups (dynamic/assigned)                         | **Full Parity**      | Intune Plan 1+ (Entra ID P1 for dynamic)              | User groups function equivalently to user collections. Dynamic groups use Entra ID query syntax.                                                                                                                                      |
| **RBAC — Built-in Security Roles** (17+ roles in SCCM)                                                                                   | Intune RBAC — 30+ built-in roles                                | **Full Parity**      | Intune Plan 1+                                        | Comprehensive built-in roles with granular permissions. Intune provides more built-in roles than SCCM.                                                                                                                                |
| **RBAC — Custom Security Roles**                                                                                                         | Intune custom roles                                             | **Full Parity**      | Intune Plan 1+                                        | Full custom role creation with granular permission selection (read, create, delete, update, assign per resource type).                                                                                                                |
| **RBAC — Security Scopes**                                                                                                               | Scope tags                                                      | **Full Parity**      | Intune Plan 1+                                        | Scope tags provide equivalent resource isolation. Tag resources (policies, apps, devices, groups) and assign tags to admin roles.                                                                                                     |
| **RBAC — Collection-Based Permissions**                                                                                                  | Entra ID administrative units + scope tags                      | **Near Parity**      | Intune Plan 1+ (Entra ID P1 for administrative units) | Administrative units in Entra ID combined with scope tags provide collection-based access control equivalent.                                                                                                                         |
| **Site Maintenance Tasks** (backup site server, delete aged discovery data, rebuild indexes, etc.)                                       | Automatic cloud service maintenance                             | **Intune Advantage** | Intune Plan 1+                                        | Microsoft manages all backend maintenance. No admin intervention required. No maintenance windows to schedule.                                                                                                                        |
| **Content Library Management**                                                                                                           | Automatic cloud storage                                         | **Intune Advantage** | Intune Plan 1+                                        | No content library to manage, no disk space monitoring, no content validation tasks. Cloud storage is automatic and infinite.                                                                                                         |
| **High Availability** (passive site server, SQL Always On, site server HA)                                                               | Azure cloud SLA (99.9%+)                                        | **Intune Advantage** | Intune Plan 1+                                        | Cloud service HA is built-in with Azure's multi-region redundancy. No on-premises HA infrastructure needed.                                                                                                                           |
| **Site Recovery** (backup/restore procedures, site recovery wizard)                                                                      | N/A (cloud service resilience managed by Microsoft)             | **Intune Advantage** | Intune Plan 1+                                        | Microsoft manages disaster recovery and business continuity. No site recovery procedures needed.                                                                                                                                      |
| **Configuration Backup** (site server backup task)                                                                                       | Configuration backup via Graph API / IntuneCD / Microsoft365DSC | **Near Parity**      | Intune Plan 1+                                        | No site backup needed. **Configuration** can be backed up via PowerShell (IntuneBackupAndRestore), Python (IntuneCD), or Graph API exports.                                                                                           |
| **Service Health Monitoring** (alerts, status messages, status system)                                                                   | Intune service health + Graph activity logs + audit logs        | **Full Parity**      | Intune Plan 1+                                        | Service health monitoring dashboard, audit logs via Graph API, and comprehensive activity logging provide equivalent monitoring.                                                                                                      |
| **Multi-Tenant Management**                                                                                                              | Microsoft 365 Lighthouse (MSPs)                                 | **Partial**          | Lighthouse requires CSP relationship                  | Lighthouse provides multi-tenant views for MSPs. Not applicable for single-org multi-tenant scenarios (use separate admin access per tenant).                                                                                         |
| **Tenant Attach** (ConfigMgr devices in Intune console)                                                                                  | Native Intune enrollment                                        | **N/A**              | Intune Plan 1+                                        | Tenant attach is a co-management bridge feature. In pure Intune, devices enroll natively via Autopilot, GPO, or manual enrollment.                                                                                                    |

---

## Key Findings

### Full/Near Parity Areas

#### RBAC: Full Functional Equivalence

Intune's RBAC model achieves **Full Parity** with SCCM across all dimensions:

**Built-in Roles**: Intune provides 30+ built-in roles compared to SCCM's 17+, including specialized roles such as:

- **Policy and Profile Manager** (equivalent to SCCM Application Administrator)
- **Endpoint Security Manager** (focused on security policies)
- **Cloud PC Administrator** (Windows 365 management)
- **Read Only Operator** (equivalent to SCCM Read-only Analyst)
- **Help Desk Operator** (remote actions only, no configuration changes)

**Custom Roles**: Full custom role creation with granular permissions across all resource types. Permissions are organized by resource category (Device configurations, Apps, Managed devices, Mobile apps, etc.) with individual read/create/delete/update/assign permissions per category.

**Scope Tags**: Directly equivalent to SCCM security scopes. Tag resources during creation, assign scope tags to admin roles, and admins can only see/manage resources with matching tags. Critical for multi-regional or multi-business-unit organizations.

**Administrative Units** (Entra ID): Provide user/device-based scope restrictions equivalent to collection-based permissions. For example, restrict a helpdesk admin to only manage devices in the "Chicago" administrative unit.

**Migration Path**: Map existing SCCM security roles to Intune built-in roles, migrate security scopes 1:1 to scope tags, and recreate collection-based permissions using administrative units. No capability loss.

#### User Collections → User Groups: Full Parity

**Entra ID user groups** (dynamic or assigned) provide full equivalent functionality to SCCM user collections:

- **Dynamic groups** = query-based collections (evaluated automatically by Entra ID, typically within minutes)
- **Assigned groups** = direct membership collections
- **Nested groups** supported for hierarchy (though expansion logic differs from SCCM include/exclude)
- **Group-based licensing** for automatic Intune license assignment

**Query Language Shift**: Dynamic groups use Entra ID query syntax instead of WQL. Example comparison:

**SCCM WQL**:

```sql
select SMS_R_USER.ResourceID from SMS_R_User
where SMS_R_User.UserGroupName = "CONTOSO\\Sales"
```

**Entra ID Dynamic Group**:

```
user.department -eq "Sales"
```

The capability is equivalent, but admins must learn the new query syntax. See [Microsoft Learn: Dynamic membership rules for groups in Azure Active Directory](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership) for syntax reference.

#### Content Distribution: Near Parity with Cloud Trade-offs

**Microsoft CDN** replaces distribution points with global cloud infrastructure:

- **Automatic routing**: Clients automatically connect to nearest CDN edge server (100+ locations globally)
- **Delivery Optimization**: Peer-to-peer content sharing replaces BranchCache for local network optimization
- **No capacity planning**: Infinite cloud storage eliminates disk space monitoring and content library management
- **No distribution point installation**: Zero infrastructure deployment for content delivery

**Trade-offs**:

- **Loss of granular control**: Cannot define specific content locations, fallback relationships, or network boundaries
- **Internet dependency**: Content delivery requires internet connectivity (no offline distribution point scenarios)
- **Bandwidth considerations**: Organizations with bandwidth constraints must rely on Delivery Optimization peer-to-peer (cannot force local DP usage)

**Parity Rating**: **Near Parity** overall. Content is delivered efficiently and reliably, but organizations accustomed to precise control over content distribution paths may experience operational adjustment.

### Partial Parity / Gaps

#### Device Collections → Groups/Filters: Operational Reconceptualization Required

The shift from SCCM device collections to Entra ID groups + Intune device filters represents **Near Parity** in capability but **significant operational change**:

**What Translates Well**:

- **Query-based collections** → **Dynamic groups** (Entra ID evaluates membership automatically)
- **Direct membership** → **Assigned/static groups** (manual device addition)
- **Limiting collections** → **Scope tags** (restrict which devices admins can target)

**What Requires New Approaches**:

1. **Maintenance Windows**: No native equivalent in Intune. **Workaround**: Use deployment rings with scheduled rollout phases, policy scheduling options, and gradual rollout controls. For update maintenance windows, use Windows Update for Business update rings with specific deployment schedules.

2. **Include/Exclude Collection Logic**: Entra ID group nesting works differently. **Workaround**: Use complex dynamic group rules or device filters to achieve similar targeting. Example: Instead of "All Windows 10 Workstations" exclude "VIP Devices" collection, use device filter: `(device.osVersion -startsWith "10.0") -and (device.deviceOwnership -ne "VIP")` or create separate dynamic group with exclusion logic in the query.

3. **Incremental Updates**: SCCM's incremental update feature (immediate membership updates on inventory changes) has no direct control in Intune. Entra ID dynamic groups update automatically (typically within minutes), but timing cannot be forced. Device filters evaluate at policy-deployment time (real-time).

4. **Query Language Migration**: WQL → Entra ID query syntax requires rewriting all collection queries. Common property mappings:
   - `SMS_R_System.OperatingSystemNameandVersion` → `device.deviceOSType` + `device.deviceOSVersion`
   - `SMS_R_System.ResourceDomainORWorkgroup` → `device.deviceTrustType`
   - `SMS_G_System_COMPUTER_SYSTEM.Manufacturer` → `device.manufacturer` (via device filters, not Entra ID groups)
   - `SMS_R_System.LastLogonUserName` → `device.enrolledDateTime` or `device.userPrincipalName` (different property model)

**Device Filters: The Operational Game-Changer**

Device filters (introduced in Intune) provide policy-time targeting **without changing group membership**. This is a capability SCCM collections do not have. Example use case:

**Scenario**: Deploy an application to "All Sales Users" but exclude devices with less than 10GB free disk space.

**SCCM approach**:

- Create collection "Sales Users - Sufficient Disk Space" with complex query combining user department + disk space
- Deployment targets this collection
- Collection membership must reevaluate on schedule

**Intune approach**:

- Assign app to Entra ID group "Sales Users" (simple dynamic group: `user.department -eq "Sales"`)
- Apply device filter on assignment: `(device.freeStorageSpaceInBytes -ge 10737418240)` (exclude)
- Filter evaluates at deployment time without changing group membership

**Migration Consideration**: Maintenance windows are the most commonly cited gap. Organizations must shift from "deploy to collection with maintenance window" to "deploy to group with deployment ring schedule and gradual rollout controls." This requires process change and operational retraining, but achieves similar outcomes.

#### Boundary Groups: Limited Control in Cloud Model

**SCCM Boundary Groups** provided precise control over:

- Which distribution points clients use based on network location (IP subnet, AD site, VPN connection)
- Fallback relationships (if local DP unavailable, fall back to regional DP after X minutes)
- Site assignment (which primary site manages the client)
- Preferred management points

**Intune**: All content distribution is automatic via Microsoft CDN. Clients connect to the nearest CDN edge server based on internet routing (anycast). **No configuration options** for content location preferences or fallback relationships.

**Partial Parity Justification**: Content is delivered efficiently and globally, but organizations lose the ability to:

- Force clients to use specific content sources (e.g., "always use local DP before going to internet")
- Define fallback timing (boundary groups allowed custom fallback delays)
- Control bandwidth usage via distribution point throttling (Delivery Optimization provides peer-to-peer, but not DP-level throttling)

**Workaround**: Use **Delivery Optimization** settings to control peer-to-peer behavior and bandwidth limits:

- Delivery Optimization group IDs (create logical groups of devices for peer sharing within site/building)
- Bandwidth throttling (limit download bandwidth from Microsoft CDN)
- Download mode settings (prefer peers from same domain, LAN only, etc.)

For disconnected or bandwidth-constrained environments, this is a **Significant Gap**. Consider retaining SCCM distribution points via co-management for scenarios requiring offline content access.

### Significant Gaps / No Equivalent

#### Site Hierarchy: The Fundamental Architectural Difference

**SCCM Site Hierarchy** was designed for an era of on-premises networks with controlled WAN links. The architecture supported:

- **Central Administration Site (CAS)**: Top-level aggregation point for multi-primary-site deployments (global view, global reporting, global collections)
- **Primary Sites**: Full-featured management sites (database, management point, distribution point, reporting point)
- **Secondary Sites**: Simplified remote-office sites (no SQL Server, content caching only)
- **Database Replication**: Global data (collections, packages, task sequences) replicated from CAS to primary sites; site data (inventory, status messages) replicated from primaries to CAS
- **File-Based Replication**: Content (applications, packages, OS images) replicated between sites via compressed DRS (Data Replication Service) or BITS

This architecture enabled:

- **Geographical segmentation**: "APAC Primary Site" vs. "EMEA Primary Site" with regional control
- **WAN optimization**: Replicate content once to regional primary site, distribute locally via DPs in that site's boundary groups
- **Organizational segmentation**: Separate primary sites for different business units with centralized CAS oversight

**Intune Architecture**: Single flat cloud tenant. All devices connect directly to the Intune service via HTTPS (port 443). No hierarchy, no sites, no replication.

**Impact**:

- **Multi-site SCCM deployments collapse to single tenant**. Organizations with complex hierarchies (1 CAS + 5 primary sites + 20 secondary sites) transition to a single Intune tenant.
- **Geographical segmentation** must be achieved via separate tenants (e.g., "Contoso-APAC" tenant vs. "Contoso-EMEA" tenant) if required for regulatory/political reasons. This introduces multi-tenant management complexity (separate admin access, no cross-tenant reporting, no unified console).
- **Network optimization** shifts from site topology to internet routing and Delivery Optimization peer-to-peer. Organizations cannot "replicate to regional site" and then distribute locally—all content comes from Microsoft CDN.

**Parity Rating**: **No Equivalent**. This is not a gap to be remediated—it is an architectural paradigm shift. Organizations must accept the flat cloud model and eliminate site planning from their operational vocabulary.

**Migration Recommendation**:

1. **Single-tenant consolidation**: Collapse all SCCM sites to a single Intune tenant unless regulatory/political requirements mandate separation.
2. **Geographical optimization**: Rely on Microsoft's global CDN (100+ edge locations) for content delivery. Use Delivery Optimization group IDs to create logical peer groups within sites/buildings.
3. **Organizational segmentation**: Use scope tags (not separate tenants) to segment management by business unit, region, or department within a single tenant.

#### Configuration Backup: Infrastructure vs. Configuration

**SCCM Backup Task**: The built-in "Backup Site Server" maintenance task backed up:

- Site database (SQL backup)
- CD.Latest folder (site installation source files matching current version)
- Site server registry keys and certificates
- Content library metadata

This was **infrastructure backup** designed for disaster recovery (rebuild site server from backup after hardware failure).

**Intune**: Microsoft manages all backend infrastructure. There is no site server to back up, no SQL database under customer control, and no infrastructure recovery procedures.

**Configuration Backup** (not infrastructure backup) is possible via:

1. **IntuneBackupAndRestore** (PowerShell module by John Seerden):
   - Exports all Intune configurations to JSON files via Graph API
   - Supports backup/restore of policies, profiles, apps, compliance policies, etc.
   - GitHub: [jseerden/IntuneBackupAndRestore](https://github.com/jseerden/IntuneBackupAndRestore)

2. **IntuneCD** (Python-based tool by Almenscorner):
   - Configuration-as-code for Intune (backup, document, update, version control)
   - Exports configurations as JSON, stores in Git, enables CI/CD pipelines
   - GitHub: [almenscorner/IntuneCD](https://github.com/almenscorner/IntuneCD)

3. **Microsoft365DSC** (PowerShell DSC resources):
   - Declarative configuration management for entire M365 tenant (including Intune)
   - Export current state to DSC configuration file, version control, redeploy via DSC
   - GitHub: [microsoft/Microsoft365DSC](https://github.com/microsoft/Microsoft365DSC)

4. **Graph API Manual Export**:
   - Script custom backup via Graph API calls (export all policies, apps, profiles as JSON)
   - Store in Azure DevOps, GitHub, or SharePoint for version control

**Parity Rating**: **Near Parity**. The **capability** (protect against configuration loss, restore after accidental deletion) is fully covered. The **operational model** is different (configuration backup, not infrastructure backup). Organizations must adopt configuration-as-code practices instead of traditional backup/restore workflows.

**Migration Recommendation**: Implement IntuneCD or Microsoft365DSC as part of Intune deployment. Store configurations in Git repository with change history and CI/CD pipeline for automated deployment. This provides superior version control and auditability compared to SCCM backup tasks.

### Intune Advantages

#### Cloud Infrastructure Management: Zero Operational Overhead

Intune eliminates the entire operational burden of infrastructure management:

**What Microsoft Manages**:

- **High availability**: Multi-region Azure infrastructure with automatic failover
- **Disaster recovery**: Microsoft's business continuity processes (no customer action required)
- **Patching**: Backend service updates deployed automatically (no maintenance windows, no site upgrades)
- **Capacity planning**: Infinite cloud scale (no server sizing, no database growth monitoring)
- **Performance tuning**: Azure infrastructure optimization managed by Microsoft
- **Security**: Infrastructure security, compliance certifications, threat monitoring

**What Organizations Eliminate**:

- Site server hardware procurement and lifecycle management
- SQL Server licensing, installation, patching, Always On configuration
- Management point/distribution point server builds
- Site-to-site replication monitoring and troubleshooting
- Content library disk space alerts
- Backup job failures and tape rotation
- Disaster recovery testing and runbooks

**Operational Impact**: Organizations shift from **infrastructure ownership** (you manage servers, databases, network, HA) to **cloud service consumption** (Microsoft manages infrastructure, you manage configuration). This is a profound cultural shift requiring trust in Microsoft's operational excellence.

**Financial Impact**: Eliminate:

- Windows Server licenses for site systems
- SQL Server licenses for site database
- Hardware costs (physical or virtual machine compute/storage)
- Backup infrastructure (backup software, storage, tape libraries)
- Datacenter costs (power, cooling, rack space)

Offset by Intune licensing costs ($8/user/month for Plan 1), but total cost of ownership typically decreases, especially for organizations with distributed SCCM hierarchies.

#### Automatic Cloud Maintenance: No "Maintenance Mode" Required

**SCCM Maintenance Tasks**: 30+ built-in maintenance tasks running on schedule:

- Delete Aged Discovery Data
- Delete Aged Inventory History
- Delete Aged Status Messages
- Rebuild Indexes
- Update Application Catalog Tables
- Summarize Installed Software Data
- Backup Site Server

Each task required configuration, monitoring, and occasional troubleshooting (failed index rebuilds, backup failures, etc.).

**Intune**: All backend maintenance is automatic and invisible. Microsoft manages:

- Data retention policies (audit logs retained per Microsoft policy)
- Database index optimization
- Storage cleanup
- Performance optimization

**Operational Advantage**: Zero administrative overhead for maintenance tasks. No maintenance window planning, no monitoring maintenance task failures, no troubleshooting stuck SQL jobs.

#### Service Health Transparency: Real-Time Global Visibility

**SCCM Monitoring**: On-premises monitoring stack:

- Status message queries for component errors
- Site system health in Monitoring workspace
- SQL Server monitoring (manually configured)
- Custom alerts for critical failures
- Log file analysis (CMTrace reviewing 50+ log files)

**Intune Service Health**: Cloud service health dashboard in Microsoft 365 admin center:

- **Service Health** dashboard: Real-time global service status (incidents, advisories)
- **Message Center**: Advance notice of planned changes and new features
- **Audit Logs**: Comprehensive activity logging via Graph API (who changed what, when)
- **Service Level Agreement**: 99.9% uptime guarantee with financial credits for SLA violations

**Advantage**: Global visibility into service status across all Microsoft 365 services (Intune, Entra ID, Exchange, SharePoint, Teams). Microsoft provides proactive communication about incidents, planned maintenance, and upcoming changes. Organizations no longer need to troubleshoot "is this a site server issue or a client issue?"—if Intune has an issue, Microsoft's global status page shows it.

---

## Paradigm Shift: Architectural Reconceptualization

The SCCM-to-Intune infrastructure transition is not a feature migration—it is a **paradigm shift** requiring operational reconceptualization across multiple dimensions.

### From Hierarchical to Flat: The Topology Transformation

**SCCM Mental Model**: Multi-tier hierarchy with sites, replication, and geographical distribution.

**Operational Concepts**:

- "We have a CAS in our datacenter and primary sites in each region (Americas, EMEA, APAC)"
- "The Chicago secondary site is a remote office with 500 devices and a local DP"
- "Collections limit to the EMEA site's devices for our European admins"
- "We replicate content from CAS to primaries, then distribute to DPs in boundary groups"

**Intune Mental Model**: Single flat cloud tenant with global CDN distribution.

**New Operational Concepts**:

- "We have one Intune tenant for the global organization"
- "The Chicago office devices are in a dynamic group 'Chicago Devices' and use Delivery Optimization for local peer-to-peer caching"
- "Scope tags restrict European admins to resources tagged 'EMEA'"
- "Content deploys to all devices via Microsoft CDN with automatic routing to nearest edge server"

**Cultural Shift**: "Site planning" disappears from the operational vocabulary. Organizations must trust Microsoft's global infrastructure instead of designing their own geographical topology.

### From Collections to Groups/Filters: The Targeting Transformation

**SCCM Mental Model**: Collections are central to everything. Create query-based collections for every targeting scenario. Collections have maintenance windows, limiting collections, include/exclude logic, and incremental updates.

**Operational Concepts**:

- "Create collection 'Windows 10 Workstations - Sales - Patch Tuesday 2AM' with WQL query, limiting collection, and maintenance window"
- "Deployment targets a collection; collection membership determines who gets it"
- "Incremental updates ensure new devices get deployments immediately"

**Intune Mental Model**: Entra ID groups define membership; device filters provide additional targeting without group changes; deployment rings control rollout timing.

**New Operational Concepts**:

- "Assign policy to Entra ID dynamic group 'Sales Users' (simple membership rule); apply device filter 'Windows 10 Enterprise only' (exclude Windows 10 Home); configure deployment ring with gradual rollout starting Tuesday 2AM (5% immediate, 10% after 1 day, 50% after 3 days, 100% after 7 days)"
- "Assignment targets a group; filters refine at policy time; deployment rings control timing"
- "Dynamic group membership updates automatically within minutes"

**Cultural Shift**: Maintenance windows → Deployment rings. Include/exclude collections → Device filters. WQL queries → Entra ID query syntax. Collections as "containers for devices" → Groups as "membership definitions" + filters as "policy-time refinement."

### From WMI to Graph: The API Transformation

**SCCM Mental Model**: WMI classes in SMS namespace, queried via WQL, accessed via on-premises SMS Provider.

**Operational Concepts**:

- "Query SMS_R_System to get device inventory"
- "Use ConfigurationManager PowerShell module connected to site server"
- "WMI is Windows-only; automation requires Windows Server with ConfigMgr console installed"

**Intune Mental Model**: RESTful Graph API, queried via OData, accessed via OAuth-authenticated HTTPS.

**New Operational Concepts**:

- "Query `https://graph.microsoft.com/v1.0/deviceManagement/managedDevices` to get device inventory"
- "Use Microsoft.Graph PowerShell SDK with OAuth app registration (client ID/secret) or delegated auth (user credentials)"
- "Graph API is cross-platform; automation runs from Windows, Linux, macOS, or cloud (Azure Automation, GitHub Actions)"

**Cultural Shift**: Windows-centric WMI → Cross-platform REST API. On-premises SMS Provider → Cloud OAuth authentication. WQL queries → OData `$filter` queries. Single API (Graph) for Intune + Entra ID + M365 services instead of separate APIs per product.

### From Infrastructure Ownership to Cloud SLA Dependency

**SCCM Mental Model**: IT owns the infrastructure. If site server fails, IT fixes it. If SQL database crashes, IT restores it. If replication breaks, IT troubleshoots it.

**Operational Concepts**:

- "We built site server HA with passive site server failover"
- "SQL Always On provides database redundancy"
- "We have disaster recovery runbooks for site recovery"
- "We monitor site system health and respond to alerts"

**Intune Mental Model**: Microsoft owns the infrastructure. If service fails, Microsoft fixes it. If outage occurs, Microsoft communicates via Service Health dashboard.

**New Operational Concepts**:

- "Azure provides built-in HA; we don't configure failover"
- "Microsoft manages backend databases; we don't see them"
- "We rely on Microsoft's SLA (99.9% uptime); we monitor Service Health dashboard, not site servers"
- "We focus on configuration management, not infrastructure management"

**Cultural Shift**: Control → Trust. Infrastructure ownership → Configuration ownership. Troubleshooting site systems → Monitoring service health. Disaster recovery planning → Microsoft's responsibility.

### From On-Premises Control to Internet Dependency

**SCCM Mental Model**: Intranet-first architecture. Clients on corporate network communicate with on-premises site systems. Internet clients use CMG or VPN.

**Operational Concepts**:

- "Internal clients connect to on-premises management point"
- "VPN required for remote workers to get software deployments"
- "CMG is optional for internet-based management"

**Intune Mental Model**: Internet-first architecture. All clients communicate directly with Intune cloud service over HTTPS.

**New Operational Concepts**:

- "All clients connect to Intune service via internet (no VPN required)"
- "Intune is internet-only; no intranet connectivity mode"
- "Network requirements: HTTPS outbound to `*.manage.microsoft.com`, `*.windows.net`, and Microsoft CDN domains"

**Cultural Shift**: VPN for remote workers → No VPN needed (cloud-native). CMG deployment for internet clients → All clients are internet clients. Firewall rules for intranet → Firewall rules for outbound HTTPS to Microsoft cloud.

---

## Licensing Impact

The infrastructure capabilities assessed in this document are distributed across multiple licensing tiers. See the **Licensing Impact Register** for consolidated analysis.

### Capabilities Included in Intune Plan 1 (M365 E3)

All core infrastructure capabilities are included in **Intune Plan 1**, which is bundled in **Microsoft 365 E3**:

- Cloud tenant architecture (no additional cost for cloud hosting)
- Scope tags (RBAC resource isolation)
- Built-in and custom RBAC roles
- Device filters
- Microsoft CDN content delivery
- Delivery Optimization
- Service health monitoring
- Audit logs via Graph API
- Configuration backup via Graph API

### Capabilities Requiring Entra ID P1 (Included in M365 E3)

| Feature                                                        | License Required | Included In                 | Impact                                                                                          |
| -------------------------------------------------------------- | ---------------- | --------------------------- | ----------------------------------------------------------------------------------------------- |
| **Dynamic groups** (query-based membership)                    | Entra ID P1      | M365 E3, M365 E5, EMS E3/E5 | Required to replicate SCCM query-based collections without manual group maintenance.            |
| **Administrative units** (scope user/device access for admins) | Entra ID P1      | M365 E3, M365 E5, EMS E3/E5 | Required for collection-based RBAC equivalent (restrict admin scope to specific users/devices). |

**Note**: Entra ID P1 is included in Microsoft 365 E3 at no additional cost. Organizations with M365 E3 licensing have full access to dynamic groups and administrative units.

### Capabilities Requiring Intune Suite (Included in M365 E3/E5 from July 2026)

| Feature                                          | License Before July 2026      | License After July 2026 | Impact                                                                                                                       |
| ------------------------------------------------ | ----------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Cloud PKI** (certificate lifecycle management) | Intune Suite ($10/user/month) | Included in M365 E5     | Replaces on-premises PKI for device certificates. Organizations with complex certificate requirements benefit significantly. |

**July 2026 Licensing Changes**: Microsoft is integrating Intune Suite features into M365 E3 and E5 licensing with a $3/user/month price increase. Cloud PKI moves to M365 E5. See [Intune Suite Is Included in E3/E5 Starting July 2026](https://sra.io/blog/intune-suite-is-included-in-e3-e5-starting-july-2026/) for details.

### No Additional Licensing Required

The following capabilities have **no Intune licensing gates** beyond base Intune Plan 1:

- Flat cloud architecture (single tenant)
- Microsoft CDN content delivery (bandwidth included)
- Azure cloud HA (99.9% SLA included)
- Automatic cloud maintenance
- Service health monitoring

---

## Migration Considerations

### Planning the Transition

#### 1. Accept the Paradigm Shift

**Critical Success Factor**: Leadership and IT teams must understand this is not a "lift-and-shift" migration but an **architectural transformation**. Invest in change management, training, and cultural readiness.

**Recommended Actions**:

- Executive briefing: "SCCM site hierarchy has no Intune equivalent—this is a paradigm shift from on-premises to cloud"
- Technical training: Entra ID groups, device filters, Graph API, deployment rings (not maintenance windows)
- Pilot program: Deploy Intune to 5-10% of devices to validate new operational processes before full migration

#### 2. Inventory Site Infrastructure and Targeting Model

**Assessment Checklist**:

- [ ] Document site hierarchy (CAS, primaries, secondaries) → Consolidate to single tenant
- [ ] Inventory device collections (query-based vs. direct membership) → Map to dynamic groups vs. assigned groups
- [ ] Identify collections with maintenance windows → Redesign as deployment rings with gradual rollout
- [ ] Document RBAC (security roles, scopes, collection permissions) → Map to Intune roles + scope tags + administrative units
- [ ] Inventory boundary groups and distribution points → Accept Microsoft CDN + plan Delivery Optimization group IDs

#### 3. Retrain Admins on New Mental Models

**Collection → Group/Filter Training**:

- WQL to Entra ID query syntax translation workshop
- Device filter hands-on lab (create filters for OS version, disk space, manufacturer)
- Deployment rings configuration (gradual rollout timing and percentage phases)

**WMI → Graph API Training**:

- Graph API fundamentals (OAuth authentication, REST API concepts, OData queries)
- Microsoft.Graph PowerShell SDK hands-on exercises
- Graph Explorer interactive API browser training

**Infrastructure → Cloud Training**:

- Service health dashboard monitoring
- Configuration-as-code with IntuneCD or Microsoft365DSC
- Delivery Optimization group IDs and bandwidth management

#### 4. Redesign Targeting and Deployment Processes

**Maintenance Window Replacement**:

**SCCM Process**:

1. Create collection "Patch Group 1 - Tuesday 2AM"
2. Set maintenance window on collection (Tuesday 2:00 AM - 4:00 AM)
3. Deploy updates to collection; SCCM enforces window

**Intune Process**:

1. Create Entra ID dynamic group "Patch Group 1" (based on department, device type, or custom device property)
2. Create Windows Update for Business update ring:
   - Deployment ring 1 (Patch Group 1): Quality updates 3 days after release, installation deadline 2 days, restart deadline 3 days, schedule specific restart time (Tuesday 2:00 AM)
3. Assign update ring to group; devices install updates on defined schedule

**Result**: Similar enforcement (updates install at specific time), different mechanism (deployment ring schedule, not collection maintenance window).

#### 5. Plan Content Distribution Optimization

**For Well-Connected Environments**:

- Accept Microsoft CDN default behavior (automatic routing to nearest edge server)
- Configure Delivery Optimization for peer-to-peer caching within sites/buildings (use DO group IDs)

**For Bandwidth-Constrained Environments**:

- Configure Delivery Optimization bandwidth limits (percentage or absolute limits)
- Use Delivery Optimization group IDs to create peer groups within buildings/sites (devices download from Microsoft CDN once, share locally)
- For extremely constrained or disconnected sites, consider **retaining SCCM distribution points via co-management** during transition period

**For Disconnected Environments** (no internet access):

- **Significant Gap**: Intune requires internet connectivity for management. Truly disconnected devices cannot be managed via Intune.
- **Mitigation**: Retain SCCM for disconnected devices, or establish internet connectivity (dedicated internet circuit, firewall rules for Intune endpoints)

#### 6. Implement Configuration-as-Code

Adopt configuration backup and version control practices:

**Option 1: IntuneCD** (Python-based, recommended for multi-platform environments):

- Install IntuneCD: `pip install IntuneCD`
- Export current Intune configuration: `IntuneCD-startbackup --mode=1 --output=./backup`
- Store in Git repository (Azure DevOps, GitHub)
- Implement CI/CD pipeline for deployment (update Git → pipeline deploys to Intune)

**Option 2: Microsoft365DSC** (PowerShell-based, recommended for Windows-centric environments):

- Install Microsoft365DSC: `Install-Module Microsoft365DSC`
- Export configuration: `Export-M365DSCConfiguration -Components @("IntuneDeviceConfiguration", "IntuneDeviceCompliance", ...)`
- Store exported `.ps1` configuration in Git
- Apply configuration via DSC: `Start-DscConfiguration -Path ./M365Config`

**Option 3: Manual Graph API Export** (custom scripting):

- Script Graph API calls to export all policies, profiles, apps as JSON
- Store in Git or SharePoint document library
- Version control via Git commit history

**Benefit**: Automated disaster recovery (redeploy from code), change tracking (Git history shows who changed what), cross-tenant deployments (export from production, deploy to UAT tenant).

#### 7. Plan RBAC Migration

**Mapping Exercise**:

| SCCM Security Role        | Intune Equivalent                                            | Notes                                                             |
| ------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------- |
| Full Administrator        | Intune Administrator (Entra ID global admin for full access) | Full access to all Intune resources                               |
| Application Administrator | Application Manager                                          | Manage apps, app configurations, app protection policies          |
| Operations Administrator  | Endpoint Security Manager                                    | Manage security policies, compliance, Defender integration        |
| Read-only Analyst         | Read Only Operator                                           | Read-only access to all Intune data                               |
| Help Desk Operator        | Help Desk Operator                                           | Remote actions (restart, wipe, etc.) but no configuration changes |

**Scope Tag Migration**:

- SCCM security scope "Scope_Chicago" → Intune scope tag "Chicago"
- Tag all Chicago-related resources (policies, apps, devices) with "Chicago" tag
- Assign "Chicago" scope tag to Chicago admin roles

**Collection-Based Permission Migration**:

- SCCM: "Helpdesk role can only manage devices in 'Chicago Devices' collection"
- Intune: Create Entra ID administrative unit "Chicago Devices" (add Chicago devices), assign helpdesk admin role scoped to "Chicago Devices" administrative unit

### Risk Assessment

| Risk                                                              | Severity | Mitigation                                                                                                                  |
| ----------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Operational disruption during transition**                      | High     | Implement co-management gradual transition (retain SCCM during migration, move workloads one at a time)                     |
| **Admin knowledge gap (WQL → Entra ID queries, WMI → Graph API)** | High     | Invest in comprehensive training 3-6 months before migration; create query translation reference guides                     |
| **Loss of maintenance windows for critical systems**              | Medium   | Redesign as deployment rings with scheduled installation times; pilot with non-critical systems first                       |
| **Bandwidth constraints in remote offices**                       | Medium   | Configure Delivery Optimization bandwidth limits and group IDs; consider retaining SCCM DPs for extremely constrained sites |
| **Disconnected/air-gapped devices**                               | High     | Retain SCCM for disconnected devices (Intune cannot manage devices without internet) or establish internet connectivity     |
| **Multi-tenant requirement (regulatory/political separation)**    | Medium   | Plan multi-tenant architecture (separate Intune tenants for regions); accept loss of unified management console             |

### Recommended Transition Sequence

**Phase 1: Foundation (Months 1-3)**

- License verification (M365 E3 minimum for Entra ID P1 dynamic groups)
- Pilot Intune tenant setup and configuration
- Admin training (Entra ID groups, device filters, Graph API)
- RBAC design (map SCCM roles to Intune roles, define scope tags)

**Phase 2: Targeting Model Migration (Months 2-4)**

- Translate SCCM collections to Entra ID dynamic groups
- Create device filters for common targeting scenarios
- Redesign maintenance windows as deployment rings
- Pilot deployments to test groups (validate targeting accuracy)

**Phase 3: Co-Management Enablement (Months 3-5)**

- Enable co-management for pilot devices
- Move compliance policies workload to Intune (low risk, easy validation)
- Move resource access policies workload to Intune (required for ConfigMgr 2403+)
- Validate workload transitions with pilot group before expanding

**Phase 4: Gradual Workload Transition (Months 4-12)**

- Move Windows Update policies workload
- Move endpoint protection workload
- Move device configuration workload
- Move client apps workload (final workload)
- Expand pilot to 10% → 25% → 50% → 100% of devices per workload

**Phase 5: SCCM Decommission (Months 12-18)**

- All devices fully managed by Intune
- Disable co-management
- Retain SCCM for final 3-6 months (insurance policy)
- Decommission SCCM infrastructure (site servers, SQL databases, DPs)
- Celebrate infrastructure elimination and operational simplification

**Critical Success Factor**: Do not rush. Organizations with complex SCCM deployments should plan 12-18 months for full transition. Co-management provides safety net (retain SCCM while learning Intune).

---

## Sources

### Official Microsoft Documentation

- [Design a site hierarchy - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/core/plan-design/hierarchy/design-a-hierarchy-of-sites)
- [Fundamentals of sites and hierarchies - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/core/understand/fundamentals-of-sites-and-hierarchies)
- [Boundary groups and distribution points - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/deploy/configure/boundary-groups-distribution-points)
- [Categorize devices into groups in Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-group-mapping)
- [Assignment filter properties and operators reference - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/filters-device-properties)
- [Assignment Filter Performance Tips for Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/filters-performance-recommendations)
- [Use role-based access control (RBAC) and scope tags for distributed IT - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/mem/intune/fundamentals/scope-tags)
- [Cloud management gateway overview - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/cmg/overview)
- [Role-based access control (RBAC) with Microsoft Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control)
- [Microsoft Intune built-in roles reference - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control-reference)
- [Add groups to organize users and devices for Microsoft Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/groups-add)
- [Dynamic membership rules for groups in Azure Active Directory | Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership)

### Community Resources and Practical Guidance

- [Unlocking the Power of the Cloud Management Gateway (CMG) in Microsoft Configuration Manager | Abou Conde's Blog](https://abouconde.com/2024/11/29/unlocking-the-power-of-the-cloud-management-gateway-cmg-in-microsoft-configuration-manager/)
- [Creating dynamic groups and filters for Microsoft devices | Scott Duffey | Learning Microsoft Intune | Medium](https://medium.com/learning-mem/creating-dynamic-groups-and-filters-for-microsoft-devices-427e1a7cdea2)
- [How to Use Dynamic Azure AD Groups and Filters to Improve Targeting | Patch Tuesday](https://patchtuesday.com/blog/tech-blog/dynamic-azure-ad-groups/)
- [Intune grouping, targeting, and filtering: recommendations for best performance | Microsoft Community Hub](https://techcommunity.microsoft.com/t5/intune-customer-success/intune-grouping-targeting-and-filtering-recommendations-for-best/ba-p/2983058)
- [Using filters for assigning apps, policies and profiles to specific devices | Peter van der Woude](https://petervanderwoude.nl/post/using-filters-for-assigning-apps-policies-and-profiles-to-specific-devices/)

### Configuration-as-Code and Backup Tools

- [GitHub - almenscorner/IntuneCD: Tool to backup, update and document configurations in Intune](https://github.com/almenscorner/IntuneCD)
- [GitHub - jseerden/IntuneBackupAndRestore: PowerShell Module that queries Microsoft Graph](https://github.com/jseerden/IntuneBackupAndRestore)
- [Configuration as Code for Microsoft Intune | Microsoft Community Hub](https://techcommunity.microsoft.com/blog/intunecustomersuccess/configuration-as-code-for-microsoft-intune/3701792)

### 2026 Updates and Changes

- [What's New in Microsoft Intune – January 2026 | Microsoft Tech Community](https://techcommunity.microsoft.com/blog/microsoftintuneblog/whats-new-in-microsoft-intune-%E2%80%93-january-2026/4476487)
- [Microsoft Intune In Development for February 2026 is now available - M365 Admin](https://m365admin.handsontek.net/microsoft-intune-development-february-2026-now-available/)
- [Plan for Change: Update to Intune Data Warehouse infrastructure - M365 Admin](https://m365admin.handsontek.net/plan-change-update-intune-data-warehouse-infrastructure/)
- [Intune Suite Is Included in E3/E5 Starting July 2026 | Security Risk Advisors](https://sra.io/blog/intune-suite-is-included-in-e3-e5-starting-july-2026/)
- [What Microsoft's New Intune Changes Mean For Your Business - Cloud Context](https://www.cloudcontext.com.au/microsoft-365-intune-updates-2026/)

### Multi-Tenant Management

- [Overview of the Tenants page in Microsoft 365 Lighthouse - Microsoft 365 Lighthouse | Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/lighthouse/m365-lighthouse-tenants-page-overview?view=o365-worldwide)
- [Lighthouse + Intune + Defender: The MSP Telemetry Stack | Netlogic My365](https://netlogicmy365.com/2026/01/30/lighthouse-intune-defender-the-msp-telemetry-stack-that-turns-signals-into-proactive-service/)

---

**Document End**
