---
title: "How to Implement User Application Hardening"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Implement User Application Hardening

---

## Overview

This guide provides goal-oriented steps for hardening user-facing applications — primarily web browsers, PDF readers, and Microsoft Office — at each Essential Eight maturity level. User application hardening reduces the attack surface exposed by these applications by disabling unnecessary functionality, blocking malicious content, and isolating high-risk browsing activity.

For maturity level requirements and detailed specifications, see the [Essential Eight Maturity Model Reference](reference-maturity-model.md).

For authoritative requirements, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

This guide assumes you have:

- A supported, centrally managed browser deployed to all endpoints (Microsoft Edge on Chromium is the current ACSC-aligned recommendation; Internet Explorer 11 is unsupported and must be retired)
- A mechanism for deploying and enforcing configuration policies — for example, Microsoft Intune configuration profiles, Group Policy Objects (GPO), or an equivalent endpoint management platform
- Completed an inventory of user-facing applications, including PDF readers and Microsoft Office versions

For cross-control dependencies and sequencing guidance, see [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md).

---

## Maturity Level 1

**Objective**: Block common web-based threats and disable legacy, high-risk application functionality across all endpoints.

### Step 1 — Standardise the Browser

1. Confirm all endpoints are running a supported browser version. Retire or block Internet Explorer 11 and any legacy browser versions through your endpoint management platform.
2. Enforce automatic updates for the browser so that security patches are applied promptly.
3. Prevent users from installing unsanctioned alternative browsers, or ensure any permitted browser receives equivalent hardening configuration.

### Step 2 — Configure Browser Security Settings

Deploy a browser policy (via Intune configuration profile, GPO, or equivalent) that enforces the following:

- Block web advertisements — use a centrally managed content blocker or browser policy setting. Managed deployment of a browser extension such as uBlock Origin Lite is a common approach; configure it to prevent user modification.
- Enable enhanced tracking prevention at the "Strict" or equivalent level.
- Disable legacy plugins: Flash, Java applets, and Silverlight must be disabled. These components are unsupported and represent significant exploit vectors.
- Enforce HTTPS — configure the browser to upgrade insecure HTTP connections to HTTPS where possible and warn users on non-HTTPS sites.
- Restrict browser extension installation to a managed allowlist. Prevent users from installing unapproved extensions.

### Step 3 — Harden the PDF Reader

1. Disable JavaScript execution within PDF documents. In Adobe Acrobat Reader, this is controlled under Preferences > JavaScript — uncheck "Enable Acrobat JavaScript". Deploy this setting centrally via registry policy or Intune.
2. Disable the ability for PDF documents to launch external applications or execute embedded content without explicit user confirmation.

### Step 4 — Harden Microsoft Office

1. Enable Protected View for files originating from the internet, from email attachments, and from potentially unsafe locations. This setting is available via Group Policy or Intune (Office ADMX templates).
2. Configure the Office Trust Centre to block macros from internet-sourced files. This is distinct from the macro settings control (Essential Eight Strategy 3) but reinforces it.
3. Disable automatic download of external images in email clients (for example, Outlook). This prevents beacon-style tracking and reduces the risk of drive-by content loading.

### Verification — ML1

Collect the following evidence to confirm ML1 compliance:

- Screenshot or export of the enforced browser policy showing advertisement blocking, tracking prevention, and plugin settings
- Extension deployment report showing the content blocker is force-installed and locked on all endpoints
- Registry or configuration export confirming JavaScript is disabled in the PDF reader
- GPO/Intune configuration report confirming Protected View is enabled in Office
- Browser version compliance report showing all endpoints are on supported versions

**Typical time to achieve ML1:** 4–6 weeks from a baseline of no controls.

---

## Maturity Level 2

**Objective**: Strengthen browser security posture against more sophisticated threats, including DNS-based attacks and high-risk browsing contexts.

ML2 builds on all ML1 controls, which must remain fully implemented.

### Step 5 — Enable DNS over HTTPS

Configure the browser to use DNS over HTTPS (DoH) for DNS resolution. This prevents network-level interception of DNS queries and provides an additional layer of protection against DNS-based threats.

- In Microsoft Edge, deploy the `DnsOverHttpsMode` policy set to `"secure"` or `"automatic"` and configure a trusted DoH resolver via `DnsOverHttpsTemplates`.
- Alternatively, enforce DoH at the operating system level or via your network stack if you require consistent coverage across all applications, not just the browser.

### Step 6 — Implement Browser Isolation for Risky Sites

Introduce browser isolation or web content filtering to reduce the risk from high-risk browsing destinations:

- Use Microsoft Defender SmartScreen (enabled via browser policy) to block access to known malicious URLs and downloads.
- Consider deploying Attack Surface Reduction (ASR) rules via Microsoft Defender for Endpoint or Intune to block untrusted and unsigned executable content running from the browser download path.
- Evaluate web content filtering solutions that categorise and restrict access to high-risk site categories (e.g., newly registered domains, uncategorised sites, known malware distribution points).

### Step 7 — Expand Hardening to Additional Application Surfaces

Review and extend ML1 controls to cover:

