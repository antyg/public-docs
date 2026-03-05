# Compliance & Configuration Baselines — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: **Near Parity**

---

## Executive Summary

Microsoft Intune achieves **Near Parity** with SCCM for compliance and configuration management, delivering approximately 85% capability coverage through a combination of device compliance policies, device configuration profiles, and the settings catalog. Intune's [settings catalog](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) provides access to **5,000+ Windows settings** (as of 2026), exceeding SCCM's Desired Configuration Management (DCM) coverage. [Custom compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-use-custom-settings) with PowerShell detection scripts replicate SCCM's script-based configuration items. Primary gaps are the lack of a **pre-built baseline library** (organizations must recreate SCCM baselines as Intune policies) and **multi-setting baseline objects** (Intune requires separate policies instead of single baseline containers). Intune provides significant advantages through **Conditional Access integration** (enforce compliance as resource access gate), **Endpoint Analytics** (user experience scoring and proactive insights), and the auto-generated settings catalog that stays current with Windows releases.

---

## Feature Parity Matrix

| SCCM Feature                                    | Intune Equivalent                                         | Parity Rating        | Licensing           | Notes                                                                                                        |
| ----------------------------------------------- | --------------------------------------------------------- | -------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Configuration Items (CIs)**                   | Device configuration profiles and compliance policies     | **Full Parity**      | Plan 1              | Intune separates configuration (profiles) from compliance (policies); functional equivalence                 |
| **Configuration Baselines**                     | Security baselines and custom compliance policies         | **Near Parity**      | Plan 1              | Security baselines for built-in scenarios; custom compliance for others; no single baseline container object |
| **Compliance Evaluation Schedules**             | Automatic evaluation (configurable interval)              | **Full Parity**      | Plan 1              | Intune evaluates on schedule (default 24h) and event-driven (policy change, reboot)                          |
| **Remediation (Auto-Remediation)**              | Remediations (PowerShell detection + remediation scripts) | **Full Parity**      | Plan 1              | Equivalent functionality with more granular control (user vs device context, 32-bit vs 64-bit)               |
| **DCM Settings (Registry, File, WMI, etc.)**    | Settings catalog (5000+ settings)                         | **Full Parity**      | Plan 1              | Settings catalog covers registry, policy CSPs, ADMX-backed GPOs, WMI-based settings                          |
| **Custom Script-Based CIs**                     | Custom compliance policies (PowerShell + JSON rules)      | **Full Parity**      | Plan 1              | PowerShell detection script + JSON rule definition; equivalent to SCCM script CIs                            |
| **Compliance Rules - Value Comparison**         | Custom compliance and settings catalog                    | **Full Parity**      | Plan 1              | Both support value comparisons (equals, not equals, greater than, less than, etc.)                           |
| **Compliance Rules - Existential**              | Custom compliance and settings catalog                    | **Full Parity**      | Plan 1              | Both support existence checks (file exists, registry key exists, service running)                            |
| **Compliance Rules - Expression/Complex Logic** | Custom compliance with PowerShell                         | **Near Parity**      | Plan 1              | PowerShell provides equivalent expression logic; no built-in expression editor                               |
| **Baseline Deployment to Collections**          | Policy assignment to Azure AD groups                      | **Full Parity**      | Plan 1              | Azure AD groups (static, dynamic) replace SCCM collections                                                   |
| **Compliance Reporting - Dashboard**            | Device compliance dashboard and reports                   | **Full Parity**      | Plan 1              | Equivalent visibility: compliance percentage, non-compliant devices, policy details                          |
| **Compliance Reporting - Detailed**             | Per-device compliance details                             | **Full Parity**      | Plan 1              | Click-through to device shows which settings are compliant/non-compliant                                     |
| **Compliance Reporting - Trends**               | Compliance trends over time                               | **Partial**          | Plan 1              | 28-day trend data in console; extended retention requires Azure Log Analytics                                |
| **Baseline Library (Pre-Built)**                | Security baselines (Windows, Edge, Defender, M365)        | **Partial**          | Plan 1              | Fewer pre-built baselines than SCCM; must recreate others as custom policies                                 |
| **Multi-Setting Baselines (Single Object)**     | Multiple individual policies                              | **Partial**          | Plan 1              | No single baseline container; must create separate configuration profiles and compliance policies            |
| **Baseline Versioning**                         | Policy change tracking via Graph API                      | **Partial**          | Plan 1              | No built-in versioning; must use external change tracking or policy backup solutions                         |
| **CI Data Export (XML)**                        | Graph API JSON export                                     | **Full Parity**      | Plan 1              | Export policies via Graph API for backup, version control, or migration                                      |
| **Settings Catalog (5000+ Settings)**           | Settings catalog                                          | **Intune Advantage** | Plan 1              | More settings than SCCM DCM; auto-generated from Windows CSPs; stays current                                 |
| **Conditional Access Integration**              | Conditional Access policies (Entra ID)                    | **Intune Advantage** | E3/E5 (Entra ID P1) | Enforce device compliance as gate for resource access; no SCCM equivalent                                    |
| **Endpoint Analytics**                          | Endpoint Analytics                                        | **Intune Advantage** | Plan 1              | User experience scoring, startup performance, app reliability insights; no SCCM equivalent                   |
| **Proactive Remediations Monitoring**           | Remediations dashboard                                    | **Intune Advantage** | Plan 1              | Track detection/remediation success rates, create custom health scripts                                      |
| **Attack Surface Reduction (ASR) Policies**     | Endpoint security policies                                | **Intune Advantage** | Plan 1              | Pre-built security policies for ASR rules, exploit protection, controlled folder access                      |
| **Security Baselines Auto-Update**              | Baseline version updates                                  | **Intune Advantage** | Plan 1              | Microsoft publishes updated baseline versions; deploy latest security recommendations                        |
| **Compliance Policy Templates**                 | Built-in compliance policy templates                      | **Full Parity**      | Plan 1              | Templates for Windows, iOS, Android, macOS with common compliance requirements                               |

---

## Key Findings

### Full/Near Parity Areas

#### Configuration Items and Baselines Architecture

SCCM's [configuration baselines](https://learn.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/create-configuration-baselines) group multiple configuration items (CIs) into a single deployable unit. Each CI defines settings (registry, file, WMI, Active Directory query, SQL query, script, etc.) and compliance rules (value comparison, existential checks, expression-based logic).

**SCCM architecture**:

```
Configuration Baseline: "Windows 11 Security Baseline v1.0"
  ├─ Configuration Item: BitLocker Encryption
  │   ├─ Setting: System Volume Encrypted (WMI query)
  │   └─ Rule: Encrypted = True
  ├─ Configuration Item: Windows Firewall
  │   ├─ Setting: Domain Profile Enabled (Registry)
  │   ├─ Setting: Private Profile Enabled (Registry)
  │   └─ Rules: Both = 1
  ├─ Configuration Item: Windows Defender
  │   ├─ Setting: Real-Time Protection Enabled (Registry)
  │   └─ Rule: Enabled = 1
  └─ Configuration Item: Local Admin Password (Script)
      ├─ Script: Check-LocalAdminPassword.ps1
      └─ Rule: Exit code = 0 (compliant)
```

**Intune achieves equivalent functionality through three mechanisms**:

**1. Device Configuration Profiles** (Settings application, not compliance checking):

