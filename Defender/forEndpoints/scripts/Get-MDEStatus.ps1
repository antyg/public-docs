<#
.SYNOPSIS
    Intelligent multi-method MDE status validation with automatic fallback.

.DESCRIPTION
    Validates Microsoft Defender for Endpoint status using multiple methods with automatic
    fallback chain. Attempts validation in order of efficiency and reliability:

    1. CIM/WSMan (fastest, modern systems Windows 10/11, Server 2016+)
    2. WMI/DCOM (legacy compatibility Windows 7, Server 2008 R2)
    3. Registry (works when WMI/CIM unavailable)
    4. Service (minimal validation when registry locked down)

    Automatically detects best method per device and falls back gracefully on failure.
    Supports single device and CSV bulk validation with parallel execution.

    All validation results are automatically logged to Get-MDEStatus-Log.txt in the script
    directory with Australian date/time format for tracking and audit purposes.

.PARAMETER ComputerName
    Target computer name. Defaults to local computer.

.PARAMETER CsvPath
    Path to CSV file containing device hostnames. Must have 'Hostname' column.

.PARAMETER OutputPath
    Path for output CSV report. Defaults to current directory with timestamp.

.PARAMETER Credential
    PSCredential for remote access. If not provided, uses current context.

.PARAMETER ThrottleLimit
    Maximum number of parallel sessions when processing CSV (default: 10).

.PARAMETER PreferredMethod
    Force specific validation method: 'CIM', 'WMI', 'Registry', 'Service', or 'Auto' (default).

.EXAMPLE
    .\Get-MDEStatus.ps1

.EXAMPLE
    .\Get-MDEStatus.ps1 -ComputerName "WORKSTATION01"

.EXAMPLE
    $Cred = Get-Credential
    .\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -Credential $Cred -OutputPath "C:\mde-status.csv"

.EXAMPLE
    .\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -ThrottleLimit 20

.EXAMPLE
    .\Get-MDEStatus.ps1 -ComputerName "SERVER01" -PreferredMethod Registry

.NOTES
    Author: Security Operations Team
    Version: 2.5
    Requires: PowerShell 5.1+ (PowerShell 7.0+ recommended for parallel execution)
    Region: Australian localization (AU date format: dd/MM/yyyy HH:mm:ss)

    PowerShell Version Behavior:
    - PowerShell 7.0+: Parallel execution with configurable throttle limit (fast)
    - PowerShell 5.1: Sequential execution fallback (slower, but compatible)
    - Single device validation works on both versions

    Bug Fixes (v2.5):
    - Fixed OnboardingState collection when using CIM/WMI validation methods
    - MSFT_MpComputerStatus doesn't include MDE onboarding state - now supplements with registry query
    - Console output now correctly displays OnboardingState for all validation methods
    - Resolved undefined variable error in parallel execution block

    Features (v2.4):
    - Comprehensive key=value log format with all result fields for intelligent parsing
    - Console output now displays OnboardingState during bulk validation
    - Structured logging enables advanced filtering and analysis

    Features (v2.3):
    - PowerShell 5.1 compatibility with sequential processing fallback
    - Thread-safe logging using synchronized collections (PS7+) or sequential writes (PS5.1)
    - Automatic logging to Get-MDEStatus-Log.txt with AU date/time format

    Bug Fixes (v2.1):
    - Fixed DefenderInstalled detection when using CIM/WMI validation methods
    - Added service status queries to supplement CIM/WMI data (SENSE, DiagTrack)
    - CIM/WMI now correctly infers installation from MSFT_MpComputerStatus presence

.REFERENCES
    Troubleshoot Microsoft Defender for Endpoint onboarding issues
    https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding

    MSFT_MpComputerStatus class - Defender WMI/CIM Provider
    https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus

    Get-CimInstance cmdlet - PowerShell CIM Cmdlets
    https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance

    New-CimSession cmdlet - PowerShell CIM Cmdlets
    https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/new-cimsession

    Get-WmiObject cmdlet - PowerShell Management
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject

    Get-Service cmdlet - PowerShell Management
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service

    Get-ItemProperty cmdlet - Registry Access
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty

    Get-WinEvent cmdlet - Event Log Queries
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent

    Review events and errors using Event Viewer - MDE
    https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes

    Invoke-Command cmdlet - PowerShell Remoting
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command

    ForEach-Object -Parallel - PowerShell Parallel Processing
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object

    Import-Csv cmdlet - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv

    Export-Csv cmdlet - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
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
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory = $false, ParameterSetName = 'Bulk')]
    [ValidateRange(1, 50)]
    [int]$ThrottleLimit = 10,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Auto', 'CIM', 'WMI', 'Registry', 'Service')]
    [string]$PreferredMethod = 'Auto'
)

