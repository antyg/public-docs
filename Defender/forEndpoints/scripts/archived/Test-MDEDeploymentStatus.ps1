<#
.SYNOPSIS
    Validates MDE deployment status for devices from CSV input.

.DESCRIPTION
    Tests Microsoft Defender for Endpoint deployment status across multiple devices
    using PowerShell remoting. Checks MDE installation, onboarding state, service
    health, and signature status. Outputs detailed CSV report.

.PARAMETER CsvPath
    Path to CSV file containing device hostnames. Must have 'Hostname' column.

.PARAMETER OutputPath
    Path for output CSV report. Defaults to current directory with timestamp.

.PARAMETER ThrottleLimit
    Maximum number of parallel remote sessions. Default: 10

.PARAMETER Credential
    PSCredential object for remote authentication. If not provided, uses current context.

.EXAMPLE
    .\Test-MDEDeploymentStatus.ps1 -CsvPath "C:\devices.csv" -OutputPath "C:\mde-report.csv"

.EXAMPLE
    $Cred = Get-Credential
    .\Test-MDEDeploymentStatus.ps1 -CsvPath "devices.csv" -Credential $Cred -ThrottleLimit 20

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+, WinRM enabled on target devices

.REFERENCES
    Microsoft Defender for Endpoint Onboarding Troubleshooting
    https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    
    Get-MpComputerStatus PowerShell Cmdlet
    https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus
    
    Invoke-Command PowerShell Remoting
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
    
    Test-Connection Network Connectivity
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
    
    Windows Diagnostic Data Configuration
    https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
    
    PowerShell Remoting Setup and Configuration
    https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/08-powershell-remoting
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 50)]
    [int]$ThrottleLimit = 10,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