```
Configuration Profile: "BitLocker Configuration"
  Policy Type: Endpoint Protection
  Settings:
    - Encrypt system drive: Yes
    - Encryption method: XTS-AES 256
    - Require TPM: Yes
    - Startup authentication: TPM only
```

**2. Device Compliance Policies** (Compliance evaluation and reporting):

```
Compliance Policy: "Windows 11 Security Requirements"
  Settings:
    - Minimum OS version: 10.0.22621.0 (Windows 11 22H2)
    - BitLocker required: Yes
    - Firewall enabled: Yes
    - Antivirus enabled: Yes
    - Microsoft Defender Antimalware: Required
```

**3. Custom Compliance Policies** (Script-based checks for settings not in built-in compliance):

```
Custom Compliance Policy: "Local Admin Password Compliance"
  Detection Script: Check-LocalAdminPassword.ps1
    (Returns JSON with compliance status)
  JSON Rules: Define expected values
  Assignment: All Devices
```

**Comparison**:

| Aspect                | SCCM Baseline                 | Intune Policies                               | Notes                                    |
| --------------------- | ----------------------------- | --------------------------------------------- | ---------------------------------------- |
| Grouping              | Single baseline object        | Multiple separate policies                    | SCCM advantage: single deployment unit   |
| Settings coverage     | DCM settings + scripts        | Settings catalog + scripts                    | Intune advantage: more built-in settings |
| Deployment            | Deploy baseline to collection | Assign policies to groups                     | Functional parity                        |
| Compliance evaluation | On schedule (default 7 days)  | On schedule (default 24 hours) + event-driven | Intune more frequent                     |
| Reporting             | Baseline compliance dashboard | Multiple policy compliance views              | SCCM advantage: single compliance view   |
| Remediation           | Auto-remediate per setting    | Remediations for scripts                      | Functional parity                        |

**Practical impact**: Organizations with 20-setting SCCM baseline must create 3-5 Intune policies (1 compliance policy for built-in checks, 2-3 configuration profiles for settings application, 1-2 custom compliance policies for script-based checks). More policy objects but equivalent functional outcome.

#### Settings Catalog (5000+ Settings)

Intune's [settings catalog](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) provides access to **5,000+ Windows settings** as of February 2026, auto-generated directly from Windows Configuration Service Providers (CSPs). This exceeds SCCM's Desired Configuration Management coverage.

**Settings catalog coverage**:

| Setting Category         | Example Settings                           | Count (Approx) |
| ------------------------ | ------------------------------------------ | -------------- |
| **Windows Settings**     | Registry-based OS configuration            | 2,000+         |
| **ADMX-Backed Policies** | All Group Policy settings from ADMX files  | 1,500+         |
| **Microsoft Edge**       | Browser policies, extension management     | 400+           |
| **Microsoft Office**     | Office app settings, update behavior       | 300+           |
| **Security Policies**    | BitLocker, Windows Defender, firewall, ASR | 500+           |
| **User Experience**      | Start menu, taskbar, notifications         | 200+           |
| **Network Settings**     | VPN, Wi-Fi, proxy configuration            | 100+           |

**Example: Windows Defender Antivirus settings catalog**:

```
Configuration Profile: "Defender Antivirus - Corporate Standard"
  Profile Type: Settings Catalog
  Platform: Windows 10 and later

  Settings Selected (from 100+ available Defender settings):
    Windows Defender Antivirus > Real-time Protection
      - Turn on behavior monitoring: Enabled
      - Scan all downloaded files and attachments: Enabled
      - Monitor file and program activity: Enabled
      - Turn on process scanning: Enabled

    Windows Defender Antivirus > Scan
      - Scan removable drives: Enabled
      - Turn on e-mail scanning: Disabled (using Exchange Online Protection)
      - Scan network files: Enabled
      - CPU usage limit during scan: 50%

    Windows Defender Antivirus > Signature Updates
      - Define file shares for downloading definition updates: \\server\updates
      - Define the order of sources for downloading definition updates:
          1. Internal definition update server
          2. Microsoft Update
          3. MMPC
```

**Settings catalog advantages over SCCM DCM**:

1. **Auto-generated from Windows**: Microsoft automatically adds new settings when Windows CSPs expand. SCCM DCM requires manual Configuration Item creation for new settings.

2. **Search and discovery**: Settings catalog includes search functionality. Type "BitLocker" to find all BitLocker-related settings across all CSPs.

3. **Dependency awareness**: Settings catalog shows setting dependencies. If "Enable BitLocker" requires "TPM configured," the catalog displays the relationship.

4. **Documentation integration**: Each setting links to official Microsoft documentation explaining purpose, supported values, and prerequisites.

5. **Conflict detection**: Settings catalog warns when multiple profiles configure the same setting with different values.

**SCCM DCM advantages**:

1. **Baseline grouping**: Multiple CIs group into single baseline object. Settings catalog requires separate profiles per category.

2. **Custom setting types**: SCCM supports Active Directory query, SQL query, IIS metabase settings. Settings catalog limited to Windows CSPs and ADMX.

3. **Complex expression rules**: SCCM CI rules support complex expressions (e.g., "If RAM > 8GB AND Disk > 256GB, then require BitLocker"). Settings catalog rules are simpler.

#### Custom Compliance Policies (Script-Based Configuration Items)

[Custom compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-use-custom-settings) replicate SCCM's script-based configuration items with PowerShell detection scripts and JSON rule definitions.

**SCCM script-based CI**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt thresholds for your environment.

```powershell
# SCCM CI: Check Minimum RAM
# Discovery Script
$TotalRAM = (Get-CimInstance -ClassName Win32_PhysicalMemory |
    Measure-Object -Property Capacity -Sum).Sum / 1GB

if ($TotalRAM -ge 8) {
    return "Compliant"
} else {
    return "Non-Compliant"
}

# Compliance Rule: Discovery script returns "Compliant"
# Severity: Critical
# Report non-compliance: Yes
```

**Intune custom compliance equivalent**:

```powershell
# Intune Custom Compliance: Check Minimum RAM
# Detection Script (must return JSON)
$TotalRAM = (Get-CimInstance -ClassName Win32_PhysicalMemory |
    Measure-Object -Property Capacity -Sum).Sum / 1GB

$hash = @{
    MinimumRAM = $TotalRAM
}

return $hash | ConvertTo-Json -Compress
```

```json
// JSON Rules File
{
  "Rules": [
    {
      "SettingName": "MinimumRAM",
      "Operator": "IsEquals",
      "DataType": "Int64",
      "Operand": 8,
      "MoreInfoUrl": "https://contoso.com/hardware-requirements",
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "Insufficient RAM Detected",
          "Description": "This device has less than 8GB RAM. Please contact IT to upgrade memory."
        }
      ]
    }
  ]
}
```

**Custom compliance capabilities**:

| Feature                      | SCCM Script CI                                           | Intune Custom Compliance            | Notes                 |
| ---------------------------- | -------------------------------------------------------- | ----------------------------------- | --------------------- |
| Detection language           | PowerShell, VBScript, JScript                            | PowerShell (Windows), Shell (Linux) | Intune supports Linux |
| Return format                | String, Boolean, Integer                                 | JSON (structured data)              | Intune more flexible  |
| Multiple settings per script | No (one value per CI)                                    | Yes (JSON with multiple properties) | Intune advantage      |
| Compliance operators         | Equals, NotEquals, GreaterThan, LessThan, Between, OneOf | Same operators                      | Parity                |
| Data types                   | String, Integer, DateTime, Boolean                       | Same types                          | Parity                |
| Remediation guidance         | Not built-in                                             | RemediationStrings in JSON          | Intune advantage      |
| User context execution       | No (system context only)                                 | Supports user context               | Intune advantage      |

