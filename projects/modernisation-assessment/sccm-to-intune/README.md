---
title: "SCCM-to-Intune Transition Assessment — Master Index"
status: "published"
last_updated: "2026-02-18"
audience: "IT Managers"
document_type: "readme"
domain: "projects"
---

# SCCM-to-Intune Transition Assessment — Master Index

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**Assessment Scope**: 10 capability areas, 14 documents, 200+ feature comparisons

---

## Introduction

This assessment provides a comprehensive, capability-by-capability analysis of Microsoft Intune as a replacement for on-premises System Center Configuration Manager (SCCM). The document set uses a **SCCM-centric approach**: for every SCCM capability, we identify the Intune equivalent, rate parity level, document licensing requirements, and provide migration guidance.

**How to Use This Document Set**:

- **Executives**: Read [Executive Summary](reference-executive-summary.md) for consolidated RAG ratings, top gaps/advantages, licensing summary, and recommendations
- **IT Leadership**: Read Executive Summary, then priority assessments ([OS Deployment](reference-os-deployment.md), [Patch Management](reference-patch-management.md), [Endpoint Protection](reference-endpoint-protection.md))
- **Technical Teams**: Read all 10 capability area assessments for detailed feature mapping and migration guidance
- **Project Managers**: Use [Organization Template](reference-org-template.md) to capture environment-specific configuration for scoping

**Key Findings**:

- **Overall Parity**: 7 of 10 capability areas achieve Near Parity or better; 3 areas have Significant Gaps requiring remediation
- **Biggest Gap**: OS Deployment (task sequences, bare-metal imaging) — requires OEM custom imaging, SCCM hybrid model, or workflow redesign
- **Biggest Win**: Endpoint Protection with native MDE integration and Conditional Access — immediate zero-trust enablement
- **Paradigm Shift**: Infrastructure (site hierarchy → flat cloud tenant) — not a gap to remediate, but an architectural transformation requiring new operational models

---

## Reading Order

### Recommended Reading Sequence

**Phase 1: Executive Overview** (30-60 minutes)

1. **[Executive Summary](reference-executive-summary.md)** — Start here for consolidated RAG ratings, top gaps/advantages, licensing summary, and migration roadmap

**Phase 2: Priority Capability Assessments** (2-4 hours; prioritized by migration impact)

**Critical Assessments** (read first):

1. **[OS Deployment & Imaging](reference-os-deployment.md)** — 🔴 Significant Gap

- Understand task sequence limitations before committing to migration
- Bare-metal imaging requires workarounds (OEM custom imaging, SCCM hybrid model, or elimination)
- **Read first if**: Your organization performs bare-metal imaging, uses custom WIM files, or has complex task sequences

1. **[Patch & Update Management](reference-patch-management.md)** — 🟡 Near Parity (Microsoft); 🔴 Significant Gap (third-party)
   - Third-party patching requires commercial solution (~$2-4/device/year)
   - Orchestration groups have no Intune equivalent (retain SCCM for server clusters)
   - **Read first if**: You patch >50 third-party applications or use orchestration groups for SQL/Hyper-V/Exchange clusters

2. **[Endpoint Protection & Security](reference-endpoint-protection.md)** — 🟢 Full Parity to 🔵 Intune Advantage
   - Native MDE integration and Conditional Access provide immediate zero-trust enablement
   - Full parity across antivirus, firewall, ASR policies
   - **Read first if**: Security and compliance are primary migration drivers

**Core Management Assessments**:

1. **[Software Deployment](reference-software-deployment.md)** — 🟡 Near Parity

- Win32 apps, winget integration, supersedence, dependencies
- Global Conditions gap (no reusable library; requirements configured per app)
- App-V server EOL April 2026; client moves to extended support (requires MSIX migration or repackaging)

1. **[Compliance Baselines](reference-compliance-baselines.md)** — 🟡 Near Parity
   - Settings Catalog (5,000+ settings), security baselines, custom compliance
   - Conditional Access integration (enforcement vs. SCCM report-only compliance)
   - Pre-built baseline library gap (fewer baselines than SCCM; must recreate others)

