# OS Deployment & Imaging — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: **Significant Gap**

---

## Executive Summary

OS deployment represents the **most significant capability regression** when transitioning from SCCM to Intune. SCCM's task sequence engine provides comprehensive imaging and deployment automation that has **no direct Intune equivalent**. Critical gaps include bare-metal deployment (no PXE boot or bootable media), task sequence workflows (no equivalent automation engine), User State Migration Tool (no comprehensive profile migration), and custom OS imaging (cannot deploy WIM files). Intune excels at **transforming OEM-delivered devices** through Windows Autopilot, which provides superior out-of-box experience for new device provisioning with zero-touch deployment, branded OOBE, and automated policy/app delivery. Organizations must adopt a **scenario-based approach**: use Autopilot for new device procurement, evaluate OneDrive Known Folder Move sufficiency for refresh scenarios, and retain SCCM or adopt OEM custom imaging partnerships for bare-metal and custom build requirements.

---

## Feature Parity Matrix

| SCCM Feature                                | Intune Equivalent                                         | Parity Rating        | Licensing        | Notes                                                                                                                |
| ------------------------------------------- | --------------------------------------------------------- | -------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Task Sequences - Bare Metal Deployment**  | No equivalent                                             | **No Equivalent**    | N/A              | Autopilot requires pre-installed OS from OEM; cannot image blank hardware or deploy WIM files                        |
| **Task Sequences - Refresh/Wipe-and-Load**  | Windows Autopilot Reset                                   | **Partial**          | Plan 1           | Autopilot Reset reprovisions device but cannot change OS version; no USMT-style migration                            |
| **Task Sequences - Replace (PC Migration)** | Autopilot user-driven + manual data migration             | **Partial**          | Plan 1           | No automated migration workflow; relies on OneDrive Known Folder Move                                                |
| **Task Sequences - In-Place Upgrade**       | Feature update policies                                   | **Full Parity**      | Plan 1           | Both use Windows Setup for in-place version upgrades; Intune via Windows Update                                      |
| **Task Sequences - Custom Workflows**       | No equivalent                                             | **No Equivalent**    | N/A              | No task sequence engine in Intune; cannot create custom deployment workflows                                         |
| **Task Sequence Steps (50+ built-in)**      | No equivalent                                             | **No Equivalent**    | N/A              | Steps like Partition Disk, Apply OS Image, Install Drivers, Run Command Line have no Intune equivalents              |
| **Task Sequence Variables**                 | No equivalent                                             | **No Equivalent**    | N/A              | Cannot use dynamic variables to control deployment logic                                                             |
| **Boot Images (WinPE)**                     | No equivalent                                             | **No Equivalent**    | N/A              | Autopilot uses full Windows OOBE during provisioning; no WinPE boot environment                                      |
| **OS Images (WIM/ESD)**                     | OEM pre-installed Windows                                 | **No Equivalent**    | N/A              | Intune does not deploy OS images; devices must have Windows pre-installed                                            |
| **Custom OS Images**                        | No equivalent                                             | **No Equivalent**    | N/A              | Cannot create or deploy custom reference images                                                                      |
| **Image Capture (Reference Machine)**       | No equivalent                                             | **No Equivalent**    | N/A              | Cannot capture running OS as deployable WIM file                                                                     |
| **Driver Packages**                         | Driver update policies (Windows Update only)              | **Partial**          | Plan 1           | Intune deploys drivers via Windows Update; cannot inject custom driver packages                                      |
| **Driver Categories (Make/Model)**          | Automatic (Windows Update hardware matching)              | **Partial**          | Plan 1           | Windows Update automatically matches drivers to hardware; no manual categorization                                   |
| **Apply Driver Package Task**               | Automatic during Windows setup                            | **Partial**          | Plan 1           | Drivers install automatically from Windows Update or OEM image; no explicit injection step                           |
| **User State Migration Tool (USMT)**        | OneDrive Known Folder Move                                | **Partial**          | E3/E5 (OneDrive) | OneDrive replicates Desktop/Documents/Pictures only; no registry, app settings, or custom profile data               |
| **Hard-Link Migration (Refresh)**           | No equivalent                                             | **No Equivalent**    | N/A              | Cannot preserve user state locally during OS wipe-and-reload                                                         |
| **State Migration Point (SMP)**             | OneDrive for Business (cloud storage)                     | **Partial**          | E3/E5 (OneDrive) | Cloud storage vs. on-premises SMP; no intermediate migration store for air-gapped scenarios                          |
| **PXE Boot**                                | No equivalent                                             | **No Equivalent**    | N/A              | Autopilot uses OOBE; no network boot capability                                                                      |
| **Multicast Deployment**                    | No equivalent                                             | **No Equivalent**    | N/A              | Not applicable to cloud-based provisioning model                                                                     |
| **Prestaged Media (USB/DVD)**               | Provisioning packages (PPKG)                              | **Partial**          | Plan 1 (Free)    | PPKG can apply settings but cannot deploy OS images or run workflows                                                 |
| **Bootable Media (Standalone)**             | No equivalent                                             | **No Equivalent**    | N/A              | Cannot create bootable USB drives for OS deployment                                                                  |
| **Capture Media**                           | No equivalent                                             | **No Equivalent**    | N/A              | Cannot create media to capture OS images from reference machines                                                     |
| **Pre-Provision BitLocker**                 | BitLocker policy (post-provisioning)                      | **Partial**          | Plan 1           | BitLocker enables after device provisioning completes; cannot pre-provision during imaging                           |
| **Offline Domain Join (ODJ)**               | Azure AD join or Hybrid Azure AD join                     | **Full Parity**      | Plan 1           | Both support domain join during provisioning; Intune uses Azure AD instead of on-prem AD                             |
| **Unknown Computer Support**                | Autopilot self-deploying mode                             | **Partial**          | Plan 1           | Self-deploying mode for kiosk/shared devices; requires TPM 2.0; different use case than SCCM unknown computer object |
| **Computer Association (Replace)**          | No equivalent                                             | **No Equivalent**    | N/A              | Cannot link old PC to new PC for automated state migration                                                           |
| **Windows Autopilot - User-Driven**         | Windows Autopilot user-driven mode                        | **Intune Advantage** | Plan 1           | OOBE-based zero-touch provisioning with branded experience                                                           |
| **Windows Autopilot - Self-Deploying**      | Windows Autopilot self-deploying mode                     | **Intune Advantage** | Plan 1           | Fully automated provisioning for kiosk and shared devices                                                            |
| **Windows Autopilot - Pre-Provisioned**     | Windows Autopilot pre-provisioning (White Glove)          | **Intune Advantage** | Plan 1           | Technician pre-provisions device (apps, policies) before user delivery                                               |
| **Autopilot Device Preparation**            | Autopilot device preparation (Win11 24H2+)                | **Intune Advantage** | Plan 1           | Simplified provisioning flow with enhanced performance; max 25 apps during OOBE (as of Jan 2026)                     |
| **Enrollment Status Page (ESP)**            | Enrollment Status Page                                    | **Intune Advantage** | Plan 1           | Tracks app/policy deployment during provisioning; blocks user access until complete                                  |
| **OOBE Customization**                      | Autopilot profiles (skip privacy, EULA, OEM registration) | **Intune Advantage** | Plan 1           | Streamlined OOBE with organizational branding                                                                        |
| **Self-Service Device Reset**               | Autopilot Reset (user-initiated or remote)                | **Intune Advantage** | Plan 1           | Users can reset devices to factory state without IT intervention                                                     |
| **Cloud Recovery**                          | Windows 11 cloud recovery                                 | **Intune Advantage** | Plan 1 (Free)    | Download Windows image from cloud during reset/recovery (Win11 only)                                                 |

