# Software Deployment & App Management — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: **Near Parity**

---

## Executive Summary

Microsoft Intune achieves **Near Parity** with SCCM for software deployment and application management, delivering approximately 85% capability coverage. Intune's Win32 app platform provides comprehensive deployment functionality equivalent to SCCM's application model, including detection methods, requirements rules, dependencies, and supersedence relationships. Primary gaps are the absence of a reusable global conditions library (increasing administrative overhead) and lack of automated phased deployment progression. App-V virtualization reaches end-of-life in April 2026, affecting both platforms equally. Intune provides significant advantages through native Windows Package Manager (winget) integration and improved Microsoft Store app management.

---

## Feature Parity Matrix

| SCCM Feature                                                 | Intune Equivalent                                                          | Parity Rating        | Licensing     | Notes                                                                                                                     |
| ------------------------------------------------------------ | -------------------------------------------------------------------------- | -------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Application Model - Detection Methods**                    | Win32 app detection rules (MSI, File, Registry, PowerShell)                | **Full Parity**      | Plan 1        | Both support MSI product code, file/folder version, registry key/value, and custom script detection                       |
| **Application Model - Requirements Rules**                   | Win32 app requirements (OS, architecture, disk space, RAM, custom scripts) | **Full Parity**      | Plan 1        | Script-based requirements supported in both; Intune adds registry and file requirement types                              |
| **Application Model - Dependencies**                         | Win32 app dependencies with sub-dependencies                               | **Full Parity**      | Plan 1        | Intune supports multi-level dependency chains; dependencies install before main app                                       |
| **Application Model - Supersedence**                         | Win32 app supersedence (update/replace, max 10 nodes)                      | **Near Parity**      | Plan 1        | Both support update (preserve) and replace (uninstall) workflows; Intune has 10-node limit per chain                      |
| **Application Model - Deployment Types**                     | Requirements-based targeting                                               | **Near Parity**      | Plan 1        | Intune uses requirements rules instead of explicit deployment types; achieves same outcome                                |
| **Application Model - Global Conditions**                    | No direct equivalent                                                       | **Partial**          | N/A           | Must recreate conditions per app; no reusable global library reduces consistency and increases administrative effort      |
| **Package/Program Model (Legacy)**                           | Win32 apps                                                                 | **Near Parity**      | Plan 1        | Win32 apps replace legacy package/program with modern detection and requirements                                          |
| **App-V Virtualization**                                     | MSIX (App-V EOL April 2026)                                                | **Partial**          | Plan 1        | App-V server EOL 4/2026; client extended support; ~80% App-V packages are MSIX-compatible; repackaging required           |
| **MSIX App Packages**                                        | MSIX deployment                                                            | **Full Parity**      | Plan 1        | Native MSIX support in both platforms with automatic updates                                                              |
| **Microsoft Store Apps (Business/Education)**                | Microsoft Store apps via winget catalog                                    | **Intune Advantage** | Plan 1        | Intune offers improved Store integration via winget; no Store for Business re-authentication issues                       |
| **Windows Package Manager (winget)**                         | Native winget integration                                                  | **Intune Advantage** | Plan 1        | Intune native winget catalog browsing and deployment without repackaging; SCCM has no equivalent                          |
| **Microsoft 365 Apps for Enterprise**                        | Microsoft 365 Apps deployment and update policies                          | **Full Parity**      | Plan 1        | Both platforms deploy and update M365 Apps; Intune uses settings catalog for update policies                              |
| **Line-of-Business (LOB) Apps**                              | LOB app deployment (.msi, .appx, .appxbundle)                              | **Full Parity**      | Plan 1        | Direct LOB app deployment for MSI and APPX packages without wrapping                                                      |
| **Install Behaviors - System Context**                       | Install for system account                                                 | **Full Parity**      | Plan 1        | Both support system-level installation                                                                                    |
| **Install Behaviors - User Context**                         | Install for user account                                                   | **Full Parity**      | Plan 1        | Both support user-level installation                                                                                      |
| **Install Behaviors - 32-bit on 64-bit**                     | 32-bit installer on 64-bit OS flag                                         | **Full Parity**      | Plan 1        | Both support 32-bit redirection handling                                                                                  |
| **Install Behaviors - Restart Handling**                     | Device restart behavior settings                                           | **Full Parity**      | Plan 1        | Both support suppress, force, determine based on exit code                                                                |
| **Return Codes - Success/Failure**                           | Return codes with success/soft reboot/hard reboot/retry                    | **Full Parity**      | Plan 1        | Intune default codes: 0=success, 1707=success, 3010=soft reboot, 1641=hard reboot, 1618=retry                             |
| **User Experience - Installation Deadline**                  | Assignment deadline (Required apps)                                        | **Full Parity**      | Plan 1        | Both support enforcement deadlines for required apps                                                                      |
| **User Experience - Grace Period**                           | Grace period for restart                                                   | **Full Parity**      | Plan 1        | Configurable grace period before forced restart (default 1440 minutes in Intune)                                          |
| **User Experience - Toast Notifications**                    | Company Portal notifications                                               | **Full Parity**      | Plan 1        | Both display toast notifications for available apps, installation progress, and restart requirements                      |
| **Content Distribution - Distribution Points**               | Delivery Optimization                                                      | **Partial**          | Plan 1 (Free) | Delivery Optimization replaces DPs for cloud scenarios; no on-premises content hosting without Microsoft Connected Cache  |
| **Content Distribution - Peer Cache**                        | Delivery Optimization peer-to-peer                                         | **Full Parity**      | Plan 1 (Free) | Delivery Optimization includes peer-to-peer caching within subnet or download group                                       |
| **Content Distribution - BranchCache**                       | Delivery Optimization                                                      | **Full Parity**      | Plan 1 (Free) | Delivery Optimization supersedes BranchCache with equivalent functionality                                                |
| **Content Distribution - Cloud DP**                          | Microsoft Connected Cache for Enterprise                                   | **Near Parity**      | Plan 1 (Free) | MCC provides on-premises caching for cloud content; requires Windows Server host or Azure Stack HCI                       |
| **Content Distribution - Pull DPs**                          | Microsoft Connected Cache hosts                                            | **Near Parity**      | Plan 1 (Free) | MCC hosts serve similar function to pull DPs for remote locations                                                         |
| **Content Distribution - Multicast**                         | No equivalent                                                              | **No Equivalent**    | N/A           | Not applicable to cloud-based deployment model                                                                            |
| **Content Distribution - Prestaged Content**                 | No equivalent                                                              | **No Equivalent**    | N/A           | All content delivered on-demand from cloud or MCC cache                                                                   |
| **Deployment Monitoring - Status**                           | App install status reporting                                               | **Full Parity**      | Plan 1        | Both provide per-device installation status, success/failure tracking, error codes                                        |
| **Deployment Monitoring - Detailed Messages**                | Device diagnostics and IME logs                                            | **Full Parity**      | Plan 1        | Intune collects IME logs via diagnostics; includes app installation events and error details                              |
| **Deployment Monitoring - Alerts**                           | No equivalent                                                              | **Partial**          | N/A           | Intune has no configurable deployment alerts; must use Azure Monitor Workbooks or Graph API                               |
| **Phased Deployments - Apps**                                | Manual deployment rings via Azure AD groups                                | **Partial**          | Plan 1        | No automatic phase progression; must manually create ring groups and staged assignments                                   |
| **Phased Deployments - Updates**                             | Update rings with staged rollout                                           | **Near Parity**      | Plan 1        | Update rings provide phased rollout for Windows updates                                                                   |
| **Assignment Types - Required**                              | Required assignment intent                                                 | **Full Parity**      | Plan 1        | Both enforce automatic installation with deadline                                                                         |
| **Assignment Types - Available**                             | Available for enrolled devices                                             | **Full Parity**      | Plan 1        | Both present app in Software Center / Company Portal for user-initiated install                                           |
| **Assignment Types - Uninstall**                             | Uninstall assignment intent                                                | **Full Parity**      | Plan 1        | Both support forced application removal                                                                                   |
| **Assignment Types - Available to Users Without Enrollment** | Available for unenrolled devices (MAM)                                     | **Intune Advantage** | Plan 1        | Intune supports app deployment to unenrolled devices via MAM; SCCM requires device enrollment                             |
| **Software Center**                                          | Company Portal                                                             | **Near Parity**      | Plan 1        | Company Portal lacks restart required indicator and estimated install time metadata                                       |
| **Application Catalog (Deprecated)**                         | Company Portal web portal                                                  | **Full Parity**      | Plan 1        | Company Portal web interface provides equivalent user-available app browsing                                              |
| **User Device Affinity**                                     | Primary user assignment                                                    | **Full Parity**      | Plan 1        | Both associate devices with primary users; Intune automatically determines via sign-in frequency                          |
| **App Groups (Virtual Environments)**                        | No equivalent                                                              | **No Equivalent**    | N/A           | App-V server component EOL; no replacement for virtual environment groups                                                 |
| **Script Deployment**                                        | Platform scripts (PowerShell/shell) and Remediations                       | **Near Parity**      | Plan 1        | Intune separates one-time scripts (Platform scripts) from recurring scripts (Remediations); no collection-based targeting |

