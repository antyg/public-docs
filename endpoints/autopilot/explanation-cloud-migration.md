---
title: "Cloud Migration Strategy"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Cloud Migration Strategy

This document explains the conceptual foundations of migrating from hybrid Microsoft Entra join to cloud-native Windows Autopilot deployments. It covers why organisations migrate, what authentication and application dependencies create friction, and how a phased approach manages coexistence during the transition. It is understanding-oriented — it does not provide configuration procedures.

---

## Migration Rationale

### Microsoft's Strategic Direction

Microsoft [explicitly recommends deploying new devices as cloud-native using Microsoft Entra join](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/azure-ad-joined-hybrid-azure-ad-joined) rather than hybrid Entra join. This position has hardened progressively: hybrid join is characterised as a transitional bridge, not a destination architecture. New endpoint management capabilities are developed for cloud-native endpoints first; hybrid-join equivalents are either delivered later or not at all.

The deprecation of the [Intune Connector for Active Directory](https://learn.microsoft.com/en-us/autopilot/whats-new) versions earlier than 6.2501.2000.5 in June 2025 created concrete migration urgency for organisations running hybrid Autopilot flows. This is a pattern that will continue: hybrid-specific infrastructure components have shorter support lifecycles than their cloud-native equivalents.

### Structural Limitations of Hybrid Join

[Hybrid Entra joined devices require network line-of-sight to on-premises domain controllers](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/azure-ad-joined-hybrid-azure-ad-joined) for user sign-in and policy updates. This dependency constrains device deployment to locations with domain controller access and creates complexity for remote workers, branch offices, and hardware refresh cycles. Devices that lose domain controller connectivity cannot authenticate new users, receive Group Policy updates, or complete certain compliance checks.

Hybrid join also creates a policy conflict surface: Group Policy Objects (GPOs) and Intune configuration profiles can apply to the same device, and resolving conflicts between the two policy engines adds operational overhead. Cloud-native devices are managed exclusively through Intune, eliminating this dual-policy surface.

From a security posture perspective, cloud-native devices enable security controls that operate consistently regardless of network location. The [Australian Signals Directorate's Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) Maturity Model expects organisations to implement application control, patch management, and restrict administrative privileges across all managed endpoints — requirements that are more consistently enforced through a single cloud management plane than through a hybrid arrangement where on-premises Group Policy and cloud MDM policies must be kept aligned.

### The Migration Imperative

The combination of Microsoft's product investment direction, deprecation of hybrid-specific infrastructure, and the operational simplification benefits of a single management plane create a clear migration rationale. The barriers to migration are not architectural preferences — they are concrete technical dependencies that must be assessed and addressed systematically before devices can be transitioned.

---

## Authentication Transition Challenges

### The Domain Authentication Dependency Problem

Enterprise environments that have operated on Active Directory for many years accumulate deep authentication dependencies. These dependencies are not always visible in application documentation — they exist in how applications were built, how databases are accessed, and how services authenticate to each other. A cloud-native device, joined only to Microsoft Entra ID, does not have a domain computer account and cannot participate in Kerberos authentication against on-premises Active Directory by default.

The primary categories of domain authentication dependency are:

**Windows Integrated Authentication (WIA):** Many on-premises web applications, SharePoint farms, and line-of-business applications use Negotiate or NTLM authentication. These protocols rely on the user's domain session, which is established at sign-in when a device is domain-joined or hybrid-joined. A user signing into an Entra-joined device does not establish a domain session unless a bridging mechanism is in place.

**Certificate-based authentication:** Organisations with mature Public Key Infrastructure (PKI) may have applications, VPNs, or smart card authentication flows that depend on certificates issued by an on-premises Certificate Authority. Moving to cloud-native devices does not automatically replace this infrastructure — the certificate provisioning mechanism must be replicated in a cloud-aware form.

**Service account dependencies:** Background services, scheduled tasks, application pools, and database connection strings may authenticate using domain service accounts. These are entirely separate from interactive user authentication and are often not inventoried alongside user-facing applications.

**Kerberos Service Principal Names (SPNs):** Applications registered with SPNs in Active Directory receive Kerberos tickets when accessed from domain-joined machines. An Entra-joined device without a Kerberos bridging mechanism cannot obtain these tickets and will fail to authenticate to such applications.

### Kerberos and the Cloud Trust Model

Microsoft has addressed the Kerberos gap through [Microsoft Entra Kerberos](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust), which turns Microsoft Entra ID into a cloud Key Distribution Centre (KDC) for Kerberos authentication. When Windows Hello for Business is deployed with the cloud Kerberos trust model, Entra-joined devices can request Ticket Granting Tickets (TGTs) for on-premises Active Directory domains without requiring on-premises PKI or certificate synchronisation. This is Microsoft's [recommended hybrid deployment model for Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust) and the primary mechanism for maintaining single sign-on (SSO) to on-premises resources from cloud-native devices.

Cloud Kerberos trust requires:
- Microsoft Entra Kerberos server objects created in each Active Directory domain
- Sufficient domain controller write access in each Active Directory site
- Minimum supported Windows client and server versions

This mechanism enables passwordless authentication (Windows Hello for Business or FIDO2 security keys) while preserving access to on-premises resources secured by Kerberos — the most significant barrier for organisations attempting to move away from hybrid join.

### Certificate Challenges in a Cloud-Native Context

Moving certificate-based authentication to a cloud-native model requires replacing the on-premises certificate issuance and distribution pipeline. On-premises Enterprise CAs issue certificates through Group Policy auto-enrolment, a mechanism unavailable to Entra-joined devices. The cloud-native equivalent is [Microsoft Intune Certificate Connector with SCEP or PKCS profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure), which provides policy-driven certificate deployment to enrolled devices without requiring domain membership.

For organisations with mature PKI, a hybrid certificate trust chain is typically maintained during the migration period: on-premises Certificate Authorities remain authoritative, but certificate delivery to new cloud-native devices is handled through Intune rather than Group Policy. Over time, certificate-based authentication dependencies are either eliminated through modern authentication adoption or maintained through [Microsoft Entra certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication), which allows Entra ID to validate user certificates issued by trusted on-premises CAs.

### Modern Authentication Architecture as the Target State

The target authentication architecture for cloud-native endpoints relies on protocols that do not require domain membership: OAuth 2.0, OpenID Connect, SAML 2.0, and FIDO2. Applications that authenticate through these protocols work identically from an Entra-joined device as from a hybrid-joined device.

[Microsoft Entra Application Proxy](https://learn.microsoft.com/en-us/entra/identity/app-proxy/overview-what-is-app-proxy) provides a bridge for on-premises applications that cannot be immediately modernised. Application Proxy publishes on-premises web applications through a cloud relay, applying Entra ID pre-authentication and Conditional Access before traffic reaches the on-premises application. This allows cloud-native devices to access legacy on-premises applications secured with Windows Integrated Authentication through a modern authentication front-end, without requiring VPN or network line-of-sight. Internally, Application Proxy connectors can perform [Kerberos Constrained Delegation](https://learn.microsoft.com/en-us/entra/identity/app-proxy/conceptual-deployment-plan) on behalf of authenticated users, satisfying the on-premises application's Kerberos requirement transparently.

This architecture means that authentication modernisation is not a prerequisite for every application before migration can begin. Application Proxy provides a coexistence mechanism that decouples device migration from application modernisation.

---

## Application Compatibility Considerations

### Domain-Joined Application Dependencies

The category of applications most likely to block or complicate cloud-native migration are those built with Active Directory as an assumed dependency rather than an external service. Such applications may:

- Use Windows Integrated Authentication for user login, assuming the user has a domain session
- Connect to SQL Server or other databases using `Integrated Security=true` in connection strings, passing the application pool's domain service account identity
- Perform group membership lookups against Active Directory using LDAP queries to determine user authorisation
- Use Distributed COM (DCOM) or WCF with Windows Authentication for inter-service communication
- Depend on file shares accessed via SMB with NTFS permissions governed by domain security groups

The presence of these patterns does not mean the application cannot be accessed from a cloud-native device — it means the access mechanism must be mediated. Application Proxy handles the browser-accessible web application case. For thick-client applications or service-to-service authentication, the dependency must be addressed at the application or infrastructure layer.

### File and Network Resource Access

Network file shares present a specific challenge. SMB file shares with NTFS permissions controlled by domain security groups require Kerberos authentication to access. A cloud-native device using cloud Kerberos trust can obtain TGTs for on-premises domains and therefore access these shares via SSO — this is the primary benefit of the cloud Kerberos trust model for file access scenarios.

Where file data needs to move to cloud storage long-term, [Azure Files with identity-based authentication](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview) supports both on-premises AD DS and Microsoft Entra Domain Services as identity sources, providing a migration path that preserves existing permission models while the underlying storage moves to Azure. SharePoint Online and OneDrive for Business represent the cloud-native target for document and collaboration content.

[Microsoft Universal Print](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-whatis) addresses the print services dependency. On-premises print queues published in Active Directory are inaccessible to Entra-joined devices without bridging. Universal Print replaces this with a cloud print service managed through Microsoft Entra ID and Intune, eliminating the domain print dependency entirely.

### Database Authentication Dependencies

Database platforms that use Windows Authentication — most commonly SQL Server with `Integrated Security=true` connection strings — present a particular complication. These connections authenticate as the calling process's Windows identity (a domain service account), which does not exist for services running on cloud-native devices.

The cloud-native equivalents are [Azure AD authentication for Azure SQL Database and SQL Managed Instance](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview) (for workloads moving to Azure SQL) and [Azure Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) for application-to-service authentication, which replace service account credentials with automatically rotated Entra identity tokens. For on-premises SQL Server instances that cannot yet be migrated, a hybrid authentication bridge — where both Windows Authentication and Entra-based authentication are accepted simultaneously — supports a gradual migration of application connection strings.

### Complexity Stratification

Not all applications present equal migration complexity. Applications using modern authentication protocols (OAuth 2.0, OIDC, SAML) with cloud identity providers work without modification from cloud-native devices. Applications using Windows Integrated Authentication but accessible via a browser can typically be fronted by Application Proxy. Applications with deep Active Directory schema dependencies, service-to-service Kerberos, or embedded domain service account credentials require direct remediation work.

Categorising the application estate by this complexity dimension — modern, Application Proxy bridgeable, or requires remediation — determines the migration wave structure and the realistic timeline before the hybrid infrastructure can be retired.

---

## Migration Phasing

### Why a Phased Approach

Organisations with substantial hybrid infrastructure cannot switch from hybrid to cloud-native Autopilot in a single event. The authentication and application dependencies described above create a technical coexistence requirement: cloud-native devices must be able to reach on-premises resources while those resources are being progressively modernised or bridged. A phased migration approach respects this reality and manages risk by limiting the scope of each wave.

[Microsoft's cloud-native endpoints guidance](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/cloud-native-endpoints-overview) characterises hybrid Entra join as appropriate for existing devices until replacement or reset, with new devices deployed as Entra joined. This creates a natural migration boundary: the hardware refresh cycle.

### Assessment and Foundation Phase

Before any devices are migrated, the authentication and application dependency landscape must be mapped. This involves discovering which applications use Windows Integrated Authentication, which services use domain service accounts, which certificate templates are in use, and which file shares have domain-group-controlled permissions. Without this inventory, migration waves cannot be stratified by complexity, and the risk of disrupting production workloads is unacceptable.

The foundation phase also establishes the cloud authentication infrastructure that will support migrated devices: Microsoft Entra Kerberos server objects for cloud Kerberos trust, Intune Certificate Connector for certificate delivery, Application Proxy connectors for legacy application bridging, and Windows Hello for Business policies for passwordless authentication.

Consistent with [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) guidance on multi-factor authentication and application control, the target cloud-native state should enforce MFA for all cloud resource access and apply Conditional Access policies that gate access on device compliance state — policies that are significantly easier to enforce uniformly once hybrid join complexity is removed.

### Pilot Phase

A controlled pilot — typically five to ten per cent of the user population — validates the foundation before broad rollout. The pilot group should be representative in terms of application dependencies, not selected purely for technical simplicity. Finding Application Proxy gaps, Kerberos trust configuration issues, or certificate delivery failures in a pilot of 100 users is substantially less disruptive than discovering them during a wave of 2,000.

The pilot phase validates not only technical function but user experience. Entra-joined devices behave differently from hybrid-joined devices in observable ways: sign-in behaviour, cached credential handling, and the absence of domain-specific group policy controls. Change management and user communication are prerequisites for the pilot, not afterthoughts.

### Wave-Based Migration

Following a successful pilot, migration proceeds in waves stratified by application complexity. A common stratification is:

- **Wave 1** (low complexity, approximately 30% of population): Users whose application estate is predominantly cloud-hosted or accessible via modern authentication. Minimal Application Proxy dependency. Short remediation backlog.
- **Wave 2** (medium complexity, approximately 40% of population): Users with some on-premises application dependencies addressable via Application Proxy or cloud Kerberos trust. Moderate change management requirements.
- **Wave 3** (high complexity, approximately 30% of population): Users with deep Active Directory-integrated application dependencies requiring direct application remediation, database migration, or extended hybrid bridging arrangements.

Wave stratification is determined by the dependency inventory from the assessment phase, not by organisational unit or geography alone.

### Coexistence Period

During migration waves, the environment operates in a coexistence state: some devices are Entra-joined and cloud-native; others are hybrid-joined and managed through the existing tooling. The coexistence period has a defined end state — when the last hybrid-joined device is retired or reset — and it should be time-bounded. An indefinite coexistence state increases operational overhead and delays the security and simplicity benefits of the cloud-native target.

The hybrid infrastructure (on-premises domain controllers, Entra Connect synchronisation, Intune Connector for Active Directory) should not be retired until the dependency inventory confirms zero remaining production dependencies. Premature retirement of hybrid infrastructure is a significant rollback risk.

### Success Metrics

A migration programme should track leading and lagging indicators against defined thresholds. Technical success metrics include authentication success rates, application availability from cloud-native devices, certificate provisioning success rates, and device compliance rates. User experience metrics include helpdesk ticket volumes relating to authentication or application access issues and user satisfaction scores. Business metrics include reduction in hybrid infrastructure operational costs and improvement in security posture indicators (MFA coverage, device compliance coverage, Conditional Access policy scope).

Thresholds are organisation-specific and should be anchored to current baseline measurements rather than aspirational targets. A threshold of "95% authentication success rate" is only meaningful if the current hybrid baseline is measured before migration begins.

---

## Related Resources

### Microsoft Learn

- [Cloud-Native Endpoints Overview](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/cloud-native-endpoints-overview)
- [Microsoft Entra Joined vs. Hybrid Entra Joined](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/azure-ad-joined-hybrid-azure-ad-joined)
- [Windows Autopilot Overview](https://learn.microsoft.com/en-us/autopilot/overview)
- [What's New in Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/whats-new)
- [Windows Hello for Business Cloud Kerberos Trust Deployment](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust)
- [Microsoft Entra Application Proxy Overview](https://learn.microsoft.com/en-us/entra/identity/app-proxy/overview-what-is-app-proxy)
- [Secure Hybrid Access for Legacy Applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/secure-hybrid-access)
- [Application Proxy Deployment Plan](https://learn.microsoft.com/en-us/entra/identity/app-proxy/conceptual-deployment-plan)
- [Microsoft Entra Certificate-Based Authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-certificate-based-authentication)
- [Intune Certificate Connector Configuration](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure)
- [Azure Files Identity-Based Authentication](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview)
- [Azure AD Authentication for Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview)
- [Azure Managed Identities Overview](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [Universal Print Overview](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-whatis)
- [Microsoft Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)

### Australian Regulatory and Security Frameworks

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ASD Small Business Cloud Security Guides (Microsoft 365 and Intune)](https://www.cyber.gov.au/resources-business-and-government/essential-cybersecurity/small-business-cybersecurity/small-business-cloud-security-guide/small-business-cloud-security-guides-introduction)

### Related Documentation in This Library

- [Windows Autopilot Architecture](explanation-architecture.md) — Service boundaries, deployment modes, and the Autopilot–Entra–Intune handoff chain
