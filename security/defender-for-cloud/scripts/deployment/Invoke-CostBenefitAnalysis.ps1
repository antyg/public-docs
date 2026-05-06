#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Calculates cost-benefit analysis and ROI for Microsoft Defender for Cloud deployment.

.DESCRIPTION
    This script analyzes discovered infrastructure and calculates the cost implications
    of enabling various Defender for Cloud plans. It provides recommendations for
    cost optimization through DCU commitments and tiered protection strategies.

.PARAMETER DiscoveryResultsPath
    Path to the infrastructure discovery JSON file

.PARAMETER OrganizationBudget
    Annual security budget for cost optimization calculations

.PARAMETER EnvironmentMapping
    Hashtable mapping resource groups to environments (Production, Development, etc.)

.PARAMETER OutputPath
    Directory path for exported cost analysis (default: current directory)

.EXAMPLE
    .\Invoke-CostBenefitAnalysis.ps1 -DiscoveryResultsPath ".\discovery.json" -OrganizationBudget 150000

.EXAMPLE
    .\Invoke-CostBenefitAnalysis.ps1 -DiscoveryResultsPath ".\discovery.json" -OrganizationBudget 150000 -EnvironmentMapping @{"rg-prod" = "Production"; "rg-dev" = "Development"}

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Infrastructure discovery results
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DiscoveryResultsPath,

    [Parameter(Mandatory = $true)]
    [int]$OrganizationBudget,

    [Parameter(Mandatory = $false)]
    [hashtable]$EnvironmentMapping = @{},

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Validate input file
if (-not (Test-Path $DiscoveryResultsPath)) {
    throw "Discovery results file not found: $DiscoveryResultsPath"
}

# Load discovery results
try {
    $discoveryResults = Get-Content $DiscoveryResultsPath -Raw | ConvertFrom-Json
    Write-Host "Loaded discovery results from: $DiscoveryResultsPath" -ForegroundColor Green
} catch {
    throw "Failed to load discovery results: $($_.Exception.Message)"
}

# Define pricing tiers (monthly costs in USD)
$defenderPricing = @{
    Servers = @{
        Plan1 = 5
        Plan2 = 15
    }
    SQL = @{
        Servers = 15
        VirtualMachines = 15
    }
    Storage = @{
        BaseRate = 10
        PerGBScanned = 0.15
    }
    Containers = @{
        PerVCore = 7
    }
    AppServices = @{
        PerInstance = 15
    }
    KeyVault = @{
        PerVault = 1
    }
    CloudPosture = @{
        Free = 0  # Foundational CSPM
        Premium = 3  # Premium CSPM
    }
}

# DCU discount tiers
$dcuDiscounts = @{
    50000 = 0.10   # 10% discount for $50K+ commitment
    100000 = 0.15  # 15% discount for $100K+ commitment
    350000 = 0.22  # 22% discount for $350K+ commitment
}

function Get-ResourceEnvironment {
    param([string]$ResourceGroup)
    
    # Check explicit mapping first
    if ($EnvironmentMapping.ContainsKey($ResourceGroup)) {
        return $EnvironmentMapping[$ResourceGroup]
    }
    
    # Infer from naming patterns
    $rgLower = $ResourceGroup.ToLower()
    if ($rgLower -match "prod|production") { return "Production" }
    if ($rgLower -match "dev|development") { return "Development" }
    if ($rgLower -match "test|testing|qa") { return "Testing" }
    if ($rgLower -match "sandbox|sbx|demo") { return "Sandbox" }
    
    return "Unknown"
}

function Get-RecommendedPlan {
    param([string]$Environment, [string]$ResourceType)
    
    switch ($Environment) {
        "Production" {
            switch ($ResourceType) {
                "VirtualMachine" { return "Plan2" }
                "SQL" { return "Standard" }
                "Storage" { return "Standard" }
                "Container" { return "Standard" }
                "AppService" { return "Standard" }
                "KeyVault" { return "Standard" }
                default { return "CSPM" }
            }
        }
        "Development" {
            switch ($ResourceType) {
                "VirtualMachine" { return "Plan1" }
                "SQL" { return "Standard" }
                "Storage" { return "Free" }
                "Container" { return "Standard" }
                "AppService" { return "Free" }
                "KeyVault" { return "Free" }
                default { return "CSPM" }
            }
        }
        "Testing" {
            switch ($ResourceType) {
                "VirtualMachine" { return "Plan1" }
                "SQL" { return "Free" }
                "Storage" { return "Free" }
                "Container" { return "Free" }
                "AppService" { return "Free" }
                "KeyVault" { return "Free" }
                default { return "CSPM" }
            }
        }
        default {
            return "CSPM"  # Sandbox and Unknown get minimal protection
        }
    }
}

