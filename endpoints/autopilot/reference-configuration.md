---
title: "Autopilot Configuration Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Autopilot Configuration Reference

## Admin Portal Quick Reference

| Portal | URL | Primary Use |
|--------|-----|-------------|
| [Microsoft Intune Admin Center](https://intune.microsoft.com/) | `https://intune.microsoft.com/` | Device management, Autopilot profiles, ESP |
| [Microsoft Entra Admin Center](https://entra.microsoft.com/) | `https://entra.microsoft.com/` | Device settings, MDM enrolment, Conditional Access |
| [Microsoft 365 Admin Center](https://admin.microsoft.com/) | `https://admin.microsoft.com/` | Licensing, service health, support cases |
| [Windows Autopilot Devices](https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/WindowsAutopilotMenu) | Direct link | Autopilot device list and import |

### Navigation Paths

| Function | Path |
|----------|------|
| Device registration | Devices > Windows > Windows enrollment > Windows Autopilot > Devices |
| Deployment profiles | Devices > Windows > Windows enrollment > Windows Autopilot > Deployment profiles |
| Enrollment Status Page | Devices > Windows > Windows enrollment > Enrollment Status Page |
| MDM enrolment scope | Entra Admin Center > Identity > Mobility (MDM and MAM) > Microsoft Intune |
| Device settings | Entra Admin Center > Identity > Devices > Device settings |
| Autopilot events | Devices > Monitor > Enrollment failures |

## PowerShell Commands

All Graph API cmdlets require the [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation). Connect with `Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"` before running device management commands.

### Device Registration

| Purpose | Cmdlet / Command |
|---------|-----------------|
| Collect hardware hash on-device | `Install-Script -Name Get-WindowsAutopilotInfo -Force` then `Get-WindowsAutopilotInfo.ps1 -OutputFile C:\Temp\DeviceInfo.csv -GroupTag "TagName"` |
| Upload direct to Autopilot service | `Get-WindowsAutopilotInfo.ps1 -Online -GroupTag "TagName"` |
| Import devices from CSV via Graph | `New-MgDeviceManagementWindowsAutopilotDeviceIdentity -BodyParameter $device` |
| List registered devices | `Get-MgDeviceManagementWindowsAutopilotDeviceIdentity` |
| Delete a device registration | `Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $id` |
| Check device registration status | `dsregcmd /status` |
| Check Autopilot deployment state | `Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_WindowsAutopilot` |

### Profile Management

| Purpose | Cmdlet |
|---------|--------|
| List all deployment profiles | `Get-MgDeviceManagementWindowsAutopilotDeploymentProfile` |
| Create deployment profile | `New-MgDeviceManagementWindowsAutopilotDeploymentProfile -BodyParameter $profile` |
| Get profile assignments | `Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $id` |
| Assign profile to group | `New-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $id -BodyParameter $assignment` |

### Diagnostics

| Purpose | Cmdlet / Command |
|---------|-----------------|
| Collect full diagnostics bundle | `Install-Script -Name Get-AutopilotDiagnostics -Force` then `Get-AutopilotDiagnostics -OutputPath C:\Temp\AutopilotDiags.zip` |
| Check ESP progress registry | `Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\StatusPageProvider"` |
| Check enrolment status | `Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_EnrollmentStatusTracking_TrackingInfo` |
| Read Autopilot event log | `Get-WinEvent -LogName "Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin"` |
| Read Intune enrolment log | `Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"` |
| Check Intune connector version | `Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Intune on-premise Connector" -Name "Version"` |

### Dynamic Group Membership Rules

| Group Intent | Rule |
|-------------|------|
| All Autopilot-registered devices | `(device.devicePhysicalIds -any _ -startswith "[ZTDId]")` |
| Devices with a specific group tag | `(device.devicePhysicalIds -any _ -eq "[OrderID]:tagvalue")` |
| Devices by manufacturer | `(device.deviceManufacturer -eq "Dell Inc.")` |

### Log File Locations

| Log | Path |
|-----|------|
| Autopilot OOBE | `C:\Windows\Panther\UnattendGC\setupact.log` |
| Autopilot diagnostics | `C:\Windows\Logs\Autopilot\` |
| Enrollment Status Page | `C:\Windows\Logs\ESPStatus\` |
| Intune Management Extension | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\` |
| Device registration | `C:\Windows\Logs\DeviceRegistration\` |
| Hybrid domain join | `C:\Windows\Debug\NetSetup.log` |

## Network Requirements

Source: [Windows Autopilot requirements — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/requirements) and [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints).

### Required Endpoints

| Service | Endpoint | Protocol | Port | Notes |
|---------|----------|----------|------|-------|
| Autopilot deployment service | `ztd.dds.microsoft.com` | HTTPS | 443 | Device registration lookup |
| Autopilot deployment service | `cs.dds.microsoft.com` | HTTPS | 443 | Profile retrieval |
| Microsoft Live ID | `login.live.com` | HTTPS | 443 | Autopilot service auth |
| Intune management | `*.manage.microsoft.com` | HTTPS | 443 | Device management and MDM |
| MDM enrolment | `enrollment.manage.microsoft.com` | HTTPS | 443 | MDM enrolment endpoint |
| Microsoft Entra authentication | `login.microsoftonline.com` | HTTPS | 443 | User and device auth |
| Device registration | `enterpriseregistration.windows.net` | HTTPS | 443 | Entra device join |
| Device login | `device.login.microsoftonline.com` | HTTPS | 443 | Device certificate auth |
| Windows Update | `*.windowsupdate.com` | HTTPS | 443 | OS and driver updates |
| Delivery Optimisation | `*.delivery.mp.microsoft.com` | HTTPS | 443 | Peer-to-peer update delivery |
| Certificate revocation | `crl.microsoft.com` | HTTPS | 443 | CRL validation |
| Certificate trust | `*.public-trust.com` | HTTPS | 443 | Certificate services |
| Network connectivity check | `*.msftconnecttest.com` | HTTP | 80 | NCSI probe — must resolve via DNS |
| TPM attestation | `*.microsoftaik.azure.net` | HTTPS | 443 | Firmware TPM certificate retrieval |
| Time synchronisation | `time.windows.com` | NTP | 123 (UDP) | Required for certificate validation |

### DNS Requirements

Custom domain environments require a CNAME record for device registration:

| Record | Name | Target |
|--------|------|--------|
| CNAME | `enterpriseregistration.yourdomain.com` | `enterpriseregistration.windows.net` |

### Hybrid-Only Additional Ports

Required when the [Intune Connector for Active Directory](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-hybrid) is in use:

| Service | Protocol | Port |
|---------|----------|------|
| LDAP | TCP | 389 |
| LDAPS | TCP | 636 |
| Global Catalogue | TCP | 3268 / 3269 |
| Kerberos | TCP/UDP | 88 |
| DNS | TCP/UDP | 53 |

## Deployment Profile Settings

Source: [Windows Autopilot deployment profiles — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/profiles).

### Profile Configuration Matrix

| Setting | User-Driven | Self-Deploying | Pre-Provisioning |
|---------|-------------|----------------|------------------|
| User interaction | Required | None | Technician only |
| Join type | Entra join or Hybrid | Entra join only | Entra join or Hybrid |
| White Glove / Pre-provision | Optional | Not applicable | Required |
| Device usage type | Single user or shared | Shared / kiosk | Single user or shared |
| User account type | Standard or admin | Admin | Standard or admin |
| TPM 2.0 required | No | Yes | No |
| Recommended for new devices | Yes | Yes | Yes |

### Deployment Mode Comparison

| Feature | User-Driven | Self-Deploying | Pre-Provisioning |
|---------|-------------|----------------|------------------|
| Typical setup time | 15–30 min | 10–20 min | 30–45 min (technician phase) + fast user phase |
| User presence required | Yes | No | Technician only for first phase |
| Application installation | During ESP | During ESP | Pre-stage and post-user sign-in |
| Domain join support | Entra + Hybrid | Entra only | Entra + Hybrid |
| Typical use case | Standard PC deployment | Kiosk / shared device | Bulk deployment, pre-staged |

### OOBE Settings Reference

| Setting | Recommended Value | Notes |
|---------|-------------------|-------|
| Microsoft Software License Terms | Hide | Suppresses EULA screen |
| Privacy settings | Hide | Suppresses privacy page |
| Hide change account options | Hide | Prevents account switching at sign-in |
| User account type | Standard | Least-privilege default |
| Allow pre-provisioned deployment | Yes | Required for White Glove scenarios |
| Apply device name template | Yes | Enables consistent naming convention |
| Device name template example | `CORP-%RAND:5%` | Prefix + 5 random alphanumeric characters |
| Skip keyboard selection | Yes | Reduces OOBE steps |
| Language / region | OS default | Or set to specific locale |

### Enrollment Status Page Settings

| Setting | Recommended Value |
|---------|-------------------|
| Show app and profile installation progress | Yes |
| Block device use until apps and profiles are installed | Yes |
| Allow users to collect logs on installation error | Yes |
| Allow users to reset device on installation error | Yes |
| Show error when installation exceeds N minutes | 60 |

## Error Code Reference

Source: [Troubleshoot Windows Autopilot — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/troubleshoot-oobe).

| Error Code | Category | Description | First Action |
|------------|----------|-------------|--------------|
| `0x800705B4` | ESP timeout | Application or policy installation timed out during ESP | Review app assignment settings and installation logs |
| `0x80070002` | File not found | Application package or dependency file missing | Verify .intunewin package integrity |
| `0x80070774` | Domain not found | Domain controller unreachable during hybrid join | Check VPN connectivity and DC accessibility |
| `0x801C0003` | Device registration | Device could not register with Autopilot service | Verify hardware hash; delete and re-register device |
| `0x80004005` | Generic failure | Unspecified error — multiple possible causes | Collect diagnostics with `Get-AutopilotDiagnostics` |
| `0x80180014` | Not authorised | Device not authorised for Autopilot deployment | Confirm device is registered in Autopilot service |
| `0x80180018` | Profile not found | No Autopilot profile assigned to device | Verify group tag and dynamic group membership |
| `0x80070032` | Not supported | Feature not supported on this device configuration | Check Windows version and TPM requirements |

## Related Resources

- [Windows Autopilot overview — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/overview)
- [Windows Autopilot requirements — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/requirements)
- [Windows Autopilot deployment profiles — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/profiles)
- [Network endpoints for Microsoft Intune — Microsoft Learn](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints)
- [Troubleshoot Windows Autopilot OOBE issues — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/troubleshoot-oobe)
- [Microsoft Graph PowerShell SDK installation — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation)
- [Get-WindowsAutopilotInfo script — PowerShell Gallery](https://www.powershellgallery.com/packages/Get-WindowsAutopilotInfo)
- [Windows Autopilot known issues — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/known-issues)
