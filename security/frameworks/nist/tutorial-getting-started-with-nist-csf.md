---
title: "Getting Started with NIST Cybersecurity Framework 2.0"
status: "published"
last_updated: "2026-03-09"
audience: "Security engineers, risk managers, and IT administrators beginning NIST CSF adoption"
document_type: "tutorial"
domain: "security"
---

# Getting Started with NIST Cybersecurity Framework 2.0

---

## Overview

This tutorial walks you through your first steps adopting the [NIST Cybersecurity Framework (CSF) 2.0](https://www.nist.gov/publications/nist-cybersecurity-framework-csf-20), published by the US National Institute of Standards and Technology in February 2024. By the end, you will have mapped your organisation's current security posture to the CSF 2.0 functions, identified priority gaps, and produced a target profile to guide implementation.

NIST CSF 2.0 is a voluntary framework applicable to any organisation regardless of size, sector, or geography. Australian organisations frequently adopt it alongside the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — CSF provides the governance and risk management structure while Essential Eight provides the specific technical controls.

---

## Before You Begin

You need:

- Access to the [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters) — a free browser-based tool for exploring and exporting CSF content
- A basic inventory of your organisation's critical systems and data
- Stakeholder access across IT, security, legal/compliance, and business leadership

No specific technology platform is required for the initial assessment phase.

---

## Step 1 — Understand the Six Core Functions

NIST CSF 2.0 organises cybersecurity activities into six functions. The Govern function is new in CSF 2.0 — it was added to emphasise that cybersecurity is a strategic enterprise risk, not solely a technical concern.

| Function | Symbol | Purpose |
|----------|--------|---------|
| **Govern** | GV | Establish and monitor cybersecurity risk management strategy, expectations, and policy |
| **Identify** | ID | Develop understanding of assets, risks, and vulnerabilities |
| **Protect** | PR | Implement safeguards to limit impact of cybersecurity events |
| **Detect** | DE | Identify cybersecurity events in a timely manner |
| **Respond** | RS | Take action on detected cybersecurity incidents |
| **Recover** | RC | Restore capabilities impaired by cybersecurity incidents |

Source: [NIST CSF 2.0 (CSWP 29)](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)

The Govern function spans all others — it establishes the context in which Identify through Recover operate. Think of it as the management layer above the technical layer.

---

## Step 2 — Download the CSF 2.0 Quick-Start Guide

NIST publishes quick-start guides tailored for different audiences. Select the one appropriate to your role:

- [Quick-Start Guide for Small Businesses](https://www.nist.gov/system/files/documents/2024/02/26/CSF-2.0-Small-Business-Quick-Start-Guide.pdf)
- [Quick-Start Guide for Enterprise Risk Managers](https://www.nist.gov/system/files/documents/2024/02/26/CSF-2.0-Enterprise-Risk-Manager-Quick-Start-Guide.pdf)
- [Quick-Start Guide for Creating Organisational Profiles](https://www.nist.gov/system/files/documents/2024/02/26/CSF-2.0-Organizational-Profile-Quick-Start-Guide.pdf)

For most organisations beginning their CSF journey, start with the **Organisational Profiles** guide.

---

## Step 3 — Create a Current Profile

A **Current Profile** describes your organisation's current cybersecurity posture — which CSF outcomes you have achieved and to what degree. This is your baseline.

### 3a — Open the CSF 2.0 Reference Tool

Navigate to [csrc.nist.gov/projects/cybersecurity-framework](https://csrc.nist.gov/projects/cybersecurity-framework) and open the **CSF 2.0 Reference Tool**. The tool allows you to:

- Browse all six functions, 22 categories, and 106 subcategories
- Export the full framework as a spreadsheet
- Filter by implementation tier

### 3b — Export the Framework Spreadsheet

Export the CSF 2.0 content to Excel or CSV. Add three columns:

| Column | Values | Description |
|--------|--------|-------------|
| Current Tier | 1–4 | How fully your organisation currently satisfies this outcome |
| Target Tier | 1–4 | Where you want to be in 12–18 months |
| Owner | Name/team | Who is responsible for this outcome |

### 3c — Rate Each Subcategory

Work through the subcategories function by function. Use the four **Implementation Tiers** as your rating scale:

| Tier | Label | Meaning |
|------|-------|---------|
| Tier 1 | Partial | Ad hoc, reactive, limited awareness of risk |
| Tier 2 | Risk Informed | Risk management exists but is not organisation-wide |
| Tier 3 | Repeatable | Risk practices formalised, consistently applied |
| Tier 4 | Adaptive | Risk management continuously improved, informed by lessons learned |

You do not need to assess all 106 subcategories in your first pass. Focus on the most critical ones for your organisation's context.

---

## Step 4 — Create a Target Profile

A **Target Profile** describes the cybersecurity outcomes your organisation needs to achieve to meet its risk tolerance, business requirements, and compliance obligations.

For Australian organisations, your target profile should incorporate:

- [ACSC Essential Eight Maturity Level 2](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) requirements — these map primarily to CSF Protect and Recover functions
- Any sector-specific obligations (APRA CPS 234, SOCI Act risk management programs, PSPF for government entities)
- Business objectives (customer trust, continuity, regulatory standing)

### Setting Target Tiers

As a starting point, set target tiers based on your organisation's size and risk profile:

| Organisation Profile | Suggested Target Tier |
|---------------------|----------------------|
| Small organisation, low-sensitivity data | Tier 2 for most outcomes |
| Medium organisation, moderate sensitivity | Tier 3 for critical outcomes, Tier 2 elsewhere |
| Government entity or regulated industry | Tier 3 across all outcomes; Tier 4 for critical systems |
| Critical infrastructure operator | Tier 4 for essential systems |

---

## Step 5 — Conduct a Gap Analysis

Compare your Current Profile to your Target Profile. For each subcategory where Current < Target:

1. **Describe the gap** — What specific capability is missing?
2. **Estimate effort** — Low (< 1 week), Medium (1–4 weeks), High (> 1 month)
3. **Assign priority** — Based on risk reduction and implementation dependency

Sort your gap list by a simple priority score: `Risk Impact × Implementation Ease`. Address high-impact, easy-to-implement gaps first.

---

## Step 6 — Identify Quick Wins

Look for gaps that can be closed immediately using capabilities you already own in Azure or Microsoft 365:

| CSF Outcome | Quick Win | Service |
|-------------|-----------|---------|
| PR.AA-01: Identities and credentials are managed | Enable [Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection) | Microsoft Entra ID P2 |
| PR.AA-03: Users authenticated before access | Enable MFA via [Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | Microsoft Entra ID P1 |
| DE.CM-01: Networks are monitored | Enable [Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | Azure subscription |
| RS.CO-02: Incidents are reported | Configure [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview) incident alerts | Microsoft Sentinel |
| GV.OC-01: Mission and stakeholder expectations understood | Document your security policy in [Microsoft Purview Compliance Portal](https://learn.microsoft.com/en-us/purview/compliance-manager-overview) | Microsoft 365 E3/E5 |

---

## Step 7 — Document Your Plan

Produce a simple implementation plan from your gap analysis:

```
Framework: NIST CSF 2.0
Assessment Date: [Date]
Current Profile: [Summary — average tier across functions]
Target Profile: [Summary — target tier per function]

Top 10 Priority Gaps:
1. [Gap description] — [Owner] — [Target date]
...

Review Cadence: Quarterly reassessment
```

Share this plan with leadership and revisit quarterly. CSF is designed to be a living instrument — your profiles should evolve as your capabilities and risk environment change.

---

## Next Steps

- [Map NIST CSF to Azure Services](how-to-map-nist-to-azure.md) — Function-by-function Azure service mapping
- [NIST CSF 2.0 Functions Reference](reference-nist-csf-functions.md) — Detailed function, category, and subcategory definitions
- [NIST CSF Evolution — 1.1 to 2.0](explanation-nist-csf-evolution.md) — What changed and why the Govern function matters

### Official Resources

- [NIST CSF 2.0 Publication (CSWP 29)](https://www.nist.gov/publications/nist-cybersecurity-framework-csf-20)
- [NIST CSF 2.0 Full PDF](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.29.pdf)
- [NIST CSF 2.0 Reference Tool](https://csrc.nist.gov/projects/cybersecurity-framework/filters#/csf/filters)
- [NIST — CSF 2.0 Quick-Start Guides](https://www.nist.gov/cyberframework/getting-started)
- [Microsoft — NIST CSF compliance documentation](https://learn.microsoft.com/en-us/compliance/regulatory/offering-nist-csf)