$ErrorActionPreference = 'Stop'

# Initialize log file in script directory
# Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/split-path
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptPath) { $ScriptPath = $PWD.Path }
$LogFile = Join-Path -Path $ScriptPath -ChildPath 'Get-MDEStatus-Log.txt'

function Write-MDELog {
    param(
        [PSCustomObject]$Result
    )

    try {
        # Create comprehensive log entry with key-value pairs for intelligent parsing
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-content
        $Timestamp = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
        
        # Build structured log entry with all fields
        $LogFields = [ordered]@{
            Timestamp                  = $Timestamp
            Hostname                   = $Result.Hostname
            Reachable                  = $Result.Reachable
            ValidationMethod           = $Result.ValidationMethod
            HealthStatus               = $Result.HealthStatus
            DefenderInstalled          = $Result.DefenderInstalled
            OnboardingState            = if ($Result.OnboardingState) { $Result.OnboardingState } else { 'Unknown' }
            OnboardingStateValue       = if ($null -ne $Result.OnboardingStateValue) { $Result.OnboardingStateValue } else { 'N/A' }
            AMRunningMode              = if ($Result.AMRunningMode) { $Result.AMRunningMode } else { 'N/A' }
            AMServiceEnabled           = if ($null -ne $Result.AMServiceEnabled) { $Result.AMServiceEnabled } else { 'N/A' }
            RealTimeProtectionEnabled  = if ($null -ne $Result.RealTimeProtectionEnabled) { $Result.RealTimeProtectionEnabled } else { 'N/A' }
            BehaviorMonitorEnabled     = if ($null -ne $Result.BehaviorMonitorEnabled) { $Result.BehaviorMonitorEnabled } else { 'N/A' }
            IsTamperProtected          = if ($null -ne $Result.IsTamperProtected) { $Result.IsTamperProtected } else { 'N/A' }
            TamperProtectionSource     = if ($Result.TamperProtectionSource) { $Result.TamperProtectionSource } else { 'N/A' }
            AntivirusSignatureVersion  = if ($Result.AntivirusSignatureVersion) { $Result.AntivirusSignatureVersion } else { 'N/A' }
            SignatureAgeHours          = if ($null -ne $Result.SignatureAgeHours) { $Result.SignatureAgeHours } else { 'N/A' }
            SENSEServiceStatus         = if ($Result.SENSEServiceStatus) { $Result.SENSEServiceStatus } else { 'N/A' }
            DiagTrackServiceStatus     = if ($Result.DiagTrackServiceStatus) { $Result.DiagTrackServiceStatus } else { 'N/A' }
            RecentSENSEErrors          = if ($null -ne $Result.RecentSENSEErrors) { $Result.RecentSENSEErrors } else { '0' }
            LastSENSEError             = if ($Result.LastSENSEError -and $Result.LastSENSEError -ne 'None') { $Result.LastSENSEError } else { 'None' }
            ErrorMessage               = if ($Result.ErrorMessage) { $Result.ErrorMessage } else { 'None' }
        }

        # Convert to structured key=value format for intelligent parsing
        $LogEntry = ($LogFields.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ' | '

        # Append to log file
        Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue
    }
    catch {
        # Silently continue if logging fails - don't break validation
        Write-Verbose "Failed to write to log file: $_"
    }
}

function Get-SENSEEventLog {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            try {
                # Query SENSE operational log for errors and warnings in last 7 days
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/event-error-codes
                # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent
                $ErrorEvents = Get-WinEvent -FilterHashtable @{
                    LogName   = 'Microsoft-Windows-SENSE/Operational'
                    Level     = 2, 3
                    StartTime = (Get-Date).AddDays(-7)
                } -MaxEvents 50 -ErrorAction SilentlyContinue

                $ErrorCount = if ($ErrorEvents) { $ErrorEvents.Count } else { 0 }
                $LastError = if ($ErrorEvents) {
                    $Latest = $ErrorEvents[0]
                    "$($Latest.TimeCreated) - Event $($Latest.Id): $($Latest.Message)"
                }
                else {
                    'None'
                }

                [PSCustomObject]@{
                    ErrorCount = $ErrorCount
                    LastError  = $LastError
                }
            }
            catch {
                [PSCustomObject]@{
                    ErrorCount = 0
                    LastError  = 'None'
                }
            }
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            $Data = & $ScriptBlock
        }
        else {
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'SilentlyContinue'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            $Data = Invoke-Command @InvokeParams
        }

        return $Data
    }
    catch {
        return $null
    }
}

