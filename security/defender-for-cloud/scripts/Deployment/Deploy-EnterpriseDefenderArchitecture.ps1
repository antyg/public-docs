#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources, Az.Security, Az.ManagementGroups, Az.OperationalInsights, Az.PolicyInsights

<#
.SYNOPSIS
    Deploys enterprise-scale Microsoft Defender for Cloud architecture with multi-cloud support.

.DESCRIPTION
    This script implements a comprehensive Defender for Cloud deployment including:
    - Management group hierarchy creation
    - Policy framework deployment (FedRAMP High, NIST SP 800-53)
    - Log Analytics workspace configuration
    - Tiered protection strategy based on environment classification
    - Auto-provisioning and data collection setup

.PARAMETER OrganizationPrefix
    Prefix for naming management groups and resources (e.g., 'StateDoT', 'Corp')

.PARAMETER SubscriptionMappings
    Hashtable mapping subscription IDs to management groups

.PARAMETER DefenderPlans
    Hashtable defining protection plans by environment

.PARAMETER LogRetentionDays
    Log retention period in days (default: 2555 for government compliance)

.PARAMETER Location
    Azure region for resource deployment (default: 'East US')

.PARAMETER DryRun
    Perform validation and planning without making changes

.EXAMPLE
    $subMappings = @{
        "sub-prod-123" = "StateDoT-Production"
        "sub-dev-456" = "StateDoT-Development"
    }
    .\Deploy-EnterpriseDefenderArchitecture.ps1 -OrganizationPrefix "StateDoT" -SubscriptionMappings $subMappings

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Owner or Management Group Contributor permissions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateLength(3, 12)]
    [string]$OrganizationPrefix,

    [Parameter(Mandatory = $false)]
    [hashtable]$SubscriptionMappings = @{},

    [Parameter(Mandatory = $false)]
    [hashtable]$DefenderPlans = @{},

    [Parameter(Mandatory = $false)]
    [ValidateRange(90, 2555)]
    [int]$LogRetentionDays = 2555,

    [Parameter(Mandatory = $false)]
    [string]$Location = 'East US',

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Initialize deployment tracking
$deploymentResults = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    OrganizationPrefix = $OrganizationPrefix
    CreatedResources = @()
    Warnings = @()
    Errors = @()
    ValidationResults = @()
}

# Default defender plans configuration
if ($DefenderPlans.Count -eq 0) {
    $DefenderPlans = @{
        Production = @{
            VirtualMachines = @{ Tier = "Standard"; SubPlan = "P2" }
            SqlServers = @{ Tier = "Standard" }
            SqlServerVirtualMachines = @{ Tier = "Standard" }
            StorageAccounts = @{ Tier = "Standard" }
            KubernetesService = @{ Tier = "Standard" }
            AppServices = @{ Tier = "Standard" }
            KeyVaults = @{ Tier = "Standard" }
        }
        Development = @{
            VirtualMachines = @{ Tier = "Standard"; SubPlan = "P1" }
            SqlServers = @{ Tier = "Standard" }
            StorageAccounts = @{ Tier = "Free" }
        }
        Sandbox = @{
            # Only Foundational CSPM
        }
    }
}

