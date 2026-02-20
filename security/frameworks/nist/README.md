# NIST Cybersecurity Framework

**Status**: SEEDED — Content planned but not yet migrated

This folder will contain documentation for the US National Institute of Standards and Technology (NIST) Cybersecurity Framework and related control catalogues.

## Scope

NIST publishes several cybersecurity frameworks and control catalogues that are widely adopted internationally:

### NIST Cybersecurity Framework (CSF)

A risk-based framework organised into five core functions:

1. **Identify** — Develop organisational understanding of cyber risk
2. **Protect** — Implement safeguards to ensure delivery of critical services
3. **Detect** — Identify occurrence of cybersecurity events
4. **Respond** — Take action regarding detected cybersecurity incidents
5. **Recover** — Maintain resilience and restore capabilities

### NIST SP 800-53

Security and Privacy Controls for Information Systems and Organizations — a comprehensive catalogue of security controls organised into families (e.g., Access Control, Audit and Accountability, Configuration Management).

### NIST SP 800-171

Protecting Controlled Unclassified Information (CUI) in nonfederal systems — a subset of SP 800-53 controls applicable to contractors and partners handling sensitive government information.

## Planned Content

This folder will contain:

- **Control Family Documentation** — Detailed specifications for each SP 800-53 control family
- **CSF Framework Guides** — Implementation guidance for the five core functions
- **Control Baselines** — Low, moderate, and high impact baselines
- **Mapping to Australian ISM** — Cross-reference NIST controls to Australian ISM controls
- **CUI Protection Guidance** — SP 800-171 implementation for controlled unclassified information
- **Assessment Procedures** — How to evaluate NIST control implementation

## Relationship to Product Documentation

NIST frameworks define **what** controls must be implemented. Product-specific documentation describes **how** the technology works. Compliance alignment guidance in the separate `compliance/` domain maps NIST controls to product capabilities.

### Example Workflow

To implement NIST SP 800-53 access control (AC) controls using Microsoft Entra ID:

1. **Read requirements** — This folder defines AC family control specifications
2. **Understand technology** — Product documentation explains how Entra ID access controls work
3. **Implement compliance** — `../../../compliance/nist/entra-id/` provides step-by-step configuration to meet specific AC controls

## Australian Context

While NIST is a US framework, it's widely used in Australia for several reasons:

- **International Operations** — Organisations operating globally often need both ISM and NIST compliance
- **Industry Standards** — Many sectors (finance, healthcare) reference NIST controls
- **Control Mapping** — NIST controls map well to Australian ISM, providing implementation guidance
- **Technology Alignment** — Microsoft and other vendors often publish NIST compliance documentation

This folder will include Australian-specific guidance for mapping NIST controls to ISM requirements.

## Control Family Overview

NIST SP 800-53 Rev 5 includes 20 control families:

- AC — Access Control
- AT — Awareness and Training
- AU — Audit and Accountability
- CA — Assessment, Authorization, and Monitoring
- CM — Configuration Management
- CP — Contingency Planning
- IA — Identification and Authentication
- IR — Incident Response
- MA — Maintenance
- MP — Media Protection
- PE — Physical and Environmental Protection
- PL — Planning
- PM — Program Management
- PS — Personnel Security
- PT — PII Processing and Transparency
- RA — Risk Assessment
- SA — System and Services Acquisition
- SC — System and Communications Protection
- SI — System and Information Integrity
- SR — Supply Chain Risk Management

## Resources

Official NIST resources:
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [SP 800-53 Rev 5 Security and Privacy Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [SP 800-171 Rev 2 Protecting CUI](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)

---

**Note**: This is a seeded placeholder. Content migration is planned but not yet complete. Until migration, refer to official NIST documentation for framework requirements.
