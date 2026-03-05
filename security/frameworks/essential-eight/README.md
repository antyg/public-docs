# Essential Eight

**Status**: SEEDED — Content planned but not yet migrated

This folder will contain documentation for the Australian Cyber Security Centre (ACSC) Essential Eight Maturity Model.

## Scope

The Essential Eight is a prioritised set of eight mitigation strategies designed to protect Australian organisations from cyber security incidents. The ACSC recommends organisations implement all eight strategies to Maturity Level 2 (ML2) at a minimum.

### Eight Strategies

The Essential Eight comprises:

1. **Application Control** — Prevent execution of unapproved applications
2. **Patch Applications** — Update security vulnerabilities in applications
3. **Configure Microsoft Office Macro Settings** — Restrict macro execution
4. **User Application Hardening** — Disable risky features in office productivity suites
5. **Restrict Administrative Privileges** — Limit users with privileged access
6. **Patch Operating Systems** — Update security vulnerabilities in operating systems
7. **Multi-Factor Authentication** — Require multiple verification factors
8. **Regular Backups** — Maintain recoverable copies of data

### Maturity Levels

Each strategy has three maturity levels:

- **Maturity Level 1 (ML1)** — Partial coverage, focuses on most common threats
- **Maturity Level 2 (ML2)** — Broad coverage, protects against most threats (ACSC recommended minimum)
- **Maturity Level 3 (ML3)** — Complete coverage, addresses sophisticated adversaries

## Planned Content

This folder will contain:

- **Control Specifications** — Detailed requirements for each strategy at each maturity level
- **Maturity Assessment Guides** — How to evaluate current implementation maturity
- **Implementation Priorities** — Sequencing guidance for organisations starting their Essential Eight journey
- **Australian Context** — ACSC-specific guidance and regulatory considerations
- **Cross-Framework Mapping** — Alignment with ISM, NIST, ISO 27001

## Relationship to Product Documentation

Essential Eight defines **what** must be implemented. Product-specific documentation (e.g., Defender for Endpoint, Defender for Cloud) describes **how** the technology works. Compliance alignment guidance in the separate `compliance/` domain maps Essential Eight controls to product capabilities.

### Example Workflow

To implement Essential Eight application control using Defender for Endpoint:

1. **Read requirements** — This folder defines Maturity Level 2 application control requirements
2. **Understand technology** — `../../../security/defender-for-endpoint/` explains how Defender's application control features work
3. **Implement compliance** — `../../../compliance/essential-eight/defender-for-endpoint/` provides step-by-step configuration to meet ML2 requirements

## Australian Regulatory Context

The Essential Eight is referenced in:

- **ISM** — Australian Government Information Security Manual
- **PSPF** — Protective Security Policy Framework
- **State/Territory Requirements** — Many Australian jurisdictions mandate Essential Eight implementation

Organisations subject to these frameworks should prioritise Essential Eight implementation.

## Resources

Official ACSC resources:
- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)

---

**Note**: This is a seeded placeholder. Content migration is planned but not yet complete. Until migration, refer to official ACSC documentation for Essential Eight requirements.
