<#
.SYNOPSIS
    Downloads and extracts the Microsoft Defender for Endpoint Client Analyzer tool.

.DESCRIPTION
    Downloads the latest MDE Client Analyzer from Microsoft's official aka.ms URL,
    saves it to the script directory, and extracts it to a subfolder for immediate use.

    The analyzer provides comprehensive diagnostic capabilities including:
    - Network connectivity validation to MDE cloud endpoints
    - Sensor health and configuration checks
    - Event log analysis for onboarding issues
    - Performance troubleshooting
    - Detailed diagnostic reports in HTML and text formats

.PARAMETER Force
    Force re-download even if the analyzer already exists locally.

.PARAMETER SkipExtraction
    Download the ZIP file but skip extraction (useful for offline deployment scenarios).

.EXAMPLE
    .\Get-MDEClientAnalyzer.ps1

.EXAMPLE
    .\Get-MDEClientAnalyzer.ps1 -Force

.EXAMPLE
    .\Get-MDEClientAnalyzer.ps1 -SkipExtraction

.NOTES
    Author: Security Operations Team
    Version: 1.0
    Requires: PowerShell 5.1+, Internet connectivity
    Region: Australian localization (AU date format: dd/MM/yyyy HH:mm:ss)

.REFERENCES
    Run the client analyzer on Windows - Microsoft Defender for Endpoint
    https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows

    MDE Client Analyzer - GitHub Repository
    https://github.com/microsoft/MDATP-PowerBI-Templates/tree/master/MDE%20Client%20Analyzer

    Invoke-WebRequest PowerShell Cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest

    Expand-Archive PowerShell Cmdlet
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$SkipExtraction
)

$ErrorActionPreference = 'Stop'

# Determine script directory and set paths
# Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptPath) { $ScriptPath = $PWD.Path }

$ZipPath = Join-Path -Path $ScriptPath -ChildPath 'MDEClientAnalyzer.zip'
$ExtractPath = Join-Path -Path $ScriptPath -ChildPath 'MDEClientAnalyzer'
$AnalyzerUrl = 'https://aka.ms/mdatpanalyzer'

