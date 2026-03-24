# Manage-CertificateTemplates.ps1
# Certificate template management procedures

function New-CertificateTemplate {
    param(
        [string]$TemplateName,
        [string]$DisplayName,
        [string]$BasedOn = "Computer",
        [int]$ValidityPeriod = 365,
        [int]$RenewalPeriod = 60,
        [string[]]$ApplicationPolicies,
        [string[]]$AllowedPrincipals
    )

    # Duplicate existing template
    $sourceTemplate = Get-CATemplate -Name $BasedOn

    # Create new template
    $newTemplate = $sourceTemplate.PSObject.Copy()
    $newTemplate.Name = $TemplateName
    $newTemplate.DisplayName = $DisplayName

    # Set validity period
    $newTemplate.'pKIExpirationPeriod' = [System.BitConverter]::GetBytes($ValidityPeriod * -864000000000)
    $newTemplate.'pKIOverlapPeriod' = [System.BitConverter]::GetBytes($RenewalPeriod * -864000000000)

    # Set application policies
    if ($ApplicationPolicies) {
        $newTemplate.'pKIExtendedKeyUsage' = $ApplicationPolicies
    }

    # Set permissions
    $acl = Get-Acl "AD:CN=$BasedOn,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=company,DC=local"

    foreach ($principal in $AllowedPrincipals) {
        $permission = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            (Get-ADUser $principal).SID,
            "GenericAll",
            "Allow"
        )
        $acl.AddAccessRule($permission)
    }

    # Create template in AD
    $templatePath = "CN=$TemplateName,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=company,DC=local"
    New-ADObject -Type pKICertificateTemplate -Path $templatePath -OtherAttributes $newTemplate

    # Set ACL
    Set-Acl -Path "AD:$templatePath" -AclObject $acl

    # Publish to CAs
    Publish-CATemplate -Template $TemplateName

    Write-Host "Template '$DisplayName' created successfully" -ForegroundColor Green
}

function Modify-CertificateTemplate {
    param(
        [string]$TemplateName,
        [hashtable]$Changes
    )

    # Get current template
    $template = Get-CATemplate -Name $TemplateName

    # Apply changes
    foreach ($change in $Changes.GetEnumerator()) {
        $template.($change.Key) = $change.Value
    }

    # Update template
    Set-ADObject -Identity $template.DistinguishedName -Replace $Changes

    # Increment version number
    $version = [int]$template.revision + 1
    Set-ADObject -Identity $template.DistinguishedName -Replace @{revision = $version }

    # Force replication
    Sync-CATemplates

    Write-Host "Template '$TemplateName' updated successfully" -ForegroundColor Green
}