- Any additional PDF readers or document viewers in use across the organisation
- Any additional browsers permitted on endpoints (ensure equivalent policy coverage)
- Office applications beyond the standard suite, such as Project or Visio, if present

### Verification — ML2

In addition to ML1 evidence, collect:

- Browser policy export confirming DoH is configured
- SmartScreen policy configuration report
- ASR rule deployment report (where applicable)
- Web content filtering policy showing blocked categories and any exception register

**Typical time to achieve ML2 after ML1:** 6–12 months.

---

## Maturity Level 3

**Objective**: Apply comprehensive isolation and filtering to maximise defence against targeted and advanced persistent threats.

ML3 builds on all ML1 and ML2 controls, which must remain fully implemented.

### Step 8 — Deploy Browser Isolation for Internet Browsing

At ML3, the ACSC requires browser isolation for all internet-facing browsing. This separates browser execution from the endpoint, ensuring that web-based exploit code cannot reach the underlying operating system.

Options include:

- **Remote browser isolation (RBI):** The browser renders content on a remote server; only a visual stream is delivered to the endpoint. Solutions include Microsoft Defender for Cloud Apps integration with Conditional Access App Control, or dedicated RBI products.
- **Application Guard for Microsoft Edge:** Deploys untrusted web sessions in a hardware-isolated container (Hyper-V). Configure via Intune or GPO using the Windows Defender Application Guard ADMX templates. This is effective for managed Windows 10/11 endpoints.

Deploy the chosen solution to all endpoints and verify that internet browsing sessions are isolated by default. Document exceptions (e.g., intranet sites excluded from isolation) in a formal exception register.

### Step 9 — Enforce Comprehensive Web Content Filtering

Implement web content filtering at the network or endpoint level that:

- Blocks access to known malicious categories unconditionally
- Restricts access to uncategorised and newly registered domains unless explicitly approved
- Logs all blocked and allowed web access for audit purposes

Use Microsoft Defender for Endpoint's web content filtering capability, or an equivalent network proxy or DNS filtering solution. Ensure filtering applies to all endpoints regardless of whether they are on-network or remote.

### Step 10 — Validate Full Coverage

At ML3 the controls must apply to all systems without exception. Conduct a coverage audit:

1. Generate a report from your endpoint management platform listing all managed devices.
2. Cross-reference against browser policy compliance, Application Guard deployment status, and web content filtering enrolment.
3. Identify and remediate any gaps. No endpoint should be excluded without a formal, time-limited, risk-accepted exception.

### Verification — ML3

In addition to ML1 and ML2 evidence, collect:

- Application Guard or RBI deployment report confirming all endpoints are covered
- Web content filtering policy configuration and coverage report
- Access logs demonstrating filtering is active and logging
- Exception register for any approved exclusions

**Typical time to achieve ML3 after ML2:** 6–12 months.

---

## Common Challenges

| Challenge | Recommended approach |
|---|---|
| Websites break when advertisements are blocked | Establish a formal exception process. Document approved exceptions, review quarterly, and aim to reduce over time. Do not disable ad blocking globally. |
| Users resist browser restrictions | Communicate the security rationale. Frame controls as protecting users from malicious content, not restricting productivity. Provide a support channel for legitimate site issues. |
| Legacy internal sites require Internet Explorer or legacy plugins | Prioritise decommissioning or modernising legacy sites. Where unavoidable, use IE Mode in Microsoft Edge with a restricted site list rather than maintaining a standalone IE11 installation. |
| Application Guard breaks access to internal sites | Configure an explicit exclusion list of trusted intranet URLs that bypass isolation. Keep this list minimal and subject to change management review. |
| PDF JavaScript is required by a business-critical form | Assess whether the form can be replaced or the workflow redesigned. Where genuinely unavoidable, implement a compensating control (e.g., open in a sandboxed environment) and document the exception. |

---

## Evidence for Compliance Audits

When preparing for an Essential Eight assessment, collect and organise the following artefacts:

- Browser hardening policy export (GPO result or Intune configuration profile) showing all required settings
- Configuration evidence that advertisement blocking and tracking prevention are enforced and cannot be disabled by users
- Browser extension deployment report confirming the content blocker is present and locked on all endpoints
- Browser version compliance report (all endpoints on supported versions)
- PDF reader registry or policy export confirming JavaScript is disabled
- Office Protected View configuration report
- (ML2+) DNS over HTTPS policy configuration
- (ML2+) SmartScreen and ASR rule deployment report
- (ML3) Application Guard or RBI deployment and coverage report
- (ML3) Web content filtering policy and access log samples
- Exception register for any approved deviations from policy

---

## Related Resources

### ACSC Authoritative Guidance

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Essential Eight — User Application Hardening](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-explained/user-application-hardening)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)

### Documentation Library

- [Essential Eight Maturity Model Reference](reference-maturity-model.md)
- [Essential Eight Glossary](reference-glossary.md)
- [Essential Eight Cross-Reference Matrix](reference-cross-reference-matrix.md)
- [How to Implement Essential Eight Controls](how-to-implement-e8-controls.md)
