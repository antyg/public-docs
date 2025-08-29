# Monitor-PKISecurity.ps1
# Security monitoring and threat detection

function Start-PKISecurityMonitoring {
    $securityEvents = @()

    # Monitor for suspicious certificate requests
    $suspiciousRequests = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID      = 4886  # Certificate request
    } | Where-Object {
        $_.Message -match "Code Signing" -or
        $_.Message -match "high-value template"
    }

    foreach ($event in $suspiciousRequests) {
        $securityEvents += @{
            Type    = "Suspicious Request"
            Time    = $event.TimeCreated
            User    = $event.UserId
            Details = $event.Message
        }
    }

    # Monitor for multiple failed requests
    $failedRequests = Get-WinEvent -FilterHashtable @{
        LogName = 'Application'
        ID      = 100  # Failed certificate request
    } | Group-Object UserId | Where-Object { $_.Count -gt 5 }

    foreach ($group in $failedRequests) {
        $securityEvents += @{
            Type   = "Multiple Failed Requests"
            User   = $group.Name
            Count  = $group.Count
            Action = "Investigate potential attack"
        }
    }

    # Monitor for unauthorized template modifications
    $templateChanges = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID      = 4899  # Template modified
    }

    foreach ($event in $templateChanges) {
        if ($event.UserId -notin $authorizedAdmins) {
            $securityEvents += @{
                Type   = "Unauthorized Template Change"
                Time   = $event.TimeCreated
                User   = $event.UserId
                Action = "Revert change and investigate"
            }
        }
    }

    # Alert on critical security events
    if ($securityEvents.Count -gt 0) {
        Send-SecurityAlert -Events $securityEvents -Priority "High"
    }

    return $securityEvents
}
