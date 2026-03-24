#requires -version 5.1

<#
.SYNOPSIS
    Calculates optimal Defender Credit Unit (DCU) commitment levels for budget planning and discount optimization.

.DESCRIPTION
    This script analyzes projected Defender for Cloud costs to recommend optimal DCU pre-purchase
    commitments that maximize government discount opportunities and provide predictable annual budgeting.
    Supports multi-year planning and commitment scenario analysis.

.PARAMETER ProductionServers
    Number of production servers requiring protection

.PARAMETER DevelopmentServers
    Number of development/test servers requiring protection

.PARAMETER SqlDatabases
    Number of SQL databases requiring protection

.PARAMETER StorageAccounts
    Number of storage accounts requiring protection

.PARAMETER ContainerClusters
    Number of container clusters requiring protection

.PARAMETER PlanLevel
    Default protection plan level (Plan1, Plan2)

.PARAMETER AnalysisPeriod
    Number of years to analyze for commitment planning (default: 3)

.PARAMETER OutputPath
    Directory path for exported planning results (default: current directory)

.EXAMPLE
    .\Invoke-DCUCommitmentPlanning.ps1 -ProductionServers 100 -DevelopmentServers 50 -SqlDatabases 25

.EXAMPLE
    .\Invoke-DCUCommitmentPlanning.ps1 -ProductionServers 200 -SqlDatabases 50 -AnalysisPeriod 5

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+
    Reference: https://learn.microsoft.com/en-us/azure/defender-for-cloud/prepurchase-plan
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 10000)]
    [int]$ProductionServers = 0,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 5000)]
    [int]$DevelopmentServers = 0,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 1000)]
    [int]$SqlDatabases = 0,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 500)]
    [int]$StorageAccounts = 0,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 100)]
    [int]$ContainerClusters = 0,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Plan1", "Plan2")]
    [string]$PlanLevel = "Plan2",

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 5)]
    [int]$AnalysisPeriod = 3,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# DCU pricing structure (monthly costs)
$dcuPricing = @{
    "Servers" = @{
        "Plan1" = 5    # $5 per server per month
        "Plan2" = 15   # $15 per server per month
    }
    "SQL" = 15         # $15 per database per month
    "Storage" = 10     # $10 base + $0.15 per GB scanned
    "Containers" = 7   # $7 per vCore per month (estimate 4 vCores per cluster)
    "Apps" = 24        # $24 per app per month
}

# DCU commitment discount tiers
$commitmentTiers = @(
    @{
        MinimumDCUs = 5000
        DiscountRate = 0.10
        Name = "5K Tier"
        AnnualCommitment = 5000
    },
    @{
        MinimumDCUs = 50000
        DiscountRate = 0.15
        Name = "50K Tier"
        AnnualCommitment = 50000
    },
    @{
        MinimumDCUs = 350000
        DiscountRate = 0.22
        Name = "350K Tier"
        AnnualCommitment = 350000
    }
)

# Initialize planning results
$dcuPlanning = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    InputParameters = @{
        ProductionServers = $ProductionServers
        DevelopmentServers = $DevelopmentServers
        SqlDatabases = $SqlDatabases
        StorageAccounts = $StorageAccounts
        ContainerClusters = $ContainerClusters
        PlanLevel = $PlanLevel
        AnalysisPeriod = $AnalysisPeriod
    }
    CostProjections = @{}
    CommitmentAnalysis = @{}
    Recommendations = @()
}

function Get-AnnualCostProjection {
    param(
        [int]$ProdServers,
        [int]$DevServers,
        [int]$Databases,
        [int]$Storage,
        [int]$Containers
    )
    
    # Calculate monthly costs
    $monthlyServers = ($ProdServers * $dcuPricing.Servers[$PlanLevel]) + 
                      ($DevServers * $dcuPricing.Servers["Plan1"])  # Dev servers use Plan 1
    $monthlySql = $Databases * $dcuPricing.SQL
    $monthlyStorage = $Storage * $dcuPricing.Storage
    $monthlyContainers = $Containers * $dcuPricing.Containers * 4  # Estimate 4 vCores per cluster
    
    $totalMonthlyCost = $monthlyServers + $monthlySql + $monthlyStorage + $monthlyContainers
    $totalAnnualCost = $totalMonthlyCost * 12
    
    return @{
        Monthly = @{
            Servers = $monthlyServers
            SQL = $monthlySql
            Storage = $monthlyStorage
            Containers = $monthlyContainers
            Total = $totalMonthlyCost
        }
        Annual = @{
            Servers = $monthlyServers * 12
            SQL = $monthlySql * 12
            Storage = $monthlyStorage * 12
            Containers = $monthlyContainers * 12
            Total = $totalAnnualCost
        }
        DCUEquivalent = [math]::Ceiling($totalAnnualCost / 1000) * 1000  # Round up to nearest 1K DCUs
    }
}