try {
    Write-Host '=== Microsoft Defender for Endpoint Client Analyzer Downloader ===' -ForegroundColor Cyan
    Write-Host "Script Directory: $ScriptPath" -ForegroundColor Gray
    Write-Host "Download URL: $AnalyzerUrl`n" -ForegroundColor Gray

    # Check if already downloaded
    if (Test-Path $ZipPath) {
        if ($Force) {
            Write-Host 'Existing ZIP file found - Force parameter specified, re-downloading...' -ForegroundColor Yellow
            Remove-Item -Path $ZipPath -Force
        }
        else {
            Write-Host 'Existing ZIP file found - use -Force to re-download' -ForegroundColor Yellow
            $UseExisting = $true
        }
    }

    # Download the analyzer
    if (-not $UseExisting) {
        Write-Host 'Downloading MDE Client Analyzer...' -ForegroundColor Cyan

        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest
        # -UseBasicParsing for compatibility with Server Core installations
        # -MaximumRedirection follows aka.ms redirect to actual download location
        $StartTime = Get-Date
        Invoke-WebRequest -Uri $AnalyzerUrl `
            -OutFile $ZipPath `
            -UseBasicParsing `
            -MaximumRedirection 5 `
            -ErrorAction Stop

        $EndTime = Get-Date
        $Duration = ($EndTime - $StartTime).TotalSeconds

        $FileSize = (Get-Item $ZipPath).Length
        $FileSizeMB = [math]::Round($FileSize / 1MB, 2)

        Write-Host "Download complete! ($FileSizeMB MB in $([math]::Round($Duration, 1)) seconds)" -ForegroundColor Green
        Write-Host "Saved to: $ZipPath" -ForegroundColor Cyan
    }
    else {
        $FileSize = (Get-Item $ZipPath).Length
        $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
        Write-Host "Using existing download: $ZipPath ($FileSizeMB MB)" -ForegroundColor Cyan
    }

    # Extract the analyzer
    if (-not $SkipExtraction) {
        Write-Host "`nExtracting analyzer..." -ForegroundColor Cyan

        # Remove existing extraction directory if present
        if (Test-Path $ExtractPath) {
            Write-Host 'Removing existing extraction directory...' -ForegroundColor Yellow
            Remove-Item -Path $ExtractPath -Recurse -Force
        }

        # Reference: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive
        Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

        Write-Host 'Extraction complete!' -ForegroundColor Green
        Write-Host "Extracted to: $ExtractPath" -ForegroundColor Cyan

        # Locate the main analyzer executable
        $AnalyzerCmd = Get-ChildItem -Path $ExtractPath -Filter 'MDEClientAnalyzer.cmd' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        $AnalyzerPs1 = Get-ChildItem -Path $ExtractPath -Filter 'MDEClientAnalyzer.ps1' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($AnalyzerCmd) {
            Write-Host "`n=== Analyzer Ready ===" -ForegroundColor Green
            Write-Host "CMD Script: $($AnalyzerCmd.FullName)" -ForegroundColor White

            if ($AnalyzerPs1) {
                Write-Host "PS1 Script: $($AnalyzerPs1.FullName)" -ForegroundColor White
            }

            Write-Host "`n=== Usage Instructions ===" -ForegroundColor Yellow
            Write-Host 'To run the analyzer with default settings:' -ForegroundColor White
            Write-Host "  cd `"$($AnalyzerCmd.DirectoryName)`"" -ForegroundColor Cyan
            Write-Host '  .\MDEClientAnalyzer.cmd' -ForegroundColor Cyan

            Write-Host "`nFor advanced options (PowerShell):" -ForegroundColor White
            Write-Host "  cd `"$($AnalyzerPs1.DirectoryName)`"" -ForegroundColor Cyan
            Write-Host '  Get-Help .\MDEClientAnalyzer.ps1 -Full' -ForegroundColor Cyan

            Write-Host "`nCommon scenarios:" -ForegroundColor White
            Write-Host '  Basic connectivity test: .\MDEClientAnalyzer.cmd -Connectivity' -ForegroundColor Gray
            Write-Host '  Full diagnostic:         .\MDEClientAnalyzer.cmd' -ForegroundColor Gray
            Write-Host '  Performance analysis:    .\MDEClientAnalyzer.ps1 -PerformanceAnalysis' -ForegroundColor Gray
        }
        else {
            Write-Warning 'Could not locate MDEClientAnalyzer.cmd in extracted files'
            Write-Host "Please check the extraction directory: $ExtractPath" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "`nSkipping extraction (use without -SkipExtraction to extract)" -ForegroundColor Yellow
    }

    # Provide summary
    $Timestamp = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
    Write-Host "`n=== Download Summary ===" -ForegroundColor Yellow
    Write-Host "Timestamp: $Timestamp" -ForegroundColor Gray
    Write-Host "ZIP File: $ZipPath" -ForegroundColor Gray
    if (-not $SkipExtraction) {
        Write-Host "Extracted: $ExtractPath" -ForegroundColor Gray
    }
    Write-Host "`n✅ MDE Client Analyzer ready for use!" -ForegroundColor Green

    # Additional references
    Write-Host "`n=== Additional Resources ===" -ForegroundColor Yellow
    Write-Host 'Official Documentation:' -ForegroundColor White
    Write-Host '  https://learn.microsoft.com/en-us/defender-endpoint/run-analyzer-windows' -ForegroundColor Cyan
    Write-Host 'GitHub Repository:' -ForegroundColor White
    Write-Host '  https://github.com/microsoft/MDATP-PowerBI-Templates' -ForegroundColor Cyan

}
catch {
    Write-Error "Failed to download/extract MDE Client Analyzer: $_"

    Write-Host "`n=== Troubleshooting ===" -ForegroundColor Yellow
    Write-Host 'If download fails:' -ForegroundColor White
    Write-Host '  1. Check internet connectivity' -ForegroundColor Gray
    Write-Host '  2. Verify proxy settings: netsh winhttp show proxy' -ForegroundColor Gray
    Write-Host "  3. Test URL manually: Invoke-WebRequest -Uri '$AnalyzerUrl' -UseBasicParsing" -ForegroundColor Gray
    Write-Host '  4. Download manually from: https://aka.ms/mdatpanalyzer' -ForegroundColor Gray

    exit 1
}