function Get-MDEStatus {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred,
        [string]$Method = 'Auto'
    )

    $Result = [PSCustomObject]@{
        Hostname                      = $Computer
        Reachable                     = $false
        ValidationMethod              = 'None'
        DefenderInstalled             = $false
        OnboardingState               = $null
        OnboardingStateValue          = $null
        AMRunningMode                 = $null
        AMServiceEnabled              = $null
        RealTimeProtectionEnabled     = $null
        BehaviorMonitorEnabled        = $null
        IsTamperProtected             = $null
        TamperProtectionSource        = $null
        AntivirusSignatureVersion     = $null
        SignatureAgeHours             = $null
        SENSEServiceStatus            = $null
        DiagTrackServiceStatus        = $null
        RecentSENSEErrors             = $null
        LastSENSEError                = $null
        HealthStatus                  = 'Unknown'
        ErrorMessage                  = ''
        Timestamp                     = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')  # Australian date format: DD/MM/YYYY HH:MM:SS
    }

    try {
        $Result.Reachable = Test-Connection -ComputerName $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue

        if (-not $Result.Reachable) {
            $Result.ErrorMessage = 'Device not reachable'
            $Result.HealthStatus = 'Offline'
            return $Result
        }

        if ($Method -eq 'Auto') {
            $MethodsToTry = @('CIM', 'WMI', 'Registry', 'Service')
        }
        else {
            $MethodsToTry = @($Method)
        }

        foreach ($CurrentMethod in $MethodsToTry) {
            try {
                switch ($CurrentMethod) {
                    'CIM' {
                        $CimResult = Get-MDEStatusViaCIM -Computer $Computer -Cred $Cred
                        if ($CimResult.Success) {
                            $Result = Merge-MDEResult -Target $Result -Source $CimResult.Data
                            $Result.ValidationMethod = 'CIM-WSMan'
                            break
                        }
                    }
                    'WMI' {
                        $WmiResult = Get-MDEStatusViaWMI -Computer $Computer -Cred $Cred
                        if ($WmiResult.Success) {
                            $Result = Merge-MDEResult -Target $Result -Source $WmiResult.Data
                            $Result.ValidationMethod = 'WMI-DCOM'
                            break
                        }
                    }
                    'Registry' {
                        $RegResult = Get-MDEStatusViaRegistry -Computer $Computer -Cred $Cred
                        if ($RegResult.Success) {
                            $Result = Merge-MDEResult -Target $Result -Source $RegResult.Data
                            $Result.ValidationMethod = 'Registry'
                            break
                        }
                    }
                    'Service' {
                        $SvcResult = Get-MDEStatusViaService -Computer $Computer -Cred $Cred
                        if ($SvcResult.Success) {
                            $Result = Merge-MDEResult -Target $Result -Source $SvcResult.Data
                            $Result.ValidationMethod = 'Service'
                            break
                        }
                    }
                }

                if ($Result.ValidationMethod -ne 'None') {
                    break
                }
            }
            catch {
                continue
            }
        }

        if ($Result.ValidationMethod -eq 'None') {
            $Result.ErrorMessage = 'All validation methods failed'
            $Result.HealthStatus = 'ValidationFailed'
        }
        else {
            # Supplement CIM/WMI validation with registry and service data
            # MSFT_MpComputerStatus doesn't include MDE onboarding state or service status
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            if ($Result.ValidationMethod -in @('CIM-WSMan', 'WMI-DCOM')) {
                # Get onboarding state from registry (CIM/WMI doesn't provide this)
                $RegData = Get-MDEStatusViaRegistry -Computer $Computer -Cred $Cred
                if ($RegData.Success -and $RegData.Data) {
                    if ($RegData.Data.OnboardingState) {
                        $Result.OnboardingState = $RegData.Data.OnboardingState
                        $Result.OnboardingStateValue = $RegData.Data.OnboardingStateValue
                    }
                }

                # Get service status (CIM/WMI doesn't provide this either)
                $ServiceData = Get-ServiceStatus -Computer $Computer -Cred $Cred
                if ($ServiceData) {
                    if ($ServiceData.SENSEServiceStatus) {
                        $Result.SENSEServiceStatus = $ServiceData.SENSEServiceStatus
                    }
                    if ($ServiceData.DiagTrackServiceStatus) {
                        $Result.DiagTrackServiceStatus = $ServiceData.DiagTrackServiceStatus
                    }
                }
            }

            $EventLogData = Get-SENSEEventLog -Computer $Computer -Cred $Cred
            if ($EventLogData) {
                $Result.RecentSENSEErrors = $EventLogData.ErrorCount
                $Result.LastSENSEError = $EventLogData.LastError
            }

            $Result = Get-MDEHealthState -Result $Result
        }
    }
    catch {
        $Result.ErrorMessage = $_.Exception.Message
        $Result.HealthStatus = 'Error'
    }

    return $Result
}

