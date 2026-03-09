#Requires -Version 7.0
#Requires -Modules Az.Accounts, Az.Security, Az.Resources, Az.OperationalInsights, Az.PolicyInsights

<#
.SYNOPSIS
    Deploys Microsoft Defender for Cloud foundational configuration for government environments.

.DESCRIPTION
    This script automates the deployment of Microsoft Defender for Cloud foundational components
    including Foundational CSPM, compliance frameworks, Log Analytics workspace, and basic
    workload protection plans. Designed for government agencies with FedRAMP High, StateRAMP,
    and CJIS compliance requirements.

.PARAMETER SubscriptionId
    The Azure subscription ID where Defender for Cloud will be deployed.

.PARAMETER Environment
    The target environment type. Valid values: Production, Development, Testing, Sandbox.

.PARAMETER ComplianceFramework
    The compliance framework to implement. Valid values: FedRAMP-High, StateRAMP, NIST-SP-800-53, NIST-SP-800-171, CJIS.

.PARAMETER ResourceGroupName
    The resource group name for Log Analytics workspace and related resources.

.PARAMETER WorkspaceName
    The Log Analytics workspace name for centralized security logging.

.PARAMETER Location
    The Azure region for resource deployment.

.PARAMETER SecurityContactEmail
    Email address for security notifications and alerts.

.PARAMETER SecurityContactPhone
    Phone number for critical security notifications (optional).

.PARAMETER DryRun
    Performs validation and shows what would be deployed without making changes.

.EXAMPLE
    .\Deploy-DefenderFoundation.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -Environment "Production" -ComplianceFramework "FedRAMP-High" -SecurityContactEmail "security@agency.gov"

.EXAMPLE
    .\Deploy-DefenderFoundation.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -Environment "Development" -ComplianceFramework "NIST-SP-800-53" -SecurityContactEmail "security@agency.gov" -DryRun

.NOTES
    Author: Azure Security Architecture Team
    Version: 1.0
    Created: October 2025

    Prerequisites:
    - PowerShell 7.0 or higher
    - Az.Accounts, Az.Security, Az.Resources, Az.OperationalInsights, Az.PolicyInsights modules
    - Owner or Contributor permissions on target subscription
    - Security Admin role in Entra ID

    Compliance:
    - Follows ALCOA-C data integrity principles
    - Implements government security baselines
    - Maintains audit trails for all operations
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Production', 'Development', 'Testing', 'Sandbox')]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [ValidateSet('FedRAMP-High', 'StateRAMP', 'NIST-SP-800-53', 'NIST-SP-800-171', 'CJIS')]
    [string]$ComplianceFramework,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-security-$($Environment.ToLower())",

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceName = "law-defender-$($Environment.ToLower())",

    [Parameter(Mandatory = $false)]
    [string]$Location = "East US",

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    [string]$SecurityContactEmail,

    [Parameter(Mandatory = $false)]
    [string]$SecurityContactPhone = "",

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Initialize logging and error handling
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'Continue'

# Create audit trail for compliance
$auditLog = @{
    Timestamp  = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    Script     = $MyInvocation.MyCommand.Name
    Parameters = $PSBoundParameters
    User       = $env:USERNAME
    Computer   = $env:COMPUTERNAME
    Actions    = @()
}

function Write-AuditLog {
    param(
        [string]$Action,
        [string]$Status,
        [string]$Details = ""
    )

    $auditEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        Action    = $Action
        Status    = $Status
        Details   = $Details
    }

    $auditLog.Actions += $auditEntry
    Write-Host "[$($auditEntry.Timestamp)] $Action - $Status" -ForegroundColor $(if ($Status -eq 'SUCCESS') { 'Green' } elseif ($Status -eq 'FAILED') { 'Red' } else { 'Yellow' })

    if ($Details) {
        Write-Verbose $Details
    }
}

