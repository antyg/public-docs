# Scripting, Automation & Extensibility — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Near Parity to Intune Advantage

---

## Executive Summary

The scripting, automation, and extensibility capabilities in Intune achieve **Near Parity to Intune Advantage** compared to SCCM, with Microsoft Graph API representing a significant upgrade over WMI/SMS Provider. Platform Scripts and Proactive Remediations (renamed to "Remediations" in 2026) provide equivalent functionality to SCCM's Run Scripts feature with **Near Parity**, while custom compliance scripting achieves **Full Parity**. The primary gap is CMPivot's real-time ad-hoc query capability, which has **Partial** coverage through scheduled Remediations, Graph API queries, and Microsoft Defender for Endpoint Advanced Hunting (for E5 customers). However, Intune's configuration-as-code capabilities via Graph API, IntuneCD, and Microsoft365DSC represent an **Intune Advantage** that far exceeds SCCM's scriptable automation model. Organizations gain a modern REST API, cross-platform SDKs, webhooks for event-driven automation, and comprehensive CI/CD integration capabilities.

---

## Feature Parity Matrix

| SCCM Feature                                                                                       | Intune Equivalent                                                                     | Parity Rating                      | Licensing                                                           | Notes                                                                                                                                                                                                                                   |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CMPivot** (real-time WQL queries, built-in entities, ad-hoc investigation)                       | Remediations (scheduled detection scripts) + Graph API queries + MDE Advanced Hunting | **Partial**                        | Intune Plan 1 (Remediations); MDE P2 for Advanced Hunting (M365 E5) | CMPivot provides real-time ad-hoc queries. Remediations run on schedule. Graph API queries tenant-level data (not per-device real-time). MDE Advanced Hunting provides KQL queries for security scenarios.      |
| **Run Scripts** (PowerShell execution, collection targeting, approval workflow, output monitoring) | Platform Scripts + Remediations                                                       | **Near Parity**                    | Intune Plan 1+                                                      | Platform scripts deploy PowerShell/shell to devices. Remediations provide detection+remediation pairs. No built-in approval workflow (use external change management). Output captured in Intune console.       |
| **ConfigMgr PowerShell cmdlets** (900+ cmdlets in ConfigurationManager module)                     | Microsoft.Graph PowerShell SDK                                                        | **Near Parity**                    | Intune Plan 1+                                                      | Graph PowerShell SDK provides comprehensive automation. Different cmdlet structure (REST-oriented) but equivalent functionality for most scenarios. Learning curve for OAuth and Graph API concepts.            |
| **WMI/SMS Provider** (programmatic access via WQL queries, 700+ classes)                           | Microsoft Graph REST API                                                              | **Intune Advantage**               | Intune Plan 1+                                                      | Graph API is modern REST API with superior documentation, cross-platform support, webhooks, batching, and unified access to Intune+Entra ID+M365 services. Far exceeds WMI capabilities.                        |
| **AdminService REST API** (OData v4 endpoint for ConfigMgr automation)                             | Microsoft Graph REST API                                                              | **Full Parity**                    | Intune Plan 1+                                                      | Graph API is the cloud-native equivalent. AdminService was ConfigMgr's REST modernization; Graph is far more mature and comprehensive.                                                                          |
| **Task Sequence Variables** (OSD customization, dynamic deployment logic)                          | Autopilot provisioning packages + ESP settings + Platform scripts                     | **Partial** to **Significant Gap** | Intune Plan 1+ (Autopilot in M365 E3+)                              | Autopilot handles standard deployments but lacks task sequence flexibility. Use platform scripts for post-deployment customization. Complex OSD scenarios face capability regression.                           |
| **Custom Compliance CI Scripts** (detection + remediation PowerShell/VBScript)                     | Custom Compliance Scripts (JSON schema + PowerShell discovery)                        | **Full Parity**                    | Intune Plan 1+                                                      | Custom compliance in Intune uses JSON schema + PowerShell detection script. Equivalent functionality with different implementation (JSON output vs. Boolean return).                                            |
| **Configuration Items & Baselines** (scripted settings detection)                                  | Custom Compliance + Settings Catalog + Configuration Profiles                         | **Full Parity**                    | Intune Plan 1+                                                      | Settings Catalog (5000+ settings) covers built-in CI functionality. Custom compliance covers scripted detection scenarios.                                                                                      |
| **Management Insights** (proactive recommendations, rule evaluation)                               | Intune recommendations + Microsoft Secure Score                                       | **Near Parity**                    | Intune Plan 1+                                                      | Intune provides proactive recommendations dashboard. Secure Score provides security-focused guidance. Similar intent to Management Insights.                                                                    |
| **Community Hub**                                                                                  | N/A (deprecated in ConfigMgr 2023)                                                    | **N/A**                            | N/A                                                                 | Community Hub was deprecated. No direct Intune equivalent. Community sharing happens via GitHub, PowerShell Gallery, Intune community forums.                                                                   |
| **Configuration-as-Code**                                                                          | IntuneCD + Microsoft365DSC + IntuneBackupAndRestore + Graph API                       | **Intune Advantage**               | Intune Plan 1+                                                      | Graph API enables robust configuration-as-code workflows. IntuneCD (Python), Microsoft365DSC (PowerShell DSC), IntuneBackupAndRestore (PowerShell) provide declarative config management superior to ConfigMgr. |
| **Microsoft Graph Change Notifications** (webhooks for resource changes)                           | Native Graph API feature                                                              | **Intune Advantage**               | Intune Plan 1+                                                      | Webhooks for real-time event-driven automation (e.g., trigger Azure Function when policy changes). No SCCM equivalent. Enables modern event-driven architectures.                                               |
| **Intune Data Warehouse** (OData reporting feed)                                                   | Intune Data Warehouse + Graph API                                                     | **Full Parity**                    | Intune Plan 1+                                                      | OData feed for historical reporting (30-day retention as of Feb 2026 update). Graph API for real-time data. Power BI integration. Equivalent to ConfigMgr data warehouse views.                                 |
| **Status Message Queries** (troubleshooting via status messages)                                   | Audit logs + Graph API activity logs                                                  | **Full Parity**                    | Intune Plan 1+                                                      | Comprehensive audit logging via Graph API. Filter by user, resource type, action, date range. Export to Log Analytics for advanced KQL queries.                                                                 |
| **Client Settings** (device-level configuration via policy)                                        | Configuration profiles + Settings Catalog                                             | **Full Parity**                    | Intune Plan 1+                                                      | Settings Catalog provides equivalent granular control (5000+ settings across Windows, macOS, iOS, Android).                                                                                                     |

---

## Key Findings

### Full/Near Parity Areas

#### Platform Scripts + Remediations: Equivalent to Run Scripts

**SCCM Run Scripts** capabilities:

- PowerShell scripts stored in ConfigMgr console library
- Target collections for execution
- Optional peer approval workflow before execution
- Script parameters supported
- Output monitoring (view script results per device)
- On-demand execution or scheduled (via maintenance windows)

**Intune Platform Scripts**:

