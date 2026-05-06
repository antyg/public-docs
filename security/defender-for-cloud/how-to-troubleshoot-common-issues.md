---
title: "How to Troubleshoot Common Issues in Microsoft Defender for Cloud"
status: "published"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Cloud"
---

# How to Troubleshoot Common Issues in Microsoft Defender for Cloud

This guide covers diagnostic procedures and resolution steps for the most common issues encountered when operating Microsoft Defender for Cloud. It references the diagnostic scripts in [`scripts/troubleshooting/`](scripts/troubleshooting/README.md) and links to [Microsoft's official troubleshooting guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/troubleshooting-guide).

---

## Diagnostic Scripts

Two scripts in `scripts/troubleshooting/` support the procedures in this guide.

| Script | Purpose |
|--------|---------|
| [`Test-DefenderDiagnostics.ps1`](scripts/troubleshooting/Test-DefenderDiagnostics.ps1) | Comprehensive diagnostics: agent readiness, network connectivity, policy compliance, API authentication |
| [`Invoke-DefenderAPIWithRetry.ps1`](scripts/troubleshooting/Invoke-DefenderAPIWithRetry.ps1) | REST API calls with exponential backoff retry logic for rate-limiting and transient failures |

Run a quick connectivity and compliance check before investigating issues manually:

```powershell
.\scripts\troubleshooting\Test-DefenderDiagnostics.ps1 `
    -SubscriptionId "<subscription-id>" `
    -TestConnectivity `
    -TestPolicyCompliance
```

For full diagnostics with log collection and auto-remediation suggestions:

```powershell
.\scripts\troubleshooting\Test-DefenderDiagnostics.ps1 `
    -SubscriptionId "<subscription-id>" `
    -VirtualMachineName "<vm-name>" `
    -TestConnectivity `
    -TestPolicyCompliance `
    -TestAPIAuthentication `
    -CollectLogs `
    -OutputPath "C:\Diagnostics" `
    -Remediate
```

---

## Agent and Data Collection Issues

### Azure Monitor Agent Installation Failures

**Symptoms:** Agent fails to install, hangs, or times out. Errors appear in Windows Event Log or Linux syslog.

**Common root causes:**

| Category | Causes |
|----------|--------|
| Network connectivity | Outbound HTTPS (port 443) blocked to `*.ods.opinsights.azure.com`; proxy misconfiguration; DNS resolution failure |
| System prerequisites | Insufficient disk space (minimum 2 GB required); unsupported OS version; missing Visual C++ Redistributable |
| Permissions | Insufficient VM Contributor rights; managed identity not configured; local administrator access unavailable |
| Resource constraints | VM CPU/memory exhausted during installation; concurrent deployments overwhelming network bandwidth |

**Resolution steps:**

1. Run `Test-DefenderDiagnostics.ps1` with `-TestConnectivity` and `-Remediate` flags against the affected VM.
2. Verify outbound HTTPS access to `management.azure.com`, `login.microsoftonline.com`, `<workspace-id>.ods.opinsights.azure.com`, and `<workspace-id>.oms.opinsights.azure.com`.
3. Confirm the VM has at least 2 GB free disk space.
4. Verify the deployment identity has **Virtual Machine Contributor**, **Log Analytics Contributor**, or **Monitoring Contributor** role on the VM scope.
5. Check for conflicting agent extensions: remove legacy Microsoft Monitoring Agent (MMA) extensions before deploying Azure Monitor Agent (AMA).
6. For proxy environments, set `HTTPS_PROXY` on the VM and add Azure endpoints to the `NO_PROXY` bypass list.

After resolving, allow 10–15 minutes for the agent to initialise and begin data collection.

**Reference:** [Azure Monitor Agent installation troubleshooting](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-troubleshoot-windows-vm)

---

### Agent Connectivity — Agent Installed but Not Sending Data

**Symptoms:** Agent is installed but data does not appear in the Log Analytics workspace. Heartbeat gaps exceed 10 minutes.

**Diagnostic queries (Log Analytics):**

```kusto
// Identify VMs with heartbeat gaps
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(10m)
| project Computer, LastHeartbeat, MinutesAgo = datetime_diff('minute', now(), LastHeartbeat)
```

```kusto
// Check for data collection failures
Operation
| where TimeGenerated > ago(1d)
| where OperationCategory == "Data Collection"
| where OperationStatus == "Failed"
| summarize FailureCount = count() by OperationName, bin(TimeGenerated, 1h)
```

**Resolution steps:**

1. On Windows VMs, check the Azure Monitor Agent service: `Get-Service -Name AzureMonitorAgent`.
2. On Linux VMs, check: `systemctl status azuremonitoragent`.
3. Review agent logs:
   - Windows: `C:\WindowsAzure\Logs\Plugins\Microsoft.Azure.Monitor.AzureMonitorWindowsAgent\`
   - Linux: `/var/opt/microsoft/azuremonitoragent/log/mdsd.err`
4. Verify Data Collection Rules (DCRs) are associated with the VM in the Azure portal under **Monitor > Data Collection Rules**.
5. Check the Log Analytics workspace daily ingestion cap has not been reached (**Log Analytics workspace > Usage and estimated costs**).
6. Confirm workspace access: the VM's managed identity or the deploying service principal must have **Log Analytics Contributor** on the workspace.

---

### Log Analytics Workspace Data Ingestion Problems

**Symptoms:** Missing or delayed data; incomplete log ingestion; query timeouts.

**Diagnostic queries:**

```kusto
// Data ingestion volume over time
Usage
| where TimeGenerated > ago(7d)
| where IsBillable == true
| summarize TotalVolumeMB = sum(Quantity) by bin(TimeGenerated, 1h), DataType
| render timechart

// Data Collection Rule errors
DCRLogErrors
| where TimeGenerated > ago(1d)
| summarize ErrorCount = count() by ErrorCode, DCRName
| order by ErrorCount desc
```

**Resolution steps:**

1. Check the workspace daily ingestion cap and increase it if necessary.
2. Validate DCR configurations in the portal: ensure sources, destinations, and stream declarations are correct.
3. Confirm network routing — workspace endpoint must be reachable from all connected VMs.
4. For Private Link environments, verify the workspace is registered in the Azure Monitor Private Link Scope (AMPLS).

**Reference:** [Troubleshoot Log Analytics data collection](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-ingestion-time)

---

## Compliance Assessment Issues

### Policy Assignments Not Evaluating

**Symptoms:** Compliance shows "Not started" or resources remain non-compliant without detail. Policy evaluation does not update after remediation.

**Resolution steps:**

1. Confirm the policy assignment exists and has the correct scope:

   ```powershell
   Get-AzPolicyAssignment -Name "<assignment-name>"
   ```

2. Trigger an immediate compliance scan (scans normally run every 24 hours):

   ```powershell
   Start-AzPolicyComplianceScan -AsJob
   ```

   Allow 15–30 minutes for the scan to complete.

3. Check the managed identity on the policy assignment has a role assignment. If missing, assign **Contributor** to the identity:

   ```powershell
   $Assignment = Get-AzPolicyAssignment -Name "<assignment-name>"
   $PrincipalId = $Assignment.Identity.PrincipalId
   New-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionName "Contributor" `
       -Scope "/subscriptions/<subscription-id>"
   ```

4. Verify all required policy parameters are populated. Compare `Get-AzPolicyDefinition` parameter requirements against the assignment.

5. For initiatives, check each constituent policy definition for individual evaluation errors in **Microsoft Defender for Cloud > Regulatory compliance**.

**Reference:** [Troubleshoot Azure Policy compliance](https://learn.microsoft.com/en-us/azure/governance/policy/troubleshoot/general)

---

### Secure Score Not Updating

**Symptoms:** Secure score does not change after implementing recommended controls. Recommendations persist after remediation.

**Resolution steps:**

1. Allow up to 24 hours after remediation for the score to update — policy re-evaluation is not immediate.
2. Verify the remediation actually applied: use the **Fix** function in Defender for Cloud and confirm the resource configuration changed.
3. For custom recommendations, confirm the underlying policy definition logic correctly identifies compliant states.
4. Check whether the subscription has **Microsoft Defender for Cloud > Environment settings > Security policies** enabled for the relevant standard.

---

## Performance Issues

### Slow Dashboard or Workbook Loading

**Symptoms:** Dashboards take more than 30 seconds to load; workbook queries time out; intermittent slow response.

**Diagnostic query:**

```kusto
// Identify slow queries (>10 seconds) in last 24 hours
Operation
| where TimeGenerated > ago(1d)
| where OperationCategory == "Query"
| extend DurationMs = todouble(split(Detail, " ")[0])
| where DurationMs > 10000
| summarize
    SlowQueryCount = count(),
    AvgDurationSec = round(avg(DurationMs) / 1000, 2),
    MaxDurationSec = round(max(DurationMs) / 1000, 2)
```

**Resolution steps:**

1. Add time-range filters to all queries — avoid open-ended queries with no `TimeGenerated` filter.
2. Apply specific filters (subscription, resource group, resource type) early in the query pipeline before `summarize` or `join` operations.
3. Use `summarize` to reduce result sets before rendering.
4. Review the top data types by ingestion volume and consider reducing verbose sources:

   ```kusto
   Usage
   | where TimeGenerated > ago(7d)
   | where IsBillable == true
   | summarize TotalVolumeMB = sum(Quantity) by DataType
   | order by TotalVolumeMB desc
   | take 10
   ```

5. Archive data older than your retention requirement to reduce workspace scan volume.
6. Consider [materialized views](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/management/materialized-views/materialized-view-overview) for frequently-used aggregations.

---

## API and Automation Issues

### API Authentication Failures (HTTP 401)

**Symptoms:** Automation scripts return 401 Unauthorized; token expiration errors; service principal authentication failures.

**Resolution steps:**

1. Verify the service principal credentials are current — client secrets expire. Rotate via **Entra ID > App registrations > Certificates & secrets**.
2. Confirm the service principal has the required RBAC role on the target subscription (`Security Reader` minimum; `Security Admin` for write operations).
3. Verify the correct Azure environment endpoint is used. For standard Azure commercial tenants use `management.azure.com`. Do not use `.us` government endpoints unless operating in an Azure Government tenant.
4. Test authentication directly:

   ```powershell
   $SecurePassword = ConvertTo-SecureString "<client-secret>" -AsPlainText -Force
   $Credential = New-Object System.Management.Automation.PSCredential("<client-id>", $SecurePassword)
   Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant "<tenant-id>"
   ```

5. For managed identity scenarios, confirm the identity is enabled on the VM or App Service and has the required role assignments.

**Reference:** [Microsoft Defender for Cloud REST API authentication](https://learn.microsoft.com/en-us/rest/api/defenderforcloud/operation-groups)

---

### API Rate Limiting (HTTP 429)

**Symptoms:** Scripts return HTTP 429 Too Many Requests; automation pipelines fail intermittently under load.

**Resolution steps:**

1. Use `Invoke-DefenderAPIWithRetry.ps1` for all API calls — it implements exponential backoff and respects `Retry-After` headers:

   ```powershell
   .\scripts\troubleshooting\Invoke-DefenderAPIWithRetry.ps1 `
       -Uri "https://management.azure.com/subscriptions/<id>/providers/Microsoft.Security/assessments?api-version=2020-01-01" `
       -Method "GET" `
       -MaxRetries 10 `
       -EnableDetailedLogging
   ```

2. Introduce delays between bulk API calls — batch operations against large subscription counts in groups of 20–50 with a 1–2 second pause between batches.
3. Cache API responses where data freshness allows. Defender assessments update every 24 hours; avoid polling more frequently than necessary.
4. Spread automation across off-peak hours if running large-scale subscription sweeps.

**Reference:** [Azure REST API throttling guidance](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling)

---

## Multi-Cloud Connector Issues

### AWS Connector Not Showing Resources

**Symptoms:** AWS accounts connected but no resources appear; connector shows unhealthy status.

**Resolution steps:**

1. Verify the AWS IAM role trust policy grants `sts:AssumeRole` to the Defender for Cloud service principal (`arn:aws:iam::197857026523:root`).
2. Confirm the AWS IAM role has the following managed policies attached:
   - `arn:aws:iam::aws:policy/SecurityAudit`
   - `arn:aws:iam::aws:policy/job-function/ViewOnlyAccess`
3. Confirm AWS Config is enabled in the connected regions and a delivery channel and recorder are active.
4. For AWS Security Hub integration, ensure Security Hub is enabled and findings are being generated.
5. In the Azure portal, navigate to **Defender for Cloud > Environment settings**, select the AWS account, and use **Test connector** to identify the specific failing check.
6. Allow up to 24 hours after initial connector setup for resources to appear.

**Reference:** [Connect AWS accounts to Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/quickstart-onboard-aws)

---

### GCP Connector Issues

**Symptoms:** GCP projects connected but recommendations are missing or the connector reports an authentication error.

**Resolution steps:**

1. Confirm the GCP service account has the **Security Reviewer** (`roles/iam.securityReviewer`) role at the project or organisation level.
2. Verify Workload Identity Federation is correctly configured — the service account must trust Defender for Cloud's Azure managed identity.
3. Check that the required GCP APIs are enabled: `securitycenter.googleapis.com`, `cloudresourcemanager.googleapis.com`, `iam.googleapis.com`.
4. Use **Test connector** in **Defender for Cloud > Environment settings** to identify the specific failure.

**Reference:** [Connect GCP projects to Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/quickstart-onboard-gcp)

---

## Escalation

If the steps above do not resolve the issue, raise a support request with the following information:

| Item | How to collect |
|------|---------------|
| Diagnostic output | Run `Test-DefenderDiagnostics.ps1` with `-CollectLogs -OutputPath C:\Diagnostics` |
| Subscription and resource IDs | Azure portal > subscription overview |
| Error messages and HTTP status codes | Script verbose output or browser developer tools network tab |
| Time window of issue | Exact timestamps (UTC) when the issue first appeared and when it recurs |
| Recent changes | Policy assignments, network configuration changes, agent deployments |

Raise a support request via the [Azure portal support blade](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview) with severity based on business impact. Select **Microsoft Defender for Cloud** as the service.

For ACSC-registered organisations, security incidents involving a potential breach should also be reported to the [ACSC via cyber.gov.au](https://www.cyber.gov.au/report-and-recover/report).

---

## Related Resources

- [Microsoft Defender for Cloud troubleshooting guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/troubleshooting-guide)
- [Azure Monitor Agent troubleshooting](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-troubleshoot-windows-vm)
- [Azure Policy compliance troubleshooting](https://learn.microsoft.com/en-us/azure/governance/policy/troubleshoot/general)
- [Log Analytics data ingestion troubleshooting](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-ingestion-time)
- [Azure REST API throttling](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling)
- [ACSC — Report a cyber incident](https://www.cyber.gov.au/report-and-recover/report)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Diagnostic scripts — scripts/troubleshooting/README.md](scripts/troubleshooting/README.md)
