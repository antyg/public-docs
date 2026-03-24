#
# PowerShell Module for Microsoft Defender for Cloud Scripts
#
# This module provides comprehensive PowerShell scripts for deploying, managing,
# troubleshooting, and monitoring Microsoft Defender for Cloud across enterprise environments.
#

# Set strict mode for better error handling
Set-StrictMode -Version Latest

# Module variables
$ModuleVersion = '1.0.0'
$ModuleName = 'DefenderForCloudScripts'

# Get the module root path
$ModuleRoot = $PSScriptRoot

Write-Verbose "Loading Microsoft Defender for Cloud Scripts Module v$ModuleVersion"
Write-Verbose "Module Root: $ModuleRoot"

# Function to check for required Azure modules
function Test-RequiredAzureModules {
    [CmdletBinding()]
    param()

    $RequiredModules = @(
        'Az.Accounts',
        'Az.Resources',
        'Az.Security',
        'Az.Monitor',
        'Az.OperationalInsights',
        'Az.Automation',
        'Az.LogicApp',
        'Az.KeyVault',
        'Az.Storage',
        'Az.Compute',
        'Az.Network'
    )

    $MissingModules = @()

    foreach ($Module in $RequiredModules) {
        if (-not (Get-Module -Name $Module -ListAvailable)) {
            $MissingModules += $Module
        }
    }

    if ($MissingModules.Count -gt 0) {
        Write-Warning "Missing required Azure PowerShell modules:"
        $MissingModules | ForEach-Object { Write-Warning "  - $_" }
        Write-Warning "Install missing modules with: Install-Module -Name Az -AllowClobber"
        return $false
    }

    return $true
}

# Function to validate Azure authentication
function Test-AzureAuthentication {
    [CmdletBinding()]
    param()

    try {
        $Context = Get-AzContext -ErrorAction SilentlyContinue
        if ($null -eq $Context) {
            Write-Warning "Not authenticated to Azure. Please run Connect-AzAccount first."
            return $false
        }

        Write-Verbose "Authenticated to Azure as: $($Context.Account.Id)"
        Write-Verbose "Subscription: $($Context.Subscription.Name) ($($Context.Subscription.Id))"
        Write-Verbose "Tenant: $($Context.Tenant.Id)"

        return $true
    } catch {
        Write-Warning "Error checking Azure authentication: $($_.Exception.Message)"
        return $false
    }
}

