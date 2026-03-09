#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources, Az.Security

<#
.SYNOPSIS
    Tests connectivity and prerequisites for Microsoft Defender for Cloud deployment.

.DESCRIPTION
    This script validates network connectivity to required Azure endpoints,
    verifies authentication status, and checks licensing requirements for
    Microsoft Defender for Cloud deployment in government environments.

.PARAMETER Environment
    Specify Azure environment. Valid values: 'AzureCloud', 'AzureUSGovernment'

.PARAMETER TestType
    Type of test to perform. Valid values: 'Network', 'Authentication', 'All'

.EXAMPLE
    .\Test-DefenderPrerequisites.ps1 -Environment AzureCloud -TestType All

.EXAMPLE
    .\Test-DefenderPrerequisites.ps1 -Environment AzureUSGovernment -TestType Network

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Az PowerShell modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('AzureCloud', 'AzureUSGovernment')]
    [string]$Environment = 'AzureCloud',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Network', 'Authentication', 'All')]
    [string]$TestType = 'All'
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Function to test network connectivity
function Test-NetworkConnectivity {
    param([string]$Environment)

    Write-Host "Testing network connectivity for $Environment..." -ForegroundColor Yellow

    if ($Environment -eq 'AzureCloud') {
        $endpoints = @(
            @{Name = "Security Service"; Address = "security.microsoft.com"; Port = 443 },
            @{Name = "Authentication"; Address = "login.microsoftonline.com"; Port = 443 }
        )
    } else {
        $endpoints = @(
            @{Name = "Security Service (Gov)"; Address = "security.azure.us"; Port = 443 },
            @{Name = "Authentication (Gov)"; Address = "login.microsoftonline.us"; Port = 443 }
        )
    }

    $results = @()
    foreach ($endpoint in $endpoints) {
        try {
            $result = Test-NetConnection -ComputerName $endpoint.Address -Port $endpoint.Port -InformationLevel Quiet
            if ($result) {
                Write-Host "✓ $($endpoint.Name): Connected" -ForegroundColor Green
                $results += @{Endpoint = $endpoint.Name; Status = "Connected" }
            } else {
                Write-Warning "✗ $($endpoint.Name): Failed to connect"
                $results += @{Endpoint = $endpoint.Name; Status = "Failed" }
            }
        } catch {
            Write-Warning "✗ $($endpoint.Name): Error - $($_.Exception.Message)"
            $results += @{Endpoint = $endpoint.Name; Status = "Error" }
        }
    }

    return $results
}

# Function to test Azure authentication
function Test-AzureAuthentication {
    Write-Host "Testing Azure authentication..." -ForegroundColor Yellow

    try {
        $context = Get-AzContext -ErrorAction SilentlyContinue
        if ($null -eq $context) {
            Write-Warning "✗ Not authenticated to Azure. Please run Connect-AzAccount."
            return $false
        }

        Write-Host "✓ Authenticated as: $($context.Account.Id)" -ForegroundColor Green
        Write-Host "✓ Subscription: $($context.Subscription.Name)" -ForegroundColor Green
        Write-Host "✓ Tenant: $($context.Tenant.Id)" -ForegroundColor Green

        return $true
    } catch {
        Write-Warning "✗ Authentication check failed: $($_.Exception.Message)"
        return $false
    }
}

# Function to check Defender for Cloud status
function Test-DefenderStatus {
    Write-Host "Checking Defender for Cloud status..." -ForegroundColor Yellow

    try {
        $pricing = Get-AzSecurityPricing -ErrorAction SilentlyContinue
        if ($pricing) {
            Write-Host "✓ Defender for Cloud accessible" -ForegroundColor Green

            $cloudPosture = $pricing | Where-Object { $_.Name -eq "CloudPosture" }
            if ($cloudPosture) {
                Write-Host "✓ Foundational CSPM: $($cloudPosture.PricingTier)" -ForegroundColor Green
            }

            return $true
        } else {
            Write-Warning "✗ Unable to access Defender for Cloud pricing information"
            return $false
        }
    } catch {
        Write-Warning "✗ Error checking Defender status: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
Write-Host "Microsoft Defender for Cloud Prerequisites Test" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$testResults = @{
    NetworkConnectivity = $null
    Authentication      = $null
    DefenderStatus      = $null
}

# Test network connectivity
if ($TestType -eq 'Network' -or $TestType -eq 'All') {
    $testResults.NetworkConnectivity = Test-NetworkConnectivity -Environment $Environment
    Write-Host ""
}

# Test authentication
if ($TestType -eq 'Authentication' -or $TestType -eq 'All') {
    $testResults.Authentication = Test-AzureAuthentication
    Write-Host ""
}

# Test Defender for Cloud status (only if authenticated)
if ($TestType -eq 'All' -and $testResults.Authentication) {
    $testResults.DefenderStatus = Test-DefenderStatus
    Write-Host ""
}

# Summary
Write-Host "Prerequisites Test Summary" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

$allPassed = $true
if ($testResults.NetworkConnectivity) {
    $failedConnections = $testResults.NetworkConnectivity | Where-Object { $_.Status -ne "Connected" }
    if ($failedConnections) {
        Write-Host "⚠ Network connectivity issues detected" -ForegroundColor Yellow
        $allPassed = $false
    } else {
        Write-Host "✓ Network connectivity: All endpoints accessible" -ForegroundColor Green
    }
}

if ($null -ne $testResults.Authentication) {
    if ($testResults.Authentication) {
        Write-Host "✓ Azure authentication: Configured" -ForegroundColor Green
    } else {
        Write-Host "✗ Azure authentication: Not configured" -ForegroundColor Red
        $allPassed = $false
    }
}

if ($null -ne $testResults.DefenderStatus) {
    if ($testResults.DefenderStatus) {
        Write-Host "✓ Defender for Cloud: Accessible" -ForegroundColor Green
    } else {
        Write-Host "✗ Defender for Cloud: Issues detected" -ForegroundColor Red
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Host "✓ All prerequisites validated successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠ Some prerequisites require attention" -ForegroundColor Yellow
    exit 1
}
