---
title: "Compliance"
status: "draft"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "readme"
domain: "compliance"
---

# Compliance

---

## Purpose

The compliance domain serves as the **alignment bridge** between security frameworks (what to comply with) and technology documentation (how the technology works). While `security/frameworks/` defines control requirements and `identity/`, `endpoints/`, `infrastructure/` describe how technologies operate, the compliance domain answers:

> **"How do I configure Product X to meet the requirements of Framework Y?"**

For the full conceptual explanation of how this domain functions, see [`alignment-bridge/README.md`](./alignment-bridge/README.md).

---

## Domain Structure

```
compliance/
├── alignment-bridge/               ← Conceptual framework (concept overview, mapping methodology, maintenance)
├── essential-eight-alignment/      ← Essential Eight × Microsoft technology stack alignment guides
└── ism-alignment/                  ← ISM × Microsoft technology stack alignment guides
```

---

## Subfolders

### [`alignment-bridge/`](./alignment-bridge/README.md)

The conceptual framework describing how compliance alignment content is constructed, the three-layer model (frameworks → compliance → product docs), mapping methodology, and maintenance guidelines.

| File | Content |
|------|---------|
| [`README.md`](./alignment-bridge/README.md) | Concept overview, three-layer model, domain relationships |
| [`mapping-methodology.md`](./alignment-bridge/mapping-methodology.md) | Control decomposition, technology mapping, evidence standards |
| [`maintenance-guidelines.md`](./alignment-bridge/maintenance-guidelines.md) | Framework update triggers, review process, deprecation |

---

### [`essential-eight-alignment/`](./essential-eight-alignment/README.md)

Alignment guides mapping the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) controls to Microsoft technology implementations across Azure, Microsoft 365, Intune, Defender, and Entra ID.

---

### [`ism-alignment/`](./ism-alignment/README.md)

Alignment guides mapping the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) controls to Microsoft technology implementations across cloud, identity, and endpoint domains.

---

## Audience

- **Security Architects** — Designing compliant technology solutions
- **Compliance Officers** — Validating framework adherence and preparing for audits
- **Auditors** — Understanding how technology configurations satisfy control requirements
- **Platform Engineers** — Implementing security controls in production environments

---

## Relationship to Other Domains

| Domain | Relationship |
|--------|--------------|
| `security/frameworks/` | **Upstream** — compliance/ consumes framework control definitions |
| `identity/` | **Downstream reference** — compliance/ references IAM configuration |
| `security/defender-for-cloud/` | **Downstream reference** — compliance/ references CSPM and workload protection |
| `security/defender-for-endpoint/` | **Downstream reference** — compliance/ references EDR configuration |
| `endpoints/intune/` | **Downstream reference** — compliance/ references device management |
| `infrastructure/` | **Downstream reference** — compliance/ references Azure infrastructure security |

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)

---

**Australian English** is used throughout this documentation.