---

## Key Findings

### This is the Largest Gap Area

OS deployment represents the most significant capability regression when moving from SCCM to Intune. The gap is architectural — SCCM is an **imaging platform** designed to deploy operating system images to blank hardware, while Intune is a **device transformation platform** designed to configure OEM-delivered devices. These are fundamentally different approaches.

**SCCM's imaging model**:

1. Boot blank hardware via PXE, USB, or DVD
2. Partition disk and format volumes
3. Apply OS image (WIM file) to disk
4. Inject drivers for hardware
5. Apply Windows settings and join domain
6. Install applications
7. Capture user state from old PC and restore to new PC

**Intune's transformation model**:

1. Purchase device with OEM-installed Windows
2. Pre-register device hardware hash in Autopilot service
3. User unboxes device and powers on
4. Device contacts Autopilot service during OOBE
5. Autopilot applies Azure AD join, Intune enrollment, policies, and apps
6. User receives fully configured device

The imaging model provides complete control over OS deployment. The transformation model eliminates imaging infrastructure but depends on OEM-delivered Windows installations.

---

### No Equivalent Features

#### Task Sequence Engine

SCCM's [task sequences](https://learn.microsoft.com/en-us/mem/configmgr/osd/understand/task-sequence-steps) are a workflow automation engine supporting 50+ built-in steps for OS deployment and general automation. Task sequences orchestrate complex deployment workflows with conditional logic, error handling, and dynamic variables.

**Common task sequence types**:

**1. Bare Metal Deployment**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Task Sequence: Deploy Windows 11 23H2 - Bare Metal
  ├─ Restart in Windows PE
  ├─ Partition Disk 0 - UEFI (500MB EFI + 128MB MSR + remaining OS)
  ├─ Apply Operating System (Windows 11 23H2 WIM)
  ├─ Apply Windows Settings (Computer name: %ComputerName%, Organization: Contoso)
  ├─ Apply Network Settings (Join domain: contoso.com, OU: OU=Workstations)
  ├─ Setup Windows and ConfigMgr (Install ConfigMgr client)
  ├─ Apply Driver Package (Model: %Model%, Manufacturer: %Make%)
  ├─ Install Software (7-Zip, Chrome, Office, LOB apps)
  ├─ Enable BitLocker
  └─ Run PowerShell - Post-Deployment (Custom configuration)
```

**2. Refresh (Wipe-and-Load)**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Task Sequence: Windows 11 23H2 - Refresh
  ├─ Capture User State (USMT - hardlink migration)
  ├─ Restart in Windows PE
  ├─ Format and Partition Disk
  ├─ Apply Operating System
  ├─ Apply Drivers
  ├─ Setup Windows and ConfigMgr
  ├─ Restore User State (USMT restore from hardlinks)
  ├─ Install Software
  └─ Enable BitLocker
```

**3. Replace (PC Migration)**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Old PC Task Sequence: Capture User State
  └─ Capture User State (USMT to State Migration Point over network)

New PC Task Sequence: Deploy Windows 11 - Replace
  ├─ Request State Store (Query SMP for user state)
  ├─ Partition Disk
  ├─ Apply Operating System
  ├─ Apply Drivers
  ├─ Setup Windows and ConfigMgr
  ├─ Restore User State (USMT from SMP)
  ├─ Install Software
  └─ Release State Store (Delete user state from SMP)
```

**4. In-Place Upgrade**:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Task Sequence: Upgrade to Windows 11 23H2
  ├─ Pre-Upgrade Checks (Disk space, application compatibility)
  ├─ Download Package Content (Windows 11 upgrade files)
  ├─ Run Command Line: Uninstall-IncompatibleApp.ps1
  ├─ Upgrade Operating System (Setup.exe with answer file)
  ├─ Post-Upgrade Applications (Reinstall apps if needed)
  └─ Run PowerShell - Cleanup (Remove old Windows.old folder)
```

**Intune has no task sequence engine**. There is no mechanism to create multi-step deployment workflows with conditional logic. Organizations using task sequences for:

- Bare-metal builds from blank hardware
- Complex refresh scenarios with USMT
- Custom automation workflows (BitLocker pre-provisioning, certificate enrollment, registry modifications)
- Server deployments

**...cannot replicate these workflows in Intune**.

**Alternatives**:

1. **Windows Autopilot**: Replace new device provisioning task sequences with Autopilot user-driven mode
2. **PowerShell scripts**: Deploy configuration scripts via Intune Remediations or Platform Scripts (runs after OS installation, not during)
3. **SCCM retention**: Keep SCCM infrastructure for imaging scenarios via co-management
4. **OEM custom imaging**: Partner with Dell, HP, Lenovo for custom Windows images delivered on new hardware
5. **MDT (Microsoft Deployment Toolkit)**: Standalone imaging tool (no cloud management; manual process)

#### Bare-Metal Deployment (No PXE, No Bootable Media)

SCCM deploys operating system images to hardware with no operating system via:

**[PXE boot](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/use-pxe-to-deploy-windows-over-the-network)**:

1. Configure Distribution Point with PXE responder role
2. Device boots to network (UEFI network boot or legacy PXE)
3. PXE responder sends WinPE boot image to device
4. Device boots into WinPE, contacts SCCM, executes task sequence
5. Task sequence partitions disk, applies OS image, installs drivers, configures settings

**[Bootable media](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/create-bootable-media)** (USB/DVD):

1. Create bootable media in SCCM console
2. Copy to USB drive or burn to DVD
3. Boot device from USB/DVD
4. Device boots into WinPE with embedded task sequence
5. Task sequence applies OS image (standalone deployment, no network required)

