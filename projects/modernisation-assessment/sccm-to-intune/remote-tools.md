# Remote Tools & Client Management — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Partial to Significant Gap

---

## Executive Summary

SCCM's remote tools provide **unattended remote desktop control**, **wake-on-LAN**, **power management**, and extensive **client notification** capabilities that significantly exceed Intune's current remote action offerings. Intune covers core device management actions (**wipe, retire, sync, restart, diagnostics**) and offers **Remote Help** for user-present remote assistance (included in M365 E3 starting July 2026), but lacks unattended remote control, wake-on-LAN, and power management. Organizations dependent on **silent remote desktop control** for helpdesk workflows face a **Significant Gap** and must evaluate third-party solutions (**TeamViewer Tensor/Corporate** requires separate licensing) or retain SCCM co-management for the Remote Tools workload. **Wake-on-LAN** and **power management** have no Intune equivalents, requiring acceptance of capability loss, third-party tools, or on-premises scripts.

---

## Feature Parity Matrix

| SCCM Feature                                                          | Intune Equivalent                               | Parity Rating   | Licensing                                                                  | Notes                                                                                                          |
| --------------------------------------------------------------------- | ----------------------------------------------- | --------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Remote Control (Unattended Desktop Control)**                       | Remote Help (User-Present)                      | Significant Gap | Remote Help: Intune Suite (M365 E3 July 2026+) or standalone ~$3.50/user/month | SCCM allows silent remote desktop; Remote Help requires user acceptance                                        |
| **Remote Desktop Connection**                                         | Remote Desktop (via Quick Assist or TeamViewer) | Partial         | Quick Assist: Free (Windows built-in); TeamViewer: Third-party license     | SCCM right-click RDP; Intune requires manual RDP or third-party tools                                          |
| **Client Notifications (Policy Refresh, App Eval, Script Execution)** | Device Sync + Bulk Actions                      | Partial         | Intune Plan 1                                                              | SCCM client notifications trigger instant actions; Intune sync forces check-in (not instant)                   |
| **Client Push Installation**                                          | Autopilot / Manual Enrollment                   | No Equivalent   | Intune Plan 1 (Autopilot free with M365)                                   | SCCM installs client remotely; Intune requires device enrollment (user-driven or zero-touch)                   |
| **Client Health Evaluation (ccmeval)**                                | Intune Device Sync + Compliance Policies        | Partial         | Intune Plan 1                                                              | SCCM client health remediation automatic; Intune relies on compliance policies for health checks               |
| **Client Settings Management**                                        | Configuration Policies (Settings Catalog)       | Full Parity     | Intune Plan 1                                                              | Both manage client/device configurations; Intune uses CSPs vs. SCCM client agent settings                      |
| **Wake-on-LAN (WoL)**                                                 | No Equivalent                                   | No Equivalent   | N/A                                                                        | SCCM wakes sleeping devices remotely; no Intune equivalent (requires third-party solutions)                    |
| **Power Management (Power Plans, Schedules)**                         | No Equivalent                                   | No Equivalent   | N/A                                                                        | SCCM applies power plans to collections; no Intune equivalent (use Group Policy or third-party)                |
| **Client Peer Cache**                                                 | Delivery Optimization                           | Near Parity     | Intune Plan 1 (DO free with Windows)                                       | SCCM peer cache for content; Windows Delivery Optimization provides P2P content delivery                       |
| **Remote Actions (Wipe, Retire, Restart, Sync, Diagnostics)**         | Intune Remote Actions                           | Full Parity     | Intune Plan 1                                                              | Intune provides comprehensive remote actions (wipe, retire, restart, sync, diagnostics, Autopilot reset, etc.) |
| **Bulk Device Actions**                                               | Bulk Actions (up to 100 devices)                | Full Parity     | Intune Plan 1                                                              | Both support bulk operations on device selections                                                              |
| **Run Scripts**                                                       | Platform Scripts / Proactive Remediations       | Partial         | Intune Plan 1 (Remediations require Endpoint Analytics in M365 E3)         | SCCM Run Scripts instant on-demand execution; Intune scripts scheduled or deployment-based                     |

---

## Key Findings

### 1. Full Parity Areas

#### 1.1 Intune Remote Actions

**SCCM Capability**: Configuration Manager provides limited remote actions via device context menu (ConfigMgr console):

- **Remote Control** (unattended desktop control)
- **Remote Assistance** (user-present assistance)
- **Remote Desktop Connection** (RDP launch)
- **Client Notification actions** (policy refresh, app evaluation, hardware inventory)
- **Retire/Wipe** (remove ConfigMgr client or wipe device)
- **Restart Computer** (remote restart)

SCCM's remote actions focus on client management (policy refresh, inventory cycles) and remote access (Remote Control, Remote Assistance, RDP).

**Intune Capability**: Intune provides **comprehensive remote device actions** accessible from the Intune admin center (Devices > [Device Name] > Overview > Device actions):

**Core Remote Actions**:

- **Wipe**: Factory reset device (removes all data, apps, configurations)
- **Retire**: Remove company data without full wipe (unenrolls device, removes managed apps/settings/profiles, preserves personal data)
- **Sync**: Force device check-in with Intune (retrieves pending actions and policies)
- **Restart**: Restart device remotely
- **Fresh Start**: Windows reset with user data preserved (removes OEM bloatware)
- **Autopilot Reset**: Reset device to Autopilot OOBE state (re-enrollment required)
- **Remote Lock**: Lock device remotely (mobile devices)
- **Collect Diagnostics**: Gather device logs for troubleshooting (Windows 10/11)
- **Rotate BitLocker Keys**: Force BitLocker recovery key rotation (Windows)
- **Rename**: Rename device (updates device name in Intune and Entra ID)
- **Custom Notifications**: Send organizational messages to users (Windows 10/11, displayed in Notifications area)
- **Bulk Actions**: Apply actions to up to 100 devices simultaneously

**Platform-Specific Actions**:

- **Windows**: Wipe, retire, sync, restart, Fresh Start, Autopilot reset, diagnostics, BitLocker rotation, rename
- **macOS**: Wipe, retire, sync, restart, rotate FileVault key, remote lock
- **iOS/iPadOS**: Wipe, retire, sync, restart, remote lock, lost mode, locate device, play sound, bypass activation lock
- **Android**: Wipe, retire, sync, restart, remote lock