function Write-DeploymentStep {
    param([string]$Message, [string]$Type = "Info")
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Info" { "Cyan" }
        default { "White" }
    }
    
    $prefix = switch ($Type) {
        "Success" { "✓" }
        "Warning" { "⚠" }
        "Error" { "✗" }
        "Info" { "•" }
        default { "-" }
    }
    
    Write-Host "[$prefix] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-DeploymentStep "Validating prerequisites" "Info"
    
    $prereqResults = @{
        Authentication = $false
        Permissions = $false
        Modules = $false
    }
    
    # Test authentication
    try {
        $context = Get-AzContext
        if ($context) {
            $prereqResults.Authentication = $true
            Write-DeploymentStep "Azure authentication verified: $($context.Account.Id)" "Success"
        } else {
            throw "Not authenticated to Azure"
        }
    } catch {
        $script:deploymentResults.Errors += "Authentication failed: $($_.Exception.Message)"
        Write-DeploymentStep "Authentication failed: $($_.Exception.Message)" "Error"
        return $false
    }
    
    # Test permissions
    try {
        Get-AzManagementGroup -ErrorAction Stop | Out-Null
        $prereqResults.Permissions = $true
        Write-DeploymentStep "Management group permissions verified" "Success"
    } catch {
        $script:deploymentResults.Errors += "Insufficient permissions for management groups"
        Write-DeploymentStep "Insufficient permissions for management groups" "Error"
        return $false
    }
    
    # Test required modules
    $requiredModules = @('Az.Security', 'Az.ManagementGroups', 'Az.OperationalInsights', 'Az.PolicyInsights')
    $missingModules = @()
    
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -Name $module -ListAvailable)) {
            $missingModules += $module
        }
    }
    
    if ($missingModules.Count -eq 0) {
        $prereqResults.Modules = $true
        Write-DeploymentStep "All required modules available" "Success"
    } else {
        $script:deploymentResults.Errors += "Missing modules: $($missingModules -join ', ')"
        Write-DeploymentStep "Missing modules: $($missingModules -join ', ')" "Error"
        return $false
    }
    
    $script:deploymentResults.ValidationResults += $prereqResults
    return $true
}

function Deploy-ManagementGroupHierarchy {
    Write-DeploymentStep "Creating management group hierarchy" "Info"
    
    $managementGroups = @{
        "$OrganizationPrefix-Root" = @{
            DisplayName = "$OrganizationPrefix Organization Root"
            Description = "Root management group for all organizational resources"
            ParentId = $null
        }
        "$OrganizationPrefix-Production" = @{
            DisplayName = "Production Environment"
            Description = "Production workloads requiring high security compliance"
            ParentId = "$OrganizationPrefix-Root"
        }
        "$OrganizationPrefix-Development" = @{
            DisplayName = "Development Environment"
            Description = "Development and testing workloads"
            ParentId = "$OrganizationPrefix-Root"
        }
        "$OrganizationPrefix-Sandbox" = @{
            DisplayName = "Sandbox Environment"
            Description = "Experimental and training workloads"
            ParentId = "$OrganizationPrefix-Root"
        }
        "$OrganizationPrefix-MultiCloud" = @{
            DisplayName = "Multi-Cloud Resources"
            Description = "AWS and other cloud provider resources"
            ParentId = "$OrganizationPrefix-Root"
        }
    }
    
    if ($DryRun) {
        Write-DeploymentStep "DRY RUN: Would create $($managementGroups.Count) management groups" "Info"
        foreach ($mgName in $managementGroups.Keys) {
            Write-DeploymentStep "  - $mgName`: $($managementGroups[$mgName].DisplayName)" "Info"
        }
        return $true
    }
    
    foreach ($mgName in $managementGroups.Keys) {
        $mg = $managementGroups[$mgName]
        
        try {
            $existing = Get-AzManagementGroup -GroupName $mgName -ErrorAction SilentlyContinue
            if ($existing) {
                Write-DeploymentStep "Management group already exists: $($mg.DisplayName)" "Warning"
                $script:deploymentResults.Warnings += "Management group already exists: $mgName"
            } else {
                $params = @{
                    GroupName = $mgName
                    DisplayName = $mg.DisplayName
                }
                
                if ($mg.ParentId) {
                    $params.ParentId = $mg.ParentId
                }
                
                New-AzManagementGroup @params | Out-Null
                Write-DeploymentStep "Created management group: $($mg.DisplayName)" "Success"
                $script:deploymentResults.CreatedResources += "Management Group: $mgName"
            }
        } catch {
            $script:deploymentResults.Errors += "Failed to create management group $mgName`: $($_.Exception.Message)"
            Write-DeploymentStep "Failed to create management group $mgName`: $($_.Exception.Message)" "Error"
            return $false
        }
    }
    
    # Move subscriptions to management groups
    if ($SubscriptionMappings.Count -gt 0) {
        Write-DeploymentStep "Assigning subscriptions to management groups" "Info"
        
        foreach ($subId in $SubscriptionMappings.Keys) {
            $mgName = $SubscriptionMappings[$subId]
            
            try {
                New-AzManagementGroupSubscription -GroupName $mgName -SubscriptionId $subId -ErrorAction SilentlyContinue | Out-Null
                Write-DeploymentStep "Assigned subscription $subId to $mgName" "Success"
            } catch {
                $script:deploymentResults.Warnings += "Failed to assign subscription $subId to $mgName`: $($_.Exception.Message)"
                Write-DeploymentStep "Failed to assign subscription $subId to $mgName`: $($_.Exception.Message)" "Warning"
            }
        }
    }
    
    return $true
}

