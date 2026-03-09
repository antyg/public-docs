---
title: "Password Policy"
status: "draft"
last_updated: "2026-03-08"
audience: "Identity Engineers"
document_type: "readme"
domain: "identity"
---

# Password Policy


---

## Purpose

This folder contains the authoritative guidance on password policy for Microsoft Entra ID and enterprise environments. Content is structured per the [Diátaxis framework](https://diataxis.fr/) — explanation (why), how-to (implementation), and reference (standards and templates).

The central finding of this documentation: mandatory password expiration is counterproductive to security and should be replaced with modern compensating controls. This position is supported by [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html) (July 2025) and [Microsoft's password policy guidance](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations).

---

## Content Structure

| Folder         | Diátaxis Type | Content                                                        |
| -------------- | ------------- | -------------------------------------------------------------- |
| `explanation/` | Explanation   | Policy rationale, research summary, behavioural analysis       |
| `how-to/`      | How-to        | Implementation guidance for modern password controls           |
| `reference/`   | Reference     | Standards table, policy templates, compliance matrix, glossary |

---

## Key Documents

| Document                                                                                                   | Description                                                                                                              |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| [`explanation/why-expiration-is-counterproductive.md`](explanation/why-expiration-is-counterproductive.md) | Research-backed case against mandatory password expiration — NIST SP 800-63B-4, Microsoft guidance, behavioural analysis |
| [`how-to/implement-modern-password-controls.md`](how-to/implement-modern-password-controls.md)             | Step-by-step guide for removing expiration and enabling compensating controls in Entra ID                                |
| [`reference/standards-and-templates.md`](reference/standards-and-templates.md)                             | Standards reference table (NIST SP 800-63B-4, Microsoft, ACSC/ISM), decision framework, glossary                         |

---

## Relationship to Sibling Folders

- **`../entra-id/`** — Entra ID tenant configuration, including password policy settings
- **`../conditional-access/`** — Risk-based Conditional Access as a compensating control
- **`../mfa/`** — MFA is the primary compensating control when removing password expiration

---

## Relationship to Other Domains

- **`../../security/frameworks/essential-eight/`** — Essential Eight MFA requirements
- **`../../security/frameworks/nist/`** — NIST SP 800-63B-4 framework context
- **`../../compliance/`** — Compliance framework alignment for credential management controls

---

## Audience

- **Security Architects** — Designing password policies aligned with modern standards
- **Compliance Officers** — Justifying departure from legacy password expiration requirements
- **Identity Engineers** — Implementing evidence-based credential policies in Entra ID
- **Auditors** — Understanding security rationale for policy decisions

---

## Australian English

This documentation uses Australian English spelling and conventions throughout.
