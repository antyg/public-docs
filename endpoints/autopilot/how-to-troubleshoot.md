---
title: "Troubleshoot Windows Autopilot"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "how-to"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Troubleshoot Windows Autopilot

This guide covers systematic diagnostic and remediation procedures for Windows Autopilot deployment failures. It assumes the reader has already attempted a deployment and is working to diagnose a specific failure. For initial deployment setup, see [how-to-deploy-autopilot.md](how-to-deploy-autopilot.md).

---

## Diagnostic Data Collection

Collect diagnostic data before attempting any remediation. Attempting fixes without evidence wastes time and can obscure the root cause.

### MDM Diagnostics Tool

The primary tool for collecting Autopilot diagnostic data is `mdmdiagnosticstool.exe`. Run the following command on the affected device, either from a command prompt during OOBE (press Shift+F10) or after provisioning. See [Collect MDM logs](https://learn.microsoft.com/en-us/windows/client-management/mdm-collect-logs) for the full reference.

```cmd
mdmdiagnosticstool.exe -area Autopilot;TPM -cab C:\autopilot.cab
```

The generated `.cab` file contains:

| File | Contents |
|---|---|
| `DiagnosticLogCSP_Collector_Autopilot_*.etl` | Autopilot ETL trace |
| `DiagnosticLogCSP_Collector_DeviceProvisioning_*.etl` | Device provisioning ETL trace |
| `MDMDiagHtmlReport.html` | Human-readable MDM configuration snapshot |
| `MDMDiagReport.xml` | Detailed MDM enrollment variables and provisioning packages |
| `MDMDiagReport_RegistryDump.reg` | MDM enrollment registry keys, Autopilot profile settings, and app assignments |

To analyse the cab file using PowerShell:

```powershell
Install-Script -Name Get-AutopilotDiagnostics -Force
Get-AutopilotDiagnostics -CABFile C:\autopilot.cab
```

### Intune Remote Diagnostics

For enrolled devices, the **Collect Diagnostics** remote action in Intune automatically captures and uploads logs. Navigate to **Devices > All devices > [Device] > Collect diagnostics**. This action supports bulk collection from up to 25 Windows devices simultaneously. See [Remote Device Action: Collect Diagnostics](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics).

### Autopilot ETL Logs

On-device log paths for manual review:

```
Autopilot OOBE logs:
C:\Windows\Logs\Autopilot\

Autopilot OOBE (Panther):
C:\Windows\Panther\UnattendGC\setupact.log

Enrolment Status Page logs:
C:\Windows\Logs\ESPStatus\

Intune Management Extension logs:
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\

Device registration logs:
C:\Windows\Logs\DeviceRegistration\

Hybrid domain join logs:
C:\Windows\Debug\NetSetup.log
```

### Event Viewer

Key event log channels for Autopilot diagnostics:

```powershell
# Autopilot-specific events
Get-WinEvent -LogName "Microsoft-Windows-ModernDeployment-Diagnostics-Provider/AutoPilot"

# MDM enrolment events (failures, policy application)
Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"

# Entra ID join events
Get-WinEvent -LogName "Microsoft-Windows-AAD/Operational"

# ESP and provisioning events
Get-WinEvent -LogName "Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin"
```

### Device Registration Status

Run the following on the provisioned device to assess join state:

```powershell
# Full registration and join status
dsregcmd /status

# Key fields to review:
# AzureAdJoined      : YES/NO
# DomainJoined       : YES/NO (hybrid only)
# AzureAdPrt         : YES (user SSO token — confirms successful auth)
# MDMUrl             : populated (confirms Intune enrolment)
```

### Windows 11 Diagnostics Page

On Windows 11 devices where the ESP profile has **Turn on log collection and diagnostics page for end users** set to **Yes**, press **Ctrl+Shift+D** during OOBE or select **View Diagnostics** in the ESP error screen. This surfaces a structured diagnostics view without requiring command-line access.

---

## Common Deployment Failures

See [Windows Autopilot troubleshooting FAQ](https://learn.microsoft.com/en-us/autopilot/troubleshooting-faq) and [Windows Autopilot known issues](https://learn.microsoft.com/en-us/autopilot/known-issues) for the authoritative Microsoft reference.

### Failure Table

| Symptom | Error Code | Likely Cause | Resolution |
|---|---|---|---|
| Device does not receive Autopilot profile at OOBE | — | Device not registered, or group membership not propagated | Confirm device appears in **Intune > Devices > Windows Autopilot > Devices**. Confirm device is in the target dynamic group. Allow up to 24 hours for group membership. |
| "Something went wrong" at OOBE, no profile applied | 0x801C0003 | Device not registered with Autopilot service | Re-register device: delete existing registration and re-import hardware hash CSV. |
| ESP times out before apps complete | 0x800705B4 | App installation exceeds ESP timeout | Increase ESP timeout (default 60 minutes). Review app assignment settings — confirm **Required** and **System** install context. Check IME logs at `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\`. |
| File not found error during app install | 0x80070002 | App package content missing or corrupted | Verify the `.intunewin` package uploads successfully. Re-package using the [Win32 Content Prep Tool](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare) and re-upload. |
| Generic failure during ESP | 0x80004005 | Multiple possible causes | Collect MDM diagnostic cab. Review `IntuneManagementExtension.log` for the specific failing app or policy. |
| Profile applied but wrong profile | — | Multiple profiles targeting same device group | Review all profile assignments. The oldest (lowest precedence number) profile wins when multiple profiles match the same device. Remove conflicting assignments. |
| Device registers but deployment does not start | — | Profile not assigned to device's group | Confirm group tag on device matches dynamic group membership rule. |

### Checking App Assignment Status

```powershell
# Check Win32 app installation state on device
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\*" |
    Select-Object PSChildName, InstallState

# Review last 10 app installation errors from IME
Get-EventLog -LogName Application -Source "Microsoft Intune Management Extension" -EntryType Error -Newest 10
```

### Verifying Profile Assignment

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.Read.All"

# Check all profile assignments — identify conflicts
Get-MgDeviceManagementWindowsAutopilotDeploymentProfile |
    ForEach-Object {
        $p = $_
        Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment `
            -WindowsAutopilotDeploymentProfileId $p.Id |
        Select-Object @{N='Profile';E={$p.DisplayName}}, *
    }
```

---

## Network Connectivity Issues

Network failures are the most common silent cause of Autopilot failures. The device must reach all required endpoints before and throughout OOBE. See [Windows Autopilot requirements — networking](https://learn.microsoft.com/en-us/autopilot/requirements) and [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints) for the authoritative endpoint lists.

### Required Endpoint Validation

Run the following connectivity test from the provisioning device or a representative device on the same network segment:

```powershell
$endpoints = @(
    "ztd.dds.microsoft.com",
    "cs.dds.microsoft.com",
    "login.microsoftonline.com",
    "login.live.com",
    "enrollment.manage.microsoft.com",
    "enterpriseregistration.windows.net",
    "device.login.microsoftonline.com",
    "portal.manage.microsoft.com",
    "time.windows.com"
)

foreach ($endpoint in $endpoints) {
    $result = Test-NetConnection -ComputerName $endpoint -Port 443 -WarningAction SilentlyContinue
    [PSCustomObject]@{
        Endpoint  = $endpoint
        Reachable = $result.TcpTestSucceeded
        RTT_ms    = $result.PingReplyDetails.RoundtripTime
    }
}

# Test time sync (UDP 123)
Test-NetConnection -ComputerName "time.windows.com" -Port 123
```

All endpoints must return `TcpTestSucceeded : True`. Any failure requires firewall or proxy remediation before retrying deployment.

### Proxy Troubleshooting

If a proxy is in use:

1. Confirm the proxy supports **TLS 1.2** — older proxies performing TLS inspection on a lower version will break certificate validation.
2. Confirm the proxy does not perform deep packet inspection (DPI) or SSL break-and-inspect on the Microsoft endpoints listed above. DPI on authentication endpoints breaks device registration.
3. Check the proxy bypass list includes `*.microsoftonline.com`, `*.manage.microsoft.com`, `*.windows.net`, and `*.windowsupdate.com`.
4. Verify the system proxy configuration is visible to the Windows OOBE context:

```cmd
netsh winhttp show proxy
```

If the proxy is not configured at the WinHTTP level, OOBE processes — which run as SYSTEM — will not use it. Apply proxy settings at the WinHTTP level, or configure a Proxy Auto-Configuration (PAC) file accessible without authentication.

### Time Synchronisation

Certificate validation failures during device registration are frequently caused by clock skew. The Windows Autopilot service requires accurate time. Confirm UDP port 123 to `time.windows.com` is reachable and not blocked by the firewall. Verify device clock accuracy:

```cmd
w32tm /query /status
```

---

## Hybrid Join Failures

Microsoft recommends cloud-native (Microsoft Entra join) for all new deployments. Hybrid join adds significant dependency complexity. For guidance on hybrid join setup, see [Enrollment for Microsoft Entra hybrid joined devices](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-hybrid).

### ODJ Connector Issues

The Intune Connector for Active Directory (ODJ connector) performs the offline domain join during hybrid Autopilot provisioning. Connector versions older than **6.2501.2000.5** are deprecated and will not process enrolment requests. See [Install the Intune Connector for Active Directory](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/hybrid-azure-ad-join-intune-connector) for installation requirements.

**Verify connector version and service state:**

```powershell
# Check installed connector version (must be >= 6.2501.2000.5)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Intune on-premise Connector" -Name "Version"

# Verify connector service is running
Get-Service "Microsoft Intune Connector" | Select-Object Name, Status, StartType
```

**Verify connector event logs** on the member server hosting the connector:

```
Event Viewer > Applications and Services Logs > ODJ Connector Server
```

Common ODJ connector errors:

| Error | Cause | Resolution |
|---|---|---|
| "Failed to get the ODJ Blob — insufficient privileges" | MSA account lacks permission to create computer objects in the target OU | Open ADUC (dsa.msc), right-click the target OU, select **Delegate Control**, and grant the connector's Managed Service Account (MSA) permission to create Computer objects. |
| 0x80070774 — domain not found | Device cannot reach a domain controller at join time, or **Assign user** is configured in a hybrid join profile | Verify DC connectivity from the provisioning network. Remove the **Assign user** setting — it is not supported in hybrid join scenarios. |
| 0x80070002 — timed out waiting for ODJ blob | Network connectivity failure between device and connector, or connector service not running | Verify the connector service is running. Verify network path between the provisioning device and the connector server. |
| OU not found during join | Target OU not listed in `ODJConnectorEnrollmentWizard.exe.config` | Edit the config file on the connector server and add the target OU in LDAP distinguished name format. Multiple OUs are separated by semicolons. |

### Domain Join Timing

The ODJ connector must obtain the offline domain join blob and return it to Intune before the provisioning device times out waiting. If the connector is under load or DNS resolution to the connector is slow, this window can be missed.

- Confirm the connector server has low latency DNS resolution for Intune endpoints.
- Do not install the connector on a domain controller — install on a dedicated domain-joined member server.
- If multiple connector servers exist, confirm all are at the required version.

### DNS Resolution for Hybrid Join

The provisioning device must be able to resolve domain controller DNS records at join time. If the device is on a network segment that does not have access to internal DNS:

1. Confirm DHCP provides the internal DNS server address on the provisioning VLAN.
2. Confirm the internal DNS server can resolve `_ldap._tcp.<domain>` SRV records.
3. Check `C:\Windows\Debug\NetSetup.log` on the device for the exact domain join error.

---

## Emergency Procedures

### Autopilot Reset (Entra Joined Devices)

Autopilot Reset wipes user data, settings, and apps while preserving the device's Entra ID join and Intune enrolment. This is the preferred reset method for repurposing an enrolled device. See [Windows Autopilot Reset](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-reset) for full prerequisites.

Autopilot Reset supports **Entra joined devices only** — it does not support hybrid joined devices.

**Remote reset via Intune:**

1. Navigate to **Devices > All devices > [Device]**.
2. Select **Autopilot Reset** from the device actions menu.
3. Confirm the action. The device will reboot into OOBE and re-provision from the assigned Autopilot profile.

Requires the **Intune Service Administrator** role. See [Remote Device Action: Autopilot Reset](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/device-autopilot-reset).

**Remote reset via PowerShell:**

```powershell
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.PrivilegedOperations.All"

$device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'DEVICENAME'"
Invoke-MgWipeDeviceManagementManagedDevice -ManagedDeviceId $device.Id -KeepEnrollmentData:$true
```

### Full Device Wipe

A full wipe (factory reset) removes all data, settings, enrolment, and Entra ID join. Use this when a device needs to be retired, re-deployed to a different tenant, or has an unrecoverable enrolment state. See [Remote Device Action: Wipe](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/device-wipe).

Navigate to **Devices > All devices > [Device] > Wipe**. After wipe completes, the device will restart to the Windows OOBE — if the device's serial number is still registered in Autopilot, it will re-enrol automatically on next boot.

**Local reset (on device):**

```cmd
systemreset -cleanpc
```

### Re-register a Device

If a device was wiped or had its Autopilot registration deleted, re-register it:

```powershell
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Check for and remove existing stale registration
$existing = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity `
    -Filter "contains(serialNumber,'<SERIALNUMBER>')"
if ($existing) {
    Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity `
        -WindowsAutopilotDeviceIdentityId $existing.Id
}

