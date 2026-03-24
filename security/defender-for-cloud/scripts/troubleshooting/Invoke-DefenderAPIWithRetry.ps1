<#
.SYNOPSIS
    Invokes Microsoft Defender for Cloud REST APIs with intelligent retry logic and rate limiting mitigation.

.DESCRIPTION
    This script provides a robust wrapper for calling Microsoft Defender for Cloud REST APIs with built-in
    retry logic, exponential backoff, rate limiting handling, and comprehensive error reporting. It helps
    mitigate common API issues and provides detailed diagnostics for troubleshooting.

.PARAMETER Uri
    The REST API URI to call.

.PARAMETER Method
    HTTP method to use. Valid values: 'GET', 'POST', 'PUT', 'DELETE', 'PATCH'.

.PARAMETER Body
    Request body for POST, PUT, and PATCH operations.

.PARAMETER Headers
    Additional headers to include in the request.

.PARAMETER MaxRetries
    Maximum number of retry attempts. Default is 5.

.PARAMETER InitialRetryDelay
    Initial delay in seconds before first retry. Default is 1 second.

.PARAMETER MaxRetryDelay
    Maximum delay in seconds between retries. Default is 60 seconds.

.PARAMETER EnableDetailedLogging
    Switch to enable detailed request/response logging.

.PARAMETER OutputFormat
    Output format for the response. Valid values: 'JSON', 'PSObject', 'Raw'.

.PARAMETER TimeoutSeconds
    Request timeout in seconds. Default is 300 (5 minutes).

.EXAMPLE
    .\Invoke-DefenderAPIWithRetry.ps1 -Uri "https://management.azure.com/subscriptions/12345/providers/Microsoft.Security/assessments" -Method "GET"

.EXAMPLE
    .\Invoke-DefenderAPIWithRetry.ps1 -Uri "https://management.azure.com/subscriptions/12345/providers/Microsoft.Security/pricings/VirtualMachines" -Method "PUT" -Body '{"properties":{"pricingTier":"Standard"}}' -EnableDetailedLogging

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: Az PowerShell module, appropriate API permissions

    This script handles common API issues including rate limiting, transient failures, and authentication challenges.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Uri,

    [Parameter(Mandatory = $false)]
    [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
    [string]$Method = 'GET',

    [Parameter(Mandatory = $false)]
    [string]$Body,

    [Parameter(Mandatory = $false)]
    [hashtable]$Headers = @{},

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 10)]
    [int]$MaxRetries = 5,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 30)]
    [int]$InitialRetryDelay = 1,

    [Parameter(Mandatory = $false)]
    [ValidateRange(10, 300)]
    [int]$MaxRetryDelay = 60,

    [Parameter(Mandatory = $false)]
    [switch]$EnableDetailedLogging,

    [Parameter(Mandatory = $false)]
    [ValidateSet('JSON', 'PSObject', 'Raw')]
    [string]$OutputFormat = 'PSObject',

    [Parameter(Mandatory = $false)]
    [ValidateRange(30, 600)]
    [int]$TimeoutSeconds = 300
)

# Import required modules
try {
    Import-Module Az.Accounts -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import required Azure modules: $($_.Exception.Message)"
    exit 1
}

# Function to get Azure access token
function Get-AzureAccessToken {
    try {
        $Context = Get-AzContext
        if (-not $Context) {
            throw "No Azure context found. Please run Connect-AzAccount first."
        }

        $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($Context.Account, $Context.Environment, $Context.Tenant.Id, $null, $null, $null, "https://management.azure.com/").AccessToken
        return $Token
    } catch {
        throw "Failed to get Azure access token: $($_.Exception.Message)"
    }
}

# Function to calculate exponential backoff delay
function Get-ExponentialBackoffDelay {
    param(
        [int]$RetryAttempt,
        [int]$InitialDelay,
        [int]$MaxDelay
    )

    $Delay = $InitialDelay * [Math]::Pow(2, $RetryAttempt - 1)
    return [Math]::Min($Delay, $MaxDelay)
}

# Function to parse retry-after header
function Get-RetryAfterDelay {
    param(
        [string]$RetryAfterHeader
    )

    if ([string]::IsNullOrEmpty($RetryAfterHeader)) {
        return 0
    }

    # Try to parse as seconds
    $Seconds = 0
    if ([int]::TryParse($RetryAfterHeader, [ref]$Seconds)) {
        return $Seconds
    }

    # Try to parse as HTTP date
    $Date = [DateTime]::MinValue
    if ([DateTime]::TryParse($RetryAfterHeader, [ref]$Date)) {
        $DelaySeconds = ($Date - [DateTime]::UtcNow).TotalSeconds
        return [Math]::Max(0, $DelaySeconds)
    }

    return 0
}

