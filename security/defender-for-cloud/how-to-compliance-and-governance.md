---
title: "Compliance and Governance in Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-08"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# Compliance and Governance in Microsoft Defender for Cloud

---

## Overview

This guide covers adding regulatory compliance standards to the Defender for Cloud [regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard), monitoring compliance posture against the ACSC Essential Eight and ISM, creating custom Azure Policy definitions, and configuring governance rules to drive remediation accountability.

**Prerequisites**: Defender for Cloud enabled with at least Foundational CSPM. Contributor or Security Admin role on the subscription or management group.

---

## The Regulatory Compliance Dashboard

The [regulatory compliance dashboard](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard) maps Defender for Cloud assessments (the same data that drives Secure Score) to the control requirements of compliance frameworks. Each control in a framework is assessed as:

- **Passed** — all associated Defender for Cloud assessments on all in-scope resources are healthy
- **Failed** — one or more associated assessments have unhealthy resources
- **Not applicable** — the control has no automated assessment (requires manual attestation)

The dashboard is read-only evidence of your current technical posture. It does not provide a formal compliance certification — that requires an independent assessment. However, it substantially reduces the evidence-gathering burden for audits by providing a continuously updated, resource-level view of control implementation.

---

## Step 1: Add the ACSC Essential Eight Standard

The [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) is available as a built-in regulatory compliance standard in Defender for Cloud.

1. In Defender for Cloud, select **Regulatory compliance**
2. Select **Manage compliance policies**
3. Select your subscription or management group
4. Under **Industry & regulatory standards**, locate **Australian Government ISM PROTECTED** or search for **Essential Eight**
5. Toggle the standard to **On**
6. Select **Save**

The dashboard will populate within a few minutes. Each Essential Eight strategy maps to one or more Defender for Cloud assessments:

| Essential Eight Strategy | Example Mapped Assessments |
|--------------------------|---------------------------|
| Application control | "Adaptive application controls should be enabled on VMs" |
| Patch applications | "System updates should be installed on VMs", "SQL databases should have vulnerability findings resolved" |
| Configure macro settings | "Windows machines should meet requirements for 'Administrative Templates - MS Security Guide'" |
| User application hardening | Browser security configuration assessments |
| Restrict administrative privileges | "MFA should be enabled for accounts with owner permissions", "There should be more than one owner assigned to subscriptions" |
| Patch operating systems | "System updates should be installed on VMs", "Vulnerabilities in security configuration should be remediated" |
| Multi-factor authentication | "MFA should be enabled on accounts with write permissions", "MFA should be enabled for accounts with read permissions" |
| Regular backups | "Azure Backup should be enabled for virtual machines" |

> **Maturity level note**: The built-in Essential Eight assessment in Defender for Cloud primarily reflects Maturity Level 1 and Maturity Level 2 technical controls that have Azure Policy equivalents. Maturity Level 3 controls and process controls require manual attestation in the compliance dashboard.

---

## Step 2: Add the Australian Government ISM Standard

The [Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) from the Australian Signals Directorate is available as a built-in compliance standard.

1. In **Regulatory compliance** > **Manage compliance policies**
2. Select your subscription
3. Under **Industry & regulatory standards**, locate and enable **Australian Government ISM PROTECTED**
4. Select **Save**

ISM controls map to Defender for Cloud assessments across the key security domains including access control, system monitoring, vulnerability management, and cryptography. Controls without automated assessments are flagged as **Not applicable** and can be manually attested.

---

## Step 3: Add Additional Compliance Standards

Other commonly required standards available as built-in options include:

| Standard | Relevant for |
|----------|-------------|
| PCI DSS 4.0 | Organisations processing payment card data |
| ISO 27001:2013 | International information security management |
| SOC 2 Type 2 | Service organisations requiring trust services criteria |
| NIST SP 800-53 Rev. 5 | US federal reference; used by some Australian agencies for comparison |
| CIS Microsoft Azure Foundations Benchmark | Azure-specific configuration hardening baseline |

To add any of these:
1. In **Manage compliance policies** for your subscription
2. Toggle the desired standard to **On**

---

## Step 4: Create Custom Compliance Initiatives

