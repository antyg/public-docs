# Patch & Update Management — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: **Near Parity** (Microsoft updates); **Significant Gap** (third-party patching)

---

## Executive Summary

Microsoft Intune achieves **Near Parity** with SCCM for Microsoft software update management (Windows, Office, Defender), delivering approximately 85% capability coverage through Windows Update for Business. The cloud-native update infrastructure eliminates WSUS and Software Update Point dependencies while providing equivalent deployment control via update rings and feature update policies. **Significant gaps exist for third-party application patching** (no native catalog support; requires commercial third-party solutions like Patch My PC or Ivanti) and **orchestration groups** (no equivalent for sequenced server cluster updates). Intune provides advantages through expedited quality updates (24-hour emergency security patching), Windows Autopatch (fully managed update service), and driver/firmware update management.

---

## Feature Parity Matrix

| SCCM Feature                                | Intune Equivalent                                   | Parity Rating        | Licensing              | Notes                                                                                                           |
| ------------------------------------------- | --------------------------------------------------- | -------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Software Update Point (SUP) Role**        | Windows Update for Business service                 | **Full Parity**      | Plan 1 (Free)          | WUfB service replaces SUP infrastructure; devices connect directly to Microsoft Update                          |
| **WSUS Integration**                        | Direct Microsoft Update connection                  | **Full Parity**      | Plan 1 (Free)          | No WSUS infrastructure required; devices download updates from Microsoft CDN or Delivery Optimization peers     |
| **WSUS Synchronization Schedule**           | Automatic cloud synchronization                     | **Full Parity**      | Plan 1 (Free)          | Updates appear in Intune automatically when published by Microsoft; no sync configuration needed                |
| **Update Classifications**                  | Update rings - classification filters               | **Full Parity**      | Plan 1                 | Quality updates, feature updates, drivers, non-security updates, Windows insider                                |
| **Product Selection**                       | Automatic for enrolled Windows devices              | **Full Parity**      | Plan 1                 | Updates automatically filtered to device's Windows version and edition                                          |
| **Automatic Deployment Rules (ADRs)**       | Update rings for Windows 10/11                      | **Near Parity**      | Plan 1                 | Rings provide similar automation with classification, deferral, and deadline; less granular filtering than ADRs |
| **Software Update Groups (SUGs)**           | Quality update policies and feature update policies | **Full Parity**      | Plan 1                 | Quality policies group monthly updates; feature policies target specific Windows versions                       |
| **Manual Update Approval**                  | Feature update policy version targeting             | **Partial**          | Plan 1                 | Can approve specific feature update versions; cannot approve individual KB articles for quality updates         |
| **Update Deployment Packages**              | Cloud-based delivery (no packages)                  | **Full Parity**      | Plan 1 (Free)          | No deployment packages needed; updates download directly from Microsoft Update or peers                         |
| **Distribution Points for Updates**         | Delivery Optimization and Microsoft Connected Cache | **Full Parity**      | Plan 1 (Free)          | Delivery Optimization peer-to-peer replaces DP content distribution                                             |
| **Maintenance Windows**                     | No direct equivalent                                | **Partial**          | N/A                    | Active hours block updates; deadlines force installation; no explicit maintenance window concept                |
| **Service Windows (Non-Business Hours)**    | Active hours configuration                          | **Partial**          | Plan 1                 | Active hours define "do not install" period (inverse of maintenance window); max 18-hour window                 |
| **Deployment Deadlines**                    | Update deadline settings                            | **Full Parity**      | Plan 1                 | Days after update becomes available before forced installation                                                  |
| **User Experience - Restart Notifications** | Restart grace period and notifications              | **Full Parity**      | Plan 1                 | Configurable grace period (default 3 days); toast notifications before forced restart                           |
| **User Experience - Restart Suppression**   | Active hours enforcement                            | **Full Parity**      | Plan 1                 | Updates will not restart device during active hours                                                             |
| **Phased Deployments - Updates**            | Manual deployment rings via groups                  | **Partial**          | Plan 1                 | No automatic phase progression based on success criteria; manual ring-based rollout                             |
| **Deployment Rings / Collections**          | Azure AD group-based assignment                     | **Full Parity**      | Plan 1                 | Create pilot, production rings using Azure AD groups                                                            |
| **Orchestration Groups**                    | No equivalent                                       | **Significant Gap**  | N/A                    | No sequenced update control for server clusters (SQL AG, Hyper-V clusters, Exchange DAG)                        |
| **Pre/Post-Deployment Scripts**             | No equivalent for updates                           | **Significant Gap**  | N/A                    | Cannot run custom scripts before/after update installation (available for apps only)                            |
| **Compliance Reporting**                    | Windows Update for Business reports                 | **Full Parity**      | Plan 1 (Free)          | WUfB reports in Azure Portal show device compliance, update status, Windows Defender status                     |
| **Update Scan Schedules**                   | Automatic scan (configurable frequency)             | **Full Parity**      | Plan 1                 | WUfB scans automatically; default 22-hour interval; configurable via update rings                               |
| **Third-Party Update Catalogs (SCUP)**      | No native support                                   | **No Equivalent**    | N/A                    | Requires third-party solutions (Patch My PC ~$2-4/device/year, Ivanti Neurons, ManageEngine)                    |
| **Third-Party Update Publisher**            | No equivalent                                       | **No Equivalent**    | N/A                    | Cannot publish custom updates to catalog                                                                        |
| **Expedited Quality Updates**               | Expedited quality update deployment                 | **Intune Advantage** | Plan 1                 | Deploy latest security updates within 24 hours, bypassing deferral policies                                     |
| **Feature Update Policies**                 | Feature update policies                             | **Full Parity**      | Plan 1                 | Direct control over Windows version deployment (22H2, 23H2, 24H2, etc.)                                         |
| **Feature Update Rollback**                 | Uninstall updates policy                            | **Partial**          | Plan 1                 | Can uninstall quality updates (10-day default window); feature update rollback via setting                      |
| **Update Installation Behavior**            | Installation behavior settings                      | **Full Parity**      | Plan 1                 | Auto-download/auto-install, notify to download, notify to install                                               |
| **Driver and Firmware Updates**             | Driver update policies                              | **Intune Advantage** | Plan 1                 | Intune can deploy driver and firmware updates from Windows Update; SCCM requires manual packages                |
| **Windows Insider Program Management**      | Windows Insider deployment ring                     | **Full Parity**      | Plan 1                 | Configure devices for Insider preview builds (Dev, Beta, Release Preview channels)                              |
| **Microsoft 365 Apps Updates**              | Microsoft 365 Apps update policies                  | **Full Parity**      | Plan 1                 | Control update channel, deadline, and rollback for Office apps via settings catalog                             |
| **Windows Autopatch**                       | Windows Autopatch (managed service)                 | **Intune Advantage** | E3/E5 (from July 2026) | Fully automated patch management service with progressive rollout, testing, and rollback                        |
| **Update Compliance Dashboard**             | Windows Update for Business reports dashboard       | **Full Parity**      | Plan 1 (Free)          | Equivalent visibility: devices needing updates, update status, compliance percentage                            |
| **Client Health Reporting**                 | Device check-in and health monitoring               | **Full Parity**      | Plan 1                 | Monitor device enrollment status, last check-in, policy application status                                      |
| **Superseded Updates Removal**              | Automatic (Windows Update managed)                  | **Full Parity**      | Plan 1 (Free)          | Windows Update automatically manages supersedence; no manual cleanup required                                   |
| **WSUS Cleanup Wizard**                     | Not applicable                                      | **Full Parity**      | N/A                    | No WSUS infrastructure to maintain; cloud service is self-maintaining                                           |
| **Update Download Scheduling**              | Delivery Optimization bandwidth throttling          | **Full Parity**      | Plan 1 (Free)          | Limit download bandwidth by percentage or absolute Mbps; schedule download times                                |

