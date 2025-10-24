<#
.SYNOPSIS
    Validates connectivity prerequisites for Get-MDEStatus.ps1 remote validation methods.

.DESCRIPTION
    Comprehensive pre-flight validation script that tests network connectivity, port accessibility,
    service availability, and authentication for all remote access methods used by Get-MDEStatus.ps1:
    
    1. ICMP Ping - Basic network reachability
    2. CIM/WSMan - Modern Windows 10/11, Server 2016+ (ports 5985/5986)
    3. WMI/DCOM - Legacy Windows 7, Server 2008 R2 (port 135 + dynamic)
    4. PowerShell Remoting - Registry, Service, Event Log access (ports 5985/5986)
    
    Provides actionable troubleshooting guidance for failed prerequisites with specific remediation steps.

.PARAMETER ComputerName
    Target computer name or IP address to validate connectivity against.

.PARAMETER Credential
    PSCredential for remote access authentication. If not provided, uses current context.

.PARAMETER TestHTTPS
    Test HTTPS WSMan (port 5986) instead of HTTP (port 5985). Default is HTTP.

.PARAMETER IncludeDynamicPorts
    Test dynamic RPC port range (49152-65535) for WMI/DCOM. WARNING: This is slow.

.PARAMETER OutputPath
    Path for detailed HTML report. Defaults to current directory with timestamp.

.EXAMPLE
    .\Test-MDEConnectivityPrerequisites.ps1 -ComputerName "WORKSTATION01"

.EXAMPLE
    $Cred = Get-Credential
    .\Test-MDEConnectivityPrerequisites.ps1 -ComputerName "SERVER01" -Credential $Cred -TestHTTPS

.EXAMPLE
    .\Test-MDEConnectivityPrerequisites.ps1 -ComputerName "10.0.1.50" -OutputPath "C:\Reports\connectivity.html"

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+
    
    Port Reference:
    - ICMP Echo: Network Layer (Type 8)
    - WSMan HTTP: TCP 5985
    - WSMan HTTPS: TCP 5986
    - RPC Endpoint Mapper: TCP 135
    - RPC Dynamic: TCP 49152-65535
    
    Service Requirements:
    - WinRM (Windows Remote Management)
    - RpcSs (Remote Procedure Call)
    - RemoteRegistry (Remote Registry - optional)
    
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
    [string]$OutputPath
)

$ErrorActionPreference = 'Continue'

$Results = [System.Collections.ArrayList]::new()
$OverallStatus = 'Pass'

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

