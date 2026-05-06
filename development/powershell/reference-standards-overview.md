---
title: "PowerShell Module Evaluation Standards — Overview"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Technical Leads, Code Reviewers"
document_type: "reference"
domain: "development"
---

# PowerShell Module Evaluation Standards — Overview

The PSEval Standards Framework is a systematic evaluation framework for assessing PowerShell codebases at all organisational scope levels. It comprises 147 individual standards across six categories, derived from [Microsoft's official PowerShell documentation](https://learn.microsoft.com/en-us/powershell/) and enterprise best practices established through the [PowerShell Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style).

---

## Evaluation Scope Levels

Standards apply at six discrete scope levels. Each level implies a progressively broader evaluation surface:

| Level | Definition | Typical Scale |
|---|---|---|
| **Enterprise** | Entire organisational PowerShell codebase | 1 000+ modules |
| **Repository** | Multiple modules within a single codebase | 10–100 modules |
| **Module** | Single PowerShell module (`.psm1` + `.psd1`) | 1 module |
| **Script** | Standalone `.ps1` file | 1 script |
| **Function** | Individual function or cmdlet | 1 function |
| **Component** | Specific code component (parameters, error handling, documentation blocks) | 1 component |

---

## Standards Categories

### 1. Architecture Standards — 25 Standards

Covers module structure and organisation patterns, manifest design and configuration, file and directory hierarchies, deployment and distribution strategies, and module lifecycle management. See [standards-architecture.md](standards-architecture.md).

Critical standards: ARCH-001 (module manifest required), ARCH-002 (standard directory structure), ARCH-004 (explicit export declaration).

### 2. Coding Standards — 31 Standards

Covers [Microsoft naming conventions](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) compliance, variable scope management, flow control patterns, performance optimisation techniques, and security implementation patterns. See [standards-coding.md](standards-coding.md).

Critical standards: CODE-001 (approved verbs only), CODE-002 (Verb-Noun pattern), CODE-013 (credential handling), CODE-014 (input validation).

### 3. Function Design Standards — 28 Standards

Covers advanced function architecture, parameter design and validation, pipeline integration patterns, input/output type management, and processing method implementation. See [standards-functions.md](standards-functions.md).

Critical standards: FUNC-001 (`CmdletBinding` required), FUNC-002 (parameter validation), FUNC-004 (output type declaration).

### 4. Documentation Standards — 24 Standards

Covers comment-based help completeness, external XML help file quality, API reference documentation, example and usage documentation, and cross-reference and linking standards. See [standards-documentation.md](standards-documentation.md).

Critical standards: DOC-001 (comment-based help required), DOC-002 (synopsis and description quality).

### 5. Error Handling Standards — 22 Standards

Covers exception categorisation and handling, error record construction, retry and resilience patterns, debugging and diagnostic capabilities, and centralised error management. See [standards-error-handling.md](standards-error-handling.md).

Critical standards: ERR-001 (try-catch implementation), ERR-002 (error record construction), ERR-006 (security-safe error reporting).

### 6. Testing and Validation Standards — 17 Standards

Covers unit testing coverage and quality, integration testing strategies, performance testing requirements, security testing protocols, and automated validation processes. See [standards-testing.md](standards-testing.md).

Critical standards: TEST-001 (unit test coverage ≥ 80%), TEST-010 (security vulnerability testing), TEST-016 (quality gate implementation).

---

## Standards Priority Classification

### Critical Standards — 42 Standards

Mandatory for any enterprise PowerShell module. Failure to meet any critical standard constitutes a blocking compliance defect.

| Standard ID | Category | Title | Scope |
|---|---|---|---|
| ARCH-001 | Architecture | Module Manifest Required | Module, Repository, Enterprise |
| ARCH-002 | Architecture | Standard Directory Structure | Module, Repository, Enterprise |
| CODE-001 | Coding | Microsoft Approved Verbs Only | Function, Module, Repository |
| CODE-002 | Coding | Verb-Noun Naming Pattern | Function, Module, Repository |
| CODE-013 | Coding | Credential Handling | Function, Module, Enterprise |
| CODE-014 | Coding | Input Validation and Sanitisation | Function, Script |
| FUNC-001 | Functions | CmdletBinding Required | Function, Module, Repository |
| FUNC-002 | Functions | Parameter Validation | Function, Module, Repository |
| DOC-001 | Documentation | Comment-Based Help Required | Function, Module, Repository |
| DOC-002 | Documentation | Help Content Quality | Function, Module |
| ERR-001 | Error Handling | Try-Catch Implementation | Function, Module, Repository |
| ERR-002 | Error Handling | Error Record Construction | Function, Module |
| ERR-006 | Error Handling | Security-Safe Error Reporting | Function, Module |
| TEST-001 | Testing | Unit Test Coverage Requirements | Function, Module, Repository |
| TEST-010 | Testing | Security Vulnerability Testing | Function, Module, Repository |
| TEST-011 | Testing | Credential Handling Testing | Function, Module |
| TEST-016 | Testing | Quality Gate Implementation | Repository, Enterprise |

### Important Standards — 58 Standards

Significantly improve code quality and maintainability. Deviation requires documented justification.

| Standard ID | Category | Title | Scope |
|---|---|---|---|
| ARCH-003 | Architecture | Semantic Version Compliance | Module, Repository, Enterprise |
| CODE-003 | Coding | Variable Naming Standards | Function, Script |
| FUNC-003 | Functions | Pipeline Input Support | Function, Module, Repository |
| DOC-003 | Documentation | API Reference Completeness | Module, Repository |
| ERR-003 | Error Handling | Exception Type Specificity | Function |

### Recommended Standards — 47 Standards

Enhance user experience and enterprise integration. Treated as targets for mature codebases.

| Standard ID | Category | Title | Scope |
|---|---|---|---|
| ARCH-004 | Architecture | Module Auto-Loading Support | Module, Repository |
| CODE-004 | Coding | Performance Optimisation | Function, Module, Repository |
| FUNC-004 | Functions | Progress Indicators | Function, Module |
| DOC-004 | Documentation | Type Documentation | Module |
| ERR-004 | Error Handling | Centralised Error Logging | Module, Repository |

---

## Compliance Scoring

The framework uses a weighted scoring model across three tiers:

| Category | Weight | Pass Threshold |
|---|---|---|
| Critical standards | High | All must pass (100%) |
| Important standards | Medium | ≥ 80% must pass |
| Recommended standards | Low | ≥ 60% recommended |

**Overall module pass threshold**: ≥ 75% weighted score with 100% of Critical standards passing.

Compliance scores are reported at function, module, repository, and enterprise levels. See [explanation-evaluation-methodology.md](explanation-evaluation-methodology.md) for scoring methodology detail.

---

## Automated Evaluation

The [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) module provides automated static analysis covering a significant subset of standards. The `Invoke-PSEvaluation` automation engine extends PSScriptAnalyzer with custom rules aligned to this framework. See [how-to-automate-evaluation.md](how-to-automate-evaluation.md) and [reference-evaluation-automation-api.md](reference-evaluation-automation-api.md).

---

## Standards Maintenance

| Cycle | Activity |
|---|---|
| Quarterly | Standards effectiveness assessment |
| Annual | Major standards revisions and additions |
| Continuous | Developer feedback integration |
| As needed | Alignment with Microsoft PowerShell community updates |

All standards changes are versioned. Impact assessments are performed before changes are published. Migration guidance is provided for breaking changes.

---

## Related Resources

- [Microsoft PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [PowerShell Approved Verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [PSScriptAnalyzer — GitHub](https://github.com/PowerShell/PSScriptAnalyzer)
- [Pester Testing Framework](https://pester.dev/)
- [standards-architecture.md](standards-architecture.md)
- [standards-coding.md](standards-coding.md)
- [standards-functions.md](standards-functions.md)
- [standards-documentation.md](standards-documentation.md)
- [standards-error-handling.md](standards-error-handling.md)
- [standards-testing.md](standards-testing.md)
- [explanation-evaluation-methodology.md](explanation-evaluation-methodology.md)
- [how-to-evaluate-module-compliance.md](how-to-evaluate-module-compliance.md)
- [how-to-automate-evaluation.md](how-to-automate-evaluation.md)
- [reference-evaluation-automation-api.md](reference-evaluation-automation-api.md)
