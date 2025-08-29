# PowerShell script for NetScaler certificate automation
# Integrate with Azure Key Vault

function Update-NetScalerCertificate {
    param(
        [string]$NSIPAddress,
        [string]$Username,
        [string]$Password,
        [string]$KeyVaultName,
        [string]$CertificateName
    )

    # Get certificate from Azure Key Vault
    $cert = Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $CertificateName
    $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $CertificateName
    $certBytes = [Convert]::FromBase64String($secret.SecretValueText)

    # Extract certificate and key
    $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certCollection.Import($certBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

    # Connect to NetScaler
    $nsSession = Connect-NetScaler -IPAddress $NSIPAddress -Username $Username -Password $Password

    # Upload new certificate
    $certPath = "/nsconfig/ssl/$CertificateName.crt"
    $keyPath = "/nsconfig/ssl/$CertificateName.key"

    Upload-NetScalerFile -Session $nsSession -Path $certPath -Content $cert.Certificate
    Upload-NetScalerFile -Session $nsSession -Path $keyPath -Content $cert.PrivateKey

    # Update certificate binding
    $cmd = "update ssl certKey $CertificateName -cert $certPath -key $keyPath"
    Invoke-NetScalerCommand -Session $nsSession -Command $cmd

    # Save configuration
    Save-NetScalerConfig -Session $nsSession
}

# Schedule as Azure Automation Runbook
$schedule = New-AzAutomationSchedule `
    -AutomationAccountName "AA-PKI-Automation" `
    -Name "NetScaler-Cert-Update" `
    -StartTime (Get-Date).AddDays(1) `
    -MonthInterval 1 `
    -DaysOfMonth 15