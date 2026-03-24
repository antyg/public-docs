# Configure-PKIRBAC.ps1
# Sets up role-based access control for PKI infrastructure

# Define custom role for PKI Administrators
$pkiAdminRole = @{
    Name             = "PKI Infrastructure Administrator"
    Description      = "Full control over PKI infrastructure resources"
    Actions          = @(
        "Microsoft.KeyVault/*",
        "Microsoft.Compute/virtualMachines/*",
        "Microsoft.Network/*",
        "Microsoft.Storage/*",
        "Microsoft.CertificateRegistration/*",
        "Microsoft.Authorization/*/read",
        "Microsoft.Resources/*",
        "Microsoft.Support/*"
    )
    NotActions       = @(
        "Microsoft.KeyVault/vaults/delete",
        "Microsoft.KeyVault/vaults/purge"
    )
    AssignableScopes = @(
        "/subscriptions/$SubscriptionId/resourceGroups/RG-PKI-Core-$Environment",
        "/subscriptions/$SubscriptionId/resourceGroups/RG-PKI-KeyVault-$Environment"
    )
}

# Create custom role
New-AzRoleDefinition -Role $pkiAdminRole

# Assign roles to security groups
$roleAssignments = @(
    @{
        ObjectId           = (Get-AzADGroup -DisplayName "PKI-Administrators").Id
        RoleDefinitionName = "PKI Infrastructure Administrator"
        ResourceGroupName  = "RG-PKI-Core-$Environment"
    },
    @{
        ObjectId           = (Get-AzADGroup -DisplayName "PKI-Operators").Id
        RoleDefinitionName = "Contributor"
        ResourceGroupName  = "RG-PKI-Core-$Environment"
    },
    @{
        ObjectId           = (Get-AzADGroup -DisplayName "PKI-Auditors").Id
        RoleDefinitionName = "Reader"
        ResourceGroupName  = "RG-PKI-Core-$Environment"
    },
    @{
        ObjectId           = (Get-AzADGroup -DisplayName "Security-Team").Id
        RoleDefinitionName = "Security Admin"
        Scope              = "/subscriptions/$SubscriptionId"
    }
)

foreach ($assignment in $roleAssignments) {
    New-AzRoleAssignment @assignment
}
