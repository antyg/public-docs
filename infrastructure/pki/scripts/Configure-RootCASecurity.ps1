# Configure-RootCASecurity.ps1
# Implements security controls for Root CA

# Enable audit logging
$auditConfig = @{
    Enabled       = $true
    LogLevel      = "Verbose"
    RetentionDays = 2555  # 7 years
    Categories    = @(
        "CertificateIssued",
        "CertificateRevoked",
        "CRLPublished",
        "ConfigurationChanged",
        "SecurityEventOccurred"
    )
}

Set-AzPrivateCAuditConfiguration `
    -CAName $CAName `
    -ResourceGroupName $ResourceGroup `
    -Configuration $auditConfig

# Configure access control
$accessPolicies = @(
    @{
        PrincipalId = (Get-AzADGroup -DisplayName "PKI-Administrators").Id
        Role        = "CA Administrator"
        Permissions = @("All")
    },
    @{
        PrincipalId = (Get-AzADGroup -DisplayName "PKI-Operators").Id
        Role        = "CA Operator"
        Permissions = @("Issue", "Revoke", "Read")
    },
    @{
        PrincipalId = (Get-AzADGroup -DisplayName "PKI-Auditors").Id
        Role        = "CA Auditor"
        Permissions = @("Read", "Audit")
    }
)

foreach ($policy in $accessPolicies) {
    Set-AzPrivateCAAccessPolicy @policy
}

# Configure security alerts
$alertRules = @(
    @{
        Name        = "UnauthorizedAccess"
        Description = "Alert on unauthorized access attempts"
        Condition   = "Failed authentication > 3 in 5 minutes"
        Action      = "Email PKI-Security@company.com.au"
    },
    @{
        Name        = "CertificateAnomalies"
        Description = "Alert on unusual certificate issuance patterns"
        Condition   = "Certificate count > 100 per hour"
        Action      = "Email PKI-Team@company.com.au"
    },
    @{
        Name        = "ConfigurationChange"
        Description = "Alert on CA configuration changes"
        Condition   = "Any configuration modification"
        Action      = "Email PKI-Administrators@company.com.au"
    }
)

foreach ($rule in $alertRules) {
    New-AzPrivateCAAlertRule @rule
}
