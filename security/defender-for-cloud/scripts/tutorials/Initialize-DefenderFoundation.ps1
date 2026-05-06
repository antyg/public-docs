#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources, Az.Security, Az.ManagementGroups, Az.OperationalInsights

<#
.SYNOPSIS
    Initializes foundational Microsoft Defender for Cloud configuration.

.DESCRIPTION
    This script performs the initial setup of Microsoft Defender for Cloud including:
    - Enabling foundational CSPM
    - Creating management group hierarchy
    - Applying compliance frameworks (FedRAMP High, NIST SP 800-53)
    - Configuring Log Analytics workspace
    - Enabling basic workload protection

.PARAMETER OrganizationPrefix
    Prefix for naming management groups and resources (e.g., 'Gov', 'Corp')

.PARAMETER LogRetentionDays
    Log retention period in days (default: 730 for government compliance)

.PARAMETER Location
    Azure region for resource deployment (default: 'East US')

.PARAMETER EnableBasicWorkloadProtection
    Enable Defender for Servers Plan 2 and Defender for SQL

.EXAMPLE
    .\Initialize-DefenderFoundation.ps1 -OrganizationPrefix "Gov" -LogRetentionDays 730

.EXAMPLE
    .\Initialize-DefenderFoundation.ps1 -OrganizationPrefix "Corp" -EnableBasicWorkloadProtection

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Owner or Contributor permissions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateLength(2, 8)]
    [string]$OrganizationPrefix,

    [Parameter(Mandatory = $false)]
    [ValidateRange(30, 2555)]
    [int]$LogRetentionDays = 730,

    [Parameter(Mandatory = $false)]
    [string]$Location = 'East US',

    [Parameter(Mandatory = $false)]
    [switch]$EnableBasicWorkloadProtection
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Initialize tracking variables
$CreatedResources = @()
$Warnings = @()
$Errors = @()

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Issue {
    param([string]$Message, [string]$Type = "Warning")
    if ($Type -eq "Error") {
        Write-Host "✗ $Message" -ForegroundColor Red
        $script:Errors += $Message
    } else {
        Write-Host "⚠ $Message" -ForegroundColor Yellow
        $script:Warnings += $Message
    }
}

# Step 1: Verify prerequisites
Write-Step "Verifying prerequisites"
try {
    $context = Get-AzContext
    if (-not $context) {
        throw "Not authenticated to Azure. Please run Connect-AzAccount first."
    }
    Write-Success "Azure authentication verified"

    # Check required permissions by testing management group access
    try {
        Get-AzManagementGroup -ErrorAction Stop | Out-Null
        Write-Success "Management group permissions verified"
    } catch {
        Write-Issue "Unable to access management groups. Owner or Management Group Contributor role required." "Error"
        throw
    }
} catch {
    Write-Issue "Prerequisites check failed: $($_.Exception.Message)" "Error"
    throw
}

# Step 2: Enable foundational CSPM
Write-Step "Enabling foundational CSPM"
try {
    $cloudPosture = Get-AzSecurityPricing -Name "CloudPosture" -ErrorAction SilentlyContinue
    if ($cloudPosture.PricingTier -eq "Free") {
        Write-Success "Foundational CSPM already enabled (automatic)"
    } else {
        Write-Issue "Unexpected CSPM pricing tier: $($cloudPosture.PricingTier)"
    }
} catch {
    Write-Issue "Error checking CSPM status: $($_.Exception.Message)"
}