**Action Precedence**: Retire, Wipe, and Delete actions take precedence over other actions. If multiple actions pending, system carries out retire/wipe/delete first and ignores others.

**Parity Assessment**: **Full Parity**. Intune remote actions cover core device management scenarios and exceed SCCM's remote action capabilities in many areas (Fresh Start, Autopilot Reset, diagnostics collection, bulk actions).

**Migration Considerations**:

- **Retire vs. Wipe**: Understand difference (Retire = remove company data, preserve personal; Wipe = factory reset)
- **Bulk actions**: Use for patching-related restarts (e.g., "Restart 50 devices after critical update deployment")
- **Diagnostics collection**: Use for troubleshooting Windows 10/11 devices (replaces manual log collection)
- **Custom notifications**: Use for user communication (e.g., "Your device is out of compliance; please contact IT")

**Sources**:

- [Remote actions available for devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/)
- [Bulk device actions in Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/#bulk-device-actions)
- [Intune Remote Wipe, Retire, Fresh Start, Autopilot Reset - Call4Cloud](https://call4cloud.nl/2021/05/intune-remote-wipe-retire-fresh-start-autopilot-reset/)

#### 1.2 Client Settings Management (Configuration Policies)

**SCCM Capability**: Configuration Manager **Client Settings** control ConfigMgr client agent behavior:

- **Hardware Inventory**: Enable/disable, schedule (default 7 days)
- **Software Inventory**: Enable/disable, schedule, file types to inventory
- **Software Metering**: Enable/disable, data collection schedule
- **Software Updates**: Scan schedule, deadline behavior, maintenance windows
- **Remote Tools**: Enable remote control, prompt user, audio settings
- **Computer Agent**: Organization name, software center branding, notifications
- **Power Management**: Enable power management, power plans, wakeup settings
- **Client Policy**: Policy polling interval (default 60 minutes)
- **Endpoint Protection**: Manage Endpoint Protection client, deployment settings
- **Background Intelligent Transfer**: BITS throttling, network usage windows

Client settings deploy to device collections (default client settings apply to all devices; custom client settings override default).

**Intune Capability**: Intune **Configuration Policies** manage device settings via Windows CSPs (Configuration Service Providers):

**Policy Types**:

- **Device Configuration Profiles**: Pre-built templates (Device restrictions, Email, VPN, Wi-Fi, etc.)
- **Settings Catalog**: 5000+ granular settings organized by category (same settings as SCCM client settings but CSP-based)
- **Administrative Templates**: Group Policy ADMX settings (for domain-joined or Entra joined devices)
- **Custom Policies**: OMA-URI configurations for advanced scenarios

**Settings Catalog Categories** (equivalent to SCCM client settings):

- **Windows Update for Business**: Update policies, scan schedules, deadlines, maintenance windows
- **Delivery Optimization**: P2P content delivery, bandwidth throttling, caching
- **Microsoft Defender Antivirus**: Scan schedules, real-time protection, exclusions (equivalent to SCCM Endpoint Protection)
- **Experience**: Branding, notifications, Start menu, Taskbar
- **Privacy**: Telemetry, diagnostic data, activity history
- **System**: Power management, storage sense, Windows services

**Parity Assessment**: **Full Parity**. Both manage client/device configurations. Intune uses modern CSP-based configuration vs. SCCM's client agent settings registry model.

**Migration Considerations**:

- **Inventory SCCM client settings**: Export custom client settings (PowerShell: `Get-CMClientSetting`)
- **Map to Intune Settings Catalog**: Use Settings Catalog picker to find equivalent CSPs
- **Test configurations**: Deploy to pilot group before broad rollout (especially Delivery Optimization bandwidth settings)
- **Combine with Compliance Policies**: Use Compliance Policies for enforcement (mark device non-compliant if setting not applied)

**Sources**:

- [Use the settings catalog to configure settings](https://learn.microsoft.com/en-us/intune/intune-service/configuration/settings-catalog)
- [Configuration Manager Client Settings](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/deploy/about-client-settings)

#### 1.3 Content Delivery (Client Peer Cache vs. Delivery Optimization)

**SCCM Capability**: Configuration Manager **Client Peer Cache** allows clients to share content with other clients on the same subnet:

- **Enable via client settings**: Administration > Client Settings > Client Cache Settings > "Enable Configuration Manager client in full OS to share content" = Yes
- **Clients cache content**: Apps, software updates, OS images stored in ccmcache and served to peers
- **Boundary group integration**: Clients in same boundary group share content
- **Reduces WAN bandwidth**: Branch office clients download from local peer cache instead of distribution point over WAN
- **Fallback to DP**: If no peer cache source available, client downloads from distribution point

**Configuration** (client settings):

- Minimum duration before cached content can be accessed by peer (default: 0 minutes)
- Maximum percentage of disk space for cache (default: 50%)
- Enable peer cache to allow user computers to share content on same subnet

**Intune Capability**: Windows **Delivery Optimization** provides native peer-to-peer content sharing:

**Delivery Optimization Policies** (Intune > Devices > Configuration profiles > Delivery optimization):

- **Download mode**:
  - **HTTP only (0)**: No P2P, downloads from Windows Update or Intune only
  - **LAN (1)**: P2P on local network (same subnet)
  - **Group (2)**: P2P across devices in same group (Group ID-based)
  - **Internet (3)**: P2P across Internet peers (Microsoft global P2P network)
  - **Simple (99)**: HTTP downloads without P2P
  - **Bypass (100)**: BITS used instead of Delivery Optimization
- **Group ID**: Define custom group for scoped peering (devices in same group share content)
- **Maximum upload bandwidth**: Absolute (KB/s) or percentage of available bandwidth
- **Maximum download bandwidth**: Absolute (KB/s) or percentage of available bandwidth
- **Minimum background download bandwidth**: Minimum guaranteed bandwidth for background downloads
- **Cache configuration**: Foreground/background download cache age, max cache size, minimum disk size

**Content Types Supported**:

- Windows updates (quality updates, feature updates)
- Microsoft Store apps
- Intune Win32 apps (deployed via Intune Management Extension)
- Microsoft 365 Apps (Office deployment)

**Automatic Peer Discovery**:

- **LAN mode**: Devices discover peers on same subnet (broadcast/multicast)
- **Group mode**: Devices in same Group ID discover each other (cloud-managed groups via Microsoft cloud service)
- **Internet mode**: Devices connect to Microsoft cloud service to find peers globally

**Parity Assessment**: **Near Parity**. Delivery Optimization provides equivalent P2P content delivery with cloud-native management. Some differences:

- **SCCM peer cache**: More granular control (boundary groups, specific DPs); requires boundary group configuration
- **Delivery Optimization**: Broader content support (Microsoft Store, M365 Apps); no infrastructure required (cloud-managed)

**Migration Considerations**:

- **Disable SCCM peer cache**: Disable client peer cache in SCCM client settings before migration
- **Enable Delivery Optimization**: Deploy Delivery Optimization policy to all devices (LAN or Group mode)
- **Configure Group IDs**: For branch offices, use Group mode with site-specific Group IDs (e.g., GroupID = "BranchOffice-NYC")
- **Monitor bandwidth**: Use Delivery Optimization bandwidth policies to prevent network saturation
- **Test with pilot**: Validate P2P content sharing works across different network topologies

**Example Group ID Strategy**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```
Site 1 (HQ): GroupID = "Site01-HQ"
Site 2 (NYC): GroupID = "Site02-NYC"
Site 3 (LA): GroupID = "Site03-LA"
```

Devices in same site share content with each other but not across sites (reduces inter-site WAN traffic).

**Sources**:

- [Delivery Optimization settings for Windows devices in Intune](https://learn.microsoft.com/en-us/intune/intune-service/configuration/delivery-optimization-windows)
- [Peer Cache for Configuration Manager clients](https://learn.microsoft.com/en-us/intune/configmgr/core/plan-design/hierarchy/client-peer-cache)

---

### 2. Partial Parity / Gaps

#### 2.1 Client Notifications and Immediate Actions

**SCCM Capability**: Configuration Manager **Client Notification** allows immediate trigger of client actions via fast channel:

**Available Actions** (right-click device or collection in ConfigMgr console):

- **Download Computer Policy**: Machine policy retrieval & evaluation (instant policy refresh)
- **Download User Policy**: User policy retrieval (for user-targeted deployments)
- **Send Discovery Data Record**: Force heartbeat discovery DDR
- **Collect Discovery Data**: Trigger discovery method execution
- **Run Application Deployment Evaluation Cycle**: Re-evaluate all app deployments
- **Run Software Updates Deployment Evaluation Cycle**: Re-scan for software updates
- **Run Hardware Inventory Cycle**: Force immediate hardware inventory collection
- **Run Software Inventory Cycle**: Force immediate software inventory collection
- **Run Software Metering Usage Report Cycle**: Upload software metering data
- **Re-evaluate all deployments**: Run all evaluation cycles (apps, updates, baselines)
- **Trigger client health check (ccmeval)**: Force client health evaluation and remediation
- **Run custom scripts**: Execute PowerShell scripts via Run Scripts feature (instant on-demand execution)

**Execution Method**: Uses fast channel (client notification infrastructure, same as CMPivot and Endpoint Protection notifications)

**Scope**: Apply to individual devices or entire collections (bulk actions)

**Use Cases**:

- Force policy refresh after critical deployment (e.g., "New antivirus policy deployed; force all devices to retrieve policy immediately")
- Trigger immediate software update scan after Patch Tuesday
- Collect hardware inventory for troubleshooting (e.g., "Verify RAM upgrade on device X")
- Run compliance baseline evaluation for audit (e.g., "Run CIS baseline evaluation on all servers now")
- Execute remediation scripts immediately (via Run Scripts)

**Intune Capability**: Intune provides limited equivalents for immediate actions:

**1. Device Sync**:

- **Access**: Devices > [Device Name] > Overview > Sync (or Bulk Actions > Sync for multiple devices)
- **Function**: Forces device to check in with Intune immediately (retrieves pending policies, apps, configurations)
- **Limitation**: Not as granular as SCCM client notifications (syncs all policies, not specific cycles like "hardware inventory only")
- **Check-in interval**: Normal check-in every 8 hours (Windows); Sync forces immediate check-in

**2. Bulk Device Actions** (up to 100 devices):

- **Restart devices**: Remote restart (useful after critical updates)
- **Quick scan** (Windows Defender): Force immediate quick scan
- **Full scan** (Windows Defender): Force immediate full scan
- **Sync devices**: Bulk sync (same as Device Sync but for multiple devices)
- **Rotate BitLocker keys**: Force BitLocker recovery key rotation
- **Collect diagnostics**: Gather logs from multiple devices

**3. Proactive Remediations** (scheduled scripts):

- **Detection and remediation scripts**: PowerShell scripts run on schedule (hourly, daily, weekly)
- **Not immediate on-demand execution**: Scripts run according to schedule (cannot trigger "run now" from console)
- **Manual trigger per device**: Can manually trigger from individual device (Devices > [Device Name] > Proactive remediations > [Remediation] > Run)
- **Requires Endpoint Analytics licensing**: Included in M365 E3/E5/A3/A5, Windows 10/11 Enterprise E3/E5

**4. Platform Scripts**:

- **PowerShell scripts** (Windows) and **Shell scripts** (macOS/Linux): Deploy scripts as required or available
- **Execution**: Scripts run once at deployment or on schedule (recurring scripts)
- **No instant "run now"**: Cannot trigger immediate execution from console (SCCM Run Scripts has instant execution)

**Parity Assessment**: **Partial**. Intune Device Sync replicates basic policy refresh but lacks:

- **Granular cycle triggers**: Cannot trigger "hardware inventory now" or "software update scan now" independently
- **Immediate script execution**: SCCM Run Scripts has instant on-demand execution; Intune scripts scheduled or deployment-based

**Gap Impact**:

| SCCM Use Case                                                   | Intune Alternative                                                                                                       |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| "Force policy refresh on 500 devices after critical deployment" | Device Sync (bulk action up to 100 devices; must repeat for 500)                                                         |
| "Run hardware inventory now for troubleshooting"                | No equivalent; inventory runs on 7-day schedule or manual sync (but sync doesn't force inventory, just policy retrieval) |
| "Trigger software update scan immediately"                      | Device Sync forces check-in; update scan runs on schedule (cannot force instant scan)                                    |
| "Execute remediation script now on 10 devices"                  | Deploy PowerShell script as required; execution happens on next check-in (not instant)                                   |

**Workarounds**:

1. **Device Sync for policy refresh**: Use Device Sync (or Bulk Sync) for immediate policy retrieval (closest to "Download Computer Policy")
2. **Proactive Remediations for scheduled actions**: Accept scheduled execution (hourly minimum) instead of instant on-demand
3. **Platform Scripts with immediate deployment**: Deploy PowerShell script as required to specific devices; script runs on next check-in (typically within 8 hours)
4. **MDE Live Response** (if MDE P2 licensed): For security scenarios, use MDE Live Response to execute PowerShell scripts instantly on remote devices

**Sources**:

- [Client notification - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/client-notification)
- [Remote actions available for devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/device-remote-wipe)
- [Bulk device actions in Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/#bulk-device-actions)

#### 2.2 Client Health Evaluation

**SCCM Capability**: Configuration Manager **Client Health Evaluation** (`ccmeval.exe`) runs automatically to remediate common client issues:

**Automatic Remediation** (runs daily at 5:00 AM by default):

- **WMI repository verification**: Repairs WMI if corrupted
- **ConfigMgr client service verification**: Restarts SMS Agent Host service if stopped
- **Client prerequisite verification**: Checks .NET Framework, Windows Installer, BITS service
- **Client installation verification**: Reinstalls client if binaries corrupted
- **Client settings cache verification**: Repairs client policy cache if corrupted
- **Certificate verification**: Validates client certificate (PKI or self-signed)
- **Site assignment verification**: Verifies client assigned to correct site

**Manual Trigger**: Run `ccmeval.exe` from command line or via client notification (right-click device > Client Notification > Trigger Client Health Check)

**Reporting**: Client health status visible in ConfigMgr console (Monitoring > Client Status)

**Intune Capability**: Intune relies on **Device Compliance Policies** and **Device Sync** for client health:

**1. Device Compliance Policies**:

- **Health Attestation**: Verify Secure Boot, BitLocker, Code Integrity, Early Launch Anti-Malware
- **Device properties**: Require minimum OS version, maximum OS version, mobile device management (not jailbroken/rooted)
- **System Security**: Require password, encryption, firewall, antivirus
- **Configuration Manager Compliance** (for co-managed devices): Sync compliance state from ConfigMgr

**Limitation**: Compliance policies check device state but don't remediate issues automatically (mark device non-compliant; admin must manually remediate)

**2. Device Sync**:

- Forces device check-in (retrieves pending policies and actions)
- Does not remediate client issues (only policy retrieval)

**3. Proactive Remediations**:

- **Detection script**: Check for issue (e.g., "Is Windows Update service running?")
- **Remediation script**: Fix issue if detected (e.g., "Start Windows Update service")
- **Scheduled execution**: Runs hourly, daily, or weekly (not instant like ccmeval)
- **Reporting**: Intune shows remediation status per device

**Example Proactive Remediation** (client health check):

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```powershell
# Detection script
$WUService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
if ($WUService.Status -ne 'Running') {
    Write-Output "Windows Update service not running"
    exit 1  # Indicates issue detected (triggers remediation)
} else {
    Write-Output "Windows Update service running"
    exit 0  # No issue (no remediation needed)
}

# Remediation script
Start-Service -Name wuauserv
Write-Output "Windows Update service started"
exit 0
```

**Parity Assessment**: **Partial**. SCCM client health remediation is automatic (runs daily, fixes common issues without admin intervention). Intune requires manual creation of Proactive Remediations for each health check scenario.

**Migration Considerations**:

- **Inventory ccmeval scenarios**: Document common client issues remediated by ccmeval in your environment
- **Create Proactive Remediations**: Build detection/remediation scripts for top 5-10 client health issues
- **Schedule hourly**: For critical health checks (e.g., antivirus service), schedule hourly execution
- **Compliance Policies**: Use for health attestation (Secure Boot, BitLocker, etc.)

**Sources**:

- [Monitor clients in Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/monitor-clients)
- [Proactive remediations in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/remediations)

---

### 3. Significant Gaps / No Equivalent

#### 3.1 Remote Control (Unattended Desktop Control)

**SCCM Capability**: Configuration Manager provides **Remote Control** for unattended desktop access:

**Features**:

- **Full interactive desktop control** without user interaction
- **Can connect when no user is logged on** (e.g., after-hours maintenance, locked-out devices, kiosks)
- **Initiated from ConfigMgr console**: Right-click device > Start > Remote Control
- **Uses ConfigMgr Remote Control Viewer**: Built-in client component (no third-party software required)
- **Configurable client settings**:
  - Permit/deny remote control
  - Show notification icon when remote control session active
  - Grant Remote Control permission to local Administrators group
  - Configure permitted viewers (security groups)
  - Audio indicator settings
  - Play sound on client computer when remote control session active
- **Audio and clipboard sharing** during session
- **Session logging and auditing**: All remote control sessions logged in ConfigMgr

**Use Cases**:

- **Helpdesk support**: Troubleshoot user issues without physical access
- **After-hours maintenance**: Connect to servers/workstations when users offline
- **Kiosk management**: Remote control of kiosks with no logged-on user
- **Locked-out device recovery**: Access devices when user cannot log in

**Limitation**: Remote Control not supported for clients connected via Cloud Management Gateway (CMG).

**Intune Capability**: Intune provides remote assistance through **three mechanisms**, but none support unattended access:

**1. Remote Help** (Microsoft native solution, part of Intune Suite):

- **User-Present Requirement**: User must be logged on and **approve session** (cannot connect unattended)
- **Features**:
  - Full desktop control (view and control) or view-only mode
  - Role-based access controls (helpdesk roles can be restricted to view-only)
  - Session audit logging (all sessions logged in Intune)
  - Conditional Access integration (compliance requirements for helper)
  - Compliance warning (helper sees device compliance state before connecting)
- **Platform Support**: Windows 10/11 only (no macOS/iOS/Android support)
- **Licensing**:
  - **Included in Intune Suite** (standalone $10/user/month prior to July 2026)
  - **Included in M365 E3/E5 starting July 2026** (no additional cost beyond $3/user/month price increase)
  - **Standalone add-on**: ~$3.50/user/month (if not purchasing full Intune Suite)
- **Unattended access**: **NOT supported** (user must click "Allow" to grant access)

**Configuration** (Intune admin center):

- **Tenant administration > Connectors and tokens > Remote Help**: Enable Remote Help
- **Role-Based Access Control**: Create custom roles with Remote Help permissions (Full control, View only, Elevation)
- **Conditional Access**: Apply CA policies to helpers (require compliant device, MFA)

**2. TeamViewer Integration** (third-party):

- **Intune integrates with TeamViewer** for remote support
- **Launch from Intune admin center**: Devices > [Device] > New remote assistance session (opens TeamViewer)
- **Platform Support**: Windows MDM, Android devices (not Android Enterprise corporate-owned)
- **Licensing**: **Requires separate TeamViewer Tensor or Corporate license** (purchased from TeamViewer, not Microsoft; pricing varies by device count and features)
- **Unattended Access**: TeamViewer supports unattended access if licensed (TeamViewer Tensor includes unattended access; Corporate license may require add-on)
- **Features**: Advanced remote control, file transfer, remote reboot, session recording, full encryption, mobile device support

**Configuration**:

1. Purchase TeamViewer Tensor or Corporate license from TeamViewer
2. Intune admin center > Tenant administration > Connectors and tokens > TeamViewer Connector
3. Authorize Intune to connect to TeamViewer account
4. Deploy TeamViewer client to devices via Intune Win32 app

**3. Quick Assist** (Windows built-in, free):

- **Windows built-in feature** (no licensing required)
- **User-present remote assistance** (screen sharing and control)
- **Requires user to generate code** and share with helper (manual process, no Intune integration)
- **No session logging or RBAC** (no audit trail)
- **No Conditional Access integration**
- **Unattended access**: **NOT supported** (user must generate code and share)

**Parity Assessment**: **Significant Gap**. SCCM's ability to remotely control devices **without user presence** has no Intune equivalent:

- **Remote Help** and **Quick Assist**: Both require user approval (user-present only)
- **TeamViewer**: Supports unattended access but requires **separate licensing** (not included with Intune or M365)

**Gap Impact**:

| SCCM Use Case                                            | Intune Alternative                                                                                |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Connect to locked-out device (user cannot log in)        | No Intune equivalent; requires physical access or TeamViewer unattended access (separate license) |
| After-hours server maintenance (no user logged on)       | No Intune equivalent; use RDP (if enabled) or TeamViewer unattended access                        |
| Remote control of kiosks (no user session)               | No Intune equivalent; TeamViewer unattended access required                                       |
| Silent helpdesk support (connect without user awareness) | Not supported in Intune; Remote Help requires user approval for privacy/compliance                |

**Workarounds**:

1. **TeamViewer Tensor/Corporate** (for unattended access):
   - Purchase TeamViewer license (pricing: ~$50/month for 1 user + device fees; contact TeamViewer for enterprise pricing)
   - Deploy TeamViewer client to devices via Intune Win32 app
   - Configure unattended access per device (TeamViewer ID and password)
   - Connect via TeamViewer (outside Intune console integration)

2. **Remote Desktop (RDP)** (for domain-joined or Entra joined devices):
   - Enable RDP via Intune Configuration Policy (Settings Catalog > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections > Allow users to connect remotely)
   - Use Windows Admin Center (cloud-based) or traditional RDP client
   - Limitation: User must be logged on (or use domain admin credentials); not truly unattended

3. **Co-Management** (retain SCCM Remote Control):
   - Keep SCCM infrastructure for Remote Control only
   - Use Intune for all other workloads (apps, updates, compliance, endpoint security)
   - Trade-off: Maintain SCCM infrastructure for single feature

4. **Third-party remote access solutions**:
   - **ConnectWise Control** (ScreenConnect): Unattended access, session recording, scripting
   - **AnyDesk**: Unattended access, file transfer, remote restart
   - **Splashtop**: Unattended access, mobile app, session recording
   - Pricing: Typically $10-30/technician/month + per-device fees

**Migration Decision Tree**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Is unattended remote control required?
├─ NO: Use Remote Help (included in M365 E3 July 2026+) for user-present scenarios
└─ YES:
    ├─ Can budget for third-party tool?
    │   ├─ YES: Procure TeamViewer Tensor or alternative (ConnectWise, AnyDesk, Splashtop)
    │   └─ NO: Retain SCCM co-management for Remote Control workload (delay migration)
    └─ Acceptable to use RDP for servers only?
        └─ YES: Enable RDP for servers, use Remote Help for workstations
```

**Sources**:

- [Configure remote control - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/remote-control/configuring-remote-control)
- [Remote Help in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/remote-help)
- [Remotely administer devices in Microsoft Intune (TeamViewer)](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/teamviewer-support)
- [Intune Remote Access Options: TeamViewer vs RemoteHelp - EdTech IRL](https://www.edtechirl.com/p/intune-remote-access-options-teamviewer)
- [TeamViewer & Microsoft Intune Integration](https://www.teamviewer.com/en-us/integrations/microsoft-intune/)

#### 3.2 Wake-on-LAN (WoL)

**SCCM Capability**: Configuration Manager supports **wake-on-LAN** for sleeping/hibernating devices:

**Features**:

- **Client setting**: "Allow network wake-up" configures network adapter power settings to enable WoL magic packet reception
- **Deployment-Based WoL**:
  - Send wake-up packets for required deployments with deadlines (task sequences, software updates, apps)
  - Site server uses client notification channel to identify awake proxy devices on same subnet, which send magic packets
- **Manual Wake**: Right-click collection > Client Notification > Wake Up (wakes all devices in collection)
- **Wake Proxy**: Clients can act as wake proxies for other clients on same subnet (ConfigMgr 1810+)
- **Custom UDP Port**: Configurable Wake On LAN port (UDP, default 9)

**Configuration Requirements**:

- Network adapters must support WoL and have it enabled in BIOS/UEFI
- Network infrastructure must allow magic packets (some switches block broadcasts)
- Clients must be on same subnet as site server or use wake proxies

**Use Cases**:

- **Wake devices for scheduled software update installation windows** (e.g., "Patch Tuesday at 2 AM; wake all devices at 1:50 AM")
- **Wake devices for required task sequence deployments** (OS deployment during off-hours)
- **Wake devices for patch management outside business hours** (minimize user disruption)
- **Energy savings**: Allow devices to sleep during business hours while ensuring availability for maintenance windows

**Intune Capability**: **No Equivalent**. Intune has no wake-on-LAN capability.

**Parity Assessment**: **No Equivalent**. WoL is an on-premises network feature requiring subnet proximity or wake proxy infrastructure. Intune cloud-native architecture does not support WoL.

**Gap Impact**:

- Organizations dependent on WoL for after-hours patching cannot replicate this in Intune-only environments
- Software update deployment must occur during business hours (when devices awake) or accept delayed deployment (next time device online)
- OS deployment via Autopilot requires device to be online (no "wake for deployment" option)

**Workarounds**:

1. **Co-Management** (retain SCCM for WoL):
   - Keep SCCM infrastructure with co-management enabled
   - Use SCCM for WoL-dependent deployments (software updates, OS deployment)
   - Use Intune for all other workloads (apps, compliance, endpoint security)
   - Trade-off: Maintain SCCM infrastructure

2. **Third-Party Network Management Tools**:
   - **SolarWinds Wake-On-LAN**: Standalone WoL tool (free or paid versions)
   - **ManageEngine OpUtils**: Wake-on-LAN with scheduled wake-up jobs
   - **Script-based solutions**: PowerShell scripts on on-premises servers to send magic packets (requires script maintenance)

3. **On-Premises Scripts** (PowerShell):

   > **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

   ```powershell
   # PowerShell WoL script (run from on-premises server on same subnet)
   function Send-WOL {
       param([string]$MacAddress)

       $MacByteArray = $MacAddress -split '[:-]' | ForEach-Object { [Byte]"0x$_" }
       $MagicPacket = [Byte[]](,0xFF * 6) + ($MacByteArray * 16)

       $UdpClient = New-Object System.Net.Sockets.UdpClient
       $UdpClient.Connect(([System.Net.IPAddress]::Broadcast), 9)
       $UdpClient.Send($MagicPacket, $MagicPacket.Length) | Out-Null
       $UdpClient.Close()
   }

   # Wake devices from CSV (MAC addresses exported from Intune)
   $Devices = Import-Csv "IntuneDevices.csv"  # Columns: DeviceName, MacAddress
   foreach ($Device in $Devices) {
       Send-WOL -MacAddress $Device.MacAddress
       Write-Output "Sent WoL to $($Device.DeviceName) ($($Device.MacAddress))"
   }
   ```

   - **Limitation**: Requires on-premises server on same subnet; cannot wake devices across subnets without WoL-capable routers

4. **Accept No WoL** (adjust deployment windows):
   - Deploy software updates during business hours (8 AM - 6 PM when devices online)
   - Use Intune Update Rings with flexible deadlines (e.g., "Install within 7 days")
   - Accept delayed deployment for offline devices (installs when device next online)
   - Trade-off: User disruption during business hours (restarts, performance impact during updates)

**Migration Decision Tree**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Is WoL required for after-hours patching?
├─ NO: Adjust deployment windows to business hours (accept user disruption)
└─ YES:
    ├─ Can deploy on-premises WoL script?
    │   ├─ YES: Use PowerShell WoL script on on-premises server (scheduled task)
    │   └─ NO: Procure third-party network management tool with WoL support
    └─ Critical for OS deployment?
        └─ YES: Retain SCCM co-management for OS deployment workload
```

**Sources**:

- [Configure Wake on LAN - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/deploy/configure-wake-on-lan)
- [Configure Power Management In Configuration Manager - Anoop Nair](https://www.anoopcnair.com/configure-power-management-in-configuration-manager-sccm/)
- [How to enable SCCM Wake on LAN Client Notification (1810+) - System Center Dudes](https://www.systemcenterdudes.com/sccm-wake-on-lan-client-notification/)

#### 3.3 Power Management

**SCCM Capability**: Configuration Manager **Power Management** allows centralized power plan deployment:

**Features**:

- **Power Plans**: Apply Windows power plans to device collections (Balanced, High Performance, Power Saver, or custom)
- **Business vs. Non-Business Hours**: Different power settings during business hours (e.g., never sleep) vs. non-business hours (e.g., sleep after 30 minutes)
- **Granular Settings**:
  - Turn off display after (minutes): Business hours vs. non-business hours
  - Sleep after (minutes): Business hours vs. non-business hours
  - Require password on wakeup
  - When computer is unplugged (laptops): Different settings for AC vs. battery
- **Power Capabilities Report**: Identifies devices supporting sleep, hibernate, wake-from-sleep, wake-from-hibernate
- **Power Consumption Reports**: Estimates energy cost savings from power plan deployments (kilowatt-hours, CO2 emissions, cost)
- **Exclusions**: Exclude specific devices or collections from power management
- **Monitor Compliance**: Power management dashboard shows power plan compliance

**Use Cases**:

- **Energy cost savings**: Sleep desktops during non-business hours (e.g., 6 PM - 6 AM)
- **Prevent sleep during business hours**: Keep workstations always-available for remote access
- **VDI optimization**: Prevent virtual desktops from sleeping (performance impact)
- **Compliance with environmental policies**: Reduce energy consumption for green IT initiatives

**Intune Capability**: **No Equivalent**. Intune does not provide power management policies.

**Parity Assessment**: **No Equivalent**. Power management is a legacy on-premises feature. Modern cloud-managed devices typically use default Windows power plans or user-configured settings.

**Gap Impact**:

- Organizations with energy savings initiatives lose centralized power management
- Compliance requirements for power management (e.g., government mandates for energy-efficient IT) cannot be enforced centrally
- Cost savings tracking (kilowatt-hours, CO2, cost) not available

**Workarounds**:

1. **Group Policy** (for domain-joined devices):
   - Use GPO for power management: Computer Configuration > Policies > Administrative Templates > System > Power Management
   - Configure settings: Turn off display, Sleep, Hibernate, Require password on wakeup
   - Limitation: Requires domain-joined devices; not applicable to Entra joined or Entra registered devices

2. **Settings Catalog** (limited CSP support):
   - Intune Settings Catalog may support some power-related CSPs (limited, not full power plan deployment)
   - Search Settings Catalog for "Power" to find available settings
   - Limitation: No comprehensive power management equivalent to SCCM

3. **PowerShell Scripts via Proactive Remediations**:
   - Deploy detection/remediation scripts to configure power settings via `powercfg.exe`
   - Example:

     > **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

     ```powershell
     # Remediation script: Apply Balanced power plan and configure sleep settings
     powercfg /setactive SCHEME_BALANCED  # Balanced power plan GUID
     powercfg /change monitor-timeout-ac 15  # Turn off display after 15 min (AC)
     powercfg /change standby-timeout-ac 30  # Sleep after 30 min (AC)
     powercfg /change monitor-timeout-dc 10  # Turn off display after 10 min (battery)
     powercfg /change standby-timeout-dc 20  # Sleep after 20 min (battery)
     Write-Output "Power settings configured"
     exit 0
     ```

   - **Limitation**: No reporting dashboard (must query Proactive Remediation results); no energy cost tracking

4. **Third-Party Power Management Tools**:
   - **1E NightWatchman**: Enterprise power management with wake-on-LAN, reporting, energy cost tracking
   - **Dell KACE**: Includes power management module
   - **ManageEngine Desktop Central**: Power management policies
   - Pricing: Typically $2-5/device/year

5. **Accept No Power Management**:
   - Rely on Windows default power plans (user-configurable)
   - Modern devices (laptops, tablets) have aggressive power management by default
   - Desktops may waste energy if users don't configure sleep settings

**Migration Decision Tree**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Is centralized power management required?
├─ NO: Accept Windows default power plans (adequate for most environments)
└─ YES:
    ├─ Domain-joined devices only?
    │   └─ YES: Use Group Policy for power management
    └─ Cloud-only devices (Entra joined)?
        ├─ Can use Proactive Remediations (PowerShell scripts)?
        │   └─ YES: Deploy powercfg scripts via Proactive Remediations
        └─ Need reporting and cost tracking?
            └─ YES: Procure third-party power management tool (1E NightWatchman, etc.)
```

**Sources**:

- [SCCM Power Management Guide: Step-by-Step - Prajwal Desai](https://www.prajwaldesai.com/sccm-power-management-guide/)
- [Configure Power Management In Configuration Manager - Anoop Nair](https://www.anoopcnair.com/configure-power-management-in-configuration-manager-sccm/)

---

## Licensing Impact

| Feature                                                              | Minimum License            | Included In                                           | Notes                                                                                        |
| -------------------------------------------------------------------- | -------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| **Intune Remote Actions (Wipe, Retire, Sync, Restart, Diagnostics)** | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | All core remote actions included                                                             |
| **Bulk Device Actions (up to 100 devices)**                          | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | Bulk restart, sync, scan, BitLocker rotation                                                 |
| **Fresh Start (Windows Reset)**                                      | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | Remove OEM bloatware while preserving user data                                              |
| **Autopilot Reset**                                                  | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | Reset device to Autopilot OOBE state                                                         |
| **Collect Diagnostics**                                              | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | Gather device logs for troubleshooting                                                       |
| **Remote Help (User-Present)**                                       | Intune Suite or standalone | M365 E3/E5 (from July 2026); standalone ~$3.50/user/month | User must approve session; no unattended access                                              |
| **TeamViewer Integration**                                           | Third-party license        | Purchased separately from TeamViewer                  | Unattended access requires TeamViewer Tensor or Corporate license (~$50/month + device fees) |
| **Quick Assist**                                                     | Free                       | Windows built-in                                      | User-present only; no logging or RBAC                                                        |
| **Delivery Optimization**                                            | Free                       | Windows built-in                                      | P2P content delivery; no additional licensing                                                |
| **Configuration Policies (Settings Catalog)**                        | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | 5000+ device settings                                                                        |
| **Proactive Remediations**                                           | Endpoint Analytics         | M365 E3, E5, A3, A5, Windows 10/11 Enterprise E3/E5   | Scheduled PowerShell scripts for health checks                                               |
| **Platform Scripts**                                                 | Intune Plan 1              | M365 E3, E5, F3, Business Premium                     | PowerShell/shell scripts (not instant execution like SCCM Run Scripts)                       |

**Key Takeaway**: All core Intune remote actions included in **Intune Plan 1** (M365 E3). **Remote Help** included in M365 E3/E5 starting July 2026 (no additional cost beyond $3/user/month price increase). **Unattended remote control** requires **third-party licensing** (TeamViewer, ConnectWise, etc.).

**See**: **Licensing Impact Register** for consolidated licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Remote Tools Assessment

**Action Items** (complete before migration):

1. **Remote Control Usage Audit**:
   - Query ConfigMgr remote control session logs (ConfigMgr database: `StatusMessages` table, MessageID 2700-2799)
   - Identify frequency of remote control usage (sessions per day/week/month)
   - Document critical use cases (after-hours support, kiosk management, locked-out device recovery)
   - Determine if unattended access is required or "nice-to-have"

2. **Wake-on-LAN Dependency Check**:
   - Review software update deployments with WoL enabled
   - Identify task sequences using WoL for OS deployment
   - Document business justification for after-hours patching (user disruption avoidance, compliance windows)
   - Evaluate feasibility of business-hours deployment windows

3. **Power Management Inventory**:
   - Review power management policies deployed to collections
   - Document energy savings targets (kilowatt-hours, cost, CO2)
   - Check if power management required for compliance (government mandates, corporate environmental policies)

4. **Client Notification Analysis**:
   - Document client notification actions used regularly (policy refresh, inventory cycles, script execution)
   - Identify workflows dependent on instant execution (e.g., "Force policy refresh after critical deployment")

### Migration Strategies

#### Strategy 1: Intune-Only with Remote Help (User-Present Scenarios)

**Profile**: Organizations with user-present support model, no unattended remote control requirement, business-hours patching acceptable.

**Approach**:

1. **Remote Help**: Deploy Remote Help to all Windows 10/11 devices (included in M365 E3 from July 2026)
2. **Device Sync**: Use Device Sync (or Bulk Sync) for immediate policy refresh
3. **Proactive Remediations**: Create health check scripts for common client issues
4. **Business-Hours Patching**: Adjust Windows Update deployment windows to business hours (8 AM - 6 PM)
5. **Accept No WoL**: Deploy updates when devices online (delayed deployment for offline devices)
6. **No Power Management**: Rely on Windows default power plans

**Effort**: Low (minimal workflow changes; Remote Help similar to SCCM Remote Assistance)

**Timeline**: 30-60 days (includes Remote Help deployment and user training)

**Cost**: Included in M365 E3/E5 (from July 2026; ~$3.50/user/month standalone prior)

#### Strategy 2: Intune + TeamViewer (Unattended Remote Control)

**Profile**: Organizations with helpdesk requiring unattended remote control, willing to invest in third-party remote access tool.

**Approach**:

1. **Procure TeamViewer Tensor or Corporate license** (contact TeamViewer for enterprise pricing)
2. **Deploy TeamViewer client** to all devices via Intune Win32 app
3. **Configure unattended access** per device (TeamViewer ID and password)
4. **Integrate with Intune**: Configure TeamViewer connector in Intune admin center
5. **Train helpdesk**: TeamViewer interface differs from SCCM Remote Control Viewer
6. **Remote Help for user-present**: Use Remote Help for user-present scenarios (cheaper than TeamViewer session fees)

**Effort**: Medium (TeamViewer procurement, deployment, helpdesk training)

**Timeline**: 60-90 days (includes TeamViewer deployment and pilot testing)

**Cost**: TeamViewer licensing (~$50/month per technician + device fees; varies by contract)

#### Strategy 3: Co-Management Hybrid (Retain SCCM Remote Tools)

**Profile**: Organizations with heavy reliance on SCCM Remote Control, WoL, and power management; not ready to invest in third-party tools.

**Approach**:

1. **Enable co-management** with Remote Tools workload in SCCM
2. **Retain SCCM infrastructure** for Remote Control, WoL, power management
3. **Use Intune for all other workloads** (apps, updates, compliance, endpoint security)
4. **Plan 3-5 year SCCM retention** for Remote Tools only
5. **Gradual transition**: Evaluate third-party remote access tools or business process changes over time

**Effort**: Low (no immediate remote tools migration required)

**Timeline**: Indefinite (phased over 3-5 years)

**Cost**: Maintain SCCM infrastructure (SQL Server licensing, site server hardware, admin overhead)

**Trade-off**: Delays full cloud transition, but preserves critical remote tools capabilities.

### Phased Rollout Plan

**Phase 1: Pilot (100 devices, IT/Security team)**

- Deploy Remote Help to pilot group (IT staff test both helper and user roles)
- Test Device Sync for policy refresh (verify policy retrieval timing)
- Create 3-5 Proactive Remediations for common client health issues
- Validate Intune remote actions (wipe, retire, restart, diagnostics)
- If using TeamViewer: Deploy to pilot group, test unattended access
- Duration: 30 days

**Phase 2: Helpdesk Training (20-30 days)**

- Train helpdesk on Remote Help interface (differs from SCCM Remote Control Viewer)
- Document workflows: "How to connect to device via Remote Help" (step-by-step)
- If using TeamViewer: Train on TeamViewer interface and unattended access
- Create knowledge base articles for common scenarios
- Duration: 30 days

**Phase 3: Production Rollout (Ring Deployment)**

- **Ring 1** (10% users): Deploy Remote Help, monitor helpdesk feedback
- **Ring 2** (50% users): Scale after 2-week Ring 1 validation
- **Ring 3** (100% users): Full rollout after 30-day Ring 2 soak
- Duration: 90 days

**Phase 4: Decommission SCCM Remote Tools** (if not co-management)

- Verify all remote support scenarios covered (Remote Help or TeamViewer)
- Disable SCCM Remote Control client setting
- Decommission SCCM infrastructure after 90-day validation period
- Duration: 30 days

### Common Pitfalls to Avoid

1. **Assuming Remote Help = Remote Control**: Remote Help requires user approval (no unattended access). Test workflows before migration.

2. **Overlooking TeamViewer Licensing Costs**: TeamViewer enterprise licenses can be expensive (~$50/month/technician + device fees). Budget accordingly.

3. **Ignoring Wake-on-LAN Impact**: After-hours patching workflows dependent on WoL cannot replicate in Intune. Adjust deployment windows or retain SCCM.

4. **Underestimating Helpdesk Training**: Remote Help interface differs from SCCM Remote Control Viewer. Budget 2-4 hours training per helpdesk technician.

5. **Forgetting Proactive Remediations Licensing**: Proactive Remediations require Endpoint Analytics (included in M365 E3, but verify licensing).

6. **Expecting Instant Script Execution**: SCCM Run Scripts executes instantly; Intune Platform Scripts run on schedule or next check-in. Adjust workflows.

7. **Power Management Oversight**: Organizations with energy savings mandates cannot replicate SCCM power management in Intune without Group Policy or third-party tools.

---

## Sources

### Microsoft Official Documentation

- [Remote actions available for devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/)
- [Bulk device actions in Intune](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/#bulk-device-actions)
- [Remote Help in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/remote-help)
- [Remotely administer devices in Microsoft Intune (TeamViewer)](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/teamviewer-support)
- [Configure remote control - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/remote-control/configuring-remote-control)
- [Client notification - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/client-notification)
- [Configure Wake on LAN - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/deploy/configure-wake-on-lan)
- [Use the settings catalog to configure settings](https://learn.microsoft.com/en-us/intune/intune-service/configuration/settings-catalog)
- [Configuration Manager Client Settings](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/deploy/about-client-settings)
- [Delivery Optimization settings for Windows devices in Intune](https://learn.microsoft.com/en-us/intune/intune-service/configuration/delivery-optimization-windows)
- [Peer Cache for Configuration Manager clients](https://learn.microsoft.com/en-us/intune/configmgr/core/plan-design/hierarchy/client-peer-cache)
- [Monitor clients in Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/monitor-clients)
- [Proactive remediations in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/remediations)

### Community and Expert Sources

- [Intune Remote Access Options: TeamViewer vs RemoteHelp - EdTech IRL](https://www.edtechirl.com/p/intune-remote-access-options-teamviewer)
- [TeamViewer & Microsoft Intune Integration](https://www.teamviewer.com/en-us/integrations/microsoft-intune/)
- [Intune Remote Wipe, Retire, Fresh Start, Autopilot Reset - Call4Cloud](https://call4cloud.nl/2021/05/intune-remote-wipe-retire-fresh-start-autopilot-reset/)
- [Configure Power Management In Configuration Manager - Anoop Nair](https://www.anoopcnair.com/configure-power-management-in-configuration-manager-sccm/)
- [SCCM Power Management Guide: Step-by-Step - Prajwal Desai](https://www.prajwaldesai.com/sccm-power-management-guide/)
- [How to enable SCCM Wake on LAN Client Notification (1810+) - System Center Dudes](https://www.systemcenterdudes.com/sccm-wake-on-lan-client-notification/)
- [New Intune Remote Help Solution Is Available Now - Anoop Nair](https://www.anoopcnair.com/intune-remote-help-solution-available-with-mem/)
- [How To Configure Intune Remote Help: A Step-by-Step Guide - Prajwal Desai](https://www.prajwaldesai.com/intune-remote-help/)

---

**End of Assessment**
