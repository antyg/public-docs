# Create-PKIResourceGroups.ps1
# Creates and configures all required resource groups

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$Location = "australiaeast",

    [Parameter(Mandatory = $true)]
    [string]$Environment = "Production"
)

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Define resource groups
$resourceGroups = @(
    @{
        Name     = "RG-PKI-Core-$Environment"
        Location = $Location
        Tags     = @{
            Environment         = $Environment
            Department          = "Infrastructure"
            CostCenter          = "IT-Security"
            Owner               = "PKI-Team"
            Project             = "PKI-Modernization"
            Compliance          = "PCI-DSS,ISO27001,ACSC-ISM"
            DataClassification  = "Highly Confidential"
            BusinessCriticality = "Mission Critical"
            DR_RPO              = "1 hour"
            DR_RTO              = "4 hours"
        }
    },
    @{
        Name     = "RG-PKI-KeyVault-$Environment"
        Location = $Location
        Tags     = @{
            Environment = $Environment
            Department  = "Infrastructure"
            CostCenter  = "IT-Security"
            Owner       = "PKI-Team"
            Purpose     = "HSM and Key Management"
            Compliance  = "FIPS-140-2-Level3"
        }
    },
    @{
        Name     = "RG-PKI-Network-$Environment"
        Location = $Location
        Tags     = @{
            Environment = $Environment
            Department  = "Infrastructure"
            CostCenter  = "IT-Network"
            Owner       = "Network-Team"
            Purpose     = "PKI Network Infrastructure"
        }
    },
    @{
        Name     = "RG-PKI-Monitor-$Environment"
        Location = $Location
        Tags     = @{
            Environment = $Environment
            Department  = "Infrastructure"
            CostCenter  = "IT-Operations"
            Owner       = "Operations-Team"
            Purpose     = "Monitoring and Logging"
        }
    }
)

# Create resource groups
foreach ($rg in $resourceGroups) {
    Write-Host "Creating Resource Group: $($rg.Name)" -ForegroundColor Green
    New-AzResourceGroup @rg -Force

    # Apply resource locks
    New-AzResourceLock -LockLevel CanNotDelete `
        -LockName "PKI-Protection-Lock" `
        -ResourceGroupName $rg.Name `
        -LockNotes "Protected PKI infrastructure - deletion requires approval"
}

# Create management groups if needed
$mgmtGroup = "MG-PKI-Infrastructure"
if (-not (Get-AzManagementGroup -GroupName $mgmtGroup -ErrorAction SilentlyContinue)) {
    New-AzManagementGroup -GroupName $mgmtGroup `
        -DisplayName "PKI Infrastructure Management Group"
}

Write-Host "Resource groups created successfully!" -ForegroundColor Green