- **PowerShell scripts** (Windows) or **shell scripts** (macOS/Linux)
- Uploaded to Intune admin center (Devices > Scripts and remediations > Platform scripts)
- Target Entra ID groups (user or device groups)
- Run scripts in user context or system context
- Script output captured (standard output, error output, exit code)
- On-demand execution (assign to group → devices execute on next check-in, typically 8 hours, can be forced via Sync action)

**Intune Remediations** (formerly Proactive Remediations):

- **Detection script** + **Remediation script** pairs
- Scheduled execution (hourly, daily, weekly)
- Per-device execution with output monitoring
- Use case: Proactive issue detection and auto-fix (e.g., detect low disk space → remediate by cleaning temp files)

**Parity Rating**: **Near Parity**

**What Translates Directly**:

- Script storage and deployment ✓
- Collection/group targeting ✓
- Output monitoring ✓
- System/user context execution ✓

**What Requires Workarounds**:

1. **Approval Workflow**: SCCM supported peer approval (script author submits → approver reviews → execution allowed). Intune has no built-in approval workflow.

   **Workaround**: Implement external change management process:
   - Store scripts in Git repository (Azure DevOps, GitHub)
   - Use pull request approval workflow (author creates PR → peer reviews → merge approved)
   - Deploy approved scripts to Intune via Graph API or manual upload
   - Track approvals in Git commit history

2. **Script Parameters**: SCCM supported parameterized scripts (pass values at deployment time). Intune platform scripts do not support parameters.

   **Workaround**: Embed logic in script or use environment variables:

   > **Note**: The following is a conceptual example illustrating parameter workarounds. Adapt server names and ports for your environment.

   ```powershell
   # SCCM approach (parameterized)
   param([string]$ServerName, [int]$Port)
   Test-NetConnection -ComputerName $ServerName -Port $Port

   # Intune approach (embedded logic or env vars)
   $ServerName = "contoso.com"  # Hardcode or read from registry/env var
   $Port = 443
   Test-NetConnection -ComputerName $ServerName -Port $Port
   ```

3. **Immediate Execution**: SCCM Run Scripts executed immediately when triggered. Intune platform scripts execute on next device check-in (typically 8 hours for Windows, can force via Sync device action).

   **Workaround**: Use Intune Sync device action (Forces immediate check-in) or configure faster check-in interval (not recommended for battery-powered devices).

**Migration Path**: Migrate SCCM Run Scripts to Intune Platform Scripts 1:1. For detection+remediation scenarios, use Remediations instead (better suited for scheduled compliance checks).

#### Custom Compliance: Full Functional Equivalence

**SCCM Configuration Items** (custom settings):

- Detection script (PowerShell, VBScript, JScript) that returns Boolean or value
- Remediation script (optional, runs if non-compliant)
- Compliance rule (e.g., "value equals X" or "script returns true")
- Deployed via compliance baseline to collections

**Intune Custom Compliance**:

- Detection script (PowerShell for Windows, shell script for Linux/macOS) that outputs JSON
- JSON schema defines rules for evaluating detection script output
- Remediation handled separately via Remediations (not part of compliance policy)
- Deployed as compliance policy to groups

**Parity Rating**: **Full Parity**

**Example Comparison**:

**SCCM Configuration Item Detection Script**:

```powershell
# Returns Boolean (compliant = $true)
$MinFreeSpace = 10GB
$FreeSpace = (Get-PSDrive C).Free
if ($FreeSpace -ge $MinFreeSpace) {
    return $true  # Compliant
} else {
    return $false # Non-compliant
}
```

**Intune Custom Compliance Detection Script**:

```powershell
# Returns JSON with named values
$MinFreeSpace = 10GB
$FreeSpace = (Get-PSDrive C).Free
$hash = @{
    FreeSpaceGB = [math]::Round($FreeSpace / 1GB, 2)
    IsCompliant = ($FreeSpace -ge $MinFreeSpace)
}
return $hash | ConvertTo-Json -Compress
```

**Intune JSON Schema** (defines compliance rules):

```json
{
  "Rules": [
    {
      "SettingName": "FreeSpaceGB",
      "Operator": "GreaterEquals",
      "DataType": "Double",
      "Operand": 10,
      "MoreInfoUrl": "https://docs.contoso.com/disk-space-policy",
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "Insufficient disk space",
          "Description": "Drive C: has less than 10GB free space. Please clean up unnecessary files."
        }
      ]
    }
  ]
}
```

**Key Difference**: SCCM used Boolean return values; Intune uses JSON output with schema-based rule evaluation. The capability is equivalent, but the implementation model differs.

**Advantage of Intune Model**: JSON schema allows multiple settings in a single detection script with complex rule logic (AND/OR operators, nested rules). SCCM required separate CIs for each setting.

**Migration Path**: Rewrite SCCM CI detection scripts to output JSON instead of Boolean. Map SCCM compliance rules to Intune JSON schema rules. Test compliance evaluation before deploying to production.

#### ConfigMgr PowerShell vs. Graph PowerShell: Learning Curve with Equivalent Capability

**ConfigMgr PowerShell Module**:

- 900+ cmdlets in `ConfigurationManager` module
- On-premises connection to SMS Provider (requires line-of-sight to site server)
- Windows authentication (no explicit credential management needed if running as domain user)
- Cmdlet naming: `Get-CMDevice`, `New-CMCollection`, `Set-CMClientSetting`, `Invoke-CMReport`

**Microsoft.Graph PowerShell SDK**:

- Comprehensive cmdlet coverage across Graph API resources (1000+ cmdlets across multiple modules)
- Cloud-based connection via OAuth (requires app registration or delegated auth)
- Permission scopes (request specific permissions: `DeviceManagementManagedDevices.Read.All`, etc.)
- Cmdlet naming: `Get-MgDeviceManagementManagedDevice`, `New-MgDeviceManagementDeviceConfiguration`, `Update-MgDeviceManagementManagedDevice`

**Parity Rating**: **Near Parity**

**Authentication Comparison**:

**SCCM**:

```powershell
# Connect to ConfigMgr site
Import-Module ConfigurationManager
Set-Location "PS1:"  # Site code drive
# Windows auth automatically used
Get-CMDevice -Name "DEVICE01"
```

**Intune (Graph)**:

```powershell
# Connect to Graph API
Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
# OAuth authentication prompts for credentials or uses cached token
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'DEVICE01'"
```

**Common Automation Scenarios**:

| Scenario                     | SCCM Cmdlet                                           | Intune (Graph) Cmdlet                                                            |
| ---------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------- |
| Get device inventory         | `Get-CMDevice -Name "DEVICE01"`                       | `Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'DEVICE01'"`         |
| List all devices             | `Get-CMDevice`                                        | `Get-MgDeviceManagementManagedDevice -All`                                       |
| Get device compliance status | `Get-CMDeviceComplianceStatus -DeviceName "DEVICE01"` | `Get-MgDeviceManagementManagedDeviceCompliancePolicy -ManagedDeviceId $deviceId` |
| Restart device               | `Invoke-CMDeviceAction -DeviceId $id -Action Restart` | `Restart-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceId`             |
| Wipe device                  | `Invoke-CMDeviceAction -DeviceId $id -Action Wipe`    | `Clear-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceId`               |
| Create configuration policy  | `New-CMConfigurationItem`                             | `New-MgDeviceManagementDeviceConfiguration -BodyParameter $policyJson`           |
| Deploy application           | `New-CMApplicationDeployment`                         | `New-MgDeviceAppManagementMobileAppAssignment`                                   |

