# Deploy-PKIConnectivity.ps1
# Configures ExpressRoute and backup VPN connectivity

# ExpressRoute Circuit
$circuit = New-AzExpressRouteCircuit `
    -Name "ER-PKI-Sydney-Primary" `
    -ResourceGroupName "RG-PKI-Network-Production" `
    -Location "australiaeast" `
    -ServiceProviderName "Telstra" `
    -PeeringLocation "Sydney" `
    -BandwidthInMbps 200 `
    -SkuTier "Standard" `
    -SkuFamily "MeteredData"

# ExpressRoute Gateway
$gwSubnet = Get-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -VirtualNetwork $virtualNetwork

$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
    -Name "ERGatewayIP" `
    -SubnetId $gwSubnet.Id `
    -PublicIpAddressId $gwpip.Id

$erGateway = New-AzVirtualNetworkGateway `
    -Name "GW-PKI-ExpressRoute" `
    -ResourceGroupName "RG-PKI-Network-Production" `
    -Location "australiaeast" `
    -IpConfigurations $gwipconfig `
    -GatewayType "ExpressRoute" `
    -GatewaySku "Standard" `
    -AsJob

# VPN Gateway (Backup)
$vpnGateway = New-AzVirtualNetworkGateway `
    -Name "GW-PKI-VPN-Backup" `
    -ResourceGroupName "RG-PKI-Network-Production" `
    -Location "australiaeast" `
    -IpConfigurations $vpnipconfig `
    -GatewayType "Vpn" `
    -VpnType "RouteBased" `
    -EnableBgp $true `
    -GatewaySku "VpnGw2" `
    -VpnGatewayGeneration "Generation2" `
    -AsJob

# Configure BGP
$bgpSettings = @{
    Asn               = 65001
    BgpPeeringAddress = "10.50.255.254"
    PeerWeight        = 0
}

Set-AzVirtualNetworkGateway -VirtualNetworkGateway $vpnGateway -BgpSettings $bgpSettings
