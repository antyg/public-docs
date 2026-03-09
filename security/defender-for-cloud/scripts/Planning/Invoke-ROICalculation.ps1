#requires -version 5.1

<#
.SYNOPSIS
    Calculates return on investment (ROI) for Microsoft Defender for Cloud implementation.

.DESCRIPTION
    This script performs comprehensive ROI analysis for Defender for Cloud investments,
    including security incident cost avoidance, operational efficiency gains, and compliance
    cost savings. Provides risk-adjusted calculations for government budget justification.

.PARAMETER AnnualDefenderCost
    Total annual cost of Defender for Cloud implementation

.PARAMETER OrganizationSize
    Size category of the organization (Small, Medium, Large, Enterprise)

.PARAMETER DataClassification
    Highest data classification handled (Public, Internal, PII, CUI)

.PARAMETER IndustryVertical
    Industry vertical for risk adjustment (Government, Healthcare, Financial, Education, Other)

.PARAMETER AnalysisPeriod
    Number of years for ROI analysis (default: 3)

.PARAMETER IncludeComplianceSavings
    Include compliance and audit cost avoidance in calculations

.PARAMETER OutputPath
    Directory path for exported ROI analysis (default: current directory)

.EXAMPLE
    .\Invoke-ROICalculation.ps1 -AnnualDefenderCost 75000 -OrganizationSize "Large" -DataClassification "CUI"

.EXAMPLE
    .\Invoke-ROICalculation.ps1 -AnnualDefenderCost 150000 -IndustryVertical "Government" -IncludeComplianceSavings

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+
    Based on IBM Cost of Data Breach Report 2024 and industry studies
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1000, 10000000)]
    [decimal]$AnnualDefenderCost,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Small", "Medium", "Large", "Enterprise")]
    [string]$OrganizationSize = "Medium",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Public", "Internal", "PII", "CUI")]
    [string]$DataClassification = "Internal",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Government", "Healthcare", "Financial", "Education", "Other")]
    [string]$IndustryVertical = "Government",

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 10)]
    [int]$AnalysisPeriod = 3,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeComplianceSavings,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Industry baseline data from security research
$securityBaselines = @{
    DataBreachCosts = @{
        "2024" = 4450000    # IBM Cost of Data Breach Report 2024 - Global average
        "Government" = 3780000
        "Healthcare" = 10930000
        "Financial" = 5900000
        "Education" = 3650000
        "Other" = 4450000
    }
    
    OrganizationMultipliers = @{
        "Small" = 0.6      # <500 employees
        "Medium" = 0.8     # 500-2000 employees
        "Large" = 1.0      # 2000-5000 employees
        "Enterprise" = 1.4 # >5000 employees
    }
    
    DataClassificationMultipliers = @{
        "Public" = 0.3     # Public information
        "Internal" = 0.7   # Internal use only
        "PII" = 1.2        # Personally identifiable information
        "CUI" = 1.8        # Controlled unclassified information
    }
    
    AnnualAttackProbability = @{
        "Government" = 0.31   # Higher target profile
        "Healthcare" = 0.28
        "Financial" = 0.26
        "Education" = 0.22
        "Other" = 0.23
    }
    
    DefenderEffectiveness = @{
        "PreventionRate" = 0.85     # 85% attack prevention rate
        "DetectionSpeed" = 0.75     # 75% faster mean time to detection
        "ResponseSpeed" = 0.60      # 60% faster mean time to response
        "FalsePositiveReduction" = 0.80  # 80% reduction in false positives
    }
}

# Compliance and operational savings
$complianceSavings = @{
    AuditPreparation = @{
        "Government" = 150000   # Annual audit preparation costs
        "Healthcare" = 200000
        "Financial" = 300000
        "Education" = 75000
        "Other" = 100000
    }
    
    ComplianceEfficiency = @{
        "AutomatedAssessment" = 0.70    # 70% automation of compliance checks
        "DocumentationReduction" = 0.60 # 60% reduction in manual documentation
        "ReportingEfficiency" = 0.80    # 80% improvement in compliance reporting
    }
    
    ToolConsolidation = @{
        "LegacyToolReplacement" = 120000  # Annual legacy security tool costs
        "VendorManagementSavings" = 25000 # Vendor relationship management
        "TrainingReduction" = 40000       # Reduced training on multiple platforms
    }
}

