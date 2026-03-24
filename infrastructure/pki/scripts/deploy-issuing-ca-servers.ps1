# Deploy-IssuingCAServers.ps1
# Deploys Windows Server 2022 VMs for Issuing CAs

param(
    [string]$ResourceGroup = "RG-PKI-Core-Production",
    [string]$Location = "australiaeast",
    [string]$VNetName = "VNET-PKI-PROD",
    [string]$SubnetName = "PKI-Core"
)

# VM Configuration
$vmConfigs = @(
    @{
        Name             = "PKI-ICA-01"
        Size             = "Standard_D4s_v5"
        IP               = "10.50.1.10"
        Role             = "Primary Issuing CA"
        AvailabilityZone = "1"
    },
    @{
        Name             = "PKI-ICA-02"
        Size             = "Standard_D4s_v5"
        IP               = "10.50.1.11"
        Role             = "Secondary Issuing CA"
        AvailabilityZone = "2"
    },
    @{
        Name             = "PKI-NDES-01"
        Size             = "Standard_D2s_v5"
        IP               = "10.50.1.20"
        Role             = "NDES/SCEP Server"
        AvailabilityZone = "1"
    },
    @{
        Name             = "PKI-OCSP-01"
        Size             = "Standard_D2s_v5"
        IP               = "10.50.1.30"
        Role             = "OCSP Responder Primary"
        AvailabilityZone = "1"
    },
    @{
        Name             = "PKI-OCSP-02"
        Size             = "Standard_D2s_v5"
        IP               = "10.50.1.31"
        Role             = "OCSP Responder Secondary"
        AvailabilityZone = "2"
    }
)

# Get subnet reference
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName "RG-PKI-Network-Production"
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

# Create availability set
$availSet = New-AzAvailabilitySet `
    -ResourceGroupName $ResourceGroup `
    -Name "AS-PKI-CAs" `
    -Location $Location `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 5 `
    -Sku "Aligned"

foreach ($vmConfig in $vmConfigs) {
    Write-Host "Deploying VM: $($vmConfig.Name)" -ForegroundColor Green

    # Create public IP (for management only - will be removed later)
    $pip = New-AzPublicIpAddress `
        -Name "$($vmConfig.Name)-PIP" `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -AllocationMethod Static `
        -Sku Standard `
        -Zone $vmConfig.AvailabilityZone

    # Create NIC with static IP
    $nic = New-AzNetworkInterface `
        -Name "$($vmConfig.Name)-NIC" `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $pip.Id `
        -PrivateIpAddress $vmConfig.IP `
        -EnableAcceleratedNetworking

    # VM credential
    $cred = Get-Credential -Message "Enter credentials for $($vmConfig.Name)"

    # Create VM configuration
    $vm = New-AzVMConfig `
        -VMName $vmConfig.Name `
        -VMSize $vmConfig.Size `
        -AvailabilitySetId $availSet.Id

    $vm = Set-AzVMOperatingSystem `
        -VM $vm `
        -Windows `
        -ComputerName $vmConfig.Name `
        -Credential $cred `
        -EnableAutoUpdate `
        -ProvisionVMAgent

    $vm = Add-AzVMNetworkInterface `
        -VM $vm `
        -Id $nic.Id

    $vm = Set-AzVMSourceImage `
        -VM $vm `
        -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" `
        -Skus "2022-datacenter-g2" `
        -Version "latest"

    # OS Disk configuration
    $vm = Set-AzVMOSDisk `
        -VM $vm `
        -Name "$($vmConfig.Name)-OSDisk" `
        -CreateOption FromImage `
        -StorageAccountType "Premium_LRS" `
        -DiskSizeInGB 128

    # Data Disk for CA database
    $dataDiskConfig = New-AzDiskConfig `
        -Location $Location `
        -CreateOption Empty `
        -DiskSizeGB 256 `
        -AccountType Premium_LRS `
        -Zone $vmConfig.AvailabilityZone

    $dataDisk = New-AzDisk `
        -ResourceGroupName $ResourceGroup `
        -DiskName "$($vmConfig.Name)-DataDisk" `
        -Disk $dataDiskConfig

    $vm = Add-AzVMDataDisk `
        -VM $vm `
        -Name "$($vmConfig.Name)-DataDisk" `
        -CreateOption Attach `
        -ManagedDiskId $dataDisk.Id `
        -Lun 0

    # Boot diagnostics
    $vm = Set-AzVMBootDiagnostic `
        -VM $vm `
        -Enable `
        -ResourceGroupName $ResourceGroup `
        -StorageAccountName "pkidiagnosticstorage"

    # Create the VM
    New-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -VM $vm `
        -AsJob

    # Apply tags
    $tags = @{
        Name         = $vmConfig.Name
        Role         = $vmConfig.Role
        Environment  = "Production"
        Department   = "Infrastructure"
        CostCenter   = "IT-Security"
        BackupPolicy = "Daily"
        PatchGroup   = "PKI-Servers"
        Monitoring   = "Enabled"
        Compliance   = "PCI-DSS,ISO27001"
    }

    Set-AzResource `
        -ResourceId "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$($vmConfig.Name)" `
        -Tag $tags `
        -Force
}

Write-Host "All VMs deployment initiated. Check job status for completion." -ForegroundColor Yellow

# Wait for all jobs to complete
Get-Job | Wait-Job
Get-Job | Receive-Job
