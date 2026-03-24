---
title: "Terraform"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# Terraform

## Purpose

This directory contains documentation for Infrastructure as Code (IaC) practices using [Terraform](https://developer.hashicorp.com/terraform/docs) and the [Terraform Azure Provider (`azurerm`)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs). It covers the Terraform execution lifecycle, state management with Azure Storage backends, module architecture, CI/CD pipeline integration, testing strategies, and code structure conventions for Azure resource deployments.

## Content

### Explanation

Understanding-oriented documents covering concepts and design rationale.

| Document | Description |
|----------|-------------|
| [Terraform Workflows](explanation-terraform-workflows.md) | IaC principles; init → plan → apply → destroy lifecycle; remote state with Azure Storage; state locking; module architecture (root vs child modules); workspace management; Azure DevOps and GitHub Actions CI/CD integration; testing strategies (tflint, checkov, Terratest); drift detection; secret management with Azure Key Vault |

### Reference

Information-oriented documents for factual lookup and configuration specifications.

| Document | Description |
|----------|-------------|
| [Terraform Patterns Reference](reference-terraform-patterns.md) | Module file structure conventions; Azure resource naming patterns; backend configuration for Azure Storage; variable types and validation patterns; output patterns for cross-module references; provider version constraint syntax; resource tagging standards; lifecycle meta-arguments; data source patterns for existing Azure resources |

## Planned Expansion

Future content to be added to this directory:

- **how-to-bootstrap-terraform-backend.md** — Step-by-step guide to provisioning the Azure Storage Account, container, and service principal required before first `terraform init`
- **how-to-create-module.md** — Procedure for authoring, testing, and publishing a new internal Terraform module
- **how-to-set-up-pipeline.md** — Azure DevOps pipeline YAML templates for validate → plan → apply workflows
- **reference-module-library.md** — Catalogue of approved internal modules with version pins and usage examples
- **explanation-state-management-strategy.md** — Design rationale for state partitioning (per-component vs per-environment vs per-team) and remote state sharing patterns

<!-- TODO: Add how-to guides and module library reference once the internal module registry and CI/CD platform are confirmed -->

## Relationship to Other Content

| Domain | Relationship |
|--------|-------------|
| [infrastructure/azure-landing-zones/](../azure-landing-zones/) | Landing zone architecture defines the target state that Terraform modules implement; subscription hierarchy, network topology, and policy assignments are all deployed via Terraform |
| [infrastructure/pki/](../pki/) | PKI infrastructure resources (Azure Private CA, Key Vault) are candidates for Terraform-managed deployment |
| [networking/](../../networking/) | Network infrastructure resources (virtual networks, firewalls, DNS) are deployed and managed via Terraform modules |
| [identity/](../../identity/) | Entra ID app registrations and service principals used for Terraform authentication are managed in the identity domain |

## Navigation

- Parent: [Infrastructure Documentation](../README.md)
- Sibling: [azure-landing-zones/](../azure-landing-zones/), [pki/](../pki/)
- Domain root: [antyg-public Documentation Library](../../README.md)

---

**Australian English** | **Last Updated**: 2026-03-16