---

## Key Findings

### Full/Near Parity Areas

#### Application Model Fundamentals

Intune's [Win32 app platform](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-app-management) achieves near-complete functional parity with SCCM's application model. The core application lifecycle — packaging, detection, requirements evaluation, installation, and monitoring — operates identically.

**Detection Rules**: Both platforms support multiple detection methods that can be combined with AND logic:

| Detection Method | SCCM       | Intune     | Notes                                                           |
| ---------------- | ---------- | ---------- | --------------------------------------------------------------- |
| MSI product code | Yes        | Yes        | Detects based on MSI product GUID and version                   |
| File existence   | Yes        | Yes        | Supports path, version comparison, date comparison              |
| Folder existence | Yes        | Yes        | Detects presence of folder                                      |
| Registry key     | Yes        | Yes        | Detects key existence or value data with comparison operators   |
| Custom script    | PowerShell | PowerShell | Must return 0 exit code for detected, non-zero for not detected |

Example Intune detection rule (PowerShell):

> **Note**: The following is a conceptual example illustrating the pattern. Adapt version numbers and paths for your environment.

```powershell
# Detection script for application version
$appVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Vendor\Product" -Name "Version" -ErrorAction SilentlyContinue).Version
if ($appVersion -ge "2.5.0") {
    Write-Output "Detected"
    exit 0
} else {
    exit 1
}
```

