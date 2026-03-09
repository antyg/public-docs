#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources, Az.Security, Az.PolicyInsights

<#
.SYNOPSIS
    Exports Microsoft Defender for Cloud configuration for documentation and backup.

.DESCRIPTION
    This script exports the current Microsoft Defender for Cloud configuration including:
    - Pricing tiers and enablement status
    - Policy assignments and compliance status
    - Secure score information
    - Auto-provisioning settings
    - Workspace configurations

.PARAMETER OutputPath
    Directory path for exported configuration files (default: current directory)

.PARAMETER IncludeCompliance
    Include detailed compliance assessment data in export

.PARAMETER Format
    Output format for exports. Valid values: 'CSV', 'JSON', 'Both' (default: Both)

.EXAMPLE
    .\Export-DefenderConfiguration.ps1 -OutputPath "C:\DefenderBackup"

.EXAMPLE
    .\Export-DefenderConfiguration.ps1 -IncludeCompliance -Format JSON

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Security Reader permissions minimum
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeCompliance,

    [Parameter(Mandatory = $false)]
    [ValidateSet('CSV', 'JSON', 'Both')]
    [string]$Format = 'Both'
)

# Set error action preference
$ErrorActionPreference = 'Continue'

# Create timestamp for file naming
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Initialize configuration object
$defenderConfig = @{
    Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    Subscription      = $null
    PricingTiers      = @()
    PolicyAssignments = @()
    ComplianceState   = @()
    SecureScore       = $null
    AutoProvisioning  = @()
    WorkspaceSettings = @()
    ExportMetadata    = @{
        ExportedBy        = (Get-AzContext).Account.Id
        ExportTool        = "Export-DefenderConfiguration.ps1"
        Format            = $Format
        IncludeCompliance = $IncludeCompliance.IsPresent
    }
}

function Write-Status {
    param([string]$Message, [string]$Type = "Info")

    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "Cyan" }
    }

    Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Export-Data {
    param(
        [object]$Data,
        [string]$FileName,
        [string]$Format,
        [string]$Path
    )

    if ($Format -eq 'CSV' -or $Format -eq 'Both') {
        $csvPath = Join-Path $Path "$FileName.csv"
        try {
            $Data | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
            Write-Status "Exported to CSV: $csvPath" "Success"
        } catch {
            Write-Status "Failed to export CSV: $($_.Exception.Message)" "Error"
        }
    }

    if ($Format -eq 'JSON' -or $Format -eq 'Both') {
        $jsonPath = Join-Path $Path "$FileName.json"
        try {
            $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
            Write-Status "Exported to JSON: $jsonPath" "Success"
        } catch {
            Write-Status "Failed to export JSON: $($_.Exception.Message)" "Error"
        }
    }
}

# Validate prerequisites
Write-Status "Validating Azure authentication and permissions"
try {
    $context = Get-AzContext
    if (-not $context) {
        throw "Not authenticated to Azure. Please run Connect-AzAccount first."
    }

    $defenderConfig.Subscription = @{
        Id       = $context.Subscription.Id
        Name     = $context.Subscription.Name
        TenantId = $context.Tenant.Id
    }

    Write-Status "Authenticated as: $($context.Account.Id)" "Success"
    Write-Status "Subscription: $($context.Subscription.Name)" "Success"
} catch {
    Write-Status "Authentication validation failed: $($_.Exception.Message)" "Error"
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    try {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
        Write-Status "Created output directory: $OutputPath" "Success"
    } catch {
        Write-Status "Failed to create output directory: $($_.Exception.Message)" "Error"
        exit 1
    }
}

