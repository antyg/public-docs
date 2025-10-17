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
    Version: 2.0
    Requires: PowerShell 5.1+, Administrator privileges (for some tests)
    Reference: MDEClientAnalyzer RegionsURLs.json (official Microsoft endpoint configuration)

    Version 2.0 Features:
    - Tests Gateway Architecture endpoints (*.endpoint.security.microsoft.com)
    - Validates AU-specific blob storage endpoints (automatedirstrprdaus/aue)
    - Distinguishes CRITICAL vs OPTIONAL endpoints
    - Tests command/control, cyber data, AutoIR blobs, and sample upload endpoints
    - Only fails (exit 1) on CRITICAL endpoint failures
    - Port 80 fallback diagnostics for SSL/TLS troubleshooting
    - Comprehensive reporting with criticality-based color coding
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
# Reference: MDEClientAnalyzer - RegionsURLs.json (official Microsoft endpoint configuration)
# MDE regional endpoints - Gateway Architecture (GW_AU, GW_EU, GW_UK, GW_US)
# Tests both legacy and new streamlined connectivity endpoints
$RegionEndpoints = @{
    AU = @{
        # Gateway Architecture - Streamlined Connectivity (2025+)
        CommandsGW        = @(
            @{ Url = 'edr-aus.au.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'edr-aue.au.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'mdav.au.endpoint.security.microsoft.com'; Critical = $true }
        )
        CyberDataGW       = @(
            @{ Url = 'au-v20.events.endpoint.security.microsoft.com'; Critical = $true }
        )
        # Proxied blob storage through gateway endpoints (authentication required - 403/404 expected)
        AutoIRBlobsGW     = @(
            @{ Url = 'edr-aus.au.endpoint.security.microsoft.com/storage/automatedirstrprdaus/'; Critical = $false }
            @{ Url = 'edr-aue.au.endpoint.security.microsoft.com/storage/automatedirstrprdaue/'; Critical = $false }
        )
        SampleUploadGW    = @(
            @{ Url = 'edr-aue.au.endpoint.security.microsoft.com/storage/ussau1eastprod/'; Critical = $false }
            @{ Url = 'edr-aus.au.endpoint.security.microsoft.com/storage/ussau1southeastprod/'; Critical = $false }
        )
        # Legacy Architecture - Direct blob storage (may be deprecated)
        AutoIRBlobsLegacy = @(
            @{ Url = 'automatedirstrprdaus.blob.core.windows.net'; Critical = $false }
            @{ Url = 'automatedirstrprdaue.blob.core.windows.net'; Critical = $false }
        )
        SampleUploadLegacy = @(
            @{ Url = 'ussau1eastprod.blob.core.windows.net'; Critical = $false }
            @{ Url = 'ussau1southeastprod.blob.core.windows.net'; Critical = $false }
        )
    }
    EU = @{
        CommandsGW     = @(
            @{ Url = 'edr-weu.eu.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'edr-neu.eu.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'mdav.eu.endpoint.security.microsoft.com'; Critical = $true }
        )
        CyberDataGW    = @(
            @{ Url = 'eu-v20.events.endpoint.security.microsoft.com'; Critical = $true }
        )
    }
    UK = @{
        CommandsGW     = @(
            @{ Url = 'edr-uks.uk.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'edr-ukw.uk.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'mdav.uk.endpoint.security.microsoft.com'; Critical = $true }
        )
        CyberDataGW    = @(
            @{ Url = 'uk-v20.events.endpoint.security.microsoft.com'; Critical = $true }
        )
    }
    US = @{
        CommandsGW     = @(
            @{ Url = 'edr-cus.us.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'edr-eus.us.endpoint.security.microsoft.com'; Critical = $true }
            @{ Url = 'mdav.us.endpoint.security.microsoft.com'; Critical = $true }
        )
        CyberDataGW    = @(
            @{ Url = 'us-v20.events.endpoint.security.microsoft.com'; Critical = $true }
        )
    }
}

# Reference: https://learn.microsoft.com/en-us/defender-endpoint/configure-environment
# Common endpoints required for MDE cloud connectivity
$CommonEndpoints = @(
    # NOTE: Blob storage connectivity removed as of 2025 streamlined connectivity model
    # Reference: https://blog.sonnes.cloud/microsoft-defender-for-endpoint-new-and-more-streamlined-device-connectivity-on-the-way/
    # Microsoft eliminated ~20 blob URLs in favor of consolidated MDE domains
    # Use MDEClientAnalyzer.cmd for comprehensive connectivity validation including region-specific blob endpoints
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows

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
        [string]$Name,
        [bool]$Critical = $true
    )

    $Result = [PSCustomObject]@{
        Name              = $Name
        Hostname          = $Hostname
        Port              = $Port
        Critical          = $Critical
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
        $EndpointList = $RegionTests[$EndpointType]

        # Display endpoint category
        $CategoryName = $EndpointType -replace 'GW$', ' (Gateway)' -replace 'Legacy$', ' (Legacy)'
        Write-Host "`n[$CategoryName]" -ForegroundColor Cyan

        foreach ($EndpointConfig in $EndpointList) {
            $Hostname = $EndpointConfig.Url
            $IsCritical = $EndpointConfig.Critical

            $CriticalityLabel = if ($IsCritical) { '[CRITICAL]' } else { '[OPTIONAL]' }
            Write-Host "  $CriticalityLabel Testing $Hostname..." -NoNewline

            $Result = Test-EndpointConnectivity -Hostname $Hostname -Name "$Region $EndpointType" -Critical $IsCritical

            if ($Result.Status -eq 'Success') {
                Write-Host ' OK' -ForegroundColor Green
            }
            elseif ($Result.Status -eq 'Warning') {
                $WarnColor = if ($IsCritical) { 'Red' } else { 'Yellow' }
                Write-Host ' Warning' -ForegroundColor $WarnColor
            }
            else {
                $FailColor = if ($IsCritical) { 'Red' } else { 'Yellow' }
                Write-Host ' FAILED' -ForegroundColor $FailColor
            }

            if ($VerbosePreference -eq 'Continue') {
                Write-Host "    DNS: $($Result.DNSResolution) | IP: $($Result.IPAddress)" -ForegroundColor Gray
                Write-Host "    TCP:443: $($Result.TCPConnection) | HTTP: $($Result.HTTPStatusCode) | Time: $($Result.ResponseTime)ms" -ForegroundColor Gray
                if ($null -ne $Result.Port80Reachable) {
                    Write-Host "    TCP:80: $($Result.Port80Reachable) (Fallback diagnostic)" -ForegroundColor $(if ($Result.Port80Reachable) { 'Yellow' } else { 'Gray' })
                }
                if ($Result.ErrorMessage) {
                    Write-Host "    Error: $($Result.ErrorMessage)" -ForegroundColor Red
                }
            }

            $AllResults += $Result
        }
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

    # Separate critical and optional endpoints
    $CriticalTests = $AllResults | Where-Object Critical -EQ $true
    $OptionalTests = $AllResults | Where-Object Critical -EQ $false
    $CriticalSuccess = ($CriticalTests | Where-Object Status -EQ 'Success').Count
    $CriticalTotal = $CriticalTests.Count
    $OptionalSuccess = ($OptionalTests | Where-Object Status -EQ 'Success').Count
    $OptionalTotal = $OptionalTests.Count

    Write-Host "`n=== Connectivity Summary ===" -ForegroundColor Yellow
    Write-Host "Overall: $SuccessCount / $TotalCount ($SuccessPercent%)" -ForegroundColor $(
        if ($SuccessPercent -eq 100) { 'Green' } elseif ($SuccessPercent -ge 80) { 'Yellow' } else { 'Red' }
    )
    Write-Host "  Critical Endpoints: $CriticalSuccess / $CriticalTotal" -ForegroundColor $(
        if ($CriticalSuccess -eq $CriticalTotal) { 'Green' } else { 'Red' }
    )
    Write-Host "  Optional Endpoints: $OptionalSuccess / $OptionalTotal" -ForegroundColor $(
        if ($OptionalSuccess -eq $OptionalTotal) { 'Green' } elseif ($OptionalSuccess -gt 0) { 'Yellow' } else { 'Red' }
    )

    $FailedTests = $AllResults | Where-Object Status -EQ 'Failed'
    $CriticalFailures = $FailedTests | Where-Object Critical -EQ $true
    $OptionalFailures = $FailedTests | Where-Object Critical -EQ $false

    if ($CriticalFailures.Count -gt 0) {
        Write-Host "`n=== ❌ CRITICAL FAILURES ===" -ForegroundColor Red
        Write-Host 'These endpoints are REQUIRED for MDE functionality:' -ForegroundColor Red
        $CriticalFailures | Select-Object Name, Hostname, Port80Reachable, ErrorMessage | Format-Table -AutoSize

        $Port80Available = $CriticalFailures | Where-Object Port80Reachable -EQ $true
        if ($Port80Available.Count -gt 0) {
            Write-Host "⚠️  Note: $($Port80Available.Count) critical endpoint(s) reachable on port 80 but failed HTTPS (443)" -ForegroundColor Yellow
            Write-Host '   This suggests SSL/TLS or firewall policy blocking HTTPS traffic specifically' -ForegroundColor Yellow
        }
    }

    if ($OptionalFailures.Count -gt 0) {
        Write-Host "`n=== ⚠️  OPTIONAL ENDPOINT WARNINGS ===" -ForegroundColor Yellow
        Write-Host 'These endpoints are optional (blob storage typically requires authentication):' -ForegroundColor Yellow
        $OptionalFailures | Select-Object Name, Hostname, HTTPStatusCode, ErrorMessage | Format-Table -AutoSize
    }

    Write-Host "`n=== Recommendations ===" -ForegroundColor Yellow

    if ($CriticalFailures.Count -eq 0 -and $OptionalFailures.Count -eq 0) {
        Write-Host '✅ All connectivity tests passed!' -ForegroundColor Green
        Write-Host '✅ MDE should have full cloud connectivity' -ForegroundColor Green
    }
    elseif ($CriticalFailures.Count -eq 0) {
        Write-Host '✅ All CRITICAL endpoints accessible' -ForegroundColor Green
        Write-Host "⚠️  $($OptionalFailures.Count) optional endpoint(s) failed (blob storage - may require authentication)" -ForegroundColor Yellow
        Write-Host '   MDE core functionality should work normally' -ForegroundColor Yellow
    }
    else {
        Write-Host '❌ CRITICAL endpoint failures detected - MDE functionality will be impaired' -ForegroundColor Red
        Write-Host 'URGENT Action Items:' -ForegroundColor Red
        Write-Host '  1. Verify firewall rules allow HTTPS (443) to *.endpoint.security.microsoft.com' -ForegroundColor White
        Write-Host '  2. Check proxy configuration: netsh winhttp show proxy' -ForegroundColor White
        Write-Host '  3. Verify DNS resolution for failed endpoints' -ForegroundColor White
        Write-Host '  4. Review SSL/TLS inspection policies (may block certificate validation)' -ForegroundColor White
        Write-Host '  5. Run MDEClientAnalyzer.cmd for comprehensive diagnostics' -ForegroundColor White
    }

    $ExportPath = "MDE-Connectivity-Test-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
    $AllResults | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "`nDetailed results exported to: $ExportPath" -ForegroundColor Cyan

    # Exit with error code only if CRITICAL endpoints failed
    if ($CriticalFailures.Count -gt 0) {
        Write-Host "`n❌ Exiting with error code 1 due to critical endpoint failures" -ForegroundColor Red
        exit 1
    }
    elseif ($OptionalFailures.Count -gt 0) {
        Write-Host "`n⚠️  Exiting with success (optional endpoint warnings only)" -ForegroundColor Yellow
        exit 0
    }
    else {
        Write-Host "`n✅ All tests passed successfully" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Error "Connectivity test failed: $_"
    exit 1
}