---

## Key Findings

### Full/Near Parity Areas

#### Windows Update Infrastructure Replacement

[Windows Update for Business (WUfB)](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) is the cloud-native replacement for SCCM's Software Update Point and WSUS infrastructure. Devices enrolled in Intune connect directly to Microsoft Update (windowsupdate.com) without on-premises server dependencies.

**Architecture comparison**:

| Component             | SCCM                                         | Intune                                                           |
| --------------------- | -------------------------------------------- | ---------------------------------------------------------------- |
| Update catalog source | WSUS synchronization from Microsoft Update   | Direct from Microsoft Update (cloud service)                     |
| Update metadata sync  | SUP role syncs to WSUS, then to ConfigMgr DB | Automatic cloud sync (no configuration)                          |
| Update file hosting   | Distribution Points                          | Microsoft CDN + Delivery Optimization peer-to-peer               |
| Client-side agent     | Windows Update Agent + SCCM client           | Windows Update Agent (built-in)                                  |
| Approval workflow     | Administrator approves updates via console   | Automated via update rings or manual via feature update policies |
| Reporting             | SCCM console + SQL Reporting Services        | Azure Portal (WUfB reports) + Intune console                     |

**WUfB benefits**:

- **Zero infrastructure**: No Software Update Point, WSUS server, or SQL Server database for update metadata
- **Automatic synchronization**: Updates appear in Intune immediately when Microsoft publishes them
- **Cloud-scale bandwidth**: Microsoft CDN handles update distribution; no DP capacity planning
- **Built-in resilience**: 99.9% SLA for Windows Update service; no single point of failure

**WUfB limitations**:

- **Internet dependency**: Devices must reach Microsoft Update endpoints (can use Microsoft Connected Cache for bandwidth optimization)
- **No third-party updates**: WUfB catalog only includes Microsoft updates

#### Automatic Deployment Rules (ADRs) vs Update Rings

SCCM's [Automatic Deployment Rules](https://learn.microsoft.com/en-us/mem/configmgr/sum/deploy-use/automatically-deploy-software-updates) provide granular filtering and automated deployment. Intune's [update rings](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure) provide similar automation with different filtering capabilities.

**SCCM ADR filters**:

- Product (Windows 10, Windows 11, Windows Server, Office, etc.)
- Classification (Critical, Security, Definition, Feature Pack, Update Rollup, etc.)
- Severity (Critical, Important, Moderate, Low)
- Date released (last X days, specific date range)
- KB article number (include/exclude specific KBs)
- Required count (devices needing update)
- Superseded status (exclude superseded)

**Intune update ring settings**:

- **Quality update deferral**: 0-30 days after Microsoft release
- **Feature update deferral**: 0-365 days after Microsoft release
- **Classification inclusion**: Quality updates, drivers, non-security updates, feature updates (Windows Insider)
- **Automatic driver updates**: Include/exclude drivers
- **Windows pre-release features**: Disable, pilot, production Insider builds

**Comparison**:

| Capability                          | SCCM ADR                    | Intune Update Ring                             | Assessment                                |
| ----------------------------------- | --------------------------- | ---------------------------------------------- | ----------------------------------------- |
| Auto-deploy monthly quality updates | Yes (via schedule)          | Yes (via deferral period)                      | **Full Parity**                           |
| Filter by KB number                 | Yes (include/exclude)       | No (all updates in ring)                       | **Gap** — cannot exclude specific KBs     |
| Filter by severity                  | Yes                         | No (all quality updates included)              | **Gap** — cannot filter by severity       |
| Phased rollout automation           | Yes (phased deployment)     | No (manual group rings)                        | **Gap** — requires manual ring management |
| Update approval workflow            | Automatic via ADR or manual | Automatic via ring or manual (feature updates) | **Near Parity**                           |

**Practical impact**: Most organizations use ADRs to auto-deploy all quality updates with 7-day pilot, 30-day production deferral. Intune update rings achieve this exactly:

- **Pilot ring**: 0-day deferral, assigned to pilot group
- **Production ring**: 7-day deferral, assigned to production group