**Key Learning Curve Points**:

1. **OAuth Authentication**: Graph requires understanding OAuth flows (delegated auth for user context, app-only auth for service principal). SCCM used transparent Windows auth.

2. **Permission Scopes**: Graph uses granular permission scopes that must be requested explicitly. SCCM used role-based access control without explicit scope requests in scripts.

3. **REST-Oriented Naming**: Graph cmdlets reflect REST API resource paths (e.g., `Get-MgDeviceManagementManagedDevice` maps to `/deviceManagement/managedDevices`). SCCM cmdlets used shorter product-specific names.

4. **Filter Syntax**: Graph uses OData `$filter` queries (e.g., `deviceName eq 'DEVICE01'`) instead of PowerShell `-Filter` parameters with WQL-like syntax.

**Migration Strategy**:

- Invest in Graph API training (PowerShell SDK fundamentals, OAuth concepts, OData queries)
- Create cmdlet translation reference guide (SCCM cmdlet → Graph cmdlet mappings)
- Rewrite existing SCCM automation scripts to Graph PowerShell SDK
- Test scripts in non-production tenant before deploying to production

**Advantage of Graph SDK**: Cross-platform support (PowerShell 7+ runs on Windows, Linux, macOS), unified API across Intune+Entra ID+M365, comprehensive online documentation with examples in Microsoft Graph documentation.

### Partial Parity / Gaps

#### CMPivot: Real-Time Queries vs. Scheduled Remediations

**SCCM CMPivot** is a powerful real-time query tool for ad-hoc investigation and incident response:

**Capabilities**:

- **Real-time execution**: Query executes immediately against online devices in a collection via fast channel (same infrastructure as client notifications)
- **WQL-like syntax** with built-in entities: `Device`, `OS`, `LogicalDisk`, `Registry`, `File`, `Service`, `Process`, `EventLog`, etc.
- **Query operators**: `where`, `project`, `summarize`, `join`, `distinct`, `count`, `sort`
- **Standalone mode**: Query without targeting a collection (query all online devices)
- **Use cases**:
  - Incident response: "Find all devices with vulnerable DLL version"
  - Compliance checks: "Show all devices with BitLocker disabled"
  - Troubleshooting: "Which devices have less than 10GB free space?"
  - Security investigation: "Which devices have process X running?"

**Example CMPivot Queries**:

> **Note**: The following are conceptual examples illustrating CMPivot query syntax. Adapt entity names and filters for your environment.

```kusto
// Find devices with low disk space
Device
| where (Online == 1)
| project Device, LastLogonUser
| join (LogicalDisk | where (DriveType == 'Fixed') | where (FreeSpace < 10000))
| project Device, LastLogonUser, FreeSpace

// Find devices with specific registry key
Registry('HKLM:\\SOFTWARE\\Contoso\\Version')
| where Value == '2.0'
| project Device, Value

// Find running processes
Process
| where (Name == 'malware.exe')
| project Device, ProcessName, ExecutablePath
```

**Intune Alternatives** (none provide exact CMPivot parity):

**1. Remediations (formerly Proactive Remediations)**:

- **Detection scripts** run on schedule (hourly, daily, weekly) against assigned devices
- **Not real-time**: Scripts execute on defined schedule, not on-demand
- **Use case**: Proactive compliance monitoring and remediation (scheduled health checks, not ad-hoc investigation)

**Example Remediation (Low Disk Space Detection)**:

```powershell
# Detection script (runs on device, outputs JSON)
$MinFreeSpace = 10GB
$Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
$LowSpaceDrives = $Drives | Where-Object { $_.Free -lt $MinFreeSpace }

if ($LowSpaceDrives) {
    Write-Output "Non-compliant: Low disk space detected"
    exit 1  # Non-compliant (triggers remediation if configured)
} else {
    Write-Output "Compliant: Sufficient disk space"
    exit 0  # Compliant
}
```

**Limitation**: Runs on schedule (not on-demand), results visible in Intune console but require navigation per device (no aggregated query result view like CMPivot).

**2. Microsoft Graph API Queries**:

- Query tenant-level device data via Graph API
- **Not per-device real-time**: Queries return data synced to Intune service (last check-in data, typically 8 hours old)
- **Use case**: Tenant-wide device inventory queries, compliance reporting

**Example Graph API Query (PowerShell)**:

```powershell
# Find devices with low disk space (based on last reported inventory)
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
$Devices = Get-MgDeviceManagementManagedDevice -All
$LowSpaceDevices = $Devices | Where-Object { $_.freeStorageSpaceInBytes -lt 10GB }
$LowSpaceDevices | Select-Object deviceName, userPrincipalName, freeStorageSpaceInBytes
```

**Limitation**: Data is not real-time (reflects last device check-in). Cannot query live state like CMPivot.

**3. Microsoft Defender for Endpoint Advanced Hunting** (requires MDE Plan 2 / M365 E5):

- **KQL-based real-time queries** across security-related device data
- **Real-time capability**: Queries execute against MDE telemetry (process execution, file operations, registry changes, network connections)
- **Use case**: Security investigation, threat hunting, incident response
- **Limitation**: Security-focused data only (not general device inventory like disk space, installed software, etc.)

**Example MDE Advanced Hunting Query**:

```kusto
// Find devices with specific process running (last 7 days)
DeviceProcessEvents
| where Timestamp > ago(7d)
| where FileName == "malware.exe"
| project Timestamp, DeviceName, FileName, FolderPath, ProcessCommandLine
| summarize Count=count() by DeviceName
```

**Advantage**: Real-time security investigation. **Limitation**: Requires MDE P2 license (M365 E5 or standalone ~$5.20/user/month). Only security telemetry, not general device inventory.

**4. Azure Log Analytics + KQL Queries** (requires Azure subscription + Log Analytics workspace):

- Ingest Intune device data into Log Analytics workspace
- Query via KQL (Kusto Query Language) in Azure Monitor
- **Use case**: Historical trending, custom dashboards, cross-service queries (Intune + Defender + Entra ID)
- **Limitation**: Not real-time (data ingestion delay), additional cost (Log Analytics consumption charges)

**Parity Rating**: **Partial**

**CMPivot Capability Mapping**:

| CMPivot Use Case                               | Intune Alternative           | Parity Level | Notes                                                                   |
| ---------------------------------------------- | ---------------------------- | ------------ | ----------------------------------------------------------------------- |
| Real-time ad-hoc device queries                | Remediations (scheduled)     | Partial      | Scheduled execution, not real-time                                      |
| Security investigation (process/file/registry) | MDE Advanced Hunting         | Near Parity  | Real-time KQL queries but requires MDE P2 (E5 license)                  |
| Tenant-wide inventory queries                  | Graph API queries            | Full Parity  | Tenant-level data but not real-time per-device                          |
| Historical trending and dashboards             | Log Analytics + KQL          | Full Parity  | Historical analysis but not real-time ad-hoc                            |
| On-demand script execution for troubleshooting | Platform Scripts (on-demand) | Partial      | Can execute script on-demand but no aggregated result view like CMPivot |

