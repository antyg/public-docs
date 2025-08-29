# Revoke-Certificate.ps1
# Certificate revocation with audit trail

function Revoke-Certificate {
    param(
        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter(Mandatory)]
        [ValidateSet(
            "Unspecified",
            "KeyCompromise",
            "CACompromise",
            "AffiliationChanged",
            "Superseded",
            "CessationOfOperation",
            "CertificateHold"
        )]
        [string]$Reason,

        [string]$RequestedBy,
        [string]$ApprovedBy,
        [string]$Comments
    )

    # Validate authorization
    if (-not (Test-RevocationAuthorization -User $RequestedBy)) {
        throw "User not authorized to revoke certificates"
    }

    # Create audit record
    $auditRecord = @{
        Timestamp    = Get-Date
        SerialNumber = $SerialNumber
        Reason       = $Reason
        RequestedBy  = $RequestedBy
        ApprovedBy   = $ApprovedBy
        Comments     = $Comments
    }

    try {
        # Get certificate details
        $cert = Get-CACertificate -SerialNumber $SerialNumber

        # Perform revocation
        $result = certutil -revoke $SerialNumber $Reason

        if ($result -match "successfully revoked") {
            # Update CRL immediately for critical revocations
            if ($Reason -in @("KeyCompromise", "CACompromise")) {
                Publish-CRL -Force -Emergency
            }

            # Notify affected parties
            Send-RevocationNotification `
                -Certificate $cert `
                -Reason $Reason `
                -Recipients (Get-CertificateOwner -Certificate $cert)

            # Update audit log
            $auditRecord.Status = "Success"
            $auditRecord.RevokedAt = Get-Date

            Write-EventLog -LogName "PKI-Security" -Source "Revocation" `
                -EventId 3001 -EntryType Warning `
                -Message "Certificate $SerialNumber revoked: $Reason by $RequestedBy"

            return @{
                Success      = $true
                SerialNumber = $SerialNumber
                Message      = "Certificate successfully revoked"
            }
        } else {
            throw "Revocation failed: $result"
        }

    } catch {
        $auditRecord.Status = "Failed"
        $auditRecord.Error = $_.Exception.Message

        Write-EventLog -LogName "PKI-Security" -Source "Revocation" `
            -EventId 3002 -EntryType Error `
            -Message "Revocation failed for $SerialNumber : $_"

        throw

    } finally {
        # Always save audit record
        $auditRecord | Export-Csv -Path "C:\PKI\Audit\Revocations.csv" -Append
    }
}
