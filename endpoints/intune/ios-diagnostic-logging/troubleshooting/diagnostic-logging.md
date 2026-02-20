# Troubleshooting — iOS/iPadOS Diagnostic Logging

> **Document type**: Troubleshooting guide — symptom-based reference for common failures across all iOS/iPadOS diagnostic logging workflows.

## Overview

This page covers common issues encountered when collecting diagnostic logs from iOS/iPadOS devices, along with resolution steps. Use this as a reference when a workflow from the other guides doesn't behave as expected.

---

## Collect Diagnostics Action Not Available

**Symptom**: The **Collect diagnostics** option is greyed out or missing from the device action bar in the Intune admin center.

**Possible causes and resolutions**:

- **Insufficient permissions** — The signed-in administrator's role does not include the [**Remote tasks: Collect diagnostics** permission](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics). Verify the role assignment under **Tenant administration → Roles** and ensure the role includes this permission.

> **UI Path**: Tenant administration → **Roles** → *select role* → **Properties** → **Permissions**

- **Feature disabled at tenant level** — Diagnostic collection may be toggled off. Navigate to **Tenant administration → Device diagnostics** and ensure the feature is enabled.

> **UI Path**: Tenant administration → **Device diagnostics** → verify toggle is **On**

- **Device not enrolled** — The Collect Diagnostics remote action only applies to MDM-enrolled devices. For MAM-only/BYOD devices, use the [MAM App Protection Diagnostics](../how-to/mam-app-protection-diagnostics.md) workflow instead.

---

## Diagnostic Collection Stuck on Pending

**Symptom**: After triggering Collect Diagnostics, the action remains in **Pending** status indefinitely.

**Possible causes and resolutions**:

- **Device is offline** — The device must be connected to the internet and able to reach Intune services. The device has a [**24-hour window**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) to check in and receive the collection request. If it doesn't check in within this window, the action will fail.

- **Push notification issues** — There is a [known behaviour](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) where the Collect Diagnostics action may not trigger the expected push notification to the device. The device will only collect logs when it next performs a routine check-in with Intune, which may introduce a delay. As a workaround, ask the end-user to open Company Portal and manually trigger a device sync.

