# SCCM-to-Intune Co-Management Transition Guide

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**ConfigMgr Version**: Current Branch 2403+
**Intune Version**: Current production (February 2026)

---

## Section A — Quick Reference Card

### Co-Management Workload Sliders

During SCCM-to-Intune transition, co-management allows gradual migration via **workload sliders** that control which authority (SCCM or Intune) manages each capability area.

| #   | Workload                     | Slider Values                | Description                                                                                                                      | Recommended Transition Order                              |
| --- | ---------------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 1   | **Compliance Policies**      | SCCM → Pilot Intune → Intune | Device compliance baselines (BitLocker, firewall, antivirus, password policies). Required for Conditional Access.                | **Phase 1** (Weeks 1-6) — Enable zero-trust immediately   |
| 2   | **Device Configuration**     | SCCM → Pilot Intune → Intune | Configuration profiles, Settings Catalog policies, administrative templates (5,000+ settings).                                   | **Phase 2** (Weeks 7-12) — After compliance proven        |
| 3   | **Endpoint Protection**      | SCCM → Pilot Intune → Intune | Antivirus policies, ASR rules, firewall rules, MDE integration.                                                                  | **Phase 1** (Weeks 1-6) — Security priority               |
| 4   | **Windows Update Policies**  | SCCM → Pilot Intune → Intune | Quality updates, feature updates, driver updates via Windows Update for Business.                                                | **Phase 2** (Weeks 7-16) — After security baseline proven |
| 5   | **Office Click-to-Run Apps** | SCCM → Pilot Intune → Intune | Microsoft 365 Apps deployment and update channel management.                                                                     | **Phase 3** (Weeks 17-24) — Low risk, gradual rollout     |
| 6   | **Client Apps**              | SCCM → Pilot Intune → Intune | Win32 apps, LOB apps, Store apps, scripts.                                                                                       | **Phase 3** (Weeks 17-30+) — Largest migration effort     |
| 7   | **Resource Access** ⚠️       | SCCM → Intune (deprecated)   | VPN, Wi-Fi, email, certificates. **Note**: Deprecated in ConfigMgr 2403; slider removed. Must migrate before upgrading to 2403+. | **Phase 1** (Immediate) — Prerequisite for 2403 upgrade   |

### Critical Prerequisites

Before sliding any workloads to Intune:

- ✅ **Entra Hybrid Join**: All co-managed devices must be Entra Hybrid Joined (Azure AD registered + on-premises AD joined)
- ✅ **Intune Licensing**: All users assigned M365 E3/E5 or equivalent Intune license
- ✅ **Cloud Management Gateway (CMG) or VPN**: Internet-based devices must connect to SCCM via CMG or VPN
- ✅ **Intune Auto-Enrollment**: GPO configured to auto-enroll Entra Hybrid Joined devices in Intune
- ✅ **Resource Access Slider = Intune**: **Mandatory for ConfigMgr 2403+**; upgrade blocked if slider not set to Intune

⚠️ **ConfigMgr 2403+ Breaking Change**: The Resource Access slider is removed in version 2403. Organizations on ConfigMgr 2203 or earlier must migrate Resource Access policies to Intune **before** upgrading to 2403. Upgrade prerequisite check will block if Resource Access policies still exist in SCCM.

### Recommended Transition Sequence

**Priority Order** (fastest value, lowest risk):

1. **Compliance Policies** + **Endpoint Protection** (Weeks 1-6) — Enable Conditional Access and unified MDE management
2. **Device Configuration** (Weeks 7-12) — Settings Catalog migration
3. **Windows Update Policies** (Weeks 7-16) — Microsoft updates to WUfB; deploy third-party patching solution
4. **Office Click-to-Run Apps** (Weeks 17-24) — M365 Apps channel management
5. **Client Apps** (Weeks 17-30+) — Largest effort; migrate incrementally per application

**Long-Term Retention Candidates** (retain in SCCM via co-management):

- **Software Updates**: If third-party patching solution not deployed or orchestration groups required for server clusters
- **OS Deployment**: If bare-metal imaging or complex task sequence workflows required (note: not a workload slider; SCCM infrastructure retained)

---

## Section B — Full Transition Guide

### Understanding Co-Management Workloads

Co-management creates **dual management** where devices are managed by both SCCM and Intune simultaneously. Workload sliders control **authority** (which system is authoritative for policy delivery) per capability area.

