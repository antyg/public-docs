---
title: "Microsoft 365 Apps Administration (OCPS)"
status: "draft"
last_updated: "2026-03-09"
audience: "M365 Administrators"
document_type: "readme"
domain: "microsoft-365"
---

# Microsoft 365 Apps Administration (OCPS)

Documentation for the Office Cloud Policy Service (OCPS) — the cloud-based policy engine that delivers user-targeted configuration policies to Microsoft 365 Apps (Word, Excel, PowerPoint, Outlook, etc.) regardless of device enrolment status.

## Admin Surfaces

OCPS is accessible through **two portals** that share the same backend:

| Portal                          | URL                            | Navigation Path                        |
| ------------------------------- | ------------------------------ | -------------------------------------- |
| Microsoft 365 Apps admin centre | <https://config.office.com>    | Customisation > Policy Management      |
| Microsoft Intune admin centre   | <https://intune.microsoft.com> | Apps > Policies for Microsoft 365 Apps |

Policies created in one portal appear in the other. They are the **same service**, not separate policy engines.

## How OCPS Differs from Intune Policies

| Aspect                 | OCPS (This Folder)                                                  | Intune App Protection / Config (endpoints/intune/)          |
| ---------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------- |
| **Target**             | Users (Entra ID groups)                                             | Devices or managed apps                                     |
| **Enrolment required** | No — user signs into any M365 app                                   | Depends on policy type                                      |
| **Enforcement**        | Click-to-Run cloud check-in                                         | Intune SDK / MDM channel                                    |
| **Scope**              | Desktop + mobile + web                                              | Primarily mobile (APP) or enrolled devices (ACP)            |
| **Examples**           | Macro blocking, Protected View, privacy controls, trusted locations | Copy/paste restrictions, PIN requirements, save-as blocking |
| **Precedence**         | Takes precedence over Group Policy and local settings               | Operates independently via MAM/MDM                          |

---

## Published Content

| Topic                                          | Path                                                                                   | Type        | Status       |
| ---------------------------------------------- | -------------------------------------------------------------------------------------- | ----------- | ------------ |
| Portal Overlap, Boundaries, and GPO Precedence | [ocps-portal-overlap-and-gpo-precedence.md](ocps-portal-overlap-and-gpo-precedence.md) | Explanation | ✅ Published |

---

## Cross-References

- **Intune administrators** encountering OCPS in the Intune console: see [Intune — OCPS Cross-Reference](../../endpoints/intune/ocps-cross-reference.md)
- **Intune-native policies** (MAM, App Config, Config Profiles): see [endpoints/intune/](../../endpoints/intune/README.md)

---

## Planned Content

- Creating and managing OCPS policy configurations
- OCPS security baseline recommendations
- Privacy control policies for Microsoft 365 Apps
- Policy conflict resolution and priority ordering
- Platform coverage (Windows, macOS, iOS, Android, web)

---

## Related Resources

- [Overview of Cloud Policy service for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy)
- [Policies for Microsoft 365 Apps — Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-office-policies)
- [Security baseline for Microsoft 365 Apps for enterprise](https://learn.microsoft.com/en-us/microsoft-365-apps/security/security-baseline)
- [Privacy controls for Microsoft 365 Apps](https://learn.microsoft.com/en-us/microsoft-365-apps/privacy/manage-privacy-controls)

---

## Document Information

| Field        | Value                                  |
| ------------ | -------------------------------------- |
| Audience     | IT administrators, M365 service owners |
| Last updated | March 2026                             |
