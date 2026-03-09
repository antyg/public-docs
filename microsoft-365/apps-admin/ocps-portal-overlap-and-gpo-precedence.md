---
title: "OCPS — Portal Overlap, Boundaries, and GPO Precedence"
status: "published"
last_updated: "2026-03-09"
audience: "M365 Administrators"
document_type: "explanation"
domain: "microsoft-365"
---

# OCPS — Portal Overlap, Boundaries, and GPO Precedence

## Scope

This document explains how the Office Cloud Policy Service (OCPS) relates to traditional Group Policy Object (GPO) configuration for Microsoft 365 Apps, why the same policies appear in multiple admin portals, and how OCPS precedence over GPO affects operational management.

**Covers**: OCPS architecture, dual-portal behaviour, GPO precedence rules, conflict scenarios, and migration considerations.

**Excludes**: Intune App Protection Policies (MAM), Intune App Configuration Policies, device-level configuration profiles, Conditional Access. For those topics, see [endpoints/intune/](../../endpoints/intune/README.md).

---

## What Is OCPS?

The Office Cloud Policy Service is a **cloud-native policy engine** that delivers configuration settings to Microsoft 365 Apps (Word, Excel, PowerPoint, Outlook, etc.) based on the **signed-in user**, not the device. When a user signs into a Microsoft 365 App on any device — domain-joined, Intune-enrolled, personal, or unmanaged — the Click-to-Run service checks in with OCPS and applies the relevant policies.

OCPS manages the same category of settings traditionally controlled by Office ADMX Group Policy templates: macro behaviour, Protected View, trusted locations, privacy controls, and security baselines.

### Key Characteristics

| Characteristic     | Detail                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------- |
| Target             | Users (via Entra ID security groups)                                                        |
| Delivery mechanism | Click-to-Run cloud check-in (90-minute interval for group members, 24-hour for non-members) |
| Enrolment required | No — device does not need to be enrolled in Intune or domain-joined                         |
| Platform coverage  | Windows, macOS, iOS, Android, Office for the web                                            |
| Licensing          | Requires Microsoft 365 Apps for business or enterprise                                      |
| Precedence         | Takes precedence over GPO, local policy, and preference settings                            |

Source: [Overview of Cloud Policy service for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy)

---

## The Dual-Portal Surface

OCPS is accessible through **two separate admin portals** that share the **same backend service**:

| Portal                          | URL                          | Navigation                             |
| ------------------------------- | ---------------------------- | -------------------------------------- |
| Microsoft 365 Apps admin centre | https://config.office.com    | Customisation > Policy Management      |
| Microsoft Intune admin centre   | https://intune.microsoft.com | Apps > Policies for Microsoft 365 Apps |

### Same Service, Two Doors

- A policy created in config.office.com **immediately appears** in Intune admin centre under Apps > Policies for Microsoft 365 Apps, and vice versa.
- There is no synchronisation delay — both portals read from and write to the same OCPS backend.
- Priority ordering, group targeting, and policy settings are identical regardless of which portal is used.

Microsoft's documentation confirms this directly:

> _"Commercial and US Government customers can access the Microsoft 365 Apps admin centre at https://config.office.com or directly in the Microsoft Intune admin centre, under Apps > Policy > Policies for Office apps."_

