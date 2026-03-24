#requires -version 5.1
#requires -modules Az.Accounts, Az.Resources, Az.Sql, Az.Storage, Az.Aks, Az.Network, Az.KeyVault, AWSPowerShell.NetCore

<#
.SYNOPSIS
    Comprehensive infrastructure discovery for Microsoft Defender for Cloud deployment planning.

.DESCRIPTION
    This script performs automated discovery of Azure and AWS infrastructure to support
    Defender for Cloud deployment planning. It inventories virtual machines, databases,
    storage accounts, Kubernetes clusters, and other resources across cloud environments.

.PARAMETER TenantId
    Azure AD tenant ID for authentication

.PARAMETER SubscriptionIds
    Array of Azure subscription IDs to scan

.PARAMETER AWSProfileName
    AWS credential profile name (default: 'default')

.PARAMETER OutputPath
    Directory path for exported results (default: current directory)

.PARAMETER IncludeTagAnalysis
    Include detailed tag analysis for resource classification

.EXAMPLE
    .\Invoke-InfrastructureDiscovery.ps1 -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionIds @("sub1", "sub2")

.EXAMPLE
    .\Invoke-InfrastructureDiscovery.ps1 -TenantId $TenantId -SubscriptionIds $Subs -AWSProfileName "statedot" -IncludeTagAnalysis

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: PowerShell 5.1+, Az PowerShell modules, AWS PowerShell modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string[]]$SubscriptionIds,

    [Parameter(Mandatory = $false)]
    [string]$AWSProfileName = "default",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeTagAnalysis
)

# Set error action preference
$ErrorActionPreference = 'Continue'

# Connect to Azure
try {
    Connect-AzAccount -TenantId $TenantId -ErrorAction Stop
    Write-Host "Successfully connected to Azure tenant: $TenantId" -ForegroundColor Green
} catch {
    Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
    exit 1
}

# Initialize discovery results
$discoveryResults = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    TenantId = $TenantId
    Azure = @{}
    AWS = @{}
    Summary = @{}
    TagAnalysis = @{}
}

