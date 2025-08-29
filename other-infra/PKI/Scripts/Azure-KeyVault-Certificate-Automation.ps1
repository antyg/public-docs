# Azure Key Vault Certificate Automation
# Manage-AzureKeyVaultCertificates.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [int]$RenewalThresholdDays = 30
)

# Connect to Azure
Connect-AzAccount -Identity

# Function to create certificate policy
function New-CertificatePolicy {
    param(
        [string]$SubjectName,
        [string[]]$DnsNames,
        [int]$ValidityInMonths = 12
    )
    
    $policy = New-AzKeyVaultCertificatePolicy `
        -SubjectName "CN=$SubjectName, O=Company, C=AU" `
        -DnsNames $DnsNames `
        -IssuerName "Company-Issuing-CA" `
        -ValidityInMonths $ValidityInMonths `
        -RenewAtPercentageLifetime 80 `
        -KeyType RSA `
        -KeySize 2048 `
        -SecretContentType "application/x-pkcs12" `
        -ReuseKeyOnRenewal $false
    
    return $policy
}

# Function to request new certificate
function Request-NewCertificate {
    param(
        [string]$CertificateName,
        [string]$CommonName,
        [string[]]$SANs
    )
    
    $policy = New-CertificatePolicy -SubjectName $CommonName -DnsNames $SANs
    
    $cert = Add-AzKeyVaultCertificate `
        -VaultName $KeyVaultName `
        -Name $CertificateName `
        -CertificatePolicy $policy
    
    # Wait for certificate to be issued
    $operation = Get-AzKeyVaultCertificateOperation `
        -VaultName $KeyVaultName `
        -Name $CertificateName
    
    while ($operation.Status -eq "inProgress") {
        Start-Sleep -Seconds 10
        $operation = Get-AzKeyVaultCertificateOperation `
            -VaultName $KeyVaultName `
            -Name $CertificateName
    }
    
    if ($operation.Status -eq "completed") {
        Write-Host "Certificate $CertificateName issued successfully"
        return $cert
    } else {
        throw "Certificate issuance failed: $($operation.ErrorMessage)"
    }
}

# Function to check and renew certificates
function Check-CertificateRenewal {
    $certificates = Get-AzKeyVaultCertificate -VaultName $KeyVaultName
    
    foreach ($cert in $certificates) {
        $certDetails = Get-AzKeyVaultCertificate `
            -VaultName $KeyVaultName `
            -Name $cert.Name `
            -IncludeVersions
        
        $latestVersion = $certDetails | Sort-Object Created -Descending | Select-Object -First 1
        $expiryDate = $latestVersion.Attributes.Expires
        $daysUntilExpiry = ($expiryDate - (Get-Date)).Days
        
        if ($daysUntilExpiry -le $RenewalThresholdDays) {
            Write-Host "Certificate $($cert.Name) expires in $daysUntilExpiry days. Renewing..."
            
            # Trigger renewal
            $renewalOperation = Add-AzKeyVaultCertificate `
                -VaultName $KeyVaultName `
                -Name $cert.Name `
                -RenewCertificate
            
            # Log renewal
            $logEntry = @{
                Timestamp = Get-Date
                Certificate = $cert.Name
                Action = "Renewal Initiated"
                DaysUntilExpiry = $daysUntilExpiry
                OperationId = $renewalOperation.Id
            }
            
            Write-Output $logEntry | ConvertTo-Json
        }
    }
}

# Function to bind certificate to App Service
function Update-AppServiceCertificate {
    param(
        [string]$AppServiceName,
        [string]$CertificateName
    )
    
    # Get certificate from Key Vault
    $certificate = Get-AzKeyVaultCertificate `
        -VaultName $KeyVaultName `
        -Name $CertificateName
    
    # Import to App Service
    $appServiceCert = New-AzWebAppSSLBinding `
        -ResourceGroupName $ResourceGroup `
        -WebAppName $AppServiceName `
        -CertificateFilePath $certificate.SecretId `
        -CertificatePassword $null `
        -SslState "SniEnabled"
    
    Write-Host "Certificate bound to App Service $AppServiceName"
}

# Main execution
try {
    # Check for certificates needing renewal
    Check-CertificateRenewal
    
    # Example: Request new certificate
    # Request-NewCertificate -CertificateName "webapp-cert" `
    #     -CommonName "webapp.company.com.au" `
    #     -SANs @("webapp.company.com.au", "www.webapp.company.com.au")
    
    # Example: Update App Service binding
    # Update-AppServiceCertificate -AppServiceName "company-webapp" `
    #     -CertificateName "webapp-cert"
    
} catch {
    Write-Error "Certificate automation failed: $_"
    throw
}