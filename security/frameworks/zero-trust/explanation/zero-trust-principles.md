---
title: "Zero Trust Principles — Verify Explicitly, Least Privilege, Assume Breach"
status: "published"
last_updated: "2026-03-09"
audience: "Security leaders, architects, and stakeholders understanding the Zero Trust model"
document_type: "explanation"
domain: "security"
---

# Zero Trust Principles — Verify Explicitly, Least Privilege, Assume Breach

---

## What Zero Trust Is

Zero Trust is a security strategy, not a product. It is built on the recognition that the traditional security model — "trust everything inside the network perimeter" — is fundamentally broken in a world of cloud services, remote workers, mobile devices, and sophisticated adversaries.

The term was coined by Forrester Research analyst John Kindervag in 2010. The core insight: trust is a vulnerability. When an attacker breaches the perimeter — through phishing, supply chain compromise, or stolen credentials — a perimeter-based model gives them unrestricted lateral movement across the network. Zero Trust removes implicit trust from the model entirely.

[Microsoft's Zero Trust model](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview) is built on three principles, each addressing a specific failure mode of the traditional model.

---

## Principle 1 — Verify Explicitly

**The failure it addresses**: Perimeter-based security trusts any traffic that originates from inside the network. Once an attacker is inside — via compromised credentials, a phishing-delivered payload, or a rogue insider — they are trusted by default.

**What it means**: Every access request must be authenticated and authorised based on all available data points:

| Signal | Example | Azure Control |
|--------|---------|---------------|
| Identity | Who is requesting access? | [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis) authentication |
| Location | Where is the request coming from? | [Conditional Access — Named Locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition) |
| Device health | Is the device managed and compliant? | [Intune compliance + Conditional Access](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started) |
| Sign-in risk | Are there anomalies suggesting compromise? | [Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection) |
| Application | What is the user accessing, and why? | [Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/what-is-defender-for-cloud-apps) |
| Data sensitivity | What classification is the requested data? | [Microsoft Purview sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) |

Verification is not a one-time event at sign-in. [Continuous Access Evaluation (CAE)](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation) enables Microsoft Entra ID to revoke access tokens in near real-time when conditions change — for example, when an account is disabled or a risk event is detected, even mid-session.

**Practical implication**: Every user, every device, every request — regardless of network origin — must prove the right to access. There is no "trusted zone" where authentication is skipped.

---

## Principle 2 — Use Least Privilege Access

**The failure it addresses**: Traditional environments grant broad, persistent access rights. A user account compromised by an attacker carries all the privileges that user was assigned — often far more than needed. An administrator account is catastrophic: full control over systems, unlimited lateral movement.

**What it means**: Access is granted only for:

- The **minimum permissions** needed for the specific task
- The **minimum duration** required (just-in-time, not standing access)
- The **minimum scope** (specific resources, not broad access)

### Just-In-Time Access

[Microsoft Entra Privileged Identity Management (PIM)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) implements JIT access for privileged roles:

- Administrators are **eligible** for roles, not permanently assigned
- Activation requires justification, MFA, and optionally approval
- Activation is time-limited (typically 1–8 hours)
- All activation events are logged and auditable

Without PIM, every privileged account has standing access — a dormant but permanent risk. With PIM, an attacker who steals an eligible account gets nothing — the role only exists during approved activation windows.

### Just-Enough-Access

[Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) and [Microsoft Entra RBAC](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/overview) enable fine-grained permission scoping:

- Assign roles at the resource level, not subscription level, wherever possible
- Use custom roles with only the specific permissions required (not built-in roles with excess permissions)
- Apply [Attribute-Based Access Control (ABAC)](https://learn.microsoft.com/en-us/azure/role-based-access-control/conditions-overview) for data-level access control (e.g., access to blobs with specific tags)

### Risk-Based Adaptive Policies

Least privilege is not static. [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) implements **adaptive access** — the level of access granted adapts to real-time risk signals:

- Low risk + compliant device → standard access
- Elevated risk → step-up MFA challenge
- High risk → block or require remediation (password reset, admin review)

**Practical implication**: Users should never have more access than they need right now. Privileged operations should require an explicit, logged, time-limited elevation — not a permanently privileged account.

---

## Principle 3 — Assume Breach

**The failure it addresses**: Traditional security is primarily preventive. If prevention fails — and at scale, it will — there is no plan for the attacker being inside the network. The assumption that the perimeter holds means lateral movement, persistence, and data exfiltration go undetected for weeks or months.

**What it means**: Design systems on the assumption that a breach has already occurred or will occur:

| Design Decision | Zero Trust Approach | Azure Service |
|-----------------|--------------------|-|
| Segment everything | Micro-segmentation limits blast radius — an attacker in one segment cannot reach others | [Azure Virtual Networks + NSGs](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview); [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview) |
| Encrypt everything | Data encrypted at rest and in transit — even if an attacker reaches data, they cannot read it | [Azure encryption at rest](https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-atrest); [TLS enforcement](https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-overview) |
| Monitor everything | All access, all traffic, all changes logged and analysed for anomalies | [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/overview); [Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender) |
| Automate response | Manual incident response is too slow; automated playbooks contain breaches faster | [Sentinel Playbooks](https://learn.microsoft.com/en-us/azure/sentinel/automate-responses-with-playbooks); [Defender XDR AIR](https://learn.microsoft.com/en-us/defender-xdr/m365d-autoir) |
| Test your defences | Assume your controls will be tested by real adversaries — validate they work | [Microsoft Defender XDR — Attack simulation training](https://learn.microsoft.com/en-us/defender-office-365/attack-simulation-training-get-started) |

### The Blast Radius Concept

"Blast radius" refers to the scope of damage an attacker can cause if they compromise a specific account, system, or segment. Zero Trust minimises blast radius at every layer:

- **Identity blast radius**: PIM ensures a compromised eligible account cannot self-escalate to a privileged role without approval
- **Network blast radius**: NSG rules and Azure Firewall ensure a compromised server cannot reach other segments
- **Data blast radius**: Sensitivity labels and encryption ensure a compromised storage account does not expose all data — only the subset the attacker can decrypt

**Practical implication**: The question is not "can we prevent all breaches?" (we cannot). The question is "if a breach occurs, what can the attacker reach, and how quickly can we detect and contain it?"

---

## Zero Trust Is Not a Product

A common misconception is that Zero Trust can be achieved by purchasing a specific product or platform. Zero Trust is a **strategy** that requires:

1. **Architecture decisions** — How systems are designed (segmentation, encryption, least privilege)
2. **Process changes** — How access is requested, approved, and reviewed
3. **Cultural change** — How security is treated as a shared responsibility across IT, business, and leadership

Technology platforms — including Microsoft Azure and Microsoft 365 — provide the controls that implement Zero Trust. But the controls are only as effective as the architecture and processes governing them.

The [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview) provides guidance for aligning business leaders, technology teams, and security practitioners in a structured Zero Trust adoption journey.

---

## Australian Regulatory Context

Zero Trust principles are increasingly reflected in Australian government security guidance:

- The [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) includes controls directly implementing Zero Trust principles — particularly in access control, network segmentation, and privileged access management
- The [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) strategies 5 (restrict administrative privileges) and 7 (multi-factor authentication) directly implement the "verify explicitly" and "least privilege" principles
- [PSPF](https://www.protectivesecurity.gov.au/) system security requirements increasingly reflect Zero Trust architectural expectations for government agencies handling classified information

The [CISA Zero Trust Maturity Model v2.0](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model), while US-focused, is explicitly designed to be applicable to any organisation and provides a useful maturity assessment structure alongside Australian frameworks.

---

## Related Resources

- [Microsoft Zero Trust Overview](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview)
- [Microsoft Zero Trust Adoption Framework](https://learn.microsoft.com/en-us/security/zero-trust/adopt/zero-trust-adoption-overview)
- [NIST SP 800-207 Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [CISA Zero Trust Maturity Model v2.0](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model)
- [Zero Trust Assessment Tool](https://microsoft.github.io/zerotrustassessment/)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [Zero Trust Maturity Reference](../reference/zero-trust-maturity.md)
- [Implement Zero Trust Pillars](../how-to/implement-zero-trust-pillars.md)