# Function to log detailed request information
function Write-RequestLog {
    param(
        [string]$Message,
        [string]$Level = "Info",
        [hashtable]$Details = @{}
    )

    if (-not $EnableDetailedLogging) {
        return
    }

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $LogEntry = @{
        Timestamp = $Timestamp
        Level     = $Level
        Message   = $Message
        Details   = $Details
    }

    $Color = switch ($Level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Success" { "Green" }
        default { "Gray" }
    }

    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Color

    if ($Details.Count -gt 0) {
        foreach ($Key in $Details.Keys) {
            Write-Host "  $Key`: $($Details[$Key])" -ForegroundColor Gray
        }
    }
}

# Main retry logic function
function Invoke-APIWithRetry {
    param(
        [string]$Uri,
        [string]$Method,
        [string]$Body,
        [hashtable]$Headers,
        [string]$AccessToken
    )

    $RetryAttempt = 0
    $LastException = $null

    while ($RetryAttempt -le $MaxRetries) {
        try {
            # Prepare headers
            $RequestHeaders = @{
                'Authorization' = "Bearer $AccessToken"
                'Content-Type'  = 'application/json'
                'User-Agent'    = 'PowerShell-DefenderAPIClient/1.0'
            }

            # Add custom headers
            foreach ($Header in $Headers.GetEnumerator()) {
                $RequestHeaders[$Header.Key] = $Header.Value
            }

            Write-RequestLog -Message "Making API request" -Details @{
                "Attempt" = $RetryAttempt + 1
                "Uri"     = $Uri
                "Method"  = $Method
                "HasBody" = (-not [string]::IsNullOrEmpty($Body))
            }

            # Prepare request parameters
            $RequestParams = @{
                Uri             = $Uri
                Method          = $Method
                Headers         = $RequestHeaders
                TimeoutSec      = $TimeoutSeconds
                UseBasicParsing = $true
            }

            if (-not [string]::IsNullOrEmpty($Body) -and $Method -in @('POST', 'PUT', 'PATCH')) {
                $RequestParams.Body = $Body
            }

            # Make the request
            $Response = Invoke-RestMethod @RequestParams

            Write-RequestLog -Message "API request successful" -Level "Success" -Details @{
                "StatusCode"   = "200"
                "ResponseSize" = if ($Response) { "$($Response | ConvertTo-Json -Depth 1 -Compress | Measure-Object -Character | Select-Object -ExpandProperty Characters) characters" } else { "0 characters" }
            }

            return @{
                Success      = $true
                Response     = $Response
                StatusCode   = 200
                RetryAttempt = $RetryAttempt
                Error        = $null
            }
        } catch {
            $LastException = $_
            $StatusCode = 0
            $RetryAfter = 0

            # Extract status code and retry-after header if available
            if ($_.Exception.Response) {
                $StatusCode = [int]$_.Exception.Response.StatusCode
                $RetryAfterHeader = $_.Exception.Response.Headers['Retry-After']
                if ($RetryAfterHeader) {
                    $RetryAfter = Get-RetryAfterDelay -RetryAfterHeader $RetryAfterHeader
                }
            }

            $ShouldRetry = $false
            $RetryReason = ""

            # Determine if we should retry based on the error
            switch ($StatusCode) {
                429 {
                    # Too Many Requests
                    $ShouldRetry = $true
                    $RetryReason = "Rate limiting (429)"
                }
                500 {
                    # Internal Server Error
                    $ShouldRetry = $true
                    $RetryReason = "Internal server error (500)"
                }
                502 {
                    # Bad Gateway
                    $ShouldRetry = $true
                    $RetryReason = "Bad gateway (502)"
                }
                503 {
                    # Service Unavailable
                    $ShouldRetry = $true
                    $RetryReason = "Service unavailable (503)"
                }
                504 {
                    # Gateway Timeout
                    $ShouldRetry = $true
                    $RetryReason = "Gateway timeout (504)"
                }
                default {
                    if ($_.Exception.Message -like "*timeout*" -or $_.Exception.Message -like "*network*") {
                        $ShouldRetry = $true
                        $RetryReason = "Network/timeout error"
                    }
                }
            }

            Write-RequestLog -Message "API request failed" -Level "Warning" -Details @{
                "StatusCode"  = $StatusCode
                "Error"       = $_.Exception.Message
                "ShouldRetry" = $ShouldRetry
                "RetryReason" = $RetryReason
                "RetryAfter"  = $RetryAfter
            }

            if (-not $ShouldRetry -or $RetryAttempt -ge $MaxRetries) {
                Write-RequestLog -Message "Maximum retries exceeded or non-retryable error" -Level "Error"
                break
            }

            # Calculate delay
            $DelaySeconds = if ($RetryAfter -gt 0) {
                [Math]::Min($RetryAfter, $MaxRetryDelay)
            } else {
                Get-ExponentialBackoffDelay -RetryAttempt ($RetryAttempt + 1) -InitialDelay $InitialRetryDelay -MaxDelay $MaxRetryDelay
            }

            Write-RequestLog -Message "Waiting before retry" -Details @{
                "DelaySeconds" = $DelaySeconds
                "NextAttempt"  = $RetryAttempt + 2
            }

            Start-Sleep -Seconds $DelaySeconds
            $RetryAttempt++
        }
    }

    # All retries failed
    return @{
        Success      = $false
        Response     = $null
        StatusCode   = if ($LastException.Exception.Response) { [int]$LastException.Exception.Response.StatusCode } else { 0 }
        RetryAttempt = $RetryAttempt
        Error        = $LastException
    }
}