# Re-collect hardware hash on device and re-import CSV via Intune admin centre
# Devices > Windows > Enrollment > Windows Autopilot > Devices > Import
```

### Remove a Deployment Profile

To remove a profile assignment without deleting the profile:

1. Navigate to **Devices > Windows > Enrollment > Windows Autopilot > Deployment Profiles**.
2. Select the profile.
3. Select **Assignments** and remove the target group from **Included groups**.
4. Save. The change takes effect on next device sync (allow up to 15 minutes).

To delete the profile entirely, confirm no devices are actively provisioning against it, then select **Delete** from the profile overview.

---

## Related Resources

- [Windows Autopilot troubleshooting FAQ](https://learn.microsoft.com/en-us/autopilot/troubleshooting-faq)
- [Windows Autopilot known issues](https://learn.microsoft.com/en-us/autopilot/known-issues)
- [Collect MDM logs](https://learn.microsoft.com/en-us/windows/client-management/mdm-collect-logs)
- [Troubleshoot the Enrollment Status Page (ESP)](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-enrollment/understand-troubleshoot-esp)
- [Remote Device Action: Collect Diagnostics](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics)
- [Windows Autopilot requirements — networking](https://learn.microsoft.com/en-us/autopilot/requirements)
- [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints)
- [Enrollment for Microsoft Entra hybrid joined devices](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-hybrid)
- [Install the Intune Connector for Active Directory](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/hybrid-azure-ad-join-intune-connector)
- [Windows Autopilot Reset](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-reset)
- [Remote Device Action: Autopilot Reset](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/device-autopilot-reset)
- [Remote Device Action: Wipe](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/device-wipe)
- [Deploy Windows Autopilot — how-to-deploy-autopilot.md](how-to-deploy-autopilot.md)
