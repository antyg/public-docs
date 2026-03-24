#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Analyzes Microsoft 365 E5 security coverage and identifies protection gaps for Defender for Cloud planning.

.DESCRIPTION
    This script evaluates current Microsoft 365 E5 security coverage against cloud infrastructure
    requirements to identify gaps that require additional Defender for Cloud protection.
    Provides strategic recommendations for budget optimization and security tool consolidation.

.PARAMETER E5Users
    Number of Microsoft 365 E5 licensed users in the organization

.PARAMETER MaxDevicesPerUser
    Maximum devices per E5 user license (default: 5)

.PARAMETER CurrentProtectedDevices
    Number of devices currently protected by Defender for Endpoint

.PARAMETER IncludeToolRationalization
    Include analysis of tools that can be consolidated with E5 capabilities

.PARAMETER OutputPath
    Directory path for exported analysis results (default: current directory)

.EXAMPLE
    .\Invoke-E5CoverageAnalysis.ps1 -E5Users 1000 -CurrentProtectedDevices 3200

.EXAMPLE
    .\Invoke-E5CoverageAnalysis.ps1 -E5Users 500 -CurrentProtectedDevices 1800 -IncludeToolRationalization

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Az PowerShell modules for infrastructure assessment
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 100000)]
    [int]$E5Users,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 10)]
    [int]$MaxDevicesPerUser = 5,

    [Parameter(Mandatory = $false)]
    [int]$CurrentProtectedDevices = 0,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeToolRationalization,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "."
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Initialize analysis results
$coverageAnalysis = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    E5LicenseAnalysis = @{}
    CoverageGaps = @{}
    UtilizationMetrics = @{}
    CostOptimization = @{}
    Recommendations = @()
    ToolRationalization = @{}
}

function Get-E5SecurityCoverage {
    param([int]$UserCount)
    
    $e5Coverage = @{
        IncludedComponents = @{
            "Defender for Endpoint Plan 2" = @{
                Scope = "User workstations"
                Devices = $UserCount * $MaxDevicesPerUser
                Value = "Endpoint protection, EDR, threat hunting"
                Cost = "Included"
            }
            "Defender for Office 365 Plan 2" = @{
                Scope = "Email and collaboration"
                Protection = "Advanced threat protection, Safe Attachments, Safe Links"
                Value = "Email security, zero-day protection"
                Cost = "Included"
            }
            "Defender for Identity" = @{
                Scope = "On-premises Active Directory"
                Protection = "Identity compromise detection, lateral movement"
                Value = "Hybrid identity protection"
                Cost = "Included"
            }
            "Defender for Cloud Apps" = @{
                Scope = "Cloud applications and services"
                Protection = "CASB, data governance, app risk assessment"
                Value = "Cloud application security"
                Cost = "Included"
            }
            "Defender for Business" = @{
                Scope = "Small business (up to 300 employees)"
                Protection = "Basic endpoint and email protection"
                Value = "SMB security bundle"
                Cost = "Included if under 300 employees"
            }
        }
        
        ExcludedComponents = @{
            "Azure Virtual Machines" = @{
                Gap = "Server workload protection"
                RequiredSolution = "Defender for Servers Plan 1/2"
                EstimatedCost = "5-15 per server per month"
            }
            "Container Security" = @{
                Gap = "AKS, Arc-enabled Kubernetes protection"
                RequiredSolution = "Defender for Containers"
                EstimatedCost = "7 per vCore per month"
            }
            "Database Protection" = @{
                Gap = "Azure SQL, PostgreSQL, MySQL threat protection"
                RequiredSolution = "Defender for SQL"
                EstimatedCost = "15 per server per month"
            }
            "Storage Security" = @{
                Gap = "Storage account malware scanning, activity monitoring"
                RequiredSolution = "Defender for Storage"
                EstimatedCost = "10 per account + 0.15 per GB scanned"
            }
            "Multi-Cloud Protection" = @{
                Gap = "AWS EC2, GCP Compute Engine protection"
                RequiredSolution = "Cloud connectors + Defender plans"
                EstimatedCost = "Same as Azure pricing"
            }
        }
    }
    
    return $e5Coverage
}

