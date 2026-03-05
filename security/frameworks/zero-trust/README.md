# Zero Trust Architecture

**Status**: SEEDED — Content planned but not yet migrated

This folder will contain documentation for Zero Trust security architecture principles and implementation strategies.

## Scope

Zero Trust is a security model based on the principle "never trust, always verify". Unlike traditional perimeter-based security, Zero Trust assumes breach and verifies every access request regardless of origin.

### Core Principles

The Zero Trust model is built on three foundational principles:

1. **Verify Explicitly** — Always authenticate and authorise based on all available data points (identity, location, device health, service/workload, data classification, anomalies)

2. **Use Least Privilege Access** — Limit user access with Just-In-Time and Just-Enough-Access (JIT/JEA), risk-based adaptive policies, and data protection

3. **Assume Breach** — Minimise blast radius and segment access. Verify end-to-end encryption. Use analytics to gain visibility, drive threat detection, and improve defences.

### Six Pillars

Zero Trust architecture spans six pillars:

1. **Identities** — Users, services, devices verify before granting access
2. **Devices** — Monitor and enforce device health and compliance
3. **Applications** — Discover shadow IT, ensure appropriate in-app permissions, gate access based on real-time analytics
4. **Data** — Move from perimeter-based data protection to data-driven protection
5. **Infrastructure** — Use telemetry to detect attacks and anomalies, automatically block and flag risky behaviour
6. **Networks** — Encrypt all internal communications, limit access by policy, employ micro-segmentation and real-time threat protection

## Planned Content

This folder will contain:

- **Architecture Guides** — Reference architectures for Zero Trust implementation
- **Implementation Strategies** — Phased deployment approaches, maturity models
- **Microsoft Zero Trust Deployment** — Specific guidance for Microsoft 365, Azure, and Defender platforms
- **Identity-Centric Security** — Modern authentication, conditional access, privileged access management
- **Network Micro-Segmentation** — Software-defined perimeters, application-aware networking
- **Continuous Verification** — Risk-based access controls, adaptive policies, anomaly detection

## Relationship to Product Documentation

Zero Trust defines **what** the target architecture should achieve. Product-specific documentation describes **how** the technology works. Compliance alignment guidance in the separate `compliance/` domain maps Zero Trust principles to product capabilities.

### Example Workflow

To implement Zero Trust identity verification using Microsoft Entra ID:

1. **Read principles** — This folder defines verify explicitly and least privilege requirements
2. **Understand technology** — Product documentation explains how Entra ID Conditional Access and Privileged Identity Management work
3. **Implement architecture** — Architecture guides in this folder provide deployment sequencing and integration patterns

## Integration with Other Frameworks

Zero Trust complements traditional compliance frameworks:

- **Essential Eight** — Zero Trust architectural patterns support Essential Eight controls (especially MFA, application control, privileged access)
- **NIST SP 800-207** — NIST's Zero Trust Architecture publication provides detailed implementation guidance
- **ISM** — Australian ISM increasingly references Zero Trust principles in access control and network security controls

This folder will include mapping between Zero Trust principles and traditional framework controls.

## Microsoft Zero Trust Deployment

For organisations using Microsoft platforms, Zero Trust implementation follows a specific deployment path:

### Deployment Phases

1. **Establish identity foundation** — Modern authentication, MFA, Conditional Access
2. **Secure endpoints** — Device management, compliance policies, application protection
3. **Protect data** — Information protection, DLP, encryption
4. **Harden infrastructure** — Network segmentation, workload protection, security monitoring
5. **Implement governance** — Continuous assessment, automated response, threat intelligence

### Key Technologies

- **Microsoft Entra ID** — Identity and access management, Conditional Access
- **Defender for Endpoint** — Endpoint detection and response, device compliance
- **Defender for Cloud** — Infrastructure security, workload protection
- **Microsoft Purview** — Information protection, data loss prevention
- **Microsoft Sentinel** — Security information and event management, orchestration

Detailed product-specific deployment guidance will reference the respective product documentation folders.

## Maturity Model

Zero Trust implementation follows a maturity progression:

- **Traditional** — On-premises identity, perimeter-based security, static policies
- **Advanced** — Cloud identity, some segmentation, basic analytics
- **Optimal** — Full Zero Trust architecture, continuous verification, adaptive policies, automated response

Implementation guidance will include assessment tools and maturity progression paths.

## Resources

Official resources:
- [Microsoft Zero Trust](https://www.microsoft.com/security/business/zero-trust)
- [NIST SP 800-207 Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [CISA Zero Trust Maturity Model](https://www.cisa.gov/zero-trust-maturity-model)

---

**Note**: This is a seeded placeholder. Content migration is planned but not yet complete. Until migration, refer to official documentation for Zero Trust architecture guidance.
