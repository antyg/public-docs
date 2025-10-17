# Microsoft Defender for Endpoint (MDE) Deployment Validation Toolkit

Comprehensive validation methods, PowerShell automation, and Azure Workbooks for Microsoft Defender for Endpoint deployment verification

[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](./docs/INDEX.md)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](../../LICENSE)

---

## 📋 Overview

This toolkit provides enterprise-grade resources for validating Microsoft Defender for Endpoint (MDE) deployment status across Windows devices. Whether you're managing 10 devices or 10,000, these tools help ensure comprehensive security coverage through automated validation, detailed reporting, and actionable insights.

### Key Features

- ✅ **7 Validation Methods** - Comprehensive coverage from PowerShell to Advanced Hunting KQL
- ✅ **4 Production Scripts** - Intelligent multi-method automation with automatic fallback
- ✅ **Azure Workbook** - Real-time dashboards with interactive analytics
- ✅ **AU Localized** - All endpoints configured for Australian region by default
- ✅ **Enterprise Ready** - Supports bulk validation, parallel processing, and scheduled reporting
- ✅ **Automated Diagnostics** - One-click download and setup of official Microsoft analyzer tool

---

## 📁 Repository Structure

```text
.\Defender\forEndpoints\
│
├── README.md                           # This file - complete toolkit guide
│
├── docs\                               # Comprehensive validation documentation (8 files)
│   ├── INDEX.md                        # Documentation hub and quick start guide
│   ├── 01-PowerShell-Validation.md     # Method 1: Local/remote PowerShell validation
│   ├── 02-Graph-API-Validation.md      # Method 2: Microsoft Graph API queries
│   ├── 03-Security-Console-Manual.md   # Method 3: Portal-based manual checks
│   ├── 04-Registry-Service-Validation.md # Method 4: Registry and service validation
│   ├── 05-Advanced-Hunting-KQL.md      # Method 5: KQL queries for historical analysis
│   ├── 06-MDE-Client-Analyzer.md       # Method 6: Official Microsoft diagnostic tool
│   └── 07-WMI-CIM-Validation.md        # Method 7: Legacy WMI/CIM queries
│
├── scripts\                            # Production PowerShell automation (4 active + 5 archived)
│   ├── Get-MDEStatus.ps1               # ⭐ Primary: Intelligent multi-method validation
│   ├── Export-MDEInventoryFromGraph.ps1 # Graph API tenant-wide device export
│   ├── Test-MDEConnectivity.ps1        # Network connectivity validation (AU region)
│   ├── Get-MDEClientAnalyzer.ps1       # Download and extract official Microsoft analyzer
│   └── archived\                       # Superseded scripts (kept for reference)
│       ├── Get-MDECimStatus.ps1        # Replaced by Get-MDEStatus.ps1 -PreferredMethod CIM
│       ├── Get-MDEWmiStatus.ps1        # Replaced by Get-MDEStatus.ps1 -PreferredMethod WMI
│       ├── Get-MDERegistryStatus.ps1   # Replaced by Get-MDEStatus.ps1 -PreferredMethod Registry
│       ├── Get-MDEServiceStatus.ps1    # Replaced by Get-MDEStatus.ps1 -PreferredMethod Service
│       └── Test-MDEDeploymentStatus.ps1 # Replaced by Get-MDEStatus.ps1 -CsvPath
│
└── workbooks\                          # Azure Workbook for visualization (2 files)
    ├── MDE-Deployment-Validation-Workbook.json # Interactive Azure Workbook
    └── README.md                       # Workbook deployment and usage guide
```

---

## 🚀 Quick Start

### For First-Time Users

1. **Start with Documentation**

   ```powershell
   # Open the main documentation hub
   Get-Content .\docs\INDEX.md
   ```

2. **Validate a Single Device**

   ```powershell
   # Test local device MDE status
   .\scripts\Get-MDEStatus.ps1

   # Test remote device
   .\scripts\Get-MDEStatus.ps1 -ComputerName "WORKSTATION01"
   ```

3. **Validate Multiple Devices**

   ```powershell
   # Create CSV with device list
   @"
   Hostname,Notes
   WORKSTATION01,Finance Dept
   WORKSTATION02,HR Dept
   SERVER01,File Server
   "@ | Out-File devices.csv

   # Run bulk validation
   .\scripts\Get-MDEStatus.ps1 -CsvPath .\devices.csv -OutputPath .\results.csv
   ```

4. **Test Network Connectivity**

   ```powershell
   # Validate connectivity to MDE cloud endpoints (AU region)
   .\scripts\Test-MDEConnectivity.ps1 -Region AU -Verbose
   ```

