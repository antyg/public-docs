# Reporting & Analytics — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Partial

---

## Executive Summary

SCCM's **SQL Server Reporting Services (SSRS)** integration with 400+ built-in reports and **Report Builder** for custom report authoring represents a mature, low-code reporting framework. Intune provides modern cloud-based reporting through built-in reports, **Log Analytics**, **Data Warehouse**, and **Microsoft Graph API**, but lacks the custom report authoring experience of SSRS Report Builder. **CMPivot's** real-time multi-device query capability has limited Intune equivalents (single-device queries only via Device Query; historical data via Log Analytics with ingestion lag). Organizations heavily reliant on custom SSRS reports must invest in **Power BI** skills or engage partners for report development. The **Intune Data Warehouse infrastructure was updated in mid-February 2026**, resetting historical data to 30 days and requiring transition from the deprecated beta Power BI connector to the OData feed method.

---

## Feature Parity Matrix

| SCCM Feature                                    | Intune Equivalent                            | Parity Rating   | Licensing                                                       | Notes                                                                                                         |
| ----------------------------------------------- | -------------------------------------------- | --------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **SSRS Integration & Reporting Services Point** | Built-in Intune Reports + Log Analytics      | Partial         | Intune Plan 1 (Log Analytics requires Azure subscription)       | SSRS provides on-premises SQL-based reporting; Intune cloud-native                                            |
| **400+ Built-in Reports**                       | ~50+ Built-in Reports                        | Partial         | Intune Plan 1                                                   | SCCM has 400+ reports in 50+ folders; Intune has fewer built-in reports but covers core scenarios             |
| **Report Builder (Custom Reports)**             | Power BI + Data Warehouse / Graph API        | Significant Gap | Intune Plan 1 (DWH free); Power BI Pro/Premium for distribution | No GUI report authoring equivalent to Report Builder; requires Power BI skills                                |
| **Report Subscriptions (Scheduled Email)**      | Power BI Subscriptions / Logic Apps          | Partial         | Power BI Pro ($10/user/month) or Logic Apps (Azure)             | SSRS subscriptions are native; Intune requires Power BI Pro or custom automation                              |
| **CMPivot (Real-Time Multi-Device Queries)**    | Device Query (Single Device) + Log Analytics | Significant Gap | Intune Plan 1 (Log Analytics requires Azure)                    | CMPivot queries collections in real-time; Intune queries single devices or uses Log Analytics (not real-time) |
| **CMPivot Kusto Query Language (KQL)**          | Log Analytics KQL Queries                    | Partial         | Azure Log Analytics (pay-per-GB ingestion)                      | CMPivot uses KQL subset; Log Analytics uses full KQL but requires data ingestion setup                        |
| **Status Message System**                       | Intune Audit Logs + Monitor Node             | Near Parity     | Intune Plan 1                                                   | SCCM status messages for component health; Intune uses Entra ID audit logs and Monitor blade                  |
| **Power BI Integration**                        | Native Power BI + Data Warehouse             | Full Parity     | Power BI Pro/Premium                                            | SCCM 2002+ integrates Power BI Report Server; Intune uses cloud Power BI with Data Warehouse OData feed       |
| **Data Warehouse**                              | Intune Data Warehouse                        | Full Parity     | Intune Plan 1 (DWH free; Power BI separate)                     | Both provide OData feeds for external reporting tools; Intune DWH updated February 2026                       |
| **SQL Direct Access**                           | Graph API (RESTful)                          | Partial         | Intune Plan 1                                                   | SCCM: Direct SQL queries; Intune: RESTful API with OAuth 2.0 (modern but requires development)                |
| **Real-Time Collection Queries**                | MDE Advanced Hunting (if MDE P2)             | Partial         | MDE Plan 2 ($5.20/user/month or M365 E5)                        | CMPivot instant queries; MDE advanced hunting provides similar capability for security scenarios              |
| **Custom Query Creation**                       | KQL in Log Analytics / MDE                   | Partial         | Azure Log Analytics or MDE Plan 2                               | SCCM: WQL queries in console; Intune: KQL in Log Analytics workspace or MDE portal                            |

---

## Key Findings

### 1. Full Parity Areas

#### 1.1 Data Warehouse and External Reporting

**SCCM Capability**: Configuration Manager database (SQL Server) is directly accessible for custom queries and external reporting tools:

- **Direct SQL queries** against CM database (read-only recommended)
- **SSRS Report Builder** for custom reports (drag-drop GUI)
- **Third-party tools** (Tableau, Qlik, Crystal Reports) connect via SQL Server driver
- **Power BI Report Server integration** (SCCM 2002+): Publish Power BI reports to on-premises Report Server, visible in ConfigMgr console
- **Data exports** via SQL queries or SSRS subscriptions (CSV, Excel, PDF)
- **Historical data**: Unlimited retention (depends on SQL Server storage capacity and maintenance policies)

**Intune Capability**: Intune **Data Warehouse** provides structured OData v4 feed for external reporting:

**Access Methods**:

1. **OData Feed URL**: Obtain from Intune admin center (Reports > Intune Data warehouse > Custom Feed URL)
2. **Power BI OData Connector**: Connect Power BI Desktop to OData feed (direct import)
3. **RESTful API calls**: Access via HTTP GET with Azure AD OAuth 2.0 token
4. **Excel Power Query**: Import OData feed into Excel for analysis

**Data Model** (~50 entities):

- **Devices**: Device inventory (hardware, OS, enrollment details)
- **Users**: User accounts and assignments
- **Applications**: App inventory, installation status, assignment details
- **Compliance**: Compliance policy results, settings compliance
- **Configurations**: Configuration profile deployment status
- **Enrollments**: Enrollment method, date, platform
- **Policies**: Policy assignments and effectiveness
- **Updates**: Windows Update deployment and compliance

**Data Retention**: **30 days** (as of February 2026 infrastructure update; previously unlimited historical data, reset during update)

**February 2026 Infrastructure Update**:

- **Historical data reset**: All data prior to mid-February 2026 purged; only 30-day retention going forward
- **Surrogate keys regenerated**: Primary keys reset (breaks existing Power BI reports using cached keys)
- **Beta connector deprecated**: Intune Data Warehouse (beta) Power BI connector no longer supported
- **OData feed mandatory**: All integrations must use OData feed URL from admin center
- **Licensing definitions changed**: Some entity schema updates

