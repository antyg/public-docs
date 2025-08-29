# Deploy-PKLCDN.ps1
# Configures Azure CDN for global CRL/AIA distribution

# Create CDN profile
$cdnProfile = New-AzCdnProfile `
    -ProfileName "CDN-PKI-Australia" `
    -ResourceGroupName "RG-PKI-Core-Production" `
    -Location "global" `
    -Sku "Standard_Microsoft"

# Create CDN endpoints
$endpoints = @(
    @{
        Name           = "crl-company"
        OriginHostName = "pkicrlstorageaus.blob.core.windows.net"
        OriginPath     = "/crl"
        CustomDomain   = "crl.company.com.au"
    },
    @{
        Name           = "aia-company"
        OriginHostName = "pkicrlstorageaus.blob.core.windows.net"
        OriginPath     = "/aia"
        CustomDomain   = "aia.company.com.au"
    },
    @{
        Name           = "ocsp-company"
        OriginHostName = "pki-ocsp.australiaeast.cloudapp.azure.com"
        CustomDomain   = "ocsp.company.com.au"
    }
)

foreach ($endpoint in $endpoints) {
    $cdnEndpoint = New-AzCdnEndpoint `
        -ProfileName $cdnProfile.Name `
        -ResourceGroupName "RG-PKI-Core-Production" `
        -EndpointName $endpoint.Name `
        -OriginHostName $endpoint.OriginHostName `
        -OriginPath $endpoint.OriginPath `
        -ContentTypesToCompress @("application/octet-stream", "application/pkix-crl") `
        -IsCompressionEnabled $true `
        -IsHttpAllowed $true `
        -IsHttpsAllowed $true `
        -QueryStringCachingBehavior "IgnoreQueryString" `
        -OptimizationType "GeneralWebDelivery"

    # Configure caching rules
    $cachingRules = @(
        @{
            Name       = "CRLCaching"
            Order      = 1
            Conditions = @{
                RequestUri = @{
                    Operator        = "EndsWith"
                    NegateCondition = $false
                    MatchValues     = @(".crl")
                }
            }
            Actions    = @{
                CacheExpiration = @{
                    CacheBehavior = "Override"
                    CacheDuration = "04:00:00"  # 4 hours
                }
            }
        }
    )

    Set-AzCdnEndpointRule -EndpointName $endpoint.Name @cachingRules

    # Add custom domain (requires DNS CNAME verification)
    if ($endpoint.CustomDomain) {
        New-AzCdnCustomDomain `
            -EndpointName $endpoint.Name `
            -ProfileName $cdnProfile.Name `
            -ResourceGroupName "RG-PKI-Core-Production" `
            -CustomDomainName $endpoint.CustomDomain.Replace(".", "-") `
            -HostName $endpoint.CustomDomain
    }
}

Write-Host "CDN configuration complete!" -ForegroundColor Green
