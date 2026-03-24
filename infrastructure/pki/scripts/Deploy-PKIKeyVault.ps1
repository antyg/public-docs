# Deploy-PKIKeyVault.ps1
# Deploys and configures Azure Key Vault with HSM protection

param(
    [string]$KeyVaultName = "KV-PKI-RootCA-Prod",
    [string]$ResourceGroup = "RG-PKI-KeyVault-Production",
    [string]$Location = "australiaeast"
)

# Create Premium Key Vault
$keyVault = New-AzKeyVault `
    -Name $KeyVaultName `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Sku "Premium" `
    -EnabledForDeployment `
    -EnabledForDiskEncryption `
    -EnabledForTemplateDeployment `
    -EnablePurgeProtection `
    -EnableRbacAuthorization `
    -SoftDeleteRetentionInDays 90 `
    -PublicNetworkAccess "Disabled"

# Configure network rules
$networkRules = @{
    DefaultAction       = "Deny"
    Bypass              = "AzureServices"
    IpRules             = @(
        @{IpAddressRange = "203.10.20.0/24" } # Office IP range
    )
    VirtualNetworkRules = @(
        @{
            VirtualNetworkResourceId = "/subscriptions/$subId/resourceGroups/RG-PKI-Network-Production/providers/Microsoft.Network/virtualNetworks/VNET-PKI-PROD/subnets/PKI-Core"
        }
    )
}

Update-AzKeyVaultNetworkRuleSet -VaultName $KeyVaultName @networkRules

# Create private endpoint
$privateEndpoint = @{
    Name                         = "PE-KeyVault-PKI"
    ResourceGroupName            = $ResourceGroup
    Location                     = $Location
    Subnet                       = Get-AzVirtualNetworkSubnetConfig -Name "PKI-Core" -VirtualNetwork $vnet
    PrivateLinkServiceConnection = New-AzPrivateLinkServiceConnection `
        -Name "PLC-KeyVault-PKI" `
        -PrivateLinkServiceId $keyVault.ResourceId `
        -GroupId "vault"
}

New-AzPrivateEndpoint @privateEndpoint

# Configure diagnostic settings
$diagnosticSetting = @{
    ResourceId       = $keyVault.ResourceId
    Name             = "KeyVault-Diagnostics"
    WorkspaceId      = "/subscriptions/$subId/resourceGroups/RG-PKI-Monitor-Production/providers/Microsoft.OperationalInsights/workspaces/LAW-PKI-Monitor"
    LogCategory      = @("AuditEvent", "AzurePolicyEvaluationDetails")
    MetricCategory   = @("AllMetrics")
    Enabled          = $true
    RetentionEnabled = $true
    RetentionInDays  = 365
}

Set-AzDiagnosticSetting @diagnosticSetting

Write-Host "Key Vault deployed successfully!" -ForegroundColor Green
