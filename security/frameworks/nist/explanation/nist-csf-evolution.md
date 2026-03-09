---
title: "NIST CSF Evolution — From 1.1 to 2.0"
status: "published"
last_updated: "2026-03-09"
audience: "Security leaders, architects, and compliance professionals understanding CSF 2.0 changes"
document_type: "explanation"
domain: "security"
---

# NIST CSF Evolution — From 1.1 to 2.0

---

## Why NIST Updated the Framework

The original NIST Cybersecurity Framework (CSF 1.0) was published in 2014 in response to US Presidential Executive Order 13636, which directed NIST to work with critical infrastructure sectors to develop a voluntary framework for improving cybersecurity. CSF 1.1 followed in 2018 with targeted refinements.

By 2022, several factors made a more substantial update necessary:

**Governance was missing**: CSF 1.1 treated cybersecurity as primarily a technical discipline. A decade of major incidents — including SolarWinds (2020), Colonial Pipeline (2021), and Log4Shell (2021) — demonstrated that inadequate board-level governance and risk management strategy were as much a root cause as technical failures. The framework needed to explicitly address leadership accountability.

**Scope had expanded beyond critical infrastructure**: CSF 1.1 was written for critical infrastructure operators. In practice, governments, small businesses, universities, and organisations in every sector adopted it. CSF 2.0 explicitly acknowledges this universal application.

**Supply chain risk had become a first-order concern**: The SolarWinds supply chain attack demonstrated that an organisation's security is only as strong as its supplier relationships. CSF 2.0 elevates supply chain risk management to a dedicated category within the new Govern function.

**The framework needed to be more actionable**: CSF 1.1 was criticised as abstract. CSF 2.0 introduces quick-start guides, implementation examples, and an online reference tool to reduce the gap between framework text and practical implementation.

