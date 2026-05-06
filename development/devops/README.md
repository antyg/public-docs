---
title: "DevOps Practices"
status: "planned"
last_updated: "2026-03-16"
audience: "DevOps Engineers, Platform Engineers, Developers"
document_type: "readme"
domain: "development"
---

# DevOps Practices

CI/CD pipeline design, automation workflows, release management, and DevOps practices for infrastructure and application deployment in the workspace.

---

## Planned Content

### CI/CD Pipeline Design

- [Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines) YAML pipeline structure: stages, jobs, steps, templates
- [GitHub Actions](https://docs.github.com/en/actions) workflow design: events, jobs, reusable workflows
- Pipeline-as-code principles: pipelines version-controlled alongside application code
- Multi-stage pipeline patterns: build → test → staging → production promotion
- Pipeline templates and reusable components
- Conditional execution: branch filters, path filters, manual approval gates

### Automation Workflows

- Idempotent deployment scripts: re-runnable without side effects
- PowerShell automation patterns for pipeline steps
- Infrastructure validation scripts (pre- and post-deployment checks)
- Automated rollback triggers and procedures
- Scheduled maintenance automation (cleanup, rotation, health checks)

### Release Management and Deployment Strategies

- [Semantic Versioning](https://semver.org/) for all modules and applications
- Automated version bumping from commit history
- Release branch strategies: trunk-based development vs Gitflow
- Deployment strategies: blue-green, canary, rolling update, feature flags
- Release notes generation from `CHANGELOG.md` ([Keep a Changelog](https://keepachangelog.com/) format)
- Artefact management: Azure Artifacts, GitHub Packages, PowerShell Gallery

### Infrastructure Testing and Validation Automation

- Infrastructure-as-code testing with [Pester](https://pester.dev/) (PowerShell) and [pytest](https://docs.pytest.org/) (Python)
- [Checkov](https://www.checkov.io/) for Bicep/Terraform static analysis
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) in pipeline for PowerShell quality gates
- Smoke tests post-deployment: verify deployed resources are responsive
- Integration test environments: ephemeral environments spun up per PR
- Test result publishing: NUnit XML to Azure Pipelines, JUnit to GitHub Actions

### Secrets Management and Secure Pipeline Practices

- [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/) for secret storage; no secrets in pipeline YAML
- Service principal and managed identity patterns for pipeline authentication
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and environment protection rules
- Azure Pipelines variable groups with Key Vault integration
- Secret rotation automation and expiry monitoring
- Principle of least privilege for pipeline service accounts

### Monitoring and Observability

- Deployment metrics: deployment frequency, lead time, change failure rate, MTTR ([DORA metrics](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance))
- Pipeline health dashboards in Azure DevOps and GitHub
- Alert on pipeline failure: Teams/email notifications from failed builds
- Post-deployment health monitoring integration
- Structured logging from automation scripts

### Infrastructure as Code

- [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/) for Azure resource deployment
- [Terraform](https://developer.hashicorp.com/terraform) for multi-cloud or complex dependency scenarios
- Module patterns: reusable Bicep modules, Terraform modules
- State management: Azure storage backend for Terraform state
- Drift detection: compare deployed state against IaC definitions

---

## Related Resources

- [Microsoft — What is Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [DORA Metrics](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Checkov](https://www.checkov.io/)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