Source: [Overview of Cloud Policy service for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy#steps-for-creating-a-policy-configuration)

### Why This Matters

Administrators who manage Intune may discover OCPS policies in their console and assume they are Intune-native. They are not. Understanding that "Policies for Microsoft 365 Apps" in Intune is a **pass-through to OCPS** — not an Intune feature — is critical for:

- Correct team ownership assignment
- Avoiding accidental policy creation by teams who do not own the service
- Consistent audit and change management across portals

---

## OCPS Is Not Intune

Despite sharing a console, OCPS and Intune policies are fundamentally different systems:

| Aspect             | OCPS                                                                      | Intune App Protection (MAM)                            | Intune App Configuration        | Intune Config Profiles       |
| ------------------ | ------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------- | ---------------------------- |
| Target             | Users                                                                     | Apps on mobile devices                                 | Managed devices or managed apps | Enrolled devices             |
| Enforcement        | Click-to-Run cloud check-in                                               | Intune SDK / MAM channel                               | MDM OS channel or MAM channel   | MDM enrolment                |
| Enrolment required | No                                                                        | No                                                     | Depends                         | Yes                          |
| Platform           | Windows, macOS, iOS, Android, web                                         | iOS, Android                                           | iOS, Android, Windows           | iOS, Android, Windows, macOS |
| Settings type      | Office app behaviour (macros, Protected View, trusted locations, privacy) | Data protection (copy/paste, save-as, PIN, encryption) | App-specific key/value pairs    | OS and device settings       |
| Backend service    | Office Cloud Policy Service                                               | Microsoft Intune                                       | Microsoft Intune                | Microsoft Intune             |

For Intune-specific policy documentation, see: [Intune — Policies for Microsoft 365 Apps (Cross-Reference)](../../endpoints/intune/ocps-cross-reference.md)

---

## GPO Precedence — OCPS Wins

This is the most operationally significant behaviour to understand.

### Precedence Order (Highest to Lowest)

| Priority        | Source                    | Applies To                 |
| --------------- | ------------------------- | -------------------------- |
| **1 (Highest)** | OCPS cloud policy         | Signed-in user, any device |
| 2               | GPO (domain Group Policy) | Domain-joined devices      |
| 3               | Local Group Policy        | Local machine              |
| 4               | Preference settings       | User/app defaults          |

When the same policy setting (e.g., "Block macros from running in Office files from the Internet") is configured in **both** OCPS and GPO:

- **OCPS wins** — the GPO setting is overridden silently
- There is **no merge** — OCPS does not combine with GPO; it replaces
- There is **no notification** to the admin — the GPO setting still appears configured in Group Policy Management Console, but the effective policy on the endpoint is the OCPS value

Source: [Overview of Cloud Policy service for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy#how-the-policy-configuration-is-applied)

### Conflict Scenarios

| Scenario                                                               | Outcome                                                                 |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| OCPS sets "Block macros = Enabled", GPO sets "Block macros = Disabled" | Macros are **blocked** (OCPS wins)                                      |
| OCPS has no policy for a setting, GPO configures it                    | **GPO applies** (OCPS only overrides settings it explicitly configures) |
| OCPS configures a setting, no GPO exists                               | **OCPS applies**                                                        |
| Multiple OCPS policies target the same user (via different groups)     | **Priority value** determines winner (0 = highest, set in OCPS admin)   |

### Implications for GPO Migration

Organisations adopting OCPS SHOULD plan a deliberate GPO retirement strategy:

1. **Audit** existing Office ADMX GPO settings currently in production
2. **Map** each GPO setting to its OCPS equivalent (available settings are identical — OCPS uses the same policy definitions)
3. **Implement** the settings in OCPS, targeting the appropriate Entra ID groups
4. **Validate** that OCPS is delivering the expected effective policy on endpoints
5. **Retire** the corresponding GPO settings to avoid shadow policy (GPO appears active but has no effect)

Failing to retire GPOs creates a **governance risk**: the GPO Management Console shows settings as "configured" while the effective policy is entirely determined by OCPS. Future auditors or administrators reviewing GPO will see a policy state that does not reflect reality.

---

## Policy Delivery Mechanism

Understanding how OCPS delivers policies helps explain its behaviour:

1. User opens a Microsoft 365 App (e.g., Word) and signs in
2. The Click-to-Run service contacts OCPS to check for policies
3. OCPS evaluates the user's Entra ID group memberships
4. If the user is a member of a group targeted by an OCPS policy configuration, the policies are returned
5. Policies take effect **on the next app restart** (same behaviour as GPO)
6. Check-in interval: **90 minutes** for users with policies, **24 hours** for users without

Policies are enforced based on the **primary signed-in user**. If multiple accounts are signed in, only the primary account's policies apply. Switching the primary account requires an app restart for new policies to take effect.

Source: [How the policy configuration is applied](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy#how-the-policy-configuration-is-applied)

---

## Security Baseline

OCPS includes a curated set of policies tagged as a **security baseline**. These can be filtered in the policy configuration UI using the "Recommendation" column. The security baseline covers policies Microsoft considers essential for protecting Microsoft 365 Apps in enterprise environments.

Source: [Security baseline for Microsoft 365 Apps for enterprise](https://learn.microsoft.com/en-us/microsoft-365-apps/security/security-baseline)

---

## Related Resources

- [Overview of Cloud Policy service for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy)
- [Policies for Microsoft 365 Apps — Intune documentation](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-office-policies)
- [Security baseline for Microsoft 365 Apps for enterprise](https://learn.microsoft.com/en-us/microsoft-365-apps/security/security-baseline)
- [Privacy controls for Microsoft 365 Apps](https://learn.microsoft.com/en-us/microsoft-365-apps/privacy/manage-privacy-controls)
- [Intune — OCPS Cross-Reference](../../endpoints/intune/ocps-cross-reference.md) — stub document directing Intune administrators to this explanation

---

## Document Information

| Field        | Value                                              |
| ------------ | -------------------------------------------------- |
| Audience     | IT administrators, SOE teams, ICM teams, MDO teams |
| Last updated | March 2026                                         |
