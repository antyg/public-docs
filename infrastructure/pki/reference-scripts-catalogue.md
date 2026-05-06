---
title: "PKI Modernisation — Scripts Catalogue"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "reference"
domain: "infrastructure"
---

# PKI Modernisation — Scripts Catalogue

## Overview

This catalogue lists all 68 scripts in the `scripts/` subdirectory, organised by functional category. Scripts span PowerShell (.ps1), Python (.py), shell (.sh), Tcl (.tcl), C (.c), and HTML (.html) formats. Each entry includes a one-line description, language, and the implementation phase or how-to guide the script supports.

---

## Deployment Scripts (11 scripts)

Scripts that provision infrastructure components for the first time.

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `Deploy-AzurePrivateCA.ps1` | PowerShell | Phase 1 | Deploys Azure Private CA service, configures key algorithm, validity, and subject name |
| `Deploy-PKICDN.ps1` | PowerShell | Phase 1 | Provisions content delivery infrastructure for CRL and AIA distribution |
| `Deploy-PKIConnectivity.ps1` | PowerShell | Phase 1 | Configures ExpressRoute and VPN connectivity for PKI service reachability |
| `Deploy-PKIKeyVault.ps1` | PowerShell | Phase 1 | Creates Azure Key Vault with Premium SKU, HSM backing, and private endpoint |
| `Deploy-PKINetwork.ps1` | PowerShell | Phase 1 | Provisions virtual networks, subnets, and peering for PKI infrastructure |
| `Deploy-CRLStorage.ps1` | PowerShell | Phase 1 | Creates and configures Azure Blob Storage for CRL and AIA publication |
| `Deploy-CertificateToAppliances.ps1` | PowerShell | Phase 3 | Pushes certificates to network appliances (NetScaler, F5) via management APIs |
| `Deploy-CodeSigningService.ps1` | PowerShell | Phase 3 | Deploys code signing infrastructure including approval workflows |
| `Create-PKIResourceGroups.ps1` | PowerShell | Phase 1 | Creates and tags Azure resource groups per PKI component type |
| `deploy-issuing-ca-servers.ps1` | PowerShell | Phase 2 | Provisions Windows Server 2022 VMs for issuing CA roles |
| `deploy-certificate-templates.ps1` | PowerShell | Phase 2 | Deploys all 15+ certificate templates to issuing CAs via AD CS |

---

## Configuration Scripts (29 scripts)

Scripts that configure existing components, including installation and setup of roles and services.

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `Configure-AutoEnrollment-Policy.ps1` | PowerShell | Phase 2 | Configures autoenrollment certificate policy in Intune or AD CS |
| `Configure-AzureServicesCertificates.ps1` | PowerShell | Phase 3 | Automates certificate assignment for Azure PaaS services |
| `Configure-CodeSignApproval.ps1` | PowerShell | Phase 3 | Sets up code signing approval workflow and authorised signers list |
| `Configure-HSMKeys.ps1` | PowerShell | Phase 1 | Initialises HSM key objects in Azure Key Vault for CA operations |
| `Configure-PKIBackup.ps1` | PowerShell | Phase 2 | Configures scheduled CA database and private key backup jobs |
| `Configure-PKINSGs.ps1` | PowerShell | Phase 1 | Applies Network Security Group rules to PKI subnet resources |
| `Configure-PKIRBAC.ps1` | PowerShell | Phase 1 | Assigns Azure RBAC roles for Key Vault and Private CA access |
| `Configure-RootCASecurity.ps1` | PowerShell | Phase 1 | Applies hardening baseline to root CA server (audit, local firewall, services) |
| `Configure-SCCMPKI.ps1` | PowerShell | Phase 3 | Configures SCCM site system certificate requirements and PKI mode |
| `Configure-ZscalerPKI.ps1` | PowerShell | Phase 3 | Imports enterprise root CA certificate into Zscaler trusted root store |
| `configure-autoenrollment-gpo.ps1` | PowerShell | Phase 2 | Creates and links Group Policy Object for certificate autoenrollment |
| `configure-base-servers.ps1` | PowerShell | Phase 2 | Applies base OS configuration to CA servers (time sync, audit, updates) |
| `configure-netscaler-ssl.py` | Python | Phase 3 | Configures SSL profiles, cipher suites, and certificate bindings on NetScaler via REST API |
| `install-adcs.ps1` | PowerShell | Phase 2 | Installs Active Directory Certificate Services role and management tools |
| `install-ndes.ps1` | PowerShell | Phase 2 | Installs and configures Network Device Enrollment Service role |
| `install-intune-connector.ps1` | PowerShell | Phase 2 | Installs and registers Intune Connector for SCEP certificate delivery |
| `join-pki-domain.ps1` | PowerShell | Phase 2 | Domain-joins PKI servers with pre-staged computer accounts |
| `complete-subordinate-ca.ps1` | PowerShell | Phase 2 | Completes subordinate CA installation after root CA signature |
| `auto-enrollment-gpo-configuration.ps1` | PowerShell | Phase 2 | Configures autoenrollment registry values and GPO settings for Windows clients |

