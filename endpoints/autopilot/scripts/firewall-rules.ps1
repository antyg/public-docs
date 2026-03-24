<#
.SYNOPSIS
Windows Firewall configuration for Windows Autopilot endpoints

.DESCRIPTION
Creates Windows Firewall rules to allow Windows Autopilot traffic through corporate firewalls.
This script configures outbound rules for all required Autopilot service endpoints.

.PARAMETER RemoveExisting
Remove any existing Autopilot firewall rules before creating new ones

.PARAMETER TestConnectivity
Test connectivity to endpoints after creating firewall rules

.EXAMPLE
.\firewall-rules.ps1

.EXAMPLE
.\firewall-rules.ps1 -RemoveExisting -TestConnectivity

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Administrative privileges
Compatible: Windows 10/11, Windows Server 2016+
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$RemoveExisting,

    [Parameter(Mandatory=$false)]
    [switch]$TestConnectivity
)

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires administrative privileges. Please run PowerShell as Administrator."
    exit 1
}

try {
    Write-Output "Configuring Windows Firewall for Windows Autopilot..."

    # Remove existing rules if requested
    if ($RemoveExisting) {
        Write-Output "Removing existing Autopilot firewall rules..."
        Get-NetFirewallRule -DisplayName "Windows Autopilot*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
        Get-NetFirewallRule -DisplayName "Certificate Validation" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
        Get-NetFirewallRule -DisplayName "Time Synchronization" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    }

    # Define Autopilot service endpoints
    $autopilotRules = @(
        @{
            DisplayName = "Windows Autopilot - Registration"
            Description = "Allow access to Autopilot device registration services"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("ztd.dds.microsoft.com", "cs.dds.microsoft.com")
        },
        @{
            DisplayName = "Windows Autopilot - Management"
            Description = "Allow access to Intune management services"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("*.manage.microsoft.com", "manage.microsoft.com")
        },
        @{
            DisplayName = "Windows Autopilot - Authentication"
            Description = "Allow access to Azure AD authentication services"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("login.microsoftonline.com", "login.microsoft.com", "account.microsoft.com")
        },
        @{
            DisplayName = "Windows Autopilot - Device Registration"
            Description = "Allow access to device registration endpoints"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("enterpriseregistration.windows.net", "device.login.microsoftonline.com")
        },
        @{
            DisplayName = "Windows Autopilot - Graph API"
            Description = "Allow access to Microsoft Graph API"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("graph.microsoft.com", "graph.windows.net")
        }
    )

    # Windows Update and Delivery Optimization rules
    $updateRules = @(
        @{
            DisplayName = "Windows Autopilot - Windows Update"
            Description = "Allow Windows Update during Autopilot deployment"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("*.windowsupdate.com", "windowsupdate.microsoft.com", "update.microsoft.com")
        },
        @{
            DisplayName = "Windows Autopilot - Delivery Optimization"
            Description = "Allow Delivery Optimization for app downloads"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("*.delivery.mp.microsoft.com", "*.do.dsp.mp.microsoft.com")
        },
        @{
            DisplayName = "Windows Autopilot - Microsoft Store"
            Description = "Allow Microsoft Store app downloads"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("*.apps.microsoft.com", "storeedgefd.dsx.mp.microsoft.com")
        }
    )

    # Certificate and supporting service rules
    $supportingRules = @(
        @{
            DisplayName = "Certificate Validation"
            Description = "Allow certificate validation services"
            Protocol = "TCP"
            Port = 443
            RemoteAddress = @("crl.microsoft.com", "www.microsoft.com", "ctldl.windowsupdate.com")
        },
        @{
            DisplayName = "Time Synchronization"
            Description = "Allow NTP time synchronization"
            Protocol = "UDP"
            Port = 123
            RemoteAddress = @("time.windows.com")
        }
    )

    # Function to create firewall rules
    function New-AutopilotFirewallRule {
        param($RuleConfig)

        foreach ($address in $RuleConfig.RemoteAddress) {
            $ruleName = "$($RuleConfig.DisplayName) - $address"

            try {
                if ($RuleConfig.Protocol -eq "TCP") {
                    New-NetFirewallRule -DisplayName $ruleName `
                                        -Description $RuleConfig.Description `
                                        -Direction Outbound `
                                        -Protocol TCP `
                                        -RemotePort $RuleConfig.Port `
                                        -RemoteAddress $address `
                                        -Action Allow `
                                        -Profile Any `
                                        -ErrorAction Stop
                } else {
                    New-NetFirewallRule -DisplayName $ruleName `
                                        -Description $RuleConfig.Description `
                                        -Direction Outbound `
                                        -Protocol UDP `
                                        -RemotePort $RuleConfig.Port `
                                        -RemoteAddress $address `
                                        -Action Allow `
                                        -Profile Any `
                                        -ErrorAction Stop
                }
                Write-Output "  ✅ Created rule: $ruleName"
            } catch {
                Write-Warning "  ⚠️ Failed to create rule: $ruleName - $($_.Exception.Message)"
            }
        }
    }

    # Create all firewall rules
    Write-Output "Creating Autopilot service rules..."
    foreach ($rule in $autopilotRules) {
        New-AutopilotFirewallRule -RuleConfig $rule
    }

    Write-Output "Creating Windows Update rules..."
    foreach ($rule in $updateRules) {
        New-AutopilotFirewallRule -RuleConfig $rule
    }

    Write-Output "Creating supporting service rules..."
    foreach ($rule in $supportingRules) {
        New-AutopilotFirewallRule -RuleConfig $rule
    }

    # Test connectivity if requested
    if ($TestConnectivity) {
        Write-Output ""
        Write-Output "Testing connectivity to key Autopilot endpoints..."

        $testEndpoints = @(
            "login.microsoftonline.com",
            "manage.microsoft.com",
            "enterpriseregistration.windows.net",
            "ztd.dds.microsoft.com",
            "graph.microsoft.com"
        )

        foreach ($endpoint in $testEndpoints) {
            try {
                $result = Test-NetConnection -ComputerName $endpoint -Port 443 -WarningAction SilentlyContinue
                if ($result.TcpTestSucceeded) {
                    Write-Output "  ✅ $endpoint : Connected"
                } else {
                    Write-Output "  ❌ $endpoint : Failed"
                }
            } catch {
                Write-Output "  ❌ $endpoint : Error - $($_.Exception.Message)"
            }
        }
    }

    Write-Output ""
    Write-Output "🎉 Windows Firewall configuration for Autopilot completed successfully!"
    Write-Output ""
    Write-Output "Next Steps:"
    Write-Output "1. Test Autopilot deployment in your environment"
    Write-Output "2. Monitor firewall logs for any blocked connections"
    Write-Output "3. Update rules as Microsoft adds new endpoints"
    Write-Output "4. Consider implementing proxy bypass rules if using a corporate proxy"

} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}