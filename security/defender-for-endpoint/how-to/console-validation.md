---
title: "How to Verify MDE Deployment Through the Microsoft Defender Portal"
status: "published"
last_updated: "2026-03-08"
audience: "Security analysts and administrators performing ad-hoc MDE deployment checks"
document_type: "how-to"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# How to Verify MDE Deployment Through the Microsoft Defender Portal

---

## When to Use This Guide

Use the Microsoft Defender portal for:

- Ad-hoc visual confirmation of device onboarding status
- Identifying devices that can be onboarded (discovered but unprotected)
- Exporting a device inventory snapshot without scripting
- Checking an individual device's sensor health, risk level, and recent alerts

For automated or recurring validation, prefer the [PowerShell tutorial](../tutorials/powershell-validation.md) or [Graph API tutorial](../tutorials/graph-api-validation.md). The portal export is limited to 100,000 devices and cannot be scheduled.

### Portal vs. Scripted Validation

| Aspect | Security Console (Portal) | PowerShell / Graph API |
|--------|--------------------------|------------------------|
| Setup time | None | App registration or script installation required |
| Execution | Manual, per device or per export | Automated bulk processing |
| Export speed | Medium (1–5 minutes) | Fast (seconds via API) |
| Filtering | GUI-based | Code-based OData or Where-Object |
| Scheduling | Manual only | Automatable via Task Scheduler or pipeline |
| Audit trail | Manual CSV saves | Automated logging |
| Device limit | 100,000 per export | Unlimited (paginated) |
| Best for | Ad-hoc checks, visual verification | Recurring compliance reporting |

---

## Prerequisites