**Requirements Rules**: [Intune requirements](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-add) match SCCM's requirement rule types. Both platforms evaluate requirements before installation attempt:

- Operating system version (minimum, maximum, specific builds)
- Processor architecture (x86, x64, ARM64)
- Disk space (minimum free space in MB)
- Physical memory (minimum RAM in MB)
- Custom PowerShell scripts (must return 0 for requirement met)
- Registry values (Intune-specific)
- File/folder properties (Intune-specific)

Requirements rules determine whether a deployment type (SCCM) or application (Intune) is applicable to a device. Multiple requirements combine with AND logic.

**Dependencies**: Intune's [dependency relationships](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-app-management) support multi-level dependency chains. Dependencies install automatically before the parent application. If a dependency has its own dependencies (sub-dependencies), the entire dependency tree resolves depth-first.

Example dependency chain:

```
Application: SAP GUI 8.0
  └─ Dependency: Microsoft Visual C++ 2019 Redistributable (x64)
       └─ Sub-dependency: Windows 10 1809+ (OS requirement)
```

Intune enforces dependency order: sub-dependencies install first, then dependencies, then the parent application. If any dependency fails, the parent installation aborts.

**Supersedence**: [Intune supersedence](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-supersedence) supports two modes matching SCCM:

1. **Update** (uninstall previous version = No): Installs new version; previous version remains if new installation fails. Use for in-place upgrades.
2. **Replace** (uninstall previous version = Yes): Uninstalls previous version before installing new version. Use when clean install required.

