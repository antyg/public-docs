# User-Side Log Collection — iOS/iPadOS

> **Document type**: How-to guide — task-oriented methods for end-user log collection on iOS/iPadOS.

> **Before you start**: For background on how Company Portal log uploads work and what the incident ID is used for, see [Concepts and Architecture](../reference/concepts.md).

---

## Method 1 — Send Logs via the Company Portal App

This is the most common method. The Company Portal app has a built-in [log upload feature](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) accessible from the app's navigation menu.

### Step 1 — Open Company Portal

The user opens the **Company Portal** app on their iOS/iPadOS device.

### Step 2 — Navigate to Send Logs

The user taps the **More** tab at the bottom of the screen, then taps **Send Logs**.

> **UI Path**: Company Portal → **More** tab (bottom bar) → **Send Logs**

### Step 3 — Wait for Upload

Company Portal will package and upload the diagnostic logs automatically. A progress indicator may appear briefly. Once the upload completes, an **incident ID** is displayed.

### Step 4 — Record the Incident ID

The user should save or note the **incident ID** shown on screen. This ID uniquely identifies the log submission and is essential for Microsoft support teams to locate the data if a support ticket is escalated.

### Step 5 — Email Follow-Up (Optional)

After the upload, the user can tap **Email Logs** to compose a follow-up email to IT support. The email will include the incident ID and can be used to add context about what the user was experiencing.

> **UI Path**: After upload → **Email Logs** → compose email with incident ID

---

## Method 2 — Shake Gesture

Company Portal supports a physical [shake gesture](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) to trigger diagnostic log submission. This is useful when an error occurs and the user needs to report it immediately.

### Step 1 — Enable Shake Gesture (One-Time Setup)

If the shake gesture is not already enabled, the user navigates to the iOS **Settings** app, scrolls to or searches for **Company Portal** under the Apps section, and enables the [**Shake Gesture** toggle](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios).

> **UI Path**: iOS Settings → Apps → **Company Portal** → **Shake Gesture** → toggle **On**

### Step 2 — Trigger the Gesture

While the Company Portal app is open and in the foreground, the user physically shakes the device. A prompt will appear asking whether to **Send Diagnostic Report**.

### Step 3 — Confirm and Send

The user taps **Send Diagnostic Report**. The logs are uploaded in the same manner as Method 1, and an incident ID is provided.

---

## Method 3 — Report from an Error Alert

When Company Portal encounters an error and displays an alert dialog, the alert may include a **Report** button.

### Step 1 — Tap Report

When an error alert appears in Company Portal, the user taps **Report** directly on the alert dialog.

### Step 2 — Logs Are Sent Automatically

This triggers the same log upload flow. The incident ID is provided upon completion.

> **UI Element**: Error alert dialog → **Report** button

---

## Method 4 — Collect Logs via Microsoft Authenticator

In some scenarios, Company Portal coordinates with **Microsoft Authenticator** to collect additional logs.

### Step 1 — Initiate from Company Portal

After sending logs via any of the methods above, Company Portal may display an option to **Open Authenticator**.

### Step 2 — Collect Authenticator Logs

Tapping this opens Microsoft Authenticator, which will automatically collect its own diagnostic logs and include them alongside the Company Portal submission.

> **UI Path**: After Company Portal log upload → **Open Authenticator** → logs collected automatically

---

## Enabling Verbose Logging

[Verbose logging](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) increases the detail level captured in diagnostic logs. This is particularly useful when standard logs don't contain enough information to diagnose an issue. **Advise end-users to enable this before reproducing an issue.**

### What Verbose Logging Captures

In standard mode, Company Portal logs high-level events such as app launches, policy check-ins, and errors. When verbose logging is enabled, the log detail expands to include:

- Granular step-by-step traces of every app interaction
- Detailed error context including internal error codes and stack references
- Network request and response metadata during Intune service communication
- Policy evaluation details showing how each App Protection Policy setting was applied
- Authentication flow details during sign-in and token refresh operations

This additional detail is automatically included in any subsequent log upload — no separate action is needed to capture verbose data.

### To Enable

In the Company Portal app, tap **Settings** (accessible from the **More** tab or the gear icon, depending on the Company Portal version). Under the **Troubleshooting** or **Diagnostics** section, locate the **Verbose Logging** toggle and enable it.

> **UI Path**: Company Portal → **More** tab → **Settings** → Troubleshooting → **Verbose Logging** → toggle **On**

Once enabled, the user should keep Company Portal open and proceed to reproduce the issue. All subsequent log uploads will contain the enhanced detail until verbose logging is disabled.

### To Disable

After the troubleshooting session is complete, advise the user to return to the same settings area and disable verbose logging.

> **UI Path**: Company Portal → **More** tab → **Settings** → Troubleshooting → **Verbose Logging** → toggle **Off**

Keeping verbose logging enabled long-term may slightly affect app performance, increase battery consumption, and produce larger log files. It is intended as a temporary troubleshooting measure.

### Important: Verbose Logging Is User-Controlled Only

Verbose logging cannot be enabled remotely by an administrator. There is no Intune admin centre action, device configuration profile, or App Protection Policy setting that toggles verbose logging on a device. The end-user must enable it manually in the Company Portal app settings. This means you will need to communicate with the user (via phone, email, chat, or a support ticket) and guide them through the steps above before they reproduce the issue.

---

## Method 5 — Manual Log Retrieval via macOS Console (Advanced)