**Slider Positions**:

- **Configuration Manager**: SCCM is authoritative; Intune policies ignored
- **Pilot Intune**: Pilot collection (defined in co-management settings) receives Intune policies; all other devices receive SCCM policies
- **Intune**: All co-managed devices receive Intune policies; SCCM policies ignored

**Key Principle**: Sliders control **which policies apply**, not which system can **see** the device. Devices remain visible in both SCCM and Intune consoles regardless of slider position.

---

### Workload-Specific Transition Guidance

#### Workload 1: Compliance Policies

**What Changes When Slider Moves to Intune**:

- SCCM configuration baselines stop evaluating on devices
- Intune compliance policies begin evaluating (BitLocker, firewall, antivirus, password, encryption)
- Compliance status flows to Entra ID for Conditional Access enforcement
- Devices report compliance to Intune console (not SCCM console)

**Policy Overlap Risks**:

- **Risk**: SCCM baseline enforces BitLocker XTS-AES-128; Intune policy enforces XTS-AES-256. Device non-compliant after slider flip.
- **Mitigation**: Deploy Intune compliance policies **before** flipping slider. Allow 24-48 hours for evaluation. Verify 100% compliance in Intune console. Only then flip slider.

**Pilot Collection Strategy**:

- **Pilot size**: 50-100 devices (5-10% of total)
- **Pilot composition**: IT team devices (10-20) + representative user departments (30-80)
- **Pilot duration**: 2-4 weeks
- **Success criteria**: 95%+ compliance rate, zero helpdesk escalations, Conditional Access functional

**Validation Steps**:

1. Deploy Intune compliance policies to pilot collection (via Entra ID group matching pilot collection)
2. Monitor Intune compliance dashboard for 7 days (verify all policies evaluate successfully)
3. Flip slider to "Pilot Intune"
4. Force SCCM policy refresh on pilot devices: `Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"`
5. Verify devices show "Co-managed" in Intune console
6. Enable Conditional Access for pilot group (Exchange Online access requires compliant device)
7. Test non-compliance scenario (disable BitLocker, verify access blocked, re-enable, verify access restored)
8. Expand to production: Flip slider to "Intune" after 2-4 week pilot success

**Conditional Access Enablement** (Primary Benefit):

- Create Conditional Access policy: "All users → Exchange Online → Require compliant device"
- Enable for pilot group only during validation
- Expand to production after pilot success
- **Value**: Non-compliant devices blocked from email access; user self-service remediation via Company Portal

**Cross-References**:

- See [Compliance Baselines Assessment](compliance-baselines.md) for detailed SCCM baseline to Intune policy mapping
- See [Endpoint Protection Assessment](endpoint-protection.md) for security baseline migration

---

#### Workload 2: Device Configuration

**What Changes When Slider Moves to Intune**:

- SCCM client settings, configuration items stop applying
- Intune configuration profiles and Settings Catalog policies apply
- Administrative templates (ADMX-backed GPOs) managed via Intune Settings Catalog
- Devices receive policies from Intune management extension (IME) instead of SCCM client

**Policy Overlap Risks**:

- **Risk**: SCCM client setting configures remote desktop port 3389; Intune Settings Catalog configures port 3390. Device switches ports after slider flip; existing RDP sessions break.
- **Mitigation**: Audit all SCCM client settings and configuration items. Map to equivalent Intune Settings Catalog settings. Deploy Intune policies **before** slider flip. Validate no configuration drift.

**Pilot Collection Strategy**:

- **Pilot size**: 100-200 devices (10-20% of total)
- **Pilot composition**: Same pilot collection as Compliance Policies (continuity)
- **Pilot duration**: 4-6 weeks (longer than Compliance due to breadth of settings)
- **Success criteria**: Zero configuration drift, user-reported issues <1%, settings apply within 8 hours

**Validation Steps**:

1. Export all SCCM client settings: `Get-CMClientSetting | Export-Csv C:\Temp\sccm-client-settings.csv`
2. Map each setting to Intune Settings Catalog equivalent (use Microsoft documentation or community mapping guides)
3. Create Intune configuration profiles for each setting group (recommend 5-10 profiles max for manageability)
4. Deploy to pilot Entra ID group
5. Validate settings applied: Use Intune device configuration report or Proactive Remediation detection script
6. Flip slider to "Pilot Intune"
7. Monitor for 4 weeks; address any configuration drift or user-reported issues
8. Expand to production: Flip slider to "Intune"