**Migration Recommendation**:

1. **For routine compliance monitoring**: Migrate to **Remediations** with scheduled execution (e.g., daily disk space check, weekly software inventory).

2. **For security investigation**: Use **MDE Advanced Hunting** if M365 E5 licensed. Provides real-time security queries with KQL (superior to CMPivot for security scenarios).

3. **For tenant-wide inventory queries**: Use **Graph API queries** (PowerShell or REST API). Not real-time per-device but provides comprehensive tenant-level data.

4. **For ad-hoc troubleshooting**: Use **Platform Scripts** deployed to specific device (assign to single-device group, force sync, review output in Intune console). Less elegant than CMPivot but achieves similar outcome.

5. **For historical trending**: Ingest Intune data into **Azure Log Analytics**, create KQL queries and Azure Monitor Workbooks for dashboards (replaces SSRS reports with modern interactive dashboards).

**Workaround for Real-Time Queries** (interim solution until better Intune capability emerges):

- Create library of **Remediations** for common query scenarios (disk space, software version, registry keys, service status)
- Schedule daily execution
- Create Power BI dashboard connected to Remediation output (via Intune Data Warehouse or Graph API)
- For urgent ad-hoc queries, deploy **Platform Script** to specific device/group and force sync

**Bottom Line**: CMPivot's real-time ad-hoc query capability is the most significant functional gap in Intune scripting/automation. Organizations heavily reliant on CMPivot must adapt workflows to scheduled Remediations or invest in MDE P2 for security-focused Advanced Hunting.

#### Task Sequence Variables: OSD Flexibility Regression

**SCCM Task Sequences** provided infinite flexibility for OS deployment customization:

**Built-in Variables** (200+ variables):

- `_SMSTSMake`, `_SMSTSModel`, `_SMSTSAssetTag` (hardware detection)
- `OSDComputerName`, `OSDDomainName`, `OSDDomainOUName` (deployment settings)
- `OSDisk`, `OSDTargetSystemDrive` (disk configuration)
- Custom variables set via "Set Task Sequence Variable" step or collection variables

**PowerShell Access to Variables**:

> **Note**: The following is a conceptual example illustrating SCCM task sequence variable access patterns.

```powershell
# Inside task sequence step
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$model = $tsenv.Value("_SMSTSModel")
$computerName = $tsenv.Value("OSDComputerName")

# Conditional logic based on model
if ($model -like "*Surface*") {
    # Install Surface-specific drivers
}
```

**Dynamic Logic**:

- Conditional steps (run step if variable equals value)
- Variable-driven decisions (partition disk differently based on disk size variable)
- Multi-stage deployments (set variable in step 10, reference in step 50)

**Intune Autopilot + ESP**:

- **Windows Autopilot**: User-driven or self-deploying deployment profiles
- **Enrollment Status Page (ESP)**: Sequencing of app/policy deployment during provisioning
- **Provisioning Packages (PPKG)**: Static customization (pre-configured settings applied during OOBE)
- **Platform Scripts**: Post-deployment customization scripts

**No Native Variable System**: Autopilot has no equivalent to task sequence variables for dynamic deployment logic.

**Parity Rating**: **Partial** to **Significant Gap** (depends on OSD complexity)

**Capability Mapping**:

| SCCM OSD Capability                            | Intune Equivalent                               | Parity          | Notes                                                                           |
| ---------------------------------------------- | ----------------------------------------------- | --------------- | ------------------------------------------------------------------------------- |
| Standard Windows deployment                    | Autopilot user-driven                           | Full Parity     | Standard corporate image deployment works well                                  |
| Dynamic computer naming                        | Autopilot device name templates (limited)       | Partial         | Autopilot supports `%SERIAL%`, `%RAND:X%` in name template but not custom logic |
| Conditional driver installation                | Driver updates via Intune policy                | Partial         | Windows Update handles drivers automatically; less control than TS              |
| Custom partitioning                            | Fixed partition scheme (Windows default)        | Significant Gap | Cannot customize partition layout in Autopilot                                  |
| Multi-stage app installation with dependencies | Win32 app dependencies + ESP tracking           | Near Parity     | Dependencies and ESP sequencing provide similar chaining                        |
| BIOS/UEFI configuration                        | Platform scripts (post-deployment) or OEM tools | Partial         | Can configure via scripts but not during imaging                                |
| Variable-driven conditional logic              | Platform scripts with detection rules           | Partial         | Move logic to post-deployment scripts instead of TS variables                   |

**Workarounds for Common TS Variable Scenarios**:

**Scenario 1: Dynamic Computer Naming Based on Asset Tag**

**SCCM Task Sequence**:

> **Note**: The following is a conceptual example illustrating SCCM task sequence variable patterns.

```powershell
# Get asset tag and construct computer name
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$assetTag = $tsenv.Value("_SMSTSAssetTag")
$computerName = "WKS-$assetTag"
$tsenv.Value("OSDComputerName") = $computerName
```

**Intune Workaround**:

- **Autopilot device name template**: Use `%SERIAL%` placeholder (e.g., `WKS-%SERIAL%`)
- **Post-deployment rename script**: Deploy platform script that renames device based on logic, then restarts

```powershell
# Platform script (runs post-Autopilot)
$assetTag = (Get-WmiObject -Class Win32_SystemEnclosure).SMBIOSAssetTag
$computerName = "WKS-$assetTag"
Rename-Computer -NewName $computerName -Force -Restart
```

**Scenario 2: Conditional App Installation Based on Department**

**SCCM Task Sequence**:

> **Note**: The following is a conceptual example illustrating SCCM conditional logic patterns.

```powershell
# Set variable based on OU
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$ou = $tsenv.Value("OSDDomainOUName")
if ($ou -like "*Sales*") {
    $tsenv.Value("InstallSalesApp") = "True"
}
# Later step: Install app if variable = True
```

**Intune Workaround**:

- **Dynamic groups + app assignment**: Assign Sales app to Entra ID dynamic group "Sales Users" (department-based)
- **Device filters**: Apply filter on app assignment (e.g., only install if device property matches criteria)

**Scenario 3: Hardware-Specific Driver Installation**

**SCCM Task Sequence**:

> **Note**: The following is a conceptual example illustrating SCCM hardware-specific deployment patterns.

```powershell
# Conditional driver package based on model
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$model = $tsenv.Value("_SMSTSModel")
if ($model -eq "Surface Pro 9") {
    # Apply Surface Pro 9 driver package
}
```

**Intune Workaround**:

- **Windows Update automatic driver installation**: Windows Update handles drivers automatically during Autopilot (less control but minimal admin effort)
- **Device filters for driver deployment**: Create driver update policy with device filter targeting specific manufacturer/model

**Migration Recommendation**:

1. **Standard deployments**: Autopilot handles well with no modification needed.

2. **Complex OSD with extensive TS variables**: Consider **hybrid co-management approach** during transition (retain SCCM for OSD, use Intune for ongoing management). Gradually simplify OSD process to fit Autopilot model.

