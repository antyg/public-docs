---
title: "Policies for Microsoft 365 Apps — OCPS Cross-Reference"
status: "published"
last_updated: "2026-03-01"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Microsoft Intune"
---

# Policies for Microsoft 365 Apps — OCPS Cross-Reference

## Scope

This is a **cross-reference stub**. The Intune admin centre surfaces "Policies for Microsoft 365 Apps" under Apps > Policies for Microsoft 365 Apps. Despite appearing in the Intune console, this feature is **not an Intune-native policy type** — it is a pass-through to the Office Cloud Policy Service (OCPS).

**This stub exists to redirect Intune administrators to the authoritative OCPS documentation.**

---

## Key Facts

- The policies visible at **Apps > Policies for Microsoft 365 Apps** in Intune are the **same** policies available at https://config.office.com
- They are managed by the **Office Cloud Policy Service (OCPS)**, not Intune
- OCPS targets **users** (via Entra ID groups), not devices — it does not require Intune enrolment
- OCPS policies **take precedence over Group Policy** for the same settings
- Creating a policy in Intune's UI creates it in OCPS — it will immediately appear in config.office.com, and vice versa

---

## Authoritative Documentation

For full documentation on OCPS behaviour, portal overlap, GPO precedence, and policy delivery, see:

**[OCPS — Portal Overlap, Boundaries, and GPO Precedence](../../microsoft-365/apps-admin/ocps-portal-overlap-and-gpo-precedence.md)**

This document is the canonical reference for OCPS in the documentation library. It is located in the `microsoft-365/apps-admin/` domain because OCPS is a tenant-level cloud service, not an endpoint management feature.

---

## What Intune Actually Manages (Not OCPS)

The following Intune policy types are **genuinely Intune-native** and are documented in this `endpoints/intune/` section:

| Policy Type                   | Target                          | Use Case                                               |
| ----------------------------- | ------------------------------- | ------------------------------------------------------ |
| App Protection Policies (MAM) | Apps on mobile devices          | Data protection — copy/paste, save-as, PIN, encryption |
| App Configuration Policies    | Managed devices or managed apps | App-specific key/value configuration                   |
| Configuration Profiles        | Enrolled devices                | OS and device settings                                 |
| Compliance Policies           | Enrolled devices                | Device compliance evaluation for Conditional Access    |

---

## Document Information

| Field            | Value                                                                                                                 |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| Audience         | Intune administrators                                                                                                 |
| Last updated     | March 2026                                                                                                            |
| Canonical source | [ocps-portal-overlap-and-gpo-precedence.md](../../microsoft-365/apps-admin/ocps-portal-overlap-and-gpo-precedence.md) |
