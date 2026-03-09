---
title: "Explanation — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Explanation — Microsoft Defender for Endpoint

## About This Section

Explanation documents are understanding-oriented. They provide context, background, and conceptual frameworks that help you make informed decisions. They explain *why* things work the way they do, and *when* to choose one approach over another.

---

## Documents in This Section

| Document | Description |
|----------|-------------|
| [Validation Methods Overview](validation-methods-overview.md) | Comparative analysis of all seven MDE validation methods — scope, authentication, execution time, and best-fit scenarios |

---

## Key Concepts Explained

### Validation States

Every MDE device falls into one of these states, regardless of which validation method is used:

| State | Meaning |
|-------|---------|
| **Installed** | MDE components are present on the device |
| **Onboarded** | Device is registered with the MDE cloud service |
| **Functional** | All MDE services are running and reporting correctly |
| **Can Be Onboarded** | Device discovered via network scanning but not enrolled |
| **Unsupported** | Operating system incompatible with MDE |
| **Insufficient Info** | Status cannot be determined |

### Method Selection

The choice of validation method depends on three factors:

1. **Scope** — Are you checking one device or your entire fleet?
2. **Access** — Do you have local admin, WinRM, or only portal access?
3. **Purpose** — Is this a quick check, compliance report, or deep troubleshooting?

See the [Validation Methods Overview](validation-methods-overview.md) for a full decision matrix.

---

## Related Sections

- [Tutorials](../tutorials/README.md) — Hands-on exercises for PowerShell and Graph API validation
- [How-to Guides](../how-to/README.md) — Practical task-oriented validation procedures
- [Reference](../reference/README.md) — Technical data for WMI/CIM and API schemas
