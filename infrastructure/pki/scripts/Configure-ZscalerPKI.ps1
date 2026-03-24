# Configure-ZscalerPKI.ps1
# Integrates Zscaler with enterprise PKI for SSL inspection

param(
    [string]$ZscalerAPIUrl = "https://admin.zscalertwo.net/api/v1",
    [string]$APIKey = $env:ZSCALER_API_KEY,
    [string]$Username = "admin@company.com.au",
    [string]$Password = $env:ZSCALER_PASSWORD
)

# Authenticate to Zscaler API
function Get-ZscalerAuthToken {
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $authPayload = @{
        apiKey    = $APIKey
        username  = $Username
        password  = $Password
        timestamp = $timestamp
    }

    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/authenticatedSession" `
        -Method Post `
        -Body ($authPayload | ConvertTo-Json) `
        -ContentType "application/json"

    return $response.token
}

$token = Get-ZscalerAuthToken

# Upload Root CA certificate to Zscaler
function Upload-RootCAToZscaler {
    param(
        [string]$CertificatePath = "C:\PKI\Certificates\RootCA-G2.crt"
    )

    $certContent = Get-Content $CertificatePath -Raw
    $certBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($certContent))

    $uploadPayload = @{
        name            = "Company Root CA G2"
        description     = "Company enterprise root certificate authority"
        certificate     = $certBase64
        certificateType = "ROOT_CA"
        trustLevel      = "TRUSTED"
    }

    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/certificates" `
        -Method Post `
        -Headers @{
        "auth-token"   = $token
        "Content-Type" = "application/json"
    } `
        -Body ($uploadPayload | ConvertTo-Json)

    Write-Host "Root CA uploaded to Zscaler: $($response.id)" -ForegroundColor Green
    return $response.id
}

# Configure SSL inspection policy
function Configure-SSLInspectionPolicy {
    $policyConfig = @{
        enableSslInspection        = $true
        excludedCategories         = @(
            "BANKING_AND_FINANCE",
            "HEALTH"
        )
        excludedDomains            = @(
            "*.company.local",
            "*.company-internal.com"
        )
        certificateChainValidation = @{
            enabled            = $true
            trustInternalCAs   = $true
            validateRevocation = $true
            ocspValidation     = $true
            crlValidation      = $true
        }
        customCertificates         = @{
            useInternalCA = $true
            internalCAId  = Upload-RootCAToZscaler
        }
    }

    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/inspectionPolicy" `
        -Method Put `
        -Headers @{
        "auth-token"   = $token
        "Content-Type" = "application/json"
    } `
        -Body ($policyConfig | ConvertTo-Json -Depth 10)

    Write-Host "SSL inspection policy configured" -ForegroundColor Green
}

# Create certificate validation rules
function Create-CertificateValidationRules {
    $rules = @(
        @{
            name        = "Validate Internal Certificates"
            description = "Ensure internal certificates are from Company CA"
            ruleOrder   = 1
            action      = "ALLOW"
            state       = "ENABLED"
            conditions  = @(
                @{
                    type     = "CERTIFICATE_ISSUER"
                    operator = "CONTAINS"
                    value    = "Company Issuing CA"
                }
            )
        },
        @{
            name        = "Block Untrusted Certificates"
            description = "Block connections with untrusted certificates"
            ruleOrder   = 2
            action      = "BLOCK"
            state       = "ENABLED"
            conditions  = @(
                @{
                    type     = "CERTIFICATE_VALIDATION"
                    operator = "EQUALS"
                    value    = "UNTRUSTED"
                }
            )
        },
        @{
            name        = "Warn Expired Certificates"
            description = "Warn users about expired certificates"
            ruleOrder   = 3
            action      = "WARN"
            state       = "ENABLED"
            conditions  = @(
                @{
                    type     = "CERTIFICATE_EXPIRY"
                    operator = "EXPIRED"
                    value    = "true"
                }
            )
        }
    )

    foreach ($rule in $rules) {
        $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/validationRules" `
            -Method Post `
            -Headers @{
            "auth-token"   = $token
            "Content-Type" = "application/json"
        } `
            -Body ($rule | ConvertTo-Json -Depth 10)

        Write-Host "Created rule: $($rule.name)" -ForegroundColor Green
    }
}

# Configure certificate-based authentication
function Configure-CertificateAuthentication {
    $authConfig = @{
        enableClientCertAuth = $true
        clientCertValidation = @{
            validateChain      = $true
            validateExpiry     = $true
            validateRevocation = $true
            trustedIssuers     = @("Company Issuing CA 01", "Company Issuing CA 02")
        }
        certificateMapping   = @{
            usernameField = "CN"
            domainField   = "O"
            emailField    = "emailAddress"
        }
        authenticationPolicy = @{
            requireClientCert  = $false
            fallbackToPassword = $true
            cacheDuration      = 480  # 8 hours
        }
    }

    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/authentication/clientCertificate" `
        -Method Put `
        -Headers @{
        "auth-token"   = $token
        "Content-Type" = "application/json"
    } `
        -Body ($authConfig | ConvertTo-Json -Depth 10)

    Write-Host "Certificate authentication configured" -ForegroundColor Green
}

# Main execution
Configure-SSLInspectionPolicy
Create-CertificateValidationRules
Configure-CertificateAuthentication

Write-Host "Zscaler PKI integration complete!" -ForegroundColor Green