5. **Download MDE Client Analyzer**

   ```powershell
   # Download and extract official Microsoft diagnostic tool
   .\scripts\Get-MDEClientAnalyzer.ps1
   ```

6. **Export Tenant-Wide Inventory**

   ```powershell
   # Export all devices from Microsoft Graph API
   .\scripts\Export-MDEInventoryFromGraph.ps1 `
       -TenantId "your-tenant-id" `
       -ClientId "your-client-id" `
       -ClientSecret "your-secret"
   ```

---

## 📚 Documentation Guide

### Navigation Structure

All documentation follows the **[Diátaxis Framework](https://diataxis.fr/)** for optimal user experience:

- **Tutorials** (Learning-oriented): Methods 1-2
- **How-to Guides** (Task-oriented): Methods 3-6
- **Reference** (Information-oriented): Method 7
- **Explanation** (Understanding-oriented): INDEX.md

### Documentation Files

| File                                                                              | Type      | Purpose                                                                   | Audience                           |
| --------------------------------------------------------------------------------- | --------- | ------------------------------------------------------------------------- | ---------------------------------- |
| [**INDEX.md**](./docs/INDEX.md)                                                   | Hub       | Quick start guide, validation criteria, troubleshooting decision tree     | All users                          |
| [**01-PowerShell-Validation.md**](./docs/01-PowerShell-Validation.md)             | Tutorial  | PowerShell-based local and remote validation using `Get-MpComputerStatus` | PowerShell users                   |
| [**02-Graph-API-Validation.md**](./docs/02-Graph-API-Validation.md)               | Tutorial  | Microsoft Graph API programmatic access for organization-wide reporting   | Developers, automation engineers   |
| [**03-Security-Console-Manual.md**](./docs/03-Security-Console-Manual.md)         | How-to    | Web-based manual validation via Microsoft 365 Defender portal             | Security analysts, ad-hoc checks   |
| [**04-Registry-Service-Validation.md**](./docs/04-Registry-Service-Validation.md) | How-to    | Direct registry and service validation for definitive status checks       | Troubleshooting, support engineers |
| [**05-Advanced-Hunting-KQL.md**](./docs/05-Advanced-Hunting-KQL.md)               | How-to    | KQL queries for historical analysis and trending                          | Security operations, analysts      |
| [**06-MDE-Client-Analyzer.md**](./docs/06-MDE-Client-Analyzer.md)                 | How-to    | Official Microsoft diagnostic tool for deep troubleshooting               | Advanced troubleshooting           |
| [**07-WMI-CIM-Validation.md**](./docs/07-WMI-CIM-Validation.md)                   | Reference | Legacy WMI/CIM queries for Windows 7, Server 2008 R2 compatibility        | Legacy system administrators       |

### Key Validation Criteria

All documentation references these universal validation states:

- ✅ **Installed**: SENSE service exists, registry keys present
- ✅ **Onboarded**: `OnboardingState` registry = 1, appears in Security Console
- ✅ **Functional**: SENSE service running, real-time protection enabled, signatures current
- ⚠️ **Can Be Onboarded**: Discovered via Device Discovery but not yet onboarded
- ❌ **Unsupported**: OS incompatible with MDE (e.g., Windows 7 without ESU)

---

## 🛠️ PowerShell Scripts

### Active Production Scripts

#### 1. **Get-MDEStatus.ps1** ⭐ PRIMARY VALIDATION TOOL

**Purpose:** Intelligent multi-method MDE status validation with automatic fallback

**Features:**

- Automatic method detection and fallback chain:
  1. CIM/WSMan (fastest, modern systems Windows 10/11, Server 2016+)
  2. WMI/DCOM (legacy Windows 7, Server 2008 R2)
  3. Registry (works when WMI/CIM unavailable)
  4. Service (minimal validation when registry locked)
- Event log checking (SENSE operational log, last 7 days)
- Single device and bulk CSV validation
- Parallel processing with configurable throttle limit (PS7+) or sequential fallback (PS5.1)
- Comprehensive health status determination
- **Automatic comprehensive logging** to `Get-MDEStatus-Log.txt` with structured key=value format
- Console output displays HealthStatus | OnboardingState [ValidationMethod] for quick assessment
- All 21 result fields logged for intelligent parsing and analysis

**Usage Examples:**

```powershell
# Local device validation
.\Get-MDEStatus.ps1

# Remote device validation
.\Get-MDEStatus.ps1 -ComputerName "WORKSTATION01"

# Force specific validation method
.\Get-MDEStatus.ps1 -ComputerName "SERVER01" -PreferredMethod Registry

# Bulk validation from CSV
.\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -OutputPath "C:\results.csv"

