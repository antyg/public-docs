# PKI Modernization - Phase 3: Services Integration

[← Previous: Phase 2 Core Infrastructure](06-phase2-core-infrastructure.md) | [Back to Index](00-index.md) | [Next: Phase 4 Migration Strategy →](08-phase4-migration-strategy.md)

## Executive Summary

Phase 3 integrates the PKI infrastructure with enterprise services including code signing, SCCM, Azure services, load balancers (NetScaler/F5), and security services (Zscaler). This phase establishes automated certificate lifecycle management, API integration, and comprehensive monitoring across all certificate-consuming services.

## Phase 3 Overview

### Objectives
- Establish code signing infrastructure for DevOps
- Integrate SCCM for enterprise certificate deployment
- Automate Azure service certificate management
- Configure SSL/TLS on load balancers and proxies
- Integrate with Zscaler for SSL inspection
- Deploy comprehensive monitoring and automation
- Implement REST API for certificate services

### Success Criteria
- ✅ Code signing service operational with approval workflow
- ✅ SCCM deploying certificates to 10,000+ endpoints
- ✅ Azure services auto-renewing certificates
- ✅ Load balancers configured with PKI certificates
- ✅ Zscaler trust established for SSL inspection
- ✅ Monitoring detecting all certificate events
- ✅ API supporting automated certificate operations

### Timeline
**Duration**: 2 weeks (March 3-14, 2025)
**Resources Required**: 7.5 FTE
**Budget**: $50,000 (Software) + $75,000 (Integration Services)

## Week 5: Core Services Integration

### Day 1-3: Code Signing Infrastructure

#### Deploy Code Signing Service
```powershell
# Deploy-CodeSigningService.ps1
# Implements secure code signing infrastructure

param(
    [string]$ServiceServer = "PKI-CODESIGN-01",
    [string]$KeyVaultName = "KV-PKI-CodeSign-Prod",
    [string]$ResourceGroup = "RG-PKI-Core-Production"
)

# Create dedicated VM for code signing
Write-Host "Deploying code signing service VM..." -ForegroundColor Green

$vmConfig = @{
    Name = $ServiceServer
    ResourceGroupName = $ResourceGroup
    Location = "australiaeast"
    Size = "Standard_D4s_v5"
    Image = "Win2022Datacenter"
    VirtualNetworkName = "VNET-PKI-PROD"
    SubnetName = "PKI-Services"
    PrivateIpAddress = "10.50.4.10"
    SecurityGroupName = "NSG-PKI-CodeSign"
}

# Deploy VM (using existing deployment function)
New-PKIServiceVM @vmConfig

# Configure code signing service
Invoke-Command -ComputerName $ServiceServer -ScriptBlock {
    
    # Install required components
    Install-WindowsFeature -Name Web-Server, Web-Asp-Net45, Web-Net-Ext45
    
    # Create directory structure
    $paths = @(
        "C:\CodeSign",
        "C:\CodeSign\Service",
        "C:\CodeSign\Queue",
        "C:\CodeSign\Signed",
        "C:\CodeSign\Logs",
        "C:\CodeSign\Archive"
    )
    
    foreach ($path in $paths) {
        New-Item -ItemType Directory -Path $path -Force
    }
    
    # Set strict permissions
    $acl = Get-Acl "C:\CodeSign"
    $acl.SetAccessRuleProtection($true, $false)
    
    # Remove all existing permissions
    $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }
    
    # Add specific permissions
    $permissions = @(
        @{Identity = "SYSTEM"; Rights = "FullControl"},
        @{Identity = "Administrators"; Rights = "FullControl"},
        @{Identity = "CodeSign-Service"; Rights = "Modify"},
        @{Identity = "CodeSign-Approvers"; Rights = "Read"}
    )
    
    foreach ($perm in $permissions) {
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $perm.Identity, $perm.Rights, "ContainerInherit,ObjectInherit", "None", "Allow"
        )
        $acl.AddAccessRule($rule)
    }
    
    Set-Acl -Path "C:\CodeSign" -AclObject $acl
    
    Write-Host "Code signing directories configured" -ForegroundColor Green
}

# Deploy code signing web service
$codeSignServiceCode = @'
using System;
using System.Web.Http;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography;
using Azure.Security.KeyVault.Certificates;
using Azure.Identity;

namespace CodeSigningService
{
    public class SigningController : ApiController
    {
        private readonly string KeyVaultUrl = "https://kv-pki-codesign-prod.vault.azure.net/";
        private readonly string CertificateName = "CodeSigningCert2025";
        
        [HttpPost]
        [Route("api/sign")]
        public async Task<IHttpActionResult> SignFile([FromBody] SignRequest request)
        {
            try
            {
                // Validate request
                if (!ValidateRequest(request))
                {
                    return BadRequest("Invalid signing request");
                }
                
                // Check approval status
                if (!await CheckApproval(request.RequestId))
                {
                    return StatusCode(HttpStatusCode.Forbidden);
                }
                
                // Get certificate from Key Vault
                var client = new CertificateClient(
                    new Uri(KeyVaultUrl),
                    new DefaultAzureCredential()
                );
                
                var certificate = await client.GetCertificateAsync(CertificateName);
                
                // Sign the file
                var signedData = await SignData(
                    request.FileContent,
                    certificate.Value
                );
                
                // Log signing operation
                await LogSigningOperation(request, signedData);
                
                // Return signed file
                return Ok(new SignResponse
                {
                    RequestId = request.RequestId,
                    SignedFile = signedData,
                    Certificate = certificate.Value.Cer,
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                LogError(ex);
                return InternalServerError();
            }
        }
        
        private bool ValidateRequest(SignRequest request)
        {
            // Validate file size (max 100MB)
            if (request.FileContent.Length > 104857600)
                return false;
            
            // Validate file type
            var allowedTypes = new[] { ".exe", ".dll", ".msi", ".ps1", ".cab" };
            if (!allowedTypes.Contains(Path.GetExtension(request.FileName)))
                return false;
            
            // Validate requester
            if (!User.Identity.IsAuthenticated)
                return false;
            
            return true;
        }
        
        private async Task<bool> CheckApproval(string requestId)
        {
            // Query approval database
            using (var db = new ApprovalContext())
            {
                var approval = await db.Approvals
                    .Where(a => a.RequestId == requestId)
                    .FirstOrDefaultAsync();
                
                return approval?.Status == ApprovalStatus.Approved;
            }
        }
        
        private async Task<byte[]> SignData(byte[] data, KeyVaultCertificate cert)
        {
            // Implement Authenticode signing
            // This would use SignTool.exe or similar
            
            var tempFile = Path.GetTempFileName();
            File.WriteAllBytes(tempFile, data);
            
            var signToolPath = @"C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe";
            var arguments = $"sign /fd SHA256 /td SHA256 /tr http://timestamp.company.com.au /n \"{cert.Properties.Subject}\" \"{tempFile}\"";
            
            var process = Process.Start(signToolPath, arguments);
            await process.WaitForExitAsync();
            
            if (process.ExitCode != 0)
            {
                throw new Exception("Signing failed");
            }
            
            var signedData = File.ReadAllBytes(tempFile);
            File.Delete(tempFile);
            
            return signedData;
        }
    }
    
    public class SignRequest
    {
        public string RequestId { get; set; }
        public string FileName { get; set; }
        public byte[] FileContent { get; set; }
        public string Requester { get; set; }
        public string Purpose { get; set; }
        public Dictionary<string, string> Metadata { get; set; }
    }
    
    public class SignResponse
    {
        public string RequestId { get; set; }
        public byte[] SignedFile { get; set; }
        public byte[] Certificate { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
'@

# Save and compile service code
$codeSignServiceCode | Out-File -FilePath "C:\CodeSign\Service\SigningController.cs"

Write-Host "Code signing service deployed" -ForegroundColor Green
```

