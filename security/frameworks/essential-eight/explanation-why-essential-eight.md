---
title: "Why Essential Eight — Framework Rationale and Australian Regulatory Context"
status: "published"
last_updated: "2026-03-09"
audience: "Security leaders, risk managers, and stakeholders evaluating the Essential Eight"
document_type: "explanation"
domain: "security"
---

# Why Essential Eight — Framework Rationale and Australian Regulatory Context

---

## What the Essential Eight Is

The Essential Eight is a prioritised set of eight mitigation strategies developed by the [Australian Signals Directorate (ASD)](https://www.asd.gov.au/) through its [Australian Cyber Security Centre (ACSC)](https://www.cyber.gov.au/) arm. The strategies are drawn from the ASD's broader list of [Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents) — a catalogue of 40+ controls ranked by effectiveness. The ACSC selected the eight strategies with the highest return-on-investment for the broadest range of Australian organisations.

The eight strategies address three distinct adversary objectives:

| Adversary Objective | Relevant Strategies |
|--------------------|---------------------|
| Initial access and code execution | Application control, patch applications, configure macro settings, user application hardening |
| Lateral movement and privilege escalation | Restrict administrative privileges, patch operating systems |
| Persistence and impact | Multi-factor authentication, regular backups |

The framework is not a compliance checkbox exercise. It represents the ACSC's evidence-based view of the controls most likely to prevent cyber incidents from succeeding against Australian organisations.

---

## Why Australia Has Its Own Baseline

Most countries adopt frameworks developed by others — commonly [NIST CSF](https://www.nist.gov/cyberframework) (USA) or [ISO 27001](https://www.iso.org/standard/27001) (international). Australia chose to develop a domestically authoritative baseline for several reasons:

**Threat intelligence specificity**: The ASD operates Australia's sovereign cyber intelligence capability. The Essential Eight reflects threats observed in the Australian threat landscape — adversaries targeting Australian government, critical infrastructure, and businesses — not a generalised global threat model.

**Regulatory integration**: The Essential Eight is referenced directly in Australian government frameworks:
- [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) — The primary control set for Australian government agencies, which includes Essential Eight implementation as baseline requirements
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/) — Governs protective security for Commonwealth entities; references Essential Eight as the cyber baseline
- [Security of Critical Infrastructure (SOCI) Act 2018](https://www.legislation.gov.au/Series/C2018A00029) — Critical infrastructure sector risk management programs increasingly reference Essential Eight controls

**Practical focus**: The eight strategies were selected specifically because their combination provides the greatest reduction in risk for the least implementation complexity. This reflects the ACSC's mandate to uplift the security posture of all Australian organisations, not just large enterprises with dedicated security teams.

---

## Regulatory Obligations

### Commonwealth Government Entities

All non-corporate Commonwealth entities (NCEs) subject to the [Public Governance, Performance and Accountability Act 2013 (PGPA Act)](https://www.legislation.gov.au/Series/C2013A00123) must comply with the PSPF, which mandates:

- **ML2 across all eight strategies** as the minimum cyber baseline for all systems handling OFFICIAL information
- Annual self-assessment and reporting to the Attorney-General's Department
- [Commonwealth Cyber Security Posture reporting](https://www.cyber.gov.au/about-us/view-all-content/publications/commonwealth-cyber-security-posture-2025) — annual public report on government-wide Essential Eight compliance

The 2025 Commonwealth Cyber Security Posture report (covering the 2024–25 reporting period) found that entity compliance with ML2 across all eight strategies remains an ongoing challenge, with legacy technology and funding constraints the primary barriers.

### State and Territory Governments

Requirements vary by jurisdiction, but most Australian state and territory governments have adopted Essential Eight as their cyber baseline:

- **New South Wales**: NSW Cyber Security Policy mandates Essential Eight ML2 for all NSW government agencies
- **Victoria**: Victorian Protective Data Security Framework (VPDSF) references Essential Eight
- **Queensland**: Queensland Government Information Security Policy requires Essential Eight alignment
- **Western Australia**: WA Government Cyber Security Policy references Essential Eight
- **South Australia**: SA Government Cyber Security Framework mandates Essential Eight assessment
- **Other jurisdictions**: Progressively adopting Essential Eight as the baseline standard

### Regulated Industries

Several Australian regulatory bodies have incorporated Essential Eight into sector-specific requirements:

- **Australian Prudential Regulation Authority (APRA)** — CPS 234 Information Security does not mandate Essential Eight specifically but requires equivalent controls; most entities use Essential Eight as their implementation reference
- **Australian Securities and Investments Commission (ASIC)** — Cyber security guidance references ACSC frameworks
- **Australian Health Sector** — My Health Records system access requirements align with Essential Eight

---

## How the Framework Evolved

| Year | Development |
|------|-------------|
| 2010 | ASD publishes first "Top 35 Mitigations" — evidence-based ranking of controls by effectiveness |
| 2013 | ASD mandates the "Top 4" (application control, patch applications, restrict admin privileges, application whitelisting) for Commonwealth agencies |
| 2017 | Essential Eight published — eight strategies with maturity model |
| 2019 | Maturity model formalised with ML1, ML2, ML3 definitions |
| 2021 | PSPF updated to mandate ML2 as Commonwealth baseline |
| 2022 | ISM alignment updated — detailed ISM control mapping published |
| 2023 | Significant maturity model update in November 2023 — backups strategy requirements substantially revised to address ransomware threats |
| 2024 | October 2024 update — further refinements to patch timing requirements and internet-facing service classifications |

Source: [Essential Eight Maturity Model changes (November 2023)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20changes%20(November%202023).pdf)

---

## Relationship to Other Frameworks

The Essential Eight is not designed to replace other frameworks. It is a focused baseline that complements broader governance frameworks:

| Framework | Relationship to Essential Eight |
|-----------|-------------------------------|
| [NIST CSF 2.0](https://www.nist.gov/cyberframework) | Essential Eight maps to specific subcategories within NIST CSF's Protect and Recover functions. NIST CSF is broader in scope (governance, risk management, supply chain). |
| [ISO 27001:2022](https://www.iso.org/standard/27001) | Essential Eight is a subset of ISO 27001 Annex A controls. Organisations implementing Essential Eight ML3 will satisfy many ISO 27001 controls but must address additional governance requirements separately. |
| [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) | The ISM provides a mapping between NIST 800-53 controls and ISM controls; Essential Eight sits within this mapping. |
| [Zero Trust Architecture](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview) | Essential Eight strategies 5 (restrict admin privileges) and 7 (MFA) directly implement Zero Trust identity verification principles. Strategy 1 (application control) implements Zero Trust device control. |
| [ASD Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) | The Essential Eight is derived from the ISM. Full ISM compliance requires implementing Essential Eight plus additional controls. |

---

## Limitations and Common Misconceptions

**Essential Eight is not a complete security programme**: The eight strategies address the most common attack vectors but do not cover all risks. Organisations should layer the Essential Eight with:
- Incident response capability
- Security monitoring and threat detection (e.g., Microsoft Sentinel)
- Supply chain risk management
- Personnel security (as required by PSPF)

**ML2 is the minimum, not the target**: The ACSC recommends ML2 as the starting floor, not the ceiling. High-value targets and organisations handling sensitive data should target ML3.

**Maturity levels must be consistent**: An organisation cannot claim ML2 overall if any single strategy is at ML1. The maturity level achieved is the lowest across all eight strategies.

**Assessment requires evidence**: The ACSC's [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide) specifies that maturity claims must be supported by evidence — logs, configuration exports, test results. Self-reporting without evidence does not constitute genuine ML compliance.

---

## Related Resources

- [ACSC — Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Strategies to Mitigate Cyber Security Incidents](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/strategies-mitigate-cyber-security-incidents)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [Security of Critical Infrastructure Act 2018](https://www.legislation.gov.au/Series/C2018A00029)
- [Commonwealth Cyber Security Posture in 2025](https://www.cyber.gov.au/sites/default/files/2026-02/the_commonwealth_cyber_security_posture_in_2025.pdf)
- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md)
