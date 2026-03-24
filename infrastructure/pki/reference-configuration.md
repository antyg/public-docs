---
title: "PKI Modernisation — Configuration Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "reference"
domain: "infrastructure"
---

# PKI Modernisation — Configuration Reference

## Technology Stack

| Layer | Component | Version |
|-------|-----------|---------|
| Cloud CA | Azure Private CA | Current |
| On-premises CA | Windows Server AD CS | Windows Server 2022 |
| Key management | Azure Key Vault (Premium, HSM-backed) | Current |
| SCEP gateway | NDES (Network Device Enrollment Service) | Windows Server 2022 |
| MDM integration | Intune Connector for AD CS | Current |
| CRL/OCSP | Windows Server OCSP responder | Windows Server 2022 |
| HSM | Azure Key Vault Managed HSM (FIPS 140-2 Level 3) | Current |

---

## CA Hierarchy

| Tier | Name | Type | Location | Key Protection |
|------|------|------|----------|----------------|
| Root CA | Company-Root-CA | Offline, air-gapped | Azure Key Vault (HSM) | FIPS 140-2 Level 3 |
| Issuing CA 1 | Company-Issuing-CA-01 | Online, Active-Active | Azure / Windows Server 2022 | HSM-backed |
| Issuing CA 2 | Company-Issuing-CA-02 | Online, Active-Active | Azure / Windows Server 2022 | HSM-backed |

---

## CAPolicy.inf Parameters

### Root CA Policy

| Section | Parameter | Value | Notes |
|---------|-----------|-------|-------|
| `[Version]` | `Signature` | `"$Windows NT$"` | Required header |
| `[PolicyStatementExtension]` | `Policies` | `InternalPolicy` | Policy OID reference |
| `[InternalPolicy]` | `OID` | `1.2.3.4.1455.67.89.5` | Organisation-specific OID |
| `[InternalPolicy]` | `Notice` | `"Internal Use Only"` | CPS notice text |
| `[Certsrv_Server]` | `RenewalKeyLength` | `4096` | RSA key length for root |
| `[Certsrv_Server]` | `RenewalValidityPeriod` | `Years` | Validity period unit |
| `[Certsrv_Server]` | `RenewalValidityPeriodUnits` | `20` | 20-year root CA validity |
| `[Certsrv_Server]` | `CRLPeriod` | `Years` | CRL publication unit |
| `[Certsrv_Server]` | `CRLPeriodUnits` | `1` | Annual CRL for offline root |
| `[Certsrv_Server]` | `CRLDeltaPeriod` | `Days` | Delta CRL unit |
| `[Certsrv_Server]` | `CRLDeltaPeriodUnits` | `0` | No delta CRL for root |
| `[Certsrv_Server]` | `LoadDefaultTemplates` | `0` | No default templates |
| `[BasicConstraintsExtension]` | `PathLength` | `1` | Max subordinate depth = 1 |

### Issuing CA Policy

| Section | Parameter | Value | Notes |
|---------|-----------|-------|-------|
| `[Certsrv_Server]` | `RenewalKeyLength` | `4096` | RSA key length |
| `[Certsrv_Server]` | `RenewalValidityPeriod` | `Years` | Validity period unit |
| `[Certsrv_Server]` | `RenewalValidityPeriodUnits` | `5` | 5-year issuing CA validity |
| `[Certsrv_Server]` | `CRLPeriod` | `Days` | CRL publication unit |
| `[Certsrv_Server]` | `CRLPeriodUnits` | `7` | Weekly CRL |
| `[Certsrv_Server]` | `CRLDeltaPeriod` | `Hours` | Delta CRL unit |
| `[Certsrv_Server]` | `CRLDeltaPeriodUnits` | `4` | 4-hour delta CRL |
| `[Certsrv_Server]` | `LoadDefaultTemplates` | `0` | No default templates |
| `[CRLDistributionPoint]` | `Empty` | `True` | Remove built-in CDP |
| `[AuthorityInformationAccess]` | `Empty` | `True` | Remove built-in AIA |

---

## Certificate Template Parameters

### Standard Templates

