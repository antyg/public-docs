---
title: "Infrastructure Documentation"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# Infrastructure Documentation

## Purpose

This domain contains core infrastructure documentation covering certificate services, cloud landing zone architecture, infrastructure-as-code practices, server infrastructure, and foundational infrastructure components.

## Scope

The infrastructure domain encompasses:

- **Public Key Infrastructure (PKI)**: Certificate authority design, certificate lifecycle management, HSM integration, automated certificate enrolment
- **Cloud Landing Zones**: Azure landing zone architecture, management group hierarchy, subscription design, policy frameworks
- **Infrastructure as Code**: Terraform modules, ARM/Bicep templates, infrastructure automation, configuration management
- **Server Infrastructure**: Physical and virtual server design, capacity planning, high availability, disaster recovery
- **Identity Infrastructure**: Domain controllers, federation services, directory services (documented separately in identity/)
- **Storage Infrastructure**: Storage systems, backup architecture, data protection, archival strategies

## Current Structure

### Active Subfolders

| Subfolder | Status | Description |
|-----------|--------|-------------|
| [pki/](pki/) | Diátaxis migration complete | Public Key Infrastructure documentation including Azure Private CA implementation, AD CS integration, certificate lifecycle automation. Full Diátaxis structure: tutorials, how-to guides, reference, and explanation documents. |
| [azure-landing-zones/](azure-landing-zones/) | Seeded — explanation + reference outlines (planned) | Azure CAF landing zone architecture; management group hierarchy; subscription design; hub-spoke network topology; identity integration; Azure Policy governance; Defender for Cloud and Sentinel security baseline |
| [terraform/](terraform/) | Seeded — explanation + reference outlines (planned) | Terraform IaC workflows; init → plan → apply lifecycle; Azure Storage backend state management; module architecture; CI/CD integration; testing strategies; code structure conventions |

### Planned Expansion

Future expansion of this domain will include:

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
- Include security hardening requirements and compliance considerations aligned with the [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- Provide rollback and disaster recovery procedures
- Specify capacity requirements and scalability considerations
- Include operational procedures for day-2 operations

## Key Technologies

This domain covers:

- **Certificate Services**: Azure Private CA, AD CS, NDES, SCEP, EST, OCSP, CRL
- **Cloud Platforms**: Azure, hybrid and multi-cloud architectures
- **Infrastructure as Code**: Terraform, Bicep, ARM templates, Ansible, PowerShell DSC
- **Virtualisation**: Hyper-V, VMware, Azure Virtual Machines
- **Hardware Security Modules (HSM)**: Thales Luna, Azure Key Vault HSM, certificate key protection
- **Directory Services**: Active Directory, Azure AD, LDAP, DNS

## Migration Notes

### WP03 — Diátaxis Seeding (Complete 2026-03-16)

WP03 seeded two new subfolders with Diátaxis-aligned explanation and reference outlines:

- **azure-landing-zones/**: Two files added — `explanation-landing-zone-architecture.md` and `reference-landing-zone-configuration.md`. Status: planned stubs ready for content development.
- **terraform/**: Two files added — `explanation-terraform-workflows.md` and `reference-terraform-patterns.md`. Status: planned stubs ready for content development.

### Earlier Consolidation (Complete 2026-03-09)

- **PKI documentation** (534KB): Comprehensive PKI modernisation guides migrated to `infrastructure/pki/`; Diátaxis migration completed in WP02.
- **Azure Firewall content** (17KB): Networking-focused content migrated to `networking/azure-firewall/`.

## Navigation

- Parent: [antyg-public Documentation Library](../README.md)
- Sibling Domains: [networking/](../networking/), [identity/](../identity/), [security/](../security/)

---

**Australian English** | **Last Updated**: 2026-03-16
