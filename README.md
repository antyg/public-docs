---
title: "Public Documentation Library"
status: "published"
last_updated: "2026-03-09"
audience: "Infrastructure Engineers"
document_type: "readme"
---

# Public Documentation Library

A structured, domain-based technical documentation library covering Microsoft 365 security, Azure infrastructure, endpoint management, identity, and development standards — with particular emphasis on Australian regulatory compliance (ISM, Essential Eight) and enterprise deployment best practices.

## Domain Structure

This library is organised into **10 top-level domains**, each covering a distinct area of technical documentation. Domains contain product-specific subfolders with guides, scripts, templates, and configuration references.

| Domain                                 | Purpose                                       | Key Content                                                                                                                                              |
| -------------------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **[security/](security/)**             | Security frameworks and product documentation | Defender for Cloud (19 guides + scripts), Defender for Endpoint (validation toolkit), Essential Eight, NIST, Zero Trust                                  |
| **[identity/](identity/)**             | Identity and access management                | Password policy research, Entra ID (planned), Okta, Ping                                                                                                 |
| **[networking/](networking/)**         | Network infrastructure                        | Azure Firewall + ExpressRoute routing                                                                                                                    |
| **[endpoints/](endpoints/)**           | Endpoint and VM management                    | iOS device capture toolkit (ZCC VPN), Intune iOS diagnostic logging, Autopilot, platform coverage (iOS/Android/ChromeOS/macOS/Windows), virtual machines |
| **[microsoft-365/](microsoft-365/)**   | Tenant-level M365 service administration      | OCPS (M365 Apps policy), admin centre, Exchange Online, SharePoint Online, Teams, OneDrive admin portals                                                 |
| **[infrastructure/](infrastructure/)** | Core infrastructure                           | PKI modernisation (13 guides + 68 scripts)                                                                                                               |
| **[development/](development/)**       | Coding standards and tooling                  | PSEval PowerShell standards (147 standards, 10 documents)                                                                                                |
| **[integrations/](integrations/)**     | API specifications and SDKs                   | Microsoft Graph API                                                                                                                                      |
| **[compliance/](compliance/)**         | Alignment bridge — framework × product        | How to align tech stacks with E8, ISM, NIST                                                                                                              |
| **[projects/](projects/)**             | Bounded initiatives and assessments           | Modernisation assessment template                                                                                                                        |

## Design Principles

### Three-Way Model

The library separates three concerns that are often conflated:

1. **Frameworks** (`security/frameworks/`) — What to comply with (E8 controls, NIST requirements)
2. **Products** (domain subfolders) — How the technology works (configuration, deployment, operations)
3. **Compliance** (`compliance/`) — How to make the technology comply (alignment guidance for specific framework × product combinations)

### Domain Boundary: endpoints/ vs. microsoft-365/

The `endpoints/` and `microsoft-365/` domains share adjacent subject matter but serve distinct concerns:

- **`endpoints/`** — Manages **devices** and what runs on them. Intune device compliance, app protection (MAM), app configuration, configuration profiles, Autopilot provisioning.
- **`microsoft-365/`** — Manages **tenant services** and user-targeted cloud policy. M365 admin centre, OCPS (Policies for M365 Apps), Exchange Online, SharePoint Online, Teams, OneDrive admin portals.

**Decision rule**: If the policy targets a **user** and is enforced via a **cloud service** regardless of device enrolment status → `microsoft-365/`. If it targets a **device** or requires **enrolment/SDK integration** → `endpoints/`.

### Organisation Conventions

- **Naming**: Lowercase folders, hyphens for multi-word names only (`defender-for-cloud/`, `azure-firewall/`)
- **Scripts**: Co-located with their documentation (each topic keeps its own `scripts/`, `templates/`, `config/`)
- **READMEs**: Every folder has a README.md describing its purpose, content, and relationships
- **Sequential guides**: Numbered `00-index.md` through `NN-topic.md` for learning-path content

## Coverage Status

| Status         | Count      | Description                                                      |
| -------------- | ---------- | ---------------------------------------------------------------- |
| ✅ Substantive | 10 topics  | Has real content with guides, scripts, or detailed documentation |
| 🌱 Seeded      | 6 topics   | Placeholder structure with README — content planned              |
| 📋 Planned     | 20+ topics | Future additions identified in domain READMEs                    |

## Documentation Standards

This library follows three quality frameworks:

- **[Diátaxis](https://diataxis.fr/)** — Four-category documentation structure (tutorials, how-to guides, reference, explanation)
- **[ALCOA-C](https://www.fda.gov/media/119267/download)** — Data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate, Complete, Consistent)
- **[Docs-as-Code](https://www.writethedocs.org/guide/docs-as-code/)** — Version control, plain text, automation

## Getting Started

| I want to...                                   | Start here                                                                           |
| ---------------------------------------------- | ------------------------------------------------------------------------------------ |
| Capture ZCC VPN diagnostics from an iOS device | [endpoints/iOS/device-capture-toolkit/](endpoints/iOS/device-capture-toolkit/)       |
| Collect iOS diagnostic logs via Intune         | [endpoints/intune/ios-diagnostic-logging/](endpoints/intune/ios-diagnostic-logging/) |
| Deploy Windows Autopilot                       | [endpoints/autopilot/](endpoints/autopilot/)                                         |
| Implement Defender for Cloud                   | [security/defender-for-cloud/](security/defender-for-cloud/)                         |
| Validate Defender for Endpoint                 | [security/defender-for-endpoint/](security/defender-for-endpoint/)                   |
| Modernise PKI infrastructure                   | [infrastructure/pki/](infrastructure/pki/)                                           |
| Evaluate PowerShell code quality               | [development/powershell/](development/powershell/)                                   |
| Assess modernisation readiness                 | [projects/modernisation-assessment/](projects/modernisation-assessment/)             |
| Understand Graph API integration               | [integrations/graph-api/](integrations/graph-api/)                                   |
| Understand M365 Apps cloud policy (OCPS)       | [microsoft-365/apps-admin/](microsoft-365/apps-admin/)                               |
| Navigate M365 admin portals                    | [microsoft-365/](microsoft-365/)                                                     |

## Migration Notice

> **This library is being reorganised.** The new domain-based structure (folders listed above) coexists with the legacy structure while content migration is underway. Legacy folders (`Autopilot/`, `Coding/`, `Defender/`, `other-infra/`, etc.) will be removed once migration is complete. Navigate using the new domain folders for the intended structure.

## Contributing

Please follow the documentation standards (Diátaxis, ALCOA-C, Docs-as-Code) and maintain consistent structure within each domain. Every folder should have a README.md, and scripts should be co-located with their documentation.

---

**Repository**: public-docs
**Remote**: github.com/antyg/public-docs
**Visibility**: Public
**Last Updated**: February 2026
