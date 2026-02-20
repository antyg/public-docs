# SCCM-to-Intune Migration — Organization Assessment Template

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**Purpose**: Environment-specific inventory checklist to scope SCCM-to-Intune migration

---

## Instructions

This template captures your organization's current SCCM configuration to scope migration complexity, timeline, and budget. Fill in each section during Weeks 1-8 of migration planning. Use this data to:

- Estimate migration effort (hours per capability area)
- Identify migration blockers (bare-metal imaging dependencies, third-party patching requirements)
- Prioritize workload migration order
- Budget for add-on licensing (Power BI Pro, third-party tools)
- Define pilot collection composition

**Notation**:

- `[ ]` — Checkbox (check if true/applicable)
- `___` — Fill in the blank with specific value
- Sections marked **Critical** directly impact migration feasibility or timeline

---

## General Environment

### SCCM Infrastructure

**Site Hierarchy**:

- [ ] Standalone primary site (single site)
- [ ] Hierarchy with CAS (Central Administration Site)
  - Number of primary sites: \_\_\_\_\_\_
  - Number of secondary sites: \_\_\_\_\_\_
- [ ] Site replication functional (no replication issues in last 30 days)

**SCCM Version**:

- ConfigMgr version: \_\_\_\_\_\_ (e.g., Current Branch 2403, 2309, 2203)
- SQL Server version: \_\_\_\_\_\_ (e.g., SQL Server 2019, 2022)
- [ ] All sites on same version (uniform upgrade state)
- [ ] Client health >95% (check Client Health dashboard)

**Managed Devices** (**Critical**):

- Total managed devices: \_\_\_\_\_\_
- Windows 10/11 workstations: \_\_\_\_\_\_
- Windows Server devices: \_\_\_\_\_\_
- Non-Windows devices (macOS, Linux): \_\_\_\_\_\_
- Average device age: \_\_\_\_\_\_ years

**Infrastructure Components**:

- Number of distribution points: \_\_\_\_\_\_
  - [ ] Using cloud distribution points
  - [ ] Using BranchCache
  - [ ] Using peer cache
- Number of boundary groups: \_\_\_\_\_\_
- [ ] Cloud Management Gateway (CMG) deployed
- [ ] HTTPS communication enabled (Enhanced HTTP minimum)

---

### Identity and Cloud Readiness

**Azure Active Directory / Entra ID**:

- [ ] Organization uses Entra ID (Azure AD)
- [ ] Devices are Entra Hybrid Joined (Azure AD + on-premises AD)
  - Estimated % Entra Hybrid Joined: \_\_\_\_\_\_
- [ ] Entra Connect (Azure AD Connect) deployed and functional
- [ ] Conditional Access policies in use (if yes, list count: \_\_\_\_\_\_)

**SCCM Cloud Integration**:

- [ ] SCCM connected to Azure AD tenant
- [ ] Co-management enabled
  - If yes, current workload sliders (check all that apply):
    - [ ] Compliance Policies: SCCM / Pilot Intune / Intune
    - [ ] Device Configuration: SCCM / Pilot Intune / Intune
    - [ ] Endpoint Protection: SCCM / Pilot Intune / Intune
    - [ ] Windows Update Policies: SCCM / Pilot Intune / Intune
    - [ ] Office Click-to-Run Apps: SCCM / Pilot Intune / Intune
    - [ ] Client Apps: SCCM / Pilot Intune / Intune
    - [ ] Resource Access: SCCM / Intune (note: deprecated in 2403+)
- [ ] CMG deployed for internet-based client management

---

### Licensing

**Current Microsoft 365 Licensing** (**Critical**):

- [ ] Microsoft 365 E3 (how many licenses: \_\_\_\_\_\_)
- [ ] Microsoft 365 E5 (how many licenses: \_\_\_\_\_\_)
- [ ] Microsoft 365 Business Premium (how many licenses: \_\_\_\_\_\_)
- [ ] EMS E3 or E5 only (standalone, no M365)
- [ ] Other: \_\_\_\_\_\_

**Current Intune Licensing**:

- [ ] Intune Plan 1 (bundled with M365 E3/E5)
- [ ] Intune Plan 2 (standalone add-on)
- [ ] Intune Suite (standalone add-on, $10/user/month)

**Microsoft Defender for Endpoint**:

- [ ] MDE Plan 1 (bundled with M365 E3)
- [ ] MDE Plan 2 (bundled with M365 E5 or standalone $5.20/user/month)
- [ ] Not licensed

**Power BI**:

- [ ] Power BI Pro licenses (how many: \_\_\_\_\_\_)
- [ ] Power BI Premium capacity
- [ ] No Power BI licensing

**Notes on licensing gaps** (e.g., need to procure Power BI Pro for custom reporting):

---

---

## Capability Area 1: Software Deployment & App Management

**Reference**: See [Software Deployment Assessment](software-deployment.md)

### Current SCCM Configuration

