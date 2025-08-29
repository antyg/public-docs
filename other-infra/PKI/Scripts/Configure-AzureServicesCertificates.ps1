# Configure-AzureServicesCertificates.ps1
# Automates certificate management for Azure services

param(
    [string]$KeyVaultName = "KV-PKI-Services-Prod",
    [string]$ResourceGroup = "RG-PKI-Core-Production"
)

# Define Azure services requiring certificates
$azureServices = @(
    @{
        ServiceType     = "AppService"
        Name            = "app-company-portal"
        ResourceGroup   = "RG-Apps-Production"
        Hostname        = "portal.company.com.au"
        CertificateName = "portal-company-com-au"
    },
    @{
        ServiceType     = "ApplicationGateway"
        Name            = "AGW-Company-Main"
        ResourceGroup   = "RG-Network-Production"
        Hostname        = "www.company.com.au"
        CertificateName = "www-company-com-au"
    },
    @{
        ServiceType     = "APIManagement"
        Name            = "APIM-Company"
        ResourceGroup   = "RG-API-Production"
        Hostname        = "api.company.com.au"
        CertificateName = "api-company-com-au"
    },
    @{
        ServiceType     = "FrontDoor"
        Name            = "AFD-Company-Global"
        ResourceGroup   = "RG-CDN-Production"
        Hostname        = "cdn.company.com.au"
        CertificateName = "cdn-company-com-au"
    }
)

foreach ($service in $azureServices) {
    Write-Host "Configuring certificate for $($service.Name)" -ForegroundColor Yellow

    # Create certificate policy in Key Vault
    $policy = New-AzKeyVaultCertificatePolicy `
        -SubjectName "CN=$($service.Hostname), O=Company Australia, C=AU" `
        -DnsNames $service.Hostname, "www.$($service.Hostname)" `
        -IssuerName "Company-Issuing-CA" `
        -ValidityInMonths 12 `
        -RenewAtPercentageLifetime 80 `
        -KeyType RSA `
        -KeySize 2048 `
        -SecretContentType "application/x-pkcs12" `
        -ReuseKeyOnRenewal $false

    # Add certificate to Key Vault
    Add-AzKeyVaultCertificate `
        -VaultName $KeyVaultName `
        -Name $service.CertificateName `
        -CertificatePolicy $policy

    # Configure service-specific integration
    switch ($service.ServiceType) {
        "AppService" {
            # Import certificate to App Service
            $cert = Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $service.CertificateName

            Import-AzWebAppKeyVaultCertificate `
                -ResourceGroupName $service.ResourceGroup `
                -WebAppName $service.Name `
                -KeyVaultName $KeyVaultName `
                -CertificateName $service.CertificateName

            # Bind certificate to custom domain
            New-AzWebAppSSLBinding `
                -ResourceGroupName $service.ResourceGroup `
                -WebAppName $service.Name `
                -Name $service.Hostname `
                -Thumbprint $cert.Thumbprint `
                -SslState "SniEnabled"
        }

        "ApplicationGateway" {
            # Get Application Gateway
            $appGw = Get-AzApplicationGateway `
                -Name $service.Name `
                -ResourceGroupName $service.ResourceGroup

            # Add certificate
            $cert = Get-AzKeyVaultSecret `
                -VaultName $KeyVaultName `
                -Name $service.CertificateName

            Add-AzApplicationGatewaySslCertificate `
                -ApplicationGateway $appGw `
                -Name $service.CertificateName `
                -KeyVaultSecretId $cert.Id

            # Update HTTPS listener
            $listener = Get-AzApplicationGatewayHttpListener `
                -ApplicationGateway $appGw `
                -Name "listener-https-443"

            Set-AzApplicationGatewayHttpListener `
                -ApplicationGateway $appGw `
                -HttpListener $listener `
                -SslCertificate $service.CertificateName

            # Apply changes
            Set-AzApplicationGateway -ApplicationGateway $appGw
        }

        "APIManagement" {
            # Configure API Management certificate
            $apimContext = New-AzApiManagementContext `
                -ResourceGroupName $service.ResourceGroup `
                -ServiceName $service.Name

            $cert = Get-AzKeyVaultCertificate `
                -VaultName $KeyVaultName `
                -Name $service.CertificateName

            New-AzApiManagementCertificate `
                -Context $apimContext `
                -CertificateId $service.CertificateName `
                -KeyVaultId $cert.SecretId

            # Bind to custom domain
            Set-AzApiManagementHostname `
                -Context $apimContext `
                -HostnameType "Proxy" `
                -HostName $service.Hostname `
                -CertificateThumbprint $cert.Thumbprint
        }

        "FrontDoor" {
            # Configure Front Door certificate
            $frontDoor = Get-AzFrontDoor `
                -ResourceGroupName $service.ResourceGroup `
                -Name $service.Name

            # Enable HTTPS on custom domain
            Enable-AzFrontDoorCustomDomainHttps `
                -ResourceGroupName $service.ResourceGroup `
                -FrontDoorName $service.Name `
                -FrontendEndpointName $service.Hostname `
                -VaultId (Get-AzKeyVault -VaultName $KeyVaultName).ResourceId `
                -SecretName $service.CertificateName
        }
    }

    Write-Host "Certificate configured for $($service.Name)" -ForegroundColor Green
}

# Create automation runbook for certificate renewal
$runbookCode = @'
workflow Renew-AzureServiceCertificates
{
    param(
        [string]$KeyVaultName,
        [int]$RenewalThresholdDays = 30
    )

    # Get all certificates from Key Vault
    $certificates = Get-AzKeyVaultCertificate -VaultName $KeyVaultName

    foreach -parallel ($cert in $certificates) {
        $certificate = Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $cert.Name
        $daysUntilExpiry = ($certificate.Attributes.Expires - (Get-Date)).Days

        if ($daysUntilExpiry -le $RenewalThresholdDays) {
            Write-Output "Renewing certificate: $($cert.Name)"

            # Trigger renewal
            Add-AzKeyVaultCertificate `
                -VaultName $KeyVaultName `
                -Name $cert.Name `
                -RenewCertificate

            # Wait for renewal to complete
            $maxWait = 300
            $waited = 0

            while ($waited -lt $maxWait) {
                $operation = Get-AzKeyVaultCertificateOperation `
                    -VaultName $KeyVaultName `
                    -Name $cert.Name

                if ($operation.Status -eq "completed") {
                    Write-Output "Certificate renewed: $($cert.Name)"
                    break
                }

                Start-Sleep -Seconds 10
                $waited += 10
            }
        }
    }
}
'@

# Create automation account and runbook
$automationAccount = New-AzAutomationAccount `
    -Name "AA-PKI-CertRenewal" `
    -ResourceGroupName $ResourceGroup `
    -Location "australiaeast"

New-AzAutomationRunbook `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -Name "Renew-AzureServiceCertificates" `
    -Type PowerShellWorkflow `
    -ResourceGroupName $ResourceGroup

# Schedule daily execution
New-AzAutomationSchedule `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -Name "DailyCertificateCheck" `
    -StartTime (Get-Date).AddDays(1).Date.AddHours(2) `
    -DayInterval 1 `
    -ResourceGroupName $ResourceGroup

Register-AzAutomationScheduledRunbook `
    -AutomationAccountName $automationAccount.AutomationAccountName `
    -RunbookName "Renew-AzureServiceCertificates" `
    -ScheduleName "DailyCertificateCheck" `
    -ResourceGroupName $ResourceGroup `
    -Parameters @{KeyVaultName = $KeyVaultName }

Write-Host "Azure services certificate automation configured" -ForegroundColor Green