# Main execution
try {
    Write-Host "Initializing Defender API client with retry logic..." -ForegroundColor Yellow

    # Validate Azure context
    $Context = Get-AzContext
    if (-not $Context) {
        Write-Error "No Azure context found. Please run Connect-AzAccount first."
        exit 1
    }

    Write-RequestLog -Message "Azure context validated" -Details @{
        "SubscriptionId" = $Context.Subscription.Id
        "TenantId"       = $Context.Tenant.Id
        "Account"        = $Context.Account.Id
    }

    # Get access token
    Write-Host "Obtaining Azure access token..." -ForegroundColor Yellow
    $AccessToken = Get-AzureAccessToken
    Write-RequestLog -Message "Access token obtained successfully"

    # Validate URI
    try {
        $UriObject = [System.Uri]::new($Uri)
        if ($UriObject.Scheme -notin @('http', 'https')) {
            throw "URI must use HTTP or HTTPS scheme"
        }
    } catch {
        Write-Error "Invalid URI: $($_.Exception.Message)"
        exit 1
    }

    # Execute API call with retry logic
    Write-Host "Executing API call with retry logic..." -ForegroundColor Yellow
    $StartTime = Get-Date
    $Result = Invoke-APIWithRetry -Uri $Uri -Method $Method -Body $Body -Headers $Headers -AccessToken $AccessToken
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime

    # Process results
    if ($Result.Success) {
        Write-Host "✓ API call completed successfully" -ForegroundColor Green
        Write-Host "  Retry attempts: $($Result.RetryAttempt)" -ForegroundColor Gray
        Write-Host "  Total duration: $([math]::Round($Duration.TotalSeconds, 2)) seconds" -ForegroundColor Gray

        # Format output based on requested format
        switch ($OutputFormat) {
            'JSON' {
                return $Result.Response | ConvertTo-Json -Depth 10
            }
            'Raw' {
                return $Result.Response
            }
            default {
                return $Result.Response
            }
        }
    } else {
        Write-Host "✗ API call failed after $($Result.RetryAttempt) retry attempts" -ForegroundColor Red
        Write-Host "  Total duration: $([math]::Round($Duration.TotalSeconds, 2)) seconds" -ForegroundColor Gray
        Write-Host "  Final status code: $($Result.StatusCode)" -ForegroundColor Red
        Write-Host "  Error: $($Result.Error.Exception.Message)" -ForegroundColor Red

        # Return error information
        return @{
            Success       = $false
            StatusCode    = $Result.StatusCode
            Error         = $Result.Error.Exception.Message
            RetryAttempts = $Result.RetryAttempt
            Duration      = $Duration.TotalSeconds
        }
    }
} catch {
    Write-Error "Failed to execute API call: $($_.Exception.Message)"
    exit 1
}

# Support case creation helper function
function New-DefenderSupportCase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Critical', 'High', 'Medium', 'Low')]
        [string]$Severity,

        [Parameter(Mandatory = $false)]
        [string[]]$DiagnosticFiles = @()
    )

    Write-Host "Creating Microsoft Support Case for Defender for Cloud..." -ForegroundColor Yellow

    $SupportCase = @{
        Title             = $Title
        Description       = $Description
        Severity          = $Severity
        ProductFamily     = "Microsoft Defender for Cloud"
        CreatedDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        DiagnosticFiles   = $DiagnosticFiles
        ContactPreference = "Email"
        SubscriptionId    = (Get-AzContext).Subscription.Id
    }

    Write-Host "Support Case Information:" -ForegroundColor Cyan
    Write-Host "  Title: $($SupportCase.Title)" -ForegroundColor White
    Write-Host "  Severity: $($SupportCase.Severity)" -ForegroundColor White
    Write-Host "  Subscription: $($SupportCase.SubscriptionId)" -ForegroundColor White
    Write-Host "  Created: $($SupportCase.CreatedDate)" -ForegroundColor White

    if ($DiagnosticFiles.Count -gt 0) {
        Write-Host "  Diagnostic Files:" -ForegroundColor White
        foreach ($File in $DiagnosticFiles) {
            Write-Host "    - $File" -ForegroundColor Gray
        }
    }

    Write-Host "`nPlease provide this information when contacting Microsoft Support." -ForegroundColor Yellow
    Write-Host "Support Portal: https://portal.azure.com/#create/Microsoft.Support" -ForegroundColor Cyan

    return $SupportCase
}