**Intune cannot perform bare-metal OS deployment**. [Autopilot requirements](https://learn.microsoft.com/en-us/autopilot/requirements) explicitly state:

> "Devices must have a preinstalled version of Windows from the OEM or Windows installation media"

Intune assumes devices arrive with Windows already installed (OEM factory image). Organizations that:

- Build custom reference images for baseline security configuration
- Image devices from blank hard drives
- Deploy to custom-built hardware (white box PCs)
- Repurpose devices with wiped/corrupt OS

**...cannot perform these scenarios with Intune alone**.

**Workarounds**:

**1. OEM Custom Imaging Service**:
Major OEMs (Dell, HP, Lenovo) offer custom imaging services:

- Upload custom Windows image to OEM portal
- OEM factory-installs custom image on new devices
- Devices ship with custom image pre-loaded
- **Cost**: $10-30/device setup fee + per-device imaging fee
- **Timeline**: 2-4 week lead time for image validation and deployment

**2. SCCM Hybrid Model (Co-Management)**:

- Use SCCM to image devices (bare metal, custom builds)
- Task sequence completes with Autopilot registration step
- Device reboots, completes Autopilot provisioning, enrolls in Intune
- Device managed by Intune post-imaging

Example hybrid task sequence:

> **Note**: The following is pseudo-code illustrating the logical flow, not executable syntax.

```
Task Sequence: Hybrid - SCCM Image + Autopilot
  ├─ [SCCM steps: Partition, Apply OS, Drivers, Domain Join]
  ├─ Install Applications (Base apps via SCCM)
  ├─ Run PowerShell: Register-AutopilotDevice.ps1
  │   └─ Get-WindowsAutopilotInfo -Online -GroupTag "SCCM-Imaged"
  └─ Restart Computer (Triggers Autopilot on next boot)
```

After restart, device completes Autopilot user-driven provisioning and enrolls in Intune. Combines SCCM imaging capabilities with Intune cloud management.

**3. MDT Standalone Imaging**:
[Microsoft Deployment Toolkit](https://learn.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/get-started-with-the-microsoft-deployment-toolkit) provides free imaging tool without cloud management:

- Create reference images
- Deploy via PXE or bootable media
- Manual process (no central management console)
- Suitable for small-scale imaging (< 50 devices)

**4. Configuration During Autopilot (Eliminate Imaging)**:
Instead of deploying custom image with pre-installed apps and configuration:

- Start with OEM factory image
- Autopilot applies all configuration via policies
- Autopilot deploys all apps via Win32 apps
- **Downside**: Longer provisioning time (30-90 minutes vs 15-30 for imaging)
- **Benefit**: No image maintenance (no patching reference images monthly)

#### User State Migration Tool (USMT)

SCCM task sequences use [USMT](https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-overview) to capture and restore user profiles, documents, settings, and application data during refresh/replace scenarios.

**What USMT captures**:

- User profile folders (Desktop, Documents, Pictures, Music, Videos, Downloads)
- Application settings (registry keys, AppData files)
- Browser data (favorites, cookies, history)
- Email data (Outlook PST files, signatures)
- Operating system settings (wallpaper, taskbar, desktop icons)
- Custom file locations (via MigXML rules)
- Mapped network drives
- Printers
- Certificates

**USMT scenarios**:

**Refresh (Hard-Link Migration)**:

1. Run USMT ScanState with `/hardlink` option
2. USMT creates hard-links to user files on existing OS partition
3. Task sequence wipes OS partition (hard-links remain on data partition)
4. Task sequence installs new OS
5. Run USMT LoadState to restore files from hard-links
6. User data restored to new OS installation

**Replace (Network Migration)**:

1. Run USMT ScanState on old PC
2. User state uploads to State Migration Point (network share)
3. Deploy new PC with task sequence
4. Task sequence runs USMT LoadState
5. User state downloads from SMP and restores to new PC
6. SMP deletes user state after successful restore

**Intune has no USMT equivalent**. Microsoft's recommended alternative is [OneDrive Known Folder Move](https://learn.microsoft.com/en-us/onedrive/redirect-known-folders):

**OneDrive Known Folder Move**:

- Automatically redirects Desktop, Documents, and Pictures folders to OneDrive
- Files sync to OneDrive cloud storage
- On new device, user signs into OneDrive
- Files sync down automatically from cloud

**OneDrive Known Folder Move limitations**:

| Data Type                                | USMT                    | OneDrive KFM                                | Gap             |
| ---------------------------------------- | ----------------------- | ------------------------------------------- | --------------- |
| Desktop, Documents, Pictures             | ✓ Captured              | ✓ Synced                                    | None            |
| Application settings (registry, AppData) | ✓ Captured              | ✗ Not synced                                | **Significant** |
| Browser favorites                        | ✓ Captured              | ✗ Not synced (use Edge sync)                | Moderate        |
| Outlook PST files                        | ✓ Captured              | ✗ Not synced (too large)                    | Moderate        |
| Custom file locations (C:\Data)          | ✓ Captured (via MigXML) | ✗ Not synced                                | **Significant** |
| Mapped network drives                    | ✓ Captured              | ✗ Not synced                                | Low             |
| Installed certificates                   | ✓ Captured              | ✗ Not synced                                | Moderate        |
| Operating system settings                | ✓ Captured              | ✗ Not synced (use Enterprise State Roaming) | Low             |

**Example impact**:

- **Line-of-business application** stores data in `C:\AppData\Local\VendorApp\` → USMT captures, OneDrive does not
- **User customization** includes custom registry keys for application preferences → USMT captures, OneDrive does not
- **Email** includes 10GB Outlook PST file → USMT captures, OneDrive exceeds size limits

**Workarounds**:

**1. OneDrive + Enterprise State Roaming + Manual Migration**:

- OneDrive Known Folder Move: Captures Desktop/Documents/Pictures (80% of user data)
- [Enterprise State Roaming](https://learn.microsoft.com/en-us/azure/active-directory/devices/enterprise-state-roaming-overview): Syncs Windows settings, Edge favorites, passwords (requires Entra ID P1)
- Manual documentation: Document LOB app data locations, provide users with migration instructions

**2. Third-Party Migration Tools**:

- **Tranxition Migration Manager**: Enterprise user state migration with Intune integration
- **Laplink PCmover**: Consumer-grade migration tool
- **ForensiT User Profile Wizard**: Profile migration for domain changes

**3. Application-Native Sync**:
Many modern applications sync settings to cloud:

- Microsoft Edge: Syncs favorites, passwords, settings to Microsoft account
- Google Chrome: Syncs to Google account
- Microsoft 365 Apps: Settings stored in OneDrive
- Visual Studio Code: Settings Sync extension

**4. Accept Data Loss / Fresh Start**:
Organizations moving to cloud-first model often adopt "fresh start" philosophy:

- Users start with clean profile on new device
- All data stored in OneDrive/SharePoint (not local drives)
- Applications reconfigured from scratch
- **Benefit**: Eliminates legacy profile corruption issues
- **Downside**: User disruption, lost custom configurations

**Impact assessment**:

- **Simple user profiles** (office workers, knowledge workers): OneDrive Known Folder Move provides 80-90% coverage
- **Complex user profiles** (developers, engineers, power users): Significant gaps; manual migration or third-party tools required
- **Line-of-business apps with local data**: High risk; USMT retention or application refactoring needed

#### Driver Management

SCCM supports [driver packages](https://learn.microsoft.com/en-us/mem/configmgr/osd/get-started/manage-drivers) for explicit driver injection during OS deployment:

**SCCM driver workflow**:

1. Download drivers from vendor (Dell, HP, Lenovo CAB files)
2. Import drivers to SCCM console
3. Categorize drivers by make/model
4. Create driver packages per model
5. Task sequence detects hardware model via WMI query
6. Task sequence applies matching driver package during "Apply Drivers" step

**Benefits**:

- **Offline driver injection**: Drivers install before Windows boots (no internet required)
- **Version control**: Explicit driver versions deployed (no automatic updates)
- **Custom drivers**: Can deploy modified or custom drivers not in vendor catalogs
- **Air-gapped support**: Drivers deploy from on-premises DPs (no internet dependency)

**Intune relies on Windows Update for driver delivery**:

[Driver update policies](https://learn.microsoft.com/en-us/mem/intune/protect/windows-driver-updates-overview):

- Configure automatic approval of drivers from Windows Update
- Filter by driver category (e.g., network adapters only)
- Manually approve specific drivers
- Drivers install after Windows installation completes

**Intune driver limitations**:

| Requirement                    | SCCM                                     | Intune                        | Gap             |
| ------------------------------ | ---------------------------------------- | ----------------------------- | --------------- |
| Drivers install during imaging | ✓ During task sequence                   | ✗ After Windows boots         | Medium          |
| Custom/modified drivers        | ✓ Any driver                             | ✗ Windows Update catalog only | **Significant** |
| Air-gapped deployment          | ✓ From DPs                               | ✗ Requires internet           | Medium          |
| Driver version pinning         | ✓ Explicit versions                      | Partial (approve/block)       | Low             |
| Storage controller drivers     | ✓ Mass storage drivers injected to WinPE | ✗ Must be in OEM image        | **Significant** |

**Critical impact: Storage controller drivers**:

During bare-metal imaging, Windows PE must have storage controller drivers to access hard drive. SCCM injects mass storage drivers into WinPE boot image. Intune has no imaging capability, so storage driver requirement is irrelevant **unless** device has storage controller not supported by OEM Windows image.

**Workaround**:

- **OEM pre-installed drivers**: Dell, HP, Lenovo factory images include all drivers for that specific hardware model
- **Windows Update driver coverage**: Test driver availability before deploying hardware models
- **Driver pre-staging**: For known gaps, deploy driver installers as Win32 apps assigned to specific device models (install after Autopilot completes)

**Example driver pre-staging**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt device model and driver pack paths for your environment.

```powershell
# Win32 app: Dell Precision 5680 - Custom Driver Pack
# Requirement rule: device.model -eq "Precision 5680"
# Install command:
.\DellDriverPack.exe /s /f
```

**Impact**: Low for mainstream hardware (Dell, HP, Lenovo workstations). High for custom-built PCs or specialty hardware (CAD workstations, medical devices, industrial PCs).

---

### Partial Parity

#### Refresh/Reinstall (Autopilot Reset)

SCCM refresh task sequences wipe devices and redeploy Windows while preserving user data via USMT. Intune's [Autopilot Reset](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-reset) can reprovision devices with significant limitations:

**Autopilot Reset capabilities**:

- Remove user-installed apps (Win32 apps, Store apps)
- Remove user data (if not using Known Folder Move)
- Reset Windows settings to defaults
- Re-run Autopilot provisioning (ESP, policy application, app installation)
- Preserve device's Azure AD join and Intune enrollment
- Preserve Wi-Fi connection profile (on local reset only)

**Autopilot Reset limitations**:

| Feature                | SCCM Refresh               | Autopilot Reset                 | Gap             |
| ---------------------- | -------------------------- | ------------------------------- | --------------- |
| Change Windows version | ✓ Can upgrade or downgrade | ✗ Keeps existing OS version     | **Significant** |
| User state migration   | ✓ USMT capture/restore     | ✗ Relies on OneDrive            | **Significant** |
| Custom partitioning    | ✓ Repartition disk         | ✗ Preserves existing partitions | Low             |
| Initiation method      | Admin or user              | Admin (remote) or user (local)  | None            |
| Offline operation      | ✓ Via boot media           | ✗ Requires internet             | Medium          |

**Autopilot Reset does not change Windows version**. A device on Windows 11 22H2 will remain on Windows 11 22H2 after reset. To change Windows version:

1. Deploy feature update policy before reset (upgrade to target version)
2. Then perform Autopilot Reset
3. **Or** wipe device completely and re-image via SCCM/OEM

**Autopilot Reset types**:

**Local Autopilot Reset** (user-initiated):

- User accesses Settings > Update & Security > Recovery > Reset this PC
- Selects "Fresh Start" (Windows 11) or "Start" under Autopilot Reset (Windows 10)
- Device resets and re-provisions automatically
- User must authenticate with Azure AD credentials to complete provisioning

**Remote Autopilot Reset** (admin-initiated):

- Admin selects device in Intune console
- Clicks "Autopilot Reset" remote action
- Device receives reset command at next check-in
- Device resets automatically at next user logoff or after timeout

**Use cases**:

- **Repurpose device**: Reset device for new user (remove previous user's apps and data)
- **Troubleshooting**: Reset device to eliminate configuration issues
- **Device refresh**: Clean up device performance degradation (bloatware removal)

**Not suitable for**:

- Windows version downgrades (e.g., Windows 11 → Windows 10)
- Offline devices (requires internet for provisioning)
- Devices with corrupted Windows installation (no OS to boot into)

#### Replace Scenarios (PC Migration)

SCCM replace task sequences automate PC migration:

1. Capture user state from old PC (USMT to State Migration Point)
2. Deploy OS to new PC
3. Restore user state from SMP to new PC
4. Delete old PC from SCCM database

**Intune requires manual workflow**:

**Intune PC migration workflow**:

1. **Pre-migration (user's old PC)**:
   - Ensure OneDrive Known Folder Move is enabled
   - Wait for all files to sync to OneDrive (check sync status)
   - Export browser favorites (if not using Edge/Chrome sync)
   - Document installed applications and settings

2. **Provision new PC**:
   - Purchase new PC with Windows pre-installed
   - Pre-register hardware hash in Autopilot (or use OEM API)
   - Ship device to user

3. **User unboxing**:
   - User powers on new PC
   - Autopilot detects device during OOBE
   - User authenticates with Azure AD credentials
   - Autopilot applies policies and installs apps (ESP shows progress)

4. **Post-migration**:
   - User signs into OneDrive
   - Files sync down from cloud automatically
   - User reconfigures applications manually
   - User retires old PC (wipe or return to IT)

**Comparison**:

| Aspect                | SCCM Replace                            | Intune Migration                                     | Gap              |
| --------------------- | --------------------------------------- | ---------------------------------------------------- | ---------------- |
| IT effort             | High (create task sequence, manage SMP) | Low (user self-service)                              | Intune advantage |
| User disruption       | Low (IT handles everything)             | Medium (user waits for file sync, reconfigures apps) | SCCM advantage   |
| Data coverage         | Complete (USMT captures all)            | Partial (OneDrive KFM only)                          | **Significant**  |
| Application migration | Automatic (reinstall via task sequence) | Automatic (Win32 apps via Intune)                    | Parity           |
| Timeline              | 2-4 hours (IT-driven)                   | 1-2 hours provisioning + user configuration time     | Similar          |

**Impact**: Medium. For users with simple profiles (Desktop/Documents/Pictures in OneDrive), migration is seamless. For users with LOB app data or complex configurations, manual intervention required.

#### In-Place Upgrades (Feature Update Policies)

**Full Parity achieved**. Both SCCM and Intune perform in-place operating system upgrades using Windows Setup.

**SCCM**: Uses "Upgrade Operating System" task sequence step:

```
Task Sequence: Upgrade to Windows 11 23H2
  ├─ Pre-Upgrade Compatibility Check
  ├─ Download Package Content (Windows 11 23H2 upgrade files)
  ├─ Upgrade Operating System (Setup.exe /auto upgrade /dynamicupdate enable)
  ├─ Post-Upgrade Application Compatibility Fixes
  └─ Cleanup (Remove Windows.old folder)
```

**Intune**: Uses [feature update policies](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-feature-updates):

```
Policy: Windows 11 23H2 Feature Update
  Target version: Windows 11 (23H2)
  Rollout start: 2026-03-01
  Rollout end: 2026-06-30
  Assignment: All-Devices-Production
```

Windows Update downloads Windows 11 23H2 upgrade files and runs `Setup.exe` automatically.

**Functional differences**:

| Feature                  | SCCM Task Sequence                        | Intune Feature Update Policy           | Notes                          |
| ------------------------ | ----------------------------------------- | -------------------------------------- | ------------------------------ |
| Pre-upgrade scripts      | ✓ Task sequence steps                     | Via Remediations (separate deployment) | SCCM has tighter integration   |
| Deployment schedule      | ✓ Explicit deadline                       | Rollout window (start/end dates)       | Different control models       |
| Pilot/production phasing | ✓ Phased deployment                       | Manual group creation                  | SCCM has automatic progression |
| Rollback on failure      | Automatic (Windows Setup)                 | Automatic (Windows Setup)              | Same underlying technology     |
| User experience          | Customizable (suppress UI, force restart) | Standard Windows Update prompts        | SCCM has more control          |

**Recommendation**: Both platforms handle in-place upgrades effectively. SCCM offers more granular control and automation. Intune is simpler to configure and manage. Organizations transitioning from SCCM to Intune will find feature update policies provide acceptable functionality for Windows version upgrades.

---

### Intune Advantages

#### Windows Autopilot

[Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/whats-new) transforms OEM device provisioning with zero-touch deployment. This is Intune's flagship OS deployment capability and represents a significant improvement over SCCM imaging for **new device procurement scenarios**.

**Autopilot Deployment Modes**:

##### 1. User-Driven Mode (Most Common)

**Workflow**:

1. **Pre-provisioning**: IT registers device hardware hash in Intune Autopilot service (manual CSV upload or OEM API)
2. **Device assignment**: Assign device to Autopilot deployment profile
3. **User unboxing**: User unboxes device, powers on, connects to network
4. **OOBE branding**: Windows OOBE displays organizational branding ("Setting up for Contoso")
5. **User authentication**: User enters Azure AD credentials
6. **Autopilot provisioning**:
   - Azure AD join or Hybrid Azure AD join
   - Intune enrollment
   - Device configuration policy application
   - Win32 app installation (tracked by ESP)
   - Compliance policy evaluation
7. **User desktop access**: ESP completes, user reaches desktop with all apps and policies applied

**Configuration** (Autopilot deployment profile):

```
Deployment mode: User-driven
Join type: Azure AD join
OOBE experience:
  - Skip privacy settings: Yes
  - Skip EULA: Yes
  - Skip OEM registration: Yes
  - Hide change account options: Yes
Language: United States
Automatically configure keyboard: Yes
Apply device name template: DESKTOP-%RAND:4%
Enrollment Status Page:
  - Show app and profile installation progress: Yes
  - Block device use until required apps install: Yes
  - Required apps: Microsoft 365 Apps, Chrome, Defender
  - Timeout: 60 minutes
```

**User experience**:

- Total time: 30-60 minutes (depending on app count and network speed)
- User interaction: Enter credentials, wait for ESP to complete
- No IT involvement required

**Benefits vs SCCM imaging**:

- **No imaging infrastructure**: No PXE servers, DPs, boot images
- **User self-service**: Users provision own devices without IT assistance
- **OEM integration**: Hardware vendors pre-register devices (Dell, HP, Lenovo Autopilot service)
- **Branded experience**: Organizational branding in OOBE
- **No re-imaging required**: Device uses OEM factory image (no patching reference images monthly)

##### 2. Self-Deploying Mode (Kiosk/Shared Devices)

**Workflow**:

1. Device boots to OOBE
2. Device detects Autopilot profile automatically (no user interaction)
3. Device joins Azure AD and enrolls in Intune
4. Policies and apps deploy automatically
5. Device reaches logon screen (shared device mode) or kiosk app launches

**Requirements**:

- TPM 2.0 (for device attestation)
- Windows 11 or Windows 10 1903+
- Network connectivity during OOBE

**Use cases**:

- Kiosk devices (retail point-of-sale, information displays)
- Shared workstations (healthcare, manufacturing shift workers)
- Conference room devices

**Configuration**:

```
Deployment mode: Self-deploying
Join type: Azure AD join
OOBE experience: All OOBE screens skipped
Device name template: KIOSK-%SERIAL%
Assigned Access: Launch single kiosk app (POS app)
```

##### 3. Pre-Provisioning Mode (White Glove)

**Workflow**:

1. **Technician pre-provisioning**:
   - IT technician unboxes device
   - Device boots to OOBE
   - Technician presses Windows key 5 times (launches Autopilot pre-provisioning)
   - Technician authenticates with Azure AD credentials
   - Autopilot provisions device (joins Azure AD, enrolls Intune, installs apps)
   - Technician verifies all apps installed successfully
   - Technician seals device (Autopilot Reset to user-ready state)

2. **User provisioning**:
   - User unboxes pre-provisioned device
   - User enters credentials
   - Device completes final user-specific configuration (user apps, user policies)
   - Total user wait time: 5-10 minutes (vs 30-60 for user-driven)

**Benefits**:

- **Reduced user wait time**: Technician pre-installs large apps (Office, Adobe Creative Cloud) before user receives device
- **Quality validation**: Technician verifies successful deployment before shipping to user
- **Remote location support**: Pre-provision devices at distribution center, ship directly to users

**Example timeline**:

- Traditional user-driven: User waits 45 minutes for apps to install
- White Glove: Technician pre-provisions (45 minutes), user waits 8 minutes for user-specific config

**Use cases**:

- Remote workers (ship pre-configured devices directly to home)
- High-value deployments (executive devices, specialty hardware)
- Large-scale rollouts (provision 1000 devices in warehouse before distribution)

##### 4. Autopilot Device Preparation (Windows 11 24H2+)

[Autopilot device preparation](https://learn.microsoft.com/en-us/autopilot/device-preparation/overview) is a **simplified provisioning flow** introduced for Windows 11 24H2 and backported to 23H2/22H2 with KB5035942.

**Key differences from traditional Autopilot**:

- **Faster provisioning**: Optimized deployment flow reduces provisioning time by 20-30%
- **Simplified configuration**: Single deployment policy vs multiple profiles
- **Enhanced monitoring**: Percentage-based progress indicator in OOBE (vs generic ESP spinner)
- **App limit increased**: Maximum 25 apps during OOBE (increased from 20 in January 2026)
- **No ESP**: Does not use traditional Enrollment Status Page (simpler UX)

**Configuration** (device preparation policy):

```
Policy Name: Device Preparation - Employees
Device group: All-Employees-Autopilot
Apps to deploy during provisioning:
  - Microsoft 365 Apps for Enterprise (required)
  - Microsoft Edge (required)
  - Company Portal (required)
  - OneDrive (required)
  - Microsoft Teams (required)
  [... up to 25 apps total]
PowerShell scripts:
  - Set-CorporateWallpaper.ps1
  - Configure-NetworkPrinters.ps1
```

**Recommendation**: Use device preparation for new Windows 11 deployments (simpler than traditional Autopilot). Use traditional Autopilot for Windows 10 or complex deployment scenarios requiring ESP blocking behavior.

#### Enrollment Status Page (ESP)

[Enrollment Status Page](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-enrollment-status) displays provisioning progress during Autopilot and blocks user access until device configuration completes.

**ESP tracking phases**:

**Device Preparation**:

- Azure AD join
- Intune MDM enrollment
- Device certificate enrollment
- Network connectivity validation

**Device Setup**:

- Security policies (BitLocker, firewall, antivirus)
- Device configuration profiles (Wi-Fi, VPN, certificates)
- Device compliance policy application
- Endpoint detection and response (Defender for Endpoint onboarding)

**Account Setup**:

- User profile creation
- User certificates
- Network profile configuration
- User-assigned apps (if configured)

**ESP configuration**:

```
Show app and profile installation progress: Yes
Block device use until all apps and profiles are installed: Yes
Allow users to reset device if installation error occurs: Yes
Show error when installation exceeds timeout: Yes
Turn on log collection: Yes

Required apps (device setup):
  - Microsoft 365 Apps for Enterprise
  - Microsoft Defender for Endpoint
  - Company Portal

Required apps (account setup):
  - None (all apps in device setup for faster provisioning)

Timeout: 60 minutes
```

**ESP vs SCCM task sequence progress**:

| Feature             | SCCM Task Sequence                             | Intune ESP                                  | Assessment         |
| ------------------- | ---------------------------------------------- | ------------------------------------------- | ------------------ |
| Progress visibility | ✓ Step-by-step progress                        | ✓ Phase-based progress                      | Parity             |
| Error handling      | ✓ Retry, continue on error, fail task sequence | ✓ Retry, allow user reset, show error       | Parity             |
| Timeout             | ✓ Configurable per step                        | ✓ Global timeout (default 60 min)           | SCCM more granular |
| Blocking behavior   | ✓ User cannot access desktop until complete    | ✓ User cannot access desktop until complete | Parity             |
| Log collection      | ✓ SMSTS.log                                    | ✓ MDMDiagReport.zip                         | Parity             |

**Recommendation**: Configure ESP with blocking behavior for required apps to ensure users receive fully configured devices before accessing desktop. Set realistic timeout (60-90 minutes for large app deployments).

#### OOBE Customization and Branding

Autopilot provides **organizational branding** in Windows OOBE that SCCM cannot replicate.

**OOBE customization options**:

- Skip privacy settings screen
- Skip EULA acceptance
- Skip OEM registration (Dell, HP, Lenovo registration prompts)
- Hide change account options (prevents local account creation)
- Skip Cortana setup (Windows 10)
- Skip Windows Hello setup
- Custom organizational messaging ("Setting up device for Contoso Corp")
- Corporate logo display

**Example branded OOBE experience**:

```
Windows OOBE screen:
  "Setting up your device for Contoso Corporation"
  [Contoso logo]

  Progress: Installing Microsoft 365 Apps...
  [Progress bar: 45%]

  "This may take a few minutes. Please don't turn off your device."
```

**User experience benefits**:

- **Professional appearance**: Users see organizational branding, not generic Windows setup
- **Reduced clicks**: Skip unnecessary OOBE screens (reduces user interaction from 10 screens to 2-3)
- **Consistent experience**: All devices show same branded experience
- **Reduced support calls**: Clear messaging reduces user confusion

**SCCM comparison**: SCCM task sequences can customize Windows installation but run in WinPE (no OOBE). Users see:

1. Task sequence progress bar (technical, not user-friendly)
2. Standard Windows OOBE after task sequence completes (all screens, no branding)

Autopilot's branded OOBE provides superior user experience for end-user device provisioning.

---

## Licensing Impact

### Base Features (Intune Plan 1 / M365 E3)

All Windows Autopilot capabilities are included in **Intune Plan 1**, which is bundled with:

- Microsoft 365 E3/E5
- Microsoft 365 Business Premium
- Enterprise Mobility + Security (EMS) E3/E5
- Standalone Intune Plan 1 ($8/user/month)

**Included features**:

- Windows Autopilot (all deployment modes)
- Autopilot device preparation
- Enrollment Status Page
- Feature update policies (in-place upgrades)
- Autopilot Reset (local and remote)

**Free Windows features** (no licensing cost):

- Provisioning packages (Windows Configuration Designer)
- Windows 11 cloud recovery

### Additional Requirements

**OneDrive for Business** (for data migration alternative to USMT):

- Included in Microsoft 365 E3/E5, Business Standard, Business Premium
- Standalone: $5/user/month (OneDrive Plan 1 - 1TB storage)

**Azure AD/Entra ID P1** (for Hybrid Azure AD join, dynamic groups):

- Included in Microsoft 365 E3/E5, EMS E3/E5
- Required for Hybrid Azure AD join (domain-joined + Azure AD-joined devices)

### Third-Party Solutions (Not Microsoft Licensed)

| Solution                         | Purpose                                      | Typical Cost            |
| -------------------------------- | -------------------------------------------- | ----------------------- |
| **OEM Custom Imaging Service**   | Pre-load custom Windows image on new devices | $10-30/device setup fee |
| **Tranxition Migration Manager** | Enterprise user state migration              | Contact vendor          |
| **Laplink PCmover**              | Consumer user state migration                | $30-60/device one-time  |

### Total Cost of Ownership Comparison

**SCCM OS deployment costs** (1,000 devices, 3-year period):

- Infrastructure: $30,000-60,000 (servers, DPs, PXE servers)
- Image maintenance: $15,000-30,000 (monthly reference image patching, testing)
- Administrative overhead: $60,000-90,000 (0.5-0.75 FTE × 3 years)
- **Total**: $105,000-180,000

**Intune Autopilot costs** (1,000 devices, 3-year period):

- Intune licensing: $0 (included in M365 E3)
- OEM Autopilot service: $0 (Dell, HP, Lenovo include Autopilot registration at no cost)
- User state migration: $0 (OneDrive included in M365 E3)
- Infrastructure: $0 (cloud service)
- Administrative overhead: $15,000-30,000 (0.1-0.25 FTE for profile maintenance)
- **Total incremental cost**: $15,000-30,000

**Savings**: $90,000-150,000 over 3 years primarily due to infrastructure elimination and reduced image maintenance overhead.

**However**: This assumes **new device procurement only**. Organizations requiring bare-metal imaging or complex refresh scenarios must retain SCCM or adopt OEM custom imaging, adding $10,000-50,000 to Intune costs.

See [Executive Summary — Licensing Summary](executive-summary.md) for comprehensive licensing analysis across all capability areas.

---

## Migration Considerations

### Scenario-Based Migration Assessment

**Critical question**: What OS deployment scenarios does your organization require?

| Scenario                              | SCCM Approach                        | Intune Approach                                      | Recommendation                                                             |
| ------------------------------------- | ------------------------------------ | ---------------------------------------------------- | -------------------------------------------------------------------------- |
| **New device procurement**            | PXE boot or media → image deployment | Autopilot user-driven mode                           | **Migrate to Autopilot** (superior experience)                             |
| **Device refresh (same user)**        | Refresh task sequence (USMT)         | Autopilot Reset + OneDrive KFM                       | **Evaluate data complexity** (simple profiles → Autopilot; complex → SCCM) |
| **Device replace (new hardware)**     | Replace task sequence (USMT via SMP) | Manual migration (OneDrive + new Autopilot device)   | **Evaluate data complexity**                                               |
| **Bare-metal imaging (blank drives)** | PXE or media deployment              | **No Intune capability**                             | **Retain SCCM or OEM custom imaging**                                      |
| **Custom OS images**                  | Build and deploy reference images    | **No Intune capability**                             | **Eliminate custom images or use OEM service**                             |
| **Server deployments**                | Server task sequences                | **No Intune support** (Windows Server not supported) | **Retain SCCM or use Azure Automation**                                    |
| **In-place upgrades**                 | Upgrade task sequence                | Feature update policies                              | **Migrate to Intune** (equivalent functionality)                           |

### Pre-Migration Assessment

#### OS Deployment Inventory

Audit SCCM task sequences and deployment activity:

```sql
-- SQL query for SCCM database to inventory task sequence deployments
SELECT
    ts.Name AS TaskSequenceName,
    ts.Description,
    CASE ts.Purpose
        WHEN 1 THEN 'Standard client task sequence'
        WHEN 2 THEN 'Server task sequence'
        WHEN 3 THEN 'Custom task sequence'
    END AS Purpose,
    COUNT(DISTINCT dep.CollectionID) AS DeployedToCollections,
    COUNT(DISTINCT exec.ResourceID) AS ExecutionCount,
    MAX(exec.ExecutionTime) AS LastExecution
FROM v_TaskSequencePackage ts
LEFT JOIN v_CIAssignment dep ON ts.PackageID = dep.AssignmentName
LEFT JOIN v_TaskExecutionStatus exec ON ts.PackageID = exec.PackageID
GROUP BY ts.Name, ts.Description, ts.Purpose
ORDER BY ExecutionCount DESC
```

#### Task Sequence Complexity Analysis

For each task sequence, evaluate Autopilot migration feasibility:

| Task Sequence Type               | Complexity Indicators                           | Autopilot Feasible? | Migration Action                                            |
| -------------------------------- | ----------------------------------------------- | ------------------- | ----------------------------------------------------------- |
| **New device build**             | Standard: Partition → Apply OS → Drivers → Apps | **Yes**             | Migrate to Autopilot user-driven; deploy apps as Win32 apps |
| **New device with custom image** | Uses custom WIM file (not vanilla Windows)      | **Partial**         | OEM custom imaging service or eliminate custom image        |
| **Refresh (simple profiles)**    | USMT with Desktop/Documents/Pictures only       | **Yes**             | OneDrive Known Folder Move + Autopilot Reset                |
| **Refresh (complex profiles)**   | USMT with custom MigXML rules, LOB app data     | **No**              | Retain SCCM or third-party migration tool                   |
| **Replace**                      | USMT via SMP, computer association              | **Partial**         | Manual OneDrive migration + new Autopilot device            |
| **Bare metal**                   | PXE or media boot required                      | **No**              | Retain SCCM or OEM custom imaging                           |
| **In-place upgrade**             | Standard upgrade process                        | **Yes**             | Feature update policies                                     |
| **Server build**                 | Windows Server deployment                       | **No**              | Retain SCCM or Azure Automation (Azure VMs)                 |
| **Custom workflow**              | Complex pre/post scripts, conditional logic     | **No**              | Reimplement as Remediations or retain SCCM                  |

#### User State Migration Assessment

Analyze user profile complexity to determine OneDrive Known Folder Move sufficiency:

**Data collection script** (run on sample devices):

> **Note**: The following is a conceptual example illustrating the pattern. Test on sample devices before broad deployment.

```powershell
# Analyze user profile data locations
$ProfileSizes = @()

foreach ($User in (Get-ChildItem C:\Users -Directory | Where-Object {$_.Name -notin @('Public', 'Default')})) {
    $DesktopSize = (Get-ChildItem $User.FullName\Desktop -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    $DocumentsSize = (Get-ChildItem $User.FullName\Documents -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    $AppDataSize = (Get-ChildItem $User.FullName\AppData -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    $OtherSize = (Get-ChildItem $User.FullName -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch 'Desktop|Documents|AppData'} | Measure-Object -Property Length -Sum).Sum / 1GB

    $ProfileSizes += [PSCustomObject]@{
        User = $User.Name
        Desktop_GB = [math]::Round($DesktopSize, 2)
        Documents_GB = [math]::Round($DocumentsSize, 2)
        AppData_GB = [math]::Round($AppDataSize, 2)
        Other_GB = [math]::Round($OtherSize, 2)
        OneDriveKFM_Coverage_Percent = [math]::Round((($DesktopSize + $DocumentsSize) / ($DesktopSize + $DocumentsSize + $AppDataSize + $OtherSize)) * 100, 0)
    }
}

$ProfileSizes | Export-Csv -Path "ProfileSizeAnalysis.csv" -NoTypeInformation
```

**Analysis**:

- OneDrive KFM coverage >80%: Good candidate for Autopilot migration
- OneDrive KFM coverage <50%: High risk; retain SCCM or deploy third-party migration solution
- AppData >5GB: LOB apps store significant data locally; identify apps and evaluate migration path

### Migration Strategies

#### Strategy 1: New Device Procurement → Autopilot (Immediate Win)

**Timeline**: 1-3 months

**Approach**:

1. **Month 1: Pilot Autopilot**
   - Purchase 50 Autopilot-enabled devices (Dell, HP, or Lenovo with Autopilot service)
   - Configure Autopilot deployment profile
   - Create ESP with required apps
   - Deploy to pilot users (IT, HR)
   - Monitor provisioning success and user feedback

2. **Month 2: Production Rollout**
   - Expand to all new device procurement
   - Train helpdesk on Autopilot support (reset device, resync, ESP timeout)
   - Update device procurement process (require Autopilot-enabled devices)

3. **Month 3: Decommission New Device Imaging**
   - Stop creating new PXE deployments for new devices
   - Archive new device task sequences
   - Retain SCCM for refresh/replace scenarios (if needed)

**Benefits**:

- **Fast time-to-value**: Autopilot provides immediate benefits for new purchases
- **Low risk**: Does not affect existing devices or refresh workflows
- **User satisfaction**: Superior user experience vs traditional imaging

**Recommendation**: **All organizations should migrate new device procurement to Autopilot immediately**. This is the highest ROI, lowest-risk Intune OS deployment migration.

#### Strategy 2: Refresh/Replace → OneDrive + Autopilot (Conditional)

**Timeline**: 3-6 months

**Prerequisites**:

- OneDrive Known Folder Move deployed to all devices (6-12 weeks for full sync)
- User profile analysis shows >80% data coverage via OneDrive KFM
- LOB applications store data in known folders or have cloud alternatives

**Approach**:

1. **Month 1-2: Deploy OneDrive Known Folder Move**
   - Configure OneDrive KFM policy in Intune
   - Deploy to pilot group (100-200 users)
   - Monitor sync status and storage usage
   - Expand to production

2. **Month 3: Pilot Autopilot Refresh**
   - Select 20-50 devices for refresh
   - Verify OneDrive sync complete
   - Perform Autopilot Reset (remote or local)
   - Monitor user satisfaction and data loss reports

3. **Month 4-5: Production Rollout**
   - Document user communication (what to expect, how to verify data synced)
   - Schedule refresh deployments in waves (100-200 devices/week)
   - Monitor for issues and adjust process

4. **Month 6: Decommission SCCM Refresh Task Sequences**
   - Stop using SCCM for device refresh
   - Archive refresh task sequences
   - Update helpdesk procedures (Autopilot Reset instead of re-image)

**Success criteria**:

- <5% data loss incidents during pilot
- User satisfaction >80% (post-refresh survey)
- Provisioning time <90 minutes

**Rollback plan**:

- If pilot shows >10% data loss: Retain SCCM refresh task sequences, delay Autopilot migration
- If provisioning time >2 hours: Reduce ESP app count, optimize app deployment

**Organizations that should NOT migrate refresh to Autopilot**:

- User profiles with significant LOB app data in AppData
- Compliance requirements for guaranteed data migration (healthcare, finance)
- Users with >1TB local data (OneDrive sync time excessive)

#### Strategy 3: Bare-Metal Imaging → Hybrid Model (Long-Term SCCM Retention)

**For organizations requiring bare-metal imaging**:

**Permanent state**:

- **New device procurement**: Autopilot (primary method)
- **Bare-metal imaging**: SCCM (retained indefinitely)
- **Refresh/replace**: Autopilot (if OneDrive sufficient) or SCCM (if complex profiles)

**Infrastructure sizing**:

- Reduce SCCM infrastructure to minimum required for imaging (1 primary site, 1-2 DPs)
- Decommission SUPs, application deployment, software inventory (migrate to Intune)
- Retain only OS deployment infrastructure

**Cost optimization**:

- SCCM licensing: Required (cannot eliminate)
- Infrastructure: Reduced by 50-70% (fewer servers, smaller DPs)
- Administrative overhead: Reduced by 60-80% (imaging only, not full management)

**Alternative: OEM Custom Imaging**

Instead of retaining SCCM for bare-metal imaging:

1. **Build custom reference image**:
   - Create Windows 11 reference image with baseline apps and configuration
   - Test and validate image (security settings, performance, compliance)

2. **Upload to OEM custom imaging service**:
   - Dell: Upload image to Dell Factory Integration Portal
   - HP: Upload image to HP Image Engineering Services
   - Lenovo: Upload image to Lenovo Services Portal

3. **Order devices with custom image**:
   - New device orders ship with custom image pre-loaded
   - Devices complete Autopilot provisioning on first boot (apply final policies and apps)

**OEM custom imaging costs**:

- Setup fee: $5,000-15,000 (one-time validation and testing)
- Per-device fee: $10-30/device
- Lead time: 2-4 weeks for image validation, then normal order fulfillment

**Break-even analysis** (1,000 devices over 3 years):

- SCCM retention costs: $50,000-80,000 (infrastructure + admin overhead)
- OEM custom imaging costs: $15,000-45,000 (setup + per-device fees)
- **OEM custom imaging cheaper for organizations imaging <200 devices/year**

#### Strategy 4: Server Imaging → Azure Automation (Azure VMs Only)

For organizations with servers in Azure:

**[Azure Automation Update Management](https://learn.microsoft.com/en-us/azure/automation/update-management/overview)**:

- OS deployment for Azure VMs
- Patch management with orchestration
- Pre/post-deployment scripts
- Maintenance windows
- Hybrid support (Azure + on-premises)

**Transition plan**:

1. Migrate on-premises servers to Azure IaaS
2. Onboard Azure VMs to Azure Automation
3. Decommission SCCM server OS deployment

**Not applicable for**:

- On-premises physical servers (no Azure migration path)
- Specialized server hardware (hardware management consoles, out-of-band management)

### Common Migration Issues and Resolutions

| Issue                                        | Cause                                               | Resolution                                                                                                                                                           |
| -------------------------------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Autopilot provisioning fails at ESP**      | Required app installation timeout or failure        | Increase ESP timeout to 90 minutes; review app installation logs; remove blocking apps if non-critical                                                               |
| **Device not detected by Autopilot**         | Hardware hash not registered or incorrect           | Verify device in Autopilot devices list; re-register hardware hash; wait 15 minutes for sync                                                                         |
| **OneDrive Known Folder Move not syncing**   | Folder size exceeds limits or policy not applied    | Check folder size limits (>300,000 files or >5000 items per folder); verify policy assignment; force sync: `C:\Program Files\Microsoft OneDrive\onedrive.exe /reset` |
| **User data missing after Autopilot Reset**  | OneDrive not fully synced before reset              | Train users to verify sync status before reset (OneDrive icon = green check); document verification procedure                                                        |
| **Autopilot Reset stuck at "Getting ready"** | Network connectivity issue or Intune service issue  | Verify internet connectivity; check Intune service health in M365 admin center; reboot device and retry                                                              |
| **Apps not installing during Autopilot**     | Assignment targeting incorrect group or app failure | Verify Azure AD group membership; check app installation logs: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`               |
| **Hybrid Azure AD join fails**               | On-premises AD connector issue or network issue     | Verify Azure AD Connect sync status; verify device can reach on-prem DC; check Hybrid Azure AD join status: `dsregcmd /status`                                       |

---

## Sources

### Microsoft Learn Documentation

- [Overview of Windows Autopilot device preparation](https://learn.microsoft.com/en-us/autopilot/device-preparation/overview)
- [What's new in Windows Autopilot device preparation](https://learn.microsoft.com/en-us/autopilot/device-preparation/whats-new)
- [Windows Autopilot requirements](https://learn.microsoft.com/en-us/autopilot/requirements)
- [What's new in Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/whats-new)
- [Windows Autopilot scenarios](https://learn.microsoft.com/en-us/autopilot/tutorial/autopilot-scenarios)
- [Windows Autopilot for pre-provisioned deployment](https://learn.microsoft.com/en-us/autopilot/pre-provision)
- [Windows Autopilot deployment for existing devices](https://learn.microsoft.com/en-us/autopilot/existing-devices)
- [Windows Autopilot Reset](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-reset)
- [Set up the Enrollment Status Page](https://learn.microsoft.com/en-us/mem/intune/enrollment/windows-enrollment-status)
- [Deploy a task sequence - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/deploy-a-task-sequence)
- [Task sequence steps - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/understand/task-sequence-steps)
- [Use PXE for OSD over the network - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/use-pxe-to-deploy-windows-over-the-network)
- [Create bootable media - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/deploy-use/create-bootable-media)
- [Manage user state - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/get-started/manage-user-state)
- [Manage drivers - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/osd/get-started/manage-drivers)
- [User State Migration Tool (USMT) Overview](https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-overview)
- [Redirect Known Folders to OneDrive](https://learn.microsoft.com/en-us/onedrive/redirect-known-folders)
- [Enterprise State Roaming Overview](https://learn.microsoft.com/en-us/azure/active-directory/devices/enterprise-state-roaming-overview)
- [Manage Windows Feature Updates - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/windows-10-feature-updates)
- [Microsoft Deployment Toolkit](https://learn.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/get-started-with-the-microsoft-deployment-toolkit)
- [Azure Automation Update Management Overview](https://learn.microsoft.com/en-us/azure/automation/update-management/overview)

### Community and Technical Resources

- [Windows Autopilot Best Practices: 2026 Updated - WorkWize](https://www.goworkwize.com/blog/windows-autopilot-best-practices)
- [Windows Autopilot: The Proven Guide for 2025 - The Deployment Guy](https://thedeploymentguy.co.uk/windows-autopilot-2025/)
- [Cloud OS Deployment, Part 4 - Imaging over Internet, directly into Windows Autopilot - Deployment Research](https://www.deploymentresearch.com/cloud-os-deployment-part-4-imaging-over-internet-directly-into-windows-autopilot/)
- [What are Windows Autopilot & Microsoft Intune? Pros & cons - SmartDeploy](https://www.smartdeploy.com/blog/windows-autopilot-and-microsoft-intune/)

---

**Research Date**: February 18, 2026
**Primary Sources**: Microsoft Learn official documentation, Microsoft Community Hub, verified third-party technical resources
