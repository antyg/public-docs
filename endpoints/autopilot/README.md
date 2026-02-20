# Windows Autopilot

## Overview

**Windows Autopilot** is Microsoft's modern endpoint provisioning platform that enables zero-touch deployment of Windows 10 and Windows 11 devices. This folder contains comprehensive technical documentation for implementing Autopilot in cloud-native and hybrid environments, including migration strategies, architectural guidance, and ready-to-use automation templates.

## Purpose

This is a **substantive documentation folder** receiving approximately **330KB of migrated Windows Autopilot content** from the legacy documentation structure. It serves as the authoritative reference for organisations deploying or optimising Autopilot-based endpoint provisioning workflows, with particular emphasis on migrating from traditional hybrid Active Directory environments to cloud-native Entra ID architectures.

## Content Overview

This folder contains six major content areas covering the full spectrum of Autopilot implementation:

### `cloud-migration/` (88KB)

Strategic guidance for migrating from hybrid domain-joined endpoint provisioning to cloud-native Autopilot deployments. Key topics include:

- **Authentication considerations**: Transitioning from on-premises AD authentication to Entra ID, handling legacy authentication requirements, and implementing modern authentication protocols
- **Application compatibility**: Identifying line-of-business applications with hard dependencies on domain membership and implementing cloud-ready alternatives
- **Migration planning**: Phased approaches for moving existing endpoint estates to Autopilot management
- **Hybrid coexistence**: Operating hybrid Entra ID join during transition periods
- **Service limitations**: Documenting cloud service boundaries and designing workarounds for unsupported scenarios

### `limitations-and-solutions/` (62KB)

Practical documentation of real-world constraints encountered in Autopilot hybrid deployments, along with tested workarounds and architectural alternatives:

- Known platform limitations in hybrid Entra ID join scenarios
- Network connectivity requirements and firewall rule dependencies
- Domain join timing issues and mitigation strategies
- Certificate-based authentication challenges in cloud-only environments
- Group Policy gaps and Intune configuration profile equivalents

### `quick-reference/` (20KB)

Administrator cheatsheets and rapid-reference guides for day-to-day Autopilot operations:

- Deployment profile configuration quick start
- Troubleshooting decision trees
- Common PowerShell commands for Autopilot management
- Hardware hash collection procedures
- Tenant configuration validation checklists

### `setup-guides/` (37KB)

Comprehensive step-by-step setup procedures for Autopilot deployment:

- Initial tenant configuration and prerequisites
- Deployment profile creation and assignment
- Hardware vendor integration workflows
- Network infrastructure preparation
- End-to-end deployment testing procedures

### `technical-diagrams/` (65KB)

Visual architecture documentation using Mermaid diagram syntax:

- High-level Autopilot deployment flows (user-driven vs self-deploying)
- Service boundary and network communication diagrams
- Authentication sequence flows for hybrid scenarios
- Decision trees for deployment profile selection
- Integration points with Intune, Entra ID, and Endpoint Manager

### `templates/` (58KB)

**12 PowerShell scripts and configuration templates** ready for production use:

- **Hardware hash collection**: Scripts for capturing device identifiers for Autopilot registration
- **Network testing utilities**: Tools for validating connectivity to required Microsoft endpoints
- **Firewall rule templates**: PowerShell scripts to configure proxy servers and enterprise firewalls for Autopilot traffic
- **Bulk operations**: Scripts for managing large endpoint populations (mass import, profile assignment, deregistration)
- **Proxy configuration**: Automated configuration of WinHTTP proxy settings for Autopilot in proxied environments
- **Deployment validation**: Post-provisioning verification scripts to confirm successful Autopilot completion

## Technologies

This documentation covers the following technology stack:

- **Windows 10 and Windows 11**: Target operating systems for Autopilot provisioning
- **Microsoft Endpoint Manager (Intune)**: Endpoint management platform delivering configuration profiles during Autopilot
- **Microsoft Entra ID**: Cloud identity platform for device registration and conditional access
- **Hybrid Entra ID Join**: Transitional architecture maintaining on-premises AD integration
- **Windows PowerShell and PowerShell 7**: Automation scripts for bulk operations and administration
- **Microsoft Graph API**: Programmatic access to Autopilot and endpoint management services
- **Endpoint Manager Admin Centre**: Web-based management console for Autopilot configuration

## Target Audience

This documentation is designed for:

- **IT administrators** responsible for deploying Windows endpoints at scale
- **Endpoint management specialists** implementing zero-touch provisioning workflows
- **Cloud migration architects** planning transitions from on-premises to cloud-native endpoint management
- **Systems engineers** troubleshooting Autopilot deployment issues
- **Security teams** validating endpoint compliance and conditional access policies

## Relationship to Parent Domain

Autopilot is the **primary provisioning mechanism** for the broader endpoints domain. It handles the initial endpoint setup and configuration, after which ongoing management transitions to the platforms documented in sibling folders:

- **`../intune/`**: Autopilot relies on Intune (MEM) for delivering configuration profiles, compliance policies, and applications during the out-of-box experience (OOBE). Post-provisioning, Intune provides continuous endpoint management.
- **Parent `endpoints/`**: Autopilot documentation focuses specifically on the provisioning phase of the endpoint lifecycle. Broader endpoint management topics (compliance monitoring, update management, application deployment) are covered elsewhere in the endpoints domain.

## Migration Status

This folder is actively receiving content migrated from:

- Previous location: `D:\antyg\docs\antyg-public\Autopilot\`
- Content volume: ~330KB across 6 subfolders
- Migration includes: Markdown documentation, Mermaid diagrams, PowerShell scripts (.ps1), and configuration templates
- Quality standards: All migrated content undergoes review for technical accuracy, formatting consistency, and Australian English compliance

## Getting Started

**New to Autopilot?** Start with:

1. **`setup-guides/`** — Follow the tenant configuration procedures
2. **`technical-diagrams/`** — Understand the architecture and deployment flows
3. **`templates/`** — Use the hardware hash collection script for your first device registration

**Migrating from hybrid AD?** Begin with:

1. **`cloud-migration/`** — Assess authentication and application dependencies
2. **`limitations-and-solutions/`** — Identify potential blockers and workarounds
3. **`setup-guides/`** — Implement a phased rollout approach

**Day-to-day management?** Use:

1. **`quick-reference/`** — Rapid lookup for common tasks
2. **`templates/`** — PowerShell automation for bulk operations

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Content Status**: Substantive — receiving 330KB of production documentation
**Script Count**: 12 PowerShell templates for automation