**Example: Complex multi-setting custom compliance**

Check multiple security requirements in single script:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt security checks for your environment.

```powershell
# Detection Script: Security Configuration Check
$compliance = @{}

# Check 1: LAPS password age
try {
    $lapsPassword = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\LAPS" -Name PasswordAge -ErrorAction Stop
    $compliance.LAPSPasswordAge = $lapsPassword.PasswordAge
} catch {
    $compliance.LAPSPasswordAge = -1
}

# Check 2: Last Windows Update installation
$lastUpdate = (Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1).InstalledOn
$daysSinceUpdate = (New-TimeSpan -Start $lastUpdate -End (Get-Date)).Days
$compliance.DaysSinceLastUpdate = $daysSinceUpdate

# Check 3: Required applications installed
$requiredApps = @("Microsoft Defender for Endpoint", "Microsoft Edge", "Company VPN Client")
$installedApps = Get-Package | Select-Object -ExpandProperty Name
$compliance.RequiredAppsInstalled = ($requiredApps | Where-Object { $installedApps -contains $_ }).Count

# Check 4: Disk encryption status
$bitlockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeType -eq "OperatingSystem" }
$compliance.OSVolumeEncrypted = ($bitlockerVolumes.ProtectionStatus -eq "On")

return $compliance | ConvertTo-Json -Compress
```

```json
// JSON Rules for Multi-Check Compliance
{
  "Rules": [
    {
      "SettingName": "LAPSPasswordAge",
      "Operator": "IsEquals",
      "DataType": "Int64",
      "Operand": 30,
      "MoreInfoUrl": "https://contoso.com/laps-policy"
    },
    {
      "SettingName": "DaysSinceLastUpdate",
      "Operator": "LessThan",
      "DataType": "Int64",
      "Operand": 30,
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "Windows Updates Overdue",
          "Description": "This device has not installed Windows updates in over 30 days. Please install pending updates immediately."
        }
      ]
    },
    {
      "SettingName": "RequiredAppsInstalled",
      "Operator": "IsEquals",
      "DataType": "Int64",
      "Operand": 3,
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "Required Applications Missing",
          "Description": "One or more required applications are not installed. Check Company Portal for required apps."
        }
      ]
    },
    {
      "SettingName": "OSVolumeEncrypted",
      "Operator": "IsEquals",
      "DataType": "Boolean",
      "Operand": true,
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "BitLocker Encryption Required",
          "Description": "The operating system drive is not encrypted. Contact IT to enable BitLocker."
        }
      ]
    }
  ]
}
```

This single custom compliance policy replaces 4 SCCM configuration items with more efficient execution (one script run vs four) and unified reporting.

#### Remediations (Proactive Remediations)

[Remediations](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations) (formerly Proactive Remediations) provide automatic remediation of configuration drift, equivalent to SCCM's auto-remediation capability.

**How Remediations work**:

1. **Detection script** runs on schedule (hourly, daily, weekly)
2. Script checks configuration state
3. If compliant: Exit 0 (no remediation needed)
4. If non-compliant: Exit 1 (trigger remediation)
5. **Remediation script** runs when detection exits 1
6. Remediation script corrects configuration
7. Next detection run validates remediation success

**Example: Automatic OneDrive Known Folder Move remediation**

> **Note**: The following is a conceptual example illustrating the pattern. Test thoroughly before production deployment.

```powershell
# Detection Script
$odRegPath = "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"
$kfmState = (Get-ItemProperty -Path $odRegPath -Name "KFMConfiguredFolderState" -ErrorAction SilentlyContinue).KFMConfiguredFolderState

# KFMConfiguredFolderState = 31 means Desktop, Documents, Pictures all redirected
if ($kfmState -eq 31) {
    Write-Output "OneDrive KFM configured"
    exit 0  # Compliant
} else {
    Write-Output "OneDrive KFM not configured"
    exit 1  # Trigger remediation
}
```

```powershell
# Remediation Script
try {
    # Configure OneDrive Known Folder Move via registry
    $odRegPath = "HKCU:\Software\Policies\Microsoft\OneDrive"
    if (-not (Test-Path $odRegPath)) {
        New-Item -Path $odRegPath -Force | Out-Null
    }

    # Set KFM policy (Desktop=1, Documents=2, Pictures=4; 1+2+4=7)
    Set-ItemProperty -Path $odRegPath -Name "KFMSilentOptIn" -Value "7" -Force

    # Restart OneDrive to apply
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" -ArgumentList "/background"

    Write-Output "OneDrive KFM configured successfully"
    exit 0
} catch {
    Write-Error "Failed to configure OneDrive KFM: $_"
    exit 1
}
```

**Remediation configuration**:

```
Name: Configure OneDrive Known Folder Move
Description: Automatically redirect Desktop, Documents, and Pictures to OneDrive
Detection script: Detect-OneDriveKFM.ps1
Remediation script: Remediate-OneDriveKFM.ps1
Run script in 64-bit PowerShell: Yes
Run this script using logged on credentials: Yes (user context)
Enforce script signature check: No
Schedule: Daily at 12:00 PM
Assignment: All Users
```

**Remediations reporting**:

Intune console shows:

- **Detection status**: Percentage of devices where detection ran successfully
- **Compliant devices**: Percentage where detection exited 0
- **Remediation attempts**: Percentage where remediation triggered
- **Remediation success**: Percentage where remediation script exited 0
- **Trends**: 30-day compliance trend graph

**Example use cases**:

| Scenario                   | Detection Check                           | Remediation Action                                |
| -------------------------- | ----------------------------------------- | ------------------------------------------------- |
| **OneDrive KFM**           | Check KFM registry state                  | Configure KFM policies, restart OneDrive          |
| **Stale Temp Files**       | Check C:\Temp folder size                 | Delete files older than 30 days                   |
| **Windows Update Health**  | Check Windows Update service status       | Restart service, clear SoftwareDistribution cache |
| **Registry Drift**         | Check security registry values            | Set registry values to required state             |
| **Certificate Expiration** | Check certificate expiration dates        | Renew certificates via SCEP or internal CA        |
| **Application Health**     | Check if LOB app is installed and current | Reinstall or update LOB app                       |

**Comparison to SCCM auto-remediation**:

| Feature                     | SCCM                                   | Intune Remediations                     |
| --------------------------- | -------------------------------------- | --------------------------------------- |
| Detection frequency         | Configurable (default 7 days)          | Configurable (hourly to monthly)        |
| Remediation trigger         | Automatic when non-compliant           | Automatic when detection exits 1        |
| User vs device context      | Device context only                    | Both user and device context            |
| 32-bit vs 64-bit PowerShell | Automatic based on client architecture | Configurable per remediation            |
| Reporting granularity       | Baseline compliance percentage         | Per-device detection/remediation status |
| Script signing              | Not enforced                           | Optional enforcement                    |

#### Compliance Reporting

Both platforms provide comprehensive compliance reporting with click-through drill-down.

**SCCM compliance reporting**:

- **Compliance dashboard**: Baseline compliance percentage, non-compliant devices count, compliance trend
- **Baseline deployment report**: Per-device compliance status for specific baseline
- **CI details**: Which configuration items are compliant/non-compliant per device
- **SQL Reporting Services**: Custom reports via SSRS

