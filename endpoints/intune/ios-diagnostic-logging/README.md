# iOS/iPadOS Diagnostic Logging

Intune administrators guide for retrieving diagnostic logs from managed and app-protected iOS/iPadOS devices. Covers admin-initiated MDM collection, user-side Company Portal methods, MAM app protection diagnostics, and on-device Microsoft Edge diagnostics.

## When to Use Each Guide

| Scenario | Guide | Device State |
|----------|-------|--------------|
| You need logs from a **fully enrolled** (MDM) device and can act from the admin center | [Admin-Initiated Remote Diagnostics](how-to/admin-initiated-diagnostics.md) | Enrolled, online |
| An **end-user** needs to send logs from their device (e.g., at your request or after an error) | [User-Side Log Collection](how-to/user-side-log-collection.md) | Enrolled or unenrolled |
| You need App Protection Policy logs from a **BYOD/MAM-only** device | [MAM App Protection Diagnostics](how-to/mam-app-protection-diagnostics.md) | MAM-managed (enrolment not required) |
| Something isn't working as expected in any of the above | [Troubleshooting Tips](troubleshooting/diagnostic-logging.md) | Any |

---

## How This Guide Is Organised

This guide follows the [Diátaxis documentation framework](https://diataxis.fr/):

| Folder | Type | Contents |
|--------|------|----------|
| `how-to/` | How-to guides | Step-by-step UI navigation for each diagnostic workflow |
| `reference/` | Reference | Concepts, capabilities matrix, platform limits, data scope |
| `troubleshooting/` | Troubleshooting | Symptom-based resolution for common failures |

---

## Capabilities at a Glance

For a full comparison of what each diagnostic workflow can and cannot do, see [Capabilities Comparison](reference/capabilities.md).

---

## Key Concepts

For definitions of MDM, MAM, Company Portal, and Microsoft Edge as a diagnostic tool, and for background on how each collection mechanism works, see [Concepts and Architecture](reference/concepts.md).

---

## Document Information

| Field | Value |
|-------|-------|
| Platform scope | iOS / iPadOS |
| Last reviewed | February 2026 |
| Source authority | [Microsoft Learn — Intune documentation](https://learn.microsoft.com/en-us/intune/intune-service/remote-actions/collect-diagnostics) |
| Document framework | [Diátaxis](https://diataxis.fr/) |