The inability to exclude specific KB numbers affects organizations that identify problematic updates and need emergency exclusions. **Workaround**: Use [update compliance safeguard holds](https://learn.microsoft.com/en-us/windows/deployment/update/update-compliance-feature-update-status#safeguard-holds) — Microsoft automatically blocks problematic updates from deploying.

#### Feature Update Management

Both SCCM and Intune provide direct control over Windows major version deployments:

**SCCM**: Uses in-place upgrade task sequences with Windows 10/11 installation media. Provides granular control over:

- Pre-upgrade scripts (application compatibility checks, backups)
- Dynamic variables (skip upgrade for specific hardware models)
- Post-upgrade scripts (application reinstallation, configuration)

**Intune**: Uses [feature update policies](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-feature-updates) that trigger Windows Setup via Windows Update:

- Select target Windows version (e.g., Windows 11 23H2)
- Configure rollout settings (start date, end date)
- Assign to Azure AD groups
- Windows Update downloads and installs feature update automatically

**Functional parity**: Both platforms perform in-place upgrades using Windows Setup. Key differences:

| Feature                    | SCCM                           | Intune                                     | Notes                                                                       |
| -------------------------- | ------------------------------ | ------------------------------------------ | --------------------------------------------------------------------------- |
| Pre-upgrade script         | Yes (task sequence steps)      | Via Remediations (separate deployment)     | Intune requires separate script deployment before feature update assignment |
| Compatibility checks       | Yes (built into task sequence) | Automatic (Windows Setup readiness checks) | Both run same Windows Setup compatibility validation                        |
| User data preservation     | Automatic (in-place upgrade)   | Automatic (in-place upgrade)               | Full parity                                                                 |
| Rollback on failure        | Automatic (Windows Setup)      | Automatic (Windows Setup)                  | Full parity — both use Windows Setup's rollback mechanism                   |
| Deployment ring automation | Yes (phased deployment)        | No (manual group creation)                 | Gap — requires manual pilot/production group management                     |

**Example Intune feature update policy configuration**:

```
Policy Name: Windows 11 23H2 - Production
Feature update to deploy: Windows 11, version 23H2
Rollout options:
  - Make update available: 2026-03-01
  - Set update end date: 2026-06-30 (90-day deployment window)
Assignment:
  - Group: All-Devices-Production
  - Filters: (device.osVersion -startsWith "10.0.22")  // Only upgrade Windows 11 22H2 devices
```

#### Compliance Reporting

[Windows Update for Business reports](https://learn.microsoft.com/en-us/windows/deployment/update/wufb-reports-overview) provide equivalent visibility to SCCM compliance dashboards. Reports are accessible via Azure Portal > Windows Update for Business reports or Intune console > Reports > Windows updates.

**Available reports**:

| Report                        | Description                             | Equivalent SCCM Report                    |
| ----------------------------- | --------------------------------------- | ----------------------------------------- |
| **Update Compliance**         | Devices with missing updates            | Compliance 1 - Overall compliance         |
| **Windows Feature Updates**   | Feature update version distribution     | All Systems by Version                    |
| **Windows Quality Updates**   | Quality update installation status      | Update 3 - Update states for a deployment |
| **Windows Expedited Updates** | Expedited update deployment status      | (No equivalent)                           |
| **Windows Driver Updates**    | Driver update installation status       | (No equivalent)                           |
| **Delivery Optimization**     | Peer-to-peer efficiency metrics         | (No equivalent)                           |
| **Windows Defender**          | Antivirus definition version and status | Endpoint Protection - Malware compliance  |

**Report data includes**:

- Device name, user, Azure AD group membership
- Installed Windows version and build number
- Missing update count and KB article numbers
- Last scan time and last update installation time
- Update installation errors (error code, failure count)
- Compliance state (compliant, not compliant, not assessed)

**Data retention**: WUfB reports retain 28 days of data by default. For longer retention, export data to [Azure Log Analytics](https://learn.microsoft.com/en-us/windows/deployment/update/wufb-reports-prerequisites) (additional cost ~$2.30/GB ingestion).

**Export capabilities**:

- CSV export from Azure Portal (manual)
- Graph API programmatic access
- Azure Monitor Workbooks for custom dashboards
- Power BI integration via Log Analytics connector

#### Microsoft 365 Apps Update Management

Both platforms manage [Microsoft 365 Apps for Enterprise updates](https://learn.microsoft.com/en-us/deployoffice/overview-update-process-microsoft-365-apps):

**SCCM**: Uses Office 365 Client Management dashboard and Automatic Deployment Rules for Office 365 updates
**Intune**: Uses Settings Catalog > Microsoft Office > Update policies

**Intune configuration** (via Settings Catalog):

- **Update channel**: Current Channel, Monthly Enterprise, Semi-Annual Enterprise
- **Update deadline**: Days after update available before forced installation
- **Hide update notifications**: Suppress Office update toast notifications
- **Update version**: Target specific Office version or "Latest"
- **Rollback**: Automatically roll back failed updates

**Full parity achieved** — both platforms control Office update behavior identically.

---

### Partial Parity / Gaps

#### Maintenance Windows

SCCM [maintenance windows](https://learn.microsoft.com/en-us/mem/configmgr/core/clients/manage/collections/use-maintenance-windows) provide explicit time ranges when updates can install, with collection-based assignment. Organizations define:

- **All Deployments window**: General maintenance window for all activities
- **Software Updates window**: Specific window for update installation only
- **Task Sequences window**: Separate window for OS deployments

Example SCCM maintenance window configuration:

```
Collection: Servers-Production
Maintenance Window: "Production Maintenance"
  Schedule: Every Saturday 02:00-06:00 (4-hour window)
  Type: Software Updates
  Allow restart outside window: No
```

**Intune has no direct maintenance window equivalent**. Organizations must approximate maintenance windows using:

1. **Active Hours**: Define when updates should NOT install (inverse of maintenance window)
   - Maximum 18-hour active hours window
   - Updates install outside active hours (typically overnight)
   - Limitation: Active hours are user-configurable on devices unless enforced via policy

2. **Update Deadlines**: Force installation by specific time
   - Configure deadline (e.g., 7 days after update available)
   - Updates install automatically at next reboot or deadline, whichever comes first
   - Limitation: No "install between 02:00-06:00" precision

3. **Restart Grace Period**: Delay forced restart after installation
   - Configure grace period (default 3 days)
   - User can delay restart up to grace period limit
   - Limitation: Does not control installation time, only restart time

**Workaround for server patching**:

For servers requiring strict maintenance window control, use [update orchestrator scripts](https://learn.microsoft.com/en-us/windows/deployment/update/waas-restart) triggered by scheduled tasks:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt for your environment and test thoroughly.

```powershell
# Scheduled task runs at 02:00 Saturday
# Script forces pending update installation and restart
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateInstaller = $UpdateSession.CreateUpdateInstaller()
$SearchResult = (New-Object -ComObject Microsoft.Update.Searcher).Search("IsInstalled=0")
if ($SearchResult.Updates.Count -gt 0) {
    $UpdateInstaller.Updates = $SearchResult.Updates
    $InstallResult = $UpdateInstaller.Install()
    if ($InstallResult.RebootRequired) {
        Restart-Computer -Force
    }
}
```

Deploy script via Intune Platform Scripts or Remediations, configure scheduled task via device configuration profile. This approximates SCCM maintenance windows but requires custom scripting.

**Impact**: Medium. Organizations with strict change control windows (especially server patching) experience significant workflow regression. Co-management retention of SCCM Software Updates workload is common for servers.

#### Phased Deployments

SCCM's [phased update deployments](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/create-phased-deployment-for-task-sequence) (available since version 1810) automate progressive rollout:

- **Phase 1 (Pilot)**: Deploy to pilot collection (e.g., 50 devices)
- **Success criteria**: 95% installation success rate
- **Monitoring period**: 7 days
- **Phase 2 (Production)**: Automatically begin when Phase 1 meets success criteria
- **Fallback**: Pause Phase 2 if success rate drops below threshold

**Intune requires manual deployment ring management**:

1. Create Azure AD groups for each ring:

   ```
   Ring-0-IT-Admins (static membership)
   Ring-1-Pilot (dynamic: user.department -in ["IT", "HR"])
   Ring-2-Production (All Devices)
   ```

2. Create update policies for each ring with increasing deferral:
   - **Ring 0**: 0-day deferral, deadline 3 days
   - **Ring 1**: 3-day deferral, deadline 7 days
   - **Ring 2**: 7-day deferral, deadline 14 days

3. Monitor Ring 0/1 installation success in WUfB reports (manual process)

4. If Ring 0/1 identifies problematic update:
   - Remove update policy assignments (blocks future installations)
   - Uninstall update via [Quality Update uninstall policy](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-expedite-updates#uninstall-updates)

**Limitations**:

- No automatic phase progression based on success rate
- Manual monitoring required to determine ring readiness
- No automatic rollback on failure detection

**Windows Autopatch alternative**: Organizations licensed for [Windows Autopatch](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-overview) (included in M365 E3/E5 from July 2026) gain fully automated phased deployment with:

- Automatic device grouping into rings (Test, First, Fast, Broad)
- Automated deployment progression based on success criteria
- Automated rollback on compatibility issue detection
- Microsoft-managed deployment schedule

Autopatch significantly closes the phased deployment gap for organizations with E3/E5 licenses.

---

### Significant Gaps

#### Third-Party Application Patching

This is the **single largest capability gap** in Intune patch management. SCCM supports third-party update catalogs via:

1. **System Center Updates Publisher (SCUP)**: Standalone tool to publish custom updates to WSUS catalog
2. **Native third-party catalog integration** (introduced SCCM 1806): Subscribe to vendor-maintained update catalogs (Adobe, Dell, HP, etc.) directly in SCCM console

**Intune has no native third-party patching capability**. Windows Update for Business catalog contains only Microsoft updates (Windows, Office, Defender, Surface firmware).

**Impact severity**: Critical for organizations with extensive third-party application portfolios. Common third-party applications requiring regular patching:

- Adobe Acrobat Reader DC
- Google Chrome
- Mozilla Firefox
- Java Runtime Environment
- 7-Zip
- VLC Media Player
- Zoom
- Slack
- Vendor-specific LOB applications

**Workarounds**:

##### Option 1: Win32 App Supersedence (Manual)

Package each application update as Win32 app, configure supersedence relationships. Requires ongoing administrative effort:

1. Monitor vendor websites for new versions
2. Download installer, wrap with IntuneWinAppUtil
3. Upload to Intune as new Win32 app
4. Configure supersedence relationship (new version supersedes old version)
5. Assign to devices
6. Repeat for next version

**Effort estimate**: 15-30 minutes per application per update. For organization with 50 third-party apps updating monthly, this represents 12-25 hours/month of administrative overhead.

##### Option 2: Third-Party Patching Solutions (Commercial)

Commercial vendors provide catalog-based third-party patching for Intune:

**[Patch My PC](https://patchmypc.com/third-party-patch-management-for-microsoft-intune)**:

- **Catalog size**: 550+ applications (as of 2026)
- **Update automation**: Monitors vendor websites, automatically creates Intune Win32 apps for new versions
- **Supersedence**: Automatically configures supersedence relationships
- **Deployment**: Configure automatic assignment to device groups
- **Pricing**: ~$2-4/device/year
- **Deployment**: On-premises publisher server or cloud-hosted option

**[Ivanti Neurons Patch for Intune](https://www.ivanti.com/products/ivanti-neurons-patch-for-intune)**:

- **Catalog size**: 500+ applications
- **Cloud-native**: No on-premises infrastructure required
- **Integration**: Publishes updates to Intune as Win32 apps
- **Pricing**: Contact vendor (subscription-based)

**[ManageEngine Patch Connect Plus](https://www.manageengine.com/sccm-third-party-patch-management/)**:

- **Catalog size**: 850+ applications
- **Hybrid support**: Patch SCCM and Intune devices from single console
- **Pricing**: Contact vendor

**Comparison**:

| Solution       | Catalog Size | Cloud/On-Prem | Typical Cost     | Notes                                       |
| -------------- | ------------ | ------------- | ---------------- | ------------------------------------------- |
| Patch My PC    | 550+ apps    | Both          | $2-4/device/year | Most popular; excellent catalog coverage    |
| Ivanti Neurons | 500+ apps    | Cloud only    | Contact vendor   | Enterprise-focused                          |
| ManageEngine   | 850+ apps    | Both          | Contact vendor   | Largest catalog; hybrid SCCM/Intune support |

**Recommendation**: Organizations with >50 third-party applications should budget for third-party patching solution. Patch My PC is most commonly deployed due to catalog coverage and competitive pricing.

##### Option 3: Enterprise Application Management (Intune Suite)

[Enterprise Application Management](https://learn.microsoft.com/en-us/mem/intune/apps/apps-enterprise-app-management) (included in Intune Suite, moving to M365 E5 from July 2026) provides curated third-party app catalog with automated updates. However:

- **Limited catalog**: ~100 applications as of early 2026 (vs 500+ in commercial solutions)
- **Microsoft curation**: Apps added based on popularity and publisher partnership
- **No custom app support**: Cannot add internal LOB apps to catalog

Enterprise App Management complements but does not replace commercial third-party patching solutions for organizations with broad application portfolios.

#### Orchestration Groups

SCCM's [orchestration groups](https://learn.microsoft.com/en-us/mem/configmgr/sum/deploy-use/orchestration-groups) control update sequencing for server clusters:

**Use cases**:

- **SQL Server Always On Availability Groups**: Patch secondary replicas first, fail over, patch primary
- **Hyper-V clusters**: Patch nodes sequentially, live-migrate VMs before patching
- **Exchange Database Availability Groups**: Patch passive copies first, switchover, patch active
- **Scale-out file servers**: Patch nodes with coordination

**SCCM orchestration group capabilities**:

- Define group membership (2-1000 devices)
- Configure sequencing:
  - Percentage-based: Patch 25% of members at a time
  - Explicit order: Patch Server1, then Server2, then Server3
- Pre-update PowerShell script: Run validation or pre-patch tasks
- Post-update PowerShell script: Run health checks or resume services
- Timeout settings: Maximum time allowed per device
- Exclusions: Definition updates bypass orchestration (SCCM 2103+)

**Intune has no orchestration group equivalent**. All devices in an update policy group receive updates simultaneously (subject to Delivery Optimization download timing).

**Impact**: Critical for clustered server workloads. Simultaneous patching of cluster nodes causes:

- Service outages (both nodes rebooting simultaneously)
- Data loss risk (database cluster quorum loss)
- Failover failures (no healthy node to accept workload)

**Workarounds**:

1. **Manual orchestration**: Create separate update policies per cluster node, manually trigger updates sequentially
2. **Scheduled task orchestration**: Deploy custom PowerShell scripts via Remediations that check cluster state, apply updates when safe
3. **Azure Automation**: Use Azure Automation Update Management for Azure VMs (supports orchestration)
4. **Co-management retention**: Keep Software Updates workload in SCCM for servers, move workstations to Intune

**Recommendation**: Organizations with clustered server workloads should retain SCCM Software Updates workload via co-management or migrate servers to Azure Automation Update Management (for Azure-hosted VMs).

#### Pre/Post-Update Scripts

SCCM supports [pre-installation and post-installation scripts](https://learn.microsoft.com/en-us/mem/configmgr/sum/deploy-use/manage-software-updates#BKMK_DeploymentPackageScripts) for software update deployments:

**Use cases**:

- Pre-update: Stop services, close applications, create backups
- Post-update: Start services, validate functionality, send notifications

**Intune has no pre/post-update script capability**. Update installation is fully automated via Windows Update Agent with no script integration points.

**Workaround**: Use [Remediations](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations) (formerly Proactive Remediations) with detection/remediation scripts that run on schedule:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt for your environment.

```powershell
# Detection script (runs hourly)
# Check if pending updates exist and services should be stopped
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$PendingUpdates = (New-Object -ComObject Microsoft.Update.Searcher).Search("IsInstalled=0").Updates
if ($PendingUpdates.Count -gt 0) {
    # Updates pending, prepare for installation
    exit 1  # Trigger remediation
} else {
    exit 0  # No remediation needed
}

# Remediation script (runs when detection returns exit 1)
# Stop services before Windows Update installs updates
Stop-Service -Name "CustomApp" -Force
Set-Content -Path "C:\Temp\PreUpdateComplete.txt" -Value (Get-Date)
```

This provides approximate functionality but lacks the precise timing integration of SCCM's pre/post-update scripts (which run immediately before/after update installation).

**Impact**: Medium. Most organizations do not require pre/post-update scripting for workstations. Server patching workflows requiring scripting should use co-management SCCM retention.

---

### Intune Advantages

#### Expedited Quality Updates

Intune's [expedited quality update feature](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-expedite-updates) enables emergency security patching within 24 hours, bypassing normal deferral policies. SCCM has no equivalent capability.

**How it works**:

1. Microsoft releases out-of-band security update (e.g., zero-day exploit mitigation)
2. Administrator creates expedited update policy in Intune
3. Intune immediately triggers update installation on targeted devices
4. Devices install update within 24 hours, overriding deferral and active hours settings
5. Devices restart automatically (grace period reduced to 2 hours)

**Use cases**:

- **Zero-day vulnerabilities**: PrintNightmare (CVE-2021-34527), Windows MSHTML (CVE-2021-40444)
- **Active exploitation**: Updates for vulnerabilities under active attack
- **Compliance emergencies**: Regulatory requirement to patch within 24 hours

**Example expedited update policy**:

```
Policy Name: Expedited - KB5034441 (January 2026 Security)
Update version: Windows 10 and later - KB5034441
Assignment: All Devices
Deployment: As soon as possible
```

Devices receive update immediately via Windows Update. Intune console shows installation progress and completion status.

**SCCM comparison**: SCCM requires manual ADR creation, content download to DPs, deployment creation, and collection assignment — minimum 2-4 hours for emergency deployment. Intune's expedited updates deploy immediately from cloud.

#### Driver and Firmware Updates

Intune can deploy [driver and firmware updates](https://learn.microsoft.com/en-us/mem/intune/protect/windows-driver-updates-overview) from Windows Update automatically. SCCM requires manual driver package creation and deployment.

**Intune driver update policy configuration**:

- **Automatically approve all drivers**: Install all manufacturer-approved drivers from Windows Update
- **Automatically approve drivers in categories**: Approve only specific categories (network adapters, storage controllers, etc.)
- **Manually approve drivers**: Review and approve individual driver updates before deployment

**Benefits**:

- **Zero driver packaging effort**: No need to download, package, and deploy driver .inf files
- **Automatic vendor updates**: Dell, HP, Lenovo publish driver updates to Windows Update; Intune deploys automatically
- **Hardware-specific targeting**: Windows Update only offers drivers compatible with device hardware

**Limitations**:

- Requires manufacturers to publish drivers to Windows Update catalog
- Some enterprise hardware (servers, specialized workstations) may not have drivers in Windows Update
- Cannot deploy custom or modified drivers

**Recommendation**: Enable automatic driver updates for workstations (most modern hardware fully supported). Use SCCM driver packages for servers or specialized hardware not in Windows Update catalog.

#### Windows Autopatch

[Windows Autopatch](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-overview) is a fully managed update service that automates patch deployment with progressive rollout, testing, and rollback capabilities. SCCM has no equivalent managed service.

**How Autopatch works**:

1. **Automatic device grouping**: Autopatch assigns devices to deployment rings (Test, First, Fast, Broad) based on registration order or admin override
2. **Automated deployment schedule**:
   - **Test ring**: Updates 1 day after release (Patch Tuesday + 1)
   - **First ring**: Updates 2 days after Test ring completes successfully
   - **Fast ring**: Updates 3 days after First ring completes
   - **Broad ring**: Updates 7 days after Fast ring completes
3. **Automated monitoring**: Microsoft monitors installation success rates, error rates, compatibility holds
4. **Automated rollback**: If compatibility issue detected, Microsoft pauses deployment and publishes safeguard hold
5. **Microsoft-managed**: Microsoft engineers manage deployment schedule, monitoring, and incident response

**What's included**:

- Windows quality updates (monthly security updates)
- Windows feature updates (annual/semi-annual version upgrades)
- Microsoft 365 Apps updates
- Microsoft Edge updates
- Microsoft Defender updates

**What's not included**:

- Third-party application updates (requires separate third-party patching solution)
- Driver updates (separate driver update policy recommended)

**Licensing**:

- **Before July 2026**: Standalone add-on ($2-3/user/month) or Intune Suite ($10/user/month)
- **After July 2026**: Included in Microsoft 365 E3/E5 at no additional cost (part of $3/user/month price increase)

**Comparison to manual update ring management**:

| Capability          | Manual Update Rings                                  | Windows Autopatch                                            |
| ------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| Ring creation       | Manual (create groups, policies)                     | Automatic (Autopatch creates rings)                          |
| Deployment schedule | Manual (configure deferral per ring)                 | Automatic (Microsoft-managed schedule)                       |
| Monitoring          | Manual (review reports, identify issues)             | Automatic (Microsoft monitors and responds)                  |
| Rollback            | Manual (remove assignments, create uninstall policy) | Automatic (Microsoft pauses deployment, publishes safeguard) |
| Incident management | Customer responsibility                              | Microsoft responsibility                                     |

**Recommendation**: Organizations with M365 E3/E5 licenses should strongly consider Windows Autopatch (especially post-July 2026 when included). Eliminates manual update management overhead while providing enterprise-grade deployment automation.

**Exclusions**: Autopatch is not suitable for:

- Servers (Windows Server not supported)
- Devices requiring strict maintenance windows (Autopatch controls deployment schedule)
- Air-gapped or restricted internet environments (requires cloud connectivity)

---

## Licensing Impact

### Base Features (Intune Plan 1 / M365 E3)

All core patch management features are included in **Intune Plan 1**, which is bundled with:

- Microsoft 365 E3/E5
- Microsoft 365 Business Premium
- Enterprise Mobility + Security (EMS) E3/E5
- Standalone Intune Plan 1 ($8/user/month)

**Included features**:

- Windows Update for Business
- Update rings (quality and feature updates)
- Feature update policies
- Expedited quality updates
- Driver and firmware update policies
- Windows Update for Business reports (28-day retention)
- Delivery Optimization (Windows feature, no licensing cost)
- Microsoft Connected Cache (Windows Server feature, no Intune licensing cost)

### Premium Features

**Windows Autopatch**:

- **Before July 2026**: Standalone add-on ($2-3/user/month) or Intune Suite ($10/user/month)
- **After July 2026**: Included in Microsoft 365 E3/E5 (no additional cost beyond $3/user/month M365 price increase)

**Azure Log Analytics** (for extended WUfB report retention):

- Consumption-based pricing: ~$2.30/GB ingestion
- Requires Azure subscription

### Third-Party Solutions (Not Microsoft Licensed)

| Solution                            | Typical Cost     | Licensing Model                     |
| ----------------------------------- | ---------------- | ----------------------------------- |
| **Patch My PC**                     | $2-4/device/year | Per-device subscription             |
| **Ivanti Neurons Patch for Intune** | Contact vendor   | Per-device or per-user subscription |
| **ManageEngine Patch Connect Plus** | Contact vendor   | Per-device subscription             |

**Budget planning**: Organizations with 1,000 devices requiring third-party patching should budget approximately $2,000-4,000/year for Patch My PC or equivalent solution.

### Total Cost of Ownership Comparison

**SCCM patch management costs** (1,000 devices, 3-year period):

- SCCM licensing: $50,000-100,000 (System Center Configuration Manager license)
- Infrastructure: $30,000-60,000 (servers, SQL Server, WSUS, DPs)
- Administrative overhead: $90,000-150,000 (1 FTE at $30-50k/year × 3 years)
- **Total**: $170,000-310,000

**Intune patch management costs** (1,000 devices, 3-year period):

- Intune licensing: $0 (included in M365 E3 at $36/user/month × 1,000 users × 36 months = $1,296,000 total M365 cost, but Intune is just one component)
- Third-party patching: $6,000-12,000 (Patch My PC at $2-4/device/year × 3 years)
- Windows Autopatch: $0 (included in M365 E3 from July 2026)
- Infrastructure: $0 (cloud service)
- Administrative overhead: $30,000-60,000 (0.3-0.5 FTE with Autopatch automation)
- **Total incremental cost**: $36,000-72,000 (assuming M365 E3 already licensed)

**Savings**: $134,000-238,000 over 3 years primarily due to infrastructure elimination and reduced administrative overhead with Autopatch.

See [Executive Summary — Licensing Summary](executive-summary.md) for comprehensive licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Assessment

#### Update Deployment Inventory

Audit SCCM update deployments before migration:

```sql
-- SQL query for SCCM database to inventory update deployments
SELECT
    upd.ArticleID AS KB_Article,
    upd.Title AS Update_Title,
    dep.CollectionName,
    dep.DeploymentTime,
    dep.EnforcementDeadline,
    dep.AvailableTime,
    COUNT(DISTINCT cs.ResourceID) AS TargetedDevices,
    SUM(CASE WHEN cs.StateID = 3 THEN 1 ELSE 0 END) AS InstalledCount,
    SUM(CASE WHEN cs.StateID IN (1,2) THEN 1 ELSE 0 END) AS PendingCount,
    SUM(CASE WHEN cs.StateID IN (4,5) THEN 1 ELSE 0 END) AS FailedCount
FROM v_UpdateDeploymentSummary upd
INNER JOIN v_CIAssignment dep ON upd.AssignmentID = dep.AssignmentID
LEFT JOIN v_ClientStateInformation cs ON dep.AssignmentID = cs.AssignmentID
GROUP BY upd.ArticleID, upd.Title, dep.CollectionName, dep.DeploymentTime, dep.EnforcementDeadline, dep.AvailableTime
ORDER BY dep.DeploymentTime DESC
```

#### Automatic Deployment Rule Analysis

Document ADR configurations for Intune update ring translation:

| ADR Setting                                                | Intune Equivalent                            | Migration Action                                         |
| ---------------------------------------------------------- | -------------------------------------------- | -------------------------------------------------------- |
| Run schedule (e.g., 2nd Tuesday monthly)                   | Automatic (updates release on Patch Tuesday) | No configuration needed; updates automatically available |
| Deferral period (e.g., 7 days pilot, 30 days production)   | Quality update deferral (0-30 days)          | Create update rings with matching deferral periods       |
| Deployment collection (e.g., Workstations-Pilot)           | Azure AD group assignment                    | Create Azure AD groups matching SCCM collections         |
| Enforcement deadline (e.g., 7 days after available)        | Deadline for quality updates (1-30 days)     | Configure deadline in update ring settings               |
| User experience (allow restart outside maintenance window) | Restart grace period                         | Configure grace period to match SCCM behavior            |

#### Third-Party Update Catalog Assessment

Identify third-party applications currently patched via SCCM/SCUP:

```sql
-- SQL query to identify non-Microsoft updates deployed
SELECT DISTINCT
    upd.Publisher,
    upd.Title,
    upd.ArticleID,
    COUNT(DISTINCT dep.CollectionID) AS DeployedToCollections
FROM v_UpdateInfo upd
INNER JOIN v_CIAssignment dep ON upd.CI_ID = dep.CI_ID
WHERE upd.Publisher NOT LIKE 'Microsoft%'
GROUP BY upd.Publisher, upd.Title, upd.ArticleID
ORDER BY upd.Publisher, upd.Title
```

For each third-party application:

- Verify availability in Patch My PC / Ivanti catalog
- Determine if application is business-critical (prioritize for third-party patching solution)
- Identify alternative update methods (winget, Microsoft Store, vendor auto-update)

### Migration Strategies

#### Strategy 1: Phased Workload Migration (Co-Management)

**Best for**: Large environments (>2,000 devices), organizations with servers

**Timeline**: 4-6 months

**Phases**:

1. **Enable Co-Management** (Week 1-2)
   - Configure Azure AD Hybrid Join or Azure AD join
   - Enable co-management in SCCM console
   - Set Windows Update workload slider to **SCCM** (baseline)

2. **Pilot Windows Update for Business** (Week 3-6)
   - Create Intune update rings for pilot group (50-100 workstations)
   - Shift pilot devices' Windows Update workload to **Intune** via co-management policy
   - Monitor update deployment for 2-3 update cycles
   - Validate update installation, restart behavior, reporting

3. **Migrate Workstations to Intune** (Week 7-16)
   - Shift Windows Update workload slider to **Intune** for all workstations
   - Decommission workstation ADRs in SCCM
   - Configure Intune update rings matching previous SCCM deployment rings
   - Monitor update compliance in WUfB reports

4. **Deploy Third-Party Patching Solution** (Week 17-20)
   - Deploy Patch My PC publisher server or cloud connector
   - Configure automatic app deployment rules
   - Assign third-party apps to device groups
   - Monitor third-party update deployment

5. **Evaluate Server Update Strategy** (Week 21-24)
   - **Option A**: Retain SCCM for servers (co-management indefinitely)
   - **Option B**: Migrate servers to Azure Automation Update Management (if Azure-hosted)
   - **Option C**: Migrate servers to Intune with manual orchestration scripts

**Advantages**:

- Low risk (devices can revert to SCCM instantly via workload slider)
- Incremental validation (pilot before broad deployment)
- Servers remain on SCCM if Intune gaps are unacceptable

**Disadvantages**:

- Requires co-management infrastructure (Azure AD Hybrid Join)
- Longer migration timeline (4-6 months)

#### Strategy 2: Greenfield Cutover

**Best for**: Smaller environments (<500 devices), cloud-first organizations, workstation-only environments

**Timeline**: 4-8 weeks

**Steps**:

1. **Week 1-2: Design and Preparation**
   - Create Azure AD groups (Ring-0-IT, Ring-1-Pilot, Ring-2-Production)
   - Design update ring policies (deferral, deadline, restart settings)
   - Procure third-party patching solution (if required)
   - Document rollback plan

2. **Week 3-4: Pilot Deployment**
   - Unenroll 50-100 pilot devices from SCCM (uninstall ConfigMgr client)
   - Enroll pilot devices in Intune (Azure AD join or Hybrid Join)
   - Assign update ring policies to pilot group
   - Monitor update deployment for 2-3 weeks

3. **Week 5-6: Production Cutover**
   - Unenroll production workstations from SCCM
   - Enroll in Intune via Autopilot or ConfigMgr client uninstall + re-enrollment
   - Assign update ring policies to production groups
   - Deploy third-party patching solution

4. **Week 7-8: Validation and Decommissioning**
   - Validate update installation success rates
   - Verify third-party patching automation
   - Decommission SCCM Software Update Point (if no servers remaining)
   - Archive SCCM update deployment history

**Advantages**:

- Fast migration timeline (4-8 weeks)
- Clean separation (no co-management complexity)
- Forces cloud-first adoption

**Disadvantages**:

- Higher risk (all devices must migrate successfully)
- Production disruption if issues occur
- Cannot support servers requiring orchestration

#### Strategy 3: Hybrid Long-Term (Selective Migration)

**Best for**: Organizations with complex server patching requirements, regulated industries with strict change control

**Permanent state**:

- **Workstations**: Intune Windows Update for Business
- **Servers**: SCCM Software Updates workload (orchestration groups, maintenance windows, pre/post scripts)

**Configuration**:

1. Enable co-management for workstations
2. Shift Windows Update workload to Intune for workstation collections
3. Keep Windows Update workload in SCCM for server collections
4. Maintain SCCM infrastructure for server patching indefinitely

**Advantages**:

- Leverages strengths of both platforms
- Eliminates Intune gaps for server patching
- Workstations gain cloud-native update benefits

**Disadvantages**:

- Permanent dual-platform administrative overhead
- License costs for both platforms (SCCM + Intune)
- Requires ongoing co-management maintenance

### Common Migration Issues and Resolutions

| Issue                                                         | Cause                                                | Resolution                                                                                                                   |
| ------------------------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Devices not receiving updates from Intune**                 | Update ring not assigned or filter excluding devices | Verify Azure AD group membership; check filter evaluation in Intune console                                                  |
| **Updates installing during business hours**                  | Active hours not configured or incorrectly set       | Configure Active Hours via device configuration profile or update ring settings                                              |
| **Devices showing "Not compliant" despite updates installed** | WUfB reports data lag (24-48 hours)                  | Wait 48 hours for reporting sync; force device sync via Intune remote action                                                 |
| **Feature update not deploying**                              | Device not compatible or safeguard hold active       | Check Windows Update troubleshooting logs; review safeguard holds in WUfB reports                                            |
| **Third-party apps not updating**                             | Patch My PC assignment missing or detection failing  | Verify Patch My PC console shows app deployment; check Intune Win32 app assignment and detection rules                       |
| **Devices restarting unexpectedly**                           | Deadline reached or grace period expired             | Review update ring deadline and grace period settings; increase grace period if needed                                       |
| **"Download paused" error**                                   | Delivery Optimization connectivity issue             | Verify firewall allows DO endpoints (http://dl.delivery.mp.microsoft.com); check DO status: `Get-DeliveryOptimizationStatus` |

### Server Patching Decision Matrix

| Server Type                                                     | Recommended Solution                     | Rationale                                                                           |
| --------------------------------------------------------------- | ---------------------------------------- | ----------------------------------------------------------------------------------- |
| **Azure VMs**                                                   | Azure Automation Update Management       | Native Azure service; supports orchestration, maintenance windows, pre/post scripts |
| **On-prem clustered workloads** (SQL AG, Hyper-V, Exchange DAG) | SCCM (co-management retention)           | Orchestration groups; proven cluster patching workflows                             |
| **On-prem standalone servers**                                  | Intune with custom orchestration scripts | Acceptable for non-clustered; use Remediations for pre/post tasks                   |
| **Windows Server Core**                                         | SCCM or Azure Automation                 | Intune Company Portal not available on Server Core; command-line management only    |
| **DMZ / restricted servers**                                    | SCCM with on-prem DP                     | Intune requires internet connectivity to Microsoft Update                           |

### Windows Autopatch Enablement

For organizations with M365 E3/E5 licenses (especially post-July 2026):

**Prerequisites**:

- Windows 10 20H2+ or Windows 11
- Azure AD join (Hybrid Join supported with caveats)
- Intune enrollment
- 256MB RAM minimum
- Internet connectivity to Windows Update endpoints

**Enrollment steps**:

1. **Register tenant**: Intune admin center > Tenant administration > Windows Autopatch > Register
2. **Review prerequisites**: Autopatch runs automated tenant configuration check (Azure AD, Intune policies, Update rings)
3. **Configure deployment rings**: Autopatch creates 4 default rings or use existing groups
4. **Register devices**: Assign devices to Autopatch via Azure AD group
5. **Monitor deployment**: Autopatch dashboard shows deployment progress, issues, recommendations

**Devices excluded from Autopatch**:

- Windows Server
- Azure Virtual Desktop session hosts
- Devices not connected to internet at least once per week
- Devices managed by SCCM (co-management conflicts with Autopatch)

**Autopatch limitations**:

- No maintenance window support (Autopatch controls deployment schedule)
- Limited customization (Microsoft manages deployment timing)
- Requires trust in Microsoft-managed service

**Recommendation**: Pilot Autopatch with 10-20% of devices before broad enrollment. Monitor for 2-3 update cycles before expanding to production.

---

## Sources

### Microsoft Learn Documentation

- [Windows Update Management Overview - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-update-for-business-configure)
- [Manage Windows Feature Updates - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-feature-updates)
- [Manage Windows Quality Updates - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-expedite-updates)
- [Windows Update for Business Reports Overview](https://learn.microsoft.com/en-us/windows/deployment/update/wufb-reports-overview)
- [Automatically Deploy Software Updates - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/sum/deploy-use/automatically-deploy-software-updates)
- [Orchestration Groups - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/sum/deploy-use/orchestration-groups)
- [Use Maintenance Windows - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/core/clients/manage/collections/use-maintenance-windows)
- [Windows Autopatch Overview](https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-overview)
- [Delivery Optimization Reference](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization-reference)
- [Microsoft Connected Cache for Enterprise](https://learn.microsoft.com/en-us/windows/deployment/do/mcc-ent-edu-overview)
- [Windows Update Restart Management](https://learn.microsoft.com/en-us/windows/deployment/update/waas-restart)
- [Update Compliance Safeguard Holds](https://learn.microsoft.com/en-us/windows/deployment/update/update-compliance-feature-update-status#safeguard-holds)
- [Driver Updates Overview - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-driver-updates-overview)
- [Enterprise Application Management](https://learn.microsoft.com/en-us/mem/intune/apps/apps-enterprise-app-management)

### Community and Technical Resources

- [Third-Party Patch Management in Microsoft Intune How-to Guide - Patch My PC](https://patchmypc.com/blog/now-available-third-party-patch-management-in-microsoft-intune-how-to-guide/)
- [Patch My PC Third-Party Patch Management for Intune](https://patchmypc.com/third-party-patch-management-for-microsoft-intune)
- [Ivanti Neurons Patch for Intune](https://www.ivanti.com/products/ivanti-neurons-patch-for-intune)
- [ManageEngine Patch Connect Plus - Intune Integration](https://www.manageengine.com/patch-management/intune-patch-management.html)
- [Windows Patching via Intune - Recast](https://www.recastsoftware.com/resources/windows-patching-via-intune/)
- [Microsoft Intune vs. Configuration Manager for Third-Party Application Patching - Recast](https://www.recastsoftware.com/resources/microsoft-intune-vs-configuration-manager-for-third-party-application-patching/)
- [Intune Patch Management Solutions - Microsoft Community Hub](https://techcommunity.microsoft.com/discussions/microsoft-intune/intune-patch-management-solutions/3971883)

---

**Research Date**: February 18, 2026
**Primary Sources**: Microsoft Learn official documentation, Microsoft Community Hub, verified third-party technical resources
