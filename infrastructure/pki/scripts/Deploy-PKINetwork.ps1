# Deploy-PKINetwork.ps1
# Deploys the complete PKI network infrastructure

param(
    [string]$ResourceGroup = "RG-PKI-Network-Production",
    [string]$Location = "australiaeast"
)

# Main Virtual Network
$vnet = @{
    Name                 = "VNET-PKI-PROD"
    ResourceGroupName    = $ResourceGroup
    Location             = $Location
    AddressPrefix        = "10.50.0.0/16"
    DnsServer            = @("10.10.10.10", "10.10.10.11", "168.63.129.16")
    EnableDdosProtection = $true
    EnableVmProtection   = $true
}

$virtualNetwork = New-AzVirtualNetwork @vnet

# Subnet Configuration
$subnets = @(
    @{
        Name                 = "PKI-Core"
        AddressPrefix        = "10.50.1.0/24"
        NetworkSecurityGroup = "NSG-PKI-Core"
        ServiceEndpoints     = @("Microsoft.KeyVault", "Microsoft.Storage")
    },
    @{
        Name                 = "PKI-HSM"
        AddressPrefix        = "10.50.2.0/24"
        NetworkSecurityGroup = "NSG-PKI-HSM"
        ServiceEndpoints     = @("Microsoft.KeyVault")
        Delegations          = @("Microsoft.HardwareSecurityModules/dedicatedHSMs")
    },
    @{
        Name                 = "PKI-Management"
        AddressPrefix        = "10.50.3.0/24"
        NetworkSecurityGroup = "NSG-PKI-Management"
        ServiceEndpoints     = @("Microsoft.Storage", "Microsoft.Sql")
    },
    @{
        Name                 = "PKI-Services"
        AddressPrefix        = "10.50.4.0/24"
        NetworkSecurityGroup = "NSG-PKI-Services"
    },
    @{
        Name                 = "PKI-Web"
        AddressPrefix        = "10.50.5.0/24"
        NetworkSecurityGroup = "NSG-PKI-Web"
    },
    @{
        Name          = "AzureBastionSubnet"
        AddressPrefix = "10.50.250.0/24"
    },
    @{
        Name          = "AzureFirewallSubnet"
        AddressPrefix = "10.50.254.0/24"
    },
    @{
        Name          = "GatewaySubnet"
        AddressPrefix = "10.50.255.0/24"
    }
)

foreach ($subnet in $subnets) {
    # Create NSG if specified
    if ($subnet.NetworkSecurityGroup) {
        $nsg = New-AzNetworkSecurityGroup `
            -Name $subnet.NetworkSecurityGroup `
            -ResourceGroupName $ResourceGroup `
            -Location $Location
    }

    # Add subnet to VNet
    Add-AzVirtualNetworkSubnetConfig `
        -Name $subnet.Name `
        -AddressPrefix $subnet.AddressPrefix `
        -VirtualNetwork $virtualNetwork `
        -NetworkSecurityGroup $nsg `
        -ServiceEndpoint $subnet.ServiceEndpoints
}

# Update VNet with subnets
$virtualNetwork | Set-AzVirtualNetwork
