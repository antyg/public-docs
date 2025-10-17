<#
.SYNOPSIS
    Tests network connectivity to Microsoft Defender for Endpoint cloud endpoints.

.DESCRIPTION
    Validates network connectivity to MDE cloud service endpoints including
    blob storage, telemetry services, and certificate validation URLs.
    Tests DNS resolution, TCP connectivity, and HTTPS response codes.

.PARAMETER Region
    MDE service region. Valid values: US, EU, UK, AU. Default: US

.PARAMETER TestProxy
    Switch to test proxy configuration and connectivity through proxy.

.PARAMETER Verbose
    Display detailed connectivity test results.

.EXAMPLE
    .\Test-MDEConnectivity.ps1

.EXAMPLE
    .\Test-MDEConnectivity.ps1 -Region EU -Verbose

.EXAMPLE
    .\Test-MDEConnectivity.ps1 -TestProxy

.REFERENCES
    Configure your network environment to ensure connectivity with Defender for Endpoint service
    https://learn.microsoft.com/en-us/defender-endpoint/configure-environment

    Verify client connectivity to Microsoft Defender for Endpoint service URLs
    https://learn.microsoft.com/en-us/defender-endpoint/verify-connectivity

    Resolve-DnsName PowerShell Cmdlet Reference
    https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname

    Test-NetConnection PowerShell Cmdlet Reference
    https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection

    Invoke-WebRequest PowerShell Cmdlet Reference
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest

    netsh winhttp Commands Reference
    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winhttp

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+, Administrator privileges (for some tests)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('US', 'EU', 'UK', 'AU')]
    [string]$Region = 'AU',

    [Parameter(Mandatory = $false)]
    [switch]$TestProxy
)

$ErrorActionPreference = 'Stop'

# Reference: https://learn.microsoft.com/en-us/defender-endpoint/configure-environment
# MDE regional endpoints for telemetry, cyber events, and command/control
$RegionEndpoints = @{
    US = @{
        Telemetry = 'us.vortex-win.data.microsoft.com'
        Cyber     = 'us-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-cus.microsoft.com'
    }
    EU = @{
        Telemetry = 'eu.vortex-win.data.microsoft.com'
        Cyber     = 'eu-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-neu.microsoft.com'
    }
    UK = @{
        Telemetry = 'uk.vortex-win.data.microsoft.com'
        Cyber     = 'uk-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-uks.microsoft.com'
    }
    AU = @{
        Telemetry = 'au.vortex-win.data.microsoft.com'
        Cyber     = 'au-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-aue.microsoft.com'
    }
}

# Reference: https://learn.microsoft.com/en-us/defender-endpoint/configure-environment
# Common endpoints required for MDE cloud connectivity
$CommonEndpoints = @(
    @{ Name = 'Blob Storage'; Url = '*.blob.core.windows.net'; TestUrl = 'winatpmanagement.blob.core.windows.net' }
    @{ Name = 'CRL Distribution'; Url = 'crl.microsoft.com'; TestUrl = 'crl.microsoft.com' }
    @{ Name = 'Certificate Validation'; Url = 'www.microsoft.com'; TestUrl = 'www.microsoft.com' }
    @{ Name = 'Windows Update'; Url = '*.windowsupdate.com'; TestUrl = 'fe3.delivery.mp.microsoft.com' }
)

