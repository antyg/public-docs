# Microsoft Autopilot Administrator Cheat Sheet (2025)

## Metadata
- **Document Type**: Quick Reference Guide
- **Version**: 1.0.1
- **Last Updated**: 2025-08-27 (Links verified and updated)
- **Target Audience**: IT Administrators, Help Desk Staff, System Engineers
- **Scope**: Daily administrative tasks and troubleshooting for Windows Autopilot
- **Prerequisites**: Windows Autopilot already configured (see setup guide)

## Executive Summary

This cheat sheet provides quick reference information for day-to-day Microsoft Windows Autopilot administration tasks, common troubleshooting procedures, and essential PowerShell commands. Designed for administrators who need fast access to frequently used procedures and diagnostic information.

**⚠️ 2025 Critical Updates:**
- Legacy Intune Connector deprecated June 2025 (update required)
- Enterprise App Catalog support added
- Enhanced security with low privileged accounts
- Microsoft recommends cloud-native (Entra join) over hybrid deployments

## Quick Access Portal Links

### Primary Administration Portals

- **[Microsoft Intune Admin Center](https://intune.microsoft.com/)**
- **[Microsoft Entra Admin Center](https://entra.microsoft.com/)**
- **[Microsoft 365 Admin Center](https://admin.microsoft.com/)**
- **[Windows Autopilot Admin](https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/WindowsAutopilotMenu)**

### Common Navigation Paths

**[Device Registration](https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/WindowsAutopilotDeviceIdentitiesMenu)**
- Path: Devices > Windows > Windows enrollment > Windows Autopilot > Devices

**[Deployment Profiles](https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/WindowsAutopilotDeploymentProfilesMenu)**
- Path: Devices > Windows > Windows enrollment > Windows Autopilot > Deployment profiles

**[Device Status](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/overview)**
- Path: Devices > All devices > [Select device] > Hardware

**[Autopilot Events](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMonitorMenu/~/enrollmentFailures)**
- Path: Devices > Monitor > Enrollment failures

**[MDM Enrollment](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Mobility)**
- Path: Microsoft Entra admin center > Identity > Mobility (MDM and MAM) > Microsoft Intune

**[Device Settings](https://portal.azure.com/#blade/Microsoft_AAD_IAM/DevicesMenuBlade/DeviceSettings/menuId/)**
- Path: Microsoft Entra admin center > Identity > Devices > Device settings

## Essential PowerShell Commands

### Device Registration and Management

#### Get Hardware Hash (On Device)

**Template Available:** **[hardware-hash-collection.ps1](../templates/hardware-hash-collection.ps1)**

```powershell
# Install required script
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Get hardware info with group tag
Get-WindowsAutopilotInfo.ps1 -OutputFile C:\Temp\DeviceInfo.csv -GroupTag "Finance"

# Get hardware info for current device
Get-WindowsAutopilotInfo.ps1 -Online -GroupTag "IT-Managed"
```

#### Device Registration Status
```powershell
# Check device registration status
dsregcmd /status

# Check Autopilot deployment status  
Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_WindowsAutopilot

# Get device compliance status
Get-MsolDevice -All | Where-Object {$_.DisplayName -like "*COMPUTERNAME*"}
```

#### Bulk Device Registration
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Import devices from CSV
Import-Csv "C:\Devices.csv" | ForEach-Object {
    $device = @{
        serialNumber = $_.SerialNumber
        productKey = $_.ProductKey  
        hardwareIdentifier = $_.HardwareHash
        groupTag = $_.GroupTag
        assignedUser = $_.AssignedUser
    }
    New-MgDeviceManagementWindowsAutopilotDeviceIdentity -BodyParameter $device
}
```

### Profile Management

#### List All Profiles
```powershell
# Get all Autopilot profiles
Get-MgDeviceManagementWindowsAutopilotDeploymentProfile

# Get profile assignments
Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $ProfileId
```

#### Create Quick Profile (PowerShell)
```powershell
$profile = @{
    displayName = "Quick Corporate Profile"
    description = "Standard user-driven deployment"
    deviceType = "windowsPc"
    language = "os-default"
    enableWhiteGlove = $true
    extractHardwareHash = $false
    deviceNameTemplate = "CORP-%RAND:5%"
    outOfBoxExperienceSettings = @{
        hidePrivacySettings = $true
        hideEULA = $true
        userType = "standard"
        deviceUsageType = "singleUser"
        skipKeyboardSelectionPage = $true
    }
}

New-MgDeviceManagementWindowsAutopilotDeploymentProfile -BodyParameter $profile
```

### Diagnostic Commands

#### Autopilot Diagnostics Collection
```powershell
# Get comprehensive Autopilot diagnostics (requires script)
Install-Script -Name Get-AutopilotDiagnostics -Force
Get-AutopilotDiagnostics -OutputPath C:\Temp\AutopilotDiags.zip

# Check enrollment status
Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_EnrollmentStatusTracking_TrackingInfo

# Review ESP progress
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\StatusPageProvider"
```

#### Network Connectivity Testing

**Template Available:** **[network-connectivity-test.ps1](../templates/network-connectivity-test.ps1)**

```powershell
# Test required endpoints
$endpoints = @(
    "login.microsoftonline.com",
    "enrollment.manage.microsoft.com", 
    "enterpriseregistration.windows.net",
    "device.login.microsoftonline.com"
)

foreach ($endpoint in $endpoints) {
    $result = Test-NetConnection -ComputerName $endpoint -Port 443
    Write-Output "$endpoint : $($result.TcpTestSucceeded)"
}
```

## Common Administrative Tasks

### Device Management

#### Register New Device (Manual)
1. **Get device hardware hash:**
   - Run `Get-WindowsAutopilotInfo.ps1` on device
   - Save CSV output

2. **Import to Autopilot:**
   - Navigate to: Devices > Windows > Windows enrollment > Windows Autopilot > Devices
   - Click **Import** > Select CSV file
   - Wait for sync (can take up to 15 minutes)

3. **Assign to group:**
   - Ensure device appears in appropriate dynamic group
   - Verify group tag matches group membership rules

#### Reset Autopilot Device
```powershell
# Reset device (removes from Intune, preserves Autopilot registration)
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'DEVICENAME'" | 
    Invoke-MgWipeDeviceManagementManagedDevice -KeepEnrollmentData:$false

# Alternative: Reset via Intune admin center
# Devices > All devices > [Device] > Retire/Wipe
```

#### Delete Autopilot Registration
```powershell
# Find and delete device registration
$device = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "contains(serialNumber,'SERIALNUMBER')"
Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $device.Id
```

### Profile Management Tasks

#### Quick Profile Assignment
1. **Create dynamic group** for target devices:
   ```
   Group name: Autopilot-Finance-Devices
   Membership rule: (device.devicePhysicalIds -any _ -eq "[OrderID]:finance")
   ```
   
   **More dynamic group rules:** **[autopilot-group-rules.txt](../templates/autopilot-group-rules.txt)**

2. **Assign profile to group:**
   - Navigate to: Deployment profiles > [Profile] > Assignments
   - Click **Assign** > Select group > Save

#### Profile Troubleshooting
```powershell
# Check profile assignment status
$device = Get-MgDevice -Filter "displayName eq 'DEVICENAME'"
Get-MgDeviceRegisteredOwner -DeviceId $device.Id

# Verify group membership
Get-MgGroupMember -GroupId "GROUP-ID" | Where-Object {$_.Id -eq $device.Id}
```

### Application Deployment

#### Add Required App for Autopilot
1. **Convert app to Win32 format:**
   ```powershell
   # Download Microsoft Win32 Content Prep Tool
   IntuneWinAppUtil.exe -c "C:\Source" -s "App.msi" -o "C:\Output" -q
   ```

2. **Create app in Intune:**
   - Navigate to: Apps > All apps > Add
   - App type: Windows app (Win32)
   - Upload .intunewin file

3. **Configure for Autopilot:**
   - Assignment: Required
   - Device install context: System
   - Available for enrolled devices: Yes

#### Monitor App Installation
```powershell
# Check app installation status
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\*" | 
    Select-Object PSChildName, @{Name='AppName';Expression={$_.DisplayName}}, InstallState

# Review installation logs
Get-ChildItem "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\" -Name "*.log" |
    ForEach-Object { Get-Content "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$_" -Tail 20 }
```

## Troubleshooting Quick Reference

### Common Issues and Solutions

#### Issue: Device Not Appearing in Autopilot
**Diagnostic Steps:**
1. Verify hardware hash is correct
2. Check CSV file format
3. Confirm device is not already registered

**Resolution:**
```powershell
# Re-generate hardware hash
Get-WindowsAutopilotInfo.ps1 -OutputFile C:\Temp\NewHash.csv

# Check for existing registration
Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "contains(serialNumber,'SERIALNUMBER')"

# Delete and re-register if found
Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $ExistingDevice.Id
```

#### Issue: Profile Not Assigned
**Diagnostic Steps:**
1. Check group membership
2. Verify assignment configuration  
3. Review profile precedence rules

**Resolution:**
```powershell
# Verify group membership
$device = Get-MgDevice -Filter "displayName eq 'DEVICENAME'"
Get-MgDirectoryObjectMemberOf -DirectoryObjectId $device.Id

# Check assignment conflicts
Get-MgDeviceManagementWindowsAutopilotDeploymentProfile | 
    ForEach-Object { 
        Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $_.Id
    }
```

#### Issue: Apps Failing During ESP
**Diagnostic Steps:**
1. Check app assignment settings
2. Review installation logs
3. Verify system context permissions

**Resolution:**
```powershell
# Check app assignment
Get-MgDeviceAppManagementMobileApp -Filter "displayName eq 'APPNAME'" | 
    Get-MgDeviceAppManagementMobileAppAssignment

# Review failed installations
Get-EventLog -LogName Application -Source "Microsoft Intune Management Extension" -EntryType Error -Newest 10
```

### Log File Locations

#### Primary Autopilot Logs
```
Windows Autopilot OOBE:
C:\Windows\Panther\UnattendGC\setupact.log

Autopilot Diagnostics:
C:\Windows\Logs\Autopilot\

ESP Status Logs:
C:\Windows\Logs\ESPStatus\

Domain Join (Hybrid):
C:\Windows\Debug\NetSetup.log
```

#### Intune Management Logs
```
Intune Management Extension:
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\

Win32 App Installation:
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log

Device Registration:
C:\Windows\Logs\DeviceRegistration\
```

#### Event Log Locations
```powershell
# Autopilot events
Get-WinEvent -LogName "Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin"

# Intune enrollment events  
Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"

# Application installation events
Get-WinEvent -LogName "Application" | Where-Object {$_.ProviderName -eq "Microsoft Intune Management Extension"}
```

## Security and Compliance Quick Checks

### Device Compliance Verification
```powershell
# Check BitLocker status
Get-BitLockerVolume

# Verify TPM status
Get-Tpm

# Check Windows Hello configuration
Get-WindowsOptionalFeature -Online -FeatureName "HelloFace" | Select-Object State
```

### Policy Application Status
```powershell
# Check applied policies
Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_Policy_Result01

# Verify compliance state
dsregcmd /status | Select-String "AzureAdPrt", "IsCompliant"

# Get device certificate info
Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object {$_.Subject -like "*Device*"}
```

## 2025 Feature Updates

### Enterprise App Catalog (New)
**Configuration Location:** Apps > Enterprise App Catalog

**Key Settings:**
- Enable catalog apps in ESP
- Configure blocking behavior
- Set deployment assignments

**PowerShell Management:**
```powershell
# List catalog apps
Get-MgDeviceAppManagementMobileApp -Filter "contains(displayName,'Catalog')"

# Deploy catalog app during Autopilot
$catalogApp = @{
    displayName = "Enterprise Catalog App"
    installIntent = "required"
    settings = @{
        blockOnEsp = $true
        installContext = "system"
    }
}
```

### Updated Intune Connector (Critical)
**⚠️ Action Required:** Upgrade by June 2025

**Verification:**
```powershell
# Check connector version (must be >= 6.2501.2000.5)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Intune on-premise Connector" -Name "Version"

# Verify MSA account configuration
Get-Service "Microsoft Intune Connector" | Select-Object Status, StartType
```

**Upgrade Process:**
1. Download new connector from Intune admin center
2. Run installer with admin privileges
3. Verify MSA account creation
4. Test hybrid join functionality

## Quick Reference Tables

### Profile Configuration Matrix
| Setting | User-Driven | Self-Deploying | Pre-Provisioning |
|---------|-------------|----------------|-------------------|
| User Interaction | Required | None | Technician Only |
| Join Type | Entra/Hybrid | Entra Only | Entra/Hybrid |
| White Glove | Optional | N/A | Required |
| Device Usage | Single/Shared | Shared | Single/Shared |
| User Account Type | Standard/Admin | Admin | Standard/Admin |

### Deployment Mode Comparison
| Feature | User-Driven | Self-Deploying | Pre-Provision |
|---------|-------------|----------------|---------------|
| Setup Time | 15-30 min | 10-20 min | 30-45 min |
| User Presence | Required | None | Tech Only |
| App Installation | During ESP | During ESP | Pre & Post |
| Domain Join | Supported | Cloud Only | Supported |
| Best Use Case | Standard PC | Kiosk/Shared | Bulk Deploy |

### Common Error Codes
| Error Code | Description | Resolution |
|------------|-------------|------------|
| 0x800705B4 | Timeout during ESP | Check app assignments |
| 0x80070002 | File not found | Verify app package |
| 0x80070774 | Domain not found | Check hybrid join config |
| 0x801C0003 | Device registration | Re-register device |
| 0x80004005 | Generic failure | Check logs for details |

### Required Network Ports
| Service | Protocol | Port | Destination |
|---------|----------|------|-------------|
| Autopilot Registration | HTTPS | 443 | *.manage.microsoft.com |
| Authentication | HTTPS | 443 | login.microsoftonline.com |
| Device Registration | HTTPS | 443 | enterpriseregistration.windows.net |
| Windows Update | HTTPS | 443 | *.windowsupdate.com |
| Time Sync | NTP | 123 | time.windows.com |

## Emergency Procedures

### Complete Device Reset
```powershell
# Nuclear option - complete device reset
# WARNING: This will remove all data and configurations

# Method 1: Intune wipe
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'DEVICENAME'" | 
    Invoke-MgWipeDeviceManagementManagedDevice -KeepEnrollmentData:$false

# Method 2: Local reset (on device)
systemreset -cleanpc
```

### Profile Assignment Override
```powershell
# Emergency profile assignment (bypasses groups)
$device = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "contains(serialNumber,'SERIAL')"
$emergencyProfile = Get-MgDeviceManagementWindowsAutopilotDeploymentProfile -Filter "displayName eq 'Emergency Profile'"

# Direct assignment (use sparingly)
$assignment = @{
    target = @{
        "@odata.type" = "#microsoft.graph.deviceAndAppManagementAssignmentTarget"
        deviceAndAppManagementAssignmentFilterId = $device.Id
    }
}
New-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $emergencyProfile.Id -BodyParameter $assignment
```

### Service Health Check
```powershell
# Quick service health verification
$services = @(
    "Microsoft Intune Management Extension",
    "Windows Push Notifications System Service", 
    "Windows Update Medic Service",
    "Microsoft Store Install Service"
)

foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Output "$service : $($svc.Status)"
        if ($svc.Status -ne "Running") {
            Start-Service -Name $service
        }
    }
}
```

## Monitoring and Reporting

### Daily Health Checks
```powershell
# Autopilot deployment success rate (last 7 days)
$deployments = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity | 
    Where-Object {$_.LastContactedDateTime -gt (Get-Date).AddDays(-7)}

$successful = $deployments | Where-Object {$_.EnrollmentState -eq "enrolled"}
$successRate = ($successful.Count / $deployments.Count) * 100

Write-Output "7-Day Success Rate: $([math]::Round($successRate,2))%"
```

### Weekly Reporting Queries
```powershell
# Device enrollment trends
Get-MgDeviceManagementManagedDevice | 
    Where-Object {$_.EnrolledDateTime -gt (Get-Date).AddDays(-7)} |
    Group-Object {$_.EnrolledDateTime.DayOfWeek} |
    Select-Object Name, Count

# App installation failures
Get-MgDeviceAppManagementMobileApp | 
    Get-MgDeviceAppManagementMobileAppInstallSummary |
    Where-Object {$_.FailedDeviceCount -gt 0} |
    Select-Object DisplayName, FailedDeviceCount, TotalInstallCount
```

## Contact Information and Escalation

### Internal Support Contacts
```
Level 1 Support: Help Desk
- Phone: [Replace with Internal Help Desk Number]
- Email: [Replace with helpdesk@yourcompany.com]
- Hours: Business hours

Level 2 Support: IT Infrastructure  
- Phone: [Replace with Infrastructure Team Number]
- Email: [Replace with infrastructure@yourcompany.com]
- Hours: Extended hours

Level 3 Support: Microsoft Support
- Case Portal: **[Microsoft 365 Admin Center](https://admin.microsoft.com/)** (Support section)
- Alternative: **[Microsoft Support Hub](https://support.serviceshub.microsoft.com/)**
- Priority: Based on support plan and business impact
- Contact: [Replace with your Microsoft Account Manager]
```

### Microsoft Support Resources

- **[Microsoft Tech Community](https://techcommunity.microsoft.com/t5/microsoft-intune/ct-p/Microsoft-Intune)**
- **[Microsoft Autopilot Documentation](https://learn.microsoft.com/autopilot/)**
- **[Service Health Dashboard](https://admin.microsoft.com/Adminportal/Home#/servicehealth)**
- **[Microsoft 365 Feature Roadmap](https://www.microsoft.com/microsoft-365/roadmap)**

---

## Cross-References

### Related Documentation
- **[Complete Setup Guide](../setup-guides/)** - Comprehensive setup and configuration procedures
- **[Hybrid Deployment Limitations](../limitations-and-solutions/)** - Hybrid join specific limitations and workarounds

### External Quick References
- **[Microsoft Intune Fundamentals](https://learn.microsoft.com/en-us/mem/intune/fundamentals/)** - Intune overview and getting started
- **[Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation)** - Graph API PowerShell modules installation

---

*This cheat sheet provides quick reference for daily Windows Autopilot administration tasks. For comprehensive setup instructions and detailed configuration guidance, refer to the complete setup guide.*