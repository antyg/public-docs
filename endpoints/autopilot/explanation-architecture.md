---
title: "Windows Autopilot Architecture"
status: "draft"
last_updated: "2026-03-16"
audience: "Endpoint Engineers"
document_type: "explanation"
domain: "endpoints"
platform: "Windows Autopilot"
---

# Windows Autopilot Architecture

This document explains what Windows Autopilot is, how its components relate to the broader Microsoft cloud deployment stack, and where the boundaries between Autopilot, Microsoft Entra ID, and Microsoft Intune lie. It is understanding-oriented — it does not provide configuration steps or procedures.

---

## Service Overview

[Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/overview) is a collection of technologies used to set up and pre-configure new Windows devices, transforming an OEM-installed Windows installation into a business-ready state without requiring IT to touch the device or apply a custom image.

Autopilot does not replace the operating system or re-image hardware. Instead, it customises the out-of-box experience (OOBE), registers device identity, and orchestrates a handoff chain to Entra ID and Intune. The result is a device that is domain-free, cloud-managed, and policy-compliant from the moment the end user completes sign-in.

The service is designed around [zero-touch provisioning](https://learn.microsoft.com/en-us/autopilot/overview): an OEM or reseller registers a device's hardware hash against a tenant, and when the device first boots and reaches the internet, Autopilot identifies it, applies the correct deployment profile, and guides it through registration — with no IT physical intervention required.

### What Autopilot Does

- Identifies a device by hardware hash and matches it to a registered deployment profile
- Customises the OOBE experience with organisational branding and suppresses consumer-facing setup screens
- Directs the device to authenticate against the correct Microsoft Entra tenant
- Applies an Autopilot deployment profile that determines join type, account type, and device naming

### What Autopilot Does Not Do

- Autopilot does not authenticate users or validate credentials — that is the role of Microsoft Entra ID
- Autopilot does not enrol devices into MDM or apply configuration policies — that is the role of Microsoft Intune
- Autopilot does not install applications — Intune handles all application deployment
- Autopilot's active scope lasts approximately 60–90 seconds during initial boot; all ongoing device management occurs entirely within Intune

This distinction matters for troubleshooting and architecture planning. Failures in the first 90 seconds of OOBE are Autopilot or network registration issues. Failures during sign-in are Entra ID issues. Failures in policy or application delivery are Intune issues.

---

## Architecture and Dependencies

### Core Service Dependencies

Windows Autopilot has no standalone infrastructure footprint. It is entirely cloud-dependent and requires the following Microsoft services to function:

| Service | Role in Autopilot |
|---|---|
| [Windows Autopilot Deployment Service](https://learn.microsoft.com/en-us/autopilot/overview) | Stores device registrations, deployment profiles, and group tags; performs hardware hash lookup during OOBE |
| [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/) | Provides device identity creation, user authentication, Entra join, and MDM autoenrolment trigger |
| [Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/) | Receives device via MDM enrolment; applies configuration profiles, compliance policies, and applications |

Network connectivity to Microsoft cloud endpoints is a hard prerequisite. Autopilot cannot complete if the device cannot reach the Autopilot registration service, the Microsoft Entra authentication endpoints, or the Intune management endpoints. Time synchronisation is also critical because certificate validation will fail if the device clock is significantly skewed.

### Service Integration Model

The three services form a sequential dependency chain, not a parallel system:

1. The Autopilot Deployment Service identifies the device and assigns a profile (60–90 seconds)
2. Entra ID authenticates the user, creates a device identity object, and triggers MDM autoenrolment (30–120 seconds)
3. Intune receives the newly enrolled device, applies policies and applications, and manages it ongoing

Each service in the chain depends on the previous service completing successfully. Autopilot must hand the device to Entra ID before Entra can register it. Entra must create a device identity and enrolment token before Intune can receive the device. This sequential nature is why the [Enrolment Status Page (ESP)](https://learn.microsoft.com/en-us/autopilot/enrollment-status) is significant — it holds the device at the OOBE stage until the Intune phase is sufficiently complete, preventing users from accessing a device before required security policies and applications are applied.

### Hybrid Join Additional Dependencies

Microsoft [does not recommend hybrid Entra join for new deployments](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/azure-ad-joined-hybrid-azure-ad-joined). Where hybrid join is required for legacy reasons, additional components are needed: on-premises Active Directory Domain Services, Microsoft Entra Connect for identity synchronisation, and the Intune Connector for Active Directory to perform offline domain join operations. These components introduce network line-of-sight requirements and operational overhead that are absent in cloud-native deployments.

The Intune Connector for Active Directory versions earlier than 6.2501.2000.5 [were deprecated in June 2025](https://learn.microsoft.com/en-us/autopilot/whats-new), creating migration urgency for organisations still relying on hybrid Autopilot flows.

---

## Service Boundaries and Handoffs

A common misconception is that "Windows Autopilot manages and configures devices." In practice, Autopilot is a device discovery and redirection service. The three services involved in Autopilot deployment have non-overlapping ownership boundaries.

### Windows Autopilot: Device Discovery (60–90 seconds)

The Autopilot service owns the period from device power-on to the point at which the OOBE authentication screen appears. During this window it:

- Receives the hardware hash from the device and performs a lookup against the Autopilot device registry
- Returns a deployment profile to the device (join type, display name template, OOBE customisation settings)
- Customises the OOBE experience (suppresses EULA, privacy settings, and keyboard selection pages)
- Redirects the device to `login.microsoftonline.com` for authentication

The Autopilot service does not create device identity objects in Entra ID, does not validate user credentials, and has no role in policy or application delivery. Its function ends when it redirects to authentication.

### Microsoft Entra ID: Identity and Authentication (30–120 seconds)

Entra ID owns the period from authentication screen presentation to MDM enrolment trigger. During this window it:

- Validates user credentials and enforces multi-factor authentication requirements
- Evaluates Conditional Access policies against the authentication context
- Creates the Entra device identity object and issues device certificates
- Performs the Entra join operation (for cloud-native deployments) or coordinates with on-premises AD (for hybrid deployments)
- Triggers automatic MDM enrolment by redirecting the device to `enrollment.manage.microsoft.com`

Entra ID does not apply device configuration, install applications, or evaluate device compliance. It stores compliance state (reported by Intune) and uses it in Conditional Access evaluations, but the compliance evaluation itself is an Intune function.

### Microsoft Intune: Device Management (Ongoing)

Intune owns everything from the MDM enrolment point forward, which is the majority of the device lifecycle. During initial provisioning it:

- Receives the device enrolment request and processes MDM enrolment
- Pushes security configuration profiles (BitLocker, Windows Hello for Business, Defender)
- Deploys required applications via the Enrolment Status Page blocking phase
- Begins compliance evaluation against configured compliance policies

After provisioning, Intune continues to own all ongoing device management: policy updates, application lifecycle, compliance monitoring, and device retirement.

### Responsibility Matrix

| Responsibility | Windows Autopilot | Microsoft Entra ID | Microsoft Intune |
|---|---|---|---|
| Hardware hash lookup and profile assignment | Primary owner | Not involved | Not involved |
| Device identity object creation | Initiates only | Primary owner | Not involved |
| User authentication and MFA | Not involved | Primary owner | Not involved |
| Conditional Access evaluation | Not involved | Primary owner | Not involved |
| MDM enrolment | Not involved | Initiates only | Primary owner |
| Configuration profile application | Not involved | Not involved | Primary owner |
| Application deployment | Not involved | Not involved | Primary owner |
| Compliance policy enforcement | Not involved | Stores state | Primary owner |
| Ongoing device management | Not involved | Not involved | Primary owner |

---

## Deployment Modes

[Windows Autopilot supports several deployment modes](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-scenarios), each representing a different relationship between the device, the user, and the provisioning sequence. The mode is configured in the Autopilot deployment profile and determines how the OOBE proceeds.

### User-Driven Mode

[User-driven mode](https://learn.microsoft.com/en-us/autopilot/user-driven) is the standard mode for corporate devices assigned to individual users. The user receives the device, powers it on, and completes sign-in using their organisational credentials. Both the Device ESP phase (policies and device-targeted applications) and the User ESP phase (user-targeted applications) occur during this first boot, meaning the user waits while the device is provisioned before reaching the desktop.

User-driven mode supports both Entra join (recommended) and hybrid Entra join. It is appropriate when devices need to be associated with a specific user and when the end-to-end setup time at first boot is acceptable.

### Self-Deploying Mode

[Self-deploying mode](https://learn.microsoft.com/en-us/autopilot/self-deploying) is designed for devices that are not associated with a single user — kiosk devices, shared workstations, or meeting-room equipment. No user credentials are required during setup; instead, the device authenticates to Entra ID using its TPM 2.0 hardware attestation. Self-deploying mode is only supported for Entra join, not hybrid Entra join.

Because no user is enrolled at setup time, user-based compliance policies do not apply during the deployment phase. Only device-targeted policies are evaluated. Self-deploying mode requires TPM 2.0 and device attestation support; devices without these capabilities cannot use this mode.

### Pre-Provisioning Mode

[Pre-provisioning mode](https://learn.microsoft.com/en-us/autopilot/pre-provision) (formerly "White Glove") splits the provisioning sequence into two distinct phases separated in time. An IT technician, OEM, or reseller first completes the Device ESP phase — all device-targeted policies and applications — in a controlled environment before the device is delivered to the user. The user then receives a device where only the User ESP phase remains, dramatically reducing the time the user waits at first boot.

Pre-provisioning only supports Entra join and hybrid Entra join in the user-driven variant. It requires TPM 2.0 and device attestation. Virtual machines cannot use pre-provisioning because the self-deploying capabilities used internally require physical TPM attestation.

### Conceptual Comparison

| Characteristic | User-Driven | Self-Deploying | Pre-Provisioning |
|---|---|---|---|
| User present at setup | Yes | No | No (technician phase) + Yes (user phase) |
| User credentials required | Yes | No (TPM attestation) | No then Yes |
| Typical use case | Assigned corporate devices | Kiosk, shared, headless devices | High-volume, user-ready deployments |
| Hybrid Entra join support | Yes | No | Yes (user-driven variant only) |
| TPM 2.0 required | Recommended | Mandatory | Mandatory |
| Device ESP and User ESP | Sequential at first boot | Device ESP only | Split: Device ESP before delivery, User ESP at first boot |

---

## Related Resources

### Microsoft Learn

- [Windows Autopilot Overview](https://learn.microsoft.com/en-us/autopilot/overview)
- [Windows Autopilot Scenarios and Capabilities](https://learn.microsoft.com/en-us/autopilot/windows-autopilot-scenarios)
- [Windows Autopilot User-Driven Mode](https://learn.microsoft.com/en-us/autopilot/user-driven)
- [Windows Autopilot Self-Deploying Mode](https://learn.microsoft.com/en-us/autopilot/self-deploying)
- [Windows Autopilot for Pre-Provisioned Deployment](https://learn.microsoft.com/en-us/autopilot/pre-provision)
- [Enrolment Status Page](https://learn.microsoft.com/en-us/autopilot/enrollment-status)
- [Microsoft Entra Device Management](https://learn.microsoft.com/en-us/entra/identity/devices/)
- [Microsoft Intune Fundamentals](https://learn.microsoft.com/en-us/mem/intune/fundamentals/)
- [Cloud-Native Endpoints Overview](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/cloud-native-endpoints-overview)
- [Microsoft Entra Joined vs. Hybrid Entra Joined](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/azure-ad-joined-hybrid-azure-ad-joined)
- [What's New in Windows Autopilot](https://learn.microsoft.com/en-us/autopilot/whats-new)

### Related Documentation in This Library

- [Cloud Migration Strategy](explanation-cloud-migration.md) — Understanding the transition from hybrid to cloud-native Autopilot deployment
