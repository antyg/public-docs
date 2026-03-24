---
title: "Cloud Migration Assessment Reference"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "reference"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Cloud Migration Assessment Reference

This reference supports assessment of enterprise environments for migration from hybrid Azure AD join to cloud-native Windows Autopilot deployments using [Microsoft Entra join](https://learn.microsoft.com/en-us/entra/identity/devices/concept-directory-join). It catalogues authentication dependencies, application dependencies, and available modern authentication solutions.

## Authentication Dependencies

Source: [Microsoft Entra authentication methods — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods).

### AUTH-001: Domain Authentication Dependencies

| Dependency Type | Examples | Cloud Migration Complexity | Cloud Solution |
|----------------|---------|---------------------------|----------------|
| Windows Integrated Authentication (Negotiate/NTLM) | SharePoint on-premises, Exchange on-premises, line-of-business web apps, network file shares | High | [Microsoft Entra application proxy](https://learn.microsoft.com/en-us/entra/identity/app-proxy/) with pre-authentication; migrate to modern auth |
| Service account dependencies | SQL Server service accounts, IIS application pool identities, scheduled task accounts, background services | Medium–High | [Azure managed identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) or certificate-based service authentication |
| Certificate-based authentication | Internal CA infrastructure, smart card authentication, device certificates, user certificates for applications | High | [Microsoft Entra certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication); [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) for certificate lifecycle management |

### AUTH-002: Kerberos Authentication Dependencies

| Service Type | Domain Dependency | Cloud Solution | Migration Complexity |
|-------------|------------------|----------------|---------------------|
| File shares (SMB) | High | [Azure Files with Entra ID DS integration](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable) | Medium |
| SQL Server | High | [Azure SQL with managed identity authentication](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview) | High |
| Web applications | Medium | [Microsoft Entra application proxy with KCD](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-configure-single-sign-on-with-kcd) | Medium |
| Print services | High | [Universal Print](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-whatis) | Low |
| Exchange on-premises | High | [Exchange Online migration](https://learn.microsoft.com/en-us/exchange/mailflow-best-practices/use-connectors-to-configure-mail-flow/use-connectors-to-configure-mail-flow) | Low |
| SharePoint on-premises | High | [SharePoint Online / SharePoint Migration Tool](https://learn.microsoft.com/en-us/sharepointmigration/introducing-the-sharepoint-migration-tool) | Low |
| Oracle database | High | Certificate-based authentication | Very High |

### AUTH-003: Certificate-Based Authentication Migration

| Current State Component | Target State Component | Migration Approach |
|------------------------|----------------------|-------------------|
| On-premises Enterprise CA | [Microsoft Entra certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication) | Upload root and issuing CA certificates to Entra ID; configure CRL distribution points |
| Smart card infrastructure | [Windows Hello for Business (cloud trust)](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-hybrid-cloud-kerberos-trust) or [FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless) | Deploy phased passwordless rollout |
| Device certificates via internal CA | [SCEP/PKCS profiles via Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/certificates-configure) | Deploy Intune certificate profiles; use NDES or third-party CA connector |
| User certificates for applications | [Azure Key Vault managed certificates](https://learn.microsoft.com/en-us/azure/key-vault/certificates/about-certificates) with automated lifecycle | Configure Key Vault auto-renewal policies; integrate with Entra ID CBA |

## Application Dependencies

Source: [Microsoft Entra application proxy documentation](https://learn.microsoft.com/en-us/entra/identity/app-proxy/) and [Azure Files identity-based authentication](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable).

### APP-001: Domain-Joined Application Dependencies

| Dependency Category | Sub-type | Migration Complexity | Recommended Cloud Solution |
|--------------------|---------|---------------------|---------------------------|
| Authentication dependencies | Windows Integrated Authentication (IWA) | High | [Entra application proxy with pre-authentication](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy) |
| Authentication dependencies | NTLM / Kerberos protocol | High | Entra application proxy with [Kerberos Constrained Delegation (KCD)](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-configure-single-sign-on-with-kcd) |
| Authentication dependencies | AD group membership queries | Medium | Synchronise groups via [Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect); use Entra ID groups in cloud apps |
| Authorisation dependencies | ACL-based access on network resources | Medium | Azure Files with Entra ID DS; SharePoint Online with mapped permissions |
| Authorisation dependencies | SQL Server Windows Authentication | High | [Azure SQL with Entra ID authentication](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview) and managed identities |
| Data access dependencies | File share access via domain credentials | Medium | Azure Files or SharePoint Online / OneDrive for Business sync |
| Service dependencies | Windows service account authentication | Medium | [Azure managed identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) |
| Service dependencies | WCF service authentication | High | Modernise to REST/OAuth2; use managed identity for service-to-service |

### APP-002: File System and Network Resource Dependencies

| Current Resource | Migration Target | Migration Complexity | Key Consideration |
|----------------|-----------------|---------------------|-------------------|
| Windows file shares (SMB/CIFS) with NTFS permissions | [Azure Files with Entra ID DS](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable) | Medium | Entra ID Domain Services must be provisioned; NTFS permission mapping required |
| Distributed File System (DFS) namespaces | Azure Files DFS-N equivalent or SharePoint Online | Medium | DFS namespace topology must be replicated in Azure Files |
| Network-attached storage with AD integration | Azure Files or Azure NetApp Files with Kerberos | Medium–High | Depends on protocol and throughput requirements |
| Active Directory-published printers | [Universal Print](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-whatis) | Low | Native Intune integration; no on-premises connector required for cloud-joined devices |
| SharePoint on-premises document libraries | [SharePoint Online via SharePoint Migration Tool](https://learn.microsoft.com/en-us/sharepointmigration/introducing-the-sharepoint-migration-tool) | Low | Security mapping from AD groups to Entra ID groups required |

### APP-003: Database Authentication Dependencies

| Database Platform | Current Authentication | Cloud Solution | Migration Complexity | Estimated Timeframe |
|------------------|----------------------|----------------|---------------------|---------------------|
| SQL Server | Windows Authentication | [Azure SQL with Entra ID authentication](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview) | High | 6–12 months |
| Oracle | Kerberos authentication | Certificate-based authentication | Very High | 12–18 months |
| MySQL | Domain plugin | [Azure Database for MySQL with Entra ID](https://learn.microsoft.com/en-us/azure/mysql/single-server/concepts-azure-ad-authentication) | Medium | 3–6 months |
| PostgreSQL | GSSAPI / Kerberos | [Azure Database for PostgreSQL with Entra ID](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-azure-ad-authentication) | Medium | 3–6 months |
| MongoDB | Kerberos | Entra ID integration via MongoDB Atlas | High | 6–9 months |

## Modern Authentication Solutions

Sources: [Windows Hello for Business — Microsoft Learn](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/), [Microsoft Entra application proxy — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/app-proxy/), [Microsoft Entra CBA — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication).

### SOLUTION-001: Modern Authentication Architecture

| Layer | Technology | Purpose | Licence Requirement |
|-------|-----------|---------|---------------------|
| Primary authentication | [Azure AD Password Hash Sync](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-phs) | Synchronised credential validation | Entra ID Free |
| MFA | [Microsoft Entra MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks) | Second factor enforcement | Entra ID P1 |
| Passwordless | [Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/) | TPM-backed biometric / PIN | Entra ID P1 |
| Passwordless | [FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless) | Hardware token authentication | Entra ID P1 |
| SSO integration | [Azure AD Seamless SSO](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso) | Transparent sign-on for domain-joined legacy apps | Entra ID Free |
| SSO integration | SAML 2.0 / OIDC / OAuth 2.0 | Federation and delegated authorisation for SaaS and custom apps | Entra ID Free |
| Conditional Access | [Device-based, location-based, risk-based policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | Access control enforcement | Entra ID P1 |
| Legacy app integration | [Microsoft Entra application proxy](https://learn.microsoft.com/en-us/entra/identity/app-proxy/) | Cloud access for on-premises apps without VPN | Entra ID P1 |

### SOLUTION-002: Microsoft Entra Application Proxy for Legacy Applications

[Microsoft Entra application proxy](https://learn.microsoft.com/en-us/entra/identity/app-proxy/) provides secure remote access to on-premises web applications without requiring inbound firewall ports or a VPN. The connector initiates outbound connections only.

| Component | Role | Requirement |
|-----------|------|-------------|
| Application proxy connector | Installed on on-premises Windows Server; proxies traffic to internal apps | Windows Server 2016+; outbound HTTPS 443 to Azure |
| Entra ID pre-authentication | Validates user identity and Conditional Access before reaching internal app | Entra ID P1 licence per user |
| External URL | Published HTTPS endpoint under `*.msappproxy.net` or custom domain | Custom domain requires certificate in Entra ID |
| KCD configuration | Enables SSO to Kerberos-authenticated on-premises applications | Service Principal Names (SPNs) must be configured on target app |
| Connector groups | Logical grouping of connectors for geographic or application-specific routing | Minimum 2 connectors per group recommended for high availability |

**Application Proxy deployment phases:**

| Phase | Actions |
|-------|---------|
| 1 — Connector installation | Download and install connector on on-premises server; connector auto-registers with Entra ID |
| 2 — Application registration | Create app registration in Entra ID; configure internal and external URLs; set pre-authentication to Entra ID |
| 3 — Security configuration | Apply Conditional Access policies; configure HTTPS-only cookies; enable header translation |
| 4 — Testing and validation | Test internal access; test external access via proxy URL; validate SSO experience |

### SOLUTION-003: Certificate-Based Authentication for Modern Applications

[Microsoft Entra certificate-based authentication (CBA)](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication) allows organisations to authenticate users with X.509 certificates issued by their internal CA, eliminating the need for ADFS.

| Configuration Item | Detail |
|-------------------|--------|
| CA upload | Upload root and issuing CA certificates (.cer format) to Entra ID via Entra Admin Center > Security > Certificate authorities |
| CRL distribution | CRL distribution point URLs must be publicly accessible; delta CRL and base CRL URLs required |
| User binding | Certificate Subject Alternative Name (SAN) must contain a routable UPN or RFC822 email address that maps to the Entra ID user object |
| Certificate templates | User authentication EKU (`1.3.6.1.5.5.7.3.2`) required; key usage must include `digitalSignature` |
| Conditional Access integration | CBA can be used as a Conditional Access grant control; combine with device compliance for phishing-resistant MFA |
| Certificate lifecycle via Intune | Deploy SCEP or PKCS certificate profiles via [Intune certificate profiles](https://learn.microsoft.com/en-us/intune/intune-service/protect/certificates-configure) for managed devices |
| Azure Key Vault managed certs | Use [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/certificates/about-certificates) for automated certificate renewal with configurable lifetime actions |

## Assessment Checklists

### Authentication Pre-Migration Assessment

- [ ] Complete inventory of all applications using Windows Integrated Authentication or Kerberos
- [ ] Identify all NTLM authentication patterns via Security event log (Event ID 4624, authentication package = NTLM)
- [ ] Catalogue all certificate templates in use and their purpose (user auth, device auth, code signing, etc.)
- [ ] Document all service accounts and their consuming applications
- [ ] Map user authentication flows for each major application
- [ ] Identify users with cloud-only Entra ID accounts who may be affected by hybrid join requirements
- [ ] Assess ADFS dependency — if in use, evaluate migration to [password hash synchronisation](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-phs)

### Application Pre-Migration Assessment

- [ ] Complete inventory of all IIS-hosted applications and their authentication configuration
- [ ] Identify all applications using `Integrated Security=true` or `Trusted_Connection=yes` in database connection strings
- [ ] Catalogue all Windows services running under domain service accounts
- [ ] Map all DFS namespace paths and their underlying share targets
- [ ] Identify all Group Policy-deployed printers and assess Universal Print readiness
- [ ] Classify each application by migration complexity: Low / Medium / High / Very High
- [ ] Estimate effort per application category: Low = 1–2 months, Medium = 3–6 months, High = 6–12 months, Very High = 12–18 months

### Migration Planning

- [ ] Design modern authentication target architecture (passwordless, Conditional Access, Seamless SSO)
- [ ] Plan passwordless rollout: Windows Hello for Business for standard users; FIDO2 for high-privilege accounts
- [ ] Identify applications requiring application proxy and deploy connector infrastructure
- [ ] Design Entra ID CBA configuration: CA chain upload, CRL accessibility, user binding rules
- [ ] Create service account migration plan: map each domain service account to a managed identity equivalent
- [ ] Plan file services migration: Azure Files, SharePoint Online, or retention of on-premises with Entra ID DS
- [ ] Establish fallback authentication methods and emergency access procedures

### Post-Migration Validation

- [ ] Verify authentication success rates across all application categories
- [ ] Confirm no NTLM fallback is occurring (monitor with [Entra ID sign-in logs](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-in-log))
- [ ] Validate Conditional Access policies are enforcing as intended for cloud-native devices
- [ ] Confirm certificate auto-renewal is functioning where Azure Key Vault lifecycle management is configured
- [ ] Test application proxy SSO for each published on-premises application
- [ ] Validate compliance policy evaluation and Conditional Access grant controls for Entra-joined devices
- [ ] Document any applications retained on legacy authentication with a scheduled remediation date

## Related Resources

- [Windows Autopilot hybrid Azure AD join — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-hybrid)
- [Move to cloud-native endpoints — Microsoft Learn](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/cloud-native-windows-endpoints)
- [Microsoft Entra application proxy — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/app-proxy/)
- [Microsoft Entra certificate-based authentication — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication)
- [Windows Hello for Business — Microsoft Learn](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/)
- [FIDO2 security keys — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless)
- [Azure Files identity-based authentication — Microsoft Learn](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable)
- [SharePoint Migration Tool — Microsoft Learn](https://learn.microsoft.com/en-us/sharepointmigration/introducing-the-sharepoint-migration-tool)
- [Universal Print — Microsoft Learn](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-whatis)
- [Microsoft Entra Connect — Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect)
- [Best practices for migrating applications to Microsoft Entra ID — Microsoft Learn](https://learn.microsoft.com/en-us/entra/architecture/migration-best-practices)
