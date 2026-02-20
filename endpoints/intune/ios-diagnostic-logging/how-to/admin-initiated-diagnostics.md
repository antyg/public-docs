# Admin-Initiated Remote Diagnostics — iOS/iPadOS

> **Document type**: How-to guide — task-oriented step-by-step UI navigation for Intune administrators.

> **Before you start**: For background on how the collection mechanism works (APNs push, blob storage upload, device check-in lifecycle), see [Concepts and Architecture](../reference/concepts.md).

Use this guide to trigger a remote diagnostic collection from the Microsoft Intune admin center for a managed iOS/iPadOS device, download the resulting package, and manage the collection feature at the tenant level. No scripting is required — all steps use the admin center UI.

---

## Triggering Diagnostic Collection for a Single Device

### Step 1 — Navigate to the Device

Sign in to the [Microsoft Intune admin center](https://intune.microsoft.com). From the left-hand navigation pane, select **Devices**, then select **All devices**. Locate and select the target device from the device list.

> **UI Path**: Devices → All devices → *select target device*

### Step 2 — Initiate Collection

On the device overview page, look at the action bar across the top of the device blade. Select the ellipsis menu (**…**) if the action is not immediately visible, then select **Collect diagnostics**.

> **UI Path**: Device overview → action bar → **…** (More) → **Collect diagnostics**

A confirmation prompt will appear. Select **Yes** to confirm. Intune will send a request to the device to begin gathering diagnostic data.

### Step 3 — Monitor the Action Status

After triggering the action, you can track its progress. From the device overview page, select **Device actions status** in the **Monitor** section of the left-hand navigation.

> **UI Path**: Device overview → Monitor → **Device actions status**

The status will progress through stages such as **Pending**, **In progress**, and **Completed**. If the device is offline, the action will remain pending until the device checks in.

---

## Downloading the Collected Diagnostics

### Step 4 — Access the Diagnostics Tab

Once collection is complete, navigate to the device's detail page. Select the **Diagnostics** tab to view available diagnostic packages.

> **UI Path**: Devices → All devices → *select device* → **Diagnostics** tab

Each diagnostic entry displays the device name, platform, date created, and a download link.

### Step 5 — Download the Package

Select the diagnostic entry you wish to review, then select **Download**. The diagnostic package will download as a compressed archive containing the collected log files.

> **UI Path**: Diagnostics tab → *select entry* → **Download**

---

## Triggering Collection via the Troubleshooting Pane (Alternative Path)

Use this path when you are already investigating a specific user's issues and are working within the user-centric troubleshooting view.

### Step 1 — Navigate to Troubleshooting + Support

In the Intune admin center, select **Troubleshooting + support** from the left-hand navigation. Search for and select the target user.

> **UI Path**: **Troubleshooting + support** → *search and select user*

### Step 2 — Locate the Device

On the user's summary page, select **Devices** to view all devices associated with the user. Select the device you need diagnostics from.

> **UI Path**: User summary → **Devices** → *select target device*

### Step 3 — Trigger Collection

From the device detail view within the troubleshooting pane, select **Collect diagnostics** from the action bar and confirm with **Yes**.

> **UI Path**: Device detail → action bar → **Collect diagnostics** → **Yes**

The diagnostic package will appear in the same **Diagnostics** tab described in the main workflow above.

---

## What to Expect

> **Note**: **Timing** — The collection process can take [up to 30 minutes](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) from the time the request is sent. If the device is offline, it must check in within [24 hours](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) or the action will fail. **User experience** — The device user may be prompted to close and reopen a managed app; if the app uses a PIN or authentication policy, the user will need to re-authenticate after reopening. The collection itself runs in the background. **Storage** — Packages are retained for [**28 days**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) and then automatically deleted. Each device can store up to [**10 diagnostic collections**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) at a time. **File size limits** — If the upload exceeds [**4 MB** or contains more than **50 diagnostic files**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics), it cannot be downloaded from the Intune portal; logs may still be accessible to Microsoft support engineers if a support ticket is open.

---

## Data Collected from iOS/iPadOS

For iOS/iPadOS devices, the Collect Diagnostics action gathers [**Intune App Protection logs**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) from the following supported Microsoft 365 applications:

- Microsoft Outlook
- Microsoft Teams
- Microsoft OneDrive
- Microsoft Edge
- Microsoft Word, Excel, PowerPoint
- Microsoft OneNote
- Microsoft 365 (Office)

The diagnostic data focuses on app-level telemetry and policy application status. It does not collect personal user data by design, though log contents may incidentally include user-identifiable information such as email addresses or UPNs.

> **Note**: Unlike Windows devices, iOS/iPadOS Collect Diagnostics does **not** gather device-level system logs, configuration profiles, certificate details, registry data, or event logs. The collection scope on iOS/iPadOS is limited to app-level Intune App Protection logs. If you require deeper device-level telemetry, consider the [macOS Console method](user-side-log-collection.md#method-5--manual-log-retrieval-via-macos-console-advanced) or the [Edge diagnostics console](mam-app-protection-diagnostics.md#on-device-diagnostics-via-microsoft-edge) for additional insight.

---

## Bulk Diagnostic Collection (Windows Only)

> **Note**: Bulk collection via the **Bulk device actions** feature supports up to [25 devices at once](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics), but this capability is currently limited to **Windows devices only**. For iOS/iPadOS, diagnostics must be collected one device at a time using the single-device workflow described above.

---

## Required Permissions

To use the Collect Diagnostics action, the administrator's Intune role must include the [**Remote tasks: Collect diagnostics** permission](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics).

| Role | Includes Permission |
|---|---|
| Intune Administrator | Yes (built-in) |
| Help Desk Operator | Yes (built-in) |
| School Administrator | Yes (built-in) |
| Custom roles | Grantable individually |

---

## Network Requirements

For the diagnostic upload to succeed, the device must be able to reach the regional Azure Blob Storage endpoints used by Intune.

| Region | Blob Storage Endpoint |
|---|---|
| Europe | lgmsapeweu.blob.core.windows.net |
| Americas | Regional Americas endpoint |
| East Asia / India | lgmsapeind.blob.core.windows.net |

If your organisation uses a web proxy, firewall, or content filter, ensure these endpoints are in the allow list. Devices that cannot reach the blob storage endpoint will fail to upload diagnostic packages even if the collection itself succeeds on-device.

> **Note**: Apple Push Notification service (APNs) connectivity is also required for the initial push notification that prompts the device to check in. If APNs is blocked, the device will not receive the collection request until its next scheduled sync.

---

## Disabling Diagnostic Collection (Tenant-Wide)

If your organisation's policy requires disabling the remote diagnostic collection feature entirely, this can be done at the tenant level.

### To disable diagnostic collection

Navigate to the Intune admin center. From the left-hand navigation, select **Tenant administration**, then select **Device diagnostics**. Toggle the diagnostic collection setting to **Off**.

> **UI Path**: Tenant administration → **Device diagnostics** → toggle **Off**

This will prevent any administrator from initiating remote diagnostic collection across the entire tenant.

---

*Return to [iOS Diagnostic Logging](../README.md) · Next: [User-Side Log Collection](user-side-log-collection.md)*
