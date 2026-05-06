---
title: "Terraform Patterns Reference"
status: "planned"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "reference"
domain: "infrastructure"
platform: "Terraform"
---

# Terraform Patterns Reference

Factual reference for Terraform code structure, naming conventions, backend configuration, variable patterns, and lifecycle rules for Azure resource deployments. For workflow concepts and CI/CD integration see [Terraform Workflows](explanation-terraform-workflows.md).

---

## Module Structure Conventions

Every Terraform module MUST follow a consistent file layout. Separating concerns across files makes the module navigable and supports automated tooling.

| File | Purpose | Required |
|------|---------|----------|
| `main.tf` | Resource definitions; primary logic | Yes |
| `variables.tf` | Input variable declarations with types, descriptions, and defaults | Yes |
| `outputs.tf` | Output value declarations | Yes (even if empty) |
| `providers.tf` | Provider and `terraform {}` blocks; version constraints | Yes (root modules only) |
| `locals.tf` | Local value computations; derived names; tag merging | No (include when locals are non-trivial) |
| `data.tf` | Data source declarations | No (include when data sources are non-trivial) |
| `versions.tf` | Alternative location for `terraform {}` block if `providers.tf` is large | No |

Child modules MUST NOT declare `provider` blocks — providers are configured in root modules and passed to child modules via inheritance. Child modules MAY declare `required_providers` within `terraform {}` to document the minimum provider version they require.

<!-- TODO: Add example module directory tree once the internal module library structure is confirmed -->

---

## Naming Conventions for Azure Resources in Terraform

Azure resource names are immutable after creation for most resource types. Errors in naming require resource recreation.

### Terraform Identifier Naming

| Pattern | Applied To | Example |
|---------|-----------|---------|
| `snake_case` | All Terraform resource labels, variable names, output names, local names | `hub_virtual_network`, `location_primary` |
| Descriptive, not abbreviated | Resource labels | `hub_virtual_network` not `hvn` |
| Type suffix omitted from label | Resource labels when the resource type is already explicit | `azurerm_virtual_network.hub` not `azurerm_virtual_network.hub_vnet` |

### Azure Resource Name Construction

Recommended pattern: `<prefix>-<workload>-<environment>-<region>-<sequence>`

| Token | Description | Example |
|-------|-------------|---------|
| `<prefix>` | Organisation or project abbreviation | `cntso` |
| `<workload>` | Resource's workload or purpose | `connectivity`, `identity`, `spoke01` |
| `<environment>` | Environment tier | `prod`, `nonprod`, `dev` |
| `<region>` | Azure region abbreviation | `aue` (Australia East), `ase` (Australia Southeast) |
| `<sequence>` | Zero-padded integer for disambiguation | `001` |

Construct names using a local value to enforce consistency:

```hcl
locals {
  name_prefix = "${var.org_prefix}-${var.workload}-${var.environment}-${var.region}"
}

resource "azurerm_virtual_network" "hub" {
  name = "${local.name_prefix}-vnet-001"
  ...
}
```

Azure resource name length limits and allowed character sets apply. Validate names against [Azure naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) before applying.

<!-- TODO: Publish the approved organisation-specific abbreviation table (org prefix, workload names, region codes) -->

---

## Backend Configuration for Azure Storage Account

The `azurerm` backend stores Terraform state in an Azure Storage Account blob. Configuration is split between a code block (committed to version control) and a backend configuration file (environment-specific, not committed).

### `providers.tf` — backend block (committed)

```hcl
terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    # Values supplied at init time via -backend-config flag
    # Do not hardcode subscription_id, resource_group_name, storage_account_name, or access_key here
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

### `backend.hcl` — environment-specific (not committed)

```hcl
subscription_id      = "<management-subscription-id>"
resource_group_name  = "rg-terraform-state-prod-aue-001"
storage_account_name = "stterraformstateprod001"
container_name       = "tfstate"
key                  = "connectivity/hub.tfstate"
use_oidc             = true
```

`use_oidc = true` enables authentication via Workload Identity Federation (OIDC), avoiding the need to store storage account keys or service principal secrets in pipeline variables.

### Initialise with backend config

```bash
terraform init -backend-config="backend.hcl"
```

<!-- TODO: Document the naming convention for state container keys (key path pattern) once confirmed -->

---

## Common Variable Types and Validation Patterns

### Type Declarations

Always declare explicit types. Avoid `type = any`.

```hcl
variable "location" {
  type        = string
  description = "Azure region for resource deployment."
  default     = "australiaeast"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "subnet_config" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "List of subnet configurations."
}
```

### Validation Blocks

Use validation blocks to catch invalid inputs at plan time before any Azure API calls are made:

```hcl
variable "environment" {
  type        = string
  description = "Environment tier."

  validation {
    condition     = contains(["prod", "nonprod", "dev", "sandbox"], var.environment)
    error_message = "environment must be one of: prod, nonprod, dev, sandbox."
  }
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment."

  validation {
    condition     = contains(["australiaeast", "australiasoutheast"], var.location)
    error_message = "location must be australiaeast or australiasoutheast."
  }
}
```

---

## Output Patterns for Cross-Module References

Outputs expose values from a module for consumption by the calling root module or other child modules.

### Declaring Outputs

```hcl
# outputs.tf

output "vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall."
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
```

### Consuming Outputs from a Child Module

```hcl
module "hub" {
  source   = "../modules/azure/hub-vnet"
  ...
}

