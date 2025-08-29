# Configure-HSMKeys.ps1
# Creates and configures HSM-protected keys for Root CA

# Create Root CA signing key
$rootCAKey = Add-AzKeyVaultKey `
    -VaultName $KeyVaultName `
    -Name "RootCA-SigningKey-2025" `
    -KeyType RSA-HSM `
    -Size 4096 `
    -KeyOps @("sign", "verify") `
    -NotBefore (Get-Date) `
    -Expires (Get-Date).AddYears(20) `
    -Tag @{
    Purpose    = "Root CA Signing"
    Algorithm  = "RSA-4096"
    Protection = "HSM"
    CreatedBy  = "PKI-Team"
    Ceremony   = "2025-02-10"
}

# Set key permissions
$keyPermissions = @{
    PermissionsToKeys         = @("get", "list", "sign", "verify", "backup")
    PermissionsToSecrets      = @("get", "list")
    PermissionsToCertificates = @("get", "list", "create", "import")
}

# Assign permissions to Azure Private CA service principal
Set-AzKeyVaultAccessPolicy `
    -VaultName $KeyVaultName `
    -ServicePrincipalName "Microsoft.Azure.CertificateAuthority" `
    @keyPermissions

# Create key rotation policy
$rotationPolicy = @{
    KeyRotationLifetimeAction = @{
        Action           = "Notify"
        TimeBeforeExpiry = "P30D"
    }
    KeyRotationPolicy         = @{
        ExpiresIn = "P10Y"
        KeyType   = "RSA-HSM"
        KeySize   = 4096
    }
}

Set-AzKeyVaultKeyRotationPolicy `
    -VaultName $KeyVaultName `
    -Name "RootCA-SigningKey-2025" `
    @rotationPolicy

# Enable key backup
Backup-AzKeyVaultKey `
    -VaultName $KeyVaultName `
    -Name "RootCA-SigningKey-2025" `
    -OutputFile "C:\Backup\RootCA-Key-Backup.blob"

Write-Host "HSM key configuration complete!" -ForegroundColor Green
