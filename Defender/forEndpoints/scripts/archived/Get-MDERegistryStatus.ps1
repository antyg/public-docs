<#
.SYNOPSIS
    Validates MDE deployment via registry keys and service status.

.DESCRIPTION
    Performs comprehensive registry-based validation of Microsoft Defender for Endpoint
    installation and onboarding status. Checks registry keys, service configuration,
    and optionally event log errors.

.PARAMETER ComputerName
    Target computer name. Defaults to local computer.

.PARAMETER CheckEventLog
    Switch to include recent SENSE event log error analysis.

.PARAMETER Credential
    PSCredential for remote access. If not provided, uses current context.

.EXAMPLE
    .\Get-MDERegistryStatus.ps1

.EXAMPLE
    .\Get-MDERegistryStatus.ps1 -ComputerName "WORKSTATION01" -CheckEventLog

.EXAMPLE
    $Cred = Get-Credential
    .\Get-MDERegistryStatus.ps1 -ComputerName "SERVER01" -Credential $Cred -CheckEventLog

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+, Administrator privileges

.REFERENCES
    Microsoft Defender for Endpoint Troubleshooting
    https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding

    PowerShell Get-ItemProperty Cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty

    PowerShell Get-Service Cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service

    PowerShell Get-WinEvent with FilterHashtable
    https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable

    PowerShell Invoke-Command for Remote Execution
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command

    Event Logs for Microsoft Defender for Endpoint
    https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes

    Windows Diagnostic Data Configuration (DiagTrack)
    https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory = $false)]
    [switch]$CheckEventLog,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

function Get-RemoteRegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Computer,
        [PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            param($RegPath, $ValueName)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty
            Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty $ValueName
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            & $ScriptBlock -RegPath $Path -ValueName $Name
        }
        else {
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ArgumentList = @($Path, $Name)
                ErrorAction  = 'SilentlyContinue'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            Invoke-Command @InvokeParams
        }
    }
    catch {
        return $null
    }
}

function Get-RemoteService {
    param(
        [string]$ServiceName,
        [string]$Computer,
        [PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            param($Name)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
            Get-Service -Name $Name -ErrorAction SilentlyContinue
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            & $ScriptBlock -Name $ServiceName
        }
        else {
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ArgumentList = @($ServiceName)
                ErrorAction  = 'SilentlyContinue'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            Invoke-Command @InvokeParams
        }
    }
    catch {
        return $null
    }
}

