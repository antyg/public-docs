---
title: "PowerShell Development Standards"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Module Authors, Code Reviewers, DevOps Engineers"
document_type: "readme"
domain: "development"
---

# PowerShell Development Standards

Comprehensive PowerShell coding standards, evaluation frameworks, and best practices for developing high-quality PowerShell modules, scripts, and functions. The centrepiece is the PSEval Standards Framework — 147 standards across six categories with full automated evaluation tooling.

---

## Standards Reference

| Document | Standards | Description |
|---|---|---|
| [reference-standards-overview.md](reference-standards-overview.md) | Framework | PSEval framework overview, scope levels, compliance scoring, automated evaluation summary |
| [reference-standards-architecture.md](reference-standards-architecture.md) | ARCH-001–025 | Module structure, manifest, directory layout, versioning, dependencies |
| [reference-standards-coding.md](reference-standards-coding.md) | CODE-001–031 | Naming conventions, variables, flow control, performance, security |
| [reference-standards-functions.md](reference-standards-functions.md) | FUNC-001–028 | Function design, CmdletBinding, parameter validation, pipeline integration |
| [reference-standards-documentation.md](reference-standards-documentation.md) | DOC-001–024 | Comment-based help, API reference, README, changelog |
| [reference-standards-error-handling.md](reference-standards-error-handling.md) | ERR-001–022 | Exception handling, error records, retry logic, resilience patterns |
| [reference-standards-testing.md](reference-standards-testing.md) | TEST-001–017 | Pester unit/integration tests, coverage, security testing, CI quality gates |

---

## Evaluation Documentation

| Document | Type | Description |
|---|---|---|
| [explanation-evaluation-methodology.md](explanation-evaluation-methodology.md) | Explanation | Compliance scoring model, priority tiers, pass thresholds, automated vs manual evaluation |
| [how-to-evaluate-module-compliance.md](how-to-evaluate-module-compliance.md) | How-to | Step-by-step checklists for module evaluation at all scope levels |
| [how-to-automate-evaluation.md](how-to-automate-evaluation.md) | How-to | CI/CD integration for Azure Pipelines and GitHub Actions |
| [reference-evaluation-automation-api.md](reference-evaluation-automation-api.md) | Reference | Function API for `Invoke-PSEvaluation`, `Export-PSEvalResults`, configuration objects |

---

## Standards at a Glance

| Category | Standards | Critical | Important | Recommended |
|---|---|---|---|---|
| Architecture | 25 | 3 | 17 | 5 |
| Coding | 31 | 4 | 20 | 7 |
| Functions | 28 | 5 | 18 | 5 |
| Documentation | 24 | 2 | 16 | 6 |
| Error Handling | 22 | 4 | 14 | 4 |
| Testing | 17 | 4 | 10 | 3 |
| **Total** | **147** | **22** | **95** | **30** |

---

## Compliance Thresholds

| Result | Overall Score | Critical Score |
|---|---|---|
| Pass | ≥ 75% | ≥ 80% |
| Excellence | ≥ 90% | ≥ 95% |

All Critical standards carry 60% of the total weight. A module that fails any Critical standard cannot achieve Pass status regardless of overall score.

---

## Technologies Covered

- **PowerShell 5.1** — Windows PowerShell standards and compatibility
- **PowerShell 7.x** — Cross-platform PowerShell Core/7+ features and patterns
- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** — Static code analysis and linting (mandatory quality gate)
- **[Pester 5.x](https://pester.dev/)** — Testing framework (v4 for PS 5.1-only modules)

---

## Relationship to Other Domains

PowerShell is a cross-cutting development language used throughout the workspace. These standards apply to PowerShell code in all technology domains:

- **security/** — Defender for Endpoint queries, security automation scripts
- **identity/** — Entra ID user management, authentication automation
- **endpoints/** — Intune endpoint management, configuration scripts
- **operations/** — System administration runbooks and utilities

---

## Future Expansion

Planned additions to this folder:

- PowerShell DSC (Desired State Configuration) patterns
- PowerShell class design and implementation guidance
- Advanced pipeline and streaming patterns
- Performance optimisation strategies
- PowerShell 7+ specific feature guidance (parallel foreach, ternary operators, null coalescing)
