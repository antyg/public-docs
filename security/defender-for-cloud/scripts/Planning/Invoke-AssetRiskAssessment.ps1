#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Performs risk-based asset assessment for strategic Defender for Cloud resource allocation.

.DESCRIPTION
    This script evaluates assets based on multiple risk factors to prioritize protection
    investments and optimize budget allocation for Defender for Cloud deployment.
    Uses threat-based scoring to justify protection levels and timeline planning.

.PARAMETER SubscriptionIds
    Array of Azure subscription IDs to assess

.PARAMETER AssetInventoryPath
    Path to existing asset inventory JSON file (optional)

.PARAMETER RiskWeighting
    Custom risk weighting factors for scoring calculation

.PARAMETER OutputPath
    Directory path for exported assessment results (default: current directory)

.EXAMPLE
    .\Invoke-AssetRiskAssessment.ps1 -SubscriptionIds @("sub1", "sub2")

.EXAMPLE
    .\Invoke-AssetRiskAssessment.ps1 -AssetInventoryPath ".\inventory.json" -OutputPath "C:\Risk Assessment"

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Az PowerShell modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$SubscriptionIds = @(),

    [Parameter(Mandatory = $false)]
    [string]$AssetInventoryPath,

    [Parameter(Mandatory = $false)]
    [hashtable]$RiskWeighting = @{},

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

# Set error action preference
$ErrorActionPreference = 'Continue'

# Default risk weighting factors
$defaultRiskWeighting = @{
    AssetType = @{
        "VirtualMachine" = 2
        "Database" = 4
        "Container" = 3
        "Storage" = 3
        "Network" = 2
        "KeyVault" = 4
        "AppService" = 3
    }
    DataClassification = @{
        "CUI" = 5          # Controlled Unclassified Information
        "PII" = 4          # Personally Identifiable Information
        "Internal" = 2     # Internal use only
        "Public" = 1       # Public information
        "Unknown" = 3      # Default for unclassified
    }
    ExposureLevel = @{
        "Internet" = 5     # Internet-facing resources
        "Intranet" = 3     # Internal network access
        "Isolated" = 1     # Isolated/air-gapped
        "DMZ" = 4          # Demilitarized zone
        "Unknown" = 3      # Default assumption
    }
    BusinessCriticality = @{
        "Critical" = 5     # Mission-critical systems
        "Important" = 3    # Important business functions
        "Standard" = 2     # Standard business operations
        "Low" = 1          # Low business impact
        "Unknown" = 2      # Default assumption
    }
}

# Merge custom risk weighting with defaults
if ($RiskWeighting.Count -gt 0) {
    foreach ($category in $RiskWeighting.Keys) {
        if ($defaultRiskWeighting.ContainsKey($category)) {
            foreach ($factor in $RiskWeighting[$category].Keys) {
                $defaultRiskWeighting[$category][$factor] = $RiskWeighting[$category][$factor]
            }
        }
    }
}

# Initialize assessment results
$riskAssessment = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    AssetInventory = @()
    RiskScoring = @()
    ProtectionMatrix = @()
    BudgetAllocation = @{}
    Recommendations = @()
    Metadata = @{
        RiskWeighting = $defaultRiskWeighting
        AssessmentCriteria = "NIST Risk Management Framework"
    }
}