**Supporting Capability Assessments**:

1. **[Infrastructure & Site Architecture](reference-infrastructure.md)** — 🔴 Significant Gap to ⬛ No Equivalent (Paradigm Shift)

- Site hierarchy has no Intune equivalent (flat cloud tenant)
- Collections → Groups/Filters, Maintenance windows → Deployment rings
- **Critical for administrators**: Understand operational model transformation

1. **[Scripting & Automation](reference-scripting-automation.md)** — 🟡 Near Parity to 🔵 Intune Advantage
   - Graph API superiority over WMI, configuration-as-code ecosystem
   - CMPivot gap (partial replacement via MDE Advanced Hunting or Proactive Remediations)
   - Platform Scripts, Remediations, IntuneCD, Microsoft365DSC

2. **[Reporting & Analytics](reference-reporting-analytics.md)** — 🟠 Partial
   - Built-in reports cover core scenarios; Power BI for custom reports
   - SSRS Report Builder gap (no GUI authoring; requires Power BI skills)
   - CMPivot real-time query gap, Data Warehouse 30-day retention

3. **[Device Inventory](reference-device-inventory.md)** — 🟠 Partial to 🔴 Significant Gap
   - Properties Catalog (97 pre-defined properties) vs. SCCM unlimited WMI extensibility
   - Software metering has no Intune equivalent (requires third-party SAM tools)
   - Asset Intelligence has no Intune equivalent

4. **[Remote Tools](reference-remote-tools.md)** — 🟠 Partial to 🔴 Significant Gap
   - Remote Help (user-present only; included in M365 E3 from July 2026)
   - Unattended remote control gap (requires TeamViewer or third-party solution)
   - Wake-on-LAN and Power Management have no Intune equivalents

**Phase 3: Implementation Guidance** (2-4 hours)

1. **[Co-Management Appendix](reference-co-management.md)** — **Required reading for gradual migration**
   - 7 workload sliders (Compliance, Device Configuration, Endpoint Protection, Windows Update Policies, Office Apps, Client Apps, Resource Access)
   - Phased migration timeline (Phase 1: Enable co-management, Phase 2: Pilot workloads, Phase 3: Full transition)
   - Policy overlap guidance, monitoring, rollback procedures
   - **Read before**: Starting migration; understanding workload slider configuration

2. **[Organization Template](reference-org-template.md)** — **Fill in during Weeks 1-8**
   - Environment inventory checklist (10 capability areas + general environment)
   - Structured fields to capture SCCM configuration (applications, baselines, collections, task sequences)
   - Migration complexity estimation, budget planning, timeline calculation
   - **Use for**: Scoping migration effort, identifying blockers, prioritizing workloads

3. **[Master Index](README.md)** — This document
   - Navigation, reading order, document inventory, parity rating legend, methodology

---

## Document Inventory

### Phase 1: Executive Overview

| #   | Document              | File                 | Rating | Description                                                                                  |
| --- | --------------------- | -------------------- | ------ | -------------------------------------------------------------------------------------------- |
| 1   | **Executive Summary** | reference-executive-summary.md | —      | Consolidated RAG ratings, top 5 gaps, top 5 advantages, licensing summary, migration roadmap |

### Phase 2: Capability Area Assessments

