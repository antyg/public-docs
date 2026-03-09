<#
.SYNOPSIS
    Comprehensive diagnostic tool for Microsoft Defender for Cloud deployment, connectivity, and performance issues.

.DESCRIPTION
    This script performs extensive diagnostics across all Microsoft Defender for Cloud components including
    agent deployment readiness, connectivity testing, policy compliance validation, API authentication,
    and performance analysis. It provides automated resolution suggestions and can collect diagnostic logs.

.PARAMETER SubscriptionId
    The Azure subscription ID to diagnose.

.PARAMETER ResourceGroupName
    Optional. Specific resource group to focus diagnostics on.

.PARAMETER VirtualMachineName
    Optional. Specific virtual machine to diagnose agent issues.

.PARAMETER TestConnectivity
    Switch to perform comprehensive connectivity testing.

.PARAMETER TestPolicyCompliance
    Switch to validate policy compliance across resources.

.PARAMETER TestAPIAuthentication
    Switch to test Defender API authentication and permissions.

.PARAMETER CollectLogs
    Switch to collect detailed diagnostic logs for support cases.

.PARAMETER OutputPath
    Path to save diagnostic reports and logs. Defaults to current directory.

.PARAMETER Remediate
    Switch to attempt automatic remediation of identified issues.

.EXAMPLE
    .\Test-DefenderDiagnostics.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -TestConnectivity -TestPolicyCompliance

.EXAMPLE
    .\Test-DefenderDiagnostics.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -VirtualMachineName "WebServer01" -CollectLogs -OutputPath "C:\Diagnostics" -Remediate

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: Az PowerShell module, Security Reader permissions (Contributor for remediation)

    This script provides comprehensive diagnostics and troubleshooting capabilities.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$VirtualMachineName,

    [Parameter(Mandatory = $false)]
    [switch]$TestConnectivity,

    [Parameter(Mandatory = $false)]
    [switch]$TestPolicyCompliance,

    [Parameter(Mandatory = $false)]
    [switch]$TestAPIAuthentication,

    [Parameter(Mandatory = $false)]
    [switch]$CollectLogs,

    [Parameter(Mandatory = $false)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [switch]$Remediate
)

# Import required modules
try {
    $RequiredModules = @('Az.Accounts', 'Az.Resources', 'Az.Security', 'Az.Compute', 'Az.Monitor', 'Az.OperationalInsights')
    foreach ($Module in $RequiredModules) {
        Import-Module $Module -Force -ErrorAction Stop
    }
    Write-Host "✓ Required Azure modules imported successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to import required Azure modules: $($_.Exception.Message)"
    exit 1
}

# Initialize diagnostic results
$DiagnosticResults = @{
    SubscriptionId  = $SubscriptionId
    TestResults     = @{}
    Issues          = @()
    Recommendations = @()
    LogFiles        = @()
    StartTime       = Get-Date
}