function Test-EndpointConnectivity {
    param(
        [string]$Hostname,
        [int]$Port = 443,
        [string]$Name
    )

    $Result = [PSCustomObject]@{
        Name              = $Name
        Hostname          = $Hostname
        Port              = $Port
        DNSResolution     = $false
        IPAddress         = $null
        TCPConnection     = $false
        HTTPSResponse     = $false
        HTTPStatusCode    = $null
        ResponseTime      = $null
        ErrorMessage      = $null
        Status            = 'Unknown'
    }

    try {
        # Reference: https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname
        $DNSResult = Resolve-DnsName -Name $Hostname -Type A -ErrorAction SilentlyContinue
        if ($DNSResult) {
            $Result.DNSResolution = $true
            $Result.IPAddress = ($DNSResult | Where-Object Type -EQ 'A' | Select-Object -First 1).IPAddress
        }
        else {
            $Result.ErrorMessage = 'DNS resolution failed'
            $Result.Status = 'Failed'
            return $Result
        }

        # Reference: https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection
        $TCPTest = Test-NetConnection -ComputerName $Hostname -Port $Port -WarningAction SilentlyContinue
        if ($TCPTest.TcpTestSucceeded) {
            $Result.TCPConnection = $true
        }
        else {
            $Result.ErrorMessage = "TCP connection failed (Port $Port)"
            $Result.Status = 'Failed'
            return $Result
        }

        try {
            $StartTime = Get-Date
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest
            $WebRequest = Invoke-WebRequest -Uri "https://$Hostname" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            $EndTime = Get-Date

            $Result.HTTPSResponse = $true
            $Result.HTTPStatusCode = $WebRequest.StatusCode
            $Result.ResponseTime = [math]::Round(($EndTime - $StartTime).TotalMilliseconds, 2)

            if ($WebRequest.StatusCode -in @(200, 301, 302, 403, 404)) {
                $Result.Status = 'Success'
            }
            else {
                $Result.Status = 'Warning'
                $Result.ErrorMessage = "Unexpected HTTP status: $($WebRequest.StatusCode)"
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode.value__) {
                $Result.HTTPStatusCode = $_.Exception.Response.StatusCode.value__
                $Result.HTTPSResponse = $true
                $Result.Status = 'Success'
            }
            else {
                $Result.ErrorMessage = "HTTPS request failed: $($_.Exception.Message)"
                $Result.Status = 'Failed'
            }
        }
    }
    catch {
        $Result.ErrorMessage = $_.Exception.Message
        $Result.Status = 'Failed'
    }

    return $Result
}