function Get-OptimalCommitmentTier {
    param([int]$ProjectedDCUs)
    
    $optimalTier = $null
    $maxSavings = 0
    
    foreach ($tier in $commitmentTiers) {
        if ($ProjectedDCUs -ge ($tier.AnnualCommitment * 0.8)) {  # 80% utilization threshold
            $potentialSavings = $tier.AnnualCommitment * $tier.DiscountRate
            if ($potentialSavings -gt $maxSavings) {
                $maxSavings = $potentialSavings
                $optimalTier = $tier
            }
        }
    }
    
    return $optimalTier
}

function Get-MultiyearProjection {
    param([hashtable]$BaselineCosts, [int]$Years)
    
    $projection = @{}
    $growthRate = 1.15  # Assume 15% annual growth in protected assets
    
    for ($year = 1; $year -le $Years; $year++) {
        $scaleFactor = [math]::Pow($growthRate, $year - 1)
        $yearlyCommitment = [math]::Ceiling($BaselineCosts.DCUEquivalent * $scaleFactor / 1000) * 1000
        
        $optimalTier = Get-OptimalCommitmentTier -ProjectedDCUs $yearlyCommitment
        
        $projection["Year$year"] = @{
            ProjectedDCUs = $yearlyCommitment
            OptimalTier = $optimalTier
            Savings = if ($optimalTier) { 
                $yearlyCommitment * $optimalTier.DiscountRate 
            } else { 
                0 
            }
            NetCost = if ($optimalTier) {
                $yearlyCommitment * (1 - $optimalTier.DiscountRate)
            } else {
                $yearlyCommitment
            }
        }
    }
    
    return $projection
}

function Get-GovernmentPricingAdjustment {
    param([hashtable]$Costs, [string]$CloudEnvironment = "Commercial")
    
    $premiumMultipliers = @{
        "Commercial" = 1.0
        "GCC" = 1.2         # 20% premium
        "GCCHigh" = 1.7     # 70% premium
    }
    
    $multiplier = $premiumMultipliers[$CloudEnvironment] ?? 1.0
    
    $adjustedCosts = @{}
    foreach ($key in $Costs.Keys) {
        if ($Costs[$key] -is [hashtable]) {
            $adjustedCosts[$key] = @{}
            foreach ($subKey in $Costs[$key].Keys) {
                $adjustedCosts[$key][$subKey] = $Costs[$key][$subKey] * $multiplier
            }
        } else {
            $adjustedCosts[$key] = $Costs[$key] * $multiplier
        }
    }
    
    return @{
        CloudEnvironment = $CloudEnvironment
        PremiumMultiplier = $multiplier
        AdjustedCosts = $adjustedCosts
    }
}

function Generate-BudgetScenarios {
    param([hashtable]$BaseCosts)
    
    $scenarios = @{
        "Conservative" = @{
            Description = "Minimal viable protection"
            ProductionMultiplier = 0.7
            DevelopmentMultiplier = 0.5
            DatabaseMultiplier = 0.8
        }
        "Recommended" = @{
            Description = "Balanced protection and cost"
            ProductionMultiplier = 1.0
            DevelopmentMultiplier = 1.0
            DatabaseMultiplier = 1.0
        }
        "Comprehensive" = @{
            Description = "Maximum protection coverage"
            ProductionMultiplier = 1.3
            DevelopmentMultiplier = 1.2
            DatabaseMultiplier = 1.2
        }
    }
    
    $scenarioResults = @{}
    
    foreach ($scenarioName in $scenarios.Keys) {
        $scenario = $scenarios[$scenarioName]
        
        $adjustedProd = [math]::Ceiling($ProductionServers * $scenario.ProductionMultiplier)
        $adjustedDev = [math]::Ceiling($DevelopmentServers * $scenario.DevelopmentMultiplier)
        $adjustedDb = [math]::Ceiling($SqlDatabases * $scenario.DatabaseMultiplier)
        
        $scenarioCosts = Get-AnnualCostProjection -ProdServers $adjustedProd -DevServers $adjustedDev -Databases $adjustedDb -Storage $StorageAccounts -Containers $ContainerClusters
        $optimalTier = Get-OptimalCommitmentTier -ProjectedDCUs $scenarioCosts.DCUEquivalent
        
        $scenarioResults[$scenarioName] = @{
            Description = $scenario.Description
            ProjectedDCUs = $scenarioCosts.DCUEquivalent
            AnnualCost = $scenarioCosts.Annual.Total
            OptimalTier = $optimalTier
            PotentialSavings = if ($optimalTier) { 
                $scenarioCosts.DCUEquivalent * $optimalTier.DiscountRate 
            } else { 
                0 
            }
            BreakEvenAnalysis = if ($optimalTier) {
                @{
                    CommitmentLevel = $optimalTier.AnnualCommitment
                    RequiredUtilization = [math]::Round(($scenarioCosts.DCUEquivalent / $optimalTier.AnnualCommitment) * 100, 1)
                    AnnualSavings = $scenarioCosts.DCUEquivalent * $optimalTier.DiscountRate
                }
            } else {
                $null
            }
        }
    }
    
    return $scenarioResults
}