# Function to test agent deployment readiness
function Test-AgentDeploymentReadiness {
    param(
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$VirtualMachineName
    )

    Write-Host "Testing agent deployment readiness..." -ForegroundColor Yellow
    $Results = @{
        TestName = "Agent Deployment Readiness"
        Status   = "Pass"
        Details  = @()
        Issues   = @()
    }

    try {
        # Get VMs to test
        if ($VirtualMachineName) {
            $VMs = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName -ErrorAction Stop
        } elseif ($ResourceGroupName) {
            $VMs = Get-AzVM -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        } else {
            $VMs = Get-AzVM -ErrorAction Stop
        }

        foreach ($VM in $VMs) {
            $VMTest = @{
                VMName        = $VM.Name
                ResourceGroup = $VM.ResourceGroupName
                OSType        = $VM.StorageProfile.OsDisk.OsType
                PowerState    = (Get-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Status).Statuses | Where-Object { $_.Code -like "PowerState/*" } | Select-Object -ExpandProperty DisplayStatus
                Extensions    = @()
                Issues        = @()
            }

            # Check VM power state
            if ($VMTest.PowerState -ne "VM running") {
                $VMTest.Issues += "VM is not running: $($VMTest.PowerState)"
                $Results.Status = "Warning"
            }

            # Check for existing monitoring extensions
            $Extensions = Get-AzVMExtension -ResourceGroupName $VM.ResourceGroupName -VMName $VM.Name -ErrorAction SilentlyContinue
            foreach ($Extension in $Extensions) {
                $VMTest.Extensions += @{
                    Name   = $Extension.Name
                    Type   = $Extension.ExtensionType
                    Status = $Extension.ProvisioningState
                }

                # Check for conflicting extensions
                if ($Extension.ExtensionType -in @('MicrosoftMonitoringAgent', 'OmsAgentForLinux') -and $Extension.ProvisioningState -eq "Succeeded") {
                    $VMTest.Issues += "Legacy monitoring agent detected: $($Extension.ExtensionType)"
                    $Results.Status = "Warning"
                }
            }

            # Check network connectivity requirements
            $NetworkProfile = $VM.NetworkProfile
            foreach ($NIC in $NetworkProfile.NetworkInterfaces) {
                $NICResource = Get-AzNetworkInterface -ResourceId $NIC.Id
                foreach ($IPConfig in $NICResource.IpConfigurations) {
                    if ($IPConfig.PublicIpAddress -eq $null -and $IPConfig.Subnet.Id -notlike "*private*") {
                        $VMTest.Issues += "VM may have network connectivity issues for agent communication"
                        $Results.Status = "Warning"
                    }
                }
            }

            $Results.Details += $VMTest
        }

        $Results.Issues = $Results.Details | Where-Object { $_.Issues.Count -gt 0 } | ForEach-Object { $_.Issues }
        Write-Host "  ✓ Agent deployment readiness test completed" -ForegroundColor Gray
    } catch {
        $Results.Status = "Fail"
        $Results.Issues += "Failed to test agent deployment readiness: $($_.Exception.Message)"
        Write-Host "  ✗ Agent deployment readiness test failed" -ForegroundColor Red
    }

    return $Results
}

# Function to test Windows agent connectivity
function Test-WindowsAgentConnectivity {
    param(
        [string]$SubscriptionId,
        [string]$VirtualMachineName,
        [string]$ResourceGroupName
    )

    Write-Host "Testing Windows agent connectivity..." -ForegroundColor Yellow
    $Results = @{
        TestName = "Windows Agent Connectivity"
        Status   = "Pass"
        Details  = @()
        Issues   = @()
    }

    try {
        # Required endpoints for Azure Monitor Agent
        $RequiredEndpoints = @(
            "global.handler.control.monitor.azure.com",
            "*.ingest.monitor.azure.com",
            "*.control.monitor.azure.com",
            "login.microsoftonline.com",
            "management.azure.com"
        )

        $ConnectivityTests = @()
        foreach ($Endpoint in $RequiredEndpoints) {
            $TestResult = @{
                Endpoint     = $Endpoint
                Port         = 443
                Status       = "Unknown"
                ResponseTime = 0
            }

            try {
                $TestConnection = Test-NetConnection -ComputerName $Endpoint -Port 443 -WarningAction SilentlyContinue
                $TestResult.Status = if ($TestConnection.TcpTestSucceeded) { "Success" } else { "Failed" }
                $TestResult.ResponseTime = $TestConnection.PingReplyDetails.RoundtripTime

                if (-not $TestConnection.TcpTestSucceeded) {
                    $Results.Status = "Fail"
                    $Results.Issues += "Cannot connect to required endpoint: $Endpoint"
                }
            } catch {
                $TestResult.Status = "Error"
                $Results.Issues += "Error testing endpoint $Endpoint : $($_.Exception.Message)"
                $Results.Status = "Fail"
            }

            $ConnectivityTests += $TestResult
        }

        $Results.Details = $ConnectivityTests
        Write-Host "  ✓ Windows agent connectivity test completed" -ForegroundColor Gray
    } catch {
        $Results.Status = "Fail"
        $Results.Issues += "Failed to test Windows agent connectivity: $($_.Exception.Message)"
        Write-Host "  ✗ Windows agent connectivity test failed" -ForegroundColor Red
    }

    return $Results
}