**Intune compliance reporting**:

- **Device compliance dashboard**: Overall compliance percentage, non-compliant devices, compliance policies list
- **Compliance policy report**: Per-policy compliance statistics, non-compliant devices list
- **Device details**: Click-through to device shows which settings failed compliance, error messages
- **Trends**: 28-day compliance trend (extended retention via Azure Log Analytics)

**Report data export**:

> **Note**: The following is a conceptual example illustrating the pattern. Requires appropriate Graph API permissions.

```powershell
# Export compliance data via Graph API
$uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicySettingStateSummaries"
$complianceData = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get

# Export to CSV
$complianceData.value | Export-Csv -Path "Intune-Compliance-Export.csv" -NoTypeInformation
```

**Functional parity achieved** for core reporting. SCCM advantage: custom SSRS reports. Intune advantage: built-in trend graphs and Power BI integration.

---

### Partial Parity / Gaps

#### Baseline Library (Pre-Built Baselines)

SCCM includes pre-built configuration baselines for common scenarios. Intune provides [security baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) for specific products but has a smaller library.

**SCCM pre-built baselines** (partial list):

- Windows 10/11 Security Baseline
- Windows Server Security Baseline
- Microsoft Edge Browser
- Internet Explorer 11
- Windows Firewall
- Office 365 ProPlus (Microsoft 365 Apps)
- SQL Server
- Exchange Server
- SharePoint Server

**Intune security baselines** (February 2026):

- **Windows Security Baseline** (Windows 10/11)
  - Based on Microsoft Security Compliance Toolkit
  - Covers BitLocker, Windows Defender, firewall, account policies, user rights
  - Updated quarterly by Microsoft Security team
- **Microsoft Edge Security Baseline**
  - Browser security settings, extension policies, update behavior
- **Microsoft Defender for Endpoint Baseline**
  - ASR rules, exploit protection, controlled folder access, network protection
- **Windows 365 Security Baseline**
  - Cloud PC-specific security settings

**Gap**: SCCM has broader baseline library (Server products, Office, Exchange, SharePoint). Intune focuses on workstation and cloud product baselines.

**Workaround**: Recreate missing baselines as Intune policies using settings catalog or custom compliance. Organizations must invest time to rebuild SCCM baselines in Intune format.

**Example: Recreating SCCM "Windows Firewall" baseline in Intune**

SCCM baseline:

```
Configuration Baseline: Windows Firewall
  ├─ CI: Domain Profile
  │   ├─ Setting: Firewall Enabled (Registry)
  │   └─ Rule: Value = 1
  ├─ CI: Private Profile
  │   ├─ Setting: Firewall Enabled (Registry)
  │   └─ Rule: Value = 1
  ├─ CI: Public Profile
  │   ├─ Setting: Firewall Enabled (Registry)
  │   ├─ Setting: Inbound Connections Blocked (Registry)
  │   └─ Rules: Enabled = 1, Inbound = Block
```

Intune recreation:

```
Configuration Profile: "Windows Defender Firewall"
  Profile Type: Settings Catalog
  Settings:
    Firewall > Domain Profile
      - Enable Firewall: Enabled
      - Default Inbound Action: Block
      - Default Outbound Action: Allow
    Firewall > Private Profile
      - Enable Firewall: Enabled
      - Default Inbound Action: Block
      - Default Outbound Action: Allow
    Firewall > Public Profile
      - Enable Firewall: Enabled
      - Default Inbound Action: Block All Connections
      - Default Outbound Action: Allow

Compliance Policy: "Windows Firewall Compliance"
  Settings:
    - Firewall: Required
```

**Migration effort**: Low-complexity baselines (3-5 settings) take 15-30 minutes to recreate. High-complexity baselines (20+ settings with scripts) take 2-4 hours.

#### Multi-Setting Baselines (Single Container Object)

SCCM baselines are **single deployment objects** that group multiple configuration items. Intune has **no equivalent single baseline container** — organizations must create multiple policies.

**SCCM single deployment**:

```
Baseline: "Corporate Security Standard v2.0"
  Contains: 15 configuration items (25 total settings)
  Deployment: Single deployment to "All Workstations" collection
  Reporting: Single compliance percentage for entire baseline
```

**Intune multi-policy equivalent**:

```
Compliance Policy: "Security Compliance - Corporate Standard"
  Contains: 8 built-in compliance settings

Configuration Profile 1: "Security Settings - BitLocker"
  Profile Type: Endpoint Protection
  Contains: 6 BitLocker settings

Configuration Profile 2: "Security Settings - Defender"
  Profile Type: Endpoint Security > Antivirus
  Contains: 8 Defender settings

Custom Compliance Policy: "Security Compliance - Custom Checks"
  Detection Script: Check-SecurityBaseline.ps1
  JSON Rules: 3 custom security checks

Remediation: "Security Baseline Auto-Fix"
  Detection + Remediation Scripts: Fix common drift

Total: 5 separate policy objects
```

**Implications**:

| Aspect                   | SCCM Single Baseline             | Intune Multi-Policy                   | Impact                                |
| ------------------------ | -------------------------------- | ------------------------------------- | ------------------------------------- |
| **Deployment effort**    | Deploy once                      | Deploy 5 times                        | Medium administrative overhead        |
| **Group assignment**     | One assignment                   | Five assignments (can use same group) | Low (use same Azure AD group for all) |
| **Compliance reporting** | Single compliance view           | Must aggregate 5 policy views         | Medium reporting complexity           |
| **Version control**      | Baseline version number          | Must track versions per policy        | Medium overhead                       |
| **Change management**    | Update baseline version          | Update multiple policies              | Medium overhead                       |
| **Rollback**             | Deploy previous baseline version | Roll back multiple policies           | Medium complexity                     |

**Workaround strategies**:

**1. Naming convention** (recommended):

```
Compliance Policy: "CORP-BASELINE-v2.0-Compliance"
Configuration Profile: "CORP-BASELINE-v2.0-BitLocker"
Configuration Profile: "CORP-BASELINE-v2.0-Defender"
Custom Compliance: "CORP-BASELINE-v2.0-CustomChecks"
Remediation: "CORP-BASELINE-v2.0-AutoFix"
```

All policies share "CORP-BASELINE-v2.0" prefix for easy identification and filtering.

**2. Azure AD group standardization**:

```
Group Name: "Devices-Corporate-Security-Baseline-v2.0"
  All policies assigned to same group
  Single group membership change affects all policies
```

**3. Policy backup and version control** (PowerShell automation):

> **Note**: The following is a conceptual example illustrating the pattern. Adapt policy names for your environment.

