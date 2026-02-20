#!/usr/bin/env pwsh
#Requires -Version 5.1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Interactive diagnostic capture script — internal helper functions do not require ShouldProcess support.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Return is always content that requires plural form.')]

<#
.SYNOPSIS
    Capture ZCC VPN diagnostics from iOS device on Windows.

.DESCRIPTION
    Captures comprehensive device-side diagnostics for Zscaler Client Connector (ZCC)
    VPN troubleshooting on Windows including:
      - iOS device logs (ZCC client behavior)
      - Device VPN profiles (ZCC configuration)
      - Device system information

    IMPORTANT LIMITATION:
    Network packet capture is NOT available on Windows.
    - RVI (Remote Virtual Interface) is macOS-only
    - Cannot capture VPN tunnel traffic on Windows
    - For network-level diagnostics: Use macOS version

    This captures device-side logs only, which are still valuable for:
      - ZCC client errors and status
      - VPN profile configuration issues
      - Authentication problems
      - App-level diagnostics

.PARAMETER OutputDirectory
    Custom output directory for captured diagnostics.
    Default: .\logs\<timestamp>

.EXAMPLE
    .\Invoke-ZCCDiagnosticCapture.ps1

    Captures device diagnostics to default location.

.EXAMPLE
    .\Invoke-ZCCDiagnosticCapture.ps1 -OutputDirectory "C:\ZCC_Diagnostics"

    Captures diagnostics to custom directory.

.NOTES
    Version: 1.0.0

    Network Capture Limitation:
    - Windows cannot capture VPN network traffic from iOS devices
    - RVI requires macOS rvictl and Apple frameworks
    - Use macOS for complete VPN tunnel diagnostics
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'

# Configuration
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$scriptDir = $PSScriptRoot

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $scriptDir "logs\$timestamp"
}

# Console colors
function Write-ColorOutput {
    param(
        [string]$Message,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White
    )
    $previousColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $previousColor
}

function Write-Header {
    param([string]$Text)
    Write-ColorOutput "`n================================================" -ForegroundColor Cyan
    Write-ColorOutput $Text -ForegroundColor Cyan
    Write-ColorOutput "================================================`n" -ForegroundColor Cyan
}

function Write-Section {
    param([string]$Text)
    Write-ColorOutput "`n$Text" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Text)
    Write-ColorOutput "  ✓ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-ColorOutput "  ⚠ $Text" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Text)
    Write-ColorOutput "  ✗ $Text" -ForegroundColor Red
}

# Script-level variables
$script:deviceLogJob = $null
$script:captureActive = $false

# Cleanup function
function Invoke-Cleanup {
    Write-Section '🛑 Stopping all diagnostic captures...'

    # Stop device log capture
    if ($script:deviceLogJob) {
        Stop-Job -Job $script:deviceLogJob -ErrorAction SilentlyContinue
        Remove-Job -Job $script:deviceLogJob -ErrorAction SilentlyContinue
        Write-Success 'Stopped device log capture'
    }

    # Capture final VPN profiles
    Save-VPNProfiles -Label 'final'

    # Generate summary
    New-CaptureSummary

    Write-ColorOutput "`n✅ Diagnostic capture complete!" -ForegroundColor Green
    Write-ColorOutput "📂 Output directory: $OutputDirectory`n" -ForegroundColor Blue

    # Open output directory
    if (Test-Path $OutputDirectory) {
        Invoke-Item $OutputDirectory
    }
}

