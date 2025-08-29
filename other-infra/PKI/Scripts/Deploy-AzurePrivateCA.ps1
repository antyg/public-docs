# Deploy-AzurePrivateCA.ps1
# Deploys Azure Private CA as Root Certificate Authority

param(
    [string]$CAName = "Company-Root-CA-G2",
    [string]$ResourceGroup = "RG-PKI-Core-Production",
    [string]$KeyVaultName = "KV-PKI-RootCA-Prod"
)

# Create CA configuration
$caConfig = @{
    Subject                 = @{
        CommonName         = "Company Australia Root CA G2"
        Organization       = "Company Australia Pty Ltd"
        OrganizationalUnit = "Information Security"
        Locality           = "Sydney"
        State              = "New South Wales"
        Country            = "AU"
    }

    KeySpecification        = @{
        KeyType            = "RSA"
        KeySize            = 4096
        SignatureAlgorithm = "SHA384withRSA"
        KeyStorageProvider = "AzureKeyVault"
        KeyVaultId         = (Get-AzKeyVault -VaultName $KeyVaultName).ResourceId
        KeyName            = "RootCA-SigningKey-2025"
    }

    Validity                = @{
        ValidityInYears = 20
        ValidityType    = "Years"
    }

    Extensions              = @{
        BasicConstraints           = @{
            Critical             = $true
            CertificateAuthority = $true
            PathLengthConstraint = 2
        }
        KeyUsage                   = @{
            Critical         = $true
            DigitalSignature = $false
            NonRepudiation   = $false
            KeyEncipherment  = $false
            DataEncipherment = $false
            KeyAgreement     = $false
            KeyCertSign      = $true
            CRLSign          = $true
        }
        SubjectKeyIdentifier       = @{
            Critical              = $false
            GenerateFromPublicKey = $true
        }
        AuthorityKeyIdentifier     = @{
            Critical      = $false
            KeyIdentifier = $true
            IssuerName    = $false
            SerialNumber  = $false
        }
        CRLDistributionPoints      = @{
            Critical = $false
            URI      = @(
                "http://crl.company.com.au/root-g2.crl",
                "ldap://directory.company.com.au/CN=Company%20Root%20CA%20G2,OU=PKI,O=Company,C=AU?certificateRevocationList"
            )
        }
        AuthorityInformationAccess = @{
            Critical  = $false
            CAIssuers = @("http://aia.company.com.au/root-g2.crt")
            OCSP      = @("http://ocsp.company.com.au/root")
        }
        CertificatePolicies        = @{
            Critical = $false
            Policies = @(
                @{
                    PolicyIdentifier = "1.3.6.1.4.1.company.1.1"
                    PolicyQualifiers = @(
                        @{
                            Type  = "CPS"
                            Value = "https://pki.company.com.au/cps"
                        }
                    )
                }
            )
        }
    }

    CAType                  = "Root"

    RevocationConfiguration = @{
        CRLConfiguration  = @{
            Enabled           = $true
            ExpirationInHours = 720  # 30 days
            OverlapInHours    = 48      # 2 days
            DeltaCRLEnabled   = $false
        }
        OCSPConfiguration = @{
            Enabled   = $true
            ServerUrl = "http://ocsp.company.com.au"
        }
    }
}

# Deploy Azure Private CA (Note: This is a conceptual representation)
# Actual deployment would use ARM templates or Azure REST API
$rootCA = New-AzPrivateCertificateAuthority `
    -Name $CAName `
    -ResourceGroupName $ResourceGroup `
    -Location "australiaeast" `
    -Configuration $caConfig `
    -Tier "Premium"

# Wait for CA to be ready
$timeout = 300
$timer = 0
while ($rootCA.ProvisioningState -ne "Succeeded" -and $timer -lt $timeout) {
    Start-Sleep -Seconds 10
    $timer += 10
    $rootCA = Get-AzPrivateCertificateAuthority -Name $CAName -ResourceGroupName $ResourceGroup
}

if ($rootCA.ProvisioningState -eq "Succeeded") {
    Write-Host "Root CA deployed successfully!" -ForegroundColor Green

    # Export root certificate
    $rootCert = Export-AzPrivateCACertificate `
        -CAName $CAName `
        -ResourceGroupName $ResourceGroup `
        -OutputFile "C:\PKI\Certificates\RootCA-G2.crt"

    Write-Host "Root certificate exported to C:\PKI\Certificates\RootCA-G2.crt" -ForegroundColor Yellow
} else {
    throw "Root CA deployment failed!"
}