# Main execution
Write-Host "DCU Commitment Planning Analysis" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Step 1: Calculate baseline cost projections
Write-Host "Calculating baseline cost projections..." -ForegroundColor Yellow
$dcuPlanning.CostProjections = Get-AnnualCostProjection -ProdServers $ProductionServers -DevServers $DevelopmentServers -Databases $SqlDatabases -Storage $StorageAccounts -Containers $ContainerClusters

# Step 2: Analyze commitment options
Write-Host "Analyzing DCU commitment options..." -ForegroundColor Yellow
$optimalTier = Get-OptimalCommitmentTier -ProjectedDCUs $dcuPlanning.CostProjections.DCUEquivalent

# Step 3: Multi-year projection
Write-Host "Generating multi-year projections..." -ForegroundColor Yellow
$multiyearProjection = Get-MultiyearProjection -BaselineCosts $dcuPlanning.CostProjections -Years $AnalysisPeriod

# Step 4: Government pricing scenarios
Write-Host "Calculating government pricing scenarios..." -ForegroundColor Yellow
$commercialPricing = Get-GovernmentPricingAdjustment -Costs $dcuPlanning.CostProjections -CloudEnvironment "Commercial"
$gccPricing = Get-GovernmentPricingAdjustment -Costs $dcuPlanning.CostProjections -CloudEnvironment "GCC"
$gccHighPricing = Get-GovernmentPricingAdjustment -Costs $dcuPlanning.CostProjections -CloudEnvironment "GCCHigh"

# Step 5: Budget scenarios
Write-Host "Generating budget scenarios..." -ForegroundColor Yellow
$budgetScenarios = Generate-BudgetScenarios -BaseCosts $dcuPlanning.CostProjections

# Compile results
$dcuPlanning.CommitmentAnalysis = @{
    BaselineProjection = $dcuPlanning.CostProjections
    OptimalTier = $optimalTier
    MultiyearProjection = $multiyearProjection
    GovernmentPricing = @{
        Commercial = $commercialPricing
        GCC = $gccPricing
        GCCHigh = $gccHighPricing
    }
    BudgetScenarios = $budgetScenarios
}

# Generate recommendations
$dcuPlanning.Recommendations = @()

if ($optimalTier) {
    $utilizationRate = [math]::Round(($dcuPlanning.CostProjections.DCUEquivalent / $optimalTier.AnnualCommitment) * 100, 1)
    $dcuPlanning.Recommendations += "Recommended: $($optimalTier.Name) commitment ($($optimalTier.AnnualCommitment) DCUs) with $($optimalTier.DiscountRate * 100)% discount"
    $dcuPlanning.Recommendations += "Projected utilization: $utilizationRate% (target: 80-120%)"
    $dcuPlanning.Recommendations += "Annual savings: $$('{0:N0}' -f ($dcuPlanning.CostProjections.DCUEquivalent * $optimalTier.DiscountRate))"
} else {
    $dcuPlanning.Recommendations += "Current projected usage ($($dcuPlanning.CostProjections.DCUEquivalent) DCUs) does not qualify for commitment discounts"
    $dcuPlanning.Recommendations += "Consider scaling protected assets to reach 5,000 DCU minimum for 10% discount"
}

$dcuPlanning.Recommendations += "Align DCU purchases with fiscal year appropriations for budget predictability"
$dcuPlanning.Recommendations += "Plan for 15% annual growth in protected assets"

if ($SqlDatabases -gt 0) {
    $dcuPlanning.Recommendations += "Database protection represents $([math]::Round(($dcuPlanning.CostProjections.Annual.SQL / $dcuPlanning.CostProjections.Annual.Total) * 100, 1))% of costs - prioritize high-value databases"
}