| #   | Document                   | File                    | Rating                                  | Description                                                                                               |
| --- | -------------------------- | ----------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 2   | **Software Deployment**    | reference-software-deployment.md  | 🟡 Near Parity                          | Win32 apps, winget integration, supersedence, dependencies, global conditions gap, App-V EOL              |
| 3   | **Patch Management**       | reference-patch-management.md     | 🟡 Near Parity (MS); 🔴 Gap (3rd-party) | Windows Update for Business, Autopatch, third-party patching gap, orchestration groups gap                |
| 4   | **OS Deployment**          | reference-os-deployment.md        | 🔴 Significant Gap                      | Autopilot, Enrollment Status Page, task sequence gap, bare-metal imaging gap, USMT gap                    |
| 5   | **Compliance Baselines**   | reference-compliance-baselines.md | 🟡 Near Parity                          | Settings Catalog (5,000+ settings), Conditional Access, security baselines, custom compliance             |
| 6   | **Device Inventory**       | reference-device-inventory.md     | 🟠 Partial to 🔴 Gap                    | Properties Catalog (97 properties), custom inventory gap, software metering gap, Asset Intelligence gap   |
| 7   | **Endpoint Protection**    | reference-endpoint-protection.md  | 🟢 Full Parity to 🔵 Advantage          | MDE integration, ASR policies, Conditional Access, unified security console, security baselines           |
| 8   | **Reporting & Analytics**  | reference-reporting-analytics.md  | 🟠 Partial                              | Built-in reports, Power BI, Data Warehouse, SSRS Report Builder gap, CMPivot gap                          |
| 9   | **Remote Tools**           | reference-remote-tools.md         | 🟠 Partial to 🔴 Gap                    | Remote Help, remote actions, unattended control gap, Wake-on-LAN gap, Power Management gap                |
| 10  | **Infrastructure**         | reference-infrastructure.md       | 🔴 Gap to ⬛ No Equivalent              | Cloud architecture, site hierarchy paradigm shift, Collections→Groups, RBAC, scope tags                   |
| 11  | **Scripting & Automation** | reference-scripting-automation.md | 🟡 Near Parity to 🔵 Advantage          | Graph API, Platform Scripts, Remediations, CMPivot gap, configuration-as-code (IntuneCD, Microsoft365DSC) |

### Phase 3: Implementation Guidance

| #   | Document                   | File             | Rating | Description                                                                                      |
| --- | -------------------------- | ---------------- | ------ | ------------------------------------------------------------------------------------------------ |
| 12  | **Co-Management Appendix** | reference-co-management.md | —      | Workload sliders, phased migration timeline, policy overlap guidance, rollback procedures        |
| 13  | **Organization Template**  | reference-org-template.md  | —      | Environment inventory checklist for 10 capability areas + general environment                    |
| 14  | **Master Index**           | README.md        | —      | Navigation, reading order, document inventory, parity rating legend, methodology (this document) |

---

## Parity Rating Legend

All capability mappings use a **five-level parity scale** plus one supplementary tag:

| Rating               | Symbol | Definition                                                                                                         | Colour Indicator | Implication                                                                                                                              |
| -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------ | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **Full Parity**      | 🟢     | Intune feature is functionally equivalent to SCCM. No capability loss.                                             | Green            | Migrate with confidence. No workarounds required.                                                                                        |
| **Near Parity**      | 🟡     | ≥80% capability coverage. Minor functional differences or administrative overhead differences.                     | Yellow-Green     | Migrate; document minor differences for operational awareness. Workarounds available for remaining 20%.                                  |
| **Partial**          | 🟠     | 40-79% capability coverage. Workarounds exist but introduce administrative overhead or require additional tooling. | Orange           | Migrate with workarounds. Document workarounds and accept trade-offs (increased admin effort, third-party tools).                        |
| **Significant Gap**  | 🔴     | <40% capability coverage. Core functionality missing. Third-party tools or retained SCCM workload required.        | Red              | Flag for remediation planning. Evaluate third-party solutions, co-management retention, or accept capability loss.                       |
| **No Equivalent**    | ⬛     | SCCM capability has zero Intune counterpart. Architectural or design difference prevents coverage.                 | Black            | Retain SCCM workload via co-management, adopt third-party solution, or accept capability loss. Not a "gap" but a fundamental difference. |
| **Intune Advantage** | 🔵     | Intune exceeds SCCM capability. Cloud-native features with no SCCM equivalent.                                     | Blue             | No investigation required — note as migration benefit. Leverage these advantages for business value justification.                       |

### Rating Application Guidelines

**Area-Level Rating** (Overall Parity Rating for each capability area):