#### Code Signing Approval Workflow
```powershell
# Configure-CodeSignApproval.ps1
# Implements approval workflow for code signing requests

# Create approval database
Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Query @"
CREATE DATABASE CodeSignApprovals;
GO

USE CodeSignApprovals;
GO

CREATE TABLE SigningRequests (
    RequestId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RequestDate DATETIME2 DEFAULT GETUTCDATE(),
    Requester NVARCHAR(100) NOT NULL,
    FileName NVARCHAR(500) NOT NULL,
    FileHash NVARCHAR(64) NOT NULL,
    Purpose NVARCHAR(1000),
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending',
    Approver NVARCHAR(100),
    ApprovalDate DATETIME2,
    RejectionReason NVARCHAR(1000),
    SigningDate DATETIME2,
    CertificateSerial NVARCHAR(100),
    INDEX IX_RequestDate (RequestDate),
    INDEX IX_Requester (Requester),
    INDEX IX_Status (ApprovalStatus)
);

CREATE TABLE ApprovalRules (
    RuleId INT IDENTITY PRIMARY KEY,
    RuleName NVARCHAR(100),
    FilePattern NVARCHAR(500),
    RequesterPattern NVARCHAR(100),
    AutoApprove BIT DEFAULT 0,
    RequiredApprovers INT DEFAULT 1,
    ApproverGroup NVARCHAR(100),
    MaxFileSize BIGINT,
    IsActive BIT DEFAULT 1
);

-- Insert default rules
INSERT INTO ApprovalRules (RuleName, FilePattern, RequesterPattern, AutoApprove, RequiredApprovers, ApproverGroup)
VALUES 
    ('PowerShell Scripts', '%.ps1', '%', 0, 1, 'CodeSign-Approvers'),
    ('Production Executables', '%.exe', '%', 0, 2, 'CodeSign-Managers'),
    ('Test Builds', '%test%.exe', 'DEV-%', 1, 0, NULL),
    ('Driver Packages', '%.sys', '%', 0, 2, 'Security-Team');
"@

# Create Power Automate flow for approval
$approvalFlow = @{
    Name = "Code Signing Approval Flow"
    Trigger = "When a new item is created in SigningRequests"
    Actions = @(
        @{
            Type = "GetApprovalRules"
            Query = "SELECT * FROM ApprovalRules WHERE @FileName LIKE FilePattern"
        },
        @{
            Type = "Condition"
            If = "AutoApprove = 1"
            Then = @{
                Type = "UpdateStatus"
                Status = "Approved"
                Approver = "System-Auto"
            }
            Else = @{
                Type = "SendApprovalEmail"
                To = "ApproverGroup"
                Subject = "Code Signing Request: @FileName"
                Body = "Please review and approve the code signing request"
            }
        },
        @{
            Type = "WaitForApproval"
            Timeout = "24 hours"
        },
        @{
            Type = "UpdateDatabase"
            Fields = @("ApprovalStatus", "Approver", "ApprovalDate")
        },
        @{
            Type = "NotifyRequester"
            EmailTemplate = "ApprovalDecision"
        }
    )
}

Write-Host "Approval workflow configured" -ForegroundColor Green
```

### Day 4-5: SCCM Integration

