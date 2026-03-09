---
title: "How-to Guides — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# How-to Guides — Microsoft Defender for Endpoint

## About This Section

How-to guides are task-oriented. They provide goal-directed, practical instructions for completing specific MDE validation and troubleshooting tasks. They assume basic competence and focus on achieving a result.

---

## Guides in This Section

| Guide | Task |
|-------|------|
| [Method 3: Security Console Manual Checks](console-validation.md) | Export device inventory and validate onboarding status via the Microsoft 365 Defender portal |
| [Method 4: Registry and Service Validation](../reference/registry-service-reference.md) | Definitively verify MDE installation and onboarding state using registry keys and Windows services |
| [Method 5: Advanced Hunting KQL Queries](advanced-hunting-kql.md) | Query MDE telemetry using KQL for compliance reporting and trend analysis |
| [Method 6: MDE Client Analyzer Tool](../reference/client-analyzer.md) | Run the official MDE diagnostic tool for deep sensor health and connectivity troubleshooting |

---

## Choosing the Right Guide

| Scenario | Guide |
|----------|-------|
| Need a quick visual check without scripting | [Method 3: Security Console](console-validation.md) |
| Device not appearing in portal — local check needed | [Method 4: Registry/Service](../reference/registry-service-reference.md) |
| Compliance reporting over 30 days of history | [Method 5: Advanced Hunting KQL](advanced-hunting-kql.md) |
| Deep diagnostics for escalation to Microsoft Support | [Method 6: MDE Client Analyzer](../reference/client-analyzer.md) |

---

## Related Sections

- [Tutorials](../tutorials/README.md) — Step-by-step learning exercises for PowerShell and Graph API validation
- [Reference](../reference/README.md) — WMI/CIM class schemas and property lookup
- [Explanation](../explanation/README.md) — Method comparison and decision guidance
- [Scripts](../scripts/README.md) — Production-ready PowerShell automation scripts