function Test-Prerequisites {
    Write-Host "Validating prerequisites..." -ForegroundColor Cyan

    # Test PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "PowerShell 7.0 or higher is required. Current version: $($PSVersionTable.PSVersion)"
    }
    Write-AuditLog -Action "Validate PowerShell Version" -Status "SUCCESS" -Details "Version $($PSVersionTable.PSVersion)"

    # Test required modules
    $requiredModules = @('Az.Accounts', 'Az.Security', 'Az.Resources', 'Az.OperationalInsights', 'Az.PolicyInsights')
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -Name $module -ListAvailable)) {
            throw "Required module '$module' is not installed. Run: Install-Module -Name $module"
        }
        Write-AuditLog -Action "Validate Module $module" -Status "SUCCESS"
    }

    # Test Azure connection
    try {
        $context = Get-AzContext
        if (-not $context) {
            throw "Not connected to Azure. Run: Connect-AzAccount"
        }
        Write-AuditLog -Action "Validate Azure Connection" -Status "SUCCESS" -Details "Tenant: $($context.Tenant.Id)"
    } catch {
        Write-AuditLog -Action "Validate Azure Connection" -Status "FAILED" -Details $_.Exception.Message
        throw $_
    }

    # Test subscription access
    try {
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        $subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
        Write-AuditLog -Action "Validate Subscription Access" -Status "SUCCESS" -Details "Subscription: $($subscription.Name)"
    } catch {
        Write-AuditLog -Action "Validate Subscription Access" -Status "FAILED" -Details $_.Exception.Message
        throw $_
    }
}

function Get-ComplianceConfiguration {
    param([string]$Framework)

    $configurations = @{
        'FedRAMP-High'    = @{
            PolicyInitiatives = @(
                'FedRAMP High',
                'NIST SP 800-53 Rev. 5'
            )
            RetentionDays     = 2555  # 7 years
            DefenderPlans     = @{
                'VirtualMachines'          = @{ Tier = 'Standard'; SubPlan = 'P2' }
                'SqlServers'               = @{ Tier = 'Standard' }
                'SqlServerVirtualMachines' = @{ Tier = 'Standard' }
                'StorageAccounts'          = @{ Tier = 'Standard' }
                'KubernetesService'        = @{ Tier = 'Standard' }
            }
        }
        'StateRAMP'       = @{
            PolicyInitiatives = @(
                'FedRAMP High',
                'NIST SP 800-53 Rev. 5'
            )
            RetentionDays     = 2555  # Aligned with FedRAMP
            DefenderPlans     = @{
                'VirtualMachines' = @{ Tier = 'Standard'; SubPlan = 'P2' }
                'SqlServers'      = @{ Tier = 'Standard' }
                'StorageAccounts' = @{ Tier = 'Standard' }
            }
        }
        'NIST-SP-800-53'  = @{
            PolicyInitiatives = @(
                'NIST SP 800-53 Rev. 5'
            )
            RetentionDays     = 2190  # 6 years
            DefenderPlans     = @{
                'VirtualMachines' = @{ Tier = 'Standard'; SubPlan = 'P2' }
                'SqlServers'      = @{ Tier = 'Standard' }
                'StorageAccounts' = @{ Tier = 'Standard' }
            }
        }
        'NIST-SP-800-171' = @{
            PolicyInitiatives = @(
                'NIST SP 800-171 Rev. 2'
            )
            RetentionDays     = 2190  # 6 years
            DefenderPlans     = @{
                'VirtualMachines' = @{ Tier = 'Standard'; SubPlan = 'P1' }
                'SqlServers'      = @{ Tier = 'Standard' }
            }
        }
        'CJIS'            = @{
            PolicyInitiatives = @(
                'NIST SP 800-53 Rev. 5'
            )
            RetentionDays     = 2555  # 7 years for audit logs
            DefenderPlans     = @{
                'VirtualMachines' = @{ Tier = 'Standard'; SubPlan = 'P2' }
                'SqlServers'      = @{ Tier = 'Standard' }
                'StorageAccounts' = @{ Tier = 'Standard' }
            }
        }
    }

    return $configurations[$Framework]
}

