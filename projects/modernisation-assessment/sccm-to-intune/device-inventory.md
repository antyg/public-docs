# Device Inventory & Asset Intelligence — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Partial to Significant Gap

---

## Executive Summary

Device inventory capabilities in Microsoft Intune provide adequate coverage for standard hardware and software tracking but fall significantly short of SCCM's mature inventory framework. The **Properties Catalog** feature (released December 2024) adds limited hardware property extensibility, but cannot replicate SCCM's full WMI class customization via MOF extensions. **Software Metering** and **Asset Intelligence** have no Intune equivalents, creating substantial gaps for organizations dependent on usage tracking and license optimization. Organizations with custom inventory requirements must implement workarounds using **Proactive Remediations** with **Log Analytics custom logs** or retain SCCM co-management for inventory workloads.

---

## Feature Parity Matrix

| SCCM Feature                                   | Intune Equivalent                         | Parity Rating   | Licensing                                          | Notes                                                                                                               |
| ---------------------------------------------- | ----------------------------------------- | --------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Hardware Inventory (Standard WMI Classes)**  | Device properties + Properties Catalog    | Near Parity     | Intune Plan 1                                      | Intune collects standard hardware info at enrollment; Properties Catalog (Dec 2024) adds 97+ extensible properties  |
| **Custom Hardware Inventory (MOF Extensions)** | Properties Catalog (limited)              | Significant Gap | Intune Plan 1                                      | SCCM supports full WMI class extensions via configuration.mof; Intune limited to 97 pre-defined property categories |
| **Hardware Inventory Cycles (Delta & Full)**   | 7-day refresh cycle (24h for apps)        | Partial         | Intune Plan 1                                      | SCCM allows configurable cycles (hourly to daily); Intune fixed 7-day cycle (24h for Win32 apps)                    |
| **Software Inventory (File Collection)**       | Discovered Apps                           | Partial         | Intune Plan 1                                      | SCCM collects file header details with granular rules; Intune detects installed apps only (no file metadata)        |
| **Software Metering (Usage Tracking)**         | No Equivalent                             | No Equivalent   | N/A                                                | SCCM tracks .exe usage, duration, idle time; no Intune equivalent for license optimization                          |
| **Asset Intelligence (Catalogue & Sync)**      | No Equivalent                             | No Equivalent   | N/A                                                | SCCM provides software categorization, license management reports; no direct Intune equivalent                      |
| **Discovery Methods (AD System/User/Group)**   | Entra ID Device Registration              | Partial         | Intune Plan 1                                      | Entra ID replaces AD discovery; no network discovery equivalent                                                     |
| **Heartbeat Discovery**                        | Device check-in (sync)                    | Near Parity     | Intune Plan 1                                      | Both maintain device liveness; Intune uses MDM check-in vs. SCCM heartbeat DDR                                      |
| **Resource Explorer**                          | Device properties + Managed Apps          | Near Parity     | Intune Plan 1                                      | SCCM Resource Explorer shows all inventory classes; Intune shows device details + apps per device                   |
| **Inventory Reports**                          | Device inventory reports + Data Warehouse | Partial         | Intune Plan 1                                      | SCCM has 50+ inventory reports; Intune requires custom reporting via Data Warehouse/Graph API                       |
| **Custom Inventory Collection**                | Proactive Remediations + Log Analytics    | Significant Gap | Endpoint Analytics (M365 E3) + Azure Log Analytics | Workaround requires PowerShell scripts uploading to Log Analytics custom logs (~$2.30/GB ingestion)                 |

---

## Key Findings

### 1. Full/Near Parity Areas

#### 1.1 Standard Hardware Inventory

**SCCM Capability**: Configuration Manager collects hardware inventory from over 100 default WMI classes including:

- System enclosure (manufacturer, model, serial number)
- BIOS (version, manufacturer, release date, SMBIOS version)
- Processor (name, cores, threads, clock speed, architecture)
- Memory (total physical memory, memory devices, bank details)
- Disk (volumes, partitions, capacity, free space)
- Network adapters (MAC address, IP configuration, adapter type)
- Operating system (version, build, service pack, architecture, install date)
- Video controller (name, RAM, resolution)
- TPM (version, manufacturer, spec version)
- Battery (chemistry, design capacity, full charge capacity)

**Intune Capability**: Intune automatically collects standard device properties during enrollment and maintains them through periodic sync (7-day cycle):

- Device name, serial number, manufacturer, model
- BIOS version and manufacturer
- Processor architecture, cores
- Total physical memory
- Storage capacity and available space
- OS version, build number, edition
- TPM version
- Network adapters (MAC addresses)
- Battery health status (mobile devices)
- Entra ID device ID, join type (Entra joined, hybrid joined, registered)
- Primary user assignment
- Compliance state
- Last check-in timestamp

**Properties Catalog Enhancement** (December 2024): The **Properties Catalog** feature extends Intune's hardware inventory with 97+ additional properties across categories:

