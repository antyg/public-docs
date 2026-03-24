---
title: "Configuration — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Configuration — Microsoft Defender for Endpoint

## Overview

Configuration artefacts for Microsoft Defender for Endpoint (MDE) deployment, validation, and operational monitoring. This directory contains Azure Monitor workbook definitions, policy baselines, and other deployment configuration templates.

## Contents

| File | Type | Description |
|------|------|-------------|
| [MDE-Deployment-Validation-Workbook.json](MDE-Deployment-Validation-Workbook.json) | Azure Workbook | Comprehensive monitoring and reporting workbook for MDE deployment validation across an organisation |
| [MDE-Onboarding-Policy-Baseline.json](MDE-Onboarding-Policy-Baseline.json) | Policy Baseline | Recommended Intune/Group Policy settings for MDE onboarding configuration |

## MDE Deployment Validation Workbook

### Features

- **Executive Summary** — Total device count, onboarded count, compliance rate, visual KPIs
- **Device Inventory** — Searchable device list with onboarding status, OS details, Entra ID join status, MDE client version, export to Excel
- **Onboarding Status Analysis** — Distribution pie chart, breakdown by OS platform, priority list of devices ready for onboarding, unsupported devices
- **Health and Connectivity** — Active vs inactive distribution, communication frequency, inactive device alerts (>7 days), client version distribution
- **Troubleshooting and Diagnostics** — Communication gap detection, missing telemetry (SENSE service issues), network connectivity, Entra ID join status, remediation guidance
- **Trending and Analytics** — Onboarding progress over time, device discovery rate, onboarding velocity, OS platform growth trends, 30-day historical analysis

### Prerequisites

1. **Microsoft 365 Defender** with Advanced Hunting enabled
2. **Azure Log Analytics workspace** (optional, if streaming MDE data)
3. **Permissions:**
   - Security Reader (minimum)
   - Security Administrator or Global Reader (recommended)
   - Workbook Contributor (to deploy workbook)

### Deployment

> **Customisation Required**: The workbook JSON contains placeholder GitHub URLs (`your-org`) in the Quick Links section. Replace these with your organisation's actual repository URLs before deploying to Azure Monitor.

#### Deploy via Azure Portal (Recommended)

1. Navigate to **Azure Portal** > **Monitor** > **Workbooks**
2. Click **+ New** > **Advanced Editor** (`</>`)
3. Delete default JSON, paste contents of `MDE-Deployment-Validation-Workbook.json`
4. Click **Apply** > **Save**
5. Name: `MDE Deployment Validation`, Region: `australiaeast` or `australiasoutheast`

#### Deploy via PowerShell

```powershell
$SubscriptionId = "your-subscription-id"
$ResourceGroup = "your-resource-group"
$WorkbookName = "MDE-Deployment-Validation"
$Location = "australiaeast"
$WorkbookJsonPath = ".\MDE-Deployment-Validation-Workbook.json"

Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

$WorkbookContent = Get-Content -Path $WorkbookJsonPath -Raw

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateBody @"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Insights/workbooks",
      "apiVersion": "2021-03-08",
      "name": "[guid('$WorkbookName')]",
      "location": "$Location",
      "kind": "shared",
      "properties": {
        "displayName": "$WorkbookName",
        "serializedData": $(ConvertTo-Json $WorkbookContent),
        "category": "sentinel"
      }
    }
  ]
}
"@
```

#### Deploy via Azure CLI

```bash
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
WORKBOOK_NAME="MDE-Deployment-Validation"
LOCATION="australiaeast"
WORKBOOK_JSON_PATH="./MDE-Deployment-Validation-Workbook.json"

az account set --subscription $SUBSCRIPTION_ID

az monitor app-insights workbook create \
  --resource-group $RESOURCE_GROUP \
  --display-name "$WORKBOOK_NAME" \
  --serialized-data @$WORKBOOK_JSON_PATH \
  --kind shared \
  --location $LOCATION \
  --category sentinel
```

### Usage

1. Navigate to **Azure Portal** > **Monitor** > **Workbooks** > **Shared Workbooks**
2. Click **MDE Deployment Validation**
3. Use interactive filters: Time Range, Onboarding Status, OS Platform

### CSV Export via PowerShell

```powershell
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "your-tenant-id" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -OutputPath "C:\Reports\MDE-Status-$(Get-Date -Format 'yyyy-MM-dd').csv"
```

### KQL Query Reference

All queries use the Advanced Hunting schema:

| Table | Purpose |
|-------|---------|
| `DeviceInfo` | Device inventory, onboarding status, OS details, Entra ID join, MDE client version |
| `DeviceProcessEvents` | Process execution telemetry, sensor health detection |
| `DeviceNetworkInfo` | Network adapter information, IP addresses, connectivity status |

### Troubleshooting

| Issue | Cause | Resolution |
|-------|-------|------------|
| No data available | Advanced Hunting may lack data for selected time range | Verify devices onboarded, try "Last 30 days", check permissions |
| Queries timing out | Large dataset or complex query | Reduce time range, apply OS Platform filter, use PowerShell export for large datasets |
| Devices shown as "Can be onboarded" but actually onboarded | Synchronisation delay or duplicate entries | Wait 24 hours, check duplicates in Device Inventory, run `Get-MpComputerStatus` locally, refer to [reference-registry-service-reference.md](../reference-registry-service-reference.md) |

## MDE Onboarding Policy Baseline

Recommended Group Policy and Intune configuration settings for MDE onboarding. See [MDE-Onboarding-Policy-Baseline.json](MDE-Onboarding-Policy-Baseline.json) for the complete baseline definition.

## Integration with Validation Methods

| Validation Method | Config Artefact | Use Case |
|-------------------|-----------------|----------|
| [PowerShell validation](../tutorial-powershell-validation.md) | Workbook Health & Connectivity tab | Local device validation |
| [Graph API validation](../tutorial-graph-api-validation.md) | Workbook Device Inventory tab | Programmatic access |
| [Security Console validation](../how-to-console-validation.md) | All workbook tabs | Manual verification |
| [Registry/Service validation](../reference-registry-service-reference.md) | Workbook Troubleshooting tab | Definitive status checks |
| [Advanced Hunting KQL](../how-to-advanced-hunting-kql.md) | All workbook tabs | Data source |
| [MDE Client Analyzer](../reference-client-analyzer.md) | Workbook Troubleshooting tab | Deep diagnostics |

## Best Practices

1. **Review daily** — Check "Devices Ready for Onboarding" tab
2. **Monitor inactive devices** — Investigate devices with >7 days no communication
3. **Track compliance** — Maintain >95% onboarding rate
4. **Export monthly** — Keep historical records for compliance reporting
5. **Validate alerts** — Cross-reference with PowerShell local validation

## Related Sections

- [Validation Methods Overview](../explanation-validation-methods-overview.md) — Comparison of all 7 validation methods
- [PowerShell Validation Scripts](../scripts/README.md) — Automation scripts for MDE validation

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-17 | Initial release — Azure Workbook with 5 tabs and 20+ queries |
| 1.1.0 | 2026-03-23 | Migrated from `workbooks/` to `config/`; added onboarding policy baseline |