function Get-MDEStatusViaCIM {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    $Session = $null
    try {
        # Create CIM session using WSMan protocol (modern Windows 10/11, Server 2016+)
        # Reference: https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/new-cimsession
        $SessionParams = @{
            ComputerName = $Computer
            ErrorAction  = 'Stop'
        }

        if ($Cred) {
            $SessionParams.Credential = $Cred
        }

        $Session = New-CimSession @SessionParams

        # Query Defender status via WMI namespace using CIM
        # Reference: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus
        # Reference: https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance
        $Status = Get-CimInstance -CimSession $Session `
            -Namespace 'root/Microsoft/Windows/Defender' `
            -ClassName 'MSFT_MpComputerStatus' `
            -ErrorAction Stop

        if ($Status) {
            return @{
                Success = $true
                Data    = $Status
            }
        }

        return @{ Success = $false }
    }
    catch {
        return @{ Success = $false }
    }
    finally {
        if ($Session) {
            Remove-CimSession -CimSession $Session -ErrorAction SilentlyContinue
        }
    }
}

function Get-MDEStatusViaWMI {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    try {
        # Legacy WMI/DCOM query for Windows 7, Server 2008 R2 compatibility
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject
        # Reference: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus
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
            return @{
                Success = $true
                Data    = $Status
            }
        }

        return @{ Success = $false }
    }
    catch {
        return @{ Success = $false }
    }
}

function Get-MDEStatusViaRegistry {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            # Query MDE registry keys and service status when WMI/CIM unavailable
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty
            $RegData = [PSCustomObject]@{
                DefenderInstalled    = $false
                OnboardingState      = $null
                OnboardingStateValue = $null
                SENSEServiceStatus   = $null
                DiagTrackServiceStatus = $null
            }

            # Check MDE installation registry key
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            $InstallPath = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection' -Name 'InstallLocation' -ErrorAction SilentlyContinue
            if ($InstallPath) {
                $RegData.DefenderInstalled = $true
            }

            # Check onboarding state from registry (0 = not onboarded, 1 = onboarded)
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
            $StatusPath = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status'
            $OnboardingValue = Get-ItemProperty $StatusPath -Name 'OnboardingState' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'OnboardingState'

            if ($null -ne $OnboardingValue) {
                $RegData.OnboardingStateValue = $OnboardingValue
                $RegData.OnboardingState = if ($OnboardingValue -eq 1) { 'Onboarded' } else { 'NotOnboarded' }
            }

            # Check SENSE service (MDE behavioral sensor)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
            $SenseService = Get-Service -Name 'SENSE' -ErrorAction SilentlyContinue
            if ($SenseService) {
                $RegData.SENSEServiceStatus = $SenseService.Status
            }

            # Check DiagTrack service (required for MDE telemetry)
            # Reference: https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
            $DiagService = Get-Service -Name 'DiagTrack' -ErrorAction SilentlyContinue
            if ($DiagService) {
                $RegData.DiagTrackServiceStatus = $DiagService.Status
            }

            return $RegData
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            $Data = & $ScriptBlock
        }
        else {
            # Execute registry query remotely via PowerShell Remoting
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'Stop'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            $Data = Invoke-Command @InvokeParams
        }

        if ($Data.DefenderInstalled) {
            return @{
                Success = $true
                Data    = $Data
            }
        }

        return @{ Success = $false }
    }
    catch {
        return @{ Success = $false }
    }
}

function Get-ServiceStatus {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            # Query MDE service status to supplement CIM/WMI/Registry validation
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
            $SvcData = [PSCustomObject]@{
                SENSEServiceStatus     = $null
                DiagTrackServiceStatus = $null
            }

            $SenseService = Get-Service -Name 'SENSE' -ErrorAction SilentlyContinue
            if ($SenseService) {
                $SvcData.SENSEServiceStatus = $SenseService.Status
            }

            $DiagService = Get-Service -Name 'DiagTrack' -ErrorAction SilentlyContinue
            if ($DiagService) {
                $SvcData.DiagTrackServiceStatus = $DiagService.Status
            }

            return $SvcData
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            $Data = & $ScriptBlock
        }
        else {
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'SilentlyContinue'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            $Data = Invoke-Command @InvokeParams
        }

        return $Data
    }
    catch {
        return $null
    }
}

function Get-MDEStatusViaService {
    param(
        [string]$Computer,
        [System.Management.Automation.PSCredential]$Cred
    )

    try {
        $ScriptBlock = {
            # Minimal validation via service status only (when registry unavailable)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
            $SvcData = [PSCustomObject]@{
                DefenderInstalled      = $false
                SENSEServiceStatus     = $null
                DiagTrackServiceStatus = $null
            }

            $SenseService = Get-Service -Name 'SENSE' -ErrorAction SilentlyContinue
            if ($SenseService) {
                $SvcData.DefenderInstalled = $true
                $SvcData.SENSEServiceStatus = $SenseService.Status
            }

            $DiagService = Get-Service -Name 'DiagTrack' -ErrorAction SilentlyContinue
            if ($DiagService) {
                $SvcData.DiagTrackServiceStatus = $DiagService.Status
            }

            return $SvcData
        }

        if ($Computer -eq $env:COMPUTERNAME) {
            $Data = & $ScriptBlock
        }
        else {
            $InvokeParams = @{
                ComputerName = $Computer
                ScriptBlock  = $ScriptBlock
                ErrorAction  = 'Stop'
            }

            if ($Cred) {
                $InvokeParams.Credential = $Cred
            }

            $Data = Invoke-Command @InvokeParams
        }

        if ($Data.DefenderInstalled) {
            return @{
                Success = $true
                Data    = $Data
            }
        }

        return @{ Success = $false }
    }
    catch {
        return @{ Success = $false }
    }
}

function Merge-MDEResult {
    param(
        [PSCustomObject]$Target,
        [PSCustomObject]$Source
    )

    # If we successfully retrieved data from CIM/WMI (MSFT_MpComputerStatus), infer Defender is installed
    # The WMI class wouldn't exist if Defender wasn't installed
    # Reference: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/defender/msft-mpcomputerstatus
    if ($Source.AMRunningMode -or  $null -ne $Source.RealTimeProtectionEnabled) {
        $Target.DefenderInstalled = $true
    }

    # Registry/Service methods explicitly set DefenderInstalled
    if ($Source.DefenderInstalled) {
        $Target.DefenderInstalled = $Source.DefenderInstalled
    }

    if ($Source.OnboardingState) {
        $Target.OnboardingState = $Source.OnboardingState
        $Target.OnboardingStateValue = $Source.OnboardingStateValue
    }

    if ($Source.AMRunningMode) {
        $Target.AMRunningMode = $Source.AMRunningMode
    }

    if ($null -ne $Source.AMServiceEnabled) {
        $Target.AMServiceEnabled = $Source.AMServiceEnabled
    }

    if ($null -ne $Source.RealTimeProtectionEnabled) {
        $Target.RealTimeProtectionEnabled = $Source.RealTimeProtectionEnabled
    }

    if ($null -ne $Source.BehaviorMonitorEnabled) {
        $Target.BehaviorMonitorEnabled = $Source.BehaviorMonitorEnabled
    }

    if ($null -ne $Source.IsTamperProtected) {
        $Target.IsTamperProtected = $Source.IsTamperProtected
    }

    if ($Source.TamperProtectionSource) {
        $Target.TamperProtectionSource = $Source.TamperProtectionSource
    }

    if ($Source.AntivirusSignatureVersion) {
        $Target.AntivirusSignatureVersion = $Source.AntivirusSignatureVersion
    }

    if ($Source.AntivirusSignatureLastUpdated) {
        $Target.SignatureAgeHours = [math]::Round(((Get-Date) - $Source.AntivirusSignatureLastUpdated).TotalHours, 2)
    }

    if ($Source.SENSEServiceStatus) {
        $Target.SENSEServiceStatus = $Source.SENSEServiceStatus
    }

    if ($Source.DiagTrackServiceStatus) {
        $Target.DiagTrackServiceStatus = $Source.DiagTrackServiceStatus
    }

    return $Target
}

function Get-MDEHealthState {
    param(
        [PSCustomObject]$Result
    )

    # Determine overall health status based on validation results
    # Health states: Healthy, Passive, RealTimeProtectionDisabled, OutdatedSignatures,
    #                Degraded, NotOnboarded, NotInstalled, EventLogErrors,
    #                SenseServiceNotRunning, ValidationFailed, Offline
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/troubleshoot-onboarding
    if (-not $Result.DefenderInstalled) {
        $Result.HealthStatus = 'NotInstalled'
        return $Result
    }

    if ($Result.OnboardingState -eq 'NotOnboarded') {
        $Result.HealthStatus = 'NotOnboarded'
        return $Result
    }

    if ($Result.AMRunningMode -eq 'Normal' -and
        $Result.RealTimeProtectionEnabled -eq $true -and
        $Result.BehaviorMonitorEnabled -eq $true -and
        $Result.SignatureAgeHours -lt 48 -and
        ($null -eq $Result.RecentSENSEErrors -or $Result.RecentSENSEErrors -lt 10)) {
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
    elseif ($Result.SENSEServiceStatus -ne 'Running') {
        $Result.HealthStatus = 'SenseServiceNotRunning'
    }
    elseif ($Result.RecentSENSEErrors -ge 10) {
        $Result.HealthStatus = 'EventLogErrors'
    }
    elseif ($Result.OnboardingState -eq 'Onboarded' -and $Result.SENSEServiceStatus -eq 'Running') {
        $Result.HealthStatus = 'Healthy'
    }
    else {
        $Result.HealthStatus = 'Degraded'
    }

    return $Result
}

try {
    if ($PSCmdlet.ParameterSetName -eq 'Single') {
        # Single device validation mode
        Write-Host "Validating MDE status on: $ComputerName" -ForegroundColor Cyan
        if ($PreferredMethod -ne 'Auto') {
            Write-Host "Using preferred method: $PreferredMethod" -ForegroundColor Cyan
        }

        $Result = Get-MDEStatus -Computer $ComputerName -Cred $Credential -Method $PreferredMethod

        # Log result to file
        Write-MDELog -Result $Result

        Write-Host "`n=== MDE Status ===" -ForegroundColor Yellow
        $Result | Format-List Hostname, ValidationMethod, HealthStatus, OnboardingState,
        AMRunningMode, RealTimeProtectionEnabled, BehaviorMonitorEnabled,
        IsTamperProtected, AntivirusSignatureVersion, SignatureAgeHours,
        SENSEServiceStatus, DiagTrackServiceStatus, RecentSENSEErrors, LastSENSEError, ErrorMessage

        switch ($Result.HealthStatus) {
            'Healthy' { Write-Host "`n✅ MDE is healthy and functional" -ForegroundColor Green }
            { $_ -in @('Passive', 'RealTimeProtectionDisabled', 'OutdatedSignatures', 'Degraded') } {
                Write-Host "`n⚠️ MDE has configuration issues: $_" -ForegroundColor Yellow
            }
            default { Write-Host "`n❌ MDE is not functional: $_" -ForegroundColor Red }
        }

        Write-Host "`nValidation completed using: $($Result.ValidationMethod)" -ForegroundColor Cyan
        Write-Host "Log file: $LogFile" -ForegroundColor Gray
    }
    else {
        # Bulk validation mode with CSV input
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv
        $Devices = Import-Csv -Path $CsvPath

        if (-not ($Devices | Get-Member -Name 'Hostname' -MemberType NoteProperty)) {
            throw "CSV file must contain 'Hostname' column"
        }

        Write-Host "Loaded $($Devices.Count) devices from CSV" -ForegroundColor Cyan
        Write-Host "Processing with ThrottleLimit: $ThrottleLimit" -ForegroundColor Cyan
        if ($PreferredMethod -ne 'Auto') {
            Write-Host "Using preferred method: $PreferredMethod" -ForegroundColor Cyan
        }

        if (-not $OutputPath) {
            $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $OutputPath = "MDE-Status-Report-$Timestamp.csv"
        }

        # Check PowerShell version for parallel execution support
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-7.4#-parallel
        $UsesParallel = $PSVersionTable.PSVersion.Major -ge 7

        if ($UsesParallel) {
            Write-Host "Using parallel execution (PowerShell 7+) with ThrottleLimit: $ThrottleLimit" -ForegroundColor Cyan

            # Create thread-safe synchronized list for log entries
            # Reference: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1
            $LogQueue = [System.Collections.Generic.List[string]]::Synchronized((New-Object System.Collections.Generic.List[string]))

            # Process devices in parallel for performance (PowerShell 7+)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object
            $Results = $Devices | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
                $Device = $_
                $Cred = $using:Credential
                $Method = $using:PreferredMethod
                $SyncLogQueue = $using:LogQueue

                ${function:Get-SENSEEventLog} = ${using:function:Get-SENSEEventLog}
                ${function:Get-ServiceStatus} = ${using:function:Get-ServiceStatus}
                ${function:Get-MDEStatus} = ${using:function:Get-MDEStatus}
                ${function:Get-MDEStatusViaCIM} = ${using:function:Get-MDEStatusViaCIM}
                ${function:Get-MDEStatusViaWMI} = ${using:function:Get-MDEStatusViaWMI}
                ${function:Get-MDEStatusViaRegistry} = ${using:function:Get-MDEStatusViaRegistry}
                ${function:Get-MDEStatusViaService} = ${using:function:Get-MDEStatusViaService}
                ${function:Merge-MDEResult} = ${using:function:Merge-MDEResult}
                ${function:Get-MDEHealthState} = ${using:function:Get-MDEHealthState}
                ${function:Write-MDELog} = ${using:function:Write-MDELog}

                Write-Host "Checking $($Device.Hostname)..." -NoNewline
                $Result = Get-MDEStatus -Computer $Device.Hostname -Cred $Cred -Method $Method

                # Build comprehensive log entry with all fields using Write-MDELog function
                # Reference: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1.add
                $LogFields = [ordered]@{
                    Timestamp                  = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
                    Hostname                   = $Result.Hostname
                    Reachable                  = $Result.Reachable
                    ValidationMethod           = $Result.ValidationMethod
                    HealthStatus               = $Result.HealthStatus
                    DefenderInstalled          = $Result.DefenderInstalled
                    OnboardingState            = if ($Result.OnboardingState) { $Result.OnboardingState } else { 'Unknown' }
                    OnboardingStateValue       = if ($null -ne $Result.OnboardingStateValue) { $Result.OnboardingStateValue } else { 'N/A' }
                    AMRunningMode              = if ($Result.AMRunningMode) { $Result.AMRunningMode } else { 'N/A' }
                    AMServiceEnabled           = if ($null -ne $Result.AMServiceEnabled) { $Result.AMServiceEnabled } else { 'N/A' }
                    RealTimeProtectionEnabled  = if ($null -ne $Result.RealTimeProtectionEnabled) { $Result.RealTimeProtectionEnabled } else { 'N/A' }
                    BehaviorMonitorEnabled     = if ($null -ne $Result.BehaviorMonitorEnabled) { $Result.BehaviorMonitorEnabled } else { 'N/A' }
                    IsTamperProtected          = if ($null -ne $Result.IsTamperProtected) { $Result.IsTamperProtected } else { 'N/A' }
                    TamperProtectionSource     = if ($Result.TamperProtectionSource) { $Result.TamperProtectionSource } else { 'N/A' }
                    AntivirusSignatureVersion  = if ($Result.AntivirusSignatureVersion) { $Result.AntivirusSignatureVersion } else { 'N/A' }
                    SignatureAgeHours          = if ($null -ne $Result.SignatureAgeHours) { $Result.SignatureAgeHours } else { 'N/A' }
                    SENSEServiceStatus         = if ($Result.SENSEServiceStatus) { $Result.SENSEServiceStatus } else { 'N/A' }
                    DiagTrackServiceStatus     = if ($Result.DiagTrackServiceStatus) { $Result.DiagTrackServiceStatus } else { 'N/A' }
                    RecentSENSEErrors          = if ($null -ne $Result.RecentSENSEErrors) { $Result.RecentSENSEErrors } else { '0' }
                    LastSENSEError             = if ($Result.LastSENSEError -and $Result.LastSENSEError -ne 'None') { $Result.LastSENSEError } else { 'None' }
                    ErrorMessage               = if ($Result.ErrorMessage) { $Result.ErrorMessage } else { 'None' }
                }
                $LogEntry = ($LogFields.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ' | '
                $SyncLogQueue.Add($LogEntry)

                $StatusColor = switch ($Result.HealthStatus) {
                    'Healthy' { 'Green' }
                    { $_ -in @('Passive', 'RealTimeProtectionDisabled', 'OutdatedSignatures', 'Degraded') } { 'Yellow' }
                    default { 'Red' }
                }

                $OnboardingDisplay = if ($Result.OnboardingState) { $Result.OnboardingState } else { 'Unknown' }
                Write-Host " $($Result.HealthStatus) | $OnboardingDisplay [$($Result.ValidationMethod)]" -ForegroundColor $StatusColor

                $Result
            }

            # Write all log entries to file after parallel execution completes (thread-safe)
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-content
            if ($LogQueue.Count -gt 0) {
                $LogQueue | Add-Content -Path $LogFile -ErrorAction SilentlyContinue
            }
        }
        else {
            # PowerShell 5.1 fallback - sequential processing (no parallel support)
            Write-Warning 'PowerShell 5.1 detected - using sequential validation (slower)'
            Write-Warning 'For faster bulk validation, install PowerShell 7: https://aka.ms/install-powershell'
            Write-Host "Processing $($Devices.Count) devices sequentially..." -ForegroundColor Yellow

            $Results = foreach ($Device in $Devices) {
                Write-Host "Checking $($Device.Hostname)..." -NoNewline
                $Result = Get-MDEStatus -Computer $Device.Hostname -Cred $Credential -Method $PreferredMethod

                # Log result to file (sequential, no threading concerns)
                Write-MDELog -Result $Result

                $StatusColor = switch ($Result.HealthStatus) {
                    'Healthy' { 'Green' }
                    { $_ -in @('Passive', 'RealTimeProtectionDisabled', 'OutdatedSignatures', 'Degraded') } { 'Yellow' }
                    default { 'Red' }
                }

                $OnboardingDisplay = if ($Result.OnboardingState) { $Result.OnboardingState } else { 'Unknown' }
                Write-Host " $($Result.HealthStatus) | $OnboardingDisplay [$($Result.ValidationMethod)]" -ForegroundColor $StatusColor

                $Result
            }
        }

        # Export results to CSV
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
        $Results | Export-Csv -Path $OutputPath -NoTypeInformation

        Write-Host "`nValidation complete!" -ForegroundColor Green
        Write-Host "Results exported to: $OutputPath" -ForegroundColor Cyan
        Write-Host "Log file: $LogFile" -ForegroundColor Gray

        $Summary = $Results | Group-Object -Property HealthStatus | Select-Object Name, Count
        Write-Host "`n=== Health Status Summary ===" -ForegroundColor Yellow
        $Summary | Format-Table -AutoSize

        $MethodSummary = $Results | Where-Object Reachable -EQ $true | Group-Object -Property ValidationMethod | Select-Object Name, Count
        Write-Host "`n=== Validation Methods Used ===" -ForegroundColor Yellow
        $MethodSummary | Format-Table -AutoSize

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
            $IssueDevices | Select-Object Hostname, HealthStatus, ValidationMethod, OnboardingState, AMRunningMode | Format-Table -AutoSize
        }
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
