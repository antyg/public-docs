# Public Key Infrastructure (PKI) Documentation

## Purpose

This folder contains comprehensive documentation for Public Key Infrastructure (PKI) design, implementation, and operations, including Azure Private CA integration, Active Directory Certificate Services (AD CS) modernisation, HSM integration, and automated certificate lifecycle management.

## Content Overview

This folder receives the complete PKI modernisation documentation from `other-infra/PKI/`, providing end-to-end guidance for implementing a modern, cloud-integrated PKI infrastructure.

### Migrated Content

**Source**: `other-infra/PKI/` (534KB total)

**Content Inventory**:

- **13 Sequential Implementation Guides**: Complete documentation from planning through cutover (00-index through 12)
- **Implementation Plan**: Project-scoped implementation plan (remains co-located per user decision)
- **68 PowerShell and Python Scripts**: Automation for PKI deployment, certificate operations, and validation
- **10 Configuration Files**: Templates for CA configuration, CRL distribution, OCSP responders, and HSM integration

### Implementation Architecture

The documentation follows a **5-phase implementation approach**:

#### Phase 1: Foundation
- Azure Private CA service deployment
- HSM integration for root and issuing CA keys
- Azure resource configuration (Key Vault, storage accounts, networking)
- Certificate profile design and policy definition

#### Phase 2: Core Infrastructure
- Active Directory Certificate Services (AD CS) integration
- Certificate Revocation List (CRL) distribution infrastructure
- Online Certificate Status Protocol (OCSP) responder deployment
- Certificate template configuration and versioning

#### Phase 3: Services Integration
- NDES (Network Device Enrollment Service) deployment for SCEP protocol support
- EST (Enrollment over Secure Transport) configuration
- NetScaler, F5, and Zscaler certificate integration
- Certificate autoenrollment configuration

#### Phase 4: Migration
- Certificate migration planning and execution
- Application certificate replacement
- Legacy PKI decommissioning procedures
- Rollback and contingency planning

#### Phase 5: Cutover
- Production cutover procedures
- Validation and testing protocols
- Operational handover documentation
- Monitoring and alerting configuration

## Key Technologies

### Certificate Services

- **Azure Private CA**: Managed certificate authority service in Azure
- **AD CS (Active Directory Certificate Services)**: Enterprise PKI for Windows environments
- **NDES (Network Device Enrollment Service)**: SCEP protocol support for device certificate enrollment
- **SCEP (Simple Certificate Enrollment Protocol)**: Automated certificate enrollment for devices
- **EST (Enrollment over Secure Transport)**: Modern certificate enrollment protocol
- **OCSP (Online Certificate Status Protocol)**: Real-time certificate revocation checking
- **CRL (Certificate Revocation List)**: Traditional revocation distribution mechanism

### Security and Key Management

- **HSM (Hardware Security Module)**: Thales Luna HSM for cryptographic key protection
- **Azure Key Vault**: Cloud-based key and secret management with HSM backing
- **Private Key Protection**: FIPS 140-2 Level 3 compliant key storage
- **Key Ceremony Procedures**: Multi-party key generation and backup procedures

### Integration Points

- **NetScaler**: Citrix NetScaler certificate integration for SSL offload
- **F5 BIG-IP**: F5 load balancer certificate management
- **Zscaler**: Cloud security platform certificate trust configuration
- **Windows Autoenrollment**: Group Policy-based certificate distribution
- **Web Server Integration**: IIS, Apache, nginx certificate deployment

## Documentation Structure

### Sequential Guides (00-12)

Each guide builds on the previous, covering:

0. **Index and Overview**: Navigation, architecture summary, prerequisites
1. **Planning and Design**: CA hierarchy, certificate profiles, naming conventions
2. **Azure Private CA Deployment**: Service setup, network configuration, identity management
3. **HSM Integration**: HSM initialisation, key generation, partition configuration
4. **Root CA Configuration**: Root key ceremony, root certificate generation, offline storage
5. **Issuing CA Configuration**: Issuing CA deployment, policy module configuration
6. **CRL Infrastructure**: CRL distribution points, CDP configuration, HTTP publishing
7. **OCSP Configuration**: OCSP responder deployment, signing certificate issuance
8. **AD CS Integration**: Enterprise CA configuration, certificate template creation
9. **NDES/SCEP Deployment**: NDES server setup, SCEP protocol configuration
10. **Service Integration**: NetScaler, F5, Zscaler certificate deployment
11. **Migration Procedures**: Certificate replacement, application updates, legacy decommissioning
12. **Cutover and Validation**: Production deployment, smoke testing, operational readiness

### Automation Scripts

**PowerShell Scripts** (51 files):
- Azure Private CA management cmdlets
- Certificate issuance and renewal automation
- CRL and OCSP publishing scripts
- AD CS template deployment
- Health monitoring and validation
- HSM key management utilities

**Python Scripts** (17 files):
- Certificate parsing and validation
- EST protocol client implementation
- Cryptographic operations
- Certificate chain validation
- OCSP client implementation