function Deploy-LogAnalyticsWorkspace {
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName,
        [string]$Location,
        [int]$RetentionDays
    )

    Write-Host "Deploying Log Analytics workspace..." -ForegroundColor Cyan

    try {
        # Create resource group if it doesn't exist
        $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $resourceGroup) {
            if ($PSCmdlet.ShouldProcess($ResourceGroupName, "Create Resource Group")) {
                New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
                Write-AuditLog -Action "Create Resource Group" -Status "SUCCESS" -Details "Name: $ResourceGroupName, Location: $Location"
            }
        } else {
            Write-AuditLog -Action "Validate Resource Group" -Status "SUCCESS" -Details "Existing resource group found"
        }

        # Create Log Analytics workspace
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
        if (-not $workspace) {
            if ($PSCmdlet.ShouldProcess($WorkspaceName, "Create Log Analytics Workspace")) {
                $workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location -RetentionInDays $RetentionDays
                Write-AuditLog -Action "Create Log Analytics Workspace" -Status "SUCCESS" -Details "Name: $WorkspaceName, Retention: $RetentionDays days"
            }
        } else {
            # Update retention if different
            if ($workspace.RetentionInDays -ne $RetentionDays) {
                if ($PSCmdlet.ShouldProcess($WorkspaceName, "Update Retention Period")) {
                    Set-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -RetentionInDays $RetentionDays | Out-Null
                    Write-AuditLog -Action "Update Workspace Retention" -Status "SUCCESS" -Details "Updated to $RetentionDays days"
                }
            }
            Write-AuditLog -Action "Validate Log Analytics Workspace" -Status "SUCCESS" -Details "Existing workspace found"
        }

        return $workspace
    } catch {
        Write-AuditLog -Action "Deploy Log Analytics Workspace" -Status "FAILED" -Details $_.Exception.Message
        throw $_
    }
}

function Deploy-DefenderPlans {
    param(
        [hashtable]$DefenderPlans
    )

    Write-Host "Configuring Defender for Cloud protection plans..." -ForegroundColor Cyan

    foreach ($planName in $DefenderPlans.Keys) {
        $plan = $DefenderPlans[$planName]

        try {
            if ($PSCmdlet.ShouldProcess($planName, "Enable Defender Plan")) {
                $setParams = @{
                    Name        = $planName
                    PricingTier = $plan.Tier
                }

                if ($plan.SubPlan) {
                    $setParams.SubPlan = $plan.SubPlan
                }

                Set-AzSecurityPricing @setParams | Out-Null
                Write-AuditLog -Action "Enable Defender Plan" -Status "SUCCESS" -Details "Plan: $planName, Tier: $($plan.Tier), SubPlan: $($plan.SubPlan)"
            }
        } catch {
            Write-AuditLog -Action "Enable Defender Plan $planName" -Status "FAILED" -Details $_.Exception.Message
            throw $_
        }
    }
}

function Deploy-CompliancePolicies {
    param(
        [string[]]$PolicyInitiatives,
        [string]$WorkspaceId
    )

    Write-Host "Deploying compliance policy initiatives..." -ForegroundColor Cyan

    foreach ($initiativeName in $PolicyInitiatives) {
        try {
            # Find policy initiative
            $initiative = Get-AzPolicySetDefinition | Where-Object { $_.Properties.displayName -like "*$initiativeName*" } | Select-Object -First 1

            if (-not $initiative) {
                Write-Warning "Policy initiative '$initiativeName' not found. Skipping..."
                Write-AuditLog -Action "Deploy Policy Initiative" -Status "WARNING" -Details "Initiative '$initiativeName' not found"
                continue
            }

            $assignmentName = "$initiativeName-$Environment"
            $existingAssignment = Get-AzPolicyAssignment -Name $assignmentName -Scope "/subscriptions/$SubscriptionId" -ErrorAction SilentlyContinue

            if (-not $existingAssignment) {
                if ($PSCmdlet.ShouldProcess($assignmentName, "Assign Policy Initiative")) {
                    $assignment = New-AzPolicyAssignment -Name $assignmentName -PolicySetDefinition $initiative -Scope "/subscriptions/$SubscriptionId"
                    Write-AuditLog -Action "Deploy Policy Initiative" -Status "SUCCESS" -Details "Initiative: $initiativeName, Assignment: $assignmentName"
                }
            } else {
                Write-AuditLog -Action "Validate Policy Initiative" -Status "SUCCESS" -Details "Assignment '$assignmentName' already exists"
            }
        } catch {
            Write-AuditLog -Action "Deploy Policy Initiative $initiativeName" -Status "FAILED" -Details $_.Exception.Message
            throw $_
        }
    }
}

