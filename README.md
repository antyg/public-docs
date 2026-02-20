# Public Documentation Library

A structured, domain-based technical documentation library covering Microsoft 365 security, Azure infrastructure, endpoint management, identity, and development standards — with particular emphasis on Australian regulatory compliance (ISM, Essential Eight) and enterprise deployment best practices.

## Domain Structure

This library is organised into **9 top-level domains**, each covering a distinct area of technical documentation. Domains contain product-specific subfolders with guides, scripts, templates, and configuration references.

| Domain | Purpose | Key Content |
|--------|---------|-------------|
| **[security/](security/)** | Security frameworks and product documentation | Defender for Cloud (19 guides + scripts), Defender for Endpoint (validation toolkit), Essential Eight, NIST, Zero Trust |
| **[identity/](identity/)** | Identity and access management | Password policy research, Entra ID (planned), Okta, Ping |
| **[networking/](networking/)** | Network infrastructure | Azure Firewall + ExpressRoute routing |
| **[endpoints/](endpoints/)** | Endpoint and VM management | Windows Autopilot (330KB complete suite), Intune/MEM |
| **[infrastructure/](infrastructure/)** | Core infrastructure | PKI modernisation (13 guides + 68 scripts) |
| **[development/](development/)** | Coding standards and tooling | PSEval PowerShell standards (147 standards, 10 documents) |
| **[integrations/](integrations/)** | API specifications and SDKs | Microsoft Graph API |
| **[compliance/](compliance/)** | Alignment bridge — framework × product | How to align tech stacks with E8, ISM, NIST |
| **[projects/](projects/)** | Bounded initiatives and assessments | Modernisation assessment template |

## Design Principles

### Three-Way Model

The library separates three concerns that are often conflated:

1. **Frameworks** (`security/frameworks/`) — What to comply with (E8 controls, NIST requirements)
2. **Products** (domain subfolders) — How the technology works (configuration, deployment, operations)
3. **Compliance** (`compliance/`) — How to make the technology comply (alignment guidance for specific framework × product combinations)

### Organisation Conventions

- **Naming**: Lowercase folders, hyphens for multi-word names only (`defender-for-cloud/`, `azure-firewall/`)
- **Scripts**: Co-located with their documentation (each topic keeps its own `scripts/`, `templates/`, `config/`)
- **READMEs**: Every folder has a README.md describing its purpose, content, and relationships
- **Sequential guides**: Numbered `00-index.md` through `NN-topic.md` for learning-path content

## Coverage Status

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Substantive | 8 topics | Has real content with guides, scripts, or detailed documentation |
| 🌱 Seeded | 5 topics | Placeholder structure with README — content planned |
| 📋 Planned | 20+ topics | Future additions identified in domain READMEs |

## Documentation Standards

This library follows three quality frameworks:

- **[Diátaxis](https://diataxis.fr/)** — Four-category documentation structure (tutorials, how-to guides, reference, explanation)
- **[ALCOA-C](https://www.fda.gov/media/119267/download)** — Data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate, Complete, Consistent)
- **[Docs-as-Code](https://www.writethedocs.org/guide/docs-as-code/)** — Version control, plain text, automation

## Getting Started

| I want to... | Start here |
|--------------|-----------|
| Deploy Windows Autopilot | [endpoints/autopilot/](endpoints/autopilot/) |
| Implement Defender for Cloud | [security/defender-for-cloud/](security/defender-for-cloud/) |
| Validate Defender for Endpoint | [security/defender-for-endpoint/](security/defender-for-endpoint/) |
| Modernise PKI infrastructure | [infrastructure/pki/](infrastructure/pki/) |
| Evaluate PowerShell code quality | [development/powershell/](development/powershell/) |
| Assess modernisation readiness | [projects/modernisation-assessment/](projects/modernisation-assessment/) |
| Understand Graph API integration | [integrations/graph-api/](integrations/graph-api/) |

## Migration Notice

> **This library is being reorganised.** The new domain-based structure (folders listed above) coexists with the legacy structure while content migration is underway. Legacy folders (`Autopilot/`, `Coding/`, `Defender/`, `other-infra/`, etc.) will be removed once migration is complete. Navigate using the new domain folders for the intended structure.

## Contributing

Please follow the documentation standards (Diátaxis, ALCOA-C, Docs-as-Code) and maintain consistent structure within each domain. Every folder should have a README.md, and scripts should be co-located with their documentation.

---

**Repository**: public-docs
**Remote**: github.com/antyg/public-docs
**Visibility**: Public
**Last Updated**: February 2026
