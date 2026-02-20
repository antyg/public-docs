#!/usr/bin/env pwsh
#Requires -Version 5.1

<#
.SYNOPSIS
    Setup script for ZCC VPN diagnostic capture on Windows.

.DESCRIPTION
    Verifies prerequisites and prepares environment for Zscaler Client Connector (ZCC)
    VPN troubleshooting via iOS device diagnostics on Windows.

    IMPORTANT LIMITATION:
    - Windows does NOT support RVI (Remote Virtual Interface) for network packet capture
    - Network-level VPN troubleshooting requires macOS with RVI
    - This Windows setup focuses on device-side diagnostics only:
      * iOS device logs via libimobiledevice
      * Device VPN profiles
      * System information

    For complete ZCC VPN diagnostics including network packet capture, use macOS setup.

.PARAMETER InstallDependencies
    Automatically install missing dependencies without prompting.

.EXAMPLE
    .\Setup-ZCCDiagnostics.ps1

.EXAMPLE
    .\Setup-ZCCDiagnostics.ps1 -InstallDependencies

.NOTES
    Version: 1.0.0

    Network Capture Limitation:
    - RVI is macOS-only (requires rvictl command and Apple frameworks)
    - Windows libimobiledevice cannot create virtual network interfaces
    - For VPN tunnel analysis, TLS handshake issues, MTU problems: Use macOS
    - This Windows version captures device logs and profiles only
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$InstallDependencies
)

$ErrorActionPreference = 'Stop'

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

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check for Chocolatey
function Test-Chocolatey {
    return $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
}

# Install Chocolatey
function Install-Chocolatey {
    Write-Section 'Installing Chocolatey package manager...'

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $chocoInstallScript = [System.IO.Path]::GetTempFileName() + '.ps1'
        try {
            Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile $chocoInstallScript -UseBasicParsing
            & $chocoInstallScript
        }
        finally {
            Remove-Item -Path $chocoInstallScript -ErrorAction SilentlyContinue
        }

        # Refresh environment variables
        $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
        Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
        refreshenv

        if (Test-Chocolatey) {
            Write-Success 'Chocolatey installed successfully'
            return $true
        }
        else {
            Write-Error 'Chocolatey installation failed'
            return $false
        }
    }
    catch {
        Write-Error "Failed to install Chocolatey: $_"
        return $false
    }
}

# Check for libimobiledevice
function Test-LibimobileDevice {
    return $null -ne (Get-Command idevice_id -ErrorAction SilentlyContinue)
}

# Install libimobiledevice
function Install-LibimobileDevice {
    Write-Section 'Installing libimobiledevice for iOS device logging...'

    try {
        choco install libimobiledevice -y

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

        if (Test-LibimobileDevice) {
            Write-Success 'libimobiledevice installed successfully'
            return $true
        }
        else {
            Write-Error 'libimobiledevice installation failed'
            Write-Warning 'You may need to restart your terminal and run setup again'
            return $false
        }
    }
    catch {
        Write-Error "Failed to install libimobiledevice: $_"
        return $false
    }
}

# Check for connected iOS devices
function Test-IOSDevice {
    if (-not (Test-LibimobileDevice)) {
        return $null
    }

    try {
        $devices = & idevice_id -l 2>$null
        if ($LASTEXITCODE -eq 0 -and $devices) {
            return $devices
        }
        return $null
    }
    catch {
        return $null
    }
}

# Main setup
Write-Header 'ZCC VPN Diagnostic Capture - Windows Setup'

Write-ColorOutput @'
IMPORTANT: Network Capture Limitation on Windows
================================================

Windows does NOT support RVI (Remote Virtual Interface) for iOS network capture.

What this means:
  ✗ Cannot capture VPN tunnel network traffic
  ✗ Cannot analyze TLS handshake issues at network level
  ✗ Cannot diagnose MTU/fragmentation problems
  ✗ Cannot inspect certificate chain validation at wire level

What Windows CAN capture:
  ✓ iOS device logs (ZCC client behavior)
  ✓ Device VPN profiles (ZCC configuration)
  ✓ Device system information

For complete ZCC VPN diagnostics including network packet capture:
  → Use macOS with RVI support
  → See: setup.sh in the macOS directory

This Windows setup focuses on device-side diagnostics only.

'@ -ForegroundColor Yellow

$continue = Read-Host 'Continue with limited Windows diagnostics? (y/n)'
if ($continue -notmatch '^[Yy]') {
    Write-ColorOutput "`nSetup cancelled. Use macOS for complete VPN diagnostics.`n" -ForegroundColor Yellow
    exit 0
}

# Check Windows version
Write-Section 'Checking system...'
$osVersion = [System.Environment]::OSVersion.Version
Write-Output "  Windows version: $($osVersion.Major).$($osVersion.Minor) (Build $($osVersion.Build))"

if ($osVersion.Major -lt 10) {
    Write-Warning 'Windows 10+ recommended for best compatibility'
}

Write-Output ''

# Check administrator privileges
Write-Section 'Checking administrator privileges...'

if (Test-Administrator) {
    Write-Success 'Running as administrator'
}
else {
    Write-Warning 'Not running as administrator'
    Write-Output '     Some operations may require administrator privileges'
    Write-Output "     Right-click and 'Run as Administrator' for full functionality"
}

Write-Output ''

# Check/Install Chocolatey
Write-Section 'Checking for Chocolatey package manager...'

$chocoAvailable = Test-Chocolatey

