# Development

## Purpose

This domain houses development standards, coding practices, evaluation frameworks, and tooling references that guide software development activities across the workspace. It provides the foundational knowledge for writing high-quality, maintainable code across multiple languages and development contexts.

## What This Folder Holds

Development-focused documentation organised by language, technology, or practice area. Each subfolder contains language-specific or practice-specific standards, evaluation frameworks, best practices, and tooling guidance.

## Current Structure

### Subfolders

- **powershell/** — PowerShell coding standards, evaluation frameworks, and best practices (substantive content migrated from Coding/PS/)

## Planned Expansion

Future language and practice areas to be added as the documentation library grows:

- **python/** — Python coding standards, PEP compliance, virtual environment management, testing frameworks
- **devops/** — CI/CD pipeline patterns, infrastructure as code practices, deployment strategies
- **git/** — Version control workflows, branching strategies, commit conventions, repository management

## Relationship to Other Domains

The development domain focuses on **how to write code**, while technology domains (identity, security, endpoints, etc.) focus on **what to build**. Development standards apply across all technology implementations.

For example:
- PowerShell standards in `development/powershell/` apply to scripts in `security/defender/`, `identity/entra-id/`, and `endpoints/intune/`
- Python standards would apply to automation scripts across all technology domains
- Git workflows apply to all repositories referenced in the documentation

## Scope

This domain covers:
- Language-specific coding standards and style guides
- Code quality evaluation frameworks and checklists
- Testing methodologies and frameworks
- Development tooling configuration and usage
- Code review practices and quality gates
- Performance and optimisation guidance
- Security considerations in code development

This domain does **not** cover:
- Technology-specific implementation patterns (those belong in technology domains)
- Project-specific development plans (those belong in `projects/`)
- Operational runbooks (those belong in `operations/`)

## Audience

- Software developers and engineers
- DevOps practitioners
- Code reviewers and quality assurance teams
- Technical leads establishing coding standards
- Anyone writing code for the workspace
