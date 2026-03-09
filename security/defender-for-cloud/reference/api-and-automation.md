---
title: "API and Automation Reference: Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "reference"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# API and Automation Reference: Microsoft Defender for Cloud

---

## Overview

Microsoft Defender for Cloud exposes all its capabilities through the [Azure REST API](https://learn.microsoft.com/en-us/rest/api/securitycenter/), enabling programmatic access to security assessments, alerts, recommendations, compliance data, and plan configuration. This reference covers authentication, key API endpoints, Azure Policy integration, Logic Apps automation, and PowerShell module usage.

---

## Authentication

All Defender for Cloud API calls authenticate using [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/) tokens against the Azure Resource Manager endpoint (`https://management.azure.com`).

### Service Principal Authentication

```powershell
# Authenticate using a service principal (suitable for automation pipelines)
$tenantId     = '<your-tenant-id>'
$clientId     = '<service-principal-app-id>'
$clientSecret = '<service-principal-secret>'

$tokenBody = @{
    grant_type    = 'client_credentials'
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = 'https://management.azure.com/.default'
}

$tokenResponse = Invoke-RestMethod `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Method POST `
    -Body $tokenBody

$authHeader = @{ Authorization = "Bearer $($tokenResponse.access_token)" }
```

The service principal requires at minimum the **Security Reader** role for read-only operations or **Security Admin** for write operations (enabling plans, dismissing alerts).

### Azure PowerShell Authentication

```powershell
# For interactive or managed identity authentication
Connect-AzAccount

# Acquire token for REST API calls
$token = (Get-AzAccessToken -ResourceUrl 'https://management.azure.com').Token
$authHeader = @{ Authorization = "Bearer $token" }
```

---

## Key REST API Endpoints

The Defender for Cloud API namespace is `Microsoft.Security`. All endpoints follow the pattern:

```
https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Security/{resource}?api-version={version}
```

### Secure Score

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Secure Score for subscription | GET | `/subscriptions/{id}/providers/Microsoft.Security/secureScores/ascScore` |
| List all Secure Score controls | GET | `/subscriptions/{id}/providers/Microsoft.Security/secureScoreControls` |

```powershell
$subscriptionId = '<subscription-id>'
$apiVersion     = '2020-01-01'

$secureScore = Invoke-RestMethod `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/secureScores/ascScore?api-version=$apiVersion" `
    -Headers $authHeader

Write-Output "Current score: $($secureScore.properties.score.current) / $($secureScore.properties.score.max)"
```

### Security Assessments (Recommendations)

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List all assessments | GET | `/subscriptions/{id}/providers/Microsoft.Security/assessments` |
| Get single assessment | GET | `/subscriptions/{id}/providers/Microsoft.Security/assessments/{assessmentName}` |

```powershell
$assessments = Invoke-RestMethod `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/assessments?api-version=2021-06-01" `
    -Headers $authHeader

# Filter to unhealthy assessments only
$unhealthy = $assessments.value | Where-Object { $_.properties.status.code -eq 'Unhealthy' }
Write-Output "Unhealthy recommendations: $($unhealthy.Count)"
```

### Security Alerts

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List all alerts | GET | `/subscriptions/{id}/providers/Microsoft.Security/alerts` |
| Dismiss an alert | POST | `/subscriptions/{id}/providers/Microsoft.Security/alerts/{alertName}/dismiss` |
| Update alert status | PUT | `/subscriptions/{id}/providers/Microsoft.Security/alerts/{alertName}` |

```powershell
$alerts = Invoke-RestMethod `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/alerts?api-version=2022-01-01" `
    -Headers $authHeader

$highSeverity = $alerts.value | Where-Object { $_.properties.severity -eq 'High' }
Write-Output "Active High severity alerts: $($highSeverity.Count)"
```

### Defender Plan Configuration

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List current plan pricing | GET | `/subscriptions/{id}/providers/Microsoft.Security/pricings` |
| Get pricing for a specific plan | GET | `/subscriptions/{id}/providers/Microsoft.Security/pricings/{planName}` |
| Enable a Defender plan | PUT | `/subscriptions/{id}/providers/Microsoft.Security/pricings/{planName}` |

Valid `{planName}` values: `VirtualMachines`, `SqlServers`, `AppServices`, `StorageAccounts`, `Containers`, `KeyVaults`, `Arm`, `Dns`, `OpenSourceRelationalDatabases`, `CosmosDbs`.

```powershell
# Enable Defender for Storage
$body = @{ properties = @{ pricingTier = 'Standard' } } | ConvertTo-Json

Invoke-RestMethod `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/pricings/StorageAccounts?api-version=2023-01-01" `
    -Method PUT `
    -Headers ($authHeader + @{ 'Content-Type' = 'application/json' }) `
    -Body $body
```

### Regulatory Compliance

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List compliance standards | GET | `/subscriptions/{id}/providers/Microsoft.Security/regulatoryComplianceStandards` |
| Get compliance standard detail | GET | `/subscriptions/{id}/providers/Microsoft.Security/regulatoryComplianceStandards/{standardName}` |
| List controls for a standard | GET | `/subscriptions/{id}/providers/Microsoft.Security/regulatoryComplianceStandards/{standardName}/regulatoryComplianceControls` |

---

## Azure Policy Integration

[Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) is the enforcement layer beneath Defender for Cloud recommendations. Each recommendation corresponds to one or more Policy definitions.

### Assign the Microsoft Cloud Security Benchmark

The [Microsoft Cloud Security Benchmark (MCSB)](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction) policy initiative is the default assessment standard for Foundational CSPM. Assign it at management group scope for consistent coverage:

```powershell
# Assign MCSB at management group level
$initiative = Get-AzPolicySetDefinition | Where-Object {
    $_.Properties.displayName -eq 'Microsoft cloud security benchmark'
}

New-AzPolicyAssignment `
    -Name 'MCSB-Assignment' `
    -DisplayName 'Microsoft Cloud Security Benchmark' `
    -PolicySetDefinition $initiative `
    -Scope "/providers/Microsoft.Management/managementGroups/<mg-name>" `
    -EnforcementMode 'Default'
```

### Assign the Essential Eight Initiative

```powershell
# Find the Australian Government Essential Eight initiative
$e8Initiative = Get-AzPolicySetDefinition | Where-Object {
    $_.Properties.displayName -like '*Essential Eight*'
}

New-AzPolicyAssignment `
    -Name 'EssentialEight-Assessment' `
    -DisplayName 'ACSC Essential Eight Assessment' `
    -PolicySetDefinition $e8Initiative `
    -Scope "/subscriptions/<subscription-id>" `
    -EnforcementMode 'DoNotEnforce'  # Audit only — does not block deployments
```

### Custom Policy Initiative — Government Baseline

The [`configuration/azure-policy-initiatives.json`](../configuration/azure-policy-initiatives.json) file contains a custom policy initiative definition (`DefenderForCloudGovernmentBaseline`) that bundles 14 policy definitions across 8 control groups:

| Control Group | Policies | Effect |
|--------------|----------|--------|
| WorkloadProtection | Defender for Servers (P2), SQL, Storage, Containers | DeployIfNotExists |
| Monitoring | Azure Monitor Agent, Log Analytics workspace | DeployIfNotExists |
| DataProtection | Encryption in transit, encryption at rest | Audit / AuditIfNotExists |
| IdentityAndAccess | MFA for administrators | AuditIfNotExists |
| NetworkSecurity | NSGs, public network access, private endpoints | Audit / AuditIfNotExists |
| VulnerabilityManagement | Vulnerability assessment | AuditIfNotExists |
| IncidentResponse | Security contacts | DeployIfNotExists |
| AutoProvisioning | Automatic agent provisioning | DeployIfNotExists |

The initiative includes compliance control mappings for FedRAMP High, NIST SP 800-53, NIST SP 800-171, and CJIS. Assign it using:

```powershell
# Deploy custom government baseline initiative
$initiativeJson = Get-Content '../configuration/azure-policy-initiatives.json' -Raw
$initiative = New-AzPolicySetDefinition `
    -Name 'DefenderForCloudGovernmentBaseline' `
    -DisplayName 'Microsoft Defender for Cloud - Government Baseline' `
    -PolicyDefinition ($initiativeJson | ConvertFrom-Json).properties.policyDefinitions `
    -Parameter ($initiativeJson | ConvertFrom-Json).properties.parameters `
    -ManagementGroupName '<mg-name>'
```

---

## Logic Apps Automation

[Workflow automation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/workflow-automation) connects Defender for Cloud alerts and recommendations to Azure Logic Apps for automated response.

### Built-in Trigger: Defender for Cloud Alert

The Logic Apps connector for Defender for Cloud exposes a **When a Microsoft Defender for Cloud alert is created or triggered** trigger. Use this to build notification or response workflows:

1. In Logic Apps Designer, add trigger: **Microsoft Defender for Cloud** > **When a Microsoft Defender for Cloud alert is created or triggered**
2. Add action: **Send an email (V2)** (Office 365 Outlook connector) — include alert name, severity, affected resource, and description
3. Optionally add conditional branching: if `Severity == High`, also post to a Teams channel

### Register the Logic App in Defender for Cloud

1. In Defender for Cloud > **Environment settings** > **Workflow automation** > **Add workflow automation**
2. Set:
   - **Trigger conditions**: Alert severity = High (or as appropriate)
   - **Logic App**: select the Logic App you created
3. Select **Save**

---

## PowerShell: Az.Security Module

The [Az.Security](https://learn.microsoft.com/en-us/powershell/module/az.security/) module provides PowerShell cmdlets for Defender for Cloud.

| Cmdlet | Purpose |
|--------|---------|
| `Get-AzSecurityPricing` | List current Defender plan pricing tier per plan |
| `Set-AzSecurityPricing` | Enable or disable a Defender plan |
| `Get-AzSecurityAlert` | List security alerts |
| `Set-AzSecurityAlert` | Dismiss or update alert status |
| `Get-AzSecurityTask` | List security recommendations (tasks) |
| `Get-AzSecurityAssessment` | Get assessment results |
| `Get-AzSecurityCompliance` | Get compliance data |
| `Get-AzSecureScore` | Get Secure Score |

```powershell
# Install the module if not present
Install-Module -Name Az.Security -Scope CurrentUser

# List all Defender plan states
Get-AzSecurityPricing | Select-Object Name, PricingTier |
    Sort-Object PricingTier -Descending

# Enable Defender for Key Vault
Set-AzSecurityPricing -Name 'KeyVaults' -PricingTier 'Standard'

# Export all High severity alerts to CSV
Get-AzSecurityAlert |
    Where-Object { $_.AlertSeverity -eq 'High' } |
    Select-Object AlertDisplayName, AlertSeverity, TimeGeneratedUtc, CompromisedEntity |
    Export-Csv -Path './high-alerts.csv' -NoTypeInformation
```

---

## Related Resources

- [Defender for Cloud REST API reference — Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/securitycenter/)
- [Az.Security PowerShell module — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/az.security/)
- [Workflow automation (Logic Apps) — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/workflow-automation)
- [Azure Policy overview — Microsoft Learn](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Continuous export — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/continuous-export)
- [Microsoft Cloud Security Benchmark — Microsoft Learn](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