# Initialize ROI analysis results
$roiAnalysis = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    InputParameters = @{
        AnnualDefenderCost = $AnnualDefenderCost
        OrganizationSize = $OrganizationSize
        DataClassification = $DataClassification
        IndustryVertical = $IndustryVertical
        AnalysisPeriod = $AnalysisPeriod
        IncludeComplianceSavings = $IncludeComplianceSavings.IsPresent
    }
    RiskAssessment = @{}
    CostAvoidance = @{}
    ComplianceValue = @{}
    TotalROI = @{}
    Scenarios = @{}
    Recommendations = @()
}

function Get-RiskAdjustedBreachCost {
    param([string]$Industry, [string]$OrgSize, [string]$DataClass)
    
    $baseCost = $securityBaselines.DataBreachCosts[$Industry]
    $orgMultiplier = $securityBaselines.OrganizationMultipliers[$OrgSize]
    $dataMultiplier = $securityBaselines.DataClassificationMultipliers[$DataClass]
    
    $adjustedCost = $baseCost * $orgMultiplier * $dataMultiplier
    
    return @{
        BaseCost = $baseCost
        OrganizationMultiplier = $orgMultiplier
        DataClassificationMultiplier = $dataMultiplier
        AdjustedCost = $adjustedCost
    }
}

function Get-SecurityIncidentPrevention {
    param([decimal]$BreachCost, [string]$Industry)
    
    $attackProbability = $securityBaselines.AnnualAttackProbability[$Industry]
    $preventionRate = $securityBaselines.DefenderEffectiveness.PreventionRate
    
    $expectedAnnualLoss = $BreachCost * $attackProbability
    $protectedLoss = $expectedAnnualLoss * $preventionRate
    
    return @{
        AttackProbability = $attackProbability
        ExpectedAnnualLoss = $expectedAnnualLoss
        PreventionRate = $preventionRate
        ProtectedLoss = $protectedLoss
        NetSecurityValue = $protectedLoss
    }
}

function Get-OperationalEfficiencyGains {
    param([decimal]$DefenderCost)
    
    # SOC operational improvements
    $socStaffingCost = 450000  # Annual cost for 3 FTE security analysts
    $efficiencyImprovements = @{
        "ReducedFalsePositives" = $socStaffingCost * 0.25  # 25% time savings
        "FasterIncidentResponse" = $socStaffingCost * 0.15  # 15% time savings
        "AutomatedThreatHunting" = $socStaffingCost * 0.20  # 20% time savings
    }
    
    $totalEfficiencyValue = ($efficiencyImprovements.Values | Measure-Object -Sum).Sum
    
    return @{
        SOCStaffingBaseline = $socStaffingCost
        EfficiencyGains = $efficiencyImprovements
        TotalEfficiencyValue = $totalEfficiencyValue
        EfficiencyROI = ($totalEfficiencyValue / $DefenderCost) * 100
    }
}

function Get-ComplianceAndAuditSavings {
    param([string]$Industry, [bool]$IncludeSavings)
    
    if (-not $IncludeSavings) {
        return @{
            Enabled = $false
            TotalSavings = 0
        }
    }
    
    $auditCosts = $complianceSavings.AuditPreparation[$Industry]
    $automationSavings = $auditCosts * $complianceSavings.ComplianceEfficiency.AutomatedAssessment
    $documentationSavings = $auditCosts * $complianceSavings.ComplianceEfficiency.DocumentationReduction * 0.5  # Conservative estimate
    $toolConsolidationSavings = $complianceSavings.ToolConsolidation.LegacyToolReplacement
    
    $totalComplianceSavings = $automationSavings + $documentationSavings + $toolConsolidationSavings
    
    return @{
        Enabled = $true
        AuditPreparationBaseline = $auditCosts
        AutomationSavings = $automationSavings
        DocumentationSavings = $documentationSavings
        ToolConsolidationSavings = $toolConsolidationSavings
        TotalSavings = $totalComplianceSavings
    }
}