#### Configure SCCM for PKI
```powershell
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
    ProfileName = "Company Root CA G2"
    Description = "Company Root Certificate Authority"
    CertPath = "\\PKI-ICA-01\CertEnroll\RootCA-G2.crt"
    TargetCollection = "All Systems"
}

New-CMCertificateProfileTrustedRootCA @rootCAProfile

# Create SCEP profiles for different device types
$scepProfiles = @(
    @{
        Name = "Windows Workstation Certificate"
        Template = "Company-Computer-Authentication"
        Platform = "Windows10"
        KeySize = 2048
        HashAlgorithm = "SHA256"
        KeyUsage = "DigitalSignature,KeyEncipherment"
        SubjectName = "CN={{ComputerName}},OU=Workstations,O=Company"
        SANType = "DNS"
        SANValue = "{{ComputerName}}.company.local"
        RenewalThreshold = 20
        Collection = "All Windows 10 Workstations"
    },
    @{
        Name = "Server Authentication Certificate"
        Template = "Company-Web-Server"
        Platform = "WindowsServer"
        KeySize = 3072
        HashAlgorithm = "SHA256"
        KeyUsage = "DigitalSignature,KeyEncipherment"
        SubjectName = "CN={{ComputerName}},OU=Servers,O=Company"
        SANType = "DNS"
        SANValue = "{{ComputerName}}.company.local"
        RenewalThreshold = 30
        Collection = "All Servers"
    },
    @{
        Name = "Mobile Device Certificate"
        Template = "Company-Mobile-Device"
        Platform = "iOS,Android"
        KeySize = 2048
        HashAlgorithm = "SHA256"
        KeyUsage = "DigitalSignature"
        SubjectName = "CN={{DeviceId}},OU=Mobile,O=Company"
        RenewalThreshold = 20
        Collection = "All Mobile Devices"
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
    Name = "Certificate Compliance"
    Description = "Validates PKI certificates are present and valid"
    SupportedPlatform = "Windows10"
    RuleType = "Value"
    DataType = "DateTime"
    Expression = @'
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
```

#### SCCM Certificate Deployment Monitoring
```powershell
# Monitor-SCCMCertificates.ps1
# Monitors certificate deployment through SCCM

# Get deployment status
$deploymentStatus = Get-CMCertificateProfileDeploymentStatus -Name "Windows Workstation Certificate"

$report = @{
    TotalTargeted = $deploymentStatus.NumberTargeted
    Successful = $deploymentStatus.NumberSuccess
    InProgress = $deploymentStatus.NumberInProgress
    Failed = $deploymentStatus.NumberErrors
    Unknown = $deploymentStatus.NumberUnknown
    SuccessRate = [math]::Round(($deploymentStatus.NumberSuccess / $deploymentStatus.NumberTargeted) * 100, 2)
}

# Create detailed report
$detailedReport = Get-WmiObject -Namespace "root\SMS\site_$siteCode" `
    -Class SMS_CertificateInfo -ComputerName $siteServer |
    Select-Object @{
        Name = "ComputerName"
        Expression = {$_.ResourceName}
    },
    @{
        Name = "CertificateType"
        Expression = {$_.CertificateType}
    },
    @{
        Name = "Subject"
        Expression = {$_.Subject}
    },
    @{
        Name = "Issuer"
        Expression = {$_.Issuer}
    },
    @{
        Name = "ValidFrom"
        Expression = {[DateTime]::Parse($_.ValidFrom)}
    },
    @{
        Name = "ValidTo"
        Expression = {[DateTime]::Parse($_.ValidTo)}
    },
    @{
        Name = "DaysRemaining"
        Expression = {([DateTime]::Parse($_.ValidTo) - (Get-Date)).Days}
    }

# Generate compliance report
$complianceReport = $detailedReport | Group-Object -Property {
    if ($_.DaysRemaining -lt 0) { "Expired" }
    elseif ($_.DaysRemaining -lt 30) { "Expiring Soon" }
    elseif ($_.DaysRemaining -lt 90) { "Warning" }
    else { "Healthy" }
} | Select-Object Name, Count

# Export reports
$report | Export-Csv -Path "C:\Reports\SCCM-Certificate-Deployment-$(Get-Date -Format 'yyyyMMdd').csv"
$detailedReport | Export-Csv -Path "C:\Reports\SCCM-Certificate-Details-$(Get-Date -Format 'yyyyMMdd').csv"
$complianceReport | Export-Csv -Path "C:\Reports\SCCM-Certificate-Compliance-$(Get-Date -Format 'yyyyMMdd').csv"

Write-Host "SCCM Certificate Deployment Status:" -ForegroundColor Cyan
$report | Format-Table -AutoSize
```

### Day 6-7: Azure Services Certificate Automation

#### Configure Azure Key Vault Certificate Automation
```powershell
# Configure-AzureServicesCertificates.ps1
# Automates certificate management for Azure services

param(
    [string]$KeyVaultName = "KV-PKI-Services-Prod",
    [string]$ResourceGroup = "RG-PKI-Core-Production"
)