# Export pricing tiers
Write-Status "Exporting Defender for Cloud pricing tiers"
try {
    $pricingTiers = Get-AzSecurityPricing
    $defenderConfig.PricingTiers = $pricingTiers | ForEach-Object {
        @{
            Name                   = $_.Name
            PricingTier            = $_.PricingTier
            SubPlan                = $_.SubPlan
            FreeTrialRemainingTime = $_.FreeTrialRemainingTime
            EnablementTime         = $_.EnablementTime
        }
    }

    Export-Data -Data $defenderConfig.PricingTiers -FileName "DefenderPricingTiers-$timestamp" -Format $Format -Path $OutputPath
    Write-Status "Exported $($defenderConfig.PricingTiers.Count) pricing tier configurations" "Success"
} catch {
    Write-Status "Failed to export pricing tiers: $($_.Exception.Message)" "Error"
}

# Export policy assignments (security-related)
Write-Status "Exporting security policy assignments"
try {
    $securityPolicies = Get-AzPolicyAssignment | Where-Object {
        $_.Properties.displayName -like "*Security*" -or
        $_.Properties.displayName -like "*FedRAMP*" -or
        $_.Properties.displayName -like "*NIST*" -or
        $_.Properties.displayName -like "*Defender*"
    }

    $defenderConfig.PolicyAssignments = $securityPolicies | ForEach-Object {
        @{
            Name               = $_.Name
            DisplayName        = $_.Properties.displayName
            Description        = $_.Properties.description
            Scope              = $_.Properties.scope
            PolicyDefinitionId = $_.Properties.policyDefinitionId
            Parameters         = $_.Properties.parameters
            EnforcementMode    = $_.Properties.enforcementMode
        }
    }

    Export-Data -Data $defenderConfig.PolicyAssignments -FileName "SecurityPolicyAssignments-$timestamp" -Format $Format -Path $OutputPath
    Write-Status "Exported $($defenderConfig.PolicyAssignments.Count) security policy assignments" "Success"
} catch {
    Write-Status "Failed to export policy assignments: $($_.Exception.Message)" "Error"
}

# Export compliance state (if requested)
if ($IncludeCompliance) {
    Write-Status "Exporting compliance assessment data"
    try {
        $complianceStates = Get-AzPolicyState -All | Where-Object {
            $_.PolicyDefinitionName -like "*Security*" -or
            $_.PolicyDefinitionName -like "*FedRAMP*" -or
            $_.PolicyDefinitionName -like "*NIST*"
        }

        $defenderConfig.ComplianceState = $complianceStates | ForEach-Object {
            @{
                Timestamp              = $_.Timestamp
                ResourceId             = $_.ResourceId
                PolicyDefinitionName   = $_.PolicyDefinitionName
                ComplianceState        = $_.ComplianceState
                ResourceType           = $_.ResourceType
                ResourceLocation       = $_.ResourceLocation
                PolicyAssignmentName   = $_.PolicyAssignmentName
                PolicyDefinitionAction = $_.PolicyDefinitionAction
            }
        } | Select-Object -First 10000  # Limit to prevent large exports

        Export-Data -Data $defenderConfig.ComplianceState -FileName "ComplianceFindings-$timestamp" -Format $Format -Path $OutputPath
        Write-Status "Exported $($defenderConfig.ComplianceState.Count) compliance findings" "Success"
    } catch {
        Write-Status "Failed to export compliance data: $($_.Exception.Message)" "Error"
    }
}

# Export secure score
Write-Status "Exporting secure score information"
try {
    $secureScore = Get-AzSecurityScore -Name "ascScore"
    $secureScoreControls = Get-AzSecurityScoreControl

    $defenderConfig.SecureScore = @{
        CurrentScore = $secureScore.CurrentScore
        MaxScore     = $secureScore.MaxScore
        Percentage   = [math]::Round(($secureScore.CurrentScore / $secureScore.MaxScore) * 100, 2)
        Controls     = $secureScoreControls | ForEach-Object {
            @{
                DisplayName            = $_.DisplayName
                CurrentScore           = $_.CurrentScore
                MaxScore               = $_.MaxScore
                Percentage             = [math]::Round(($_.CurrentScore / $_.MaxScore) * 100, 2)
                UnhealthyResourceCount = $_.UnhealthyResourceCount
                HealthyResourceCount   = $_.HealthyResourceCount
            }
        }
    }

    Export-Data -Data $defenderConfig.SecureScore -FileName "SecureScore-$timestamp" -Format $Format -Path $OutputPath
    Write-Status "Exported secure score: $($defenderConfig.SecureScore.CurrentScore)/$($defenderConfig.SecureScore.MaxScore) ($($defenderConfig.SecureScore.Percentage)%)" "Success"
} catch {
    Write-Status "Failed to export secure score: $($_.Exception.Message)" "Error"
}