**Application Inventory** (**Critical**):

- Total applications deployed (Application Model): \_\_\_\_\_\_
- Total packages deployed (Package/Program model): \_\_\_\_\_\_
  - [ ] Using Application Model (recommended)
  - [ ] Using legacy Package/Program model
  - [ ] Migrating from Package/Program to Application Model in progress

**Application Complexity**:

- Applications with global conditions: \_\_\_\_\_\_
  - Average global conditions per app: \_\_\_\_\_\_
- Applications with dependencies: \_\_\_\_\_\_
  - Average dependency depth (levels): \_\_\_\_\_\_
  - Deepest dependency tree (how many levels): \_\_\_\_\_\_
- Applications with supersedence: \_\_\_\_\_\_
  - Longest supersedence chain (how many nodes): \_\_\_\_\_\_

**Third-Party Apps Requiring Deployment** (**Critical**):

- Number of third-party applications: \_\_\_\_\_\_
- Top 10 third-party apps by deployment frequency:
  1. ***
  2. ***
  3. ***
  4. ***
  5. ***
  6. ***
  7. ***
  8. ***
  9. ***
  10. ***

**App-V Virtualization** (**Critical** — App-V server EOL April 2026; client moves to extended support):

- [ ] Using App-V virtualization
  - Number of App-V packages: \_\_\_\_\_\_
  - [ ] App-V server deployed
  - [ ] App-V packages are business-critical (cannot be decommissioned by April 2026)
  - Estimated % App-V packages that are MSIX-compatible: \_\_\_\_\_\_

**Content Distribution**:

- [ ] Using cloud distribution points
- [ ] Using BranchCache
- [ ] Using peer cache
- [ ] Using Delivery Optimization (Windows 10/11 peer-to-peer)
- Number of boundary groups for content location: \_\_\_\_\_\_

**Phased Deployments**:

- [ ] Using phased deployments for applications
  - Number of phased deployments: \_\_\_\_\_\_
- [ ] Using automatic phase progression (or manual progression only)

### Migration Planning

**Application Migration Complexity Estimate**:

- Low-complexity apps (MSI, single detection rule, no dependencies): \_\_\_\_\_\_
- Medium-complexity apps (custom EXE, script detection, 1-2 dependencies): \_\_\_\_\_\_
- High-complexity apps (multi-component, deep dependencies, conditional logic): \_\_\_\_\_\_

**Migration Priority**:

- Applications to migrate first (low-complexity, high-frequency): **\*\*\*\***\_\_\_**\*\*\*\***
- Applications to migrate last (high-complexity, legacy): **\*\*\*\***\_\_\_**\*\*\*\***
- Applications to retire (no longer needed): \_\_\_\_\_\_

**Third-Party Patching Decision** (**Critical**):

- [ ] Deploy commercial solution (Patch My PC ~$2-4/device/year)
- [ ] Use Enterprise Application Management (Intune Suite, M365 E5 from July 2026)
- [ ] Use Win32 app supersedence (manual)
- [ ] Retain SCCM Software Updates workload via co-management for third-party patching

### Migration Notes

_Space for environment-specific notes, concerns, blockers:_

---

---

---

## Capability Area 2: Patch & Update Management

**Reference**: See [Patch Management Assessment](patch-management.md)

### Current SCCM Configuration

**Software Update Point (SUP)**:

- [ ] SUP role deployed and functional
- [ ] WSUS integration configured
- WSUS sync schedule: \_\_\_\_\_\_ (e.g., daily, weekly)
- Update classifications synchronized (check all):
  - [ ] Critical Updates
  - [ ] Security Updates
  - [ ] Definition Updates
  - [ ] Feature Updates
  - [ ] Drivers
  - [ ] Non-Security Updates

**Automatic Deployment Rules (ADRs)** (**Critical**):

- Number of ADRs: \_\_\_\_\_\_
- ADR deployment targets (check all):
  - [ ] Workstations
  - [ ] Servers
  - [ ] Both
- Typical deployment deadline: \_\_\_\_\_\_ days after Patch Tuesday

**Maintenance Windows** (**Critical**):

- [ ] Using maintenance windows for update installation
  - Number of collections with maintenance windows: \_\_\_\_\_\_
  - Typical maintenance window schedule: \_\_\_\_\_\_ (e.g., Sunday 2 AM - 6 AM)
  - [ ] Different maintenance windows for workstations vs. servers
  - [ ] Business-critical servers have specific maintenance windows

**Orchestration Groups** (**Critical** — No Intune Equivalent):

- [ ] Using orchestration groups for server clusters
  - Number of orchestration groups: \_\_\_\_\_\_
  - Cluster types (check all):
    - [ ] SQL Always On Availability Groups
    - [ ] Hyper-V clusters
    - [ ] Exchange DAG (Database Availability Groups)
    - [ ] Other: \_\_\_\_\_\_

**Third-Party Update Catalogs** (**Critical** — No Intune Equivalent):

