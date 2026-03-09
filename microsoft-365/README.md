---
title: "Microsoft 365"
status: "draft"
last_updated: "2026-03-09"
audience: "M365 Administrators"
document_type: "readme"
domain: "microsoft-365"
---

# Microsoft 365

## Overview

The **Microsoft 365** domain covers tenant-level service administration, cloud policy management, and workload configuration for Microsoft 365. This domain documents the admin portals, cloud services, and policy frameworks that operate at the **tenant and user level** — independent of whether devices are enrolled in endpoint management.

## Purpose

Microsoft 365 is administered through multiple specialised portals, each governing a distinct workload. Administrators frequently encounter the same settings surfaced in more than one portal (e.g., Office Cloud Policy Service appearing in both config.office.com and the Intune admin centre). This domain provides the documentation needed to understand each admin surface, its scope, and its relationship to other portals — eliminating confusion about where settings are authored and how they are enforced.

## Scope

### In Scope

- **Tenant administration** — Microsoft 365 admin centre (admin.microsoft.com): licensing, domains, organisational settings, service health, user management
- **Microsoft 365 Apps policy** — Office Cloud Policy Service (OCPS) via config.office.com and the Intune admin centre: user-targeted policy for Microsoft 365 Apps (Word, Excel, PowerPoint, Outlook, etc.)
- **Exchange Online administration** — Exchange admin centre: mail flow, transport rules, mailbox policies, accepted domains, connectors
- **SharePoint Online administration** — SharePoint admin centre: site management, sharing policies, storage, access control
- **OneDrive administration** — OneDrive admin centre: sync settings, sharing, storage, device access (note: MAM Global policy settings are deprecated here — see Boundary Rules)
- **Teams administration** — Teams admin centre: messaging policies, meeting policies, calling, app management, guest access

### Out of Scope — Boundary Rules

The following topics belong in **other domains** and MUST NOT be documented here:

| Topic                                | Belongs In             | Rationale                                                               |
| ------------------------------------ | ---------------------- | ----------------------------------------------------------------------- |
| Intune device compliance policies    | `endpoints/intune/`    | Targets devices, not tenant services                                    |
| Intune app protection policies (MAM) | `endpoints/intune/`    | Mobile Application Management is a device-level data protection control |
| Intune app configuration policies    | `endpoints/intune/`    | Delivered via MDM or MAM channel to managed devices/apps                |
| Intune configuration profiles        | `endpoints/intune/`    | Device configuration, not tenant policy                                 |
| Windows Autopilot                    | `endpoints/autopilot/` | Device provisioning workflow                                            |
| Conditional Access policies          | `identity/`            | Identity and access control, enforced at authentication                 |
| Entra ID configuration               | `identity/`            | Identity platform administration                                        |
| Defender for Endpoint / Cloud        | `security/`            | Security product configuration                                          |
| Microsoft Sentinel                   | `security/`            | SIEM and threat detection                                               |
| Azure Firewall, ExpressRoute         | `networking/`          | Network infrastructure                                                  |
| Microsoft Graph API                  | `integrations/`        | Programmatic access layer                                               |
| Framework-to-product alignment       | `compliance/`          | Compliance mapping (E8 × product, ISM × product)                        |

### Key Boundary: OCPS vs. Intune App Policies

This is the most common source of confusion and MUST be clearly understood:

| Policy Type                                         | Admin Surface                                                   | Target                          | Enforcement                                   | Domain                          |
| --------------------------------------------------- | --------------------------------------------------------------- | ------------------------------- | --------------------------------------------- | ------------------------------- |
| **OCPS policies** (Policies for Microsoft 365 Apps) | config.office.com **or** Intune > Apps > Policies for M365 Apps | Users (via Entra ID groups)     | Click-to-Run cloud check-in — device-agnostic | **`microsoft-365/apps-admin/`** |
| **App Protection Policies** (MAM)                   | Intune > Apps > App protection policies                         | Apps on mobile devices          | Intune SDK / MAM channel                      | **`endpoints/intune/`**         |
| **App Configuration Policies**                      | Intune > Apps > App configuration policies                      | Managed devices or managed apps | MDM OS channel or MAM channel                 | **`endpoints/intune/`**         |
| **Configuration Profiles**                          | Intune > Devices > Configuration                                | Enrolled devices                | MDM enrolment                                 | **`endpoints/intune/`**         |

**Decision rule**: If the policy targets a **user** and is enforced via a **cloud service** regardless of device enrolment status, it belongs here. If it targets a **device** or requires **enrolment/SDK integration**, it belongs in `endpoints/`.

## Domain Structure

| Folder                                     | Covers                                                                   | Admin Portal                                               | Status     |
| ------------------------------------------ | ------------------------------------------------------------------------ | ---------------------------------------------------------- | ---------- |
| [`admin-centre/`](admin-centre/)           | Tenant administration — licensing, domains, org settings, service health | admin.microsoft.com                                        | 📋 Planned |
| [`apps-admin/`](apps-admin/)               | Microsoft 365 Apps policy (OCPS), security baselines, privacy controls   | config.office.com / Intune > Apps > Policies for M365 Apps | 📋 Planned |
| [`exchange-online/`](exchange-online/)     | Mail flow, transport rules, mailbox policies, connectors                 | Exchange admin centre                                      | 📋 Planned |
| [`sharepoint-online/`](sharepoint-online/) | Site management, sharing policies, storage, access control               | SharePoint admin centre                                    | 📋 Planned |
| [`teams-admin/`](teams-admin/)             | Messaging, meetings, calling, apps, guest access                         | Teams admin centre                                         | 📋 Planned |
| [`onedrive-admin/`](onedrive-admin/)       | Sync settings, sharing, storage quotas                                   | OneDrive admin centre                                      | 📋 Planned |

## Relationship to Other Domains

| Domain            | Relationship                                                                                                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **endpoints/**    | Intune embeds the OCPS UI at Apps > Policies for M365 Apps — this is a pass-through to the same OCPS backend documented here. Cross-references SHOULD link between domains.                                                          |
| **identity/**     | Conditional Access evaluates device compliance and app protection status set by Intune, and OCPS policies target users via Entra ID groups. Identity is the glue but is documented separately.                                       |
| **security/**     | Microsoft 365 service settings (e.g., Exchange transport rules, SharePoint sharing) have security implications. Security baseline recommendations for OCPS are documented here; Defender product configuration stays in `security/`. |
| **compliance/**   | Alignment guides mapping M365 service configurations to frameworks (E8, ISM) belong in `compliance/`, not here. This domain documents **what the settings do**; compliance documents **which settings satisfy which controls**.      |
| **integrations/** | Graph API provides programmatic access to M365 services. API documentation goes in `integrations/`; this domain covers the admin portal experience and policy behaviour.                                                             |

## Target Audience

- Microsoft 365 tenant administrators
- IT managers responsible for service configuration
- Security teams reviewing tenant-level policy settings
- Compliance officers assessing M365 service controls

## Technologies Covered

- Microsoft 365 admin centre (admin.microsoft.com)
- Microsoft 365 Apps admin centre / Office Cloud Policy Service (config.office.com)
- Exchange Online admin centre
- SharePoint Online admin centre
- OneDrive admin centre
- Microsoft Teams admin centre

---

**Last Updated**: March 2026
**Maintainer**: antyg
**Status**: Seeded — domain scaffold with planned content structure
