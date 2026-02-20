# Platform Limits and Caveats — iOS/iPadOS Diagnostic Logging

> **Document type**: Reference — platform-enforced limits and known behavioural caveats for Intune diagnostic logging on iOS/iPadOS.

## Platform Limits

| Limit | Value | Source |
|-------|-------|--------|
| Max diagnostic package size (portal download) | 4 MB | CD |
| Max diagnostic files per package | 50 | CD |
| Diagnostic retention | 28 days | CD |
| Max stored collections per device | 10 | CD |
| Bulk collection max devices | 25 (Windows only) | CD |
| MAM auto-approval window | 7 days after initial consent | CD |
| Offline device check-in window | 24 hours | CD |

---

## Known Caveats

| Caveat | Detail | Source |
|--------|--------|--------|
| Push notification unreliable | Collect Diagnostics push may not fire. Device collects on next routine sync. Workaround: manual sync via CP | CD |
| No remote verbose toggle | Verbose logging is user-controlled only. No admin-side policy, profile, or remote action can enable it | CP-iOS |
| No timed capture window | No mechanism to remotely enable debug logging for a defined duration with automatic upload upon expiry | — |
| CP logs not always admin-visible | Send Logs uploads route to Microsoft backend. Not reliably surfaced in admin center Troubleshooting pane | CP-iOS |
| Sovereign cloud: Send Logs unavailable | In-app Send Logs may be missing. Must use Email Logs or manual retrieval | CP-iOS |
| Edge console requires managed Edge | about:intunehelp only works when Edge has an assigned APP. Unmanaged Edge shows empty/broken page | EDGE |
| APP save restrictions apply to diagnostics | Users may not be able to save diagnostic data locally from Edge console | EDGE |
| MAM requires active user consent | User must close app, reopen, and consent. No silent collection | CD |
| APNs dependency | Initial push notification uses APNs. Blocked APNs = delayed collection | CD |
| Log file naming | CP generates **Company Portal-Log.log** in upload package | CP-iOS |

---

## Source Reference Codes

| Code | Title | URL |
|------|-------|-----|
| CD | [Collect Diagnostics Remote Action](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) | https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics |
| APP | [App Protection Policy Settings Log](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-log) | https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-log |
| CP-iOS | [Report Problems in Company Portal (iOS)](https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios) | https://learn.microsoft.com/en-us/intune/intune-service/user-help/send-logs-to-microsoft-ios |
| RET | [Retrieve iOS App Logs](https://learn.microsoft.com/en-us/intune/intune-service/user-help/retrieve-ios-app-logs) | https://learn.microsoft.com/en-us/intune/intune-service/user-help/retrieve-ios-app-logs |
| EDGE | [Manage Microsoft Edge on iOS/Android](https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge) | https://learn.microsoft.com/en-us/intune/intune-service/apps/manage-microsoft-edge |
| TSAPP | [Troubleshoot APP Deployment](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment) | https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-app-protection-policy-deployment |

---

## Related
- [Concepts and Architecture](concepts.md)
- [Capabilities Comparison](capabilities.md)
- [Diagnostic Data Scope](data-scope.md)
