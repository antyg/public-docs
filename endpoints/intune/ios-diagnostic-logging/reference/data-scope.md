# Diagnostic Data Scope — iOS/iPadOS Diagnostic Logging

> **Document type**: Reference — what data each Intune diagnostic method collects from iOS/iPadOS devices.

---

## MDM Remote Diagnostics (Collect Diagnostics Action)

### What Is Collected

The [Collect Diagnostics remote action](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) collects [Intune App Protection logs](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) from supported Microsoft 365 applications installed on the device. The collection scope is limited to app-level policy data. Log contents may incidentally include user-identifiable information such as email addresses or UPNs.

Supported applications:

- Microsoft Outlook
- Microsoft Teams
- Microsoft OneDrive
- Microsoft Edge
- Microsoft Word
- Microsoft Excel
- Microsoft PowerPoint
- Microsoft OneNote
- Microsoft 365 (Office)

### What Is Not Collected

Unlike Windows, iOS/iPadOS Collect Diagnostics does not gather:

- Device-level system logs
- Configuration profiles
- Certificate details
- Registry data
- Event logs

These data types are Windows-only. The collection scope on iOS/iPadOS is strictly limited to app-level Intune App Protection logs.

---

## MAM App Protection Diagnostics

### What Is Collected

MAM diagnostic logs contain detailed App Protection Policy data. Log content includes:

- All applied APP settings organised by policy section, with individual setting values (e.g., PIN length, encryption level, OS version requirements):
  - **Access Requirements** — PIN settings (enabled, minimum length, expiry interval, PIN type), biometric authentication (Face ID, Touch ID), and re-check intervals
  - **Data Protection** — Encryption level, backup restrictions, cut/copy/paste controls, data transfer rules, save-to restrictions, and printing controls
  - **Conditional Launch** — Device compliance checks (jailbreak detection), minimum and maximum OS version requirements, threat level thresholds, and grace period settings
- Policy check-in history and timestamps
- App version and Intune SDK version for each managed application
- Policy assignment and targeting information
- Any policy conflicts or override conditions

### Supported Applications

[MAM diagnostic collection](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) is supported for the following Microsoft 365 applications on iOS/iPadOS:

- Microsoft Outlook
- Microsoft Teams
- Microsoft OneDrive
- Microsoft Edge
- Microsoft Word
- Microsoft Excel
- Microsoft PowerPoint
- Microsoft OneNote
- Microsoft 365 (Office)

Third-party applications that integrate the Intune App SDK may also support diagnostic collection, depending on their implementation.

### What Is Not Collected

MAM logs do not contain:

- Device-level system logs
- Configuration profiles
- MDM compliance state

MAM diagnostic logs are strictly scoped to app-level policy data.

---

## Company Portal Log Uploads

### What Is Collected

[Company Portal log uploads](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) contain app-level telemetry and interaction traces. The output file is named **Company Portal-Log.log**.

Standard log uploads include:

- App-level telemetry events
- User interaction traces

When verbose logging is enabled on the device, the log additionally includes:

- Granular event traces
- Internal error codes
- Network request metadata
- Policy evaluation detail
- Authentication flow traces

Verbose logging is user-controlled only — there is no admin-side policy or remote action that can enable it remotely.

---

## Microsoft Edge — about:intunehelp Console

### What Is Collected

The [about:intunehelp diagnostics console](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) in Microsoft Edge displays the following data directly on-device.

**Shared Device Information** — device-level context:

- Device model
- iOS/iPadOS version
- Microsoft Edge app version
- Intune user principal name (UPN)

**Intune App Status** — per managed application:

- App version
- Bundle ID (iOS bundle identifier)
- Intune SDK version
- Policy check-in timestamp (last synchronisation with the Intune service)
- Full list of applied App Protection Policy settings, organised by category:
  - **Access Requirements** — PIN settings (enabled, minimum length, expiry, type), biometric authentication (Face ID, Touch ID), re-check intervals
  - **Data Protection** — Encryption level, backup restrictions, cut/copy/paste controls, data transfer rules, save-to restrictions, printing controls
  - **Conditional Launch** — Device compliance checks (jailbreak detection), minimum and maximum OS version requirements, threat level thresholds, grace period settings

If a managed app displays only its version number, bundle ID, and check-in timestamp without detailed settings, no App Protection Policy is currently applied to that app on the device.

Log collection is initiated from **Collect Intune Diagnostics → Get Started** and shared via the iOS share sheet using **Share Logs**.

The bookmark configuration key for pre-configuring access in Edge via App Configuration Policy is:

- **com.microsoft.intune.mam.managedbrowser.bookmarks**

The [App Protection Policy may prevent saving diagnostic data](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) to the device's local storage. In that case, Share Logs is the available export path.

---

## Maintenance Notes

Items to re-verify on future review cycles:

1. **CP log visibility in admin center** — Microsoft may add visibility for Company Portal log uploads in the Intune admin center Troubleshooting pane. Check Intune What's New for updates.
2. **Push notification reliability** — The known intermittent issue with Collect Diagnostics push notifications may be resolved in a future service update.
3. **macOS Console UI** — Apple changes the Console application interface between major macOS releases; retrieval steps for the macOS Console method may require revision after major macOS updates.
4. **Edge diagnostics features** — The about:intunehelp console receives incremental updates; data fields and sections displayed may expand over time.

---

## Related

- [Concepts and Architecture](concepts.md)
- [Capabilities Comparison](capabilities.md)
- [Platform Limits and Caveats](limits-and-caveats.md)
