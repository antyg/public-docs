<#
.SYNOPSIS
Register devices for Windows Autopilot

.DESCRIPTION
Collects hardware information and registers devices with Windows Autopilot service
Compatible with PowerShell 5.1+ and Windows 10/11

.PARAMETER OutputPath
Path to save device registration CSV file

.PARAMETER GroupTag
Optional group tag for device categorization

.PARAMETER UseOfficialScript
Use the official Microsoft Get-WindowsAutoPilotInfo script (recommended)

.EXAMPLE
.\hardware-hash-collection.ps1 -OutputPath "C:\temp\devices.csv" -GroupTag "corporate"

.EXAMPLE
.\hardware-hash-collection.ps1 -OutputPath "C:\temp\devices.csv" -UseOfficialScript

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Administrative privileges
Compatible: Windows 10/11, PowerShell 5.1+
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [string]$GroupTag = "",

    [Parameter(Mandatory=$false)]
    [switch]$UseOfficialScript
)

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires administrative privileges. Please run PowerShell as Administrator."
    exit 1
}

try {
    if ($UseOfficialScript) {
        Write-Output "Using official Microsoft Get-WindowsAutoPilotInfo script..."
        
        # Install the official script if not present
        if (!(Get-InstalledScript -Name "Get-WindowsAutoPilotInfo" -ErrorAction SilentlyContinue)) {
            Write-Output "Installing Get-WindowsAutoPilotInfo script..."
            Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope CurrentUser
        }
        
        # Execute with parameters
        if ($GroupTag) {
            Get-WindowsAutoPilotInfo.ps1 -OutputFile $OutputPath -GroupTag $GroupTag
        } else {
            Get-WindowsAutoPilotInfo.ps1 -OutputFile $OutputPath
        }
    } 
    else {
        Write-Output "Using custom hardware hash collection method..."
        
        # Install required module
        if (!(Get-Module -ListAvailable -Name WindowsAutopilotIntune)) {
            Write-Output "Installing WindowsAutopilotIntune module..."
            Install-Module -Name WindowsAutopilotIntune -Force -Scope CurrentUser
        }

        # Get hardware information
        $serialNumber = (Get-CimInstance -Class Win32_BIOS).SerialNumber
        $model = (Get-CimInstance -Class Win32_ComputerSystem).Model
        $manufacturer = (Get-CimInstance -Class Win32_ComputerSystem).Manufacturer
        $uuid = (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID
        
        # Get Windows Product ID
        $productId = try {
            (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductId).ProductId
        } catch {
            "Not Available"
        }

        # Generate hardware hash (simplified version)
        $hwid = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($uuid + $model + $serialNumber)))

        # Create device registration data
        $deviceInfo = [PSCustomObject]@{
            'Device Serial Number' = $serialNumber
            'Windows Product ID' = $productId
            'Hardware Hash' = $hwid
            'Manufacturer' = $manufacturer
            'Model' = $model
        }

        # Add group tag if specified
        if ($GroupTag) {
            $deviceInfo | Add-Member -MemberType NoteProperty -Name 'Group Tag' -Value $GroupTag
        }

        # Add assigned user column for manual entry
        $deviceInfo | Add-Member -MemberType NoteProperty -Name 'Assigned User' -Value ""

        # Export to CSV
        $deviceInfo | Export-Csv -Path $OutputPath -NoTypeInformation
        
        Write-Output "Device Information Collected:"
        Write-Output "  Serial Number: $serialNumber"
        Write-Output "  Model: $model"
        Write-Output "  Manufacturer: $manufacturer"
    }

    Write-Output "Device registration data exported to: $OutputPath"
    Write-Output "Ready for import to Microsoft Intune admin center:"
    Write-Output "  Devices > Windows > Windows enrollment > Windows Autopilot > Devices > Import"

} catch {
    Write-Error "Failed to collect hardware information: $($_.Exception.Message)"
    exit 1
}