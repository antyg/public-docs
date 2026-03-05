# Endpoint Protection & Security — SCCM-to-Intune Assessment

**Document Version**: 1.0
**Assessment Date**: 2026-02-18
**SCCM Version Assessed**: Current Branch 2403+
**Intune Version Assessed**: Current production (February 2026)
**Overall Parity Rating**: Full Parity to Intune Advantage

---

## Executive Summary

Endpoint Protection & Security is the **strongest parity area** in the SCCM-to-Intune capability assessment. Microsoft Intune meets or exceeds SCCM Endpoint Protection capabilities across all major domains: antivirus policy management, firewall configuration, Attack Surface Reduction (ASR) rules, and security baselines. Intune's **native Microsoft Defender for Endpoint (MDE) integration** provides significant advantages over SCCM's tenant attach requirement, enabling risk-based Conditional Access, automated remediation tasks, and unified security console visibility. Organizations migrating endpoint security workloads gain cloud-native security baselines, advanced ASR rule management with granular audit mode support, and Tamper Protection central management. The only minor gap is SCCM's Software Update Point control for Defender definition updates, which Intune replaces with Windows Update-based delivery (adequate for most environments).

---

## Feature Parity Matrix

| SCCM Feature                                                                                                 | Intune Equivalent                                     | Parity Rating    | Licensing                 | Notes                                                                                  |
| ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------- | ---------------- | ------------------------- | -------------------------------------------------------------------------------------- |
| **Endpoint Protection Site System Role**                                                                     | Endpoint Security Node (Intune)                       | Full Parity      | Intune Plan 1             | Intune provides unified endpoint security management without infrastructure            |
| **Antimalware Policies (Scheduled Scans, Real-Time Protection, Exclusions)**                                 | Antivirus Policies (Endpoint Security)                | Full Parity      | Intune Plan 1             | Both configure Microsoft Defender Antivirus; Intune uses modern CSP-based config       |
| **Microsoft Defender Antivirus Definition Updates**                                                          | Automatic via MDE / Windows Update                    | Full Parity      | Intune Plan 1             | Intune relies on Windows Update; SCCM can distribute via SUP (more control)            |
| **Windows Firewall Policies**                                                                                | Firewall Policies (Endpoint Security)                 | Full Parity      | Intune Plan 1             | Both manage Windows Defender Firewall; Intune supports advanced rule creation natively |
| **Microsoft Defender Exploit Guard (ASR, Controlled Folder Access, Network Protection, Exploit Protection)** | Attack Surface Reduction Policies (Endpoint Security) | Full Parity      | Intune Plan 1             | Intune provides granular ASR rule management with audit mode support                   |
| **Microsoft Defender for Endpoint Onboarding**                                                               | Native MDE Integration                                | Intune Advantage | MDE P1/P2 + Intune Plan 1 | Intune native onboarding; SCCM requires tenant attach for MDE onboarding               |
| **Endpoint Protection Reports (Agent Status, Malware Detections)**                                           | Endpoint Security Reports + MDE Portal                | Full Parity      | Intune Plan 1 + MDE P1/P2 | Intune has built-in antivirus reports; MDE portal provides advanced analytics          |
| **Security Baselines (Windows, Office, Edge)**                                                               | Security Baselines (Intune)                           | Intune Advantage | Intune Plan 1             | Intune baselines include Windows, Edge, M365 Apps, MDE, Windows 365                    |
| **Tamper Protection Management**                                                                             | Tamper Protection via MDE/Intune                      | Intune Advantage | MDE P1+ or Windows E5     | Intune manages Tamper Protection centrally; SCCM has limited support                   |
| **Security Configuration Management (MDE SCM)**                                                              | Native Capability                                     | Intune Advantage | MDE P2                    | MDE Security Configuration Management allows policy delivery to non-enrolled devices   |
| **Endpoint Protection Client Deployment**                                                                    | MDM Enrollment                                        | Full Parity      | Intune Plan 1             | SCCM deploys EP client; Intune uses built-in Windows Defender (no separate client)     |
| **Cloud Protection Service (MAPS)**                                                                          | Cloud Protection (Antivirus Policy)                   | Full Parity      | Intune Plan 1             | Both configure Microsoft Active Protection Service (MAPS) for cloud-based detection    |
| **Potentially Unwanted Applications (PUA) Blocking**                                                         | PUA Blocking (Antivirus Policy)                       | Full Parity      | Intune Plan 1             | Intune supports PUA blocking in audit and block modes                                  |
| **Controlled Folder Access**                                                                                 | Controlled Folder Access (ASR Policy)                 | Full Parity      | Intune Plan 1             | Both protect specified folders from ransomware encryption                              |

---

## Key Findings

### 1. Full Parity Areas

#### 1.1 Antimalware and Antivirus Policy Management

**SCCM Capability**: Configuration Manager Endpoint Protection antimalware policies configure Microsoft Defender Antivirus through device collections. Policy settings include:

**Scheduled Scans**:

- Scan type: Quick scan, Full scan, or both
- Scan schedule: Day of week, time, randomization (for VDI)
- CPU throttling during scans (percentage)
- User control: Allow users to schedule scans
- Scan settings: Check for latest definitions before scan, scan removable drives, scan network files, scan archives

**Scan Settings (Detailed)**:

- Email scanning (scan email messages and attachments)
- Removable storage scanning (USB drives, external drives)
- Network file scanning (mapped drives and UNC paths)
- Archived file scanning (.zip, .cab, etc.)
- Reparse point scanning (symbolic links)

**Real-Time Protection**:

- Enable/disable real-time protection
- Monitor file and program activity on the computer
- Scan system files: Incoming, outgoing, or both
- Behavior monitoring (cloud-powered protection for suspicious behavior)
- Network-based exploit protection (Network Inspection System)
- Script scanning (PowerShell, JavaScript, VBScript)

