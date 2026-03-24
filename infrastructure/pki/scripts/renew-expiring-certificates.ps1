# Renew-ExpiringCertificates.ps1
# Automated certificate renewal process

function Start-CertificateRenewal {
    param(
        [int]$DaysBeforeExpiry = 30,
        [switch]$AutoApprove = $false
    )

    Write-Host "Starting certificate renewal process..." -ForegroundColor Cyan

    # Get expiring certificates
    $expiringCerts = Get-ADObject -Filter { objectClass -eq "pKICertificate" } -Properties * |
    Where-Object {
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($_.userCertificate[0])
        ($cert.NotAfter - (Get-Date)).Days -le $DaysBeforeExpiry
    }

    $renewalResults = @()

    foreach ($certObj in $expiringCerts) {
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certObj.userCertificate[0])

        Write-Host "Processing renewal for: $($cert.Subject)" -ForegroundColor Yellow

        # Determine template
        $template = Get-CertificateTemplate -Certificate $cert

        # Check if auto-renewal is enabled
        if ($template.AutoRenewal -or $AutoApprove) {
            # Generate renewal request
            $renewalRequest = New-CertificateRenewalRequest `
                -OldCertificate $cert `
                -Template $template.Name

            # Submit renewal
            $newCert = Submit-CertificateRenewal `
                -Request $renewalRequest `
                -CA "PKI-ICA-01.company.local\Company Issuing CA 01"

            if ($newCert) {
                # Replace old certificate
                Replace-Certificate `
                    -Old $cert `
                    -New $newCert `
                    -UpdateBindings $true

                $renewalResults += @{
                    Subject   = $cert.Subject
                    OldSerial = $cert.SerialNumber
                    NewSerial = $newCert.SerialNumber
                    Status    = "Success"
                }

                Write-Host "  ✓ Renewed successfully" -ForegroundColor Green
            } else {
                $renewalResults += @{
                    Subject   = $cert.Subject
                    OldSerial = $cert.SerialNumber
                    Status    = "Failed"
                    Error     = "Renewal submission failed"
                }

                Write-Host "  ✗ Renewal failed" -ForegroundColor Red
            }
        } else {
            # Create renewal request for manual approval
            New-PendingRenewal `
                -Certificate $cert `
                -Template $template.Name `
                -NotifyOwner $true

            $renewalResults += @{
                Subject   = $cert.Subject
                OldSerial = $cert.SerialNumber
                Status    = "Pending Approval"
            }

            Write-Host "  ⚠ Pending manual approval" -ForegroundColor Yellow
        }
    }

    # Generate renewal report
    $renewalResults | Export-Csv -Path "C:\PKI\Reports\Renewal-$(Get-Date -Format 'yyyyMMdd').csv"

    return $renewalResults
}
