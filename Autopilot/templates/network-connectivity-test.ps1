<#
.SYNOPSIS
Network connectivity test for Windows Autopilot endpoints

.DESCRIPTION
Tests connectivity to all required Windows Autopilot service endpoints to validate 
network configuration and firewall rules before deployment.

.PARAMETER OutputFile
Optional file path to save test results in CSV format

.PARAMETER IncludeOptional
Include optional endpoints that improve deployment experience but are not strictly required

.PARAMETER TestDNS
Test DNS resolution in addition to TCP connectivity

.PARAMETER Timeout
Connection timeout in seconds (default: 10)

.EXAMPLE
.\network-connectivity-test.ps1

.EXAMPLE
.\network-connectivity-test.ps1 -OutputFile "C:\temp\connectivity-test.csv" -IncludeOptional -TestDNS

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Network access, no administrative privileges required
Compatible: Windows 10/11, PowerShell 5.1+
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,

    [Parameter(Mandatory=$false)]
    [switch]$IncludeOptional,

    [Parameter(Mandatory=$false)]
    [switch]$TestDNS,

    [Parameter(Mandatory=$false)]
    [int]$Timeout = 10
)

# Define required Autopilot endpoints
$requiredEndpoints = @(
    @{
        Name = "Azure AD Authentication"
        Endpoint = "login.microsoftonline.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Authentication"
        Required = $true
        Description = "Primary authentication service for Azure AD"
    },
    @{
        Name = "Microsoft Intune Management"
        Endpoint = "enrollment.manage.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Management"
        Required = $true
        Description = "Device enrollment and management"
    },
    @{
        Name = "Device Registration"
        Endpoint = "enterpriseregistration.windows.net"
        Port = 443
        Protocol = "HTTPS"
        Category = "Registration"
        Required = $true
        Description = "Enterprise device registration"
    },
    @{
        Name = "Device Login"
        Endpoint = "device.login.microsoftonline.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Authentication"
        Required = $true
        Description = "Device authentication endpoint"
    },
    @{
        Name = "Autopilot Service Discovery"
        Endpoint = "ztd.dds.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Discovery"
        Required = $true
        Description = "Autopilot device discovery service"
    },
    @{
        Name = "Microsoft Graph"
        Endpoint = "graph.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "API"
        Required = $true
        Description = "Microsoft Graph API endpoint"
    }
)

# Define optional endpoints (improve experience but not strictly required)
$optionalEndpoints = @(
    @{
        Name = "Windows Update"
        Endpoint = "windowsupdate.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Updates"
        Required = $false
        Description = "Windows Update services"
    },
    @{
        Name = "Delivery Optimization"
        Endpoint = "dl.delivery.mp.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Content Delivery"
        Required = $false
        Description = "Content delivery optimization"
    },
    @{
        Name = "Microsoft Store"
        Endpoint = "storeedgefd.dsx.mp.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Applications"
        Required = $false
        Description = "Microsoft Store application downloads"
    },
    @{
        Name = "Certificate Validation"
        Endpoint = "crl.microsoft.com"
        Port = 443
        Protocol = "HTTPS"
        Category = "Security"
        Required = $false
        Description = "Certificate revocation list"
    },
    @{
        Name = "Time Synchronization"
        Endpoint = "time.windows.com"
        Port = 123
        Protocol = "NTP"
        Category = "Time"
        Required = $false
        Description = "Network Time Protocol server"
    }
)

# Combine endpoint lists
$allEndpoints = $requiredEndpoints
if ($IncludeOptional) {
    $allEndpoints += $optionalEndpoints
}

# Test results array
$testResults = @()

Write-Output "🔍 Windows Autopilot Network Connectivity Test"
Write-Output "=============================================="
Write-Output "Testing $(($allEndpoints | Where-Object { $_.Required }).Count) required endpoints$(if($IncludeOptional){" and $(($allEndpoints | Where-Object { -not $_.Required }).Count) optional endpoints"})"
Write-Output "Timeout: $Timeout seconds"
Write-Output ""

# Function to test TCP connectivity
function Test-TCPConnectivity {
    param($Endpoint, $Port, $TimeoutSec)
    
    try {
        $result = Test-NetConnection -ComputerName $Endpoint -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
        return $result.TcpTestSucceeded
    } catch {
        return $false
    }
}

# Function to test DNS resolution
function Test-DNSResolution {
    param($Endpoint)
    
    try {
        $dnsResult = Resolve-DnsName -Name $Endpoint -ErrorAction Stop
        return $true, $dnsResult[0].IPAddress
    } catch {
        return $false, $null
    }
}

# Function to format test result
function Format-TestResult {
    param($Success, $Optional = $false)
    
    if ($Success) {
        return if ($Optional) { "✅ PASS (Optional)" } else { "✅ PASS" }
    } else {
        return if ($Optional) { "⚠️ FAIL (Optional)" } else { "❌ FAIL" }
    }
}

