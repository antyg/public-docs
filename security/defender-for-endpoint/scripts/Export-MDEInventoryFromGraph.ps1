<#
.SYNOPSIS
    Exports MDE onboarding status from Microsoft Graph API for devices in CSV.

.DESCRIPTION
    Queries Microsoft Graph API to retrieve MDE onboarding status, health state,
    risk scores, and device details. Supports three modes:
    1. CSV validation - validate devices from CSV file
    2. Full inventory export - retrieve all devices (no CSV)
    3. Unmanaged device discovery - find devices with "CanBeOnboarded" status

    Supports both app-only authentication (client credentials) and delegated permissions.

.PARAMETER TenantId
    Azure AD Tenant ID

.PARAMETER ClientId
    Azure AD App Registration Client ID

.PARAMETER ClientSecret
    Azure AD App Registration Client Secret

.PARAMETER CsvPath
    Path to CSV file containing device hostnames (optional). If not provided, retrieves all devices.

.PARAMETER OutputPath
    Path for output CSV report. Defaults to current directory with timestamp.

.PARAMETER OnlyUnmanaged
    Switch to filter results to only unmanaged devices (OnboardingStatus = "CanBeOnboarded").
    Use for discovering devices that can be onboarded to MDE.

.EXAMPLE
    .\Export-MDEStatusFromGraph.ps1 `
        -TenantId "12345678-1234-1234-1234-123456789012" `
        -ClientId "abcd1234-5678-90ab-cdef-123456789012" `
        -ClientSecret "your-client-secret"

.EXAMPLE
    .\Export-MDEStatusFromGraph.ps1 `
        -TenantId "tenant-id" `
        -ClientId "client-id" `
        -ClientSecret "secret" `
        -CsvPath "C:\devices.csv" `
        -OutputPath "C:\mde-graph-report.csv"

.EXAMPLE
    .\Export-MDEStatusFromGraph.ps1 `
        -TenantId "tenant-id" `
        -ClientId "client-id" `
        -ClientSecret "secret" `
        -OnlyUnmanaged `
        -OutputPath "C:\unmanaged-devices.csv"

.NOTES
    Author: Security Operations Team
    Version: 1.1
    Requires: PowerShell 5.1+
    API Permissions Required: Machine.Read.All or Machine.ReadWrite.All
    Region: Australian localisation (AU date format: dd/MM/yyyy HH:mm:ss)

.REFERENCES
    OAuth 2.0 Client Credentials Flow - Microsoft Identity Platform
    https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow

    Get Access Without a User - Microsoft Graph
    https://learn.microsoft.com/en-us/graph/auth-v2-service

    Create an App to Access Microsoft Defender for Endpoint Without a User
    https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-webapp

    List Machines API - Microsoft Defender for Endpoint
    https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines

    Machine Resource Type - Microsoft Defender for Endpoint
    https://learn.microsoft.com/en-us/defender-endpoint/api/machine

    Import-Csv Cmdlet - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv

    Export-Csv Cmdlet - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$ClientId,

    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,

    [Parameter(Mandatory = $false)]
    [ValidateScript({ if ($_) { Test-Path $_ } else { $true } })]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [switch]$OnlyUnmanaged
)

$ErrorActionPreference = 'Stop'

function Get-GraphAccessToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    # OAuth 2.0 client credentials flow for Microsoft Defender for Endpoint API
    # Reference: https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-webapp
    $Body = @{
        Grant_Type    = 'client_credentials'
        Scope         = 'https://api.securitycenter.microsoft.com/.default'
        Client_Id     = $ClientId
        Client_Secret = $ClientSecret
    }

    # Microsoft identity platform v2.0 token endpoint
    # Reference: https://learn.microsoft.com/en-us/graph/auth-v2-service
    $TokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

    try {
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod
        $Response = Invoke-RestMethod -Method Post -Uri $TokenUrl -Body $Body -ContentType 'application/x-www-form-urlencoded'
        return $Response.access_token
    }
    catch {
        throw "Failed to obtain access token: $_"
    }
}

function Get-MDEDevicesFromGraph {
    param(
        [string]$AccessToken,
        [string]$Filter = $null
    )

    $Headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    # Microsoft Defender for Endpoint machines API endpoint
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
    # Rate limits: 100 calls per minute, 1,500 calls per hour
    $BaseUri = 'https://api.security.microsoft.com/api/machines'
    $AllDevices = @()
    $Uri = if ($Filter) { "$BaseUri?`$filter=$Filter" } else { $BaseUri }

    do {
        try {
            # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod
            $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
            $AllDevices += $Response.value

            # OData pagination support for large result sets
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
            if ($Response.'@odata.nextLink') {
                $Uri = $Response.'@odata.nextLink'
                Write-Host "Retrieved $($AllDevices.Count) devices so far..." -ForegroundColor Cyan
            }
            else {
                $Uri = $null
            }
        }
        catch {
            # Handle rate limiting as per API documentation
            # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
            if ($_.Exception.Response.StatusCode -eq 429) {
                Write-Warning 'Rate limit exceeded. Waiting 60 seconds...'
                Start-Sleep -Seconds 60
            }
            else {
                throw "Graph API query failed: $_"
            }
        }
    } while ($Uri)

    return $AllDevices
}

