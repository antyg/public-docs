# Endpoints Domain

## Overview

The **Endpoints** domain encompasses endpoint management across the modern workplace ecosystem. This domain provides comprehensive documentation for provisioning, configuring, managing, and securing endpoints throughout their lifecycle — from initial deployment through ongoing maintenance and eventual retirement. Endpoints include physical devices (workstations, laptops, mobile), virtual machines, and cloud-hosted compute resources.

## Purpose

This folder serves as the centralised repository for endpoint management documentation, covering the tools, processes, and best practices required to maintain a secure, compliant, and efficiently managed endpoint estate. Whether deploying new devices via zero-touch provisioning, managing virtual machine fleets, or governing existing endpoints through Microsoft Endpoint Manager (MEM), this domain provides the technical guidance needed for successful implementation.

## Scope

The endpoints domain addresses the following key areas:

- **Endpoint Provisioning**: Automated deployment workflows, zero-touch provisioning, and cloud-native onboarding
- **Endpoint Management (MEM)**: Microsoft Endpoint Manager — policy enforcement, compliance monitoring, and remote management capabilities
- **Application Management (MAM)**: Application deployment, configuration, and protection strategies
- **Endpoint Configuration**: Operating system settings, security baselines, and configuration profiles
- **OS Deployment**: Operating system imaging, feature updates, and version management
- **Endpoint Compliance**: Policy definitions, compliance assessment, and remediation workflows
- **Virtual Machines**: VM provisioning, configuration, and lifecycle management

## Domain Structure

### Platform Folders

OS-platform documentation — device management, enrolment, compliance, and
configuration specific to each operating system:

| Folder                                            | Platform                             | Status                                               |
| ------------------------------------------------- | ------------------------------------ | ---------------------------------------------------- |
| [`iOS/`](iOS/README.md)                           | iOS / iPadOS                         | 🟡 Seeded — `device-capture-toolkit/` published      |
| [`Android/`](Android/README.md)                   | Android Enterprise                   | 📋 Planned                                           |
| [`ChromeOS/`](ChromeOS/README.md)                 | ChromeOS                             | 📋 Planned                                           |
| [`MacOS/`](MacOS/README.md)                       | macOS                                | 📋 Planned                                           |
| [`Windows/`](Windows/README.md)                   | Windows 10 / 11                      | 📋 Planned                                           |
| [`virtual-machines/`](virtual-machines/README.md) | Azure VMs, Hyper-V, AVD, Windows 365 | 📋 Planned                                           |

### Product / Tool Folders

Cross-platform management tool documentation — spans multiple OS platforms:

| Folder                              | Tool                   | Status                                          |
| ----------------------------------- | ---------------------- | ----------------------------------------------- |
| [`autopilot/`](autopilot/README.md) | Windows Autopilot      | 🔄 Migration in progress (~330KB)               |
| [`intune/`](intune/README.md)       | Microsoft Intune (MEM) | 🟡 Seeded — `ios-diagnostic-logging/` published |

## Relationship to Other Domains

The endpoints domain intersects with several other documentation domains:

- **Identity**: Endpoint compliance is enforced through conditional access policies tied to user and device identity
- **Security**: Endpoint security controls, threat protection, and security baselines are configured through endpoint management platforms
- **Infrastructure**: Endpoint provisioning relies on network connectivity, DNS resolution, and backend infrastructure services
- **Integrations**: Microsoft Graph API provides programmatic access to endpoint management and reporting

## Target Audience

This documentation is designed for:

- IT administrators responsible for endpoint provisioning and management
- Endpoint management specialists implementing zero-touch deployment
- Security teams defining endpoint compliance requirements
- Infrastructure engineers supporting endpoint deployment workflows
- Virtual infrastructure administrators managing VM estates

## Technologies Covered

Primary technologies documented within this domain include:

- Microsoft Endpoint Manager (Intune)
- Windows Autopilot
- Microsoft Entra ID device registration
- Configuration Manager (for hybrid scenarios)
- Apple Business Manager and DEP
- Android Enterprise management
- Hyper-V and Azure Virtual Machines
- PowerShell and Microsoft Graph API for automation

## Getting Started

For new implementations, begin with the **`autopilot/`** folder for modern, cloud-native Windows endpoint provisioning. For ongoing endpoint management and compliance, refer to the **`intune/`** folder for platform-specific configuration guidance.

---

**Last Updated**: February 2026
**Maintainer**: antyg
**Status**: Active — domain scaffold with substantive Autopilot content and seeded Intune placeholder