function Get-DeviceUtilizationAnalysis {
    param([int]$UserCount, [int]$CurrentDevices)
    
    $totalAvailableDevices = $UserCount * $MaxDevicesPerUser
    $utilizationRate = if ($totalAvailableDevices -gt 0) { 
        ($CurrentDevices / $totalAvailableDevices) * 100 
    } else { 0 }
    $unutilizedCapacity = $totalAvailableDevices - $CurrentDevices
    
    # Calculate potential third-party license replacement value
    $avgEndpointSecurityCost = 4  # $4 per device per month for third-party solutions
    $potentialAnnualSavings = $unutilizedCapacity * $avgEndpointSecurityCost * 12
    
    $utilization = @{
        TotalAvailableDevices = $totalAvailableDevices
        CurrentlyProtectedDevices = $CurrentDevices
        UtilizationRate = [math]::Round($utilizationRate, 2)
        UnutilizedCapacity = $unutilizedCapacity
        PotentialAnnualSavings = $potentialAnnualSavings
        RecommendedActions = @()
    }
    
    # Generate recommendations
    if ($utilizationRate -lt 50) {
        $utilization.RecommendedActions += "CRITICAL: Only $([math]::Round($utilizationRate, 1))% of E5 endpoint protection utilized"
        $utilization.RecommendedActions += "Deploy E5 endpoint protection to all permitted devices immediately"
    } elseif ($utilizationRate -lt 80) {
        $utilization.RecommendedActions += "Opportunity to improve E5 utilization from $([math]::Round($utilizationRate, 1))% to 90%+"
        $utilization.RecommendedActions += "Audit and onboard remaining unprotected devices"
    } else {
        $utilization.RecommendedActions += "Good E5 device utilization at $([math]::Round($utilizationRate, 1))%"
    }
    
    if ($potentialAnnualSavings -gt 10000) {
        $utilization.RecommendedActions += "Potential to reallocate $$('{0:N0}' -f $potentialAnnualSavings) from third-party endpoint security to infrastructure protection"
    }
    
    return $utilization
}

function Get-ToolRationalizationAnalysis {
    if (-not $IncludeToolRationalization) {
        return @{}
    }
    
    $rationalization = @{
        ConsolidationOpportunities = @{
            "Email Security Gateway" = @{
                TypicalCost = 50000  # Annual cost
                E5Replacement = "Defender for Office 365 Plan 2"
                Action = "Migrate to included solution"
                Savings = 50000
                ImplementationEffort = "Medium"
                RiskLevel = "Low"
            }
            "CASB Solution" = @{
                TypicalCost = 30000
                E5Replacement = "Defender for Cloud Apps"
                Action = "Consolidate to E5 capability"
                Savings = 30000
                ImplementationEffort = "Low"
                RiskLevel = "Low"
            }
            "Identity Security" = @{
                TypicalCost = 25000
                E5Replacement = "Defender for Identity"
                Action = "Integrate with existing Active Directory"
                Savings = 25000
                ImplementationEffort = "Medium"
                RiskLevel = "Medium"
            }
            "Third-Party Endpoint Security" = @{
                TypicalCost = 40000  # For unutilized devices
                E5Replacement = "Defender for Endpoint Plan 2"
                Action = "Maximize E5 device allocation"
                Savings = 40000
                ImplementationEffort = "Low"
                RiskLevel = "Low"
            }
        }
        
        TotalAnnualSavings = 145000,
        RecommendedTimeframe = "6-12 months",
        AvailableForInfrastructureProtection = 145000
    }
    
    return $rationalization
}

