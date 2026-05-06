# Complete-Documentation.ps1
# Generates comprehensive PKI documentation

param(
    [string]$OutputPath = "C:\PKI\Documentation"
)

Write-Host "Generating comprehensive PKI documentation..." -ForegroundColor Cyan

# Create documentation structure
$docStructure = @(
    "Architecture",
    "Procedures",
    "Runbooks",
    "Policies",
    "Diagrams",
    "Scripts",
    "Reports"
)

foreach ($folder in $docStructure) {
    New-Item -ItemType Directory -Path "$OutputPath\$folder" -Force | Out-Null
}

# Generate architecture documentation
Write-Host "Creating architecture documentation..." -ForegroundColor Yellow

$architectureDoc = @"
# PKI Infrastructure Architecture

## Overview
The Company PKI infrastructure is a hybrid Azure-based solution providing enterprise certificate services.

## Components

### Azure Components
- **Azure Private CA**: Root Certificate Authority (Australia East)
- **Azure Key Vault**: HSM-protected key storage
- **Azure Automation**: Certificate lifecycle management

### On-Premises Components
- **Issuing CAs**: 2x Windows Server 2022 (PKI-ICA-01, PKI-ICA-02)
- **NDES Server**: Mobile device enrollment (PKI-NDES-01)
- **OCSP Responders**: 2x for high availability
- **Web Enrollment**: Certificate request portal

## Network Architecture
- Primary Site: Australia East
- DR Site: Australia Southeast
- Connectivity: ExpressRoute + VPN backup

## Certificate Templates
$(Get-CATemplate | Select-Object Name, Type, ValidityPeriod | ConvertTo-Markdown)

## Trust Relationships
- Internal: Active Directory integrated
- External: Zscaler, Partner organizations
- Cloud: Azure services, Microsoft 365
"@

$architectureDoc | Out-File "$OutputPath\Architecture\PKI-Architecture.md"

# Generate operational procedures
Write-Host "Creating operational procedures..." -ForegroundColor Yellow

$procedures = @{
    "Certificate-Request"    = "How to request certificates"
    "Certificate-Renewal"    = "Certificate renewal procedures"
    "Certificate-Revocation" = "Revocation procedures"
    "Template-Management"    = "Managing certificate templates"
    "Backup-Recovery"        = "Backup and recovery procedures"
    "Monitoring"             = "Monitoring and alerting"
}

foreach ($proc in $procedures.GetEnumerator()) {
    Generate-Procedure -Name $proc.Key -Description $proc.Value -OutputPath "$OutputPath\Procedures"
}

# Generate runbooks
Write-Host "Creating operational runbooks..." -ForegroundColor Yellow

$runbooks = @(
    @{
        Name     = "Daily-Health-Check"
        Script   = Get-Content "C:\PKI\Scripts\Test-PKIHealth.ps1" -Raw
        Schedule = "Daily at 08:00"
    },
    @{
        Name     = "Certificate-Expiry-Report"
        Script   = Get-Content "C:\PKI\Scripts\Get-ExpiringCertificates.ps1" -Raw
        Schedule = "Weekly on Monday"
    },
    @{
        Name     = "CRL-Publication"
        Script   = Get-Content "C:\PKI\Scripts\Publish-CRL.ps1" -Raw
        Schedule = "Every 7 days"
    }
)

foreach ($runbook in $runbooks) {
    $runbookDoc = @"
# Runbook: $($runbook.Name)

## Schedule
$($runbook.Schedule)

## Script
``````powershell
$($runbook.Script)
``````

## Notes
- Ensure service account has appropriate permissions
- Monitor execution logs for failures
- Escalate critical alerts immediately
"@

    $runbookDoc | Out-File "$OutputPath\Runbooks\$($runbook.Name).md"
}

# Generate network diagram
Write-Host "Creating network diagrams..." -ForegroundColor Yellow

$mermaidDiagram = @"
graph TB
    subgraph Azure Cloud
        AKV[Azure Key Vault<br/>HSM]
        APCA[Azure Private CA<br/>Root CA]
    end

    subgraph On-Premises
        ICA1[Issuing CA 01]
        ICA2[Issuing CA 02]
        NDES[NDES Server]
        OCSP[OCSP Responders]
    end

    subgraph Endpoints
        USERS[Users]
        COMPUTERS[Computers]
        MOBILE[Mobile Devices]
        SERVERS[Servers]
    end

    APCA --> ICA1
    APCA --> ICA2
    ICA1 --> USERS
    ICA1 --> COMPUTERS
    ICA2 --> SERVERS
    NDES --> MOBILE
"@

$mermaidDiagram | Out-File "$OutputPath\Diagrams\PKI-Overview.mmd"

# Compile all scripts
Write-Host "Organizing scripts..." -ForegroundColor Yellow

$scripts = Get-ChildItem -Path "C:\PKI\Scripts" -Filter "*.ps1"
foreach ($script in $scripts) {
    Copy-Item $script.FullName -Destination "$OutputPath\Scripts" -Force
}

# Generate final report
Write-Host "Generating project closure report..." -ForegroundColor Yellow

Generate-ProjectReport -OutputPath "$OutputPath\Reports\Project-Closure-Report.html"

Write-Host "Documentation complete. Location: $OutputPath" -ForegroundColor Green
