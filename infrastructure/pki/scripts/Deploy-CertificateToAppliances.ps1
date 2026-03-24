# Master certificate deployment script for all network appliances
# Save as Deploy-CertificateToAppliances.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$CertificatePath,

    [Parameter(Mandatory = $true)]
    [string]$PrivateKeyPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet("NetScaler", "F5", "PaloAlto", "Zscaler", "All")]
    [string]$TargetAppliance,

    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = ".\appliance-config.json"
)

# Load configuration
$config = Get-Content $ConfigFile | ConvertFrom-Json

function Deploy-ToNetScaler {
    param($cert, $key, $config)

    $nsSession = Connect-NetScaler -IPAddress $config.NetScaler.IP `
        -Username $config.NetScaler.Username `
        -Password (ConvertTo-SecureString $config.NetScaler.Password -AsPlainText -Force)

    # Upload certificate files
    $certName = [System.IO.Path]::GetFileNameWithoutExtension($cert)
    Upload-NetScalerFile -Session $nsSession -Path "/nsconfig/ssl/$certName.crt" -LocalFile $cert
    Upload-NetScalerFile -Session $nsSession -Path "/nsconfig/ssl/$certName.key" -LocalFile $key

    # Create certificate object
    $cmd = "add ssl certKey $certName -cert /nsconfig/ssl/$certName.crt -key /nsconfig/ssl/$certName.key"
    Invoke-NetScalerCommand -Session $nsSession -Command $cmd

    # Update bindings
    foreach ($vserver in $config.NetScaler.VirtualServers) {
        $cmd = "bind ssl vserver $vserver -certkeyName $certName"
        Invoke-NetScalerCommand -Session $nsSession -Command $cmd
    }

    Save-NetScalerConfig -Session $nsSession
    Write-Host "Successfully deployed certificate to NetScaler" -ForegroundColor Green
}

function Deploy-ToF5 {
    param($cert, $key, $config)

    # F5 iControl REST API
    $headers = @{
        'Content-Type'  = 'application/json'
        'Authorization' = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($config.F5.Username):$($config.F5.Password)"))
    }

    $certContent = Get-Content $cert -Raw
    $keyContent = Get-Content $key -Raw

    # Upload certificate
    $certBody = @{
        name = "wildcard-company-$(Get-Date -Format 'yyyy')"
        cert = $certContent
        key  = $keyContent
    } | ConvertTo-Json

    $uri = "https://$($config.F5.IP)/mgmt/tm/sys/crypto/cert"
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $certBody -SkipCertificateCheck

    Write-Host "Successfully deployed certificate to F5 BIG-IP" -ForegroundColor Green
}

function Deploy-ToPaloAlto {
    param($cert, $key, $config)

    # Generate API key
    $authUri = "https://$($config.PaloAlto.IP)/api/?type=keygen&user=$($config.PaloAlto.Username)&password=$($config.PaloAlto.Password)"
    $authResponse = Invoke-RestMethod -Uri $authUri -Method Get -SkipCertificateCheck
    $apiKey = $authResponse.response.result.key

    # Import certificate
    $certContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($cert))
    $keyContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($key))

    $importUri = "https://$($config.PaloAlto.IP)/api/?type=import&category=certificate"
    $importUri += "&certificate-name=wildcard-company&format=pem&key=$apiKey"

    $body = @{
        certificate = $certContent
        private_key = $keyContent
    }

    Invoke-RestMethod -Uri $importUri -Method Post -Body $body -SkipCertificateCheck

    # Commit configuration
    $commitUri = "https://$($config.PaloAlto.IP)/api/?type=commit&key=$apiKey"
    Invoke-RestMethod -Uri $commitUri -Method Get -SkipCertificateCheck

    Write-Host "Successfully deployed certificate to Palo Alto firewall" -ForegroundColor Green
}

function Deploy-ToZscaler {
    param($cert, $key, $config)

    # Zscaler API implementation
    $baseUrl = "https://zsapi.$($config.Zscaler.Cloud)/api/v1"

    # Authenticate
    $authBody = @{
        apiKey    = $config.Zscaler.ApiKey
        username  = $config.Zscaler.Username
        password  = $config.Zscaler.Password
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    } | ConvertTo-Json

    $session = Invoke-RestMethod -Uri "$baseUrl/authenticatedSession" -Method Post -Body $authBody

    # Upload certificate
    $certContent = Get-Content $cert -Raw
    $uploadBody = @{
        certificate = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($certContent))
        type        = "INTERMEDIATE_CA"
    } | ConvertTo-Json

    $headers = @{
        'Cookie'       = "JSESSIONID=$($session.jsessionid)"
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri "$baseUrl/sslSettings/intermediateCaCert" -Method Post -Headers $headers -Body $uploadBody

    Write-Host "Successfully deployed certificate to Zscaler" -ForegroundColor Green
}

# Main execution
try {
    $certificate = Get-Content $CertificatePath
    $privateKey = Get-Content $PrivateKeyPath

    switch ($TargetAppliance) {
        "NetScaler" { Deploy-ToNetScaler -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "F5" { Deploy-ToF5 -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "PaloAlto" { Deploy-ToPaloAlto -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "Zscaler" { Deploy-ToZscaler -cert $CertificatePath -key $PrivateKeyPath -config $config }
        "All" {
            Deploy-ToNetScaler -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToF5 -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToPaloAlto -cert $CertificatePath -key $PrivateKeyPath -config $config
            Deploy-ToZscaler -cert $CertificatePath -key $PrivateKeyPath -config $config
        }
    }

    Write-Host "`nCertificate deployment completed successfully!" -ForegroundColor Green

} catch {
    Write-Error "Certificate deployment failed: $_"
    exit 1
}