- [ ] Using SCUP (System Center Updates Publisher) for third-party updates
  - Number of third-party update catalogs: \_\_\_\_\_\_
  - Top third-party products patched via SCUP:
    1. ***
    2. ***
    3. ***
    4. ***
    5. ***

**Pre/Post-Deployment Scripts** (**Critical** — No Intune Equivalent for Updates):

- [ ] Using pre-deployment scripts (e.g., stop service before update)
- [ ] Using post-deployment scripts (e.g., restart service after update)
  - Number of deployments with scripts: \_\_\_\_\_\_

### Migration Planning

**Server Update Strategy Decision** (**Critical**):

- [ ] Migrate on-premises standalone servers to Intune (no orchestration required)
- [ ] Migrate Azure VMs to Azure Automation Update Management (supports orchestration)
- [ ] Retain SCCM Software Updates workload for on-premises clustered servers
- [ ] Migrate workstations to Intune; retain servers in SCCM (hybrid model)

**Third-Party Patching Budget**:

- Estimated cost for Patch My PC (devices × $2-4/year): $\_\_\_\_\_\_
- [ ] Budget approved for third-party patching solution
- [ ] Defer third-party patching; retain SCCM workload via co-management

**Maintenance Window to Deployment Ring Mapping**:

- SCCM maintenance window schedule: \_\_\_\_\_\_
- Target Intune update ring schedule:
  - IT ring: Install immediately, deadline \_\_\_\_\_\_ days
  - 10% ring: Defer **_ days, deadline _** days
  - 50% ring: Defer **_ days, deadline _** days
  - 100% ring: Defer **_ days, deadline _** days

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 3: OS Deployment & Imaging

**Reference**: See [OS Deployment Assessment](os-deployment.md)

### Current SCCM Configuration

**OS Deployment Scenarios** (**Critical**):

- [ ] Bare-metal deployment (PXE boot, bootable media)
  - Number of bare-metal deployments per month: \_\_\_\_\_\_
- [ ] Refresh/wipe-and-load (in-place reprovision)
  - Number of refresh deployments per month: \_\_\_\_\_\_
- [ ] Replace/PC migration (user state migration)
  - Number of replace deployments per month: \_\_\_\_\_\_
- [ ] In-place upgrade (Windows 10 to 11, 21H2 to 22H2, etc.)
  - Number of in-place upgrades per month: \_\_\_\_\_\_

**Task Sequences** (**Critical** — No Intune Equivalent):

- [ ] Using task sequences for OS deployment
  - Number of task sequence templates: \_\_\_\_\_\_
  - Task sequence complexity (check one):
    - [ ] Low (10-20 steps: partition, apply image, install drivers, join domain)
    - [ ] Medium (20-40 steps: + custom scripts, conditional logic, application installation)
    - [ ] High (40+ steps: + dynamic computer naming, hardware-specific logic, multi-step validation)

**Custom OS Images** (**Critical** — No Intune Equivalent):

- [ ] Using custom WIM images (reference images)
  - Number of custom images maintained: \_\_\_\_\_\_
  - Image update frequency: \_\_\_\_\_\_ (e.g., monthly, quarterly)
  - Estimated time to build/update image: \_\_\_\_\_\_ hours

**User State Migration Tool (USMT)** (**Critical**):

- [ ] Using USMT for user profile migration
  - Average USMT package size: \_\_\_\_\_\_ GB
  - USMT success rate: \_\_\_\_\_\_% (check task sequence reports)
  - [ ] Migrating application settings (via custom USMT XML)
  - [ ] Migrating PST files (Outlook data files)
  - [ ] Migrating certificates

**Driver Packages**:

- [ ] Using driver packages for OS deployment
  - Number of driver packages: \_\_\_\_\_\_
  - Hardware models supported: \_\_\_\_\_\_ (e.g., Dell Latitude 5420, HP EliteBook 840 G8)
  - [ ] Using dynamic driver injection (WMI queries for hardware model)

**PXE Boot**:

- [ ] Using PXE boot for bare-metal deployment
  - Number of PXE-enabled distribution points: \_\_\_\_\_\_

**Bootable Media**:

- [ ] Creating bootable USB/DVD media for standalone deployment
  - Frequency of bootable media creation: \_\_\_\_\_\_ (e.g., monthly, as-needed)

### Migration Planning

**Scenario-Based Assessment** (**Critical**):

**New device procurement**:

- Estimated new devices per year: \_\_\_\_\_\_
- [ ] Migrate to Autopilot immediately (superior experience, lowest risk)
- [ ] Use OEM custom imaging service ($10-30/device)
- [ ] Retain SCCM for imaging new devices

**Device refresh (same user)**:

- Estimated device refreshes per year: \_\_\_\_\_\_
- [ ] Migrate to Autopilot Reset (simple profiles, OneDrive KFM coverage >80%)
- [ ] Retain SCCM for refresh (complex profiles, USMT required)

