# PowerShell Development Standards

## Purpose

This folder contains comprehensive PowerShell coding standards, evaluation frameworks, and best practices for developing high-quality PowerShell modules, scripts, and functions. The centrepiece is the PSEval Standards Framework — a complete evaluation methodology for assessing PowerShell code quality across six critical categories.

## What This Folder Holds

**Substantive content migrated from Coding/PS/** — This is a well-established body of work, not a placeholder.

### PSEval Standards Framework (218KB)

A comprehensive PowerShell module evaluation framework consisting of 147 standards across 6 categories:

- **Architecture** (25 standards) — Module structure, file organisation, versioning, dependencies, compatibility
- **Coding** (31 standards) — Syntax, style, naming conventions, parameter handling, pipeline support
- **Functions** (28 standards) — Function design, cmdlet binding, parameter validation, output handling
- **Documentation** (24 standards) — Comment-based help, inline documentation, README files, examples
- **Error Handling** (22 standards) — Try/catch patterns, error action preferences, terminating vs non-terminating errors
- **Testing** (17 standards) — Pester test coverage, unit tests, integration tests, mocking strategies

### Documents in This Folder

The framework comprises 10 documents (pending migration from legacy `Coding/PS/` to a `pseval/` subfolder):

1. **Overview** — Framework introduction, evaluation philosophy, scope levels
2. **Architecture** — Module structure and organisation standards
3. **Coding** — Syntax, style, and coding practice standards
4. **Functions** — Function design and implementation standards
5. **Documentation** — Documentation completeness and quality standards
6. **Error Handling** — Error management and resilience standards
7. **Testing** — Test coverage and quality assurance standards
8. **Evaluation Methods** — How to conduct evaluations, scoring methodology
9. **Evaluation Automation** — Automated evaluation tools and scripts
10. **Evaluation Checklists** — Quick reference checklists for each category

## Scope Levels

The framework applies to code at multiple scope levels:

- **Enterprise** — Organisation-wide standards and policies
- **Repository** — Repository-level conventions and structure
- **Module** — PowerShell module architecture and design
- **Script** — Standalone script quality and structure
- **Function** — Individual function implementation
- **Component** — Reusable code components

## Technologies Covered

- **PowerShell 5.1** — Windows PowerShell standards and compatibility
- **PowerShell 7.x** — Cross-platform PowerShell Core/7+ features and patterns
- **PSScriptAnalyzer** — Static code analysis and linting
- **Pester** — Testing framework (v4 and v5)

## Relationship to Other Domains

PowerShell is a cross-cutting development language used throughout the workspace:

- **security/** — Defender for Endpoint queries, security automation scripts
- **identity/** — Entra ID user management, authentication automation
- **endpoints/** — Intune (MEM) endpoint management, configuration scripts
- **operations/** — System administration runbooks and utilities

The standards in this folder apply to PowerShell code in **all** technology domains. When writing PowerShell for security automation, device management, or identity operations, developers should reference these standards.

## Using This Documentation

### For Code Reviews

Use the evaluation checklists to perform structured code reviews. Each category checklist provides a quick assessment framework.

### For Module Development

Follow the architecture and coding standards when creating new modules. The framework provides detailed guidance on module structure, manifest requirements, and best practices.

### For Quality Gates

Implement the evaluation automation guidance to create quality gates in CI/CD pipelines. The framework supports both manual and automated evaluation approaches.

### For Learning and Improvement

Use the framework as a learning resource for PowerShell best practices. Each standard includes rationale and examples.

## Audience

- PowerShell developers and scripters
- Module authors and maintainers
- Code reviewers and quality assurance teams
- DevOps engineers implementing PowerShell automation
- Technical leads establishing PowerShell coding standards
- Anyone writing PowerShell for production use

## Future Expansion

Planned additions to this folder:

- PowerShell DSC (Desired State Configuration) patterns
- PowerShell class design and implementation guidance
- Advanced pipeline and streaming patterns
- Performance optimisation strategies
- PowerShell 7+ specific feature guidance (parallel foreach, ternary operators, null coalescing)
