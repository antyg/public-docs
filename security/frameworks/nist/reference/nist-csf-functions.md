---
title: "NIST CSF 2.0 — Functions Reference"
status: "published"
last_updated: "2026-03-09"
audience: "Security architects, compliance officers, and auditors"
document_type: "reference"
domain: "security"
---

# NIST CSF 2.0 — Functions Reference

**Source**: [NIST Cybersecurity Framework 2.0 (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf), published February 2024

---

## Framework Structure

NIST CSF 2.0 is organised into a three-level hierarchy:

| Level | Term | Count | Description |
|-------|------|-------|-------------|
| 1 | Function | 6 | Highest-level cybersecurity outcomes |
| 2 | Category | 22 | Groups of related outcomes within a function |
| 3 | Subcategory | 106 | Specific outcomes within each category |

The full list of subcategories, with informative references and implementation examples, is available in the [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters).

---

## GV — Govern

**Purpose**: Establish and monitor the organisation's cybersecurity risk management strategy, expectations, and policy. Govern is the context in which all other functions operate.

**Note**: The Govern function is new in CSF 2.0. In CSF 1.1, governance activities were distributed across other functions. Centralising them in Govern reflects NIST's recognition that cybersecurity is a strategic enterprise risk management concern. Source: [NIST CSF 2.0 news release](https://www.nist.gov/news-events/news/2024/02/nist-releases-version-20-landmark-cybersecurity-framework)

| ID | Category | Key Outcomes |
|----|----------|-------------|
| GV.OC | Organisational Context | Mission, stakeholder expectations, legal/regulatory obligations understood and communicated |
| GV.RM | Risk Management Strategy | Risk appetite, tolerance, and prioritisation criteria established |
| GV.RR | Roles, Responsibilities, and Authorities | Cybersecurity roles assigned; accountability and authority documented |
| GV.PO | Policy | Policies based on risk strategy published, reviewed, updated |
| GV.OV | Oversight | Cybersecurity risk management results reviewed by leadership |
| GV.SC | Cybersecurity Supply Chain Risk Management | Supply chain risk management integrated into broader risk management; supplier requirements established |

---

## ID — Identify

**Purpose**: Develop the organisational understanding necessary to manage cybersecurity risk to systems, people, assets, data, and capabilities.

| ID | Category | Key Outcomes |
|----|----------|-------------|
| ID.AM | Asset Management | Software, hardware, services, and data inventoried; assets prioritised based on risk |
| ID.RA | Risk Assessment | Vulnerabilities, threats, and likelihood/impact assessed; risks prioritised |
| ID.IM | Improvement | Improvements identified from evaluations, assessments, lessons learned |

**Note**: CSF 2.0 simplified the Identify function compared to 1.1. The Business Environment (BE) and Governance (GV) categories from ID in CSF 1.1 were separated out — GV became its own function, and the remaining ID categories were consolidated.

---

## PR — Protect

**Purpose**: Develop and implement appropriate safeguards to ensure delivery of critical services.

| ID | Category | Key Outcomes |
|----|----------|-------------|
| PR.AA | Identity Management, Authentication, and Access Control | Identities and credentials managed; physical and remote access authorised; permissions managed with least privilege |
| PR.AT | Awareness and Training | Personnel have security awareness; privileged users understand their roles |
| PR.DS | Data Security | Data managed consistent with risk strategy; data-at-rest and in-transit protected |
| PR.PS | Platform Security | Hardware, software, and services managed to reduce attack surface |
| PR.IR | Technology Infrastructure Resilience | Resilience and recovery plans implemented for technology assets |

---

## DE — Detect

**Purpose**: Develop and implement activities to identify the occurrence of a cybersecurity event.

| ID | Category | Key Outcomes |
|----|----------|-------------|
| DE.CM | Continuous Monitoring | Networks, computing environment, and personnel activity monitored to identify potentially adverse events |
| DE.AE | Adverse Event Analysis | Anomalies detected, their potential impact analysed, information correlated to identify incidents |

---

## RS — Respond

**Purpose**: Develop and implement activities to take action regarding a detected cybersecurity incident.

| ID | Category | Key Outcomes |
|----|----------|-------------|
| RS.MA | Incident Management | Incidents contained and eradicated; evidence collected |
| RS.AN | Incident Analysis | Investigations conducted; characteristics of incidents understood |
| RS.CO | Incident Response Reporting and Communication | Response activities coordinated; incidents reported to internal and external stakeholders |
| RS.MI | Incident Mitigation | Incidents contained; effects of incidents mitigated |

---

## RC — Recover

**Purpose**: Develop and implement activities to maintain plans for resilience and to restore capabilities or services impaired by a cybersecurity incident.

| ID | Category | Key Outcomes |
|----|----------|-------------|
| RC.RP | Incident Recovery Plan Execution | Recovery activities executed in accordance with plans; completeness of recovery confirmed |
| RC.CO | Incident Recovery Communication | Restoration activities communicated to internal and external stakeholders |

---

## Implementation Tiers

Implementation Tiers describe the rigour and sophistication of an organisation's cybersecurity risk management practices. Tiers apply to the whole framework; they are not a maturity score per subcategory.

| Tier | Label | Characteristics |
|------|-------|----------------|
| **Tier 1** | Partial | Risk management is ad hoc, limited awareness of risk, no formalised processes |
| **Tier 2** | Risk Informed | Risk management practices exist but are not organisation-wide; prioritisation is informed but not formal |
| **Tier 3** | Repeatable | Risk management practices are formally approved, consistently applied, and regularly updated |
| **Tier 4** | Adaptive | Risk management is continuously improved based on lessons learned; organisation adapts in real time |

Source: [NIST CSF 2.0 (CSWP 29), Section 3.4 — Tiers](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)

Tiers are not a compliance measurement — an organisation at Tier 2 is not "non-compliant". Organisations should target the tier appropriate to their risk environment and resource capacity.

---

## Organisational Profiles

A **Profile** represents the alignment of the CSF functions and categories with the organisation's business requirements, risk tolerance, and resources.

| Profile Type | Purpose |
|-------------|---------|
| **Current Profile** | Snapshot of the organisation's current cybersecurity outcomes — what is achieved today |
| **Target Profile** | The outcomes the organisation aims to achieve in a defined timeframe |
| **Gap Analysis** | Comparison of Current to Target — identifies priorities for investment and action |

Profiles are documented using the CSF 2.0 subcategory list. Each subcategory is rated as: Not Achieved, Partially Achieved, Largely Achieved, or Fully Achieved (or using the Tier 1–4 scale).

---

## Relationship to NIST SP 800-53

[NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) is a comprehensive catalogue of security and privacy controls. It provides the detailed "how" to implement CSF outcomes. The relationship is:

- **CSF 2.0** — Defines *what* outcomes to achieve (functions, categories, subcategories)
- **SP 800-53** — Defines *which specific controls* achieve those outcomes

NIST publishes a [CSF to SP 800-53 mapping](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters) in the Reference Tool, allowing organisations to trace from CSF subcategory to specific 800-53 controls.

---

## Australian Context

While NIST CSF is a US framework, it is widely adopted in Australia for:

- **Cross-jurisdictional operations** — Organisations with US government contracts or customers may need NIST CSF compliance alongside Australian ISM compliance
- **International certifications** — NIST CSF aligns well with ISO 27001 and SOC 2 requirements
- **Microsoft compliance documentation** — Microsoft publishes NIST CSF compliance guidance for Azure and Microsoft 365, making it easier to use when implementing Microsoft platforms

The [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) is the authoritative Australian framework. For mapping between ISM controls and NIST CSF, use the [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager-overview) which provides pre-built assessment templates for both frameworks.

---

## Related Resources

- [NIST CSF 2.0 Full Publication (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)
- [NIST CSF 2.0 Resource and Overview Guide (SP 1299)](https://csrc.nist.gov/pubs/sp/1299/final)
- [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters)
- [NIST SP 800-53 Rev 5 Security and Privacy Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [Microsoft — NIST CSF compliance for Azure](https://learn.microsoft.com/en-us/compliance/regulatory/offering-nist-csf)
- [How to Map NIST CSF to Azure](../how-to/map-nist-to-azure.md)
- [NIST CSF Evolution — 1.1 to 2.0](../explanation/nist-csf-evolution.md)
