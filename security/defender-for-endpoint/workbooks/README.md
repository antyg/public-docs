---
title: "MDE Deployment Validation Workbook"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# MDE Deployment Validation Workbook

## Overview

This Azure Workbook provides comprehensive monitoring and reporting for Microsoft Defender for Endpoint (MDE) deployment validation across your organisation.

## Features

### Executive Summary

- Total device count with real-time metrics
- Onboarded device count and compliance rate
- Devices ready for onboarding
- Visual KPIs with colour-coded status

### Device Inventory

- Complete searchable device list
- Onboarding status with visual indicators
- OS platform, version, and build information
- Azure AD join status
- MDE client version tracking
- Last seen timestamps
- Export to Excel capability

### Onboarding Status Analysis

- Distribution pie chart (Onboarded / Can be onboarded / Unsupported)
- Breakdown by OS platform
- Priority list of devices ready for onboarding
- Unsupported devices with reasons
- Days since discovery tracking

### Health and Connectivity

- Active vs inactive device distribution
- Communication frequency analysis
- Inactive devices list (>7 days no communication)
- MDE client version distribution
- Health status trending

### Troubleshooting and Diagnostics

- Devices with communication gaps
- Missing telemetry detection (SENSE service issues)
- Network connectivity status
- Azure AD join status distribution
- Built-in remediation guidance with documentation links

### Trending and Analytics

- Onboarding progress over time
- Device discovery rate (new devices per day)
- Onboarding velocity (devices onboarded per day)
- OS platform growth trends
- 30-day historical analysis

## Installation

### Prerequisites

1. **Microsoft 365 Defender** with Advanced Hunting enabled
2. **Azure Log Analytics workspace** (optional, if streaming MDE data)
3. **Permissions:**
   - Security Reader (minimum)
   - Security Administrator or Global Reader (recommended)
   - Workbook Contributor (to deploy workbook)

### Deployment Steps

> **Customisation Required**: The workbook JSON contains placeholder GitHub URLs (`your-org`) in the Quick Links section. Replace these with your organisation's actual repository URLs before deploying to Azure Monitor.

#### Option 1: Deploy via Azure Portal (Recommended)

1. Navigate to **Azure Portal** > **Monitor** > **Workbooks**
2. Click **+ New**
3. Click **Advanced Editor** (`</>` icon in toolbar)
4. Delete default JSON
5. Copy contents of `MDE-Deployment-Validation-Workbook.json`
6. Paste into editor
7. Click **Apply**
8. Click **Save**
   - Name: `MDE Deployment Validation`
   - Location: Select subscription and resource group
   - Region: `australiaeast` or `australiasoutheast`
9. Click **Save** to confirm

#### Option 2: Deploy via PowerShell

```powershell
# Set variables
$SubscriptionId = "your-subscription-id"
$ResourceGroup = "your-resource-group"
$WorkbookName = "MDE-Deployment-Validation"
$Location = "australiaeast"
$WorkbookJsonPath = ".\MDE-Deployment-Validation-Workbook.json"

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Read workbook JSON
$WorkbookContent = Get-Content -Path $WorkbookJsonPath -Raw

# Create workbook resource
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

#### Option 3: Deploy via Azure CLI

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
WORKBOOK_NAME="MDE-Deployment-Validation"
LOCATION="australiaeast"
WORKBOOK_JSON_PATH="./MDE-Deployment-Validation-Workbook.json"

# Set subscription
az account set --subscription $SUBSCRIPTION_ID

# Deploy workbook (requires application-insights CLI extension)
# Install if needed: az extension add --name application-insights
az monitor app-insights workbook create \
  --resource-group $RESOURCE_GROUP \
  --display-name "$WORKBOOK_NAME" \
  --serialized-data @$WORKBOOK_JSON_PATH \
  --kind shared \
  --location $LOCATION \
  --category sentinel
```

## Usage

### Accessing the Workbook

1. Navigate to **Azure Portal** > **Monitor** > **Workbooks**
2. Select **Shared Workbooks** tab
3. Click **MDE Deployment Validation**

### Using Interactive Filters

**Time Range:**

- Select: Last 1 hour, 24 hours, 7 days, or 30 days (default)
- Custom ranges supported

**Onboarding Status Filter:**

- Filter by: Onboarded, Can be onboarded, Unsupported, Insufficient Info
- Multi-select supported
- Default: All statuses

**OS Platform Filter:**

- Filter by: Windows 10, Windows 11, Windows Server, etc.
- Multi-select supported
- Default: All platforms

### Exporting Data

**Excel Export:**

1. Navigate to any data grid
2. Click **Export to Excel** button in grid toolbar
3. File downloads automatically with current filters applied

**CSV Export via PowerShell:**

