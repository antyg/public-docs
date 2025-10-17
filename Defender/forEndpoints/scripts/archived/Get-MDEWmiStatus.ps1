<#
.SYNOPSIS
    Validates Microsoft Defender status using legacy WMI cmdlets for compatibility with older systems.

.DESCRIPTION
    Performs comprehensive Defender validation using Get-WmiObject cmdlet for legacy system support.
    Queries the root/Microsoft/Windows/Defender WMI namespace to retrieve Defender status,
    antivirus configuration, and signature information. Supports both single device and CSV bulk validation.

    This script is specifically designed for Windows 7, Server 2008 R2 with ESU, and environments
    where CIM cmdlets are not available or DCOM is preferred over WSMan.

.PARAMETER ComputerName
    Target computer name. Defaults to local computer. For remote queries, DCOM must be allowed through firewall.

.PARAMETER CsvPath
    Path to CSV file containing device hostnames. Must have 'Hostname' column.

.PARAMETER OutputPath
    Path for output CSV report. Defaults to current directory with timestamp.

.PARAMETER Credential
    PSCredential for remote WMI access. If not provided, uses current context.

.EXAMPLE
    .\Get-DefenderStatusWMI.ps1

.EXAMPLE
    .\Get-DefenderStatusWMI.ps1 -ComputerName "WORKSTATION01"

.EXAMPLE
    $Cred = Get-Credential
    .\Get-DefenderStatusWMI.ps1 -CsvPath "C:\devices.csv" -Credential $Cred -OutputPath "C:\defender-wmi-report.csv"

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 3.0+, WMI access (DCOM protocol)

.REFERENCES
    Working with WMI - PowerShell
    https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi

    MSFT_MpComputerStatus class
    https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus

    Get-WmiObject cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject

    Microsoft Defender Antivirus compatibility
    https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility
#>

[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(Mandatory = $false, ParameterSetName = 'Single')]
    [string]$ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory = $true, ParameterSetName = 'Bulk')]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [Parameter(Mandatory = $false, ParameterSetName = 'Bulk')]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

function Get-MDEWmiStatus {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    $Result = [PSCustomObject]@{
        Hostname                      = $Computer
        Reachable                     = $false
        DefenderInstalled             = $false
        AMRunningMode                 = $null
        AMServiceEnabled              = $null
        AntivirusEnabled              = $null
        RealTimeProtectionEnabled     = $null
        BehaviorMonitorEnabled        = $null
        IoavProtectionEnabled         = $null
        OnAccessProtectionEnabled     = $null
        IsTamperProtected             = $null
        TamperProtectionSource        = $null
        AntivirusSignatureVersion     = $null
        AntivirusSignatureLastUpdated = $null
        SignatureAgeHours             = $null
        ComputerState                 = $null
        HealthStatus                  = 'Unknown'
        ErrorMessage                  = ''
        Timestamp                     = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }

    try {
        $Result.Reachable = Test-Connection -ComputerName $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue

        if (-not $Result.Reachable) {
            $Result.ErrorMessage = 'Device not reachable'
            $Result.HealthStatus = 'Offline'
            return $Result
        }

        $WmiParams = @{
            ComputerName = $Computer
            Namespace    = 'root/Microsoft/Windows/Defender'
            Class        = 'MSFT_MpComputerStatus'
            ErrorAction  = 'Stop'
        }

        if ($Cred) {
            $WmiParams.Credential = $Cred
        }

        $Status = Get-WmiObject @WmiParams

        if ($Status) {
            $Result.DefenderInstalled = $true
            $Result.AMRunningMode = $Status.AMRunningMode
            $Result.AMServiceEnabled = $Status.AMServiceEnabled
            $Result.AntivirusEnabled = $Status.AntivirusEnabled
            $Result.RealTimeProtectionEnabled = $Status.RealTimeProtectionEnabled
            $Result.BehaviorMonitorEnabled = $Status.BehaviorMonitorEnabled
            $Result.IoavProtectionEnabled = $Status.IoavProtectionEnabled
            $Result.OnAccessProtectionEnabled = $Status.OnAccessProtectionEnabled
            $Result.IsTamperProtected = $Status.IsTamperProtected
            $Result.TamperProtectionSource = $Status.TamperProtectionSource
            $Result.AntivirusSignatureVersion = $Status.AntivirusSignatureVersion
            $Result.AntivirusSignatureLastUpdated = $Status.AntivirusSignatureLastUpdated
            $Result.ComputerState = $Status.ComputerState

            if ($Status.AntivirusSignatureLastUpdated) {
                $Result.SignatureAgeHours = [math]::Round(((Get-Date) - $Status.AntivirusSignatureLastUpdated).TotalHours, 2)
            }

            if ($Result.AMRunningMode -eq 'Normal' -and
                $Result.RealTimeProtectionEnabled -eq $true -and
                $Result.BehaviorMonitorEnabled -eq $true -and
                $Result.SignatureAgeHours -lt 48) {
                $Result.HealthStatus = 'Healthy'
            }
            elseif ($Result.AMRunningMode -eq 'Passive') {
                $Result.HealthStatus = 'Passive'
            }
            elseif ($Result.RealTimeProtectionEnabled -eq $false) {
                $Result.HealthStatus = 'RealTimeProtectionDisabled'
            }
            elseif ($Result.SignatureAgeHours -ge 48) {
                $Result.HealthStatus = 'OutdatedSignatures'
            }
            else {
                $Result.HealthStatus = 'Degraded'
            }
        }
        else {
            $Result.ErrorMessage = 'WMI namespace not found or Defender not installed'
            $Result.HealthStatus = 'NotInstalled'
        }
    }
    catch {
        $Result.ErrorMessage = $_.Exception.Message
        $Result.HealthStatus = 'Error'
    }

    return $Result
}

