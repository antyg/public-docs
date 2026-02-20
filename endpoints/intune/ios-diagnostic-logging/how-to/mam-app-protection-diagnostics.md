# MAM App Protection Diagnostics — iOS/iPadOS

> **Document type**: How-to guide — task-oriented workflows for MAM app protection diagnostic log collection on iOS/iPadOS.

> **Before you start**: This guide covers devices managed by App Protection Policies only (MAM without enrolment). For background on the difference between MDM and MAM diagnostic approaches, see [Concepts and Architecture](../reference/concepts.md).

This guide covers two workflows for collecting MAM diagnostic logs on iOS/iPadOS:

1. **[Admin-initiated remote collection](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics)** — Triggering log collection from the Intune admin centre
2. **[On-device diagnostics via Microsoft Edge](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge)** — Using the built-in Intune diagnostics console in Edge

---

## Enabling MAM Diagnostic Collection (Tenant Setting)

Before MAM diagnostic logs can be collected, the feature must be [enabled at the tenant level](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics).

### Step 1 — Navigate to Device Diagnostics

Sign in to the Microsoft Intune admin centre. From the left-hand navigation, select **Tenant administration**, then select **Device diagnostics**.

> **UI Path**: Tenant administration → **Device diagnostics**

### Step 2 — Enable the Setting

Locate the setting that enables diagnostic collection for app-protected devices (this is a separate toggle from MDM device diagnostics). Ensure it is set to **On**.

> **Note**: If your environment also includes Android devices, Android MAM diagnostics [additionally require the user to be signed into the Company Portal app](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) — even though the device is not enrolled. This requirement does not apply to iOS/iPadOS.

---

## Admin-Initiated MAM Log Collection

### Step 1 — Navigate to Troubleshooting

In the Intune admin centre, select **Troubleshooting + support** from the left-hand navigation.

> **UI Path**: **Troubleshooting + support**

### Step 2 — Select the User

Use the user search to locate the target user. Select their name to open the troubleshooting summary.

> **UI Path**: Troubleshooting + support → *search and select user*

### Step 3 — Open App Protection Summary

On the user's troubleshooting summary page, select **App protection** from the summary section. This displays all App Protection Policies applied to the user's apps, organised by platform and check-in status.

> **UI Path**: User summary → **App protection**

### Step 4 — View Checked-In Applications

Select the **Checked-in** tab to see applications that have successfully checked in with their App Protection Policy status. Locate the application you need diagnostics from.

> **UI Path**: App protection → **Checked-in** tab → *locate target application*

### Step 5 — Trigger Diagnostic Collection

Select the target application from the list. Then select **Collect diagnostics**. A confirmation dialog will appear — select **Yes** to confirm.

> **UI Path**: *Select application* → **Collect diagnostics** → **Yes**

### Step 6 — Monitor Collection Status

After triggering collection, the status will appear in the **Diagnostic Status** column next to the application. Allow approximately **15 minutes** after the user has interacted with the app before checking the status. Select **Refresh** to update the view.

> **UI Path**: App protection → Checked-in → **Diagnostic Status** column (select the hyperlink to view details)

The status will progress through stages. Once the diagnostics have been collected and uploaded, the status hyperlink will become active and the logs will be available for download.

### What Happens on the Device

When the admin triggers diagnostic collection, the Intune service queues a diagnostic request for the targeted application. The next time the app performs a policy check-in (which occurs when the app is launched or brought to the foreground), it receives the request.

The user must then:

1. **Close** the managed app completely
2. **Reopen** the app
3. **Consent** to the diagnostic log collection when prompted

Once the user consents, the app collects its diagnostic data and uploads it to Intune immediately.

The user must actively interact with the app for logs to be collected. If the user does not reopen the app or does not consent, the collection will not complete.

### 7-Day Auto-Approval Window

> **Note**: After an initial diagnostic request has been approved by the user, any subsequent diagnostic requests for the **same application** within the next [**7 days** are **automatically approved**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) — the user will not be prompted for consent again. This is useful when you need to collect logs multiple times during an extended troubleshooting investigation. After the 7-day window expires, the next request will require fresh user consent.

---

## Downloading MAM Diagnostic Logs

### Step 1 — Navigate to User Diagnostics

In the Intune admin centre, go to **Troubleshooting + support**, select the user, then select the **Diagnostics** tab.

> **UI Path**: Troubleshooting + support → *select user* → **Diagnostics** tab

### Step 2 — Download

The diagnostics tab displays all available diagnostic packages for the user, including device name, platform, creation date, and a download link. Select the relevant entry and download.

> **UI Path**: Diagnostics tab → *select entry* → **Download**

---

## On-Device Diagnostics via Microsoft Edge

### Step 1 — Open the Diagnostics Console

On the iOS/iPadOS device, open **Microsoft Edge**. In the address bar, type **about:intunehelp** and navigate to the page.

> **UI Element**: Edge address bar → type **about:intunehelp** → navigate

Edge will open in a special troubleshooting mode, displaying the **Intune Diagnostics** page.

### Step 2 — Review Device and App Information

The diagnostics page displays two main sections:

**Section 1 — Shared Device Information**: This section displays device-level context including the device model, iOS version, Edge app version, and the Intune user principal name (UPN) associated with the device. This information is useful for confirming you are looking at the correct device and for including in support tickets.

**Section 2 — Intune App Status**: Select **View Intune App Status** to see a list of all apps managed by App Protection Policies on the device. Selecting a specific app shows the APP settings currently active for that app.

> **UI Path**: Intune Diagnostics page → **View Intune App Status** → *select an app*

For each managed app, the diagnostics console displays:

- **App version** — The installed version of the application
- **Bundle ID** — The iOS bundle identifier for the app
- **Intune SDK Version** — The version of the Intune App SDK integrated into the app (critical for policy compatibility)
- **Policy check-in timestamp** — When the app last synchronised its App Protection Policy with the Intune service
- **Applied policy settings** — The full list of [APP settings](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-log) currently active, organised by category:
  - **Access Requirements** — PIN settings (enabled, minimum length, expiry, type), biometric authentication (Face ID, Touch ID), and re-check intervals
  - **Data Protection** — Encryption level, backup restrictions, cut/copy/paste controls, data transfer rules, save-to restrictions, and printing controls
  - **Conditional Launch** — Device compliance checks (jailbreak detection), minimum and maximum OS version requirements, threat level thresholds, and grace period settings

If an app only shows its version number and bundle ID with a check-in timestamp (but no detailed settings), this indicates that no App Protection Policy is currently applied to that app on this device.

### Step 3 — Collect and Share Logs

The diagnostics page also contains a **Collect Intune Diagnostics** section. Select **Get Started** to begin collecting logs from all APP-enabled applications on the device.

> **UI Path**: Intune Diagnostics page → Collect Intune Diagnostics → **Get Started**

Once collection is complete, select **Share Logs** to share the collected data via the iOS share sheet (email, AirDrop, or other share targets).

> **UI Path**: Collect Intune Diagnostics → **Share Logs**

### Clearing Old Logs

Before collecting fresh logs (for example, after reproducing an issue), select the **Clear** icon at the top-right of the diagnostics data view. This removes old log entries so that only new, relevant data is captured.

> **UI Element**: Diagnostics data view → **Clear** icon (top-right)

### Tip — Bookmark the Diagnostics Page

For end-users who frequently need to access the diagnostics console, an Intune [**App Configuration Policy**](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) can be used to pre-configure a bookmark in Microsoft Edge. The configuration key is:

> **Configuration Key**: com.microsoft.intune.mam.managedbrowser.bookmarks

This key accepts a bookmark definition that can include a direct link to the diagnostics page, removing the need for users to remember or type the address.

To configure this:

1. In the Intune admin centre, navigate to **Apps → App configuration policies**
2. Create or edit a configuration policy targeting **Microsoft Edge** on iOS/iPadOS
3. Add the managed bookmarks key with a bookmark entry pointing to **about:intunehelp**
4. Assign the policy to the relevant user or device groups

> **UI Path**: Apps → **App configuration policies** → *create/edit Edge policy* → add **com.microsoft.intune.mam.managedbrowser.bookmarks** key

---

## Key Information for Edge Diagnostics

**Intune SDK version matters.** When reviewing the status of a managed app, pay attention to the [**Intune SDK Version**](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment) reported in the app details. Policy enforcement depends on the SDK version integrated into the app — outdated SDK versions may not support newer policy settings. If a policy isn't behaving as expected, compare the app's SDK version against the current release.

**Policy check-in timestamp** shows when the app last synchronised its App Protection Policy with the Intune service. A stale timestamp may indicate connectivity issues or that the app hasn't been opened recently.

**Save restrictions apply.** The Intune App Protection Policy may [prevent saving diagnostic data](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) to the device's local storage. If the user is unable to save logs locally, use the Share Logs option to send them directly via email or another permitted channel.

---

## What to Expect

**User involvement**: Unlike MDM remote diagnostics, MAM log collection **always requires user interaction**. The user must open the app, consent to collection, and in the Edge workflow, manually share the logs.

**Delivery time**: After triggering collection from the admin centre, the logs are available once the user has interacted with the app and consented. This may take minutes or hours depending on user responsiveness.

**Log content**: MAM diagnostic logs contain detailed App Protection Policy data including:

- All applied APP settings organised by policy section (Access Requirements, Data Protection, Conditional Launch)
- Individual setting values (e.g., PIN length, encryption level, OS version requirements)
- Policy check-in history and timestamps
- App version and Intune SDK version for each managed application
- Policy assignment and targeting information
- Any policy conflicts or override conditions

MAM logs do **not** contain device-level system logs, configuration profiles, or MDM compliance state. They are strictly scoped to app-level policy data.

**Size limits**: The same limits as MDM diagnostics apply — uploads exceeding [**4 MB** or **50 diagnostic files**](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) cannot be downloaded from the Intune portal.

---

## Supported Applications

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

---

*Return to [iOS Diagnostic Logging](../README.md) · Previous: [User-Side Log Collection](user-side-log-collection.md) · Next: [Troubleshooting](../troubleshooting/diagnostic-logging.md)*
