<#
.SYNOPSIS
Configure proxy settings for Windows Autopilot deployment

.DESCRIPTION
Configures system proxy settings to ensure Windows Autopilot services can access required endpoints
through corporate proxy infrastructure.

.PARAMETER ProxyServer
Proxy server address and port (e.g., "proxy.company.com:8080")

.PARAMETER ProxyBypass
Semicolon-separated list of addresses to bypass proxy

.PARAMETER ProxyAutoConfigURL
URL to proxy auto-configuration (PAC) file

.PARAMETER TestConnectivity
Test connectivity to key Autopilot endpoints after configuration

.EXAMPLE
.\proxy-configuration.ps1 -ProxyServer "proxy.company.com:8080" -TestConnectivity

.EXAMPLE
.\proxy-configuration.ps1 -ProxyServer "proxy.company.com:8080" -ProxyBypass "*.microsoft.com;*.microsoftonline.com;*.windows.net"

.EXAMPLE
.\proxy-configuration.ps1 -ProxyAutoConfigURL "http://proxy.company.com/proxy.pac" -TestConnectivity

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Administrative privileges
Compatible: Windows 10/11, Windows Server 2016+
#>

param(
    [Parameter(ParameterSetName='Manual', Mandatory=$true)]
    [string]$ProxyServer,

    [Parameter(ParameterSetName='Manual', Mandatory=$false)]
    [string]$ProxyBypass = "*.microsoft.com;*.microsoftonline.com;*.windows.net;*.windowsupdate.com",

    [Parameter(ParameterSetName='PAC', Mandatory=$true)]
    [string]$ProxyAutoConfigURL,

    [Parameter(Mandatory=$false)]
    [switch]$TestConnectivity
)

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires administrative privileges. Please run PowerShell as Administrator."
    exit 1
}

try {
    Write-Output "Configuring proxy settings for Windows Autopilot..."
    Write-Output "================================================"
    Write-Output ""

    if ($PSCmdlet.ParameterSetName -eq 'Manual') {
        Write-Output "Configuration Mode: Manual Proxy Server"
        Write-Output "Proxy Server: $ProxyServer"
        Write-Output "Proxy Bypass: $ProxyBypass"
        Write-Output ""

        # Configure WinHTTP proxy settings
        Write-Output "Configuring WinHTTP proxy settings..."
        $winHttpResult = netsh winhttp set proxy proxy-server="$ProxyServer" bypass-list="$ProxyBypass"

        if ($LASTEXITCODE -eq 0) {
            Write-Output "✅ WinHTTP proxy configuration successful"
        } else {
            throw "Failed to configure WinHTTP proxy: $winHttpResult"
        }

    } elseif ($PSCmdlet.ParameterSetName -eq 'PAC') {
        Write-Output "Configuration Mode: Proxy Auto-Configuration (PAC)"
        Write-Output "PAC URL: $ProxyAutoConfigURL"
        Write-Output ""

        # Test PAC file accessibility
        Write-Output "Testing PAC file accessibility..."
        try {
            $pacContent = Invoke-WebRequest -Uri $ProxyAutoConfigURL -UseBasicParsing -TimeoutSec 10
            Write-Output "✅ PAC file is accessible"
        } catch {
            Write-Warning "⚠️  Could not access PAC file: $($_.Exception.Message)"
        }

        # Configure WinHTTP with PAC file
        Write-Output "Configuring WinHTTP with PAC file..."
        $winHttpResult = netsh winhttp set proxy pac="$ProxyAutoConfigURL"

        if ($LASTEXITCODE -eq 0) {
            Write-Output "✅ WinHTTP PAC configuration successful"
        } else {
            throw "Failed to configure WinHTTP PAC: $winHttpResult"
        }
    }

    # Verify proxy configuration
    Write-Output ""
    Write-Output "Verifying proxy configuration..."
    $proxyConfig = netsh winhttp show proxy
    Write-Output "Current WinHTTP proxy configuration:"
    Write-Output $proxyConfig
    Write-Output ""

    # Test connectivity if requested
    if ($TestConnectivity) {
        Write-Output "Testing connectivity to Windows Autopilot endpoints..."
        Write-Output "======================================================"

        $testEndpoints = @(
            @{Name = "Azure AD Authentication"; Endpoint = "login.microsoftonline.com"; Port = 443},
            @{Name = "Intune Management"; Endpoint = "enrollment.manage.microsoft.com"; Port = 443},
            @{Name = "Device Registration"; Endpoint = "enterpriseregistration.windows.net"; Port = 443},
            @{Name = "Autopilot Service"; Endpoint = "ztd.dds.microsoft.com"; Port = 443},
            @{Name = "Microsoft Graph"; Endpoint = "graph.microsoft.com"; Port = 443}
        )

        $testResults = @()
        foreach ($endpoint in $testEndpoints) {
            Write-Output "Testing: $($endpoint.Name) ($($endpoint.Endpoint):$($endpoint.Port))"

            try {
                $result = Test-NetConnection -ComputerName $endpoint.Endpoint -Port $endpoint.Port -WarningAction SilentlyContinue
                if ($result.TcpTestSucceeded) {
                    Write-Output "  ✅ Connected successfully"
                    $testResults += [PSCustomObject]@{
                        Service = $endpoint.Name
                        Endpoint = $endpoint.Endpoint
                        Port = $endpoint.Port
                        Status = "Success"
                    }
                } else {
                    Write-Output "  ❌ Connection failed"
                    $testResults += [PSCustomObject]@{
                        Service = $endpoint.Name
                        Endpoint = $endpoint.Endpoint
                        Port = $endpoint.Port
                        Status = "Failed"
                    }
                }
            } catch {
                Write-Output "  ❌ Connection error: $($_.Exception.Message)"
                $testResults += [PSCustomObject]@{
                    Service = $endpoint.Name
                    Endpoint = $endpoint.Endpoint
                    Port = $endpoint.Port
                    Status = "Error"
                }
            }
        }

        Write-Output ""
        Write-Output "📊 CONNECTIVITY TEST SUMMARY"
        Write-Output "============================"
        $successful = ($testResults | Where-Object { $_.Status -eq "Success" }).Count
        $total = $testResults.Count

        Write-Output "Successful connections: $successful/$total"

        if ($successful -eq $total) {
            Write-Output "🎉 All Autopilot endpoints are accessible!"
        } else {
            Write-Output "⚠️  Some endpoints are not accessible. Check proxy configuration and firewall rules."
            Write-Output ""
            Write-Output "Failed Endpoints:"
            $testResults | Where-Object { $_.Status -ne "Success" } |
                ForEach-Object { Write-Output "  • $($_.Service): $($_.Endpoint):$($_.Port)" }
        }
    }

    Write-Output ""
    Write-Output "🎉 Proxy configuration completed successfully!"
    Write-Output ""
    Write-Output "Next Steps:"
    Write-Output "1. Test Windows Autopilot deployment in your environment"
    Write-Output "2. Monitor proxy logs for Autopilot-related traffic"
    Write-Output "3. Update proxy bypass rules as Microsoft adds new endpoints"
    Write-Output "4. Document proxy configuration for troubleshooting reference"

} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}