function Get-AzureResourceInventory {
    param([string]$SubscriptionId)
    
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    $subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
    
    Write-Host "Discovering resources in subscription: $($subscription.Name)" -ForegroundColor Cyan
    
    $inventory = @{
        SubscriptionName = $subscription.Name
        SubscriptionId = $SubscriptionId
        VirtualMachines = @()
        SqlServers = @()
        StorageAccounts = @()
        KubernetesClusters = @()
        NetworkSecurityGroups = @()
        KeyVaults = @()
        AppServices = @()
        ContainerRegistries = @()
    }
    
    # Virtual Machines
    try {
        $vms = Get-AzVM
        foreach ($vm in $vms) {
            $vmStatus = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
            $powerState = ($vmStatus.Statuses | Where-Object {$_.Code -like "PowerState/*"}).DisplayStatus
            
            $vmDetail = @{
                Name = $vm.Name
                ResourceGroup = $vm.ResourceGroupName
                Location = $vm.Location
                Size = $vm.HardwareProfile.VmSize
                OSType = $vm.StorageProfile.OsDisk.OsType
                PowerState = $powerState
                Tags = $vm.Tags ?? @{}
                ProvisioningState = $vm.ProvisioningState
            }
            $inventory.VirtualMachines += $vmDetail
        }
        Write-Host "  Found $($vms.Count) virtual machines" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering virtual machines: $($_.Exception.Message)"
    }
    
    # SQL Servers
    try {
        $sqlServers = Get-AzSqlServer
        foreach ($server in $sqlServers) {
            $databases = Get-AzSqlDatabase -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName | Where-Object {$_.DatabaseName -ne "master"}
            
            $serverDetail = @{
                Name = $server.ServerName
                ResourceGroup = $server.ResourceGroupName
                Location = $server.Location
                Version = $server.ServerVersion
                DatabaseCount = $databases.Count
                Databases = $databases | Select-Object DatabaseName, Edition, ServiceObjectiveName
                Tags = $server.Tags ?? @{}
            }
            $inventory.SqlServers += $serverDetail
        }
        Write-Host "  Found $($sqlServers.Count) SQL servers" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering SQL servers: $($_.Exception.Message)"
    }
    
    # Storage Accounts
    try {
        $storageAccounts = Get-AzStorageAccount
        foreach ($storage in $storageAccounts) {
            $storageDetail = @{
                Name = $storage.StorageAccountName
                ResourceGroup = $storage.ResourceGroupName
                Location = $storage.Location
                Tier = $storage.Sku.Tier
                Kind = $storage.Kind
                EnableHttpsTrafficOnly = $storage.EnableHttpsTrafficOnly
                AllowBlobPublicAccess = $storage.AllowBlobPublicAccess
                Tags = $storage.Tags ?? @{}
            }
            $inventory.StorageAccounts += $storageDetail
        }
        Write-Host "  Found $($storageAccounts.Count) storage accounts" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering storage accounts: $($_.Exception.Message)"
    }
    
    # AKS Clusters
    try {
        $aksClusters = Get-AzAksCluster
        foreach ($cluster in $aksClusters) {
            $clusterDetail = @{
                Name = $cluster.Name
                ResourceGroup = $cluster.ResourceGroupName
                Location = $cluster.Location
                NodeCount = $cluster.DefaultNodePool.Count
                KubernetesVersion = $cluster.KubernetesVersion
                PowerState = $cluster.PowerState.Code
                Tags = $cluster.Tags ?? @{}
            }
            $inventory.KubernetesClusters += $clusterDetail
        }
        Write-Host "  Found $($aksClusters.Count) AKS clusters" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering AKS clusters: $($_.Exception.Message)"
    }
    
    # Network Security Groups
    try {
        $nsgs = Get-AzNetworkSecurityGroup
        foreach ($nsg in $nsgs) {
            $nsgDetail = @{
                Name = $nsg.Name
                ResourceGroup = $nsg.ResourceGroupName
                Location = $nsg.Location
                SecurityRulesCount = $nsg.SecurityRules.Count
                DefaultSecurityRulesCount = $nsg.DefaultSecurityRules.Count
                Tags = $nsg.Tags ?? @{}
            }
            $inventory.NetworkSecurityGroups += $nsgDetail
        }
        Write-Host "  Found $($nsgs.Count) network security groups" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering network security groups: $($_.Exception.Message)"
    }
    
    # Key Vaults
    try {
        $keyVaults = Get-AzKeyVault
        foreach ($vault in $keyVaults) {
            $vaultDetail = @{
                VaultName = $vault.VaultName
                ResourceGroup = $vault.ResourceGroupName
                Location = $vault.Location
                EnabledForDiskEncryption = $vault.EnabledForDiskEncryption
                EnablePurgeProtection = $vault.EnablePurgeProtection
                SoftDeleteEnabled = $vault.EnableSoftDelete
                Tags = $vault.Tags ?? @{}
            }
            $inventory.KeyVaults += $vaultDetail
        }
        Write-Host "  Found $($keyVaults.Count) key vaults" -ForegroundColor White
    } catch {
        Write-Warning "Error discovering key vaults: $($_.Exception.Message)"
    }
    
    return $inventory
}

function Get-AWSResourceInventory {
    param([string]$ProfileName)
    
    try {
        if (-not (Get-AWSCredential -ProfileName $ProfileName -ErrorAction SilentlyContinue)) {
            Write-Warning "AWS profile '$ProfileName' not found or not configured"
            return @{ Error = "AWS credentials not configured or accessible" }
        }
        
        Write-Host "Discovering AWS resources using profile: $ProfileName" -ForegroundColor Cyan
        Set-AWSCredential -ProfileName $ProfileName
        
        $inventory = @{
            ProfileName = $ProfileName
            EC2Instances = @()
            RDSInstances = @()
            S3Buckets = @()
            EKSClusters = @()
            SecurityGroups = @()
        }
        
        # EC2 Instances
        try {
            $ec2Instances = Get-EC2Instance
            foreach ($reservation in $ec2Instances) {
                foreach ($instance in $reservation.Instances) {
                    $tags = @{}
                    $instance.Tags | ForEach-Object { $tags[$_.Key] = $_.Value }
                    
                    $instanceDetail = @{
                        InstanceId = $instance.InstanceId
                        InstanceType = $instance.InstanceType
                        State = $instance.State.Name
                        Platform = $instance.Platform ?? "Linux"
                        AvailabilityZone = $instance.Placement.AvailabilityZone
                        LaunchTime = $instance.LaunchTime
                        Tags = $tags
                    }
                    $inventory.EC2Instances += $instanceDetail
                }
            }
            Write-Host "  Found $($inventory.EC2Instances.Count) EC2 instances" -ForegroundColor White
        } catch {
            Write-Warning "Error discovering EC2 instances: $($_.Exception.Message)"
        }
        
        # RDS Instances
        try {
            $rdsInstances = Get-RDSDBInstance
            foreach ($instance in $rdsInstances) {
                $rdsDetail = @{
                    DBInstanceIdentifier = $instance.DBInstanceIdentifier
                    DBInstanceClass = $instance.DBInstanceClass
                    Engine = $instance.Engine
                    EngineVersion = $instance.EngineVersion
                    DBInstanceStatus = $instance.DBInstanceStatus
                    AvailabilityZone = $instance.AvailabilityZone
                    MultiAZ = $instance.MultiAZ
                }
                $inventory.RDSInstances += $rdsDetail
            }
            Write-Host "  Found $($rdsInstances.Count) RDS instances" -ForegroundColor White
        } catch {
            Write-Warning "Error discovering RDS instances: $($_.Exception.Message)"
        }
        
        # S3 Buckets
        try {
            $s3Buckets = Get-S3Bucket
            foreach ($bucket in $s3Buckets) {
                $bucketDetail = @{
                    BucketName = $bucket.BucketName
                    CreationDate = $bucket.CreationDate
                    Region = (Get-S3BucketLocation -BucketName $bucket.BucketName).Value
                }
                $inventory.S3Buckets += $bucketDetail
            }
            Write-Host "  Found $($s3Buckets.Count) S3 buckets" -ForegroundColor White
        } catch {
            Write-Warning "Error discovering S3 buckets: $($_.Exception.Message)"
        }
        
        return $inventory
    } catch {
        Write-Warning "AWS discovery failed: $($_.Exception.Message)"
        return @{ Error = "AWS discovery failed: $($_.Exception.Message)" }
    }
}