# Export auto-provisioning settings
Write-Status "Exporting auto-provisioning settings"
try {
    $autoProvisioningSettings = Get-AzSecurityAutoProvisioningSetting
    $defenderConfig.AutoProvisioning = $autoProvisioningSettings | ForEach-Object {
        @{
            Name          = $_.Name
            AutoProvision = $_.AutoProvision
        }
    }

    Export-Data -Data $defenderConfig.AutoProvisioning -FileName "AutoProvisioningSettings-$timestamp" -Format $Format -Path $OutputPath
    Write-Status "Exported $($defenderConfig.AutoProvisioning.Count) auto-provisioning settings" "Success"
} catch {
    Write-Status "Failed to export auto-provisioning settings: $($_.Exception.Message)" "Error"
}

# Export workspace settings
Write-Status "Exporting workspace settings"
try {
    $workspaceSettings = Get-AzSecurityWorkspaceSetting
    $defenderConfig.WorkspaceSettings = $workspaceSettings | ForEach-Object {
        @{
            Name        = $_.Name
            WorkspaceId = $_.WorkspaceId
            Scope       = $_.Scope
        }
    }

    Export-Data -Data $defenderConfig.WorkspaceSettings -FileName "WorkspaceSettings-$timestamp" -Format $Format -Path $OutputPath
    Write-Status "Exported $($defenderConfig.WorkspaceSettings.Count) workspace settings" "Success"
} catch {
    Write-Status "Failed to export workspace settings: $($_.Exception.Message)" "Error"
}

# Export complete configuration
Write-Status "Exporting complete configuration summary"
try {
    $summaryPath = Join-Path $OutputPath "DefenderConfiguration-Complete-$timestamp.json"
    $defenderConfig | ConvertTo-Json -Depth 15 | Out-File -FilePath $summaryPath -Encoding UTF8
    Write-Status "Complete configuration exported to: $summaryPath" "Success"
} catch {
    Write-Status "Failed to export complete configuration: $($_.Exception.Message)" "Error"
}

# Generate summary report
Write-Host ""
Write-Host "Microsoft Defender for Cloud Configuration Export Complete" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

Write-Status "Export Summary:" "Info"
Write-Host "  • Subscription: $($defenderConfig.Subscription.Name)" -ForegroundColor White
Write-Host "  • Timestamp: $($defenderConfig.Timestamp)" -ForegroundColor White
Write-Host "  • Output Path: $OutputPath" -ForegroundColor White
Write-Host "  • Format: $Format" -ForegroundColor White
Write-Host "  • Pricing Tiers: $($defenderConfig.PricingTiers.Count)" -ForegroundColor White
Write-Host "  • Policy Assignments: $($defenderConfig.PolicyAssignments.Count)" -ForegroundColor White
Write-Host "  • Auto-Provisioning Settings: $($defenderConfig.AutoProvisioning.Count)" -ForegroundColor White
Write-Host "  • Workspace Settings: $($defenderConfig.WorkspaceSettings.Count)" -ForegroundColor White

if ($IncludeCompliance) {
    Write-Host "  • Compliance Findings: $($defenderConfig.ComplianceState.Count)" -ForegroundColor White
}

Write-Host ""
Write-Status "Configuration export completed successfully. Files are ready for backup or documentation." "Success"
