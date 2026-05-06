---
title: "PowerShell Scripts: Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# PowerShell Scripts: Microsoft Defender for Cloud

---

## Overview

This directory contains PowerShell automation scripts for Microsoft Defender for Cloud. Scripts are organised by function: Deployment, Monitoring, Planning, and Troubleshooting. A Tutorials subfolder contains prerequisite validation and configuration export utilities.

All scripts require [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps) (Az module) and PowerShell 7+. Authenticate with `Connect-AzAccount` and set the target subscription with `Set-AzContext` before running any script.

---

## Prerequisites

```powershell
# Install required modules
Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

# Authenticate
Connect-AzAccount

# Set subscription context
Set-AzContext -SubscriptionId '<your-subscription-id>'
```

**Minimum role requirements**:

| Script category | Minimum role |
|----------------|-------------|
| Deployment | Contributor + Security Admin |
| Monitoring | Security Admin |
| Planning | Security Reader |
| Troubleshooting | Security Reader |
| Tutorials | Security Reader |

---

## Deployment

Scripts that provision Defender for Cloud infrastructure and integrations.

### Deploy-DefenderFoundation.ps1

**Source**: `Deploy-DefenderFoundation.ps1`
**Purpose**: Deploys foundational Defender for Cloud configuration — enables Foundational CSPM, assigns compliance frameworks, creates a Log Analytics workspace, and enables baseline Defender plans.

**Key parameters**: `-SubscriptionId`, `-Environment` (Production/Development/Testing/Sandbox), `-ComplianceFramework` (FedRAMP-High/NIST-SP-800-53/Essential-Eight), `-ResourceGroupName`, `-WorkspaceName`, `-Location`

**Australian usage**:
```powershell
.\Deploy-DefenderFoundation.ps1 `
    -SubscriptionId '<subscription-id>' `
    -Environment Production `
    -ComplianceFramework 'Essential-Eight' `
    -ResourceGroupName 'rg-security-baseline' `
    -WorkspaceName 'law-security-australiaeast' `
    -Location 'australiaeast'
```

### Deployment\Deploy-EnterpriseScaleArchitecture.ps1

**Purpose**: Deploys enterprise-scale Defender for Cloud across multiple subscriptions with multi-region redundancy and compliance framework assignment.

**Key parameters**: `-SubscriptionId`, `-PrimaryRegion`, `-SecondaryRegion`, `-ComplianceFramework`, `-OrganizationPrefix`, `-EnableAutomation`, `-IncludeThreatHunting`

### Deployment\Deploy-GovernmentSOC.ps1

**Purpose**: Deploys a government-grade Security Operations Centre with 24x7 monitoring, classification-based data retention, and automated incident response. Originally written for US Government Cloud (`US Gov Virginia`). Replace region with `australiaeast` or `australiasoutheast` for Australian deployments.

**Key parameters**: `-SubscriptionId`, `-SOCRegion`, `-OrganizationName`, `-ClassificationLevel`, `-AlertEmailAddresses`

### Deployment\Deploy-DevSecOpsIntegration.ps1

**Purpose**: Integrates Defender for Cloud with CI/CD pipelines (Azure DevOps, GitHub). Enables IaC security scanning, container vulnerability scanning, and security gate policies in deployment pipelines.

**Key parameters**: `-SubscriptionId`, `-DevOpsOrganization`, `-Platform` (AzureDevOps/GitHub), `-ProjectNames`, `-SecurityGatePolicy`, `-EnableIaCScan`, `-EnableContainerScan`

### Deployment\Invoke-InfrastructureDiscovery.ps1

**Purpose**: Discovers and inventories all Azure resources across a subscription, producing a report of resources by type, region, and risk classification to inform Defender plan scoping decisions.

### Deployment\Invoke-CostBenefitAnalysis.ps1

**Purpose**: Calculates projected Defender for Cloud licensing costs based on current resource inventory, comparing plan options (Plan 1 vs Plan 2 for servers, selective vs full database coverage).

### Deployment\Deploy-EnterpriseDefenderArchitecture.ps1

**Purpose**: End-to-end enterprise deployment combining multi-subscription management group configuration, policy initiative assignment, and Defender plan enablement.

---

## Monitoring

Scripts for incident response automation and threat hunting capability deployment.

### Monitoring\Deploy-IncidentResponsePlaybooks.ps1

**Purpose**: Deploys Azure Logic Apps incident response playbooks — automated alert notification, evidence preservation, stakeholder escalation, and containment workflows.