# Define Azure services requiring certificates
$azureServices = @(
    @{
        ServiceType = "AppService"
        Name = "app-company-portal"
        ResourceGroup = "RG-Apps-Production"
        Hostname = "portal.company.com.au"
        CertificateName = "portal-company-com-au"
    },
    @{
        ServiceType = "ApplicationGateway"
        Name = "AGW-Company-Main"
        ResourceGroup = "RG-Network-Production"
        Hostname = "www.company.com.au"
        CertificateName = "www-company-com-au"
    },
    @{
        ServiceType = "APIManagement"
        Name = "APIM-Company"
        ResourceGroup = "RG-API-Production"
        Hostname = "api.company.com.au"
        CertificateName = "api-company-com-au"
    },
    @{
        ServiceType = "FrontDoor"
        Name = "AFD-Company-Global"
        ResourceGroup = "RG-CDN-Production"
        Hostname = "cdn.company.com.au"
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
    -Parameters @{KeyVaultName = $KeyVaultName}

Write-Host "Azure services certificate automation configured" -ForegroundColor Green
```

## Week 6: Infrastructure Services Integration

### Day 8-9: Load Balancer SSL Configuration

#### NetScaler SSL Configuration
```python
#!/usr/bin/env python3
# configure_netscaler_ssl.py
# Configures SSL certificates on NetScaler ADC

import requests
import json
import base64
from datetime import datetime

class NetScalerSSLConfig:
    def __init__(self, nsip, username, password):
        self.nsip = nsip
        self.base_url = f"https://{nsip}/nitro/v1/config"
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'X-NITRO-USER': username,
            'X-NITRO-PASS': password
        })
        self.session.verify = False
    
    def upload_certificate(self, cert_name, cert_content, key_content):
        """Upload certificate and key to NetScaler"""
        
        # Upload certificate file
        cert_data = {
            "systemfile": {
                "filename": f"{cert_name}.crt",
                "filecontent": base64.b64encode(cert_content.encode()).decode(),
                "filelocation": "/nsconfig/ssl/",
                "fileencoding": "BASE64"
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/systemfile",
            json=cert_data
        )
        
        if response.status_code != 201:
            raise Exception(f"Failed to upload certificate: {response.text}")
        
        # Upload key file
        key_data = {
            "systemfile": {
                "filename": f"{cert_name}.key",
                "filecontent": base64.b64encode(key_content.encode()).decode(),
                "filelocation": "/nsconfig/ssl/",
                "fileencoding": "BASE64"
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/systemfile",
            json=key_data
        )
        
        if response.status_code != 201:
            raise Exception(f"Failed to upload key: {response.text}")
        
        print(f"Certificate {cert_name} uploaded successfully")
    
    def create_certkey_pair(self, certkey_name, cert_file, key_file):
        """Create certificate-key pair"""
        
        certkey_data = {
            "sslcertkey": {
                "certkey": certkey_name,
                "cert": f"/nsconfig/ssl/{cert_file}",
                "key": f"/nsconfig/ssl/{key_file}",
                "inform": "PEM",
                "passplain": ""
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/sslcertkey",
            json=certkey_data
        )
        
        if response.status_code not in [201, 409]:  # 409 = already exists
            raise Exception(f"Failed to create certkey: {response.text}")
        
        print(f"Certificate-key pair {certkey_name} created")
    
    def bind_cert_to_vserver(self, vserver_name, certkey_name):
        """Bind certificate to virtual server"""
        
        binding_data = {
            "sslvserver_sslcertkey_binding": {
                "vservername": vserver_name,
                "certkeyname": certkey_name,
                "snicert": True
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/sslvserver_sslcertkey_binding",
            json=binding_data
        )
        
        if response.status_code not in [201, 409]:
            raise Exception(f"Failed to bind certificate: {response.text}")
        
        print(f"Certificate bound to vserver {vserver_name}")
    
    def configure_ssl_parameters(self, vserver_name):
        """Configure SSL parameters for security"""
        
        ssl_params = {
            "sslvserver": {
                "vservername": vserver_name,
                "ssl3": "DISABLED",
                "tls1": "DISABLED",
                "tls11": "DISABLED",
                "tls12": "ENABLED",
                "tls13": "ENABLED",
                "snienable": "ENABLED",
                "sendclosenotify": "YES",
                "cleartextport": 0,
                "dh": "ENABLED",
                "dhfile": "/nsconfig/ssl/dhparam2048.pem",
                "ersa": "ENABLED",
                "sessreuse": "ENABLED",
                "sesstimeout": 120,
                "cipherredirect": "DISABLED",
                "sslredirect": "ENABLED"
            }
        }
        
        response = self.session.put(
            f"{self.base_url}/sslvserver/{vserver_name}",
            json=ssl_params
        )
        
        if response.status_code != 200:
            raise Exception(f"Failed to configure SSL parameters: {response.text}")
        
        print(f"SSL parameters configured for {vserver_name}")
    
    def configure_cipher_suites(self, vserver_name):
        """Configure secure cipher suites"""
        
        # Create custom cipher group
        cipher_group = {
            "sslcipher": {
                "ciphergroupname": "SECURE_CIPHER_GROUP_2025",
                "ciphernamesuite": [
                    "TLS1.3-AES256-GCM-SHA384",
                    "TLS1.3-AES128-GCM-SHA256",
                    "TLS1.2-ECDHE-RSA-AES256-GCM-SHA384",
                    "TLS1.2-ECDHE-RSA-AES128-GCM-SHA256",
                    "TLS1.2-ECDHE-ECDSA-AES256-GCM-SHA384",
                    "TLS1.2-ECDHE-ECDSA-AES128-GCM-SHA256"
                ]
            }
        }
        
        # Bind cipher group to vserver
        binding_data = {
            "sslvserver_sslcipher_binding": {
                "vservername": vserver_name,
                "ciphername": "SECURE_CIPHER_GROUP_2025"
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/sslvserver_sslcipher_binding",
            json=binding_data
        )
        
        print(f"Cipher suites configured for {vserver_name}")

# Main configuration
if __name__ == "__main__":
    # NetScaler details
    NS_IP = "10.20.1.10"
    NS_USER = "nsadmin"
    NS_PASS = "nspassword"
    
    # Initialize NetScaler configuration
    ns = NetScalerSSLConfig(NS_IP, NS_USER, NS_PASS)
    
    # Virtual servers to configure
    vservers = [
        {
            "name": "VS_Company_Portal_443",
            "cert_name": "portal_company_com_au",
            "hostname": "portal.company.com.au"
        },
        {
            "name": "VS_API_Gateway_443",
            "cert_name": "api_company_com_au",
            "hostname": "api.company.com.au"
        },
        {
            "name": "VS_Web_Services_443",
            "cert_name": "www_company_com_au",
            "hostname": "www.company.com.au"
        }
    ]
    
    for vserver in vservers:
        print(f"\nConfiguring {vserver['name']}...")
        
        # Get certificate from PKI
        # This would retrieve cert from CA or Key Vault
        cert_content = get_certificate_from_pki(vserver['hostname'])
        key_content = get_private_key_from_pki(vserver['hostname'])
        
        # Upload certificate
        ns.upload_certificate(vserver['cert_name'], cert_content, key_content)
        
        # Create cert-key pair
        ns.create_certkey_pair(
            vserver['cert_name'],
            f"{vserver['cert_name']}.crt",
            f"{vserver['cert_name']}.key"
        )
        
        # Bind to vserver
        ns.bind_cert_to_vserver(vserver['name'], vserver['cert_name'])
        
        # Configure SSL parameters
        ns.configure_ssl_parameters(vserver['name'])
        
        # Configure cipher suites
        ns.configure_cipher_suites(vserver['name'])
        
    print("\nNetScaler SSL configuration complete!")
```

#### F5 BIG-IP SSL Configuration
```tcl
# configure_f5_ssl.tcl
# F5 BIG-IP SSL certificate configuration

# Create SSL profiles
tmsh create ltm profile client-ssl /PKI/clientssl_company_2025 {
    cert /PKI/company_wildcard_2025.crt
    key /PKI/company_wildcard_2025.key
    chain /PKI/company_chain_2025.crt
    ciphers "TLSv1_3:TLSv1_2+ECDHE:TLSv1_2+DHE:!SSLv3:!RC4:!DES"
    options { no-sslv3 no-tlsv1 no-tlsv1_1 }
    secure-renegotiation require
    server-name company.com.au
    sni-default true
    strict-resume enabled
}

tmsh create ltm profile server-ssl /PKI/serverssl_backend {
    cert /PKI/backend_client_2025.crt
    key /PKI/backend_client_2025.key
    ciphers "DEFAULT"
    secure-renegotiation require-strict
    server-name backend.company.local
}

# Create certificate monitoring
tmsh create sys icall event /PKI/cert_expiry_check {
    event-name "cert_expiry_check"
}

tmsh create sys icall handler /PKI/cert_expiry_handler {
    event-name cert_expiry_check
    script {
        set cert_list [tmsh list sys crypto cert]
        foreach cert $cert_list {
            set expiry [tmsh show sys crypto cert $cert expiration-date]
            set days_left [expr {($expiry - [clock seconds]) / 86400}]
            
            if { $days_left < 30 } {
                tmsh create sys log-config publisher /PKI/cert_alert {
                    description "Certificate $cert expires in $days_left days"
                }
            }
        }
    }
}

# Create iRule for certificate validation
tmsh create ltm rule /PKI/cert_validation_rule {
    when CLIENTSSL_CLIENTCERT {
        # Check if client certificate was provided
        if {[SSL::cert count] > 0} {
            # Extract certificate information
            set cert_subject [X509::subject [SSL::cert 0]]
            set cert_issuer [X509::issuer [SSL::cert 0]]
            set cert_serial [X509::serial_number [SSL::cert 0]]
            
            # Validate issuer
            if { $cert_issuer contains "Company Issuing CA" } {
                # Certificate is from our CA
                HTTP::header insert X-Client-Certificate-Subject $cert_subject
                HTTP::header insert X-Client-Certificate-Serial $cert_serial
                log local0. "Valid client certificate: $cert_subject"
            } else {
                # Invalid issuer
                reject
                log local0. "Invalid certificate issuer: $cert_issuer"
            }
        } else {
            # No client certificate provided
            HTTP::respond 403 content "Client certificate required"
        }
    }
}

# Apply to virtual servers
tmsh modify ltm virtual /PKI/vs_company_portal_443 {
    profiles add { /PKI/clientssl_company_2025 { context clientside } }
    profiles add { /PKI/serverssl_backend { context serverside } }
    rules { /PKI/cert_validation_rule }
}

# Save configuration
tmsh save sys config
```

### Day 10: Zscaler Integration

#### Configure Zscaler Trust
```powershell
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
        apiKey = $APIKey
        username = $Username
        password = $Password
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
        name = "Company Root CA G2"
        description = "Company enterprise root certificate authority"
        certificate = $certBase64
        certificateType = "ROOT_CA"
        trustLevel = "TRUSTED"
    }
    
    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/certificates" `
        -Method Post `
        -Headers @{
            "auth-token" = $token
            "Content-Type" = "application/json"
        } `
        -Body ($uploadPayload | ConvertTo-Json)
    
    Write-Host "Root CA uploaded to Zscaler: $($response.id)" -ForegroundColor Green
    return $response.id
}

# Configure SSL inspection policy
function Configure-SSLInspectionPolicy {
    $policyConfig = @{
        enableSslInspection = $true
        excludedCategories = @(
            "BANKING_AND_FINANCE",
            "HEALTH"
        )
        excludedDomains = @(
            "*.company.local",
            "*.company-internal.com"
        )
        certificateChainValidation = @{
            enabled = $true
            trustInternalCAs = $true
            validateRevocation = $true
            ocspValidation = $true
            crlValidation = $true
        }
        customCertificates = @{
            useInternalCA = $true
            internalCAId = Upload-RootCAToZscaler
        }
    }
    
    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/inspectionPolicy" `
        -Method Put `
        -Headers @{
            "auth-token" = $token
            "Content-Type" = "application/json"
        } `
        -Body ($policyConfig | ConvertTo-Json -Depth 10)
    
    Write-Host "SSL inspection policy configured" -ForegroundColor Green
}

# Create certificate validation rules
function Create-CertificateValidationRules {
    $rules = @(
        @{
            name = "Validate Internal Certificates"
            description = "Ensure internal certificates are from Company CA"
            ruleOrder = 1
            action = "ALLOW"
            state = "ENABLED"
            conditions = @(
                @{
                    type = "CERTIFICATE_ISSUER"
                    operator = "CONTAINS"
                    value = "Company Issuing CA"
                }
            )
        },
        @{
            name = "Block Untrusted Certificates"
            description = "Block connections with untrusted certificates"
            ruleOrder = 2
            action = "BLOCK"
            state = "ENABLED"
            conditions = @(
                @{
                    type = "CERTIFICATE_VALIDATION"
                    operator = "EQUALS"
                    value = "UNTRUSTED"
                }
            )
        },
        @{
            name = "Warn Expired Certificates"
            description = "Warn users about expired certificates"
            ruleOrder = 3
            action = "WARN"
            state = "ENABLED"
            conditions = @(
                @{
                    type = "CERTIFICATE_EXPIRY"
                    operator = "EXPIRED"
                    value = "true"
                }
            )
        }
    )
    
    foreach ($rule in $rules) {
        $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/sslSettings/validationRules" `
            -Method Post `
            -Headers @{
                "auth-token" = $token
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
            validateChain = $true
            validateExpiry = $true
            validateRevocation = $true
            trustedIssuers = @("Company Issuing CA 01", "Company Issuing CA 02")
        }
        certificateMapping = @{
            usernameField = "CN"
            domainField = "O"
            emailField = "emailAddress"
        }
        authenticationPolicy = @{
            requireClientCert = $false
            fallbackToPassword = $true
            cacheDuration = 480  # 8 hours
        }
    }
    
    $response = Invoke-RestMethod -Uri "$ZscalerAPIUrl/authentication/clientCertificate" `
        -Method Put `
        -Headers @{
            "auth-token" = $token
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
```

### Day 11-13: Monitoring and API Development

#### Deploy PKI Monitoring Solution
```yaml
# pki-monitoring-config.yaml
# Comprehensive PKI monitoring configuration

monitoring:
  prometheus:
    scrape_configs:
      - job_name: 'pki-metrics'
        static_configs:
          - targets:
            - 'pki-ica-01:9100'
            - 'pki-ica-02:9100'
            - 'pki-ndes-01:9100'
            - 'pki-ocsp-01:9100'
            - 'pki-ocsp-02:9100'
        
      - job_name: 'certificate-exporter'
        static_configs:
          - targets:
            - 'cert-exporter:9117'
    
    rules:
      - name: pki_alerts
        rules:
          - alert: CertificateExpiringSoon
            expr: certificate_expiry_days < 30
            for: 1h
            labels:
              severity: warning
            annotations:
              summary: "Certificate expiring soon"
              description: "Certificate {{ $labels.cn }} expires in {{ $value }} days"
          
          - alert: CAServiceDown
            expr: up{job="pki-metrics"} == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "CA service is down"
              description: "{{ $labels.instance }} has been down for more than 5 minutes"
          
          - alert: HighCertificateIssuanceRate
            expr: rate(certificates_issued_total[5m]) > 100
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "High certificate issuance rate"
              description: "Certificate issuance rate is {{ $value }} per second"
          
          - alert: CRLGenerationFailed
            expr: crl_generation_last_success < time() - 86400
            for: 1h
            labels:
              severity: critical
            annotations:
              summary: "CRL generation failed"
              description: "CRL has not been generated for more than 24 hours"

  grafana:
    dashboards:
      - name: "PKI Overview"
        panels:
          - title: "Certificate Issuance Rate"
            type: graph
            query: "rate(certificates_issued_total[5m])"
          
          - title: "Certificate Expiry Distribution"
            type: heatmap
            query: "certificate_expiry_days"
          
          - title: "CA Service Health"
            type: stat
            query: "up{job='pki-metrics'}"
          
          - title: "OCSP Response Time"
            type: graph
            query: "histogram_quantile(0.95, ocsp_response_duration_seconds)"
          
          - title: "Failed Certificate Requests"
            type: counter
            query: "increase(certificate_requests_failed_total[1h])"
          
          - title: "Certificate Types Issued"
            type: pie
            query: "sum by (template) (certificates_issued_total)"

  elastic:
    indices:
      - name: pki-audit
        mappings:
          properties:
            timestamp:
              type: date
            event_type:
              type: keyword
            user:
              type: keyword
            certificate_serial:
              type: keyword
            template:
              type: keyword
            success:
              type: boolean
            error_message:
              type: text
      
      - name: pki-metrics
        mappings:
          properties:
            timestamp:
              type: date
            ca_name:
              type: keyword
            certificates_issued:
              type: long
            certificates_revoked:
              type: long
            crl_size:
              type: long
            database_size:
              type: long
```

#### PKI REST API Implementation
```python
# pki_api_service.py
# REST API for PKI certificate services

from flask import Flask, request, jsonify
from flask_restful import Api, Resource
from flask_jwt_extended import JWTManager, jwt_required, create_access_token
import requests
import base64
import subprocess
import logging
from datetime import datetime, timedelta
import pyodbc

app = Flask(__name__)
api = Api(app)

# Configuration
app.config['JWT_SECRET_KEY'] = 'your-secret-key'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
jwt = JWTManager(app)

# Database connection
conn_str = 'DRIVER={SQL Server};SERVER=SQL-PKI-DB;DATABASE=PKI_Management;Trusted_Connection=yes;'

class CertificateRequest(Resource):
    @jwt_required()
    def post(self):
        """Submit new certificate request"""
        data = request.get_json()
        
        # Validate request
        required_fields = ['template', 'subject', 'san']
        if not all(field in data for field in required_fields):
            return {'error': 'Missing required fields'}, 400
        
        try:
            # Generate CSR
            csr = self.generate_csr(data['subject'], data['san'])
            
            # Submit to CA
            cert_serial = self.submit_to_ca(csr, data['template'])
            
            # Log request
            self.log_request(data, cert_serial)
            
            return {
                'status': 'success',
                'serial': cert_serial,
                'message': 'Certificate request submitted successfully'
            }, 201
            
        except Exception as e:
            logging.error(f"Certificate request failed: {str(e)}")
            return {'error': str(e)}, 500
    
    def generate_csr(self, subject, san):
        """Generate certificate signing request"""
        config = f"""
        [req]
        distinguished_name = req_distinguished_name
        req_extensions = v3_req
        
        [req_distinguished_name]
        
        [v3_req]
        subjectAltName = @alt_names
        
        [alt_names]
        DNS.1 = {san}
        """
        
        # Write config to temp file
        with open('/tmp/csr.conf', 'w') as f:
            f.write(config)
        
        # Generate private key and CSR
        subprocess.run([
            'openssl', 'req', '-new', '-newkey', 'rsa:2048',
            '-nodes', '-keyout', '/tmp/private.key',
            '-out', '/tmp/request.csr',
            '-subj', subject,
            '-config', '/tmp/csr.conf'
        ])
        
        with open('/tmp/request.csr', 'r') as f:
            csr = f.read()
        
        return csr
    
    def submit_to_ca(self, csr, template):
        """Submit CSR to Certificate Authority"""
        ca_url = "https://pki-ica-01.company.local/certsrv/certfnsh.asp"
        
        payload = {
            'Mode': 'newreq',
            'CertRequest': csr,
            'CertAttrib': f'CertificateTemplate:{template}',
            'TargetStoreFlags': '0',
            'SaveCert': 'yes'
        }
        
        response = requests.post(ca_url, data=payload, auth=('domain\\username', 'password'))
        
        # Parse response for serial number
        # This is simplified - actual implementation would parse HTML response
        serial = response.text.split('Serial Number:')[1].split('<')[0].strip()
        
        return serial
    
    def log_request(self, data, serial):
        """Log certificate request to database"""
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO CertificateRequests 
            (RequestDate, Template, Subject, SAN, Serial, Requester, Status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, datetime.now(), data['template'], data['subject'],
            data.get('san'), serial, request.headers.get('X-User'), 'Issued')
        
        conn.commit()
        conn.close()

class CertificateRetrieval(Resource):
    @jwt_required()
    def get(self, serial):
        """Retrieve certificate by serial number"""
        try:
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            cursor.execute("""
                SELECT Certificate, IssuedDate, ExpiryDate, Status
                FROM Certificates
                WHERE Serial = ?
            """, serial)
            
            row = cursor.fetchone()
            
            if row:
                return {
                    'serial': serial,
                    'certificate': base64.b64encode(row[0]).decode(),
                    'issued': row[1].isoformat(),
                    'expiry': row[2].isoformat(),
                    'status': row[3]
                }, 200
            else:
                return {'error': 'Certificate not found'}, 404
                
        except Exception as e:
            logging.error(f"Certificate retrieval failed: {str(e)}")
            return {'error': str(e)}, 500

class CertificateRevocation(Resource):
    @jwt_required()
    def post(self, serial):
        """Revoke certificate"""
        data = request.get_json()
        reason = data.get('reason', 'unspecified')
        
        try:
            # Call certutil to revoke certificate
            result = subprocess.run([
                'certutil', '-revoke', serial, reason
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                # Update database
                conn = pyodbc.connect(conn_str)
                cursor = conn.cursor()
                
                cursor.execute("""
                    UPDATE Certificates
                    SET Status = 'Revoked', RevokedDate = ?, RevokedReason = ?
                    WHERE Serial = ?
                """, datetime.now(), reason, serial)
                
                conn.commit()
                conn.close()
                
                return {
                    'status': 'success',
                    'message': f'Certificate {serial} revoked'
                }, 200
            else:
                return {'error': result.stderr}, 500
                
        except Exception as e:
            logging.error(f"Certificate revocation failed: {str(e)}")
            return {'error': str(e)}, 500

class CertificateValidation(Resource):
    def post(self):
        """Validate certificate chain"""
        data = request.get_json()
        cert_pem = data.get('certificate')
        
        if not cert_pem:
            return {'error': 'Certificate required'}, 400
        
        try:
            # Write certificate to temp file
            with open('/tmp/cert.pem', 'w') as f:
                f.write(cert_pem)
            
            # Validate against CA chain
            result = subprocess.run([
                'openssl', 'verify', '-CAfile', '/etc/pki/ca-chain.pem',
                '/tmp/cert.pem'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                # Parse certificate details
                cert_info = subprocess.run([
                    'openssl', 'x509', '-in', '/tmp/cert.pem',
                    '-noout', '-subject', '-issuer', '-serial', '-dates'
                ], capture_output=True, text=True)
                
                return {
                    'valid': True,
                    'details': cert_info.stdout
                }, 200
            else:
                return {
                    'valid': False,
                    'error': result.stderr
                }, 200
                
        except Exception as e:
            logging.error(f"Certificate validation failed: {str(e)}")
            return {'error': str(e)}, 500

# Authentication endpoint
@app.route('/api/auth', methods=['POST'])
def authenticate():
    username = request.json.get('username')
    password = request.json.get('password')
    
    # Validate credentials against AD
    # This is simplified - actual implementation would use LDAP
    if validate_ad_credentials(username, password):
        access_token = create_access_token(identity=username)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify(error='Invalid credentials'), 401

# API endpoints
api.add_resource(CertificateRequest, '/api/certificate/request')
api.add_resource(CertificateRetrieval, '/api/certificate/<string:serial>')
api.add_resource(CertificateRevocation, '/api/certificate/<string:serial>/revoke')
api.add_resource(CertificateValidation, '/api/certificate/validate')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, ssl_context='adhoc')
```

## Phase 3 Validation

### Integration Testing Suite
```powershell
# Test-Phase3Integration.ps1
# Comprehensive testing of Phase 3 integrations

function Test-Phase3Integrations {
    $results = @()
    
    # Test 1: Code Signing Service
    Write-Host "`nTesting Code Signing Service..." -ForegroundColor Cyan
    
    $testFile = "C:\Test\TestApp.exe"
    $signRequest = @{
        Uri = "https://codesign.company.com.au/api/sign"
        Method = "POST"
        Body = @{
            RequestId = [Guid]::NewGuid()
            FileName = "TestApp.exe"
            FileContent = [Convert]::ToBase64String([IO.File]::ReadAllBytes($testFile))
            Purpose = "Testing"
        } | ConvertTo-Json
        ContentType = "application/json"
    }
    
    try {
        $response = Invoke-RestMethod @signRequest
        if ($response.SignedFile) {
            $results += @{Test = "Code Signing"; Result = "PASSED"}
            Write-Host "✓ Code signing service operational" -ForegroundColor Green
        }
    } catch {
        $results += @{Test = "Code Signing"; Result = "FAILED"; Error = $_.Exception.Message}
        Write-Host "✗ Code signing failed: $_" -ForegroundColor Red
    }
    
    # Test 2: SCCM Certificate Deployment
    Write-Host "`nTesting SCCM Integration..." -ForegroundColor Cyan
    
    $sccmStatus = Get-WmiObject -Namespace "root\ccm\clientsdk" `
        -Class CCM_ClientUtilities -ComputerName "localhost" |
        Select-Object -ExpandProperty PKICertificate
    
    if ($sccmStatus) {
        $results += @{Test = "SCCM Deployment"; Result = "PASSED"}
        Write-Host "✓ SCCM certificate deployment working" -ForegroundColor Green
    } else {
        $results += @{Test = "SCCM Deployment"; Result = "FAILED"}
        Write-Host "✗ SCCM certificate not found" -ForegroundColor Red
    }
    
    # Test 3: Azure Services Automation
    Write-Host "`nTesting Azure Services..." -ForegroundColor Cyan
    
    $kvCerts = Get-AzKeyVaultCertificate -VaultName "KV-PKI-Services-Prod"
    $expiringSoon = $kvCerts | Where-Object {
        ($_.Attributes.Expires - (Get-Date)).Days -lt 90
    }
    
    if ($kvCerts.Count -gt 0 -and $expiringSoon.Count -eq 0) {
        $results += @{Test = "Azure Automation"; Result = "PASSED"}
        Write-Host "✓ Azure certificate automation healthy" -ForegroundColor Green
    } else {
        $results += @{Test = "Azure Automation"; Result = "WARNING"; 
                      Note = "$($expiringSoon.Count) certificates expiring soon"}
        Write-Host "⚠ $($expiringSoon.Count) certificates need attention" -ForegroundColor Yellow
    }
    
    # Test 4: Load Balancer SSL
    Write-Host "`nTesting Load Balancer SSL..." -ForegroundColor Cyan
    
    $sslTest = Test-NetConnection -ComputerName "portal.company.com.au" -Port 443
    
    if ($sslTest.TcpTestSucceeded) {
        # Check SSL certificate
        $cert = Invoke-RestMethod -Uri "https://portal.company.com.au" -Method Head
        $results += @{Test = "Load Balancer SSL"; Result = "PASSED"}
        Write-Host "✓ Load balancer SSL configured" -ForegroundColor Green
    } else {
        $results += @{Test = "Load Balancer SSL"; Result = "FAILED"}
        Write-Host "✗ Load balancer SSL not responding" -ForegroundColor Red
    }
    
    # Test 5: API Functionality
    Write-Host "`nTesting PKI API..." -ForegroundColor Cyan
    
    # Get auth token
    $authResponse = Invoke-RestMethod -Uri "https://api-pki.company.com.au/api/auth" `
        -Method Post `
        -Body (@{username = "apitest"; password = "Test123!"} | ConvertTo-Json) `
        -ContentType "application/json"
    
    if ($authResponse.access_token) {
        # Test certificate request endpoint
        $headers = @{Authorization = "Bearer $($authResponse.access_token)"}
        
        $testRequest = @{
            template = "Company-Web-Server"
            subject = "/CN=apitest.company.com.au"
            san = "apitest.company.com.au"
        }
        
        $apiResponse = Invoke-RestMethod -Uri "https://api-pki.company.com.au/api/certificate/request" `
            -Method Post `
            -Headers $headers `
            -Body ($testRequest | ConvertTo-Json) `
            -ContentType "application/json"
        
        if ($apiResponse.serial) {
            $results += @{Test = "PKI API"; Result = "PASSED"}
            Write-Host "✓ PKI API operational" -ForegroundColor Green
        }
    } else {
        $results += @{Test = "PKI API"; Result = "FAILED"}
        Write-Host "✗ PKI API authentication failed" -ForegroundColor Red
    }
    
    # Generate summary
    Write-Host "`n========== Phase 3 Integration Test Summary ==========" -ForegroundColor Cyan
    
    $passed = ($results | Where-Object {$_.Result -eq "PASSED"}).Count
    $failed = ($results | Where-Object {$_.Result -eq "FAILED"}).Count
    $warnings = ($results | Where-Object {$_.Result -eq "WARNING"}).Count
    
    Write-Host "Passed: $passed" -ForegroundColor Green
    Write-Host "Failed: $failed" -ForegroundColor Red
    Write-Host "Warnings: $warnings" -ForegroundColor Yellow
    
    return $results
}

# Run tests
$testResults = Test-Phase3Integrations

# Export results
$testResults | Export-Csv -Path "C:\PKI\TestResults\Phase3-Integration-$(Get-Date -Format 'yyyyMMdd').csv"
```

## Phase 3 Deliverables

### Technical Deliverables
- ✅ Code signing service with approval workflow
- ✅ SCCM integration with 10,000+ endpoints
- ✅ Azure services certificate automation
- ✅ NetScaler/F5 SSL configuration
- ✅ Zscaler PKI trust integration
- ✅ Comprehensive monitoring dashboards
- ✅ REST API for certificate operations
- ✅ Automation scripts and runbooks

### Documentation Deliverables
- ✅ Code signing procedures and policies
- ✅ SCCM certificate deployment guide
- ✅ Azure automation runbooks
- ✅ Load balancer SSL configuration
- ✅ API documentation and examples
- ✅ Monitoring and alerting guide
- ✅ Integration test results

### Operational Readiness
- ✅ All services integrated and tested
- ✅ Monitoring alerts configured
- ✅ Automation workflows active
- ✅ API endpoints documented
- ✅ Support procedures established

---

**Document Control**
- Version: 1.0
- Last Updated: March 2025
- Next Review: End of Phase 4
- Owner: PKI Implementation Team
- Classification: Confidential

---
[← Previous: Phase 2 Core Infrastructure](06-phase2-core-infrastructure.md) | [Back to Index](00-index.md) | [Next: Phase 4 Migration Strategy →](08-phase4-migration-strategy.md)