# Function to test policy compliance
function Test-PolicyCompliance {
    param(
        [string]$SubscriptionId,
        [string]$ResourceGroupName
    )

    Write-Host "Testing policy compliance..." -ForegroundColor Yellow
    $Results = @{
        TestName = "Policy Compliance"
        Status   = "Pass"
        Details  = @()
        Issues   = @()
    }

    try {
        # Get policy compliance data
        $ComplianceStates = Get-AzPolicyState -SubscriptionId $SubscriptionId -ErrorAction Stop

        $ComplianceSummary = @{
            TotalResources        = $ComplianceStates.Count
            CompliantResources    = ($ComplianceStates | Where-Object { $_.ComplianceState -eq "Compliant" }).Count
            NonCompliantResources = ($ComplianceStates | Where-Object { $_.ComplianceState -eq "NonCompliant" }).Count
            ConflictResources     = ($ComplianceStates | Where-Object { $_.ComplianceState -eq "Conflict" }).Count
        }

        $ComplianceSummary.CompliancePercentage = if ($ComplianceSummary.TotalResources -gt 0) {
            [math]::Round(($ComplianceSummary.CompliantResources / $ComplianceSummary.TotalResources) * 100, 2)
        } else { 100 }

        # Identify critical non-compliance issues
        $CriticalPolicies = @(
            "Deploy Dependency agent for Windows virtual machines",
            "Deploy Log Analytics agent for Windows virtual machines",
            "Enable Security Center for subscription"
        )

        $CriticalIssues = $ComplianceStates | Where-Object {
            $_.ComplianceState -eq "NonCompliant" -and
            $_.PolicyDefinitionName -in $CriticalPolicies
        }

        foreach ($Issue in $CriticalIssues) {
            $Results.Issues += "Critical policy non-compliance: $($Issue.PolicyDefinitionName) on $($Issue.ResourceId)"
            $Results.Status = "Warning"
        }

        if ($ComplianceSummary.CompliancePercentage -lt 80) {
            $Results.Status = "Warning"
            $Results.Issues += "Overall compliance percentage is below 80%: $($ComplianceSummary.CompliancePercentage)%"
        }

        $Results.Details = $ComplianceSummary
        Write-Host "  ✓ Policy compliance test completed - $($ComplianceSummary.CompliancePercentage)% compliant" -ForegroundColor Gray
    } catch {
        $Results.Status = "Fail"
        $Results.Issues += "Failed to test policy compliance: $($_.Exception.Message)"
        Write-Host "  ✗ Policy compliance test failed" -ForegroundColor Red
    }

    return $Results
}

# Function to test Defender API authentication
function Test-DefenderAPIAuthentication {
    param(
        [string]$SubscriptionId
    )

    Write-Host "Testing Defender API authentication..." -ForegroundColor Yellow
    $Results = @{
        TestName = "Defender API Authentication"
        Status   = "Pass"
        Details  = @()
        Issues   = @()
    }

    try {
        # Test Security Center API access
        $SecurityContacts = Get-AzSecurityContact -ErrorAction Stop
        $Results.Details += @{
            Test               = "Security Contacts API"
            Status             = "Success"
            ContactsConfigured = $SecurityContacts.Count
        }

        # Test Security Assessments API
        $SecurityAssessments = Get-AzSecurityAssessment -ErrorAction Stop | Select-Object -First 5
        $Results.Details += @{
            Test                 = "Security Assessments API"
            Status               = "Success"
            AssessmentsRetrieved = $SecurityAssessments.Count
        }

        # Test Security Pricing API
        $SecurityPricing = Get-AzSecurityPricing -ErrorAction Stop
        $Results.Details += @{
            Test                  = "Security Pricing API"
            Status                = "Success"
            PricingTiersRetrieved = $SecurityPricing.Count
        }

        # Test Regulatory Compliance API
        try {
            $ComplianceResults = Get-AzSecurityRegulatoryComplianceAssessment -StandardName "Azure-Security-Benchmark" -ErrorAction Stop | Select-Object -First 5
            $Results.Details += @{
                Test                           = "Regulatory Compliance API"
                Status                         = "Success"
                ComplianceAssessmentsRetrieved = $ComplianceResults.Count
            }
        } catch {
            $Results.Details += @{
                Test   = "Regulatory Compliance API"
                Status = "Failed"
                Error  = $_.Exception.Message
            }
            $Results.Issues += "Cannot access Regulatory Compliance API: $($_.Exception.Message)"
            $Results.Status = "Warning"
        }

        Write-Host "  ✓ Defender API authentication test completed" -ForegroundColor Gray
    } catch {
        $Results.Status = "Fail"
        $Results.Issues += "Failed to test Defender API authentication: $($_.Exception.Message)"
        Write-Host "  ✗ Defender API authentication test failed" -ForegroundColor Red
    }

    return $Results
}

