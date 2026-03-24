---
title: "Git Standards"
status: "planned"
last_updated: "2026-03-16"
audience: "Developers, DevOps Engineers"
document_type: "readme"
domain: "development"
---

# Git Standards

Repository structure, branching strategy, commit conventions, and collaboration workflows for version control across the workspace.

---

## Planned Content

### Repository Structure and Organisation

- Repository naming conventions: `<org>-<Product>` pattern (e.g., `antyg-SccmIntuneMigrationAssistant`)
- Standard top-level directories: `src/`, `tests/`, `docs/`, `.github/` or `.azuredevops/`
- Module repositories: `src/Public/`, `src/Private/`, `tests/Unit/`, `tests/Integration/`
- Root file requirements: `README.md`, `CHANGELOG.md`, `.gitignore`, module manifest
- `.gitignore` patterns: build artefacts, log files, credential files, IDE files, `node_modules/`, `__pycache__/`
- Mono-repository vs multi-repository trade-offs
- Submodule usage: when appropriate, how to manage updates

### Branching Strategy

- **Trunk-based development** (preferred for small teams and CI/CD): short-lived feature branches, direct merge to `main`, feature flags for incomplete work
- **Gitflow** (for release-gated products): `main`, `develop`, `feature/*`, `release/*`, `hotfix/*` branch model
- Branch naming conventions: `feature/<ticket>-<short-description>`, `fix/<ticket>-<description>`, `hotfix/<version>-<description>`
- Branch protection rules: require PR review, require status checks to pass, no direct push to `main`
- Stale branch cleanup: automated deletion after merge; manual review of branches > 30 days old

### Commit Message Conventions

- [Conventional Commits](https://www.conventionalcommits.org/) specification: `<type>(<scope>): <description>`
- Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `revert`
- Scope: module name or area affected (e.g., `feat(auth): add token refresh logic`)
- Subject line: imperative mood, ≤ 72 characters, no full stop
- Body: explain *why* not *what*; wrap at 72 characters
- Breaking changes: `BREAKING CHANGE:` footer or `!` suffix (e.g., `feat!: remove deprecated parameter`)
- Co-author attribution: `Co-authored-by: Name <email>`
- [Author trailer](https://git-scm.com/docs/git-commit#_discussion) pattern for agent commits

### Semantic Versioning

- [Semantic Versioning 2.0.0](https://semver.org/): `MAJOR.MINOR.PATCH`
  - `MAJOR` — breaking changes (incompatible API changes)
  - `MINOR` — backwards-compatible new functionality
  - `PATCH` — backwards-compatible bug fixes
- Pre-release versions: `1.0.0-alpha.1`, `1.0.0-beta.2`, `1.0.0-rc.1`
- Version tagging: `git tag v1.2.3` on merge commit to `main`
- Module manifest `ModuleVersion` must match git tag at release
- Automated version bumping from Conventional Commits using tools like [standard-version](https://github.com/conventional-changelog/standard-version) or [semantic-release](https://semantic-release.gitbook.io/)

### Pull Request Workflows

- PR description template: Summary, Motivation, Testing, Screenshots (if applicable), Checklist
- Minimum one approving review before merge
- All CI status checks must pass before merge
- Squash merge preferred for feature branches (clean history on `main`)
- Merge commit for release branches (preserve merge history)
- PR size guidelines: < 400 lines changed per PR; split large changes into sequential PRs
- Draft PRs for early feedback on work-in-progress
- Link PR to issue or work item

### Code Review Practices

- Reviewer responsibilities: correctness, security, standards compliance, test coverage
- Reviewee responsibilities: respond to all comments, mark resolved when addressed
- Comment tone: constructive and specific; suggest alternatives rather than just identifying problems
- Review turnaround: 24 hours for standard PRs, 4 hours for hotfix PRs
- Approval does not mean endorsement of all choices — it means the code meets the bar for merge

### Git Hooks and Pre-Commit Automation

- [pre-commit](https://pre-commit.com/) framework for client-side hooks
- Pre-commit checks: linting (Ruff, PSScriptAnalyzer), formatting (Black), secret scanning
- Commit message validation: [commitlint](https://commitlint.js.org/) enforcing Conventional Commits
- Pre-push hooks: run test suite before push to remote
- Server-side hooks (Azure DevOps / GitHub): branch protection, required status checks
- Hook bypass (`--no-verify`): documented exception process; not for routine use

### History Management

- Interactive rebase for local cleanup before PR (never rebase shared branches)
- `git bisect` for regression investigation
- `git log --oneline --graph` for history visualisation
- Preserving history: prefer `revert` over `reset --hard` for shared branches
- `.git-blame-ignore-revs` for bulk formatting commits (suppresses formatter commits from `git blame`)

---

## Related Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [pre-commit Framework](https://pre-commit.com/)
- [commitlint](https://commitlint.js.org/)
- [Microsoft — Azure DevOps Branch Policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies)
- [GitHub — Protected Branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Atlassian — Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Trunk Based Development](https://trunkbaseddevelopment.com/)
