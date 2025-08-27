<#
.SYNOPSIS
Bulk assign Autopilot deployment profiles

.DESCRIPTION
Assigns specified Autopilot profile to multiple device groups using Microsoft Graph

.PARAMETER ProfileName
Name of the Autopilot deployment profile

.PARAMETER GroupNames
Array of group names to assign the profile to

.PARAMETER TenantId
Optional tenant ID for specific tenant connection

.EXAMPLE
.\profile-assignment.ps1 -ProfileName "Corporate Standard Profile" -GroupNames @("Autopilot-Finance","Autopilot-HR")

.EXAMPLE
.\profile-assignment.ps1 -ProfileName "Kiosk Profile" -GroupNames @("Autopilot-Kiosks") -TenantId "your-tenant-id"

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Microsoft Graph PowerShell SDK
Scopes: DeviceManagementServiceConfig.ReadWrite.All
Compatible: PowerShell 5.1+
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProfileName,

    [Parameter(Mandatory=$true)]
    [string[]]$GroupNames,

    [Parameter(Mandatory=$false)]
    [string]$TenantId
)

# Function to test Microsoft Graph connectivity
function Test-GraphConnection {
    try {
        $context = Get-MgContext
        if ($context) {
            Write-Output "Connected to Microsoft Graph as: $($context.Account)"
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

try {
    # Check if Microsoft Graph module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Output "Microsoft Graph PowerShell SDK not found. Installing..."
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
    }

    # Connect to Microsoft Graph
    if (!(Test-GraphConnection)) {
        Write-Output "Connecting to Microsoft Graph..."
        if ($TenantId) {
            Connect-MgGraph -TenantId $TenantId -Scopes "DeviceManagementServiceConfig.ReadWrite.All", "Group.Read.All"
        } else {
            Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All", "Group.Read.All"
        }
    }

    # Get the deployment profile
    Write-Output "Searching for Autopilot profile: $ProfileName"
    $profile = Get-MgDeviceManagementWindowsAutopilotDeploymentProfile -Filter "displayName eq '$ProfileName'"

    if (!$profile) {
        Write-Error "Profile '$ProfileName' not found. Available profiles:"
        $availableProfiles = Get-MgDeviceManagementWindowsAutopilotDeploymentProfile
        foreach ($p in $availableProfiles) {
            Write-Output "  - $($p.DisplayName)"
        }
        exit 1
    }

    Write-Output "Found profile: $($profile.DisplayName) (ID: $($profile.Id))"

    # Process each group
    $successCount = 0
    $failureCount = 0

    foreach ($groupName in $GroupNames) {
        try {
            Write-Output "Processing group: $groupName"
            
            # Get the group
            $group = Get-MgGroup -Filter "displayName eq '$groupName'"

            if ($group) {
                Write-Output "  Found group: $($group.DisplayName) (ID: $($group.Id))"
                
                # Check if assignment already exists
                $existingAssignments = Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $profile.Id
                $alreadyAssigned = $existingAssignments | Where-Object { $_.Target.GroupId -eq $group.Id }

                if ($alreadyAssigned) {
                    Write-Warning "  Profile already assigned to group '$groupName'"
                    continue
                }

                # Create assignment
                $assignment = @{
                    target = @{
                        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                        groupId = $group.Id
                    }
                }

                New-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $profile.Id -BodyParameter $assignment
                Write-Output "  ✅ Successfully assigned profile '$ProfileName' to group '$groupName'"
                $successCount++
            } else {
                Write-Warning "  ❌ Group '$groupName' not found"
                $failureCount++
            }
        } catch {
            Write-Error "  ❌ Failed to assign profile to group '$groupName': $($_.Exception.Message)"
            $failureCount++
        }
    }

    # Summary
    Write-Output ""
    Write-Output "Profile Assignment Summary:"
    Write-Output "  Profile: $ProfileName"
    Write-Output "  Successful assignments: $successCount"
    Write-Output "  Failed assignments: $failureCount"
    Write-Output "  Total groups processed: $($GroupNames.Count)"

    if ($failureCount -eq 0) {
        Write-Output "  🎉 All profile assignments completed successfully!"
    }

} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
} finally {
    # Disconnect from Microsoft Graph (optional)
    # Disconnect-MgGraph
}