# Function to get script information
function Get-DefenderScriptInfo {
    <#
    .SYNOPSIS
    Gets information about available Microsoft Defender for Cloud scripts.

    .DESCRIPTION
    This function returns detailed information about all available scripts in the
    Microsoft Defender for Cloud Scripts module, including their purpose, parameters,
    and usage examples.

    .PARAMETER Category
    Filter scripts by category. Valid values: 'Deployment', 'Troubleshooting', 'Monitoring', 'All'

    .PARAMETER ScriptName
    Get information for a specific script name.

    .EXAMPLE
    Get-DefenderScriptInfo

    .EXAMPLE
    Get-DefenderScriptInfo -Category 'Deployment'

    .EXAMPLE
    Get-DefenderScriptInfo -ScriptName 'Deploy-EnterpriseScaleArchitecture'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Deployment', 'Troubleshooting', 'Monitoring', 'All')]
        [string]$Category = 'All',

        [Parameter(Mandatory = $false)]
        [string]$ScriptName
    )

    $Scripts = @{
        'Deployment'      = @{
            'Deploy-EnterpriseScaleArchitecture' = @{
                'Path'                 = 'Deployment\Deploy-EnterpriseScaleArchitecture.ps1'
                'Description'          = 'Deploys enterprise-scale Microsoft Defender for Cloud with multi-region redundancy and compliance frameworks'
                'Key Features'         = @(
                    'Multi-region deployment with failover capabilities',
                    'NIST, FedRAMP, and StateRAMP compliance support',
                    'Automated resource provisioning and configuration',
                    'Cross-region Log Analytics workspace setup'
                )
                'Required Permissions' = 'Security Admin, Contributor'
            }
            'Deploy-GovernmentSOC'               = @{
                'Path'                 = 'Deployment\Deploy-GovernmentSOC.ps1'
                'Description'          = 'Deploys Government Security Operations Center with 24x7x365 monitoring capabilities'
                'Key Features'         = @(
                    'Government cloud compatibility (Azure Government)',
                    'CJIS compliance support for law enforcement',
                    'Classification-based data retention policies',
                    'Automated incident response workflows',
                    'Digital forensics and incident response (DFIR) capabilities'
                )
                'Required Permissions' = 'Security Admin, Contributor'
            }
            'Deploy-DevSecOpsIntegration'        = @{
                'Path'                 = 'Deployment\Deploy-DevSecOpsIntegration.ps1'
                'Description'          = 'Integrates Microsoft Defender for Cloud with DevSecOps pipelines'
                'Key Features'         = @(
                    'Multi-platform support (Azure DevOps, GitHub, GitLab, Jenkins)',
                    'Infrastructure as Code (IaC) security scanning',
                    'Container vulnerability scanning',
                    'Static and Dynamic Application Security Testing',
                    'Automated security remediation'
                )
                'Required Permissions' = 'Security Admin, Contributor'
            }
        }
        'Troubleshooting' = @{
            'Test-DefenderDiagnostics'    = @{
                'Path'                 = 'Troubleshooting\Test-DefenderDiagnostics.ps1'
                'Description'          = 'Comprehensive diagnostics for Microsoft Defender for Cloud components'
                'Key Features'         = @(
                    'Agent deployment readiness testing',
                    'Network connectivity validation',
                    'Policy compliance assessment',
                    'API authentication verification',
                    'Automated issue remediation suggestions'
                )
                'Required Permissions' = 'Security Reader (Contributor for remediation)'
            }
            'Invoke-DefenderAPIWithRetry' = @{
                'Path'                 = 'Troubleshooting\Invoke-DefenderAPIWithRetry.ps1'
                'Description'          = 'Robust API client with retry logic and rate limiting mitigation'
                'Key Features'         = @(
                    'Exponential backoff retry logic',
                    'Rate limiting detection and handling',
                    'Comprehensive error reporting',
                    'Detailed request/response logging',
                    'Support case creation helper'
                )
                'Required Permissions' = 'Security Reader'
            }
        }
        'Monitoring'      = @{
            'Deploy-IncidentResponsePlaybooks' = @{
                'Path'                 = 'Monitoring\Deploy-IncidentResponsePlaybooks.ps1'
                'Description'          = 'Deploys comprehensive incident response playbooks and automation workflows'
                'Key Features'         = @(
                    'Automated threat detection and triage',
                    'Incident response workflow automation',
                    'Evidence collection and preservation',
                    'Stakeholder notification systems',
                    'Compliance reporting automation'
                )
                'Required Permissions' = 'Security Admin, Logic Apps Contributor'
            }
            'Deploy-ThreatHuntingCapabilities' = @{
                'Path'                 = 'Monitoring\Deploy-ThreatHuntingCapabilities.ps1'
                'Description'          = 'Deploys advanced threat hunting capabilities with KQL queries and automation'
                'Key Features'         = @(
                    'Pre-built threat hunting KQL queries',
                    'MITRE ATT&CK framework mapping',
                    'Automated hunting schedules',
                    'Threat intelligence feed integration',
                    'Custom detection rule support'
                )
                'Required Permissions' = 'Security Admin, Log Analytics Contributor'
            }
        }
    }

    if ($ScriptName) {
        # Find specific script
        foreach ($Cat in $Scripts.Keys) {
            if ($Scripts[$Cat].ContainsKey($ScriptName)) {
                $ScriptInfo = $Scripts[$Cat][$ScriptName]
                $ScriptInfo['Category'] = $Cat
                $ScriptInfo['Name'] = $ScriptName
                return $ScriptInfo
            }
        }
        Write-Warning "Script '$ScriptName' not found."
        return $null
    }

    if ($Category -eq 'All') {
        return $Scripts
    } else {
        return $Scripts[$Category]
    }
}

