<#
.SYNOPSIS
    Validates connectivity prerequisites for Get-MDEStatus.ps1 remote validation methods.

.DESCRIPTION
    Comprehensive pre-flight validation script that tests network connectivity, DNS resolution,
    VPN/tunnel routing, port accessibility, service availability, and authentication for all
    remote access methods used by Get-MDEStatus.ps1:

    Network Layer Tests:
    1. DNS Forward Resolution - Hostname to IP mapping validation
    2. DNS Reverse Resolution - PTR record validation
    3. DNS Record Freshness - Stale record detection
    4. VPN/Tunnel Detection - Split-tunnel and VPN adapter identification
    5. Network Route Analysis - Routing table and next-hop validation
    6. Network Path Quality - Traceroute and hop count analysis
    7. Network Latency - Round-trip time measurement and packet loss detection

    Protocol & Port Tests:
    8. ICMP Ping - Basic network reachability
    9. CIM/WSMan Port Access - Modern Windows (ports 5985/5986)
    10. WMI/DCOM RPC Endpoint - Legacy Windows (port 135)
    11. CIM Session Creation - Authentication and session establishment
    12. WMI Namespace Access - DCOM/RPC validation
    13. PowerShell Remoting - WinRM session validation
    14. Remote Registry Access - Registry service validation
    15. Remote Service Enumeration - Service control validation
    16. Remote Event Log Access - Event log reader permissions

    Provides actionable troubleshooting guidance for failed prerequisites with specific remediation steps.

.PARAMETER ComputerName
    Target computer name or IP address to validate connectivity against.

.PARAMETER Credential
    PSCredential for remote access authentication. If not provided, uses current context.

.PARAMETER TestHTTPS
    Test HTTPS WSMan (port 5986) instead of HTTP (port 5985). Default is HTTP.

.PARAMETER IncludeDynamicPorts
    Test dynamic RPC port range (49152-65535) for WMI/DCOM. WARNING: This is slow.

.PARAMETER SkipNetworkTests
    Skip advanced network tests (DNS, traceroute, VPN detection). Use for faster validation.

.PARAMETER NetworkType
    Network deployment type for adjusting latency and hop count thresholds.
    LAN: 1-5 hops, <50ms latency
    Campus: 5-10 hops, <100ms latency
    Regional: 10-20 hops, <200ms latency (default)
    Global: 20-30 hops, <500ms latency
    Satellite: Up to 40 hops, <700ms latency

.PARAMETER MaxAcceptableHops
    Maximum acceptable hop count before warning. Default varies by NetworkType.
    Manual override for custom environments.

.PARAMETER LatencyThresholdMs
    Maximum acceptable latency in milliseconds before warning. Default varies by NetworkType.
    Manual override for custom environments.

.PARAMETER PacketLossThresholdPercent
    Maximum acceptable packet loss percentage before warning. Default: 5%

.PARAMETER GenerateHTML
    Generate HTML report in addition to text report. By default, only text report is created.

.PARAMETER OutputPath
    Path for output report. Defaults to current directory with timestamp. Extension determines format (.txt or .html).

.EXAMPLE
    .\Test-MDEStatusPrerequisites.ps1 -ComputerName "WORKSTATION01"

.EXAMPLE
    $Cred = Get-Credential
    .\Test-MDEStatusPrerequisites.ps1 -ComputerName "SERVER01" -Credential $Cred -TestHTTPS

.EXAMPLE
    .\Test-MDEStatusPrerequisites.ps1 -ComputerName "10.0.1.50" -SkipNetworkTests

.EXAMPLE
    .\Test-MDEStatusPrerequisites.ps1 -ComputerName "WORKSTATION01" -OutputPath "C:\Reports\prereqs.html"

.NOTES
    Author: Security Operations Team
    Version: 2.0
    Requires: PowerShell 5.1+

    Network Test Coverage:
    - DNS forward/reverse resolution
    - DNS record staleness detection
    - VPN adapter and split-tunnel detection
    - Network path latency and packet loss
    - Routing table analysis

    Port Reference:
    - ICMP Echo: Network Layer (Type 8)
    - DNS: UDP 53
    - WSMan HTTP: TCP 5985
    - WSMan HTTPS: TCP 5986
    - RPC Endpoint Mapper: TCP 135
    - RPC Dynamic: TCP 49152-65535

    Service Requirements:
    - WinRM (Windows Remote Management)
    - RpcSs (Remote Procedure Call)
    - RemoteRegistry (Remote Registry - optional)
    - Dnscache (DNS Client)

    Firewall Rules Required:
    - Windows Remote Management (HTTP-In)
    - Windows Remote Management (HTTPS-In)
    - Windows Management Instrumentation (DCOM-In)
    - Windows Management Instrumentation (WMI-In)

.REFERENCES
    Windows Remote Management (WinRM)
    https://learn.microsoft.com/en-us/windows/win32/winrm/portal

    Test-NetConnection cmdlet
    https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection

    Enable-PSRemoting cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting

    WMI and DCOM Troubleshooting
    https://learn.microsoft.com/en-us/windows/win32/wmisdk/connecting-to-wmi-remotely-starting-with-vista

    New-CimSession cmdlet
    https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/new-cimsession

    Get-WmiObject cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject

    Resolve-DnsName cmdlet
    https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname

    Get-NetRoute cmdlet
    https://learn.microsoft.com/en-us/powershell/module/nettcpip/get-netroute

    Get-NetAdapter cmdlet
    https://learn.microsoft.com/en-us/powershell/module/netadapter/get-netadapter

    DNS Troubleshooting
    https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/verify-dns-functionality

    VPN Split Tunneling
    https://learn.microsoft.com/en-us/windows/security/identity-protection/vpn/vpn-routing
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory = $false)]
    [switch]$TestHTTPS,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDynamicPorts,

    [Parameter(Mandatory = $false)]
    [switch]$SkipNetworkTests,

    [Parameter(Mandatory = $false)]
    [ValidateSet('LAN', 'Campus', 'Regional', 'Global', 'Satellite')]
    [string]$NetworkType = 'Regional',

    [Parameter(Mandatory = $false)]
    [int]$MaxAcceptableHops,

    [Parameter(Mandatory = $false)]
    [int]$LatencyThresholdMs,

    [Parameter(Mandatory = $false)]
    [int]$PacketLossThresholdPercent = 5,

    [Parameter(Mandatory = $false)]
    [switch]$GenerateHTML,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Continue'

$Results = [System.Collections.ArrayList]::new()
$OverallStatus = 'Pass'

if (-not $MaxAcceptableHops) {
    $MaxAcceptableHops = switch ($NetworkType) {
        'LAN' { 5 }
        'Campus' { 10 }
        'Regional' { 20 }
        'Global' { 30 }
        'Satellite' { 40 }
        default { 20 }
    }
}

if (-not $LatencyThresholdMs) {
    $LatencyThresholdMs = switch ($NetworkType) {
        'LAN' { 50 }
        'Campus' { 100 }
        'Regional' { 200 }
        'Global' { 500 }
        'Satellite' { 700 }
        default { 200 }
    }
}

