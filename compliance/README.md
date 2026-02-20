# Compliance Alignment Bridge

**Domain**: Compliance
**Status**: Seeded
**Purpose**: Bridge security frameworks with technology implementation

---

## Purpose

The compliance domain serves as the **alignment bridge** between security frameworks (what to comply with) and technology documentation (how the technology works). While `security/frameworks/` defines control requirements and `identity/`, `endpoints/`, `infrastructure/` describe how technologies operate, the compliance domain answers the critical question:

> **"How do I configure Product X to meet the requirements of Framework Y?"**

This domain translates abstract control language into actionable configuration guidance for specific technology stacks.

---

## Key Concept: The Three-Layer Model

```
┌─────────────────────────────────────────┐
│   security/frameworks/                  │  ← What to comply with
│   (Essential Eight, ISM, NIST, etc.)    │     (Control definitions)
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│   compliance/                           │  ← How to align Tech with Framework
│   (Alignment guides)                    │     (THIS DOMAIN)
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│   identity/, endpoints/, infrastructure/ │  ← How the technology works
│   (Product documentation)               │     (Technical implementation)
└─────────────────────────────────────────┘
```

---

## Content Scope

### Alignment Guides

Compliance documentation maps framework requirements to technology configurations:

- **Framework → Technology Stack** alignment
  - "How to align Microsoft 365 with Essential Eight"
  - "ISM alignment guide for Azure infrastructure"
  - "NIST 800-53 controls in Entra ID"

- **Maturity Level Implementations**
  - "Essential Eight Maturity Level 2 across Entra/Azure/O365"
  - "Achieving ISM 'Must' controls in Microsoft ecosystem"

- **Control-Specific Guidance**
  - "Implementing E8 MFA requirements in hybrid identity"
  - "ISM application control using Intune/Defender"
  - "Patch management alignment across Azure Update Manager and WSUS"

---

## Relationship to `security/frameworks/`

The `security/frameworks/` domain contains:

- Framework definitions (Essential Eight, ISM, NIST 800-53, CIS Controls)
- Control descriptions and requirements
- Maturity models and assessment criteria
- Framework relationships and mappings

The `compliance/` domain **consumes** framework definitions and produces:

- Technology-specific alignment guidance
- Configuration checklists mapped to controls
- Evidence collection procedures
- Audit preparation materials

**Example Flow**:
1. `security/frameworks/essential-eight/` defines "Maturity Level 2: Multi-Factor Authentication"
2. `compliance/essential-eight-microsoft-365/` provides step-by-step Entra ID Conditional Access configuration to satisfy that requirement
3. `identity/entra-id/` and `endpoints/intune/` provide the underlying technical reference

---

## Planned Content Structure

```
compliance/
├── essential-eight/
│   ├── microsoft-365/          # E8 alignment for M365 stack
│   ├── azure/                  # E8 alignment for Azure infrastructure
│   └── hybrid-windows/         # E8 for on-premises + cloud Windows
├── ism/
│   ├── cloud-controls/         # ISM cloud-specific controls
│   └── identity-controls/      # ISM identity and access controls
├── nist-800-53/
│   └── azure-gov/              # NIST 800-53 for Azure Government
└── cis-controls/
    └── microsoft-stack/        # CIS Controls across Microsoft ecosystem
```

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
| `security/frameworks/` | **Upstream dependency** — compliance/ consumes framework definitions |
| `identity/` | **Downstream dependency** — compliance/ references IAM configuration |
| `infrastructure/` | **Downstream dependency** — compliance/ references Azure infrastructure security features |
| `endpoints/intune/` | **Downstream dependency** — compliance/ references endpoint management and security capabilities |
| `endpoints/` | **Downstream dependency** — compliance/ references Windows and device hardening |

---

## Content Development Approach

Alignment guides will be developed as:

1. **Framework documentation matures** in `security/frameworks/`
2. **Product documentation stabilises** in technology domains
3. **Implementation patterns emerge** from real-world deployments

This is a **substantive domain** — content will grow through iterative cycles of framework study, technical implementation, and practical validation.

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