function Get-InfrastructureGapAnalysis {
    try {
        # Attempt to get Azure infrastructure inventory if connected
        $context = Get-AzContext -ErrorAction SilentlyContinue
        if ($context) {
            $infrastructure = @{
                VirtualMachines = (Get-AzVM -ErrorAction SilentlyContinue).Count
                SqlServers = (Get-AzSqlServer -ErrorAction SilentlyContinue).Count
                StorageAccounts = (Get-AzStorageAccount -ErrorAction SilentlyContinue).Count
                AksClusters = (Get-AzAksCluster -ErrorAction SilentlyContinue).Count
            }
        } else {
            # Use estimated values if not connected to Azure
            $infrastructure = @{
                VirtualMachines = "Not assessed - Azure not connected"
                SqlServers = "Not assessed - Azure not connected"
                StorageAccounts = "Not assessed - Azure not connected"
                AksClusters = "Not assessed - Azure not connected"
            }
        }
    } catch {
        $infrastructure = @{
            VirtualMachines = "Error accessing Azure resources"
            SqlServers = "Error accessing Azure resources"
            StorageAccounts = "Error accessing Azure resources"
            AksClusters = "Error accessing Azure resources"
        }
    }
    
    $gaps = @{
        InfrastructureInventory = $infrastructure
        ProtectionGaps = @{
            "Server Workloads" = "Requires Defender for Servers - E5 only covers user endpoints"
            "Database Security" = "Requires Defender for SQL - No database protection in E5"
            "Container Security" = "Requires Defender for Containers - No container protection in E5"
            "Storage Protection" = "Requires Defender for Storage - No storage security in E5"
            "Multi-Cloud Assets" = "Requires cloud connectors - E5 limited to Microsoft services"
        }
        CriticalGaps = @()
    }
    
    # Identify critical gaps
    foreach ($gapType in $gaps.ProtectionGaps.Keys) {
        $gaps.CriticalGaps += "$gapType`: $($gaps.ProtectionGaps[$gapType])"
    }
    
    return $gaps
}

function Generate-CoverageReport {
    param([hashtable]$Analysis)
    
    $report = @{
        ExecutiveSummary = @{
            E5Users = $E5Users
            UtilizationRate = "$($Analysis.UtilizationMetrics.UtilizationRate)%"
            UnutilizedCapacity = $Analysis.UtilizationMetrics.UnutilizedCapacity
            PotentialSavings = $Analysis.UtilizationMetrics.PotentialAnnualSavings
            RecommendedAction = if ($Analysis.UtilizationMetrics.UtilizationRate -lt 80) { 
                "Maximize E5 utilization before additional investments" 
            } else { 
                "Good E5 utilization - proceed with infrastructure protection" 
            }
        }
        
        CoverageAnalysis = @{
            IncludedCapabilities = $Analysis.E5LicenseAnalysis.IncludedComponents
            ProtectionGaps = $Analysis.CoverageGaps.ProtectionGaps
            InfrastructureImpact = $Analysis.CoverageGaps.CriticalGaps
        }
        
        FinancialImpact = @{
            DeviceUtilizationSavings = $Analysis.UtilizationMetrics.PotentialAnnualSavings
            ToolConsolidationSavings = if ($Analysis.ToolRationalization.TotalAnnualSavings) { 
                $Analysis.ToolRationalization.TotalAnnualSavings 
            } else { 
                "Not calculated" 
            }
            AvailableBudget = if ($Analysis.ToolRationalization.AvailableForInfrastructureProtection) {
                $Analysis.ToolRationalization.AvailableForInfrastructureProtection
            } else {
                $Analysis.UtilizationMetrics.PotentialAnnualSavings
            }
        }
        
        StrategicRecommendations = $Analysis.Recommendations
    }
    
    return $report
}

# Main execution
Write-Host "Microsoft 365 E5 Coverage Analysis" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Step 1: Analyze E5 security coverage
Write-Host "Analyzing E5 security coverage..." -ForegroundColor Yellow
$coverageAnalysis.E5LicenseAnalysis = Get-E5SecurityCoverage -UserCount $E5Users

# Step 2: Analyze device utilization
Write-Host "Calculating device utilization metrics..." -ForegroundColor Yellow
$coverageAnalysis.UtilizationMetrics = Get-DeviceUtilizationAnalysis -UserCount $E5Users -CurrentDevices $CurrentProtectedDevices

# Step 3: Identify infrastructure gaps
Write-Host "Identifying infrastructure protection gaps..." -ForegroundColor Yellow
$coverageAnalysis.CoverageGaps = Get-InfrastructureGapAnalysis

# Step 4: Tool rationalization analysis
if ($IncludeToolRationalization) {
    Write-Host "Analyzing tool consolidation opportunities..." -ForegroundColor Yellow
    $coverageAnalysis.ToolRationalization = Get-ToolRationalizationAnalysis
}

# Step 5: Generate strategic recommendations
$coverageAnalysis.Recommendations = @()

