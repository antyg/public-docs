# Concepts and Architecture — iOS/iPadOS Diagnostic Logging

> **Document type**: Reference — conceptual definitions and architecture for iOS/iPadOS diagnostic logging.

---

## Key Concepts

**MDM (Mobile Device Management)** refers to devices that are fully enrolled in Intune. The organisation has device-level control and can push remote actions — including diagnostic collection — from the admin center. MDM enrolment is required for admin-initiated remote diagnostics via the Collect Diagnostics action.

**MAM (Mobile Application Management)** refers to scenarios where only the applications are protected by Intune App Protection Policies (APP), without full device enrolment. This is common in BYOD environments. Diagnostic log collection for MAM-only devices follows a different workflow from MDM device diagnostics and always requires user interaction on the device.

**Company Portal** is the Microsoft app installed on managed iOS devices. It serves as the primary channel for end-users to [upload diagnostic logs, report errors](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios), and communicate with IT support. Company Portal log uploads generate an incident ID that can be referenced in Microsoft support cases.

**Microsoft Edge** acts as a secondary diagnostic tool on iOS. When managed by Intune, Edge exposes a [built-in diagnostics console](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) accessible via `about:intunehelp` that can display App Protection Policy status and collect managed app logs directly on the device.

---

## Collection Mechanisms

### MDM Remote Diagnostic Collection — How It Works

The [**Collect Diagnostics** remote action](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) allows Intune administrators to request diagnostic data from managed iOS/iPadOS devices directly from the Microsoft Intune admin center. The collection happens in the background and the logs are uploaded to Intune for the administrator to download. Understanding the underlying process explains timing, failure modes, and what to expect:

1. **Admin triggers the action** — When you select **Collect diagnostics** in the admin center, Intune sends a [Graph API request](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) to the device.
2. **Push notification** — Intune attempts to send a push notification via Apple Push Notification service (APNs) to prompt the device to check in immediately.
3. **Device check-in** — Upon receiving the notification (or during its next routine sync), the device contacts the Intune service and receives the diagnostic collection instruction.
4. **Scheduled collection** — The device creates an internal task with a short delay (typically around 5 minutes) before beginning log collection. This delay allows the device to stabilise after the sync.
5. **Log packaging and upload** — The device gathers the applicable logs, packages them into a compressed archive, and uploads the archive to a [regional Azure Blob Storage endpoint](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) provided by Intune.
6. **Admin download** — Once the upload completes, the diagnostic package becomes available in the admin center for download.

If the push notification fails to reach the device (a [known intermittent issue](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics)), the device will not collect logs until its next scheduled check-in with Intune, which may introduce a significant delay.

---

### MAM Diagnostic Collection — How It Works

In environments where iOS/iPadOS devices are not fully enrolled in Intune MDM — such as BYOD scenarios — organisations often rely on App Protection Policies (APP) to secure corporate data within managed applications. This is referred to as Mobile Application Management (MAM) or "MAM without enrolment."

Admin-initiated MAM diagnostic collection is [triggered from the Intune admin center](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) via the Troubleshooting + support pane, targeting a specific user's app-protected application. When the admin triggers collection, the Intune service queues a diagnostic request for the targeted application.

The request is delivered the next time the app performs a policy check-in, which occurs when the app is launched or brought to the foreground. At that point, the user must:

1. **Close** the managed app completely
2. **Reopen** the app
3. **Consent** to the diagnostic log collection when prompted

Once the user consents, the app collects its diagnostic data and uploads it to Intune immediately.

Silent collection is not possible for MAM-managed devices. The user must actively interact with the app for logs to be collected. If the user does not reopen the app or does not consent, the collection will not complete.

After an initial diagnostic request has been approved by the user, any subsequent diagnostic requests for the same application within the next [**7 days** are **automatically approved**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) — the user will not be prompted for consent again. After the 7-day window expires, the next request will require fresh user consent.

---

### Company Portal Log Upload — How It Works

Company Portal log uploads are initiated by the end-user on the device rather than by an administrator from the admin center. When a user submits logs via the Company Portal app, the logs are uploaded to a Microsoft backend service and an **incident ID** is generated. This incident ID serves as the reference for Microsoft support cases.

Company Portal log uploads do not reliably surface in the Intune admin center Diagnostics tab. Whether the logs are visible to the administrator depends on the specific upload method used. In many cases, the logs are retained by the Microsoft backend and are accessible to Microsoft support engineers when a support case is open and the incident ID is provided, but they are not directly downloadable by the administrator from the portal.

---

## Architecture Dependencies

### Apple Push Notification Service (APNs)

Apple Push Notification service (APNs) is the mechanism Intune uses to prompt an iOS/iPadOS device to check in immediately when a remote action — including Collect Diagnostics — is triggered from the admin center. Without APNs, the device does not receive real-time notification of the pending action and will not act on the request until its next scheduled sync with the Intune service.

If APNs is blocked by a firewall, proxy, or content filter, the diagnostic collection request will not reach the device promptly. The device will eventually receive the instruction during its next routine check-in, but this may introduce a delay of several hours. APNs connectivity must be preserved for timely remote action delivery.

---

### Azure Blob Storage Endpoints

After the device completes log packaging, the diagnostic archive is uploaded to a regional Azure Blob Storage endpoint operated by Intune. The specific endpoint depends on the geographic region of the Intune tenant:

| Region | Blob Storage Endpoint |
|---|---|
| Europe | lgmsapeweu.blob.core.windows.net |
| Americas | Regional Americas endpoint |
| East Asia / India | lgmsapeind.blob.core.windows.net |

If the organisation uses a web proxy, firewall, or content filter, these endpoints must be included in the allow list. Devices that cannot reach the blob storage endpoint will fail to upload diagnostic packages even if the on-device collection itself completes successfully. The admin center action status will remain in a non-completed state until the upload succeeds or the action times out.

---

### Intune App SDK

The Intune App SDK is a library integrated directly into supported Microsoft 365 applications and third-party apps that enables App Protection Policy (APP) enforcement on iOS/iPadOS. Policy features — including data protection controls, conditional launch checks, and diagnostic log collection — are implemented through the SDK.

The SDK version integrated into an app determines which policy settings the app can enforce. Outdated SDK versions may not support newer policy settings, which can result in policies appearing to apply correctly in the admin center while not being enforced as expected on the device. When troubleshooting policy behaviour, the SDK version is a critical data point.

The Intune SDK Version for each managed application can be found in the [Microsoft Edge diagnostics console](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment) at `about:intunehelp` — navigate to **View Intune App Status** and select the target application to see the **Intune SDK Version** field alongside the app version, bundle ID, and policy check-in timestamp.

---

## Related

- [Capabilities Comparison](capabilities.md)
- [Platform Limits and Caveats](limits-and-caveats.md)
- [Diagnostic Data Scope](data-scope.md)