### Configuration Templates

- **CA Configuration Files**: Policy module, extensions, validity periods
- **CRL Distribution Points**: CDP URLs, publication intervals
- **OCSP Responder**: Signing certificate templates, responder policy
- **HSM Partition Configuration**: Key storage policies, backup procedures
- **Certificate Templates**: Template definitions for various use cases
- **GPO Settings**: Autoenrollment and trust configuration
- **Web Server Configs**: IIS, Apache, nginx certificate bindings
- **Load Balancer Configs**: NetScaler and F5 SSL profile templates
- **Azure Resource Templates**: ARM/Bicep for Azure Private CA resources
- **Network Security**: NSG rules, firewall policies for PKI services

## Certificate Lifecycle Coverage

The documentation addresses the complete certificate lifecycle:

1. **Certificate Request**: Enrollment protocols, validation procedures, approval workflows
2. **Certificate Issuance**: Template application, extension processing, signing operations
3. **Certificate Distribution**: Autoenrollment, manual deployment, trust chain publication
4. **Certificate Renewal**: Automatic renewal, manual renewal, re-keying procedures
5. **Certificate Revocation**: Revocation reasons, CRL publishing, OCSP updates
6. **Certificate Validation**: Chain validation, trust anchor configuration, revocation checking
7. **Certificate Archival**: Long-term retention, compliance requirements, key escrow

## Use Cases Covered

### Enterprise PKI
- Domain controller certificates
- User authentication certificates
- Email signing and encryption (S/MIME)
- Smart card logon
- Code signing certificates

### Infrastructure Certificates
- Web server SSL/TLS certificates
- Load balancer certificates
- VPN gateway certificates
- Wireless (802.1X) authentication
- IPsec certificates

### Device Certificates
- Mobile device management (MDM)
- IoT device authentication
- Network device (SCEP) enrollment
- Printer and scanner certificates
- Access point authentication

### Application Integration
- Service-to-service authentication
- API authentication (mTLS)
- Container and Kubernetes certificates
- Database encryption certificates
- Email gateway certificates

## Security Considerations

The documentation addresses:

- **Offline Root CA**: Air-gapped root CA for maximum security
- **HSM Key Protection**: Hardware-backed private key storage (FIPS 140-2 Level 3)
- **Key Ceremony Procedures**: Multi-party key generation with witness protocols
- **Secure CRL Distribution**: HTTPS-only CRL publishing, redundant distribution points
- **OCSP Security**: OCSP signing certificate rotation, responder authentication
- **Template Security**: Minimal permission grants, approval requirements for sensitive templates
- **Audit Logging**: Comprehensive audit trails for all PKI operations
- **Disaster Recovery**: Key backup procedures, CA restoration processes

## Operational Procedures

Day-2 operations covered include:

- **Health Monitoring**: Certificate expiry monitoring, CRL freshness checks, OCSP availability
- **Performance Tuning**: CRL publication intervals, OCSP caching, template optimisation
- **Capacity Planning**: Certificate issuance rates, storage requirements, bandwidth planning
- **Troubleshooting**: Common issues, diagnostic procedures, resolution steps
- **Backup and Recovery**: CA database backup, key backup, disaster recovery testing
- **Compliance**: Audit procedures, compliance reporting, policy enforcement

## Relationship to Other Content

This PKI documentation integrates with:

- **identity/entra-id/**: Azure AD certificate-based authentication
- **networking/expressroute/**: Certificate requirements for hybrid connectivity
- **infrastructure/azure-landing-zones/**: Landing zone trust and encryption requirements
- **security/**: Certificate-based security controls and compliance
- **operations/monitoring/**: PKI health monitoring and alerting

## Audience

This documentation is intended for:

- PKI architects designing certificate authority hierarchies
- Security engineers implementing certificate-based authentication
- Infrastructure engineers deploying and managing PKI services
- Application teams integrating certificate-based security
- Compliance and audit teams validating PKI controls
- Operations teams monitoring and maintaining PKI infrastructure

## Implementation Timeline

The documented implementation follows a phased approach:

- **Weeks 1-4**: Foundation phase (Azure Private CA, HSM integration)
- **Weeks 5-8**: Core infrastructure (CRL, OCSP, AD CS integration)
- **Weeks 9-12**: Services integration (NDES, application integration)
- **Weeks 13-16**: Migration (certificate replacement, legacy decommissioning)
- **Week 17+**: Cutover and operational handover

## Prerequisites

Before implementing the documented PKI solution:

- Azure subscription with appropriate resource providers
- HSM hardware (Thales Luna or equivalent) or Azure Key Vault Premium
- Active Directory domain with appropriate schema extensions
- Network connectivity between on-premises and Azure (ExpressRoute recommended)
- Windows Server infrastructure for AD CS and NDES roles
- Administrative access to applications requiring certificate integration

## Navigation

- Parent: [infrastructure/](../README.md)
- Domain Root: [antyg-public Documentation Library](../../README.md)

---

**Australian English** | **Last Updated**: 2026-02-09