If log upload via Company Portal is unavailable (for example, the app crashes on launch), logs can be [retrieved manually using a Mac](https://learn.microsoft.com/en-us/intune/intune-service/user-help/retrieve-ios-app-logs).

### Requirements

- The iOS/iPadOS device
- A Mac running macOS 10.12 (Sierra) or later
- A USB cable to connect the two devices

### Step 1 — Connect the Device

Connect the iOS device to the Mac using a USB cable. If prompted on the iOS device, tap **Trust** to authorise the connection.

### Step 2 — Open Console on Mac

On the Mac, open Spotlight search (press Command and Space together), type **Console**, and open the Console application.

### Step 3 — Select the iOS Device

In the Console sidebar, the connected iOS device will appear under the **Devices** section. Select it to begin viewing live log output.

### Step 4 — Enable All Message Types

In the Console toolbar, ensure that **Include Info Messages** and **Include Debug Messages** are both enabled. Clear any active search filters to ensure no log entries are hidden.

> **UI Path** (macOS Console): Toolbar → **Action** menu → enable **Include Info Messages** and **Include Debug Messages**

### Step 5 — Reproduce the Issue

On the iOS device, open Company Portal and reproduce the problem that needs to be diagnosed. The Console on the Mac will display live log entries as they are generated.

### Step 6 — Copy and Save the Logs

Select all relevant log entries in the Console, copy them, and paste them into a plain text editor (such as TextEdit in plain text mode). Save the file with a descriptive name such as **CompanyPortal-Diagnostics.log** and send it to the IT support team.

---

## The Incident ID

The **incident ID** displayed after each upload is the single most important piece of information from the user-side log collection process. It is:

- **Unique per submission** — each upload generates a distinct ID
- **The primary locator** used by Microsoft support engineers to find the log package in their backend systems
- **Required for support tickets** — without the incident ID, Microsoft support cannot efficiently locate the specific log submission among all uploads
- **Not time-limited** — the incident ID remains valid as long as the logs are retained in Microsoft's systems

Advise end-users to save the incident ID immediately (screenshot, note, or email it to themselves) before navigating away from the confirmation screen.

---

## Where Logs Appear

- **For Intune administrators**: Logs submitted via Company Portal may appear in the **Troubleshooting + support** pane of the Intune admin centre under the relevant user's **Diagnostics** tab. However, availability depends on the log type and submission method — not all Company Portal uploads are surfaced in the admin centre. The admin centre currently provides the most reliable visibility for logs collected via the admin-initiated [remote diagnostics](admin-initiated-diagnostics.md) or [MAM diagnostics](mam-app-protection-diagnostics.md) workflows.
- **For Microsoft support**: If a support ticket is open, provide the incident ID to the Microsoft support engineer, who can locate and analyse the full log package.

### Sovereign Cloud Environments

In [sovereign cloud environments](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) (such as Azure Government or Azure China), the **Send Logs** option within Company Portal may be **unavailable**. In these environments, logs must be sent manually via email instead. Guide the user to use the **Email Logs** option (if available) or to retrieve the logs manually using the [macOS Console method](#method-5--manual-log-retrieval-via-macos-console-advanced) and email them to IT support.

---

## Quick Reference — All Methods at a Glance

| Method | Trigger | Best For |
|--------|---------|----------|
| **Send Logs** (More tab) | Manual, user-initiated | Routine log submission on request |
| **Shake Gesture** | Physical device shake | Immediate reporting during an error |
| **Error Alert Report** | Tap Report on alert | Responding to a specific error |
| **Authenticator Handoff** | Automatic after CP upload | Collecting auth-related logs alongside |
| **macOS Console** | USB + Mac Console app | App crashes or Company Portal won't launch |

---

## Recommended: Guided Troubleshooting Session Workflow

When you need detailed diagnostic logs from an end-user to investigate a specific issue, the most effective approach is to coordinate a structured troubleshooting session. This combines verbose logging with a targeted log collection to capture maximum diagnostic detail.

### Step 1 — Contact the User

Reach out to the end-user (via phone, chat, or email) and explain that you need them to perform a series of steps on their device. Keep communication open during the session if possible.

### Step 2 — Enable Verbose Logging

Guide the user through enabling verbose logging in Company Portal as described in the [Enabling Verbose Logging](#enabling-verbose-logging) section above.

### Step 3 — Reproduce the Issue

Ask the user to perform the exact actions that trigger the problem. If the issue is intermittent, have them use the app normally for a defined period (for example, 10–15 minutes) to increase the likelihood of capturing the issue in the logs.

### Step 4 — Collect Logs Immediately After Reproduction

As soon as the issue occurs (or the testing period ends), have the user send logs using **Method 1** (More tab → Send Logs) or **Method 2** (shake gesture). The timing matters — collecting logs immediately after the issue ensures the verbose log entries are fresh and haven't been rotated out by newer entries.

### Step 5 — Record the Incident ID

Have the user read back or screenshot the **incident ID** and send it to you.

### Step 6 — Disable Verbose Logging

Guide the user through disabling verbose logging to restore normal app performance.

### Step 7 — Retrieve Logs from Admin Centre or Support Ticket

Use the incident ID in a Microsoft support ticket, or check the **Troubleshooting + support** pane in the admin centre for the user's diagnostic submissions.

> This coordinated workflow produces the highest-quality diagnostic data available from an iOS/iPadOS device in Intune. The key is ensuring verbose logging is active **before** the issue is reproduced, and that logs are uploaded **immediately after**.

---

*Return to [iOS Diagnostic Logging](../README.md) · Previous: [Admin-Initiated Diagnostics](admin-initiated-diagnostics.md) · Next: [MAM App Protection Diagnostics](mam-app-protection-diagnostics.md)*