**Bare-metal imaging**:

- Estimated bare-metal deployments per year: \_\_\_\_\_\_
- [ ] Eliminate bare-metal imaging (OEM devices only)
- [ ] Use OEM custom imaging service
- [ ] Retain SCCM hybrid model (SCCM for imaging, Intune for management)
- [ ] Use MDT standalone for small-scale bare-metal (<50 devices/year)

**User State Migration Data Coverage Analysis** (**Critical**):

- Average user profile size: \_\_\_\_\_\_ GB
- Desktop/Documents/Pictures size: \_\_\_\_\_\_ GB (OneDrive KFM coverage)
- AppData size: \_\_\_\_\_\_ GB (application settings, not covered by OneDrive KFM)
- Other data size: \_\_\_\_\_\_ GB (custom locations, PST files)
- OneDrive KFM coverage %: \_\_\_\_\_\_% (Desktop+Documents+Pictures / Total profile size)
  - [ ] > 80% coverage: Good Autopilot candidate
  - [ ] 50-80% coverage: Moderate risk; evaluate third-party migration tool
  - [ ] <50% coverage: High risk; retain SCCM or accept data loss

**OEM Custom Imaging Decision**:

- [ ] Use OEM custom imaging service (Dell/HP/Lenovo)
  - Estimated cost (devices/year × $10-30): $\_\_\_\_\_\_
  - [ ] Budget approved
- [ ] Eliminate custom images entirely (start with OEM image, configure via Autopilot policies)

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 4: Compliance & Configuration Baselines

**Reference**: See [Compliance Baselines Assessment](compliance-baselines.md)

### Current SCCM Configuration

**Configuration Baselines** (**Critical**):

- Total configuration baselines: \_\_\_\_\_\_
- Configuration items (CIs) per baseline (average): \_\_\_\_\_\_
- Baseline complexity (check all):
  - [ ] Registry-based CIs (low complexity, 15-30 min migration per baseline)
  - [ ] File/WMI-based CIs (medium complexity, 30-60 min migration per baseline)
  - [ ] Script-based CIs (PowerShell, VBScript; medium-high complexity, 1-2 hours migration)
  - [ ] SQL/IIS-based CIs (high complexity, 2-4 hours migration per baseline)

**Top 5 Critical Baselines** (prioritize for migration):

1. ***
2. ***
3. ***
4. ***
5. ***

**Configuration Item Types**:

- Registry settings: \_\_\_\_\_\_
- File/folder settings: \_\_\_\_\_\_
- WMI queries: \_\_\_\_\_\_
- Script-based CIs: \_\_\_\_\_\_
- Active Directory queries: \_\_\_\_\_\_

**Remediation (Auto-Remediation)**:

- [ ] Using auto-remediation for configuration baselines
  - Number of baselines with auto-remediation enabled: \_\_\_\_\_\_

**Deployment Targets**:

- Average baseline deployment count (how many collections per baseline): \_\_\_\_\_\_
- Compliance percentage (check Configuration Baseline dashboard): \_\_\_\_\_\_%

### Migration Planning

**Baseline Migration Strategy**:

- [ ] Baseline-by-Baseline (incremental; 3-6 months; low risk)
- [ ] All-Baselines Cutover (greenfield; 4-8 weeks; higher risk)
- [ ] Security-First (Conditional Access enablement; 2-4 months; immediate security benefit)

**Conditional Access Enablement Priority** (**Critical** — Biggest Win):

- [ ] Migrate security baselines first (Windows Security, BitLocker, Defender, Firewall)
- [ ] Create Intune compliance policy aggregating security requirements
- [ ] Pilot Conditional Access with pilot group (Exchange Online access requires compliant device)
- [ ] Expand to production and add additional resources (SharePoint, Teams, SaaS apps)

**Baseline Inventory and Complexity Assessment**:

- Estimated total migration hours (baselines × complexity): \_\_\_\_\_\_ hours
  - Example calculation: 15 baselines × average 1.5 hours/baseline = 22.5 hours

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 5: Device Inventory & Asset Intelligence

**Reference**: See [Device Inventory Assessment](device-inventory.md)

### Current SCCM Configuration

**Hardware Inventory** (**Critical**):

- [ ] Using standard hardware inventory (default WMI classes)
- [ ] Using custom hardware inventory (configuration.mof extensions)
  - Number of custom WMI classes added: \_\_\_\_\_\_
  - Top 5 custom inventory items:
    1. ***
    2. ***
    3. ***
    4. ***
    5. ***

**Software Inventory**:

- [ ] Using software inventory (file collection)
  - Number of file collection rules: \_\_\_\_\_\_

**Software Metering** (**Critical** — No Intune Equivalent):

- [ ] Using software metering for license optimization
  - Number of software metering rules: \_\_\_\_\_\_
  - Applications metered for license compliance:
    1. ***
    2. ***
    3. ***
  - [ ] Software metering data used for vendor audits
  - [ ] Software metering data used for SAM (Software Asset Management)

