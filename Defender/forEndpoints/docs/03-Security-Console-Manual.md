# Method 3: Security Console Manual Checks and Exports

## Overview

The Microsoft 365 Defender portal (Security Console) provides web-based access to MDE device inventory with manual validation capabilities and export functionality[1]. This method is ideal for ad-hoc checks, visual verification, and generating compliance reports without scripting.

## Capabilities

- ✅ View organization-wide device inventory
- ✅ Filter and search devices by multiple criteria
- ✅ Export complete device list to CSV
- ✅ Check individual device details
- ✅ Review onboarding status visually
- ✅ Access device timeline and alerts
- ✅ Generate compliance reports
- ✅ Identify discoverable devices

## Prerequisites

### Access Requirements

- Microsoft 365 Defender portal access: [https://security.microsoft.com](https://security.microsoft.com) [1]
- One of the following roles [2]:
  - Security Administrator
  - Security Operator
  - Security Reader
  - Global Reader
  - Global Administrator

### Browser Requirements

- Microsoft Edge (Chromium)
- Google Chrome
- Mozilla Firefox
- Safari (macOS)
- JavaScript enabled
- Cookies enabled

## Accessing the Device Inventory

### Navigation Path

1. Navigate to [https://security.microsoft.com](https://security.microsoft.com) [1]
2. Click **Assets** in left navigation
3. Click **Devices** [3]

#### Alternative path

- [https://security.microsoft.com/machines](https://security.microsoft.com/machines) [3]

### First-Time Access

On first access, device list may take 1-2 minutes to populate for large organizations.

## Device Inventory Interface

### Column Headers (Default)

The device inventory interface displays various status indicators for onboarding [3] and sensor health[3]:

| Column                  | Description                  | Values                                          |
| ----------------------- | ---------------------------- | ----------------------------------------------- |
| **Device name**         | Computer hostname            | NetBIOS or FQDN                                 |
| **Onboarding status**   | MDE enrollment state         | Onboarded, Can be onboarded, Unsupported        |
| **Sensor health state** | Agent communication status   | Active, Inactive, Misconfigured, No sensor data |
| **Risk level**          | Calculated risk score        | Low, Medium, High, Critical                     |
| **Exposure level**      | Vulnerability exposure       | Low, Medium, High                               |
| **OS Platform**         | Operating system             | Windows 10, Windows 11, Windows Server, etc.    |
| **Group**               | Device group assignment      | Production, Staging, etc.                       |
| **Tags**                | Custom tags                  | Finance, HR, Domain Controller, etc.            |
| **Last seen**           | Last communication timestamp | Date/Time                                       |

### Customizing Columns

1. Click **Customize columns** (gear icon) [3]
2. Select additional columns:
   - IP addresses
   - Managed by
   - First seen
   - Azure AD Device ID
   - OS version
   - Defender antivirus status
   - And more...
3. Click **Apply**

## Filtering Devices

### Filter by Onboarding Status

1. Click **Filters** button [3]
2. Select **Onboarding status**
3. Choose filter value:
   - **Onboarded** - Devices successfully enrolled
   - **Can be onboarded** - Discovered but not enrolled
   - **Unsupported** - OS incompatible with MDE [3]
4. Click **Apply**

### Filter by Sensor Health State

1. Click **Filters** [3]
2. Select **Sensor health state**
3. Choose:
   - **Active** - Reporting normally
   - **Inactive** - No communication >7 days
   - **Misconfigured** - Configuration issues
   - **No sensor data** - Sensor not reporting [3]
4. Click **Apply**

### Filter by OS Platform

1. Click **Filters** [3]
2. Select **OS platform**
3. Choose platform (Windows 10, Windows 11, Windows Server 2016, etc.)
4. Click **Apply**

### Multiple Filters (AND Logic)

Apply multiple filters simultaneously to narrow results [3]:

- Example: **Onboarded** AND **Active** AND **Windows 11**
- All conditions must match

### Search by Device Name

1. Use search box at top of device list [3]
2. Enter device name (partial match supported)
3. Press Enter
4. Results update in real-time

## Exporting Device Inventory

### Full Export (All Devices)

1. Navigate to **Assets** > **Devices** [3]
2. Click **Export** button (top right)
3. Choose **Export all devices**
4. Download begins automatically

#### Export Details

- Format: CSV [3]
- Size: Depends on device count (can be large for 10,000+ devices)
- Time: 30 seconds to 5 minutes for large exports
- Columns: All available device properties

### Filtered Export (Current View)

1. Apply desired filters (onboarding status, health state, etc.) [3]
2. Click **Export**
3. Choose **Export filtered devices**
4. Download filtered CSV

**Use Case:** Export only "Can be onboarded" devices for deployment planning

### Export Limitations

- Maximum 100,000 devices per export [4]
- For organizations >100,000 devices, use [Method 2: Graph API](./02-Graph-API-Validation.md)
- Export represents snapshot at time of export (not real-time) [3]

## CSV Export Format

### Standard Export Columns

```csv
Device name,IP addresses,Group,Onboarding status,Sensor health state,Risk level,Exposure level,OS Platform,OS Version,First seen,Last seen,Tags,Managed by,Azure AD Device ID,Defender antivirus status
WORKSTATION01,10.0.1.100,Production,Onboarded,Active,Low,None,Windows 11,10.0.22621.2715,2025-01-15T08:30:00Z,2025-10-16T10:45:00Z,Finance,Microsoft Defender for Endpoint,a1b2c3d4-...,Enabled
WORKSTATION02,10.0.1.101,,Can be onboarded,,,,Windows 10,10.0.19045.3803,2025-10-10T14:22:00Z,2025-10-16T09:12:00Z,,Device discovery,,
SERVER01,10.0.2.50,Domain Controllers,Onboarded,Active,Medium,Low,Windows Server 2019,10.0.17763.5329,2024-08-20T12:00:00Z,2025-10-16T11:00:00Z,Infrastructure,Microsoft Defender for Endpoint,e5f6g7h8-...,Enabled
```

### Interpreting Export Data

#### Onboarded Device

- Onboarding status: `Onboarded` [3]
- Sensor health state: `Active` [3]
- Last seen: Recent (within 24 hours)
- Defender antivirus status: `Enabled`

##### Discoverable Device (Not Onboarded)

- Onboarding status: `Can be onboarded` [3]
- Sensor health state: Empty
- Managed by: `Device discovery`
- Defender antivirus status: Empty

##### Problem Device

- Onboarding status: `Onboarded` [3]
- Sensor health state: `Inactive` or `Misconfigured` [3]
- Last seen: >7 days ago

## Individual Device Details

### Accessing Device Page

1. Click device name in inventory [5]
2. Device details page opens

### Device Page Sections

#### Overview Tab

- **Device information** [5]
  - Device name
  - IP address(es)
  - Domain
  - OS version and build
  - Processor architecture
- **Sensor information**
  - Sensor version
  - Health state
  - Onboarding status
  - Last update time
- **Risk assessment**
  - Risk level with justification
  - Active alerts count
  - Exposure level

#### Timeline Tab

- All security events chronologically [5]
- User logons
- Process executions
- Network connections
- File modifications
- Registry changes

#### Alerts Tab

- Active alerts for this device [5]
- Alert severity
- Alert category
- Investigation status

#### Security Recommendations Tab

- Applicable security recommendations [5]
- Exposure score impact
- Affected software

#### Software Inventory Tab

- Installed applications [5]
- Version numbers
- Vulnerabilities

#### Discovered Vulnerabilities Tab

- CVE IDs [5]
- Severity scores
- Remediation guidance

## Validation Workflows

### Validate CSV List Against Portal

#### Manual Process

1. Import CSV containing device hostnames
2. For each hostname:
   a. Search device in portal [3]
   b. Check onboarding status
   c. Verify sensor health state
   d. Note last seen time
3. Document findings in spreadsheet

**Recommended:** Use [Script: Get-MDEStatus.ps1](../scripts/Get-MDEStatus.ps1) for automation

### Identify Unmanaged Devices (Can Be Onboarded)

1. Navigate to **Assets** > **Devices** [3]
2. Click **Filters**
3. Select **Onboarding status** = **Can be onboarded** [3]
4. Click **Apply**
5. Click **Export** > **Export filtered devices**
6. Review CSV for deployment planning

**Result:** List of discovered devices not yet protected by MDE

### Check for Inactive Onboarded Devices

1. Click **Filters** [3]
2. Set **Onboarding status** = **Onboarded** [3]
3. Set **Sensor health state** = **Inactive** [3]
4. Click **Apply**
5. Review devices with last seen >7 days
6. Export for investigation

#### Actions

- Verify devices still in production
- Check network connectivity
- Restart SENSE service
- Review event logs
- Consider offboarding if decommissioned

### Monitor Unsupported Devices

1. Click **Filters** [3]
2. Set **Onboarding status** = **Unsupported** [3]
3. Click **Apply**
4. Review OS versions
5. Export for OS upgrade planning

#### Common Unsupported

- Windows 7 without ESU
- Windows 8/8.1 (EOL)
- Windows Server 2008 R2 without ESU
- Unsupported Linux kernel versions

## Device Discovery Feature

### What is Device Discovery?

MDE can discover unmanaged devices on the network using onboarded devices as sensors [6].

### Viewing Discovered Devices

1. Navigate to **Settings** > **Device discovery** [6]
2. View discovery mode (Basic or Standard)
3. Click **Discovered devices** tab
4. Review devices found but not onboarded

### Discovery Status Indicators

- **Can be onboarded**: Supported OS, discovered via network [6]
- **First seen**: When device first discovered
- **Last seen**: Most recent network observation
- **Discovery method**: Standard discovery, Basic discovery

### Prioritizing Discovery Onboarding

1. Filter **Can be onboarded** devices [6]
2. Sort by **First seen** (oldest first)
3. Sort by **Last seen** (most recently active)
4. Focus on frequently seen, long-discovered devices

## Reporting and Dashboards

### Security Dashboard

Navigate to **Home** dashboard for [7]:

- Devices at risk summary
- Devices with active alerts
- Sensor health distribution
- Onboarding progress

### Threat Analytics

Navigate to **Threat analytics** for [8]:

- Exposure to specific threats
- Vulnerable devices
- Recommended actions

### Secure Score

Navigate to **Secure score** for [9]:

- Improvement actions related to MDE
- Score impact of onboarding additional devices
- Comparison to similar organizations

## Troubleshooting

### Issue: Device Not Appearing in Portal

**Timeframe:** Wait 5-30 minutes after onboarding script execution

#### Verification

1. Check device locally: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
2. Verify SENSE service running
3. Check network connectivity to MDE endpoints
4. Review SENSE event log for errors

### Issue: Sensor Health State = "Misconfigured"

#### Causes

- Proxy misconfiguration
- Certificate issues
- Conflicting third-party AV
- Corrupted sensor installation

#### Resolution

1. Run [Method 6: MDE Client Analyzer](./06-MDE-Client-Analyzer.md)
2. Review analyzer output for specific errors
3. Fix identified issues
4. Restart SENSE service

### Issue: Export Button Grayed Out

**Cause:** Insufficient permissions [2]

**Resolution:** Verify Security Reader role or higher and contact Global Administrator for role assignment.

- Verify Security Reader role or higher
- Contact Global Administrator for role assignment

### Issue: Device Shows "Can Be Onboarded" But Is Actually Onboarded

**Cause:** Synchronization delay or duplicate device entry

**Resolution:** Search by IP address and verify Azure AD Device ID matches.

1. Search by IP address instead of hostname [3]
2. Check for multiple entries with similar names
3. Verify Azure AD Device ID matches
4. Wait 24 hours for synchronization
5. Contact Microsoft Support if persists

## Best Practices

1. ✅ Export device inventory weekly for audit trail [3]
2. ✅ Create custom column views for different use cases:
   - Security review: Risk level, Exposure level, Active alerts
   - Compliance: Onboarding status, Sensor health, Last seen
   - Deployment: Can be onboarded, OS platform, Group
3. ✅ Use tags to organize devices by business function
4. ✅ Bookmark filtered views for recurring checks
5. ✅ Schedule regular "Can be onboarded" reviews (monthly)
6. ✅ Document device exceptions (unsupported OS with business justification)
7. ✅ Compare portal data with [Method 2: Graph API](./02-Graph-API-Validation.md) exports for discrepancies

## Comparison: Portal vs. Script-Based Validation

| Aspect             | Security Console  | PowerShell/Graph API                   |
| ------------------ | ----------------- | -------------------------------------- |
| **Setup Time**     | None              | App registration or script development |
| **Execution Time** | Manual per device | Automated bulk processing              |
| **Export Speed**   | Medium (1-5 min)  | Fast (seconds for API)                 |
| **Filtering**      | GUI-based         | Code-based                             |
| **Scheduling**     | Manual only       | Automated via Task Scheduler           |
| **Audit Trail**    | Manual CSV saves  | Automated logging                      |
| **Best For**       | Ad-hoc checks     | Recurring compliance                   |

## Integration with Other Methods

### After Portal Identification

For devices identified as problematic:

1. Note device name and last seen time
2. Use [Method 1: PowerShell](./01-PowerShell-Validation.md) for detailed status
3. If issues found, escalate to [Method 6: Client Analyzer](./06-MDE-Client-Analyzer.md)

### Validate Graph API Results

1. Export via [Method 2: Graph API](./02-Graph-API-Validation.md)
2. Manually verify sample of devices in portal [3]
3. Check for discrepancies (RBAC filtering, sync delays)

### Historical Analysis

1. Export current state from portal [3]
2. Use [Method 5: Advanced Hunting KQL](./05-Advanced-Hunting-KQL.md)
3. Compare current vs. historical onboarding trends

## Keyboard Shortcuts

| Action             | Shortcut            |
| ------------------ | ------------------- |
| Search             | `/` (forward slash) |
| Refresh page       | `Ctrl + R` or `F5`  |
| Open filters       | `Alt + F`           |
| Export             | `Alt + E`           |
| Navigate to Assets | `G` then `A`        |

## Limitations

- ❌ Manual process not suitable for large-scale automation
- ❌ Export limited to 100,000 devices [4]
- ❌ No scheduled export capability
- ❌ Synchronization delays (5-30 minutes for new devices)
- ❌ Cannot validate local service status directly
- ⚠️ Filtered exports require reapplying filters each time

## Next Steps

- For bulk automation: [Method 2: Graph API](./02-Graph-API-Validation.md)
- For local validation: [Method 4: Registry/Service](./04-Registry-Service-Validation.md)
- For deep diagnostics: [Method 6: Client Analyzer](./06-MDE-Client-Analyzer.md)
- For historical queries: [Method 5: Advanced Hunting KQL](./05-Advanced-Hunting-KQL.md)

## References

1. [Microsoft 365 Defender Portal](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal)
2. [Microsoft Defender for Endpoint Basic Permissions](https://learn.microsoft.com/en-us/defender-endpoint/basic-permissions)
3. [Device Inventory Overview](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview)
4. [Software Inventory Assessment API](https://learn.microsoft.com/en-us/defender-endpoint/api/get-assessment-software-inventory)
5. [Device Entity Page](https://learn.microsoft.com/en-us/defender-xdr/entity-page-device)
6. [Configure Device Discovery](https://learn.microsoft.com/en-us/defender-endpoint/configure-device-discovery)
7. [Microsoft Defender for Business Get Started](https://learn.microsoft.com/en-us/defender-business/mdb-get-started)
8. [Threat Analytics](https://learn.microsoft.com/en-us/defender-xdr/threat-analytics)
9. [Microsoft Secure Score](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score)

[1]: https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal
[2]: https://learn.microsoft.com/en-us/defender-endpoint/basic-permissions
[3]: https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview
[4]: https://learn.microsoft.com/en-us/defender-endpoint/api/get-assessment-software-inventory
[5]: https://learn.microsoft.com/en-us/defender-xdr/entity-page-device
[6]: https://learn.microsoft.com/en-us/defender-endpoint/configure-device-discovery
[7]: https://learn.microsoft.com/en-us/defender-business/mdb-get-started
[8]: https://learn.microsoft.com/en-us/defender-xdr/threat-analytics
[9]: https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score