# Step 3: Create management group hierarchy
Write-Step "Creating management group hierarchy"
try {
    $rootGroupName = "$OrganizationPrefix-Root"
    $prodGroupName = "$OrganizationPrefix-Production"
    $devGroupName = "$OrganizationPrefix-Development"

    # Create root management group
    try {
        $rootGroup = Get-AzManagementGroup -GroupName $rootGroupName -ErrorAction SilentlyContinue
        if (-not $rootGroup) {
            New-AzManagementGroup -GroupName $rootGroupName -DisplayName "$OrganizationPrefix Organization Root" | Out-Null
            Write-Success "Created management group: $rootGroupName"
            $CreatedResources += "Management Group: $rootGroupName"
        } else {
            Write-Success "Management group already exists: $rootGroupName"
        }
    } catch {
        Write-Issue "Error creating root management group: $($_.Exception.Message)"
    }

    # Create production management group
    try {
        $prodGroup = Get-AzManagementGroup -GroupName $prodGroupName -ErrorAction SilentlyContinue
        if (-not $prodGroup) {
            New-AzManagementGroup -GroupName $prodGroupName -DisplayName "Production Environment" -ParentId $rootGroupName | Out-Null
            Write-Success "Created management group: $prodGroupName"
            $CreatedResources += "Management Group: $prodGroupName"
        } else {
            Write-Success "Management group already exists: $prodGroupName"
        }
    } catch {
        Write-Issue "Error creating production management group: $($_.Exception.Message)"
    }

    # Create development management group
    try {
        $devGroup = Get-AzManagementGroup -GroupName $devGroupName -ErrorAction SilentlyContinue
        if (-not $devGroup) {
            New-AzManagementGroup -GroupName $devGroupName -DisplayName "Development Environment" -ParentId $rootGroupName | Out-Null
            Write-Success "Created management group: $devGroupName"
            $CreatedResources += "Management Group: $devGroupName"
        } else {
            Write-Success "Management group already exists: $devGroupName"
        }
    } catch {
        Write-Issue "Error creating development management group: $($_.Exception.Message)"
    }
} catch {
    Write-Issue "Error in management group creation: $($_.Exception.Message)"
}

# Step 4: Apply compliance frameworks
Write-Step "Applying compliance frameworks"
try {
    # Apply FedRAMP High controls
    $fedRampInitiative = Get-AzPolicySetDefinition | Where-Object { $_.Properties.displayName -like "*FedRAMP High*" } | Select-Object -First 1
    if ($fedRampInitiative) {
        $fedRampAssignment = Get-AzPolicyAssignment -Name "FedRAMP-High-Prod" -ErrorAction SilentlyContinue
        if (-not $fedRampAssignment) {
            New-AzPolicyAssignment -Name "FedRAMP-High-Prod" -PolicySetDefinition $fedRampInitiative -Scope "/providers/Microsoft.Management/managementGroups/$prodGroupName" | Out-Null
            Write-Success "Applied FedRAMP High initiative to production"
            $CreatedResources += "Policy Assignment: FedRAMP-High-Prod"
        } else {
            Write-Success "FedRAMP High initiative already assigned"
        }
    } else {
        Write-Issue "FedRAMP High initiative not found"
    }

    # Apply NIST SP 800-53 controls
    $nistInitiative = Get-AzPolicySetDefinition | Where-Object { $_.Properties.displayName -like "*NIST SP 800-53*" } | Select-Object -First 1
    if ($nistInitiative) {
        $nistAssignment = Get-AzPolicyAssignment -Name "NIST-SP-800-53-R5" -ErrorAction SilentlyContinue
        if (-not $nistAssignment) {
            New-AzPolicyAssignment -Name "NIST-SP-800-53-R5" -PolicySetDefinition $nistInitiative -Scope "/providers/Microsoft.Management/managementGroups/$rootGroupName" | Out-Null
            Write-Success "Applied NIST SP 800-53 Rev. 5 initiative to root"
            $CreatedResources += "Policy Assignment: NIST-SP-800-53-R5"
        } else {
            Write-Success "NIST SP 800-53 initiative already assigned"
        }
    } else {
        Write-Issue "NIST SP 800-53 initiative not found"
    }
} catch {
    Write-Issue "Error applying compliance frameworks: $($_.Exception.Message)"
}

