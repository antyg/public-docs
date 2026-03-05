# Integrations

## Purpose

This domain provides API specifications, SDK references, integration patterns, and technical documentation for external services and platforms. It focuses on the **API-centric view** of integration technologies — the protocols, authentication mechanisms, query patterns, and SDK usage needed to integrate with external systems.

## What This Folder Holds

Documentation for cross-domain APIs and integration technologies organised by platform or service. Each subfolder contains API references, SDK usage guides, authentication patterns, common query examples, and integration best practices.

## Current Structure

### Subfolders

- **graph-api/** — Microsoft Graph API fundamentals, authentication, SDK usage, query patterns (seeded content from GraphAPI/)

## Planned Expansion

Future integration platforms to be added as the documentation library grows:

- **azure-rest-api/** — Azure Resource Manager (ARM) REST API patterns, authentication, resource management
- **power-platform/** — Power Automate, Power Apps, and Power Platform connectors integration
- **webhooks/** — Webhook patterns, event-driven integration, callback handling
- **exchange-web-services/** — EWS API for Exchange on-premises integration
- **active-directory-api/** — On-premises Active Directory APIs and LDAP integration

## Cross-Cutting Nature of APIs

APIs in this domain are **cross-cutting tools** that span multiple technology domains. They provide a unified integration layer across diverse capabilities.

### Example: Microsoft Graph API

Graph API touches nearly every technology domain:

- **identity/** — User and group management (users, groups, authentication)
- **security/** — Defender for Endpoint queries, security alerts, compliance policies
- **endpoints/** — Intune (MEM) endpoint management, configuration policies, compliance status
- **mail/** — Exchange Online mailbox access, calendar, contacts
- **collaboration/** — Teams, SharePoint, OneDrive integration
- **reports/** — Usage analytics, audit logs, sign-in reports

The `integrations/graph-api/` documentation provides the **API-centric view** — authentication, query syntax, batch operations, SDK usage. The technology domains reference this content when describing domain-specific operations.

## Relationship to Technology Domains

Integration documentation and technology domains have a complementary relationship:

- **Integrations** focuses on **how to call the API** — authentication patterns, SDK setup, query construction, error handling, rate limiting
- **Technology domains** focus on **what to accomplish** — specific queries for user management, device policies, security alerts

For example:
- `integrations/graph-api/` explains Graph API authentication with MSAL, batch request patterns, and PowerShell SDK installation
- `security/defender/` uses Graph API to query Defender alerts and references the authentication guidance from `integrations/graph-api/`
- `identity/entra-id/` uses Graph API for user provisioning and references the SDK usage patterns from `integrations/graph-api/`

## Relationship to Development Standards

The `development/` domain provides language-specific coding standards (PowerShell, Python) that apply when writing integration code. The `integrations/` domain focuses on the integration platform itself, not the language used to interact with it.

For example:
- `integrations/graph-api/` documents Graph API authentication flows and SDK usage
- `development/powershell/` documents PowerShell coding standards for any PowerShell code, including Graph API scripts

## Scope

This domain covers:
- API authentication and authorisation patterns
- SDK installation, configuration, and usage
- Common query patterns and examples
- Batch operations and bulk processing
- Rate limiting and throttling strategies
- Error handling and retry logic
- Webhook and event-driven integration patterns
- API versioning and migration guidance

This domain does **not** cover:
- Technology-specific use cases (those belong in technology domains)
- Language-specific coding standards (those belong in `development/`)
- Operational procedures for managing integrated systems (those belong in `operations/`)

## Audience

- Integration developers and engineers
- PowerShell and Python automation developers
- API consumers across all technology domains
- Architects designing cross-platform integrations
- DevOps engineers implementing API-driven automation
- Anyone building integrations with external services