```powershell
# Export all baseline policies to JSON for version control
$policies = @(
    "CORP-BASELINE-v2.0-Compliance",
    "CORP-BASELINE-v2.0-BitLocker",
    "CORP-BASELINE-v2.0-Defender",
    "CORP-BASELINE-v2.0-CustomChecks",
    "CORP-BASELINE-v2.0-AutoFix"
)

foreach ($policy in $policies) {
    $policyData = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies?`$filter=displayName eq '$policy'"
    $policyData | ConvertTo-Json -Depth 10 | Out-File "Baseline-Backup\$policy.json"
}
```

Commit JSON files to Git repository for version control and audit trail.

**4. Reporting consolidation** (Power BI):

Create Power BI report that queries Intune Data Warehouse for all baseline-related policies and aggregates compliance into single dashboard.

**Impact assessment**: Medium. More policy objects increase administrative overhead but do not reduce functional capability. Organizations with mature change management processes adapt quickly. Organizations with limited Intune experience find multi-policy management challenging initially.

#### Baseline Versioning

SCCM baselines support built-in versioning with change tracking. Intune policies do not have native versioning.

**SCCM baseline versioning**:

```
Baseline: "Corporate Security Standard"
  Version 1.0 (Created: 2024-01-15)
    - 10 configuration items
  Version 2.0 (Created: 2025-06-20)
    - Added 3 new configuration items
    - Modified 2 existing items
    - Change notes: "Added Windows 11 23H2 requirements"
  Version 3.0 (Created: 2026-01-10)
    - Removed deprecated IE11 configuration item
    - Added Edge security settings
```

SCCM tracks which devices have which baseline version deployed and compliance per version.

**Intune**: No built-in policy versioning. Policy changes are immediate — no "version 1" vs "version 2" concept.

**Workarounds**:

**1. Policy naming with version suffix**:

```
Instead of: "Corporate Security Baseline"
Use: "Corporate Security Baseline v3.0"

When creating new version:
  1. Duplicate "v2.0" policy
  2. Rename to "v3.0"
  3. Modify settings in v3.0
  4. Test v3.0 with pilot group
  5. Assign v3.0 to production group
  6. Unassign v2.0 from production group
  7. Archive v2.0 (do not delete for rollback capability)
```

**2. Graph API change auditing**:

> **Note**: The following is a conceptual example illustrating the pattern. Requires appropriate Graph API permissions.

```powershell
# Query Azure AD audit logs for policy changes
$uri = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$filter=activityDisplayName eq 'Update policy'"
$changes = Invoke-MgGraphRequest -Uri $uri -Method Get

$changes.value | Where-Object {$_.targetResources.displayName -like "Corporate*"} |
    Select-Object activityDateTime, initiatedBy, targetResources |
    Export-Csv -Path "Policy-Change-Audit.csv"
```

**3. Third-party backup solutions**:

- **Intune Backup & Restore** (community PowerShell tool)
- **IntuneCD** (Infrastructure as Code for Intune)
- **Enterprise backup solutions** (Veeam Backup for Microsoft 365, etc.)

**Impact**: Low-Medium. Versioning lack complicates change management and rollback but does not prevent compliance management. Organizations must implement external version tracking.

---

### Intune Advantages

#### Conditional Access Integration

[Conditional Access](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview) is the **most significant Intune compliance advantage** with no SCCM equivalent. Conditional Access policies in Azure AD/Entra ID enforce device compliance as a **gate for accessing corporate resources**.

**How it works**:

1. User attempts to access resource (Exchange Online, SharePoint, SaaS app)
2. Azure AD evaluates Conditional Access policies
3. Policy requires "Device must be compliant"
4. Azure AD queries Intune for device compliance state
5. If compliant: Grant access
6. If non-compliant: Block access + display remediation instructions
7. User remediates compliance issue (installs update, enables BitLocker, etc.)
8. Intune re-evaluates compliance
9. Azure AD automatically grants access when device becomes compliant

**Example Conditional Access policy**:

```
Policy Name: "Require Compliant Devices for Exchange Online"
Assignments:
  Users: All Users
  Cloud apps: Office 365 Exchange Online
  Conditions:
    - Device platforms: Windows, iOS, Android
Access controls:
  Grant access:
    ☑ Require device to be marked as compliant
    ☐ Require approved client app
    ☐ Require app protection policy
  Session controls: None

Result: Users can only access Exchange Online email from compliant devices
```

**Common Conditional Access scenarios**:

| Resource                             | Compliance Requirement                    | User Experience                                                               |
| ------------------------------------ | ----------------------------------------- | ----------------------------------------------------------------------------- |
| **Exchange Online**                  | Device compliant + MFA                    | Non-compliant device blocked; user sees "Contact IT to make device compliant" |
| **SharePoint Online**                | Device compliant + Hybrid Azure AD joined | BYOD devices blocked; only corporate devices access SharePoint                |
| **Azure Portal**                     | Device compliant + Entra ID P2 (PIM)      | Admins must use compliant devices to access Azure Portal                      |
| **SaaS Apps (Salesforce, Workday)**  | Device compliant + approved app           | Unmanaged devices blocked; only managed devices with approved apps            |
| **On-Premises Apps (via App Proxy)** | Device compliant + network location       | Remote users must have compliant device + VPN                                 |

**Compliance requirements enforced via Conditional Access**:

```
Compliance Policy: "Exchange Online Access Requirements"
  Settings:
    - Minimum OS: Windows 10 1809
    - BitLocker: Required
    - Firewall: Required
    - Antivirus: Required
    - Microsoft Defender Antimalware: Real-time protection enabled
    - Minimum threat level: Medium (Defender ATP signals)
    - Password: Minimum 8 characters
    - Inactivity timeout: 15 minutes
    - Jailbroken/rooted devices: Blocked

Conditional Access Policy: "Enforce Compliance for Exchange"
  Requires: Device compliant (references compliance policy above)

User experience when non-compliant:
  1. User opens Outlook on non-compliant device
  2. Azure AD blocks authentication
  3. User sees: "Your device doesn't meet security requirements.
                 Please enable BitLocker encryption and try again.
                 For help, contact IT at helpdesk@contoso.com"
  4. User enables BitLocker
  5. Intune re-evaluates compliance (next check-in or manual sync)
  6. Device becomes compliant
  7. User refreshes Outlook → Access granted automatically
```

**Benefits**:

- **Automated enforcement**: No manual intervention required; access granted/revoked automatically based on compliance
- **Zero-trust architecture**: "Never trust, always verify" — compliance checked on every access attempt
- **User self-service**: Users can remediate compliance issues without IT involvement
- **Real-time protection**: Compromised or non-compliant devices immediately lose access

**SCCM comparison**: SCCM compliance is **report-only**. Non-compliant devices are flagged in reports, but access is not automatically blocked. IT must manually intervene to remediate or revoke access.

#### Endpoint Analytics

[Endpoint Analytics](https://learn.microsoft.com/en-us/mem/analytics/overview) provides data-driven insights into device health and user experience. SCCM has no equivalent capability.

**Endpoint Analytics capabilities**:

**1. Startup Performance Score**:

- Tracks device boot time from power-on to desktop ready
- Identifies devices with slow startups (>30 seconds)
- Identifies problematic startup processes consuming CPU/disk
- Provides regression analysis (startup performance trend over time)

**Example report**:

```
Overall Startup Performance Score: 72/100

Top Devices with Slow Startup:
  LAPTOP-1234: 95 seconds average boot time
    - Causes: OneDrive.exe (25s), AdobeUpdateService.exe (18s)

Top Problematic Startup Processes:
  1. AdobeUpdateService.exe
     - Adds 18 seconds to boot time
     - Installed on 450 devices
     - Recommendation: Disable auto-start, schedule updates separately

  2. Dell SupportAssist
     - Adds 12 seconds to boot time
     - Installed on 300 devices
     - Recommendation: Uninstall (not business-critical)
