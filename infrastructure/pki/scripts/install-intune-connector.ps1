# Install-IntuneConnector.ps1
# Installs and configures Microsoft Intune Certificate Connector

# Download Intune Certificate Connector
$connectorUrl = "https://go.microsoft.com/fwlink/?LinkId=833842"
$installerPath = "C:\Temp\IntuneCertificateConnector.msi"

Invoke-WebRequest -Uri $connectorUrl -OutFile $installerPath

# Install on NDES server
Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    param($installer)

    # Install Certificate Connector
    Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait

    # Wait for installation
    Start-Sleep -Seconds 30

} -ArgumentList $installerPath

# Configure Intune Connector
Write-Host "Configuring Intune Certificate Connector..." -ForegroundColor Yellow

# This requires interactive configuration through the UI
# Steps:
# 1. Launch Certificate Connector UI
# 2. Sign in with Intune admin account
# 3. Select SCEP profile
# 4. Enter NDES server URL: https://ndes.company.com.au/certsrv/mscep/mscep.dll
# 5. Select client certificate for authentication
# 6. Test connection
# 7. Save configuration

Write-Host @"
Manual steps required:
1. RDP to PKI-NDES-01
2. Launch 'Microsoft Intune Certificate Connector' from Start Menu
3. Sign in with Intune admin credentials
4. Configure SCEP settings:
   - NDES URL: https://ndes.company.com.au/certsrv/mscep/mscep.dll
   - Select appropriate client certificate
5. Test and save configuration
"@ -ForegroundColor Cyan

# Create Intune SCEP profile
$scepProfile = @{
    "@odata.type"                  = "#microsoft.graph.windows81SCEPCertificateProfile"
    displayName                    = "Company Mobile Device Certificate"
    description                    = "SCEP certificate for mobile device authentication"
    scepServerUrls                 = @("https://ndes.company.com.au/certsrv/mscep/mscep.dll")
    subjectNameFormatString        = "CN={{DeviceId}},OU=Mobile,O=Company"
    keyUsage                       = "digitalSignature,keyEncipherment"
    keySize                        = "2048"
    hashAlgorithm                  = "sha2"
    extendedKeyUsages              = @(
        @{
            name             = "Client Authentication"
            objectIdentifier = "1.3.6.1.5.5.7.3.2"
        }
    )
    certificateValidityPeriodScale = "years"
    certificateValidityPeriodValue = 2
    renewalThresholdPercentage     = 20
}

# Note: This would be deployed via Microsoft Graph API
Write-Host "SCEP profile configuration prepared for Intune deployment" -ForegroundColor Green
