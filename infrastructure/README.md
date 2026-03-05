# Infrastructure Documentation

## Purpose

This domain contains core infrastructure documentation covering certificate services, server infrastructure, cloud landing zone architecture, infrastructure-as-code practices, and foundational infrastructure components.

## Scope

The infrastructure domain encompasses:

- **Public Key Infrastructure (PKI)**: Certificate authority design, certificate lifecycle management, HSM integration, automated certificate enrollment
- **Cloud Landing Zones**: Azure landing zone architecture, management group hierarchy, subscription design, policy frameworks
- **Infrastructure as Code**: Terraform modules, ARM/Bicep templates, infrastructure automation, configuration management
- **Server Infrastructure**: Physical and virtual server design, capacity planning, high availability, disaster recovery
- **Identity Infrastructure**: Domain controllers, federation services, directory services (documented separately in identity/)
- **Storage Infrastructure**: Storage systems, backup architecture, data protection, archival strategies

## Current Structure

### Subfolders

- **pki/**: Public Key Infrastructure documentation including Azure Private CA implementation, AD CS integration, certificate lifecycle automation

### Planned Expansion

Future expansion of this domain will include:

- **azure-landing-zones/**: Enterprise-scale landing zone design, management groups, policy assignments, governance
- **terraform/**: Terraform module library, state management, CI/CD pipelines, best practices
- **server-infrastructure/**: Physical and virtual server documentation, patching strategies, configuration baselines
- **backup-recovery/**: Backup architecture, recovery procedures, business continuity planning
- **monitoring/**: Infrastructure monitoring, alerting, capacity management, performance tuning
- **automation/**: Infrastructure automation scripts, runbooks, orchestration workflows

## Relationship to Other Domains

This domain provides foundational services for:

- **networking/**: Network infrastructure supports connectivity and security boundaries
- **identity/**: Identity services rely on PKI for certificate-based authentication
- **security/**: Security controls depend on infrastructure hardening and PKI services
- **endpoints/**: Endpoint management relies on infrastructure services for deployment and configuration

## Content Standards

Documentation in this domain should:

- Include architecture diagrams following standard notation (C4, UML, or Azure icons)
- Provide both declarative (IaC) and imperative (scripts) implementation examples
- Document dependencies between infrastructure components
- Include security hardening requirements and compliance considerations
- Provide rollback and disaster recovery procedures
- Specify capacity requirements and scalability considerations
- Include operational procedures for day-2 operations

## Key Technologies

This domain covers:

- **Certificate Services**: Azure Private CA, AD CS, NDES, SCEP, EST, OCSP, CRL
- **Cloud Platforms**: Azure, AWS, hybrid and multi-cloud architectures
- **Infrastructure as Code**: Terraform, Bicep, ARM templates, Ansible, PowerShell DSC
- **Virtualisation**: Hyper-V, VMware, Azure Virtual Machines
- **Hardware Security Modules (HSM)**: Thales Luna, Azure Key Vault HSM, certificate key protection
- **Directory Services**: Active Directory, Azure AD, LDAP, DNS

## Migration Notes

The infrastructure domain is receiving substantial content from the `other-infra/` consolidation effort:

- **PKI documentation** (534KB): Comprehensive PKI modernisation guides migrating to `infrastructure/pki/`
- **Azure Firewall content** (17KB): Networking-focused content migrating to `networking/azure-firewall/`

Additional infrastructure content will be organised into appropriate subfolders as the domain structure expands.

## Navigation

- Parent: [antyg-public Documentation Library](../README.md)
- Sibling Domains: [networking/](../networking/), [identity/](../identity/), [security/](../security/)

---

**Australian English** | **Last Updated**: 2026-02-09
