---
title: "Deploy Windows Autopilot"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "how-to"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Deploy Windows Autopilot

This guide covers the end-to-end steps required to deploy Windows Autopilot in a Microsoft 365 environment, from confirming prerequisites through to validating a successful device provisioning. It assumes familiarity with Microsoft Intune, Microsoft Entra ID, and Windows device management concepts.

---

## Prerequisites

Confirm all prerequisites are satisfied before proceeding. Incomplete prerequisites are the most common cause of failed deployments.

### Licensing

- [ ] One of the following subscriptions is assigned to each user: Microsoft 365 Business Premium, Microsoft 365 F1/F3, Microsoft 365 Enterprise E3/E5, Microsoft 365 Academic A1/A3/A5, or Enterprise Mobility + Security (EMS) E3/E5. Alternatively, [Microsoft Entra ID P1 or P2 combined with a Microsoft Intune subscription](https://learn.microsoft.com/en-us/autopilot/requirements) satisfies the requirement.
- [ ] Licences are explicitly assigned to users — subscriptions alone do not automatically grant access.
- [ ] Windows 10 Pro/Enterprise version 1809 or later, or any Windows 11 version, is installed on target devices. See [Windows Autopilot requirements](https://learn.microsoft.com/en-us/autopilot/requirements) for the full software requirements list.

### Microsoft Entra ID

- [ ] [Automatic MDM enrolment is enabled](https://learn.microsoft.com/en-us/autopilot/requirements): navigate to **Microsoft Entra admin centre > Identity > Mobility (MDM and MAM) > Microsoft Intune** and set MDM User Scope to **All** (or a scoped pilot group).
- [ ] Device registration is permitted: navigate to **Microsoft Entra admin centre > Identity > Devices > Device settings** and confirm **Users may join devices to Microsoft Entra ID** is set to **All** or the appropriate group.
- [ ] Multi-Factor Authentication (MFA) is required for device registration (recommended): set **Require Multi-Factor Authentication to register or join devices** to **Yes**.
- [ ] If using a custom domain, a DNS CNAME record exists: `enterpriseregistration.<yourdomain>` pointing to `enterpriseregistration.windows.net`.

### Intune

- [ ] The administrator account holds at minimum the **Intune Administrator** or **Policy and Profile Manager** role.
- [ ] The Microsoft Intune admin centre is accessible at [intune.microsoft.com](https://intune.microsoft.com/).

### Network

The provisioning device must have outbound HTTPS (TCP 443) access to the following endpoints before and during OOBE. See [Windows Autopilot requirements — networking](https://learn.microsoft.com/en-us/autopilot/requirements) and [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints) for the authoritative lists.

| Endpoint | Purpose |
|---|---|
| `ztd.dds.microsoft.com` | Autopilot deployment service |
| `cs.dds.microsoft.com` | Autopilot deployment service |
| `login.microsoftonline.com` | Authentication |
| `*.manage.microsoft.com` | Intune enrolment and management |
| `enterpriseregistration.windows.net` | Device registration |
| `device.login.microsoftonline.com` | Device authentication |
| `*.windowsupdate.com` | Windows Update during OOBE |
| `*.delivery.mp.microsoft.com` | Delivery Optimisation |
| `*.msftconnecttest.com` | Network Connectivity Status Indicator (NCSI) |
| `time.windows.com` (UDP 123) | Time synchronisation |

- [ ] All endpoints above are reachable from the provisioning network.
- [ ] If a proxy is in use, it supports TLS 1.2 and does not perform deep packet inspection on the above endpoints.

### Hardware

- [ ] Devices have TPM 2.0 and UEFI firmware with Secure Boot capability.
- [ ] Minimum 64 GB available storage.

---

## Register Devices

Devices must be registered with the Windows Autopilot service before a deployment profile can be applied. See [Windows Autopilot registration overview](https://learn.microsoft.com/en-us/autopilot/registration-overview) for all available registration methods.

### Collect Hardware Hashes

The hardware hash is the unique device identifier used by the Autopilot service.

**Method: Get-WindowsAutoPilotInfo script (manual or pilot scale)**

Run the following on each device booted into Windows, as an administrator. See [Manually register devices with Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/add-devices) for full instructions.

```powershell
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo.ps1 -OutputFile C:\Temp\DeviceHWID.csv -GroupTag "Corporate"
```

The resulting CSV uses the required format:

```
Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User
```

Up to 500 devices can be imported per CSV file. Do not open CSV files in Microsoft Excel — use Notepad to avoid hidden character corruption.

### Import via CSV

1. Sign in to the [Microsoft Intune admin centre](https://intune.microsoft.com/).
2. Navigate to **Devices > Windows > Enrollment > Windows Autopilot > Devices**.
3. Select **Import** and upload the CSV file.
4. Wait for the import to process — allow up to 15 minutes. Sync operations are rate-limited to once every 10 minutes.

### OEM Registration

For new hardware purchased through a participating OEM or Cloud Solution Provider (CSP), the OEM can register devices directly using the device's Product Key ID (PKID) barcode — no CSV collection is required. The Global Administrator must authorise the OEM to perform registration. See [Windows Autopilot registration overview](https://learn.microsoft.com/en-us/autopilot/registration-overview) for OEM and CSP registration paths.

### Create Device Groups

Dynamic Entra ID security groups control which devices receive which deployment profiles.

Navigate to **Microsoft Entra admin centre > Groups > New group** and create a dynamic device group with the following membership rule to target all registered Autopilot devices:

```
(device.devicePhysicalIds -any _ -startswith "[ZTDId]")
```

To target devices by group tag (e.g. `Corporate`):

```
(device.devicePhysicalIds -any _ -eq "[OrderID]:Corporate")
```

See [Create device groups for Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/enrollment-autopilot) for further group rule patterns.

---

## Configure Deployment Profiles

Deployment profiles define the deployment mode, OOBE behaviour, and device naming. Up to 350 profiles can be created per tenant. See [Configure Windows Autopilot profiles](https://learn.microsoft.com/en-us/autopilot/profiles) for the full settings reference.

### Create a Profile

1. Navigate to **Devices > Windows > Enrollment > Windows Autopilot > Deployment Profiles**.
2. Select **Create Profile > Windows PC**.
3. On the **Basics** page, enter a name and description.
4. On the **Out-of-box experience (OOBE)** page, configure settings per the table below.
5. On the **Assignments** page, assign the profile to the appropriate device group.
6. Select **Review + Create**.

### Recommended Settings — User-Driven Entra Join

| Setting | Recommended Value | Notes |
|---|---|---|
| Deployment mode | User-driven | User authenticates during OOBE |
| Join to Microsoft Entra ID as | Microsoft Entra joined | Preferred over hybrid join for new deployments |
| Microsoft Software Licence Terms | Hide | Reduces OOBE friction |
| Privacy settings | Hide | Reduces OOBE friction |
| Hide change account options | Yes | Prevents account switching at OOBE |
| User account type | Standard | Follows least-privilege principle |
| Allow pre-provisioning | Yes | Enables technician pre-staging |
| Apply device name template | Yes | Enforces naming standards |
| Device name template | `CORP-%RAND:5%` | Adjust prefix to match naming convention |
| Convert all targeted devices to Autopilot | Yes | Auto-registers existing Intune devices |

For self-deploying mode (kiosk and shared devices), see [Windows Autopilot self-deploying mode](https://learn.microsoft.com/en-us/autopilot/self-deploying).

### Assignment Behaviour

Profile assignment resolves through Entra ID group membership. Allow up to 24 hours for initial group membership propagation on newly registered devices. Ensure target groups are listed under **Included groups** — devices in **Excluded groups** will not receive the profile.

---

## Configure Enrolment Status Page

The Enrolment Status Page (ESP) displays provisioning progress during OOBE and controls whether users can access the desktop before apps and policies are installed. See [Windows Autopilot Enrollment Status Page](https://learn.microsoft.com/en-us/autopilot/enrollment-status) for the full settings reference and [Troubleshoot the Enrollment Status Page](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-enrollment/understand-troubleshoot-esp) for diagnostics.

### Create an ESP Profile

1. Navigate to **Devices > Windows > Enrollment > Enrollment Status Page**.
2. Select **Create**.
3. Configure settings per the table below.
4. Assign to the same device group used for the deployment profile.

Up to 51 ESP profiles can exist in a tenant. The profile with priority **1** (highest) takes precedence when multiple profiles target the same device.

### Recommended ESP Settings

| Setting | Recommended Value | Notes |
|---|---|---|
| Show app and profile installation progress | Yes | Required for tracking and diagnostics |
| Block device use until all apps and profiles are installed | Yes | Prevents partially provisioned access |
| Allow users to reset device if installation error occurs | Yes | Enables user self-recovery |
| Allow users to collect logs about installation errors | Yes | Enables on-device diagnostics |
| Show custom message when time limit error occurs | Yes | Set appropriate IT support message |
| Error time limit (minutes) | 60 | Increase for large app deployments |
| Block device use until required apps are installed | Selected required apps | Track only blocking apps during OOBE |
| Turn on log collection and diagnostics page for end users (Windows 11) | Yes | Enables the diagnostics button and CTRL+SHIFT+D shortcut |

### App Tracking in ESP

Only apps assigned with **Required** intent and tagged as blocking in the ESP profile are tracked during OOBE. Assign only genuinely blocking apps (security software, VPN client, Company Portal) to the ESP blocking list. Non-blocking apps can be assigned as **Required** to Intune groups and will install post-OOBE without delaying provisioning.

---

## Assign Applications

Applications assigned during Autopilot provisioning install during the device ESP phase. See [App management in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-management) for application types and deployment guidance.

### Required Apps During OOBE

Assign the following application types as **Required** and configured for **System** install context to ensure they install during the device phase of ESP:

| App Type | Install Context | ESP Blocking |
|---|---|---|
| Microsoft 365 Apps for Enterprise | System | Optional (large — assess timeout impact) |
| Company Portal | System | Yes |
| Security software (e.g. VPN client, EDR) | System | Yes |
| Core line-of-business applications | System | Assess per application |

**Win32 app packaging:** All MSI-based applications must be converted to the `.intunewin` format using the [Microsoft Win32 Content Prep Tool](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare) before upload. Win32 apps are the recommended format for Autopilot deployments.

**Enterprise App Catalogue (June 2025):** Apps from the Microsoft Enterprise App Catalogue can now be configured to block during ESP. Navigate to **Apps > Enterprise App Catalogue** to configure catalogue app assignments.

### Required Win32 App Assignment Settings

| Setting | Value |
|---|---|
| Assignment type | Required |
| Install behaviour | System |
| Device restart behaviour | Intune will force a mandatory device restart |
| Return code — success | 0 |
| Return code — soft reboot | 1641, 3010 |

### Available Apps Post-Provisioning

Assign non-critical applications as **Available** to user or device groups. These apps appear in the Company Portal after provisioning completes and do not extend OOBE duration.

---

## Validate Deployment

Test with a physical or virtual pilot device before deploying to production groups.

### Pre-Deployment Checks

1. Confirm the device serial number appears under **Devices > Windows > Enrollment > Windows Autopilot > Devices** in the Intune admin centre.
2. Confirm the device is a member of the target dynamic device group (allow up to 24 hours for group membership to propagate).
3. Confirm the deployment profile shows as **Assigned** against the device or its group.
4. Test network connectivity from the provisioning subnet using the required endpoint list in the Prerequisites section.

### Deployment Test Procedure

1. Factory-reset or use a new device and power it on.
2. Connect to the provisioning network (Ethernet recommended for first deployment).
3. Proceed through the Autopilot-customised OOBE — the device should skip standard setup screens.
4. Authenticate with a licensed user account.
5. Monitor ESP progress — all tracked apps should install to completion.
6. After provisioning, sign in and verify:

| Check | Expected Result |
|---|---|
| `dsregcmd /status` | `AzureAdJoined: YES`, `MDMUrl` populated |
| Device appears in Intune > All devices | Enrolled, compliant |
| Assigned apps installed | Visible in Add/Remove Programs or Company Portal |
| Compliance policy applied | Device marked compliant in Intune |
| BitLocker status | Enabled and recovery key escrowed to Entra ID |

### Monitoring Deployments at Scale

Navigate to **Devices > Monitor > Autopilot deployments** to review the 30-day deployment report. Review **Enrollment failures** under **Devices > Monitor** for failed provisioning events.

---

## Related Resources

- [Windows Autopilot overview](https://learn.microsoft.com/en-us/autopilot/overview)
- [Windows Autopilot requirements](https://learn.microsoft.com/en-us/autopilot/requirements)
- [Windows Autopilot registration overview](https://learn.microsoft.com/en-us/autopilot/registration-overview)
- [Manually register devices with Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/add-devices)
- [Create device groups for Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/enrollment-autopilot)
- [Configure Windows Autopilot profiles](https://learn.microsoft.com/en-us/autopilot/profiles)
- [Windows Autopilot user-driven Entra join — profile creation](https://learn.microsoft.com/en-us/autopilot/tutorial/user-driven/azure-ad-join-autopilot-profile)
- [Windows Autopilot self-deploying mode](https://learn.microsoft.com/en-us/autopilot/self-deploying)
- [Windows Autopilot Enrollment Status Page](https://learn.microsoft.com/en-us/autopilot/enrollment-status)
- [App management in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-management)
- [Microsoft Win32 Content Prep Tool](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare)
- [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/intune-endpoints)
- [Licences available for Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/licenses)
- [Troubleshoot Windows Autopilot — how-to-troubleshoot.md](how-to-troubleshoot.md)