**Settings Catalog Advantage**:

- 5,000+ settings vs. ~200 SCCM client settings
- Search and discovery (easier than navigating SCCM client settings hierarchy)
- Dependency awareness (Settings Catalog warns about conflicting settings)
- Documentation integration (each setting links to Microsoft docs)

**Cross-References**:

- See [Scripting & Automation Assessment](scripting-automation.md) for Settings Catalog overview

---

#### Workload 3: Endpoint Protection

**What Changes When Slider Moves to Intune**:

- SCCM Endpoint Protection policies (antivirus, firewall, ASR) stop applying
- Intune Endpoint Security policies apply
- Microsoft Defender for Endpoint (MDE) onboarding automated via Intune
- Tamper Protection managed centrally (prevents local admin override)
- Security baselines (Windows Security, MDE, Edge) available

**Policy Overlap Risks**:

- **Risk**: SCCM antimalware policy sets exclusion `C:\Temp\*`; Intune antivirus policy has no exclusion. Slider flip causes performance issues if `C:\Temp\` has high file activity.
- **Mitigation**: Export SCCM antimalware policies. Map exclusions, scan schedules, real-time protection settings to Intune antivirus policies. Deploy Intune policies **before** slider flip. Verify exclusions applied via MDE Security Center.

**Pilot Collection Strategy**:

- **Pilot size**: 50-100 devices (5-10% of total; security-sensitive pilot)
- **Pilot composition**: IT security team devices (20-30) + high-security user group (20-70)
- **Pilot duration**: 2-4 weeks
- **Success criteria**: Zero malware detection gaps, ASR rules functional, MDE onboarding 100%

**Validation Steps**:

1. Export SCCM Endpoint Protection policies: Review antimalware policy settings, export exclusions/schedules
2. Create Intune antivirus policy (Endpoint Security > Antivirus) matching SCCM settings
3. Create ASR policy (Endpoint Security > Attack Surface Reduction) — **deploy in Audit mode first**
4. Enable MDE tenant-wide onboarding toggle (Endpoint Security > Microsoft Defender for Endpoint > Windows 10 and later > Connect Windows devices to Microsoft Defender for Endpoint)
5. Deploy policies to pilot Entra ID group
6. Monitor MDE Security Center for pilot device onboarding (should complete within 1 hour)
7. Flip slider to "Pilot Intune"
8. Validate ASR rules in Audit mode for 30 days (review blocked events in MDE portal)
9. Switch ASR rules from Audit to Block mode
10. Expand to production: Flip slider to "Intune" after pilot success

**MDE Integration Benefits** (Primary Advantage):

- **Risk-based Conditional Access**: Block access to corporate resources if device risk level = High
- **Vulnerability Management**: MDE assesses device vulnerabilities, creates remediation tasks in Intune
- **EDR Integration**: Endpoint detection and response without separate deployment
- **Tamper Protection**: Central management; prevents users from disabling Defender

**ASR Deployment Best Practice**:

- **Phase 1**: Deploy all ASR rules in Audit mode (0-30 days)
- **Phase 2**: Analyze audit events in MDE portal; identify false positives; add exclusions
- **Phase 3**: Switch to Block mode for non-disruptive rules (rules with zero or low audit events)
- **Phase 4**: Switch remaining rules to Block mode after exclusion tuning

**Cross-References**:

- See [Endpoint Protection Assessment](endpoint-protection.md) for full ASR rule guidance and security baseline details

---

#### Workload 4: Windows Update Policies

**What Changes When Slider Moves to Intune**:

- SCCM software update deployments (ADRs, SUGs, maintenance windows) stop applying
- Intune Windows Update for Business policies apply (update rings, feature update policies)
- Devices download updates from Microsoft CDN (not SCCM distribution points)
- Delivery Optimization for peer-to-peer caching (replaces SCCM peer cache)

**Policy Overlap Risks**:

- **Risk**: SCCM maintenance window allows updates Sunday 2 AM - 6 AM; Intune active hours block updates 6 AM - 10 PM. Devices never install updates (maintenance window outside active hours).
- **Mitigation**: Map SCCM maintenance windows to Intune update ring schedules. SCCM maintenance window 2 AM - 6 AM = Intune active hours 6 AM - 10 PM + deadline 7 days. Update ring installs outside active hours (10 PM - 6 AM).

**Pilot Collection Strategy**:

- **Pilot size**: 100-200 devices (10-20% of total)
- **Pilot composition**: IT team devices (early adopter ring) + representative users (broad ring)
- **Pilot duration**: 6-12 weeks (cover 2-3 Patch Tuesday cycles)
- **Success criteria**: 95%+ devices compliant within 7 days of Patch Tuesday, user disruption <2% (restart complaints)

**Validation Steps**:

1. Audit SCCM ADRs: Document classification filters (Critical, Security, Definition Updates), deployment deadlines, maintenance windows
2. Create Intune update rings (recommend 4 rings: IT → 10% → 50% → 100%)
   - **IT ring**: Install immediately, deadline 3 days
   - **10% ring**: Defer 3 days, deadline 7 days
   - **50% ring**: Defer 7 days, deadline 10 days
   - **100% ring**: Defer 10 days, deadline 14 days
3. Create feature update policy (target specific Windows version, e.g., Windows 11 23H2)
4. Deploy update rings to pilot Entra ID groups
5. Monitor Windows Update for Business reports (Intune > Reports > Windows updates)
6. Flip slider to "Pilot Intune" **after** first Patch Tuesday cycle proven (usually month 2 of pilot)
7. Monitor for 2-3 additional Patch Tuesday cycles
8. Expand to production: Flip slider to "Intune"

**Third-Party Patching Gap**:

- **SCCM Capability**: SCUP for third-party updates (Java, Adobe, browsers, etc.)
- **Intune Gap**: No native third-party patching
- **Remediation**: Deploy commercial solution (Patch My PC ~$2-4/device/year) or Enterprise App Management (Intune Suite, M365 E5 from July 2026, ~100 apps)
- **Co-Management Bridge**: Retain SCCM Software Updates workload for third-party patching; flip Windows Update Policies slider to Intune for Microsoft updates only

**Server Update Strategy**:

- **Orchestration Groups**: SCCM capability for sequenced updates on SQL clusters, Hyper-V clusters, Exchange DAG. No Intune equivalent.
- **Recommendation**: Retain SCCM Software Updates workload for on-premises servers; migrate workstations to Intune
- **Alternative**: Azure Automation Update Management for Azure VMs (supports orchestration, pre/post scripts)

**Cross-References**:

- See [Patch Management Assessment](patch-management.md) for detailed WUfB configuration and third-party patching alternatives

---

#### Workload 5: Office Click-to-Run Apps

**What Changes When Slider Moves to Intune**:

- SCCM Microsoft 365 Apps deployments stop managing update channel and version
- Intune Microsoft 365 Apps policies control update channel (Current Channel, Monthly Enterprise, Semi-Annual Enterprise)
- Office updates delivered via Office CDN (not SCCM distribution points)
- Update deadlines enforced via Settings Catalog policy

**Policy Overlap Risks**:

- **Risk**: SCCM deploys Office 2021 perpetual license; Intune policy targets Microsoft 365 Apps subscription. Conflict causes update failures.
- **Mitigation**: This workload applies only to Microsoft 365 Apps (Click-to-Run), not Office 2019/2021 perpetual. If using perpetual Office, do not flip slider. If migrating to M365 Apps, uninstall perpetual Office via SCCM, deploy M365 Apps via Intune, then flip slider.

**Pilot Collection Strategy**:

- **Pilot size**: 50-100 devices
- **Pilot duration**: 4-8 weeks (cover 1-2 Office update cycles)
- **Success criteria**: Office updates deploy within SLA (7-14 days), zero user-reported Office breakage

**Validation Steps**:

1. Verify all devices have Microsoft 365 Apps (not Office 2019/2021 perpetual)
2. Create Intune policy: Settings Catalog > "Microsoft Office" > Update Channel = Current Channel
3. Create update deadline policy: Settings Catalog > "Microsoft Office" > Update Deadline = 7 days
4. Deploy to pilot Entra ID group
5. Monitor Office update compliance (Intune > Apps > Monitor > Discovered apps > Filter "Microsoft 365 Apps")
6. Flip slider to "Pilot Intune"
7. Validate Office continues updating on schedule
8. Expand to production: Flip slider to "Intune"

**Cross-References**:

- See [Software Deployment Assessment](software-deployment.md) for Microsoft 365 Apps deployment guidance

---

#### Workload 6: Client Apps

**What Changes When Slider Moves to Intune**:

- SCCM application deployments stop installing/updating apps
- Intune Win32 apps, LOB apps, Store apps, scripts apply
- Application supersedence managed via Intune (10-node limit per chain)
- Software Center replaced by Company Portal

**Policy Overlap Risks**:

- **Risk**: SCCM deploys 7-Zip 19.00; Intune deploys 7-Zip 24.08. Both apps attempt installation; version conflict.
- **Mitigation**: Migrate applications **incrementally** (5-10 apps at a time). For each app: Package as Win32 app in Intune, deploy to pilot group, validate installation success, flip SCCM deployment to "Available" (not Required), monitor for 2 weeks, retire SCCM deployment, expand Intune deployment to production.

**Pilot Collection Strategy**:

- **Pilot size**: 50-100 devices (application pilot, not workload slider pilot)
- **Pilot duration**: 6-12 months (longest migration effort; incremental app-by-app migration)
- **Success criteria**: 95%+ installation success rate per app, user experience equivalent to SCCM Software Center

**Validation Steps** (Per Application):

1. **Package**: Create Win32 app (.intunewin) using Microsoft Win32 Content Prep Tool
2. **Configure**: Detection rules (MSI product code, file version, registry key), requirements rules (OS, architecture, disk space), install/uninstall commands
3. **Deploy to Pilot**: Assign to pilot Entra ID group (Required assignment)
4. **Validate**: Monitor Intune > Apps > Windows apps > [App name] > Device install status (should show 100% success)
5. **Retire SCCM Deployment**: Change SCCM deployment from "Required" to "Available" (preserve fallback for issues)
6. **Monitor**: 2-week observation period (zero SCCM Software Center installs = users not seeking fallback)
7. **Expand to Production**: Assign Intune app to production Entra ID group (Required)
8. **Retire SCCM Fully**: Delete SCCM application after 30-60 days production success

**Application Migration Complexity**:

- **Low complexity** (15-30 min per app): MSI packages, single detection rule, no dependencies
- **Medium complexity** (1-2 hours per app): Custom installer (EXE with transforms), PowerShell detection script, 1-2 dependencies
- **High complexity** (4-8 hours per app): Multi-component apps, deep dependency trees (>3 levels), conditional logic, user/device context differences

**Application Portfolio Prioritization**:

1. **Migrate first**: Low-complexity apps, high-deployment frequency apps (e.g., browsers, productivity tools)
2. **Migrate middle**: Medium-complexity apps, LOB apps with moderate user base
3. **Migrate last**: High-complexity apps, legacy apps, apps with deep SCCM integration (e.g., apps using task sequence variables)
4. **Consider retention**: Apps with unsupportable complexity (Package/Program model with no MSI/EXE equivalent)

**Global Conditions Gap**:

- **SCCM Capability**: Reusable global conditions library (e.g., "Check if BitLocker enabled" used by 50 applications)
- **Intune Gap**: No global conditions; requirements rules configured per app
- **Remediation**: Create PowerShell script library in source control (Git); copy/paste detection scripts across apps; use IntuneWin32App PowerShell module for automated app creation via Graph API

**Cross-References**:

- See [Software Deployment Assessment](software-deployment.md) for detailed Win32 app packaging, supersedence, and dependency guidance

---

#### Workload 7: Resource Access (Deprecated)

**What Changes When Slider Moves to Intune**:

- SCCM VPN, Wi-Fi, email, certificate profiles stop deploying
- Intune VPN, Wi-Fi, email, certificate profiles apply
- Devices receive profiles from Intune management extension

**Policy Overlap Risks**:

- **Risk**: SCCM VPN profile connects to `vpn.contoso.com`; Intune VPN profile connects to `vpn-new.contoso.com`. Slider flip breaks existing VPN connections.
- **Mitigation**: Deploy Intune VPN/Wi-Fi profiles **before** slider flip. Validate connectivity. Only then flip slider. Users may need to reconnect to Wi-Fi/VPN after profile switches.

**⚠️ ConfigMgr 2403+ Deprecation**:

- **Breaking Change**: Resource Access policies node removed from ConfigMgr 2403+ console
- **Upgrade Blocker**: ConfigMgr upgrade to 2403+ blocked if Resource Access slider not set to Intune
- **Prerequisite Check Warning**: "Slide Co-Management workload slider for resource access policies towards Intune"
- **Action Required**: All organizations on ConfigMgr 2203 or earlier **must** migrate Resource Access policies to Intune **before** upgrading to 2403

**Migration Steps** (Required Before ConfigMgr 2403 Upgrade):

1. **Inventory**: Export all SCCM VPN, Wi-Fi, email, certificate profiles
2. **Recreate in Intune**:
   - VPN: Intune > Devices > Configuration profiles > Create > VPN
   - Wi-Fi: Intune > Devices > Configuration profiles > Create > Wi-Fi
   - Email: Intune > Devices > Configuration profiles > Create > Email
   - Certificates: Intune > Devices > Configuration profiles > Create > Trusted certificate / SCEP / PKCS
3. **Deploy to Production**: Assign Intune profiles to all user/device groups
4. **Validate**: Verify connectivity (VPN connects, Wi-Fi connects, email syncs, certificates deploy)
5. **Flip Slider to Intune**: Co-management settings > Resource Access slider > Intune
6. **Delete SCCM Policies**: Remove Resource Access policies from SCCM console
7. **Upgrade to 2403+**: Prerequisite check will pass

**Cloud PKI Alternative** (Intune Suite, M365 E5 from July 2026):

- Replaces on-premises SCEP/NDES infrastructure
- Automated certificate lifecycle management (issue, renew, revoke)
- Eliminates NDES server maintenance

**Cross-References**:

- See [Infrastructure Assessment](infrastructure.md) for Cloud PKI overview

---

### Phased Migration Timeline

#### Phase 1: Enable Co-Management (Weeks 1-4)

**Objectives**:

- Enable SCCM co-management with all sliders initially set to SCCM
- Establish dual-management foundation
- Validate Entra Hybrid Join, CMG, Intune auto-enrollment

**Tasks**:

1. Verify prerequisites: Entra Hybrid Join, Intune licensing, CMG or VPN connectivity
2. Configure GPO for Intune auto-enrollment (Entra Hybrid Joined devices)
3. Enable co-management in SCCM console (Administration > Cloud Services > Co-management)
4. Configure co-management settings: Enable auto-enrollment, select pilot collection (50-100 devices)
5. Validate pilot devices show "Co-managed" in both SCCM and Intune consoles
6. **Migrate Resource Access policies to Intune** (required for ConfigMgr 2403+ upgrade); flip Resource Access slider to Intune
7. All other sliders remain at "Configuration Manager"

**Success Criteria**:

- 100% of pilot devices co-managed (visible in both consoles)
- Resource Access slider = Intune (ConfigMgr 2403+ prerequisite met)
- Zero user impact (no settings changes; SCCM still authoritative for all workloads)

---

#### Phase 2: Pilot Workloads (Weeks 5-16)

**Objectives**:

- Flip 3 sliders to "Pilot Intune": Compliance Policies, Endpoint Protection, Windows Update Policies
- Enable Conditional Access for pilot group
- Validate security baseline and patch management

**Tasks**:

1. **Compliance Policies** (Weeks 5-10):
   - Deploy Intune compliance policies to pilot group
   - Flip slider to "Pilot Intune"
   - Enable Conditional Access (Exchange Online requires compliant device)
   - Validate 95%+ compliance rate
2. **Endpoint Protection** (Weeks 5-10):
   - Deploy Intune antivirus, firewall, ASR policies to pilot group
   - Enable MDE tenant-wide onboarding
   - Flip slider to "Pilot Intune"
   - Validate MDE onboarding 100%, ASR rules functional
3. **Windows Update Policies** (Weeks 7-16):
   - Create update rings (IT, 10%, 50%, 100%)
   - Deploy to pilot group
   - Flip slider to "Pilot Intune" after first Patch Tuesday cycle proven
   - Validate 95%+ devices compliant within 7 days of Patch Tuesday

**Success Criteria**:

- Conditional Access functional (non-compliant devices blocked, compliant devices granted access)
- MDE integration operational (risk scores visible, vulnerability management active)
- Patch compliance ≥95% within SLA

---

#### Phase 3: Full Transition (Weeks 17-30+)

**Objectives**:

- Flip all sliders to "Intune" (remove pilot collections)
- Migrate Device Configuration, Office Click-to-Run Apps, Client Apps
- Retire SCCM infrastructure (optional; or retain for specific workloads)

**Tasks**:

1. **Device Configuration** (Weeks 17-22):
   - Map SCCM client settings to Settings Catalog
   - Deploy Intune configuration profiles to all devices
   - Flip slider to "Intune"
2. **Office Click-to-Run Apps** (Weeks 23-26):
   - Deploy Microsoft 365 Apps update policies
   - Flip slider to "Intune"
3. **Client Apps** (Weeks 17-30+):
   - Migrate applications incrementally (5-10 apps every 2 weeks)
   - Flip slider to "Intune" after 50%+ applications migrated
   - Continue app migration for 6-12 months total
4. **Optional**: Retire SCCM infrastructure
   - If all workloads migrated, decommission SCCM site servers, SQL Server, distribution points
   - If retaining specific workloads (third-party patching, server management, bare-metal imaging), maintain SCCM infrastructure in hybrid model

**Success Criteria**:

- All co-managed devices receive 100% of policies from Intune
- User experience equivalent to SCCM (Company Portal replaces Software Center)
- Helpdesk ticket volume stable or decreased

---

### Prerequisites Checklist

Before enabling co-management, verify all prerequisites:

#### Identity and Enrollment

- [ ] **Entra Hybrid Join**: All devices are Entra Hybrid Joined (Azure AD registered + on-premises AD joined)
  - Verify: `dsregcmd /status` on device; check "AzureAdJoined : YES" and "DomainJoined : YES"
- [ ] **Intune Auto-Enrollment GPO**: Group Policy configured to auto-enroll Entra Hybrid Joined devices
  - GPO: Computer Configuration > Policies > Administrative Templates > Windows Components > MDM > "Enable automatic MDM enrollment using default Azure AD credentials"
- [ ] **Intune Licensing**: All users assigned M365 E3/E5 or standalone Intune license
  - Verify: Microsoft 365 admin center > Users > Active users > Licenses

#### Connectivity

- [ ] **Cloud Management Gateway (CMG)**: Deployed and functional for internet-based clients
  - Verify: SCCM console > Administration > Cloud Services > Cloud Management Gateway > Status = "Ready"
  - Alternative: VPN connectivity for internet-based clients
- [ ] **HTTPS Communication**: SCCM site configured for HTTPS (Enhanced HTTP minimum; PKI certificates recommended)
  - Verify: SCCM console > Administration > Site Configuration > Sites > Properties > Communication Security

#### SCCM Configuration

- [ ] **SCCM Version**: Current Branch version 1710 or later (2403+ recommended)
  - Verify: SCCM console > Administration > Site Configuration > Sites > Version column
- [ ] **SCCM Client Version**: Version 1710 or later on all devices
  - Verify: SCCM console > Assets and Compliance > Devices > Client Version column
- [ ] **Azure AD Tenant**: SCCM site connected to Azure AD tenant
  - Verify: SCCM console > Administration > Cloud Services > Azure Services > "Cloud Management" service added

#### Resource Access (ConfigMgr 2403+ Requirement)

- [ ] **Resource Access Slider = Intune**: **Mandatory for ConfigMgr 2403+ upgrade**
  - Verify: SCCM console > Administration > Cloud Services > Co-management > Resource Access slider = "Intune"
  - Action: Migrate VPN, Wi-Fi, email, certificate profiles to Intune before upgrading to 2403

---

### Policy Overlap Guidance

**Golden Rule**: Deploy Intune policies **before** flipping workload sliders. This prevents policy gaps and configuration drift.

#### Recommended Workflow

**Step 1: Deploy Intune Policies (Do Not Flip Slider)**

- Create Intune policies for target workload
- Assign to pilot Entra ID group (or all devices for full migration)
- Wait 24-48 hours for policies to evaluate

**Step 2: Validate No Configuration Drift**

- Compare device configuration before/after Intune policy deployment
- Use Intune device configuration report or Proactive Remediation detection script
- Verify Intune policies apply successfully (no errors in Intune console)

**Step 3: Flip Workload Slider**

- Co-management settings > Workloads > Move slider to "Pilot Intune" or "Intune"
- SCCM policies stop applying; Intune policies become authoritative
- Devices refresh policy within 8 hours (force refresh: `Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"`)