# Display summary
Write-Host "`nDCU Commitment Planning Summary:" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Projected Annual DCUs: $($dcuPlanning.CostProjections.DCUEquivalent)" -ForegroundColor White
Write-Host "Estimated Annual Cost: $$('{0:N0}' -f $dcuPlanning.CostProjections.Annual.Total)" -ForegroundColor White

if ($optimalTier) {
    Write-Host "Optimal Commitment: $($optimalTier.Name) - $($optimalTier.AnnualCommitment) DCUs" -ForegroundColor Cyan
    Write-Host "Discount Rate: $($optimalTier.DiscountRate * 100)%" -ForegroundColor Green
    Write-Host "Annual Savings: $$('{0:N0}' -f ($dcuPlanning.CostProjections.DCUEquivalent * $optimalTier.DiscountRate))" -ForegroundColor Green
} else {
    Write-Host "No commitment tier applicable - pay-as-you-go pricing" -ForegroundColor Yellow
}

# Display cost breakdown
Write-Host "`nCost Breakdown (Annual):" -ForegroundColor Yellow
Write-Host "Servers: $$('{0:N0}' -f $dcuPlanning.CostProjections.Annual.Servers)" -ForegroundColor White
Write-Host "Databases: $$('{0:N0}' -f $dcuPlanning.CostProjections.Annual.SQL)" -ForegroundColor White
Write-Host "Storage: $$('{0:N0}' -f $dcuPlanning.CostProjections.Annual.Storage)" -ForegroundColor White
Write-Host "Containers: $$('{0:N0}' -f $dcuPlanning.CostProjections.Annual.Containers)" -ForegroundColor White

# Display multi-year projection
Write-Host "`nMulti-Year Projection:" -ForegroundColor Yellow
foreach ($yearKey in ($multiyearProjection.Keys | Sort-Object)) {
    $year = $multiyearProjection[$yearKey]
    $tierName = if ($year.OptimalTier) { $year.OptimalTier.Name } else { "No Tier" }
    Write-Host "$yearKey`: $($year.ProjectedDCUs) DCUs - $tierName - Savings: $$('{0:N0}' -f $year.Savings)" -ForegroundColor White
}

# Display budget scenarios
Write-Host "`nBudget Scenarios:" -ForegroundColor Yellow
foreach ($scenarioName in $budgetScenarios.Keys) {
    $scenario = $budgetScenarios[$scenarioName]
    $tierName = if ($scenario.OptimalTier) { $scenario.OptimalTier.Name } else { "No Tier" }
    Write-Host "$scenarioName`: $($scenario.ProjectedDCUs) DCUs - $tierName - Savings: $$('{0:N0}' -f $scenario.PotentialSavings)" -ForegroundColor White
}

# Display recommendations
Write-Host "`nRecommendations:" -ForegroundColor Yellow
for ($i = 0; $i -lt $dcuPlanning.Recommendations.Count; $i++) {
    Write-Host "  $($i + 1). $($dcuPlanning.Recommendations[$i])" -ForegroundColor White
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = Join-Path $OutputPath "DCUCommitmentPlanning-$timestamp.json"
$summaryFile = Join-Path $OutputPath "DCUCommitmentSummary-$timestamp.csv"

try {
    # Export JSON report
    $dcuPlanning | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nDetailed planning report exported to: $reportFile" -ForegroundColor Green
    
    # Export CSV summary
    $csvData = [PSCustomObject]@{
        ProjectedDCUs = $dcuPlanning.CostProjections.DCUEquivalent
        AnnualCost = $dcuPlanning.CostProjections.Annual.Total
        OptimalTier = if ($optimalTier) { $optimalTier.Name } else { "None" }
        DiscountRate = if ($optimalTier) { $optimalTier.DiscountRate } else { 0 }
        PotentialSavings = if ($optimalTier) { $dcuPlanning.CostProjections.DCUEquivalent * $optimalTier.DiscountRate } else { 0 }
        RecommendedCommitment = if ($optimalTier) { $optimalTier.AnnualCommitment } else { 0 }
    }
    $csvData | Export-Csv -Path $summaryFile -NoTypeInformation -Encoding UTF8
    Write-Host "Summary exported to: $summaryFile" -ForegroundColor Green
} catch {
    Write-Warning "Failed to export results: $($_.Exception.Message)"
}

Write-Host "`nDCU commitment planning completed successfully!" -ForegroundColor Green

return $dcuPlanning