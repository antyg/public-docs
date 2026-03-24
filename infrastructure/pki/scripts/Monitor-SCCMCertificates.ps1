# Monitor-SCCMCertificates.ps1
# Monitors certificate deployment through SCCM

# Get deployment status
$deploymentStatus = Get-CMCertificateProfileDeploymentStatus -Name "Windows Workstation Certificate"

$report = @{
    TotalTargeted = $deploymentStatus.NumberTargeted
    Successful    = $deploymentStatus.NumberSuccess
    InProgress    = $deploymentStatus.NumberInProgress
    Failed        = $deploymentStatus.NumberErrors
    Unknown       = $deploymentStatus.NumberUnknown
    SuccessRate   = [math]::Round(($deploymentStatus.NumberSuccess / $deploymentStatus.NumberTargeted) * 100, 2)
}

# Create detailed report
$detailedReport = Get-WmiObject -Namespace "root\SMS\site_$siteCode" `
    -Class SMS_CertificateInfo -ComputerName $siteServer |
Select-Object @{
    Name       = "ComputerName"
    Expression = { $_.ResourceName }
},
@{
    Name       = "CertificateType"
    Expression = { $_.CertificateType }
},
@{
    Name       = "Subject"
    Expression = { $_.Subject }
},
@{
    Name       = "Issuer"
    Expression = { $_.Issuer }
},
@{
    Name       = "ValidFrom"
    Expression = { [DateTime]::Parse($_.ValidFrom) }
},
@{
    Name       = "ValidTo"
    Expression = { [DateTime]::Parse($_.ValidTo) }
},
@{
    Name       = "DaysRemaining"
    Expression = { ([DateTime]::Parse($_.ValidTo) - (Get-Date)).Days }
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