# Test each endpoint
foreach ($endpoint in $allEndpoints) {
    $startTime = Get-Date
    
    Write-Output "Testing: $($endpoint.Name) ($($endpoint.Endpoint):$($endpoint.Port))"
    
    # DNS Resolution Test
    $dnsSuccess = $true
    $ipAddress = "N/A"
    if ($TestDNS) {
        $dnsSuccess, $ipAddress = Test-DNSResolution -Endpoint $endpoint.Endpoint
        if ($ipAddress -eq $null) { $ipAddress = "Resolution Failed" }
        Write-Output "  DNS Resolution: $(if($dnsSuccess){'✅ Success'}else{'❌ Failed'}) - IP: $ipAddress"
    }
    
    # TCP Connectivity Test
    $tcpSuccess = $false
    if ($endpoint.Protocol -eq "NTP" -and $endpoint.Port -eq 123) {
        # Special handling for NTP (UDP)
        try {
            $udpClient = New-Object System.Net.Sockets.UdpClient
            $udpClient.Connect($endpoint.Endpoint, $endpoint.Port)
            $tcpSuccess = $true
            $udpClient.Close()
        } catch {
            $tcpSuccess = $false
        }
    } else {
        $tcpSuccess = Test-TCPConnectivity -Endpoint $endpoint.Endpoint -Port $endpoint.Port -TimeoutSec $Timeout
    }
    
    $endTime = Get-Date
    $duration = [math]::Round(($endTime - $startTime).TotalMilliseconds, 0)
    
    $result = Format-TestResult -Success $tcpSuccess -Optional (-not $endpoint.Required)
    Write-Output "  Connectivity: $result ($duration ms)"
    
    # Store result for reporting
    $testResults += [PSCustomObject]@{
        Name = $endpoint.Name
        Endpoint = $endpoint.Endpoint
        Port = $endpoint.Port
        Protocol = $endpoint.Protocol
        Category = $endpoint.Category
        Required = $endpoint.Required
        DNSResolution = if($TestDNS){$dnsSuccess}else{"Not Tested"}
        IPAddress = if($TestDNS){$ipAddress}else{"Not Resolved"}
        TCPConnectivity = $tcpSuccess
        ResponseTime = $duration
        Status = if($tcpSuccess){"Success"}else{"Failed"}
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    Write-Output ""
}

# Summary report
$totalTests = $testResults.Count
$requiredTests = ($testResults | Where-Object { $_.Required }).Count
$requiredPassed = ($testResults | Where-Object { $_.Required -and $_.TCPConnectivity }).Count
$optionalTests = ($testResults | Where-Object { -not $_.Required }).Count
$optionalPassed = ($testResults | Where-Object { -not $_.Required -and $_.TCPConnectivity }).Count

Write-Output "📊 TEST SUMMARY"
Write-Output "==============="
Write-Output "Required Endpoints: $requiredPassed/$requiredTests passed"
if ($IncludeOptional) {
    Write-Output "Optional Endpoints: $optionalPassed/$optionalTests passed"
}
Write-Output "Total Tests: $(($testResults | Where-Object { $_.TCPConnectivity }).Count)/$totalTests passed"
Write-Output ""

# Status assessment
if ($requiredPassed -eq $requiredTests) {
    Write-Output "🎉 AUTOPILOT READY: All required endpoints are accessible!"
    if ($IncludeOptional -and $optionalPassed -lt $optionalTests) {
        Write-Output "⚠️  Some optional endpoints failed - deployment will work but may be slower"
    }
} else {
    Write-Output "❌ AUTOPILOT NOT READY: $($requiredTests - $requiredPassed) required endpoint(s) failed"
    Write-Output ""
    Write-Output "Failed Required Endpoints:"
    $failedRequired = $testResults | Where-Object { $_.Required -and -not $_.TCPConnectivity }
    foreach ($failed in $failedRequired) {
        Write-Output "  • $($failed.Name): $($failed.Endpoint):$($failed.Port)"
    }
    Write-Output ""
    Write-Output "💡 Troubleshooting Steps:"
    Write-Output "1. Check firewall rules for the failed endpoints"
    Write-Output "2. Verify proxy configuration (if applicable)"
    Write-Output "3. Test from different network location"
    Write-Output "4. Contact network administrator for assistance"
}

# Export results if requested
if ($OutputFile) {
    try {
        $testResults | Export-Csv -Path $OutputFile -NoTypeInformation
        Write-Output ""
        Write-Output "📄 Test results exported to: $OutputFile"
    } catch {
        Write-Warning "Failed to export results: $($_.Exception.Message)"
    }
}

Write-Output ""
Write-Output "Test completed at: $(Get-Date)"