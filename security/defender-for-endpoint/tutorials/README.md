---
title: "Tutorials — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Tutorials — Microsoft Defender for Endpoint

## About This Section

Tutorials are learning-oriented. They guide you step-by-step through hands-on exercises that build practical competence with MDE validation and deployment verification.

Work through each tutorial in sequence to develop a solid foundation before moving to task-oriented how-to guides.

---

## Tutorials in This Section

| Tutorial | Description |
|----------|-------------|
| [Method 1: PowerShell Local/Remote Validation](powershell-validation.md) | Validate MDE status using PowerShell cmdlets on local and remote devices |
| [Method 2: Graph API Validation](graph-api-validation.md) | Query MDE device inventory programmatically using the Microsoft Security Center API |

---

## Prerequisites

Before starting these tutorials, ensure you have:

- Windows PowerShell 5.1 or PowerShell 7+
- Administrator credentials for target devices (for remote validation)
- Network access to target devices (WinRM enabled for remote methods)
- For Graph API tutorials: an Azure AD App Registration with `Machine.Read.All` permission

---

## Related Sections

- [How-to Guides](../how-to/README.md) — Task-oriented procedures for specific validation scenarios
- [Reference](../reference/README.md) — WMI/CIM class schemas and property lookup
- [Explanation](../explanation/README.md) — Comparison of all validation methods and when to use each
- [Scripts](../scripts/README.md) — Production-ready PowerShell automation scripts