| Template Name | Purpose | Key Algorithm | Key Size | Validity | EKU OID |
|--------------|---------|---------------|----------|----------|---------|
| Company-Computer-Authentication | Machine authentication | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.2 |
| Company-Domain-Controller | DC Kerberos and LDAPS | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.1, 1.3.6.1.5.5.7.3.2 |
| Company-User-Authentication | User logon | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.2 |
| Company-Web-Server | IIS/HTTPS | RSA | 2048 | 2 years | 1.3.6.1.5.5.7.3.1 |
| Company-SQL-Server | SQL Server TLS | RSA | 2048 | 2 years | 1.3.6.1.5.5.7.3.1 |
| Company-Code-Signing | Software signing | RSA | 4096 | 1 year | 1.3.6.1.5.5.7.3.3 |
| Company-VPN-Server | VPN gateway | RSA | 2048 | 2 years | 1.3.6.1.5.5.7.3.1 |
| Company-802.1x | Wireless/wired auth | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.2 |
| Company-SMIME | Email signing/encryption | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.4 |
| Company-OCSP-Response | OCSP signing | RSA | 2048 | 6 months | 1.3.6.1.5.5.7.3.9 |
| Company-NDES-Enrollment | SCEP proxy | RSA | 2048 | 1 year | 1.3.6.1.5.5.7.3.1 |

### Template Flags Reference

| Flag Name | Hex Value | Effect |
|-----------|-----------|--------|
| `CT_FLAG_AUTO_ENROLLMENT` | `0x20` | Enable autoenrollment |
| `CT_FLAG_MACHINE_TYPE` | `0x40` | Machine (computer) template |
| `CT_FLAG_IS_CA` | `0x80` | CA certificate template |
| `CT_FLAG_ADD_TEMPLATE_NAME` | `0x200` | Include template name in certificate |
| `CT_FLAG_DO_NOT_PERSIST_IN_DB` | `0x1000` | Do not store in CA database |
| `CT_FLAG_EXPORTABLE_KEY` | `0x10` | Allow private key export |

### Key Usage OIDs

| EKU | OID | Common Use |
|-----|-----|------------|
| Server Authentication | 1.3.6.1.5.5.7.3.1 | TLS server certificates |
| Client Authentication | 1.3.6.1.5.5.7.3.2 | TLS client / device auth |
| Code Signing | 1.3.6.1.5.5.7.3.3 | Software and script signing |
| Email Protection (S/MIME) | 1.3.6.1.5.5.7.3.4 | Email signing and encryption |
| OCSP Signing | 1.3.6.1.5.5.7.3.9 | OCSP responder certificates |
| Smart Card Logon | 1.3.6.1.4.1.311.20.2.2 | Smart card authentication |
| Encrypting File System | 1.3.6.1.4.1.311.10.3.4 | EFS certificates |

---

## CRL and CDP Configuration

| Parameter | Root CA | Issuing CA |
|-----------|---------|-----------|
| CRL publication period | 1 year | 7 days |
| CRL overlap period | 6 months | 2 days |
| Delta CRL period | None | 4 hours |
| Delta CRL overlap | N/A | 1 hour |
| CDP URL (HTTP) | `http://crl.company.com.au/pki/root-ca.crl` | `http://crl.company.com.au/pki/issuing-ca.crl` |
| CDP URL (LDAP) | LDAP://CN=...,CN=CDP,... | LDAP://CN=...,CN=CDP,... |
| AIA OCSP URL | None (offline root) | `http://ocsp.company.com.au/` |
| AIA CA Issuer URL | `http://crl.company.com.au/pki/root-ca.crt` | `http://crl.company.com.au/pki/issuing-ca.crt` |

---

## Registry Keys — AD CS Configuration