```

**2. User Experience Scores**:

- **App Reliability**: Application crash rate and hang rate
- **Battery Health**: Battery capacity degradation, battery life
- **Device Performance**: CPU/memory usage, disk health (SSD wear)
- **User Sentiment**: User-reported issues and feedback

**Example insights**:

```
App Reliability Issues Detected:
  Microsoft Teams: 15 crashes/1000 sessions (above threshold)
    - Affected users: 45
    - Common error: Out of memory exception
    - Recommendation: Upgrade devices to 16GB RAM

Battery Health Alerts:
  23 devices with <50% battery capacity
    - Recommendation: Replace batteries or devices
```

**3. Recommended Software**:

- Analyzes software install base across organization
- Identifies apps with:
  - High adoption (>50% of devices)
  - Low support burden (<5% of helpdesk tickets)
  - Good reliability (low crash rate)
- Recommends apps for standard deployment

**Example**:

```
Recommended for Deployment:
  7-Zip: Installed on 65% of devices, 0.2% support ticket rate
  Notepad++: Installed on 55% of devices, 0.1% support ticket rate

Not Recommended:
  Adobe Flash Player: 12% support ticket rate, deprecated technology
```

**4. Proactive Remediations Monitoring** (covered earlier):

- Tracks detection/remediation success rates
- Identifies devices where remediations repeatedly fail
- Provides health script templates (disk cleanup, Windows Update repair, etc.)

**SCCM comparison**: SCCM provides hardware inventory and software inventory but no user experience analytics, performance scoring, or predictive insights.

**Use cases**:

- **Device refresh planning**: Identify devices with degraded performance for replacement prioritization
- **Application optimization**: Find problematic apps increasing boot time or crashing frequently
- **Helpdesk efficiency**: Proactively remediate issues before users call helpdesk
- **User satisfaction**: Quantify user experience impact of IT changes

#### Security Baselines with Auto-Update

Intune [security baselines](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines) are pre-built configuration profiles maintained by Microsoft security teams. Microsoft periodically publishes **updated baseline versions** with latest security recommendations.

**Baseline update lifecycle**:

1. **Microsoft publishes baseline v1.0** (January 2025)
   - Includes security settings based on current threat landscape
   - Organization deploys v1.0 to all devices

2. **Microsoft publishes baseline v1.1** (July 2025)
   - Adds new ASR rules for emerging threats
   - Modifies BitLocker settings for hardware changes
   - Removes deprecated settings

3. **Intune console shows "Update Available"**
   - Organization reviews v1.1 changes (change log provided)
   - Organization tests v1.1 with pilot group
   - Organization updates production deployment to v1.1
   - Devices automatically receive new settings

**Example: Windows Security Baseline updates**

```
Windows Security Baseline for Windows 11 v23H2

Version History:
  v1.0 (January 2025): Initial release
  v1.1 (April 2025): Added ASR rule for credential theft
  v1.2 (July 2025): Updated BitLocker minimum PIN length to 8 digits
  v1.3 (October 2025): Added controlled folder access recommendations

Current Deployment: v1.2
Latest Available: v1.3

Changes in v1.3:
  + Defender > Controlled Folder Access: Enabled (NEW)
  + Defender > Protected Folders: Desktop, Documents, Pictures (NEW)
  ~ Defender > ASR Rules: Updated rule GUIDs for Windows 11 23H2
  - Internet Explorer > Enable Enhanced Protected Mode: Removed (IE deprecated)
```

**Benefits**:

- **Continuous improvement**: Security posture improves automatically as Microsoft updates baselines
- **Threat response**: Microsoft adds new protections in response to emerging threats
- **Reduced research**: Organizations don't need to monitor security bulletins and research best practices independently
- **Change tracking**: Microsoft provides detailed change logs for each baseline version

**SCCM comparison**: SCCM baselines are static. Microsoft publishes Security Compliance Toolkit updates, but organizations must manually:

1. Download new toolkit version
2. Import updated baselines into SCCM
3. Compare new vs old baseline
4. Test changes
5. Deploy updated baseline

Intune baseline updates are **in-place** — update existing deployment instead of creating new baseline.

#### Attack Surface Reduction Policies

Intune provides pre-built [endpoint security policies](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-policy) for Attack Surface Reduction, Exploit Protection, and other security controls. These are simplified, wizard-driven alternatives to settings catalog.

**Endpoint security policy types**:

| Policy Type                         | Purpose                                                             | Settings Count |
| ----------------------------------- | ------------------------------------------------------------------- | -------------- |
| **Antivirus**                       | Defender AV configuration (real-time protection, scans, exclusions) | 50+            |
| **Disk Encryption**                 | BitLocker configuration (TPM, recovery key, encryption method)      | 30+            |
| **Firewall**                        | Windows Defender Firewall rules and profiles                        | 40+            |
| **Endpoint Detection and Response** | MDE onboarding and configuration                                    | 20+            |
| **Attack Surface Reduction**        | ASR rules (block Office macros, credential theft, etc.)             | 20+            |
| **Account Protection**              | Credential Guard, Windows Hello for Business                        | 15+            |
| **Device Compliance**               | (Same as compliance policies)                                       | N/A            |

**Example: Attack Surface Reduction policy**

```
Policy Name: "ASR Rules - Corporate Standard"
Profile: Attack surface reduction rules
Platform: Windows 10 and later

Settings:
  Block executable content from email client and webmail: Audit
  Block all Office applications from creating child processes: Block
  Block Office applications from creating executable content: Block
  Block Office applications from injecting code into other processes: Block
  Block JavaScript or VBScript from launching downloaded executable content: Block
  Block execution of potentially obfuscated scripts: Audit
  Block Win32 API calls from Office macros: Block
  Block credential stealing from Windows local security authority subsystem: Block
  Block process creations originating from PSExec and WMI commands: Audit
  Block untrusted and unsigned processes that run from USB: Block
  Block Adobe Reader from creating child processes: Block
  Block persistence through WMI event subscription: Block