If a required framework is not available as a built-in standard, you can create a custom initiative using [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview).

1. In the Azure portal, navigate to **Azure Policy** > **Definitions** > **+ Initiative definition**
2. Set the **Initiative location** to your management group
3. Add a name and description referencing the specific framework version
4. Under **Policies**, add relevant built-in Azure Policy definitions for each control

For example, to create an initiative for an agency-specific control set:

```powershell
# Create a custom policy initiative for agency-specific controls
$policyDefinitions = @(
    # MFA for privileged accounts
    @{ policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/931e118d-50a1-4457-a5e4-78550e086c52' }
    # Log Analytics agent on VMs
    @{ policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/a4fe33eb-e377-4efb-ab31-119784d5be35' }
    # Vulnerability assessment on VMs
    @{ policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/501541f7-f7e7-4cd6-868c-4190fdad3ac9' }
)

New-AzPolicySetDefinition `
    -Name 'AgencySecurityBaseline' `
    -DisplayName 'Agency Security Control Baseline 2026' `
    -Description 'Custom initiative aligned to agency information security policy' `
    -PolicyDefinition ($policyDefinitions | ConvertTo-Json) `
    -ManagementGroupName 'mg-agency-root'
```

5. Once created, add the initiative to the Defender for Cloud dashboard:
   - In **Manage compliance policies** > **Custom initiatives** > **Add custom initiative**
   - Select your newly created initiative

---

## Step 5: Configure Governance Rules

[Governance rules](https://learn.microsoft.com/en-us/azure/defender-for-cloud/governance-rules) assign remediation ownership and due dates to security recommendations, enabling formal accountability tracking.

1. In Defender for Cloud, select **Environment settings** > your subscription
2. Select **Governance rules** > **Add rule**
3. Configure:
   - **Rule name** — a descriptive name (e.g., "High severity VMs — Security Team")
   - **Description** — the remediation expectation
   - **Priority** — lower number = higher priority when multiple rules match
   - **Conditions** — filter by resource type, severity, recommendation category
   - **Owner** — assign to an email address or Azure AD group
   - **Remediation timeframe** — number of days to remediate (recommended: 14 days for High, 30 days for Medium)
   - **Apply grace period** — if checked, items within the grace period are not counted as overdue
4. Select **Save**

Governance rules generate weekly email digests to assigned owners listing their outstanding recommendations, reducing the need for manual follow-up.

---

## Step 6: Export Compliance Data for Reporting

For agency reporting obligations, compliance data can be exported in several ways:

### Continuous Export to Log Analytics

[Continuous export](https://learn.microsoft.com/en-us/azure/defender-for-cloud/continuous-export) streams Defender for Cloud data to a Log Analytics workspace for querying and reporting.

1. In **Environment settings** > **Continuous export** > **Log Analytics workspace**
2. Enable export of **Regulatory compliance** data
3. Select your Log Analytics workspace (choose Australia East or Australia Southeast for data residency)
4. Select **Save**

Query compliance status in Log Analytics:

```kusto
SecurityRegulatoryCompliance
| where TimeGenerated > ago(30d)
| where ComplianceStandard contains "Essential Eight"
| summarise
    Total = dcount(ControlId),
    Passed = dcountif(ControlId, ComplianceState == "Passed"),
    Failed = dcountif(ControlId, ComplianceState == "Failed")
    by ComplianceStandard, bin(TimeGenerated, 1d)
| extend PassRate = round((Passed * 100.0) / Total, 1)
| order by TimeGenerated desc
```

### PDF and CSV Export

For ad-hoc reporting:
1. In the **Regulatory compliance** dashboard, select the framework you want to report on
2. Select **Download report** (PDF) or export individual control data as CSV

---

## Related Resources

- [Regulatory compliance dashboard — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard)
- [Add compliance standards — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/update-regulatory-compliance-packages)
- [Governance rules — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/governance-rules)
- [Continuous export — Microsoft Learn](https://learn.microsoft.com/en-us/azure/defender-for-cloud/continuous-export)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)
- [Privacy Act 1988 — Australian legislation](https://www.legislation.gov.au/Series/C2004A03712)
