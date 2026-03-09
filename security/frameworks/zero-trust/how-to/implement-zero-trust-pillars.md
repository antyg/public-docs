---
title: "How to Implement Zero Trust Pillars"
status: "published"
last_updated: "2026-03-09"
audience: "Security engineers implementing Zero Trust architecture across Microsoft Azure and Microsoft 365"
document_type: "how-to"
domain: "security"
---

# How to Implement Zero Trust Pillars

---

## Overview

The [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview) organises implementation across six technology pillars. This guide provides implementation steps for each pillar, with specific Azure and Microsoft 365 service mappings.

Complete the identity pillar (covered in [Getting Started with Zero Trust](../tutorials/getting-started-with-zero-trust.md)) before beginning the other pillars — identity verification is the prerequisite for all Zero Trust access decisions.

For maturity assessment against the CISA Zero Trust Maturity Model, see [Zero Trust Maturity Reference](../reference/zero-trust-maturity.md).

---

## Pillar 1 — Identity

**Principle**: Every access request must be authenticated and authorised using a verified identity.

**Status**: Covered in [Getting Started with Zero Trust](../tutorials/getting-started-with-zero-trust.md). Key controls:

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| MFA for all users | [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | Verify explicitly — every sign-in challenged |
| Phishing-resistant MFA for privileged users | [Authentication Strengths](https://learn.microsoft.com/en-us/entra/identity/conditional-access/authentication-strength-overview) | Verify explicitly — strongest assurance for highest risk |
| JIT privileged access | [Microsoft Entra PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) | Least privilege — time-bound access only |
| Risk-based access | [Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection) | Assume breach — continuous risk assessment |

---

## Pillar 2 — Endpoints

**Principle**: Only healthy, compliant, and managed devices should be granted access to organisational resources.

### Key Controls

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| Device compliance policies | [Microsoft Intune — Device compliance](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started) | Verify explicitly — device health assessed before access |
| Require compliant device | [Conditional Access — device compliance grant](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-compliant-device) | Verify explicitly — non-compliant devices blocked |
| Endpoint detection and response | [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint) | Assume breach — continuous threat detection on devices |
| Application control | [App Control for Business via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-app-control-policy) | Least privilege — only approved apps execute |

### Implementation Steps

**1. Create device compliance policies in Intune**

Navigate to **Intune admin centre > Devices > Compliance policies > Create policy**. For Windows 10/11:

- **Require BitLocker**: Yes
- **Require Secure Boot**: Yes
- **Require code integrity**: Yes
- **Minimum OS version**: Set to current supported version
- **Microsoft Defender Antimalware**: Required; real-time protection required
- **Defender Antimalware minimum version**: Set to current version

**2. Enforce device compliance in Conditional Access**

Create or update your Conditional Access policies:

- **Name**: ZT-004 — Require Compliant or Hybrid Joined Device
- **Users**: All users
- **Target resources**: All cloud apps
- **Grant**: Require device to be marked as compliant OR Require hybrid Azure AD join (choose based on your device management model)

**3. Enrol devices in Defender for Endpoint**

If not already deployed, enable Defender for Endpoint through the Microsoft Defender portal. Use Intune to deploy the onboarding package (**Devices > Configuration profiles > Create > Endpoint detection and response**). Target all device groups.

**4. Configure device risk integration with Conditional Access**

In Microsoft Entra admin centre, create a Conditional Access policy:

- **Conditions > Device filters**: Configure device risk levels
- **Conditions > Sign-in risk**: Medium or higher — requires MFA step-up
- **Conditions > Device risk** (via Defender for Endpoint integration): Requires device risk to be Low or Clear

---

## Pillar 3 — Data

**Principle**: Data should be classified and protected based on sensitivity, with access limited to authorised identities regardless of data location.

### Key Controls

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| Data classification | [Microsoft Purview — Sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) | Know what data you have and its sensitivity |
| Data loss prevention | [Microsoft Purview DLP](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp) | Prevent data exfiltration to unauthorised destinations |
| Encryption at rest and in transit | [Azure Storage Service Encryption](https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption); [BitLocker via Intune](https://learn.microsoft.com/en-us/mem/intune/protect/encrypt-devices) | Assume breach — data unreadable without keys |
| Information barriers | [Microsoft Purview Information Barriers](https://learn.microsoft.com/en-us/purview/information-barriers-solution-overview) | Least privilege — segment data access by department |

### Implementation Steps

**1. Define sensitivity labels**

Navigate to **Microsoft Purview compliance portal > Information protection > Labels > Create a label**. Create labels aligned to your data classification scheme (e.g., Public, Internal, Confidential, Highly Confidential). Configure:

- **Encryption**: Enable for Confidential and above — restrict access to specific groups
- **Content marking**: Apply headers, footers, and watermarks
- **Auto-labelling**: Configure for known sensitive data types (Tax File Numbers, bank details)

**2. Publish labels to users**

Create a label policy (**Information protection > Label policies > Publish label**) and assign to all users. Enable:

- **Require users to apply a label**: Yes (for email and documents)
- **Default label**: Internal

**3. Create DLP policies**

Navigate to **Microsoft Purview > Data loss prevention > Policies > Create policy**. Use the built-in Australian Financial Data template or create custom rules for:

- Australian Tax File Numbers
- Medicare numbers
- Bank account numbers

Configure to block sharing externally and notify users and compliance teams.

---

## Pillar 4 — Applications

**Principle**: Discover and control all applications in use, enforce application-level access controls, and gate access based on real-time analytics.

### Key Controls

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| Shadow IT discovery | [Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/what-is-defender-for-cloud-apps) | Verify explicitly — know which apps are in use |
| App access control | [Defender for Cloud Apps — Conditional Access App Control](https://learn.microsoft.com/en-us/defender-cloud-apps/proxy-intro-aad) | Verify explicitly — session-level app controls |
| App registration governance | [Microsoft Entra — App registrations](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/overview-application-management) | Least privilege — control consent and permissions |
| Application isolation | [Azure App Service — Network isolation](https://learn.microsoft.com/en-us/azure/app-service/networking-features) | Assume breach — isolate application workloads |

### Implementation Steps

**1. Enable Cloud Discovery in Defender for Cloud Apps**

Navigate to **Microsoft Defender portal > Cloud Apps > Cloud discovery**. Enable log collection from:

- Microsoft Defender for Endpoint (automatic cloud app discovery from endpoint traffic)
- Network firewalls (if applicable — upload or stream logs)

Review the **Discovered apps** report to identify sanctioned vs unsanctioned apps.

**2. Block unsanctioned apps**

For apps identified as high-risk or unsanctioned in Cloud App Security, use **Governance > Block** or create a Conditional Access policy that blocks access to the specific application via its app ID.

**3. Apply Conditional Access App Control for sensitive apps**

For high-sensitivity apps (finance, HR systems), create a Conditional Access policy that routes sessions through Defender for Cloud Apps:

- **Session controls**: Use app-enforced restrictions or Conditional Access App Control
- This enables real-time session monitoring, file download controls, and copy-paste restrictions

**4. Review and restrict app consent**

Navigate to **Microsoft Entra admin centre > Identity > Applications > Enterprise applications > Consent and permissions**. Set:

- **User consent for apps**: Do not allow user consent (require admin approval)
- Enable the [Admin consent workflow](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-admin-consent-workflow) so users can request access

---

## Pillar 5 — Infrastructure

**Principle**: Detect attacks and anomalies on infrastructure, automatically block and flag risky behaviour, and employ least privilege access for infrastructure management.

### Key Controls

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| Workload protection | [Microsoft Defender for Cloud — Workload protection plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | Assume breach — threat detection on servers, containers, databases |
| JIT VM access | [Defender for Cloud — Just-In-Time VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage) | Least privilege — time-limited port access for VMs |
| Azure Policy | [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) | Verify explicitly — enforce configuration baselines |
| Secure Score | [Microsoft Defender for Cloud — Secure Score](https://learn.microsoft.com/en-us/azure/defender-for-cloud/secure-score-security-controls) | Continuous posture assessment |

### Implementation Steps

**1. Enable Defender for Cloud and workload protection plans**

Navigate to **Azure portal > Microsoft Defender for Cloud > Environment settings**. Select your subscription. Enable the relevant Defender plans:

- **Defender for Servers** (Plan 2) — Threat detection, vulnerability assessment, JIT access
- **Defender for SQL** — Database threat detection
- **Defender for Storage** — Malware scanning, sensitive data discovery
- **Defender for Containers** — Kubernetes threat detection

**2. Enable Just-In-Time VM Access**

Navigate to **Defender for Cloud > Workload protections > Just-in-time VM access**. Enable JIT for all internet-facing VMs. Default JIT policy:

- RDP (3389): Maximum 3 hours, allowed source IPs restricted to corporate egress IPs
- SSH (22): Maximum 3 hours, allowed source IPs restricted

This eliminates standing open management ports — a significant attack surface reduction.

**3. Apply Azure Policy baseline**

Navigate to **Azure portal > Policy > Assignments > Assign policy**. Apply the **Azure Security Benchmark** initiative to your management group. Review compliance results and remediate non-compliant resources.

---

## Pillar 6 — Networks

**Principle**: Encrypt all communications, segment access by policy and workload, and employ real-time threat detection on network traffic.

### Key Controls

| Control | Service | Zero Trust Outcome |
|---------|---------|-------------------|
| Network segmentation | [Azure Virtual Networks — NSGs and ASGs](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) | Least privilege — restrict east-west traffic |
| Micro-segmentation | [Azure Firewall Premium](https://learn.microsoft.com/en-us/azure/firewall/premium-features) | Assume breach — prevent lateral movement |
| Private endpoints | [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) | Assume breach — services not exposed to internet |
| DDoS protection | [Azure DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview) | Resilience — absorb volumetric attacks |
| Network traffic analytics | [Azure Network Watcher — Traffic analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics) | Visibility — identify anomalous traffic patterns |

### Implementation Steps

**1. Move to private endpoints for PaaS services**

For Azure Storage, SQL Database, Key Vault, and other PaaS services, create [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) within your VNet. Disable public network access on each service after the private endpoint is operational.

**2. Implement network segmentation with NSGs**

Review and restrict Network Security Group rules:
- Remove any **Allow All Inbound** rules from the internet (source: Any)
- Apply least-privilege NSG rules: only permit traffic required for the workload
- Tag resources with Application Security Groups (ASGs) to apply workload-based rules

**3. Enable Azure Firewall for centralised egress control**

Deploy [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview) in your hub VNet. Route all spoke VNet egress through the firewall. Enable threat intelligence-based filtering and configure application rules to allow only known-good FQDNs.

---

## Related Resources

- [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview)
- [Microsoft Zero Trust Guidance Center](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview)
- [Zero Trust Assessment Tool](https://microsoft.github.io/zerotrustassessment/)
- [CISA Zero Trust Maturity Model v2.0](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model)
- [Zero Trust Maturity Reference](../reference/zero-trust-maturity.md)
- [Zero Trust Principles Explained](../explanation/zero-trust-principles.md)
