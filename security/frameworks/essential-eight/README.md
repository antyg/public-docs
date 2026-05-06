---
title: "Essential Eight"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Essential Eight

---

## Purpose

This folder contains documentation for the [Australian Cyber Security Centre (ACSC) Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — a prioritised set of eight mitigation strategies designed to protect Australian organisations from cyber security incidents.

The ACSC recommends all organisations implement the Essential Eight to [Maturity Level 2 (ML2)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) at a minimum. ML2 is the mandated baseline for Australian Government entities under the [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/).

---

## The Eight Strategies

1. **Application Control** — Prevent execution of unapproved applications
2. **Patch Applications** — Update security vulnerabilities in applications
3. **Configure Microsoft Office Macro Settings** — Restrict macro execution
4. **User Application Hardening** — Disable risky features in office productivity suites and web browsers
5. **Restrict Administrative Privileges** — Limit users with privileged access
6. **Patch Operating Systems** — Update security vulnerabilities in operating systems
7. **Multi-Factor Authentication** — Require multiple verification factors for access
8. **Regular Backups** — Maintain recoverable copies of important data

### Maturity Levels

| Level | Coverage | Threat Profile |
|-------|----------|---------------|
| **ML1** | Partial | Most common opportunistic threats |
| **ML2** | Broad | Most targeted threats (ACSC recommended minimum) |
| **ML3** | Complete | Sophisticated adversaries |

---

## Content Index

### Explanations

| File | Description |
|------|-------------|
| [explanation-why-essential-eight.md](explanation-why-essential-eight.md) | Strategic context — why the Essential Eight exists and its role in Australian cyber security |

### How-To Guides

#### General Implementation

| File | Description |
|------|-------------|
| [how-to-implement-e8-controls.md](how-to-implement-e8-controls.md) | Overview guide for implementing Essential Eight controls across all strategies |
| [how-to-collect-compliance-evidence.md](how-to-collect-compliance-evidence.md) | Collecting, organising, and presenting evidence for compliance assessments |

#### Per-Strategy Implementation

| File | Strategy |
|------|----------|
| [how-to-implement-application-control.md](how-to-implement-application-control.md) | Strategy 1 — Application Control |
| [how-to-implement-patch-applications.md](how-to-implement-patch-applications.md) | Strategy 2 — Patch Applications |
| [how-to-implement-office-macro-settings.md](how-to-implement-office-macro-settings.md) | Strategy 3 — Office Macro Settings |
| [how-to-implement-user-application-hardening.md](how-to-implement-user-application-hardening.md) | Strategy 4 — User Application Hardening |
| [how-to-implement-restrict-admin-privileges.md](how-to-implement-restrict-admin-privileges.md) | Strategy 5 — Restrict Administrative Privileges |
| [how-to-implement-patch-operating-systems.md](how-to-implement-patch-operating-systems.md) | Strategy 6 — Patch Operating Systems |
| [how-to-implement-multi-factor-authentication.md](how-to-implement-multi-factor-authentication.md) | Strategy 7 — Multi-Factor Authentication |
| [how-to-implement-regular-backups.md](how-to-implement-regular-backups.md) | Strategy 8 — Regular Backups |

#### Configuration Guides

| File | Description |
|------|-------------|
| [how-to-configure-access-controls.md](how-to-configure-access-controls.md) | MFA, RBAC, PAM, and just-in-time access configuration |
| [how-to-configure-patch-management.md](how-to-configure-patch-management.md) | Patch management infrastructure for Strategies 2 and 6 |
| [how-to-configure-backup-recovery.md](how-to-configure-backup-recovery.md) | Backup and recovery configuration for Strategy 8 |

#### Maturity Upgrade Playbooks

| File | Description |
|------|-------------|
| [how-to-upgrade-ml1-to-ml2.md](how-to-upgrade-ml1-to-ml2.md) | Step-by-step upgrade path from ML1 to ML2 |
| [how-to-upgrade-ml2-to-ml3.md](how-to-upgrade-ml2-to-ml3.md) | Step-by-step upgrade path from ML2 to ML3 |

### References

| File | Description |
|------|-------------|
| [reference-maturity-model.md](reference-maturity-model.md) | Maturity level definitions and assessment criteria |
| [reference-glossary.md](reference-glossary.md) | Essential Eight terminology and definitions |
| [reference-cross-reference-matrix.md](reference-cross-reference-matrix.md) | Control dependencies, implementation sequencing, and maturity level requirements |
| [reference-ml1-compliance-report-template.md](reference-ml1-compliance-report-template.md) | ML1 compliance report template |
| [reference-ml2-compliance-report-template.md](reference-ml2-compliance-report-template.md) | ML2 compliance report template |
| [reference-ml3-compliance-report-template.md](reference-ml3-compliance-report-template.md) | ML3 compliance report template |

### Tutorials

| File | Description |
|------|-------------|
| [tutorial-getting-started-with-essential-eight.md](tutorial-getting-started-with-essential-eight.md) | Guided introduction to the Essential Eight for newcomers |

---

## Relationship to Other Domains

| Domain | Relationship |
|--------|--------------|
| `compliance/essential-eight-alignment/` | **Downstream** — Maps these framework controls to Microsoft technology implementations |
| `security/defender-for-endpoint/` | **Product reference** — Implements controls for Strategies 1, 2, 4, 6 |
| `security/defender-for-cloud/` | **Product reference** — Implements controls for Strategies 1, 2, 6 |
| `identity/` | **Product reference** — Implements controls for Strategies 5, 7 |
| `endpoints/intune/` | **Product reference** — Implements controls for Strategies 1, 2, 3, 4, 6 |

---

## Related Resources

### ACSC Essential Eight

- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [Essential Eight Explained](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-explained)
- [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)

### Australian Regulatory Frameworks

- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)

### Compliance Alignment

- [compliance/essential-eight-alignment/](../../../compliance/essential-eight-alignment/README.md) — Technology-specific alignment guides mapping E8 controls to Microsoft products

---

**Australian English** is used throughout this documentation.