**Asset Intelligence** (**Critical** — No Intune Equivalent):

- [ ] Using Asset Intelligence catalog synchronization
- [ ] Using Asset Intelligence reports for license management
- [ ] Using Asset Intelligence for software categorization

### Migration Planning

**Custom Hardware Inventory Decision** (**Critical**):

- [ ] Inventory custom WMI classes in configuration.mof
- [ ] Categorize as:
  - [ ] Available in Intune Properties Catalog (97 pre-defined properties)
  - [ ] Requires custom workaround (Proactive Remediations + Azure Log Analytics)
  - [ ] Accept data loss (not business-critical)
- [ ] Test Properties Catalog coverage before migration

**Software Metering Alternative** (**Critical**):

- [ ] Identify applications with active metering rules
- [ ] Document business processes dependent on usage data
- [ ] Evaluate third-party SAM tool (Flexera, Snow, Lansweeper ~$2-5/device/year)
- [ ] Accept capability loss (software metering not business-critical)

**Azure Log Analytics Budget** (for custom inventory workaround):

- Estimated custom inventory data size: \_\_\_\_\_\_ GB/month
- Estimated Azure Log Analytics cost (~$2.30/GB): $\_\_\_\_\_\_/month

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 6: Endpoint Protection & Security

**Reference**: See [Endpoint Protection Assessment](endpoint-protection.md)

### Current SCCM Configuration

**Endpoint Protection Site System Role**:

- [ ] Endpoint Protection site system role deployed
- [ ] SCCM managing Microsoft Defender Antivirus
- [ ] SCCM managing Windows Firewall

**Antimalware Policies**:

- Number of antimalware policies: \_\_\_\_\_\_
- Antimalware exclusions (list critical exclusions):
  - ***
  - ***
  - ***

**Microsoft Defender Exploit Guard**:

- [ ] Using Attack Surface Reduction (ASR) rules
  - Number of ASR rules enabled: \_\_\_\_\_\_
- [ ] Using Controlled Folder Access (ransomware protection)
- [ ] Using Exploit Protection
- [ ] Using Network Protection

**Microsoft Defender for Endpoint (MDE)**:

- [ ] MDE integrated with SCCM (tenant attach)
- [ ] MDE Plan 1 licensed (bundled with M365 E3)
- [ ] MDE Plan 2 licensed (bundled with M365 E5 or standalone)

### Migration Planning

**ASR Rule Deployment Strategy** (**Critical**):

- [ ] Deploy ASR rules in Audit mode for 30 days before Block mode
- [ ] Pilot ASR rules with IT/Security team (all Block mode immediately)
- [ ] Ring deployment timeline:
  - IT/Security (Pilot, all Block): Week 1-2
  - 10% users: Week 3-4 (after 2-week validation)
  - 50% users: Week 5-6
  - 100% users: Week 7-8

**MDE Integration and Conditional Access Preparation**:

- [ ] Confirm MDE Plan 1/2 licensing
- [ ] Define device risk thresholds for resource access:
  - Block access if device risk = High
  - Allow access if device risk = Medium/Low
- [ ] Test automatic onboarding with pilot group (100 devices) before tenant-wide enablement
- [ ] Train SOC analysts on MDE portal for incident response

**Policy Recreation**:

- [ ] Export SCCM antimalware policies
- [ ] Map to Intune Antivirus policy templates
- [ ] Verify exclusions migrate correctly
- [ ] Import GPO firewall rules or recreate in Intune Firewall policies

**Minimum Baselines to Deploy**:

- [ ] Windows 10/11 Security Baseline (all devices)
- [ ] MDE Baseline (all MDE-licensed devices)
- [ ] Edge Baseline (all devices with Edge)

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 7: Reporting & Analytics

**Reference**: See [Reporting & Analytics Assessment](reporting-analytics.md)

### Current SCCM Configuration

**SQL Server Reporting Services (SSRS)**:

- [ ] SSRS Reporting Services Point deployed
- [ ] Using built-in SCCM reports (400+ reports)
- [ ] Using custom reports created in Report Builder

**Custom Reports** (**Critical**):

- Number of custom reports: \_\_\_\_\_\_
- Top 20 most-used reports (check SSRS execution log):
  1. ***
  2. ***
  3. ***
  4. ***
  5. ***
  6. ***
  7. ***
  8. ***
  9. ***
  10. ***
  11. ***
  12. ***
  13. ***
  14. ***
  15. ***
  16. ***
  17. ***
  18. ***
  19. ***
  20. ***

**Report Subscriptions**:

- [ ] Using SSRS report subscriptions (scheduled email delivery)
  - Number of active subscriptions: \_\_\_\_\_\_

**CMPivot** (**Critical** — Partial Intune Equivalent):

