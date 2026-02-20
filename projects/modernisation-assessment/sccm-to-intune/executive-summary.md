# SCCM-to-Intune Transition Assessment — Executive Summary

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version**: Configuration Manager Current Branch 2403+
**Intune Version**: Current production (February 2026)

---

## Assessment Overview

This assessment provides a comprehensive capability-by-capability analysis of Microsoft Intune as a replacement for on-premises System Center Configuration Manager (SCCM). The evaluation uses a SCCM-centric approach: for every SCCM capability, we identify the Intune equivalent, rate the parity level, document licensing requirements, and provide migration guidance. The assessment covers 10 capability areas spanning device management, security, infrastructure, and automation. This document consolidates findings into an executive-level view with actionable recommendations.

---

## Consolidated RAG Summary Table

| Capability Area            | Parity Rating                                                     | Key Gaps                                                                                                                              | Key Advantages                                                                                                                        | Licensing Impact                                                                                    |
| -------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Software Deployment**    | 🟡 Near Parity                                                    | Global Conditions Library, App-V server EOL (April 2026), Phased Deployments                                                                 | winget integration (10,000+ apps), Microsoft Store modernization, MAM for BYOD                                                        | All features in M365 E3                                                                             |
| **Patch Management**       | 🟡 Near Parity (Microsoft);</br> 🔴 Significant Gap (third-party) | Third-party patching (no native support), Orchestration Groups for server clusters, Maintenance Windows                               | Expedited updates (24-hour deployment), Windows Autopatch (managed service), Driver/firmware automation                               | Autopatch in M365 E3 (from April 2025); Third-party tools ~$2-4/device/year                         |
| **OS Deployment**          | 🔴 Significant Gap                                                | Task Sequences/bare-metal imaging (No Equivalent), USMT user state migration, Custom driver injection                                 | Autopilot zero-touch provisioning, Enrollment Status Page, Branded OOBE experience                                                    | All Autopilot features in M365 E3; OEM imaging $10-30/device                                        |
| **Compliance Baselines**   | 🟡 Near Parity                                                    | Pre-built baseline library (fewer than SCCM), Multi-setting baselines (split into multiple policies), Baseline versioning             | 🔵 Conditional Access enforcement, Settings Catalog (5,000+ settings), Endpoint Analytics                                             | All core features M365 E3; Conditional Access requires Entra ID P1 (included in E3)                 |
| **Device Inventory**       | 🟠 Partial to 🔴 Significant Gap                                  | Custom hardware inventory (97 pre-defined properties only), Software metering (No Equivalent), Asset Intelligence (No Equivalent)     | 🔵 Graph API programmatic access, Entra ID integration, Zero infrastructure maintenance                                               | Properties Catalog in M365 E3; Workarounds require Azure Log Analytics (~$2.30/GB)                  |
| **Endpoint Protection**    | 🟢 Full Parity to 🔵 Intune Advantage                             | None (Full Parity achieved)                                                                                                           | 🔵 Native MDE integration with risk-based Conditional Access, Security baselines with auto-updates, Unified endpoint security console | All core features M365 E3; MDE P1 included in E3, MDE P2 in E5                                      |
| **Reporting**              | 🟠 Partial                                                        | Custom report authoring (no GUI equivalent to SSRS Report Builder), CMPivot real-time queries, Data Warehouse 30-day retention        | Built-in reports cover core scenarios, Power BI integration, Graph API access                                                         | Built-in reports M365 E3; Power BI Pro $10/user/month for sharing; MDE P2 (E5) for Advanced Hunting |
| **Remote Tools**           | 🟠 Partial to 🔴 Significant Gap                                  | Unattended remote control (user-present only), Wake-on-LAN (No Equivalent), Power Management (No Equivalent)                          | Comprehensive remote actions (wipe, retire, sync, restart, Autopilot reset), Bulk actions (100 devices)                               | Remote Help in M365 E3 (from July 2026); TeamViewer for unattended access (third-party license)     |
| **Infrastructure**         | 🔴 Significant Gap to ⬛ No Equivalent (Paradigm Shift)           | Site Hierarchy (No Equivalent—flat cloud tenant), Maintenance Windows (use deployment rings), Boundary Groups (automatic CDN routing) | 🔵 Cloud infrastructure (99.9% SLA, zero maintenance), Automatic backend management, Service health transparency                      | All features M365 E3; Dynamic groups require Entra ID P1 (included in E3)                           |
| **Scripting & Automation** | 🟡 Near Parity to 🔵 Intune Advantage                             | CMPivot real-time ad-hoc queries, Task sequence variables (OSD flexibility), Run Scripts approval workflow                            | 🔵 Graph API (modern REST), Configuration-as-Code ecosystem (IntuneCD, Microsoft365DSC), Webhooks for event-driven automation         | All core features M365 E3; MDE Advanced Hunting (partial CMPivot replacement) requires MDE P2 (E5)  |

