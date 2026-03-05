# Security Frameworks

This folder contains security framework definitions and control specifications, independent of specific technology implementations.

## Purpose

Security frameworks define "what to comply with" — the policies, controls, and requirements that organisations must meet. These definitions are product-agnostic and serve as authoritative references for security requirements.

## Separation from Products

This folder contains only framework definitions and control specifications. It does **not** contain product-specific implementation guidance. That separation is maintained as follows:

- **Frameworks** (here) — Control definitions, maturity models, requirement specifications
- **Products** (sibling folders) — Technology documentation for security tools
- **Compliance** (separate domain) — Product-specific alignment and implementation guidance

For example, Essential Eight defines application control requirements here. Defender for Endpoint documentation lives in `../defender-for-endpoint/`. Compliance alignment guidance showing how to configure Defender for Endpoint to meet Essential Eight application control lives in the separate `compliance/` domain.

## Frameworks

### Essential Eight

[`essential-eight/`](essential-eight/) — ACSC Essential Eight Maturity Model

The Australian Cyber Security Centre's prioritised strategies to mitigate cyber security incidents. Includes maturity levels 1-3 across eight mitigation strategies.

### NIST

[`nist/`](nist/) — NIST Cybersecurity Framework and Controls

US National Institute of Standards and Technology framework, including SP 800-53 security controls and the CSF framework structure.

### Zero Trust

[`zero-trust/`](zero-trust/) — Zero Trust Architecture Principles

Architecture principles and patterns for implementing zero trust security models, including identity-centric security and least-privilege access.

## Relationship to Compliance Domain

The separate [`../../compliance/`](../../compliance/) domain contains compliance alignment matrices that map framework controls to product capabilities. Use this workflow:

1. **Define requirements** — Read framework control specifications here
2. **Understand technology** — Read product technical documentation in sibling folders
3. **Implement compliance** — Follow product-specific alignment guidance in the compliance domain

This three-way model ensures framework definitions remain authoritative and technology-neutral.

## Australian Context

Where frameworks have Australian-specific variants or interpretations (e.g., Essential Eight, ISM), this folder contains the Australian versions. International frameworks (e.g., NIST) are included for cross-mapping and organisations operating under multiple jurisdictions.