- [ ] Using CMPivot for real-time device queries
  - CMPivot query frequency: \_\_\_\_\_\_ (e.g., daily, weekly, as-needed)
  - Common CMPivot query patterns:
    - ***
    - ***
    - ***

### Migration Planning

**Report Usage Audit** (**Critical**):

- [ ] Query SSRS execution log to identify top 20 most-run reports
- [ ] Categorize custom reports:
  - [ ] Intune built-in replacement available (no recreation needed)
  - [ ] Requires Power BI recreation
  - [ ] No longer needed (retire report)

**Power BI Report Migration**:

- [ ] Obtain Intune Data Warehouse OData feed URL
- [ ] Connect Power BI Desktop to Data Warehouse
- [ ] Recreate top 10 most-used reports in Power BI
- [ ] Leverage community templates (GitHub: microsoft/Intune-Data-Warehouse)
- [ ] Configure automatic daily refresh
- [ ] License report consumers with Power BI Pro ($10/user/month)

**Power BI Licensing Budget**:

- Number of report consumers requiring Power BI Pro: \_\_\_\_\_\_
- Estimated annual cost (users × $10/month × 12): $\_\_\_\_\_\_
- [ ] Budget approved for Power BI Pro licensing

**CMPivot Alternative Evaluation** (**Critical**):

- [ ] Use MDE Advanced Hunting (if MDE P2 licensed; real-time KQL queries for security scenarios)
- [ ] Use Intune Proactive Remediations (detection script runs every 1-24 hours; scheduled, not real-time)
- [ ] Accept Azure Log Analytics latency (15-minute lag; adequate for non-emergency queries)
- [ ] Retain SCCM co-management for CMPivot access

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 8: Remote Tools & Client Management

**Reference**: See [Remote Tools Assessment](remote-tools.md)

### Current SCCM Configuration

**Remote Control** (**Critical** — Significant Gap):

- [ ] Using SCCM Remote Control (unattended desktop access)
  - Remote control session frequency: \_\_\_\_\_\_ sessions/week
  - Critical use cases:
    - [ ] After-hours server maintenance (no user logged on)
    - [ ] Locked-out device recovery (user cannot log in)
    - [ ] Kiosk management (no user session)
    - [ ] Silent helpdesk support (connect without user awareness)

**Client Notifications**:

- [ ] Using client notifications for policy refresh, app evaluation, script execution

**Wake-on-LAN (WoL)** (**Critical** — No Intune Equivalent):

- [ ] Using Wake-on-LAN for sleeping/hibernating devices
  - WoL use cases:
    - [ ] Wake devices for scheduled software update installation windows
    - [ ] Wake devices for required task sequence deployments (OS deployment during off-hours)
    - [ ] Energy savings (allow devices to sleep during business hours)

**Power Management** (**Critical** — No Intune Equivalent):

- [ ] Using SCCM power management (centralized power plan deployment)
  - Power plan deployment targets (check all):
    - [ ] Desktops
    - [ ] Laptops
    - [ ] Servers
  - Business hours power plan: \_\_\_\_\_\_
  - Non-business hours power plan: \_\_\_\_\_\_
  - [ ] Energy savings initiative dependent on SCCM power management

**Run Scripts**:

- [ ] Using SCCM Run Scripts for on-demand PowerShell execution
  - Number of saved scripts: \_\_\_\_\_\_
  - Script execution frequency: \_\_\_\_\_\_ scripts/week

### Migration Planning

**Remote Control Alternative Decision** (**Critical**):

- [ ] Use Remote Help (user-present only; included in M365 E3 from July 2026)
  - Acceptable for \_\_\_\_\_\_ % of current remote control use cases
- [ ] Procure TeamViewer (unattended access support; third-party license required)
  - Estimated cost: $\_\_\_\_\_\_/year
- [ ] Retain SCCM co-management for Remote Tools workload
- [ ] Accept no unattended remote control (adjust helpdesk workflows)

**Wake-on-LAN Alternative Decision** (**Critical**):

- [ ] Retain SCCM for WoL-dependent deployments (co-management hybrid model)
- [ ] Deploy third-party network management tools (SolarWinds WoL, ManageEngine OpUtils)
- [ ] Use on-premises PowerShell WoL scripts (scheduled task on same subnet)
- [ ] Accept no WoL (adjust deployment windows to business hours; accept user disruption)

**Power Management Alternative Decision** (**Critical**):

- [ ] Use Group Policy for power management settings (domain-joined devices)
- [ ] Use Settings Catalog (limited CSP support; search for "Power")
- [ ] Use PowerShell scripts via Proactive Remediations (`powercfg.exe` configuration)
- [ ] Deploy third-party power management tools (1E NightWatchman, Dell KACE ~$2-5/device/year)
- [ ] Accept no power management (rely on Windows default power plans)

**Helpdesk Training**:

