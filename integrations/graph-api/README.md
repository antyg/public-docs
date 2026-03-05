# Microsoft Graph API

## Purpose

This folder provides comprehensive documentation for integrating with Microsoft Graph API — the unified API endpoint for Microsoft 365, Azure Active Directory (Entra ID), and related Microsoft cloud services. It covers authentication patterns, SDK usage, common query patterns, and integration best practices.

## What This Folder Holds

**Seeded content migrated from GraphAPI/** — Currently contains foundational Graph API documentation (1.2KB) covering API fundamentals, authentication, and PowerShell SDK basics. This will be expanded with detailed patterns, examples, and advanced usage guidance.

### Current Content

- **Graph API Fundamentals** — Overview of Graph API architecture, endpoints, and capabilities
- **Authentication Basics** — Introduction to OAuth 2.0 flows and MSAL (Microsoft Authentication Library)
- **PowerShell SDK Overview** — Basic PowerShell SDK installation and usage

## Planned Scope and Expansion

This folder will grow to include comprehensive guidance on all aspects of Graph API integration:

### Authentication and Authorisation

- **OAuth 2.0 Flows** — Authorisation code flow, client credentials flow, device code flow, on-behalf-of flow
- **MSAL Integration** — MSAL.PS and MSAL.Python usage patterns, token caching, refresh token handling
- **Application vs Delegated Permissions** — When to use each permission type, consent flows, least privilege principles
- **Certificate-Based Authentication** — Using certificate credentials for unattended automation
- **Managed Identity Integration** — Using Azure Managed Identity for Graph API authentication

### SDK Usage

- **PowerShell SDK** — Microsoft.Graph PowerShell module installation, cmdlet patterns, authentication with Connect-MgGraph
- **Python SDK** — msgraph-sdk-python usage, async patterns, batch request handling
- **REST API Direct** — Raw HTTP requests with Invoke-RestMethod (PowerShell) and requests library (Python)
- **SDK Version Management** — Handling SDK updates, version compatibility, migration between versions

### Query Patterns

- **Basic Queries** — GET requests for single resources, simple filters, property selection with $select
- **Advanced Filtering** — $filter operators, complex query expressions, lambda operators (any/all)
- **Pagination** — Handling @odata.nextLink, retrieving large result sets, page size optimisation
- **Batching** — $batch endpoint usage, combining multiple requests, batch size limits
- **Delta Queries** — Tracking changes over time with deltaLink, incremental sync patterns
- **Expand and Select** — Optimising responses with $expand (related resources) and $select (specific properties)

### Common Operations

- **User Management** — Creating, updating, and deleting users; group membership; licence assignment
- **Group Operations** — Group creation, membership management, dynamic group queries
- **Device Queries** — Intune device retrieval, compliance status, configuration policies
- **Security Queries** — Defender alerts, secure score, security incidents
- **Mail and Calendar** — Mailbox access, calendar events, send mail, shared mailboxes
- **Reports and Analytics** — Usage reports, sign-in logs, audit logs

### Performance and Reliability

- **Rate Limiting and Throttling** — Understanding throttling headers, retry-after handling, exponential backoff
- **Error Handling** — HTTP status codes, error response structure, transient vs permanent errors
- **Token Management** — Token expiry handling, proactive refresh, token caching strategies
- **Batch Optimisation** — When to batch, batch size recommendations, dependency handling in batches

### Change Notifications and Webhooks

- **Subscription Management** — Creating subscriptions, subscription expiration, renewal patterns
- **Webhook Endpoints** — Implementing webhook receivers, validation, security
- **Event Processing** — Handling change notifications, event deduplication, replay protection

## Technologies Covered

- **Microsoft Graph API** — v1.0 and beta endpoints
- **MSAL (Microsoft Authentication Library)** — MSAL.PS (PowerShell), MSAL.Python
- **PowerShell SDK** — Microsoft.Graph PowerShell modules (v1.x and v2.x)
- **Python SDK** — msgraph-sdk-python
- **REST APIs** — Direct HTTP integration patterns

## Cross-References to Technology Domains

Graph API is used extensively across technology domains. This folder provides the API-centric foundation; technology domains reference it for specific use cases:

### security/

- **defender/** — Uses Graph API to query Defender for Endpoint alerts, incidents, and threat intelligence
  - References: Authentication patterns, query filtering, pagination for large alert sets

### identity/

- **entra-id/** — Uses Graph API for user provisioning, group management, authentication policies
  - References: User management operations, group queries, batch operations for bulk provisioning

### endpoints/

- **intune/** — Uses Graph API for endpoint management (MEM), configuration policies, compliance status
  - References: Endpoint queries, policy assignment, batch operations for device updates

### collaboration/

- **teams/** — Uses Graph API for Teams management, channel operations, app integration
  - References: Teams-specific endpoints, webhook patterns for Teams events

### mail/

- **exchange-online/** — Uses Graph API for mailbox access, mail flow rules, calendar operations
  - References: Delegated vs application permissions, shared mailbox access patterns

## Relationship to Development Standards

When writing code that uses Graph API, follow the language-specific standards in `development/`:

- **PowerShell** — Follow `development/powershell/` standards for error handling, function design, and testing
- **Python** — Follow `development/python/` standards (when added) for code structure and quality

The Graph API documentation focuses on **what Graph API provides**, while development standards focus on **how to write quality code** that uses it.

## Using This Documentation

### For Authentication Setup

Start with authentication patterns to establish secure API access. Choose the appropriate OAuth flow for your scenario (interactive vs unattended, user context vs application context).

### For Query Development

Use the query patterns section to build efficient Graph API queries. Reference filtering, pagination, and batching guidance to optimise performance.

### For SDK Selection

Review SDK usage guidance to choose between PowerShell SDK, Python SDK, or direct REST API calls. Each approach has different trade-offs in terms of ease of use, performance, and flexibility.

### For Error Handling

Implement robust error handling using the error handling and throttling guidance. Graph API has specific retry patterns and rate limits that must be respected.

## Audience

- Integration developers using Graph API across any technology domain
- PowerShell automation developers working with Microsoft 365
- Python developers building Graph API integrations
- Security engineers querying Defender and compliance data
- Identity administrators automating user and group management
- Device administrators querying Intune data
- Anyone building automation or integration with Microsoft cloud services

## Future Expansion

Planned additions to this folder:

- Detailed authentication flow examples with code samples
- Comprehensive query pattern library organised by resource type
- Batch operation cookbook with complex scenarios
- Change notification and webhook implementation guide
- Performance optimisation strategies and benchmarking
- Migration guides for SDK version updates
- Troubleshooting guide for common issues