function Deploy-ComplianceFrameworks {
    Write-DeploymentStep "Deploying compliance policy frameworks" "Info"
    
    $policyInitiatives = @{
        "FedRAMP High" = @{
            PolicySetId = $null  # Will be discovered
            Scope = "/providers/Microsoft.Management/managementGroups/$OrganizationPrefix-Production"
            AssignmentName = "Compliance-FedRAMP-High"
        }
        "NIST SP 800-53 Rev. 5" = @{
            PolicySetId = $null
            Scope = "/providers/Microsoft.Management/managementGroups/$OrganizationPrefix-Root"
            AssignmentName = "Compliance-NIST-SP-800-53-R5"
        }
        "NIST SP 800-171 Rev. 2" = @{
            PolicySetId = $null
            Scope = "/providers/Microsoft.Management/managementGroups/$OrganizationPrefix-Root"
            AssignmentName = "Compliance-NIST-SP-800-171-R2"
        }
    }
    
    if ($DryRun) {
        Write-DeploymentStep "DRY RUN: Would deploy $($policyInitiatives.Count) policy initiatives" "Info"
        return $true
    }
    
    foreach ($initiativeName in $policyInitiatives.Keys) {
        $initiative = $policyInitiatives[$initiativeName]
        
        try {
            # Find policy set definition
            $policySetDef = Get-AzPolicySetDefinition | Where-Object {
                $_.Properties.displayName -like "*$initiativeName*"
            } | Select-Object -First 1
            
            if (-not $policySetDef) {
                $script:deploymentResults.Warnings += "Policy initiative not found: $initiativeName"
                Write-DeploymentStep "Policy initiative not found: $initiativeName" "Warning"
                continue
            }
            
            # Check if assignment already exists
            $existingAssignment = Get-AzPolicyAssignment -Name $initiative.AssignmentName -ErrorAction SilentlyContinue
            if ($existingAssignment) {
                Write-DeploymentStep "Policy assignment already exists: $initiativeName" "Warning"
                continue
            }
            
            # Create policy assignment
            $assignment = New-AzPolicyAssignment `
                -Name $initiative.AssignmentName `
                -PolicySetDefinition $policySetDef `
                -Scope $initiative.Scope `
                -Description "Automated compliance monitoring for $initiativeName" `
                -DisplayName "$initiativeName Compliance Monitoring"
            
            Write-DeploymentStep "Deployed policy initiative: $initiativeName" "Success"
            $script:deploymentResults.CreatedResources += "Policy Assignment: $($initiative.AssignmentName)"
        } catch {
            $script:deploymentResults.Errors += "Failed to deploy policy initiative $initiativeName`: $($_.Exception.Message)"
            Write-DeploymentStep "Failed to deploy policy initiative $initiativeName`: $($_.Exception.Message)" "Error"
        }
    }
    
    return $true
}