**Key parameters**: `-SubscriptionId`, `-ResourceGroupName`, `-Location`, `-SecurityTeamEmail`, `-ComplianceFramework`, `-EnableThreatHunting`, `-EnableAutomatedContainment`, `-IncidentSeverityThreshold`

**Usage**:
```powershell
.\Monitoring\Deploy-IncidentResponsePlaybooks.ps1 `
    -SubscriptionId '<subscription-id>' `
    -ResourceGroupName 'rg-security-ir' `
    -Location 'australiaeast' `
    -SecurityTeamEmail 'security@agency.gov.au' `
    -IncidentSeverityThreshold 'High'
```

### Monitoring\Deploy-ThreatHuntingCapabilities.ps1

**Purpose**: Deploys pre-built KQL threat hunting queries, automated hunting schedules, and MITRE ATT&CK-mapped detection rules to a Log Analytics workspace.

**Key parameters**: `-SubscriptionId`, `-ResourceGroupName`, `-LogAnalyticsWorkspaceId`, `-Location`, `-HuntingTeamEmail`, `-EnableMITREMapping`, `-HuntingSchedule`, `-RetentionDays`

---

## Planning

Scripts for cost estimation, E5 coverage analysis, and risk assessment prior to deployment.

### Planning\Invoke-AssetRiskAssessment.ps1

**Purpose**: Classifies all subscription resources by risk level (Critical/High/Medium/Low) based on resource type, internet exposure, and data sensitivity tags. Produces a risk-prioritised list to guide which resources to protect first.

### Planning\Invoke-ROICalculation.ps1

**Purpose**: Calculates projected return on investment for Defender for Cloud deployment based on resource inventory, estimated breach costs, and compliance automation savings.

### Planning\Invoke-E5CoverageAnalysis.ps1

**Purpose**: Identifies which servers are covered by existing Microsoft 365 E5 or MDE Plan 2 licences, distinguishing servers that would benefit from Defender for Servers Plan 2 (MDE bundled) versus those already covered.

### Planning\Invoke-DCUCommitmentPlanning.ps1

**Purpose**: Models Defender Credit Unit (DCU) commitment tiers against projected resource growth to identify the optimal multi-year commitment discount level.

---

## Troubleshooting

Diagnostic and connectivity validation scripts.

### Troubleshooting\Test-DefenderDiagnostics.ps1

**Purpose**: Performs comprehensive diagnostics across Defender for Cloud components — agent deployment status, network connectivity to required endpoints, policy compliance, and API authentication.

**Key parameters**: `-SubscriptionId`, `-VirtualMachineName` (optional, for VM-specific diagnostics), `-TestConnectivity`, `-TestPolicyCompliance`, `-TestAPIAuthentication`, `-CollectLogs`, `-OutputPath`, `-Remediate`

**Usage**:
```powershell
.\Troubleshooting\Test-DefenderDiagnostics.ps1 `
    -SubscriptionId '<subscription-id>' `
    -TestConnectivity `
    -TestPolicyCompliance `
    -OutputPath 'C:\Temp\DefenderDiagnostics'
```

### Troubleshooting\Invoke-DefenderAPIWithRetry.ps1

**Purpose**: Wrapper for Defender for Cloud REST API calls with exponential backoff retry logic, rate limiting handling, and detailed request/response logging. Useful for bulk operations or automation scripts that encounter transient API throttling.

**Key parameters**: `-Uri`, `-Method`, `-Body`, `-MaxRetries`, `-InitialRetryDelay`, `-EnableDetailedLogging`, `-OutputFormat`

---

## Tutorials

Prerequisite validation and configuration utilities for getting started.

### Tutorials\Test-DefenderPrerequisites.ps1

**Purpose**: Validates all prerequisites before deploying Defender for Cloud — checks module versions, Azure permissions, network connectivity to required endpoints, and Log Analytics workspace availability.

### Tutorials\Initialize-DefenderFoundation.ps1

**Purpose**: Interactive guided setup that walks through enabling Foundational CSPM, selecting Defender plans, configuring auto-provisioning, and adding the first compliance standard.

### Tutorials\Export-DefenderConfiguration.ps1

**Purpose**: Exports the current Defender for Cloud configuration (enabled plans, auto-provisioning settings, workflow automations, notification settings) to a JSON file for documentation or configuration drift detection.

---

## Related Resources

- [Azure PowerShell (Az module) — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps)
- [Az.Security PowerShell module — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/az.security/)
- [Defender for Cloud REST API — Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/securitycenter/)
- [API and Automation Reference](../reference-api-and-automation.md)
- [Getting Started how-to](../how-to-getting-started.md)