function Get-TagAnalysis {
    param([hashtable]$DiscoveryResults)
    
    if (-not $IncludeTagAnalysis) {
        return @{}
    }
    
    Write-Host "Analyzing resource tags..." -ForegroundColor Cyan
    
    $tagAnalysis = @{
        CommonTags = @{}
        MissingTags = @()
        TagCoverage = @{}
        Recommendations = @()
    }
    
    $allResources = @()
    
    # Collect all Azure resources
    foreach ($subscription in $DiscoveryResults.Azure.Values) {
        $allResources += $subscription.VirtualMachines + $subscription.SqlServers + $subscription.StorageAccounts + $subscription.KubernetesClusters + $subscription.KeyVaults
    }
    
    # Analyze tag patterns
    $allTags = @{}
    foreach ($resource in $allResources) {
        if ($resource.Tags) {
            foreach ($tagKey in $resource.Tags.Keys) {
                if (-not $allTags.ContainsKey($tagKey)) {
                    $allTags[$tagKey] = 0
                }
                $allTags[$tagKey]++
            }
        }
    }
    
    $tagAnalysis.CommonTags = $allTags
    
    # Identify resources missing critical tags
    $criticalTags = @("Environment", "Owner", "CostCenter", "BusinessCriticality")
    foreach ($resource in $allResources) {
        $missingTags = @()
        foreach ($tag in $criticalTags) {
            if (-not $resource.Tags.ContainsKey($tag)) {
                $missingTags += $tag
            }
        }
        if ($missingTags.Count -gt 0) {
            $tagAnalysis.MissingTags += @{
                ResourceName = $resource.Name
                MissingTags = $missingTags
            }
        }
    }
    
    # Calculate tag coverage
    $totalResources = $allResources.Count
    $resourcesWithTags = ($allResources | Where-Object {$_.Tags.Count -gt 0}).Count
    $tagAnalysis.TagCoverage = @{
        TotalResources = $totalResources
        ResourcesWithTags = $resourcesWithTags
        CoveragePercentage = if ($totalResources -gt 0) { [math]::Round(($resourcesWithTags / $totalResources) * 100, 2) } else { 0 }
    }
    
    # Generate recommendations
    if ($tagAnalysis.TagCoverage.CoveragePercentage -lt 80) {
        $tagAnalysis.Recommendations += "Improve tag coverage - currently at $($tagAnalysis.TagCoverage.CoveragePercentage)%"
    }
    if ($tagAnalysis.MissingTags.Count -gt 0) {
        $tagAnalysis.Recommendations += "Apply critical tags to $($tagAnalysis.MissingTags.Count) resources"
    }
    
    return $tagAnalysis
}

# Azure Discovery
foreach ($subscriptionId in $SubscriptionIds) {
    try {
        $azureInventory = Get-AzureResourceInventory -SubscriptionId $subscriptionId
        $discoveryResults.Azure[$subscriptionId] = $azureInventory
    } catch {
        Write-Error "Failed to discover resources in subscription $subscriptionId : $($_.Exception.Message)"
    }
}