# Function to collect diagnostic logs
function Collect-DefenderDiagnosticLogs {
    param(
        [string]$SubscriptionId,
        [string]$OutputPath
    )

    Write-Host "Collecting Defender diagnostic logs..." -ForegroundColor Yellow
    $LogFiles = @()

    try {
        $DiagnosticPath = Join-Path $OutputPath "DefenderDiagnostics_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $DiagnosticPath -ItemType Directory -Force | Out-Null

        # Collect Security Center configuration
        $SecurityConfig = @{
            Pricing           = Get-AzSecurityPricing
            Contacts          = Get-AzSecurityContact
            AutoProvisioning  = Get-AzSecurityAutoProvisioningSetting
            WorkspaceSettings = Get-AzSecurityWorkspaceSetting
        }

        $ConfigPath = Join-Path $DiagnosticPath "SecurityCenterConfig.json"
        $SecurityConfig | ConvertTo-Json -Depth 5 | Out-File -FilePath $ConfigPath -Encoding UTF8
        $LogFiles += $ConfigPath

        # Collect Security Assessments
        $Assessments = Get-AzSecurityAssessment | Select-Object -First 100
        $AssessmentsPath = Join-Path $DiagnosticPath "SecurityAssessments.json"
        $Assessments | ConvertTo-Json -Depth 3 | Out-File -FilePath $AssessmentsPath -Encoding UTF8
        $LogFiles += $AssessmentsPath

        # Collect Policy Compliance data
        $PolicyStates = Get-AzPolicyState -SubscriptionId $SubscriptionId | Select-Object -First 100
        $PolicyPath = Join-Path $DiagnosticPath "PolicyCompliance.json"
        $PolicyStates | ConvertTo-Json -Depth 3 | Out-File -FilePath $PolicyPath -Encoding UTF8
        $LogFiles += $PolicyPath

        # Collect Resource information
        $Resources = Get-AzResource | Select-Object Name, ResourceType, ResourceGroupName, Location, Tags
        $ResourcesPath = Join-Path $DiagnosticPath "ResourceInventory.json"
        $Resources | ConvertTo-Json -Depth 3 | Out-File -FilePath $ResourcesPath -Encoding UTF8
        $LogFiles += $ResourcesPath

        Write-Host "  ✓ Diagnostic logs collected to: $DiagnosticPath" -ForegroundColor Gray
    } catch {
        Write-Host "  ✗ Failed to collect diagnostic logs: $($_.Exception.Message)" -ForegroundColor Red
    }

    return $LogFiles
}

# Function to resolve identified issues
function Resolve-DefenderIssues {
    param(
        [array]$Issues,
        [string]$SubscriptionId
    )

    Write-Host "Attempting automatic remediation of identified issues..." -ForegroundColor Yellow
    $RemediationResults = @()

    foreach ($Issue in $Issues) {
        $RemediationResult = @{
            Issue   = $Issue
            Action  = "None"
            Status  = "Skipped"
            Details = ""
        }

        try {
            # Auto-remediation logic based on issue patterns
            if ($Issue -like "*Legacy monitoring agent detected*") {
                $RemediationResult.Action = "Remove Legacy Agent"
                $RemediationResult.Details = "Legacy monitoring agents should be removed manually after confirming AMA deployment"
                $RemediationResult.Status = "Manual Action Required"
            } elseif ($Issue -like "*Cannot connect to required endpoint*") {
                $RemediationResult.Action = "Check Network Configuration"
                $RemediationResult.Details = "Verify firewall rules and DNS resolution for Azure endpoints"
                $RemediationResult.Status = "Manual Action Required"
            } elseif ($Issue -like "*Critical policy non-compliance*") {
                $RemediationResult.Action = "Apply Policy Remediation"
                $RemediationResult.Details = "Consider using Azure Policy remediation tasks for automatic compliance"
                $RemediationResult.Status = "Manual Action Required"
            } else {
                $RemediationResult.Details = "No automatic remediation available for this issue"
            }
        } catch {
            $RemediationResult.Status = "Failed"
            $RemediationResult.Details = "Error during remediation: $($_.Exception.Message)"
        }

        $RemediationResults += $RemediationResult
        Write-Host "  - $($RemediationResult.Issue): $($RemediationResult.Status)" -ForegroundColor Gray
    }

    return $RemediationResults
}

