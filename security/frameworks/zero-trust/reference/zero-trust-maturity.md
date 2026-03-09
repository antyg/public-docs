---
title: "Zero Trust Maturity Reference"
status: "published"
last_updated: "2026-03-09"
audience: "Security architects and compliance officers assessing Zero Trust maturity"
document_type: "reference"
domain: "security"
---

# Zero Trust Maturity Reference

**Source**: [CISA Zero Trust Maturity Model Version 2.0 (April 2023)](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model)

---

## Overview

The [CISA Zero Trust Maturity Model (ZTMM) v2.0](https://www.cisa.gov/sites/default/files/2023-04/zero_trust_maturity_model_v2_508.pdf) provides a structured framework for assessing and advancing Zero Trust implementation. While developed for US federal agencies in support of Executive Order 14028, CISA states that all organisations should review and consider adoption of these approaches.

The model defines five pillars and four maturity stages. This reference document maps ZTMM outcomes to Microsoft Azure and Microsoft 365 services.

---

## Maturity Stages

| Stage | Label | Characteristics |
|-------|-------|----------------|
| **Traditional** | Starting point | Manual configurations, siloed security practices, limited visibility, minimal automation |
| **Initial** | Beginning Zero Trust | Some automation and integration, centralised identity management, initial visibility tooling |
| **Advanced** | Progressing | Integrated controls across pillars, automated responses, consistent policy enforcement |
| **Optimal** | Fully realised | Fully automated, dynamic policy enforcement, continuous risk-based access evaluation, cross-pillar integration |

Source: [CISA ZTMM v2.0 PDF, Section 2](https://www.cisa.gov/sites/default/files/2023-04/zero_trust_maturity_model_v2_508.pdf)

---

## Pillar 1 — Identity

| Maturity Stage | Capability | Microsoft Service |
|---------------|------------|------------------|
| Traditional | Static passwords; limited MFA; manual provisioning; no least-privilege enforcement | — |
| Initial | MFA enforced for most users; basic RBAC in place; manual access reviews | [Microsoft Entra MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks); [Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) |
| Advanced | Phishing-resistant MFA for all users; JIT privileged access; automated lifecycle management | [Authentication Strengths](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview); [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) |
| Optimal | Risk-based adaptive access; continuous session evaluation; passwordless for all users; real-time identity anomaly response | [Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection); [Continuous Access Evaluation (CAE)](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation) |

**Assessment Questions**:
- Is MFA enforced for all users for all access (not just privileged)?
- Are phishing-resistant methods (FIDO2, Windows Hello) deployed for privileged users?
- Is standing privileged access eliminated (PIM eligible assignments)?
- Are access reviews conducted automatically and regularly?

---

## Pillar 2 — Devices

| Maturity Stage | Capability | Microsoft Service |
|---------------|------------|------------------|
| Traditional | No MDM; manual device compliance checks; unknown device state at access time | — |
| Initial | Mobile Device Management deployed; basic compliance policies; some device compliance enforcement | [Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune) |
| Advanced | Device compliance required for all resource access; endpoint detection and response active; device risk integrated with access policies | [Intune compliance policies](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started); [Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) |
| Optimal | Real-time device risk assessment; automated device remediation; application control enforced; all devices continuously monitored | [Defender for Endpoint device risk integration with Conditional Access](https://learn.microsoft.com/en-us/mem/intune/protect/advanced-threat-protection) |

**Assessment Questions**:
- Are all devices enrolled in MDM (Intune)?
- Is device compliance a requirement for accessing corporate resources (via Conditional Access)?
- Is Defender for Endpoint deployed on all managed devices?
- Is device risk score integrated into Conditional Access policy decisions?

---

## Pillar 3 — Networks

| Maturity Stage | Capability | Microsoft Service |
|---------------|------------|------------------|
| Traditional | Flat network; open east-west traffic; perimeter firewall only; no encryption of internal traffic | — |
| Initial | Basic segmentation; VPN for remote access; some egress filtering | Azure VNet with NSGs |
| Advanced | Micro-segmentation; all PaaS services on private endpoints; centralised firewall with application-layer inspection | [Azure Firewall Premium](https://learn.microsoft.com/en-us/azure/firewall/premium-features); [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) |
| Optimal | Software-defined networking; all traffic encrypted and inspected; dynamic policy enforcement; real-time threat intelligence integrated into network controls | [Azure Firewall — Threat Intelligence](https://learn.microsoft.com/en-us/azure/firewall/threat-intel); [Azure DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview) |

**Assessment Questions**:
- Is east-west traffic between workloads restricted by NSGs or firewall rules?
- Are PaaS services (Storage, SQL, Key Vault) accessible only via private endpoints?
- Is all internet egress routed through a centralised firewall with application-layer filtering?
- Is network traffic analytics enabled for visibility into traffic patterns?

---

## Pillar 4 — Applications and Workloads

| Maturity Stage | Capability | Microsoft Service |
|---------------|------------|------------------|
| Traditional | No app inventory; manual access controls; no visibility into app usage | — |
| Initial | Known apps catalogued; basic RBAC; some SSO adoption | [Microsoft Entra — Enterprise applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/overview-application-management) |
| Advanced | Shadow IT discovered and controlled; app-level Conditional Access; user consent restricted; session controls active | [Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/what-is-defender-for-cloud-apps) |
| Optimal | All apps instrumented; continuous behavioural analytics; automated response to anomalous app usage; in-session data controls | [Defender for Cloud Apps — Conditional Access App Control](https://learn.microsoft.com/en-us/defender-cloud-apps/proxy-intro-aad) |

**Assessment Questions**:
- Is cloud app discovery active (Defender for Cloud Apps or equivalent)?
- Is user consent to app permissions disabled (requiring admin approval)?
- Are high-sensitivity apps protected by Conditional Access App Control?
- Are anomalous app usage patterns alerted and investigated?

---

## Pillar 5 — Data

| Maturity Stage | Capability | Microsoft Service |
|---------------|------------|------------------|
| Traditional | No data classification; no DLP; data access based on network location | — |
| Initial | Manual classification; basic DLP policies for known sensitive types; encryption of data at rest | [Microsoft Purview — Sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) (manual) |
| Advanced | Automated classification and labelling; DLP enforced across M365 and endpoints; encryption tied to labels | [Microsoft Purview — Auto-labelling](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically); [Purview DLP](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp) |
| Optimal | Data access decisions driven by classification; real-time data exfiltration detection; data-centric access control (access tied to the data, not the location) | [Microsoft Purview — Insider Risk Management](https://learn.microsoft.com/en-us/purview/insider-risk-management-solution-overview) |

**Assessment Questions**:
- Is a sensitivity label taxonomy defined and published to all users?
- Are DLP policies active for known sensitive data types (Tax File Numbers, financial data)?
- Is encryption enforced for Confidential and above classification labels?
- Is insider risk management configured to detect data exfiltration patterns?

---

## Cross-Cutting Capabilities

CISA ZTMM v2.0 defines three cross-cutting capabilities that span all five pillars:

| Capability | Description | Microsoft Service |
|-----------|-------------|------------------|
| **Visibility and Analytics** | Telemetry from all pillars aggregated; threat detection and hunting capabilities | [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview); [Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender) |
| **Automation and Orchestration** | Policy enforcement and incident response automated; manual intervention minimised | [Sentinel Playbooks (Logic Apps)](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks); [Defender XDR — Automated Investigation and Response (AIR)](https://learn.microsoft.com/en-us/defender-xdr/m365d-autoir) |
| **Governance** | Policies formally defined; risk accepted explicitly; compliance continuously monitored | [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager-overview); [Microsoft Secure Score](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score) |

---

## Microsoft Zero Trust Assessment Tool

Microsoft provides a free interactive assessment tool at [microsoft.github.io/zerotrustassessment](https://microsoft.github.io/zerotrustassessment/). The tool:

- Connects to your Microsoft 365 tenant via a PowerShell script
- Assesses your current Zero Trust configuration against Microsoft's recommended controls
- Produces a scored report with recommended actions

Run the assessment before and after each implementation phase to track progress.

---

## Relationship to Australian Frameworks

| Australian Framework | Zero Trust Alignment |
|--------------------|---------------------|
| [ACSC Essential Eight ML2](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) | Achieving ML2 across all eight strategies corresponds to approximately **Advanced** maturity in the Identity and Devices pillars |
| [ACSC ISM — Network segmentation controls](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) | ISM network controls align with ZTMM Initial–Advanced for the Networks pillar |
| [PSPF — Protective security requirements](https://www.protectivesecurity.gov.au/) | PSPF system security requirements align with ZTMM Initial maturity as a minimum for government entities |

---

## Related Resources

- [CISA Zero Trust Maturity Model v2.0](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model)
- [CISA ZTMM v2.0 Full PDF](https://www.cisa.gov/sites/default/files/2023-04/zero_trust_maturity_model_v2_508.pdf)
- [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview)
- [Zero Trust Assessment Tool](https://microsoft.github.io/zerotrustassessment/)
- [NIST SP 800-207 Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [Implement Zero Trust Pillars](../how-to/implement-zero-trust-pillars.md)
- [Zero Trust Principles Explained](../explanation/zero-trust-principles.md)
