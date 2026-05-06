---
title: "PKI Scripts Collection"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# PKI Scripts Collection

## Purpose

This directory contains 68 automation scripts for PKI deployment, configuration, operations, testing, and migration. Scripts were developed as part of the PKI modernisation project (February–April 2025).

For detailed descriptions, parameters, and how-to guide cross-references, see [reference-scripts-catalogue.md](../reference-scripts-catalogue.md).

## Prerequisites

| Prerequisite | Required By | Notes |
|-------------|------------|-------|
| PowerShell 5.1 or 7+ | All .ps1 scripts | Windows PowerShell 5.1 minimum |
| PSPKI module | CA administration scripts | `Install-Module -Name PSPKI` |
| Az PowerShell module | Azure scripts | `Install-Module -Name Az` |
| RSAT AD DS Tools | AD-related scripts | Windows feature `RSAT-AD-PowerShell` |
| RSAT ADCS Tools | CA administration scripts | Windows feature `RSAT-ADCS` |
| Python 3.8+ | .py scripts | NetScaler, Zscaler, PKI API scripts |
| `requests` Python library | Python scripts | `pip install requests` |
| `cryptography` Python library | Python scripts | `pip install cryptography` |
| CA Administrators AD group | Operations and testing scripts | Required for CA operations |
| Azure Contributor | Azure deployment scripts | Scoped to PKI resource group |
| Key Vault Certificates Officer | Key Vault scripts | Azure RBAC role |

---

## Scripts by Category

### Deployment (11 scripts)

Provision infrastructure components for the first time.

| Script | Language | Description |
|--------|----------|-------------|
| `Deploy-AzurePrivateCA.ps1` | PowerShell | Deploys Azure Private CA service |
| `Deploy-PKICDN.ps1` | PowerShell | Provisions CRL and AIA distribution infrastructure |
| `Deploy-PKIConnectivity.ps1` | PowerShell | Configures ExpressRoute and VPN connectivity |
| `Deploy-PKIKeyVault.ps1` | PowerShell | Creates Azure Key Vault with HSM backing |
| `Deploy-PKINetwork.ps1` | PowerShell | Provisions virtual networks and subnets |
| `Deploy-CRLStorage.ps1` | PowerShell | Creates Azure Blob Storage for CRL publication |
| `Deploy-CertificateToAppliances.ps1` | PowerShell | Pushes certificates to NetScaler and F5 |
| `Deploy-CodeSigningService.ps1` | PowerShell | Deploys code signing infrastructure |
| `Create-PKIResourceGroups.ps1` | PowerShell | Creates and tags Azure resource groups |
| `deploy-issuing-ca-servers.ps1` | PowerShell | Provisions Windows Server 2022 VMs for issuing CAs |
| `deploy-certificate-templates.ps1` | PowerShell | Deploys certificate templates to issuing CAs |

---

### Configuration (29 scripts)

Configure existing components including role and service installation.

| Script | Language | Description |
|--------|----------|-------------|
| `Configure-AutoEnrollment-Policy.ps1` | PowerShell | Configures autoenrolment certificate policy |
| `Configure-AzureServicesCertificates.ps1` | PowerShell | Automates certificate assignment for Azure PaaS |
| `Configure-CodeSignApproval.ps1` | PowerShell | Sets up code signing approval workflow |
| `Configure-HSMKeys.ps1` | PowerShell | Initialises HSM key objects in Azure Key Vault |
| `Configure-PKIBackup.ps1` | PowerShell | Configures scheduled CA database backup jobs |
| `Configure-PKINSGs.ps1` | PowerShell | Applies Network Security Group rules to PKI subnets |
| `Configure-PKIRBAC.ps1` | PowerShell | Assigns Azure RBAC roles for Key Vault and Private CA |
| `Configure-RootCASecurity.ps1` | PowerShell | Applies hardening baseline to root CA server |
| `Configure-SCCMPKI.ps1` | PowerShell | Configures SCCM PKI mode and site system certificates |
| `Configure-ZscalerPKI.ps1` | PowerShell | Imports enterprise root CA into Zscaler trust store |
| `configure-autoenrollment-gpo.ps1` | PowerShell | Creates and links GPO for certificate autoenrolment |
| `configure-base-servers.ps1` | PowerShell | Applies base OS configuration to CA servers |
| `configure-netscaler-ssl.py` | Python | Configures SSL profiles on NetScaler via REST API |
| `install-adcs.ps1` | PowerShell | Installs Active Directory Certificate Services role |
| `install-ndes.ps1` | PowerShell | Installs and configures NDES role |
| `install-intune-connector.ps1` | PowerShell | Installs and registers Intune Connector for SCEP |
| `join-pki-domain.ps1` | PowerShell | Domain-joins PKI servers with pre-staged accounts |
| `complete-subordinate-ca.ps1` | PowerShell | Completes subordinate CA installation after root signing |
| `auto-enrollment-gpo-configuration.ps1` | PowerShell | Configures autoenrolment registry values and GPO settings |
| `netscaler-automation.ps1` | PowerShell | Automates NetScaler certificate renewal via NITRO API |
| `netscaler-ssl-configuration.sh` | Shell | Applies SSL policy configuration to NetScaler via CLI |
| `palo-alto-pki-configuration.sh` | Shell | Imports CA certificates into Palo Alto trust store |
| `f5-bigip-certificate-management.tcl` | Tcl | Manages certificate objects on F5 BIG-IP via iControl |
| `zscaler-pki-integration.py` | Python | Synchronises CA chain to Zscaler via ZIA API |
| `cisco-scep-enrollment.py` | Python | Automates SCEP enrolment for Cisco IOS devices |
| `pki-api-service.py` | Python | REST API service exposing PKI operations |
| `Azure-KeyVault-Certificate-Automation.ps1` | PowerShell | Automates certificate lifecycle in Azure Key Vault |
| `EST-Client-IoT.c` | C | EST protocol client for IoT device enrolment |
| `Linux-Certificate-Enrollment.sh` | Shell | Enrols certificates on Linux hosts via SCEP or EST |
| `web-enrollment-portal.html` | HTML | Static web enrolment portal for manual requests |