function Add-TestResult {
    param(
        [string]$TestCase,
        [string]$Category,
        [string]$TestName,
        [string]$Status,
        [string]$Details,
        [string]$Remediation
    )

    $null = $Results.Add([PSCustomObject]@{
            TestCase    = $TestCase
            Category    = $Category
            TestName    = $TestName
            Status      = $Status
            Details     = $Details
            Remediation = $Remediation
            Timestamp   = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
        })

    if ($Status -eq 'Fail') {
        $script:OverallStatus = 'Fail'
    }
}

Write-Host "`n=== MDE Status Prerequisites Validation ===" -ForegroundColor Cyan
Write-Host "Target: $ComputerName" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan
Write-Host "Network Type: $NetworkType (Max Hops: $MaxAcceptableHops, Latency Threshold: ${LatencyThresholdMs}ms, Packet Loss: ${PacketLossThresholdPercent}%)" -ForegroundColor Cyan
if ($SkipNetworkTests) {
    Write-Host "Network Tests: Skipped (use -SkipNetworkTests:`$false to enable)" -ForegroundColor Yellow
}
Write-Host ''

$ResolvedIP = $null
$DnsForward = $null

if (-not $SkipNetworkTests) {
    Write-Host '=== Network Layer Validation ===' -ForegroundColor Cyan

    Write-Host '[Test-Case-N01] Testing DNS Forward Resolution...' -NoNewline
    try {
        $DnsForward = Resolve-DnsName -Name $ComputerName -ErrorAction Stop | Where-Object { $_.Type -eq 'A' -or $_.Type -eq 'AAAA' } | Select-Object -First 1

        if ($DnsForward) {
            $ResolvedIP = $DnsForward.IPAddress
            Write-Host ' PASS' -ForegroundColor Green
            Write-Host "  Resolved to: $ResolvedIP" -ForegroundColor Gray
            Add-TestResult -TestCase 'Test-Case-N01' -Category 'Network-DNS' -TestName 'DNS Forward Resolution' `
                -Status 'Pass' -Details "Hostname resolved to $ResolvedIP" `
                -Remediation 'N/A'
        }
        else {
            Write-Host ' FAIL' -ForegroundColor Red
            Add-TestResult -TestCase 'Test-Case-N01' -Category 'Network-DNS' -TestName 'DNS Forward Resolution' `
                -Status 'Fail' -Details 'No A or AAAA records returned for hostname' `
                -Remediation "1. Verify hostname is correct; 2. Check DNS server configuration: 'Get-DnsClientServerAddress'; 3. Flush DNS cache: 'Clear-DnsClientCache'; 4. Test with IP address instead; 5. Check DNS zone contains host record"
        }
    }
    catch {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-N01' -Category 'Network-DNS' -TestName 'DNS Forward Resolution' `
            -Status 'Fail' -Details "DNS query failed: $($_.Exception.Message)" `
            -Remediation "1. Verify DNS server is reachable; 2. Check DNS client service is running: 'Start-Service Dnscache'; 3. Verify network connectivity; 4. Check DNS server address: 'Get-DnsClientServerAddress'; 5. Try alternate DNS server or use IP address directly"
    }

    Write-Host '[Test-Case-N02] Testing DNS Reverse Resolution...' -NoNewline
    try {
        if ($DnsForward -and $ResolvedIP) {
            $DnsReverse = Resolve-DnsName -Name $ResolvedIP -ErrorAction Stop | Where-Object { $_.Type -eq 'PTR' } | Select-Object -First 1

            if ($DnsReverse) {
                $ReverseName = $DnsReverse.NameHost
                Write-Host ' PASS' -ForegroundColor Green
                Write-Host "  PTR record: $ReverseName" -ForegroundColor Gray

                # Extract first hostname component for case-insensitive comparison
                # This handles FQDN vs short name scenarios (e.g., "SERVER01" vs "server01.contoso.com")
                $InputHostShort = ($ComputerName -split '\.')[0].ToLower()
                $PTRHostShort = ($ReverseName -split '\.')[0].ToLower()

                if ($InputHostShort -ne $PTRHostShort) {
                    Write-Host "  WARNING: PTR hostname doesn't match input hostname" -ForegroundColor Yellow
                    Add-TestResult -TestCase 'Test-Case-N02' -Category 'Network-DNS' -TestName 'DNS Reverse Resolution' `
                        -Status 'Warning' -Details "PTR hostname component '$PTRHostShort' doesn't match input hostname '$InputHostShort'. Full PTR: $ReverseName" `
                        -Remediation "1. Verify PTR record in DNS reverse lookup zone; 2. Check for stale DNS records or recent IP address change; 3. Update reverse lookup zone if incorrect; 4. NOTE: This is a heuristic check comparing only the first hostname component. Definitive validation requires remote access to verify the actual configured hostname on the target system; 5. If this is a load balancer or multi-homed server, this warning may be expected"
                }
                else {
                    Add-TestResult -TestCase 'Test-Case-N02' -Category 'Network-DNS' -TestName 'DNS Reverse Resolution' `
                        -Status 'Pass' -Details "PTR hostname matches: $ReverseName (first component: '$PTRHostShort' matches input: '$InputHostShort')" `
                        -Remediation 'N/A'
                }
            }
            else {
                Write-Host ' WARNING' -ForegroundColor Yellow
                Add-TestResult -TestCase 'Test-Case-N02' -Category 'Network-DNS' -TestName 'DNS Reverse Resolution' `
                    -Status 'Warning' -Details "No PTR record found for $ResolvedIP" `
                    -Remediation '1. Create PTR record in reverse lookup zone; 2. This is not critical for Get-MDEStatus.ps1 but may indicate DNS misconfiguration; 3. Verify reverse lookup zone exists and is properly delegated'
            }
        }
        else {
            Write-Host ' SKIPPED' -ForegroundColor Yellow
            Add-TestResult -TestCase 'Test-Case-N02' -Category 'Network-DNS' -TestName 'DNS Reverse Resolution' `
                -Status 'Warning' -Details 'Skipped due to forward resolution failure' `
                -Remediation 'Fix Test-Case-N01 first'
        }
    }
    catch {
        Write-Host ' WARNING' -ForegroundColor Yellow
        Add-TestResult -TestCase 'Test-Case-N02' -Category 'Network-DNS' -TestName 'DNS Reverse Resolution' `
            -Status 'Warning' -Details "Reverse lookup failed: $($_.Exception.Message)" `
            -Remediation '1. This is not critical for Get-MDEStatus.ps1 functionality; 2. Create PTR record if needed for proper DNS hygiene; 3. Verify reverse lookup zone configuration'
    }

    Write-Host '[Test-Case-N03] Testing DNS Record Freshness...' -NoNewline
    try {
        if ($DnsForward -and $ResolvedIP) {
            $PingTest = Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue

            if ($PingTest) {
                $PingIP = $PingTest.IPV4Address.IPAddressToString

                if ($PingIP -and $PingIP -ne $ResolvedIP) {
                    Write-Host ' WARNING' -ForegroundColor Yellow
                    Write-Host "  DNS: $ResolvedIP | Ping: $PingIP (mismatch detected)" -ForegroundColor Yellow
                    Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
                        -Status 'Warning' -Details "DNS/Ping IP mismatch. DNS resolves to: $ResolvedIP, but device responds from: $PingIP. May indicate stale DNS, multi-homed server, or load balancer. NOTE: Actual subnet cannot be determined without remote access - this is a heuristic check only." `
                        -Remediation "1. Verify if server is multi-homed (multiple NICs), clustered, or behind load balancer; 2. If none of the above, clear DNS cache: 'Clear-DnsClientCache'; 3. Update DNS A record if stale to: $PingIP; 4. Check DNS scavenging settings; 5. This warning may be normal for legitimate multi-NIC or load-balanced configurations"
                }
                elseif ($PingIP -eq $ResolvedIP) {
                    Write-Host ' PASS' -ForegroundColor Green
                    Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
                        -Status 'Pass' -Details "DNS record matches actual IP address: $ResolvedIP" `
                        -Remediation 'N/A'
                }
                else {
                    Write-Host ' SKIPPED' -ForegroundColor Yellow
                    Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
                        -Status 'Warning' -Details 'Could not extract IP from ping response' `
                        -Remediation 'N/A - Manual verification recommended'
                }
            }
            else {
                Write-Host ' SKIPPED' -ForegroundColor Yellow
                Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
                    -Status 'Warning' -Details 'Device does not respond to ICMP (ping may be blocked)' `
                    -Remediation 'N/A - This check requires ICMP response; firewall may be blocking ping while allowing WinRM/RPC'
            }
        }
        else {
            Write-Host ' SKIPPED' -ForegroundColor Yellow
            Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
                -Status 'Warning' -Details 'Skipped due to DNS resolution failure' `
                -Remediation 'Fix Test-Case-N01 first'
        }
    }
    catch {
        Write-Host ' ERROR' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-N03' -Category 'Network-DNS' -TestName 'DNS Record Freshness' `
            -Status 'Warning' -Details "Error checking DNS freshness: $($_.Exception.Message)" `
            -Remediation 'N/A - Proceed with caution, verify target IP manually'
    }

    Write-Host '[Test-Case-N04] Detecting VPN/Tunnel Adapters...' -NoNewline
    try {
        $VpnAdapters = Get-NetAdapter | Where-Object {
            $_.Status -eq 'Up' -and (
                ($_.InterfaceDescription -match 'VPN|Tunnel|TAP|Cisco|Palo Alto|FortiClient|GlobalProtect|Pulse|SonicWall|CheckPoint|OpenVPN|WireGuard' -and
                $_.InterfaceDescription -notmatch 'Hyper-V|Docker|WSL|vSwitch|VMware|VirtualBox') -or
                ($_.Name -match '^VPN|^Tunnel' -and $_.Name -notmatch 'vEthernet')
            )
        } | Select-Object Name, InterfaceDescription, Status

        if ($VpnAdapters) {
            Write-Host ' DETECTED' -ForegroundColor Yellow
            foreach ($Adapter in $VpnAdapters) {
                Write-Host "  $($Adapter.Name): $($Adapter.InterfaceDescription)" -ForegroundColor Yellow
            }
            Add-TestResult -TestCase 'Test-Case-N04' -Category 'Network-VPN' -TestName 'VPN/Tunnel Detection' `
                -Status 'Warning' -Details "Active VPN/Tunnel adapters detected: $($VpnAdapters.Name -join ', ')" `
                -Remediation "1. Verify VPN routes include target network; 2. Check split-tunnel configuration allows access to target subnet; 3. Test connectivity with VPN disconnected to isolate issue; 4. Verify routing table includes proper routes: 'Get-NetRoute'; 5. Check VPN firewall rules allow WinRM (5985/5986) and RPC (135) traffic; 6. Verify VPN concentrator permits management protocols; Note: Hyper-V/Docker/WSL virtual adapters are excluded from this detection"
        }
        else {
            Write-Host ' NONE' -ForegroundColor Green
            Add-TestResult -TestCase 'Test-Case-N04' -Category 'Network-VPN' -TestName 'VPN/Tunnel Detection' `
                -Status 'Pass' -Details 'No active VPN/Tunnel adapters detected' `
                -Remediation 'N/A'
        }
    }
    catch {
        Write-Host ' ERROR' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-N04' -Category 'Network-VPN' -TestName 'VPN/Tunnel Detection' `
            -Status 'Warning' -Details "Error detecting VPN adapters: $($_.Exception.Message)" `
            -Remediation 'N/A - Manual verification of VPN status recommended'
    }

    Write-Host '[Test-Case-N05] Analyzing Network Routes...' -NoNewline
    try {
        if ($DnsForward -and $ResolvedIP) {
            $SpecificRoute = Get-NetRoute -DestinationPrefix "$ResolvedIP/32" -ErrorAction SilentlyContinue | Select-Object -First 1

            if (-not $SpecificRoute) {
                $DefaultRoute = Get-NetRoute | Where-Object {
                    $_.DestinationPrefix -eq '0.0.0.0/0' -or $_.DestinationPrefix -eq '::/0'
                } | Sort-Object -Property RouteMetric | Select-Object -First 1
                $Route = $DefaultRoute
            }
            else {
                $Route = $SpecificRoute
            }

            if ($Route) {
                $NextHop = $Route.NextHop
                $RouteMetric = $Route.RouteMetric
                $Interface = (Get-NetAdapter -InterfaceIndex $Route.InterfaceIndex -ErrorAction SilentlyContinue).Name

                Write-Host ' FOUND' -ForegroundColor Green
                Write-Host "  Interface: $Interface | Next Hop: $NextHop | Metric: $RouteMetric" -ForegroundColor Gray

                if ($Interface -match 'VPN|Virtual|Tunnel|TAP') {
                    Add-TestResult -TestCase 'Test-Case-N05' -Category 'Network-Routing' -TestName 'Route Analysis' `
                        -Status 'Warning' -Details "Traffic routes through VPN/Tunnel interface: $Interface (Next Hop: $NextHop, Metric: $RouteMetric)" `
                        -Remediation "1. Verify VPN split-tunnel configuration allows access to target network; 2. Check specific routes to target: 'Get-NetRoute | Where-Object DestinationPrefix -like ""*$ResolvedIP*""'; 3. Test with VPN disconnected to confirm VPN routing issue; 4. Verify VPN policy allows management traffic; 5. Check route metric - lower is preferred; 6. Verify next-hop gateway is reachable"
                }
                else {
                    Add-TestResult -TestCase 'Test-Case-N05' -Category 'Network-Routing' -TestName 'Route Analysis' `
                        -Status 'Pass' -Details "Route found via physical interface: $Interface (Next Hop: $NextHop, Metric: $RouteMetric)" `
                        -Remediation 'N/A'
                }
            }
            else {
                Write-Host ' WARNING' -ForegroundColor Yellow
                Add-TestResult -TestCase 'Test-Case-N05' -Category 'Network-Routing' -TestName 'Route Analysis' `
                    -Status 'Warning' -Details 'No route found to target (no default gateway)' `
                    -Remediation "1. Check routing table: 'Get-NetRoute'; 2. Verify default gateway is configured: 'Get-NetIPConfiguration'; 3. Check network adapter status: 'Get-NetAdapter'; 4. Verify target network is reachable; 5. Add static route if needed: 'New-NetRoute'"
            }
        }
        else {
            Write-Host ' SKIPPED' -ForegroundColor Yellow
            Add-TestResult -TestCase 'Test-Case-N05' -Category 'Network-Routing' -TestName 'Route Analysis' `
                -Status 'Warning' -Details 'Skipped due to DNS resolution failure' `
                -Remediation 'Fix Test-Case-N01 first'
        }
    }
    catch {
        Write-Host ' ERROR' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-N05' -Category 'Network-Routing' -TestName 'Route Analysis' `
            -Status 'Warning' -Details "Error analyzing routes: $($_.Exception.Message)" `
            -Remediation "1. Check network configuration: 'Get-NetIPConfiguration'; 2. Verify routing service is running; 3. Review routing table manually: 'Get-NetRoute'"
    }

    Write-Host '[Test-Case-N06] Testing Network Path Quality...' -NoNewline
    try {
        if ($DnsForward -and $ResolvedIP) {
            $PathTest = Test-NetConnection -ComputerName $ResolvedIP -TraceRoute -WarningAction SilentlyContinue -ErrorAction Stop

            if ($PathTest.TraceRoute) {
                $Hops = $PathTest.TraceRoute.Count
                Write-Host ' PASS' -ForegroundColor Green
                Write-Host "  Hops: $Hops | Path: $($PathTest.TraceRoute -join ' -> ')" -ForegroundColor Gray

                if ($Hops -gt $MaxAcceptableHops) {
                    Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
                        -Status 'Warning' -Details "High hop count ($Hops hops exceeds ${MaxAcceptableHops}-hop threshold for $NetworkType network) - potential routing loop or inefficiency" `
                        -Remediation "1. Review traceroute path for routing loops: $($PathTest.TraceRoute -join ' -> '); 2. Check for routing inefficiencies; 3. Verify VPN routing is optimal; 4. High hop count may increase latency affecting WinRM session timeouts; 5. Consider network path optimization; 6. Verify NetworkType parameter matches actual deployment ($NetworkType)"
                }
                elseif ($Hops -gt ($MaxAcceptableHops * 0.75)) {
                    Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
                        -Status 'Pass' -Details "Acceptable hop count for $NetworkType network: $Hops hops (threshold: $MaxAcceptableHops)" `
                        -Remediation 'N/A'
                }
                else {
                    Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
                        -Status 'Pass' -Details "Optimal network path for $NetworkType network: $Hops hops" `
                        -Remediation 'N/A'
                }
            }
            else {
                Write-Host ' WARNING' -ForegroundColor Yellow
                Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
                    -Status 'Warning' -Details 'Traceroute failed or incomplete (ICMP may be blocked)' `
                    -Remediation "1. ICMP may be blocked by intermediate routers/firewalls; 2. This doesn't prevent WinRM/RPC functionality; 3. Proceed with protocol-specific connectivity tests"
            }
        }
        else {
            Write-Host ' SKIPPED' -ForegroundColor Yellow
            Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
                -Status 'Warning' -Details 'Skipped due to DNS resolution failure' `
                -Remediation 'Fix Test-Case-N01 first'
        }
    }
    catch {
        Write-Host ' WARNING' -ForegroundColor Yellow
        Add-TestResult -TestCase 'Test-Case-N06' -Category 'Network-Path' -TestName 'Network Path Quality' `
            -Status 'Warning' -Details "Error testing network path: $($_.Exception.Message)" `
            -Remediation 'N/A - Traceroute may be blocked; proceed with protocol-specific tests'
    }

    Write-Host '[Test-Case-N07] Testing Network Latency & Packet Loss...' -NoNewline
    try {
        $LatencyTest = Test-Connection -ComputerName $ComputerName -Count 4 -ErrorAction SilentlyContinue

        if ($LatencyTest) {
            $SuccessfulPings = $LatencyTest.Count
            $AvgLatency = ($LatencyTest | Measure-Object -Property ResponseTime -Average).Average
            $PacketLoss = ((4 - $SuccessfulPings) / 4) * 100

            Write-Host ' PASS' -ForegroundColor Green
            Write-Host "  Avg Latency: $([math]::Round($AvgLatency, 2))ms | Packet Loss: $PacketLoss%" -ForegroundColor Gray

            $SevereLatencyThreshold = $LatencyThresholdMs * 2.5
            $SeverePacketLossThreshold = $PacketLossThresholdPercent * 2

            if ($AvgLatency -gt $SevereLatencyThreshold -or $PacketLoss -gt $SeverePacketLossThreshold) {
                $Issues = @()
                if ($AvgLatency -gt $SevereLatencyThreshold) { $Issues += "SEVERE latency: $([math]::Round($AvgLatency, 2))ms (threshold: ${LatencyThresholdMs}ms for $NetworkType)" }
                if ($PacketLoss -gt $SeverePacketLossThreshold) { $Issues += "SEVERE packet loss: $PacketLoss% (threshold: ${PacketLossThresholdPercent}%)" }

                Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
                    -Status 'Warning' -Details ($Issues -join '; ') `
                    -Remediation '1. IMMEDIATE investigation required - WinRM sessions will timeout; 2. Check network congestion; 3. Verify physical connections, switches, routers; 4. Test during off-peak hours; 5. Consider QoS configuration for management traffic; 6. WinRM default timeout is 60 seconds - may need adjustment'
            }
            elseif ($AvgLatency -gt $LatencyThresholdMs -or $PacketLoss -gt $PacketLossThresholdPercent) {
                $Issues = @()
                if ($AvgLatency -gt $LatencyThresholdMs) { $Issues += "Elevated latency: $([math]::Round($AvgLatency, 2))ms (threshold: ${LatencyThresholdMs}ms for $NetworkType)" }
                if ($PacketLoss -gt $PacketLossThresholdPercent) { $Issues += "Elevated packet loss: $PacketLoss% (threshold: ${PacketLossThresholdPercent}%)" }

                Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
                    -Status 'Warning' -Details ($Issues -join '; ') `
                    -Remediation '1. May cause intermittent WinRM issues - monitor session stability; 2. Check network congestion during peak hours; 3. Verify VPN connection stability; 4. Note: ICMP may be QoS-deprioritized while TCP remains stable; 5. Consider testing actual WinRM session performance'
            }
            elseif ($AvgLatency -gt ($LatencyThresholdMs * 0.5) -or $PacketLoss -gt ($PacketLossThresholdPercent * 0.4)) {
                Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
                    -Status 'Pass' -Details "Acceptable $NetworkType network performance: Latency $([math]::Round($AvgLatency, 2))ms, Packet Loss $PacketLoss%" `
                    -Remediation 'N/A'
            }
            else {
                Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
                    -Status 'Pass' -Details "Excellent network performance: Latency $([math]::Round($AvgLatency, 2))ms, Packet Loss $PacketLoss%" `
                    -Remediation 'N/A'
            }
        }
        else {
            Write-Host ' SKIPPED' -ForegroundColor Yellow
            Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
                -Status 'Warning' -Details 'ICMP not responding - latency test skipped (firewall may block ICMP)' `
                -Remediation "N/A - ICMP blocking doesn't affect WinRM/RPC functionality; firewall configuration is normal"
        }
    }
    catch {
        Write-Host ' ERROR' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-N07' -Category 'Network-Latency' -TestName 'Network Latency & Packet Loss' `
            -Status 'Warning' -Details "Error testing latency: $($_.Exception.Message)" `
            -Remediation 'N/A - Proceed with protocol-specific tests'
    }

    Write-Host ''
}

Write-Host '=== Protocol & Service Validation ===' -ForegroundColor Cyan

Write-Host '[Test-Case-001] Testing ICMP Reachability...' -NoNewline
try {
    $PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop

    if ($PingResult) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-001' -Category 'Protocol' -TestName 'ICMP Reachability' `
            -Status 'Pass' -Details 'Device responds to ICMP Echo requests' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-001' -Category 'Protocol' -TestName 'ICMP Reachability' `
            -Status 'Fail' -Details 'Device does not respond to ICMP Echo requests' `
            -Remediation "1. Verify network connectivity and routing (see network tests above); 2. Check firewall allows ICMP inbound; 3. Verify device is powered on and network connected; 4. Check network cable/wireless connection; 5. Note: ICMP blocking doesn't prevent WinRM/RPC functionality"
    }
}
catch {
    Write-Host ' ERROR' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-001' -Category 'Protocol' -TestName 'ICMP Reachability' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation '1. Verify hostname/IP is correct; 2. Check DNS resolution (see Test-Case-N01); 3. Verify network path exists'
}

$WSManPort = if ($TestHTTPS) { 5986 } else { 5985 }
$WSManProtocol = if ($TestHTTPS) { 'HTTPS' } else { 'HTTP' }

Write-Host "[Test-Case-002] Testing CIM/WSMan Port Access ($WSManProtocol - $WSManPort)..." -NoNewline
try {
    $PortTest = Test-NetConnection -ComputerName $ComputerName -Port $WSManPort -WarningAction SilentlyContinue -ErrorAction Stop

    if ($PortTest.TcpTestSucceeded) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-002' -Category 'Protocol-Port' -TestName "WSMan Port $WSManPort" `
            -Status 'Pass' -Details "Port $WSManPort ($WSManProtocol) is open and accessible" `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-002' -Category 'Protocol-Port' -TestName "WSMan Port $WSManPort" `
            -Status 'Fail' -Details "Port $WSManPort ($WSManProtocol) is not accessible (connection refused or filtered)" `
            -Remediation "1. Enable WinRM on target: Run 'Enable-PSRemoting -Force' on target machine; 2. Configure firewall on target: 'Enable-NetFirewallRule -Name WINRM-HTTP-In-TCP'; 3. Start WinRM service: 'Start-Service WinRM' and 'Set-Service WinRM -StartupType Automatic'; 4. For non-domain joined: Configure TrustedHosts: 'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ComputerName'; 5. Check intermediate firewalls/ACLs blocking port $WSManPort"
    }
}
catch {
    Write-Host ' ERROR' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-002' -Category 'Protocol-Port' -TestName "WSMan Port $WSManPort" `
        -Status 'Fail' -Details "Error testing port: $($_.Exception.Message)" `
        -Remediation '1. Verify network connectivity (Test-Case-001 should pass first); 2. Check intermediate firewalls; 3. Verify WinRM service is running on target'
}

Write-Host '[Test-Case-003] Testing WMI/DCOM RPC Endpoint (Port 135)...' -NoNewline
try {
    $RPCTest = Test-NetConnection -ComputerName $ComputerName -Port 135 -WarningAction SilentlyContinue -ErrorAction Stop

    if ($RPCTest.TcpTestSucceeded) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-003' -Category 'Protocol-Port' -TestName 'RPC Endpoint Mapper (135)' `
            -Status 'Pass' -Details 'RPC Endpoint Mapper port 135 is accessible' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-003' -Category 'Protocol-Port' -TestName 'RPC Endpoint Mapper (135)' `
            -Status 'Fail' -Details 'RPC port 135 is not accessible (connection refused or filtered)' `
            -Remediation "1. Enable DCOM on target; 2. Configure firewall for WMI: 'netsh advfirewall firewall set rule group=""Windows Management Instrumentation (WMI)"" new enable=yes'; 3. Start RPC service: 'Start-Service RpcSs' and 'Set-Service RpcSs -StartupType Automatic'; 4. Verify COM Security permissions in Component Services (dcomcnfg); 5. Check firewall allows RPC port 135 inbound"
    }
}
catch {
    Write-Host ' ERROR' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-003' -Category 'Protocol-Port' -TestName 'RPC Endpoint Mapper (135)' `
        -Status 'Fail' -Details "Error testing port: $($_.Exception.Message)" `
        -Remediation '1. Verify network connectivity; 2. Check firewall rules for RPC; 3. Verify RpcSs service is running on target'
}

if ($IncludeDynamicPorts) {
    Write-Host '[Optional] Testing RPC Dynamic Port Range (49152-65535)...' -ForegroundColor Yellow
    Write-Host 'WARNING: Testing sample range 49152-49160 only (full range test would take hours)...' -ForegroundColor Yellow

    $DynamicPortStart = 49152
    $DynamicPortEnd = 49160
    $OpenPorts = @()

    for ($Port = $DynamicPortStart; $Port -le $DynamicPortEnd; $Port++) {
        $TestPort = Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if ($TestPort.TcpTestSucceeded) {
            $OpenPorts += $Port
        }
    }

    if ($OpenPorts.Count -gt 0) {
        Write-Host "Found $($OpenPorts.Count) open ports in sample range $DynamicPortStart-$DynamicPortEnd" -ForegroundColor Green
        Add-TestResult -TestCase 'Optional' -Category 'Protocol-Port' -TestName 'RPC Dynamic Ports (Sample)' `
            -Status 'Pass' -Details "Found open RPC dynamic ports in sample range: $($OpenPorts -join ', ')" `
            -Remediation 'N/A'
    }
    else {
        Write-Host "No open ports found in sample range $DynamicPortStart-$DynamicPortEnd" -ForegroundColor Yellow
        Add-TestResult -TestCase 'Optional' -Category 'Protocol-Port' -TestName 'RPC Dynamic Ports (Sample)' `
            -Status 'Warning' -Details 'No dynamic ports detected in sample range - firewall may be blocking' `
            -Remediation "1. This may be normal if RPC not actively listening; 2. Configure static RPC port range: 'netsh int ipv4 set dynamicport tcp start=49152 num=16384'; 3. Configure firewall to allow RPC dynamic range; 4. WMI may still work if DCOM configured properly"
    }
}

Write-Host '[Test-Case-004] Testing CIM Session Creation...' -NoNewline
$CimSession = $null
try {
    $SessionParams = @{
        ComputerName = $ComputerName
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $SessionParams.Credential = $Credential
    }

    $CimSession = New-CimSession @SessionParams

    if ($CimSession) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-004' -Category 'Authentication' -TestName 'CIM Session Creation' `
            -Status 'Pass' -Details 'Successfully created CIM session using WSMan protocol' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-004' -Category 'Authentication' -TestName 'CIM Session Creation' `
            -Status 'Fail' -Details 'CIM session creation returned null' `
            -Remediation "1. Verify WinRM is enabled (Test-Case-002 must pass); 2. Check authentication credentials are correct; 3. Verify user has remote management permissions on target; 4. For CredSSP: 'Enable-WSManCredSSP -Role Client -DelegateComputer $ComputerName'"
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-004' -Category 'Authentication' -TestName 'CIM Session Creation' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify credentials are correct; 2. Check user is in 'Remote Management Users' or 'Administrators' group on target; 3. Test WinRM: 'Test-WSMan $ComputerName'; 4. For non-domain: Configure TrustedHosts on both source and target; 5. Verify Kerberos authentication is working (domain joined) or use explicit credentials (workgroup)"
}
finally {
    if ($CimSession) {
        Remove-CimSession -CimSession $CimSession -ErrorAction SilentlyContinue
    }
}

Write-Host '[Test-Case-005] Testing WMI Namespace Access...' -NoNewline
try {
    $WmiParams = @{
        ComputerName = $ComputerName
        Namespace    = 'root\cimv2'
        Class        = 'Win32_OperatingSystem'
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $WmiParams.Credential = $Credential
    }

    $WmiResult = Get-WmiObject @WmiParams | Select-Object -First 1

    if ($WmiResult) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-005' -Category 'Authentication' -TestName 'WMI Namespace Access' `
            -Status 'Pass' -Details 'Successfully queried WMI namespace root\cimv2 via DCOM' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-005' -Category 'Authentication' -TestName 'WMI Namespace Access' `
            -Status 'Fail' -Details 'WMI query returned no results' `
            -Remediation "1. Verify DCOM is enabled on target; 2. Check WMI service is running: 'Start-Service Winmgmt'; 3. Repair WMI repository: 'winmgmt /salvagerepository' or 'winmgmt /resetrepository'"
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-005' -Category 'Authentication' -TestName 'WMI Namespace Access' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify RPC access (Test-Case-003 must pass); 2. Check DCOM permissions in Component Services (dcomcnfg.exe); 3. Verify user is in 'Distributed COM Users' group on target; 4. Enable WMI firewall rules: 'netsh advfirewall firewall set rule group=""Windows Management Instrumentation (WMI)"" new enable=yes'; 5. Check DCOM security: Launch and Activation Permissions, Access Permissions"
}

Write-Host '[Test-Case-006] Testing PowerShell Remoting Access...' -NoNewline
try {
    $InvokeParams = @{
        ComputerName = $ComputerName
        ScriptBlock  = { 1 }
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $InvokeParams.Credential = $Credential
    }

    $RemoteResult = Invoke-Command @InvokeParams

    if ($RemoteResult -eq 1) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-006' -Category 'Authentication' -TestName 'PowerShell Remoting' `
            -Status 'Pass' -Details 'Successfully executed remote command via PowerShell Remoting (WinRM)' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-006' -Category 'Authentication' -TestName 'PowerShell Remoting' `
            -Status 'Fail' -Details "Remote command returned unexpected result: $RemoteResult" `
            -Remediation "1. Verify WinRM configuration on target; 2. Check execution policy: 'Set-ExecutionPolicy RemoteSigned' on target; 3. Test manually: 'Enter-PSSession -ComputerName $ComputerName'"
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-006' -Category 'Authentication' -TestName 'PowerShell Remoting' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Enable PS Remoting on target: 'Enable-PSRemoting -Force'; 2. Verify WSMan port access (Test-Case-002 must pass); 3. For non-domain: Set TrustedHosts on client: 'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ComputerName'; 4. Check user has remote management permissions; 5. Verify WinRM service is running: 'Start-Service WinRM'"
}

Write-Host '[Test-Case-007] Testing Remote Registry Access...' -NoNewline
try {
    $ScriptBlock = {
        try {
            $RegTest = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion' -Name 'ProgramFilesDir' -ErrorAction Stop
            if ($RegTest) { return $true } else { return $false }
        }
        catch {
            return $false
        }
    }

    $InvokeParams = @{
        ComputerName = $ComputerName
        ScriptBlock  = $ScriptBlock
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $InvokeParams.Credential = $Credential
    }

    $RegistryResult = Invoke-Command @InvokeParams

    if ($RegistryResult) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-007' -Category 'Service' -TestName 'Remote Registry Access' `
            -Status 'Pass' -Details 'Successfully accessed remote registry via PowerShell Remoting' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-007' -Category 'Service' -TestName 'Remote Registry Access' `
            -Status 'Fail' -Details 'Unable to read remote registry keys' `
            -Remediation "1. Verify PS Remoting works (Test-Case-006 must pass); 2. Enable Remote Registry service on target: 'Start-Service RemoteRegistry'; 3. Set service to auto-start: 'Set-Service RemoteRegistry -StartupType Automatic'; 4. Verify registry permissions allow remote access; 5. Check GPO hasn't disabled remote registry"
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-007' -Category 'Service' -TestName 'Remote Registry Access' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation '1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check Remote Registry service status on target; 3. Verify user has registry read permissions; 4. Required for Get-MDEStatus.ps1 Registry validation method'
}

Write-Host '[Test-Case-008] Testing Remote Service Enumeration...' -NoNewline
try {
    $ScriptBlock = {
        try {
            $Svc = Get-Service -Name 'Winmgmt' -ErrorAction Stop
            if ($Svc) { return $true } else { return $false }
        }
        catch {
            return $false
        }
    }

    $InvokeParams = @{
        ComputerName = $ComputerName
        ScriptBlock  = $ScriptBlock
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $InvokeParams.Credential = $Credential
    }

    $ServiceResult = Invoke-Command @InvokeParams

    if ($ServiceResult) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-008' -Category 'Service' -TestName 'Remote Service Enumeration' `
            -Status 'Pass' -Details 'Successfully enumerated remote services (Windows Management Instrumentation)' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-008' -Category 'Service' -TestName 'Remote Service Enumeration' `
            -Status 'Fail' -Details 'Unable to enumerate remote services' `
            -Remediation '1. Verify PS Remoting works (Test-Case-006 must pass); 2. Check user permissions for service control on target; 3. Verify Services management is not restricted by Group Policy; 4. User needs to be in Administrators or specific service access groups'
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-008' -Category 'Service' -TestName 'Remote Service Enumeration' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation '1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check Service Control Manager permissions on target; 3. Verify user is in appropriate security groups; 4. Required for Get-MDEStatus.ps1 Service validation method'
}

Write-Host '[Test-Case-009] Testing Remote Event Log Access...' -NoNewline
try {
    $ScriptBlock = {
        try {
            $Event = Get-WinEvent -LogName 'System' -MaxEvents 1 -ErrorAction Stop
            if ($Event) { return $true } else { return $false }
        }
        catch {
            return $false
        }
    }

    $InvokeParams = @{
        ComputerName = $ComputerName
        ScriptBlock  = $ScriptBlock
        ErrorAction  = 'Stop'
    }

    if ($Credential) {
        $InvokeParams.Credential = $Credential
    }

    $EventLogResult = Invoke-Command @InvokeParams

    if ($EventLogResult) {
        Write-Host ' PASS' -ForegroundColor Green
        Add-TestResult -TestCase 'Test-Case-009' -Category 'Service' -TestName 'Remote Event Log Access' `
            -Status 'Pass' -Details 'Successfully accessed remote event logs (System log)' `
            -Remediation 'N/A'
    }
    else {
        Write-Host ' FAIL' -ForegroundColor Red
        Add-TestResult -TestCase 'Test-Case-009' -Category 'Service' -TestName 'Remote Event Log Access' `
            -Status 'Fail' -Details 'Unable to read remote event logs' `
            -Remediation "1. Verify PS Remoting works (Test-Case-006 must pass); 2. Add user to 'Event Log Readers' local group on target; 3. Verify Event Log service is running: 'Start-Service EventLog'; 4. Check event log file permissions; 5. Verify GPO allows remote event log access"
    }
}
catch {
    Write-Host ' FAIL' -ForegroundColor Red
    Add-TestResult -TestCase 'Test-Case-009' -Category 'Service' -TestName 'Remote Event Log Access' `
        -Status 'Fail' -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check 'Event Log Readers' group membership on target; 3. Verify Event Log service status; 4. Check Group Policy restrictions on event log access; 5. Required for Get-MDEStatus.ps1 SENSE event log queries"
}

Write-Host ''
Write-Host '=== Validation Summary ===' -ForegroundColor Yellow

$PassedTests = ($Results | Where-Object Status -EQ 'Pass').Count
$FailedTests = ($Results | Where-Object Status -EQ 'Fail').Count
$WarningTests = ($Results | Where-Object Status -EQ 'Warning').Count
$TotalTests = $Results.Count

Write-Host "Total Tests: $TotalTests" -ForegroundColor Cyan
Write-Host "Passed: $PassedTests" -ForegroundColor Green
Write-Host "Failed: $FailedTests" -ForegroundColor Red
if ($WarningTests -gt 0) {
    Write-Host "Warnings: $WarningTests" -ForegroundColor Yellow
}

Write-Host ''
if ($OverallStatus -eq 'Pass' -and $FailedTests -eq 0) {
    Write-Host '✅ All critical prerequisites validated successfully' -ForegroundColor Green
    Write-Host 'Remote validation methods available for Get-MDEStatus.ps1:' -ForegroundColor Green
    Write-Host '  - CIM/WSMan (Modern Windows 10/11, Server 2016+)' -ForegroundColor Green
    Write-Host '  - WMI/DCOM (Legacy Windows 7, Server 2008 R2)' -ForegroundColor Green
    Write-Host '  - PowerShell Remoting (Registry/Service/EventLog access)' -ForegroundColor Green

    if ($WarningTests -gt 0) {
        Write-Host ''
        Write-Host '⚠️ Warnings detected (non-critical):' -ForegroundColor Yellow
        $Results | Where-Object Status -EQ 'Warning' | ForEach-Object {
            Write-Host "  - [$($_.TestCase)] $($_.TestName): $($_.Details)" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host '❌ One or more critical prerequisites failed' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Failed Tests Requiring Immediate Attention:' -ForegroundColor Red
    $Results | Where-Object Status -EQ 'Fail' | ForEach-Object {
        Write-Host ''
        Write-Host "[$($_.TestCase)] $($_.TestName)" -ForegroundColor Red
        Write-Host "  Issue: $($_.Details)" -ForegroundColor Yellow
        Write-Host '  Remediation Steps:' -ForegroundColor Cyan
        $RemediationSteps = $_.Remediation -split '; '
        foreach ($Step in $RemediationSteps) {
            Write-Host "    $Step" -ForegroundColor Gray
        }
    }
}

if (-not $OutputPath) {
    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $TextOutputPath = "MDE-Status-Prerequisites-$ComputerName-$Timestamp.txt"
    $HtmlOutputPath = "MDE-Status-Prerequisites-$ComputerName-$Timestamp.html"
}
else {
    $TextOutputPath = $OutputPath
    if ($GenerateHTML) {
        $HtmlOutputPath = $OutputPath -replace '\.txt$', '.html'
        if ($HtmlOutputPath -eq $TextOutputPath) {
            $HtmlOutputPath = $OutputPath -replace '(\.[^.]+)?$', '.html'
        }
    }
}

$TextReport = @"
===============================================================================
  MDE STATUS PREREQUISITES VALIDATION REPORT
===============================================================================

Target Computer: $ComputerName
Generated: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Overall Status: $OverallStatus

===============================================================================
  SUMMARY
===============================================================================

Total Tests: $TotalTests
Passed: $PassedTests
Failed: $FailedTests
$(if ($WarningTests -gt 0) { "Warnings: $WarningTests" })

===============================================================================
  DETAILED TEST RESULTS
===============================================================================

"@

foreach ($Result in $Results) {
    $TextReport += @"
[$($Result.TestCase)] $($Result.TestName)
  Category: $($Result.Category)
  Status: $($Result.Status)
  Details: $($Result.Details)
$(if ($Result.Status -in @('Fail','Warning')) { "  Remediation: $($Result.Remediation)" })
  Timestamp: $($Result.Timestamp)

"@
}

if ($FailedTests -gt 0) {
    $TextReport += @'
===============================================================================
  FAILED TESTS REQUIRING IMMEDIATE ATTENTION
===============================================================================

'@
    $Results | Where-Object Status -EQ 'Fail' | ForEach-Object {
        $TextReport += @"
[$($_.TestCase)] $($_.TestName)
  Issue: $($_.Details)
  Remediation Steps:
"@
        $RemediationSteps = $_.Remediation -split '; '
        foreach ($Step in $RemediationSteps) {
            $TextReport += "    - $Step`n"
        }
        $TextReport += "`n"
    }
}

if ($WarningTests -gt 0) {
    $TextReport += @'
===============================================================================
  WARNINGS (NON-CRITICAL)
===============================================================================

'@
    $Results | Where-Object Status -EQ 'Warning' | ForEach-Object {
        $TextReport += "[$($_.TestCase)] $($_.TestName): $($_.Details)`n"
    }
    $TextReport += "`n"
}

$TextReport += @'
===============================================================================
  RECOMMENDATIONS
===============================================================================

'@

if ($OverallStatus -eq 'Pass' -and $FailedTests -eq 0) {
    $TextReport += @'
All critical prerequisites validated successfully.

Remote validation methods available for Get-MDEStatus.ps1:
  - CIM/WSMan (Modern Windows 10/11, Server 2016+)
  - WMI/DCOM (Legacy Windows 7, Server 2008 R2)
  - PowerShell Remoting (Registry/Service/EventLog access)
'@
}
else {
    $TextReport += @'
One or more critical prerequisites failed.

Action Required:
  1. Review failed tests above
  2. Follow remediation steps for each failed test
  3. Re-run this script after remediation
  4. Ensure all tests pass before running Get-MDEStatus.ps1 in production
'@
}

$TextReport += @'

===============================================================================
  SCRIPT INFORMATION
===============================================================================

Script: Test-MDEStatusPrerequisites.ps1 v2.0
Purpose: Validates all prerequisites for Get-MDEStatus.ps1 remote validation
         methods including network layer, DNS, VPN/tunnel detection, and
         protocol-specific connectivity.
Reference: See Get-MDEStatus.ps1 for MDE validation methods.

===============================================================================
'@

try {
    $TextReport | Out-File -FilePath $TextOutputPath -Encoding UTF8 -Force
    Write-Host ''
    Write-Host "📄 Text report saved to: $TextOutputPath" -ForegroundColor Cyan
}
catch {
    Write-Warning "Failed to save text report: $_"
}

if ($GenerateHTML) {
    $HtmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>MDE Status Prerequisites Report - $ComputerName</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078D4; border-bottom: 3px solid #0078D4; padding-bottom: 10px; }
        h2 { color: #005A9E; margin-top: 30px; border-bottom: 2px solid #E1E1E1; padding-bottom: 8px; }
        .summary { background-color: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .summary-item { display: inline-block; margin-right: 30px; font-size: 18px; font-weight: bold; }
        .category-section { background-color: #fff; padding: 15px; margin: 15px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; background-color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-top: 10px; }
        th { background-color: #0078D4; color: white; padding: 12px; text-align: left; font-size: 14px; }
        td { padding: 10px; border-bottom: 1px solid #ddd; font-size: 13px; }
        tr:hover { background-color: #f1f1f1; }
        .pass { color: #107C10; font-weight: bold; }
        .fail { color: #D13438; font-weight: bold; }
        .warning { color: #FF8C00; font-weight: bold; }
        .remediation { background-color: #FFF4CE; padding: 10px; border-left: 4px solid #FFB900; margin: 5px 0; font-size: 12px; line-height: 1.6; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
        .test-case { font-family: 'Consolas', 'Courier New', monospace; background-color: #f0f0f0; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>🛡️ MDE Status Prerequisites Validation Report</h1>
    <div class="summary">
        <div class="summary-item">Target: <span style="color: #0078D4;">$ComputerName</span></div>
        <div class="summary-item">Generated: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</div>
        <div class="summary-item">Overall Status: <span class="$($OverallStatus.ToLower())">$OverallStatus</span></div>
    </div>

    <div class="summary">
        <div class="summary-item"><span class="pass">✅ Passed: $PassedTests</span></div>
        <div class="summary-item"><span class="fail">❌ Failed: $FailedTests</span></div>
$(if ($WarningTests -gt 0) { "        <div class='summary-item'><span class='warning'>⚠️ Warnings: $WarningTests</span></div>" })
        <div class="summary-item">Total Tests: $TotalTests</div>
    </div>

$(if (-not $SkipNetworkTests) {
"    <div class='category-section'>
        <h2>🌐 Network Layer Tests</h2>
        <table>
            <tr>
                <th>Test Case</th>
                <th>Test Name</th>
                <th>Status</th>
                <th>Details</th>
                <th>Remediation</th>
            </tr>
$(foreach ($Result in ($Results | Where-Object Category -Like 'Network-*')) {
"            <tr>
                <td class='test-case'>$($Result.TestCase)</td>
                <td>$($Result.TestName)</td>
                <td class='$($Result.Status.ToLower())'>$($Result.Status)</td>
                <td>$($Result.Details)</td>
                <td>$(if ($Result.Status -in @('Fail','Warning')) { "<div class='remediation'>$($Result.Remediation)</div>" } else { $Result.Remediation })</td>
            </tr>"
})
        </table>
    </div>"
})

    <div class="category-section">
        <h2>🔌 Protocol & Port Tests</h2>
        <table>
            <tr>
                <th>Test Case</th>
                <th>Test Name</th>
                <th>Status</th>
                <th>Details</th>
                <th>Remediation</th>
            </tr>
$(foreach ($Result in ($Results | Where-Object Category -Like 'Protocol*')) {
"            <tr>
                <td class='test-case'>$($Result.TestCase)</td>
                <td>$($Result.TestName)</td>
                <td class='$($Result.Status.ToLower())'>$($Result.Status)</td>
                <td>$($Result.Details)</td>
                <td>$(if ($Result.Status -eq 'Fail') { "<div class='remediation'>$($Result.Remediation)</div>" } else { $Result.Remediation })</td>
            </tr>"
})
        </table>
    </div>

    <div class="category-section">
        <h2>🔐 Authentication & Service Tests</h2>
        <table>
            <tr>
                <th>Test Case</th>
                <th>Test Name</th>
                <th>Status</th>
                <th>Details</th>
                <th>Remediation</th>
            </tr>
$(foreach ($Result in ($Results | Where-Object Category -In @('Authentication','Service'))) {
"            <tr>
                <td class='test-case'>$($Result.TestCase)</td>
                <td>$($Result.TestName)</td>
                <td class='$($Result.Status.ToLower())'>$($Result.Status)</td>
                <td>$($Result.Details)</td>
                <td>$(if ($Result.Status -eq 'Fail') { "<div class='remediation'>$($Result.Remediation)</div>" } else { $Result.Remediation })</td>
            </tr>"
})
        </table>
    </div>

    <div class="footer">
        <p><strong>Script:</strong> Test-MDEStatusPrerequisites.ps1 v2.0</p>
        <p><strong>Purpose:</strong> Validates all prerequisites for Get-MDEStatus.ps1 remote validation methods including network layer, DNS, VPN/tunnel detection, and protocol-specific connectivity.</p>
        <p><strong>Next Steps:</strong> Remediate all failed tests before running Get-MDEStatus.ps1 in production. Warnings are non-critical but should be reviewed.</p>
        <p><strong>Reference:</strong> See Get-MDEStatus.ps1 for MDE validation methods that depend on these prerequisites.</p>
    </div>
</body>
</html>
"@

    try {
        $HtmlReport | Out-File -FilePath $HtmlOutputPath -Encoding UTF8 -Force
        Write-Host "📄 HTML report saved to: $HtmlOutputPath" -ForegroundColor Cyan
    }
    catch {
        Write-Warning "Failed to save HTML report: $_"
    }
}

Write-Host ''
Write-Host "Completed: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan

if ($FailedTests -gt 0) {
    exit 1
}
else {
    exit 0
}