**Integration configuration scripts (Phase 3):**

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `netscaler-automation.ps1` | PowerShell | Phase 3 | Automates NetScaler certificate renewal and binding updates via NITRO API |
| `netscaler-ssl-configuration.sh` | Shell | Phase 3 | Applies SSL policy configuration to NetScaler via CLI |
| `palo-alto-pki-configuration.sh` | Shell | Phase 3 | Imports enterprise CA certificates into Palo Alto firewall trust store |
| `f5-bigip-certificate-management.tcl` | Tcl | Phase 3 | Manages certificate objects and SSL profiles on F5 BIG-IP via iControl REST |
| `zscaler-pki-integration.py` | Python | Phase 3 | Synchronises enterprise CA chain to Zscaler tenant via ZIA API |
| `cisco-scep-enrollment.py` | Python | Phase 3 | Automates SCEP certificate enrollment for Cisco IOS devices |
| `pki-api-service.py` | Python | Phase 3 | REST API service exposing PKI operations for application integration |
| `Azure-KeyVault-Certificate-Automation.ps1` | PowerShell | Phase 3 | Automates certificate lifecycle in Azure Key Vault including rotation |
| `EST-Client-IoT.c` | C | Phase 3 | EST protocol client implementation for IoT device certificate enrollment |
| `Linux-Certificate-Enrollment.sh` | Shell | Phase 3 | Enrolls certificates on Linux hosts via SCEP or EST |
| `web-enrollment-portal.html` | HTML | Phase 3 | Static web enrollment portal for manual certificate requests |

---

## Operations Scripts (13 scripts)

Scripts for day-to-day certificate management, health monitoring, and maintenance.

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `backup-certificate-authority.ps1` | PowerShell | Ongoing | Performs full CA database backup and key backup to secure storage |
| `daily-pki-health-check.ps1` | PowerShell | Ongoing | Checks CA availability, CRL freshness, OCSP response, certificate expiry |
| `manage-certificate-templates.ps1` | PowerShell | Ongoing | Add, remove, and modify certificate templates on issuing CAs |
| `monitor-pki-security.ps1` | PowerShell | Ongoing | Monitors audit events, failed requests, and anomalous issuance patterns |
| `Monitor-SCCMCertificates.ps1` | PowerShell | Phase 3/Ongoing | Monitors SCCM client certificate enrollment status and renewal |
| `Monitor-PilotMigration.ps1` | PowerShell | Phase 4 | Real-time monitoring dashboard for pilot migration wave status |
| `perform-weekly-maintenance.ps1` | PowerShell | Ongoing | Weekly CA maintenance: archive expired certs, clean logs, validate CRL |
| `process-certificate-request.ps1` | PowerShell | Ongoing | Handles manual certificate request submission and approval workflow |
| `recover-failed-ca.ps1` | PowerShell | Ongoing | Guided CA recovery procedure from backup with integrity validation |
| `renew-expiring-certificates.ps1` | PowerShell | Ongoing | Identifies and renews certificates expiring within a configurable threshold |
| `revoke-certificate.ps1` | PowerShell | Ongoing | Revokes a certificate by serial number with CRL publication |
| `troubleshoot-pki-issues.ps1` | PowerShell | Ongoing | Diagnostic script covering common PKI failure scenarios |
| `PKI-Diagnostics-Commands.ps1` | PowerShell | Ongoing | Collection of diagnostic one-liners and functions for PKI troubleshooting |

---

## Testing Scripts (6 scripts)

