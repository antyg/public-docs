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
    Name               = $ServiceServer
    ResourceGroupName  = $ResourceGroup
    Location           = "australiaeast"
    Size               = "Standard_D4s_v5"
    Image              = "Win2022Datacenter"
    VirtualNetworkName = "VNET-PKI-PROD"
    SubnetName         = "PKI-Services"
    PrivateIpAddress   = "10.50.4.10"
    SecurityGroupName  = "NSG-PKI-CodeSign"
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
        @{Identity = "SYSTEM"; Rights = "FullControl" },
        @{Identity = "Administrators"; Rights = "FullControl" },
        @{Identity = "CodeSign-Service"; Rights = "Modify" },
        @{Identity = "CodeSign-Approvers"; Rights = "Read" }
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