function Deploy-LogAnalyticsWorkspace {
    Write-DeploymentStep "Configuring Log Analytics workspace" "Info"
    
    $workspaceConfig = @{
        ResourceGroupName = "rg-security-logging-$($OrganizationPrefix.ToLower())"
        WorkspaceName = "law-$($OrganizationPrefix.ToLower())-security"
        Location = $Location
        RetentionInDays = $LogRetentionDays
        DailyQuotaGb = 50
        Sku = "PerGB2018"
    }
    
    if ($DryRun) {
        Write-DeploymentStep "DRY RUN: Would create workspace $($workspaceConfig.WorkspaceName)" "Info"
        return $null
    }
    
    try {
        # Create resource group
        $resourceGroup = Get-AzResourceGroup -Name $workspaceConfig.ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $resourceGroup) {
            New-AzResourceGroup -Name $workspaceConfig.ResourceGroupName -Location $workspaceConfig.Location -Force | Out-Null
            Write-DeploymentStep "Created resource group: $($workspaceConfig.ResourceGroupName)" "Success"
            $script:deploymentResults.CreatedResources += "Resource Group: $($workspaceConfig.ResourceGroupName)"
        }
        
        # Create workspace
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $workspaceConfig.ResourceGroupName -Name $workspaceConfig.WorkspaceName -ErrorAction SilentlyContinue
        if (-not $workspace) {
            $workspace = New-AzOperationalInsightsWorkspace `
                -ResourceGroupName $workspaceConfig.ResourceGroupName `
                -Name $workspaceConfig.WorkspaceName `
                -Location $workspaceConfig.Location `
                -RetentionInDays $workspaceConfig.RetentionInDays `
                -Sku $workspaceConfig.Sku
            
            Write-DeploymentStep "Created Log Analytics workspace: $($workspaceConfig.WorkspaceName)" "Success"
            $script:deploymentResults.CreatedResources += "Log Analytics Workspace: $($workspaceConfig.WorkspaceName)"
        } else {
            Write-DeploymentStep "Log Analytics workspace already exists: $($workspaceConfig.WorkspaceName)" "Warning"
        }
        
        # Configure daily quota
        Set-AzOperationalInsightsWorkspace `
            -ResourceGroupName $workspaceConfig.ResourceGroupName `
            -Name $workspaceConfig.WorkspaceName `
            -DailyQuotaGb $workspaceConfig.DailyQuotaGb | Out-Null
        
        return $workspace
    } catch {
        $script:deploymentResults.Errors += "Failed to create Log Analytics workspace: $($_.Exception.Message)"
        Write-DeploymentStep "Failed to create Log Analytics workspace: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Deploy-DefenderPlans {
    param([object]$Workspace)
    
    Write-DeploymentStep "Deploying Defender protection plans" "Info"
    
    if ($DryRun) {
        Write-DeploymentStep "DRY RUN: Would deploy protection plans for $($DefenderPlans.Keys -join ', ') environments" "Info"
        return $true
    }
    
    if (-not $Workspace) {
        Write-DeploymentStep "Skipping Defender plans deployment - no workspace available" "Warning"
        return $false
    }
    
    foreach ($environment in $DefenderPlans.Keys) {
        $plans = $DefenderPlans[$environment]
        
        # Find subscription for this environment
        $environmentMG = "$OrganizationPrefix-$environment"
        $subscription = $SubscriptionMappings.Keys | Where-Object {
            $SubscriptionMappings[$_] -eq $environmentMG
        } | Select-Object -First 1
        
        if (-not $subscription) {
            Write-DeploymentStep "No subscription found for environment: $environment" "Warning"
            continue
        }
        
        # Set context to target subscription
        Set-AzContext -SubscriptionId $subscription | Out-Null
        Write-DeploymentStep "Configuring Defender plans for $environment environment" "Info"
        
        # Configure workspace setting
        try {
            Set-AzSecurityWorkspaceSetting -Name "default" -Scope "/subscriptions/$subscription" -WorkspaceId $Workspace.ResourceId | Out-Null
            Write-DeploymentStep "Connected workspace to Defender for Cloud" "Success"
        } catch {
            $script:deploymentResults.Warnings += "Failed to configure workspace setting: $($_.Exception.Message)"
        }
        
        # Enable auto-provisioning
        try {
            Set-AzSecurityAutoProvisioningSetting -Name "default" -EnableAutoProvision | Out-Null
            Write-DeploymentStep "Enabled auto-provisioning for $environment" "Success"
        } catch {
            $script:deploymentResults.Warnings += "Failed to enable auto-provisioning: $($_.Exception.Message)"
        }
        
        # Enable Defender plans
        foreach ($planName in $plans.Keys) {
            $plan = $plans[$planName]
            
            try {
                $setParams = @{
                    Name = $planName
                    PricingTier = $plan.Tier
                }
                
                if ($plan.SubPlan) {
                    $setParams.SubPlan = $plan.SubPlan
                }
                
                Set-AzSecurityPricing @setParams | Out-Null
                Write-DeploymentStep "Enabled $planName protection ($($plan.Tier)) for $environment" "Success"
                $script:deploymentResults.CreatedResources += "Protection Plan: $planName ($environment)"
            } catch {
                $script:deploymentResults.Errors += "Failed to enable $planName for $environment`: $($_.Exception.Message)"
                Write-DeploymentStep "Failed to enable $planName for $environment`: $($_.Exception.Message)" "Error"
            }
        }
    }
    
    return $true
}

function Generate-DeploymentReport {
    Write-DeploymentStep "Generating deployment report" "Info"
    
    $report = @{
        Deployment_Summary = @{
            Timestamp = $deploymentResults.Timestamp
            OrganizationPrefix = $deploymentResults.OrganizationPrefix
            DryRun = $DryRun.IsPresent
            TotalCreatedResources = $deploymentResults.CreatedResources.Count
            TotalWarnings = $deploymentResults.Warnings.Count
            TotalErrors = $deploymentResults.Errors.Count
            OverallStatus = if ($deploymentResults.Errors.Count -eq 0) { "Success" } else { "Partial" }
        }
        Created_Resources = $deploymentResults.CreatedResources
        Warnings = $deploymentResults.Warnings
        Errors = $deploymentResults.Errors
        Next_Steps = @(
            "Review recommendations in Defender for Cloud portal",
            "Configure security contacts and notification settings",
            "Validate policy compliance assessments",
            "Test alert generation and incident response workflows",
            "Schedule regular compliance and security reviews"
        )
    }
    
    return $report
}

# Main execution
Write-Host "Microsoft Defender for Cloud Enterprise Deployment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Step 1: Validate prerequisites
if (-not (Test-Prerequisites)) {
    Write-Host "Prerequisites validation failed. Deployment cannot continue." -ForegroundColor Red
    exit 1
}

# Step 2: Deploy management group hierarchy
if (-not (Deploy-ManagementGroupHierarchy)) {
    Write-Host "Management group deployment failed. Deployment cannot continue." -ForegroundColor Red
    exit 1
}

# Step 3: Deploy compliance frameworks
Deploy-ComplianceFrameworks | Out-Null

# Step 4: Deploy Log Analytics workspace
$workspace = Deploy-LogAnalyticsWorkspace

# Step 5: Deploy Defender plans
Deploy-DefenderPlans -Workspace $workspace | Out-Null

# Step 6: Generate final report
$deploymentReport = Generate-DeploymentReport

# Display summary
Write-Host ""
Write-Host "Deployment Summary" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "Status: $($deploymentReport.Deployment_Summary.OverallStatus)" -ForegroundColor $(if ($deploymentReport.Deployment_Summary.OverallStatus -eq "Success") { "Green" } else { "Yellow" })
Write-Host "Created Resources: $($deploymentReport.Deployment_Summary.TotalCreatedResources)" -ForegroundColor White
Write-Host "Warnings: $($deploymentReport.Deployment_Summary.TotalWarnings)" -ForegroundColor Yellow
Write-Host "Errors: $($deploymentReport.Deployment_Summary.TotalErrors)" -ForegroundColor Red

if ($deploymentReport.Created_Resources.Count -gt 0) {
    Write-Host ""
    Write-Host "Created Resources:" -ForegroundColor Cyan
    foreach ($resource in $deploymentReport.Created_Resources) {
        Write-Host "  ✓ $resource" -ForegroundColor Green
    }
}

if ($deploymentReport.Warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings:" -ForegroundColor Yellow
    foreach ($warning in $deploymentReport.Warnings) {
        Write-Host "  ⚠ $warning" -ForegroundColor Yellow
    }
}

if ($deploymentReport.Errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors:" -ForegroundColor Red
    foreach ($error in $deploymentReport.Errors) {
        Write-Host "  ✗ $error" -ForegroundColor Red
    }
}

# Export deployment report
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = "DefenderEnterpriseDeployment-$timestamp.json"
$deploymentReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host ""
Write-Host "Deployment report exported to: $reportFile" -ForegroundColor Green
Write-Host "Enterprise Defender for Cloud deployment completed!" -ForegroundColor Green

return $deploymentReport