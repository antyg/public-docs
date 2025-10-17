<#
.SYNOPSIS
    Validates MDE service health across multiple devices from CSV.

.DESCRIPTION
    Performs service-level health checks for Microsoft Defender for Endpoint
    across devices listed in CSV file. Checks SENSE and DiagTrack service status,
    startup configuration, and basic connectivity.

.PARAMETER CsvPath
    Path to CSV file containing device hostnames. Must have 'Hostname' column.

.PARAMETER OutputPath
    Path for output CSV report. Defaults to current directory with timestamp.

.PARAMETER Credential
    PSCredential for remote access. If not provided, uses current context.

.EXAMPLE
    .\Get-MDEServiceStatus.ps1 -CsvPath "C:\devices.csv"

.EXAMPLE
    $Cred = Get-Credential
    .\Get-MDEServiceStatus.ps1 -CsvPath "devices.csv" -Credential $Cred -OutputPath "C:\service-report.csv"

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+, Network access to target devices

.REFERENCES
    Microsoft Defender for Endpoint Troubleshooting
    https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    
    PowerShell Get-Service Cmdlet Documentation
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
    
    PowerShell Test-Connection Cmdlet Documentation
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
    
    PowerShell Invoke-Command Cmdlet Documentation
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
    
    PowerShell Get-Process Cmdlet Documentation
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process
    
    Microsoft Defender Antivirus Security Intelligence Updates
    https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