function Get-AssetRiskScore {
    param(
        [string]$AssetType,
        [string]$DataClassification = "Unknown",
        [string]$ExposureLevel = "Unknown",
        [string]$BusinessCriticality = "Unknown"
    )
    
    $weights = $defaultRiskWeighting
    
    $assetScore = $weights.AssetType[$AssetType] ?? 2
    $dataScore = $weights.DataClassification[$DataClassification] ?? 3
    $exposureScore = $weights.ExposureLevel[$ExposureLevel] ?? 3
    $criticalityScore = $weights.BusinessCriticality[$BusinessCriticality] ?? 2
    
    # Calculate composite risk score
    $riskScore = $assetScore * $dataScore * $exposureScore * $criticalityScore
    
    $riskLevel = switch ($riskScore) {
        {$_ -ge 200} { "CRITICAL" }
        {$_ -ge 100} { "HIGH" }
        {$_ -ge 50} { "MEDIUM" }
        {$_ -ge 25} { "LOW" }
        default { "MINIMAL" }
    }
    
    return @{
        Score = $riskScore
        Level = $riskLevel
        Components = @{
            AssetType = $assetScore
            DataClassification = $dataScore
            ExposureLevel = $exposureScore
            BusinessCriticality = $criticalityScore
        }
    }
}

function Get-AssetInventoryFromAzure {
    param([string[]]$SubscriptionIds)
    
    $inventory = @()
    
    foreach ($subId in $SubscriptionIds) {
        try {
            Set-AzContext -SubscriptionId $subId -ErrorAction Stop
            Write-Host "Scanning subscription: $subId" -ForegroundColor Cyan
            
            # Virtual Machines
            $vms = Get-AzVM -ErrorAction SilentlyContinue
            foreach ($vm in $vms) {
                $tags = $vm.Tags ?? @{}
                $inventory += @{
                    SubscriptionId = $subId
                    ResourceType = "VirtualMachine"
                    Name = $vm.Name
                    ResourceGroup = $vm.ResourceGroupName
                    Location = $vm.Location
                    AssetType = "VirtualMachine"
                    DataClassification = $tags["DataClassification"] ?? "Unknown"
                    ExposureLevel = $tags["ExposureLevel"] ?? "Unknown"
                    BusinessCriticality = $tags["BusinessCriticality"] ?? "Unknown"
                    OSType = $vm.StorageProfile.OsDisk.OsType
                    Size = $vm.HardwareProfile.VmSize
                    Tags = $tags
                }
            }
            
            # SQL Servers
            $sqlServers = Get-AzSqlServer -ErrorAction SilentlyContinue
            foreach ($server in $sqlServers) {
                $tags = $server.Tags ?? @{}
                $inventory += @{
                    SubscriptionId = $subId
                    ResourceType = "Microsoft.Sql/servers"
                    Name = $server.ServerName
                    ResourceGroup = $server.ResourceGroupName
                    Location = $server.Location
                    AssetType = "Database"
                    DataClassification = $tags["DataClassification"] ?? "PII"  # Assume PII for databases
                    ExposureLevel = $tags["ExposureLevel"] ?? "Intranet"
                    BusinessCriticality = $tags["BusinessCriticality"] ?? "Important"
                    Version = $server.ServerVersion
                    Tags = $tags
                }
            }
            
            # Storage Accounts
            $storageAccounts = Get-AzStorageAccount -ErrorAction SilentlyContinue
            foreach ($storage in $storageAccounts) {
                $tags = $storage.Tags ?? @{}
                $inventory += @{
                    SubscriptionId = $subId
                    ResourceType = "Microsoft.Storage/storageAccounts"
                    Name = $storage.StorageAccountName
                    ResourceGroup = $storage.ResourceGroupName
                    Location = $storage.Location
                    AssetType = "Storage"
                    DataClassification = $tags["DataClassification"] ?? "Internal"
                    ExposureLevel = if ($storage.AllowBlobPublicAccess) { "Internet" } else { "Intranet" }
                    BusinessCriticality = $tags["BusinessCriticality"] ?? "Standard"
                    Kind = $storage.Kind
                    Tier = $storage.Sku.Tier
                    Tags = $tags
                }
            }
            
            # AKS Clusters
            $aksClusters = Get-AzAksCluster -ErrorAction SilentlyContinue
            foreach ($cluster in $aksClusters) {
                $tags = $cluster.Tags ?? @{}
                $inventory += @{
                    SubscriptionId = $subId
                    ResourceType = "Microsoft.ContainerService/managedClusters"
                    Name = $cluster.Name
                    ResourceGroup = $cluster.ResourceGroupName
                    Location = $cluster.Location
                    AssetType = "Container"
                    DataClassification = $tags["DataClassification"] ?? "Internal"
                    ExposureLevel = "Internet"  # Assume internet exposure for containers
                    BusinessCriticality = $tags["BusinessCriticality"] ?? "Important"
                    KubernetesVersion = $cluster.KubernetesVersion
                    Tags = $tags
                }
            }
            
            # Key Vaults
            $keyVaults = Get-AzKeyVault -ErrorAction SilentlyContinue
            foreach ($vault in $keyVaults) {
                $tags = $vault.Tags ?? @{}
                $inventory += @{
                    SubscriptionId = $subId
                    ResourceType = "Microsoft.KeyVault/vaults"
                    Name = $vault.VaultName
                    ResourceGroup = $vault.ResourceGroupName
                    Location = $vault.Location
                    AssetType = "KeyVault"
                    DataClassification = "CUI"  # Key vaults always handle sensitive data
                    ExposureLevel = $tags["ExposureLevel"] ?? "Intranet"
                    BusinessCriticality = "Critical"  # Key vaults are always critical
                    Tags = $tags
                }
            }
            
        } catch {
            Write-Warning "Failed to scan subscription $subId`: $($_.Exception.Message)"
        }
    }
    
    return $inventory
}