try {
    if ($PSCmdlet.ParameterSetName -eq 'Single') {
        Write-Host "Querying Defender status via WMI on: $ComputerName" -ForegroundColor Cyan
        $Result = Get-MDEWmiStatus -Computer $ComputerName -Cred $Credential

        Write-Host "`n=== Defender Status (WMI) ===" -ForegroundColor Yellow
        $Result | Format-List Hostname, HealthStatus, AMRunningMode, AMServiceEnabled,
        RealTimeProtectionEnabled, BehaviorMonitorEnabled,
        IsTamperProtected, TamperProtectionSource,
        AntivirusSignatureVersion, SignatureAgeHours, ComputerState, ErrorMessage

        if ($Result.HealthStatus -eq 'Healthy') {
            Write-Host "`n✅ Defender is healthy and functional" -ForegroundColor Green
        }
        elseif ($Result.HealthStatus -in @('Passive', 'RealTimeProtectionDisabled', 'OutdatedSignatures', 'Degraded')) {
            Write-Host "`n⚠️ Defender has configuration issues: $($Result.HealthStatus)" -ForegroundColor Yellow
        }
        else {
            Write-Host "`n❌ Defender is not functional: $($Result.HealthStatus)" -ForegroundColor Red
        }
    }
    else {
        $Devices = Import-Csv -Path $CsvPath

        if (-not ($Devices | Get-Member -Name 'Hostname' -MemberType NoteProperty)) {
            throw "CSV file must contain 'Hostname' column"
        }

        Write-Host "Loaded $($Devices.Count) devices from CSV" -ForegroundColor Cyan

        if (-not $OutputPath) {
            $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $OutputPath = "Defender-WMI-Status-$Timestamp.csv"
        }

        $Results = @()

        foreach ($Device in $Devices) {
            Write-Host "Checking $($Device.Hostname)..." -NoNewline
            $Result = Get-MDEWmiStatus -Computer $Device.Hostname -Cred $Credential

            switch ($Result.HealthStatus) {
                'Healthy' { Write-Host ' Healthy' -ForegroundColor Green }
                'Passive' { Write-Host ' Passive Mode' -ForegroundColor Yellow }
                'RealTimeProtectionDisabled' { Write-Host ' RTP Disabled' -ForegroundColor Yellow }
                'OutdatedSignatures' { Write-Host ' Outdated Signatures' -ForegroundColor Yellow }
                'Degraded' { Write-Host ' Degraded' -ForegroundColor Yellow }
                'NotInstalled' { Write-Host ' Not Installed' -ForegroundColor Red }
                'Offline' { Write-Host ' Offline' -ForegroundColor Red }
                'Error' { Write-Host " Error: $($Result.ErrorMessage)" -ForegroundColor Red }
                default { Write-Host ' Unknown' -ForegroundColor Gray }
            }

            $Results += $Result
        }

        $Results | Export-Csv -Path $OutputPath -NoTypeInformation

        Write-Host "`nValidation complete!" -ForegroundColor Green
        Write-Host "Results exported to: $OutputPath" -ForegroundColor Cyan

        $Summary = $Results | Group-Object -Property HealthStatus | Select-Object Name, Count
        Write-Host "`n=== Summary ===" -ForegroundColor Yellow
        $Summary | Format-Table -AutoSize

        $HealthyCount = ($Results | Where-Object HealthStatus -EQ 'Healthy').Count
        $TotalCount = ($Results | Where-Object Reachable -EQ $true).Count

        if ($TotalCount -gt 0) {
            $HealthyPercent = [math]::Round(($HealthyCount / $TotalCount) * 100, 2)
            Write-Host "Healthy Devices: $HealthyCount / $TotalCount reachable devices ($HealthyPercent%)" -ForegroundColor $(
                if ($HealthyPercent -ge 90) { 'Green' } elseif ($HealthyPercent -ge 75) { 'Yellow' } else { 'Red' }
            )
        }

        $IssueDevices = $Results | Where-Object { $_.HealthStatus -notin @('Healthy', 'Offline') }
        if ($IssueDevices.Count -gt 0) {
            Write-Host "`n=== Devices Requiring Attention ===" -ForegroundColor Red
            $IssueDevices | Select-Object Hostname, HealthStatus, AMRunningMode, RealTimeProtectionEnabled, SignatureAgeHours | Format-Table -AutoSize
        }
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
