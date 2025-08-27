<#
.SYNOPSIS
Bulk assign Autopilot deployment profiles

.DESCRIPTION
Assigns specified Autopilot profile to multiple device groups using Microsoft Graph API

.PARAMETER ProfileName
Name of the Autopilot deployment profile

.PARAMETER GroupNames
Array of group names to assign the profile to

.EXAMPLE
.\bulk-profile-assignment.ps1 -ProfileName "Corporate Standard Profile" -GroupNames @("Finance Devices", "HR Devices")

.EXAMPLE
.\bulk-profile-assignment.ps1 -ProfileName "Kiosk Profile" -GroupNames @("Kiosk Devices")

.NOTES
Version: 1.0.0
Created: 2025-08-27
Requires: Microsoft.Graph PowerShell modules, appropriate Graph permissions
Compatible: Windows 10/11, PowerShell 5.1+
Required Scopes: DeviceManagementServiceConfig.ReadWrite.All
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProfileName,

    [Parameter(Mandatory=$true)]
    [string[]]$GroupNames
)

try {
    Write-Output "Bulk Autopilot Profile Assignment Tool"
    Write-Output "====================================="
    Write-Output "Profile: $ProfileName"
    Write-Output "Groups: $($GroupNames -join ', ')"
    Write-Output ""

    # Check if Microsoft Graph module is available
    if (!(Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
        Write-Output "Installing Microsoft Graph DeviceManagement module..."
        Install-Module -Name Microsoft.Graph.DeviceManagement -Force -Scope CurrentUser
    }

    if (!(Get-Module -ListAvailable -Name Microsoft.Graph.Groups)) {
        Write-Output "Installing Microsoft Graph Groups module..."
        Install-Module -Name Microsoft.Graph.Groups -Force -Scope CurrentUser
    }

    # Connect to Microsoft Graph
    Write-Output "Connecting to Microsoft Graph..."
    Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All", "Group.Read.All" -NoWelcome

    # Verify connection
    $context = Get-MgContext
    if (!$context) {
        throw "Failed to connect to Microsoft Graph"
    }
    
    Write-Output "Connected to tenant: $($context.TenantId)"
    Write-Output ""

    # Get the deployment profile
    Write-Output "Looking up Autopilot deployment profile..."
    $profile = Get-MgDeviceManagementWindowsAutopilotDeploymentProfile -Filter "displayName eq '$ProfileName'"

    if (!$profile) {
        throw "Profile '$ProfileName' not found. Please verify the profile name and try again."
    }

    Write-Output "✅ Found profile: $($profile.DisplayName) (ID: $($profile.Id))"
    Write-Output ""

    $assignmentResults = @()

    foreach ($groupName in $GroupNames) {
        Write-Output "Processing group: $groupName"
        
        try {
            # Get the group
            $group = Get-MgGroup -Filter "displayName eq '$groupName'"

            if ($group) {
                # Check if assignment already exists
                $existingAssignment = Get-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $profile.Id | 
                    Where-Object { $_.Target.AdditionalProperties.groupId -eq $group.Id }

                if ($existingAssignment) {
                    Write-Output "  ⚠️  Profile already assigned to this group - skipping"
                    $assignmentResults += [PSCustomObject]@{
                        GroupName = $groupName
                        GroupId = $group.Id
                        Status = "Already Assigned"
                        Error = $null
                    }
                } else {
                    # Create assignment
                    $assignment = @{
                        target = @{
                            "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                            groupId = $group.Id
                        }
                    }

                    New-MgDeviceManagementWindowsAutopilotDeploymentProfileAssignment -WindowsAutopilotDeploymentProfileId $profile.Id -BodyParameter $assignment | Out-Null
                    Write-Output "  ✅ Successfully assigned profile to group"
                    
                    $assignmentResults += [PSCustomObject]@{
                        GroupName = $groupName
                        GroupId = $group.Id
                        Status = "Success"
                        Error = $null
                    }
                }
            } else {
                Write-Output "  ❌ Group '$groupName' not found"
                $assignmentResults += [PSCustomObject]@{
                    GroupName = $groupName
                    GroupId = $null
                    Status = "Group Not Found"
                    Error = "Group does not exist"
                }
            }
        } catch {
            Write-Output "  ❌ Failed to assign profile: $($_.Exception.Message)"
            $assignmentResults += [PSCustomObject]@{
                GroupName = $groupName
                GroupId = $group.Id
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
        
        Write-Output ""
    }

    # Summary report
    Write-Output "📊 ASSIGNMENT SUMMARY"
    Write-Output "===================="
    Write-Output "Profile: $ProfileName"
    Write-Output "Total Groups Processed: $($GroupNames.Count)"
    
    $successful = ($assignmentResults | Where-Object { $_.Status -eq "Success" }).Count
    $alreadyAssigned = ($assignmentResults | Where-Object { $_.Status -eq "Already Assigned" }).Count
    $failed = ($assignmentResults | Where-Object { $_.Status -in @("Failed", "Group Not Found") }).Count
    
    Write-Output "Successful Assignments: $successful"
    Write-Output "Already Assigned: $alreadyAssigned" 
    Write-Output "Failed: $failed"
    Write-Output ""

    if ($failed -gt 0) {
        Write-Output "❌ FAILED ASSIGNMENTS:"
        $assignmentResults | Where-Object { $_.Status -in @("Failed", "Group Not Found") } | 
            ForEach-Object { Write-Output "  • $($_.GroupName): $($_.Error)" }
        Write-Output ""
    }

    if ($successful -gt 0 -or $alreadyAssigned -gt 0) {
        Write-Output "🎉 Profile assignment completed!"
        Write-Output ""
        Write-Output "Next Steps:"
        Write-Output "1. Verify assignments in Intune admin center"
        Write-Output "2. Monitor device enrollment for affected groups"
        Write-Output "3. Allow up to 24 hours for policy synchronization"
    }

} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
} finally {
    # Disconnect from Microsoft Graph
    if (Get-MgContext) {
        Disconnect-MgGraph | Out-Null
        Write-Output "Disconnected from Microsoft Graph"
    }
}