function Get-AssetInventoryFromFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        throw "Asset inventory file not found: $FilePath"
    }
    
    try {
        $inventoryData = Get-Content $FilePath -Raw | ConvertFrom-Json
        
        # Convert to standardized format if needed
        $inventory = @()
        foreach ($asset in $inventoryData) {
            $inventory += @{
                SubscriptionId = $asset.SubscriptionId ?? "Unknown"
                ResourceType = $asset.ResourceType ?? $asset.Type
                Name = $asset.Name
                ResourceGroup = $asset.ResourceGroup ?? $asset.ResourceGroupName
                Location = $asset.Location
                AssetType = $asset.AssetType ?? "Unknown"
                DataClassification = $asset.DataClassification ?? "Unknown"
                ExposureLevel = $asset.ExposureLevel ?? "Unknown"
                BusinessCriticality = $asset.BusinessCriticality ?? "Unknown"
                Tags = $asset.Tags ?? @{}
            }
        }
        
        return $inventory
    } catch {
        throw "Failed to load asset inventory from file: $($_.Exception.Message)"
    }
}

function Get-ProtectionRecommendation {
    param([int]$RiskScore, [string]$AssetType)
    
    $recommendation = switch ($RiskScore) {
        {$_ -ge 200} {
            @{
                ProtectionLevel = "Defender Plan 2 + Premium CSPM"
                Timeline = "Week 1"
                Justification = "Critical/CUI + Internet exposure requires maximum protection"
                Priority = "IMMEDIATE"
                Cost = "High"
            }
        }
        {$_ -ge 100} {
            @{
                ProtectionLevel = "Defender Plan 2"
                Timeline = "Month 1"
                Justification = "High business impact requires advanced protection"
                Priority = "HIGH"
                Cost = "Medium-High"
            }
        }
        {$_ -ge 50} {
            @{
                ProtectionLevel = "Defender Plan 1"
                Timeline = "Month 2-3"
                Justification = "Standard protection for medium-risk assets"
                Priority = "MEDIUM"
                Cost = "Medium"
            }
        }
        {$_ -ge 25} {
            @{
                ProtectionLevel = "Foundational CSPM"
                Timeline = "Month 4-6"
                Justification = "Basic monitoring for low-risk assets"
                Priority = "LOW"
                Cost = "Free"
            }
        }
        default {
            @{
                ProtectionLevel = "Risk Acceptance"
                Timeline = "TBD"
                Justification = "Document and monitor - consider decommissioning"
                Priority = "REVIEW"
                Cost = "None"
            }
        }
    }
    
    return $recommendation
}

