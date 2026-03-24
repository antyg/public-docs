---
title: "Windows Autopilot"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "readme"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Windows Autopilot

## Purpose

Windows Autopilot zero-touch deployment documentation covering architecture, cloud migration strategy, deployment procedures, troubleshooting, and configuration reference. Windows Autopilot zero-touch deployment documentation covering architecture, cloud migration strategy, deployment procedures, troubleshooting, and configuration reference.

## Content

### Explanation

Conceptual documentation for understanding Autopilot architecture and migration strategy:

- [Autopilot Architecture](explanation-architecture.md) — Service overview, architecture and dependencies, service boundaries and handoffs, deployment modes (draft)
- [Cloud Migration Strategy](explanation-cloud-migration.md) — Migration rationale, authentication transition, application compatibility, migration phasing (draft)

### How-To

Task-oriented procedural guides for deploying and troubleshooting Autopilot:

- [Deploy Windows Autopilot](how-to-deploy-autopilot.md) — Prerequisites, device registration, deployment profiles, ESP configuration, app assignment, validation (draft)
- [Troubleshoot Windows Autopilot](how-to-troubleshoot.md) — Diagnostic data collection, common failures, network issues, hybrid join failures, emergency procedures (draft)

### Reference

Factual lookup material for configuration, limitations, and architecture diagrams:

- [Configuration Reference](reference-configuration.md) — Admin portals, PowerShell commands, network requirements, profile settings, error codes (draft)
- [Hybrid Deployment Limitations](reference-limitations.md) — Limitations catalogue (LIM-001 through LIM-014) with workarounds, platform constraints (draft)
- [Cloud Migration Assessment](reference-cloud-migration-assessment.md) — Authentication dependencies (AUTH), application dependencies (APP), modern auth solutions (SOLUTION), assessment checklists (draft)
- [Architecture Diagrams](reference-diagrams.md) — Mermaid diagram library: service integration, deployment flows, service boundaries (draft)

### Scripts and Templates

- [Scripts](scripts/) — 11 PowerShell scripts and configuration templates for hardware hash collection, network testing, firewall rules, bulk operations, and proxy configuration

## Planned Expansion

Future content to be developed:

- Tutorial: End-to-end first device deployment walkthrough
- How-to: Configure Windows Autopilot for pre-provisioned deployment
- How-to: Set up Autopilot with co-management (SCCM + Intune)
- Reference: Deployment profile comparison matrix (detailed)

## Relationship to Other Content

- [endpoints/intune/](../intune/) — Autopilot relies on Intune for delivering configuration profiles, compliance policies, and applications during OOBE
- [endpoints/windows/](../windows/) — Post-provisioning Windows endpoint management
- identity/ — Entra ID device registration and conditional access integration

## Navigation

- Parent: [endpoints/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)