# Device utilization recommendations
$coverageAnalysis.Recommendations += $coverageAnalysis.UtilizationMetrics.RecommendedActions

# E5 optimization recommendations
if ($coverageAnalysis.UtilizationMetrics.UtilizationRate -lt 90) {
    $coverageAnalysis.Recommendations += "Priority 1: Maximize E5 endpoint protection deployment before purchasing additional security tools"
}

$coverageAnalysis.Recommendations += "Priority 2: Implement Foundational CSPM (free) across all Azure subscriptions immediately"
$coverageAnalysis.Recommendations += "Priority 3: Deploy Defender for Servers Plan 2 on production workloads not covered by E5"
$coverageAnalysis.Recommendations += "Priority 4: Enable Defender for SQL on all database servers handling sensitive data"

if ($IncludeToolRationalization -and $coverageAnalysis.ToolRationalization.TotalAnnualSavings -gt 50000) {
    $coverageAnalysis.Recommendations += "Opportunity: Consolidate security tools to reallocate $$('{0:N0}' -f $coverageAnalysis.ToolRationalization.TotalAnnualSavings) annually to infrastructure protection"
}

# Generate comprehensive report
$analysisReport = Generate-CoverageReport -Analysis $coverageAnalysis

# Display summary
Write-Host "`nE5 Coverage Analysis Summary:" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host "E5 Users: $($E5Users)" -ForegroundColor White
Write-Host "Device Utilization: $($coverageAnalysis.UtilizationMetrics.UtilizationRate)%" -ForegroundColor $(if ($coverageAnalysis.UtilizationMetrics.UtilizationRate -ge 80) { "Green" } else { "Yellow" })
Write-Host "Unutilized Capacity: $($coverageAnalysis.UtilizationMetrics.UnutilizedCapacity) devices" -ForegroundColor White
Write-Host "Potential Annual Savings: $$('{0:N0}' -f $coverageAnalysis.UtilizationMetrics.PotentialAnnualSavings)" -ForegroundColor Cyan

if ($IncludeToolRationalization) {
    Write-Host "Tool Consolidation Savings: $$('{0:N0}' -f $coverageAnalysis.ToolRationalization.TotalAnnualSavings)" -ForegroundColor Cyan
    Write-Host "Available for Infrastructure: $$('{0:N0}' -f $coverageAnalysis.ToolRationalization.AvailableForInfrastructureProtection)" -ForegroundColor Green
}

# Display critical gaps
Write-Host "`nCritical Protection Gaps:" -ForegroundColor Yellow
foreach ($gap in $coverageAnalysis.CoverageGaps.CriticalGaps) {
    Write-Host "  • $gap" -ForegroundColor White
}

# Display recommendations
Write-Host "`nStrategic Recommendations:" -ForegroundColor Yellow
for ($i = 0; $i -lt $coverageAnalysis.Recommendations.Count; $i++) {
    Write-Host "  $($i + 1). $($coverageAnalysis.Recommendations[$i])" -ForegroundColor White
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = Join-Path $OutputPath "E5CoverageAnalysis-$timestamp.json"
$csvFile = Join-Path $OutputPath "E5CoverageSummary-$timestamp.csv"

try {
    # Export JSON report
    $analysisReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nDetailed analysis exported to: $reportFile" -ForegroundColor Green
    
    # Export CSV summary
    $csvData = [PSCustomObject]@{
        E5Users = $E5Users
        UtilizationRate = $coverageAnalysis.UtilizationMetrics.UtilizationRate
        UnutilizedDevices = $coverageAnalysis.UtilizationMetrics.UnutilizedCapacity
        PotentialSavings = $coverageAnalysis.UtilizationMetrics.PotentialAnnualSavings
        ToolConsolidationSavings = if ($coverageAnalysis.ToolRationalization.TotalAnnualSavings) { $coverageAnalysis.ToolRationalization.TotalAnnualSavings } else { 0 }
        RecommendedAction = $analysisReport.ExecutiveSummary.RecommendedAction
    }
    $csvData | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    Write-Host "Summary exported to: $csvFile" -ForegroundColor Green
} catch {
    Write-Warning "Failed to export results: $($_.Exception.Message)"
}

Write-Host "`nE5 coverage analysis completed successfully!" -ForegroundColor Green

return $analysisReport