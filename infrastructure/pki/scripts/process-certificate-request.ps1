# Process-CertificateRequest.ps1
# Processes certificate requests from service portal

function Process-CertificateRequest {
    param(
        [string]$RequestId,
        [string]$Template,
        [string]$Subject,
        [string[]]$SANs,
        [string]$Requester,
        [string]$Approver
    )

    try {
        # Validate request
        if (-not (Test-CertificateRequestValid -RequestId $RequestId)) {
            throw "Invalid request parameters"
        }

        # Check template permissions
        if (-not (Test-TemplatePermission -Template $Template -User $Requester)) {
            throw "User not authorized for template: $Template"
        }

        # Generate CSR
        $csr = New-CertificateRequest `
            -Subject $Subject `
            -SANs $SANs `
            -KeySize 2048

        # Submit to CA
        $result = Submit-CertificateRequest `
            -CA "PKI-ICA-01.company.local\Company Issuing CA 01" `
            -Template $Template `
            -CSR $csr

        if ($result.Status -eq "Issued") {
            # Retrieve certificate
            $cert = Get-IssuedCertificate -RequestId $result.RequestId

            # Deliver to requester
            Send-CertificateToRequester `
                -Certificate $cert `
                -Requester $Requester `
                -RequestId $RequestId

            # Update tracking
            Update-CertificateTracking `
                -RequestId $RequestId `
                -Status "Completed" `
                -CertificateSerial $cert.SerialNumber

            return @{
                Success      = $true
                RequestId    = $RequestId
                SerialNumber = $cert.SerialNumber
            }
        } else {
            throw "Certificate issuance failed: $($result.Status)"
        }

    } catch {
        # Log error
        Write-EventLog -LogName "PKI-Operations" -Source "CertRequest" `
            -EventId 2001 -EntryType Error `
            -Message "Request $RequestId failed: $_"

        # Update tracking
        Update-CertificateTracking `
            -RequestId $RequestId `
            -Status "Failed" `
            -ErrorMessage $_

        return @{
            Success   = $false
            RequestId = $RequestId
            Error     = $_.Exception.Message
        }
    }
}
