---
title: "Public Key Infrastructure (PKI) Documentation"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# Public Key Infrastructure (PKI) Documentation

## Purpose

This directory contains the complete PKI modernisation documentation suite covering the design, implementation, operations, and migration of a hybrid Azure-integrated Public Key Infrastructure. The documented implementation deployed across 11 weeks, migrating 10,000 devices from a legacy PKI to a modern, cloud-integrated architecture.

## Scope

This documentation covers:

- Azure Private CA service deployment and configuration
- Active Directory Certificate Services (AD CS) on Windows Server 2022
- Hardware Security Module (HSM) integration via Azure Key Vault
- Certificate lifecycle management: enrolment, renewal, revocation
- NDES/SCEP and EST protocol configuration for device and IoT enrolment
- Integration with SCCM, Intune, NetScaler, F5, Zscaler, and Palo Alto
- Phased migration from legacy PKI across three waves
- 68 automation scripts and 10 configuration files

Out of scope: certificate-based authentication policy (see [identity/entra-id/](../identity/)), network firewall rule management (see [networking/](../../networking/README.md)).

## Audience

| Role | Primary Content |
|------|----------------|
| PKI architects | Explanation files, reference-configuration.md, reference-diagrams.md |
| Infrastructure engineers | How-to guides (how-to-\*), reference-configuration.md |
| Operations teams | How-to guides, reference-scripts-catalogue.md, scripts/ |
| Security engineers | Explanation files, reference-configuration.md (cryptographic standards) |
| Compliance and audit | reference-project-timeline.md (compliance timeline) |
| Migration leads | reference-project-timeline.md, how-to guides (Phase 4–5) |

---

## Content Index

### Reference (Information-Oriented)

Factual lookup material structured for quick access. No procedures.

| File | Content |
|------|---------|
| [reference-project-timeline.md](reference-project-timeline.md) | Implementation phases, milestones, resource matrix, budget, risk heat map, KPIs |
| [reference-configuration.md](reference-configuration.md) | CAPolicy.inf parameters, certificate template OIDs, registry keys, PowerShell cmdlets, network ports, error codes |
| [reference-scripts-catalogue.md](reference-scripts-catalogue.md) | All 68 scripts: descriptions, language, phase, cross-reference to how-to guides |
| [reference-diagrams.md](reference-diagrams.md) | Mermaid diagrams: CA hierarchy, network topology, enrollment flows, migration sequence, state machine |

### Explanation (Understanding-Oriented)

Conceptual background on PKI architecture, trust models, and design decisions.

| File | Content |
|------|---------|
| [explanation-pki-architecture.md](explanation-pki-architecture.md) | CA hierarchy rationale, two-tier model, offline root CA design |
| [explanation-enrollment-protocols.md](explanation-enrollment-protocols.md) | Certificate enrolment protocols (autoenrolment, SCEP, EST), lifecycle states, revocation |
| [explanation-migration-strategy.md](explanation-migration-strategy.md) | PKI migration strategy and rationale, Azure Private CA integration, trust propagation |

### How-To Guides (Task-Oriented)

Goal-oriented procedural guides for specific implementation tasks.

| File | Content |
|------|---------|
| [how-to-deploy-foundation.md](how-to-deploy-foundation.md) | Azure infrastructure, Key Vault HSM, Azure Private CA deployment |
| *(planned)* how-to-core-infrastructure.md | AD CS installation, issuing CA configuration, NDES, templates, GPOs |
| [how-to-integrate-services.md](how-to-integrate-services.md) | Code signing, SCCM, NetScaler, F5, Zscaler, Intune integration |
| *(planned)* how-to-execute-migration.md | Pilot and production wave execution, validation, rollback |
| [how-to-execute-cutover.md](how-to-execute-cutover.md) | Cutover execution, legacy CA decommissioning, project closure |
| [how-to-operate-pki.md](how-to-operate-pki.md) | Daily health checks, certificate renewal, revocation, backup |
| [how-to-disaster-recovery.md](how-to-disaster-recovery.md) | CA restoration from backup, key recovery, emergency procedures |

---

## Subdirectory Descriptions

### scripts/

Contains all 68 automation scripts for PKI deployment, configuration, operations, testing, and migration. See [scripts/README.md](scripts/README.md) for the full inventory.

| Category | Count |
|----------|-------|
| Deployment | 11 |
| Configuration | 29 |
| Operations | 13 |
| Testing | 6 |
| Migration | 8 |

Languages: PowerShell (58), Python (4), Shell (3), Tcl (1), C (1), HTML (1).

### config/

Contains 10 configuration file templates for CA policy, CRL distribution, OCSP, monitoring, HSM, governance, and appliance integration. See [config/README.md](config/README.md) for the full inventory.

---

## Implementation Architecture

### CA Hierarchy

Two-tier model:

- **Root CA**: Offline, HSM-protected in Azure Key Vault Premium. RSA 4096, SHA-256, 20-year validity.
- **Issuing CAs**: Two Active-Active instances (Windows Server 2022). RSA 4096, SHA-256, 5-year validity.

### Phase Summary

| Phase | Period | Outcome |
|-------|--------|---------|
| 1: Foundation | 3–14 Feb 2025 | Azure infrastructure, Root CA, HSM operational |
| 2: Core Infrastructure | 17–28 Feb 2025 | Issuing CAs, NDES, 15+ templates, autoenrolment |
| 3: Services Integration | 3–14 Mar 2025 | Code signing, SCCM, load balancers, monitoring |
| 4: Migration | 17 Mar–11 Apr 2025 | 10,000 devices migrated across 3 waves |
| 5: Cutover | 14–18 Apr 2025 | Legacy CA offline, handover complete |

### Key Metrics

| Metric | Value |
|--------|-------|
| Total devices migrated | 10,000 |
| Certificates managed | 50,000+ |
| Migration success rate | 99.3% |
| Certificate issuance time (post-deployment) | <30 seconds |
| System availability target | 99.95% |
| Manual overhead reduction | 80% |

---

## Key Technologies

| Technology | Role |
|-----------|------|
| Azure Private CA | Managed root CA service |
| Azure Key Vault (Premium HSM) | HSM-protected key storage (FIPS 140-2 Level 3) |
| AD CS on Windows Server 2022 | Issuing CA and certificate template management |
| NDES | SCEP protocol gateway for device enrolment |
| Intune Connector | Certificate delivery to Intune-managed devices |
| OCSP Responder | Real-time certificate revocation status |
| NetScaler ADC | SSL offload and certificate binding |
| F5 BIG-IP | SSL profile management |
| Zscaler | Enterprise CA trust integration |
| SCCM | Client certificate autoenrolment |

---

## Status

This directory is **draft**. Reference files, explanation files, and most how-to guides are complete. Two how-to guides remain planned.

| Content Type | Status |
|-------------|--------|
| Reference files (4) | Draft — complete |
| Explanation files (3) | Draft — complete |
| How-to guides (5 of 7) | Draft — complete (2 planned) |
| Scripts (68) | Present in scripts/ |
| Config files (10) | Present in config/ |

---

## Navigation

- Parent: [infrastructure/](../README.md)
- Domain root: [antyg-public Documentation Library](../../README.md)
- Related: [identity/entra-id/](../../identity/entra-id/) — certificate-based authentication
- Related: [networking/](../../networking/README.md) — ExpressRoute connectivity for PKI
- Related: [security/](../../security/README.md) — certificate-based security controls
