# Deploy-CRLStorage.ps1
# Sets up Azure Storage for CRL and AIA distribution

# Create storage account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName "RG-PKI-Core-Production" `
    -Name "pkicrlstorageaus" `
    -Location "australiaeast" `
    -SkuName "Standard_GRS" `
    -Kind "StorageV2" `
    -AccessTier "Hot" `
    -EnableHttpsTrafficOnly $true `
    -MinimumTlsVersion "TLS1_2" `
    -AllowBlobPublicAccess $true `
    -Tag @{
    Purpose      = "CRL and AIA Distribution"
    PublicAccess = "Required"
}

# Get storage context
$ctx = $storageAccount.Context

# Create containers
$containers = @(
    @{Name = "crl"; PublicAccess = "Blob" },
    @{Name = "aia"; PublicAccess = "Blob" },
    @{Name = "cps"; PublicAccess = "Blob" }
)

foreach ($container in $containers) {
    New-AzStorageContainer `
        -Name $container.Name `
        -Context $ctx `
        -Permission $container.PublicAccess
}

# Configure CORS for web access
$corsRules = @{
    AllowedOrigins  = @("*")
    AllowedMethods  = @("GET", "HEAD", "OPTIONS")
    AllowedHeaders  = @("*")
    ExposedHeaders  = @("*")
    MaxAgeInSeconds = 3600
}

Set-AzStorageCORSRule `
    -ServiceType Blob `
    -Context $ctx `
    -CorsRules @($corsRules)

# Enable storage analytics
Set-AzStorageServiceLoggingProperty `
    -ServiceType Blob `
    -LoggingOperations All `
    -Context $ctx `
    -RetentionDays 365 `
    -Version 2.0

Set-AzStorageServiceMetricsProperty `
    -ServiceType Blob `
    -MetricsType Hour `
    -Context $ctx `
    -MetricsLevel ServiceAndApi `
    -RetentionDays 30

Write-Host "Storage account configured for CRL distribution" -ForegroundColor Green