Scripts that validate readiness, correctness, and migration outcomes.

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `Test-CutoverReadiness.ps1` | PowerShell | Phase 5 | Pre-cutover readiness gate: validates all systems are ready for legacy CA retirement |
| `Test-EnterprisePKI.ps1` | PowerShell | Phase 2 | End-to-end PKI validation: CA health, CRL, OCSP, template issuance |
| `Test-MigrationValidation.ps1` | PowerShell | Phase 4 | Post-wave validation: confirms certificates issued by new CA, revocation functional |
| `Test-Phase3Integration.ps1` | PowerShell | Phase 3 | Integration test suite for all Phase 3 service integrations |
| `Test-PKIInfrastructure.ps1` | PowerShell | Phase 2 | Infrastructure-level tests: connectivity, ports, DNS, certificate chain |
| `test-certificate-issuance.ps1` | PowerShell | Phase 2 | Validates certificate issuance from each template against expected OIDs and extensions |

---

## Migration Scripts (8 scripts)

Scripts that execute or support the phased migration from legacy PKI.

| Script | Language | Phase | Description |
|--------|----------|-------|-------------|
| `Execute-PilotMigration.ps1` | PowerShell | Phase 4 | Executes pilot migration wave for the selected 10% device group |
| `Execute-Wave1Migration.ps1` | PowerShell | Phase 4 | Executes Wave 1 migration for corporate services (40% of devices) |
| `Execute-Wave2Migration.ps1` | PowerShell | Phase 4 | Executes Wave 2 migration for production systems (50% of devices) |
| `Execute-PKICutover.ps1` | PowerShell | Phase 5 | Executes production cutover: switches trust to new CA, retires old trust |
| `Select-PilotGroup.ps1` | PowerShell | Phase 4 | Selects and validates the pilot device group based on criteria |
| `Decommission-LegacyPKI.ps1` | PowerShell | Phase 5 | Decommissions legacy CA servers: revokes CA cert, archives database, removes services |
| `Complete-ProjectClosure.ps1` | PowerShell | Phase 5 | Finalises project closure tasks: handover checklist, archive, notifications |
| `Complete-Documentation.ps1` | PowerShell | Phase 5 | Automates final documentation generation and publication tasks |

---

## Script Categories Summary

| Category | Count | Languages | Primary Phases |
|----------|-------|-----------|---------------|
| Deployment | 11 | PowerShell | Phase 1, Phase 2 |
| Configuration | 29 | PowerShell, Python, Shell, Tcl, C, HTML | Phase 1, 2, 3 |
| Operations | 13 | PowerShell | Ongoing |
| Testing | 6 | PowerShell | Phase 2, 3, 4, 5 |
| Migration | 8 | PowerShell | Phase 4, 5 |
| **Total** | **68** | | |

---

## Language Distribution

| Language | Count | Script Types |
|----------|-------|-------------|
| PowerShell (.ps1) | 58 | Deployment, configuration, operations, testing, migration |
| Python (.py) | 4 | NetScaler, Zscaler, Cisco SCEP, PKI API service |
| Shell (.sh) | 3 | NetScaler CLI, Palo Alto, Linux enrollment |
| Tcl (.tcl) | 1 | F5 BIG-IP iControl |
| C (.c) | 1 | IoT EST client |
| HTML (.html) | 1 | Web enrollment portal |

---

## Prerequisites

| Prerequisite | Required By | Notes |
|-------------|------------|-------|
| PowerShell 5.1 or 7+ | All .ps1 scripts | Windows PowerShell 5.1 or pwsh 7 |
| PSPKI module | CA administration scripts | `Install-Module -Name PSPKI` |
| Az PowerShell module | Azure scripts | `Install-Module -Name Az` |
| RSAT AD DS Tools | AD-related scripts | Windows feature: `RSAT-AD-PowerShell` |
| RSAT ADCS Tools | CA administration scripts | Windows feature: `RSAT-ADCS` |
| Python 3.8+ | .py scripts | Required for NetScaler, Zscaler, PKI API scripts |
| `requests` library | Python scripts | `pip install requests` |
| `cryptography` library | Python scripts | `pip install cryptography` |
| CA administration rights | Operations and testing scripts | `CA Administrators` role in AD CS |
| Azure Contributor | Azure deployment scripts | On the PKI resource group |
| Key Vault Certificates Officer | Key Vault scripts | Azure RBAC role |