# Capture device info
function Save-DeviceInfo {
    Write-Section '💻 Capturing system information...'

    $infoFile = Join-Path $OutputDirectory 'system_info.txt'

    try {
        @"
============================================
ZCC VPN Diagnostic Capture Session (Windows)
============================================
Timestamp: $(Get-Date)
Session ID: $timestamp

System Information:
===================
Computer Name: $env:COMPUTERNAME
OS: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
OS Version: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Version)
Architecture: $env:PROCESSOR_ARCHITECTURE

PowerShell Version: $($PSVersionTable.PSVersion)

Connected iOS Devices:
======================
"@ | Out-File -FilePath $infoFile -Encoding UTF8

        if (Get-Command idevice_id -ErrorAction SilentlyContinue) {
            $devices = & idevice_id -l 2>$null
            if ($devices) {
                $devices | Out-File -FilePath $infoFile -Encoding UTF8 -Append
            }
            else {
                'No devices detected' | Out-File -FilePath $infoFile -Encoding UTF8 -Append
            }
        }
        else {
            'idevice_id command not available' | Out-File -FilePath $infoFile -Encoding UTF8 -Append
        }

        Write-Success 'System information captured'
    }
    catch {
        Write-Error "Failed to capture system info: $_"
    }
}

# Start device log capture
function Start-DeviceLogCapture {
    Write-Section '📱 Checking for attached iOS devices...'

    if (-not (Get-Command idevicesyslog -ErrorAction SilentlyContinue)) {
        Write-Warning 'idevicesyslog not found'
        Write-Output '     Install libimobiledevice: choco install libimobiledevice'
        Write-Output '     Continuing without device-specific logs...'
        return
    }

    try {
        $logFile = Join-Path $OutputDirectory 'device_logs.txt'

        Write-Success 'Found idevicesyslog, starting device log capture...'

        $script:deviceLogJob = Start-Job -ScriptBlock {
            & idevicesyslog | Out-File -FilePath $using:logFile -Encoding UTF8
        }

        Write-Success "Device log capture started (Job ID: $($script:deviceLogJob.Id))"

    }
    catch {
        Write-Error "Failed to start device log capture: $_"
    }
}

# Capture VPN profiles
function Save-VPNProfiles {
    param(
        [string]$Label = 'manual'
    )

    $captureTime = Get-Date -Format 'HHmmss'

    Write-Section "📋 Capturing device VPN profiles (checkpoint: $Label)..."

    $profileFile = Join-Path $OutputDirectory "vpn_profiles_${Label}_${captureTime}.txt"
    $deviceInfoFile = Join-Path $OutputDirectory "device_info_${Label}_${captureTime}.txt"

    try {
        if (Get-Command ideviceinfo -ErrorAction SilentlyContinue) {
            Write-Output '  📱 Capturing iOS device info via libimobiledevice...'

            & ideviceinfo 2>$null | Out-File -FilePath $deviceInfoFile -Encoding UTF8

            if (Test-Path $deviceInfoFile) {
                Write-Success 'Device info captured'
            }
        }

        if (Get-Command ideviceprovision -ErrorAction SilentlyContinue) {
            & ideviceprovision list 2>$null | Out-File -FilePath $profileFile -Encoding UTF8

            if (Test-Path $profileFile) {
                Write-Success 'iOS provisioning profiles captured'
            }
        }
        else {
            Write-Warning 'ideviceprovision not available'
            @'
iOS Device Profile Capture Failed
==================================
libimobiledevice tools not fully available.

Install with: choco install libimobiledevice
'@ | Out-File -FilePath $profileFile -Encoding UTF8
        }

    }
    catch {
        Write-Error "Failed to capture profiles: $_"
    }
}