**Step 4: Monitor for 2-4 Weeks**

- Watch Intune compliance/configuration reports
- Monitor helpdesk ticket volume (look for user-reported issues related to policy changes)
- Address any configuration drift or policy conflicts

#### Common Policy Conflicts

| SCCM Setting                      | Intune Setting            | Conflict Impact                              | Resolution                                                                                |
| --------------------------------- | ------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Maintenance window 2 AM - 6 AM    | Active hours 6 AM - 10 PM | Updates never install (outside both windows) | Set Intune active hours 6 AM - 10 PM; updates install 10 PM - 6 AM (outside active hours) |
| BitLocker XTS-AES-128             | BitLocker XTS-AES-256     | Device non-compliant after slider flip       | Migrate to XTS-AES-256 in SCCM first, validate, then flip slider                          |
| Antimalware exclusion `C:\Temp\*` | No exclusion              | Performance degradation after slider flip    | Add exclusion to Intune antivirus policy before slider flip                               |
| RDP port 3389                     | RDP port 3390             | Existing RDP sessions break                  | Align ports before slider flip or accept session interruption                             |

---

### Monitoring and Rollback Procedures

#### Monitoring Co-Management Status

**SCCM Console**:

- Administration > Cloud Services > Co-management > Co-management dashboard
- Shows per-workload distribution (how many devices SCCM vs. Intune authoritative)
- Device-level view: Assets and Compliance > Devices > Co-management column