### Parity Rating Legend

- 🟢 **Full Parity**: Functionally equivalent, no capability loss
- 🟡 **Near Parity**: ≥80% coverage, minor differences
- 🟠 **Partial**: 40-79% coverage, workarounds exist
- 🔴 **Significant Gap**: <40% coverage, core functionality missing
- ⬛ **No Equivalent**: Zero counterpart, architectural difference
- 🔵 **Intune Advantage**: Intune exceeds SCCM capability

---

## Top 5 Migration Gaps

### 1. OS Deployment: Task Sequences and Bare-Metal Imaging (No Equivalent)

**Affected Area**: OS Deployment & Imaging
**Rating**: ⬛ No Equivalent

**Gap Description**: Intune has no task sequence engine or bare-metal imaging capability. Autopilot requires pre-installed Windows from OEM. Cannot deploy WIM files, cannot PXE boot, cannot create bootable media, cannot image blank hardware.

**Remediation**:

- **OEM Custom Imaging Service**: Upload custom image to Dell/HP/Lenovo; factory-installed on new devices ($10-30/device + 2-4 week lead time)
- **SCCM Hybrid Model**: Use SCCM for imaging, register device with Autopilot in task sequence, manage with Intune post-imaging
- **Eliminate Custom Images**: Start with OEM image, apply all configuration via Autopilot policies (30-90 minute provisioning)

**Co-Management Bridge**: Retain SCCM OS Deployment workload via co-management for bare-metal scenarios while migrating workstation management to Intune.

---

### 2. Third-Party Application Patching (No Equivalent)

**Affected Area**: Patch & Update Management
**Rating**: ⬛ No Equivalent

**Gap Description**: SCCM supports third-party update catalogs via SCUP. Windows Update for Business contains only Microsoft updates (Windows, Office, Defender, Surface firmware). No native third-party patching in Intune.

**Remediation**:

- **Patch My PC**: Commercial solution with 550+ applications (~$2-4/device/year, most common choice)
- **Intune Suite Enterprise Application Management**: ~100 apps as of 2026 (included in M365 E5 from July 2026; complements but does not replace commercial solutions)
- **Win32 App Supersedence**: Manual approach; 15-30 minutes per app per update

**Co-Management Bridge**: Retain SCCM Software Updates workload for third-party patching during transition; migrate Microsoft updates to Intune immediately.

---

### 3. Custom Hardware Inventory and Software Metering (Significant Gap / No Equivalent)

**Affected Area**: Device Inventory & Asset Intelligence
**Rating**: 🔴 Significant Gap (Custom Inventory); ⬛ No Equivalent (Software Metering)

**Gap Description**:

- **Custom Hardware Inventory**: SCCM supports full WMI schema extensibility via configuration.mof. Intune Properties Catalog limited to 97 pre-defined properties across 10 categories.
- **Software Metering**: SCCM tracks application usage (launch count, duration, last used). Intune has no usage tracking capability.

**Remediation**:

- **Proactive Remediations + Azure Log Analytics**: PowerShell scripts collect custom inventory, upload to Log Analytics custom logs (~$2.30/GB ingestion)
- **Third-party SAM tools**: Flexera, Snow License Manager, Lansweeper for software metering (~$2-5/device/year)
- **Accept data loss**: Many organizations discover they don't need all custom inventory after cloud migration