Assignment: All Devices
```

**ASR rule states**:

- **Block**: Rule actively blocks malicious behavior
- **Audit**: Rule logs events but does not block (for testing)
- **Disabled**: Rule not active
- **Not configured**: Use Windows default

**Benefits vs Settings Catalog**:

| Aspect              | Settings Catalog                     | Endpoint Security Policies                               |
| ------------------- | ------------------------------------ | -------------------------------------------------------- |
| **Complexity**      | Find settings among 5000+            | Pre-filtered to security settings only                   |
| **Discoverability** | Search required                      | Wizard guides through options                            |
| **Documentation**   | Per-setting links                    | Policy-level documentation                               |
| **Conflicts**       | Warns but requires manual resolution | Automatically resolves conflicts within same policy type |
| **Use case**        | Granular control for advanced admins | Simplified for security-focused admins                   |

**Recommendation**: Use endpoint security policies for common security scenarios (ASR rules, BitLocker, Defender AV). Use settings catalog for advanced/custom configurations.

---

## Licensing Impact

### Base Features (Intune Plan 1 / M365 E3)

All compliance and configuration management features are included in **Intune Plan 1**, which is bundled with:

- Microsoft 365 E3/E5
- Microsoft 365 Business Premium
- Enterprise Mobility + Security (EMS) E3/E5
- Standalone Intune Plan 1 ($8/user/month)

**Included features**:

- Device compliance policies
- Device configuration profiles
- Settings catalog (5000+ settings)
- Security baselines (Windows, Edge, Defender, M365)
- Custom compliance policies (JSON + PowerShell)
- Remediations (detection + remediation scripts)
- Compliance reporting (28-day retention)
- Endpoint Analytics (basic)

### Premium Features

**Conditional Access Integration**:

- **Requires**: Azure AD/Entra ID P1 or P2
- **Included in**: Microsoft 365 E3/E5, EMS E3/E5
- **Standalone**: ~$6/user/month (Entra ID P1)
- **Impact**: Core zero-trust capability; essential for compliance enforcement

**Extended Analytics and Reporting**:

- **Azure Log Analytics** (for >28-day compliance report retention)
  - Consumption-based pricing: ~$2.30/GB ingestion
  - Requires Azure subscription
- **Power BI Pro** (for custom compliance dashboards)
  - $10/user/month
  - Required for sharing custom reports

**Intune Suite** ($10/user/month; moving to M365 E3/E5 from July 2026):

- **Endpoint Privilege Management**: Just-in-time admin elevation (included in E5 from July 2026)
- **Advanced Endpoint Analytics**: Enhanced insights and custom device queries (included in E3/E5 from July 2026)

### Cost Comparison

**SCCM compliance costs** (1,000 devices, 3-year period):

- Infrastructure: $20,000-40,000 (servers, SQL Server)
- Administrative overhead: $45,000-75,000 (0.5 FTE)
- Reporting (SSRS): $0 (included with SQL Server)
- **Total**: $65,000-115,000

**Intune compliance costs** (1,000 devices, 3-year period):

- Intune licensing: $0 (included in M365 E3)
- Conditional Access: $0 (Entra ID P1 included in M365 E3)
- Infrastructure: $0 (cloud service)
- Administrative overhead: $15,000-30,000 (0.1-0.25 FTE with automation)
- Advanced reporting (optional): $3,600-10,800 (Azure Log Analytics + Power BI Pro for report authors)
- **Total**: $15,000-40,800

**Savings**: $50,000-74,200 over 3 years primarily due to infrastructure elimination and reduced administrative overhead.

See [Executive Summary — Licensing Summary](executive-summary.md) for comprehensive licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Assessment

#### Configuration Baseline Inventory

Audit SCCM configuration baselines before migration:

```sql
-- SQL query for SCCM database to inventory baselines
SELECT
    cb.LocalizedDisplayName AS BaselineName,
    cb.LocalizedDescription,
    COUNT(DISTINCT ci.CI_ID) AS ConfigurationItemCount,
    COUNT(DISTINCT dep.CollectionID) AS DeployedToCollections,
    MAX(cs.LastComplianceMessageTime) AS LastEvaluationTime,
    CAST(SUM(CASE WHEN cs.ComplianceState = 1 THEN 1 ELSE 0 END) AS FLOAT) /
        NULLIF(COUNT(cs.ResourceID), 0) * 100 AS CompliancePercentage
FROM v_ConfigurationItems cb
INNER JOIN v_CIRelation rel ON cb.CI_ID = rel.FromCI_ID
INNER JOIN v_ConfigurationItems ci ON rel.ToCI_ID = ci.CI_ID
LEFT JOIN v_CIAssignment dep ON cb.CI_ID = dep.CI_ID
LEFT JOIN v_ClientState cs ON dep.AssignmentID = cs.AssignmentID
WHERE cb.CIType_ID = 2  -- Configuration Baseline
GROUP BY cb.LocalizedDisplayName, cb.LocalizedDescription
ORDER BY ConfigurationItemCount DESC
```

#### CI Complexity Analysis

For each baseline, categorize configuration items by migration complexity:

| CI Type                    | SCCM Setting Type   | Intune Equivalent                        | Migration Complexity   |
| -------------------------- | ------------------- | ---------------------------------------- | ---------------------- |
| **Registry value**         | Registry setting    | Settings catalog or custom compliance    | **Low** (15-30 min)    |
| **File/folder**            | File system setting | Custom compliance (PowerShell check)     | **Low** (15-30 min)    |
| **WMI query**              | WMI query           | Custom compliance (PowerShell + CIM)     | **Medium** (30-60 min) |
| **Script**                 | PowerShell/VBScript | Custom compliance (PowerShell + JSON)    | **Medium** (30-90 min) |
| **Active Directory query** | AD attribute check  | Custom compliance (AD PowerShell module) | **Medium** (30-60 min) |
| **SQL query**              | SQL database check  | Custom compliance (Invoke-Sqlcmd)        | **High** (1-2 hours)   |
| **IIS metabase**           | IIS configuration   | Custom compliance or direct IIS CSP      | **High** (1-2 hours)   |

**Example baseline migration estimate**:

```
Baseline: "Corporate Security Standard v2.0"
  Total CIs: 15

CI Breakdown:
  - 8 registry-based CIs → Settings catalog (2 hours total)
  - 3 file-based CIs → Custom compliance (1.5 hours total)
  - 2 script-based CIs → Custom compliance (2 hours total)
  - 1 WMI-based CI → Custom compliance (1 hour)
  - 1 AD query CI → Custom compliance (1 hour)

Total migration time: 7.5 hours
```

### Migration Strategies

#### Strategy 1: Baseline-by-Baseline Migration (Incremental)

**Best for**: Large baseline portfolios (>20 baselines), risk-averse organizations

**Timeline**: 3-6 months

**Approach**:

1. **Month 1: High-Priority Baselines** (Week 1-4)
   - Identify top 5 business-critical baselines (e.g., Security Baseline, Windows 11 Configuration)
   - Migrate to Intune policies
   - Deploy to pilot group (50-100 devices)
   - Validate compliance reporting matches SCCM
   - Address gaps and issues

2. **Month 2: Medium-Priority Baselines** (Week 5-8)
   - Migrate next 10-15 baselines
   - Deploy to pilot group
   - Expand pilot to 500 devices

3. **Month 3: Low-Priority Baselines** (Week 9-12)
   - Migrate remaining baselines
   - Deploy to production (all devices)
   - Monitor compliance percentages

4. **Month 4-6: Co-Management Transition** (Week 13-24)
   - Enable co-management
   - Shift Compliance Policies workload to Intune (pilot → production)
   - Validate SCCM and Intune compliance coexist correctly
   - Shift Device Configuration workload to Intune
   - Decommission SCCM compliance reporting once Intune at 100%

**Benefits**:

- Low risk (per-baseline validation before next migration)
- Incremental learning curve for IT team
- Rollback capability (shift workload back to SCCM if issues)

**Disadvantages**:

- Longer timeline (3-6 months)
- Dual management during transition period

#### Strategy 2: All-Baselines Cutover (Greenfield)

**Best for**: Small baseline portfolios (<10 baselines), cloud-first organizations

**Timeline**: 4-8 weeks

**Approach**:

1. **Week 1-2: Migration Preparation**
   - Document all SCCM baselines
   - Create Intune equivalents for all baselines
   - Create Azure AD groups matching SCCM collections

2. **Week 3-4: Pilot Deployment**
   - Deploy all Intune policies to pilot group (100-200 devices)
   - Validate compliance reporting
   - Test remediation scripts
   - Fix issues

3. **Week 5-6: Production Cutover**
   - Deploy all Intune policies to production
   - Monitor compliance percentages
   - Compare to SCCM compliance (should match within 5%)

4. **Week 7-8: Decommissioning**
   - Disable SCCM baseline deployments
   - Archive SCCM baselines for reference
   - Train helpdesk on Intune compliance reporting

**Benefits**:

- Fast migration (4-8 weeks)
- Clean cutover (no dual management period)

**Disadvantages**:

- Higher risk (all baselines migrate simultaneously)
- Must fix all issues before production deployment

#### Strategy 3: Security-First Migration (Conditional Access Enablement)

**Best for**: Organizations prioritizing zero-trust security, cloud-first

**Timeline**: 2-4 months

**Approach**:

1. **Month 1: Security Baselines Migration**
   - Focus on security-critical baselines only:
     - Windows Security Baseline
     - BitLocker Configuration
     - Windows Defender Configuration
     - Firewall Configuration
   - Deploy Intune security baselines
   - Create compliance policy aggregating security requirements

2. **Month 2: Conditional Access Pilot**
   - Create Conditional Access policy (pilot group):
     - Require device compliance for Exchange Online
   - Monitor user impact
   - Refine compliance policy based on feedback
   - Train helpdesk on user support

3. **Month 3: Conditional Access Production**
   - Expand Conditional Access to all users
   - Add additional resources (SharePoint, Teams, SaaS apps)
   - Monitor compliance percentages

4. **Month 4: Non-Security Baselines**
   - Migrate remaining configuration baselines (non-security)
   - Shift full workload to Intune

**Benefits**:

- Immediate zero-trust security benefit
- Focuses on highest-risk configurations first
- Conditional Access provides business value justification

**Disadvantages**:

- Security-only migration leaves non-security configs in SCCM temporarily
- Requires user communication (compliance enforcement changes access)

### Baseline Migration Workflow (Per Baseline)

**Standard workflow for migrating one SCCM baseline**:

**Step 1: Export baseline from SCCM** (Documentation)

> **Note**: The following is a conceptual example illustrating the pattern. Adapt baseline names for your environment.

```powershell
# Export SCCM baseline details
$baseline = Get-CMBaseline -Name "Corporate Security Standard v2.0"
$baseline | Select-Object Name, Description, CI_ID | Out-File "Baseline-Export.txt"