3. **Move complexity to post-deployment**: Shift customization logic from imaging (task sequence) to post-deployment (platform scripts, Win32 app dependencies, configuration profiles).

4. **Accept simplification**: Recognize that Autopilot's opinionated model is intentional (reduces complexity, improves reliability). Some task sequence flexibility cannot migrate—organizations must accept simpler deployment model.

### Intune Advantages

#### Graph API: Modern REST API Superiority

**Microsoft Graph API** represents a generational leap over SCCM's WMI/SMS Provider model:

**WMI/SMS Provider Limitations**:

- Windows-only (WMI is Windows-specific technology)
- Complex WQL query syntax with limited documentation
- No built-in batching or pagination (large result sets require manual chunking)
- No webhooks or event notifications (polling required for change detection)
- Error handling via obscure WMI error codes
- Fragmented documentation (scattered across TechNet articles and forum posts)

**Graph API Advantages**:

**1. Cross-Platform Support**:

- **REST API over HTTPS**: Any platform/language with HTTP client can call Graph API (Windows, Linux, macOS, mobile, web)
- **Official SDKs**: PowerShell, Python, C#, Java, JavaScript, Go, PHP
- **Interactive tools**: Graph Explorer (browser-based API explorer), Postman collections

**2. Comprehensive Documentation**:

- **Unified documentation**: graph.microsoft.com/docs with examples for all endpoints
- **Interactive Graph Explorer**: Test queries in browser, see request/response, get code snippets
- **OpenAPI specification**: Machine-readable API definition for code generation

**3. Advanced Query Capabilities**:

- **OData v4 filters**: `$filter`, `$select`, `$expand`, `$top`, `$skip`, `$orderby`
- **Batching**: Combine up to 20 requests in a single HTTP call (reduces round-trips)
- **Delta queries**: Incremental sync (get only changes since last query)
- **Change notifications (webhooks)**: Subscribe to resource changes, receive HTTP POST when changes occur

**4. Unified API Surface**:

- **Single API** for Intune, Entra ID, Exchange Online, SharePoint, Teams, Planner, etc.
- **Consistent patterns**: Same authentication, same query syntax, same error handling across all services
- **Cross-service queries**: Combine Intune device data with Entra ID user data in single workflow

**Example: Webhook Event-Driven Automation** (no SCCM equivalent):

**Scenario**: Automatically create ServiceNow ticket when new device enrolls in Intune.

> **Note**: The following is a conceptual example illustrating webhook-driven automation patterns. Adapt subscription parameters, Azure Function code, and ServiceNow API endpoints for your environment.

**Implementation**:

```powershell
# 1. Create webhook subscription via Graph API
$subscription = @{
    changeType = "created"
    notificationUrl = "https://contoso-function.azurewebsites.net/api/device-enrolled"
    resource = "/deviceManagement/managedDevices"
    expirationDateTime = (Get-Date).AddDays(3).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    clientState = "SecretClientState"
}
New-MgSubscription -BodyParameter $subscription

# 2. Azure Function receives webhook POST when device enrolls
# (Azure Function code)
function HandleDeviceEnrolled {
    param($WebhookData)

    $deviceId = $WebhookData.resourceData.id
    $device = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceId

    # Create ServiceNow ticket
    $ticketBody = @{
        short_description = "New device enrolled: $($device.deviceName)"
        description = "User: $($device.userPrincipalName), Serial: $($device.serialNumber)"
        assignment_group = "Endpoint Management"
    }
    Invoke-RestMethod -Uri "https://contoso.service-now.com/api/now/table/incident" `
        -Method Post -Body ($ticketBody | ConvertTo-Json) -Headers $headers
}
```

**Result**: Zero-code event-driven automation. Webhook triggers Azure Function → creates ticket automatically. SCCM required polling (check for new devices every X minutes) or manual processes.

**Example: Batching for Efficiency**:

**Scenario**: Get device details and compliance status for 100 devices.

**SCCM approach** (separate WMI queries):

> **Note**: The following is a conceptual example illustrating SCCM WMI query patterns. Adapt site code and device collection for your environment.

```powershell
# 100 separate WMI queries (slow)
foreach ($device in $devices) {
    $details = Get-WmiObject -Namespace "root/sms/site_PS1" `
        -Class SMS_R_System -Filter "Name='$($device.Name)'"
    $compliance = Get-CMDeviceComplianceStatus -DeviceName $device.Name
}
```

**Graph API approach** (batching):

> **Note**: The following is a conceptual example illustrating Graph API batching patterns. Adapt device ID collection for your environment.

```powershell
# Batch up to 20 requests per HTTP call
$batchRequests = @()
foreach ($deviceId in $deviceIds[0..19]) {  # First 20 devices
    $batchRequests += @{
        id = $deviceId
        method = "GET"
        url = "/deviceManagement/managedDevices/$deviceId"
    }
}

$batchResponse = Invoke-MgGraphRequest -Method POST -Uri '$batch' `
    -Body @{ requests = $batchRequests }
# Process 20 devices in 1 HTTP call instead of 20 separate calls
```

**Performance gain**: 20x reduction in HTTP round-trips for batch operations.

**Migration Benefit**: Organizations migrating from SCCM gain access to modern API capabilities (webhooks, batching, delta queries) that enable event-driven automation architectures and efficient data sync patterns impossible with WMI.

#### Configuration-as-Code: DevOps-Grade Infrastructure Management

**SCCM Configuration Management**:

- PowerShell scripting via ConfigurationManager module
- No official Microsoft tooling for configuration-as-code
- Community solutions (export collections/packages to XML) but limited functionality
- Version control possible but requires custom scripting

**Intune Configuration-as-Code** ecosystem:

**1. IntuneCD** (Python-based):

- **GitHub**: [almenscorner/IntuneCD](https://github.com/almenscorner/IntuneCD)
- **Capabilities**:
  - Backup: Export all Intune configurations to JSON files
  - Documentation: Auto-generate markdown documentation from configurations
  - Update: Deploy configurations from JSON to Intune (create/update/delete)
  - Version control: Store JSON in Git repository for change tracking
- **Use case**: Multi-tenant management, disaster recovery, configuration drift detection

**Example Workflow**:

```bash
# Install IntuneCD
pip install IntuneCD

# Backup production tenant
IntuneCD-startbackup --mode=1 --output=./prod-backup --localauth=interactive

# Review changes in Git
git diff prod-backup/

# Deploy to UAT tenant (test changes before production)
IntuneCD-startupdate --path=./prod-backup --localauth=interactive --report=uat-report.txt
```

**2. Microsoft365DSC** (PowerShell Desired State Configuration):

- **GitHub**: [microsoft/Microsoft365DSC](https://github.com/microsoft/Microsoft365DSC)
- **Capabilities**:
  - Export current M365/Intune configuration as DSC `.ps1` file
  - Declarative configuration management (define desired state, DSC enforces it)
  - Drift detection (compare current state to desired state, report differences)
  - Multi-tenant deployment (export from tenant A, apply to tenant B)
- **Use case**: Configuration standardization across tenants, compliance validation, disaster recovery

**Example Workflow**:

```powershell
# Install Microsoft365DSC
Install-Module Microsoft365DSC -Force

# Export current Intune configuration
Export-M365DSCConfiguration -Components @("IntuneDeviceConfigurationPolicy", "IntuneDeviceCompliancePolicy", "IntuneAppProtectionPolicy")

# Output: M365TenantConfig.ps1 (declarative DSC configuration)

# Apply configuration to another tenant
Start-DscConfiguration -Path ./M365TenantConfig -Wait -Verbose

# Test configuration drift
Test-DscConfiguration -Path ./M365TenantConfig
```

**3. IntuneBackupAndRestore** (PowerShell module):

- **GitHub**: [jseerden/IntuneBackupAndRestore](https://github.com/jseerden/IntuneBackupAndRestore)
- **Capabilities**:
  - Backup: Export Intune configurations to JSON via Graph API
  - Restore: Import configurations from JSON to Intune (cross-tenant restore)
  - Simple PowerShell module (no external dependencies)
- **Use case**: Quick backup/restore, cross-tenant copy

**Example Workflow**:

```powershell
# Install module
Install-Module IntuneBackupAndRestore

# Backup all configurations
Start-IntuneBackup -Path "./backup"

# Restore to another tenant
Start-IntuneRestoreConfig -Path "./backup"
```

**4. Graph API + Git + CI/CD Pipeline** (custom solution):

- Export configurations via Graph API as JSON
- Store in Git repository (Azure DevOps, GitHub, GitLab)
- CI/CD pipeline deploys configurations on commit (infrastructure-as-code)
- Full version control, change approval workflow, automated testing

**Example CI/CD Pipeline** (Azure DevOps YAML):

> **Note**: The following is a conceptual example illustrating CI/CD deployment patterns. Adapt trigger configuration and authentication method for your environment.

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - intune-configs/*

stages:
  - stage: Deploy
    jobs:
      - job: DeployIntuneConfigs
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: PowerShell@2
            inputs:
              targetType: 'inline'
              script: |
                Install-Module Microsoft.Graph.Intune -Force
                Connect-MgGraph -ClientId $(clientId) -TenantId $(tenantId) -ClientSecret $(clientSecret)

                # Deploy each policy JSON
                $policies = Get-ChildItem ./intune-configs/policies/*.json
                foreach ($policy in $policies) {
                    $policyJson = Get-Content $policy.FullName | ConvertFrom-Json
                    New-MgDeviceManagementDeviceConfiguration -BodyParameter $policyJson
                }
```

**Advantage Over SCCM**:

| Capability                    | SCCM                                 | Intune (with IaC tools)                   |
| ----------------------------- | ------------------------------------ | ----------------------------------------- |
| Version control               | Manual scripting required            | Native Git integration                    |
| Change tracking               | Custom audit solution                | Git commit history (who, what, when, why) |
| Disaster recovery             | Site backup/restore (infrastructure) | Config export/import (configuration)      |
| Cross-tenant deployment       | Manual export/import                 | Automated via IaC tools                   |
| Configuration drift detection | Not available                        | Built-in (Microsoft365DSC, IntuneCD)      |
| CI/CD integration             | Custom scripting                     | Native Azure DevOps/GitHub Actions        |
| Approval workflow             | Manual change control                | Pull request approval in Git              |

**Migration Benefit**: Organizations gain DevOps-grade configuration management capabilities that exceed SCCM's scriptable automation model. Intune configurations become code artifacts that can be versioned, tested, reviewed, and deployed via automated pipelines.

**Recommended Approach**:

1. **Start simple**: Use IntuneBackupAndRestore for weekly configuration backup (disaster recovery)
2. **Mature to version control**: Adopt IntuneCD or Microsoft365DSC, store configs in Git
3. **Advanced automation**: Build CI/CD pipeline for configuration deployment (test in UAT → deploy to production via pipeline)

---

## Licensing Impact

The scripting and automation capabilities assessed in this document have minimal licensing gates. See the **Licensing Impact Register** for consolidated analysis.

### Capabilities Included in Intune Plan 1 (M365 E3)

All core scripting and automation capabilities are included in **Intune Plan 1**:

- Platform Scripts (PowerShell, shell)
- Remediations (basic detection+remediation pairs)
- Custom Compliance Scripts
- Graph API access (read/write via OAuth)
- Microsoft.Graph PowerShell SDK
- Intune Data Warehouse (OData feed)
- Audit logs
- Configuration profiles and Settings Catalog

**No additional licensing required** for core automation scenarios.

### Capabilities Requiring Premium Licensing

| Feature                                                           | License Required   | Included In                                                                 | Impact                                                                                                                     |
| ----------------------------------------------------------------- | ------------------ | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **MDE Advanced Hunting** (KQL queries for security investigation) | MDE Plan 2         | M365 E5 or standalone (~$5.20/user/month)                                   | Partial replacement for CMPivot real-time queries in security scenarios. Real-time KQL queries against security telemetry. |
| **Intune Suite capabilities** (Remote Help, Advanced Analytics, etc.) | Intune Suite       | M365 E3/E5 (from July 2026) or standalone (~$10/user/month before July 2026) | Standard Remediations already included in M365 E3. Suite adds Remote Help, Advanced Analytics, EPM (E5), Cloud PKI (E5). |
| **Azure Log Analytics** (KQL queries across Intune data)          | Azure subscription | Consumption-based (~$2.30/GB ingestion)                                     | Historical trending, custom dashboards, cross-service queries. Optional for advanced reporting.                            |

**July 2026 Licensing Changes**: Intune Suite capabilities (Remote Help, Advanced Analytics, Intune Plan 2) will be included in M365 E3/E5, with EPM, Enterprise App Management, and Cloud PKI included in M365 E5 only — at no additional cost beyond the ~$3/user/month price increase. Standard Remediations (detection + remediation scripts) are already included in M365 E3. See [Intune Suite Is Included in E3/E5 Starting July 2026](https://sra.io/blog/intune-suite-is-included-in-e3-e5-starting-july-2026/).

### CMPivot Alternative Decision Matrix

| CMPivot Use Case              | Free Alternative (Intune Plan 1)        | Premium Alternative                    | License Required                     |
| ----------------------------- | --------------------------------------- | -------------------------------------- | ------------------------------------ |
| Routine compliance monitoring | Remediations (scheduled)                | N/A                                    | Intune Plan 1 (included in M365 E3)  |
| Security investigation        | Graph API queries (not real-time)       | MDE Advanced Hunting (real-time KQL)   | MDE P2 (M365 E5 or $5.20/user/month) |
| Historical trending           | Graph API + export to CSV               | Azure Log Analytics (KQL + dashboards) | Azure consumption (~$2.30/GB)        |
| Ad-hoc troubleshooting        | Platform Scripts (on-demand per device) | N/A                                    | Intune Plan 1                        |

**Recommendation**: Organizations on **M365 E3** can use Remediations + Graph API for most CMPivot scenarios at no additional cost. Organizations on **M365 E5** gain MDE Advanced Hunting for real-time security queries (superior to CMPivot for security use cases).

---

## Migration Considerations

### Planning the Transition

#### 1. Inventory Existing Automation

**Assessment Checklist**:

- [ ] Document all SCCM Run Scripts (frequency, purpose, target collections)
- [ ] Inventory ConfigMgr PowerShell automation scripts (scheduled tasks, manual scripts)
- [ ] List Configuration Items with custom scripts (compliance baselines)
- [ ] Identify CMPivot queries used regularly (convert to Remediations or MDE queries)
- [ ] Document task sequence customizations (assess Autopilot migration complexity)

#### 2. Script Migration Strategy

**Run Scripts → Platform Scripts/Remediations**:

| SCCM Run Script Use Case         | Intune Migration Path                                | Implementation                                                         |
| -------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------- |
| On-demand troubleshooting script | Platform Script (assign to device group, force sync) | Migrate script with minor modifications (remove SCCM-specific cmdlets) |
| Scheduled compliance check       | Remediation (detection + remediation pair)           | Split into detection script (outputs JSON) + remediation script        |
| Deployment preparation script    | Pre-deployment script via Win32 app dependency       | Package as Win32 app script, set as dependency for main app            |

**Example Migration**: SCCM Run Script to Intune Remediation

**SCCM Run Script** (clears print spooler when stuck):

```powershell
# SCCM Run Script (manual execution when helpdesk gets ticket)
Stop-Service -Name Spooler -Force
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service -Name Spooler
Write-Output "Print spooler cleared and restarted"
```

**Intune Remediation** (scheduled daily, auto-remediates):

**Detection Script**:

```powershell
# Check if print spooler is stuck (has jobs but not processing)
$spoolerService = Get-Service -Name Spooler
$printJobs = Get-ChildItem "C:\Windows\System32\spool\PRINTERS" -File

if ($spoolerService.Status -eq "Running" -and $printJobs.Count -gt 10) {
    # Spooler appears stuck (too many queued jobs)
    Write-Output "Non-compliant: Print spooler stuck with $($printJobs.Count) jobs"
    exit 1  # Trigger remediation
} else {
    Write-Output "Compliant: Print spooler healthy"
    exit 0
}
```

**Remediation Script**:

```powershell
# Auto-remediate stuck print spooler
Stop-Service -Name Spooler -Force
Start-Sleep -Seconds 2
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service -Name Spooler
Write-Output "Print spooler cleared and restarted automatically"
exit 0
```

**Result**: Proactive auto-remediation (no helpdesk ticket needed) instead of reactive manual script execution.

#### 3. PowerShell Automation Migration

**ConfigMgr Module → Graph SDK Translation**:

Create **translation reference guide** for common cmdlets:

| SCCM Cmdlet                             | Graph PowerShell Equivalent                           | Notes                                      |
| --------------------------------------- | ----------------------------------------------------- | ------------------------------------------ |
| `Get-CMDevice`                          | `Get-MgDeviceManagementManagedDevice`                 | Use `-Filter` parameter with OData syntax  |
| `Get-CMCollection`                      | `Get-MgDeviceManagementDeviceGroup` (Entra ID groups) | Collections → Groups paradigm shift        |
| `New-CMCollection`                      | `New-MgGroup` (Entra ID)                              | Create dynamic group with membership rules |
| `Get-CMApplication`                     | `Get-MgDeviceAppManagementMobileApp`                  | Apps in Intune                             |
| `Invoke-CMDeviceAction -Action Restart` | `Restart-MgDeviceManagementManagedDevice`             | Remote actions                             |
| `Get-CMClientSetting`                   | `Get-MgDeviceManagementDeviceConfiguration`           | Settings Catalog policies                  |

**Example Script Migration**:

**SCCM Script** (get all devices with low disk space):

```powershell
# SCCM approach
Import-Module ConfigurationManager
Set-Location "PS1:"

$devices = Get-CMDevice -All
$lowSpaceDevices = @()

foreach ($device in $devices) {
    $diskInfo = Get-WmiObject -ComputerName $device.Name -Class Win32_LogicalDisk `
        -Filter "DriveType=3" -ErrorAction SilentlyContinue

    foreach ($disk in $diskInfo) {
        if ($disk.FreeSpace -lt 10GB) {
            $lowSpaceDevices += [PSCustomObject]@{
                DeviceName = $device.Name
                DriveLetter = $disk.DeviceID
                FreeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            }
        }
    }
}

$lowSpaceDevices | Export-Csv -Path "LowDiskSpace.csv" -NoTypeInformation
```

**Intune Script** (Graph API approach):

```powershell
# Intune approach (uses last reported inventory data from Intune service)
Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

$devices = Get-MgDeviceManagementManagedDevice -All
$lowSpaceDevices = $devices | Where-Object {
    $_.freeStorageSpaceInBytes -lt 10GB -and $_.freeStorageSpaceInBytes -gt 0
} | Select-Object deviceName, userPrincipalName,
    @{N="FreeSpaceGB"; E={[math]::Round($_.freeStorageSpaceInBytes / 1GB, 2)}}

$lowSpaceDevices | Export-Csv -Path "LowDiskSpace.csv" -NoTypeInformation
```

**Key Differences**:

- SCCM script queries each device via WMI (slow, requires network access)
- Intune script queries Graph API (fast, uses cached inventory data)
- Intune approach is faster but data is not real-time (reflects last device check-in)

#### 4. CMPivot Migration Planning

**For Each CMPivot Query**:

1. **Identify query purpose**:
   - Routine compliance check → Migrate to **Remediation** (scheduled)
   - Security investigation → Migrate to **MDE Advanced Hunting** (if E5 licensed)
   - Ad-hoc troubleshooting → Use **Platform Script** (on-demand)
   - Historical trending → Build **Power BI report** from Intune Data Warehouse or Log Analytics

2. **Rewrite query in target platform**:

**CMPivot Query** (find devices with specific software version):

```kusto
Device
| join (InstalledSoftware | where (ProductName == 'Adobe Reader' and Version < '23.0'))
| project Device, Version
```

**Intune Remediation Detection Script**:

```powershell
# Check for outdated Adobe Reader
$adobeReader = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -like "Adobe*Reader*" }