function Get-MultiyearROIProjection {
    param([hashtable]$AnnualBenefits, [decimal]$AnnualCost, [int]$Years)
    
    $projection = @{}
    $cumulativeInvestment = 0
    $cumulativeBenefits = 0
    $costGrowthRate = 1.05  # 5% annual cost growth
    $benefitGrowthRate = 1.08  # 8% annual benefit growth (improving security posture)
    
    for ($year = 1; $year -le $Years; $year++) {
        $yearlyInvestment = $AnnualCost * [math]::Pow($costGrowthRate, $year - 1)
        $yearlyBenefits = $AnnualBenefits.TotalAnnualValue * [math]::Pow($benefitGrowthRate, $year - 1)
        
        $cumulativeInvestment += $yearlyInvestment
        $cumulativeBenefits += $yearlyBenefits
        
        $netValue = $cumulativeBenefits - $cumulativeInvestment
        $roi = if ($cumulativeInvestment -gt 0) { 
            ($netValue / $cumulativeInvestment) * 100 
        } else { 
            0 
        }
        
        $projection["Year$year"] = @{
            Investment = $yearlyInvestment
            Benefits = $yearlyBenefits
            CumulativeInvestment = $cumulativeInvestment
            CumulativeBenefits = $cumulativeBenefits
            NetValue = $netValue
            ROI = [math]::Round($roi, 1)
            PaybackAchieved = $netValue -gt 0
        }
    }
    
    return $projection
}

function Generate-ROIScenarios {
    param([hashtable]$BaselineAnalysis)
    
    $scenarios = @{
        "Conservative" = @{
            Description = "Minimal security improvements"
            SecurityEffectivenessMultiplier = 0.6
            OperationalEfficiencyMultiplier = 0.5
            ComplianceEfficiencyMultiplier = 0.4
        }
        "Realistic" = @{
            Description = "Expected security improvements"
            SecurityEffectivenessMultiplier = 1.0
            OperationalEfficiencyMultiplier = 1.0
            ComplianceEfficiencyMultiplier = 1.0
        }
        "Optimistic" = @{
            Description = "Maximum security improvements"
            SecurityEffectivenessMultiplier = 1.3
            OperationalEfficiencyMultiplier = 1.5
            ComplianceEfficiencyMultiplier = 1.4
        }
    }
    
    $scenarioResults = @{}
    
    foreach ($scenarioName in $scenarios.Keys) {
        $scenario = $scenarios[$scenarioName]
        
        $adjustedSecurityValue = $BaselineAnalysis.SecurityValue * $scenario.SecurityEffectivenessMultiplier
        $adjustedOperationalValue = $BaselineAnalysis.OperationalValue * $scenario.OperationalEfficiencyMultiplier
        $adjustedComplianceValue = $BaselineAnalysis.ComplianceValue * $scenario.ComplianceEfficiencyMultiplier
        
        $totalAdjustedValue = $adjustedSecurityValue + $adjustedOperationalValue + $adjustedComplianceValue
        $scenarioROI = (($totalAdjustedValue - $AnnualDefenderCost) / $AnnualDefenderCost) * 100
        
        $scenarioResults[$scenarioName] = @{
            Description = $scenario.Description
            SecurityValue = $adjustedSecurityValue
            OperationalValue = $adjustedOperationalValue
            ComplianceValue = $adjustedComplianceValue
            TotalValue = $totalAdjustedValue
            NetValue = $totalAdjustedValue - $AnnualDefenderCost
            ROI = [math]::Round($scenarioROI, 1)
            PaybackPeriod = if ($totalAdjustedValue -gt $AnnualDefenderCost) {
                [math]::Round($AnnualDefenderCost / ($totalAdjustedValue - $AnnualDefenderCost) * 12, 1)
            } else {
                "No payback"
            }
        }
    }
    
    return $scenarioResults
}

# Main execution
Write-Host "Microsoft Defender for Cloud ROI Analysis" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Step 1: Risk assessment and breach cost calculation
Write-Host "Calculating risk-adjusted breach costs..." -ForegroundColor Yellow
$breachCostAnalysis = Get-RiskAdjustedBreachCost -Industry $IndustryVertical -OrgSize $OrganizationSize -DataClass $DataClassification
$roiAnalysis.RiskAssessment = $breachCostAnalysis