try {
    $Devices = Import-Csv -Path $CsvPath

    if (-not ($Devices | Get-Member -Name 'Hostname' -MemberType NoteProperty)) {
        throw "CSV file must contain 'Hostname' column"
    }

    Write-Host "Loaded $($Devices.Count) devices from CSV" -ForegroundColor Cyan

    if (-not $OutputPath) {
        $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $OutputPath = "MDE-Validation-Report-$Timestamp.csv"
    }

    $ScriptBlock = {
        param($DeviceHostname)

        $Result = [PSCustomObject]@{
            Hostname                   = $DeviceHostname
            Reachable                  = $false
            MDEInstalled               = $false
            Onboarded                  = $false
            OnboardingState            = $null
            OrgId                      = $null
            SENSEServiceStatus         = $null
            SENSEServiceStartup        = $null
            DiagTrackServiceStatus     = $null
            AMRunningMode              = $null
            RealTimeProtectionEnabled  = $null
            BehaviorMonitorEnabled     = $null
            IsTamperProtected          = $null
            TamperProtectionSource     = $null
            SignatureVersion           = $null
            SignatureLastUpdated       = $null
            SignatureAgeHours          = $null
            ComputerState              = $null
            HealthStatus               = 'Unknown'
            ErrorMessage               = ''
            Timestamp                  = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }

        try {
            # Test network connectivity to device
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
            $Result.Reachable = Test-Connection -ComputerName $DeviceHostname -Count 1 -Quiet

            if (-not $Result.Reachable) {
                $Result.ErrorMessage = 'Device not reachable'
                $Result.HealthStatus = 'Offline'
                return $Result
            }

            # Check MDE onboarding status from registry
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            $RegStatus = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -ErrorAction SilentlyContinue

            if ($RegStatus) {
                $Result.MDEInstalled = $true
                $Result.OnboardingState = $RegStatus.OnboardingState
                $Result.Onboarded = ($RegStatus.OnboardingState -eq 1)
                $Result.OrgId = $RegStatus.OrgId
            }

            # Check SENSE service (MDE behavioral sensor)
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            $SENSEService = Get-Service -Name SENSE -ErrorAction SilentlyContinue
            if ($SENSEService) {
                $Result.SENSEServiceStatus = $SENSEService.Status
                $Result.SENSEServiceStartup = $SENSEService.StartType
            }

            # Check DiagTrack service (Connected User Experiences and Telemetry)
            # Reference: https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
            $DiagTrackService = Get-Service -Name DiagTrack -ErrorAction SilentlyContinue
            if ($DiagTrackService) {
                $Result.DiagTrackServiceStatus = $DiagTrackService.Status
            }

            # Get Microsoft Defender Antivirus status and configuration
            # Reference: https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus
            $MpStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
            if ($MpStatus) {
                $Result.AMRunningMode = $MpStatus.AMRunningMode
                $Result.RealTimeProtectionEnabled = $MpStatus.RealTimeProtectionEnabled
                $Result.BehaviorMonitorEnabled = $MpStatus.BehaviorMonitorEnabled
                $Result.IsTamperProtected = $MpStatus.IsTamperProtected
                $Result.TamperProtectionSource = $MpStatus.TamperProtectionSource
                $Result.SignatureVersion = $MpStatus.AntivirusSignatureVersion
                $Result.SignatureLastUpdated = $MpStatus.AntivirusSignatureLastUpdated
                $Result.ComputerState = $MpStatus.ComputerState

                if ($MpStatus.AntivirusSignatureLastUpdated) {
                    $Result.SignatureAgeHours = [math]::Round(((Get-Date) - $MpStatus.AntivirusSignatureLastUpdated).TotalHours, 2)
                }
            }

            if ($Result.Onboarded -and
                $Result.SENSEServiceStatus -eq 'Running' -and
                $Result.AMRunningMode -eq 'Normal' -and
                $Result.RealTimeProtectionEnabled -eq $true -and
                $Result.SignatureAgeHours -lt 48) {
                $Result.HealthStatus = 'Healthy'
            }
            elseif ($Result.MDEInstalled -and -not $Result.Onboarded) {
                $Result.HealthStatus = 'NotOnboarded'
            }
            elseif ($Result.Onboarded -and $Result.SENSEServiceStatus -ne 'Running') {
                $Result.HealthStatus = 'ServiceIssue'
            }
            elseif ($Result.Onboarded -and $Result.AMRunningMode -ne 'Normal') {
                $Result.HealthStatus = 'ConfigurationIssue'
            }
            elseif ($Result.Onboarded -and $Result.SignatureAgeHours -ge 48) {
                $Result.HealthStatus = 'OutdatedSignatures'
            }
            elseif (-not $Result.MDEInstalled) {
                $Result.HealthStatus = 'NotInstalled'
            }
            else {
                $Result.HealthStatus = 'Degraded'
            }
        }
        catch {
            $Result.ErrorMessage = $_.Exception.Message
            $Result.HealthStatus = 'Error'
        }

        return $Result
    }

    Write-Host "Starting validation with $ThrottleLimit parallel sessions..." -ForegroundColor Cyan

    $InvokeParams = @{
        ScriptBlock   = $ScriptBlock
        ArgumentList  = @{Hostname = $null }
        ThrottleLimit = $ThrottleLimit
    }

    if ($Credential) {
        $InvokeParams.Credential = $Credential
    }

    $Results = $Devices | ForEach-Object -Parallel {
        $Device = $_
        $SB = $using:ScriptBlock
        $Cred = $using:Credential

        try {
            # Execute remote PowerShell commands on target device
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            if ($Cred) {
                $SessionParams = @{
                    ComputerName = $Device.Hostname
                    Credential   = $Cred
                    ErrorAction  = 'Stop'
                }
            }
            else {
                $SessionParams = @{
                    ComputerName = $Device.Hostname
                    ErrorAction  = 'Stop'
                }
            }

            Invoke-Command @SessionParams -ScriptBlock $SB -ArgumentList $Device.Hostname
        }
        catch {
            [PSCustomObject]@{
                Hostname                   = $Device.Hostname
                Reachable                  = $false
                MDEInstalled               = $false
                Onboarded                  = $false
                OnboardingState            = $null
                OrgId                      = $null
                SENSEServiceStatus         = $null
                SENSEServiceStartup        = $null
                DiagTrackServiceStatus     = $null
                AMRunningMode              = $null
                RealTimeProtectionEnabled  = $null
                BehaviorMonitorEnabled     = $null
                IsTamperProtected          = $null
                TamperProtectionSource     = $null
                SignatureVersion           = $null
                SignatureLastUpdated       = $null
                SignatureAgeHours          = $null
                ComputerState              = $null
                HealthStatus               = 'ConnectionError'
                ErrorMessage               = $_.Exception.Message
                Timestamp                  = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            }
        }
    } -ThrottleLimit $ThrottleLimit

    $Results | Export-Csv -Path $OutputPath -NoTypeInformation

    Write-Host "`nValidation Complete!" -ForegroundColor Green
    Write-Host "Results exported to: $OutputPath" -ForegroundColor Cyan

    $Summary = $Results | Group-Object -Property HealthStatus | Select-Object Name, Count
    Write-Host "`n=== Summary ===" -ForegroundColor Yellow
    $Summary | Format-Table -AutoSize

    $HealthyCount = ($Results | Where-Object HealthStatus -EQ 'Healthy').Count
    $TotalCount = $Results.Count
    $HealthyPercent = [math]::Round(($HealthyCount / $TotalCount) * 100, 2)

    Write-Host "Healthy Devices: $HealthyCount / $TotalCount ($HealthyPercent%)" -ForegroundColor $(if ($HealthyPercent -ge 90) { 'Green' } elseif ($HealthyPercent -ge 75) { 'Yellow' } else { 'Red' })
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
