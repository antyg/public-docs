# Configure-SCCMPKI.ps1
# Integrates SCCM with PKI infrastructure for certificate deployment

$siteCode = "P01"
$siteServer = "SCCM-Primary.company.local"

# Connect to SCCM
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location "$siteCode`:"

# Create certificate profiles
function New-SCCMCertificateProfile {
    param(
        [string]$ProfileName,
        [string]$TemplateName,
        [string]$CAServer,
        [string]$Description,
        [string]$TargetCollection
    )

    $profile = New-CMCertificateProfileTrustedRootCA `
        -Name $ProfileName `
        -Description $Description `
        -Path "\\PKI-ICA-01\CertEnroll\$TemplateName.cer"

    # Create deployment
    Start-CMCertificateProfileDeployment `
        -CertificateProfile $profile `
        -CollectionName $TargetCollection `
        -DeploymentPurpose Available

    Write-Host "Certificate profile '$ProfileName' created and deployed" -ForegroundColor Green
}

# Deploy Root CA certificate
$rootCAProfile = @{
    ProfileName      = "Company Root CA G2"
    Description      = "Company Root Certificate Authority"
    CertPath         = "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt"
    TargetCollection = "All Systems"
}

New-CMCertificateProfileTrustedRootCA @rootCAProfile

# Create SCEP profiles for different device types
$scepProfiles = @(
    @{
        Name             = "Windows Workstation Certificate"
        Template         = "Company-Computer-Authentication"
        Platform         = "Windows10"
        KeySize          = 2048
        HashAlgorithm    = "SHA256"
        KeyUsage         = "DigitalSignature,KeyEncipherment"
        SubjectName      = "CN={{ComputerName}},OU=Workstations,O=Company"
        SANType          = "DNS"
        SANValue         = "{{ComputerName}}.company.local"
        RenewalThreshold = 20
        Collection       = "All Windows 10 Workstations"
    },
    @{
        Name             = "Server Authentication Certificate"
        Template         = "Company-Web-Server"
        Platform         = "WindowsServer"
        KeySize          = 3072
        HashAlgorithm    = "SHA256"
        KeyUsage         = "DigitalSignature,KeyEncipherment"
        SubjectName      = "CN={{ComputerName}},OU=Servers,O=Company"
        SANType          = "DNS"
        SANValue         = "{{ComputerName}}.company.local"
        RenewalThreshold = 30
        Collection       = "All Servers"
    },
    @{
        Name             = "Mobile Device Certificate"
        Template         = "Company-Mobile-Device"
        Platform         = "iOS,Android"
        KeySize          = 2048
        HashAlgorithm    = "SHA256"
        KeyUsage         = "DigitalSignature"
        SubjectName      = "CN={{DeviceId}},OU=Mobile,O=Company"
        RenewalThreshold = 20
        Collection       = "All Mobile Devices"
    }
)

foreach ($profile in $scepProfiles) {
    $scepProfile = New-CMCertificateProfileScep `
        -Name $profile.Name `
        -SupportedPlatform $profile.Platform `
        -KeySize $profile.KeySize `
        -HashAlgorithm $profile.HashAlgorithm `
        -KeyUsage $profile.KeyUsage `
        -SubjectNameFormat "Custom" `
        -SubjectName $profile.SubjectName `
        -SubjectAlternativeNameType $profile.SANType `
        -SubjectAlternativeNameValue $profile.SANValue `
        -CertificateTemplateName $profile.Template `
        -CertificateValidityDays 730 `
        -RenewalThresholdPercentage $profile.RenewalThreshold `
        -ScepServerUrl @("https://ndes.company.com.au/certsrv/mscep/mscep.dll")

    # Deploy profile
    Start-CMCertificateProfileDeployment `
        -CertificateProfile $scepProfile `
        -CollectionName $profile.Collection `
        -DeploymentPurpose Required
}

# Configure SCCM client settings for certificate selection
$clientSettings = Get-CMClientSetting -Name "Default Client Settings"
Set-CMClientSettingCertificate `
    -InputObject $clientSettings `
    -CertificateSelectionCriteria "Subject:company.local" `
    -CertificateStore "MY" `
    -SelectCertificateWithLongestValidityPeriod $true

# Create compliance settings for certificate validation
$complianceRule = @{
    Name              = "Certificate Compliance"
    Description       = "Validates PKI certificates are present and valid"
    SupportedPlatform = "Windows10"
    RuleType          = "Value"
    DataType          = "DateTime"
    Expression        = @'
        $cert = Get-ChildItem Cert:\LocalMachine\My |
            Where-Object {$_.Subject -like "*$env:COMPUTERNAME*" -and $_.Issuer -like "*Company Issuing CA*"}

        if ($cert -and $cert.NotAfter -gt (Get-Date).AddDays(30)) {
            return "Compliant"
        } else {
            return "NonCompliant"
        }
'@
}

New-CMComplianceRule @complianceRule

Write-Host "SCCM PKI integration complete" -ForegroundColor Green