- Derived from weighted assessment of individual feature ratings
- Critical features weighted more heavily than administrative conveniences
- Example: OS Deployment rated "Significant Gap" because bare-metal imaging (critical) has No Equivalent, despite in-place upgrade (Full Parity)

**Feature-Level Rating** (Individual SCCM features in Feature Parity Matrix):

- Each SCCM feature rated independently
- Rationale documented for each rating with specific Intune feature names and limitations
- Where feature spans multiple ratings (e.g., "Partial for advanced use, Full Parity for basic use"), range stated with conditions explained

---

## Assessment Methodology

### SCCM-Centric Approach

This assessment answers the question: **"Does Intune cover this SCCM capability?"** — not "What can Intune do?"

**Methodology Principles**:

1. **Start from SCCM**: Every assessment begins with SCCM feature inventory
2. **Map to Intune**: Identify Intune equivalent (or absence thereof)
3. **Rate Parity**: Apply five-level scale with rationale
4. **Document Remediation**: For gaps, provide remediation options (third-party tools, co-management retention, acceptance)
5. **Note Advantages**: Where Intune exceeds SCCM, document advantage (no remediation needed)

### SCCM Version Baseline

**SCCM Version Assessed**: Configuration Manager Current Branch **2403+** (latest as of February 2026)

**Rationale**: Organizations planning migration should be on Current Branch latest version. Features deprecated in 2403+ (e.g., Resource Access slider) are noted as prerequisites for migration.

### Intune Version Baseline

**Intune Version Assessed**: Current production (February 2026)

