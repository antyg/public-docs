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

## Future Expansion

Planned product additions include:
- Microsoft Sentinel (SIEM/SOAR)
- Microsoft Entra ID Protection
- Microsoft Purview (data governance and compliance)

## Relationship to Compliance Domain

The separate [`compliance/`](../compliance/) domain contains product-specific compliance alignment guidance. When you need to implement a framework control using a specific product:

1. Read the framework definition here in `security/frameworks/`
2. Read the product technical documentation here in `security/{product}/`
3. Read the compliance alignment guide in `compliance/{framework}/{product}/`

This three-way model ensures framework definitions remain authoritative and product-independent, while compliance guidance provides concrete implementation mappings.
