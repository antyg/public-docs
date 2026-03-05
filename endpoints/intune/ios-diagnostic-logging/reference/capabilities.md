# Capabilities and Sources — iOS/iPadOS Diagnostic Logging

> **Document type**: Reference — capabilities comparison matrix, scenario selection guide, and source index.

## Scenario Selection

| Scenario | Guide | Device State |
|----------|-------|--------------|
| You need logs from a **fully enrolled** (MDM) device and can act from the admin center | [Admin-Initiated Remote Diagnostics](../how-to/admin-initiated-diagnostics.md) | Enrolled, online |
| An **end-user** needs to send logs from their device (e.g., at your request or after an error) | [User-Side Log Collection](../how-to/user-side-log-collection.md) | Enrolled or unenrolled |
| You need App Protection Policy logs from a **BYOD/MAM-only** device | [MAM App Protection Diagnostics](../how-to/mam-app-protection-diagnostics.md) | MAM-managed (enrolment not required) |
| Something isn't working as expected in any of the above | [Troubleshooting Tips](../troubleshooting/diagnostic-logging.md) | Any |

---

## Capabilities Comparison Matrix

| Capability | Admin Remote (MDM) | User-Side (Company Portal) | MAM (Admin-Initiated) | Edge Diagnostics (on-device) |
|---|---|---|---|---|
| **Triggered by** | Admin from admin center | End-user on device | Admin from admin center | End-user on device |
| **Requires device enrolment** | Yes (MDM) | No | No (MAM policy only) | No (APP policy on Edge) |
| **Requires user interaction** | Minimal (close/reopen app) | Yes (full user action) | Yes (close, reopen, consent) | Yes (navigate and share) |
| **Admin can enable debug/verbose logging remotely** | No | No | No | No |
| **Verbose logging available** | No toggle | Yes (user enables in CP settings) | No toggle | No toggle |
| **Logs visible in admin center** | Yes (Diagnostics tab) | Sometimes (depends on method) | Yes (Diagnostics tab) | No (shared directly from device) |
| **Incident ID generated** | No | Yes | No | No |
| **Automatic upload** | Yes (device uploads to blob storage) | Yes (CP uploads to backend) | Yes (after user consent) | No (manual Share Logs) |
| **Timed capture window** | No | No | No | No |
| **Repeat collection (7-day auto-approval)** | N/A | N/A | Yes | N/A |
| **Offline device support** | 24-hour check-in window | No (user must act) | No (user must act) | No (on-device only) |
| **Supported apps** | M365 suite (9 apps) | Company Portal + Authenticator | M365 suite (9 apps) + SDK apps | All APP-managed apps |
| **Data scope** | APP logs only | CP app logs + telemetry | APP settings + policy data | APP status + policy settings + logs |
| **Max file size** | 4 MB / 50 files | No portal limit (incident ID-based) | 4 MB / 50 files | N/A (shared directly) |
| **Retention** | 28 days, 10 per device | Retained by Microsoft backend | 28 days | Not retained (one-time share) |

---

## Official Sources

| Ref | Title | URL | Covers |
|-----|-------|-----|--------|
| CD | Collect Diagnostics Remote Action | [learn.microsoft.com/…/collect-diagnostics](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) | Remote collection trigger, permissions, supported platforms/apps, file limits (4 MB / 50 files), retention (28 days / 10 per device), bulk ops (Windows only), tenant toggle, 7-day MAM auto-approval, Android CP sign-in requirement, blob storage endpoints |
| APP | App Protection Policy Settings Log | [learn.microsoft.com/…/app-protection-policy-settings-log](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-log) | APP setting categories in logs: Access Requirements, Data Protection, Conditional Launch. Individual setting names and values. Edge as iOS collection tool |
| CP-iOS | Report Problems in Company Portal (iOS) | [learn.microsoft.com/…/send-logs-to-microsoft-ios](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) | Send Logs, shake gesture, error alert Report button, shake enablement in iOS Settings, verbose logging toggle, incident ID, Email Logs, sovereign cloud limitation |
| RET | Retrieve iOS App Logs | [learn.microsoft.com/…/retrieve-ios-app-logs](https://learn.microsoft.com/en-us/intune/intune-service/user-help/retrieve-ios-app-logs) | macOS Console fallback: requirements (macOS 10.12+, USB), Info/Debug message types, live log capture |
| EDGE | Manage Microsoft Edge on iOS/Android | [learn.microsoft.com/…/manage-microsoft-edge](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) | about:intunehelp console, app config bookmark key, managed app log access, save restriction behaviour |
| TSAPP | Troubleshoot APP Deployment | [learn.microsoft.com/…/troubleshoot-app-protection-policy-deployment](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment) | SDK version compatibility, policy check-in validation, APP troubleshooting methodology |

---

## Community Resources

| Author | Title | URL | Covers |
|--------|-------|-----|--------|
| P. van der Woude | Intune Diagnostics for APP via about:intunehelp | [petervanderwoude.nl](https://petervanderwoude.nl/post/quick-tip-intune-diagnostics-for-app-protection-policies-via-aboutintunehelp/) | Edge console walkthrough: Shared Device Information section, View Intune App Status, Get Started, Share Logs, Clear icon, APP save restrictions |
| P. van der Woude | Remotely Collecting Diagnostic Logs for M365 Apps | [petervanderwoude.nl](https://petervanderwoude.nl/post/remotely-collecting-diagnostic-logs-for-managed-microsoft-365-apps/) | Admin-side MAM collection: Troubleshooting + support navigation, user consent flow, status monitoring |
| A. C. Nair (HTMD) | Collect Intune Logs from iOS Device Company Portal | [anoopcnair.com](https://www.anoopcnair.com/how-to-collect-intune-logs-from-ios-device/) | CP log collection on iOS with screenshots. Confirmed Send Logs flow and incident ID |
| A. C. Nair (HTMD) | Download Mobile App Diagnostics in Intune Admin Portal | [anoopcnair.com](https://www.anoopcnair.com/download-mobile-app-diagnostics-in-intune/) | Admin download from Troubleshooting + support pane. Diagnostics tab layout |
| Microsoft Tech Community | Support Tip: Troubleshooting APP Using Log Files | [techcommunity.microsoft.com](https://techcommunity.microsoft.com/t5/intune-customer-success/support-tip-troubleshooting-intune-app-protection-policy-using/ba-p/330372) | Edge console for APP troubleshooting. SDK version checks, policy check-in timestamps |

---

## Document Scope

| Decision | Choice |
|----------|--------|
| Platform | iOS/iPadOS only |
| Coverage | Admin-side + user-side + MAM |
| Audience | Mixed experience Intune admins |
| Visual aids | Descriptive UI callout boxes (no screenshots) |
| Prerequisites | Not included |
| Structure | Split files with index |

---

## Related

- [Concepts and Architecture](concepts.md)
- [Platform Limits and Caveats](limits-and-caveats.md)
- [Diagnostic Data Scope](data-scope.md)
