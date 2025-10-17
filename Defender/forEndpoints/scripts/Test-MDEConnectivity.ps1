<#
.SYNOPSIS
    Tests network connectivity to Microsoft Defender for Endpoint cloud endpoints.

.DESCRIPTION
    Validates network connectivity to MDE cloud service endpoints including
    blob storage, telemetry services, and certificate validation URLs.
    Tests DNS resolution, TCP connectivity (port 443), and HTTPS response codes.

    When HTTPS tests fail, automatically tests port 80 as a fallback diagnostic
    to help identify SSL/TLS issues versus general network connectivity problems.

.PARAMETER Region
    MDE service region. Valid values: AU, EU, UK, US. Default: AU

.PARAMETER TestProxy
    Switch to test proxy configuration and connectivity through proxy.

.PARAMETER Verbose
    Display detailed connectivity test results.

.EXAMPLE
    .\Test-MDEConnectivity.ps1

.EXAMPLE
    .\Test-MDEConnectivity.ps1 -Region AU -Verbose

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
    Version: 1.1
    Requires: PowerShell 5.1+, Administrator privileges (for some tests)

    Diagnostic Features:
    - Automatically tests port 80 when HTTPS (port 443) fails
    - Helps differentiate SSL/TLS issues from general network connectivity
    - Provides detailed error context for troubleshooting firewall rules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('AU', 'EU', 'UK', 'US')]
    [string]$Region = 'AU',

    [Parameter(Mandatory = $false)]
    [switch]$TestProxy
)

$ErrorActionPreference = 'Stop'

# Reference: https://learn.microsoft.com/en-us/defender-endpoint/configure-environment
# MDE regional endpoints for telemetry, cyber events, and command/control
$RegionEndpoints = @{
    AU = @{
        Telemetry = 'au.vortex-win.data.microsoft.com'
        Cyber     = 'au-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-aue.microsoft.com'
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
    US = @{
        Telemetry = 'us.vortex-win.data.microsoft.com'
        Cyber     = 'us-v20.events.data.microsoft.com'
        Commands  = 'winatp-gw-cus.microsoft.com'
    }
}

# Reference: https://learn.microsoft.com/en-us/defender-endpoint/configure-environment
# Common endpoints required for MDE cloud connectivity
$CommonEndpoints = @(
    # Blob storage may return 403/404 if authentication required - this is expected
    # Reference: https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security
    @{ Name = 'Blob Storage'; Url = '*.blob.core.windows.net'; TestUrl = 'winatpmanagement.blob.core.windows.net' }

    # CRL Distribution uses HTTP (not HTTPS) per RFC 5280 - certificate validation infrastructure
    # Reference: https://www.rfc-editor.org/rfc/rfc5280#section-4.2.1.13
    # Reference: https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/configure-revocation-checking-certificate-validation
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
        Port80Reachable   = $null
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

            # Accept common status codes that indicate endpoint is reachable:
            # 200 OK, 301/302 Redirect, 403 Forbidden (auth required), 404 Not Found (endpoint exists)
            # Reference: https://www.rfc-editor.org/rfc/rfc9110#name-status-codes
            if ($WebRequest.StatusCode -in @(200, 301, 302, 403, 404)) {
                $Result.Status = 'Success'
            }
            else {
                $Result.Status = 'Warning'
                $Result.ErrorMessage = "Unexpected HTTP status: $($WebRequest.StatusCode)"
            }
        }
        catch {
            # Exception with status code means endpoint responded (even if error)
            # This is expected for blob storage (403/404) and validates connectivity
            if ($_.Exception.Response.StatusCode.value__) {
                $Result.HTTPStatusCode = $_.Exception.Response.StatusCode.value__
                $Result.HTTPSResponse = $true
                $Result.Status = 'Success'
            }
            else {
                # HTTPS failed without status code - test alternative ports for additional diagnostics
                # Reference: https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection
                Write-Verbose "HTTPS failed for $Hostname - testing port 80 as fallback diagnostic"
                $Port80Test = Test-NetConnection -ComputerName $Hostname -Port 80 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

                if ($Port80Test.TcpTestSucceeded) {
                    $Result.Port80Reachable = $true
                    $Result.ErrorMessage = 'HTTPS (443) failed but HTTP (80) reachable - possible SSL/TLS issue or firewall blocking HTTPS'
                    $Result.Status = 'Warning'
                }
                else {
                    $Result.Port80Reachable = $false
                    $Result.ErrorMessage = "HTTPS request failed: $($_.Exception.Message)"
                    $Result.Status = 'Failed'
                }
            }
        }
    }
    catch {
        # Final catch block - attempt port 80 diagnostic before failing completely
        Write-Verbose "Exception in connectivity test for $Hostname - testing port 80 as fallback"
        $Port80Test = Test-NetConnection -ComputerName $Hostname -Port 80 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        if ($Port80Test.TcpTestSucceeded) {
            $Result.Port80Reachable = $true
            $Result.ErrorMessage = "$($_.Exception.Message) - Port 80 reachable, possible HTTPS-specific issue"
            $Result.Status = 'Warning'
        }
        else {
            $Result.Port80Reachable = $false
            $Result.ErrorMessage = $_.Exception.Message
            $Result.Status = 'Failed'
        }
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
            Write-Host "  TCP:443: $($Result.TCPConnection) | HTTP: $($Result.HTTPStatusCode) | Time: $($Result.ResponseTime)ms" -ForegroundColor Gray
            if ($null -ne $Result.Port80Reachable) {
                Write-Host "  TCP:80: $($Result.Port80Reachable) (Fallback diagnostic)" -ForegroundColor $(if ($Result.Port80Reachable) { 'Yellow' } else { 'Gray' })
            }
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
            Write-Host "  TCP:443: $($Result.TCPConnection) | HTTP: $($Result.HTTPStatusCode) | Time: $($Result.ResponseTime)ms" -ForegroundColor Gray
            if ($null -ne $Result.Port80Reachable) {
                Write-Host "  TCP:80: $($Result.Port80Reachable) (Fallback diagnostic)" -ForegroundColor $(if ($Result.Port80Reachable) { 'Yellow' } else { 'Gray' })
            }
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
        $FailedTests | Select-Object Name, Hostname, Port80Reachable, ErrorMessage | Format-Table -AutoSize

        $Port80Available = $FailedTests | Where-Object Port80Reachable -EQ $true
        if ($Port80Available.Count -gt 0) {
            Write-Host "`n⚠️  Note: $($Port80Available.Count) endpoint(s) reachable on port 80 but failed HTTPS (443)" -ForegroundColor Yellow
            Write-Host '   This suggests SSL/TLS or firewall policy blocking HTTPS traffic specifically' -ForegroundColor Yellow
        }
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