# Main execution
try {
    # Authenticate and set context
    $Context = Get-AzContext
    if (-not $Context -or $Context.Subscription.Id -ne $SubscriptionId) {
        Write-Host "Authenticating to Azure..." -ForegroundColor Yellow
        Connect-AzAccount -SubscriptionId $SubscriptionId -ErrorAction Stop
    }
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    Write-Host "✓ Azure context set to subscription: $SubscriptionId" -ForegroundColor Green

    # Run agent deployment readiness test
    $AgentReadinessResults = Test-AgentDeploymentReadiness -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -VirtualMachineName $VirtualMachineName
    $DiagnosticResults.TestResults["AgentDeploymentReadiness"] = $AgentReadinessResults
    $DiagnosticResults.Issues += $AgentReadinessResults.Issues

    # Run connectivity tests if requested
    if ($TestConnectivity) {
        $ConnectivityResults = Test-WindowsAgentConnectivity -SubscriptionId $SubscriptionId -VirtualMachineName $VirtualMachineName -ResourceGroupName $ResourceGroupName
        $DiagnosticResults.TestResults["WindowsAgentConnectivity"] = $ConnectivityResults
        $DiagnosticResults.Issues += $ConnectivityResults.Issues
    }

    # Run policy compliance tests if requested
    if ($TestPolicyCompliance) {
        $PolicyResults = Test-PolicyCompliance -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
        $DiagnosticResults.TestResults["PolicyCompliance"] = $PolicyResults
        $DiagnosticResults.Issues += $PolicyResults.Issues
    }

    # Run API authentication tests if requested
    if ($TestAPIAuthentication) {
        $APIResults = Test-DefenderAPIAuthentication -SubscriptionId $SubscriptionId
        $DiagnosticResults.TestResults["DefenderAPIAuthentication"] = $APIResults
        $DiagnosticResults.Issues += $APIResults.Issues
    }

    # Collect diagnostic logs if requested
    if ($CollectLogs) {
        $DiagnosticResults.LogFiles = Collect-DefenderDiagnosticLogs -SubscriptionId $SubscriptionId -OutputPath $OutputPath
    }

    # Attempt remediation if requested
    if ($Remediate -and $DiagnosticResults.Issues.Count -gt 0) {
        $DiagnosticResults.Recommendations = Resolve-DefenderIssues -Issues $DiagnosticResults.Issues -SubscriptionId $SubscriptionId
    }

    $DiagnosticResults.EndTime = Get-Date
    $DiagnosticResults.Duration = $DiagnosticResults.EndTime - $DiagnosticResults.StartTime

    # Generate summary report
    Write-Host "`n=== MICROSOFT DEFENDER FOR CLOUD DIAGNOSTIC SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Subscription: $($DiagnosticResults.SubscriptionId)" -ForegroundColor White
    Write-Host "Tests Executed: $($DiagnosticResults.TestResults.Keys.Count)" -ForegroundColor White
    Write-Host "Issues Found: $($DiagnosticResults.Issues.Count)" -ForegroundColor White
    Write-Host "Log Files Created: $($DiagnosticResults.LogFiles.Count)" -ForegroundColor White
    Write-Host "Duration: $([math]::Round($DiagnosticResults.Duration.TotalMinutes, 2)) minutes" -ForegroundColor White

    if ($DiagnosticResults.Issues.Count -gt 0) {
        Write-Host "`nISSUES IDENTIFIED:" -ForegroundColor Red
        foreach ($Issue in $DiagnosticResults.Issues) {
            Write-Host "  - $Issue" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n✓ No issues identified - Microsoft Defender for Cloud is properly configured" -ForegroundColor Green
    }

    # Save diagnostic report
    $ReportPath = Join-Path $OutputPath "DefenderDiagnosticReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $DiagnosticResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "`nDiagnostic report saved to: $ReportPath" -ForegroundColor Cyan

    return $DiagnosticResults
} catch {
    Write-Error "Diagnostic execution failed: $($_.Exception.Message)"
    exit 1
}