if ($chocoAvailable) {
    Write-Success 'Chocolatey installed'
}
else {
    Write-Warning 'Chocolatey not found'
    Write-Output ''
    Write-Output '  Chocolatey is required to install libimobiledevice for device logging.'

    if ($InstallDependencies) {
        $installChoco = $true
    }
    else {
        $response = Read-Host '  Install Chocolatey now? (y/n)'
        $installChoco = $response -match '^[Yy]'
    }

    if ($installChoco) {
        if (-not (Test-Administrator)) {
            Write-Error 'Administrator privileges required to install Chocolatey'
            Write-Output '     Please run this script as Administrator'
            exit 1
        }

        $chocoAvailable = Install-Chocolatey
    }
    else {
        Write-Output '  Skipped Chocolatey installation'
    }
}

Write-Output ''

# Check/Install libimobiledevice
Write-Section 'Checking iOS device logging tools...'

$libimobileAvailable = Test-LibimobileDevice

if ($libimobileAvailable) {
    Write-Success 'libimobiledevice installed'
}
else {
    Write-Warning 'libimobiledevice not found'

    if ($chocoAvailable) {
        Write-Output ''
        Write-Output '  Installing libimobiledevice automatically...'

        if (-not (Test-Administrator)) {
            Write-Error 'Administrator privileges required to install packages'
            Write-Output '     Please run this script as Administrator'
            exit 1
        }

        $libimobileAvailable = Install-LibimobileDevice
    }
    else {
        Write-Output ''
        Write-Warning 'Cannot install libimobiledevice without Chocolatey'
        Write-Output '     Options:'
        Write-Output '       • Install Chocolatey: https://chocolatey.org/install'
        Write-Output '       • Then run: choco install libimobiledevice'
    }
}

if (-not $libimobileAvailable) {
    Write-Output ''
    Write-ColorOutput '  ⚠️  No device log capture tools available' -ForegroundColor Yellow
    Write-Output '     Device logs will be missing from capture'
}

Write-Output ''

# Check for connected iOS devices
Write-Section 'Checking for connected iOS devices...'

$devices = Test-IOSDevice

if ($devices) {
    Write-Success 'Device(s) detected:'
    $devices | ForEach-Object {
        Write-Output "      $_"
    }
    $deviceFound = $true
}
else {
    Write-Warning 'No devices detected'
    Write-Output '     • Connect iPhone via USB'
    Write-Output '     • Unlock the iPhone'
    Write-Output '     • Trust this computer when prompted'
    Write-Output '     • Install iTunes or Apple Devices app for drivers'
    $deviceFound = $false
}

Write-Output ''

# Explain RVI limitation
Write-Section 'Network capture capability (RVI)...'

Write-ColorOutput '  ✗ RVI not available on Windows' -ForegroundColor Red
Write-Output ''
Write-Output '  RVI (Remote Virtual Interface) is macOS-only:'
Write-Output '    • Requires macOS rvictl command'
Write-Output '    • Requires Apple CoreDevice frameworks'
Write-Output '    • Not supported by libimobiledevice on Windows'
Write-Output ''
Write-Output '  For ZCC VPN network diagnostics, you need:'
Write-Output '    • macOS computer'
Write-Output '    • Run setup.sh and capture_diagnostics.sh from macOS directory'

Write-Output ''

# Check for capture script
Write-Section 'Setting up scripts...'

$captureScript = Join-Path $PSScriptRoot 'Invoke-ZCCDiagnosticCapture.ps1'

if (Test-Path $captureScript) {
    Write-Success 'Invoke-ZCCDiagnosticCapture.ps1 found'
}
else {
    Write-Error 'Invoke-ZCCDiagnosticCapture.ps1 not found'
}

Write-Output ''

# Check disk space
Write-Section 'Checking disk space...'

$drive = (Get-Location).Drive
$freeSpaceGB = [math]::Round(($drive.Free / 1GB), 2)

Write-Output "  Available space: $freeSpaceGB GB"

if ($freeSpaceGB -lt 2) {
    Write-Error 'Low disk space! Need at least 2GB for diagnostic capture'
    Write-Output '     Device logs can be large (100MB-1GB)'
}
else {
    Write-Success 'Sufficient disk space'
}

Write-Output ''

# Summary
Write-Header 'Setup Summary'

$ready = $true

Write-Output 'Device Logging:'
if ($libimobileAvailable) {
    Write-Success 'libimobiledevice available'
}
else {
    Write-Error 'No device logging tools available'
    $ready = $false
}

Write-Output ''
Write-Output 'Network Capture:'
Write-ColorOutput '  ✗ RVI not supported on Windows (macOS required)' -ForegroundColor Red

Write-Output ''
Write-Output 'Connected Devices:'
if ($deviceFound) {
    Write-Success 'iPhone detected'
}
else {
    Write-Warning 'No devices detected - connect before capture'
}

Write-Output ''

if ($ready) {
    Write-ColorOutput '✅ Ready to capture device-side ZCC diagnostics!' -ForegroundColor Green
    Write-Output ''
    Write-Output 'Next steps:'
    Write-Output '  1. Ensure ZCC is installed on iPhone'
    Write-Output '  2. Run: .\Invoke-ZCCDiagnosticCapture.ps1'
    Write-Output '  3. Reproduce ZCC VPN connection issue'
    Write-Output '  4. Press Ctrl+C when complete'
    Write-Output ''
    Write-ColorOutput '⚠ REMINDER: For network-level VPN diagnostics, use macOS' -ForegroundColor Yellow
    Write-Output ''
}
else {
    Write-ColorOutput '⚠️  Setup incomplete' -ForegroundColor Yellow
    Write-Output ''
    Write-Output 'Missing components will prevent diagnostic capture.'

    if (-not (Test-Administrator)) {
        Write-Output ''
        Write-Output 'Try running this script as Administrator to install dependencies.'
    }
}

Write-Output ''

exit 0