| Registry Path | Value Name | Type | Value | Effect |
|--------------|------------|------|-------|--------|
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `CRLPeriodUnits` | DWORD | 7 | CRL validity in units |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `CRLPeriod` | SZ | `Days` | CRL validity unit |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `CRLDeltaPeriodUnits` | DWORD | 4 | Delta CRL validity in units |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `CRLDeltaPeriod` | SZ | `Hours` | Delta CRL validity unit |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `ValidityPeriodUnits` | DWORD | 1 | Default issued cert validity |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `ValidityPeriod` | SZ | `Years` | Default issued cert validity unit |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>` | `AuditFilter` | DWORD | 127 | Enable all audit events |
| `HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA Name>\PolicyModules\CertificateAuthority_MicrosoftDefault.Policy` | `RequestDisposition` | DWORD | 1 | Auto-issue (1) or pending (2) |

---

## PowerShell Cmdlet Reference — PKI Operations

### AD CS Administration (`PSPKI` module)

| Cmdlet | Purpose | Key Parameters |
|--------|---------|----------------|
| `Get-CertificationAuthority` | List CA objects | `-ComputerName`, `-Name` |
| `Get-CATemplate` | List templates on a CA | `-CertificationAuthority` |
| `Add-CATemplate` | Add template to CA | `-CertificationAuthority`, `-DisplayName` |
| `Remove-CATemplate` | Remove template from CA | `-CertificationAuthority`, `-DisplayName` |
| `Get-IssuedRequest` | Query issued certificates | `-CertificationAuthority`, `-Filter` |
| `Get-PendingRequest` | Query pending requests | `-CertificationAuthority` |
| `Approve-CertificateRequest` | Approve pending request | `-RequestID`, `-CertificationAuthority` |
| `Deny-CertificateRequest` | Deny pending request | `-RequestID` |
| `Revoke-Certificate` | Revoke a certificate | `-SerialNumber`, `-Reason`, `-CertificationAuthority` |
| `Get-CRLDistributionPoint` | List CDP entries | `-CertificationAuthority` |
| `Add-CRLDistributionPoint` | Add CDP URL | `-CertificationAuthority`, `-URI` |

### Certificate Store Management

| Cmdlet | Purpose | Key Parameters |
|--------|---------|----------------|
| `Get-ChildItem Cert:\` | List certificates in store | Path: `Cert:\LocalMachine\My`, `Cert:\CurrentUser\My` |
| `Import-Certificate` | Import a certificate | `-FilePath`, `-CertStoreLocation` |
| `Export-Certificate` | Export a certificate | `-Cert`, `-FilePath` |
| `Import-PfxCertificate` | Import PFX with private key | `-FilePath`, `-CertStoreLocation`, `-Password` |
| `Export-PfxCertificate` | Export PFX with private key | `-Cert`, `-FilePath`, `-Password` |
| `Remove-Item Cert:\` | Delete a certificate | Path to certificate thumbprint |
| `Get-Certificate` | Request a certificate | `-Template`, `-CertStoreLocation`, `-SubjectName` |

### Azure Key Vault — Certificate Operations

| Cmdlet | Purpose | Key Parameters |
|--------|---------|----------------|
| `Get-AzKeyVaultCertificate` | List/get certificates | `-VaultName`, `-Name` |
| `Add-AzKeyVaultCertificate` | Import certificate | `-VaultName`, `-Name`, `-CertificatePolicy` |
| `Import-AzKeyVaultCertificate` | Import PFX to Key Vault | `-VaultName`, `-Name`, `-FilePath` |
| `Remove-AzKeyVaultCertificate` | Delete certificate | `-VaultName`, `-Name` |
| `Get-AzKeyVaultCertificatePolicy` | Retrieve cert policy | `-VaultName`, `-Name` |
| `Set-AzKeyVaultCertificatePolicy` | Update cert policy | `-VaultName`, `-Name`, `-CertificatePolicy` |
| `New-AzKeyVaultCertificatePolicy` | Create cert policy object | `-SecretContentType`, `-SubjectName`, `-IssuerName` |
| `Get-AzKeyVaultCertificateOperation` | Check CSR status | `-VaultName`, `-Name` |

### Group Policy — Autoenrollment

| Cmdlet / Tool | Purpose | Notes |
|--------------|---------|-------|
| `certutil -pulse` | Trigger autoenrollment manually | Run on target computer |
| `gpupdate /force` | Apply GPO including autoenrollment | Run on target computer |
| `certutil -template` | List available templates | Run on client |
| `certutil -viewstore` | View certificate store | `-user` or `-machine` flag |
| `Get-GPO` | Retrieve GPO object | Requires RSAT Group Policy module |
| `Set-GPRegistryValue` | Configure autoenrollment registry | Set `AutoEnrollment` DWORD |

---

## Network Requirements

### Ports and Protocols

| Service | Port | Protocol | Direction | Purpose |
|---------|------|----------|-----------|---------|
| LDAP | 389 | TCP | Client → DC | Certificate template enumeration |
| LDAPS | 636 | TCP | Client → DC | Secure LDAP |
| HTTP (CRL/AIA) | 80 | TCP | Client → CRL server | CRL distribution, AIA retrieval |
| HTTPS (NDES/SCEP) | 443 | TCP | Device → NDES | SCEP enrollment |
| HTTPS (OCSP) | 443 | TCP | Client → OCSP | Certificate status checking |
| HTTPS (EST) | 443 | TCP | Device → EST server | EST certificate enrollment |
| RPC/DCOM | 49152–65535 | TCP | Admin → CA | Remote CA administration |
| Kerberos | 88 | TCP/UDP | Client → DC | Authentication |
| SMB | 445 | TCP | CA → CRL share | CRL publishing to file share |
| Azure HTTPS | 443 | TCP | All → Azure | Key Vault, Azure Private CA |
| ExpressRoute | N/A | Private | On-prem ↔ Azure | Primary hybrid connectivity |

### Firewall Rule Summary

| Source Zone | Destination Zone | Port/Protocol | Justification |
|-------------|-----------------|---------------|---------------|
| All clients | CRL HTTP server | TCP 80 | CRL retrieval (must not be blocked) |
| All clients | OCSP server | TCP 443 | Real-time revocation checking |
| Managed devices | NDES server | TCP 443 | SCEP enrollment |
| NDES server | Issuing CA | TCP 49152–65535 RPC | Certificate issuance |
| CA servers | Azure Key Vault | TCP 443 | HSM operations |
| Admin workstations | CA servers | TCP 49152–65535 RPC | Administration |
| CA servers | Domain controllers | TCP 389, 636 | Template and group resolution |

### DNS Requirements

| Record | Type | Value | Purpose |
|--------|------|-------|---------|
| `crl.company.com.au` | A | CRL server IP | CRL distribution point |
| `ocsp.company.com.au` | A | OCSP responder IP | OCSP endpoint |
| `ndes.company.com.au` | A | NDES server IP | SCEP enrollment |
| `est.company.com.au` | A | EST server IP | EST enrollment |
| `pki.company.com.au` | A | Web enrollment IP | Web enrollment portal |

---

## Azure Resource Configuration

### Key Vault Settings

| Setting | Value |
|---------|-------|
| SKU | Premium (HSM-backed) |
| Soft delete | Enabled, 90-day retention |
| Purge protection | Enabled |
| Network access | Private endpoint only |
| Key type | RSA-HSM |
| Key size | 4096 bits |
| Key operations | Sign, Verify, WrapKey, UnwrapKey |

### Azure Private CA Settings

| Setting | Value |
|---------|-------|
| Key algorithm | RSA 4096 |
| Signing algorithm | SHA-256 |
| Subject | `CN=Company-Root-CA,O=Company,C=AU` |
| Validity | 20 years |
| CRL distribution | Azure Blob Storage (public endpoint) |
| OCSP | Managed by Azure Private CA service |

---

## Cryptographic Standards

| Standard | Requirement | Reference |
|----------|-------------|-----------|
| Key algorithm | RSA minimum 2048 bits; RSA 4096 for root/code signing | [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) |
| Hash algorithm | SHA-256 minimum; SHA-1 not permitted | ACSC ISM |
| Key storage | FIPS 140-2 Level 3 HSM for CA keys | FIPS 140-2 |
| TLS version | TLS 1.2 minimum; TLS 1.3 preferred | ACSC ISM |
| Certificate validity | End-entity ≤ 2 years; Sub-CA ≤ 5 years; Root ≤ 20 years | Industry baseline |
| CRL freshness | Must be published before previous CRL expires | RFC 5280 |

---

## Error Codes and Diagnostics

### Common AD CS Error Codes

| Error Code (Hex) | Error Code (Decimal) | Description | Common Cause |
|-----------------|---------------------|-------------|-------------|
| `0x80094004` | -2146877436 | `CERTSRV_E_TEMPLATE_POLICY_REQUIRED` | Template requires policy enforcement |
| `0x80094800` | -2146875392 | `CERTSRV_E_UNSUPPORTED_CERT_TYPE` | Template not available on CA |
| `0x80094801` | -2146875391 | `CERTSRV_E_NO_CERT_TYPE` | No template specified in request |
| `0x8009480a` | -2146875382 | `CERTSRV_E_TEMPLATE_DENIED` | Requester lacks enroll permission |
| `0x80070005` | -2147024891 | `E_ACCESSDENIED` | Access denied to CA or template |
| `0x80092013` | -2146885613 | `CRYPT_E_REVOKED` | Certificate has been revoked |
| `0x80092012` | -2146885614 | `CRYPT_E_NO_REVOCATION_CHECK` | Revocation check could not be performed |
| `0x80096004` | -2146869244 | `TRUST_E_CERT_SIGNATURE` | Certificate signature invalid |
| `0x800b010a` | -2146762486 | `CERT_E_CHAINING` | Certificate chain cannot be built |
| `0x800b0109` | -2146762487 | `CERT_E_UNTRUSTEDROOT` | Root CA not trusted |

### NDES/SCEP Error Codes

| HTTP Status | Meaning | Likely Cause |
|-------------|---------|-------------|
| 403 Forbidden | NDES access denied | Application pool identity lacks permissions |
| 500 Internal Server Error | NDES service fault | IIS configuration issue or CA unreachable |
| Service Unavailable | NDES offline | IIS application pool stopped |

### certutil Diagnostic Commands

| Command | Purpose |
|---------|---------|
| `certutil -verify -urlfetch <cert.cer>` | Verify certificate chain and revocation |
| `certutil -URL <cert.cer>` | GUI tool: check CDP and AIA URLs |
| `certutil -ping <CA Name>` | Test CA RPC connectivity |
| `certutil -CRL` | Publish CRL immediately |
| `certutil -getkey <serial> output.blob` | Archive key recovery |
| `certutil -viewca -config <CA>` | View CA configuration |
| `certutil -schema -config <CA>` | View CA database schema |
| `certutil -view -config <CA>` | View all issued certificates |
| `certutil -revoke <serial> <reason>` | Revoke a certificate |

### Revocation Reason Codes

| Code | Reason | Use Case |
|------|--------|----------|
| 0 | `Unspecified` | Generic revocation |
| 1 | `KeyCompromise` | Private key exposed |
| 2 | `CACompromise` | CA private key exposed |
| 3 | `AffiliationChanged` | Subject's organisation changed |
| 4 | `Superseded` | Certificate replaced |
| 5 | `CessationOfOperation` | Entity ceases to operate |
| 6 | `CertificateHold` | Temporary hold (reversible) |
| 8 | `RemoveFromCRL` | Remove hold |

---

## Related Resources

- [Microsoft Learn — Active Directory Certificate Services Overview](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority)
- [Microsoft Learn — CAPolicy.inf Syntax](https://learn.microsoft.com/en-us/windows-server/security/certificates-and-public-key-infrastructure-pki/capolicy-inf-syntax)
- [Microsoft Learn — Certificate Template Technical Reference](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/dn553174(v=ws.11))
- [Microsoft Learn — Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Microsoft Learn — Azure Private CA](https://learn.microsoft.com/en-us/azure/private-ca/overview)
- [Microsoft Learn — NDES (Network Device Enrollment Service)](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [RFC 5280 — Internet X.509 PKI Certificate and CRL Profile](https://datatracker.ietf.org/doc/html/rfc5280)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [FIPS 140-2 — Cryptographic Module Validation Program](https://csrc.nist.gov/publications/detail/fips/140/2/final)
- [PSPKI PowerShell Module Documentation](https://www.pkisolutions.com/tools/pspki/)

---

Navigation: [PKI README](README.md) | [Parent: infrastructure/](../README.md)