# AWS Discovery
$discoveryResults.AWS = Get-AWSResourceInventory -ProfileName $AWSProfileName

# Tag Analysis
$discoveryResults.TagAnalysis = Get-TagAnalysis -DiscoveryResults $discoveryResults

# Generate Summary
$discoveryResults.Summary = @{
    TotalAzureVMs = ($discoveryResults.Azure.Values.VirtualMachines | Measure-Object).Count
    TotalAzureSQLServers = ($discoveryResults.Azure.Values.SqlServers | Measure-Object).Count
    TotalStorageAccounts = ($discoveryResults.Azure.Values.StorageAccounts | Measure-Object).Count
    TotalAKSClusters = ($discoveryResults.Azure.Values.KubernetesClusters | Measure-Object).Count
    TotalKeyVaults = ($discoveryResults.Azure.Values.KeyVaults | Measure-Object).Count
    TotalAWSEC2Instances = if ($discoveryResults.AWS.EC2Instances) { $discoveryResults.AWS.EC2Instances.Count } else { 0 }
    TotalAWSRDSInstances = if ($discoveryResults.AWS.RDSInstances) { $discoveryResults.AWS.RDSInstances.Count } else { 0 }
    TotalS3Buckets = if ($discoveryResults.AWS.S3Buckets) { $discoveryResults.AWS.S3Buckets.Count } else { 0 }
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outputFile = Join-Path $OutputPath "InfrastructureDiscovery-$timestamp.json"
$csvSummaryFile = Join-Path $OutputPath "DiscoverySummary-$timestamp.csv"

try {
    $discoveryResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host "Discovery results exported to: $outputFile" -ForegroundColor Green
    
    # Export CSV summary
    $csvData = @()
    foreach ($subId in $discoveryResults.Azure.Keys) {
        $sub = $discoveryResults.Azure[$subId]
        $csvData += [PSCustomObject]@{
            SubscriptionId = $subId
            SubscriptionName = $sub.SubscriptionName
            VirtualMachines = $sub.VirtualMachines.Count
            SqlServers = $sub.SqlServers.Count
            StorageAccounts = $sub.StorageAccounts.Count
            AKSClusters = $sub.KubernetesClusters.Count
            KeyVaults = $sub.KeyVaults.Count
        }
    }
    $csvData | Export-Csv -Path $csvSummaryFile -NoTypeInformation -Encoding UTF8
    Write-Host "Summary exported to: $csvSummaryFile" -ForegroundColor Green
} catch {
    Write-Error "Failed to export results: $($_.Exception.Message)"
}

# Display summary
Write-Host "`nInfrastructure Discovery Summary:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "Azure Resources:" -ForegroundColor Cyan
Write-Host "  Virtual Machines: $($discoveryResults.Summary.TotalAzureVMs)" -ForegroundColor White
Write-Host "  SQL Servers: $($discoveryResults.Summary.TotalAzureSQLServers)" -ForegroundColor White
Write-Host "  Storage Accounts: $($discoveryResults.Summary.TotalStorageAccounts)" -ForegroundColor White
Write-Host "  AKS Clusters: $($discoveryResults.Summary.TotalAKSClusters)" -ForegroundColor White
Write-Host "  Key Vaults: $($discoveryResults.Summary.TotalKeyVaults)" -ForegroundColor White

Write-Host "AWS Resources:" -ForegroundColor Cyan
Write-Host "  EC2 Instances: $($discoveryResults.Summary.TotalAWSEC2Instances)" -ForegroundColor White
Write-Host "  RDS Instances: $($discoveryResults.Summary.TotalAWSRDSInstances)" -ForegroundColor White
Write-Host "  S3 Buckets: $($discoveryResults.Summary.TotalS3Buckets)" -ForegroundColor White

if ($IncludeTagAnalysis -and $discoveryResults.TagAnalysis.TagCoverage) {
    Write-Host "Tag Analysis:" -ForegroundColor Cyan
    Write-Host "  Tag Coverage: $($discoveryResults.TagAnalysis.TagCoverage.CoveragePercentage)%" -ForegroundColor White
    Write-Host "  Resources Missing Tags: $($discoveryResults.TagAnalysis.MissingTags.Count)" -ForegroundColor White
}

Write-Host "`nDiscovery completed successfully!" -ForegroundColor Green

return $discoveryResults