if ($adobeReader -and $adobeReader.DisplayVersion -lt "23.0") {
    Write-Output "Non-compliant: Adobe Reader version $($adobeReader.DisplayVersion) is outdated"
    exit 1
} else {
    Write-Output "Compliant: Adobe Reader is up to date or not installed"
    exit 0
}
```

**MDE Advanced Hunting Query** (if E5 licensed):

```kusto
DeviceTvmSoftwareInventory
| where SoftwareName contains "Adobe Reader"
| where SoftwareVersion < "23.0"
| project DeviceName, SoftwareName, SoftwareVersion
```

#### 5. Configuration-as-Code Implementation

**Phase 1: Backup** (immediate, disaster recovery):

```powershell
# Weekly scheduled task: Backup Intune configurations
Install-Module IntuneBackupAndRestore -Force
$backupPath = "\\fileserver\IntuneBackup\$(Get-Date -Format 'yyyy-MM-dd')"
Start-IntuneBackup -Path $backupPath
```

**Phase 2: Version Control** (3-6 months):

```bash
# Export configs to Git repository
pip install IntuneCD
IntuneCD-startbackup --mode=1 --output=./intune-configs

# Commit to Git
git add intune-configs/
git commit -m "Weekly config backup $(date +%Y-%m-%d)"
git push origin main
```

**Phase 3: CI/CD Pipeline** (6-12 months):

> **Note**: The following is a conceptual example illustrating CI/CD pipeline structure. Adapt trigger configuration and authentication method for your environment.

```yaml
# Azure DevOps pipeline: Deploy configs on commit
trigger:
  branches:
    include: [main]
  paths:
    include: [intune-configs/*]

jobs:
  - job: DeployConfigs
    steps:
      - script: pip install IntuneCD
      - script: IntuneCD-startupdate --path=./intune-configs --localauth=clientsecret
```

### Risk Assessment

| Risk                                                            | Severity              | Mitigation                                                                                                           |
| --------------------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Script compatibility (SCCM cmdlets not available in Intune)** | High                  | Invest in Graph API training; create cmdlet translation guide; test all migrated scripts in UAT                      |
| **Loss of CMPivot real-time query capability**                  | Medium-High           | Implement scheduled Remediations for routine checks; use MDE Advanced Hunting if E5 licensed; accept workflow change |
| **OAuth authentication learning curve**                         | Medium                | Provide Graph API training; create app registration documentation; use Microsoft.Graph SDK (handles auth complexity) |
| **Task sequence variable dependency (OSD)**                     | High (if complex OSD) | Retain SCCM for OSD during transition via co-management; gradually simplify OSD to fit Autopilot model               |
| **Approval workflow loss (Run Scripts)**                        | Low-Medium            | Implement Git-based approval (pull requests); document change control process                                        |

### Recommended Transition Sequence

**Phase 1: Foundation (Months 1-2)**

- Graph API training for automation team
- Install Microsoft.Graph PowerShell SDK on admin workstations
- Set up app registration for OAuth authentication
- Create cmdlet translation reference guide (SCCM → Graph)

**Phase 2: Script Migration (Months 2-4)**

- Migrate SCCM Run Scripts to Intune Platform Scripts (1:1 migration for on-demand scripts)
- Migrate compliance check scripts to Remediations (scheduled detection+remediation)
- Test all migrated scripts in pilot environment before production deployment

**Phase 3: Automation Modernization (Months 3-6)**

- Rewrite ConfigMgr PowerShell automation to Graph PowerShell SDK
- Implement configuration backup (IntuneBackupAndRestore or IntuneCD)
- Create Power BI dashboards for reporting (replace SSRS reports)

**Phase 4: CMPivot Replacement (Months 4-8)**

- Build library of Remediations for common CMPivot queries
- Train security team on MDE Advanced Hunting (if E5 licensed)
- Document alternative workflows for ad-hoc troubleshooting (Platform Scripts)

**Phase 5: Configuration-as-Code (Months 6-12)**

- Implement Git version control for Intune configurations
- Build CI/CD pipeline for automated deployment
- Establish change approval workflow via pull requests

**Phase 6: Advanced Automation (Months 9-18)**

- Implement Graph API webhooks for event-driven automation
- Build custom Azure Functions for complex workflows
- Integrate Intune automation with broader ITSM ecosystem (ServiceNow, etc.)

---

## Sources

### Official Microsoft Documentation

- [Use Remediations to Detect and Fix Support Issues - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/remediations)
- [Create and run scripts - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/apps/deploy-use/create-deploy-scripts)
- [Using CMPivot in SCCM for Real-Time Data | Justin Chalfant's SCCM Guides](https://setupconfigmgr.com/using-cmpivot-in-sccm-for-real-time-data-and-taking-real-time-action-using-scripts)
- [Configuration Manager PowerShell cmdlets - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/sccm/overview?view=sccm-ps)
- [Intune devices and apps API overview - Microsoft Graph | Microsoft Learn](https://learn.microsoft.com/en-us/graph/intune-concept-overview)
- [Working with Intune in Microsoft Graph - Microsoft Graph v1.0 | Microsoft Learn](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview?view=graph-rest-1.0)
- [Create a JSON file for custom compliance settings in Microsoft Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/protect/compliance-custom-json)
- [Use custom compliance settings for Linux and Windows devices in Microsoft Intune - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/protect/compliance-use-custom-settings)
- [Task sequence variable reference - Configuration Manager | Microsoft Learn](https://learn.microsoft.com/en-us/intune/configmgr/osd/understand/task-sequence-variables)
- [Connect to the Data Warehouse With Power BI - Microsoft Intune | Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-get-a-link-powerbi)

### Configuration-as-Code and Automation Tools

- [GitHub - almenscorner/IntuneCD: Tool to backup, update and document configurations in Intune](https://github.com/almenscorner/IntuneCD)
- [GitHub - jseerden/IntuneBackupAndRestore: PowerShell Module that queries Microsoft Graph](https://github.com/jseerden/IntuneBackupAndRestore)
- [Configuration as Code for Microsoft Intune | Microsoft Community Hub](https://techcommunity.microsoft.com/blog/intunecustomersuccess/configuration-as-code-for-microsoft-intune/3701792)

### Community Practical Guidance

- [My most used Proactive Remediations - Joey Verlinden](https://www.joeyverlinden.com/my-most-used-proactive-remediations/)
- [Fun with (ProActive) Remediations - Welcome to the land of everything Microsoft Intune!](https://evil365.com/intune/FunWith-Remediations/)
- [Deploy Proactive Remediation Script Using Intune | HTMD Blog](https://www.anoopcnair.com/deploy-proactive-remediation-script-intune/)
- [Intune Remediations 101 – Intune's hidden secret! – Andrew Taylor](https://andrewstaylor.com/2022/04/12/proactive-remediations-101-intunes-hidden-secret/)
- [Intune Proactive Remediation Scripts Vs PowerShell Scripts | HTMD Blog](https://www.anoopcnair.com/intune-proactive-remediation-scripts-powershell/)
- [Automate Intune Configuration Profile via Graph API | NinjaOne](https://www.ninjaone.com/blog/automate-intune-configuration-profile-via-graph-api/)
- [Automate Intune App Deployment Using Microsoft Graph API And PowerShell | HTMD Blog](https://www.anoopcnair.com/automate-intune-app-deployment-microsoft-graph/)
- [Creating Custom Intune Reports with Microsoft Graph API | Microsoft Community Hub](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/creating-custom-intune-reports-with-microsoft-graph-api/4431346)
- [A beginners guide to Microsoft Graph API rate limiting in Intune - MSEndpointMgr](https://msendpointmgr.com/2025/11/08/graph-api-rate-limiting-in-intune/)

### 2026 Updates

- [Plan for Change: Update to Intune Data Warehouse infrastructure - M365 Admin](https://m365admin.handsontek.net/plan-change-update-intune-data-warehouse-infrastructure/)
- [What's New in Microsoft Intune – January 2026 | Microsoft Tech Community](https://techcommunity.microsoft.com/blog/microsoftintuneblog/whats-new-in-microsoft-intune-%E2%80%93-january-2026/4476487)
- [Microsoft Intune In Development for February 2026 is now available - M365 Admin](https://m365admin.handsontek.net/microsoft-intune-development-february-2026-now-available/)

---

**Document End**
