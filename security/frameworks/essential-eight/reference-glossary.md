---
title: "Essential Eight Glossary"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "reference"
domain: "security"
---

# Essential Eight Glossary

**Source**: [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

---

## Contents

- [Essential Eight Controls](#essential-eight-controls)
- [Maturity Levels](#maturity-levels)
- [Microsoft Technologies](#microsoft-technologies)
- [Security Concepts](#security-concepts)
- [Compliance and Audit Terms](#compliance-and-audit-terms)
- [Technical Implementations](#technical-implementations)
- [Abbreviations and Acronyms](#abbreviations-and-acronyms)
- [Deprecated Terminology](#deprecated-terminology)
- [Related Resources](#related-resources)

---

## Essential Eight Controls

### Application Control

A security technique that prevents unauthorised applications and malicious code from executing on endpoints. Corresponds to Essential Eight Control 1. Also known as allowlisting. Implemented via AppLocker or Windows Defender Application Control (WDAC).

See also: [AppLocker](#applocker), [WDAC](#microsoft-defender-application-control-wdac), [Allow List](#allow-list-allowlisting)

### Attack Surface Reduction (ASR)

Security features in Microsoft Defender that restrict common application behaviours exploited by attackers. Used extensively in Controls 3 and 4 (Configure Macro Settings and User Application Hardening).

See also: [Microsoft Defender](#microsoft-defender), [ASR Rules](#attack-surface-reduction-asr-rules)

### Baseline Controls

The foundational security controls required at Maturity Level 1. Represent the minimum security posture for all organisations implementing the Essential Eight.

See also: [Maturity Level 1](#maturity-level-1-ml1)

### Control

One of the eight mitigation strategies in the Essential Eight framework. The eight controls are:

1. Application Control
2. Patch Applications
3. Configure Macro Settings
4. User Application Hardening
5. Restrict Administrative Privileges
6. Patch Operating Systems
7. Multi-Factor Authentication
8. Regular Backups

### Exploit

Code, a technique, or a sequence that takes advantage of a vulnerability to cause unintended behaviour in software or systems. Controls 2 and 6 focus on eliminating exploitable vulnerabilities through patching.

See also: [Vulnerability](#vulnerability), [Patch](#patch), [CVE](#cve-common-vulnerabilities-and-exposures)

### Macro

A series of automated commands in Microsoft Office applications, typically written in VBA. Essential Eight Control 3 governs the configuration of macro settings to block malicious macros while permitting legitimate business use.

See also: [VBA](#vba-visual-basic-for-applications), [Win32 API](#win32-api), [Office Macro](#office-macro)

### Maturity Level (ML)

A rating on a scale of 0 to 3 indicating how closely an organisation's implementation of the Essential Eight aligns with ACSC intent. ML0 indicates non-compliance; ML3 indicates full alignment.

See also: [Maturity Level 0](#maturity-level-0-ml0), [Maturity Level 1](#maturity-level-1-ml1), [Maturity Level 2](#maturity-level-2-ml2), [Maturity Level 3](#maturity-level-3-ml3)

### Multi-Factor Authentication (MFA)

An authentication method requiring two or more distinct verification factors. Factors include something the user knows (password), something the user has (token or phone), and something the user is (biometrics). Corresponds to Essential Eight Control 7.

See also: [Phishing-Resistant MFA](#phishing-resistant-mfa), [FIDO2](#fido2)

### Phishing-Resistant MFA

MFA methods that cannot be compromised through phishing attacks. Excludes SMS and voice call-based methods. Acceptable methods include FIDO2 security keys, Windows Hello for Business, and certificate-based authentication. Required at ML2 and above.

See also: [FIDO2](#fido2), [Windows Hello for Business](#windows-hello-for-business), [Hardware Security Key](#hardware-security-key)

### Privileged Access

Access rights that permit users to perform administrative tasks or access sensitive systems and data. Essential Eight Control 5 governs the restriction and monitoring of privileged access.

See also: [Administrative Privileges](#administrative-privileges), [Least Privilege](#least-privilege), [PAM](#privileged-access-management-pam)

### Requirement

A specific implementation task within a control at a given maturity level. Each control contains multiple requirements per maturity level, following the ACSC official pattern. Reference format: `ML#-XX-##-Descriptive-Name` (e.g., ML1-AC-01, ML2-MF-08), where `ML#` is the maturity level, `XX` is the control code (AC, PA, RM, AH, RA, PO, MF, RB), and `##` is a sequential number.

### Verification Script

A PowerShell script that validates whether a specific requirement is correctly implemented. Each requirement document has a corresponding verification script.

See also: [Compliance](#compliance)

---

## Maturity Levels

### Maturity Level 0 (ML0)

Indicates that an organisation is not aligned with ACSC intent for the Essential Eight. Represents non-compliance or implementation so partial that an ML1 rating cannot be achieved. ML0 is not an acceptable target for any organisation.

### Maturity Level 1 (ML1)

Indicates partial alignment with ACSC intent. Represents a baseline implementation of all eight controls. The minimum recommended target for all organisations. Manual and semi-automated processes are acceptable at this level.

Typical implementation timeline: 3–6 months. Estimated effort: 500–800 hours.

See also: [Baseline Controls](#baseline-controls)

### Maturity Level 2 (ML2)

Indicates mostly aligned with ACSC intent. Requires enhanced implementation with automation and phishing-resistant MFA throughout. The mandatory minimum for Australian Government entities subject to the PGPA Act and the ACSC-recommended minimum for all organisations.

Key differences from ML1: 14-day patching for exploited vulnerabilities, phishing-resistant MFA only, server-side application control, and PAM solutions.

Typical implementation timeline: 6–12 months from ML1. Estimated effort: 800–1,200 hours.

See also: [Phishing-Resistant MFA](#phishing-resistant-mfa), [Privileged Access Management (PAM)](#privileged-access-management-pam), [PGPA Act](#pgpa-act)

### Maturity Level 3 (ML3)

Indicates full alignment with ACSC intent. Requires maximum security controls with continuous monitoring. Recommended for critical infrastructure and high-risk environments.

Key differences from ML2: 48-hour extreme risk patching, universal phishing-resistant MFA, zero standing privileges, and air-gapped immutable backups.

Typical implementation timeline: 12–18 months from ML2. Estimated effort: 1,200–2,000 hours.

See also: [Zero Standing Privileges](#zero-standing-privileges), [Immutable Backups](#immutable-backups), [Critical Infrastructure](#critical-infrastructure)

---

## Microsoft Technologies

### Active Directory (AD)

Microsoft's directory service for Windows domain networks. Central to Controls 1, 5, and 7 (Application Control, Restrict Administrative Privileges, and Multi-Factor Authentication).

See also: [Group Policy Object (GPO)](#group-policy-object-gpo), [Organisational Unit (OU)](#organisational-unit-ou)

### AppLocker

An application control technology built into Windows that restricts which applications users can run, based on publisher, path, or hash rules. The primary tool for Control 1 (Application Control) implementation in on-premises environments.

Reference: [Microsoft Learn — AppLocker](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview)

See also: [WDAC](#microsoft-defender-application-control-wdac), [Application Control](#application-control)

### Attack Surface Reduction (ASR) Rules

Specific Microsoft Defender rule sets that block common attack behaviours at the application layer. Particularly relevant to Control 3 (Configure Macro Settings) via the rule that blocks Win32 API calls from Office macros.

Reference: [Microsoft Learn — ASR rules](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)

See also: [Microsoft Defender](#microsoft-defender), [Macro](#macro)

### Azure Active Directory (Azure AD)

Microsoft's former name for its cloud-based identity and access management service. Rebranded as Microsoft Entra ID in 2023. All current documentation should use the Entra ID name.

See also: [Microsoft Entra ID](#microsoft-entra-id)

### Conditional Access

A Microsoft Entra ID feature that enforces access controls based on conditions such as user location, device compliance state, and sign-in risk level. Essential for ML2 and ML3 MFA implementations under Control 7.

Reference: [Microsoft Learn — Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)

See also: [Microsoft Entra ID](#microsoft-entra-id)

### Group Policy Object (GPO)

A configuration settings container in Active Directory that applies policies to users and computers within an organisational unit. The primary deployment method for Essential Eight controls in on-premises Windows environments.

See also: [ADMX Template](#admx-template), [Active Directory (AD)](#active-directory-ad)

### Intune (Microsoft Intune)

A cloud-based endpoint management service used to deploy policies and manage devices. The primary deployment method for Essential Eight controls in cloud and hybrid environments.

Reference: [Microsoft Learn — Intune](https://learn.microsoft.com/en-us/mem/intune/)

See also: [Settings Catalog](#settings-catalog)

### Microsoft Defender

Microsoft's comprehensive threat protection platform (formerly Windows Defender). Critical for Controls 3 and 4 via ASR rules and SmartScreen.

See also: [ASR Rules](#attack-surface-reduction-asr-rules), [SmartScreen](#smartscreen)

### Microsoft Defender Application Control (WDAC)

An application control solution that enforces code integrity policies to determine what is permitted to run on a system. An alternative and enhancement to AppLocker for Control 1. Required at ML3.

Reference: [Microsoft Learn — WDAC](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview)

See also: [AppLocker](#applocker), [Application Control](#application-control)

### Microsoft Entra ID

The current name for Microsoft's cloud identity and access management platform (previously Azure Active Directory, rebranded 2023). Essential for MFA (Control 7) and Conditional Access policy enforcement.

Reference: [Microsoft Learn — Entra ID](https://learn.microsoft.com/en-us/entra/identity/)

See also: [Conditional Access](#conditional-access), [Multi-Factor Authentication (MFA)](#multi-factor-authentication-mfa)

### Settings Catalog

The modern Intune policy configuration interface providing access to all configurable settings for Windows and macOS endpoints. The preferred method for deploying Essential Eight controls via Intune.

See also: [Intune](#intune-microsoft-intune)

### SmartScreen

A Microsoft security technology that identifies and warns about phishing sites, malware, and potentially unsafe downloads. A key component of Control 4 (User Application Hardening).

See also: [Microsoft Defender](#microsoft-defender)

### Windows Hello for Business

A biometric and PIN-based Windows authentication mechanism that replaces traditional passwords. An acceptable phishing-resistant MFA option at ML2 and ML3 under Control 7. Requires a Trusted Platform Module (TPM).

Reference: [Microsoft Learn — Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/)

See also: [Phishing-Resistant MFA](#phishing-resistant-mfa), [FIDO2](#fido2), [Trusted Platform Module (TPM)](#trusted-platform-module-tpm)

### Windows Security Baseline

Microsoft's recommended group of security configuration settings for Windows. Provides a foundation for Essential Eight implementation, particularly Controls 4 and 5.

Reference: [Microsoft Security Baselines](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)

### Windows Server Update Services (WSUS)

An on-premises Windows Server role for managing the distribution of Microsoft updates to endpoints. Used for Control 6 (Patch Operating Systems) in on-premises environments.

See also: [Patch](#patch)

---

## Security Concepts

### Administrative Privileges

Elevated permissions that allow users to make system-wide configuration changes. Essential Eight Control 5 governs the restriction of these privileges to only those users who require them.

See also: [Least Privilege](#least-privilege), [Privileged Access](#privileged-access)

### Air Gap

Physical or logical isolation of a network or system from other networks, including the internet. Required for backup isolation at ML3 under Control 8 (Regular Backups).

See also: [Disconnected Backups](#disconnected-backups), [Immutable Backups](#immutable-backups)

### Allow List (Allowlisting)

A security approach that permits only explicitly approved items — applications, executables, scripts — to run. The foundational concept for Control 1 (Application Control). The inverse of blocklisting.

Note: "Allowlist" supersedes the deprecated term "whitelist".

See also: [Application Control](#application-control)

### Biometric Authentication

Authentication using biological characteristics such as fingerprint, face recognition, or iris scan. An acceptable phishing-resistant MFA method at ML3 under Control 7.

See also: [Windows Hello for Business](#windows-hello-for-business), [FIDO2](#fido2)

### Break Glass Account

An emergency access account used when normal authentication methods are unavailable. Required at ML3 as part of Controls 5 and 7 to ensure continuity of administrative access.

See also: [Privileged Access](#privileged-access)

### Certificate-Based Authentication

Authentication using digital certificates in place of passwords. An acceptable phishing-resistant MFA option at ML2 and above under Control 7.

See also: [Public Key Infrastructure (PKI)](#certificate-authority-ca), [Smart Card](#smart-card)

### Compensating Control

An alternative security measure applied when a primary control cannot be implemented. Relevant to ML3 patching requirements under Controls 2 and 6 when patches are unavailable from the vendor.

See also: [Virtual Patching](#virtual-patching)

### Credential Stuffing

An automated attack using stolen username and password pairs to attempt unauthorised access to systems. Mitigated by Control 7 (Multi-Factor Authentication).

See also: [Phishing](#phishing)

### Defence in Depth

A security strategy employing multiple complementary layers of protective controls. The Essential Eight represents a defence-in-depth approach through eight mutually reinforcing controls.

### Digital Signature

A cryptographic technique used to verify the authenticity and integrity of code or documents. Required for macro and application validation under Controls 1 and 3.

See also: [Code Signing](#code-signing), [Certificate Authority (CA)](#certificate-authority-ca)

### Disconnected Backups

Backups that are offline or otherwise isolated from production systems and networks. Required at ML1 and above under Control 8 (Regular Backups).

See also: [Air Gap](#air-gap), [Immutable Backups](#immutable-backups)

### Endpoint Detection and Response (EDR)

Security technology that monitors endpoints continuously for threat detection and response. Complementary to the Essential Eight, particularly for monitoring enforcement of Control 1.

See also: [Microsoft Defender](#microsoft-defender)

### Exception Management

The process of documenting and formally approving deviations from security policies. Required across all controls, particularly Application Control and patching (Controls 1, 2, and 6).

See also: [Risk Acceptance](#risk-acceptance), [Compensating Control](#compensating-control)

### Hash

A fixed-size cryptographic output derived from input data, used for identity verification of files. Used in Application Control (Control 1) to uniquely identify permitted executables.

See also: [SHA-256](#sha-256)

### Immutable Backups

Backups configured so that data cannot be modified or deleted for a defined retention period. Required at ML2 and above under Control 8 to prevent ransomware from destroying backup data.

See also: [Write-Once-Read-Many (WORM)](#write-once-read-many-worm), [Air Gap](#air-gap)

### Internet-Facing

A designation applied to systems or services accessible from the public internet. A critical classification for prioritised patching timelines (Controls 2 and 6) and MFA requirements (Control 7).

See also: [Online Services](#online-services)

### Just-Enough-Administration (JEA)

A PowerShell-based technology that restricts administrative commands to only those required for specific roles. A component of ML3 zero standing privileges under Control 5.

See also: [Just-In-Time (JIT) Access](#just-in-time-jit-access), [Least Privilege](#least-privilege)

### Just-In-Time (JIT) Access

A model in which privileged access is granted only when needed and for a limited duration, then automatically revoked. Required at ML2 and above under Control 5 (Restrict Administrative Privileges).

See also: [Privileged Access Management (PAM)](#privileged-access-management-pam)

### Lateral Movement

A technique by which an attacker moves from one compromised system to others within a network. Mitigated by Control 5 (Restrict Administrative Privileges) and Control 1 (Application Control).

### Least Privilege

The security principle of granting users only the minimum access rights required to perform their duties. The core principle underlying Control 5 (Restrict Administrative Privileges).

See also: [Privileged Access](#privileged-access), [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)

### Local Administrator

An account with full administrative rights on a local computer. ML1 requires removal of local administrator rights from standard user accounts under Control 5.

See also: [Administrative Privileges](#administrative-privileges)

### Malvertising

Malicious advertising used to deliver malware or redirect users to malicious sites. Addressed by Control 4 (User Application Hardening) through advertisement blocking.

See also: [Exploit Kit](#exploit-kit)

### Online Services

Cloud-based or web-based services accessed over the internet. Encompasses both an organisation's own internet-facing services (corporate portals, web applications, public APIs, remote access gateways) and third-party hosted SaaS platforms (Microsoft 365, Salesforce, and equivalent cloud-hosted productivity platforms).

The ACSC uses "online services" in Essential Eight Control 7 (MFA) to distinguish between an organisation's own online services (ML1-MF-01) and third-party online services (ML1-MF-02). Control 2 (Patch Applications) requires daily vulnerability scanning and 48-hour critical patching for online services.

See also: [Internet-Facing](#internet-facing)

### Organisational Unit (OU)

An Active Directory container used to organise users, computers, and other directory objects. Used to scope Group Policy Object (GPO) application for Essential Eight controls.

See also: [Active Directory (AD)](#active-directory-ad), [Group Policy Object (GPO)](#group-policy-object-gpo)

### Passwordless Authentication

Authentication that does not rely on a traditional password, using biometrics, FIDO2 security keys, or digital certificates instead. An acceptable phishing-resistant MFA method at ML2 and above under Control 7.

See also: [Windows Hello for Business](#windows-hello-for-business), [FIDO2](#fido2)

### Patch

A software update that fixes a vulnerability, bug, or security weakness in an application or operating system. The central subject of Controls 2 and 6 (Patch Applications and Patch Operating Systems).

See also: [Vulnerability](#vulnerability), [CVE](#cve-common-vulnerabilities-and-exposures)

### Patch Tuesday

The second Tuesday of each month, when Microsoft releases its scheduled security updates. A key date for patching timelines relevant to Controls 2 and 6.

### Penetration Testing

An authorised, simulated cyberattack conducted to evaluate the effectiveness of security controls. Recommended for validating Essential Eight implementation.

### Phishing

A social engineering attack using deceptive communications to steal credentials or deploy malware. ML2 and above require phishing-resistant MFA under Control 7 specifically to defend against credential theft via phishing.

See also: [Phishing-Resistant MFA](#phishing-resistant-mfa)

### Privilege Escalation

Exploiting a vulnerability or misconfiguration to gain access rights beyond those originally granted. Mitigated by Control 5 (Restrict Administrative Privileges) and Controls 2 and 6 (patching).

### Privileged Access Management (PAM)

A solution that manages, monitors, and audits privileged account access. Required at ML2 and above under Control 5 (Restrict Administrative Privileges).

See also: [Just-In-Time (JIT) Access](#just-in-time-jit-access), [Session Recording](#session-recording)

### Privileged Access Workstation (PAW)

A hardened workstation used exclusively for performing administrative tasks, isolated from standard user workloads. Required at ML3 under Control 5.

### Ransomware

Malware that encrypts victim data and demands payment in exchange for the decryption key. The Essential Eight is explicitly designed to prevent ransomware impact and enable recovery. Control 8 (Regular Backups) enables data recovery without paying a ransom.

### Recovery Point Objective (RPO)

The maximum acceptable amount of data loss, expressed as a time period. Defined in ML2 requirements under Control 8 (Regular Backups).

See also: [Recovery Time Objective (RTO)](#recovery-time-objective-rto)

### Recovery Time Objective (RTO)

The maximum acceptable time to restore systems and resume operations after an incident. Defined in ML2 requirements under Control 8 (Regular Backups).

See also: [Recovery Point Objective (RPO)](#recovery-point-objective-rpo)

### Risk Acceptance

The formal acknowledgement and acceptance of residual risk remaining after controls have been applied. The required process for documenting exceptions to Essential Eight requirements.

See also: [Exception Management](#exception-management)

### Role-Based Access Control (RBAC)

An access control model that assigns permissions based on defined roles rather than individual user identity. A component of Control 5 (Restrict Administrative Privileges) implementation.

See also: [Least Privilege](#least-privilege)

### Security Information and Event Management (SIEM)

A system that aggregates and analyses security-relevant log data from multiple sources. Recommended for monitoring administrative activity (Control 5) and macro execution (Control 3).

### Session Recording

The capture of privileged user sessions for audit and forensic purposes. Required at ML2 and above under Control 5 (Restrict Administrative Privileges).

See also: [Privileged Access Management (PAM)](#privileged-access-management-pam)

### Social Engineering

Psychological manipulation intended to trick users into divulging sensitive information or performing security-relevant actions. Mitigated by Control 7 (MFA) and Control 4 (User Application Hardening).

### Supply Chain Attack

A cyberattack that targets a less-secure element in an organisation's supply chain to compromise the primary target. Addressed by Control 1 (Application Control) and Controls 2 and 6 (patching).

### Threat Actor

An individual or group conducting malicious cyber activities. The Essential Eight controls are designed to defend against a range of threat actor tactics, techniques, and procedures (TTPs).

### Trusted Location

A file system path configured in Microsoft Office from which macros are permitted to run without restriction. Control 3 (Configure Macro Settings) requires that trusted locations be controlled and minimised.

See also: [Macro](#macro)

### Virtual Patching

A security layer that protects against a known vulnerability without modifying the vulnerable code itself. An acceptable compensating control at ML3 when vendor patches are unavailable under Controls 2 and 6.

See also: [Compensating Control](#compensating-control)

### Vulnerability

A weakness in software that could be exploited to compromise the security of a system. The central subject of Controls 2 and 6, which require timely patching to eliminate known vulnerabilities.

See also: [CVE](#cve-common-vulnerabilities-and-exposures), [Exploit](#exploit), [Patch](#patch)

### Vulnerability Assessment

The process of identifying, quantifying, and prioritising vulnerabilities in systems and applications. Required at ML1 and above under Controls 2 and 6. At ML3, continuous real-time assessment is required.

See also: [CVE](#cve-common-vulnerabilities-and-exposures), [CVSS](#cvss-common-vulnerability-scoring-system)

### Write-Once-Read-Many (WORM)

A storage technology that permits data to be written once and read an unlimited number of times without modification. An acceptable technical implementation for immutable backups at ML2 and above under Control 8.

See also: [Immutable Backups](#immutable-backups)

### Zero Standing Privileges

A model in which no permanent administrative rights exist — all privileged access is temporary and granted on demand. Required at ML3 under Control 5 (Restrict Administrative Privileges).

See also: [Just-In-Time (JIT) Access](#just-in-time-jit-access), [Just-Enough-Administration (JEA)](#just-enough-administration-jea)

### Zero Trust

A security model operating on the principle that no implicit trust exists for any user, device, or network, and that every access request must be verified. ML3 requirements across Controls 5 and 7 align with zero trust principles.

---

## Compliance and Audit Terms

### Australian Cyber Security Centre (ACSC)

Australia's lead cyber security agency and the publisher of the Essential Eight Maturity Model. Part of the Australian Signals Directorate (ASD).

Website: [https://www.cyber.gov.au](https://www.cyber.gov.au)

See also: [Australian Signals Directorate (ASD)](#australian-signals-directorate-asd)

### Australian Signals Directorate (ASD)

Australia's signals intelligence, cyber security, and offensive cyber operations agency. The parent organisation of the ACSC.

### Compliance

The state of adhering to established requirements, standards, or regulations. Essential Eight compliance is measured by the maturity level achieved across all eight controls.

### Critical Infrastructure

Assets, systems, and networks essential to the functioning of society and the economy. The ACSC recommends ML3 for organisations operating critical infrastructure.

Reference: [Security of Critical Infrastructure Act 2018](https://www.legislation.gov.au/Series/C2018A00029)

### CVE (Common Vulnerabilities and Exposures)

A public catalogue system providing standardised identifiers for known cybersecurity vulnerabilities. Used to track specific vulnerabilities requiring patches under Controls 2 and 6.

Format: `CVE-YYYY-NNNNN` (e.g., `CVE-2023-12345`)

Reference: [https://cve.mitre.org](https://cve.mitre.org)

### CVSS (Common Vulnerability Scoring System)

A standardised framework for assessing the severity of security vulnerabilities on a scale of 0 to 10. Used to prioritise patching decisions under Controls 2 and 6.

Severity bands: Low (0.1–3.9), Medium (4.0–6.9), High (7.0–8.9), Critical (9.0–10.0)

### Essential Eight Assessment

A formal evaluation of an organisation's Essential Eight implementation maturity. May be self-assessed or conducted by an ACSC-authorised assessor.

Reference: [ACSC Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)

### Evidence

Documentation, configurations, logs, or artefacts that demonstrate control implementation. Required for compliance assessment and audit purposes across all eight controls.

### Governance

The framework of policies, procedures, and controls through which security objectives are established and maintained. Essential Eight implementation requires governance processes covering exception management, periodic review, and control updates.

### ISO 27001

The international standard for information security management systems (ISMS). Essential Eight implementation supports ISO 27001 compliance through overlapping control objectives.

Reference: [ISO/IEC 27001:2022](https://www.iso.org/standard/82875.html)

### PGPA Act

The Public Governance, Performance and Accountability Act 2013. Australian Government entities subject to this legislation are required to achieve a minimum of ML2 under the Protective Security Policy Framework (PSPF).

Reference: [PGPA Act](https://www.legislation.gov.au/Series/C2013A00123)

See also: [Protective Security Policy Framework (PSPF)](#protective-security-policy-framework-pspf)

### Protective Security Policy Framework (PSPF)

The Australian Government policy framework for protecting people, information, and assets. References the Essential Eight as mandatory security controls for Commonwealth entities.

Reference: [https://www.protectivesecurity.gov.au](https://www.protectivesecurity.gov.au)

---

## Technical Implementations

### ADMX Template

An XML-based Group Policy template file that defines the available policy settings for a product or service. Used to expose Essential Eight configuration options via Group Policy.

See also: [Group Policy Object (GPO)](#group-policy-object-gpo)

### Application Reputation

A trust rating assigned to applications based on factors including prevalence, digital certificate chain, and observed behaviour. Used in ML3 Application Control (Control 1) for enhanced application validation.

### Certificate Authority (CA)

An entity authorised to issue digital certificates. Required for code signing under Control 1 and certificate-based authentication under Control 7.

See also: [Digital Signature](#digital-signature), [Code Signing](#code-signing)

### Code Signing

The practice of digitally signing executables and scripts to verify publisher identity and confirm that code has not been tampered with. Required for Application Control (Control 1) and Configure Macro Settings (Control 3).

See also: [Digital Signature](#digital-signature), [Certificate Authority (CA)](#certificate-authority-ca)

### Configuration Management Database (CMDB)

A repository storing information about IT assets and their relationships. Supports asset inventory requirements in Controls 2 and 6 (patching).

### DLL (Dynamic Link Library)

A Windows file format containing code and data shared across multiple programs. ML2 and above require DLL-level application control under Control 1 to prevent DLL injection attacks.

See also: [Application Control](#application-control)

### DNS Filtering

The use of DNS to block access to malicious or unwanted websites at the network level. A component of ML2 User Application Hardening (Control 4).

### Driver

Software that allows an operating system to communicate with hardware devices. ML3 Application Control (Control 1) requires driver-level control to prevent kernel-mode exploitation.

### FIDO2

The [FIDO Alliance](https://fidoalliance.org) authentication standard that enables passwordless login using hardware security keys or device biometrics. An acceptable phishing-resistant MFA method at ML2 and above under Control 7.

See also: [Hardware Security Key](#hardware-security-key), [Windows Hello for Business](#windows-hello-for-business)

### Hardware Security Key

A physical device that stores cryptographic keys used for authentication. An acceptable phishing-resistant MFA method at ML2 and the preferred method at ML3 under Control 7.

Examples: YubiKey, Titan Security Key

See also: [FIDO2](#fido2)

### Hypervisor-Protected Code Integrity (HVCI)

A Windows security feature that uses hardware virtualisation to protect the code integrity validation process. Enhances Application Control and driver control at ML3 under Control 1.

See also: [Virtualization-Based Security (VBS)](#virtualization-based-security-vbs)

### Indicator of Compromise (IOC)

Observable artefacts indicating that a security incident may have occurred. Monitored as part of advanced security operations that complement Essential Eight baseline controls.

### Mark of the Web (MotW)

An NTFS alternate data stream that identifies files downloaded from the internet. Used by Control 3 (Configure Macro Settings) to block the execution of internet-sourced macros.

See also: [NTFS](#ntfs-new-technology-file-system)

### NTFS (New Technology File System)

The default file system for Windows operating systems. Supports features used across multiple Essential Eight controls, including Mark of the Web, file permissions, and encryption.

### Office Macro

An automation script embedded in a Microsoft Office application, typically written in VBA. The subject of Control 3 (Configure Macro Settings).

See also: [VBA (Visual Basic for Applications)](#vba-visual-basic-for-applications), [Macro](#macro)

### PowerShell Constrained Language Mode

A PowerShell execution mode that restricts available cmdlets, types, and language features. A component of ML2 and above script control under Application Control (Control 1).

### Publisher Rule

An application control rule that permits software signed by a trusted publisher certificate. The primary rule type for ML1 Application Control (Control 1) implementations.

See also: [Code Signing](#code-signing)

### Registry

The Windows hierarchical database that stores system and application configuration settings. Multiple Essential Eight controls are applied or enforced through registry key configuration.

### Remote Desktop Protocol (RDP)

Microsoft's protocol for graphical remote access to Windows systems. Requires MFA at ML1 and above when accessible from the internet under Control 7.

See also: [Internet-Facing](#internet-facing)

### Security Baseline

A minimum security configuration for systems or applications, defining the lowest acceptable state of hardening. Essential Eight requirements define security baselines for Windows environments.

### Security Identifier (SID)

A unique identifier for security principals in Windows, including users, groups, and computers. Used in access control policy and administrative privilege management under Control 5.

### SHA-256

A cryptographic hash function that produces a 256-bit hash value. The standard hash algorithm used in Application Control (Control 1) for file identification and integrity verification.

See also: [Hash](#hash)

### Smart Card

A physical card containing an embedded integrated circuit used for authentication. An acceptable phishing-resistant MFA option at ML2 and above under Control 7.

See also: [Certificate-Based Authentication](#certificate-based-authentication)

### Temporal Access

Time-limited access privileges that expire automatically after a defined duration. A component of Just-In-Time access under ML2 and above for Control 5 (Restrict Administrative Privileges).

See also: [Just-In-Time (JIT) Access](#just-in-time-jit-access)

### Trusted Platform Module (TPM)

A hardware module providing cryptographic functions and secure key storage. Required for Windows Hello for Business (Control 7) and BitLocker drive encryption.

### User Account Control (UAC)

A Windows security feature that prompts for elevation when administrative actions are requested. Complements Control 5 (Restrict Administrative Privileges) but does not substitute for removing local administrator rights from standard users.

### VBA (Visual Basic for Applications)

The programming language used to write Microsoft Office macros. The primary macro language governed by Control 3 (Configure Macro Settings).

See also: [Macro](#macro), [Office Macro](#office-macro)

### Virtual Private Network (VPN)

An encrypted tunnel over public networks providing secure remote access to internal resources. Requires MFA at ML1 and above when internet-facing under Control 7.

### Virtualization-Based Security (VBS)

A Windows feature that uses hardware virtualisation to create an isolated security boundary. Enables HVCI and Credential Guard, which enhance Controls 1 and 5.

See also: [Hypervisor-Protected Code Integrity (HVCI)](#hypervisor-protected-code-integrity-hvci)

### Win32 API

The core set of Windows application programming interfaces. ML2 and above require that Win32 API calls from Office macros be blocked under Control 3 (Configure Macro Settings).

See also: [Macro](#macro), [ASR Rules](#attack-surface-reduction-asr-rules)

---

## Abbreviations and Acronyms

| Acronym | Full Term | Notes |
|---------|-----------|-------|
| **ACSC** | Australian Cyber Security Centre | Australia's lead cyber security agency |
| **AD** | Active Directory | Microsoft directory service |
| **ADMX** | Administrative Template XML | Group Policy template format |
| **ASD** | Australian Signals Directorate | Parent organisation of ACSC |
| **ASR** | Attack Surface Reduction | Microsoft Defender security features |
| **CA** | Certificate Authority | Entity that issues digital certificates |
| **CMDB** | Configuration Management Database | IT asset repository |
| **CVE** | Common Vulnerabilities and Exposures | Vulnerability identifier system |
| **CVSS** | Common Vulnerability Scoring System | Vulnerability severity scoring (0–10) |
| **DLL** | Dynamic Link Library | Windows shared library file |
| **DNS** | Domain Name System | Internet naming system |
| **E8** | Essential Eight | Shorthand for the Essential Eight framework |
| **EDR** | Endpoint Detection and Response | Endpoint security technology |
| **FIDO** | Fast IDentity Online | Passwordless authentication standard |
| **GPO** | Group Policy Object | Active Directory policy container |
| **HVCI** | Hypervisor-Protected Code Integrity | Virtualisation-based code protection |
| **IOC** | Indicator of Compromise | Security incident artefact |
| **ISO** | International Organisation for Standardisation | Standards body |
| **JEA** | Just-Enough-Administration | PowerShell limited administration framework |
| **JIT** | Just-In-Time | Temporal access model |
| **MFA** | Multi-Factor Authentication | Multi-step authentication |
| **ML** | Maturity Level | Essential Eight implementation level (0–3) |
| **ML1** | Maturity Level 1 | Baseline Essential Eight implementation |
| **ML2** | Maturity Level 2 | Enhanced Essential Eight implementation |
| **ML3** | Maturity Level 3 | Maximum Essential Eight implementation |
| **MotW** | Mark of the Web | Internet origin identifier (NTFS ADS) |
| **NTFS** | New Technology File System | Windows file system |
| **OU** | Organisational Unit | Active Directory container |
| **PAM** | Privileged Access Management | Privileged account management solution |
| **PAW** | Privileged Access Workstation | Hardened administrative workstation |
| **PGPA** | Public Governance, Performance and Accountability Act | Australian Government accountability legislation |
| **PIV** | Personal Identity Verification | Smart card standard |
| **PKI** | Public Key Infrastructure | Certificate-based security infrastructure |
| **PSPF** | Protective Security Policy Framework | Australian Government security framework |
| **RBAC** | Role-Based Access Control | Permission assignment by role |
| **RDP** | Remote Desktop Protocol | Windows remote access protocol |
| **RPO** | Recovery Point Objective | Acceptable data loss timeframe |
| **RTO** | Recovery Time Objective | Acceptable recovery timeframe |
| **SHA** | Secure Hash Algorithm | Cryptographic hash function family |
| **SID** | Security Identifier | Windows security principal identifier |
| **SIEM** | Security Information and Event Management | Security log aggregation system |
| **SMS** | Short Message Service | Text messaging — not phishing-resistant at ML2+ |
| **TPM** | Trusted Platform Module | Hardware security module |
| **UAC** | User Account Control | Windows privilege elevation prompt |
| **VBA** | Visual Basic for Applications | Office macro programming language |
| **VBS** | Virtualization-Based Security | Hardware virtualisation security isolation |
| **VPN** | Virtual Private Network | Encrypted remote access connection |
| **WDAC** | Windows Defender Application Control | Application control technology |
| **WORM** | Write-Once-Read-Many | Immutable storage technology |
| **WSUS** | Windows Server Update Services | On-premises update management service |
| **XDR** | Extended Detection and Response | Cross-platform threat detection platform |

---

## Deprecated Terminology

The following terms are deprecated. Use the replacements listed.

| Deprecated Term | Replacement | Reason |
|-----------------|-------------|--------|
| Whitelist / Blacklist | Allowlist / Blocklist | Updated inclusive terminology |
| Azure Active Directory (Azure AD) | Microsoft Entra ID | Microsoft product rebrand (2023) |
| Windows Defender | Microsoft Defender | Microsoft product line rebrand |

---

## Related Resources

### ACSC Essential Eight Publications

- [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [Essential Eight Maturity Model FAQ (October 2024)](https://www.cyber.gov.au/sites/default/files/2025-03/Essential%20Eight%20maturity%20model%20FAQ%20(October%202024).pdf)
- [Essential Eight Assessment Process Guide](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-assessment-process-guide)
- [ACSC Glossary](https://www.cyber.gov.au/resources/glossary)
- [Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [Protective Security Policy Framework (PSPF)](https://www.protectivesecurity.gov.au/)

### Australian Legislation

- [Security of Critical Infrastructure Act 2018](https://www.legislation.gov.au/Series/C2018A00029)
- [Public Governance, Performance and Accountability Act 2013](https://www.legislation.gov.au/Series/C2013A00123)

### Microsoft Technology References

- [App Control for Business / AppLocker Overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/appcontrol-and-applocker-overview)
- [Attack Surface Reduction Rules Reference](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)
- [Conditional Access Overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [Microsoft Intune Documentation](https://learn.microsoft.com/en-us/mem/intune/)
- [Windows Hello for Business Overview](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/)
- [Windows Security Baselines](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)

### Industry Standards

- [FIDO Alliance — FIDO2 Standard](https://fidoalliance.org/fido2/)
- [ISO/IEC 27001:2022](https://www.iso.org/standard/82875.html)
- [CVE Programme](https://cve.mitre.org)

---

## Sibling Documents

- [reference-maturity-model.md](reference-maturity-model.md) — Maturity model definitions and per-control requirement tables
- [reference-cross-reference-matrix.md](reference-cross-reference-matrix.md) — Control dependencies and sequencing
- [how-to-implement-e8-controls.md](how-to-implement-e8-controls.md) — Implementation guidance
- [explanation-why-essential-eight.md](explanation-why-essential-eight.md) — Strategic context