Source: [NIST — CSF 2.0 news release (February 2024)](https://www.nist.gov/news-events/news/2024/02/nist-releases-version-20-landmark-cybersecurity-framework)

---

## What Changed: Version Comparison

### The Addition of Govern

The most significant change in CSF 2.0 is the addition of a sixth function: **Govern** (GV).

In CSF 1.1, governance activities were distributed across other functions — risk management appeared in Identify, policy appeared in Protect. This distribution meant governance received less attention than technical controls.

CSF 2.0 consolidates governance into a dedicated function with six categories:

| CSF 1.1 Location | Category | CSF 2.0 Location |
|-----------------|----------|-----------------|
| ID.GV — Governance | Policy, roles, oversight | GV.PO, GV.RR, GV.OV |
| ID.BE — Business Environment | Organisational context | GV.OC |
| ID.RA — Risk Assessment (partial) | Risk strategy | GV.RM |
| (New in 2.0) | Supply chain risk management | GV.SC |

The Govern function is conceptually different from the other five: it does not describe a phase in the incident lifecycle. Instead, it describes the management layer that enables all other functions to operate effectively. NIST describes Govern as "transcending" the other functions.

Source: [NIST CSF 2.0 (CSWP 29), Section 2.2](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)

### Structural Changes to Existing Functions

| Function | CSF 1.1 Categories | CSF 2.0 Categories | Key Changes |
|----------|-------------------|-------------------|-------------|
| Identify | AM, BE, GV, RA, RM, SC | AM, RA, IM | BE and GV moved to Govern; RM (Risk Management) absorbed into GV.RM; new IM (Improvement) category added |
| Protect | AC, AT, DS, IP, MA, PS | AA, AT, DS, PS, IR | AC (Access Control) renamed AA (Identity Management, Authentication, Access Control); IP and MA removed or consolidated; new IR (Infrastructure Resilience) |
| Detect | AE, CM | CM, AE | Order swapped; DE.CM expanded |
| Respond | RP, CO, AN, MI, IM | MA, AN, CO, MI | RP renamed MA (Incident Management); IM removed (consolidated into MA) |
| Recover | RP, IM, CO | RP, CO | IM removed (consolidated into RP) |

### Subcategory Count

| Version | Functions | Categories | Subcategories |
|---------|-----------|------------|---------------|
| CSF 1.1 | 5 | 23 | 108 |
| CSF 2.0 | 6 | 22 | 106 |

The total subcategory count decreased slightly despite adding a new function, reflecting consolidation of overlapping outcomes.

### Scope: From Critical Infrastructure to All Organisations

| Aspect | CSF 1.1 | CSF 2.0 |
|--------|---------|---------|
| Primary audience | US critical infrastructure | Any organisation, any size, any sector, any geography |
| International applicability | Implied | Explicit |
| Small business guidance | Limited | Dedicated quick-start guide |

The explicit broadening of scope is significant. CSF 2.0 is now framed as a universal cybersecurity risk management framework, not a sector-specific tool.

### Supply Chain Risk Management

CSF 1.1 included supply chain risk as a subcategory in ID.SC. CSF 2.0 elevates this to a full category — GV.SC — within the Govern function, reflecting the strategic importance of managing third-party and supplier cybersecurity risk.

GV.SC outcomes include:
- Establishing cybersecurity requirements for suppliers and partners
- Integrating supplier risk into organisational risk management
- Planning for supplier incidents (responding when a supplier is compromised)

This change directly responds to the SolarWinds and other supply-chain-originating incidents.

---

## What Did Not Change

The fundamental structure and purpose of the framework remain consistent:

- **Functions remain the top-level organising principle** — adding Govern does not alter the logic of Identify → Protect → Detect → Respond → Recover
- **The framework is voluntary** — CSF 2.0 is not a regulation or compliance requirement (though regulators reference it)
- **Implementation Tiers remain** — Tiers 1–4 continue to describe the rigour of risk management practices
- **The framework is technology-neutral** — CSF 2.0 does not prescribe specific products or services

---

## Implications for Australian Organisations

### If You Have an Existing CSF 1.1 Programme

The structural changes require a mapping exercise — your existing CSF 1.1 categories need to be re-mapped to the CSF 2.0 structure. NIST provides a [CSF 1.1 to CSF 2.0 mapping](https://www.nist.gov/system/files/documents/2024/02/26/CSF-2.0-to-CSF-1.1-Comparison.xlsx) to support this transition.

Key migration actions:
1. Move governance content from ID.GV and ID.BE to the new GV function categories
2. Reassess supply chain risk practices against the expanded GV.SC requirements
3. Update your organisational profile to use CSF 2.0 subcategory IDs

### If You Are Starting Fresh

Use CSF 2.0 from the outset. The Govern function provides the strategic foundation that CSF 1.1 lacked. Begin with Govern outcomes (policy, roles, risk strategy) before progressing to Identify and Protect.

### CSF 2.0 and the Australian ISM

The [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) remains the primary framework for Australian government entities. CSF 2.0 does not replace the ISM but complements it:

- ISM provides detailed technical control specifications
- CSF 2.0 provides a risk management and governance structure
- Together they cover both the strategic (CSF Govern, Identify) and technical (ISM controls, CSF Protect, Detect) dimensions

[Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager-overview) provides pre-built templates for both NIST CSF and Australian regulations, allowing side-by-side gap assessment.

---

## Related Resources

- [NIST CSF 2.0 Publication (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)
- [NIST — CSF 2.0 news release (February 2024)](https://www.nist.gov/news-events/news/2024/02/nist-releases-version-20-landmark-cybersecurity-framework)
- [NIST CSF 2.0 Resource and Overview Guide (SP 1299)](https://csrc.nist.gov/pubs/sp/1299/final)
- [CSF 1.1 to 2.0 Comparison Spreadsheet](https://www.nist.gov/system/files/documents/2024/02/26/CSF-2.0-to-CSF-1.1-Comparison.xlsx)
- [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters)
- [NIST CSF 2.0 Functions Reference](../reference/nist-csf-functions.md)
- [How to Map NIST CSF to Azure](../how-to/map-nist-to-azure.md)