- [ ] Train helpdesk on Remote Help interface (differs from SCCM Remote Control Viewer)
- [ ] Document workflows: "How to connect to device via Remote Help" (step-by-step)
- [ ] If using TeamViewer, train on TeamViewer interface and unattended access
- Estimated training time per helpdesk technician: \_\_\_\_\_\_ hours

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 9: Infrastructure & Site Architecture

**Reference**: See [Infrastructure Assessment](infrastructure.md)

### Current SCCM Configuration

**Site Hierarchy** (**Critical** — Paradigm Shift):

- [ ] Standalone primary site
- [ ] Hierarchy with CAS
  - Primary sites: \_\_\_\_\_\_
  - Secondary sites: \_\_\_\_\_\_
  - Geographic distribution (list locations): **\*\*\*\***\_\_\_**\*\*\*\***

**Collections** (**Critical**):

- Total device collections: \_\_\_\_\_\_
- Total user collections: \_\_\_\_\_\_
- Query-based collections: \_\_\_\_\_\_
- Direct membership collections: \_\_\_\_\_\_
- Collections with maintenance windows: \_\_\_\_\_\_
- Most complex collection query (describe): **\*\*\*\***\_\_\_**\*\*\*\***

**RBAC (Role-Based Access Control)**:

- [ ] Using custom security roles (not just built-in roles)
  - Number of custom security roles: \_\_\_\_\_\_
- [ ] Using security scopes for resource isolation
  - Number of security scopes: \_\_\_\_\_\_
- [ ] Using collection-based permissions (restrict admin access to specific collections)

**Boundary Groups** (**Critical**):

- Number of boundary groups: \_\_\_\_\_\_
- Boundary group use cases (check all):
  - [ ] Content location (distribution point assignment)
  - [ ] Site assignment
  - [ ] Fallback relationships (primary DP fails, fallback to secondary DP)

### Migration Planning

**Accept the Paradigm Shift** (**Critical**):

- [ ] Leadership briefed: "SCCM site hierarchy has no Intune equivalent; this is architectural transformation"
- [ ] Budget allocated for administrator retraining (2-4 weeks per admin)
- [ ] Change management plan for "infrastructure ownership → cloud SLA dependency" cultural shift

**Collections to Groups/Filters Mapping** (**Critical**):

- [ ] Map query-based collections to Entra ID dynamic groups
- [ ] Map direct membership collections to Entra ID assigned groups
- [ ] Replace maintenance windows with Intune deployment ring schedules
- [ ] Rewrite collection queries from WQL to Entra ID query syntax

**Administrator Retraining Roadmap**:

- [ ] WQL to Entra ID query syntax (1 week training)
- [ ] Maintenance windows to Deployment rings (1 week training)
- [ ] Collections to Groups/Filters (1 week training)
- [ ] WMI to Graph API (1-2 weeks training)
- [ ] Infrastructure ownership to Cloud SLA dependency (cultural shift; ongoing)

**Disconnected Environments** (**Critical** — Blocker):

- [ ] Organization has disconnected environments (no internet access)
  - Number of disconnected devices: \_\_\_\_\_\_
  - [ ] Intune not viable for disconnected environments (SCCM retention required)

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Capability Area 10: Scripting, Automation & Extensibility

**Reference**: See [Scripting & Automation Assessment](scripting-automation.md)

### Current SCCM Configuration

**CMPivot** (**Critical** — Partial Intune Equivalent):

- [ ] Using CMPivot for real-time ad-hoc queries
  - CMPivot query frequency: \_\_\_\_\_\_ (e.g., daily, weekly, as-needed)
  - Common query patterns (list top 5):
    1. ***
    2. ***
    3. ***
    4. ***
    5. ***

**Run Scripts**:

- [ ] Using SCCM Run Scripts for on-demand execution
  - Number of saved scripts: \_\_\_\_\_\_
  - Script approval workflow in use: Yes / No

**ConfigMgr PowerShell Automation**:

- [ ] Using ConfigMgr PowerShell module for automation
  - Number of automation scripts: \_\_\_\_\_\_
  - Common automation tasks (check all):
    - [ ] Application deployment
    - [ ] Collection management
    - [ ] Device actions (restart, policy refresh)
    - [ ] Reporting
    - [ ] Compliance baseline deployment

**Task Sequence Variables** (**Critical** — OSD Complexity):

- [ ] Using task sequence variables for dynamic deployment logic
  - Number of task sequences using variables: \_\_\_\_\_\_
  - Common variable use cases:
    - [ ] Dynamic computer naming
    - [ ] Conditional app installation
    - [ ] Hardware-specific driver injection
    - [ ] Custom partitioning

**Configuration Items with Scripts**:

- [ ] Using script-based configuration items (PowerShell/VBScript detection + remediation)
  - Number of script-based CIs: \_\_\_\_\_\_

### Migration Planning

**CMPivot Alternative Decision** (**Critical**):

