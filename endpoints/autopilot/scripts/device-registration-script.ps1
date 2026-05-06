<#
.SYNOPSIS
Register devices for Windows Autopilot

.DESCRIPTION
Collects hardware information and registers devices with Windows Autopilot service

.PARAMETER OutputPath
Path to save device registration CSV file

.PARAMETER GroupTag
Optional group tag for device categorization

.EXAMPLE
.\device-registration-script.ps1 -OutputPath "C:\temp\device-info.csv"

.EXAMPLE
.\device-registration-script.ps1 -OutputPath "C:\temp\device-info.csv" -GroupTag "Finance"

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Administrative privileges (for some hardware queries)
Compatible: Windows 10/11, PowerShell 5.1+
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [string]$GroupTag = ""
)

try {
    Write-Output "Collecting Windows Autopilot device registration information..."

    # Install required module if not available
    if (!(Get-Module -ListAvailable -Name WindowsAutopilotIntune)) {
        Write-Output "Installing WindowsAutopilotIntune module..."
        Install-Module -Name WindowsAutopilotIntune -Force -Scope CurrentUser
    }

    # Get computer system information
    $computerSystem = Get-CimInstance -Class Win32_ComputerSystem
    $computerSystemProduct = Get-CimInstance -Class Win32_ComputerSystemProduct
    $bios = Get-CimInstance -Class Win32_BIOS

    # Generate hardware hash (simplified version for compatibility)
    $hwid = ($computerSystemProduct.UUID + $computerSystem.Model + $bios.SerialNumber) -join ""

    # Get Windows Product ID
    $productId = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductId).ProductId

    # Create registration data object
    $deviceInfo = [PSCustomObject]@{
        'Device Serial Number' = $bios.SerialNumber
        'Windows Product ID' = $productId
        'Hardware Hash' = $hwid
        'Manufacturer' = $computerSystem.Manufacturer
        'Model' = $computerSystem.Model
    }

    # Add group tag if specified
    if ($GroupTag) {
        $deviceInfo | Add-Member -MemberType NoteProperty -Name 'Group Tag' -Value $GroupTag
    }

    # Add assigned user if specified
    $deviceInfo | Add-Member -MemberType NoteProperty -Name 'Assigned User' -Value ""

    # Ensure output directory exists
    $outputDir = Split-Path -Path $OutputPath -Parent
    if (!(Test-Path -Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    # Export to CSV
    $deviceInfo | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

    Write-Output ""
    Write-Output "✅ Device registration data collected successfully!"
    Write-Output "📄 Output file: $OutputPath"
    Write-Output ""
    Write-Output "Device Information:"
    Write-Output "  Serial Number: $($bios.SerialNumber)"
    Write-Output "  Manufacturer: $($computerSystem.Manufacturer)"
    Write-Output "  Model: $($computerSystem.Model)"
    Write-Output "  Product ID: $productId"
    if ($GroupTag) {
        Write-Output "  Group Tag: $GroupTag"
    }
    Write-Output ""
    Write-Output "Next Steps:"
    Write-Output "1. Import the CSV file into Microsoft Intune admin center"
    Write-Output "2. Navigate to: Devices > Windows > Windows enrollment > Windows Autopilot > Import"
    Write-Output "3. Wait for device synchronization (up to 15 minutes)"

} catch {
    Write-Error "Failed to collect device registration data: $($_.Exception.Message)"
    exit 1
}