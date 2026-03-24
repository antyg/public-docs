---
title: "Security"
status: "draft"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
---

# Security

This domain contains security-related documentation organised into frameworks and products.

## Organisation Model

The security domain uses a three-way separation model:

- **Frameworks** (this domain) — Policy and process definitions: "what to comply with"
- **Products** (this domain) — Technology documentation: "how the tech works"
- **Compliance** (separate domain) — Product-specific alignment: "how to make the tech comply"

This separation ensures framework definitions remain product-agnostic, while product documentation focuses on technical implementation without duplicating compliance mapping.

## Subfolders

### Frameworks

[`frameworks/`](frameworks/) contains security framework definitions and control specifications, including:
- Essential Eight (ACSC maturity model)
- NIST Cybersecurity Framework
- Zero Trust Architecture

These frameworks define security controls and requirements independent of specific technology implementations.

### Products

#### Defender for Cloud

[`defender-for-cloud/`](defender-for-cloud/) contains comprehensive documentation for Microsoft Defender for Cloud, covering:
- Cloud Security Posture Management (CSPM)
- Cloud workload protection
- Multi-cloud security
- Sequential implementation guides
- PowerShell automation scripts
- Azure Policy configurations

#### Defender for Endpoint

[`defender-for-endpoint/`](defender-for-endpoint/) contains documentation for Microsoft Defender for Endpoint, covering:
- Endpoint detection and response (EDR)
- Deployment validation methods
- Status monitoring scripts
- Azure Workbook deployment validation
- Australian region configurations

#### Microsoft Sentinel

[`sentinel/`](sentinel/) contains documentation for Microsoft Sentinel, covering:
- SIEM and SOAR capabilities
- Data connector configuration
- Analytics rules and threat detection
- Automation playbooks and incident management
- KQL threat hunting

#### Microsoft Entra ID Protection

[`identity-protection/`](identity-protection/) contains documentation for Microsoft Entra ID Protection, covering:
- Identity risk detection and remediation
- Risk-based Conditional Access policies
- User risk and sign-in risk management
- Integration with Microsoft Sentinel

## Future Expansion

Planned product additions include:
- Microsoft Purview (data governance and compliance)

## Relationship to Compliance Domain

The separate [`compliance/`](../compliance/) domain contains product-specific compliance alignment guidance. When you need to implement a framework control using a specific product:

1. Read the framework definition here in `security/frameworks/`
2. Read the product technical documentation here in `security/{product}/`
3. Read the compliance alignment guide in `compliance/{framework}/{product}/`

This three-way model ensures framework definitions remain authoritative and product-independent, while compliance guidance provides concrete implementation mappings.