- **CPU**: Processor ID, stepping, revision
- **BIOS**: SMBIOS version, embedded controller version, system SKU number
- **Battery**: Design capacity, full charge capacity, cycle count, manufacture date
- **TPM**: Physical presence version, manufacturer version
- **Video Controller**: Driver version, adapter RAM, refresh rate
- **Windows QFE**: Installed quality updates with KB numbers
- **Disk**: Disk index, interface type, media type (SSD vs. HDD)
- **Memory**: Memory device details, speed, manufacturer
- **Network Adapter**: Connection status, link speed

The Properties Catalog policy deploys to corporate-owned, Entra Joined or Hybrid Joined Windows 10 21H2+ / Windows 11 21H2+ devices. The **Microsoft Device Inventory Agent** installs as a Windows service, tracking changes locally and syncing every 24 hours.

**Parity Assessment**: **Near Parity**. For organizations with standard hardware tracking requirements, Intune combined with Properties Catalog provides comparable coverage to SCCM's default inventory classes. The 7-day refresh cycle (24h for Properties Catalog) is adequate for most scenarios.

**Migration Considerations**:

- Audit SCCM hardware inventory reports to identify dependencies on specific WMI classes
- Test Properties Catalog to verify all required properties are available in the 97 pre-defined categories
- Accept 7-day/24-hour refresh cycles (SCCM's configurable hourly cycles cannot be replicated)

**Sources**:

- [Collect device hardware info with the properties catalog - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/configuration/properties-catalog)
- [View device details with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/device-inventory)
- [How Intune's New Properties Catalog Improves Inventory Management - Recast](https://www.recastsoftware.com/resources/intunes-new-properties-catalog-and-inventory-management/)

#### 1.2 Device Discovery and Liveness

**SCCM Capability**: Heartbeat Discovery (enabled by default, 7-day cycle) maintains device liveness by creating Discovery Data Records (DDRs) sent to the site database. This ensures stale devices are identified and inactive devices can be aged out.

**Intune Capability**: Device check-in serves the same liveness function. Devices sync with Intune every 8 hours (Windows), with manual sync available via **Device Actions > Sync**. The **Last check-in** timestamp identifies inactive devices. Devices automatically unenroll after 90 days of inactivity (configurable).

**Parity Assessment**: **Near Parity**. Both mechanisms achieve the same outcome: maintain current device inventory and identify stale devices.

**Sources**:

- [Configure discovery methods for Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/deploy/configure/configure-discovery-methods)
- [Categorize devices into groups in Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-group-mapping)

---

### 2. Partial Parity / Gaps

#### 2.1 Software Inventory (Discovered Apps)

**SCCM Capability**: Configuration Manager provides **Software Inventory** (despite the name, it's actually file inventory) that collects file header details for specified file types:

- Configurable file collection rules (e.g., "collect all .exe files in C:\Program Files\")
- File metadata: product name, version, manufacturer, file size, creation date, modification date
- Executable file header information
- Granular exclusions (folders, file types)
- Integration with Asset Intelligence for software categorization
- Custom reporting on file presence across device collections

**Intune Capability**: **Discovered Apps** provides application inventory by detecting installed programs from:

- Programs and Features (Control Panel uninstall registry)
- Microsoft Store apps
- Win32 apps deployed via Intune Management Extension
- macOS applications (for macOS devices)

**Discovered Apps data includes**:

- Application name
- Application version
- Publisher (where available)
- Device count (aggregate tenant-wide view)
- Per-device installation status
- 7-day refresh cycle (24 hours for Win32 apps deployed via Intune)

**Limitations**:

- No file metadata collection (file size, creation date, etc.)
- No custom file collection rules (cannot specify "collect all .dll files matching pattern X")
- No executable header details
- Detection limited to installed programs (not arbitrary file presence)

**Parity Assessment**: **Partial**. Intune Discovered Apps covers basic "what applications are installed" scenarios but lacks SCCM's granular file inventory capabilities.

**Use Case Impact**:

- **Security compliance scanning** (e.g., "identify all devices with vulnerable DLL version X"): Requires custom detection scripts via Proactive Remediations
- **File deployment verification** (e.g., "confirm configuration file Y exists on all devices"): No Intune equivalent; use custom compliance policies with PowerShell detection scripts
- **Software categorization**: No Asset Intelligence equivalent; manual categorization required after Data Warehouse export

**Workaround**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```powershell
# Proactive Remediation Detection Script Example
# Collects custom software inventory and uploads to Log Analytics

$WorkspaceId = "your-workspace-id"
$SharedKey = "your-shared-key"
$LogType = "CustomSoftwareInventory"

# Collect custom file data
$FileData = Get-ChildItem "C:\Program Files\" -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue |
    Select-Object FullName, Name, @{N='Version';E={$_.VersionInfo.FileVersion}},
                  @{N='Product';E={$_.VersionInfo.ProductName}}, Length, CreationTime

# Convert to JSON and upload to Log Analytics
$Json = $FileData | ConvertTo-Json -Depth 10
# Use Log Analytics Data Collector API to upload (requires function not shown)
```

**Sources**:

- [Discovered Apps - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/apps/app-discovered-apps)
- [Discovered Apps - The Intune Software Inventory - Patch Tuesday](https://patchtuesday.com/blog/tech-blog/intune-software-inventory/)
- [The Facts on ConfigMgr Software Inventory - Recast](https://www.recastsoftware.com/resources/sccm-software-inventory/)

#### 2.2 Hardware Inventory Refresh Cycles

**SCCM Capability**: Configurable hardware inventory cycles via client settings:

- **Simple Schedule**: Daily, weekly, or custom (e.g., every 6 hours)
- **Custom Schedule**: Granular control (e.g., "every Tuesday at 2 AM")
- **Delta Inventory**: Only changed classes/properties send to site server (reduces network traffic)
- **Full Inventory**: Complete resend every 7 cycles (default)
- **Immediate Trigger**: Manual hardware inventory cycle via client notification

**Intune Capability**:

- **Device properties**: 7-day automatic refresh
- **Discovered Apps**: 7-day automatic refresh (24 hours for Win32 apps deployed via Intune Management Extension)
- **Properties Catalog**: 24-hour refresh after initial collection
- **Manual Sync**: Device Actions > Sync forces immediate check-in (retrieves all policies and updates device state, but doesn't force immediate inventory collection)

**Limitation**: No configurable inventory schedules. Organizations cannot adjust refresh frequency based on business requirements.

**Parity Assessment**: **Partial**. Fixed cycles are adequate for most scenarios but lack the flexibility SCCM provides for high-change environments or specific compliance requirements.

**Migration Considerations**:

- Identify SCCM inventory schedules more aggressive than 24 hours (e.g., hourly compliance checks)
- Evaluate whether 7-day/24-hour cycles meet compliance reporting requirements
- For real-time inventory needs, consider MDE advanced hunting (if MDE P2 licensed) or custom Proactive Remediation scripts

**Sources**:

- [ConfigMgr Inventory Cycle Recommendations - Recast](https://www.recastsoftware.com/resources/configuration-manager-inventory-cycle-recommendations/)

#### 2.3 Inventory Reporting

**SCCM Capability**: Configuration Manager includes 50+ inventory-specific reports via SQL Server Reporting Services (SSRS):

- Hardware inventory by device collection
- Computers by processor, RAM, disk capacity
- Software inventory by file name, version, publisher
- Asset Intelligence software categorization reports
- License compliance and reconciliation
- Custom reports via Report Builder (drag-drop SQL query designer)

**Intune Capability**: Built-in reports cover basic inventory scenarios:

- **Device compliance reports**: Shows device compliance state with filters
- **Device inventory reports**: Device list with OS version, manufacturer, model, storage
- **Discovered apps reports**: Application name, version, device count (aggregate and per-device views)
- **Export to CSV**: All reports support export for offline analysis

**Custom Reporting Options**:

1. **Intune Data Warehouse** (OData v4 feed):
   - ~50 entities covering devices, users, apps, compliance
   - Access via Power BI OData connector, Excel Power Query, or RESTful API
   - 30-day historical data retention (as of February 2026 infrastructure update)
   - Free access (included in Intune Plan 1); Power BI Pro required for sharing ($10/user/month)

2. **Microsoft Graph API**:
   - Comprehensive programmatic access to all Intune data
   - Requires Azure AD app registration and OAuth 2.0 authentication
   - Suitable for custom dashboards, automation scripts

3. **Azure Log Analytics**:
   - Configure diagnostic settings to send Intune logs to Log Analytics workspace
   - Write KQL queries for advanced analytics
   - Create Azure Monitor Workbooks for interactive dashboards
   - Requires Azure subscription (~$2.30/GB ingestion for first 5GB/month)

**Parity Assessment**: **Partial**. Built-in reports adequate for operational use. Custom reporting requires Power BI skills or Graph API development (no GUI authoring equivalent to SSRS Report Builder).

**Gap Impact**: Organizations with 20+ custom SCCM inventory reports must:

- Recreate reports in Power BI (requires BI skills investment)
- Use community-shared Power BI templates (GitHub, tech blogs)
- Engage Microsoft Partners for custom report development
- Accept Intune built-in reports for most scenarios

**Workaround**: Use Graph API with PowerShell for simple custom reports:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```powershell
# Example: Export device inventory to CSV via Graph API
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
$Devices = Get-MgDeviceManagementManagedDevice -All
$Devices | Select-Object DeviceName, Manufacturer, Model, OperatingSystem,
                         TotalStorageSpaceInBytes, FreeStorageSpaceInBytes,
                         LastSyncDateTime |
           Export-Csv -Path "IntuneDeviceInventory.csv" -NoTypeInformation
```

**Sources**:

- [Introduction to reporting - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/introduction-to-reporting)
- [Microsoft Intune Reports](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)
- [Intune Data Warehouse API](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-nav-intune-data-warehouse)
- [Connect to the Data Warehouse With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-get-a-link-powerbi)

---

### 3. Significant Gaps / No Equivalent

#### 3.1 Custom Hardware Inventory (MOF Extensions)

**SCCM Capability**: Configuration Manager supports full WMI schema extensibility through `configuration.mof` editing:

- Import existing WMI classes from the WMI repository (`Win32_*`, custom classes)
- Create new custom WMI classes (e.g., `Custom_SecurityCompliance`)
- Add properties to existing classes
- Inventory custom registry keys by creating WMI class wrappers
- Configure delta vs. full inventory cycles per class
- Changes compile automatically when `configuration.mof` modified
- Custom classes survive Current Branch upgrades when added to designated extension section

**Common Use Cases**:

- Track BIOS passwords set/unset status (custom BIOS WMI query)
- Inventory third-party security agent versions (registry key collection)
- Collect specialized hardware attributes (e.g., RAID controller firmware versions)
- Custom compliance data (e.g., specific Group Policy registry settings)

**Example configuration.mof addition**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```mof
#pragma namespace ("\\\\.\\root\\cimv2")
#pragma deleteclass("Custom_BIOSPassword", NOFAIL)

[UNION, ViewSources{"SELECT * FROM Custom_BIOSPassword"},
ViewSpaces{"\\\\.\\root\\cimv2"}, dynamic, Provider("MS_VIEW_INSTANCE_PROVIDER")]
class Custom_BIOSPassword
{
    [PropertySources{"PasswordStatus"}]
    String PasswordStatus;
};
```

**Intune Capability**: The **Properties Catalog** (December 2024 release) provides limited extensibility:

- 97 pre-defined properties across 10 categories (CPU, BIOS, Battery, TPM, Video Controller, Disk, Memory, Network Adapter, Windows QFE, Other)
- Policy-based selection: Create Properties Catalog profile, select desired categories
- Data collection via Microsoft Device Inventory Agent (Windows service)
- 24-hour refresh cycle after initial deployment
- Data viewable in **Resource Explorer** per device (Devices > [Device Name] > Hardware)
- **Microsoft Graph API** access for programmatic retrieval

**Limitations**:

- **No custom WMI class creation**: Limited to Microsoft-defined property categories only
- **Category-level selection only**: Cannot selectively collect individual properties within a category (all-or-nothing)
- **No registry key inventory**: Cannot create custom properties from registry values
- **Device-level viewing only**: No aggregate reports (must query Graph API or use Data Warehouse)
- **No dynamic group support**: Cannot create dynamic groups based on Properties Catalog data (as of February 2026)
- **Platform support**: Windows 10/11 only (no cross-platform support as of February 2026)
- **Enrollment type restriction**: Corporate-owned, Entra Joined or Hybrid Joined devices only (no BYOD)

**Parity Assessment**: **Significant Gap**. Organizations with custom hardware inventory requirements (custom BIOS tracking, specialized hardware attributes, security compliance data from registry keys) cannot replicate SCCM functionality in Intune without alternative tooling.

**Gap Impact Examples**:

| SCCM Scenario                                       | Intune Limitation                                                                       |
| --------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Track BIOS password set status via custom WMI query | Properties Catalog includes BIOS version but not password status; no custom WMI queries |
| Inventory third-party antivirus registry version    | Properties Catalog cannot read registry keys; requires Proactive Remediation script     |
| Collect RAID controller firmware versions           | Not in 97 pre-defined properties; no custom property creation                           |
| Track Group Policy registry compliance              | No registry inventory; use Custom Compliance JSON + PowerShell detection script         |

**Workarounds**:

1. **Proactive Remediations with Log Analytics Custom Logs**:
   - Create detection script to collect custom inventory data
   - Upload JSON to Azure Log Analytics Custom Logs API
   - Query with KQL in Log Analytics workspace
   - Cost: ~$2.30/GB ingestion (first 5GB/month)

2. **Custom Compliance Policies (JSON + PowerShell)**:
   - Define custom compliance rules with PowerShell detection scripts
   - Results viewable in device compliance reports
   - Limitation: Binary compliant/non-compliant only (no inventory value storage)

3. **Retain SCCM Co-Management Workload**:
   - Keep **Resource Access** workload in SCCM (includes inventory)
   - Continue using SCCM hardware inventory with MOF extensions
   - Trade-off: Maintain SCCM infrastructure for inventory only

4. **Third-Party Inventory Solutions**:
   - ServiceNow Discovery
   - Snow Inventory
   - Lansweeper
   - Trade-off: Additional licensing cost

**Example Proactive Remediation Script**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```powershell
# Detection script: Collect custom hardware inventory
$CustomData = @{
    ComputerName = $env:COMPUTERNAME
    BIOSPasswordSet = (Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings).PasswordState
    RAIDFirmware = (Get-WmiObject -Class Win32_SCSIController | Where-Object {$_.Name -like "*RAID*"}).DriverVersion
    AntivirusVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Vendor\Antivirus" -ErrorAction SilentlyContinue).Version
    CollectionTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
}

# Upload to Log Analytics Custom Logs API
$WorkspaceId = "your-workspace-id"
$SharedKey = "your-shared-key"
$LogType = "CustomHardwareInventory"

$Json = $CustomData | ConvertTo-Json -Compress
# Use Log Analytics Data Collector API function (requires additional code)
```

**Sources**:

- [Extend hardware inventory - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/inventory/extend-hardware-inventory)
- [Creating Custom Hardware Inventory Tips - Recast](https://www.recastsoftware.com/resources/creating-custom-hardware-inventory-tips/)
- [How to enable Intune enhanced hardware inventory - System Center Dudes](https://www.systemcenterdudes.com/how-to-enable-intune-enhanced-hardware-inventory/)
- [Enhanced Device Inventory | Resource Explorer | Intune - Call4Cloud](https://call4cloud.nl/enhanced-device-inventory-resource-explorer/)

#### 3.2 Software Metering (Usage Tracking)

**SCCM Capability**: Configuration Manager **Software Metering** tracks application usage for license optimization:

- **Usage Metrics Collected**:
  - Application launch count
  - Total active usage duration (minutes/hours)
  - Last used timestamp
  - User who launched application
  - Idle time vs. productive time
  - Concurrent usage (how many users running application simultaneously)
- **Automatic Rule Generation**: Create metering rules from recent inventory data (e.g., "meter all instances of Adobe Acrobat detected in last 30 days")
- **Manual Rule Creation**: Specify file name, file version, language, original file name
- **7-Day Default Reporting Interval** (configurable via client settings)
- **Built-In Reports** (15+ reports):
  - All metered software programs
  - Computers with specific metered program installed
  - Computers with specific metered program run (shows usage)
  - Concurrent usage for metered software (license compliance)
  - Summary of software metering usage

**Use Cases**:

- **License optimization**: Identify underutilized software (e.g., "Adobe Creative Suite used by only 20% of licensed users")
- **License compliance**: Verify concurrent usage doesn't exceed purchased licenses
- **Software rationalization**: Identify redundant applications (e.g., "3 PDF readers installed, only 1 used")
- **Cost savings**: Reclaim unused licenses or negotiate volume license reductions

**Intune Capability**: **No Equivalent**. Intune provides no usage tracking, launch frequency, or duration metrics.

**Parity Assessment**: **No Equivalent**. License optimization workflows dependent on usage tracking cannot migrate to Intune.

**Gap Impact**:

- Organizations using software metering for SAM (Software Asset Management) lose this capability entirely
- License compliance reporting (concurrent usage) requires third-party solutions
- Cost optimization initiatives dependent on usage data cannot continue

**Workarounds**:

1. **Microsoft 365 Apps Usage Analytics** (for M365 apps only):
   - Microsoft 365 Apps admin center provides usage reports for Office applications
   - Shows active users, application usage trends, deployment status
   - Free (included with M365 licensing)
   - **Limitation**: M365 apps only (no third-party application tracking)

2. **Azure Monitor Application Insights**:
   - Instrument custom applications with Application Insights SDK
   - Track custom telemetry (usage, performance, exceptions)
   - Requires code changes (not suitable for third-party applications)
   - Cost: Consumption-based pricing

3. **Third-Party SAM Tools**:
   - **Flexera FlexNet Manager**: Comprehensive SAM platform with usage tracking
   - **Snow License Manager**: Software metering and license optimization
   - **Lansweeper**: Asset management with software usage tracking
   - **Trade-off**: Additional licensing cost (typically $2-5/device/year)

4. **Retain SCCM Co-Management Workload**:
   - Keep **Resource Access** workload in SCCM for software metering
   - Continue using SCCM software metering reports
   - Trade-off: Maintain SCCM infrastructure

**Sources**:

- [SCCM software metering reports to help licencing costs - System Center Dudes](https://www.systemcenterdudes.com/sccm-software-metering-reports/)
- [Software Metering For Microsoft Edge Using SCCM - Prajwal Desai](https://www.prajwaldesai.com/software-metering-for-microsoft-edge-using-sccm/)

#### 3.3 Asset Intelligence

**SCCM Capability**: Configuration Manager **Asset Intelligence** provides software cataloging and license management:

- **Microsoft Asset Intelligence Catalog Synchronization**: Downloads categorization data from Microsoft (60,000+ software titles)
- **Software Categorization**: Assigns software families and categories (e.g., "Microsoft Office" → "Productivity Software")
- **License Management**:
  - Reconcile purchased licenses vs. detected installations
  - Track license compliance (over/under licensed)
  - Integration with Microsoft Volume Licensing Service Center (MVLS) for automatic import
- **Uncategorized Software Requests**: Submit unknown software to Microsoft for categorization
- **Custom Software Labels**: Create custom categories for line-of-business applications
- **Built-In Reports** (20+ reports):
  - Software 01A - Summary of metered software in a specific collection
  - Software 02A - Software families
  - Software 03A - Software categories in a specific software family
  - License 01A - Microsoft Volume License ledger
  - License 03A - Count of licenses and computers

**Use Cases**:

- **License compliance reporting**: Generate reports for audits showing purchased vs. installed licenses
- **Software portfolio rationalization**: Identify all productivity software, security software, etc., across the organization
- **Budget planning**: Forecast license renewal costs based on detected installations
- **Audit preparation**: Quickly generate license reconciliation reports for vendor audits

**Intune Capability**: **No Equivalent**. Intune provides no software cataloging, categorization, or license management features.

**Parity Assessment**: **No Equivalent**. Organizations using Asset Intelligence for license compliance reporting and software categorization must implement alternative SAM processes.

**Gap Impact**:

- License compliance workflows (especially for vendor audits) must move to third-party SAM tools
- Software portfolio visibility (categorization by family/category) requires manual Excel-based categorization
- Volume license reconciliation cannot be automated

**Workarounds**:

1. **Manual Categorization After Data Warehouse Export**:
   - Export Discovered Apps via Intune Data Warehouse or Graph API
   - Import to Excel or Power BI
   - Manually categorize applications (create custom Power BI dimension table)
   - Trade-off: Manual effort, no Microsoft catalog sync

2. **Third-Party SAM Tools** (same as Software Metering workaround):
   - Flexera, Snow, Lansweeper
   - Provide software categorization, license management, compliance reporting

3. **Microsoft 365 Apps Admin Center** (for M365 only):
   - Deployment insights, usage reporting for M365 apps
   - No license reconciliation (assumes subscription licensing)

**Sources**:

- [How To Configure Asset Intelligence In Configuration Manager - Prajwal Desai](https://www.prajwaldesai.com/how-to-configure-asset-intelligence-in-configuration-manager/)
- [SCCM ConfigMgr Asset Intelligence Reports - Anoop Nair](https://www.anoopcnair.com/configmgr-asset-intelligence-reports-sccm/)

---

### 4. Intune Advantages

#### 4.1 Cloud-Native Inventory with Graph API Access

**Advantage**: Intune's cloud-native architecture provides modern API access to all inventory data via Microsoft Graph:

- **RESTful API**: Programmatic access to devices, apps, compliance, configurations
- **Granular Permissions**: OAuth 2.0 with scoped permissions (e.g., `DeviceManagementManagedDevices.Read.All`)
- **Webhook Support**: Subscribe to change notifications for real-time inventory updates
- **Cross-Platform SDKs**: PowerShell, Python, .NET, Java, JavaScript
- **No VPN Required**: Access from anywhere (vs. SCCM SQL Server on-premises access)

**Example**: Automate inventory exports for third-party ITSM integration:

```powershell
# Graph API PowerShell SDK example
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
$Devices = Get-MgDeviceManagementManagedDevice -All -Property "DeviceName,Manufacturer,Model,SerialNumber,OperatingSystem,ComplianceState"
$Devices | Export-Csv -Path "ServiceNowImport.csv" -NoTypeInformation
```

**Sources**:

- [Microsoft Graph API - Intune Documentation](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)

#### 4.2 Entra ID Integration

**Advantage**: Intune device inventory natively integrates with Entra ID (Azure AD):

- **Single Identity Plane**: Devices, users, groups managed in unified directory
- **Dynamic Group Membership**: Create device groups based on inventory attributes (e.g., "All Windows 11 devices with TPM 2.0")
- **Conditional Access Integration**: Use device attributes (OS version, compliance state, manufacturer) in access policies
- **Primary User Assignment**: Automatic based on Entra ID sign-in data (no manual resource affinity)

**Requirement**: Entra ID P1 (included in M365 E3/E5) for dynamic groups.

**Sources**:

- [Categorize devices into groups in Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-group-mapping)
- [What are Microsoft Entra registered devices?](https://docs.azure.cn/en-us/entra/identity/devices/concept-device-registration)

#### 4.3 Zero Infrastructure Maintenance

**Advantage**: Intune inventory operates as a cloud service with no on-premises infrastructure:

- No SQL Server database maintenance (backups, index optimization, capacity planning)
- No site server hardware/OS patching
- No WMI repository troubleshooting on clients
- Automatic scalability (no performance tuning required)
- 99.9% SLA (cloud high availability)

**Trade-off**: Fixed 7-day/24-hour refresh cycles (cannot optimize for performance like SCCM).

---

## Licensing Impact

| Feature                                     | Minimum License    | Included In                                         | Notes                                                                           |
| ------------------------------------------- | ------------------ | --------------------------------------------------- | ------------------------------------------------------------------------------- |
| **Standard Device Properties**              | Intune Plan 1      | M365 E3, E5, F3, Business Premium                   | Base hardware/software inventory                                                |
| **Discovered Apps**                         | Intune Plan 1      | M365 E3, E5, F3, Business Premium                   | Application inventory                                                           |
| **Properties Catalog (97 properties)**      | Intune Plan 1      | M365 E3, E5, F3, Business Premium                   | Extended hardware inventory (no additional cost)                                |
| **Intune Data Warehouse (OData)**           | Intune Plan 1      | M365 E3, E5, F3, Business Premium                   | Free access (Power BI licensing separate)                                       |
| **Microsoft Graph API**                     | Intune Plan 1      | M365 E3, E5, F3, Business Premium                   | Programmatic inventory access                                                   |
| **Proactive Remediations (custom scripts)** | Endpoint Analytics | M365 E3, E5, A3, A5, Windows 10/11 Enterprise E3/E5 | Required for custom inventory workaround                                        |
| **Azure Log Analytics (custom logs)**       | Azure subscription | Pay-as-you-go                                       | ~$2.30/GB ingestion (first 5GB/month); required for custom inventory workaround |
| **Power BI Pro**                            | Standalone         | $10/user/month                                      | Required to share custom Power BI reports from Data Warehouse                   |
| **Dynamic Groups (Entra ID)**               | Entra ID P1        | M365 E3, E5, EMS E3/E5                              | Required for inventory-based dynamic device groups                              |

**Key Takeaway**: All core Intune inventory features included in Intune Plan 1 (bundled with M365 E3). Organizations needing custom inventory collection must budget for Azure Log Analytics consumption (~$2.30/GB). Custom reporting with Power BI requires Power BI Pro licenses for report consumers.

**See**: **Licensing Impact Register** for consolidated licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Inventory Assessment

**Action Items** (complete before migration):

1. **Inventory SCCM Custom WMI Classes**:
   - Review `configuration.mof` for all custom class additions
   - Document business purpose of each custom class (compliance requirement, security tracking, etc.)
   - Categorize as "available in Properties Catalog" vs. "requires custom workaround" vs. "accept data loss"

2. **Audit Software Metering Usage**:
   - Identify applications with active metering rules
   - Document business processes dependent on usage data (license optimization, compliance reporting, cost allocation)
   - Evaluate third-party SAM tool requirements or accept capability loss

3. **Asset Intelligence Dependency Check**:
   - Review Asset Intelligence reports in use (especially for audit preparation)
   - Identify license reconciliation processes
   - Plan third-party SAM tool procurement or manual Excel-based tracking

4. **Inventory Report Inventory** (meta-inventory):
   - Export list of all custom SCCM inventory reports
   - Categorize as "Intune built-in replacement available" vs. "requires Power BI recreation" vs. "no longer needed"
   - Estimate Power BI development effort or budget for partner engagement

### Migration Strategies

#### Strategy 1: Intune-Only with Workarounds (Cloud-First)

**Profile**: Organizations with standard inventory requirements, low custom hardware inventory dependency, no software metering usage.

**Approach**:

- Deploy Properties Catalog policies to collect extended hardware properties
- Use Intune built-in reports for device/app inventory
- Implement Proactive Remediations for critical custom inventory (upload to Log Analytics)
- Accept no software metering (or procure third-party SAM tool if required)
- Recreate top 5-10 critical SCCM reports in Power BI using Data Warehouse

**Effort**: Medium (Power BI report development, Proactive Remediation scripting for custom inventory)

**Cost**: Power BI Pro licenses + Azure Log Analytics consumption (if custom inventory required)

#### Strategy 2: Co-Management Hybrid (Retain SCCM Inventory)

**Profile**: Organizations with heavy custom hardware inventory (10+ custom WMI classes), active software metering, Asset Intelligence dependency.

**Approach**:

- Enable co-management with **Resource Access** workload remaining in SCCM
- Continue using SCCM for hardware inventory (MOF extensions), software inventory, software metering, Asset Intelligence
- Use Intune for all other workloads (apps, updates, compliance, endpoint protection)
- Plan SCCM infrastructure retention for 3-5 years (inventory-only use case)

**Effort**: Low (no migration required for inventory)

**Cost**: Maintain SCCM infrastructure (SQL Server, site server, licensing)

**Trade-off**: Delays full cloud transition, but preserves critical inventory capabilities.

#### Strategy 3: Third-Party SAM Tool Integration (Replace SCCM Inventory)

**Profile**: Organizations with software metering and Asset Intelligence requirements but willing to invest in modern SAM platform.

**Approach**:

- Procure third-party SAM tool (Flexera, Snow, Lansweeper)
- Deploy SAM agent to all devices (Intune Win32 app deployment)
- Use SAM tool for custom inventory, software metering, license management
- Use Intune for standard device/app inventory
- Decommission SCCM inventory entirely

**Effort**: High (SAM tool selection, procurement, deployment, integration)

**Cost**: SAM tool licensing (~$2-5/device/year) + implementation services

**Benefit**: Modern SAM platform with capabilities exceeding SCCM (cloud SaaS, software license optimization AI, automated license harvesting)

### Phased Rollout Plan

**Phase 1: Validate (Pilot Group - 100 devices)**

- Deploy Properties Catalog policies
- Test Discovered Apps accuracy
- Validate custom Proactive Remediation scripts (if used)
- Verify dynamic group creation based on inventory attributes
- Confirm reporting via Data Warehouse or Graph API

**Phase 2: Scale (Production Rings)**

- Ring 1 (10% devices): Monitor Properties Catalog data collection, identify missing properties
- Ring 2 (50% devices): Deploy custom inventory scripts (if required), refine based on Ring 1 feedback
- Ring 3 (100% devices): Full rollout after 30-day soak in Ring 2

**Phase 3: Decommission SCCM Inventory** (if not using co-management)

- Verify all required inventory data available in Intune/Log Analytics/SAM tool
- Archive SCCM inventory database (SQL backup) for historical reference
- Disable SCCM hardware/software inventory client agent settings
- Decommission SCCM infrastructure after 90-day validation period

### Common Pitfalls to Avoid

1. **Assuming Properties Catalog = MOF Extensibility**: Properties Catalog is limited to 97 pre-defined properties (no custom WMI classes). Test thoroughly before decommissioning SCCM.

2. **Underestimating Custom Reporting Effort**: Power BI report development requires BI skills. Budget for training or partner engagement.

3. **Ignoring Software Metering Impact**: Organizations using software metering for cost optimization must plan third-party SAM tool procurement or accept capability loss.

4. **Overlooking Refresh Cycle Changes**: 7-day/24-hour cycles may not meet real-time compliance requirements. Evaluate MDE advanced hunting or custom scripts for time-sensitive data.

5. **Neglecting Azure Log Analytics Costs**: Custom inventory collection via Proactive Remediations can generate significant Log Analytics ingestion costs. Estimate volume and budget accordingly.

---

## Sources

### Microsoft Official Documentation

- [Collect device hardware info with the properties catalog - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/configuration/properties-catalog)
- [View device details with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/device-inventory)
- [Discovered Apps - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/apps/app-discovered-apps)
- [Extend hardware inventory - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/clients/manage/inventory/extend-hardware-inventory)
- [Configure discovery methods for Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/deploy/configure/configure-discovery-methods)
- [Categorize devices into groups in Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-group-mapping)
- [What are Microsoft Entra registered devices?](https://docs.azure.cn/en-us/entra/identity/devices/concept-device-registration)
- [Introduction to reporting - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/introduction-to-reporting)
- [Microsoft Intune Reports](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)
- [Intune Data Warehouse API](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-nav-intune-data-warehouse)
- [Connect to the Data Warehouse With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-get-a-link-powerbi)
- [Microsoft Graph API - Intune Documentation](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)

### Community and Expert Sources

- [How Intune's New Properties Catalog Improves Inventory Management - Recast](https://www.recastsoftware.com/resources/intunes-new-properties-catalog-and-inventory-management/)
- [How to Enable Device Hardware Inventory with Microsoft Intune - Recast](https://www.recastsoftware.com/resources/enable-device-hardware-inventory-with-intune/)
- [Enhanced Device Inventory | Resource Explorer | Intune - Call4Cloud](https://call4cloud.nl/enhanced-device-inventory-resource-explorer/)
- [How to enable Intune enhanced hardware inventory - System Center Dudes](https://www.systemcenterdudes.com/how-to-enable-intune-enhanced-hardware-inventory/)
- [Enhanced hardware inventory in Intune coming in December - Microsoft Tech Community](https://techcommunity.microsoft.com/blog/microsoftintuneblog/enhanced-hardware-inventory-in-intune-coming-in-december/4303744)
- [Discovered Apps - The Intune Software Inventory - Patch Tuesday](https://patchtuesday.com/blog/tech-blog/intune-software-inventory/)
- [The Facts on ConfigMgr Software Inventory - Recast](https://www.recastsoftware.com/resources/sccm-software-inventory/)
- [ConfigMgr Inventory Cycle Recommendations - Recast](https://www.recastsoftware.com/resources/configuration-manager-inventory-cycle-recommendations/)
- [Creating Custom Hardware Inventory Tips - Recast](https://www.recastsoftware.com/resources/creating-custom-hardware-inventory-tips/)
- [SCCM software metering reports to help licencing costs - System Center Dudes](https://www.systemcenterdudes.com/sccm-software-metering-reports/)
- [Software Metering For Microsoft Edge Using SCCM - Prajwal Desai](https://www.prajwaldesai.com/software-metering-for-microsoft-edge-using-sccm/)
- [How To Configure Asset Intelligence In Configuration Manager - Prajwal Desai](https://www.prajwaldesai.com/how-to-configure-asset-intelligence-in-configuration-manager/)
- [SCCM ConfigMgr Asset Intelligence Reports - Anoop Nair](https://www.anoopcnair.com/configmgr-asset-intelligence-reports-sccm/)

---

**End of Assessment**