# Bulk validation with credentials
$Cred = Get-Credential
.\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -Credential $Cred -ThrottleLimit 20
```

**Output Properties:**

- Hostname, ValidationMethod, HealthStatus
- OnboardingState, AMRunningMode, RealTimeProtectionEnabled
- AntivirusSignatureVersion, SignatureAgeHours
- SENSEServiceStatus, DiagTrackServiceStatus
- RecentSENSEErrors, LastSENSEError
- Timestamp

**Health Status Values:**

- `Healthy`, `Passive`, `RealTimeProtectionDisabled`, `OutdatedSignatures`
- `Degraded`, `NotOnboarded`, `NotInstalled`, `EventLogErrors`
- `SenseServiceNotRunning`, `ValidationFailed`, `Offline`

---

#### 2. **Export-MDEInventoryFromGraph.ps1** - TENANT-WIDE INVENTORY

**Purpose:** Export MDE onboarding status from Microsoft Graph API

**Features:**

- Three operation modes:
  1. CSV validation - compare CSV list against MDE tenant
  2. Full inventory export - retrieve all tenant devices
  3. Unmanaged device discovery - find devices with "CanBeOnboarded" status
- OAuth 2.0 client credentials flow authentication
- OData pagination support for large tenants (>10,000 devices)
- Rate limit handling (100 calls/min, 1,500 calls/hour)
- High-risk device identification

**Usage Examples:**

```powershell
# Full tenant inventory export
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "12345678-1234-1234-1234-123456789012" `
    -ClientId "abcd1234-5678-90ab-cdef-123456789012" `
    -ClientSecret "your-client-secret"

# Validate CSV device list against tenant
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "tenant-id" `
    -ClientId "client-id" `
    -ClientSecret "secret" `
    -CsvPath "C:\devices.csv" `
    -OutputPath "C:\mde-graph-report.csv"

# Discover unmanaged devices only
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "tenant-id" `
    -ClientId "client-id" `
    -ClientSecret "secret" `
    -OnlyUnmanaged `
    -OutputPath "C:\unmanaged-devices.csv"
```

**Output Properties:**

- ComputerDnsName, OnboardingStatus, HealthStatus
- RiskScore, ExposureLevel, OSPlatform, OSVersion
- LastSeen, FirstSeen, AzureADDeviceId
- MDEAgentVersion, DeviceId, MachineGroups, Tags

**API Permissions Required:**

- `Machine.Read.All` (Application) **OR**
- `Machine.ReadWrite.All` (Delegated)

---

#### 3. **Test-MDEConnectivity.ps1** - NETWORK VALIDATION

**Purpose:** Test network connectivity to MDE cloud endpoints (v2.0 - Gateway Architecture)

**Features:**

- **Gateway Architecture (2025+)** - Tests new streamlined `*.endpoint.security.microsoft.com` endpoints
- **Criticality Detection** - Distinguishes CRITICAL vs OPTIONAL endpoints (blob storage)
- Region-specific endpoint testing (US, EU, UK, **AU** - default)
- DNS resolution validation
- TCP connectivity testing (port 443)
- HTTPS response code validation
- **Port 80 fallback diagnostics** - automatically tests HTTP when HTTPS fails
- SSL/TLS vs general connectivity issue differentiation
- Proxy configuration detection
- AU Gateway endpoints:
  - Commands: `edr-aus.au.endpoint.security.microsoft.com`, `edr-aue.au.endpoint.security.microsoft.com`
  - Cyber Data: `au-v20.events.endpoint.security.microsoft.com`
  - MDAV: `mdav.au.endpoint.security.microsoft.com`
  - AutoIR/Sample Upload: Proxied through gateway endpoints

**Usage Examples:**

```powershell
# Test AU region connectivity (default)
.\Test-MDEConnectivity.ps1

# Test with verbose output
.\Test-MDEConnectivity.ps1 -Region AU -Verbose

# Test proxy configuration
.\Test-MDEConnectivity.ps1 -TestProxy

# Test different region
.\Test-MDEConnectivity.ps1 -Region AU -Verbose
```

**Output:**

- Per-endpoint connectivity status (DNS, TCP:443, HTTPS, TCP:80 fallback)
- SSL/TLS issue identification (when port 80 succeeds but port 443 fails)
- Proxy configuration details
- Failed test summary with remediation guidance
- CSV export with detailed results including diagnostic information

---

#### 4. **Get-MDEClientAnalyzer.ps1** - ANALYZER DOWNLOAD & SETUP

**Purpose:** Automated download and extraction of Microsoft's official MDE Client Analyzer tool

**Features:**

- Automatic download from official Microsoft aka.ms URL (`https://aka.ms/mdatpanalyzer`)
- Saves to script directory for easy access
- Automatic extraction to `MDEClientAnalyzer\` subfolder
- File size and download duration reporting
- Displays usage instructions after extraction
- Force re-download option with `-Force` parameter
- Skip extraction option with `-SkipExtraction` for offline scenarios
- Comprehensive error handling with troubleshooting guidance

**Usage Examples:**

```powershell
# Download and extract analyzer (default)
.\Get-MDEClientAnalyzer.ps1