function Generate-BudgetAllocation {
    param([array]$ScoredAssets)
    
    # Group assets by risk level
    $riskGroups = $ScoredAssets | Group-Object -Property RiskLevel
    
    $allocation = @{}
    $totalAssets = $ScoredAssets.Count
    
    foreach ($group in $riskGroups) {
        $count = $group.Count
        $percentage = [math]::Round(($count / $totalAssets) * 100, 1)
        
        $allocation[$group.Name] = @{
            AssetCount = $count
            Percentage = $percentage
            RecommendedBudgetShare = switch ($group.Name) {
                "CRITICAL" { 50 }  # 50% of budget for critical assets
                "HIGH" { 30 }      # 30% for high-risk assets
                "MEDIUM" { 15 }    # 15% for medium-risk assets
                "LOW" { 5 }        # 5% for low-risk assets
                "MINIMAL" { 0 }    # 0% - risk acceptance
            }
            EstimatedMonthlyCost = switch ($group.Name) {
                "CRITICAL" { $count * 18 }  # Plan 2 + Premium CSPM
                "HIGH" { $count * 15 }      # Plan 2
                "MEDIUM" { $count * 5 }     # Plan 1
                "LOW" { $count * 0 }        # Free CSPM
                "MINIMAL" { $count * 0 }    # No protection
            }
        }
    }
    
    return $allocation
}

# Main execution
Write-Host "Asset Risk Assessment for Defender for Cloud" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Step 1: Get asset inventory
Write-Host "Gathering asset inventory..." -ForegroundColor Yellow
if ($AssetInventoryPath) {
    Write-Host "Loading inventory from file: $AssetInventoryPath" -ForegroundColor Cyan
    $riskAssessment.AssetInventory = Get-AssetInventoryFromFile -FilePath $AssetInventoryPath
} elseif ($SubscriptionIds.Count -gt 0) {
    Write-Host "Scanning Azure subscriptions..." -ForegroundColor Cyan
    $riskAssessment.AssetInventory = Get-AssetInventoryFromAzure -SubscriptionIds $SubscriptionIds
} else {
    Write-Warning "No asset inventory source specified. Using sample data for demonstration."
    $riskAssessment.AssetInventory = @(
        @{
            Name = "web-server-prod"
            AssetType = "VirtualMachine"
            DataClassification = "CUI"
            ExposureLevel = "Internet"
            BusinessCriticality = "Critical"
            ResourceGroup = "rg-production"
        },
        @{
            Name = "sql-server-prod"
            AssetType = "Database"
            DataClassification = "PII"
            ExposureLevel = "Intranet"
            BusinessCriticality = "Critical"
            ResourceGroup = "rg-production"
        }
    )
}

# Step 2: Calculate risk scores
Write-Host "Calculating risk scores for $($riskAssessment.AssetInventory.Count) assets..." -ForegroundColor Yellow
foreach ($asset in $riskAssessment.AssetInventory) {
    $riskScore = Get-AssetRiskScore -AssetType $asset.AssetType -DataClassification $asset.DataClassification -ExposureLevel $asset.ExposureLevel -BusinessCriticality $asset.BusinessCriticality
    $protection = Get-ProtectionRecommendation -RiskScore $riskScore.Score -AssetType $asset.AssetType
    
    $scoredAsset = $asset.PSObject.Copy()
    $scoredAsset.RiskScore = $riskScore.Score
    $scoredAsset.RiskLevel = $riskScore.Level
    $scoredAsset.RiskComponents = $riskScore.Components
    $scoredAsset.RecommendedProtection = $protection.ProtectionLevel
    $scoredAsset.Priority = $protection.Priority
    $scoredAsset.Timeline = $protection.Timeline
    $scoredAsset.Justification = $protection.Justification
    
    $riskAssessment.RiskScoring += $scoredAsset
}