**Continuous Updates**: Intune is a cloud service updated continuously. Assessment reflects capabilities as of February 2026. New features may be announced after this date (check [Microsoft Intune Blog](https://techcommunity.microsoft.com/t5/microsoft-intune-blog/bg-p/MicrosoftEndpointManagerBlog) for updates).

### Source Verification

**Source Hierarchy** (in order of preference):

1. **Microsoft Learn** (learn.microsoft.com) — Official product documentation
2. **Microsoft Tech Community** (techcommunity.microsoft.com) — Official Microsoft blogs, announcements
3. **Community Technical Resources** — systemcenterdudes.com, patchmypc.com, anoopcnair.com, prajwaldesai.com, msendpointmgr.com (for practical guidance and real-world validation)

**Source Citation**: All feature comparisons cite sources with hyperlinks for verification.

### Diátaxis Classification

Assessment documents intentionally blend three [Diátaxis](https://diataxis.fr/) documentation modes within each capability area document:

- **Reference**: Feature Parity Matrices, licensing tables, configuration examples — structured for lookup
- **How-to**: Migration strategies, checklists, pre-migration assessment scripts — task-oriented guidance
- **Explanation**: Paradigm shift narratives, architectural comparisons, impact analysis — understanding-oriented context

This blending is by design. Each capability assessment serves as a complete resource for decision-making about that capability area, and separating these modes into different documents would fragment the decision context. The Feature Parity Matrix (reference) is the primary deliverable; Key Findings (explanation) and Migration Considerations (how-to) provide the narrative context needed to act on the matrix.

### Table-Led Structure

**Primary Assessment Tool**: Feature Parity Matrix

Every capability area assessment includes a Feature Parity Matrix table:

| SCCM Feature | Intune Equivalent                     | Parity Rating     | Licensing    | Notes         |
| ------------ | ------------------------------------- | ----------------- | ------------ | ------------- |
| Feature name | Equivalent feature or "No equivalent" | Rating from scale | License tier | Brief context |

**Narrative Support**: Tables supplemented with narrative for nuanced areas (gaps, advantages, migration considerations) that tables cannot fully capture.

### Document Structure Template

Each capability area assessment follows this structure:

1. **Executive Summary** — 3-5 sentences: overall parity rating, top 2-3 gaps, top Intune advantages
2. **Feature Parity Matrix** — Primary comparison table (all SCCM features vs. Intune equivalents)
3. **Key Findings** — Narrative subsections:
   - Full/Near Parity Areas
   - Partial Parity / Gaps
   - Significant Gaps / No Equivalent
   - Intune Advantages
4. **Licensing Impact** — Features gated by licensing tier (Plan 1, Plan 2, Suite, E3, E5, MDE P1/P2)
5. **Migration Considerations** — Practical guidance for transitioning this capability area
6. **Sources** — Hyperlinked references to Microsoft Learn and community sources

---

## Cross-Reference Map

### Licensing Dependencies

**Key Licensing Tiers**:

- **Intune Plan 1** (M365 E3): All core device/app management features
- **Entra ID P1** (M365 E3): Dynamic groups, Conditional Access
- **MDE Plan 1** (M365 E3): Next-gen antivirus, ASR, device Conditional Access
- **MDE Plan 2** (M365 E5): Advanced hunting (partial CMPivot replacement), extended retention
- **Intune Suite** → M365 E3/E5 (from July 2026): Remote Help, Advanced Analytics, EPM (E5), Enterprise App Management (E5), Cloud PKI (E5)
- **Power BI Pro** ($10/user/month): Custom report sharing, subscriptions
- **Azure Log Analytics** (~$2.30/GB): Advanced reporting, custom inventory workarounds

### Co-Management Workload Mapping

Each capability area maps to one or more co-management workload sliders:

| Capability Area        | Co-Management Workload Slider(s)                                    |
| ---------------------- | ------------------------------------------------------------------- |
| Software Deployment    | Client Apps, Office Click-to-Run Apps                               |
| Patch Management       | Windows Update Policies                                             |
| OS Deployment          | _(Not a workload slider; SCCM infrastructure retained for imaging)_ |
| Compliance Baselines   | Compliance Policies, Device Configuration                           |
| Device Inventory       | Resource Access _(deprecated in 2403+; migrate before upgrading)_   |
| Endpoint Protection    | Endpoint Protection                                                 |
| Reporting & Analytics  | _(No workload slider; reporting capabilities independent)_          |
| Remote Tools           | _(No workload slider; Remote Help deployed separately)_             |
| Infrastructure         | _(Not a workload slider; architectural transformation)_             |
| Scripting & Automation | _(No workload slider; Graph API and tools available immediately)_   |

See [Co-Management Appendix](reference-co-management.md) for detailed workload slider configuration and transition sequence.

### Gap Remediation Options

**Common Gap Remediation Strategies** (cross-referenced across multiple assessments):

| Gap Type                      | Remediation Options                                                                                                                                                                                          | Documents Affected                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------- |
| **Third-party patching**      | Patch My PC (~$2-4/device/year), Enterprise App Management (Intune Suite/M365 E5), Win32 app supersedence (manual), retain SCCM Software Updates workload                                                    | Patch Management, Software Deployment |
| **Bare-metal imaging**        | OEM custom imaging ($10-30/device), SCCM hybrid model (image with SCCM, manage with Intune), MDT standalone (<50 devices), eliminate custom images                                                           | OS Deployment                         |
| **Custom hardware inventory** | Proactive Remediations + Azure Log Analytics (~$2.30/GB), Custom Compliance (binary output only), retain SCCM Resource Access workload, accept data loss                                                     | Device Inventory                      |
| **Software metering**         | Third-party SAM tools (Flexera, Snow, Lansweeper ~$2-5/device/year), M365 Apps Usage Analytics (M365 apps only), retain SCCM, accept capability loss                                                         | Device Inventory                      |
| **Orchestration groups**      | Azure Automation Update Management (Azure VMs), manual orchestration via separate update policies, PowerShell scripts via Remediations, retain SCCM for servers                                              | Patch Management                      |
| **Unattended remote control** | TeamViewer (third-party license), Remote Desktop (RDP via Configuration Policy, user must be logged on), retain SCCM Remote Tools workload, accept no unattended access                                      | Remote Tools                          |
| **CMPivot real-time queries** | MDE Advanced Hunting (MDE P2 for security scenarios), Proactive Remediations (scheduled, not real-time), Graph API queries (tenant-level, not per-device), Azure Log Analytics KQL (15-min lag), retain SCCM | Reporting, Scripting & Automation     |
| **Custom SSRS reports**       | Power BI recreation (requires Power BI Pro $10/user/month for sharing), community templates (GitHub: microsoft/Intune-Data-Warehouse), partner engagement, retain SCCM                                       | Reporting & Analytics                 |

---

## Migration Complexity Factors

### Organizational Factors

**High-Complexity Organizations** (longer migration timeline; 12-24 months):

- Large application portfolio (>200 applications)
- Extensive custom hardware inventory (>10 custom WMI classes)
- Active orchestration groups for server clusters
- Bare-metal imaging requirements
- Complex task sequences (>40 steps, conditional logic, hardware-specific drivers)
- Heavy reliance on software metering for license compliance
- Disconnected environments (no internet access)

**Medium-Complexity Organizations** (typical migration timeline; 6-12 months):

- Moderate application portfolio (50-200 applications)
- Standard hardware inventory (minimal custom WMI extensions)
- No orchestration groups (standalone servers or workstations only)
- Autopilot-compatible OS deployment scenarios (new device procurement, simple refresh)
- Standard task sequences (<20 steps)
- Limited software metering usage
- Full internet connectivity via CMG or VPN

**Low-Complexity Organizations** (fast migration timeline; 3-6 months):

- Small application portfolio (<50 applications)
- No custom hardware inventory
- Workstations only (no servers)
- New device procurement only (no imaging or refresh requirements)
- No task sequences
- No software metering
- Cloud-first organization (Entra Hybrid Join already deployed)

### Technical Factors

**Migration Accelerators** (reduce timeline):

- Co-management already enabled
- CMG deployed and functional
- Entra Hybrid Join >90% coverage
- M365 E5 licensing (includes MDE P2, Intune Suite features from July 2026)
- Active Directory clean and well-maintained
- SCCM on Current Branch 2403+

**Migration Blockers** (extend timeline or prevent full migration):

- No Entra Hybrid Join (requires Azure AD Connect deployment and device migration)
- No internet connectivity for devices (Intune requires internet; SCCM retention required)
- Bare-metal imaging business-critical (no Intune equivalent; hybrid model required)
- Orchestration groups for business-critical server clusters (retain SCCM for servers)
- Extensive custom inventory dependencies (regulatory compliance, vendor audits)
- Legacy Office (2019/2021 perpetual) instead of Microsoft 365 Apps (Office Apps workload slider not applicable)

---

## Assessment Statistics

### Document Set Metrics

- **Total Documents**: 14 (1 executive summary, 10 capability assessments, 1 co-management appendix, 1 organization template, 1 master index)
- **Total Pages**: ~500 pages (estimated print output)
- **Total Feature Comparisons**: 200+ individual SCCM feature to Intune mappings
- **Total Sources Cited**: 140+ (Microsoft Learn, Microsoft Tech Community, community technical resources)
- **Assessment Effort**: ~320 hours (research, documentation, validation)

### Capability Area Distribution

**Parity Rating Distribution** (10 capability areas):

- 🟢 Full Parity to 🔵 Intune Advantage: 1 (Endpoint Protection)
- 🟡 Near Parity: 3 (Software Deployment, Patch Management, Compliance Baselines)
- 🟡 Near Parity to 🔵 Intune Advantage: 1 (Scripting & Automation)
- 🟠 Partial: 1 (Reporting & Analytics)
- 🟠 Partial to 🔴 Significant Gap: 2 (Device Inventory, Remote Tools)
- 🔴 Significant Gap: 1 (OS Deployment)
- 🔴 Significant Gap to ⬛ No Equivalent: 1 (Infrastructure — Paradigm Shift)

### Key Themes

**Consistent Gaps Across Multiple Areas**:

1. **Pre-built content/baseline libraries** — SCCM has more pre-built baselines, reports, update catalogs; Intune requires recreation
2. **Single-object containers** — SCCM uses baselines, phased deployments, orchestration groups as single objects; Intune splits into multiple policies
3. **Server-specific capabilities** — Orchestration groups, maintenance windows, bare-metal imaging designed for server workloads; Intune workstation-centric
4. **Real-time ad-hoc query** — CMPivot instant multi-device queries; Intune alternatives are scheduled (Remediations) or non-real-time (Graph API, Log Analytics)

**Consistent Intune Advantages**:

1. **Cloud-native infrastructure** — Zero on-premises servers, automatic updates, Microsoft-managed, 99.9% SLA
2. **Conditional Access integration** — Zero-trust enforcement (SCCM compliance is report-only)
3. **Auto-generated settings/catalogs** — winget (10,000+ apps), Settings Catalog (5,000+ settings), security baseline auto-updates
4. **Modern APIs** — Graph API REST API superiority over SCCM WMI/SMS Provider
5. **User experience focus** — Endpoint Analytics, branded OOBE, self-service remediation via Company Portal

**Migration Success Factors**:

1. **Scenario-based assessment** — Not all-or-nothing migration; evaluate per-scenario (new device procurement vs. bare-metal imaging)
2. **Co-management for gradual transition** — Retain SCCM workloads for gaps during migration
3. **Cloud-first workloads migrate first** — New device procurement, workstation patching, user-focused apps, endpoint protection
4. **Hybrid long-term model acceptable** — Servers/complex scenarios in SCCM, workstations in Intune (co-management bridge indefinitely)

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Intune documentation](https://learn.microsoft.com/en-us/mem/intune/)
- [Configuration Manager documentation](https://learn.microsoft.com/en-us/mem/configmgr/)
- [Co-management for Windows devices](https://learn.microsoft.com/en-us/mem/configmgr/comanage/)
- [Windows Autopilot documentation](https://learn.microsoft.com/en-us/autopilot/)
- [Microsoft Graph API documentation](https://learn.microsoft.com/en-us/graph/)
- [Windows Update for Business deployment service](https://learn.microsoft.com/en-us/windows/deployment/update/deployment-service-overview)

### Microsoft Announcements

- [Microsoft 365 adds advanced Microsoft Intune solutions at scale](https://techcommunity.microsoft.com/blog/microsoftintuneblog/microsoft-365-adds-advanced-microsoft-intune-solutions-at-scale/4474272) — July 2026 licensing changes
- [Windows Autopatch FAQ](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-faq)

### Community Resources

- [MSEndpointMgr](https://msendpointmgr.com/) — Intune and ConfigMgr technical blog
- [System Center Dudes](https://www.systemcenterdudes.com/) — SCCM and Intune tutorials
- [Patch My PC](https://patchmypc.com/) — Third-party patching solution for Intune
- [Anoop C Nair](https://www.anoopcnair.com/) — Microsoft Endpoint Manager blog
- [Prajwal Desai](https://www.prajwaldesai.com/) — SCCM and Intune guides

### Configuration-as-Code Tools

- [IntuneCD](https://github.com/almenscorner/IntuneCD) — Python-based Intune configuration backup, documentation, and deployment
- [Microsoft365DSC](https://microsoft365dsc.com/) — PowerShell DSC resources for M365 configuration management
- [IntuneBackupAndRestore](https://github.com/jseerden/IntuneBackupAndRestore) — PowerShell module for Intune backup/restore
- [Microsoft Intune Data Warehouse Power BI Templates](https://github.com/microsoft/Intune-Data-Warehouse) — Community Power BI report templates

---

## Version History

| Version | Date       | Changes                                                                       |
| ------- | ---------- | ----------------------------------------------------------------------------- |
| 1.0     | 2026-02-18 | Initial release — 14 documents, 10 capability areas, 200+ feature comparisons |

---

## Document Control

**Assessment Sponsor**: IT Leadership
**Assessment Team**: Infrastructure, Security, Applications, Reporting teams
**Review Cycle**: Quarterly (or upon major Intune feature releases)
**Next Review Date**: 2026-05-18

---

**Master Index End**