# Force re-download (overwrites existing)
.\Get-MDEClientAnalyzer.ps1 -Force

# Download only, skip extraction
.\Get-MDEClientAnalyzer.ps1 -SkipExtraction
```

**What Gets Downloaded:**

The MDE Client Analyzer provides comprehensive diagnostics including:

- Network connectivity validation to all MDE cloud endpoints
- Sensor health and configuration checks
- Event log analysis for onboarding issues
- Performance troubleshooting and baseline metrics
- Detailed diagnostic reports in HTML and text formats
- Region-specific endpoint validation (AU, US, EU, UK)

**After Download:**

```powershell
# Navigate to extracted folder
cd .\scripts\MDEClientAnalyzer

# Run basic connectivity test
.\MDEClientAnalyzer.cmd -Connectivity

# Run full diagnostic
.\MDEClientAnalyzer.cmd

# View all options
Get-Help .\MDEClientAnalyzer.ps1 -Full
```

**Official Documentation:**

- [Run the client analyzer on Windows](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)
- [GitHub Repository](https://github.com/microsoft/MDATP-PowerBI-Templates)

---

### Archived Scripts (Superseded)

These scripts have been consolidated into **Get-MDEStatus.ps1** for simplified maintenance:

| Archived Script                | Replacement Command                           |
| ------------------------------ | --------------------------------------------- |
| `Get-MDECimStatus.ps1`         | `Get-MDEStatus.ps1` (CIM is default)          |
| `Get-MDEWmiStatus.ps1`         | `Get-MDEStatus.ps1 -PreferredMethod WMI`      |
| `Get-MDERegistryStatus.ps1`    | `Get-MDEStatus.ps1 -PreferredMethod Registry` |
| `Get-MDEServiceStatus.ps1`     | `Get-MDEStatus.ps1 -PreferredMethod Service`  |
| `Test-MDEDeploymentStatus.ps1` | `Get-MDEStatus.ps1 -CsvPath <path>`           |

**Why Consolidated?**

- Single script to maintain and update
- Intelligent automatic fallback reduces need for method selection
- Event log checking now integrated by default
- Consistent output format across all methods

---

## 📊 Azure Workbook

### Overview

The **MDE Deployment Validation Workbook** provides real-time interactive dashboards for organization-wide MDE deployment monitoring.

### Features

- **Executive Summary** - Total devices, onboarding compliance rate, visual KPIs
- **Device Inventory** - Searchable device list with export to Excel
- **Onboarding Status Analysis** - Distribution charts, priority onboarding list
- **Health & Connectivity** - Active vs inactive devices, communication frequency
- **Troubleshooting & Diagnostics** - Communication gaps, missing telemetry detection
- **Trending & Analytics** - 30-day onboarding progress, discovery rate tracking

### Quick Deployment

```powershell
# Option 1: Azure Portal (Recommended)
# 1. Navigate to Azure Portal → Monitor → Workbooks
# 2. Click + New → Advanced Editor
# 3. Paste contents of MDE-Deployment-Validation-Workbook.json
# 4. Click Apply → Save

# Option 2: PowerShell Deployment
$SubscriptionId = "your-subscription-id"
$ResourceGroup = "your-resource-group"
$WorkbookName = "MDE-Deployment-Validation"
$Location = "australiaeast"

Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Deploy using ARM template
# (See workbooks/README.md for full deployment script)
```

### Data Source

All workbook queries use **Advanced Hunting** KQL queries against:

- `DeviceInfo` - Device inventory, onboarding status, OS details
- `DeviceProcessEvents` - Sensor health validation
- `DeviceNetworkInfo` - Connectivity status

**Prerequisites:**

- Microsoft 365 Defender with Advanced Hunting enabled
- Security Reader role (minimum)

### Documentation

Full deployment guide, usage instructions, and troubleshooting: [workbooks/README.md](./workbooks/README.md)

---

## 🎯 Use Cases & Scenarios

### 1. Daily Operations

**Scenario:** Monitor MDE deployment health across enterprise

**Tools:**

- Azure Workbook for daily dashboard review
- `Get-MDEStatus.ps1` for spot-checking problematic devices

**Workflow:**

```powershell
# 1. Check workbook "Devices Ready for Onboarding" tab
# 2. Export list of inactive devices
# 3. Validate specific devices locally
.\Get-MDEStatus.ps1 -ComputerName "DEVICE-FROM-WORKBOOK"
```

---

### 2. New Deployment Validation

**Scenario:** Validate MDE deployment to 500 new workstations

**Tools:**

- `Get-MDEStatus.ps1` with CSV bulk validation
- `Test-MDEConnectivity.ps1` for network validation

**Workflow:**

```powershell
# 1. Create device list from AD
Get-ADComputer -Filter "Name -like 'WS-*'" |
    Select-Object @{N='Hostname';E={$_.Name}},@{N='Notes';E={'New Deployment'}} |
    Export-Csv devices.csv -NoTypeInformation