function Get-ProxyConfiguration {
    try {
        # Reference: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winhttp
        $ProxySettings = netsh winhttp show proxy

        if ($ProxySettings -match 'Direct access \(no proxy server\)') {
            return [PSCustomObject]@{
                ProxyEnabled = $false
                ProxyServer  = 'None'
                BypassList   = 'N/A'
            }
        }
        elseif ($ProxySettings -match 'Proxy Server\(s\)\s+:\s+(.+)') {
            $ProxyServer = $Matches[1]
            $BypassList = if ($ProxySettings -match 'Bypass List\s+:\s+(.+)') { $Matches[1] } else { 'None' }

            return [PSCustomObject]@{
                ProxyEnabled = $true
                ProxyServer  = $ProxyServer
                BypassList   = $BypassList
            }
        }
        else {
            return [PSCustomObject]@{
                ProxyEnabled = $null
                ProxyServer  = 'Unable to determine'
                BypassList   = 'Unable to determine'
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            ProxyEnabled = $null
            ProxyServer  = "Error: $($_.Exception.Message)"
            BypassList   = 'N/A'
        }
    }
}

try {
    Write-Host '=== Microsoft Defender for Endpoint Connectivity Test ===' -ForegroundColor Cyan
    Write-Host "Region: $Region`n" -ForegroundColor Yellow

    if ($TestProxy) {
        Write-Host '=== Proxy Configuration ===' -ForegroundColor Yellow
        $ProxyConfig = Get-ProxyConfiguration
        Write-Host "Proxy Enabled: $($ProxyConfig.ProxyEnabled)"
        Write-Host "Proxy Server: $($ProxyConfig.ProxyServer)"
        Write-Host "Bypass List: $($ProxyConfig.BypassList)`n"
    }

    $AllResults = @()

    Write-Host "=== Testing Region-Specific Endpoints ($Region) ===" -ForegroundColor Yellow
    $RegionTests = $RegionEndpoints[$Region]

    foreach ($EndpointType in $RegionTests.Keys) {
        $Hostname = $RegionTests[$EndpointType]
        Write-Host "Testing $EndpointType endpoint: $Hostname..." -NoNewline

        $Result = Test-EndpointConnectivity -Hostname $Hostname -Name "$Region $EndpointType"

        if ($Result.Status -eq 'Success') {
            Write-Host ' OK' -ForegroundColor Green
        }
        elseif ($Result.Status -eq 'Warning') {
            Write-Host ' Warning' -ForegroundColor Yellow
        }
        else {
            Write-Host ' FAILED' -ForegroundColor Red
        }

        if ($VerbosePreference -eq 'Continue') {
            Write-Host "  DNS: $($Result.DNSResolution) | IP: $($Result.IPAddress)" -ForegroundColor Gray
            Write-Host "  TCP: $($Result.TCPConnection) | HTTP: $($Result.HTTPStatusCode) | Time: $($Result.ResponseTime)ms" -ForegroundColor Gray
            if ($Result.ErrorMessage) {
                Write-Host "  Error: $($Result.ErrorMessage)" -ForegroundColor Red
            }
        }

        $AllResults += $Result
    }

    Write-Host "`n=== Testing Common Endpoints ===" -ForegroundColor Yellow

    foreach ($Endpoint in $CommonEndpoints) {
        Write-Host "Testing $($Endpoint.Name): $($Endpoint.TestUrl)..." -NoNewline

        $Result = Test-EndpointConnectivity -Hostname $Endpoint.TestUrl -Name $Endpoint.Name

        if ($Result.Status -eq 'Success') {
            Write-Host ' OK' -ForegroundColor Green
        }
        elseif ($Result.Status -eq 'Warning') {
            Write-Host ' Warning' -ForegroundColor Yellow
        }
        else {
            Write-Host ' FAILED' -ForegroundColor Red
        }

        if ($VerbosePreference -eq 'Continue') {
            Write-Host "  DNS: $($Result.DNSResolution) | IP: $($Result.IPAddress)" -ForegroundColor Gray
            Write-Host "  TCP: $($Result.TCPConnection) | HTTP: $($Result.HTTPStatusCode) | Time: $($Result.ResponseTime)ms" -ForegroundColor Gray
            if ($Result.ErrorMessage) {
                Write-Host "  Error: $($Result.ErrorMessage)" -ForegroundColor Red
            }
        }

        $AllResults += $Result
    }

    $SuccessCount = ($AllResults | Where-Object Status -EQ 'Success').Count
    $TotalCount = $AllResults.Count
    $SuccessPercent = [math]::Round(($SuccessCount / $TotalCount) * 100, 2)

    Write-Host "`n=== Connectivity Summary ===" -ForegroundColor Yellow
    Write-Host "Successful: $SuccessCount / $TotalCount ($SuccessPercent%)" -ForegroundColor $(
        if ($SuccessPercent -eq 100) { 'Green' } elseif ($SuccessPercent -ge 80) { 'Yellow' } else { 'Red' }
    )

    $FailedTests = $AllResults | Where-Object Status -EQ 'Failed'
    if ($FailedTests.Count -gt 0) {
        Write-Host "`n=== Failed Connectivity Tests ===" -ForegroundColor Red
        $FailedTests | Select-Object Name, Hostname, ErrorMessage | Format-Table -AutoSize
    }

    Write-Host "`n=== Recommendations ===" -ForegroundColor Yellow

    if ($FailedTests.Count -eq 0) {
        Write-Host '✅ All connectivity tests passed!' -ForegroundColor Green
        Write-Host '✅ MDE should have full cloud connectivity' -ForegroundColor Green
    }
    else {
        Write-Host '❌ Some connectivity tests failed' -ForegroundColor Red
        Write-Host 'Action Items:' -ForegroundColor Yellow
        Write-Host '  1. Verify firewall rules allow HTTPS (443) to MDE endpoints' -ForegroundColor White
        Write-Host '  2. Check proxy configuration: netsh winhttp show proxy' -ForegroundColor White
        Write-Host '  3. Verify DNS resolution for failed endpoints' -ForegroundColor White
        Write-Host '  4. Review SSL/TLS inspection policies (may block certificate validation)' -ForegroundColor White
        Write-Host '  5. Run MDEClientAnalyzer.cmd for detailed diagnostics' -ForegroundColor White
    }

    $ExportPath = "MDE-Connectivity-Test-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
    $AllResults | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "`nDetailed results exported to: $ExportPath" -ForegroundColor Cyan

    if ($SuccessPercent -lt 100) {
        exit 1
    }
}
catch {
    Write-Error "Connectivity test failed: $_"
    exit 1
}
