# Deploy-CertificateTemplates.ps1
# Creates and configures all certificate templates

Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {

    # Load AD CS PowerShell module
    Import-Module ActiveDirectory

    # Function to create certificate template
    function New-CertificateTemplate {
        param(
            [string]$TemplateName,
            [string]$DisplayName,
            [string]$TemplateOID,
            [int]$ValidityPeriodYears,
            [int]$RenewalPeriod,
            [string[]]$ApplicationPolicies,
            [string[]]$AllowedPrincipals,
            [bool]$AutoEnrollment = $false,
            [string]$KeySpec = "KeyExchange",
            [int]$MinimumKeySize = 2048
        )

        # Certificate template creation via LDAP
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
        $TemplateContainer = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"

        # Create template object
        $NewTemplate = $TemplateContainer.Create("pKICertificateTemplate", "CN=$TemplateName")

        # Set template properties
        $NewTemplate.Put("displayName", $DisplayName)
        $NewTemplate.Put("flags", 131680)  # Autoenrollment flags
        $NewTemplate.Put("revision", 100)
        $NewTemplate.Put("pKIDefaultKeySpec", 1)

        # Set validity period
        $ValidityPeriod = New-TimeSpan -Days ($ValidityPeriodYears * 365)
        $NewTemplate.Put("pKIExpirationPeriod", $ValidityPeriod.TotalSeconds)

        # Set renewal period
        $RenewalPeriodSpan = New-TimeSpan -Days $RenewalPeriod
        $NewTemplate.Put("pKIOverlapPeriod", $RenewalPeriodSpan.TotalSeconds)

        # Set minimum key size
        $NewTemplate.Put("pKIDefaultCSPs", "1,Microsoft RSA SChannel Cryptographic Provider")
        $NewTemplate.Put("pKIMinimumKeySize", $MinimumKeySize)

        # Set application policies
        $NewTemplate.Put("pKIExtendedKeyUsage", $ApplicationPolicies)

        # Commit changes
        $NewTemplate.SetInfo()

        Write-Host "Template $DisplayName created successfully" -ForegroundColor Green
    }

    # Create User Certificate Templates
    $userTemplates = @(
        @{
            Name          = "Company-User-Authentication"
            DisplayName   = "Company User Authentication"
            OID           = "1.3.6.1.4.1.company.2.1.1"
            ValidityYears = 1
            RenewalDays   = 30
            AppPolicies   = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals    = @("Domain Users")
            AutoEnroll    = $true
        },
        @{
            Name          = "Company-User-Email"
            DisplayName   = "Company User Email (S/MIME)"
            OID           = "1.3.6.1.4.1.company.2.1.2"
            ValidityYears = 1
            RenewalDays   = 30
            AppPolicies   = @("1.3.6.1.5.5.7.3.4")  # Email Protection
            Principals    = @("Domain Users")
            AutoEnroll    = $true
        },
        @{
            Name          = "Company-User-EFS"
            DisplayName   = "Company User EFS"
            OID           = "1.3.6.1.4.1.company.2.1.3"
            ValidityYears = 2
            RenewalDays   = 60
            AppPolicies   = @("1.3.6.1.4.1.311.10.3.4")  # EFS
            Principals    = @("Domain Users")
            AutoEnroll    = $false
        }
    )

    # Create Computer Certificate Templates
    $computerTemplates = @(
        @{
            Name          = "Company-Computer-Authentication"
            DisplayName   = "Company Computer Authentication"
            OID           = "1.3.6.1.4.1.company.2.2.1"
            ValidityYears = 2
            RenewalDays   = 60
            AppPolicies   = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals    = @("Domain Computers")
            AutoEnroll    = $true
        },
        @{
            Name          = "Company-Domain-Controller"
            DisplayName   = "Company Domain Controller"
            OID           = "1.3.6.1.4.1.company.2.2.2"
            ValidityYears = 3
            RenewalDays   = 90
            AppPolicies   = @("1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2")  # Server + Client Auth
            Principals    = @("Domain Controllers")
            AutoEnroll    = $true
            KeySize       = 4096
        },
        @{
            Name          = "Company-Web-Server"
            DisplayName   = "Company Web Server"
            OID           = "1.3.6.1.4.1.company.2.2.3"
            ValidityYears = 1
            RenewalDays   = 30
            AppPolicies   = @("1.3.6.1.5.5.7.3.1")  # Server Authentication
            Principals    = @("Domain Computers")
            AutoEnroll    = $false
        }
    )

    # Create Special Purpose Templates
    $specialTemplates = @(
        @{
            Name          = "Company-Code-Signing"
            DisplayName   = "Company Code Signing"
            OID           = "1.3.6.1.4.1.company.2.3.1"
            ValidityYears = 1
            RenewalDays   = 60
            AppPolicies   = @("1.3.6.1.5.5.7.3.3")  # Code Signing
            Principals    = @("Code Signing Users")
            AutoEnroll    = $false
            KeySize       = 4096
        },
        @{
            Name          = "Company-OCSP-Signing"
            DisplayName   = "Company OCSP Signing"
            OID           = "1.3.6.1.4.1.company.2.3.2"
            ValidityYears = 0.038  # 2 weeks
            RenewalDays   = 7
            AppPolicies   = @("1.3.6.1.5.5.7.3.9")  # OCSP Signing
            Principals    = @("PKI-Servers")
            AutoEnroll    = $true
        },
        @{
            Name          = "Company-Mobile-Device"
            DisplayName   = "Company Mobile Device (SCEP)"
            OID           = "1.3.6.1.4.1.company.2.3.3"
            ValidityYears = 2
            RenewalDays   = 60
            AppPolicies   = @("1.3.6.1.5.5.7.3.2")  # Client Authentication
            Principals    = @("Domain Computers", "svc-NDES")
            AutoEnroll    = $false
        }
    )

    # Deploy all templates
    $allTemplates = $userTemplates + $computerTemplates + $specialTemplates

    foreach ($template in $allTemplates) {
        New-CertificateTemplate @template
    }

    Write-Host "All certificate templates deployed successfully!" -ForegroundColor Green
}

# Publish templates to CAs
Invoke-Command -ComputerName "PKI-ICA-01" -ScriptBlock {
    # Get CA name
    $CAName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration").Active

    # Templates to publish
    $templates = @(
        "Company-User-Authentication",
        "Company-User-Email",
        "Company-User-EFS",
        "Company-Computer-Authentication",
        "Company-Domain-Controller",
        "Company-Web-Server",
        "Company-Code-Signing",
        "Company-OCSP-Signing",
        "Company-Mobile-Device"
    )

    foreach ($template in $templates) {
        certutil -SetCATemplates +$template
    }

    # Restart CA service
    Restart-Service CertSvc

    Write-Host "Templates published to CA" -ForegroundColor Green
}

# Repeat for PKI-ICA-02
Invoke-Command -ComputerName "PKI-ICA-02" -ScriptBlock {
    # [Same template publishing commands]
}