# 2. Test connectivity on sample device
.\Test-MDEConnectivity.ps1 -Region AU -Verbose

# 3. Run bulk validation
.\Get-MDEStatus.ps1 -CsvPath .\devices.csv -OutputPath .\deployment-results.csv -ThrottleLimit 20

# 4. Review results
Import-Csv .\deployment-results.csv |
    Where-Object HealthStatus -ne 'Healthy' |
    Format-Table Hostname, HealthStatus, ValidationMethod, ErrorMessage
```

---

### 3. Compliance Reporting

**Scenario:** Generate monthly MDE compliance report for management

**Tools:**

- `Export-MDEInventoryFromGraph.ps1` for tenant-wide data
- Azure Workbook for visual reports

**Workflow:**

```powershell
# 1. Export complete inventory
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientSecret $Secret `
    -OutputPath "MDE-Inventory-$(Get-Date -Format 'yyyy-MM').csv"

# 2. Calculate compliance metrics
$Inventory = Import-Csv "MDE-Inventory-*.csv"
$Total = $Inventory.Count
$Onboarded = ($Inventory | Where-Object OnboardingStatus -eq 'Onboarded').Count
$Compliance = [math]::Round(($Onboarded / $Total) * 100, 2)

# 3. Generate report
@"
MDE Compliance Report - $(Get-Date -Format 'MMMM yyyy')
=====================================================
Total Devices: $Total
Onboarded: $Onboarded
Compliance Rate: $Compliance%
"@ | Out-File "MDE-Monthly-Report.txt"

# 4. Screenshot workbook charts and attach to report
```

---

### 4. Troubleshooting Onboarding Issues

**Scenario:** Device shows as "Can Be Onboarded" but won't onboard

**Tools:**

- Documentation: [Method 4: Registry/Service Validation](./docs/04-Registry-Service-Validation.md)
- `Get-MDEStatus.ps1 -PreferredMethod Registry`
- Documentation: [Method 6: MDE Client Analyzer](./docs/06-MDE-Client-Analyzer.md)

**Workflow:**

```powershell
# 1. Check local status
.\Get-MDEStatus.ps1 -ComputerName "PROBLEM-DEVICE" -PreferredMethod Registry

# 2. Review event log errors
Get-WinEvent -ComputerName "PROBLEM-DEVICE" -FilterHashtable @{
    LogName = 'Microsoft-Windows-SENSE/Operational'
    Level = 2,3
    StartTime = (Get-Date).AddDays(-7)
} | Select-Object TimeCreated, Id, LevelDisplayName, Message

# 3. Test connectivity
.\Test-MDEConnectivity.ps1 -Region AU -Verbose

# 4. If still failing, run Client Analyzer
# Download from https://aka.ms/MDEAnalyzer
MDEClientAnalyzer.cmd
```

---

### 5. Discovery of Unmanaged Devices

**Scenario:** Find all devices that can be onboarded to MDE

**Tools:**

- `Export-MDEInventoryFromGraph.ps1 -OnlyUnmanaged`
- Azure Workbook "Onboarding Status Analysis" tab

**Workflow:**

```powershell
# 1. Export unmanaged devices
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientSecret $Secret `
    -OnlyUnmanaged `
    -OutputPath "Unmanaged-Devices.csv"

# 2. Review and prioritize
Import-Csv "Unmanaged-Devices.csv" |
    Sort-Object FirstSeen |
    Format-Table ComputerDnsName, OSPlatform, OSVersion, FirstSeen

# 3. Create deployment plan
# 4. Monitor onboarding progress in workbook
```

---

## 🔧 Prerequisites

### For Documentation

- Modern web browser or Markdown viewer
- No special permissions required

### For PowerShell Scripts

**Local Execution:**

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator privileges on target devices
- Defender module (built-in on Windows 10/11, Server 2016+)

**Remote Execution:**