# Step 3: Generate protection matrix
Write-Host "Generating protection recommendations..." -ForegroundColor Yellow
$riskAssessment.ProtectionMatrix = $riskAssessment.RiskScoring | Sort-Object RiskScore -Descending

# Step 4: Calculate budget allocation
Write-Host "Calculating budget allocation strategy..." -ForegroundColor Yellow
$riskAssessment.BudgetAllocation = Generate-BudgetAllocation -ScoredAssets $riskAssessment.RiskScoring

# Step 5: Generate strategic recommendations
$criticalAssets = ($riskAssessment.RiskScoring | Where-Object {$_.RiskLevel -eq "CRITICAL"}).Count
$highRiskAssets = ($riskAssessment.RiskScoring | Where-Object {$_.RiskLevel -eq "HIGH"}).Count
$totalHighPriorityAssets = $criticalAssets + $highRiskAssets

$riskAssessment.Recommendations = @(
    "Immediate action required for $criticalAssets critical-risk assets",
    "Deploy Defender Plan 2 protection for $totalHighPriorityAssets high-priority assets within 30 days",
    "Allocate 80% of security budget to critical and high-risk assets",
    "Implement risk-based tagging strategy for automated protection deployment",
    "Establish quarterly risk assessment reviews to adjust protection levels"
)

if ($criticalAssets -eq 0) {
    $riskAssessment.Recommendations += "No critical-risk assets identified - review data classification accuracy"
}

# Display summary
Write-Host "`nRisk Assessment Summary:" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host "Total Assets Assessed: $($riskAssessment.AssetInventory.Count)" -ForegroundColor White

$riskDistribution = $riskAssessment.RiskScoring | Group-Object -Property RiskLevel
foreach ($group in $riskDistribution) {
    $color = switch ($group.Name) {
        "CRITICAL" { "Red" }
        "HIGH" { "Yellow" }
        "MEDIUM" { "Cyan" }
        "LOW" { "Green" }
        "MINIMAL" { "Gray" }
    }
    Write-Host "$($group.Name): $($group.Count) assets" -ForegroundColor $color
}

# Display top 5 highest risk assets
Write-Host "`nTop 5 Highest Risk Assets:" -ForegroundColor Yellow
$topRiskAssets = $riskAssessment.ProtectionMatrix | Select-Object -First 5
foreach ($asset in $topRiskAssets) {
    Write-Host "  • $($asset.Name) - Score: $($asset.RiskScore) ($($asset.RiskLevel))" -ForegroundColor White
    Write-Host "    Recommended: $($asset.RecommendedProtection) - $($asset.Timeline)" -ForegroundColor Gray
}

# Display recommendations
Write-Host "`nStrategic Recommendations:" -ForegroundColor Yellow
for ($i = 0; $i -lt $riskAssessment.Recommendations.Count; $i++) {
    Write-Host "  $($i + 1). $($riskAssessment.Recommendations[$i])" -ForegroundColor White
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = Join-Path $OutputPath "AssetRiskAssessment-$timestamp.json"
$matrixFile = Join-Path $OutputPath "ProtectionMatrix-$timestamp.csv"

try {
    # Export JSON report
    $riskAssessment | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nDetailed assessment exported to: $reportFile" -ForegroundColor Green
    
    # Export CSV protection matrix
    $riskAssessment.ProtectionMatrix | Select-Object Name, AssetType, RiskScore, RiskLevel, RecommendedProtection, Priority, Timeline, Justification | 
        Export-Csv -Path $matrixFile -NoTypeInformation -Encoding UTF8
    Write-Host "Protection matrix exported to: $matrixFile" -ForegroundColor Green
} catch {
    Write-Warning "Failed to export results: $($_.Exception.Message)"
}

Write-Host "`nAsset risk assessment completed successfully!" -ForegroundColor Green

return $riskAssessment