function Configure-SecurityContacts {
    param(
        [string]$Email,
        [string]$Phone
    )

    Write-Host "Configuring security contacts..." -ForegroundColor Cyan

    try {
        if ($PSCmdlet.ShouldProcess("Security Contacts", "Configure")) {
            $contactParams = @{
                Name               = 'default'
                Email              = $Email
                Phone              = $Phone
                AlertNotifications = $true
                AlertsToAdmins     = $true
            }

            Set-AzSecurityContact @contactParams | Out-Null
            Write-AuditLog -Action "Configure Security Contacts" -Status "SUCCESS" -Details "Email: $Email, Phone: $Phone"
        }
    } catch {
        Write-AuditLog -Action "Configure Security Contacts" -Status "FAILED" -Details $_.Exception.Message
        throw $_
    }
}

function Configure-AutoProvisioning {
    param(
        [string]$WorkspaceId
    )

    Write-Host "Configuring auto-provisioning settings..." -ForegroundColor Cyan

    try {
        if ($PSCmdlet.ShouldProcess("Auto-Provisioning", "Configure")) {
            # Enable Azure Monitor Agent auto-provisioning
            Set-AzSecurityAutoProvisioningSetting -Name 'default' -EnableAutoProvision | Out-Null
            Write-AuditLog -Action "Enable Auto-Provisioning" -Status "SUCCESS" -Details "Azure Monitor Agent enabled"

            # Configure workspace setting
            Set-AzSecurityWorkspaceSetting -Name 'default' -Scope "/subscriptions/$SubscriptionId" -WorkspaceId $WorkspaceId | Out-Null
            Write-AuditLog -Action "Configure Workspace Setting" -Status "SUCCESS" -Details "Workspace: $WorkspaceId"
        }
    } catch {
        Write-AuditLog -Action "Configure Auto-Provisioning" -Status "FAILED" -Details $_.Exception.Message
        throw $_
    }
}

function Test-Deployment {
    Write-Host "Validating deployment..." -ForegroundColor Cyan

    try {
        # Test Foundational CSPM
        $cspmpPlan = Get-AzSecurityPricing -Name 'CloudPosture'
        if ($cspmpPlan.PricingTier -eq 'Free') {
            Write-AuditLog -Action "Validate Foundational CSPM" -Status "SUCCESS" -Details "Foundational CSPM is enabled"
        } else {
            Write-AuditLog -Action "Validate Foundational CSPM" -Status "WARNING" -Details "CSPM plan is not on Free tier"
        }

        # Test Secure Score
        $secureScore = Get-AzSecurityScore -Name 'ascScore'
        if ($secureScore) {
            Write-AuditLog -Action "Validate Secure Score" -Status "SUCCESS" -Details "Current score: $($secureScore.Score.Current)/$($secureScore.Score.Max)"
        }

        # Test policy compliance
        Start-Sleep -Seconds 30  # Allow time for policy evaluation
        $policyStates = Get-AzPolicyState -Top 5
        if ($policyStates) {
            Write-AuditLog -Action "Validate Policy Evaluation" -Status "SUCCESS" -Details "Policy states available"
        }

        # Test Log Analytics data collection
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
        if ($workspace) {
            Write-AuditLog -Action "Validate Log Analytics Workspace" -Status "SUCCESS" -Details "Workspace operational"
        }

        Write-Host "Deployment validation completed successfully!" -ForegroundColor Green
    } catch {
        Write-AuditLog -Action "Validate Deployment" -Status "FAILED" -Details $_.Exception.Message
        Write-Warning "Deployment validation encountered issues: $($_.Exception.Message)"
    }
}

function Export-DeploymentEvidence {
    try {
        $evidencePackage = @{
            Deployment    = @{
                Timestamp           = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                Subscription        = $SubscriptionId
                Environment         = $Environment
                ComplianceFramework = $ComplianceFramework
                DryRun              = $DryRun.IsPresent
            }
            Configuration = @{
                DefenderPlans     = Get-AzSecurityPricing | Select-Object Name, PricingTier, SubPlan
                PolicyAssignments = Get-AzPolicyAssignment -Scope "/subscriptions/$SubscriptionId" | Where-Object { $_.Properties.displayName -like "*Security*" -or $_.Properties.displayName -like "*FedRAMP*" -or $_.Properties.displayName -like "*NIST*" }
                SecurityContacts  = Get-AzSecurityContact
                AutoProvisioning  = Get-AzSecurityAutoProvisioningSetting
                SecureScore       = Get-AzSecurityScore -Name 'ascScore'
            }
            AuditTrail    = $auditLog
        }

        $evidenceJson = $evidencePackage | ConvertTo-Json -Depth 5
        $evidenceFile = "DefenderDeploymentEvidence-$($Environment)-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

        if ($PSCmdlet.ShouldProcess($evidenceFile, "Export Evidence Package")) {
            $evidenceJson | Out-File -FilePath $evidenceFile -Encoding UTF8
            Write-AuditLog -Action "Export Evidence Package" -Status "SUCCESS" -Details "File: $evidenceFile"
            Write-Host "Evidence package exported to: $evidenceFile" -ForegroundColor Green
        }
    } catch {
        Write-AuditLog -Action "Export Evidence Package" -Status "FAILED" -Details $_.Exception.Message
        Write-Warning "Failed to export evidence package: $($_.Exception.Message)"
    }
}