---

### Operations (13 scripts)

Day-to-day certificate management, health monitoring, and maintenance.

| Script | Language | Description |
|--------|----------|-------------|
| `backup-certificate-authority.ps1` | PowerShell | Full CA database and key backup to secure storage |
| `daily-pki-health-check.ps1` | PowerShell | Checks CA availability, CRL freshness, OCSP, expiry |
| `manage-certificate-templates.ps1` | PowerShell | Add, remove, and modify certificate templates |
| `monitor-pki-security.ps1` | PowerShell | Monitors audit events and anomalous issuance patterns |
| `Monitor-SCCMCertificates.ps1` | PowerShell | Monitors SCCM client certificate enrolment status |
| `Monitor-PilotMigration.ps1` | PowerShell | Real-time monitoring for pilot migration wave |
| `perform-weekly-maintenance.ps1` | PowerShell | Weekly maintenance: archive, clean logs, validate CRL |
| `process-certificate-request.ps1` | PowerShell | Manual certificate request submission and approval |
| `recover-failed-ca.ps1` | PowerShell | Guided CA recovery from backup with validation |
| `renew-expiring-certificates.ps1` | PowerShell | Identifies and renews expiring certificates |
| `revoke-certificate.ps1` | PowerShell | Revokes certificate by serial number, publishes CRL |
| `troubleshoot-pki-issues.ps1` | PowerShell | Diagnostic script for common PKI failure scenarios |
| `PKI-Diagnostics-Commands.ps1` | PowerShell | Collection of diagnostic one-liners and functions |

---

### Testing (6 scripts)

Validate readiness, correctness, and migration outcomes.

| Script | Language | Description |
|--------|----------|-------------|
| `Test-CutoverReadiness.ps1` | PowerShell | Pre-cutover readiness gate for legacy CA retirement |
| `Test-EnterprisePKI.ps1` | PowerShell | End-to-end PKI validation: CA, CRL, OCSP, templates |
| `Test-MigrationValidation.ps1` | PowerShell | Post-wave validation of new CA certificate issuance |
| `Test-Phase3Integration.ps1` | PowerShell | Integration test suite for Phase 3 service integrations |
| `Test-PKIInfrastructure.ps1` | PowerShell | Infrastructure-level tests: connectivity, DNS, chain |
| `test-certificate-issuance.ps1` | PowerShell | Validates certificate issuance against expected OIDs |

---

### Migration (8 scripts)

Execute or support the phased migration from legacy PKI.

| Script | Language | Description |
|--------|----------|-------------|
| `Execute-PilotMigration.ps1` | PowerShell | Executes pilot migration wave (10% of devices) |
| `Execute-Wave1Migration.ps1` | PowerShell | Executes Wave 1 migration (40% of devices) |
| `Execute-Wave2Migration.ps1` | PowerShell | Executes Wave 2 migration (50% of devices) |
| `Execute-PKICutover.ps1` | PowerShell | Executes production cutover and trust switch |
| `Select-PilotGroup.ps1` | PowerShell | Selects and validates the pilot device group |
| `Decommission-LegacyPKI.ps1` | PowerShell | Decommissions legacy CA servers and archives database |
| `Complete-ProjectClosure.ps1` | PowerShell | Finalises project closure tasks and handover checklist |
| `Complete-Documentation.ps1` | PowerShell | Automates final documentation generation and publication |

---

## Usage Notes

- Run PowerShell scripts from a workstation with appropriate AD and Azure permissions.
- All scripts that modify CA configuration require `CA Administrators` group membership.
- Azure scripts require an authenticated Az PowerShell session (`Connect-AzAccount`).
- Python scripts require a Python 3.8+ virtual environment with `requests` and `cryptography` packages installed.
- Shell scripts (`.sh`) are intended for Linux hosts or Git Bash on Windows.
- The Tcl script (`f5-bigip-certificate-management.tcl`) runs within the F5 iControl TMOS shell.
- The C file (`EST-Client-IoT.c`) must be compiled before use. See the file header for build instructions.
- Always run `Test-PKIInfrastructure.ps1` after deployment before proceeding to the next phase.

---

## Navigation

- [Full script descriptions and parameters](../reference-scripts-catalogue.md)
- [PKI README](../README.md)
- Parent: [infrastructure/pki/](../)