try {
    Write-Host 'Authenticating to Microsoft Graph API...' -ForegroundColor Cyan
    $AccessToken = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
    Write-Host 'Authentication successful!' -ForegroundColor Green

    if ($CsvPath) {
        # Import device list from CSV file
        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv
        $DeviceList = Import-Csv -Path $CsvPath

        if (-not ($DeviceList | Get-Member -Name 'Hostname' -MemberType NoteProperty)) {
            throw "CSV file must contain 'Hostname' column"
        }

        Write-Host "Loaded $($DeviceList.Count) devices from CSV" -ForegroundColor Cyan
        Write-Host 'Querying Graph API for device status...' -ForegroundColor Cyan

        $AllDevices = Get-MDEDevicesFromGraph -AccessToken $AccessToken
        Write-Host "Retrieved $($AllDevices.Count) total devices from MDE" -ForegroundColor Green

        $Results = foreach ($Device in $DeviceList) {
            $GraphDevice = $AllDevices | Where-Object {
                $_.computerDnsName -like "*$($Device.Hostname)*" -or
                $_.computerDnsName -eq $Device.Hostname
            } | Select-Object -First 1

            if ($GraphDevice) {
                # Machine resource properties as defined in API schema
                # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/machine
                [PSCustomObject]@{
                    Hostname           = $Device.Hostname
                    FoundInGraph       = $true
                    ComputerDnsName    = $GraphDevice.computerDnsName
                    OnboardingStatus   = $GraphDevice.onboardingStatus    # Values: "onboarded", "CanBeOnboarded", "Unsupported", "InsufficientInfo"
                    HealthStatus       = $GraphDevice.healthStatus        # Values: "Active", "Inactive", "ImpairedCommunication", "NoSensorData", etc.
                    RiskScore          = $GraphDevice.riskScore           # Values: "None", "Informational", "Low", "Medium", "High"
                    ExposureLevel      = $GraphDevice.exposureLevel       # Values: "None", "Low", "Medium", "High"
                    OSPlatform         = $GraphDevice.osPlatform
                    OSVersion          = $GraphDevice.osVersion
                    LastSeen           = $GraphDevice.lastSeen
                    AzureADDeviceId    = $GraphDevice.aadDeviceId
                    MDEAgentVersion    = $GraphDevice.version
                    DeviceId           = $GraphDevice.id
                    Timestamp          = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')  # Australian date format: DD/MM/YYYY HH:MM:SS
                }
            }
            else {
                [PSCustomObject]@{
                    Hostname           = $Device.Hostname
                    FoundInGraph       = $false
                    ComputerDnsName    = $null
                    OnboardingStatus   = 'NotFoundInMDE'
                    HealthStatus       = $null
                    RiskScore          = $null
                    ExposureLevel      = $null
                    OSPlatform         = $null
                    OSVersion          = $null
                    LastSeen           = $null
                    AzureADDeviceId    = $null
                    MDEAgentVersion    = $null
                    DeviceId           = $null
                    Timestamp          = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')  # Australian date format: DD/MM/YYYY HH:MM:SS
                }
            }
        }
    }
    else {
        if ($OnlyUnmanaged) {
            Write-Host 'Retrieving only unmanaged devices (CanBeOnboarded) from MDE...' -ForegroundColor Cyan
            # Use OData filter to retrieve only devices that can be onboarded
            $AllDevices = Get-MDEDevicesFromGraph -AccessToken $AccessToken -Filter "onboardingStatus eq 'CanBeOnboarded'"
            Write-Host "Retrieved $($AllDevices.Count) unmanaged devices from MDE" -ForegroundColor Green
        }
        else {
            Write-Host 'No CSV provided. Retrieving all devices from MDE...' -ForegroundColor Cyan
            $AllDevices = Get-MDEDevicesFromGraph -AccessToken $AccessToken
            Write-Host "Retrieved $($AllDevices.Count) devices from MDE" -ForegroundColor Green
        }

        # Map all machine properties from API response
        # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/machine
        $Results = $AllDevices | ForEach-Object {
            [PSCustomObject]@{
                ComputerDnsName    = $_.computerDnsName
                OnboardingStatus   = $_.onboardingStatus
                HealthStatus       = $_.healthStatus
                RiskScore          = $_.riskScore
                ExposureLevel      = $_.exposureLevel
                OSPlatform         = $_.osPlatform
                OSVersion          = $_.osVersion
                LastSeen           = $_.lastSeen
                FirstSeen          = $_.firstSeen
                AzureADDeviceId    = $_.aadDeviceId
                MDEAgentVersion    = $_.version
                DeviceId           = $_.id
                MachineGroups      = ($_.rbacGroupName -join '; ')
                Tags               = ($_.machineTags -join '; ')
                Timestamp          = (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')  # Australian date format: DD/MM/YYYY HH:MM:SS
            }
        }
    }

    if (-not $OutputPath) {
        $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $OutputPath = "MDE-Graph-Export-$Timestamp.csv"
    }

    # Export results to CSV file
    # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv
    $Results | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "`nExport complete!" -ForegroundColor Green
    Write-Host "Results exported to: $OutputPath" -ForegroundColor Cyan

    $Summary = $Results | Group-Object -Property OnboardingStatus | Select-Object Name, Count
    Write-Host "`n=== Onboarding Status Summary ===" -ForegroundColor Yellow
    $Summary | Format-Table -AutoSize

    if ($CsvPath) {
        $FoundCount = ($Results | Where-Object FoundInGraph -EQ $true).Count
        $TotalCount = $Results.Count
        $FoundPercent = [math]::Round(($FoundCount / $TotalCount) * 100, 2)
        Write-Host "Devices found in MDE: $FoundCount / $TotalCount ($FoundPercent%)" -ForegroundColor Cyan

        $OnboardedCount = ($Results | Where-Object OnboardingStatus -EQ 'Onboarded').Count
        if ($FoundCount -gt 0) {
            $OnboardedPercent = [math]::Round(($OnboardedCount / $FoundCount) * 100, 2)
            Write-Host "Onboarded devices: $OnboardedCount / $FoundCount ($OnboardedPercent%)" -ForegroundColor $(
                if ($OnboardedPercent -eq 100) { 'Green' } elseif ($OnboardedPercent -ge 90) { 'Yellow' } else { 'Red' }
            )
        }
    }
    else {
        $OnboardedCount = ($Results | Where-Object OnboardingStatus -EQ 'Onboarded').Count
        $CanBeOnboardedCount = ($Results | Where-Object OnboardingStatus -EQ 'CanBeOnboarded').Count
        $TotalCount = $Results.Count

        Write-Host "`nOnboarded: $OnboardedCount devices" -ForegroundColor Green
        Write-Host "Can be onboarded: $CanBeOnboardedCount devices" -ForegroundColor Yellow
        Write-Host "Total devices: $TotalCount" -ForegroundColor Cyan
    }

    # Identify high-risk devices based on risk score values from API schema
    # Reference: https://learn.microsoft.com/en-us/defender-endpoint/api/machine
    $HighRiskDevices = $Results | Where-Object { $_.OnboardingStatus -eq 'Onboarded' -and $_.RiskScore -in @('High', 'Critical') }
    if ($HighRiskDevices.Count -gt 0) {
        Write-Host "`n=== High Risk Devices ===" -ForegroundColor Red
        $HighRiskDevices | Select-Object ComputerDnsName, RiskScore, ExposureLevel, LastSeen | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