**Default Actions (Per Threat Level)**:

- Severe: Recommended action, Quarantine, Remove, Allow
- High: Recommended action, Quarantine, Remove, Allow
- Medium: Recommended action, Quarantine, Remove, Allow
- Low: Recommended action, Quarantine, Remove, Allow

**Exclusions**:

- Files and folders (full path or wildcard patterns)
- File extensions (.log, .tmp, etc.)
- Processes (exclude files opened by specific executables)

**Advanced Settings**:

- Create system restore point before cleaning
- Disable client UI (hide Defender interface from users)
- Randomize scheduled scan start times (for VDI to prevent scan storms)
- Use low CPU priority for scheduled scans
- Scan only when computer is idle

**Cloud Protection Service (MAPS)**:

- Membership level: None, Basic, Advanced
- Blocking level: Normal, High, High+, Zero tolerance
- Extended cloud check timeout (seconds)
- Automatic sample submission: Send safe samples, Always prompt, Never send, Send all samples automatically

**Definition Updates**:

- Source priority order: WSUS, Microsoft Update, UNC file shares
- Fallback sources if primary unavailable
- Update schedule (separate from scan schedule)

Policies deploy to device collections with custom policies overriding the default policy. SCCM supports policy precedence based on collection membership.

**Intune Capability**: Intune Endpoint Security **Antivirus policies** configure Microsoft Defender Antivirus via Windows Configuration Service Providers (CSPs). The policy interface groups settings into logical categories:

**Platform Support**: Windows 10/11, Windows Server (with Defender Antivirus installed), macOS (Microsoft Defender for Endpoint on macOS)

**Policy Templates**:

- **Microsoft Defender Antivirus** (Windows 10/11)
- **Microsoft Defender Antivirus exclusions** (Windows 10/11)
- **Windows Security experience** (Windows 10/11)
- **Microsoft Defender Antivirus** (macOS)

**Configuration Coverage** (Windows):

- All SCCM settings available (scheduled scans, real-time protection, exclusions, cloud protection, definition updates)
- Additional settings not in SCCM:
  - **Tamper Protection**: Prevent users from disabling Defender (requires MDE P1+ or Windows E5)
  - **PUA Protection**: Block potentially unwanted applications (audit or block mode)
  - **Attack Surface Reduction**: Configure 18+ ASR rules with per-rule actions
  - **Controlled Folder Access**: Protect folders from ransomware
  - **Network Protection**: Block connections to malicious domains and IPs
  - **Exploit Protection**: Process-level mitigation settings (DEP, ASLR, CFG, etc.)

**Policy Assignment**:

- Assign to Entra ID device groups or user groups
- Supports filters (OS version, manufacturer, ownership type)
- Settings merge across policies (superset model unless conflicts exist)
- Device and user-scoped policies supported

**Integration Advantages**:

- Real-time compliance reporting (device compliance based on Defender status)
- MDE integration for threat detection and automated response
- Conditional Access enforcement based on device risk (requires MDE)
- Unified Endpoint Security console (vs. SCCM's separate Endpoint Protection node)

**Parity Assessment**: **Full Parity**. Intune replicates all critical SCCM antimalware policy settings with modern CSP-based configuration. The cloud-integrated approach provides equivalent functionality with improved visibility and automation.

**Migration Considerations**:

- Export SCCM antimalware policies (XML or via PowerShell)
- Map SCCM policy settings to Intune Antivirus policy templates
- Test policies with pilot group before broad deployment (especially Tamper Protection and PUA blocking)
- Enable Defender Antivirus reporting in Intune Endpoint Security console
- Verify exclusions migrate correctly (file paths, extensions, processes)

**Sources**:

- [Endpoint Protection antimalware policies - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/endpoint-antimalware-policies)
- [Manage endpoint security in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security)
- [Antivirus policy settings for Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-antivirus-policy)

#### 1.2 Windows Firewall Management

**SCCM Capability**: Configuration Manager Endpoint Protection Windows Firewall policies provide basic firewall configuration:

- **Enable/disable firewall** per profile (Domain, Private, Public)
- **Block all incoming connections** (including allowed apps list)
- **Notify user when a new app is blocked**

**Limitation**: SCCM Firewall policies do **NOT** configure granular inbound/outbound rules. For advanced firewall rule management (port-specific rules, application rules, remote IP filtering), SCCM environments use Group Policy.

**Intune Capability**: Intune Endpoint Security **Firewall policies** provide comprehensive firewall management without Group Policy dependency:

**Policy Templates**:

- **Microsoft Defender Firewall** (Windows 10/11)
- **Microsoft Defender Firewall Rules** (Windows 10/11)

**Configuration Options**:

- Enable/disable per profile (Domain, Private, Public)
- Default inbound action (Block, Allow, NotConfigured)
- Default outbound action (Block, Allow, NotConfigured)
- Block all incoming connections (override allow rules)
- Stealth mode (don't respond to ping/port scans)
- Firewall notification settings
- Global port rules (allow/block specific ports globally)
- IPsec settings (authentication, encryption)

**Firewall Rules (Granular)**:

- **Rule name and description**
- **Action**: Allow, Block
- **Direction**: Inbound, Outbound
- **Protocol**: TCP, UDP, ICMPv4, ICMPv6, Any
- **Local ports**: Specific ports (e.g., 443), port ranges (e.g., 8000-9000), RPC, RPC-EPMap
- **Remote ports**: Specific ports, port ranges
- **Local addresses**: Any, IPv4/IPv6 addresses, subnets, ranges
- **Remote addresses**: Any, IPv4/IPv6 addresses, subnets, ranges, predefined groups (Default Gateway, DNS Servers, WINS Servers)
- **Application path**: Full path to executable or %ProgramFiles%\... variable
- **Service name**: Windows service short name
- **Edge traversal**: Allow apps to receive inbound connections via NAT (Teredo, etc.)
- **Authorized users**: SID of users/groups allowed to use the rule
- **Interface types**: LAN, Wireless, Remote Access

**Rule Import**: Intune supports importing existing GPO firewall rules (migration path from SCCM/GPO environments).

**Parity Assessment**: **Full Parity to Intune Advantage**. Intune supports advanced firewall rule creation natively, whereas SCCM requires Group Policy for this functionality. Organizations gain cloud-managed firewall rules without GPO dependency.

**Migration Considerations**:

- **Audit Group Policy firewall rules**: Export existing GPO firewall rules via PowerShell (`Get-NetFirewallRule`)
- **Import to Intune**: Use Intune firewall rule import feature or recreate manually
- **Test rule conflicts**: Verify no conflicts between Intune policies and residual GPO settings
- **Pilot testing**: Deploy firewall rules to pilot group to verify connectivity (especially VPN, RDP, file sharing)

**Common Use Cases**:

- **Block SMBv1**: Create outbound rule blocking TCP 445 to legacy file servers
- **Restrict RDP access**: Allow TCP 3389 only from specific IP ranges (admin VPN subnet)
- **SQL Server access control**: Allow TCP 1433 inbound only from application server subnet
- **Web application firewall**: Block outbound HTTP (TCP 80), allow only HTTPS (TCP 443)

**Sources**:

- [Windows Firewall policies for Endpoint Protection - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/create-windows-firewall-policies)
- [Endpoint security firewall policy](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-firewall-policy)

#### 1.3 Attack Surface Reduction (ASR) Policies

**SCCM Capability**: Configuration Manager 1906+ supports Microsoft Defender Exploit Guard policies:

- **Attack Surface Reduction rules**: 18+ rules to block known attack vectors
- **Controlled Folder Access**: Protect specified folders from ransomware encryption
- **Network Protection**: Block connections to low-reputation domains and IPs
- **Exploit Protection**: Per-process mitigation settings (DEP, ASLR, CFG, etc.)

Configuration is less granular than Intune, with policies deployed via Endpoint Protection settings or tenant attach integration with Intune.

**Intune Capability**: Intune Endpoint Security provides dedicated **Attack Surface Reduction** policy templates with superior granularity:

**Policy Templates**:

- **Attack surface reduction rules** (Windows 10/11)
- **Exploit protection** (Windows 10/11)
- **Web protection** (Windows 10/11)

**ASR Rules** (18+ rules with per-rule configuration):

| ASR Rule                                                                                              | Purpose                                                         | Recommended Setting              |
| ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | -------------------------------- |
| **Block executable content from email client and webmail**                                            | Prevent Outlook/webmail from running executables                | Block (after 30-day audit)       |
| **Block Office applications from creating executable content**                                        | Prevent Word/Excel macros from creating .exe files              | Block (after 30-day audit)       |
| **Block Office applications from injecting code into other processes**                                | Prevent Office apps from process injection (malware technique)  | Block (after 30-day audit)       |
| **Block JavaScript or VBScript from launching downloaded executable content**                         | Prevent script-based malware execution                          | Block (after 30-day audit)       |
| **Block execution of potentially obfuscated scripts**                                                 | Detect suspicious PowerShell script characteristics             | Audit (high false positive rate) |
| **Block Win32 API calls from Office macros**                                                          | Prevent Office macros from calling Windows APIs                 | Block (after 30-day audit)       |
| **Block credential stealing from the Windows local security authority subsystem (lsass.exe)**         | Prevent mimikatz-style credential dumping                       | Block (zero false positives)     |
| **Block process creations originating from PSExec and WMI commands**                                  | Prevent lateral movement via PsExec/WMI                         | Audit (impacts IT admin tools)   |
| **Block untrusted and unsigned processes that run from USB**                                          | Prevent USB-based malware execution                             | Block (after 30-day audit)       |
| **Block Adobe Reader from creating child processes**                                                  | Prevent PDF-based exploits                                      | Block (after 30-day audit)       |
| **Block Office communication application from creating child processes**                              | Prevent Outlook from launching executables                      | Block (after 30-day audit)       |
| **Block persistence through WMI event subscription**                                                  | Prevent WMI-based persistence (fileless malware)                | Block (zero false positives)     |
| **Use advanced protection against ransomware**                                                        | Behavioral detection for ransomware activity                    | Block (after 30-day audit)       |
| **Block executable files from running unless they meet a prevalence, age, or trusted list criterion** | Smart App Control integration                                   | Audit (requires careful tuning)  |
| **Block abuse of exploited vulnerable signed drivers**                                                | Prevent BYOVD (Bring Your Own Vulnerable Driver) attacks        | Block (Windows 11 22H2+)         |
| **Block rebooting machine in Safe Mode**                                                              | Prevent attackers from booting to Safe Mode to disable security | Block (Windows 11+)              |
| **Block use of copied or impersonated system tools**                                                  | Detect renamed system binaries (e.g., fake cmd.exe)             | Block (Windows 11 23H2+)         |
| **Block webshell creation for Servers**                                                               | Prevent IIS/Apache webshell deployment                          | Block (Windows Server only)      |

**Per-Rule Actions**:

- **Not Configured**: No action (rule not enabled)
- **Disabled**: Rule explicitly disabled
- **Block**: Block activity and log event
- **Audit**: Allow activity but log event for analysis
- **Warn**: Prompt user before allowing (not all rules support this)

**Audit Mode Best Practice**: Microsoft recommends **30-day audit period per rule** before switching to Block mode. High-security environments should allow 1-2 weeks between ring expansions for data gathering and configuration refinement.

**Controlled Folder Access**:

- **Protected folders**: Specify folders to protect from unauthorized changes (ransomware protection)
- **Allowed applications**: Define trusted apps allowed to modify protected folders
- **Default protection**: Automatically protect Documents, Pictures, Videos, Music, Desktop, Favorites

**Network Protection**:

- **Enable/disable Network Protection** (Block, Audit, Disabled)
- Leverages Microsoft Defender SmartScreen URL reputation
- Blocks connections to malicious domains, phishing sites, command-and-control servers
- Works with Edge, Chrome, Firefox, and any application using WinHTTP/WinInet

**Exploit Protection**:

- System-level mitigations (apply to all processes)
- Per-application mitigations (specific executable paths)
- **Mitigation settings**:
  - Data Execution Prevention (DEP)
  - Address Space Layout Randomization (ASLR)
  - Control Flow Guard (CFG)
  - Validate exception chains
  - Validate image integrity
  - Mandatory ASLR
  - Bottom-up ASLR
  - High-entropy ASLR
  - Validate API invocation (CallerCheck, SimExec)

**Parity Assessment**: **Full Parity to Intune Advantage**. Intune provides superior ASR rule management with:

- Granular per-rule configuration (vs. SCCM's less granular policy model)
- Cloud-native reporting and MDE integration for rule effectiveness analysis
- Audit mode support for safe rollout
- Newer ASR rules (Windows 11 23H2 BYOVD, Safe Mode blocking)

**Migration Considerations**:

- **Audit existing ASR configuration**: Check if SCCM ASR policies deployed via Endpoint Protection or tenant attach
- **Start in Audit mode**: Enable all ASR rules in Audit mode for 30 days, review MDE reports for impact
- **Ring deployment**:
  - **Ring 1** (IT/Security team): Deploy all rules in Block mode, refine exclusions
  - **Ring 2** (10% users): Deploy after 2-week Ring 1 validation
  - **Ring 3** (50% users): Deploy after 2-week Ring 2 validation
  - **Ring 4** (100% users): Full rollout after 30-day Ring 3 soak
- **Exclusions**: Use ASR rule exclusions sparingly (file paths, process names); prefer allow-listing applications in Controlled Folder Access
- **MDE Reporting**: Monitor ASR rule events in MDE portal (Advanced Hunting queries: `DeviceEvents | where ActionType startswith "Asr"`)

**Sources**:

- [Manage attack surface reduction settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-asr-policy)
- [Attack surface reduction rules deployment](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-deployment-test)
- [Attack surface reduction rules reference](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)

#### 1.4 Endpoint Protection Reporting

**SCCM Capability**: Configuration Manager provides 15+ Endpoint Protection reports via SSRS:

- **Malware Activity** (all malware detections across collections)
- **Endpoint Protection agent status** (agent version, deployment state, definition age)
- **Computers with a specific malware detection** (drill-down by threat name)
- **Threat summary** (aggregate threat counts by severity)
- **Users with threats** (detections associated with user accounts)
- **Overall antimalware status** (protection coverage percentage)

Reports accessible from **Monitoring > Reporting > Reports > Endpoint Protection** in ConfigMgr console.

**Intune Capability**: Intune provides built-in **Endpoint Security reports** with cloud-native analytics:

**Built-In Reports** (Reports > Microsoft Intune > Endpoint Security):

- **Antivirus agent status**: Device count by agent version, last scan time, protection state
- **Detected malware**: Threat name, severity, detection count, device list
- **Unhealthy endpoints**: Devices with outdated definitions, disabled real-time protection, scan errors
- **Windows Defender Firewall**: Firewall state per profile (Domain, Private, Public)
- **Encryption report**: BitLocker encryption status across devices

**Report Features**:

- Real-time data (vs. SSRS data warehouse lag)
- Drill-down to device details (click device name to open device record)
- Export to CSV for offline analysis
- Filter by group, platform, compliance state

**Microsoft Defender for Endpoint Integration** (if MDE P1/P2 licensed):

- **MDE Portal Reports** (security.microsoft.com):
  - Threat & vulnerability management (TVM) dashboard
  - Device inventory with risk scores
  - Security recommendations with remediation guidance
  - Advanced hunting (KQL queries for custom threat analysis)
  - Automated investigation and response (AIR) summary
  - Incidents and alerts dashboard

**MDE Advantage**: Unified security console visibility across Intune-managed and non-Intune devices (if MDE deployed via other methods). Real-time threat intelligence and automated remediation capabilities exceed SCCM's reporting-only approach.

**Parity Assessment**: **Full Parity**. Intune built-in reports cover operational Endpoint Protection scenarios. MDE integration provides advanced analytics and threat intelligence beyond SCCM's static SSRS reports.

**Migration Considerations**:

- **Report Inventory**: Document SCCM Endpoint Protection reports in active use (especially custom reports)
- **Intune Built-In Validation**: Verify all required data points available in Intune Endpoint Security reports
- **MDE Onboarding**: Enable MDE integration for advanced reporting (Endpoint Security > Microsoft Defender for Endpoint > toggle "Allow Microsoft Defender for Endpoint to enforce Endpoint Security Configurations")
- **Custom Reporting**: Use Intune Data Warehouse or Graph API for custom Endpoint Protection reports (e.g., definition age trending)

**Sources**:

- [Endpoint Protection reports - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/monitor-endpoint-protection)
- [Endpoint security reports in Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports#endpoint-security-reports)

---

### 2. Intune Advantages

#### 2.1 Native Microsoft Defender for Endpoint Integration

**SCCM Limitation**: Configuration Manager supports MDE onboarding through **tenant attach**:

- Requires ConfigMgr devices to be visible in MEM admin center via tenant attach
- MDE onboarding configuration via Endpoint Protection policies
- Limited integration without co-management (Endpoint Protection workload moved to Intune)

**Intune Capability**: Native MDE integration provides deep security orchestration:

**Automatic Onboarding**:

- **Single toggle**: Endpoint Security > Microsoft Defender for Endpoint > "Allow Microsoft Defender for Endpoint to enforce Endpoint Security Configurations" (enabled)
- **Tenant-wide MDE onboarding**: All enrolled Windows 10/11 devices automatically onboard to MDE
- **Platforms supported**: Windows, macOS, iOS, Android, Linux (via Intune or direct MDE enrollment)

**Risk-Based Conditional Access**:

- **Device risk signal**: MDE assesses device risk level (Secure, Low, Medium, High)
- **Conditional Access policies**: Block access to corporate resources if device risk > threshold
- **Example policy**: "Block Exchange Online access if device risk = High (malware detected)"
- **Automatic remediation**: When device remediates (malware removed), risk level drops, access restores

**Vulnerability Management Integration**:

- **Intune surfaces MDE vulnerability assessments** in device compliance reports
- **Security Tasks**: MDE creates remediation tasks in Intune (e.g., "Update vulnerable Java version on 50 devices")
- **Task assignment**: Assign to IT admins or auto-remediate via Intune app deployment

**Endpoint Detection and Response (EDR) Policies**:

- **Configure MDE EDR settings** directly from Intune Endpoint Security:
  - Sample sharing (automatic, prompt, none)
  - Expedited telemetry reporting frequency
  - Live Response capabilities (remote shell access for investigations)
  - Attack Surface Reduction rule enforcement

**Tamper Protection Central Management**:

- **Enable Tamper Protection** via Intune Antivirus policy
- **Prevents local admin override**: Users/admins cannot disable Defender Antivirus or modify settings
- **Required licensing**: MDE Plan 1+ or Windows E5
- **SCCM limitation**: Tamper Protection supported via Group Policy or registry, but no central management console

**Security Configuration Management (MDE SCM)**:

- **MDE Plan 2 feature**: Deliver Intune endpoint security policies to **non-enrolled devices** registered with MDE
- **Use case**: Manage BYOD devices or partner-managed servers with MDE agent but no Intune enrollment
- **Supported policies**: Antivirus, firewall, EDR, ASR (subset of full Intune capabilities)

**Parity Assessment**: **Intune Advantage**. Native MDE integration eliminates tenant attach complexity and provides risk-based Conditional Access, automated remediation, and unified security console visibility. This is a transformational improvement over SCCM's reporting-focused Endpoint Protection.

**Migration Considerations**:

- **MDE Licensing Verification**: Confirm all users licensed for MDE Plan 1 (M365 E3) or Plan 2 (M365 E5)
- **Conditional Access Preparation**: Define device risk thresholds for resource access (recommend: Block High risk, Allow Medium/Low)
- **Pilot MDE Onboarding**: Test automatic onboarding with pilot group (100 devices) before tenant-wide enablement
- **Security Operations Center (SOC) Training**: Train SOC analysts on MDE portal (security.microsoft.com) for incident response
- **Automated Investigation & Response (AIR)**: Enable AIR settings in MDE portal for automatic threat remediation

**Licensing Requirements**:

- **Intune Plan 1**: Includes Endpoint Security policies and MDE connector
- **MDE Plan 1** (included in M365 E3/Business Premium):
  - Basic EDR (automated investigation limited to 1-month retention)
  - Threat & vulnerability management (basic)
  - Device risk signals for Conditional Access
- **MDE Plan 2** (included in M365 E5 or standalone $5.20/user/month):
  - Advanced EDR with 6-month retention
  - Advanced hunting (KQL queries for threat analysis)
  - Threat analytics and custom detection rules
  - Security Configuration Management (policy delivery to non-enrolled devices)

**Sources**:

- [Integrate Microsoft Defender for Endpoint with Intune for Device Compliance](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-defender-with-intune)
- [Onboard and Configure Devices with Microsoft Defender for Endpoint via Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-defender-integrate)
- [Onboard Windows devices to Defender for Endpoint using Intune](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-mdm)
- [Microsoft Intune and Defender: Build a Complete Endpoint Security Strategy - AlphaBold](https://www.alphabold.com/intune-defender-secure-endpoint-strategy/)

#### 2.2 Security Baselines with Cloud-Native Versioning

**SCCM Capability**: Configuration Manager supports security baseline deployment for:

- **Windows 10/11 security baselines** (Group Policy Object exports)
- **Microsoft Edge baselines**
- **Integration with Intune** via tenant attach for cloud-sourced baselines

Baselines are essentially collections of pre-configured settings (GPO exports) deployed as configuration items. Updates require manual download and re-deployment.

**Intune Capability**: Intune provides **native security baselines** with cloud-managed versioning:

**Available Baselines**:

- **Windows 10/11 Security Baseline** (Microsoft-recommended security configurations, updated quarterly)
- **Microsoft Edge Baseline** (browser security settings)
- **Microsoft 365 Apps for Enterprise Baseline** (Office application security)
- **Microsoft Defender for Endpoint Baseline** (advanced threat protection settings)
- **Windows 365 Baseline** (Cloud PC security configurations)

**Baseline Features**:

- **Version tracking**: Baseline versions updated quarterly (e.g., "Windows 10 Security Baseline for November 2023")
- **Automatic update notifications**: Intune notifies admins when new baseline versions available
- **Deviation reporting**: Compare device configuration to baseline (settings drift detection)
- **Conflict resolution**: Intune identifies conflicts between baseline and other policies (duplicate settings)
- **Rollback support**: Revert to previous baseline version if new version causes issues
- **Customization**: Override baseline settings (e.g., change password complexity while keeping other baseline settings)

**Deployment Workflow**:

1. **Select baseline**: Endpoint Security > Security Baselines > [Baseline Name] > Create Profile
2. **Review settings**: Expand categories to review 100+ settings (can customize before deployment)
3. **Assign to groups**: Deploy to Entra ID device groups
4. **Monitor compliance**: View baseline compliance report (% devices compliant, specific setting drift)
5. **Update baseline**: When new version released, update profile to new baseline version (Intune prompts)

**Comparison to SCCM**:

| Capability         | SCCM                                  | Intune                                                |
| ------------------ | ------------------------------------- | ----------------------------------------------------- |
| Baseline sources   | Windows, Edge (via GPO export)        | Windows, Edge, M365 Apps, MDE, Windows 365 (native)   |
| Versioning         | Manual download and re-deployment     | Automatic notifications with one-click update         |
| Drift detection    | Configuration item compliance reports | Built-in deviation reporting with drill-down          |
| Rollback           | Redeploy previous baseline CI         | One-click revert to previous baseline version         |
| Conflict detection | Limited (manual identification)       | Automatic conflict detection with resolution guidance |

**Parity Assessment**: **Intune Advantage**. Intune provides broader baseline coverage (includes M365 Apps, Windows 365) with cloud-native versioning, automatic update notifications, and superior drift detection.

**Migration Considerations**:

- **Baseline Inventory**: Document SCCM security baseline deployments (Windows, Edge)
- **Customization Review**: Identify baseline setting customizations in SCCM configuration items
- **Pilot Deployment**: Deploy Intune baseline to pilot group (100 devices), monitor deviation reports
- **Conflict Resolution**: Use Intune conflict detection to identify duplicate settings across policies (Antivirus policy + Windows baseline both configure Defender = conflict)
- **Update Cadence**: Plan quarterly baseline reviews (align with Microsoft's release schedule)

**Recommended Baselines** (minimum):

- **Windows 10/11 Security Baseline**: All Windows devices (core OS security settings)
- **Microsoft Defender for Endpoint Baseline**: All MDE-licensed devices (advanced threat protection)
- **Microsoft Edge Baseline**: All Windows devices with Edge browser

**Sources**:

- [Use security baselines to configure Windows devices in Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/security-baselines)
- [Windows security baseline settings for Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/security-baseline-settings-windows)

#### 2.3 Unified Endpoint Security Console

**SCCM Limitation**: Endpoint Protection management scattered across multiple nodes:

- **Administration > Client Settings > Default Client Settings > Endpoint Protection**: Client agent settings
- **Assets and Compliance > Endpoint Protection > Antimalware Policies**: Antimalware policy creation
- **Assets and Compliance > Endpoint Protection > Windows Firewall Policies**: Firewall policy creation
- **Monitoring > Security > Endpoint Protection Status**: Monitoring dashboard
- **Monitoring > Reporting > Reports > Endpoint Protection**: SSRS reports

Administrators navigate 5+ console locations for Endpoint Protection tasks.

**Intune Capability**: **Unified Endpoint Security node** consolidates all security management:

- **Endpoint Security > Overview**: Security posture dashboard (at-risk devices, malware detections, firewall status)
- **Endpoint Security > All devices**: Unified device list with risk scores, compliance state, last check-in
- **Endpoint Security > Policy**:
  - Antivirus policies
  - Disk encryption (BitLocker)
  - Firewall policies
  - Endpoint detection and response (EDR)
  - Attack surface reduction
  - Account protection (Windows Hello, Credential Guard)
  - Security baselines
- **Endpoint Security > Conditional Access**: Device compliance-based access policies
- **Endpoint Security > Microsoft Defender for Endpoint**: MDE connector settings, security tasks, device risk

**Single-Pane-of-Glass Benefits**:

- **Faster troubleshooting**: Drill from Overview dashboard to device details to policy assignments in 3 clicks
- **Unified policy model**: All security policies use same assignment/filtering/reporting model
- **Cross-workload visibility**: See antivirus status, firewall state, encryption status, compliance state in single device view

**Parity Assessment**: **Intune Advantage**. Unified console improves operational efficiency compared to SCCM's distributed Endpoint Protection management.

**Sources**:

- [Manage endpoint security in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security)

---

### 3. Partial Parity / Gaps

#### 3.1 Microsoft Defender Antivirus Definition Updates

**SCCM Capability**: Configuration Manager provides granular control over Defender definition updates via **Software Update Point (SUP)**:

- **Distribution via SUP**: Defender definition updates deploy as software updates through SCCM's update infrastructure
- **Control over timing**: Deploy definitions on specific schedule (e.g., daily at 6 AM)
- **Bandwidth management**: Use BITS throttling, delivery optimization, distribution point scheduling
- **Offline environments**: Cache definitions on distribution points for air-gapped networks
- **Custom approval**: Manually approve definition updates before deployment (rare, but possible)
- **Fallback sources**: Configure fallback to Microsoft Update if SUP unavailable

**Intune Capability**: Intune relies on **Windows Update** for Defender definition updates:

- **Automatic updates**: Devices check Windows Update directly for definition updates (multiple times per day)
- **Update ring policies**: Windows Update for Business policies control definition update deferral (0-30 days)
- **Cloud-delivered protection**: Devices with cloud protection enabled get real-time signature updates via MDE cloud service
- **No bandwidth control**: Delivery Optimization policies control bandwidth, but cannot schedule specific definition update times
- **Microsoft Update fallback**: Devices automatically fall back to Microsoft Update if Windows Update unavailable

**Configuration via Intune**:

- **Antivirus policy > Defender > Updates**:
  - Signature update interval: Check every 1-24 hours (default: 4 hours)
  - Security intelligence location: Primary (Windows Update), Secondary (file share UNC path for offline scenarios)
  - Allow real-time security intelligence updates (cloud-delivered protection): Enabled/Disabled

**Parity Assessment**: **Full Parity** for most scenarios, **Partial** for air-gapped environments. Windows Update-based delivery is adequate for internet-connected devices. Air-gapped environments require UNC file share configuration (less convenient than SCCM SUP).

**Gap Impact**:

- **Air-gapped networks**: Organizations with disconnected environments must manually download definitions to file share (SCCM SUP more convenient)
- **Bandwidth optimization**: Less granular control over definition update timing (Windows Update determines schedule)
- **Update approval**: Cannot manually approve definitions before deployment (automatic only)

**Workarounds for Air-Gapped Environments**:

1. **Configure UNC file share secondary source**:
   - Download Defender definitions from Microsoft (https://www.microsoft.com/en-us/wdsi/defenderupdates)
   - Host on internal file share (\\server\DefenderUpdates)
   - Configure Antivirus policy: Security intelligence location (secondary) = \\server\DefenderUpdates
   - Automate weekly download with scheduled task

2. **WSUS integration** (for domain-joined devices):
   - Configure WSUS to sync Defender definition updates
   - Use Group Policy to point devices to WSUS: Computer Configuration > Administrative Templates > Windows Components > Windows Update > "Specify intranet Microsoft update service location"
   - Note: Requires WSUS infrastructure (not Intune-managed)

**Migration Considerations**:

- **Internet-connected devices**: No action required (Windows Update-based delivery adequate)
- **Air-gapped devices**: Configure UNC file share secondary source or retain WSUS/SCCM co-management for definition updates
- **Bandwidth concerns**: Use Delivery Optimization policies to control update bandwidth (not specific to definitions, but applies)

**Sources**:

- [Manage Microsoft Defender Antivirus updates and apply baselines](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates)
- [Microsoft Defender Antivirus security intelligence and product updates](https://www.microsoft.com/en-us/wdsi/defenderupdates)

---

## Licensing Impact

| Feature                                 | Minimum License                       | Included In                       | Notes                                                                                    |
| --------------------------------------- | ------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------- |
| **Antivirus Policies**                  | Intune Plan 1                         | M365 E3, E5, F3, Business Premium | Core Defender Antivirus management                                                       |
| **Firewall Policies**                   | Intune Plan 1                         | M365 E3, E5, F3, Business Premium | Windows Defender Firewall management                                                     |
| **Attack Surface Reduction Policies**   | Intune Plan 1                         | M365 E3, E5, F3, Business Premium | ASR rules, Controlled Folder Access, Exploit Protection                                  |
| **Security Baselines**                  | Intune Plan 1                         | M365 E3, E5, F3, Business Premium | Windows, Edge, M365 Apps, MDE, Windows 365 baselines                                     |
| **Endpoint Security Reports**           | Intune Plan 1                         | M365 E3, E5, F3, Business Premium | Built-in antivirus, firewall, encryption reports                                         |
| **Tamper Protection**                   | MDE Plan 1 or Windows E5              | M365 E3, E5, Windows E5           | Central management of Defender Tamper Protection                                         |
| **MDE Plan 1**                          | Included in M365 E3                   | M365 E3, Business Premium, EMS E3 | Basic EDR, device risk Conditional Access, 1-month retention                             |
| **MDE Plan 2**                          | Standalone $5.20/user/month           | M365 E5, EMS E5                   | Advanced hunting, 6-month retention, threat analytics, Security Configuration Management |
| **Risk-Based Conditional Access**       | MDE Plan 1 + Entra ID P1              | M365 E3, E5                       | Block access based on device risk level                                                  |
| **Security Configuration Management**   | MDE Plan 2                            | M365 E5                           | Deliver policies to non-enrolled devices with MDE agent                                  |
| **Endpoint Privilege Management (EPM)** | Intune Suite (M365 E5 from July 2026) | M365 E5 (from July 2026)          | Just-in-time admin elevation (no SCCM equivalent)                                        |

**Key Takeaway**: All core Endpoint Protection features included in **Intune Plan 1** (bundled with M365 E3). Organizations gain significant value with **MDE Plan 1** (M365 E3) for risk-based Conditional Access. **MDE Plan 2** (M365 E5) recommended for advanced hunting and extended retention.

**No Intune Plan 2 Required**: All endpoint security features available in Intune Plan 1. Intune Plan 2 ($4/user/month add-on) provides advanced app management and Microsoft Tunnel, but **not required** for endpoint security.

**See**: **Licensing Impact Register** for consolidated licensing analysis across all capability areas.

---

## Migration Considerations

### Pre-Migration Security Assessment

**Action Items** (complete before migration):

1. **Inventory SCCM Endpoint Protection Policies**:
   - Export all antimalware policies (XML or PowerShell)
   - Document exclusions (file paths, extensions, processes)
   - Review scheduled scan configurations
   - Audit firewall policies and custom rules (via Group Policy)

2. **ASR Rule Audit**:
   - Check if ASR rules deployed via SCCM Endpoint Protection or Group Policy
   - Document current ASR rule state (Disabled, Audit, Block per rule)
   - Identify exclusions (file paths, process names)

3. **Security Baseline Assessment**:
   - Review SCCM security baseline deployments (Windows, Edge)
   - Document baseline customizations (overridden settings)
   - Export baseline settings for comparison with Intune baselines

4. **MDE Preparation**:
   - Verify MDE licensing (Plan 1 or Plan 2)
   - Review existing MDE deployment (if tenant attach already configured)
   - Plan Conditional Access policies for device risk thresholds

### Migration Strategies

#### Strategy 1: Direct Migration (Intune-Only)

**Profile**: Organizations with standard Endpoint Protection requirements, internet-connected devices, MDE Plan 1+ licensing.

**Approach**:

1. **Enable MDE Integration**: Endpoint Security > Microsoft Defender for Endpoint > toggle on
2. **Deploy Antivirus Policies**: Recreate SCCM antimalware policies in Intune Antivirus templates
3. **Deploy Firewall Policies**: Import GPO firewall rules or recreate in Intune Firewall policies
4. **Deploy ASR Policies**: Start all ASR rules in Audit mode (30-day validation), then switch to Block
5. **Deploy Security Baselines**: Windows baseline + MDE baseline + Edge baseline
6. **Enable Tamper Protection**: Include in Antivirus policy deployment
7. **Configure Conditional Access**: Device risk-based policies (Block High risk from Exchange Online, SharePoint)

**Effort**: Medium (policy recreation, ASR audit period, Conditional Access planning)

**Timeline**: 60-90 days (includes 30-day ASR audit period and phased rollout)

#### Strategy 2: Co-Management Hybrid (Phased Transition)

**Profile**: Organizations with existing SCCM Endpoint Protection, cautious migration approach, hybrid environment.

**Approach**:

1. **Enable Co-Management**: Configure co-management with Endpoint Protection workload in SCCM initially
2. **Pilot Intune Endpoint Protection**: Deploy Intune policies to pilot collection (100 devices), validate for 30 days
3. **Move Workload to Intune**: Slide Endpoint Protection co-management slider to Intune (ring-based deployment)
4. **Disable SCCM Policies**: After workload moved, disable SCCM Endpoint Protection policies to prevent conflicts
5. **Decommission SCCM EP**: After 90-day Intune validation, decommission SCCM Endpoint Protection site role

**Effort**: Low (leverages existing co-management infrastructure)

**Timeline**: 120-180 days (includes extended validation periods)

### Phased Rollout Plan

**Phase 1: Pilot (100 devices, IT/Security team)**

- Deploy all Intune Endpoint Security policies (Antivirus, Firewall, ASR, Baselines)
- Enable MDE integration and Conditional Access (test device risk signals)
- ASR rules in Audit mode only
- Monitor for conflicts with SCCM policies (if co-management)
- Validate Tamper Protection enforcement
- Duration: 30 days

**Phase 2: Ring 1 (10% users)**

- Deploy policies to 10% user population (low-risk business units)
- Switch ASR rules to Block mode (after 30-day audit in Pilot)
- Monitor MDE security tasks and automated remediation
- Refine exclusions based on false positives
- Duration: 30 days

**Phase 3: Ring 2 (50% users)**

- Scale to 50% user population
- Enable risk-based Conditional Access for production apps (Exchange, SharePoint, Teams)
- Monitor helpdesk tickets for policy-related issues
- Duration: 30 days

**Phase 4: Production (100% users)**

- Full deployment to all devices
- Decommission SCCM Endpoint Protection (if not co-management)
- Enable all advanced MDE features (AIR, custom detections)
- Duration: Ongoing

### Common Pitfalls to Avoid

1. **Skipping ASR Audit Period**: Deploying ASR rules directly to Block mode causes application breakage. Always audit for 30 days first.

2. **Overlapping Policies (SCCM + Intune)**: During co-management, SCCM and Intune policies can conflict. Use co-management workload slider to enforce single authority.

3. **Insufficient MDE Licensing**: MDE Plan 1 (M365 E3) is minimum for Conditional Access. Plan 2 (M365 E5) required for advanced hunting.

4. **Tamper Protection Surprise**: Enabling Tamper Protection prevents local admins from disabling Defender. Communicate to IT team before deployment.

5. **Firewall Rule Gaps**: SCCM relies on GPO for granular firewall rules. Ensure all GPO rules migrated to Intune before disabling GPO.

6. **Definition Update Air-Gap Oversight**: Air-gapped environments require UNC file share configuration for definition updates (not automatic like SCCM SUP).

7. **Baseline Customization Loss**: Intune baselines may reset previously customized SCCM baseline settings. Review and re-apply customizations in Intune.

---

## Sources

### Microsoft Official Documentation

- [Endpoint Protection antimalware policies - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/endpoint-antimalware-policies)
- [Manage endpoint security in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security)
- [Antivirus policy settings for Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-antivirus-policy)
- [Windows Firewall policies for Endpoint Protection - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/create-windows-firewall-policies)
- [Endpoint security firewall policy](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-firewall-policy)
- [Manage attack surface reduction settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-asr-policy)
- [Attack surface reduction rules deployment](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-deployment-test)
- [Attack surface reduction rules reference](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)
- [Use security baselines to configure Windows devices in Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/security-baselines)
- [Windows security baseline settings for Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/security-baseline-settings-windows)
- [Integrate Microsoft Defender for Endpoint with Intune for Device Compliance](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-defender-with-intune)
- [Onboard and Configure Devices with Microsoft Defender for Endpoint via Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-defender-integrate)
- [Onboard Windows devices to Defender for Endpoint using Intune](https://learn.microsoft.com/en-us/defender-endpoint/configure-endpoints-mdm)
- [Manage Microsoft Defender Antivirus updates and apply baselines](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates)
- [Microsoft Defender Antivirus security intelligence and product updates](https://www.microsoft.com/en-us/wdsi/defenderupdates)
- [Endpoint Protection reports - Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/protect/deploy-use/monitor-endpoint-protection)
- [Endpoint security reports in Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports#endpoint-security-reports)
- [Deploy endpoint detection and response policy with Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/endpoint-security-edr-policy)

### Community and Expert Sources

- [Microsoft Intune and Defender: Build a Complete Endpoint Security Strategy - AlphaBold](https://www.alphabold.com/intune-defender-secure-endpoint-strategy/)
- [Microsoft Defender for Endpoint: Getting Started with Deployment Using Intune - cloudcoffee.ch](https://www.cloudcoffee.ch/microsoft-365/microsoft-defender-for-endpoint-getting-started-with-deployment-using-intune/)

---

**End of Assessment**