**Intune Console**:

- Devices > Monitor > Co-management
- Shows enrollment status, workload authority per device
- Compliance dashboard shows compliance trends after slider flip

**Microsoft Endpoint Manager admin center**:

- Tenant administration > Tenant status > Co-management status
- High-level overview of co-managed device count

#### Rollback Procedures

**Emergency Rollback** (Immediate; <5 minutes):

1. SCCM console > Administration > Cloud Services > Co-management > Properties
2. Workloads tab > Move slider back to "Configuration Manager"
3. Devices revert to SCCM policy authority within 8 hours (or force policy refresh)
4. No user intervention required; SCCM policies automatically reapply

**Planned Rollback** (Recommended; 24-48 hours):

1. Communicate to users: "Policy rollback scheduled; expect settings changes"
2. Move slider to "Configuration Manager"
3. Force SCCM policy refresh on all devices: `Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"`
4. Validate SCCM policies reapplied (check compliance baselines, configuration items)
5. Post-rollback root cause analysis: Why did Intune policies fail? Address before re-attempting migration.

**Partial Rollback** (Pilot Issues):

1. If pilot group experiences issues, move slider from "Pilot Intune" to "Configuration Manager"
2. Pilot devices revert to SCCM policies
3. Production devices unaffected (never moved to Intune)
4. Troubleshoot pilot issues, re-deploy Intune policies, re-attempt pilot