# Export configuration items
$CIs = Get-CMConfigurationItem -BaselineId $baseline.CI_ID
$CIs | ForEach-Object {
    $_ | Select-Object LocalizedDisplayName, CI_ID, CIType_ID, SettingType |
        Out-File "Baseline-CIs-Export.txt" -Append
}
```

**Step 2: Create Intune policy equivalents**

For each CI type:

**Registry CI → Settings Catalog**:

```
SCCM CI: "Firewall - Domain Profile Enabled"
  Setting Type: Registry
  Path: HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile
  Value Name: EnableFirewall
  Data Type: REG_DWORD
  Expected Value: 1

Intune Migration:
  Profile Type: Settings Catalog
  Category: Firewall > Domain Profile
  Setting: Enable Firewall
  Value: Enabled
```

**Script CI → Custom Compliance**:

```
SCCM CI: "LAPS Password Age Check"
  Discovery Script: Check-LAPSPasswordAge.ps1
  Compliance Rule: Returns value < 30 days

Intune Migration:
  Custom Compliance Policy: "LAPS Password Age"
  Detection Script:
    $lapsAge = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\LAPS" -Name PasswordAge).PasswordAge
    return @{ LAPSPasswordAge = $lapsAge } | ConvertTo-Json
  JSON Rule:
    { "SettingName": "LAPSPasswordAge", "Operator": "LessThan", "Operand": 30 }
```

**Step 3: Assign to Azure AD group**

> **Note**: The following is a conceptual example illustrating the pattern. Adapt group names and policy filters for your environment.

```powershell
# Create Azure AD group matching SCCM collection
$sccmCollection = "All-Workstations-Compliance"
$azureGroup = "Azure-All-Workstations-Compliance"

# Manual: Create dynamic Azure AD group with equivalent membership rules
# Example: deviceOSType -eq "Windows" -and deviceOSVersion -startsWith "10.0.22"

# Assign policy to group
$policy = Get-MgDeviceManagementDeviceCompliancePolicy -Filter "displayName eq 'Corporate Security Standard v2.0'"
New-MgDeviceManagementDeviceCompliancePolicyAssignment -DeviceCompliancePolicyId $policy.Id -Target @{
    "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
    groupId = $azureGroup.Id
}
```

**Step 4: Pilot and validate**

- Deploy to pilot group (50-100 devices)
- Wait 24 hours for compliance evaluation
- Compare compliance percentage to SCCM baseline
- Investigate discrepancies (setting differences, detection logic errors)

**Step 5: Production deployment**

- Assign policy to production Azure AD group
- Monitor compliance trends for 7-14 days
- Address non-compliance issues

**Step 6: Decommission SCCM baseline**

- Disable SCCM baseline deployment
- Archive baseline for reference/rollback

### Common Migration Issues and Resolutions

| Issue                                                | Cause                                                          | Resolution                                                                                                 |
| ---------------------------------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Compliance percentage lower in Intune than SCCM**  | Detection logic differences or device targeting differences    | Review custom compliance scripts; verify Azure AD group membership matches SCCM collection                 |
| **Custom compliance always returns non-compliant**   | PowerShell script not returning JSON or JSON format incorrect  | Enable script debugging; review Intune diagnostic logs; validate JSON schema with test tool                |
| **Settings catalog setting not applying**            | Conflicting policy or Windows edition unsupported              | Check policy conflict report; verify Windows edition supports setting (Pro vs Enterprise)                  |
| **Remediation script fails repeatedly**              | Script requires elevation or user context incorrect            | Verify "Run script in 64-bit PowerShell" and "Run using logged on credentials" settings match requirements |
| **Conditional Access blocks compliant devices**      | Compliance policy not assigned to device or evaluation delay   | Force device sync in Intune; wait 8-24 hours for compliance state to sync to Azure AD                      |
| **Security baseline conflicts with custom settings** | Multiple policies configure same setting with different values | Review policy conflict report; consolidate settings into single policy or prioritize baseline              |

---

## Sources

### Microsoft Learn Documentation

- [Device compliance policies in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)
- [Create a policy using settings catalog in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog)
- [Use custom compliance settings for Linux and Windows devices in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-use-custom-settings)
- [Create discovery scripts for custom compliance policy in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-custom-script)
- [Create a JSON file for custom compliance settings in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-custom-json)
- [Use Remediations to detect and fix support issues - Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations)
- [Learn about Intune security baselines for Windows devices](https://learn.microsoft.com/en-us/mem/intune/protect/security-baselines)
- [Endpoint security policies in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-policy)
- [Endpoint Analytics overview](https://learn.microsoft.com/en-us/mem/analytics/overview)
- [What is Conditional Access?](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)
- [Enterprise State Roaming Overview](https://learn.microsoft.com/en-us/azure/active-directory/devices/enterprise-state-roaming-overview)
- [Create configuration baselines - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/create-configuration-baselines)
- [Deploy configuration baselines - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/deploy-configuration-baselines)
- [Monitor compliance settings - Configuration Manager](https://learn.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/monitor-compliance-settings)

### Community and Technical Resources

- [Intune Custom Compliance Policies - Patch My PC](https://patchmypc.com/blog/intune-custom-compliance-policies)
- [Understanding Default Device Compliance Policy in Intune - Prelude](https://www.preludesecurity.com/blog/intune-default-device-compliance-policy)

---

**Research Date**: February 18, 2026
**Primary Sources**: Microsoft Learn official documentation, Microsoft Community Hub, verified third-party technical resources