- WinRM enabled on target devices (`Enable-PSRemoting -Force`)
- Network connectivity on port 5985 (HTTP) or 5986 (HTTPS)
- Administrator credentials for target devices

**Graph API Scripts:**

- Azure AD App Registration with API permissions:
  - `Machine.Read.All` (Application) **OR**
  - `Machine.ReadWrite.All` (Delegated)
- Tenant ID, Client ID, Client Secret
- Security Reader role (minimum)

### For Azure Workbook

- Microsoft 365 Defender with Advanced Hunting enabled
- Azure subscription with Log Analytics workspace (optional)
- Permissions:
  - Security Reader (minimum)
  - Workbook Contributor (to deploy)

---

## 📖 Citation Standards

All scripts and documentation follow comprehensive citation standards:

### Documentation References

- Inline citations using Markdown footnote syntax: `[^1](URL)`
- References section at end of each document
- Authoritative Microsoft Learn URLs
- Version-specific cmdlet documentation

### PowerShell Script References

- `.REFERENCES` section in comment-based help
- Inline comments with `# Reference: URL` before code blocks
- Example:

  ```powershell
  # Query SENSE operational log for errors and warnings
  # Reference: https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes
  $ErrorEvents = Get-WinEvent -FilterHashtable @{
      LogName = 'Microsoft-Windows-SENSE/Operational'
      Level = 2,3
  }
  ```

---

## 🌏 Australian Localization

All scripts and documentation are configured for **Australian (AU) region** by default:

### Regional Endpoints

**Test-MDEConnectivity.ps1:**

- Default region: `AU`
- Telemetry: `au.vortex-win.data.microsoft.com`
- Cyber events: `au-v20.events.data.microsoft.com`
- Commands: `winatp-gw-aue.microsoft.com`

### Date/Time Format

All PowerShell scripts use **Australian date/time format**:

- **Display Format**: `dd/MM/yyyy HH:mm:ss` (e.g., "17/01/2025 14:30:45")
- **Filename Format**: `yyyyMMdd-HHmmss` (e.g., "20250117-143045")
- Applies to: Timestamp fields, CSV exports, log entries

### Log File Format (Get-MDEStatus-Log.txt)

All validation results are automatically logged with **comprehensive key=value pairs** for intelligent parsing:

**Format:** Structured log entries with all result fields separated by `|` delimiter

**Example Log Entry:**

`Timestamp=17/01/2025 14:30:45 | Hostname=WORKSTATION01 | Reachable=True | ValidationMethod=CIM-WSMan | HealthStatus=Healthy | DefenderInstalled=True | OnboardingState=Onboarded | OnboardingStateValue=1 | AMRunningMode=Normal | AMServiceEnabled=True | RealTimeProtectionEnabled=True | BehaviorMonitorEnabled=True | IsTamperProtected=True | TamperProtectionSource=Intune | AntivirusSignatureVersion=1.439.224.0 | SignatureAgeHours=15.42 | SENSEServiceStatus=Running | DiagTrackServiceStatus=Running | RecentSENSEErrors=0 | LastSENSEError=None | ErrorMessage=None`

**Fields Included:**

- `Timestamp` - Australian date/time format
- `Hostname` - Computer name validated
- `Reachable` - Network connectivity status
- `ValidationMethod` - Method used (CIM-WSMan, WMI-DCOM, Registry, Service)
- `HealthStatus` - Overall health determination
- `DefenderInstalled` - Installation status
- `OnboardingState` - Onboarding status (Onboarded/NotOnboarded/Unknown)
- `OnboardingStateValue` - Registry value (0/1)
- `AMRunningMode` - Antimalware running mode
- `AMServiceEnabled` - Service enabled status
- `RealTimeProtectionEnabled` - Real-time protection status
- `BehaviorMonitorEnabled` - Behavior monitoring status
- `IsTamperProtected` - Tamper protection status
- `TamperProtectionSource` - Source of tamper protection
- `AntivirusSignatureVersion` - Current signature version
- `SignatureAgeHours` - Age of signatures in hours
- `SENSEServiceStatus` - MDE sensor service status
- `DiagTrackServiceStatus` - Diagnostic tracking service status
- `RecentSENSEErrors` - Count of recent errors
- `LastSENSEError` - Most recent error description
- `ErrorMessage` - Validation error if any

**Parsing Example (PowerShell):**