**Co-Management Bridge**: Retain SCCM Resource Access workload for inventory collection (note: Resource Access slider removed in ConfigMgr 2403; must complete migration before upgrading).

---

### 4. Orchestration Groups for Server Clusters (No Equivalent)

**Affected Area**: Patch & Update Management
**Rating**: ⬛ No Equivalent

**Gap Description**: SCCM orchestration groups control update sequencing for server clusters (SQL Always On, Hyper-V clusters, Exchange DAG). Intune has no equivalent. Simultaneous patching causes service outages.

**Remediation**:

- **Azure Automation Update Management**: For Azure VMs; supports orchestration, maintenance windows, pre/post scripts
- **Manual orchestration**: Separate update policies per node; manual monitoring and ring progression
- **PowerShell orchestration scripts**: Via Proactive Remediations on scheduled task trigger
- **Retain SCCM for servers**: Most common approach; migrate workstations to Intune, keep servers in SCCM

**Co-Management Bridge**: Retain SCCM Software Updates workload for on-premises clustered server workloads.

---

### 5. Site Hierarchy and Infrastructure Paradigm Shift (No Equivalent)

**Affected Area**: Infrastructure & Site Architecture
**Rating**: ⬛ No Equivalent (Architectural Difference)

**Gap Description**: SCCM's multi-tier site hierarchy (CAS + primary sites + secondary sites) collapses to single flat cloud tenant. No site replication, no geographical segmentation via site topology, no boundary groups for content distribution control. This is not a gap to remediate—it is an architectural paradigm shift requiring new operational mental models.

**Remediation**:

- **Single-tenant consolidation**: Collapse all SCCM sites to one Intune tenant unless regulatory requirements mandate separation
- **Microsoft global CDN**: Rely on 100+ edge locations for content delivery (replaces distribution points)
- **Scope tags**: Use for organizational segmentation within single tenant (not separate tenants)
- **Retrain administrators**: From "infrastructure ownership" to "cloud SLA dependency"

**Co-Management Bridge**: Not applicable—this is a fundamental architectural difference, not a workload slider decision.

---

## Top 5 Intune Advantages

### 1. Conditional Access Integration (Zero-Trust Enforcement)

**Capability Area**: Compliance Baselines
**Licensing**: Entra ID P1 (included in M365 E3)

**Advantage**: Device compliance enforced as gate for accessing corporate resources (Exchange, SharePoint, Teams, SaaS apps). Non-compliant devices blocked automatically. Access granted when device becomes compliant. User self-service remediation (enable BitLocker, install updates). SCCM compliance is report-only with no automatic access enforcement.

**Benefit**: Immediate zero-trust security posture with compliance-based access control. Reduces helpdesk burden via self-service remediation workflows.

---

### 2. Windows Autopilot Zero-Touch Provisioning

**Capability Area**: OS Deployment & Imaging
**Licensing**: M365 E3

**Advantage**: User-driven mode allows user to unbox device, enter credentials, and Autopilot provisions automatically (30-60 minutes). Self-deploying mode for kiosk/shared devices (no user interaction). Pre-provisioning (White Glove) allows technician to pre-install apps; user receives pre-configured device (5-10 minute user wait time). Autopilot device preparation (Windows 11 24H2+) provides 20-30% faster provisioning.

**Benefit**: Superior user experience compared to SCCM imaging. No imaging infrastructure required. OEM integration (Dell/HP/Lenovo pre-register devices). Fastest ROI for new device procurement.

---

### 3. Microsoft Graph API (Modern REST API Superiority)

**Capability Area**: Scripting & Automation
**Licensing**: M365 E3