# Use hub outputs in the root module or pass to another child module
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  remote_virtual_network_id = module.hub.vnet_id
  ...
}
```

### Remote State Outputs

To consume outputs from a separate Terraform state (e.g., reading the hub VNet ID in a spoke configuration):

```hcl
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state-prod-aue-001"
    storage_account_name = "stterraformstateprod001"
    container_name       = "tfstate"
    key                  = "connectivity/hub.tfstate"
  }
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  remote_virtual_network_id = data.terraform_remote_state.hub.outputs.vnet_id
  ...
}
```

---

## Provider Version Constraint Syntax

Terraform uses [version constraint syntax](https://developer.hashicorp.com/terraform/language/expressions/version-constraints) for both Terraform core and provider versions.

| Operator | Meaning | Example |
|----------|---------|---------|
| `= 1.9.0` | Exact version only | Rarely appropriate; prevents patch updates |
| `>= 1.9.0` | Minimum version; no upper bound | Risk of breaking changes on major versions |
| `~> 4.0` | Allows rightmost version component to increment | `4.0`, `4.1`, `4.99` — NOT `5.0` |
| `~> 4.10.0` | Patch-only updates | `4.10.0`, `4.10.5` — NOT `4.11.0` |
| `>= 4.0, < 5.0` | Range constraint | Equivalent to `~> 4.0` |

Recommended pattern:

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}
```

Use `~> <major>.<minor>` for providers to receive patch updates automatically while protecting against breaking changes introduced in minor or major releases. Upgrade minor versions deliberately after reviewing the provider changelog.

---

## Resource Tagging Standards

All Azure resources managed by Terraform MUST carry a consistent set of tags. Enforce tags via a `locals` merge pattern:

```hcl
# variables.tf
variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to merge with the standard tag set."
  default     = {}
}

# locals.tf
locals {
  standard_tags = {
    environment         = var.environment
    workload            = var.workload
    owner               = var.owner
    cost-centre         = var.cost_centre
    data-classification = var.data_classification
    managed-by          = "terraform"
  }

  tags = merge(local.standard_tags, var.additional_tags)
}

# main.tf — reference tags on every resource
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg-001"
  location = var.location
  tags     = local.tags
}
```

`additional_tags` allows workload-specific tags without breaking the standard baseline. `merge()` applies `additional_tags` last; workload-specific values override standards only when explicitly set.

---

## Lifecycle Meta-Arguments

[Lifecycle meta-arguments](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle) control how Terraform handles resource creation, updates, and destruction.

### `create_before_destroy`

Applicable when a resource must be recreated (e.g., name change) and an in-place update is not supported. Ensures the new resource is created and all references updated before the old resource is destroyed:

```hcl
resource "azurerm_key_vault" "main" {
  ...
  lifecycle {
    create_before_destroy = true
  }
}
```

Use for resources with dependent references (Key Vault, certificates, DNS records) where destruction before creation would cause downtime.

### `prevent_destroy`

Prevents `terraform destroy` or removal from configuration from destroying the resource. Use on critical production resources:

```hcl
resource "azurerm_resource_group" "hub" {
  ...
  lifecycle {
    prevent_destroy = true
  }
}
```

Terraform will produce an error if a plan would destroy a resource protected by `prevent_destroy`. The block must be explicitly removed from the configuration before the resource can be destroyed.

### `ignore_changes`

Suppresses drift detection for specified attributes. Use when an attribute is managed outside Terraform (auto-scaling, external tag management):

```hcl
resource "azurerm_virtual_machine_scale_set" "app" {
  ...
  lifecycle {
    ignore_changes = [
      sku[0].capacity,  # Managed by autoscale rules
      tags["LastModifiedBy"],  # Managed by external CMDB tooling
    ]
  }
}
```

Use `ignore_changes` sparingly. Overuse masks legitimate drift and undermines the purpose of IaC.

---

## Data Source Patterns for Existing Azure Resources

Data sources read existing Azure resources without managing their lifecycle. Use data sources to reference platform resources (hub VNet, Key Vault, subscription IDs) that are owned by a different Terraform state or managed outside Terraform.

### Reference an Existing Resource Group

```hcl
data "azurerm_resource_group" "platform" {
  name = "rg-platform-management-prod-aue-001"
}
```

### Reference an Existing Key Vault

```hcl
data "azurerm_key_vault" "shared" {
  name                = "kv-shared-prod-aue-001"
  resource_group_name = data.azurerm_resource_group.platform.name
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.shared.id
}
```

### Reference Current Subscription and Tenant

```hcl
data "azurerm_client_config" "current" {}

# Use in resources requiring subscription_id or tenant_id
resource "azurerm_role_assignment" "example" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = var.principal_id
}
```

### Reference an Existing Virtual Network

```hcl
data "azurerm_virtual_network" "hub" {
  name                = "vnet-connectivity-prod-aue-001"
  resource_group_name = "rg-connectivity-prod-aue-001"
}
```

Data sources require the referenced resource to exist at plan time. If the resource may not exist, use `try()` or `depends_on` to sequence creation correctly.

---

## Related Resources

### HashiCorp Documentation

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform variable validation](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules)
- [Terraform lifecycle meta-arguments](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform version constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)
- [Terraform remote state data source](https://developer.hashicorp.com/terraform/language/state/remote-state-data)

### Azure Documentation

- [Azure resource naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
- [Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)
- [Azure DevOps Terraform tasks](https://learn.microsoft.com/en-us/azure/developer/terraform/)

### Australian Security Frameworks

- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