```powershell
# Read and parse log entries
$LogEntries = Get-Content "Get-MDEStatus-Log.txt" | ForEach-Object {
    $Fields = @{}
    $_.Split(' | ') | ForEach-Object {
        $Key, $Value = $_.Split('=', 2)
        $Fields[$Key] = $Value
    }
    [PSCustomObject]$Fields
}

# Filter for unhealthy devices
$LogEntries | Where-Object { $_.HealthStatus -ne 'Healthy' }

# Find devices with outdated signatures
$LogEntries | Where-Object { [double]$_.SignatureAgeHours -gt 24 }
```

### Documentation Updates

All example endpoints reference AU services:

- ✅ `au.vortex-win.data.microsoft.com` (not `us.vortex-win.data.microsoft.com`)
- ✅ `Test-NetConnection au.vortex-win.data.microsoft.com -Port 443`

### Global Services (Tenant-Based Routing)

These remain global as they route based on tenant location:

- `security.microsoft.com` (Microsoft 365 Defender portal)
- `api.security.microsoft.com` (Graph API endpoint)
- `login.microsoftonline.com` (Authentication)

---

## 🔄 Migration from Legacy Scripts

If you're using the archived scripts, migrate to **Get-MDEStatus.ps1**:

### Migration Guide

**Before (5 separate scripts):**

```powershell
# CIM validation
.\Get-MDECimStatus.ps1 -ComputerName "DEVICE01"

# WMI validation
.\Get-MDEWmiStatus.ps1 -ComputerName "DEVICE02"

# Registry validation with event log check
.\Get-MDERegistryStatus.ps1 -ComputerName "DEVICE03" -CheckEventLog

# Bulk deployment validation
.\Test-MDEDeploymentStatus.ps1 -CsvPath "devices.csv"
```

**After (1 unified script):**

```powershell
# Automatic method selection (tries CIM → WMI → Registry → Service)
.\Get-MDEStatus.ps1 -ComputerName "DEVICE01"

# Force specific method if needed
.\Get-MDEStatus.ps1 -ComputerName "DEVICE02" -PreferredMethod WMI

# Event log checking now runs by default
.\Get-MDEStatus.ps1 -ComputerName "DEVICE03"

# Bulk validation with same CSV format
.\Get-MDEStatus.ps1 -CsvPath "devices.csv"
```

### Benefits of Consolidation

- ✅ Single script to maintain and update
- ✅ Event log checking now standard (no `-CheckEventLog` switch needed)
- ✅ Intelligent fallback eliminates need for method selection
- ✅ Consistent output format across all methods
- ✅ Reduced training burden for new team members

---

## 📈 Best Practices

### 1. Daily Operations

- ✅ Review Azure Workbook daily for "Devices Ready for Onboarding"
- ✅ Investigate devices with >7 days no communication
- ✅ Maintain >95% onboarding compliance rate

### 2. Bulk Validation

- ✅ Use parallel execution with ThrottleLimit 10-20 for best performance
- ✅ Schedule validation during off-peak hours for large device counts
- ✅ Always specify `-Credential` parameter for non-domain environments

### 3. Troubleshooting

- ✅ Start with `Get-MDEStatus.ps1` (automatic method selection)
- ✅ If issues persist, use `-PreferredMethod Registry` for definitive status
- ✅ Escalate to MDE Client Analyzer for deep diagnostics
- ✅ Test connectivity with `Test-MDEConnectivity.ps1` before investigating service issues

### 4. Compliance Reporting

- ✅ Export monthly inventory via `Export-MDEInventoryFromGraph.ps1`
- ✅ Store historical reports for trending and audit trails
- ✅ Cross-reference Graph API exports with local validation samples

### 5. Documentation

- ✅ Always check [INDEX.md](./docs/INDEX.md) for latest guidance
- ✅ Refer to method-specific documentation for detailed instructions
- ✅ Follow inline references in scripts for cmdlet documentation

---

## 🆘 Troubleshooting

### Common Issues

#### Issue: "Access Denied" when running scripts

**Cause:** Insufficient permissions or execution policy

**Resolution:**

```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single script
PowerShell.exe -ExecutionPolicy Bypass -File .\Get-MDEStatus.ps1
```

---

#### Issue: Remote validation fails

**Cause:** WinRM not enabled on target device

**Resolution:**

```powershell
# On target device (run as Administrator)
Enable-PSRemoting -Force

# Test WinRM connectivity from source
Test-WSMan -ComputerName "TARGET-DEVICE"
```

---

#### Issue: Graph API authentication fails

**Cause:** Incorrect tenant ID, client ID, or insufficient permissions

**Resolution:**

1. Verify App Registration in Azure Portal → Azure AD → App registrations
2. Check API permissions:
   - Required: `Machine.Read.All` (Application permission)
   - Ensure admin consent granted