```powershell
# Use the Export-MDEInventoryFromGraph.ps1 script
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "your-tenant-id" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret" `
    -OutputPath "C:\Reports\MDE-Status-$(Get-Date -Format 'yyyy-MM-dd').csv"
```

## KQL Query Reference

All queries in this workbook are based on the Advanced Hunting schema. Key tables used:

### DeviceInfo

- Device inventory and onboarding status
- OS platform and version information
- Azure AD join status
- MDE client version

### DeviceProcessEvents

- Process execution telemetry
- Used to detect sensor health (devices reporting telemetry)

### DeviceNetworkInfo

- Network adapter information
- IP address assignments
- Connectivity status

## Troubleshooting

### Issue: "No data available"

**Cause:** Advanced Hunting may not have data for selected time range

**Resolution:**

1. Verify devices are onboarded and reporting to MDE
2. Check selected time range (try "Last 30 days")
3. Ensure you have permissions to query Advanced Hunting
4. Verify filters are not excluding all data

### Issue: Queries timing out

**Cause:** Large dataset or complex query

**Resolution:**

1. Reduce time range to last 7 days
2. Apply OS Platform filter to reduce scope
3. Export data via PowerShell scripts for large datasets

### Issue: Devices shown as "Can be onboarded" but are actually onboarded

**Cause:** Synchronisation delay or duplicate device entries

**Resolution:**

1. Wait 24 hours for synchronisation
2. Check for duplicate device entries in Device Inventory tab
3. Run PowerShell validation: `Get-MpComputerStatus` locally on device
4. Refer to [Method 4: Registry/Service Validation](../reference/registry-service-reference.md)

## Integration with Validation Methods

This workbook complements the documented validation methods:

| Validation Method | Workbook Tab | Use Case |
|-------------------|--------------|----------|
| [Method 1: PowerShell](../tutorials/powershell-validation.md) | Health & Connectivity | Local device validation |
| [Method 2: Graph API](../tutorials/graph-api-validation.md) | Device Inventory | Programmatic access |
| [Method 3: Security Console](../how-to/console-validation.md) | All tabs | Manual verification |
| [Method 4: Registry/Service](../reference/registry-service-reference.md) | Troubleshooting | Definitive status checks |
| [Method 5: Advanced Hunting KQL](../how-to/advanced-hunting-kql.md) | All tabs | Data source |
| [Method 6: MDE Client Analyzer](../reference/client-analyzer.md) | Troubleshooting | Deep diagnostics |

## Maintenance

### Updating the Workbook

1. Open workbook in Azure Portal
2. Click **Edit** in toolbar
3. Click **Advanced Editor** (`</>`)
4. Make changes to JSON
5. Click **Apply**
6. Click **Done Editing**
7. Click **Save**

### Version Control

Store workbook JSON in source control:

```bash
git add security/defender-for-endpoint/workbooks/MDE-Deployment-Validation-Workbook.json
git commit -m "docs(mde): update MDE workbook with new queries"
git push
```

## Scheduled Reports

### Option 1: Logic App Integration

Create Logic App to:

1. Run Advanced Hunting queries on schedule
2. Export results to Excel/CSV
3. Email to distribution list

### Option 2: PowerShell Automation

```powershell
# Schedule via Task Scheduler to run daily
$TenantId = "your-tenant-id"
$ClientId = "your-client-id"
$ClientSecret = Get-SecretFromVault

# Run export script
..\scripts\Export-MDEInventoryFromGraph.ps1 `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientSecret $ClientSecret `
    -OutputPath "\\fileserver\reports\MDE-Daily-$(Get-Date -Format 'yyyy-MM-dd').csv"

# Email report
Send-MailMessage `
    -From "mde-reports@contoso.com" `
    -To "security-team@contoso.com" `
    -Subject "MDE Daily Status Report - $(Get-Date -Format 'yyyy-MM-dd')" `
    -Attachments "\\fileserver\reports\MDE-Daily-$(Get-Date -Format 'yyyy-MM-dd').csv" `
    -SmtpServer "smtp.contoso.com"
```

## Best Practices

1. **Review daily** — Check "Devices Ready for Onboarding" tab
2. **Monitor inactive devices** — Investigate devices with >7 days no communication
3. **Track compliance** — Maintain >95% onboarding rate
4. **Export monthly** — Keep historical records for compliance reporting
5. **Validate alerts** — Cross-reference with PowerShell local validation
6. **Update filters** — Adjust time ranges based on organisational change velocity

## Support

**Documentation:**

- [Validation Methods Overview](../explanation/validation-methods-overview.md)
- [PowerShell Validation Scripts](../scripts/README.md)

**Issues:**

- Report workbook issues in repository
- For MDE service issues, contact Microsoft Support

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-17 | Initial release with 5 tabs and 20+ queries |