# Generate summary
function New-CaptureSummary {
    Write-Section '📝 Generating capture summary...'

    $summaryFile = Join-Path $OutputDirectory 'CAPTURE_SUMMARY.txt'

    try {
        @"
============================================
ZCC VPN Diagnostic Capture Summary (Windows)
============================================
Session ID: $timestamp
Capture End: $(Get-Date)
Output Directory: $OutputDirectory

IMPORTANT - Network Capture Limitation:
========================================
This Windows capture does NOT include network packet data.

RVI (Remote Virtual Interface) is macOS-only and required for:
  ✗ VPN tunnel network traffic capture
  ✗ TLS handshake analysis
  ✗ Certificate chain validation at wire level
  ✗ MTU/fragmentation diagnostics
  ✗ DNS resolution debugging

For complete ZCC VPN network diagnostics:
  → Use macOS with RVI support
  → See: setup.sh and capture_diagnostics.sh in macOS directory

Captured Files:
===============
$(Get-ChildItem -Path $OutputDirectory | Format-Table -AutoSize | Out-String)

File Descriptions:
==================
• device_logs.txt - iPhone/iPad syslog (ZCC client logs)
• vpn_profiles_*.txt - iPhone VPN/MDM profiles at capture points
• device_info_*.txt - iPhone device information
• system_info.txt - Windows PC and connected device information

ZCC VPN Troubleshooting Focus (Device-Side Only):
==================================================
This Windows capture focuses on device-side diagnostics:
  ✓ iPhone ZCC client logs (device_logs.txt)
  ✓ VPN configuration profiles (vpn_profiles_*.txt)
  ✗ Network traffic (not available on Windows)

Analysis Tips:
==============
1. Check device_logs.txt for ZCC client errors and VPN events
2. Compare vpn_profiles_*.txt to verify ZCC configuration
3. Search device_logs.txt for ZCC-specific bundle IDs
4. Look for authentication flows and profile installation events

For Network-Level Analysis:
============================
If you need to diagnose:
  • VPN tunnel establishment failures
  • TLS handshake issues
  • Certificate chain validation
  • MTU/fragmentation problems
  • DNS resolution for ZCC endpoints

You MUST use:
  • macOS computer
  • RVI (Remote Virtual Interface)
  • Wireshark for packet analysis

Windows libimobiledevice cannot provide network-level diagnostics.

"@ | Out-File -FilePath $summaryFile -Encoding UTF8

        Write-Success 'Summary generated'

    }
    catch {
        Write-Error "Failed to generate summary: $_"
    }
}

# Main script
Write-Header 'ZCC VPN Diagnostic Capture (Windows)'

Write-ColorOutput @'
⚠️  IMPORTANT: Network Capture Not Available

Windows does NOT support RVI (Remote Virtual Interface).
This capture will include:
  ✓ iOS device logs (ZCC client)
  ✓ Device VPN profiles
  ✗ Network packet capture (macOS required)

For complete VPN network diagnostics, use macOS.

'@ -ForegroundColor Yellow

$continue = Read-Host 'Continue with device-side capture only? (y/n)'
if ($continue -notmatch '^[Yy]') {
    Write-ColorOutput "`nCapture cancelled. Use macOS for network diagnostics.`n" -ForegroundColor Yellow
    exit 0
}

# Create output directory
try {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    Write-ColorOutput "📁 Created output directory: $OutputDirectory`n" -ForegroundColor Green
}
catch {
    Write-ColorOutput "❌ Failed to create output directory: $OutputDirectory" -ForegroundColor Red
    exit 1
}

# Register cleanup handler
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    if ($script:captureActive) {
        Invoke-Cleanup
    }
}

try {
    # Capture baseline information
    Save-DeviceInfo

    # Start device log capture
    Start-DeviceLogCapture

    # Capture initial VPN profiles
    Save-VPNProfiles -Label 'initial'

    $script:captureActive = $true

    Write-ColorOutput "`n✅ Diagnostic capture is now ACTIVE" -ForegroundColor Green
    Write-Header 'ZCC VPN Troubleshooting Workflow'

    Write-Output @'

  1️⃣  Reproduce the ZCC VPN connection issue
  2️⃣  Attempt to connect/disconnect VPN multiple times
  3️⃣  Note the exact time when errors occur
  4️⃣  Press Ctrl+C when you have captured the issue

'@

    Write-ColorOutput "Press Ctrl+C when capture is complete`n" -ForegroundColor Yellow

    Write-ColorOutput '⚠️  REMINDER: This captures device logs only' -ForegroundColor Yellow
    Write-Output "   For VPN network traffic analysis, use macOS with RVI`n"

    # Wait for user interrupt
    while ($true) {
        Start-Sleep -Seconds 1
    }

}
catch {
    Write-ColorOutput "`nCapture interrupted: $_" -ForegroundColor Red
}
finally {
    if ($script:captureActive) {
        Invoke-Cleanup
    }

    # Unregister event
    Unregister-Event -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue
}

exit 0