3. Verify client secret hasn't expired
4. Test authentication:

   ```powershell
   # Copy authentication code from script and test
   $TenantId = "your-tenant-id"
   $ClientId = "your-client-id"
   $ClientSecret = "your-client-secret"

   $Body = @{
       Grant_Type = 'client_credentials'
       Scope = 'https://api.securitycenter.microsoft.com/.default'
       Client_Id = $ClientId
       Client_Secret = $ClientSecret
   }

   Invoke-RestMethod -Method Post `
       -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
       -Body $Body
   ```

---

#### Issue: Connectivity tests fail

**Cause:** Firewall blocking or proxy misconfiguration

**Resolution:**

```powershell
# 1. Test connectivity
.\Test-MDEConnectivity.ps1 -Region AU -Verbose -TestProxy

# 2. Check proxy configuration
netsh winhttp show proxy

# 3. Configure proxy if needed
netsh winhttp set proxy proxy-server="proxy.contoso.com:8080" bypass-list="<local>"

# 4. Whitelist MDE endpoints in firewall
# See Method 6 documentation for complete URL list
```

---

#### Issue: Workbook shows "No data available"

**Cause:** Advanced Hunting has no data for selected time range

**Resolution:**

1. Verify devices are onboarded and reporting to MDE
2. Increase time range to "Last 30 days"
3. Check Advanced Hunting permissions (Security Reader required)
4. Verify filters aren't excluding all data

---

### Getting Help

**Documentation:**

- [Documentation Hub](./docs/INDEX.md)
- Method-specific guides in [docs/](./docs/) folder
- Script help: `Get-Help .\Get-MDEStatus.ps1 -Full`

**Microsoft Resources:**

- [MDE Troubleshooting](https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding)
- [MDE Client Analyzer](https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows)
- [Advanced Hunting Schema](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables)

---

## 📜 License

See [LICENSE](../../LICENSE) file in repository root.

---

## 🤝 Contributing

This toolkit follows enterprise documentation standards:

- **[Diátaxis Framework](https://diataxis.fr/)** for documentation structure
- **[ALCOA-C Principles](https://www.fda.gov/media/119267/download)** for data integrity
- **Docs-as-Code** methodology with version control
- Comprehensive inline citations with authoritative sources

When contributing:

1. Follow existing citation standards (see [Citation Standards](#-citation-standards))
2. Test all code on PowerShell 5.1 and 7.x
3. Update relevant documentation
4. Ensure AU region defaults where applicable

---

## 📅 Version History

| Version | Date       | Changes                                                                     |
| ------- | ---------- | --------------------------------------------------------------------------- |
| 3.0.0   | 2025-01-17 | Added Get-MDEClientAnalyzer.ps1 for automated analyzer download/extraction  |
| 2.6.0   | 2025-01-17 | Test-MDEConnectivity.ps1 v2.0: Gateway Architecture endpoints + criticality |
| 2.5.0   | 2025-01-17 | Comprehensive key=value log format with all fields for intelligent parsing  |
| 2.4.0   | 2025-01-17 | Added OnboardingState to console output during bulk validation              |
| 2.3.0   | 2025-01-17 | PowerShell 5.1 compatibility with sequential processing fallback            |
| 2.2.0   | 2025-01-17 | Thread-safe logging with synchronized collections (PS7+)                    |
| 2.1.0   | 2025-01-17 | Fixed CIM/WMI DefenderInstalled detection and service status collection     |
| 2.0.0   | 2025-01-17 | Updated all date/time formats to Australian standard (dd/MM/yyyy)           |
| 1.1.0   | 2025-01-17 | Added port 80 fallback diagnostics to Test-MDEConnectivity.ps1              |
| 1.0.0   | 2025-01-17 | Consolidated 5 scripts into Get-MDEStatus.ps1 with intelligent fallback     |

---

## 🔗 Quick Links

- **[Start Here: Documentation Hub](./docs/INDEX.md)**
- **[Primary Script: Get-MDEStatus.ps1](./scripts/Get-MDEStatus.ps1)**
- **[Graph API Script: Export-MDEInventoryFromGraph.ps1](./scripts/Export-MDEInventoryFromGraph.ps1)**
- **[Connectivity Test: Test-MDEConnectivity.ps1](./scripts/Test-MDEConnectivity.ps1)**
- **[Analyzer Download: Get-MDEClientAnalyzer.ps1](./scripts/Get-MDEClientAnalyzer.ps1)**
- **[Azure Workbook Guide](./workbooks/README.md)**

---

**Need Help?** Start with the [Documentation Hub](./docs/INDEX.md) or run `Get-Help .\scripts\Get-MDEStatus.ps1 -Full` for detailed script usage.

**Ready to Validate?** Jump to [Quick Start](#-quick-start) above.