try {
    # Import device list from CSV file
    # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv
    $Devices = Import-Csv -Path $CsvPath

    if (-not ($Devices | Get-Member -Name 'Hostname' -MemberType NoteProperty)) {
        throw "CSV file must contain 'Hostname' column"
    }

    Write-Host "Loaded $($Devices.Count) devices from CSV" -ForegroundColor Cyan

    if (-not $OutputPath) {
        $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $OutputPath = "MDE-Service-Status-$Timestamp.csv"
    }

    $Results = @()

    foreach ($Device in $Devices) {
        Write-Host "Checking $($Device.Hostname)..." -NoNewline

        $Result = [PSCustomObject]@{
            Hostname                  = $Device.Hostname
            Reachable                 = $false
            SENSEServiceExists        = $false
            SENSEServiceStatus        = $null
            SENSEServiceStartType     = $null
            SENSEProcessID            = $null
            DiagTrackServiceExists    = $false
            DiagTrackServiceStatus    = $null
            DiagTrackServiceStartType = $null
            DiagTrackProcessID        = $null
            HealthStatus              = 'Unknown'
            ErrorMessage              = ''
            Timestamp                 = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }

        try {
            # Test network connectivity to remote device using ICMP ping
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
            $Result.Reachable = Test-Connection -ComputerName $Device.Hostname -Count 1 -Quiet -ErrorAction SilentlyContinue

            if (-not $Result.Reachable) {
                $Result.ErrorMessage = 'Device not reachable'
                $Result.HealthStatus = 'Offline'
                Write-Host ' Offline' -ForegroundColor Red
                $Results += $Result
                continue
            }

            $ScriptBlock = {
                # Get SENSE service - the behavioral sensor for Microsoft Defender for Endpoint
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
                # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
                $SENSEService = Get-Service -Name SENSE -ErrorAction SilentlyContinue
                
                # Get DiagTrack service - Windows diagnostic data service (no longer required dependency in Windows 10 1809+)
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
                # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
                $DiagTrackService = Get-Service -Name DiagTrack -ErrorAction SilentlyContinue

                # Get MsSense.exe process - the Microsoft Defender for Endpoint EDR sensor process
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates
                # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process
                $SENSEProcess = if ($SENSEService -and $SENSEService.Status -eq 'Running') {
                    Get-Process -Name MsSense -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id
                }
                else { $null }

                # Get DiagTrack.exe process
                # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process
                $DiagTrackProcess = if ($DiagTrackService -and $DiagTrackService.Status -eq 'Running') {
                    Get-Process -Name DiagTrack -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id
                }
                else { $null }

                [PSCustomObject]@{
                    SENSEExists        = ($null -ne $SENSEService)
                    SENSEStatus        = if ($SENSEService) { $SENSEService.Status } else { $null }
                    SENSEStartType     = if ($SENSEService) { $SENSEService.StartType } else { $null }
                    SENSEProcessID     = $SENSEProcess
                    DiagTrackExists    = ($null -ne $DiagTrackService)
                    DiagTrackStatus    = if ($DiagTrackService) { $DiagTrackService.Status } else { $null }
                    DiagTrackStartType = if ($DiagTrackService) { $DiagTrackService.StartType } else { $null }
                    DiagTrackProcessID = $DiagTrackProcess
                }
            }

            # Execute remote PowerShell command to gather service information
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            $InvokeParams = @{
                ComputerName = $Device.Hostname
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'Stop'
            }

            if ($Credential) {
                $InvokeParams.Credential = $Credential
            }

            $ServiceData = Invoke-Command @InvokeParams

            $Result.SENSEServiceExists = $ServiceData.SENSEExists
            $Result.SENSEServiceStatus = $ServiceData.SENSEStatus
            $Result.SENSEServiceStartType = $ServiceData.SENSEStartType
            $Result.SENSEProcessID = $ServiceData.SENSEProcessID

            $Result.DiagTrackServiceExists = $ServiceData.DiagTrackExists
            $Result.DiagTrackServiceStatus = $ServiceData.DiagTrackStatus
            $Result.DiagTrackServiceStartType = $ServiceData.DiagTrackStartType
            $Result.DiagTrackProcessID = $ServiceData.DiagTrackProcessID

            if (-not $Result.SENSEServiceExists) {
                $Result.HealthStatus = 'NotInstalled'
                Write-Host ' Not Installed' -ForegroundColor Red
            }
            elseif ($Result.SENSEServiceStatus -eq 'Running' -and
                $Result.SENSEServiceStartType -eq 'Automatic' -and
                $Result.DiagTrackServiceStatus -eq 'Running') {
                $Result.HealthStatus = 'Healthy'
                Write-Host ' Healthy' -ForegroundColor Green
            }
            elseif ($Result.SENSEServiceStatus -ne 'Running') {
                $Result.HealthStatus = 'SENSEStopped'
                Write-Host ' SENSE Stopped' -ForegroundColor Red
            }
            elseif ($Result.SENSEServiceStartType -ne 'Automatic') {
                $Result.HealthStatus = 'SENSEManual'
                Write-Host ' SENSE not Automatic' -ForegroundColor Yellow
            }
            elseif ($Result.DiagTrackServiceStatus -ne 'Running') {
                $Result.HealthStatus = 'DiagTrackStopped'
                Write-Host ' DiagTrack Stopped' -ForegroundColor Yellow
            }
            else {
                $Result.HealthStatus = 'Degraded'
                Write-Host ' Degraded' -ForegroundColor Yellow
            }
        }
        catch {
            $Result.ErrorMessage = $_.Exception.Message
            $Result.HealthStatus = 'Error'
            Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
        }

        $Results += $Result
    }

    # Export results to CSV file
    # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
    $Results | Export-Csv -Path $OutputPath -NoTypeInformation

    Write-Host "`nService health check complete!" -ForegroundColor Green
    Write-Host "Results exported to: $OutputPath" -ForegroundColor Cyan

    $Summary = $Results | Group-Object -Property HealthStatus | Select-Object Name, Count
    Write-Host "`n=== Summary ===" -ForegroundColor Yellow
    $Summary | Format-Table -AutoSize

    $HealthyCount = ($Results | Where-Object HealthStatus -EQ 'Healthy').Count
    $TotalCount = ($Results | Where-Object Reachable -EQ $true).Count

    if ($TotalCount -gt 0) {
        $HealthyPercent = [math]::Round(($HealthyCount / $TotalCount) * 100, 2)
        Write-Host "Healthy Services: $HealthyCount / $TotalCount reachable devices ($HealthyPercent%)" -ForegroundColor $(
            if ($HealthyPercent -ge 90) { 'Green' } elseif ($HealthyPercent -ge 75) { 'Yellow' } else { 'Red' }
        )
    }

    $IssueDevices = $Results | Where-Object { $_.HealthStatus -notin @('Healthy', 'Offline') }
    if ($IssueDevices.Count -gt 0) {
        Write-Host "`n=== Devices Requiring Attention ===" -ForegroundColor Red
        $IssueDevices | Select-Object Hostname, HealthStatus, SENSEServiceStatus, DiagTrackServiceStatus | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