- [ ] Use MDE Advanced Hunting (MDE P2 required; real-time KQL for security scenarios)
- [ ] Use Intune Proactive Remediations (scheduled detection; hourly, daily, weekly)
- [ ] Use Graph API queries (PowerShell or REST; tenant-level data, not per-device real-time)
- [ ] Deploy Platform Script to specific device (assign to single-device group; ad-hoc troubleshooting)
- [ ] Ingest Intune data into Azure Log Analytics (KQL queries, Azure Monitor Workbooks; 15-min lag)
- [ ] Retain SCCM co-management for CMPivot access

**PowerShell Automation Migration** (ConfigMgr Module → Graph SDK):

- [ ] Inventory all ConfigMgr PowerShell automation scripts
- [ ] Identify common cmdlet translations:
  - `Get-CMDevice` → `Get-MgDeviceManagementManagedDevice`
  - `Get-CMCollection` → `Get-MgDeviceManagementDeviceGroup`
  - `New-CMCollection` → `New-MgGroup`
  - `Get-CMApplication` → `Get-MgDeviceAppManagementMobileApp`
- [ ] Allocate training time for OAuth authentication, permission scopes, filter syntax

**Configuration-as-Code Implementation Roadmap**:

- [ ] **Phase 1 (Immediate)**: Weekly backup via IntuneBackupAndRestore (disaster recovery)
- [ ] **Phase 2 (3-6 months)**: Version control via IntuneCD or Microsoft365DSC (store configs in Git)
- [ ] **Phase 3 (6-12 months)**: CI/CD pipeline for configuration deployment (test in UAT → deploy to production via pipeline)

### Migration Notes

_Space for environment-specific notes:_

---

---

---

## Migration Timeline and Budget

### Estimated Timeline

Based on environment complexity documented above:

**Phase 1: Enable Co-Management** (Weeks 1-4)

- Estimated effort: \_\_\_\_\_\_ hours

**Phase 2: Pilot Workloads** (Weeks 5-16)

- Compliance Policies + Endpoint Protection: \_\_\_\_\_\_ hours
- Windows Update Policies: \_\_\_\_\_\_ hours
- Estimated effort: \_\_\_\_\_\_ hours

**Phase 3: Full Transition** (Weeks 17-30+)

- Device Configuration: \_\_\_\_\_\_ hours
- Office Click-to-Run Apps: \_\_\_\_\_\_ hours
- Client Apps (incremental): \_\_\_\_\_\_ hours
- Estimated effort: \_\_\_\_\_\_ hours

**Total Estimated Migration Effort**: \_\_\_\_\_\_ hours

### Budget Summary

**Licensing** (annual):

- Microsoft 365 E3/E5 price increase (July 2026): $\_\_\_\_\_\_
- Power BI Pro licensing: $\_\_\_\_\_\_
- Third-party patching solution: $\_\_\_\_\_\_
- Third-party remote control solution: $\_\_\_\_\_\_
- Azure Log Analytics consumption: $\_\_\_\_\_\_
- Other: $\_\_\_\_\_\_

**Total Annual Licensing Add-Ons**: $\_\_\_\_\_\_

**Professional Services** (one-time):

- Migration consulting: $\_\_\_\_\_\_
- Power BI report recreation: $\_\_\_\_\_\_
- Administrator training: $\_\_\_\_\_\_
- Other: $\_\_\_\_\_\_

**Total One-Time Migration Costs**: $\_\_\_\_\_\_

**SCCM Infrastructure Savings** (annual):

- Site server hardware/hosting: $\_\_\_\_\_\_
- SQL Server licensing: $\_\_\_\_\_\_
- Distribution point infrastructure: $\_\_\_\_\_\_
- Administrator overhead reduction: $\_\_\_\_\_\_

**Total Annual Savings**: $\_\_\_\_\_\_

**Net 3-Year TCO Impact**: $\_\_\_\_\_\_

---

## Migration Readiness Summary

### Overall Readiness Assessment

Based on the inventory completed above:

- [ ] **High Readiness**: Majority of workloads can migrate to Intune within 6 months; minimal blockers
- [ ] **Moderate Readiness**: Some workloads can migrate immediately; others require co-management bridge or workarounds
- [ ] **Low Readiness**: Significant blockers (bare-metal imaging, orchestration groups, disconnected environments); long-term hybrid model required

### Key Blockers Identified

_List critical blockers that prevent full migration:_

1. ***
2. ***
3. ***

### Recommended Migration Approach

- [ ] **Full Migration**: All workloads migrate to Intune; decommission SCCM infrastructure
- [ ] **Hybrid Model (Long-Term)**: Migrate workstations to Intune; retain SCCM for servers, bare-metal imaging, third-party patching
- [ ] **Phased Migration**: Gradual workload-by-workload migration via co-management over 12-24 months

### Next Steps

_Action items based on this inventory:_

1. ***
2. ***
3. ***

---

## Document Control

**Last Updated**: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ (YYYY-MM-DD)
**Reviewed By**: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
**Approved By**: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

---

**Template End**