---

## Cross-Reference: Scripts by How-To Guide

| Guide | Supporting Scripts |
|-------|--------------------|
| Phase 1: Foundation Setup | `Deploy-AzurePrivateCA.ps1`, `Deploy-PKIKeyVault.ps1`, `Deploy-PKINetwork.ps1`, `Deploy-PKIConnectivity.ps1`, `Deploy-CRLStorage.ps1`, `Configure-HSMKeys.ps1`, `Configure-PKIRBAC.ps1`, `Configure-PKINSGs.ps1`, `Configure-RootCASecurity.ps1`, `Create-PKIResourceGroups.ps1` |
| Phase 2: Core Infrastructure | `deploy-issuing-ca-servers.ps1`, `install-adcs.ps1`, `complete-subordinate-ca.ps1`, `configure-base-servers.ps1`, `join-pki-domain.ps1`, `install-ndes.ps1`, `install-intune-connector.ps1`, `deploy-certificate-templates.ps1`, `configure-autoenrollment-gpo.ps1`, `Configure-AutoEnrollment-Policy.ps1`, `Configure-PKIBackup.ps1`, `Test-EnterprisePKI.ps1`, `Test-PKIInfrastructure.ps1`, `test-certificate-issuance.ps1` |
| Phase 3: Services Integration | `Configure-SCCMPKI.ps1`, `Configure-CodeSignApproval.ps1`, `Deploy-CodeSigningService.ps1`, `Configure-AzureServicesCertificates.ps1`, `Azure-KeyVault-Certificate-Automation.ps1`, `configure-netscaler-ssl.py`, `netscaler-automation.ps1`, `netscaler-ssl-configuration.sh`, `f5-bigip-certificate-management.tcl`, `Configure-ZscalerPKI.ps1`, `zscaler-pki-integration.py`, `palo-alto-pki-configuration.sh`, `cisco-scep-enrollment.py`, `pki-api-service.py`, `EST-Client-IoT.c`, `Linux-Certificate-Enrollment.sh`, `web-enrollment-portal.html`, `Deploy-CertificateToAppliances.ps1`, `Deploy-PKICDN.ps1`, `Test-Phase3Integration.ps1` |
| Phase 4: Migration | `Select-PilotGroup.ps1`, `Execute-PilotMigration.ps1`, `Monitor-PilotMigration.ps1`, `Execute-Wave1Migration.ps1`, `Execute-Wave2Migration.ps1`, `Test-MigrationValidation.ps1` |
| Phase 5: Cutover | `Test-CutoverReadiness.ps1`, `Execute-PKICutover.ps1`, `Decommission-LegacyPKI.ps1`, `Complete-Documentation.ps1`, `Complete-ProjectClosure.ps1` |
| Operations and Day-2 | `daily-pki-health-check.ps1`, `renew-expiring-certificates.ps1`, `revoke-certificate.ps1`, `backup-certificate-authority.ps1`, `perform-weekly-maintenance.ps1`, `manage-certificate-templates.ps1`, `process-certificate-request.ps1`, `recover-failed-ca.ps1`, `monitor-pki-security.ps1`, `Monitor-SCCMCertificates.ps1`, `troubleshoot-pki-issues.ps1`, `PKI-Diagnostics-Commands.ps1` |

---

## Related Resources

- [Microsoft Learn — PSPKI Module](https://learn.microsoft.com/en-us/powershell/module/pki/)
- [Microsoft Learn — Az PowerShell Module](https://learn.microsoft.com/en-us/powershell/azure/new-azureps-module-az)
- [Microsoft Learn — Active Directory Certificate Services PowerShell](https://learn.microsoft.com/en-us/powershell/module/adcsadministration/)
- [PSPKI Module on PowerShell Gallery](https://www.powershellgallery.com/packages/PSPKI)
- [Citrix NetScaler NITRO API Reference](https://developer-docs.citrix.com/en-us/adc-nitro-api/)
- [F5 BIG-IP iControl REST API](https://clouddocs.f5.com/api/icontrol-rest/)
- [Zscaler ZIA API Documentation](https://help.zscaler.com/zia/api)

---

Navigation: [Scripts README](scripts/README.md) | [PKI README](README.md) | [Parent: infrastructure/](../README.md)