try {
    Write-Host "Validating MDE on: $ComputerName" -ForegroundColor Cyan

    $Result = [PSCustomObject]@{
        ComputerName              = $ComputerName
        MDEInstalled              = $false
        OnboardingState           = $null
        OnboardingStateValue      = $null
        OrgId                     = $null
        SenseId                   = $null
        OnboardingBlobConfigured  = $false
        OnboardingBlobLength      = $null
        SENSEServiceExists        = $false
        SENSEServiceStatus        = $null
        SENSEServiceStartType     = $null
        DiagTrackServiceExists    = $false
        DiagTrackServiceStatus    = $null
        DiagTrackServiceStartType = $null
        RecentSENSEErrors         = $null
        LastSENSEError            = $null
        ValidationResult          = 'Unknown'
        Issues                    = @()
        Timestamp                 = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }

    # Check MDE installation via registry InstallLocation key
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    $RegBasePath = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection'
    $MDEInstalled = Get-RemoteRegistryValue -Path $RegBasePath -Name 'InstallLocation' -Computer $ComputerName -Cred $Credential

    # Verify MDE installation by checking SENSE service or InstallLocation registry
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    if ($MDEInstalled -or (Get-RemoteService -ServiceName 'SENSE' -Computer $ComputerName -Cred $Credential)) {
        $Result.MDEInstalled = $true
    }

    if ($Result.MDEInstalled) {
        # Check MDE onboarding status via registry keys
        # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
        $StatusPath = "$RegBasePath\Status"
        $Result.OnboardingStateValue = Get-RemoteRegistryValue -Path $StatusPath -Name 'OnboardingState' -Computer $ComputerName -Cred $Credential
        $Result.OrgId = Get-RemoteRegistryValue -Path $StatusPath -Name 'OrgId' -Computer $ComputerName -Cred $Credential
        $Result.SenseId = Get-RemoteRegistryValue -Path $StatusPath -Name 'SenseId' -Computer $ComputerName -Cred $Credential

        # OnboardingState: 1 = Onboarded, 0 = Not Onboarded
        # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
        if ($Result.OnboardingStateValue -eq 1) {
            $Result.OnboardingState = 'Onboarded'
        }
        elseif ($Result.OnboardingStateValue -eq 0) {
            $Result.OnboardingState = 'NotOnboarded'
        }

        # Check for onboarding policy configuration
        # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
        $PolicyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection'
        $OnboardingBlob = Get-RemoteRegistryValue -Path $PolicyPath -Name 'OnboardingInfo' -Computer $ComputerName -Cred $Credential

        if ($OnboardingBlob) {
            $Result.OnboardingBlobConfigured = $true
            $Result.OnboardingBlobLength = $OnboardingBlob.Length
        }
    }

    # Check SENSE service status - internal name for MDE behavioral sensor
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    $SENSEService = Get-RemoteService -ServiceName 'SENSE' -Computer $ComputerName -Cred $Credential
    if ($SENSEService) {
        $Result.SENSEServiceExists = $true
        $Result.SENSEServiceStatus = $SENSEService.Status
        $Result.SENSEServiceStartType = $SENSEService.StartType
    }

    # Check DiagTrack service (Connected User Experiences and Telemetry)
    # Reference: https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
    $DiagTrackService = Get-RemoteService -ServiceName 'DiagTrack' -Computer $ComputerName -Cred $Credential
    if ($DiagTrackService) {
        $Result.DiagTrackServiceExists = $true
        $Result.DiagTrackServiceStatus = $DiagTrackService.Status
        $Result.DiagTrackServiceStartType = $DiagTrackService.StartType
    }

    if ($CheckEventLog) {
        $ScriptBlock = {
            try {
                # Query Microsoft-Windows-SENSE/Operational event log for recent errors
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes
                # Reference: https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable
                $ErrorEvents = Get-WinEvent -FilterHashtable @{
                    LogName   = 'Microsoft-Windows-SENSE/Operational'
                    Level     = 2, 3
                    StartTime = (Get-Date).AddDays(-7)
                } -MaxEvents 50 -ErrorAction SilentlyContinue

                $ErrorCount = if ($ErrorEvents) { $ErrorEvents.Count } else { 0 }
                $LastError = if ($ErrorEvents) {
                    $ErrorEvents[0] | Select-Object TimeCreated, Id, LevelDisplayName, Message
                }
                else {
                    $null
                }

                [PSCustomObject]@{
                    ErrorCount = $ErrorCount
                    LastError  = $LastError
                }
            }
            catch {
                [PSCustomObject]@{
                    ErrorCount = $null
                    LastError  = "Unable to read event log: $($_.Exception.Message)"
                }
            }
        }

        if ($ComputerName -eq $env:COMPUTERNAME) {
            $EventData = & $ScriptBlock
        }
        else {
            $InvokeParams = @{
                ComputerName = $ComputerName
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'SilentlyContinue'
            }

            if ($Credential) {
                $InvokeParams.Credential = $Credential
            }

            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            $EventData = Invoke-Command @InvokeParams
        }

        if ($EventData) {
            $Result.RecentSENSEErrors = $EventData.ErrorCount
            $Result.LastSENSEError = if ($EventData.LastError) {
                "$($EventData.LastError.TimeCreated) - Event $($EventData.LastError.Id): $($EventData.LastError.Message)"
            }
            else {
                'None'
            }
        }
    }

    # Determine overall validation result based on MDE deployment status
    if (-not $Result.MDEInstalled) {
        $Result.ValidationResult = 'NOT_INSTALLED'
        $Result.Issues += 'MDE not installed on this system'
    }
    elseif ($Result.OnboardingState -eq 'NotOnboarded') {
        $Result.ValidationResult = 'NOT_ONBOARDED'
        $Result.Issues += 'MDE installed but not onboarded'

        if (-not $Result.OnboardingBlobConfigured) {
            $Result.Issues += 'Onboarding policy not configured'
        }

        # DiagTrack service is required for MDE telemetry functionality
        # Reference: https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
        if ($Result.DiagTrackServiceStatus -ne 'Running') {
            $Result.Issues += 'DiagTrack service not running'
        }
    }
    elseif ($Result.OnboardingState -eq 'Onboarded') {
        # SENSE service must be running for MDE to function properly
        # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
        if ($Result.SENSEServiceStatus -ne 'Running') {
            $Result.ValidationResult = 'SERVICE_ISSUE'
            $Result.Issues += 'SENSE service not running'
        }
        elseif ($Result.SENSEServiceStartType -ne 'Automatic') {
            $Result.ValidationResult = 'CONFIGURATION_ISSUE'
            $Result.Issues += 'SENSE service not set to Automatic startup'
        }
        elseif ($Result.DiagTrackServiceStatus -ne 'Running') {
            $Result.ValidationResult = 'SERVICE_ISSUE'
            $Result.Issues += 'DiagTrack service not running'
        }
        elseif ($CheckEventLog -and $Result.RecentSENSEErrors -gt 10) {
            $Result.ValidationResult = 'EVENT_LOG_ERRORS'
            $Result.Issues += "$($Result.RecentSENSEErrors) errors in SENSE log (last 7 days)"
        }
        else {
            $Result.ValidationResult = 'HEALTHY'
        }
    }

    Write-Host "`n=== Validation Results ===" -ForegroundColor Yellow
    Write-Host "Computer Name: $($Result.ComputerName)"
    Write-Host "MDE Installed: $($Result.MDEInstalled)"
    Write-Host "Onboarding State: $($Result.OnboardingState) (Value: $($Result.OnboardingStateValue))"
    Write-Host "Organization ID: $($Result.OrgId)"
    Write-Host "Sense ID: $($Result.SenseId)"
    Write-Host "SENSE Service: $($Result.SENSEServiceStatus) ($($Result.SENSEServiceStartType))"
    Write-Host "DiagTrack Service: $($Result.DiagTrackServiceStatus) ($($Result.DiagTrackServiceStartType))"

    if ($CheckEventLog) {
        Write-Host "Recent SENSE Errors: $($Result.RecentSENSEErrors)"
        Write-Host "Last SENSE Error: $($Result.LastSENSEError)"
    }

    Write-Host "`nValidation Result: $($Result.ValidationResult)" -ForegroundColor $(
        switch ($Result.ValidationResult) {
            'HEALTHY' { 'Green' }
            'NOT_INSTALLED' { 'Red' }
            'NOT_ONBOARDED' { 'Yellow' }
            default { 'Red' }
        }
    )

    if ($Result.Issues.Count -gt 0) {
        Write-Host "`nIssues Detected:" -ForegroundColor Red
        $Result.Issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }

    return $Result
}
catch {
    Write-Error "Validation failed: $_"
    exit 1
}