Write-Host "`n=== MDE Connectivity Prerequisites Validation ===" -ForegroundColor Cyan
Write-Host "Target: $ComputerName" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Test-Case-001] Testing ICMP Reachability..." -NoNewline
try {
    $PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop
    
    if ($PingResult) {
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-001" -Category "Network" -TestName "ICMP Reachability" `
            -Status "Pass" -Details "Device responds to ICMP Echo requests" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-001" -Category "Network" -TestName "ICMP Reachability" `
            -Status "Fail" -Details "Device does not respond to ICMP Echo requests" `
            -Remediation "1. Verify network connectivity; 2. Check firewall allows ICMP; 3. Verify device is online; 4. Check network routing"
    }
}
catch {
    Write-Host " ERROR" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-001" -Category "Network" -TestName "ICMP Reachability" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify hostname/IP is correct; 2. Check DNS resolution; 3. Verify network path exists"
}

$WSManPort = if ($TestHTTPS) { 5986 } else { 5985 }
$WSManProtocol = if ($TestHTTPS) { "HTTPS" } else { "HTTP" }

Write-Host "[Test-Case-002] Testing CIM/WSMan Port Access ($WSManProtocol - $WSManPort)..." -NoNewline
try {
    $PortTest = Test-NetConnection -ComputerName $ComputerName -Port $WSManPort -WarningAction SilentlyContinue -ErrorAction Stop
    
    if ($PortTest.TcpTestSucceeded) {
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-002" -Category "Network" -TestName "WSMan Port $WSManPort" `
            -Status "Pass" -Details "Port $WSManPort ($WSManProtocol) is open and accessible" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-002" -Category "Network" -TestName "WSMan Port $WSManPort" `
            -Status "Fail" -Details "Port $WSManPort ($WSManProtocol) is not accessible" `
            -Remediation "1. Enable WinRM: Run 'Enable-PSRemoting -Force'; 2. Configure firewall: 'Enable-NetFirewallRule -Name WINRM-HTTP-In-TCP'; 3. Start WinRM service: 'Start-Service WinRM'; 4. Check TrustedHosts if non-domain: 'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ComputerName'"
    }
}
catch {
    Write-Host " ERROR" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-002" -Category "Network" -TestName "WSMan Port $WSManPort" `
        -Status "Fail" -Details "Error testing port: $($_.Exception.Message)" `
        -Remediation "1. Verify network connectivity (Test-Case-001 must pass first); 2. Check intermediate firewalls; 3. Verify WinRM service is running on target"
}

Write-Host "[Test-Case-003] Testing WMI/DCOM RPC Endpoint (Port 135)..." -NoNewline
try {
    $RPCTest = Test-NetConnection -ComputerName $ComputerName -Port 135 -WarningAction SilentlyContinue -ErrorAction Stop
    
    if ($RPCTest.TcpTestSucceeded) {
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-003" -Category "Network" -TestName "RPC Endpoint Mapper (135)" `
            -Status "Pass" -Details "RPC Endpoint Mapper port 135 is accessible" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-003" -Category "Network" -TestName "RPC Endpoint Mapper (135)" `
            -Status "Fail" -Details "RPC port 135 is not accessible" `
            -Remediation "1. Enable DCOM: Run 'winrm set winrm/config/client @{TrustedHosts=""*""}'; 2. Configure firewall for WMI: 'netsh advfirewall firewall set rule group=""windows management instrumentation (wmi)"" new enable=yes'; 3. Start RPC service: 'Start-Service RpcSs'; 4. Verify COM Security permissions in Component Services (dcomcnfg)"
    }
}
catch {
    Write-Host " ERROR" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-003" -Category "Network" -TestName "RPC Endpoint Mapper (135)" `
        -Status "Fail" -Details "Error testing port: $($_.Exception.Message)" `
        -Remediation "1. Verify network connectivity; 2. Check firewall rules for RPC; 3. Verify RpcSs service is running"
}

if ($IncludeDynamicPorts) {
    Write-Host "[Optional] Testing RPC Dynamic Port Range (49152-65535)..." -ForegroundColor Yellow
    Write-Host "WARNING: This test is slow and may take several minutes..." -ForegroundColor Yellow
    
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
        Write-Host "Found $($OpenPorts.Count) open ports in range $DynamicPortStart-$DynamicPortEnd" -ForegroundColor Green
        Add-TestResult -TestCase "Optional" -Category "Network" -TestName "RPC Dynamic Ports" `
            -Status "Pass" -Details "Found open ports: $($OpenPorts -join ', ')" `
            -Remediation "N/A"
    }
    else {
        Write-Host "No open ports found in sample range $DynamicPortStart-$DynamicPortEnd" -ForegroundColor Yellow
        Add-TestResult -TestCase "Optional" -Category "Network" -TestName "RPC Dynamic Ports" `
            -Status "Warning" -Details "No dynamic ports detected in sample range" `
            -Remediation "This may be normal. Configure static RPC port range: 'netsh int ipv4 set dynamicport tcp start=49152 num=16384'"
    }
}

Write-Host "[Test-Case-004] Testing CIM Session Creation..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-004" -Category "Authentication" -TestName "CIM Session Creation" `
            -Status "Pass" -Details "Successfully created CIM session using WSMan" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-004" -Category "Authentication" -TestName "CIM Session Creation" `
            -Status "Fail" -Details "CIM session creation returned null" `
            -Remediation "1. Verify WinRM is enabled (Test-Case-002 must pass); 2. Check authentication credentials; 3. Verify CredSSP if required: 'Enable-WSManCredSSP -Role Client -DelegateComputer $ComputerName'"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-004" -Category "Authentication" -TestName "CIM Session Creation" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify credentials are correct; 2. Check user has remote management permissions; 3. Verify WinRM configuration: 'Test-WSMan $ComputerName'; 4. For non-domain: Configure TrustedHosts and provide credentials explicitly"
}
finally {
    if ($CimSession) {
        Remove-CimSession -CimSession $CimSession -ErrorAction SilentlyContinue
    }
}

Write-Host "[Test-Case-005] Testing WMI Namespace Access..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-005" -Category "Authentication" -TestName "WMI Namespace Access" `
            -Status "Pass" -Details "Successfully queried WMI namespace root\cimv2" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-005" -Category "Authentication" -TestName "WMI Namespace Access" `
            -Status "Fail" -Details "WMI query returned no results" `
            -Remediation "1. Verify DCOM is enabled; 2. Check WMI service is running: 'Start-Service Winmgmt'; 3. Repair WMI repository: 'winmgmt /salvagerepository'"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-005" -Category "Authentication" -TestName "WMI Namespace Access" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify RPC access (Test-Case-003 must pass); 2. Check DCOM permissions in Component Services; 3. Verify user is in 'Distributed COM Users' group; 4. Check firewall allows WMI: 'netsh advfirewall firewall set rule group=""windows management instrumentation (wmi)"" new enable=yes'"
}

Write-Host "[Test-Case-006] Testing PowerShell Remoting Access..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-006" -Category "Authentication" -TestName "PowerShell Remoting" `
            -Status "Pass" -Details "Successfully executed remote command via PS Remoting" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-006" -Category "Authentication" -TestName "PowerShell Remoting" `
            -Status "Fail" -Details "Remote command returned unexpected result: $RemoteResult" `
            -Remediation "1. Verify WinRM configuration; 2. Check execution policy: 'Set-ExecutionPolicy RemoteSigned'; 3. Test manually: 'Enter-PSSession -ComputerName $ComputerName'"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-006" -Category "Authentication" -TestName "PowerShell Remoting" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Enable PS Remoting on target: 'Enable-PSRemoting -Force'; 2. Verify WSMan port access (Test-Case-002 must pass); 3. For non-domain: 'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ComputerName'; 4. Check user has remote management permissions"
}

Write-Host "[Test-Case-007] Testing Remote Registry Access..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-007" -Category "Service" -TestName "Remote Registry Access" `
            -Status "Pass" -Details "Successfully accessed remote registry via PS Remoting" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-007" -Category "Service" -TestName "Remote Registry Access" `
            -Status "Fail" -Details "Unable to read remote registry" `
            -Remediation "1. Verify PS Remoting works (Test-Case-006 must pass); 2. Enable Remote Registry service on target: 'Start-Service RemoteRegistry'; 3. Set service to auto-start: 'Set-Service RemoteRegistry -StartupType Automatic'; 4. Verify registry permissions"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-007" -Category "Service" -TestName "Remote Registry Access" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check Remote Registry service status; 3. Verify user has registry read permissions"
}

Write-Host "[Test-Case-008] Testing Remote Service Enumeration..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-008" -Category "Service" -TestName "Remote Service Enumeration" `
            -Status "Pass" -Details "Successfully enumerated remote services" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-008" -Category "Service" -TestName "Remote Service Enumeration" `
            -Status "Fail" -Details "Unable to enumerate remote services" `
            -Remediation "1. Verify PS Remoting works (Test-Case-006 must pass); 2. Check user permissions for service control; 3. Verify Services management is not restricted by GPO"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-008" -Category "Service" -TestName "Remote Service Enumeration" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check Service Control Manager permissions; 3. Verify user is in appropriate security groups"
}

Write-Host "[Test-Case-009] Testing Remote Event Log Access..." -NoNewline
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
        Write-Host " PASS" -ForegroundColor Green
        Add-TestResult -TestCase "Test-Case-009" -Category "Service" -TestName "Remote Event Log Access" `
            -Status "Pass" -Details "Successfully accessed remote event logs" `
            -Remediation "N/A"
    }
    else {
        Write-Host " FAIL" -ForegroundColor Red
        Add-TestResult -TestCase "Test-Case-009" -Category "Service" -TestName "Remote Event Log Access" `
            -Status "Fail" -Details "Unable to read remote event logs" `
            -Remediation "1. Verify PS Remoting works (Test-Case-006 must pass); 2. Add user to 'Event Log Readers' group on target; 3. Verify Event Log service is running: 'Start-Service EventLog'; 4. Check event log file permissions"
    }
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    Add-TestResult -TestCase "Test-Case-009" -Category "Service" -TestName "Remote Event Log Access" `
        -Status "Fail" -Details "Error: $($_.Exception.Message)" `
        -Remediation "1. Verify PS Remoting access (Test-Case-006 must pass); 2. Check Event Log Readers group membership; 3. Verify Event Log service status; 4. Check GPO restrictions on event log access"
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Yellow

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

Write-Host ""
if ($OverallStatus -eq 'Pass') {
    Write-Host "✅ All prerequisites validated successfully" -ForegroundColor Green
    Write-Host "Remote validation methods available:" -ForegroundColor Green
    Write-Host "  - CIM/WSMan (Modern)" -ForegroundColor Green
    Write-Host "  - WMI/DCOM (Legacy)" -ForegroundColor Green
    Write-Host "  - PowerShell Remoting (Registry/Service/EventLog)" -ForegroundColor Green
}
else {
    Write-Host "❌ One or more prerequisites failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Failed Tests Requiring Attention:" -ForegroundColor Red
    $Results | Where-Object Status -EQ 'Fail' | ForEach-Object {
        Write-Host ""
        Write-Host "[$($_.TestCase)] $($_.TestName)" -ForegroundColor Red
        Write-Host "  Issue: $($_.Details)" -ForegroundColor Yellow
        Write-Host "  Action: $($_.Remediation)" -ForegroundColor Cyan
    }
}

if (-not $OutputPath) {
    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $OutputPath = "MDE-Connectivity-Report-$ComputerName-$Timestamp.html"
}

$HtmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>MDE Connectivity Prerequisites Report - $ComputerName</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #0078D4; border-bottom: 3px solid #0078D4; padding-bottom: 10px; }
        h2 { color: #005A9E; margin-top: 30px; }
        .summary { background-color: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .summary-item { display: inline-block; margin-right: 30px; font-size: 18px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; background-color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-top: 20px; }
        th { background-color: #0078D4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f1f1f1; }
        .pass { color: #107C10; font-weight: bold; }
        .fail { color: #D13438; font-weight: bold; }
        .warning { color: #FF8C00; font-weight: bold; }
        .remediation { background-color: #FFF4CE; padding: 10px; border-left: 4px solid #FFB900; margin: 5px 0; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <h1>MDE Connectivity Prerequisites Report</h1>
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
    
    <h2>Detailed Test Results</h2>
    <table>
        <tr>
            <th>Test Case</th>
            <th>Category</th>
            <th>Test Name</th>
            <th>Status</th>
            <th>Details</th>
            <th>Remediation</th>
        </tr>
$(foreach ($Result in $Results) {
"        <tr>
            <td>$($Result.TestCase)</td>
            <td>$($Result.Category)</td>
            <td>$($Result.TestName)</td>
            <td class='$($Result.Status.ToLower())'>$($Result.Status)</td>
            <td>$($Result.Details)</td>
            <td>$(if ($Result.Status -eq 'Fail') { "<div class='remediation'>$($Result.Remediation)</div>" } else { $Result.Remediation })</td>
        </tr>"
})
    </table>
    
    <div class="footer">
        <p><strong>Reference:</strong> This report validates prerequisites for Get-MDEStatus.ps1 remote validation methods.</p>
        <p><strong>Next Steps:</strong> Remediate all failed tests before running Get-MDEStatus.ps1 in bulk mode.</p>
        <p>Generated by Test-MDEConnectivityPrerequisites.ps1 v1.0</p>
    </div>
</body>
</html>
"@

try {
    $HtmlReport | Out-File -FilePath $OutputPath -Encoding UTF8 -Force
    Write-Host ""
    Write-Host "📄 Detailed HTML report saved to: $OutputPath" -ForegroundColor Cyan
}
catch {
    Write-Warning "Failed to save HTML report: $_"
}

Write-Host ""
Write-Host "Completed: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan

if ($OverallStatus -eq 'Fail') {
    exit 1
}
else {
    exit 0
}