# Step 2: Security incident prevention value
Write-Host "Analyzing security incident prevention value..." -ForegroundColor Yellow
$securityPrevention = Get-SecurityIncidentPrevention -BreachCost $breachCostAnalysis.AdjustedCost -Industry $IndustryVertical
$roiAnalysis.CostAvoidance = $securityPrevention

# Step 3: Operational efficiency gains
Write-Host "Calculating operational efficiency gains..." -ForegroundColor Yellow
$operationalGains = Get-OperationalEfficiencyGains -DefenderCost $AnnualDefenderCost

# Step 4: Compliance and audit savings
Write-Host "Evaluating compliance cost savings..." -ForegroundColor Yellow
$complianceValue = Get-ComplianceAndAuditSavings -Industry $IndustryVertical -IncludeSavings $IncludeComplianceSavings.IsPresent
$roiAnalysis.ComplianceValue = $complianceValue

# Step 5: Compile total value and ROI
$totalAnnualValue = $securityPrevention.NetSecurityValue + $operationalGains.TotalEfficiencyValue + $complianceValue.TotalSavings
$netAnnualValue = $totalAnnualValue - $AnnualDefenderCost
$annualROI = ($netAnnualValue / $AnnualDefenderCost) * 100

$roiAnalysis.TotalROI = @{
    SecurityValue = $securityPrevention.NetSecurityValue
    OperationalValue = $operationalGains.TotalEfficiencyValue
    ComplianceValue = $complianceValue.TotalSavings
    TotalAnnualValue = $totalAnnualValue
    AnnualInvestment = $AnnualDefenderCost
    NetAnnualValue = $netAnnualValue
    AnnualROI = [math]::Round($annualROI, 1)
    PaybackPeriod = if ($netAnnualValue -gt 0) {
        [math]::Round($AnnualDefenderCost / $netAnnualValue * 12, 1)
    } else {
        "No payback"
    }
}

# Step 6: Multi-year projection
Write-Host "Generating multi-year ROI projection..." -ForegroundColor Yellow
$multiyearProjection = Get-MultiyearROIProjection -AnnualBenefits $roiAnalysis.TotalROI -AnnualCost $AnnualDefenderCost -Years $AnalysisPeriod

# Step 7: Scenario analysis
Write-Host "Performing scenario analysis..." -ForegroundColor Yellow
$roiAnalysis.Scenarios = Generate-ROIScenarios -BaselineAnalysis $roiAnalysis.TotalROI

# Generate recommendations
$roiAnalysis.Recommendations = @()

if ($annualROI -gt 100) {
    $roiAnalysis.Recommendations += "STRONG ROI: $([math]::Round($annualROI, 0))% annual return justifies immediate investment"
} elseif ($annualROI -gt 50) {
    $roiAnalysis.Recommendations += "POSITIVE ROI: $([math]::Round($annualROI, 0))% annual return supports investment case"
} else {
    $roiAnalysis.Recommendations += "MARGINAL ROI: $([math]::Round($annualROI, 0))% annual return - evaluate implementation scope"
}

$roiAnalysis.Recommendations += "Security incident prevention represents $([math]::Round(($securityPrevention.NetSecurityValue / $totalAnnualValue) * 100, 0))% of total value"

if ($IncludeComplianceSavings) {
    $roiAnalysis.Recommendations += "Compliance automation saves $$('{0:N0}' -f $complianceValue.TotalSavings) annually in audit costs"
}

$roiAnalysis.Recommendations += "SOC operational efficiency improvements worth $$('{0:N0}' -f $operationalGains.TotalEfficiencyValue) annually"
$roiAnalysis.Recommendations += "Payback period: $($roiAnalysis.TotalROI.PaybackPeriod) months"

if ($roiAnalysis.TotalROI.PaybackPeriod -ne "No payback" -and $roiAnalysis.TotalROI.PaybackPeriod -lt 24) {
    $roiAnalysis.Recommendations += "Excellent payback period supports budget justification"
}