> **UI Path** (user's device): Company Portal → **Devices** tab → *select device* → **Check status** (or pull down to refresh)

- **Network connectivity** — Ensure the device can reach the regional blob storage endpoints used by Intune for diagnostic uploads. If your organisation uses a firewall or proxy, confirm that the Intune service endpoints are allowed.

---

## Download Button Missing or Package Cannot Be Downloaded

**Symptom**: The diagnostic entry appears in the **Diagnostics** tab, but there is no download option, or downloading fails.

**Possible causes and resolutions**:

- **File size exceeded** — If the diagnostic upload exceeds [**4 MB** in total size or contains more than **50 individual diagnostic files**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics), the package cannot be downloaded from the Intune portal. In this case, open a Microsoft support ticket and provide the diagnostic details — support engineers can access larger packages directly.

- **Package expired** — Diagnostic packages are retained for [**28 days**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) only. If more than 28 days have passed since collection, the package has been automatically deleted. Re-trigger the collection.

- **Storage limit reached** — Each device can hold a maximum of [**10 diagnostic collections**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) at a time. If this limit is reached, older collections must be deleted before new ones can be stored.

---

## User Does Not Receive Diagnostic Consent Prompt (MAM)

**Symptom**: After triggering MAM diagnostic collection from the admin center, the end-user reports that no prompt appeared in the managed app.

**Possible causes and resolutions**:

- **App not reopened** — The user must [**close and reopen**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) the managed app after the collection request is sent. The consent prompt only appears when the app is freshly launched after the request.

- **App not in the supported list** — MAM diagnostic collection only works with supported Microsoft 365 apps. Verify that the app in question is on the [supported application list](../how-to/mam-app-protection-diagnostics.md#supported-applications).

- **Tenant setting not enabled** — Confirm that the MAM diagnostic collection toggle is enabled under **Tenant administration → Device diagnostics**.

> **UI Path**: Tenant administration → **Device diagnostics** → verify MAM diagnostic setting is **On**

---

## Edge about:intunehelp Shows No Data or Limited Information

**Symptom**: Navigating to **about:intunehelp** in Microsoft Edge on the device shows an empty page, no apps listed, or apps show only version and bundle ID with no policy details.

**Possible causes and resolutions**:

- **No App Protection Policy applied** — If an app appears with only its version number and bundle ID (and a check-in timestamp, but no detailed settings), it means no App Protection Policy is currently targeting that app for this user. Verify the policy assignment in the Intune admin center.

> **UI Path**: Apps → **App protection policies** → *select policy* → **Properties** → **Assignments**

- **Edge not managed** — The diagnostics console in Edge only functions when Edge itself is [managed by an Intune App Protection Policy](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge). If Edge is installed but has no policy assigned, the diagnostics page may be empty or non-functional.

- **Stale check-in** — If the **policy check-in timestamp** is old, the app may not have synchronised recently. Ask the user to close and reopen Edge, which typically triggers a fresh policy check-in.

---

## Shake Gesture Not Working (Company Portal)

**Symptom**: Shaking the iOS device while Company Portal is open does not trigger the **Send Diagnostic Report** prompt.

**Resolution**:

The shake gesture must be [explicitly enabled](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) in iOS settings. Guide the user to:

1. Open the iOS **Settings** app
2. Scroll to or search for **Company Portal** under the Apps section
3. Enable the **Shake Gesture** toggle

> **UI Path**: iOS Settings → Apps → **Company Portal** → **Shake Gesture** → toggle **On**

After enabling, the user should return to Company Portal and shake the device again.

---

## Logs Uploaded but Not Visible in Admin Center

**Symptom**: The end-user confirms they uploaded logs from Company Portal, but no diagnostic entry appears in the Intune admin center for that user.

**Possible causes and resolutions**:

- **Log routing** — Logs sent via Company Portal's **Send Logs** feature are uploaded to Microsoft's backend, but they are not always surfaced in the admin center's Troubleshooting + support pane. These logs are primarily intended for use by Microsoft support engineers via support tickets.

- **Use the incident ID** — Ensure the user has captured the **incident ID** shown after upload. This ID is the primary mechanism for locating the logs. Include it in any Microsoft support ticket.

- **Different workflow needed** — If you need logs visible directly in the admin center, use the admin-initiated [remote diagnostics](../how-to/admin-initiated-diagnostics.md) or [MAM diagnostics](../how-to/mam-app-protection-diagnostics.md) workflow instead.

---

## Company Portal Send Logs Unavailable (Sovereign Cloud)

**Symptom**: The **Send Logs** option is missing or greyed out in Company Portal, despite the app being up to date and the user being signed in.

**Possible cause and resolution**:

- **Sovereign cloud environment** — In [sovereign cloud environments](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) (such as Azure Government or Azure China), the in-app Send Logs feature may be **unavailable**. This is a known platform limitation. Guide the user to use the **Email Logs** option instead, or retrieve logs manually using the [macOS Console method](../how-to/user-side-log-collection.md#method-5--manual-log-retrieval-via-macos-console-advanced) and email them to IT support.

---

## Network-Related Upload Failures

**Symptom**: Diagnostic collection appears to succeed (status moves beyond Pending) but no package appears for download, or the device reports an upload failure.

**Possible causes and resolutions**:

- **Blob storage endpoints blocked** — Intune uploads diagnostic packages to [regional Azure Blob Storage endpoints](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics). If your organisation uses a web proxy, firewall, or content filter, these endpoints must be in the allow list. Check with your network team that the following endpoints are reachable from managed devices:

| Region | Endpoint |
|--------|----------|
| Europe | lgmsapeweu.blob.core.windows.net |
| Americas | Regional Americas endpoint |
| East Asia / India | lgmsapeind.blob.core.windows.net |

- **Apple Push Notification service (APNs) blocked** — The initial push notification that prompts the device to check in is sent via APNs. If APNs traffic is blocked by the network, the device will not receive the collection request promptly. Verify that APNs ports and endpoints are open.

- **VPN or conditional access interference** — If the device connects through a VPN or is subject to conditional access policies that restrict network access for certain apps, the diagnostic upload may fail. Temporarily test with the VPN disconnected or with the device on a less restrictive network to isolate the issue.

---

## MAM Diagnostics Collected but Status Never Updates

**Symptom**: The user confirms they consented and reopened the app, but the **Diagnostic Status** column in the admin center never progresses beyond its initial state.

**Possible causes and resolutions**:

- **Allow 15 minutes** — After the user interacts with the app, allow approximately 15 minutes for the status to update in the admin center. The status does not update in real time.

- **App not fully closed** — On iOS, simply swiping away from an app does not always terminate it. Advise the user to force-close the app (swipe up from the app switcher) and then reopen it to ensure a fresh launch and policy check-in.

- **7-day window expired** — If this is a repeat collection request and more than 7 days have passed since the user's last consent, the request requires fresh approval. Confirm that the user actually received and accepted the consent prompt.

---

## General Tips

**Always reproduce the issue with verbose logging enabled.** Before asking a user to reproduce a problem, have them enable verbose logging in Company Portal first. This significantly increases the diagnostic detail captured and reduces the likelihood of needing a second log collection. See the [detailed verbose logging instructions](../how-to/user-side-log-collection.md#enabling-verbose-logging) for the exact steps.

**Verbose logging is user-controlled only.** There is no way for an administrator to remotely enable verbose logging on a device. You must communicate with the end-user and guide them through enabling it manually in the Company Portal app settings. Plan your troubleshooting session accordingly — contact the user first, have them enable verbose logging, then reproduce the issue.

**Use the about:intunehelp console for quick policy verification.** Before collecting full diagnostic logs, checking the Edge diagnostics console can quickly confirm whether the expected App Protection Policy is applied and which SDK version the app is running. This can save time by ruling out policy assignment issues before investing in a full log collection.

**Clear old diagnostics in Edge before collecting.** When using the Edge diagnostics console, always select the **Clear** icon before reproducing an issue. This ensures the collected logs only contain data relevant to the current problem.

**Check Intune SDK versions when policies don't apply.** If an App Protection Policy setting isn't taking effect, the app's [Intune SDK version](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment) (visible in the Edge diagnostics console) may be too old to support that setting. Check the Microsoft documentation for SDK version requirements. Each policy setting has a minimum SDK version — newer settings will silently fail on apps with older SDK versions.

**Leverage the [7-day auto-approval window](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) for MAM.** After a user approves a MAM diagnostic collection request, subsequent requests for the same app within the next 7 days are automatically approved. Use this window to collect multiple rounds of logs during an extended investigation without requiring repeated user interaction.

**Coordinate timing with end-users.** Both MAM diagnostic collection and Company Portal log uploads require user interaction. When triggering collection remotely, inform the user immediately so they can close and reopen the relevant app while it is still fresh in their workflow. For best results, use the [Guided Troubleshooting Session](../how-to/user-side-log-collection.md#recommended-guided-troubleshooting-session-workflow) workflow.

**Use the Troubleshooting + support pane as your hub.** Rather than navigating to individual devices, use the user-centric **Troubleshooting + support** pane as your starting point. From a single user view, you can access their devices, App Protection status, diagnostic packages, and policy assignments — all the information needed for a complete diagnostic investigation.

**Pre-deploy the Edge diagnostics bookmark.** If your organisation uses App Protection Policies, consider deploying an App Configuration Policy that adds an **about:intunehelp** bookmark to Microsoft Edge. This saves time when you need to direct users to the diagnostics console during a support call. See the [bookmark configuration instructions](../how-to/mam-app-protection-diagnostics.md#tip--bookmark-the-diagnostics-page) for details.

---

*Return to [iOS Diagnostic Logging](../README.md) · Previous: [MAM App Protection Diagnostics](../how-to/mam-app-protection-diagnostics.md)*
