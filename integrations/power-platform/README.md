---
title: "Power Platform"
status: "planned"
last_updated: "2026-03-16"
audience: "Developers"
document_type: "readme"
domain: "integrations"
platform: "Microsoft Power Platform"
---

# Power Platform

## Scope

This document is a structured seed for Power Platform integration documentation. It defines the content outline, key topics, and citation anchors for future substantive implementation. Full implementation is deferred to a subsequent work package.

---

## Overview

Microsoft Power Platform is a low-code/no-code development environment comprising four interconnected products:

| Product | Purpose |
|---------|---------|
| **Power Automate** | Cloud-based workflow automation (cloud flows, desktop flows, process mining) |
| **Power Apps** | Canvas apps, model-driven apps, and portals without traditional development |
| **Power BI** | Business intelligence and data visualisation |
| **Power Pages** | External-facing web portals |

Power Platform integrates natively with Microsoft 365, Dynamics 365, Azure services, and hundreds of third-party systems through a connector framework. Dataverse (formerly Common Data Service) provides the underlying data platform shared across Power Apps and Power Automate. See the [Microsoft Power Platform documentation](https://learn.microsoft.com/en-us/power-platform/) for the full product suite reference.

---

## Content Outline

### 1. Power Automate

**Planned content:**

#### Cloud Flow Patterns

Cloud flows are event-driven workflows that run in the cloud without requiring a local machine. Three trigger types exist:

| Trigger type | Description | Example |
|-------------|-------------|---------|
| Automated | Triggered by an event in a connected service | New email received, SharePoint item created, Teams message posted |
| Instant | Manually triggered by a user action | Button in mobile app, button in Teams, Power Apps button |
| Scheduled | Triggered on a time-based cadence | Daily report at 6:00 AM, hourly data sync |

See the [Power Automate cloud flows overview](https://learn.microsoft.com/en-us/power-automate/overview-cloud) for trigger type details and flow creation guidance.

#### Actions and Connectors

Flows are composed of triggers and actions. Each action represents an operation in a connected system. Connectors abstract the underlying API:

- **Standard connectors** — Included in all Power Automate licences (SharePoint, Outlook, Teams, OneDrive, Office 365 Users)
- **Premium connectors** — Require Power Automate Premium or per-flow licence (Dataverse, SQL Server, Azure services, Salesforce)
- **Custom connectors** — Developer-built wrappers for any REST or SOAP API (see Custom Connectors section below)

The full list of available connectors is in the [connector reference](https://learn.microsoft.com/en-us/connectors/connector-reference/).

#### Approval Workflows

Power Automate provides a built-in approval framework with multi-level and parallel approval support:

- **Single approver** — Route to one named user or email address
- **First to respond** — Multiple approvers; flow continues when any one approves
- **Everyone must approve** — All named approvers must approve before the flow continues
- **Sequential** — Chain multiple approval steps; each approves in turn

Approval responses are routed back to the flow via the Approvals connector. Approval history is stored in Dataverse. See [Get started with approvals](https://learn.microsoft.com/en-us/power-automate/get-started-approvals) for configuration details and approval pattern examples.

#### Error Handling

- **Configure run after** — Each action can be configured to run after success, failure, timeout, or skip. Enables branching logic for error recovery paths.
- **Scope actions** — Group multiple actions into a scope to apply shared error handling (`Run after: has failed` on a following scope).
- **Retry policy** — Configurable on individual actions: fixed interval, exponential backoff, or none.

See [Handle errors in Power Automate flows](https://learn.microsoft.com/en-us/power-automate/error-handling) for full details on run-after configuration and retry policies.

---

### 2. Power Apps

**Planned content:**

#### Canvas Apps

Canvas apps provide pixel-perfect UI control. The developer places controls on a canvas and binds them to data sources using Excel-like formulas. Canvas apps connect directly to data sources through connectors.

Key data sources for Microsoft environments:
- SharePoint lists
- Dataverse tables
- Office 365 Users (directory lookup)
- Azure SQL Database (premium connector)
- Microsoft Graph API (via custom connector)

See the [canvas apps overview](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/getting-started) for data source connection patterns and formula authoring guidance.

#### Model-Driven Apps

Model-driven apps are generated from a Dataverse data model. The app structure (forms, views, dashboards) is derived from the schema rather than manually placed controls. Model-driven apps enforce Dataverse security roles automatically.

Use model-driven apps when:
- The data model is complex with many related tables
- Role-based access control at the record or field level is required
- The app needs to scale to large data volumes

See the [model-driven apps overview](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/model-driven-app-overview) for details on schema-driven app generation and Dataverse security role enforcement.

#### Integration with Microsoft 365

Power Apps connects to Microsoft 365 data through standard connectors:
- **Office 365 Users** — Look up user profiles, manager hierarchy, presence status
- **SharePoint** — Read/write SharePoint list items; use as a lightweight data store
- **Outlook** — Send emails from within a canvas app
- **Teams** — Embed canvas apps as tabs in Teams channels

---

### 3. Custom Connectors

**Planned content:**

Custom connectors allow Power Automate and Power Apps to integrate with any REST API, SOAP API, or Azure Logic Apps workflow.

#### Building a Custom Connector

A custom connector is defined by an OpenAPI (Swagger) definition that describes the API's endpoints, parameters, authentication, and response schemas. The definition can be:
- Imported from an existing OpenAPI specification file
- Imported from a Postman collection
- Created from scratch in the [custom connector wizard](https://learn.microsoft.com/en-us/connectors/custom-connectors/define-blank)

#### Authentication Options for Custom Connectors

| Method | Description |
|--------|-------------|
| No authentication | Public APIs with no auth requirement |
| API key | Key passed in header or query parameter |
| OAuth 2.0 | Full OAuth flow with Entra ID, Auth0, or any OIDC provider |
| Windows authentication | On-premises APIs via on-premises data gateway |
| Basic authentication | Username and password (legacy systems) |

For Microsoft Graph API integration via a custom connector, use [OAuth 2.0 with the Microsoft identity platform](https://learn.microsoft.com/en-us/connectors/custom-connectors/connection-parameters#oauth-20) as the identity provider.

#### Connector Policies

Connector policies modify requests and responses in flight — used to inject headers, transform data, or filter responses without modifying the underlying API. Defined in the connector using OpenAPI extensions.

---

### 4. Dataverse

**Planned content:**

Dataverse is the relational data platform underlying model-driven Power Apps, Dynamics 365, and Power Automate. It provides:
- Structured table storage with relationships and column types
- Row-level security (record-level access control)
- Business rules, calculated columns, and roll-up fields
- Event-driven plugins and workflows triggered on data changes
- REST API (OData v4) for programmatic access

#### Dataverse API

The Dataverse Web API is an OData v4 endpoint:

```
https://{org}.crm.dynamics.com/api/data/v9.2/
```

Authentication uses the same OAuth 2.0 pattern as other Microsoft APIs, with the Dataverse service URI as the resource. See [Use the Dataverse Web API](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview) for endpoint details, OData query syntax, and authentication guidance.

#### Security Model

| Component | Description |
|-----------|-------------|
| Business units | Organisational hierarchy; users belong to a business unit |
| Security roles | Collections of privileges (Create, Read, Write, Delete, Append, AppendTo) per table and scope |
| Teams | Can hold security roles; records can be owned by a team |
| Field-level security | Restrict access to individual columns within a table |
| Record sharing | Ad-hoc sharing of specific records with individual users or teams |

The full [Dataverse security model](https://learn.microsoft.com/en-us/power-platform/admin/wp-security-cds) is documented in the Power Platform admin centre reference.

---

### 5. Authentication

**Planned content:**

#### Service Principal for Automation

Power Platform administration tasks (environment provisioning, solution export/import, user management) are performed via the Power Platform admin connector or direct API calls. Non-interactive automation requires a service principal:

1. Register an application in Entra ID
2. Grant the application the `Dynamics CRM user_impersonation` permission (for Dataverse access)
3. Create the service principal as an application user in each Dataverse environment and assign a security role

See [Connect to Dataverse with service principal](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal) for the full PowerShell provisioning procedure.

#### Delegated Permissions for User-Context Flows

Power Automate cloud flows that run in the context of a signed-in user use the flow connection owner's credentials for each connector action. Each connection is authorised with the owner's Entra ID token. The flow executes with the permissions of the connection owner, not the flow trigger user.

Flows that must act on behalf of the triggering user require careful connection design or Power Automate's "run-only users" configuration. See [Manage connections in Power Automate](https://learn.microsoft.com/en-us/power-automate/add-manage-connections) for connection ownership and sharing patterns.

---

### 6. ALM (Application Lifecycle Management)

**Planned content:**

Power Platform ALM follows a source-code-first model using solutions (zip packages containing canvas apps, flows, custom connectors, Dataverse schema changes) promoted through environments:

| Environment type | Purpose |
|----------------|---------|
| Development | Individual developer sandbox |
| Test / UAT | Integration testing and user acceptance |
| Production | Live workloads |

Solutions are exported from the source environment and imported to target environments via:
- Power Platform CLI (`pac solution export`, `pac solution import`)
- Azure Pipelines or GitHub Actions using the Power Platform Build Tools extension
- Power Platform admin centre (manual)

See the [Power Platform ALM overview](https://learn.microsoft.com/en-us/power-platform/alm/overview-alm) for solution lifecycle patterns, environment strategy, and CI/CD pipeline integration.

---

## Planned Documentation Structure

When this seed is implemented, the folder will expand to include:

```
power-platform/
├── README.md                           ← this file (hub)
├── reference/
│   ├── connectors.md                   ← standard and premium connector catalogue
│   ├── dataverse-api.md                ← Dataverse Web API reference
│   └── authentication.md               ← service principal, connections, token model
├── how-to/
│   ├── build-cloud-flow.md             ← create an automated cloud flow
│   ├── create-custom-connector.md      ← OpenAPI-based custom connector
│   ├── manage-dataverse-records.md     ← CRUD via Web API
│   └── deploy-solution.md             ← ALM: export, import, CI/CD pipeline
└── explanation/
    └── architecture.md                 ← platform architecture, connector model, Dataverse data model, security model
```

---

## Related Resources

### Microsoft Official Documentation

- [Microsoft Power Platform documentation](https://learn.microsoft.com/en-us/power-platform/)
- [Power Automate documentation](https://learn.microsoft.com/en-us/power-automate/)
- [Power Automate cloud flows overview](https://learn.microsoft.com/en-us/power-automate/overview-cloud)
- [Handle errors in Power Automate flows](https://learn.microsoft.com/en-us/power-automate/error-handling)
- [Get started with approvals](https://learn.microsoft.com/en-us/power-automate/get-started-approvals)
- [Manage connections in Power Automate](https://learn.microsoft.com/en-us/power-automate/add-manage-connections)
- [Power Apps documentation](https://learn.microsoft.com/en-us/power-apps/)
- [Canvas apps overview](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/getting-started)
- [Model-driven apps overview](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/model-driven-app-overview)
- [Dataverse Web API overview](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview)
- [Dataverse security concepts](https://learn.microsoft.com/en-us/power-platform/admin/wp-security-cds)
- [Power Platform connector reference](https://learn.microsoft.com/en-us/connectors/)
- [Connector reference overview](https://learn.microsoft.com/en-us/connectors/connector-reference/)
- [Create a custom connector from scratch](https://learn.microsoft.com/en-us/connectors/custom-connectors/define-blank)
- [Use OAuth with custom connectors](https://learn.microsoft.com/en-us/connectors/custom-connectors/connection-parameters#oauth-20)
- [Power Platform ALM overview](https://learn.microsoft.com/en-us/power-platform/alm/overview-alm)
- [Connect to Dataverse with service principal](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

### Related Documents

- [Microsoft Graph API](../graph-api/README.md)
- [Azure REST API](../azure-rest-api/README.md)