# Display summary
Write-Host "`nROI Analysis Summary:" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host "Annual Investment: $$('{0:N0}' -f $AnnualDefenderCost)" -ForegroundColor White
Write-Host "Annual Value: $$('{0:N0}' -f $totalAnnualValue)" -ForegroundColor White
Write-Host "Net Annual Value: $$('{0:N0}' -f $netAnnualValue)" -ForegroundColor $(if ($netAnnualValue -gt 0) { "Green" } else { "Yellow" })
Write-Host "Annual ROI: $([math]::Round($annualROI, 1))%" -ForegroundColor $(if ($annualROI -gt 50) { "Green" } elseif ($annualROI -gt 0) { "Yellow" } else { "Red" })
Write-Host "Payback Period: $($roiAnalysis.TotalROI.PaybackPeriod) months" -ForegroundColor White

# Display value breakdown
Write-Host "`nValue Breakdown:" -ForegroundColor Yellow
Write-Host "Security Protection: $$('{0:N0}' -f $securityPrevention.NetSecurityValue) ($([math]::Round(($securityPrevention.NetSecurityValue / $totalAnnualValue) * 100, 1))%)" -ForegroundColor White
Write-Host "Operational Efficiency: $$('{0:N0}' -f $operationalGains.TotalEfficiencyValue) ($([math]::Round(($operationalGains.TotalEfficiencyValue / $totalAnnualValue) * 100, 1))%)" -ForegroundColor White
Write-Host "Compliance Savings: $$('{0:N0}' -f $complianceValue.TotalSavings) ($([math]::Round(($complianceValue.TotalSavings / $totalAnnualValue) * 100, 1))%)" -ForegroundColor White

# Display scenario analysis
Write-Host "`nScenario Analysis:" -ForegroundColor Yellow
foreach ($scenarioName in $roiAnalysis.Scenarios.Keys) {
    $scenario = $roiAnalysis.Scenarios[$scenarioName]
    Write-Host "$scenarioName`: ROI $($scenario.ROI)% - Net Value: $$('{0:N0}' -f $scenario.NetValue)" -ForegroundColor White
}

# Display multi-year projection
Write-Host "`nMulti-Year Projection:" -ForegroundColor Yellow
foreach ($yearKey in ($multiyearProjection.Keys | Sort-Object)) {
    $year = $multiyearProjection[$yearKey]
    $paybackStatus = if ($year.PaybackAchieved) { "✓" } else { "○" }
    Write-Host "$yearKey`: ROI $($year.ROI)% - Net Value: $$('{0:N0}' -f $year.NetValue) $paybackStatus" -ForegroundColor White
}

# Display recommendations
Write-Host "`nRecommendations:" -ForegroundColor Yellow
for ($i = 0; $i -lt $roiAnalysis.Recommendations.Count; $i++) {
    Write-Host "  $($i + 1). $($roiAnalysis.Recommendations[$i])" -ForegroundColor White
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = Join-Path $OutputPath "DefenderROIAnalysis-$timestamp.json"
$summaryFile = Join-Path $OutputPath "ROISummary-$timestamp.csv"

try {
    # Export JSON report
    $roiAnalysis | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nDetailed ROI analysis exported to: $reportFile" -ForegroundColor Green
    
    # Export CSV summary
    $csvData = [PSCustomObject]@{
        InvestmentAmount = $AnnualDefenderCost
        TotalAnnualValue = $totalAnnualValue
        NetAnnualValue = $netAnnualValue
        AnnualROI = [math]::Round($annualROI, 1)
        PaybackMonths = $roiAnalysis.TotalROI.PaybackPeriod
        SecurityValue = $securityPrevention.NetSecurityValue
        OperationalValue = $operationalGains.TotalEfficiencyValue
        ComplianceValue = $complianceValue.TotalSavings
        RecommendedAction = if ($annualROI -gt 50) { "Proceed with investment" } else { "Review scope" }
    }
    $csvData | Export-Csv -Path $summaryFile -NoTypeInformation -Encoding UTF8
    Write-Host "Summary exported to: $summaryFile" -ForegroundColor Green
} catch {
    Write-Warning "Failed to export results: $($_.Exception.Message)"
}

Write-Host "`nROI analysis completed successfully!" -ForegroundColor Green

return $roiAnalysis