# Function to validate script prerequisites
function Test-DefenderScriptPrerequisites {
    <#
    .SYNOPSIS
    Validates prerequisites for running Microsoft Defender for Cloud scripts.

    .DESCRIPTION
    This function checks that all required Azure modules are installed,
    Azure authentication is configured, and necessary permissions are available.

    .EXAMPLE
    Test-DefenderScriptPrerequisites
    #>
    [CmdletBinding()]
    param()

    Write-Host "Validating Microsoft Defender for Cloud script prerequisites..." -ForegroundColor Yellow

    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -lt 5 -or ($PSVersion.Major -eq 5 -and $PSVersion.Minor -lt 1)) {
        Write-Error "PowerShell 5.1 or later is required. Current version: $($PSVersion.ToString())"
        return $false
    }
    Write-Host "✓ PowerShell version: $($PSVersion.ToString())" -ForegroundColor Green

    # Check Azure modules
    if (-not (Test-RequiredAzureModules)) {
        Write-Error "Required Azure PowerShell modules are missing."
        return $false
    }
    Write-Host "✓ Required Azure PowerShell modules are installed" -ForegroundColor Green

    # Check Azure authentication
    if (-not (Test-AzureAuthentication)) {
        Write-Error "Azure authentication is not configured."
        return $false
    }
    Write-Host "✓ Azure authentication is configured" -ForegroundColor Green

    # Check Azure context
    $Context = Get-AzContext
    if ($null -eq $Context.Subscription) {
        Write-Warning "No Azure subscription context set. Use Set-AzContext to select a subscription."
    } else {
        Write-Host "✓ Azure subscription context: $($Context.Subscription.Name)" -ForegroundColor Green
    }

    Write-Host "Prerequisites validation completed successfully!" -ForegroundColor Green
    return $true
}

# Function to get module help
function Get-DefenderScriptsHelp {
    <#
    .SYNOPSIS
    Gets help information for Microsoft Defender for Cloud Scripts module.

    .DESCRIPTION
    This function provides comprehensive help information about the Microsoft Defender
    for Cloud Scripts module, including available scripts, common usage patterns,
    and troubleshooting guidance.

    .EXAMPLE
    Get-DefenderScriptsHelp
    #>
    [CmdletBinding()]
    param()

    Write-Host @"

=== Microsoft Defender for Cloud Scripts Module Help ===

Version: $ModuleVersion
Module Root: $ModuleRoot

AVAILABLE SCRIPT CATEGORIES:

🏗️  DEPLOYMENT SCRIPTS
   Deploy-EnterpriseScaleArchitecture - Enterprise-scale deployment with compliance
   Deploy-GovernmentSOC              - Government SOC with 24x7x365 monitoring
   Deploy-DevSecOpsIntegration       - DevSecOps pipeline security integration

🔍 TROUBLESHOOTING SCRIPTS
   Test-DefenderDiagnostics          - Comprehensive diagnostics and troubleshooting
   Invoke-DefenderAPIWithRetry       - Robust API client with retry logic

📊 MONITORING SCRIPTS
   Deploy-IncidentResponsePlaybooks  - Automated incident response workflows
   Deploy-ThreatHuntingCapabilities  - Advanced threat hunting with KQL queries

QUICK START:

1. Validate prerequisites:
   Test-DefenderScriptPrerequisites

2. Get script information:
   Get-DefenderScriptInfo

3. Get help for specific scripts:
   Get-Help .\Deployment\Deploy-EnterpriseScaleArchitecture.ps1 -Detailed

4. Run scripts with proper parameters (see individual script help)

AUTHENTICATION:

For Azure Commercial:
   Connect-AzAccount
   Set-AzContext -SubscriptionId "your-subscription-id"

For Azure Government:
   Connect-AzAccount -Environment AzureUSGovernment
   Set-AzContext -SubscriptionId "your-subscription-id"

SUPPORT:

- Use Get-DefenderScriptInfo for script details
- Use Test-DefenderScriptPrerequisites to validate setup
- Review README.md for comprehensive documentation
- Use -Verbose parameter for detailed execution information

"@ -ForegroundColor Cyan
}

# Export module functions
Export-ModuleMember -Function @(
    'Get-DefenderScriptInfo',
    'Test-DefenderScriptPrerequisites',
    'Get-DefenderScriptsHelp'
)

# Module initialization
Write-Verbose "Microsoft Defender for Cloud Scripts Module loaded successfully"

# Display welcome message when module is imported
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "Microsoft Defender for Cloud Scripts Module v$ModuleVersion loaded" -ForegroundColor Green
    Write-Host "Use 'Get-DefenderScriptsHelp' for help and 'Get-DefenderScriptInfo' for script details" -ForegroundColor Yellow

    # Validate prerequisites on import
    if (-not (Test-DefenderScriptPrerequisites)) {
        Write-Warning "Some prerequisites are not met. Run 'Test-DefenderScriptPrerequisites' for details."
    }
}