# Step 5: Configure Log Analytics workspace
Write-Step "Configuring Log Analytics workspace"
try {
    $resourceGroupName = "rg-security-logging"
    $workspaceName = "law-defender-central"

    # Create resource group
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if (-not $resourceGroup) {
        New-AzResourceGroup -Name $resourceGroupName -Location $Location | Out-Null
        Write-Success "Created resource group: $resourceGroupName"
        $CreatedResources += "Resource Group: $resourceGroupName"
    } else {
        Write-Success "Resource group already exists: $resourceGroupName"
    }

    # Create Log Analytics workspace
    $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName -ErrorAction SilentlyContinue
    if (-not $workspace) {
        New-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName -Location $Location -RetentionInDays $LogRetentionDays | Out-Null
        Write-Success "Created Log Analytics workspace: $workspaceName ($LogRetentionDays days retention)"
        $CreatedResources += "Log Analytics Workspace: $workspaceName"
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName
    } else {
        Write-Success "Log Analytics workspace already exists: $workspaceName"
    }

    # Configure Defender for Cloud connection
    try {
        Set-AzSecurityWorkspaceSetting -Name "default" -Scope "/subscriptions/$($context.Subscription.Id)" -WorkspaceId $workspace.ResourceId | Out-Null
        Write-Success "Connected Defender for Cloud to workspace"
    } catch {
        Write-Issue "Error connecting workspace to Defender for Cloud: $($_.Exception.Message)"
    }

    # Enable auto-provisioning
    try {
        Set-AzSecurityAutoProvisioningSetting -Name "default" -EnableAutoProvision | Out-Null
        Write-Success "Enabled Azure Monitor Agent auto-provisioning"
    } catch {
        Write-Issue "Error enabling auto-provisioning: $($_.Exception.Message)"
    }
} catch {
    Write-Issue "Error configuring Log Analytics workspace: $($_.Exception.Message)"
}

# Step 6: Enable basic workload protection (if requested)
if ($EnableBasicWorkloadProtection) {
    Write-Step "Enabling basic workload protection"
    try {
        # Enable Defender for Servers Plan 2
        Set-AzSecurityPricing -Name "VirtualMachines" -PricingTier "Standard" -SubPlan "P2" | Out-Null
        Write-Success "Enabled Defender for Servers Plan 2"
        $CreatedResources += "Protection Plan: Defender for Servers Plan 2"

        # Enable Defender for SQL
        Set-AzSecurityPricing -Name "SqlServers" -PricingTier "Standard" | Out-Null
        Set-AzSecurityPricing -Name "SqlServerVirtualMachines" -PricingTier "Standard" | Out-Null
        Write-Success "Enabled Defender for SQL"
        $CreatedResources += "Protection Plan: Defender for SQL"
    } catch {
        Write-Issue "Error enabling workload protection: $($_.Exception.Message)"
    }
}

# Step 7: Generate summary report
Write-Step "Generating configuration summary"

Write-Host ""
Write-Host "Microsoft Defender for Cloud Foundation Setup Complete" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Created Resources:" -ForegroundColor Cyan
foreach ($resource in $CreatedResources) {
    Write-Host "  ✓ $resource" -ForegroundColor Green
}

if ($Warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings:" -ForegroundColor Yellow
    foreach ($warning in $Warnings) {
        Write-Host "  ⚠ $warning" -ForegroundColor Yellow
    }
}

if ($Errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors:" -ForegroundColor Red
    foreach ($error in $Errors) {
        Write-Host "  ✗ $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review recommendations in Defender for Cloud portal" -ForegroundColor White
Write-Host "2. Configure alert notifications for security team" -ForegroundColor White
Write-Host "3. Validate compliance posture in Regulatory compliance blade" -ForegroundColor White
Write-Host "4. Plan additional workload protection enablement" -ForegroundColor White

# Export configuration for documentation
$configSummary = @{
    Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OrganizationPrefix = $OrganizationPrefix
    LogRetentionDays   = $LogRetentionDays
    Location           = $Location
    CreatedResources   = $CreatedResources
    Warnings           = $Warnings
    Errors             = $Errors
}

$configPath = ".\DefenderFoundationConfig-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$configSummary | ConvertTo-Json -Depth 3 | Out-File -FilePath $configPath -Encoding UTF8
Write-Host ""
Write-Host "Configuration summary exported to: $configPath" -ForegroundColor Yellow
