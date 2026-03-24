---
title: "Alignment Bridge — Mapping Methodology"
status: "draft"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "explanation"
domain: "compliance"
---

# Alignment Bridge — Mapping Methodology

---

## Purpose

This document describes how alignment guides in the `compliance/` domain are constructed — the process of decomposing framework controls, mapping them to technology capabilities, and documenting the resulting configuration guidance with evidence standards sufficient for audit.

---

## Step 1: Control Decomposition

Every framework control is decomposed before mapping begins. Raw control language from frameworks such as the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) or the [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) is often written at a level of abstraction that encompasses multiple distinct technical requirements.

For each control, the decomposition produces:

| Field | Description |
|-------|-------------|
| **Control ID** | The canonical identifier from the framework (e.g., ISM-1053, E8-ML2-MFA) |
| **Control intent** | The security outcome the control is designed to achieve |
| **Atomic requirements** | The specific, testable sub-requirements derived from the control language |
| **Scope boundaries** | What is in scope (system type, user population, data classification) |
| **Maturity threshold** | For Essential Eight, the maturity level this mapping targets |

Decomposition must be grounded in the authoritative framework publication, not secondary summaries. For Essential Eight, the primary source is the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). For ISM, it is the current ISM release at [cyber.gov.au](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism).

---

## Step 2: Technology Capability Identification

Once a control is decomposed into atomic requirements, the technology capabilities that satisfy each requirement are identified. This step consumes product documentation from Layer 3 domains:

- `security/defender-for-cloud/` — Cloud security posture management, workload protection, regulatory compliance dashboards
- `security/defender-for-endpoint/` — Endpoint detection and response, application control, attack surface reduction
- `security/sentinel/` — SIEM/SOAR, analytics rules, incident management, audit log centralisation
- `identity/entra-id/` — Identity lifecycle, tenant configuration, directory services
- `identity/conditional-access/` — Policy-based access control, sign-in risk, device compliance enforcement
- `identity/mfa/` — Authentication method policies, FIDO2, Microsoft Authenticator
- `endpoints/intune/` — Device compliance policies, configuration profiles, application deployment

Each atomic requirement maps to one or more technology capabilities. The mapping must be explicit — a capability is only claimed to satisfy a requirement when the product documentation confirms the specific behaviour.

---

## Step 3: Configuration Guidance Authoring

For each requirement → capability mapping, a configuration guidance entry is authored. This entry contains:

1. **Control reference** — Framework ID and requirement text (quoted from authoritative source)
2. **Technology** — Which product and feature addresses the requirement
3. **Configuration** — What must be configured and how (linking to Layer 3 product docs, not duplicating step-by-step UI instructions)
4. **Evidence artefacts** — What evidence a configuration produces (e.g., Conditional Access policy export, compliance report, audit log entry)
5. **Gaps and caveats** — Where a technology partially satisfies a control, or where additional compensating controls are required

### Citation Standards

All control references must cite the authoritative framework publication with a direct URL. Configuration guidance must link to the relevant section of Layer 3 product documentation rather than reproducing it. Evidence artefact descriptions must reference the specific report, log, or export that demonstrates compliance.

---

## Step 4: Evidence Mapping

Compliance alignment is only useful if it produces auditable evidence. For each configuration guidance entry, the evidence mapping identifies:

| Evidence Type | Description | Example |
|--------------|-------------|---------|
| **Configuration export** | Machine-readable export of the configured setting | Conditional Access policy JSON export from Microsoft Graph |
| **Compliance report** | Platform-generated compliance status report | Defender for Cloud regulatory compliance dashboard (Essential Eight built-in) |
| **Audit log** | Event log demonstrating control operation | Entra ID sign-in log showing MFA enforcement |
| **Policy assignment** | Record of policy applied to a scope | Intune device compliance policy assignment report |
| **Assessment output** | Output from an assessment or scanning tool | ACSC Essential Eight assessment report |

Evidence mapping links the configuration to a specific auditor-facing artefact, making the compliance claim verifiable without requiring the auditor to re-derive the mapping from first principles.

---

## Step 5: Cross-Framework Alignment

Where two frameworks share overlapping control intent, alignment guides note the cross-framework relationship. For example:

- Essential Eight Multi-Factor Authentication (ML2) overlaps with ISM controls governing authentication for privileged accounts
- ISM requirements for system patching align with Essential Eight Patch Applications and Patch Operating Systems strategies
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) IA-2 (Identification and Authentication) maps to both Essential Eight MFA requirements and ISM authentication controls

Noting these relationships reduces duplicated guidance. Where one alignment guide already addresses a cross-framework requirement, it is referenced rather than restated.

---

## Authoring Standards

All alignment content must meet the following standards before publication:

- [ ] Control references cite the authoritative framework publication (not secondary sources)
- [ ] Atomic requirements are traceable to specific framework control language
- [ ] Technology capability claims are supported by Layer 3 product documentation
- [ ] Evidence artefacts are named and described specifically (not generically)
- [ ] en-AU spelling throughout — no residual en-US defaults
- [ ] Gaps and caveats documented where partial satisfaction occurs
- [ ] Cross-framework relationships noted where relevant

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CIS Controls v8](https://www.cisecurity.org/controls/v8)

---

**Australian English** is used throughout this documentation.