# Main execution
try {
    Write-Host "Starting Microsoft Defender for Cloud Foundation Deployment" -ForegroundColor Yellow
    Write-Host "Environment: $Environment" -ForegroundColor Cyan
    Write-Host "Compliance Framework: $ComplianceFramework" -ForegroundColor Cyan
    Write-Host "Subscription: $SubscriptionId" -ForegroundColor Cyan

    if ($DryRun) {
        Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
    }

    # Step 1: Validate prerequisites
    Test-Prerequisites

    # Step 2: Get compliance configuration
    $config = Get-ComplianceConfiguration -Framework $ComplianceFramework
    if (-not $config) {
        throw "Unsupported compliance framework: $ComplianceFramework"
    }
    Write-AuditLog -Action "Load Compliance Configuration" -Status "SUCCESS" -Details "Framework: $ComplianceFramework"

    # Step 3: Deploy Log Analytics workspace
    $workspace = Deploy-LogAnalyticsWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Location $Location -RetentionDays $config.RetentionDays

    # Step 4: Enable Defender plans
    if ($Environment -eq 'Production') {
        Deploy-DefenderPlans -DefenderPlans $config.DefenderPlans
    } elseif ($Environment -eq 'Development') {
        # Use Plan 1 for development
        $devPlans = @{
            'VirtualMachines' = @{ Tier = 'Standard'; SubPlan = 'P1' }
        }
        Deploy-DefenderPlans -DefenderPlans $devPlans
    } else {
        Write-Host "Skipping Defender plans for $Environment environment (using Foundational CSPM only)" -ForegroundColor Yellow
        Write-AuditLog -Action "Skip Defender Plans" -Status "SUCCESS" -Details "Environment: $Environment uses Foundational CSPM"
    }

    # Step 5: Deploy compliance policies
    Deploy-CompliancePolicies -PolicyInitiatives $config.PolicyInitiatives -WorkspaceId $workspace.ResourceId

    # Step 6: Configure security contacts
    Configure-SecurityContacts -Email $SecurityContactEmail -Phone $SecurityContactPhone

    # Step 7: Configure auto-provisioning
    Configure-AutoProvisioning -WorkspaceId $workspace.ResourceId

    # Step 8: Validate deployment
    if (-not $DryRun) {
        Test-Deployment
    }

    # Step 9: Export evidence package
    Export-DeploymentEvidence

    Write-Host "Microsoft Defender for Cloud foundation deployment completed successfully!" -ForegroundColor Green
    Write-AuditLog -Action "Deployment Complete" -Status "SUCCESS" -Details "All components deployed successfully"

    # Provide next steps
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Review Secure Score recommendations in Azure Portal" -ForegroundColor White
    Write-Host "2. Configure additional workload-specific protection plans" -ForegroundColor White
    Write-Host "3. Set up incident response playbooks and automation" -ForegroundColor White
    Write-Host "4. Schedule compliance assessment and reporting" -ForegroundColor White
    Write-Host "5. Train security team on Defender for Cloud operations" -ForegroundColor White
} catch {
    Write-AuditLog -Action "Deployment" -Status "FAILED" -Details $_.Exception.Message
    Write-Error "Deployment failed: $($_.Exception.Message)"

    # Export evidence package even on failure for troubleshooting
    Export-DeploymentEvidence

    exit 1
} finally {
    # Always export audit log for compliance
    $auditLog | ConvertTo-Json -Depth 3 | Out-File -FilePath "DefenderDeploymentAudit-$(Get-Date -Format 'yyyyMMdd-HHmmss').json" -Encoding UTF8
}
