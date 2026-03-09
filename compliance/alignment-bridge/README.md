---
title: "Alignment Bridge — Concept Overview"
status: "draft"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "explanation"
domain: "compliance"
---

# Alignment Bridge — Concept Overview

---

## Purpose

The alignment bridge is the conceptual framework that describes how the `compliance/` domain functions as the **translation layer** between security framework control requirements and technology product documentation.

Security frameworks such as the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism), the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight), [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final), and [CIS Controls](https://www.cisecurity.org/controls) define **what** must be achieved — abstract control language describing security outcomes. Technology documentation in `security/`, `identity/`, `endpoints/`, and `infrastructure/` describes **how** each product operates. Neither source alone answers the question that compliance work actually requires:

> **"How do I configure Product X to satisfy the requirements of Framework Y?"**

The alignment bridge answers that question. Alignment guides in `compliance/` consume framework control definitions from `security/frameworks/` and technology documentation from product domains, then produce actionable configuration guidance mapped to specific control identifiers.

---

## The Three-Layer Model

```
┌─────────────────────────────────────────────────────────┐
│   security/frameworks/                                  │  ← LAYER 1: What to comply with
│   Essential Eight, ISM, NIST 800-53, CIS Controls       │     Control definitions & requirements
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│   compliance/                                           │  ← LAYER 2: How to align tech with framework
│   Alignment guides, maturity mappings,                  │     (THIS DOMAIN — the alignment bridge)
│   control-specific configuration guidance               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│   identity/, endpoints/, security/, infrastructure/     │  ← LAYER 3: How the technology works
│   Product documentation, technical reference            │     Technical implementation detail
└─────────────────────────────────────────────────────────┘
```

Each layer serves a distinct purpose. Layer 1 is authoritative on control requirements. Layer 3 is authoritative on product behaviour. Layer 2 — the alignment bridge — exists solely to connect them for a specific framework × technology combination.

---

## Why a Dedicated Layer Is Necessary

Without this middle layer, compliance work requires practitioners to simultaneously hold framework control language and product configuration knowledge in mind and manually translate between them. This creates several problems:

- **Translation errors** — Abstract control language is frequently misinterpreted, leading to misconfiguration that appears compliant but does not satisfy the control intent
- **Inconsistent implementations** — Different practitioners translate the same control differently across environments
- **Audit risk** — Without documented mapping from configuration to control, evidence collection is ad hoc and incomplete
- **Duplication** — Every team independently redoes the same translation work

The alignment bridge externalises this translation work into documented, reusable guidance that can be audited, versioned, and updated when frameworks or products change.

---

## Relationship to Other Domains

| Domain | Relationship to Compliance |
|--------|---------------------------|
| `security/frameworks/` | **Upstream** — compliance/ consumes control definitions and maturity model descriptions |
| `identity/` | **Downstream reference** — compliance/ references IAM configuration guidance (Entra ID, Conditional Access, MFA) |
| `security/defender-for-cloud/` | **Downstream reference** — compliance/ references CSPM and workload protection configuration |
| `security/defender-for-endpoint/` | **Downstream reference** — compliance/ references endpoint detection and response configuration |
| `endpoints/intune/` | **Downstream reference** — compliance/ references device compliance and configuration profile management |
| `infrastructure/` | **Downstream reference** — compliance/ references Azure landing zone and network security configuration |

---

## Content in This Subfolder

| File | Purpose |
|------|---------|
| `README.md` | This file — concept overview and three-layer model explanation |
| `mapping-methodology.md` | How alignment guides are constructed — control decomposition, evidence mapping, citation standards |
| `maintenance-guidelines.md` | How alignment content is kept current as frameworks and products evolve |

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [NIST SP 800-53 Rev 5 — Security and Privacy Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CIS Controls v8](https://www.cisecurity.org/controls/v8)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)

---

**Australian English** is used throughout this documentation.