function Calculate-DefenderCosts {
    param([object]$DiscoveryData)
    
    $costBreakdown = @{
        ByEnvironment = @{}
        ByResourceType = @{}
        Total = @{
            Monthly = 0
            Annual = 0
        }
        ResourceCounts = @{}
        Recommendations = @()
    }
    
    $environments = @("Production", "Development", "Testing", "Sandbox", "Unknown")
    foreach ($env in $environments) {
        $costBreakdown.ByEnvironment[$env] = @{
            Monthly = 0
            Annual = 0
            Resources = @{}
        }
    }
    
    # Process Azure resources
    foreach ($subscriptionId in $DiscoveryData.Azure.PSObject.Properties.Name) {
        $subscription = $DiscoveryData.Azure.$subscriptionId
        
        # Virtual Machines
        foreach ($vm in $subscription.VirtualMachines) {
            $environment = Get-ResourceEnvironment -ResourceGroup $vm.ResourceGroup
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "VirtualMachine"
            
            $monthlyCost = 0
            if ($recommendedPlan -eq "Plan2") {
                $monthlyCost = $defenderPricing.Servers.Plan2
            } elseif ($recommendedPlan -eq "Plan1") {
                $monthlyCost = $defenderPricing.Servers.Plan1
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["VirtualMachines"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["VirtualMachines"] ?? 0) + 1
        }
        
        # SQL Servers
        foreach ($sql in $subscription.SqlServers) {
            $environment = Get-ResourceEnvironment -ResourceGroup $sql.ResourceGroup
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "SQL"
            
            $monthlyCost = 0
            if ($recommendedPlan -eq "Standard") {
                $monthlyCost = $defenderPricing.SQL.Servers
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["SQLServers"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["SQLServers"] ?? 0) + 1
        }
        
        # Storage Accounts
        foreach ($storage in $subscription.StorageAccounts) {
            $environment = Get-ResourceEnvironment -ResourceGroup $storage.ResourceGroup
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "Storage"
            
            $monthlyCost = 0
            if ($recommendedPlan -eq "Standard") {
                $monthlyCost = $defenderPricing.Storage.BaseRate
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["StorageAccounts"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["StorageAccounts"] ?? 0) + 1
        }
        
        # AKS Clusters
        foreach ($aks in $subscription.KubernetesClusters) {
            $environment = Get-ResourceEnvironment -ResourceGroup $aks.ResourceGroup
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "Container"
            
            $monthlyCost = 0
            if ($recommendedPlan -eq "Standard") {
                # Estimate 4 vCores per cluster as baseline
                $estimatedVCores = 4
                $monthlyCost = $estimatedVCores * $defenderPricing.Containers.PerVCore
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["AKSClusters"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["AKSClusters"] ?? 0) + 1
        }
        
        # Key Vaults
        foreach ($kv in $subscription.KeyVaults) {
            $environment = Get-ResourceEnvironment -ResourceGroup $kv.ResourceGroup
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "KeyVault"
            
            $monthlyCost = 0
            if ($recommendedPlan -eq "Standard") {
                $monthlyCost = $defenderPricing.KeyVault.PerVault
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["KeyVaults"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["KeyVaults"] ?? 0) + 1
        }
    }
    
    # Process AWS resources (if available)
    if ($DiscoveryData.AWS -and $DiscoveryData.AWS.EC2Instances) {
        foreach ($ec2 in $DiscoveryData.AWS.EC2Instances) {
            $environment = "Production"  # Assume production for AWS resources unless tagged otherwise
            if ($ec2.Tags.Environment) {
                $environment = $ec2.Tags.Environment
            }
            
            $recommendedPlan = Get-RecommendedPlan -Environment $environment -ResourceType "VirtualMachine"
            $monthlyCost = 0
            if ($recommendedPlan -eq "Plan2") {
                $monthlyCost = $defenderPricing.Servers.Plan2
            } elseif ($recommendedPlan -eq "Plan1") {
                $monthlyCost = $defenderPricing.Servers.Plan1
            }
            
            $costBreakdown.ByEnvironment[$environment].Monthly += $monthlyCost
            $costBreakdown.ByEnvironment[$environment].Resources["AWSEC2Instances"] = 
                ($costBreakdown.ByEnvironment[$environment].Resources["AWSEC2Instances"] ?? 0) + 1
        }
    }
    
    # Calculate annual costs
    foreach ($environment in $costBreakdown.ByEnvironment.Keys) {
        $costBreakdown.ByEnvironment[$environment].Annual = $costBreakdown.ByEnvironment[$environment].Monthly * 12
        $costBreakdown.Total.Monthly += $costBreakdown.ByEnvironment[$environment].Monthly
    }
    $costBreakdown.Total.Annual = $costBreakdown.Total.Monthly * 12
    
    return $costBreakdown
}

function Calculate-DCUOptimization {
    param([int]$AnnualCost, [int]$Budget)
    
    $optimization = @{
        RecommendedCommitment = 0
        DiscountRate = 0
        AnnualSavings = 0
        NetAnnualCost = 0
        BudgetUtilization = 0
        ROI = 0
        Recommendations = @()
    }
    
    # Find the best DCU discount tier
    $dcuCommitment = [math]::Ceiling($AnnualCost / 1000) * 1000  # Round up to nearest 1K
    
    $bestDiscountRate = 0
    foreach ($tier in $dcuDiscounts.Keys | Sort-Object -Descending) {
        if ($dcuCommitment -ge $tier) {
            $bestDiscountRate = $dcuDiscounts[$tier]
            break
        }
    }
    
    $optimization.RecommendedCommitment = $dcuCommitment
    $optimization.DiscountRate = $bestDiscountRate
    $optimization.AnnualSavings = $AnnualCost * $bestDiscountRate
    $optimization.NetAnnualCost = $AnnualCost - $optimization.AnnualSavings
    $optimization.BudgetUtilization = [math]::Round(($optimization.NetAnnualCost / $Budget) * 100, 2)
    
    # Calculate ROI based on security value
    $estimatedSecurityValue = $AnnualCost * 3  # Conservative 3:1 security ROI
    $optimization.ROI = [math]::Round((($estimatedSecurityValue - $optimization.NetAnnualCost) / $optimization.NetAnnualCost) * 100, 2)
    
    # Generate recommendations
    if ($optimization.BudgetUtilization -gt 100) {
        $optimization.Recommendations += "Annual cost exceeds budget by $([math]::Round($optimization.NetAnnualCost - $Budget, 0)). Consider tiered deployment or phased rollout."
    }
    
    if ($optimization.DiscountRate -eq 0) {
        $optimization.Recommendations += "Consider increasing commitment to reach DCU discount tiers."
    }
    
    if ($optimization.BudgetUtilization -lt 80) {
        $optimization.Recommendations += "Budget allows for additional security investments or premium features."
    }
    
    return $optimization
}

function Generate-CostReport {
    param([object]$CostAnalysis, [object]$Optimization)
    
    $report = @{
        Executive_Summary = @{
            TotalAnnualCost = $CostAnalysis.Total.Annual
            NetAnnualCost = $Optimization.NetAnnualCost
            BudgetUtilization = "$($Optimization.BudgetUtilization)%"
            EstimatedROI = "$($Optimization.ROI)%"
            RecommendedAction = if ($Optimization.BudgetUtilization -le 100) { "Proceed with deployment" } else { "Revise scope or increase budget" }
        }
        Cost_Breakdown = @{
            ByEnvironment = $CostAnalysis.ByEnvironment
            MonthlyTotal = $CostAnalysis.Total.Monthly
            AnnualTotal = $CostAnalysis.Total.Annual
        }
        Optimization_Strategy = @{
            DCUCommitment = $Optimization.RecommendedCommitment
            DiscountRate = "$($Optimization.DiscountRate * 100)%"
            AnnualSavings = $Optimization.AnnualSavings
            Recommendations = $Optimization.Recommendations
        }
        Risk_Assessment = @{
            OverBudgetRisk = if ($Optimization.BudgetUtilization -gt 100) { "High" } else { "Low" }
            ROIConfidence = if ($Optimization.ROI -gt 200) { "High" } else { "Medium" }
            Implementation_Complexity = "Medium"
        }
    }
    
    return $report
}

# Main execution
Write-Host "Microsoft Defender for Cloud Cost-Benefit Analysis" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Calculate costs
Write-Host "Analyzing infrastructure costs..." -ForegroundColor Yellow
$costAnalysis = Calculate-DefenderCosts -DiscoveryData $discoveryResults

# Calculate DCU optimization
Write-Host "Calculating DCU optimization..." -ForegroundColor Yellow
$optimization = Calculate-DCUOptimization -AnnualCost $costAnalysis.Total.Annual -Budget $OrganizationBudget

# Generate comprehensive report
$costReport = Generate-CostReport -CostAnalysis $costAnalysis -Optimization $optimization

# Display summary
Write-Host "`nCost Analysis Summary:" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host "Annual Cost (before discounts): $$('{0:N0}' -f $costAnalysis.Total.Annual)" -ForegroundColor White
Write-Host "Recommended DCU Commitment: $$('{0:N0}' -f $optimization.RecommendedCommitment)" -ForegroundColor White
Write-Host "Discount Rate: $($optimization.DiscountRate * 100)%" -ForegroundColor White
Write-Host "Annual Savings: $$('{0:N0}' -f $optimization.AnnualSavings)" -ForegroundColor Cyan
Write-Host "Net Annual Cost: $$('{0:N0}' -f $optimization.NetAnnualCost)" -ForegroundColor Green
Write-Host "Budget Utilization: $($optimization.BudgetUtilization)%" -ForegroundColor $(if ($optimization.BudgetUtilization -le 100) { "Green" } else { "Red" })
Write-Host "Estimated ROI: $($optimization.ROI)%" -ForegroundColor Green

# Environment breakdown
Write-Host "`nCost by Environment:" -ForegroundColor Yellow
foreach ($env in $costAnalysis.ByEnvironment.Keys) {
    if ($costAnalysis.ByEnvironment[$env].Annual -gt 0) {
        Write-Host "  $env`: $$('{0:N0}' -f $costAnalysis.ByEnvironment[$env].Annual) annually" -ForegroundColor White
    }
}

# Recommendations
if ($optimization.Recommendations.Count -gt 0) {
    Write-Host "`nRecommendations:" -ForegroundColor Yellow
    foreach ($recommendation in $optimization.Recommendations) {
        Write-Host "  • $recommendation" -ForegroundColor White
    }
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = Join-Path $OutputPath "DefenderCostAnalysis-$timestamp.json"
$csvFile = Join-Path $OutputPath "DefenderCostSummary-$timestamp.csv"

try {
    # Export JSON report
    $costReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nDetailed report exported to: $reportFile" -ForegroundColor Green
    
    # Export CSV summary
    $csvData = @()
    foreach ($env in $costAnalysis.ByEnvironment.Keys) {
        if ($costAnalysis.ByEnvironment[$env].Annual -gt 0) {
            $csvData += [PSCustomObject]@{
                Environment = $env
                MonthlyOst = $costAnalysis.ByEnvironment[$env].Monthly
                AnnualCost = $costAnalysis.ByEnvironment[$env].Annual
                ResourceCount = ($costAnalysis.ByEnvironment[$env].Resources.Values | Measure-Object -Sum).Sum
            }
        }
    }
    $csvData | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    Write-Host "CSV summary exported to: $csvFile" -ForegroundColor Green
} catch {
    Write-Warning "Failed to export reports: $($_.Exception.Message)"
}

Write-Host "`nCost-benefit analysis completed successfully!" -ForegroundColor Green

return $costReport