As of 2026, Intune supports [combined supersedence and dependency relationships](https://techcommunity.microsoft.com/blog/intunecustomersuccess/upcoming-improvements-to-win32-app-supersedence/3713026) within the same app subgraph. A subgraph is a set of apps connected through supersedence and dependency relationships. Maximum 10 related nodes per supersedence chain.

**Critical difference**: SCCM automatically targets superseding apps to devices with superseded apps. Intune requires explicit assignment of both superseding and superseded apps. The supersedence relationship defines installation behavior but does not control targeting.

#### Content Distribution

Intune eliminates SCCM's distribution point infrastructure, replacing it with cloud-based content delivery and [Delivery Optimization](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization-reference) peer-to-peer caching.

**Delivery Optimization** replaces SCCM's peer cache and BranchCache. Key capabilities:

- **HTTP downloads with peer-to-peer**: Devices download from Microsoft cloud (http://windowsupdate.com) or Microsoft Connected Cache, then share content with peers on the same subnet or download group
- **Bandwidth throttling**: Foreground/background download throttling as percentage of available bandwidth or absolute Mbps
- **Download groups**: Group devices by arbitrary string (via policy) to restrict peer sharing scope beyond subnet boundaries
- **LAN peer discovery**: Automatic peer discovery via WSD (Web Services for Devices) protocol
- **Cache management**: Configurable cache size (percentage of disk or absolute GB); least-recently-used eviction

**Microsoft Connected Cache (MCC)** for Enterprise provides on-premises caching for organizations with limited internet bandwidth or remote locations. [MCC deployment](https://learn.microsoft.com/en-us/windows/deployment/do/mcc-ent-edu-overview) requires:

- Windows Server 2022 or Windows Server 2019 host (or Azure Stack HCI)
- Minimum 200GB disk space for cache
- Internet connectivity to Microsoft content delivery network
- Intune device configuration profile to direct clients to MCC server

MCC caches all Microsoft cloud content (Windows updates, Microsoft 365 Apps, Intune Win32 apps, Microsoft Store apps) on first request, then serves subsequent requests from local cache. Operates as transparent proxy — clients attempt cloud download, MCC intercepts and serves cached content if available.

#### Deployment Monitoring

[Intune app monitoring](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-app-management) provides equivalent visibility to SCCM deployment status:

- **Device install status**: Per-device installation state (installed, pending, failed, not applicable)
- **User install status**: Per-user installation state for user-targeted apps
- **Installation details**: Exit codes, installation time, error messages
- **Diagnostics collection**: On-demand IME log collection for troubleshooting

Monitoring dashboard shows installation statistics:

- Total devices targeted
- Successfully installed
- Installation pending
- Failed installations
- Not applicable (requirements not met)

Click-through to device list allows filtering and export. However, Intune lacks SCCM's configurable deployment alerts — organizations must use Azure Monitor Workbooks or Graph API to create custom alerting.

#### Microsoft 365 Apps Deployment

Both platforms deploy and update [Microsoft 365 Apps for Enterprise](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/about-microsoft-365-apps). SCCM uses the Office 365 Installer and Office 365 Client Management dashboard. Intune uses the Microsoft 365 Apps app type (pre-configured in console) and settings catalog for update policies.

Key Intune advantages:

- **Microsoft 365 Apps for Windows 10/11** app type: Pre-built deployment with configurable suite selection (Word, Excel, PowerPoint, etc.), update channel, language, and architecture
- **Settings catalog - Microsoft 365 Apps Update policies**: Granular control over update behavior, deadlines, and user notifications without Group Policy
- **Automatic updates**: Apps update automatically via Microsoft CDN without re-deploying the app package

Both platforms support Office Customization Tool (ODT) XML configuration for advanced deployment customization.

---

### Partial Parity / Gaps

#### Global Conditions Library

SCCM's [global conditions](https://learn.microsoft.com/en-us/configmgr/apps/deploy-use/create-global-conditions) provide a reusable library of requirement rules that apply to multiple applications. Administrators create global conditions once (e.g., "Minimum 8GB RAM", "Department = Finance via registry value", "Citrix Receiver installed"), then reference them in multiple application deployment types.

Benefits:

- **Consistency**: Same requirement logic across all apps
- **Maintainability**: Update global condition once; change applies to all consuming apps
- **Discoverability**: Centralized library shows all available conditions

**Intune has no global conditions equivalent**. Requirements rules must be configured individually per application. For organizations with hundreds of applications sharing common requirements (minimum RAM, prerequisite software, organizational unit membership), this represents significant administrative overhead.

**Workaround**: Use naming conventions and documentation to maintain consistency. For PowerShell-based requirements, maintain a script library in source control and copy-paste into Intune console. Third-party tools (e.g., IntuneWin32App PowerShell module) can automate requirement rule creation via Graph API.

**Impact**: Medium. Functional outcome is identical (requirements evaluated correctly), but administrative effort increases proportionally to application portfolio size and requirement complexity.

#### App-V Virtualization End-of-Life

Microsoft App-V server components reach [end of support April 14, 2026](https://learn.microsoft.com/en-us/microsoft-desktop-optimization-pack/app-v/appv-support-policy):

- **App-V server components**: End of support (no updates, no support)
- **App-V client**: Moves to extended support (security updates only, no feature updates)

Microsoft's recommended migration path is [MSIX packaging](https://learn.microsoft.com/en-us/windows/msix/packaging-tool/create-app-package). However, compatibility varies:

- **Simple applications**: ~80% of App-V packages are MSIX-compatible without modification
- **Complex applications**: Applications using kernel drivers, COM+ registration, or dynamic DLLs may not convert cleanly

**Migration strategies**:

1. **MSIX conversion**: Use MSIX Packaging Tool to convert App-V packages to MSIX
2. **Win32 repackaging**: Repackage as traditional Win32 apps (no virtualization)
3. **Azure Virtual Desktop**: Move incompatible applications to AVD session hosts
4. **Third-party virtualization**: Consider Numecent Cloudpaging or Turbo.net (commercial alternatives)

**Timeline**: Organizations should complete App-V migration by Q2 2026 to avoid running unsupported server infrastructure. This affects both SCCM and Intune equally — the migration is platform-independent.

#### Phased Deployments for Applications

SCCM's [phased deployments](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/create-phased-deployment-for-task-sequence) automate progressive rollout with configurable criteria:

- **Phase 1 (Pilot)**: Deploy to 50 devices
- **Phase 2 (Production)**: Automatically begin when Phase 1 reaches 95% success rate after 7-day monitoring period
- **Fallback**: Automatically pause Phase 2 if success rate drops below threshold

**Intune has no automated phased deployment**. Organizations must manually implement deployment rings:

1. Create Azure AD dynamic groups for each ring:
   - **Ring 0 - IT**: `(user.department -eq "IT")`
   - **Ring 1 - Pilot**: `(user.department -in ["IT", "HR"])` or device-based groups
   - **Ring 2 - Production**: All devices group

2. Assign app to Ring 0 with immediate deadline

3. Monitor installation success rate in Intune console

4. Manually assign app to Ring 1 when Ring 0 success threshold met

5. Repeat for Ring 2

**Limitations**:

- No automatic progression based on success criteria
- No automatic rollback on failure detection
- Requires manual monitoring and ring progression
- Group-based targeting is less granular than SCCM's percentage-based phases

**Workaround**: Use [Intune filters](https://learn.microsoft.com/en-us/mem/intune/fundamentals/filters) to create percentage-based targeting:

```
(device.deviceId -in ["guid1", "guid2", ...])
```

Generate device GUID list representing X% of population, add to filter, assign app to "All Devices" with filter. Update filter membership to expand rollout. This approximates SCCM's percentage-based phases but requires external tooling to generate GUID lists.

**Impact**: Medium. Phased rollout is achievable but requires more manual orchestration and monitoring than SCCM's automated approach.

#### Software Center vs Company Portal Metadata

SCCM's [Software Center](https://learn.microsoft.com/en-us/configmgr/core/understand/software-center) displays metadata not currently shown in [Intune Company Portal](https://learn.microsoft.com/en-us/mem/intune/apps/company-portal-app):

| Metadata               | Software Center       | Company Portal |
| ---------------------- | --------------------- | -------------- |
| Restart required       | Yes (icon indicator)  | No             |
| Estimated install time | Yes (minutes)         | No             |
| Application size       | Yes (MB)              | Yes            |
| Installation deadline  | Yes (countdown timer) | Yes            |
| User ratings/reviews   | Yes (configurable)    | No             |

**Impact**: Low. Missing metadata reduces user visibility into installation impact but does not affect functionality. Users discover restart requirement after installation completes.

---

### Significant Gaps

#### Multicast and Prestaged Content

SCCM supports [multicast distribution](https://learn.microsoft.com/en-us/intune/configmgr/osd/deploy-use/use-multicast-to-deploy-windows-over-the-network) for simultaneous content delivery to multiple devices and prestaged content for WAN-constrained distribution points.

**Intune has no equivalent**. All content delivers unicast from cloud or Microsoft Connected Cache. For organizations with:

- **Low-bandwidth locations**: Deploy Microsoft Connected Cache hosts; first device downloads from cloud, subsequent devices download from local cache
- **Large application packages**: Split applications into smaller components or use Delivery Optimization peer-to-peer
- **Simultaneous deployments**: Delivery Optimization automatically shares content between peers during concurrent downloads

**Impact**: Low. Modern Delivery Optimization peer-to-peer caching provides sufficient bandwidth optimization for most scenarios. Organizations requiring guaranteed simultaneous delivery (e.g., kiosk fleet updates) should evaluate deployment timing strategies.

---

### Intune Advantages

#### Windows Package Manager (winget) Integration

Intune offers [native winget integration](https://learn.microsoft.com/en-us/windows/package-manager/) for deploying applications directly from the winget community repository without repackaging. SCCM has no equivalent capability.

**How it works**:

1. Browse winget catalog in Intune console (10,000+ applications as of 2026)
2. Select application (e.g., "7-Zip.7-Zip" package ID)
3. Configure deployment settings (assignment groups, deadline, restart behavior)
4. Intune creates Win32 app automatically with:
   - Install command: `winget install --id 7-Zip.7-Zip --exact --silent --accept-package-agreements`
   - Uninstall command: `winget uninstall --id 7-Zip.7-Zip --silent`
   - Detection rule: Queries winget for installed package

**Benefits**:

- **Zero repackaging effort**: Deploy applications without creating installers
- **Automatic updates**: Configure winget catalog apps to auto-update (app keeps pace with vendor releases)
- **Version pinning**: Deploy specific versions or "latest"
- **Community-maintained**: winget manifests maintained by community; new applications added daily

**Limitations**:

- Public winget repository only (no private repository support yet)
- Requires devices to reach winget CDN (https://cdn.winget.microsoft.com)
- No supersedence relationships between winget apps (each version is independent deployment)

**Use cases**:

- Developer tools (Visual Studio Code, Git, Python, Node.js)
- End-user applications (browsers, media players, productivity tools)
- Rapid pilot deployments (test application before formal packaging)

#### Microsoft Store App Integration

Intune provides improved Microsoft Store app management compared to SCCM:

**SCCM challenges**:

- Requires Microsoft Store for Business (deprecated November 2023)
- Offline-licensed apps only (limited catalog)
- Re-authentication issues with Store for Business connector

**Intune advantages**:

- **New Microsoft Store integration** (2024+): Deploy Store apps directly without Store for Business
- **Online-licensed apps**: Full Store catalog available
- **Automatic updates**: Store apps update automatically via Microsoft Store service
- **winget integration**: Many Store apps available via winget catalog as alternative deployment method

Organizations should migrate SCCM Store for Business deployments to Intune's new Store integration or winget equivalents.

#### Mobile Application Management (MAM)

Intune supports [app deployment to unenrolled devices](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add) via Mobile Application Management (MAM). SCCM requires device enrollment (ConfigMgr client installation) for all app deployments.

**MAM scenarios**:

- **BYOD devices**: Deploy managed apps (Outlook, Teams, OneDrive) to personal devices without full device enrollment
- **App protection policies**: Enforce data loss prevention (copy/paste restrictions, PIN requirement) without controlling entire device
- **Conditional Access**: Require managed apps for corporate data access on unenrolled devices

This extends Intune's reach beyond enrolled devices — a significant advantage for BYOD and third-party contractor scenarios.

---

## Licensing Impact

**All software deployment features assessed in this document are included in Intune Plan 1**, which is bundled with:

- Microsoft 365 E3/E5
- Microsoft 365 Business Premium
- Enterprise Mobility + Security (EMS) E3/E5
- Standalone Intune Plan 1 ($8/user/month)

**Free Windows features** (no additional licensing):

- Delivery Optimization (built into Windows 10/11)
- Microsoft Connected Cache (requires Windows Server host, no Intune licensing cost)

**Optional add-ons** (not required for base software deployment):

- **Intune Suite** ($10/user/month; included in M365 E3/E5 from July 2026): Includes Enterprise Application Management for enhanced third-party app catalog (complements but does not replace software deployment)

**No premium licensing gates** exist for software deployment features. All organizations with Intune Plan 1 have full software deployment capabilities.

See [Executive Summary — Licensing Summary](executive-summary.md) for comprehensive licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Assessment

#### Application Inventory

Audit SCCM application portfolio before migration:

```sql
-- SQL query for SCCM database to inventory applications
SELECT
    app.DisplayName AS ApplicationName,
    dt.Technology AS DeploymentType,
    COUNT(DISTINCT req.RequirementName) AS RequirementsCount,
    COUNT(DISTINCT dep.DependencyName) AS DependenciesCount,
    COUNT(DISTINCT sup.SupersedingApp) AS SupersedenceRelationships,
    app.CreatedBy,
    app.DateCreated
FROM vSMS_Application app
LEFT JOIN vSMS_DeploymentType dt ON app.CI_ID = dt.AppCI_ID
LEFT JOIN vSMS_Requirements req ON dt.CI_ID = req.CI_ID
LEFT JOIN vSMS_Dependencies dep ON dt.CI_ID = dep.CI_ID
LEFT JOIN vSMS_Supersedence sup ON app.CI_ID = sup.SupersededApp_CI_ID
GROUP BY app.DisplayName, dt.Technology, app.CreatedBy, app.DateCreated
ORDER BY RequirementsCount DESC, DependenciesCount DESC
```

Identify high-complexity applications requiring manual migration review:

- **Global conditions**: Applications referencing >5 global conditions need condition recreation
- **Complex requirements**: Script-based requirements need validation in Intune environment
- **Dependency chains**: Deep dependency trees (>3 levels) require careful migration order
- **Supersedence chains**: Long supersedence chains (>5 relationships) should be simplified during migration

#### Deployment Type Analysis

| Deployment Type            | Intune Equivalent           | Migration Action                                                                                       |
| -------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------ |
| Windows Installer (MSI)    | LOB app (.msi) or Win32 app | Use LOB app for simple MSI; Win32 app if custom detection/requirements needed                          |
| Script Installer           | Win32 app                   | Wrap installer with [IntuneWinAppUtil](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) |
| App-V                      | MSIX or Win32 app           | Convert to MSIX with MSIX Packaging Tool; repackage as Win32 if incompatible                           |
| Windows app package (APPX) | LOB app (.appx/.appxbundle) | Direct migration                                                                                       |
| Web application            | Not applicable              | Remove or replace with web link in Company Portal                                                      |

### Migration Strategies

#### Strategy 1: Parallel Deployment (Co-Management)

**Best for**: Large application portfolios (>200 apps), risk-averse organizations

1. Enable [co-management](https://learn.microsoft.com/en-us/configmgr/comanage/overview) with **Client apps** workload in SCCM
2. Migrate applications incrementally:
   - Week 1-4: Pilot apps (10-20 low-complexity apps) to Intune
   - Week 5-12: Line-of-business apps (100-200 apps)
   - Week 13-20: Remaining applications
3. Shift co-management slider to Intune when >80% apps migrated
4. Decommission SCCM when app deployments complete and stabilize

**Advantages**:

- Zero-downtime migration
- Per-app rollback capability (shift individual apps back to SCCM if issues occur)
- Users see unified app list in Company Portal (includes SCCM and Intune apps)

**Disadvantages**:

- Requires co-management infrastructure (Azure AD Hybrid Join or Azure AD join)
- Longer migration timeline (4-6 months typical)

#### Strategy 2: Clean Cutover (Greenfield)

**Best for**: Small application portfolios (<50 apps), new Intune deployments

1. Deploy all applications to Intune in staging environment
2. Test deployment on pilot device group (50-100 devices)
3. Validate application functionality, detection, and uninstall
4. Cut over production devices to Intune management (unenroll from SCCM, enroll in Intune)
5. Applications deploy automatically via Autopilot or existing device enrollment

**Advantages**:

- Fast migration timeline (4-8 weeks)
- Clean separation between SCCM and Intune (no overlap)
- Forces application modernization (eliminates legacy packages)

**Disadvantages**:

- Higher risk (all apps must work correctly before cutover)
- Requires production downtime window for device re-enrollment
- No per-app rollback (must roll back entire deployment)

#### Strategy 3: Selective Migration (Hybrid Long-Term)

**Best for**: Organizations with persistent SCCM dependencies (OS deployment, third-party patching)

1. Identify applications suitable for Intune migration (primarily user-focused apps)
2. Keep complex applications in SCCM (apps with installer dependencies on task sequence variables, apps requiring maintenance windows)
3. Use co-management indefinitely with split workload:
   - Intune: User-installed apps, Microsoft 365 Apps, Microsoft Store apps, mobile apps
   - SCCM: System-level apps, server apps, apps requiring staged deployment windows

**Advantages**:

- Leverages strengths of both platforms
- Reduces migration scope (migrate only suitable applications)
- Maintains SCCM investment for scenarios where it excels

**Disadvantages**:

- Permanent dual-platform administrative overhead
- License costs for both platforms
- Requires ongoing co-management maintenance

### Application Migration Checklist

For each application migrating to Intune:

- [ ] **Source files collected**: Obtain installer files, install/uninstall scripts, prerequisites
- [ ] **Detection method defined**: Identify MSI product code, file version, registry key, or script logic
- [ ] **Requirements documented**: OS version, architecture, disk space, RAM, prerequisite software
- [ ] **Install command validated**: Test install command with silent switches in isolated environment
- [ ] **Uninstall command validated**: Test uninstall command completes without user interaction
- [ ] **Return codes mapped**: Document installer's return codes for success, reboot, failure
- [ ] **Dependencies identified**: List prerequisite applications; create dependency relationships in Intune
- [ ] **Supersedence planned**: Identify previous versions to supersede; define update vs replace strategy
- [ ] **Content prepared**: Wrap source files with IntuneWinAppUtil if Win32 app
- [ ] **Pilot tested**: Deploy to pilot group; validate installation, functionality, uninstallation
- [ ] **Assignment groups created**: Create Azure AD groups for required, available, and uninstall assignments
- [ ] **Deployment scheduled**: Assign to production groups with appropriate deadline
- [ ] **Monitoring enabled**: Configure deployment status monitoring; review installation success rate

### Common Migration Issues and Resolutions

| Issue                                                | Cause                                                | Resolution                                                                                                                                                                      |
| ---------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Detection fails despite successful installation**  | Detection rule does not match installer behavior     | Enable IME logging (`HKLM\SOFTWARE\Microsoft\IntuneManagementExtension`, LogLevel=0); review `IntuneManagementExtension.log` for detection script output; adjust detection rule |
| **Requirements not evaluated correctly**             | Script-based requirement returns incorrect exit code | Requirement script must exit 0 (requirement met) or 1 (requirement not met); use `exit 0` or `exit 1` explicitly, not `return`                                                  |
| **Dependency installs after parent app**             | Dependency assignment missing                        | Dependencies must be assigned to same groups as parent app; dependency relationships define install order but not targeting                                                     |
| **Supersedence does not uninstall previous version** | Uninstall previous version flag not set              | Edit supersedence relationship; enable "Uninstall previous version" checkbox for replace scenario                                                                               |
| **Content download fails with 0x80070002**           | IntuneWin file corrupted or incomplete upload        | Re-run IntuneWinAppUtil to create .intunewin file; re-upload to Intune; verify file size matches source                                                                         |
| **Installation never starts (perpetual "Pending")**  | Intune Management Extension service not running      | Verify `IntuneManagementExtension` service is running; check device enrollment status; re-sync device                                                                           |

### App-V Migration Planning

For organizations with App-V deployments:

1. **Inventory App-V packages**:

   ```powershell
   # PowerShell to export App-V package inventory from SCCM
   Get-WmiObject -Namespace "root\sms\site_<SiteCode>" -Class SMS_VirtualApp |
       Select-Object Name, Version, Publisher, PackageID |
       Export-Csv -Path "AppV-Inventory.csv" -NoTypeInformation
   ```

2. **Categorize by complexity**:
   - **Simple** (80% of packages): Single executable, no COM registration, no drivers → MSIX conversion candidate
   - **Moderate** (15% of packages): Multiple executables, COM registration, registry dependencies → MSIX conversion with manual intervention
   - **Complex** (5% of packages): Kernel drivers, services, COM+ components → Win32 repackaging or AVD

3. **Test MSIX conversion**:
   - Use [MSIX Packaging Tool](https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview) to convert App-V packages
   - Test converted MSIX on Windows 10 21H2+ (MSIX minimum OS version)
   - Validate application functionality post-conversion

4. **Migration timeline**:
   - Q1 2026: Inventory and categorization complete
   - Q2 2026: MSIX conversion and testing (complete before April 2026 App-V server EOL)
   - Q3 2026: Production deployment of MSIX apps via Intune
   - Q4 2026: Decommission App-V infrastructure

---

## Sources

### Microsoft Learn Documentation

- [Win32 App Management in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-app-management)
- [Add and Assign Win32 Apps to Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-add)
- [Add Win32 App Supersedence - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-supersedence)
- [Create Applications - Configuration Manager](https://learn.microsoft.com/en-us/configmgr/apps/deploy-use/create-applications)
- [Create Global Conditions - Configuration Manager](https://learn.microsoft.com/en-us/configmgr/apps/deploy-use/create-global-conditions)
- [Delivery Optimization Reference](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization-reference)
- [Microsoft Connected Cache for Enterprise and Education Overview](https://learn.microsoft.com/en-us/windows/deployment/do/mcc-ent-edu-overview)
- [Windows Package Manager](https://learn.microsoft.com/en-us/windows/package-manager/)
- [MSIX Overview](https://learn.microsoft.com/en-us/windows/msix/overview)
- [MSIX Packaging Tool](https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview)
- [Microsoft Application Virtualization Lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/microsoft-application-virtualization)
- [Co-Management Overview](https://learn.microsoft.com/en-us/configmgr/comanage/overview)
- [Mobile Application Management](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add)

### Community and Technical Resources

- [Upcoming Improvements to Win32 App Supersedence - Microsoft Community Hub](https://techcommunity.microsoft.com/blog/intunecustomersuccess/upcoming-improvements-to-win32-app-supersedence/3713026)
- [Win32 App Deployment with Intune Supersedence Rules - Ravenswood Technology Group](https://www.ravenswoodtechnology.com/win32-app-deployment-with-intune-supersedence-rules/)
- [Win32 App Deployment with Dependencies - Techuisitive](https://techuisitive.com/win32-app-deployment-with-dependencies-microsoft-intune/)
- [Working with Supersedence Relationships for Win32 Apps - Peter van der Woude](https://petervanderwoude.nl/post/working-with-supersedence-relationships-for-win32-apps/)
- [How to Use Intune Supersedence to Update Win32 Apps - Sikich](https://www.sikich.com/insight/intune-supersedence-with-win32-apps/)
- [Microsoft Win32 Content Prep Tool - GitHub](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)

---

**Research Date**: February 18, 2026
**Primary Sources**: Microsoft Learn official documentation, Microsoft Community Hub, verified third-party technical resources
