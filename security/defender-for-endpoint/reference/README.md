---
title: "Reference — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Reference — Microsoft Defender for Endpoint

## About This Section

Reference documentation is information-oriented. It provides precise, factual technical data structured for quick lookup — without teaching or guiding. Use it when you need to know what a property means, what values a class exposes, or what the correct namespace is.

---

## Reference Documents in This Section

| Document | Description |
|----------|-------------|
| [Registry and Service Reference](registry-service-reference.md) | Definitive registry keys, Windows services, and onboarding state verification for local and remote devices |
| [WMI/CIM Query Reference](wmi-cim-reference.md) | WMI namespaces, CIM class schemas, property definitions, and remote query patterns |
| [MDE Client Analyzer Reference](client-analyzer.md) | Official MDE diagnostic tool — flags, output interpretation, and escalation workflows |

---

## Key Reference Topics

### WMI Namespace

`root\Microsoft\Windows\Defender`

### Key WMI Classes

| Class | Purpose |
|-------|---------|
| `MSFT_MpComputerStatus` | Overall Defender and MDE sensor status |
| `MSFT_MpPreference` | Defender configuration and exclusions |
| `MSFT_MpSignature` | Signature version and update state |
| `MSFT_MpThreat` | Active threat detections |

### Onboarding Status Values (Graph API)

| Value | Meaning |
|-------|---------|
| `Onboarded` | Successfully registered with MDE cloud |
| `CanBeOnboarded` | Discovered but not yet onboarded |
| `Unsupported` | OS not supported by MDE |
| `InsufficientInfo` | Cannot determine eligibility |

---

## Related Sections

- [Tutorials](../tutorials/README.md) — Hands-on exercises using these reference classes
- [How-to Guides](../how-to/README.md) — Task-oriented validation procedures
- [Explanation](../explanation/README.md) — Conceptual overview of all validation methods
