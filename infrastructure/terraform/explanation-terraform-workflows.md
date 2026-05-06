---
title: "Terraform Workflows"
status: "planned"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "explanation"
domain: "infrastructure"
platform: "Terraform"
---

# Terraform Workflows

This document explains Infrastructure as Code (IaC) principles, the Terraform execution lifecycle, state management, module architecture, and CI/CD integration patterns for Azure resource deployment. For configuration patterns, naming conventions, and code structure standards see [Terraform Patterns Reference](reference-terraform-patterns.md).

---

## Infrastructure as Code Principles

Infrastructure as Code is the practice of managing and provisioning infrastructure through machine-readable configuration files rather than manual processes or interactive tooling. The core benefits applied to Azure environments are:

- **Repeatability**: identical configurations produce identical environments across development, staging, and production
- **Auditability**: all infrastructure changes are tracked in version control with author, timestamp, and intent
- **Idempotency**: applying the same configuration multiple times produces the same result; no unintended drift
- **Peer review**: infrastructure changes are reviewed like application code before they reach production
- **Blast radius reduction**: changes are scoped and planned before execution; unintended side-effects are visible in the plan output

[Terraform](https://developer.hashicorp.com/terraform/docs) by HashiCorp implements IaC using a declarative configuration language (HCL — HashiCorp Configuration Language). The [Terraform Azure Provider (`azurerm`)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) maps HCL resource definitions to Azure Resource Manager (ARM) API calls.

<!-- TODO: Document the organisational decision to use Terraform over Bicep/ARM and link to the ADR when written -->

---

## Terraform Workflow: init → plan → apply → destroy

### `terraform init`

Initialises the working directory. Downloads provider plugins, configures the backend for remote state, and prepares modules. Must be run:

- On first use of a configuration
- After adding a new provider or module source
- After modifying backend configuration

```bash
terraform init -backend-config="backend.hcl"
```

### `terraform plan`

Produces an execution plan showing what changes Terraform will make to reach the desired state. The plan output shows resources to be created (`+`), modified (`~`), or destroyed (`-`).

Key flags:

| Flag | Purpose |
|------|---------|
| `-out=tfplan` | Save plan to a file for use with `apply` |
| `-var-file=prod.tfvars` | Load variable values from a file |
| `-refresh=false` | Skip state refresh (faster; use only when state is known current) |
| `-target=resource.type.name` | Scope plan to a specific resource (use sparingly; breaks dependency tracking) |

`terraform plan` is always read-only — it never makes changes to Azure resources.

### `terraform apply`

Applies the execution plan, creating, modifying, or destroying resources to reach the desired state. When called with a saved plan file (`terraform apply tfplan`), it executes exactly the changes shown in that plan with no interactive prompt.

In CI/CD pipelines, always use a saved plan:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

This two-step pattern ensures the plan reviewed by approvers is exactly what is applied.

### `terraform destroy`

Destroys all resources managed by the configuration. Equivalent to setting all resources to `count = 0` and applying. Used for ephemeral environments; rarely used in production.

Production subscriptions SHOULD have `prevent_destroy = true` lifecycle rules on critical resources and SHOULD NOT permit `terraform destroy` from CI/CD pipelines without manual approval gates.

<!-- TODO: Document the organisational approval gate requirements for apply and destroy operations -->

---

## State Management

### Remote State

Terraform state tracks the mapping between HCL resource definitions and real Azure resources. Remote state stores the state file in a shared, lockable location rather than on a local filesystem.

[Azure Storage Account](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage) is the standard remote backend for Azure-hosted Terraform:

- State is stored as a blob in a dedicated container
- Blob leases provide state locking, preventing concurrent `apply` operations
- Azure Storage versioning provides a full history of state file changes
- Access is controlled via RBAC on the storage account (no access keys in code)

### State Locking

State locking prevents two operators or pipeline runs from simultaneously modifying the same state, which would produce corrupt state. The Azure backend uses blob leases for locking. If a lock is not released (e.g., due to a crashed `apply`), it can be manually broken with:

```bash
terraform force-unlock <lock-id>
```

`force-unlock` MUST only be used when the process that holds the lock is confirmed dead. Using it on an active lock corrupts state.

### State File Security

The Terraform state file contains sensitive values including resource IDs, connection strings, and in some cases secret values. State files MUST:

- Never be committed to version control
- Be stored in a storage account with encryption at rest (Azure Storage default)
- Be accessible only to infrastructure engineers and pipeline service principals
- Have soft delete and versioning enabled for recovery

<!-- TODO: Document the state storage account naming convention and access control model -->

---

## Module Architecture

### Root Modules

A root module is the top-level Terraform configuration that operators run directly. Root modules:

- Define the backend configuration
- Declare provider versions
- Call child modules with environment-specific variable values
- Are not reused; they are environment-specific entry points

Root modules typically correspond to a landing zone component or workload: `connectivity/`, `identity/`, `management/`, `workload-<name>/`.

### Child Modules

Child modules are reusable, composable units of infrastructure. A child module:

- Accepts inputs via variables
- Creates resources
- Exposes outputs for consumption by calling modules

Child modules SHOULD be scoped to a single logical concern: a virtual network module, a Key Vault module, a virtual machine module. Avoid monolithic modules that provision multiple unrelated resource types.

### Module Registry

The [Terraform Registry](https://registry.terraform.io/) hosts community and verified modules. Organisationally maintained modules are hosted in internal source control and referenced by Git URL with a pinned tag:

```hcl
module "hub_vnet" {
  source  = "git::https://dev.azure.com/<org>/<project>/_git/terraform-modules//azure/vnet?ref=v2.1.0"
  ...
}
```

Pin module versions. Never reference a module at a mutable ref (`main`, `HEAD`) in production.

<!-- TODO: Define the internal module registry location, versioning policy, and release process -->

---

## Workspace Management

[Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) provide named state isolation within a single backend configuration. Each workspace has its own state file.

Workspaces are suited to managing multiple instances of the same configuration (e.g., multiple spoke subscriptions from a single module). They are NOT suited to environment separation (dev/staging/prod) because they share the same configuration code and provider credentials — environment isolation is better achieved with separate root modules or separate backend configurations.

<!-- TODO: Document whether workspaces are used in this organisation or whether environment separation uses separate root modules -->

---

## CI/CD Integration

### Azure DevOps Pipelines

[Azure DevOps Terraform integration](https://learn.microsoft.com/en-us/azure/developer/terraform/) uses the Terraform CLI installed on pipeline agents. A standard pipeline structure:

1. **Validate**: `terraform init`, `terraform validate`, `tflint`
2. **Plan**: `terraform plan -out=tfplan`; publish plan output as pipeline artefact
3. **Approval gate**: manual approval required before apply in production environments
4. **Apply**: `terraform apply tfplan`

Service connections use Workload Identity Federation (OIDC) to authenticate to Azure without storing client secrets in pipeline variables.

### GitHub Actions

For repositories using GitHub Actions, the [`hashicorp/setup-terraform`](https://github.com/hashicorp/setup-terraform) action installs the Terraform CLI. Authentication to Azure uses OIDC federation with a service principal configured with federated credentials.

<!-- TODO: Provide pipeline YAML templates once the CI/CD platform decision is confirmed -->

---

## Testing Strategies

### `terraform validate`

Validates HCL syntax and internal consistency. Catches type errors, missing required variables, and invalid references. Runs without provider credentials; suitable for pre-commit checks.

### `tflint`

[TFLint](https://github.com/terraform-linters/tflint) is a Terraform linter that detects provider-specific errors (e.g., invalid Azure VM SKUs, unsupported regions) and enforces style rules. The [`tflint-ruleset-azurerm`](https://github.com/terraform-linters/tflint-ruleset-azurerm) plugin validates `azurerm` resource arguments against the provider schema.

### Checkov

[Checkov](https://www.checkov.io/) is a static analysis tool for IaC that detects security and compliance misconfigurations. Checkov rules check for common Azure security gaps: unencrypted storage, public network access, missing diagnostic settings, and absent resource locks.

### Terratest

[Terratest](https://terratest.gruntwork.io/) is a Go-based testing framework that deploys real infrastructure, runs assertions, and tears it down. Terratest is appropriate for integration testing of modules — verifying that a module actually creates the expected resources with the correct configuration.

Terratest tests are expensive (they incur Azure resource costs and run times of minutes to tens of minutes). They are suited to module validation pipelines, not to every PR.

<!-- TODO: Define the test pyramid for this organisation: which tests run on every PR vs on merge vs on release -->

---

## Drift Detection and Remediation

Configuration drift occurs when the actual state of Azure resources diverges from the Terraform state, typically due to manual changes made outside Terraform.

Detection approaches:

- **`terraform plan` scheduled runs**: run `terraform plan` on a schedule and alert if the plan is non-empty. A non-empty plan against a stable configuration indicates drift.
- **Defender for Cloud**: detects resource configuration changes that violate policy; cross-correlate with Terraform change history.

Remediation:

- For drift introduced by a legitimate manual change: update the Terraform configuration to match, then apply to bring state in sync.
- For drift introduced by an accidental manual change: apply the existing Terraform configuration to restore desired state.
- For drift that Terraform cannot manage (e.g., Azure auto-scaling adjustments): use `lifecycle { ignore_changes = [...] }` to exclude volatile attributes from drift detection.

<!-- TODO: Document the organisational drift response process and escalation path -->

---

## Secret Management

### Azure Key Vault Provider

The [`azurerm_key_vault_secret`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) resource manages secrets in Azure Key Vault. Terraform manages the secret lifecycle (create, rotate, delete) while Key Vault manages access control and audit logging.

Secrets MUST NOT be hardcoded in HCL files or tfvars files committed to version control. Variable values containing secrets are passed via:

- Pipeline secret variables (masked in logs)
- Azure Key Vault data sources (retrieved at plan/apply time using the pipeline identity)
- Managed identity authentication (for workload-to-Key Vault access; no secret required)

### Sensitive Variables

Mark output values and variables containing secrets with `sensitive = true`. Terraform will redact these values from plan and apply output:

```hcl
output "admin_password" {
  value     = azurerm_windows_virtual_machine.vm.admin_password
  sensitive = true
}
```

Note: `sensitive = true` redacts console output but does NOT encrypt the value in state. State file security (see State Management) is the primary control for secret protection in state.

<!-- TODO: Define the organisational approved pattern for secret injection into Terraform pipelines -->

---

## Related Resources

### HashiCorp Documentation

- [Terraform documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform remote state (Azure Storage)](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
- [Terraform modules](https://developer.hashicorp.com/terraform/language/modules)
- [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)

### Azure and DevOps

- [Azure DevOps Terraform tasks](https://learn.microsoft.com/en-us/azure/developer/terraform/)
- [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)

### Testing Tools

- [TFLint](https://github.com/terraform-linters/tflint)
- [Checkov IaC scanner](https://www.checkov.io/)
- [Terratest](https://terratest.gruntwork.io/)

### Australian Security Frameworks

- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
