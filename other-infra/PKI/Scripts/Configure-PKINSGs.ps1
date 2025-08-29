# Configure-PKINSGs.ps1
# Configures detailed NSG rules for PKI infrastructure

function New-PKINSGRules {
    param(
        [string]$NSGName,
        [string]$ResourceGroup
    )

    $nsg = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroup

    # Define security rules based on NSG type
    switch ($NSGName) {
        "NSG-PKI-Core" {
            $rules = @(
                @{
                    Name                     = "Allow-HTTPS-Inbound"
                    Priority                 = 100
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "443"
                    SourceAddressPrefix      = "10.20.0.0/16"
                    DestinationAddressPrefix = "10.50.1.0/24"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Allow-RPC-Management"
                    Priority                 = 110
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "135,445"
                    SourceAddressPrefix      = "10.50.3.0/24"
                    DestinationAddressPrefix = "10.50.1.0/24"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Allow-CRL-HTTP"
                    Priority                 = 120
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "80"
                    SourceAddressPrefix      = "Internet"
                    DestinationAddressPrefix = "10.50.1.30/32"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Allow-OCSP-HTTP"
                    Priority                 = 130
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "80"
                    SourceAddressPrefix      = "Internet"
                    DestinationAddressPrefix = "10.50.1.31/32"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Allow-Azure-LoadBalancer"
                    Priority                 = 140
                    Direction                = "Inbound"
                    Protocol                 = "*"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "*"
                    SourceAddressPrefix      = "AzureLoadBalancer"
                    DestinationAddressPrefix = "*"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Deny-All-Inbound"
                    Priority                 = 4096
                    Direction                = "Inbound"
                    Protocol                 = "*"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "*"
                    SourceAddressPrefix      = "*"
                    DestinationAddressPrefix = "*"
                    Access                   = "Deny"
                }
            )
        }
        "NSG-PKI-HSM" {
            $rules = @(
                @{
                    Name                     = "Allow-HSM-Management"
                    Priority                 = 100
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "5000-5010"
                    SourceAddressPrefix      = "10.50.3.0/24"
                    DestinationAddressPrefix = "10.50.2.0/24"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Allow-KeyVault-Integration"
                    Priority                 = 110
                    Direction                = "Inbound"
                    Protocol                 = "TCP"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "443"
                    SourceAddressPrefix      = "AzureKeyVault"
                    DestinationAddressPrefix = "10.50.2.0/24"
                    Access                   = "Allow"
                },
                @{
                    Name                     = "Deny-All-Inbound"
                    Priority                 = 4096
                    Direction                = "Inbound"
                    Protocol                 = "*"
                    SourcePortRange          = "*"
                    DestinationPortRange     = "*"
                    SourceAddressPrefix      = "*"
                    DestinationAddressPrefix = "*"
                    Access                   = "Deny"
                }
            )
        }
    }

    # Apply rules to NSG
    foreach ($rule in $rules) {
        $nsg | Add-AzNetworkSecurityRuleConfig @rule
    }

    # Update NSG
    $nsg | Set-AzNetworkSecurityGroup
}

# Apply rules to all NSGs
$nsgs = @("NSG-PKI-Core", "NSG-PKI-HSM", "NSG-PKI-Management", "NSG-PKI-Services", "NSG-PKI-Web")
foreach ($nsgName in $nsgs) {
    New-PKINSGRules -NSGName $nsgName -ResourceGroup "RG-PKI-Network-Production"
}