**Migration Actions** (for existing Data Warehouse users):

1. **Back up historical data**: Export critical historical reports before update (already occurred mid-February 2026)
2. **Update Power BI reports**: Reconnect Power BI to new OData feed URL, refresh data model
3. **Verify surrogate key references**: Update any reports using device/user IDs (keys regenerated)
4. **Remove beta connector**: Delete beta connector from Power BI reports, replace with OData feed

**Parity Assessment**: **Full Parity**. Both provide data warehouse access for external reporting tools. Intune Data Warehouse is cloud-native OData feed vs. SCCM's SQL Server database. The 30-day retention limit is a constraint for long-term trend analysis but adequate for operational reporting.

**Trade-offs**:

| Aspect                         | SCCM                               | Intune                           |
| ------------------------------ | ---------------------------------- | -------------------------------- |
| Access method                  | SQL queries (T-SQL)                | OData feed (HTTP REST)           |
| Historical retention           | Unlimited (SQL storage dependent)  | 30 days (as of Feb 2026)         |
| Third-party tool compatibility | Native SQL drivers (universal)     | OData v4 (modern tools support)  |
| Authentication                 | Windows authentication or SQL auth | Azure AD OAuth 2.0               |
| Infrastructure                 | On-premises SQL Server             | Cloud service (zero maintenance) |

**Migration Considerations**:

- **Long-term trending**: Organizations requiring >30-day historical data must export to external system (Azure SQL Database, Synapse Analytics, or on-premises data lake)
- **Power BI reports**: Recreate SCCM Power BI reports using Intune Data Warehouse OData feed
- **Community templates**: Use community-shared Power BI templates (GitHub: microsoft/Intune-Data-Warehouse)

**Sources**:

- [Intune Data Warehouse API](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-nav-intune-data-warehouse)
- [Connect to the Data Warehouse With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-get-a-link-powerbi)
- [Create an Intune Report From the OData Feed With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-create-with-odata)
- [Plan for Change: Update to Intune Data Warehouse infrastructure - M365 Admin](https://m365admin.handsontek.net/plan-change-update-intune-data-warehouse-infrastructure/)
- [Intune Data Warehouse Change Log](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-changelog)

#### 1.2 Power BI Integration

**SCCM Capability**: Configuration Manager 2002+ integrates **Power BI Report Server** (on-premises):

- **Power BI Report Server** installed on SCCM site server or separate server
- **Publish Power BI Desktop reports** (.pbix files) to Report Server
- **View in ConfigMgr console**: Reports > Power BI Reports node shows published reports
- **Single sign-on**: Windows authentication (same credentials as ConfigMgr console)
- **Data source**: Connect to ConfigMgr database (SQL Server) or external sources

**Intune Capability**: Intune integrates with **cloud Power BI Service**:

- **Power BI Desktop**: Connect to Intune Data Warehouse OData feed or Microsoft Graph API
- **Create custom reports**: Build visualizations (charts, tables, maps, dashboards)
- **Publish to Power BI Service**: Upload .pbix to cloud Power BI workspace
- **Share with organization**: Publish to workspace, share links, or embed in SharePoint/Teams
- **Automatic refresh**: Schedule daily data refresh from Intune Data Warehouse
- **Mobile access**: View reports in Power BI mobile app (iOS, Android)

**Power BI Licensing** (for Intune integration):

- **Power BI Desktop**: Free (create reports on local machine)
- **Power BI Service (Free)**: View shared reports in workspace (limited)
- **Power BI Pro**: $10/user/month (required to publish reports, share with others, schedule refreshes, create subscriptions)
- **Power BI Premium**: $20/user/month or capacity-based pricing (large-scale distribution, paginated reports, advanced features)

**Parity Assessment**: **Full Parity**. Both SCCM and Intune integrate with Power BI. SCCM uses on-premises Report Server (included with SQL Server licensing), Intune uses cloud Power BI Service (requires Power BI Pro for sharing).

**Trade-offs**:

| Aspect            | SCCM (Report Server)                | Intune (Power BI Service)                |
| ----------------- | ----------------------------------- | ---------------------------------------- |
| Hosting           | On-premises                         | Cloud (SaaS)                             |
| Licensing         | Included with SQL Server            | Power BI Pro required ($10/user/month)   |
| Data source       | Direct SQL access                   | OData feed or Graph API                  |
| Mobile access     | Limited (browser only)              | Native mobile apps (iOS, Android)        |
| Automatic refresh | Manual refresh or scheduled SQL job | Scheduled cloud refresh (daily, hourly)  |
| Collaboration     | Limited (file share or email)       | Workspaces, Teams integration, embedding |

**Migration Considerations**:

- **Export SCCM Power BI reports**: Download .pbix files from Report Server
- **Reconnect data sources**: Replace SQL Server connection with Intune Data Warehouse OData feed
- **Publish to cloud**: Upload to Power BI Service workspace
- **License users**: Purchase Power BI Pro licenses for report authors and consumers
- **Schedule refresh**: Configure automatic daily refresh from Intune Data Warehouse

**Community Resources**:

- [Intune Data Warehouse Power BI Template](https://github.com/microsoft/Intune-Data-Warehouse/blob/master/Samples/PowerBI/Intune%20Data%20Warehouse%20Report%20Template.pbit)
- [How to Leverage Intune Data and Write a Basic Power BI Report - AskGarth](https://askgarth.com/blog/how-to-leverage-intune-data-and-write-a-basic-power-bi-report/)
- [Build PowerBi Dashboard based on Intune Data Warehouse - Jannik Reinhard](https://jannikreinhard.com/2022/07/10/build-powerbi-dashboard-based-on-intune-data-warehouse/)
- [Intune and Power BI Deep Dive - Part 1 - Deployment Share](https://deploymentshare.com/articles/bp-1-pbi-intune/)

**Sources**:

- [Introduction to reporting - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/introduction-to-reporting)
- [Power BI Report Server integration with Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/powerbi-report-server)

#### 1.3 Status Monitoring and Audit Logs

**SCCM Capability**: Configuration Manager **Status Message System** provides component health monitoring:

- **Status messages**: All SCCM components (site server, distribution points, clients) generate status messages (informational, warning, error)
- **Monitoring > System Status**: View site status, component status, site database replication
- **Status Message Queries**: Pre-built queries (e.g., "All messages for a specific component in the last hour")
- **Custom queries**: Create WQL-based status message queries
- **Alerts**: Configure alerts for critical status messages (email notification)

**Use Cases**:

- Troubleshooting site server component failures
- Monitoring distribution point health
- Tracking client agent errors
- Auditing administrative actions (policy changes, software deployments)

**Intune Capability**: Intune uses **Audit Logs** and **Monitor** blade for operational visibility:

**Audit Logs** (Tenant administration > Audit logs):

- **All administrative actions logged**: Policy creation/modification, app deployments, device wipes, configuration changes
- **Fields captured**: Date/time, user (UPN), activity (e.g., "Create DeviceCompliancePolicy"), category (DeviceConfiguration, DeviceCompliance, Application, etc.)
- **Filter options**: Date range, activity, category, user, status (success/failure)
- **Export to CSV**: Download audit log for offline analysis
- **Retention**: 30 days (visible in portal); extended retention via Azure Monitor integration

**Monitor Blade** (Home > Intune > Monitor):

- **Device actions**: Track remote action status (wipe, retire, sync, restart)
- **Device enrollment**: Monitor enrollment success/failure rates
- **Noncompliant devices**: Count of devices failing compliance policies
- **Policy assignment failures**: Policies that failed to apply
- **App installation failures**: Win32 app deployment errors
- **Certificate connector health**: Certificate deployment status
- **Windows Autopilot deployment profiles**: Autopilot OOBE success rates

**Azure Monitor Integration** (for extended audit retention):

- Configure diagnostic settings to send Intune audit logs to **Azure Log Analytics** workspace
- Retention: 30 days to 2 years (configurable; ingestion costs apply ~$2.30/GB)
- KQL queries for advanced analysis (e.g., "Show all device wipes performed by non-admin users in last 90 days")
- Azure Monitor Workbooks for operational dashboards

**Parity Assessment**: **Near Parity**. Intune Audit Logs and Monitor blade provide equivalent operational visibility to SCCM status messages. Azure Monitor integration extends capabilities beyond SCCM.

**Migration Considerations**:

- **Status message query inventory**: Document SCCM status message queries and alerts in use
- **Recreate in Log Analytics**: Use KQL queries in Log Analytics workspace for equivalent monitoring
- **Alert migration**: Transition SCCM alerts to Azure Monitor alerts (email, SMS, webhook notifications)

**Sources**:

- [Auditing changes and events in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/monitor-audit-logs)
- [Azure Monitor integration for reporting](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)

---

### 2. Partial Parity / Gaps

#### 2.1 Built-In Reports

**SCCM Capability**: Configuration Manager includes **400+ built-in reports** via SSRS, organized in 50+ report folders:

**Major Report Categories**:

- **Hardware inventory** (50+ reports): Computers by processor, RAM, disk capacity, BIOS version, manufacturer, model
- **Software inventory** (30+ reports): Files by name, version, publisher; file count trends
- **Software updates** (60+ reports): Update compliance, deployment status, superseded updates, missing updates
- **Application deployment** (40+ reports): Deployment success rates, error details, installation trends
- **Compliance settings** (30+ reports): Baseline compliance, configuration item status, compliance trends
- **Asset Intelligence** (20+ reports): Software categories, license compliance, software families
- **Endpoint Protection** (15+ reports): Malware detections, antivirus status, threat summary
- **Client status** (10+ reports): Client health, heartbeat discovery, online/offline status
- **OS deployment** (25+ reports): Task sequence success rates, deployment errors, image deployment history
- **Site and component status** (20+ reports): Site server health, distribution point status, replication status
- **User and device affinity** (10+ reports): Primary users, usage patterns
- **Power management** (15+ reports): Energy consumption, power plan compliance, power capabilities

**Report Features**:

- **Parameter prompts**: User input for dynamic filtering (e.g., collection name, date range, computer name)
- **Drill-through**: Click device name in summary report to open device-specific detail report
- **Linked reports**: Source reports link to destination reports with parameter passing
- **Export formats**: Excel, PDF, Word, CSV, XML, TIFF
- **Subscriptions**: Schedule and email reports (daily, weekly, monthly)
- **20 language support**: Reports display in local OS language

**Intune Capability**: Intune provides **~50+ built-in reports** across workloads:

**Report Categories** (Reports > Microsoft Intune):

- **Device compliance** (10+ reports): Compliance status, noncompliant devices, policy effectiveness
- **Device configuration** (5+ reports): Configuration profile deployment status, error details
- **Device enrollment** (5+ reports): Enrollment method breakdown, enrollment failures, platform distribution
- **Windows Updates** (10+ reports): Update compliance, deployment status, expedited updates, WUfB reports
- **Application deployment** (10+ reports): App installation status, discovered apps, app protection policies
- **Endpoint security** (10+ reports): Antivirus status, malware detections, firewall status, encryption status
- **Conditional Access** (5+ reports): Devices blocked by Conditional Access, policy effectiveness
- **Autopilot** (5+ reports): Deployment profile status, OOBE success rates, device registration

**Report Types**:

- **Organizational reports**: Aggregate metrics with filtering, searching, sorting, pagination
- **Operational reports**: Real-time data for troubleshooting (device-level details)
- **Historical reports**: Trends over time (e.g., device compliance trends over 30 days)
- **Export options**: CSV export or copy to clipboard

**Parity Assessment**: **Partial**. Intune built-in reports cover core operational scenarios but lack the breadth and depth of SCCM's 400+ reports. Organizations dependent on specific SCCM reports must use custom reporting (Power BI, Graph API, Log Analytics).

**Gap Impact Examples**:

| SCCM Report Category              | Intune Coverage                                                                 |
| --------------------------------- | ------------------------------------------------------------------------------- |
| Hardware inventory detail reports | Limited (basic device properties only; use Data Warehouse for custom)           |
| Software metering reports         | No equivalent (no usage tracking in Intune)                                     |
| Asset Intelligence reports        | No equivalent (no software categorization)                                      |
| Power management reports          | No equivalent (no power management in Intune)                                   |
| Task sequence deployment reports  | Partial (Autopilot reports cover deployment; no detailed task sequence logging) |
| Client health detailed reports    | Partial (device compliance reports; no granular client health metrics)          |

**Workarounds**:

1. **Custom Power BI reports**: Recreate SCCM reports using Intune Data Warehouse + Power BI
2. **Graph API scripts**: Use PowerShell with Graph API for simple custom reports (export to CSV)
3. **Accept Intune built-in reports**: For most operational scenarios, built-in reports adequate
4. **Community templates**: Leverage community-shared Power BI templates

**Sources**:

- [Introduction to reporting - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/introduction-to-reporting)
- [Microsoft Intune Reports](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)

#### 2.2 Report Subscriptions and Automation

**SCCM Capability**: **SSRS native subscriptions** allow scheduled report delivery:

- **Schedule options**: Daily, weekly, monthly, on-report-refresh, custom (Cron-like)
- **Delivery methods**:
  - **Email**: Report as attachment (PDF, Excel, CSV, Word) or link to report
  - **File share**: Save report to network location (archival)
- **Parameter pre-population**: "All devices in Marketing collection" runs automatically (no user input)
- **Subscription management**: SSRS web portal or ConfigMgr console
- **Batch processing**: Generate reports overnight, email to stakeholders before business hours

**Use Cases**:

- Daily compliance reports to security team (email PDF at 6 AM)
- Weekly software update status to change management board
- Monthly hardware inventory reports to IT director
- Quarterly license compliance reports to finance

**Intune Capability**: Report subscriptions require **external automation** (no native subscription feature):

**Option 1: Power BI Subscriptions** (if using Power BI for custom reports):

- **Requires Power BI Pro license** ($10/user/month)
- **Schedule**: Daily, weekly, hourly (not monthly directly; use weekly on specific day)
- **Email delivery**: Snapshot of report as of scheduled time (embedded PNG in email)
- **Limitation**: Only for reports published to Power BI Service (not Intune built-in reports)
- **Configuration**: Open report in Power BI Service > Subscribe > Set schedule and recipients

**Option 2: Azure Logic Apps** (for Data Warehouse/Graph API automation):

- **Schedule-triggered workflow**: Recurrence trigger (daily, weekly, hourly, cron)
- **Query Intune Data**: HTTP action to query Data Warehouse OData feed or Graph API
- **Format results**: Parse JSON, create HTML table or CSV
- **Send email**: Office 365 Outlook connector (Send Email action)
- **Cost**: Azure consumption pricing (~$0.01 per workflow run; minimal for daily reports)

**Example Logic App Workflow**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```
1. Recurrence trigger: Daily at 6 AM
2. HTTP action: GET https://graph.microsoft.com/beta/deviceManagement/managedDevices?$filter=complianceState eq 'noncompliant'
3. Parse JSON action: Extract device names, users, noncompliance reasons
4. Create HTML table action: Format as HTML table
5. Send email (Office 365): Email to security@company.com with HTML table in body
```

**Option 3: PowerShell Scheduled Tasks** (on-premises or Azure Automation):

- **PowerShell script** with Graph API SDK: Query Intune data, generate report, send email
- **Windows Scheduled Task** (on-premises server) or **Azure Automation runbook** (cloud)
- **Example script**:

  > **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

  ```powershell
  Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
  $NonCompliantDevices = Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'noncompliant'"
  $HtmlReport = $NonCompliantDevices | ConvertTo-Html -Property DeviceName, UserPrincipalName, ComplianceState
  Send-MgUserMail -UserId "reports@company.com" -Message @{
      Subject = "Daily Noncompliant Devices Report"
      Body = @{ ContentType = "HTML"; Content = $HtmlReport }
      ToRecipients = @(@{ EmailAddress = @{ Address = "security@company.com" } })
  }
  ```

- **Azure Automation**: Run in cloud (no on-premises server required); pay-per-job ($0.002/job)

**Parity Assessment**: **Partial**. Subscriptions are achievable but require separate tooling (Power BI Pro, Azure Logic Apps, or PowerShell automation) vs. SSRS native capability.

**Migration Considerations**:

- **Audit SCCM subscriptions**: Export list of active SSRS subscriptions (subscriber, schedule, report, parameters)
- **Prioritize by usage**: Focus on top 10 most-consumed subscriptions for Intune recreation
- **Power BI Pro licensing**: Budget for Power BI Pro licenses if using Power BI subscriptions
- **Azure Logic Apps**: Evaluate for organizations with Azure EA (consumption costs minimal)
- **Hybrid approach**: Use PowerShell scheduled tasks for simple reports; Power BI subscriptions for dashboards

**Sources**:

- [Manage report subscriptions - SSRS](https://learn.microsoft.com/en-us/sql/reporting-services/subscriptions/create-and-manage-subscriptions-for-native-mode-report-servers)
- [Power BI subscriptions](https://learn.microsoft.com/en-us/power-bi/consumer/end-user-subscribe)
- [How To: Custom PowerBI Reporting From Intune Data - Samuel McNeill](https://samuelmcneill.com/2022/07/11/how-to-custom-powerbi-reporting-from-intune-data/)

#### 2.3 Microsoft Graph API for Programmatic Access

**SCCM Limitation**: Direct SQL queries against ConfigMgr database (read-only access recommended to avoid breaking site integrity).

- **Pros**: Simple T-SQL queries, universal SQL tool support, no authentication complexity
- **Cons**: On-premises access only (VPN required), schema changes between versions, unsupported by Microsoft for direct queries

**Intune Capability**: **Microsoft Graph API** provides comprehensive RESTful API access:

**Access Scope**:

- **All Intune data**: Devices, users, apps, policies, compliance, configurations, enrollments
- **Read operations**: GET requests to retrieve data
- **Write operations**: POST/PATCH/DELETE to create/update/delete resources
- **Bulk operations**: Batch API for multiple requests in single HTTP call

**Authentication**:

- **Azure AD app registration** required (create app in Azure portal)
- **Delegated permissions** (user context): User signs in, app acts on behalf of user
- **Application permissions** (app-only context): Service principal, no user sign-in (for automation)
- **OAuth 2.0 authentication flow**: Obtain access token, include in HTTP Authorization header

**Common Endpoints** (examples):

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```
GET /deviceManagement/managedDevices (all managed devices)
GET /deviceManagement/deviceCompliancePolicies (compliance policies)
GET /deviceManagement/deviceConfigurations (configuration profiles)
GET /deviceManagement/managedDevices/{id}/deviceCompliancePolicyStates (device compliance status)
POST /deviceManagement/managedDevices/{id}/wipe (remote wipe device)
```

**SDKs Available**:

- **PowerShell**: Microsoft.Graph PowerShell SDK (1000+ cmdlets: `Get-MgDeviceManagementManagedDevice`)
- **Python**: msgraph-sdk-python
- **.NET**: Microsoft.Graph NuGet package
- **JavaScript/TypeScript**: @microsoft/microsoft-graph-client
- **Java**: microsoft-graph

**Example PowerShell Script** (export device inventory):

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```powershell
# Install SDK: Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

$Devices = Get-MgDeviceManagementManagedDevice -All -Property DeviceName, Manufacturer, Model, SerialNumber, OperatingSystem, OSVersion, TotalStorageSpaceInBytes, FreeStorageSpaceInBytes, LastSyncDateTime, ComplianceState

$Devices | Select-Object DeviceName, Manufacturer, Model, SerialNumber, OperatingSystem, OSVersion, @{N='TotalStorageGB';E={[math]::Round($_.TotalStorageSpaceInBytes/1GB,2)}}, @{N='FreeStorageGB';E={[math]::Round($_.FreeStorageSpaceInBytes/1GB,2)}}, LastSyncDateTime, ComplianceState | Export-Csv -Path "IntuneDeviceInventory_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

**Parity Assessment**: **Partial**. Graph API provides modern RESTful access (cloud-accessible, OAuth 2.0 secured) vs. SCCM's SQL queries (on-premises, Windows auth). Trade-off: requires development skills (PowerShell, Python, etc.) vs. simple SQL SELECT statements.

**Migration Considerations**:

- **Inventory SQL queries**: Document SCCM SQL queries used for custom reports and automation
- **Recreate with Graph API**: Use Graph API PowerShell SDK or Python to replicate query logic
- **Authentication setup**: Create Azure AD app registration, grant appropriate Graph API permissions
- **Scheduled execution**: Use Azure Automation runbooks or on-premises scheduled tasks
- **Community resources**: Leverage community-shared Graph API scripts (GitHub, TechNet Gallery)

**Sources**:

- [Microsoft Graph API - Intune Documentation](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Use the Microsoft Graph API to work with Intune](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)

---

### 3. Significant Gaps / No Equivalent

#### 3.1 Custom Report Authoring (SSRS Report Builder)

**SCCM Capability**: **SQL Server Report Builder** provides low-code/no-code custom report authoring:

**Report Builder Features**:

- **Drag-and-drop report designer**: Visual layout with tables, charts, gauges, formatted text, images
- **SQL query designer**: GUI-based query builder (no SQL knowledge required for basic queries)
- **Data sources**: ConfigMgr SQL database (pre-configured connection)
- **Report parameters**: User input prompts (device name, collection, date range, status)
- **Expression builder**: Calculated fields, conditional formatting (e.g., "Red if compliance < 90%")
- **Charts and visualizations**: Bar, column, line, pie, area, scatter, gauge, map
- **Export formats**: Excel, PDF, Word, CSV, XML, TIFF
- **Report linking**: Drill-through to related reports (click device name to open device detail report)

**Common Use Cases**:

- **Executive dashboard**: KPI summary with gauges (compliance %, patch %, security posture)
- **Compliance tracking**: Devices failing specific compliance settings with drill-down
- **Inventory reports**: Hardware by age, warranty expiration, disk space < 10%
- **Deployment validation**: Software deployment success rates by collection

**Intune Capability**: **No GUI authoring equivalent**. Custom reporting requires:

**Option 1: Power BI Desktop** (visual authoring, but requires BI skills):

- **Connect to Intune Data Warehouse**: Use OData feed connector in Power BI Desktop
- **Create data model**: Import entities (Devices, Users, Apps, Compliance), define relationships
- **Build visualizations**: Drag fields to canvas, create charts/tables/cards
- **Publish to Power BI Service**: Upload .pbix to workspace for sharing
- **Skill requirement**: Moderate to high (data modeling, DAX expressions, visual design)

**Option 2: Microsoft Graph API with PowerShell/Python** (programmatic, suitable for simple reports):

- **Write script**: Query Graph API, format data, export to CSV/HTML
- **Run on schedule**: Scheduled task or Azure Automation runbook
- **Skill requirement**: Moderate (PowerShell or Python, REST API concepts)

**Option 3: Azure Log Analytics Workbooks** (KQL-based, for advanced analytics):

- **Configure diagnostic settings**: Send Intune logs to Log Analytics workspace
- **Write KQL queries**: Extract and transform data
- **Create workbook**: Interactive dashboard with parameters, charts, tables
- **Skill requirement**: High (KQL query language, Log Analytics concepts)

**Parity Assessment**: **Significant Gap**. Intune lacks a low-code/no-code report authoring tool equivalent to Report Builder. Organizations must:

- **Invest in Power BI skills** (training or hire BI professionals)
- **Accept Intune built-in reports** for most scenarios
- **Use third-party reporting tools** (Tableau, Qlik, etc.) with Data Warehouse OData feed

**Gap Impact**:

- **Business analysts without SQL/BI skills** cannot self-service custom reports (SCCM Report Builder allowed this)
- **IT generalists** familiar with Report Builder face steep learning curve for Power BI or KQL
- **Custom report backlog**: Organizations with 50+ custom SCCM reports face significant recreation effort

**Workarounds**:

1. **Power BI training investment**: Send 2-3 IT staff to Power BI training (Microsoft Learn, LinkedIn Learning, Pluralsight)
2. **Community templates**: Use pre-built Power BI templates from GitHub/community (80% of common reports already created)
3. **Microsoft Partner engagement**: Contract Power BI consulting for top 10-20 critical reports
4. **Managed services**: Outsource custom reporting to managed service provider (MSP)

**Community Resources** (pre-built Power BI templates):

- [microsoft/Intune-Data-Warehouse GitHub](https://github.com/microsoft/Intune-Data-Warehouse)
- [MSEndpointMgr Intune Reports](https://msendpointmgr.com/category/intune/)
- [Call4Cloud Intune Reporting](https://call4cloud.nl/category/intune/)

**Sources**:

- [Create reports with Report Builder - SSRS](https://learn.microsoft.com/en-us/sql/reporting-services/report-builder/report-builder-in-sql-server-2016)
- [How to Leverage Intune Data and Write a Basic Power BI Report - AskGarth](https://askgarth.com/blog/how-to-leverage-intune-data-and-write-a-basic-power-bi-report/)

#### 3.2 CMPivot Real-Time Multi-Device Queries

**SCCM Capability**: **CMPivot** provides real-time KQL queries on device collections:

**Core Features**:

- **Real-time execution**: Queries run immediately on all online devices in a collection via fast channel (same infrastructure as client notifications)
- **KQL subset support**: `| where`, `| project`, `| summarize`, `| top`, `| render` operators
- **30+ pre-built entities**:
  - **Device**: Device name, domain, manufacturer, model
  - **OperatingSystem**: Name, version, build, architecture, install date
  - **Disk**: Volumes, partitions, capacity, free space, file system
  - **BIOS**: Version, manufacturer, serial number, release date
  - **Processor**: Name, cores, speed, architecture
  - **NetworkAdapter**: Name, MAC address, IP address, connection status
  - **InstalledSoftware**: Application name, version, publisher
  - **Process**: Running processes with CPU/memory usage
  - **Service**: Windows services (name, state, start mode)
  - **AutoStartSoftware**: Startup programs (registry run keys, startup folder)
  - **Registry**: Query registry keys/values
  - **File**: Search for files by name/path
  - **Event**: Windows Event Log query
  - **AppCrash**: Application crash events
  - **CCMLog**: Configuration Manager client log parsing
  - **CcmRecentlyUsedApplications**: Recently launched apps (usage tracking)

**Collection-Level Queries**: Query all devices in a collection simultaneously (e.g., 5,000 devices)

- **Online devices**: Respond immediately (within seconds)
- **Offline devices**: Marked as offline in results
- **Result limit**: 20,000 rows per query (adjustable)
- **Query timeout**: 1 hour (configurable)

**Visualization**:

- `| render barchart`, `| render piechart`, `| render timechart` operators
- Results display in ConfigMgr console with charts
- Export to CSV for offline analysis

**Collection Creation**: Create device collections directly from query results (e.g., "All devices with BIOS version < X")

**Cloud Management Gateway Support**: Queries work across CMG for internet-based clients

**Standalone CMPivot**: Lightweight app (`CMPivot.msi` in `\tools\CMPivot\`) for non-console users (security team)

**Example CMPivot Queries**:

> **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

```kql
// Find devices with BIOS version "LENOVO - 1140"
Bios | where Version == 'LENOVO - 1140'

// Identify devices with low disk space (<10% free)
Disk | where Description == 'Local Fixed Disk' and isnotnull(FreeSpace)
    | extend PercentFree = (FreeSpace / Capacity) * 100
    | where PercentFree < 10
    | project Device, Capacity, FreeSpace, PercentFree
    | order by PercentFree asc

// Query malware detections
AppCrash | where FileName == 'MsMpEng.exe'
    | summarize count() by Device

// Active processes consuming >500MB RAM
Process | where WorkingSetPrivate > 500MB
    | project Device, Name, WorkingSetPrivate
    | order by WorkingSetPrivate desc
```

**Intune Capability**: **No direct equivalent**. Two partial alternatives:

**Option 1: Device Query** (single device only):

- **Access**: Devices > [Device Name] > Monitor > Query
- **Limitation**: Queries single device only (not collections)
- **KQL support**: Limited (basic WMI queries, not full KQL)
- **Use case**: Troubleshoot single device (check installed software, running processes, registry keys)

**Option 2: Azure Log Analytics** (historical data, not real-time):

- **Configure diagnostic settings**: Send Intune logs to Log Analytics workspace
- **Write KQL queries**: Query across all enrolled devices (historical data only)
- **Data latency**: 5-15 minutes ingestion lag (not instant like CMPivot)
- **Full KQL support**: Joins, advanced analytics, aggregations
- **Azure Monitor Workbooks**: Interactive dashboards with parameters
- **Cost**: ~$2.30/GB ingestion (first 5GB/month), tiered pricing beyond

**Option 3: MDE Advanced Hunting** (if MDE Plan 2 licensed):

- **Real-time KQL queries** across MDE-onboarded devices
- **Schema**: DeviceInfo, DeviceProcessEvents, DeviceFileEvents, DeviceNetworkEvents, DeviceRegistryEvents, DeviceEvents
- **Use case**: Security-focused queries (threat hunting, malware investigations)
- **Limitation**: Security telemetry only (not general inventory like CMPivot)
- **Requires MDE Plan 2** ($5.20/user/month or M365 E5)

**Parity Assessment**: **Significant Gap**. CMPivot's real-time collection-level queries have no direct Intune equivalent:

- **Device Query**: Single device only (not scalable)
- **Log Analytics**: Historical data with ingestion lag (not real-time)
- **MDE Advanced Hunting**: Real-time for security scenarios only (requires MDE P2)

**Use Case Impact**:

| CMPivot Use Case                                                               | Intune Alternative                                                                                 |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| "Which 500 devices in Finance collection have Java version < 8u301 right now?" | Log Analytics query (historical, 15-min lag) or custom detection script via Proactive Remediations |
| "Show all devices running process X in the last 5 minutes"                     | MDE Advanced Hunting (if MDE P2 licensed and process tracked by MDE)                               |
| "Real-time compliance check: BIOS password set on all devices"                 | Custom compliance policy (binary compliant/non-compliant; no query results)                        |
| "Create collection of devices with disk space < 10GB"                          | Log Analytics query → export → import to Entra ID group (manual, not dynamic)                      |

**Workarounds**:

1. **MDE Advanced Hunting** (for security scenarios, MDE P2 required):

   > **Note**: The following is a conceptual example illustrating the pattern. Adapt values for your environment.

   ```kql
   DeviceProcessEvents
   | where Timestamp > ago(5m)
   | where ProcessCommandLine contains "malicious.exe"
   | summarize count() by DeviceName
   ```

2. **Intune Proactive Remediations** (scheduled PowerShell scripts):
   - Deploy detection script to all devices (runs every 1-24 hours)
   - Script collects data, uploads to Log Analytics custom logs
   - Query Log Analytics for results (latency = remediation schedule + ingestion lag)

3. **Accept Log Analytics latency** for most scenarios (15-minute lag acceptable for non-emergency queries)

4. **Retain SCCM co-management** for CMPivot access (keep Resource Access workload in SCCM)

**Sources**:

- [CMPivot for real-time data - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/cmpivot)
- [SCCM CMPivot Query Examples - System Center Dudes](https://www.systemcenterdudes.com/sccm-cmpivot-query/)
- [CMPivot vs. Device Query: Real-Time Data Querying Tools Compared - Patch My PC](https://patchmypc.com/blog/cmpivot-vs-device-query/)
- [Advanced hunting in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

---

## Licensing Impact

| Feature                           | Minimum License                  | Included In                                         | Notes                                                                          |
| --------------------------------- | -------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------ |
| **Built-In Intune Reports (~50)** | Intune Plan 1                    | M365 E3, E5, F3, Business Premium                   | Device compliance, configuration, enrollment, updates, apps, endpoint security |
| **Intune Data Warehouse (OData)** | Intune Plan 1                    | M365 E3, E5, F3, Business Premium                   | Free access (30-day retention as of Feb 2026)                                  |
| **Microsoft Graph API**           | Intune Plan 1                    | M365 E3, E5, F3, Business Premium                   | Programmatic access to all Intune data                                         |
| **Audit Logs (30-day retention)** | Intune Plan 1                    | M365 E3, E5, F3, Business Premium                   | All administrative actions logged                                              |
| **Power BI Desktop**              | Free                             | N/A                                                 | Create reports locally (no sharing)                                            |
| **Power BI Pro**                  | $10/user/month                   | Standalone                                          | Required to publish/share reports, schedule refreshes, create subscriptions    |
| **Power BI Premium**              | $20/user/month or capacity-based | Standalone                                          | Large-scale distribution, paginated reports, advanced features                 |
| **Azure Log Analytics**           | Azure subscription               | Pay-per-GB (~$2.30/GB first 5GB/month)              | Extended audit retention, KQL queries, Azure Monitor Workbooks                 |
| **MDE Advanced Hunting**          | MDE Plan 2                       | M365 E5 or $5.20/user/month standalone              | Real-time KQL queries for security scenarios (partial CMPivot replacement)     |
| **Proactive Remediations**        | Endpoint Analytics               | M365 E3, E5, A3, A5, Windows 10/11 Enterprise E3/E5 | Scheduled PowerShell scripts for custom data collection                        |

**Key Takeaway**: All core Intune reporting features included in **Intune Plan 1** (M365 E3). Organizations needing custom reporting with sharing must budget for **Power BI Pro** ($10/user/month). Advanced analytics with KQL requires **Azure Log Analytics** (~$2.30/GB ingestion). Real-time queries for security scenarios require **MDE Plan 2** (M365 E5 or $5.20/user/month).

**See**: **Licensing Impact Register** for consolidated licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Reporting Assessment

**Action Items** (complete before migration):

1. **Report Usage Audit**:
   - Query SSRS execution log (ReportServer database: `ExecutionLog3` view)
   - Identify top 20 most-run reports (by execution count)
   - Document report consumers (who receives scheduled subscriptions)

2. **Custom Report Inventory**:
   - Export list of all custom reports (non-built-in)
   - Categorize as "Intune built-in replacement available" vs. "requires Power BI recreation" vs. "no longer needed"
   - Estimate Power BI development effort (hours per report)

3. **CMPivot Usage Analysis**:
   - Review CMPivot query history (ConfigMgr database: `vSMS_CMPivotQuery` view)
   - Document common query patterns (inventory, compliance, security)
   - Evaluate MDE Advanced Hunting (if MDE P2 licensed) or Log Analytics as alternatives

4. **Subscription Inventory**:
   - Export SSRS subscriptions (ReportServer database: `Subscriptions` table)
   - Document schedule, recipients, parameters
   - Plan Power BI Pro licensing or Azure Logic Apps for automation

### Migration Strategies

#### Strategy 1: Intune Built-In + Power BI Custom (Cloud-First)

**Profile**: Organizations with 10-20 critical custom reports, willing to invest in Power BI skills.

**Approach**:

1. **Use Intune built-in reports** for 80% of operational scenarios (compliance, deployment, enrollment)
2. **Recreate top 10-20 custom reports** in Power BI using Intune Data Warehouse
3. **Leverage community templates** for common reports (device inventory, app deployment status)
4. **Power BI Pro licensing** for report authors (2-3 IT staff) and consumers (management team)
5. **Power BI subscriptions** for automated delivery (replace SSRS subscriptions)
6. **Accept Log Analytics for advanced queries** (15-min lag acceptable vs. CMPivot real-time)

**Effort**: High (Power BI report development, training, workflow changes)

**Timeline**: 90-120 days (includes Power BI training, report recreation, user acceptance testing)

**Cost**: Power BI Pro licenses ($10/user/month × 10-20 users) + training investment

#### Strategy 2: Co-Management Hybrid (Retain SCCM Reporting)

**Profile**: Organizations with 50+ custom reports, heavy CMPivot usage, complex reporting requirements.

**Approach**:

1. **Retain SCCM infrastructure** for reporting only (SQL Server, Reporting Services Point)
2. **Use Intune for device management** (apps, updates, compliance, endpoint protection)
3. **Continue using SCCM reports and CMPivot** for 3-5 years (delay reporting migration)
4. **Plan gradual Power BI transition** (2-3 reports per quarter)
5. **Decommission SCCM reporting** when 90% of reports migrated to Power BI

**Effort**: Low (no immediate reporting migration required)

**Timeline**: Indefinite (phased over 3-5 years)

**Cost**: Maintain SCCM infrastructure (SQL Server licensing, site server hardware)

**Trade-off**: Delays full cloud transition, but preserves critical reporting capabilities.

#### Strategy 3: Third-Party Reporting Tool Integration

**Profile**: Organizations using third-party BI platform (Tableau, Qlik, etc.), willing to integrate with Intune Data Warehouse.

**Approach**:

1. **Connect existing BI platform** to Intune Data Warehouse OData feed
2. **Recreate SCCM reports** using familiar BI tool (Tableau, Qlik, etc.)
3. **Use Intune built-in reports** for operational scenarios
4. **Azure Log Analytics** for advanced analytics (KQL queries in third-party tool or Log Analytics Workbooks)

**Effort**: Medium (OData connector setup, report recreation in existing tool)

**Timeline**: 60-90 days

**Cost**: Existing BI platform licensing (no additional Power BI Pro required)

### Phased Rollout Plan

**Phase 1: Foundation (0-30 days)**

- Obtain Intune Data Warehouse OData feed URL (admin center)
- Connect Power BI Desktop to Data Warehouse, explore data model
- Create 2-3 pilot reports (device inventory, compliance summary)
- Test Data Warehouse refresh schedule (daily automatic update)

**Phase 2: Core Reports (30-60 days)**

- Recreate top 10 most-used SCCM reports in Power BI
- Publish to Power BI Service workspace
- License 5-10 pilot users with Power BI Pro
- Configure automatic daily refresh
- Test Power BI subscriptions (replace 2-3 SSRS subscriptions)

**Phase 3: Advanced Analytics (60-90 days)**

- Configure diagnostic settings: Send Intune logs to Log Analytics workspace
- Write KQL queries for advanced scenarios (audit log analysis, trend analysis)
- Create Azure Monitor Workbooks (operational dashboards)
- Evaluate MDE Advanced Hunting (if MDE P2 licensed) for security queries

**Phase 4: Scale (90-120 days)**

- License all report consumers with Power BI Pro
- Publish all custom reports to Power BI Service
- Configure all Power BI subscriptions (replace SSRS subscriptions)
- Train IT staff on Power BI report authoring
- Decommission SCCM reporting (if not co-management)

### Common Pitfalls to Avoid

1. **Underestimating Power BI Learning Curve**: Power BI requires BI skills (data modeling, DAX, M language). Budget 2-4 weeks training for IT staff.

2. **Data Warehouse 30-Day Retention Oversight**: Historical trending >30 days requires external storage (Azure SQL, Synapse, data lake).

3. **Ignoring Community Resources**: 80% of common reports already created by community (GitHub templates). Don't recreate from scratch.

4. **Forgetting Power BI Pro Licensing**: Power BI Desktop is free, but sharing/scheduling requires Power BI Pro ($10/user/month). Budget accordingly.

5. **CMPivot Dependency**: Organizations with heavy CMPivot usage for real-time queries must plan alternative (MDE Advanced Hunting, Log Analytics, or retain SCCM).

6. **SSRS Subscription Automation Gap**: Intune has no native subscriptions. Plan Power BI Pro subscriptions or Azure Logic Apps before decommissioning SCCM.

7. **Report Parameter Complexity**: SCCM report parameters (collection dropdowns, cascading parameters) require advanced Power BI skills (parameters with dataset queries).

---

## Sources

### Microsoft Official Documentation

- [Introduction to reporting - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/introduction-to-reporting)
- [Microsoft Intune Reports](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)
- [Intune Data Warehouse API](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-nav-intune-data-warehouse)
- [Connect to the Data Warehouse With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-get-a-link-powerbi)
- [Create an Intune Report From the OData Feed With Power BI](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-proc-create-with-odata)
- [Intune Data Warehouse Change Log](https://learn.microsoft.com/en-us/intune/intune-service/developer/reports-changelog)
- [CMPivot for real-time data - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/cmpivot)
- [Auditing changes and events in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/monitor-audit-logs)
- [Azure Monitor integration for reporting](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports)
- [Microsoft Graph API - Intune Documentation](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Use the Microsoft Graph API to work with Intune](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Power BI Report Server integration with Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/servers/manage/powerbi-report-server)
- [Manage report subscriptions - SSRS](https://learn.microsoft.com/en-us/sql/reporting-services/subscriptions/create-and-manage-subscriptions-for-native-mode-report-servers)
- [Power BI subscriptions](https://learn.microsoft.com/en-us/power-bi/consumer/end-user-subscribe)
- [Create reports with Report Builder - SSRS](https://learn.microsoft.com/en-us/sql/reporting-services/report-builder/report-builder-in-sql-server-2016)
- [Advanced hunting in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

### Community and Expert Sources

- [Plan for Change: Update to Intune Data Warehouse infrastructure - M365 Admin](https://m365admin.handsontek.net/plan-change-update-intune-data-warehouse-infrastructure/)
- [Intune Data Warehouse Power BI Template - GitHub](https://github.com/microsoft/Intune-Data-Warehouse/blob/master/Samples/PowerBI/Intune%20Data%20Warehouse%20Report%20Template.pbit)
- [How to Leverage Intune Data and Write a Basic Power BI Report - AskGarth](https://askgarth.com/blog/how-to-leverage-intune-data-and-write-a-basic-power-bi-report/)
- [Build PowerBi Dashboard based on Intune Data Warehouse - Jannik Reinhard](https://jannikreinhard.com/2022/07/10/build-powerbi-dashboard-based-on-intune-data-warehouse/)
- [Intune and Power BI Deep Dive - Part 1 - Deployment Share](https://deploymentshare.com/articles/bp-1-pbi-intune/)
- [How To: Custom PowerBI Reporting From Intune Data - Samuel McNeill](https://samuelmcneill.com/2022/07/11/how-to-custom-powerbi-reporting-from-intune-data/)
- [Super easy start with reporting and the Intune Data Warehouse - Peter van der Woude](https://petervanderwoude.nl/post/super-easy-start-with-reporting-and-the-intune-data-warehouse/)
- [SCCM CMPivot Query Examples - System Center Dudes](https://www.systemcenterdudes.com/sccm-cmpivot-query/)
- [CMPivot vs. Device Query: Real-Time Data Querying Tools Compared - Patch My PC](https://patchmypc.com/blog/cmpivot-vs-device-query/)

---

**End of Assessment**