**Advantage**: Cross-platform REST API over HTTPS with official SDKs (PowerShell, Python, C#, Java, JavaScript, Go, PHP). Comprehensive documentation with interactive Graph Explorer. OData v4 filters, batching (20 requests per call), delta queries (incremental sync), change notifications (webhooks). Unified API for Intune, Entra ID, Exchange, SharePoint, Teams. Event-driven automation via webhook subscriptions.

**Benefit**: Far exceeds SCCM's WMI/SMS Provider capabilities. Enables configuration-as-code workflows (IntuneCD, Microsoft365DSC). No SCCM equivalent for webhooks or event-driven automation.

---

### 4. Native Microsoft Defender for Endpoint Integration

**Capability Area**: Endpoint Protection & Security
**Licensing**: MDE P1 (included in M365 E3); MDE P2 (included in M365 E5)

**Advantage**: Single-toggle tenant-wide MDE onboarding (all platforms: Windows, macOS, iOS, Android, Linux). Risk-based Conditional Access (block access if device risk > threshold). Vulnerability management integration (MDE creates remediation tasks in Intune). Tamper Protection central management (prevents local admin override). Security Configuration Management (MDE P2) delivers Intune policies to non-enrolled devices.

**Benefit**: Unified security posture management. SCCM requires tenant attach for MDE integration; Intune provides native integration out-of-box.

---

### 5. Cloud Infrastructure Management (Zero Operational Overhead)

**Capability Area**: Infrastructure & Site Architecture
**Licensing**: M365 E3

**Advantage**: Microsoft manages all backend infrastructure: high availability, disaster recovery, patching, capacity planning, performance tuning, security. 30+ SCCM maintenance tasks (delete aged data, rebuild indexes, backup site server) become automatic and invisible. 99.9% uptime SLA with financial credits for violations. No site server hardware, SQL Server licensing, backup infrastructure, or datacenter costs.

**Benefit**: Organizations eliminate entire infrastructure layer. Cultural shift from infrastructure ownership to cloud service consumption. Estimated savings: $90,000-150,000 over 3 years (1,000 devices).

---

## Licensing Summary

> **Note on Pricing**: All prices in this assessment are approximate figures in **USD**, sourced from publicly available Microsoft and partner resources as of February 2026. They are for **rough budget guidance only** — not exact quotations. Actual pricing varies by region, currency, volume licensing agreement, Enterprise Agreement (EA) terms, and available discounts. Always confirm current pricing with your Microsoft licensing representative or partner before procurement decisions.

### Minimum Viable: Microsoft 365 E3 (from July 2026)

**Price**: $39/user/month (increased from $36 effective July 2026)

**Included**:

- Intune Plan 1 (all core device/app management)
- Entra ID P1 (dynamic groups, Conditional Access, SSO, MFA)
- MDE Plan 1 (next-gen antivirus, ASR, device Conditional Access)
- Remote Help (from July 2026; previously ~$3.50/user/month standalone)
- Advanced Analytics (from July 2026; previously Intune Suite only)
- Tunnel for MAM (from July 2026)
- Windows Autopatch (included from April 2025; no additional cost)
- OneDrive for Business (data migration alternative to USMT)

**Not Included**:

- MDE Plan 2 (advanced hunting, extended retention) — requires M365 E5 or $5.20/user/month
- Power BI Pro (custom report sharing) — $10/user/month
- Azure Log Analytics (advanced reporting) — ~$2.30/GB ingestion
- Third-party patching tools — ~$2-4/device/year
- TeamViewer / third-party remote control — varies
- Endpoint Privilege Management — requires M365 E5 (from July 2026)
- Enterprise Application Management — requires M365 E5 (from July 2026)
- Cloud PKI — requires M365 E5 (from July 2026)

---

### Recommended: Microsoft 365 E5 (from July 2026)

**Price**: $60/user/month (increased from $57 effective July 2026)

**All M365 E3 features plus**:

- MDE Plan 2 (advanced hunting — partial CMPivot replacement, 6-month retention, custom detection rules)
- Entra ID P2 (Identity Protection, Privileged Identity Management, risk-based Conditional Access)
- Endpoint Privilege Management (just-in-time admin elevation)
- Enterprise Application Management (partial third-party patching; ~100 apps as of 2026)
- Cloud PKI (certificate lifecycle management)

---

### Add-Ons to Budget Regardless of Tier

| Add-On                         | When Required                                                  | Estimated Cost                              |
| ------------------------------ | -------------------------------------------------------------- | ------------------------------------------- |
| **Power BI Pro**               | Custom SSRS report replacement, scheduled report delivery      | $10/user/month                              |
| **Azure Log Analytics**        | Advanced reporting, custom inventory collection, KQL analytics | ~$2.30/GB ingestion (first 5GB/month free)  |
| **Third-party patching**       | Organizations with >50 third-party applications                | ~$2-4/device/year (Patch My PC most common) |
| **Third-party remote control** | Organizations requiring unattended remote desktop control      | Varies (TeamViewer Tensor/Corporate)        |

---

### July 2026 Licensing Changes

Effective July 1, 2026, Microsoft increases M365 E3/E5 pricing by $3/user/month and includes several Intune Suite features previously sold separately:

| Feature                       | Before July 2026                                | After July 2026           |
| ----------------------------- | ----------------------------------------------- | ------------------------- |
| Remote Help                   | Intune Suite ($10/user) or standalone (~$3.50/user) | Included in M365 E3/E5    |
| Advanced Analytics            | Intune Suite ($10/user)                         | Included in M365 E3/E5    |
| Tunnel for MAM                | Intune Suite ($10/user)                         | Included in EMS E3        |
| Endpoint Privilege Management | Intune Suite ($10/user)                         | Included in M365 E5       |
| Enterprise App Management     | Intune Suite ($10/user)                         | Included in M365 E5       |
| Cloud PKI                     | Intune Suite ($10/user)                         | Included in M365 E5       |
| Copilot in Intune             | Intune Suite ($10/user)                         | Remains Intune Suite only |

Organizations currently paying for standalone Intune Suite ($10/user/month) will see significant net savings despite the M365 price increase.

---

## Migration Readiness Assessment

### Overall Readiness: Conditional with Strategic Planning Required

Organizations can successfully migrate from SCCM to Intune, but success depends on **scenario-based assessment** rather than all-or-nothing migration. The assessment reveals three distinct migration profiles:

**1. Immediate Migration Candidates (High Success)**

- **New device procurement**: Migrate to Autopilot immediately for superior experience and fastest ROI
- **Workstation patching**: Migrate Microsoft updates to Windows Update for Business (budget for third-party patching solution)
- **User-focused applications**: Migrate to Intune with winget integration for simplified packaging
- **Endpoint protection**: Migrate to Intune for native MDE integration and Conditional Access enforcement
- **Compliance baselines**: Migrate to Intune Settings Catalog and enable zero-trust via Conditional Access

**2. Co-Management Bridge Scenarios (Gradual Transition)**

- **Third-party patching**: Retain SCCM Software Updates workload until commercial solution deployed (Patch My PC)
- **On-premises clustered servers**: Retain SCCM for orchestration groups; migrate workstations
- **Complex reporting dependencies**: Retain SCCM while recreating top 20 reports in Power BI
- **Custom inventory**: Retain SCCM Resource Access workload (note: deprecated in 2403; plan migration by upgrade deadline)

**3. Long-Term SCCM Retention (Hybrid Model)**

- **Bare-metal imaging requirements**: No Intune capability; retain SCCM OS Deployment workload or use OEM custom imaging
- **Windows Server deployments**: Windows Server not supported in Intune; retain SCCM or use Azure Automation (Azure VMs only)
- **Disconnected environments**: Intune requires internet connectivity; SCCM remains only option

### Key Risk: OS Deployment Paradigm Shift

The most significant migration risk is **OS deployment**. Organizations dependent on bare-metal imaging, custom WIM deployment, PXE boot, or complex task sequence workflows face a fundamental capability regression. Autopilot's opinionated model is intentional (reduces complexity, improves reliability), but some task sequence flexibility cannot migrate. Organizations must:

- Accept simpler deployment model for new device procurement (Autopilot superior to imaging)
- Retain SCCM hybrid model for bare-metal scenarios, or
- Use OEM custom imaging service ($10-30/device + lead time), or
- Eliminate custom images entirely (start with OEM image, configure via Autopilot policies)

### Biggest Win: Endpoint Protection and Zero-Trust Enablement

The most significant migration benefit is **endpoint protection** with native MDE integration and Conditional Access. Organizations gain:

- Device compliance enforced as gate for resource access (zero-trust architecture)
- Risk-based Conditional Access (block access if device compromised)
- Unified security console (Intune Endpoint Security node)
- Tamper Protection central management (prevents local admin override)
- User self-service remediation (reduces helpdesk burden)

This capability alone justifies migration for security-focused organizations. SCCM compliance is report-only; Intune compliance is enforcement-ready.

### Paradigm Shift: Infrastructure Ownership to Cloud SLA Dependency

The fundamental transformation is **infrastructure ownership → cloud service consumption**. SCCM administrators own infrastructure (fix failures, restore databases, troubleshoot replication). Intune administrators rely on Microsoft's 99.9% SLA and monitor Service Health dashboard. This requires:

- Executive understanding: "This is architectural transformation, not lift-and-shift migration"
- Administrator retraining: WQL → Entra ID queries, Collections → Groups/Filters, Maintenance windows → Deployment rings, WMI → Graph API
- Cultural readiness: From "we control the servers" to "we trust Microsoft's SLA"

Organizations underestimating this cultural shift experience migration friction regardless of technical capability parity.

---

## Recommended Next Steps

### 1. Secure Executive Buy-In on Paradigm Shift (Week 1)

Present this executive summary to leadership with explicit acknowledgment: "This is architectural transformation requiring new operational models, not feature-for-feature replacement." Budget for administrator retraining (2-4 weeks per admin for Graph API, Autopilot, dynamic groups, Conditional Access).

### 2. Enable Co-Management for Gradual Transition (Weeks 2-4)

Enable SCCM co-management with all workload sliders initially set to SCCM. This establishes dual-management foundation for gradual migration. Verify Entra Hybrid Join, CMG or VPN connectivity, Intune licensing.

**Reference**: See [Co-Management Appendix](co-management.md) for detailed workload slider configuration and transition sequence.

### 3. Pilot Intune with Low-Risk Workloads (Weeks 5-12)

Migrate 50-100 workstations in pilot group:

- **Compliance Policies**: Migrate security baselines; enable Conditional Access for pilot group (Exchange Online access)
- **Windows Update for Business**: Migrate Microsoft updates; create update rings with pilot-first deployment
- **Platform Scripts**: Migrate 5-10 common SCCM Run Scripts to test Intune scripting capabilities

Measure pilot success: user satisfaction, helpdesk ticket volume, compliance enforcement effectiveness.

### 4. Deploy Third-Party Patching Solution (Weeks 8-16)

If organization has >50 third-party applications, procure and deploy commercial patching solution (Patch My PC recommended; ~$2-4/device/year). This is the most common SCCM dependency blocker. Deploy to pilot group first; validate patch catalog coverage; expand to production.

### 5. Migrate New Device Procurement to Autopilot (Immediate)

Start Autopilot deployment for all new device purchases immediately (lowest risk, highest ROI). Work with OEM (Dell/HP/Lenovo) to pre-register devices. Create Autopilot profiles (user-driven mode for workstations, self-deploying for kiosks). This provides immediate user experience benefit and does not affect existing devices.

### 6. Complete Inventory and Fill Organization Template (Weeks 1-8)

Use [Organization Template](org-template.md) to capture environment-specific SCCM configuration. Document application portfolio, custom hardware inventory classes, software metering rules, orchestration groups, collection queries, maintenance windows. This inventory drives migration complexity assessment and timeline estimation.

### 7. Develop Power BI Reporting Strategy (Weeks 10-20)

Identify top 20 most-used SCCM custom reports. Recreate in Power BI using Intune Data Warehouse OData feed. Leverage [community templates](https://github.com/microsoft/Intune-Data-Warehouse) for common reports. Budget for Power BI Pro licensing ($10/user/month for report consumers) or partner engagement for complex reports.

---

## Document Set Reference

This assessment comprises 14 documents providing executive summary, detailed capability assessments, co-management guidance, and organization-specific planning template.

### Reading Order

**Start here**:

1. **Executive Summary** (this document) — Overview, consolidated RAG ratings, top gaps/advantages, licensing summary

**Core capability assessments** (prioritized by migration impact): 2. [OS Deployment & Imaging](os-deployment.md) — Significant Gap — Understand limitations first 3. [Patch & Update Management](patch-management.md) — Near Parity (Microsoft); Significant Gap (third-party) 4. [Software Deployment](software-deployment.md) — Near Parity 5. [Compliance Baselines](compliance-baselines.md) — Near Parity — Conditional Access opportunity 6. [Endpoint Protection](endpoint-protection.md) — Full Parity to Intune Advantage — Biggest win

**Supporting capability assessments**: 7. [Infrastructure & Site Architecture](infrastructure.md) — No Equivalent (Paradigm Shift) 8. [Scripting & Automation](scripting-automation.md) — Near Parity to Intune Advantage 9. [Reporting & Analytics](reporting-analytics.md) — Partial 10. [Device Inventory](device-inventory.md) — Partial to Significant Gap 11. [Remote Tools](remote-tools.md) — Partial to Significant Gap

**Implementation guidance**: 12. [Co-Management Appendix](co-management.md) — Required reading for gradual migration 13. [Organization Template](org-template.md) — Fill in during Weeks 1-8 14. [Master Index](README.md) — Navigation and methodology

### Document Inventory

| #   | Document               | File                    | Rating                                  | Description                                                           |
| --- | ---------------------- | ----------------------- | --------------------------------------- | --------------------------------------------------------------------- |
| 1   | Executive Summary      | executive-summary.md    | —                                       | Consolidated overview and recommendations (this document)             |
| 2   | Software Deployment    | software-deployment.md  | 🟡 Near Parity                          | Win32 apps, winget, Store, supersedence, dependencies                 |
| 3   | Patch Management       | patch-management.md     | 🟡 Near Parity (MS); 🔴 Gap (3rd-party) | WUfB, Autopatch, third-party patching gap                             |
| 4   | OS Deployment          | os-deployment.md        | 🔴 Significant Gap                      | Autopilot, ESP, task sequence gap                                     |
| 5   | Compliance Baselines   | compliance-baselines.md | 🟡 Near Parity                          | Settings Catalog, Conditional Access, security baselines              |
| 6   | Device Inventory       | device-inventory.md     | 🟠 Partial to 🔴 Gap                    | Properties Catalog, custom inventory gap, software metering gap       |
| 7   | Endpoint Protection    | endpoint-protection.md  | 🟢 Full Parity to 🔵 Advantage          | MDE integration, ASR, unified security console                        |
| 8   | Reporting & Analytics  | reporting-analytics.md  | 🟠 Partial                              | Built-in reports, Power BI, CMPivot gap, Data Warehouse               |
| 9   | Remote Tools           | remote-tools.md         | 🟠 Partial to 🔴 Gap                    | Remote actions, Remote Help, unattended control gap, WoL gap          |
| 10  | Infrastructure         | infrastructure.md       | 🔴 Gap to ⬛ No Equivalent              | Cloud architecture, site hierarchy shift, RBAC, groups vs collections |
| 11  | Scripting & Automation | scripting-automation.md | 🟡 Near Parity to 🔵 Advantage          | Graph API, Platform Scripts, Remediations, CMPivot gap, IaC tools     |
| 12  | Co-Management Appendix | co-management.md        | —                                       | Workload sliders, transition sequence, phased migration               |
| 13  | Organization Template  | org-template.md         | —                                       | Environment inventory checklist                                       |
| 14  | Master Index           | README.md               | —                                       | Navigation, methodology, parity scale                                 |

---

## Sources

- [Windows Autopatch FAQ](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq)
- [Microsoft 365 adds advanced Microsoft Intune solutions at scale](https://techcommunity.microsoft.com/blog/microsoftintuneblog/microsoft-365-adds-advanced-microsoft-intune-solutions-at-scale/4474272)
- [Co-management workloads - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/comanage/workloads)
- [Switch co-management workloads - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/comanage/how-to-switch-workloads)
- Assessment source documents: 10 capability area assessments (detailed technical analyses)

---

**Document End**
