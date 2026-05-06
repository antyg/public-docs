---
title: "Alignment Bridge — Maintenance Guidelines"
status: "draft"
last_updated: "2026-03-08"
audience: "Compliance Officers"
document_type: "explanation"
domain: "compliance"
---

# Alignment Bridge — Maintenance Guidelines

---

## Purpose

Alignment content becomes stale when frameworks are updated or when technology products change their capabilities, feature names, or configuration paths. This document defines how alignment guides in `compliance/` are kept current, who is responsible for initiating reviews, and how changes propagate through the three-layer model.

---

## What Causes Alignment Content to Become Stale

### Framework Changes

The [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) is revised periodically. The [Australian Government Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) is updated annually (typically April). [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) undergoes major revisions on multi-year cycles with interim updates.

When a framework is updated, any alignment guide that cites affected controls must be reviewed. Changes that trigger a review:

- Control requirements strengthened or relaxed (e.g., Essential Eight maturity level thresholds adjusted)
- New controls added to the framework
- Control identifiers renumbered or renamed
- Assessment criteria or evidence requirements changed

### Product Changes

Microsoft product changes — feature renames, portal consolidations, API deprecations, new capabilities — can invalidate configuration guidance even when the underlying framework requirement is unchanged.

Changes that trigger a review:

- Feature renamed (e.g., portal name changes, capability rebrand)
- Configuration path changed (e.g., setting moved between admin centres)
- New product capability that better satisfies a control
- Feature deprecated or removed
- Microsoft Learn documentation URL changed

### Assessment Findings

Where alignment guides are used during actual compliance assessments, assessors may identify that:

- Configuration guidance does not produce evidence that satisfies an auditor's interpretation of the control
- A gap or caveat was understated
- A compensating control pattern is more effective than the one documented

Assessment findings are treated as defect reports against the alignment guide and trigger a targeted update.

---

## Review Triggers and Cadence

| Trigger | Review Scope | Cadence |
|---------|-------------|---------|
| ISM annual update (typically April) | All ISM alignment content | Annual — within 4 weeks of ISM publication |
| Essential Eight revision | All Essential Eight alignment content | On publication — within 4 weeks |
| NIST SP 800-53 revision | All NIST alignment content | On publication — within 8 weeks |
| Microsoft product change affecting a documented feature | Affected alignment guide sections only | On change detection |
| Assessment finding | Specific control guidance section | Within 2 weeks of finding |
| Layer 3 product doc update (significant) | Cross-reference links in alignment guides | Quarterly review |

---

## Review Process

### 1. Identify Affected Controls

When a framework update is published, identify which control identifiers have changed. Compare against the control references documented in existing alignment guides. Any guide citing an affected control ID is in scope for review.

### 2. Assess Impact

For each affected control, determine whether the change:

- **Requires content update** — The alignment guide must be revised (control language changed, requirements tightened)
- **Requires link update only** — The guidance is still valid but a URL or document reference needs updating
- **Requires no change** — The framework change does not affect the documented controls

### 3. Update Content

Apply updates using the [mapping methodology](./mapping-methodology.md) as the authoring standard. All changes must:

- Update the **Last Updated** date in the file header
- Cite the new framework version or publication date in the affected control reference
- Preserve the prior control interpretation in a dated note if the change affects audit evidence already collected under the previous version

### 4. Update Layer 3 Cross-References

If the update reveals that a Layer 3 product document is also stale (e.g., a Microsoft Learn URL is broken, or a feature has been renamed in the product docs), log this as a defect against the relevant `security/`, `identity/`, or `endpoints/` subfolder. Alignment guides link to Layer 3 docs — they do not own or duplicate Layer 3 content.

---

## Ownership and Responsibility

Alignment content is maintained by whoever last authored the guide. When authorship is unclear, the `compliance/` domain owner is responsible.

Reviewing framework publication channels:

- **Essential Eight and ISM** — [cyber.gov.au](https://www.cyber.gov.au/) publishes updates with versioned PDFs and change summaries
- **NIST** — [csrc.nist.gov](https://csrc.nist.gov/) publishes revision announcements; subscribe to NIST news for notifications
- **CIS Controls** — [cisecurity.org](https://www.cisecurity.org/controls) publishes new versions with transition guidance
- **Microsoft product changes** — Microsoft Learn changelog, Microsoft 365 Message Centre, and Microsoft Tech Community blog for product announcements

---

## Deprecation

If an alignment guide becomes unmaintainable — for example, if the underlying product is retired or a framework is superseded without a direct successor — the guide is not silently removed. Instead:

1. Update the **Status** field to `Deprecated`
2. Add a deprecation notice at the top of the file explaining the reason and the date
3. Redirect readers to any replacement guide if one exists
4. Retain the file in version control history

---

## Related Resources

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CIS Controls v8](https://www.cisecurity.org/controls/v8)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [Alignment Bridge — Mapping Methodology](./mapping-methodology.md)

---

**Australian English** is used throughout this documentation.
