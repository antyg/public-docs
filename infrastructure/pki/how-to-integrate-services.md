---
title: "How to Integrate Services with the PKI Infrastructure"
status: "draft"
last_updated: "2026-03-17"
audience: "Infrastructure Engineers"
document_type: "how-to"
domain: "infrastructure"
platform: "PKI"
---

# How to Integrate Services with the PKI Infrastructure

This guide covers integrating enterprise services with the PKI after the foundation is operational. It covers NDES/SCEP for mobile device enrolment, Microsoft Intune certificate delivery, load balancer and proxy certificate configuration, and application certificate integration.

## Prerequisites

Before starting service integration, confirm:

- Both issuing CAs (`PKI-ICA-01`, `PKI-ICA-02`) are operational with `CertSvc` running
- Certificate templates are published (see [how-to-deploy-foundation.md](how-to-deploy-foundation.md))
- NDES server (`PKI-NDES-01`) is domain-joined and reachable
- DNS record `ndes.company.com.au` resolves to the NDES server or load balancer VIP
- Microsoft Intune tenant is licensed and the Intune administrator account has Intune Service Administrator role
- NetScaler, F5, or Zscaler appliance credentials are available
- SCCM/ConfigMgr environment is operational if using SCCM-based certificate deployment
- Firewall rules permit port 443 inbound to the NDES URL from managed devices

## Deploy NDES for Mobile Device Enrolment

NDES (Network Device Enrollment Service) provides SCEP (Simple Certificate Enrolment Protocol) support for devices that cannot use native AD CS enrolment — primarily mobile devices and network appliances. See [NDES overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/network-device-enrollment-service-overview) for architecture details.

### Step 1: Create the NDES Service Account

Create a dedicated service account in the `Service-Accounts` OU before installing the NDES role:

```powershell
Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    Import-Module ActiveDirectory

    $password = ConvertTo-SecureString "$(Get-SecurePassword)" -AsPlainText -Force
    New-ADUser -Name "svc-NDES" `
        -UserPrincipalName "svc-NDES@company.local" `
        -Path "OU=Service-Accounts,DC=company,DC=local" `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -CannotChangePassword $true

    Add-ADGroupMember -Identity "IIS_IUSRS" -Members "svc-NDES"
}
```

The service account must be granted `Log on as a service` rights via Group Policy or local security policy on the NDES server.

### Step 2: Install and Configure NDES

Install the NDES role and configure it against `PKI-ICA-01`:

```powershell
Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    Install-WindowsFeature -Name ADCS-Device-Enrollment,Web-Server,Web-Common-Http,`
        Web-Filtering,Web-Net-Ext45,Web-Asp-Net45,Web-ISAPI-Ext,Web-ISAPI-Filter `
        -IncludeManagementTools

    Import-Module ADCSDeployment

    Install-ADCSNetworkDeviceEnrollmentService `
        -ApplicationPoolIdentity `
        -RAName "Company-NDES-RA" `
        -RACountry "AU" `
        -RACompany "Company Australia" `
        -RACity "Sydney" `
        -RAState "NSW" `
        -CAConfig "PKI-ICA-01.company.local\Company Issuing CA 01" `
        -Force
}
```

### Step 3: Configure the IIS Application Pool and Registry

Set the application pool to run under the `svc-NDES` service account and configure NDES registry settings:

```powershell
Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    Import-Module WebAdministration

    Set-ItemProperty -Path "IIS:\AppPools\SCEP" `
        -Name processIdentity.identityType -Value SpecificUser
    Set-ItemProperty -Path "IIS:\AppPools\SCEP" `
        -Name processIdentity.userName -Value "company\svc-NDES"
    Set-ItemProperty -Path "IIS:\AppPools\SCEP" `
        -Name processIdentity.password -Value (Get-ServiceAccountPassword "svc-NDES")

    # Point NDES at the mobile device certificate template
    $regPath = "HKLM:\SOFTWARE\Microsoft\Cryptography\MSCEP"
    Set-ItemProperty -Path $regPath -Name "EncryptionTemplate"   -Value "Company-Mobile-Device"
    Set-ItemProperty -Path $regPath -Name "GeneralPurposeTemplate" -Value "Company-Mobile-Device"
    Set-ItemProperty -Path $regPath -Name "SignatureTemplate"    -Value "Company-Mobile-Device"

    # Configure one-time password cache
    Set-ItemProperty -Path $regPath -Name "PasswordMax"      -Value 100
    Set-ItemProperty -Path $regPath -Name "PasswordLength"   -Value 16
    Set-ItemProperty -Path $regPath -Name "PasswordValidity" -Value 60  # minutes

    iisreset /restart
}
```

Verify NDES is responding by requesting the CA certificate chain:

```powershell
$scepUrl = "https://ndes.company.com.au/certsrv/mscep/mscep.dll"
$response = Invoke-WebRequest -Uri "$scepUrl?operation=GetCACert" -Method Get
Write-Host "NDES CA cert response: $($response.StatusCode)"
```

## Deploy the Microsoft Intune Certificate Connector

The [Intune Certificate Connector](https://learn.microsoft.com/en-us/mem/intune/protect/certificate-connector-overview) bridges Microsoft Intune and the NDES/SCEP infrastructure. It must be installed on the NDES server.

### Step 1: Install the Connector

Download and install the connector on `PKI-NDES-01`:

```powershell
$connectorUrl = "https://go.microsoft.com/fwlink/?LinkId=833842"
$installerPath = "C:\Temp\IntuneCertificateConnector.msi"

Invoke-WebRequest -Uri $connectorUrl -OutFile $installerPath

Invoke-Command -ComputerName "PKI-NDES-01" -ScriptBlock {
    param($installer)
    Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait
} -ArgumentList $installerPath
```

### Step 2: Authorise the Connector in Intune

Complete this step interactively on the NDES server:

1. RDP to `PKI-NDES-01`
2. Launch **Microsoft Intune Certificate Connector** from the Start menu
3. Sign in with Intune administrator credentials
4. Select **SCEP** as the profile type
5. Enter the NDES URL: `https://ndes.company.com.au/certsrv/mscep/mscep.dll`
6. Select the client certificate for connector authentication
7. Click **Test** — confirm the connection test passes
8. Click **Save**

Verify the connector appears as **Active** in the [Intune admin centre](https://intune.microsoft.com) under Tenant administration > Connectors and tokens > Certificate connectors.

### Step 3: Create a SCEP Certificate Profile in Intune

Create and deploy a SCEP profile for Windows devices through the Intune admin centre under Devices > Configuration profiles > Create profile. Key settings:

| Setting | Value |
|---|---|
| Profile type | SCEP certificate |
| SCEP server URL | `https://ndes.company.com.au/certsrv/mscep/mscep.dll` |
| Subject name format | `CN={{DeviceId}},OU=Mobile,O=Company` |
| Key usage | Digital Signature, Key Encipherment |
| Key size | 2048 |
| Hash algorithm | SHA-2 |
| Extended key usage | Client Authentication (1.3.6.1.5.5.7.3.2) |
| Certificate validity period | 2 years |
| Renewal threshold | 20% |

Assign the profile to the appropriate device groups. See [SCEP profile configuration in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure) for the full configuration reference.

## Configure NetScaler SSL/TLS Certificates

Citrix NetScaler (now Citrix ADC) requires certificates from the enterprise PKI for TLS offload on virtual servers.

### Step 1: Request a Web Server Certificate

Request a certificate for the NetScaler VIP DNS name using the `Company-Web-Server` template:

```powershell
# Run on a domain-joined workstation with certutil
certreq -new -f netscaler-req.inf netscaler.csr
```

The INF file must specify:
- `Subject = "CN=netscaler.company.com.au,O=Company Australia,C=AU"`
- `KeySpec = 1` (key exchange)
- `KeyLength = 2048`
- `HashAlgorithm = SHA256`
- `MachineKeySet = TRUE`

Submit the CSR to the CA and retrieve the issued certificate:

```powershell
certreq -submit -config "PKI-ICA-01.company.local\Company Issuing CA 01" `
    netscaler.csr netscaler.crt
```

### Step 2: Install the Certificate on NetScaler

Export the certificate and private key as a PFX, then import to NetScaler. On the management workstation:

```powershell
certreq -accept netscaler.crt
$cert = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*netscaler*" }
Export-PfxCertificate -Cert $cert -FilePath "netscaler.pfx" `
    -Password (ConvertTo-SecureString "ExportPassword" -AsPlainText -Force)
```

Import the PFX and root/intermediate CA certificates through the NetScaler GUI: **Traffic Management > SSL > Certificates > Install**. Bind the certificate to the relevant SSL virtual servers under **Traffic Management > Load Balancing > Virtual Servers**, then select the SSL profile.

See [Citrix ADC SSL certificate management](https://docs.citrix.com/en-us/citrix-adc/current-release/ssl/ssl-certificates.html) for detailed procedures.

### Step 3: Configure the Root and Issuing CA Certificate Trust

NetScaler must trust the full certificate chain to perform client certificate validation:

1. In the NetScaler GUI, navigate to **Traffic Management > SSL > CA Certificates**
2. Import `RootCA-G2.crt` and both issuing CA certificates (`ICA01.crt`, `ICA02.crt`)
3. Link the issuing CA certificates to the root CA certificate
4. In the SSL virtual server profile, add the CA certificate chain to the **CA Certificate** binding

## Configure F5 BIG-IP SSL Certificates

F5 BIG-IP uses certificate bundles for SSL profile configuration.

### Step 1: Import Certificates to F5

Copy the certificate, private key, and CA chain to the F5 management interface or use the `tmsh` CLI:

```bash
# Import root and intermediate CA certificates
tmsh install sys crypto cert RootCA-G2 from-local-file /var/tmp/RootCA-G2.crt
tmsh install sys crypto cert IssuingCA01 from-local-file /var/tmp/ICA01.crt

# Import the server certificate and key pair
tmsh install sys crypto cert netscaler-vip from-local-file /var/tmp/server.crt
tmsh install sys crypto key netscaler-vip from-local-file /var/tmp/server.key
```

### Step 2: Create and Apply the SSL Profile

```bash
# Create client SSL profile referencing the PKI certificates
tmsh create ltm profile client-ssl pki-ssl-profile \
    cert netscaler-vip \
    key netscaler-vip \
    chain IssuingCA01 \
    ca-file RootCA-G2

# Apply the SSL profile to the virtual server
tmsh modify ltm virtual vs_app_443 profiles add { pki-ssl-profile { context clientside } }
```

See [F5 SSL certificate management](https://techdocs.f5.com/en-us/bigip-16-1-0/big-ip-local-traffic-management-fundamentals/ssl-tls-termination.html) for profile configuration details.

## Configure Zscaler SSL Inspection

Zscaler Private Access and Zscaler Internet Access require the enterprise root CA certificate to be trusted for SSL inspection. This allows Zscaler to inspect HTTPS traffic without generating untrusted certificate warnings on client devices.

### Step 1: Export the Root CA Certificate

Export the root CA certificate in DER format from the Azure portal or using certutil:

```powershell
# Export root CA certificate from the trusted root store
$rootCert = Get-ChildItem Cert:\LocalMachine\Root |
    Where-Object { $_.Subject -like "*Root CA G2*" }
Export-Certificate -Cert $rootCert -FilePath "C:\PKI\RootCA-G2.cer" -Type CERT
```

### Step 2: Upload to Zscaler

In the Zscaler admin portal:

1. Navigate to **Administration > Authentication > Certificate Management**
2. Select **Custom CA Certificate**
3. Upload `RootCA-G2.cer`
4. Enable the certificate for SSL inspection
5. Apply the configuration

If Zscaler is performing forward proxy SSL inspection, also configure the Zscaler intermediate CA certificate to be trusted on all managed endpoints. Deploy it via Group Policy as a trusted certificate authority. See [Zscaler SSL inspection configuration](https://help.zscaler.com/zia/about-ssl-inspection) for the full procedure.

### Step 3: Configure Bypass Rules

Create SSL inspection bypass rules in Zscaler for:
- Internal PKI services (`crl.company.com.au`, `ocsp.company.com.au`, `pki.company.com.au`)
- Certificate transparency logs
- Any applications that use certificate pinning

## Configure Certificate Auto-Enrolment GPO

If the auto-enrolment GPOs from the foundation deployment are not yet applied to all required OUs, extend them now.

### Verify GPO Application

On a domain-joined workstation, confirm the GPO is being received and certificates are being issued:

```powershell
# Check which GPOs are applied
gpresult /R /Scope Computer

# Trigger immediate auto-enrolment
certutil -pulse

# Verify certificates were issued
Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*company*" } |
    Select-Object Subject, NotAfter, Thumbprint
```

### Extend Auto-Enrolment to Additional OUs

Link the existing GPOs to any OUs not yet covered:

```powershell
Import-Module GroupPolicy

$additionalOUs = @(
    "OU=Remote-Workstations,DC=company,DC=local",
    "OU=Kiosks,DC=company,DC=local"
)

foreach ($ou in $additionalOUs) {
    New-GPLink -Name "PKI-Computer-AutoEnrollment" -Target $ou -LinkEnabled Yes
}

# Force GP update on affected machines
Invoke-Command -ComputerName (Get-ADComputer -Filter * -SearchBase $additionalOUs[0]).Name -ScriptBlock {
    gpupdate /force
} -ErrorAction SilentlyContinue
```

## Integrate Web Servers and Application Certificates

Web servers that cannot use auto-enrolment require manual or scripted certificate requests.

### Request and Bind a Web Server Certificate via IIS

On a domain-joined IIS server, use the IIS Manager or the following PowerShell to request and bind a certificate:

```powershell
# Request via the CA web enrolment interface or directly via Get-Certificate
$cert = Get-Certificate `
    -Template "Company-Web-Server" `
    -DnsName "app.company.com.au" `
    -SubjectName "CN=app.company.com.au" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -Url "https://pki-ica-01.company.local/certsrv"

if ($cert.Status -eq "Issued") {
    # Bind to IIS HTTPS listener
    Import-Module WebAdministration
    New-WebBinding -Name "Default Web Site" -Protocol "https" -Port 443 -HostHeader "app.company.com.au"
    $binding = Get-WebBinding -Name "Default Web Site" -Protocol "https"
    $binding.AddSslCertificate($cert.Certificate.Thumbprint, "My")
    Write-Host "Certificate bound successfully"
}
```

See [IIS SSL certificate binding](https://learn.microsoft.com/en-us/iis/manage/configuring-security/how-to-set-up-ssl-on-iis) for detailed binding procedures.

### Automate Certificate Lifecycle for Applications

For applications that need automated renewal, configure a scheduled task to run `certutil -pulse` or use the [Windows Certificate Services client API](https://learn.microsoft.com/en-us/windows/win32/seccrypto/certificate-services-architecture) to request renewals programmatically. Set renewal to trigger at 20% of certificate lifetime remaining (for a 1-year certificate, this is approximately 73 days before expiry).

## Validation

After completing all service integrations, validate each component:

```powershell
# Test NDES SCEP endpoint
$scepUrl = "https://ndes.company.com.au/certsrv/mscep/mscep.dll"
$ndesResponse = Invoke-WebRequest -Uri "$scepUrl?operation=GetCACert" -Method Get
Write-Host "NDES status: $($ndesResponse.StatusCode)"

# Confirm Intune connector is active
# Check in Intune admin centre: Tenant administration > Connectors and tokens > Certificate connectors

# Test auto-enrolment
certutil -pulse
Start-Sleep -Seconds 15
$certs = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.NotBefore -gt (Get-Date).AddMinutes(-5) }
Write-Host "Newly enrolled certificates: $($certs.Count)"

# Verify CRL and OCSP availability
$crlOK  = (Invoke-WebRequest "http://crl.company.com.au/IssuingCA01.crl").StatusCode -eq 200
$ocspOK = (Test-NetConnection "ocsp.company.com.au" -Port 80).TcpTestSucceeded
Write-Host "CRL accessible: $crlOK  |  OCSP accessible: $ocspOK"
```

For Zscaler, create a test HTTPS session through the proxy and confirm no SSL errors are generated for internal certificate chains.

## Troubleshooting

**NDES returns HTTP 403 when requesting the CA certificate**
Confirm the IIS application pool identity (`svc-NDES`) has the `Log on as a service` right. Check IIS authentication settings — the SCEP virtual directory must have Anonymous Authentication enabled and Windows Authentication disabled.

**Intune Certificate Connector shows as Inactive**
Confirm the NDES URL is reachable from the connector server. Check that the service account running the connector has the required permissions on the NDES server. Review the connector log at `%ProgramData%\Microsoft\Microsoft Intune Certificate Connector\Logs\`.

**NetScaler or F5 reports chain validation failure**
Confirm both the issuing CA certificate and root CA certificate are imported and linked on the appliance. The full chain (leaf > issuing CA > root CA) must be present. Check that the root CA is in the appliance's trusted CA store, not just the certificate store.

**Zscaler SSL inspection generating certificate errors on clients**
Confirm the root CA certificate has been deployed to all managed endpoints via Group Policy as a Trusted Root CA. Run `certmgr.msc` on an affected client and verify the root CA appears under Trusted Root Certification Authorities.

**SCEP profile not delivering certificates to mobile devices**
Verify the NDES URL is reachable from the device network segment on port 443. Confirm the `Company-Mobile-Device` template is published on both issuing CAs and that the `svc-NDES` service account has Enrol permission on the template.

## Related Resources

- [NDES overview and deployment](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/network-device-enrollment-service-overview)
- [Intune Certificate Connector overview](https://learn.microsoft.com/en-us/mem/intune/protect/certificate-connector-overview)
- [SCEP certificate profile configuration in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [Citrix ADC SSL certificate management](https://docs.citrix.com/en-us/citrix-adc/current-release/ssl/ssl-certificates.html)
- [F5 BIG-IP SSL/TLS termination](https://techdocs.f5.com/en-us/bigip-16-1-0/big-ip-local-traffic-management-fundamentals/ssl-tls-termination.html)
- [Zscaler SSL inspection configuration](https://help.zscaler.com/zia/about-ssl-inspection)
- [IIS SSL certificate binding](https://learn.microsoft.com/en-us/iis/manage/configuring-security/how-to-set-up-ssl-on-iis)
- [Certificate Auto-Enrollment in Windows](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/certificate-auto-enrollment)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