- Access to [https://security.microsoft.com](https://security.microsoft.com) ([portal reference](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal))
- One of the following roles ([permissions reference](https://learn.microsoft.com/en-us/defender-endpoint/basic-permissions)):
  - Security Administrator
  - Security Operator
  - Security Reader
  - Global Reader
- A modern browser with JavaScript and cookies enabled

---

## Navigate to the Device Inventory

1. Go to [https://security.microsoft.com](https://security.microsoft.com)
2. In the left navigation, click **Assets**
3. Click **Devices**

Direct URL: [https://security.microsoft.com/machines](https://security.microsoft.com/machines)

The [device inventory](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview) shows all devices visible to your RBAC role. On first load, allow 1–2 minutes for the list to populate in large organisations.

---

## Read the Device Inventory Columns

The default column set displays the key fields for deployment validation:

| Column | Description | Values |
|--------|-------------|--------|
| Device name | Hostname or FQDN | |
| Onboarding status | MDE enrolment state | Onboarded, Can be onboarded, Unsupported |
| Sensor health state | Agent communication status | Active, Inactive, Misconfigured, No sensor data |
| Risk level | Calculated risk score | Low, Medium, High, Critical |
| OS Platform | Operating system | Windows 10, Windows 11, Windows Server, etc. |
| Last seen | Most recent cloud communication | Date and time |

To add columns (IP addresses, Azure AD Device ID, OS version, Defender antivirus status): click the gear icon (**Customize columns**) at the top right of the device list and select the additional fields.

---

## Filter by Onboarding Status

1. Click **Filters** above the device list
2. Select **Onboarding status**
3. Choose one or more values:
   - **Onboarded** — devices currently protected
   - **Can be onboarded** — discovered devices not yet enrolled; the deployment gap
   - **Unsupported** — devices with OS versions incompatible with MDE
4. Click **Apply**

Filters use AND logic — apply multiple filters simultaneously to narrow results. For example, **Onboarded** AND **Inactive** identifies onboarded devices that have stopped communicating.

---

## Filter by Sensor Health State

1. Click **Filters** > **Sensor health state**
2. Choose:
   - **Active** — reporting normally
   - **Inactive** — no communication for more than 7 days
   - **Misconfigured** — configuration issues (proxy, certificate, or sensor)
   - **No sensor data** — sensor not reporting data

Devices showing **Misconfigured** require investigation. Common causes include proxy misconfiguration, SSL inspection breaking certificate validation, or a corrupted sensor installation. Use the [MDE Client Analyzer](../reference/client-analyzer.md) to diagnose.

---

## Export the Device Inventory

### Export All Devices

1. Navigate to **Assets** > **Devices**
2. Click **Export** (top right)
3. Choose **Export all devices**
4. The CSV downloads automatically

### Export a Filtered View

1. Apply the filters needed (e.g., **Can be onboarded** only)
2. Click **Export** > **Export filtered devices**

The export reflects the state at the time of download — it is not real-time. Exports are limited to 100,000 devices. For organisations exceeding this limit, use the [Graph API](../tutorials/graph-api-validation.md).

### CSV Column Headers

The portal export produces a CSV with the following column headers:

```text
Device name, IP addresses, Group, Onboarding status, Sensor health state, Risk level, Exposure level, OS Platform, OS Version, First seen, Last seen, Tags, Managed by, Azure AD Device ID, Defender antivirus status
```

Not all columns are populated for every device. Discovered-but-not-onboarded devices have empty values for `Sensor health state`, `Managed by` (shows `Device discovery`), and `Defender antivirus status`.

### Interpreting the Export CSV

A healthy onboarded device in the CSV shows:

```text
Onboarding status: Onboarded
Sensor health state: Active
Last seen: within the last 24 hours
Defender antivirus status: Enabled
```

A device ready for onboarding shows:

```text
Onboarding status: Can be onboarded
Sensor health state: (empty)
Managed by: Device discovery
```

A problem device (onboarded but not communicating) shows:

```text
Onboarding status: Onboarded
Sensor health state: Inactive
Last seen: more than 7 days ago
```

---

## Check an Individual Device

Click any device name to open the [device entity page](https://learn.microsoft.com/en-us/defender-xdr/entity-page-device). The **Overview** tab shows:

- Sensor version and health state
- Onboarding status
- Risk level with justification
- Active alert count

The **Timeline** tab shows all recorded security events chronologically — process executions, file modifications, network connections, and registry changes. Use this to confirm the sensor is actively collecting data.

---

## Identify Devices Ready for Onboarding

This workflow produces a prioritised list of unprotected devices for deployment planning:

1. Navigate to **Assets** > **Devices**
2. Click **Filters** > **Onboarding status** = **Can be onboarded**
3. Click **Apply**
4. Sort by **First seen** (oldest first — these have been discoverable the longest)
5. Click **Export** > **Export filtered devices**
6. Prioritise devices seen most frequently (high **Last seen** frequency indicates active, persistent devices)

For Device Discovery configuration and discovery mode settings, navigate to **Settings** > **Device discovery** ([device discovery reference](https://learn.microsoft.com/en-us/defender-endpoint/configure-device-discovery)).

---

## Check for Inactive Onboarded Devices

Inactive onboarded devices have stopped communicating with MDE and represent a visibility gap:

1. Click **Filters**
2. Set **Onboarding status** = **Onboarded**
3. Set **Sensor health state** = **Inactive**
4. Click **Apply**
5. Review devices where **Last seen** is more than 7 days ago

For each inactive device, verify whether it is still in production. If so, check SENSE service status and network connectivity using the [registry and service reference](../reference/registry-service-reference.md).

---

## Troubleshooting Portal Issues

**Device not appearing after onboarding**

Allow 5–30 minutes after running the onboarding script. If the device still does not appear after 30 minutes, use the [registry validation](../reference/registry-service-reference.md) to confirm `OnboardingState = 1` locally, then check SENSE service connectivity.

**Sensor health state shows "Misconfigured"**

Common causes: proxy misconfiguration, SSL/TLS inspection stripping certificates, conflicting third-party AV. Run the [MDE Client Analyzer](../reference/client-analyzer.md) on the affected device for a detailed diagnosis.

**Export button greyed out**

Insufficient permissions. The Security Reader role is required minimum. Contact a Global Administrator to verify role assignment.

**Device shows "Can be onboarded" but is actually onboarded**

Synchronisation delay or duplicate device entry. Search by IP address rather than hostname, check for multiple entries with similar names, and allow 24 hours for full synchronisation.

---

## Limitations

- Maximum 100,000 devices per export — use Graph API for larger tenants
- No scheduled export capability from the portal
- Synchronisation delay of 5–30 minutes for newly onboarded devices
- Cannot validate local service status directly — portal reflects cloud-side data only

---

## Related Resources

- [Microsoft 365 Defender portal overview](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender-portal)
- [Device inventory overview](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview)
- [MDE basic permissions](https://learn.microsoft.com/en-us/defender-endpoint/basic-permissions)
- [Device entity page](https://learn.microsoft.com/en-us/defender-xdr/entity-page-device)
- [Configure Device Discovery](https://learn.microsoft.com/en-us/defender-endpoint/configure-device-discovery)
- [Validation methods overview](../explanation/validation-methods-overview.md)
- [Graph API tutorial](../tutorials/graph-api-validation.md)