---

### Cross-References to Assessment Documents

Each workload slider corresponds to one or more capability area assessment documents:

| Workload Slider              | Assessment Document(s)                                                                                                                                           |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Compliance Policies          | [Compliance Baselines](compliance-baselines.md)                                                                                   |
| Device Configuration         | [Compliance Baselines](compliance-baselines.md), [Scripting & Automation](scripting-automation.md) |
| Endpoint Protection          | [Endpoint Protection](endpoint-protection.md)                                                                                     |
| Windows Update Policies      | [Patch Management](patch-management.md)                                                                                           |
| Office Click-to-Run Apps     | [Software Deployment](software-deployment.md)                                                                                     |
| Client Apps                  | [Software Deployment](software-deployment.md)                                                                                     |
| Resource Access (deprecated) | [Infrastructure](infrastructure.md)                                                                                               |

For detailed SCCM-to-Intune capability mapping, licensing requirements, and migration considerations, consult the corresponding assessment document.

---

## Sources

- [Co-management workloads - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/comanage/workloads)
- [Switch co-management workloads - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/comanage/how-to-switch-workloads)
- [Co-management Workloads and Capabilities (Revisited)](https://msendpointmgr.com/2023/02/04/co-management-workloads-capabilities/)
- [SCCM 2211 Update: Prereq warning - Resource access slider](https://learn.microsoft.com/en-us/answers/questions/1183460/sccm-2211-update-prereq-warning-slide-co-managemen)

---

**Document End**
