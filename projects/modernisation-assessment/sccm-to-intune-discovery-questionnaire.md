# SCCM-to-Intune Transition — Environment Discovery Questionnaire

**Version**: 1.0
**Last Updated**: 2026-02-19
**Purpose**: Systematic environment inventory and readiness assessment for SCCM-to-Intune migration

---

## Introduction

This questionnaire provides a structured approach to assessing your current SCCM environment and organisational readiness for transitioning to Microsoft Intune. Completing this questionnaire is the first step in your modernisation journey and provides the foundation for capability assessment and migration planning.

### How to Use This Questionnaire

1. **Assign section ownership** — Different sections require input from different teams (infrastructure, security, applications, change management)
2. **Gather evidence** — Where possible, provide quantitative data (counts, percentages, versions) rather than estimates
3. **Document constraints** — Identify technical, regulatory, or organisational blockers early
4. **Feed into planning** — Completed answers populate the Organisation Template and inform migration strategy

### Related Documents

- [Organisation Template](./sccm-to-intune/org-template.md) — Migration planning template populated from questionnaire responses
- [SCCM-to-Intune Assessment Framework](./sccm-to-intune/) — Master index with full navigation across all capability areas
- [Capability Assessments](./sccm-to-intune/executive-summary.md) — Executive summary with consolidated ratings and links to all 10 capability area assessments

---

## 1. Current State Infrastructure

**Purpose**: Understand the complexity and scale of your existing SCCM and Active Directory infrastructure to assess migration effort and identify dependencies.

### Questions

1. **Active Directory Forest and Domain Structure**
   - How many Active Directory forests exist in your organisation?
   - How many domains exist across all forests?
   - Are there trust relationships between domains or forests? (Document type: one-way, two-way, external, forest)
   - What is your forest and domain functional level?

2. **SCCM Site Hierarchy**
   - What is your SCCM site hierarchy model? (Single primary site / CAS with multiple primary sites / Multiple standalone primaries)
   - How many primary sites exist?
   - How many secondary sites exist?
   - How many distribution points are deployed? (Total count and breakdown: branch DPs, cloud DPs, pull DPs)
   - How many management points are deployed?

3. **SCCM Version and Compliance**
   - What Current Branch version of SCCM are you running? (Specific build number)
   - When was the last SCCM update applied?
   - Are you within the support window (last 3 Current Branch versions)?
   - What is your SCCM update cadence? (Every update / Baseline only / Ad-hoc)

4. **Group Policy Environment**
   - How many Group Policy Objects (GPOs) are in use across your organisation?
   - How many GPOs contain computer configuration settings that might need migrating to Intune policies?
   - Are WMI filters extensively used for GPO targeting?
   - Is GPO loopback processing configured for any OUs?
   - What percentage of GPO settings are documented?

5. **Network Topology**
   - How many physical office locations do you have?
   - How many of these locations have SCCM distribution points?
   - What is the typical WAN link bandwidth to remote sites? (List ranges: <10 Mbps / 10-50 Mbps / 50+ Mbps)
   - What percentage of your workforce is remote/work-from-home?
   - Do remote workers connect via VPN or direct internet access?

6. **Hardware Lifecycle**
   - What is the age distribution of your device estate? (Percentage in each bracket: 0-2 years / 2-4 years / 4+ years)
   - What is your hardware refresh cycle? (Years)
   - What percentage of devices are under manufacturer warranty?
   - What percentage of devices are Windows 10 vs Windows 11?
   - What is your minimum hardware specification for new device purchases?

7. **SQL Server Infrastructure**
   - What SQL Server version hosts your SCCM database? (Include build number)
   - Is SQL Server AlwaysOn configured for high availability?
   - What is the current SCCM database size?
   - Are SQL maintenance plans documented and functioning correctly?
   - Have you experienced SQL performance issues with SCCM? (Document frequency and impact)

8. **SCCM Client Health**
   - How many total SCCM clients are registered in your environment?
   - What percentage of clients have communicated with SCCM in the last 7 days?
   - What is your client remediation strategy? (Automated / Manual / None)
   - What percentage of clients are on the current client version?

> **Why This Matters**
> Infrastructure complexity directly impacts migration effort. A complex multi-site hierarchy with numerous distribution points suggests significant SCCM dependency that will require careful co-management planning. High remote worker percentage and good internet bandwidth indicate strong cloud readiness. Legacy hardware may require accelerated refresh to meet modern management requirements.

---

## 2. Identity and Authentication

**Purpose**: Assess your identity infrastructure maturity and cloud authentication readiness, which forms the foundation for Intune device management.

### Questions

1. **Current Authentication Mechanisms**
   - What is your primary authentication method for cloud services? (Password Hash Sync / Pass-Through Authentication / ADFS / None yet)
   - If using ADFS, how many ADFS servers and WAP proxies are deployed?
   - Are you still dependent on legacy authentication protocols? (NTLM, Kerberos-only applications)
   - Have you completed an inventory of applications that require legacy authentication?

2. **Entra ID Connect Configuration**
   - Is Entra ID Connect (formerly Azure AD Connect) deployed?
   - What sync scope is configured? (All users and devices / Filtered by OU / Filtered by attributes)
   - What is your sync frequency? (Default 30 minutes / Custom interval)
   - Is password hash synchronisation enabled (even if not primary auth method)?
   - Is device writeback configured?

3. **Entra Hybrid Join Status**
   - What percentage of your Windows devices are Entra Hybrid Joined?
   - Have you configured automatic device registration via Group Policy or SCCM?
   - Are there device types deliberately excluded from Entra Hybrid Join? (List reasons)
   - Do you have visibility of hybrid join status in reporting?

4. **Multi-Factor Authentication (MFA)**
   - What percentage of users are enrolled in MFA?
   - Which MFA methods are enabled? (Microsoft Authenticator / SMS / Phone call / FIDO2 / Other)
   - Are Conditional Access policies configured?
   - How many Conditional Access policies are in production?
   - Do you have specific policies for device compliance or trusted locations?

5. **Legacy Authentication Usage**
   - Have you identified all applications and services using basic authentication?
   - What is your timeline for disabling basic authentication?
   - Are there business-critical applications that cannot support modern authentication? (List them)
   - Have you enabled Entra ID sign-in logs to audit legacy auth attempts?

6. **Identity Governance Maturity**
   - Is Local Administrator Password Solution (LAPS) deployed? (Percentage coverage)
   - Do you use Privileged Access Management (PAM) or Just-In-Time (JIT) admin access?
   - Is Privileged Identity Management (PIM) configured in Entra ID?
   - What is your admin account strategy? (Dedicated admin accounts / Everyday accounts with elevation / Mixed)

7. **Entra ID Licensing**
   - What Entra ID licensing tier do you have? (Free / P1 / P2)
   - What percentage of users are licensed for Entra ID P1 or higher?
   - Are you aware of Entra ID features required for Intune? (Conditional Access, dynamic groups, group-based licensing)

8. **Identity Integration Dependencies**
   - Do you have third-party identity providers or SSO solutions integrated with AD?
   - Are there applications that query AD directly and may not support Entra ID?
   - Do you use certificate-based authentication for devices or users?
   - Is smartcard authentication required for any user population?

> **Why This Matters**
> Intune device management relies on Entra ID as the identity source. Entra Hybrid Join is a prerequisite for co-management and smooth migration. MFA and Conditional Access are critical security controls in a cloud-first model. Incomplete identity synchronisation or lack of hybrid join deployment will block migration progress and must be addressed early.

---

## 3. Device Management

**Purpose**: Understand current device management practices, tooling, and SCCM dependency to plan the transition to modern cloud-based management.

### Questions

1. **SCCM Client Health and Activity**
   - How many devices have an active SCCM client installed?
   - What percentage of clients have checked in within the last 30 days?
   - What percentage of clients report as "healthy" in SCCM client health monitoring?
   - Do you have automated client remediation configured? (ConfigMgr Client Health / Custom scripts / None)

2. **Co-Management Status**
   - Is co-management currently enabled in your environment?
   - If yes, which workloads have been shifted to Intune? (Compliance / Device Configuration / Endpoint Protection / Resource Access / Windows Update / Office Click-to-Run / Client Apps)
   - What percentage of eligible devices are enrolled in co-management?
   - Have you experienced issues with co-management? (Document problems and resolutions)

3. **Cloud Management Gateway (CMG)**
   - Have you deployed Cloud Management Gateway?
   - If yes, what percentage of clients connect via CMG vs on-premises management points?
   - What is your monthly CMG cost?
   - Have you experienced CMG performance or connectivity issues?

4. **Device Compliance**
   - How many compliance policies are configured in SCCM (via co-management) or Intune?
   - What compliance checks are enforced? (OS version / Antivirus / Encryption / Password complexity / Other)
   - Are devices marked non-compliant blocked from accessing resources?
   - What percentage of your devices are currently compliant?

5. **Application Deployment Methods**
   - What percentage of applications are deployed via SCCM?
   - What percentage are deployed via other methods? (Intune / GPO / Manual / Third-party tools)
   - Do users have self-service application access? (Software Center / Company Portal / Other)
   - What is the average time to deploy a new application to users?

6. **OS Deployment and Provisioning**
   - What is your primary OS deployment method? (SCCM task sequences / Manual imaging / Third-party / Other)
   - Have you tested Windows Autopilot for device provisioning?
   - What percentage of new devices could be provisioned via Autopilot without imaging?
   - Do you have a gold image dependency? (How many images maintained?)
   - How long does a typical device build take from unbox to user handover?

7. **SCCM Collections Structure**
   - How many device collections exist in SCCM?
   - How many are query-based vs direct membership?
   - What is your collection evaluation schedule and performance impact?
   - Do you use incremental collection updates?
   - Are collections documented with business purpose?

8. **Device Inventory and Reporting**
   - What hardware inventory is collected by SCCM? (Default / Custom classes / Extended)
   - What software inventory is collected?
   - How many custom reports have been created for SCCM?
   - Are there business-critical reports that must be replicated in Intune/Endpoint Analytics?

9. **Remote Management Capabilities**
   - What remote management tools are in use? (ConfigMgr Remote Control / Remote Assistance / Third-party tools)
   - Do helpdesk staff rely on SCCM remote tools for user support?
   - What is the business impact if remote control is unavailable during migration?

10. **Device Refresh and Retirement**
    - What is your device refresh process? (SCCM-driven / Manual / Third-party)
    - How are devices securely wiped or retired? (SCCM task sequence / Manual / BitLocker escrow + wipe)
    - Do you track device warranties and refresh eligibility in SCCM?

> **Why This Matters**
> Co-management is the bridge from SCCM to Intune — knowing your current status informs the migration path. Heavy reliance on SCCM-specific features (complex collections, custom inventory, remote tools) indicates migration complexity. CMG deployment and performance provides insight into cloud connectivity readiness. Application deployment method diversity affects timeline and testing requirements.

---

## 4. Security and Compliance

**Purpose**: Assess your security posture, endpoint protection maturity, and compliance requirements to ensure migration maintains or improves security controls.

### Questions

1. **Endpoint Protection Solution**
   - What is your primary endpoint protection platform? (Microsoft Defender / Third-party: specify / Mixed environment)
   - If third-party, what is the product and version?
   - Is the endpoint protection solution managed by SCCM, Intune, or standalone console?
   - What is your timeline for migrating to Microsoft Defender if not already deployed?

2. **Microsoft Defender for Endpoint (MDE)**
   - Is Microsoft Defender for Endpoint deployed?
   - What percentage of devices are onboarded to MDE?
   - How are devices onboarded? (SCCM tenant attach / Intune policy / Group Policy / Manual)
   - Are you using MDE advanced features? (Attack Surface Reduction / Controlled Folder Access / Network Protection / Exploit Protection)
   - Is Defender for Endpoint integration configured with Intune for device risk signals?

3. **Configuration Baselines and Security Settings**
   - How many configuration baselines are deployed in SCCM?
   - What do these baselines enforce? (Security settings / Application settings / Registry values / Other)
   - Are configuration baselines set to auto-remediate or report-only?
   - Have you mapped SCCM baselines to equivalent Intune configuration policies or Security Baselines?

4. **Data Loss Prevention (DLP)**
   - Is endpoint DLP configured? (None / Microsoft Purview / Third-party)
   - Are sensitivity labels deployed to users and devices?
   - What data types are classified and protected? (PII / Financial / Health / IP / Other)
   - Do you have compliance requirements for data protection? (GDPR / HIPAA / PCI-DSS / Other)

5. **BitLocker and Encryption**
   - What percentage of devices are encrypted with BitLocker?
   - How is BitLocker managed? (MBAM / SCCM BitLocker Management / Intune / Standalone)
   - Are recovery keys escrowed? (Active Directory / MBAM / Entra ID / None)
   - Is encryption enforced via policy or optional?
   - What is your BitLocker configuration? (TPM-only / TPM+PIN / Password / Other)

6. **Audit and Compliance Reporting**
   - What regulatory or compliance frameworks apply to your organisation? (ISO 27001 / SOC 2 / GDPR / HIPAA / PCI-DSS / Government frameworks / Other)
   - How frequently are compliance reports required? (Real-time / Daily / Weekly / Monthly / Quarterly)
   - What compliance metrics are tracked? (Patching / Encryption / Antivirus / Configuration drift / Other)
   - Are audit logs retained and reviewed regularly?
   - Do you have documented audit requirements for endpoint management changes?

7. **Security Patch Management**
   - How are security updates deployed? (SCCM Software Updates / WSUS / Intune / Automatic)
   - What is your patch deployment timeline? (Critical patches within X days / Monthly cycle / Other)
   - What percentage of devices are compliant with patch policies?
   - Do you test patches before production deployment? (Describe pilot/ring approach)

8. **Third-Party Patching**
   - Are third-party applications patched via SCCM? (SCUP catalogs / Manual packages / Not patched)
   - How many third-party applications are in your patching catalogue?
   - What third-party patching solution might replace SCCM capability? (Intune Win32 apps / Patch My PC / Third-party service)

9. **Attack Surface Reduction**
   - Are Attack Surface Reduction (ASR) rules configured?
   - Which ASR rules are enabled in block mode vs audit mode?
   - Have you measured ASR rule impact on business applications?
   - Is Application Control (WDAC/AppLocker) configured?

10. **Conditional Access and Device Compliance Integration**
    - Are Conditional Access policies linked to device compliance status?
    - What resources are protected by device compliance checks? (Exchange Online / SharePoint / Microsoft 365 apps / All apps)
    - What happens when a device becomes non-compliant? (Block access / User notification / Grace period)

11. **Security Monitoring and Incident Response**
    - Is security event logging centralised? (SIEM integration / Log Analytics / Defender portal)
    - What security events are monitored from endpoints?
    - What is your incident response process for compromised devices?
    - Can devices be remotely isolated or wiped in a security incident?

> **Why This Matters**
> Security must not regress during migration. Understanding current security controls (endpoint protection, encryption, DLP, compliance) ensures equivalent or better controls are configured in Intune before workload migration. Regulatory compliance requirements may dictate migration pace and testing rigor. MDE integration with Intune provides device risk signals for Conditional Access — this is a key cloud security capability.

---

## 5. Applications and Workloads

**Purpose**: Inventory application estate complexity, deployment methods, and SCCM-specific dependencies to plan application migration strategy.

### Questions

1. **Application Inventory**
   - How many applications are catalogued in SCCM? (Distinguish between Applications and legacy Packages)
   - How many deployment types exist across all applications?
   - What percentage of applications are business-critical?
   - What percentage are actively deployed vs archived/unused?

2. **Application Deployment Type Breakdown**
   - How many applications use MSI installers?
   - How many use Script installers (EXE, batch, PowerShell)?
   - How many use App-V virtualisation?
   - How many are MSIX packaged?
   - How many are Microsoft Store apps (UWP or Store for Business)?
   - How many applications have multiple deployment types (e.g., MSI + App-V fallback)?

3. **Application Complexity**
   - How many applications use dependencies or supersedence chains?
   - What is the average dependency depth for complex applications?
   - What is the most complex application deployment? (Describe dependencies, detection methods, install behaviour)
   - How many applications use custom detection methods (registry, file, script)?

4. **Global Conditions and Requirements**
   - How many global conditions are defined in SCCM?
   - What do global conditions check? (OS version / Disk space / CPU / Custom registry/file / Other)
   - How many applications rely on global conditions for targeting?

5. **Task Sequences**
   - How many task sequences exist in SCCM? (Include OS deployment and custom sequences)
   - What is the average step count per task sequence?
   - How many task sequences use conditional logic or dynamic variables?
   - Are task sequences documented with purpose and dependencies?
   - Which task sequences are business-critical? (Cannot be disabled during migration)

6. **Software Metering**
   - Is software metering enabled in SCCM?
   - How many metering rules are configured?
   - Are metering reports actively used for licence compliance or usage decisions?
   - What is the business impact if software metering data is unavailable during migration?

7. **Third-Party Application Patching**
   - How many third-party applications are patched via SCCM?
   - What SCUP catalogues are subscribed? (Adobe / Java / Other publishers)
   - How frequently are third-party updates deployed?
   - Have you evaluated third-party patching alternatives? (Patch My PC / Intune Win32 apps / Other)

8. **App-V Virtualisation**
   - How many App-V packages are deployed?
   - What version of App-V is in use? (App-V 5.x)
   - What is your App-V migration strategy? (Convert to MSIX / Re-package as Win32 / Replace with SaaS / Retain App-V)
   - What is the timeline for App-V migration?

9. **User-Available vs Required Deployments**
   - What percentage of application deployments are Required (automatic install)?
   - What percentage are Available (user self-service via Software Center)?
   - Do users actively use Software Center for app installation?
   - What is user familiarity with self-service application installation?

10. **Application Deployment Testing**
    - What is your current application testing process before production deployment?
    - Do you have defined pilot groups for application testing?
    - What is the typical application deployment timeline from request to production?
    - Are application deployment failures tracked and analysed?

11. **Line-of-Business (LOB) Application Packaging**
    - Who is responsible for application packaging? (In-house team / Outsourced / Vendor-provided)
    - What packaging standards are followed? (Documented standards / Ad-hoc)
    - What tools are used for packaging? (AdminStudio / Advanced Installer / Manual)
    - How many packagers are trained and available?

12. **Application Rationalisation**
    - When was the last application portfolio review?
    - How many applications are candidates for retirement or consolidation?
    - Have you identified SaaS alternatives to on-premises applications?
    - What percentage of applications could be replaced with Microsoft 365 apps or web apps?

> **Why This Matters**
> Application migration is the longest and most complex phase of SCCM-to-Intune transition. High application count and complexity (dependencies, global conditions, App-V) extend timeline significantly. Task sequence dependency indicates strong SCCM coupling — OS deployment task sequences must be replaced with Autopilot provisioning. Software metering and custom reporting dependencies require alternative solutions. Application rationalisation before migration reduces migration effort and ongoing management overhead.

---

## 6. Organisational Readiness

**Purpose**: Assess organisational change capacity, team skills, executive support, and user readiness to ensure successful migration beyond technical capability.

### Questions

1. **IT Team Structure and SCCM Expertise**
   - How many IT staff are involved in SCCM administration? (FTE count)
   - What is the team's SCCM expertise level? (Expert / Proficient / Basic / Learning)
   - Are there dedicated SCCM administrators or shared responsibilities?
   - What is the average tenure of SCCM administrators? (Risk of knowledge loss)
   - Is SCCM administration documented? (Runbooks / Procedures / Tribal knowledge only)

2. **Cloud and Intune Experience**
   - How many IT staff have hands-on experience with Intune?
   - What is the team's Intune expertise level? (Expert / Proficient / Basic / None)
   - Have team members completed Microsoft Intune training? (Official courses / Self-study / None)
   - How many team members hold relevant Microsoft certifications? (MD-102 / MS-102 / SC-300 / Other)
   - Have you conducted Intune proof-of-concept or pilot projects?

3. **Change Management Capability**
   - Do you have a formal change management process?
   - How are changes to endpoint management communicated to users?
   - What is your typical change approval timeline?
   - Have you developed a communication plan for SCCM-to-Intune migration?
   - Who are the key stakeholders that must approve migration decisions?

4. **Helpdesk Readiness**
   - How many helpdesk staff support endpoint issues?
   - What is helpdesk familiarity with Intune and Company Portal? (High / Medium / Low / None)
   - Are helpdesk procedures documented for SCCM-managed devices?
   - Have you planned helpdesk training for Intune support?
   - What is the expected support volume increase during migration?

5. **Executive Sponsorship and Budget**
   - Is there executive sponsorship for SCCM-to-Intune migration?
   - Has budget been allocated for migration project? (Licensing / Training / External consulting / Tooling)
   - What is the approved budget range?
   - Are there competing IT priorities that may delay migration?
   - Is cloud-first strategy endorsed at executive level?

6. **User Population Characteristics**
   - How would you characterise user technical literacy? (High / Medium / Low / Mixed)
   - What percentage of users are office-based vs remote/hybrid?
   - Do you have a BYOD policy? (Percentage of BYOD vs corporate-owned devices)
   - What is user familiarity with self-service tools? (High / Medium / Low)
   - Are there specific user groups with unique requirements? (Executives / Field workers / Contractors)

7. **Pilot Group Identification**
   - Have you identified pilot groups for migration testing?
   - What is the pilot group size? (Device count or percentage of estate)
   - Are pilot users willing participants and early adopters?
   - Do pilot groups represent a cross-section of organisation? (Roles / Locations / Device types)
   - What success criteria will be measured during pilot?

8. **Training and Enablement**
   - What training budget is allocated for IT staff?
   - What training budget is allocated for end users?
   - What training delivery methods are planned? (Instructor-led / E-learning / Documentation / Lunch-and-learn)
   - Have you created user-facing documentation for Company Portal and self-service?

9. **Risk Tolerance and Migration Pace**
   - What is organisational risk tolerance for disruption during migration? (High / Medium / Low)
   - What is acceptable downtime or user impact during migration?
   - Are there business cycles that prohibit changes? (Financial year-end / Peak trading periods / Academic terms)
   - What is the preferred migration pace? (Aggressive / Moderate / Cautious)

10. **Success Metrics and KPIs**
    - How will migration success be measured?
    - What KPIs will be tracked? (Device enrollment rate / Policy compliance / Helpdesk tickets / User satisfaction / Cost savings)
    - Who is accountable for migration success?
    - What reporting cadence is expected? (Daily / Weekly / Monthly)

> **Why This Matters**
> Technical capability is necessary but insufficient for successful migration. Organisational readiness determines migration pace and success probability. Low Intune expertise requires upfront training investment and slower migration. Weak executive sponsorship or budget constraints may stall migration. Helpdesk unpreparedness leads to poor user experience and increased support burden. Pilot group selection and success metrics define measurable progress and build confidence for full rollout.

---

## 7. Technical Constraints and Requirements

**Purpose**: Identify constraints that may limit migration options, affect timeline, or require workarounds to ensure realistic planning.

### Questions

1. **Regulatory Compliance Requirements**
   - What industry-specific regulations apply to your organisation? (Healthcare: HIPAA / Finance: PCI-DSS, SOX / Government: PROTECTED, FedRAMP / Education: FERPA / Other)
   - Are there data handling requirements that affect cloud service usage?
   - Do compliance requirements mandate specific security controls? (Document controls)
   - Are there audit or reporting requirements that must be maintained during migration?
   - Have you reviewed Intune compliance certifications for your industry?

2. **Data Residency and Sovereignty**
   - Are there legal or regulatory requirements for data to remain in specific geographic regions?
   - What is your organisation's data residency policy?
   - Have you confirmed Intune tenant data location meets requirements? (Check Microsoft Trust Center)
   - Are there restrictions on using cloud services based in certain countries?

3. **Network Bandwidth and Connectivity**
   - What is the total internet bandwidth available at each site? (List per-site ranges)
   - What is current bandwidth utilisation during business hours? (Percentage)
   - Have you measured available bandwidth for cloud traffic per device?
   - Are there proxy servers or network appliances that inspect/filter cloud traffic?
   - What firewall rules or URL filtering may block Intune connectivity? (List restricted domains)
   - Have you tested Intune required URLs and IP ranges for connectivity?

4. **Disconnected and Air-Gapped Environments**
   - Do you have devices in air-gapped or disconnected environments? (Count or percentage)
   - What is the business requirement for these disconnected devices?
   - Can these devices be connected to internet periodically for management?
   - What is the alternative management approach for disconnected devices? (Retain SCCM / Manual / No management)

5. **Internet Access for Devices**
   - What percentage of devices have direct internet access?
   - What percentage route through proxy servers?
   - Are proxy servers authenticated or anonymous?
   - Are SSL/TLS inspection technologies in use that may interfere with Intune?
   - Do you have split-tunnel VPN or full-tunnel VPN for remote devices?

6. **Budget Constraints and Licensing**
   - What is current SCCM licensing cost? (Include SQL Server, infrastructure, support)
   - What Intune licensing do you currently have? (Microsoft 365 E3/E5 / EMS E3/E5 / Standalone Intune)
   - What is the licensing delta for full Intune migration? (Additional cost or savings)
   - Has budget been approved for migration project costs? (Training / Consulting / Tooling)
   - Are there capital vs operational expenditure considerations?

7. **Timeline Constraints and Deadlines**
   - Are there hard deadlines for migration? (SCCM support end-of-life / Contract renewal / Regulatory deadline / Other)
   - What is your target migration completion date?
   - Are there business events that create blackout periods for changes? (List periods)
   - What is the realistic timeline given current resource availability?

8. **Third-Party Tool Dependencies**
   - What third-party tools integrate with or depend on SCCM? (Patch management / Software deployment / Inventory / Reporting / Security)
   - Which tools are business-critical and must have alternatives before SCCM decommission?
   - Have you evaluated Intune-compatible alternatives?
   - What is the migration or replacement timeline for each tool?

9. **Integration Dependencies**
   - What systems integrate with SCCM? (ServiceNow / SCCM / Other ITSM / Monitoring platforms / Reporting systems)
   - Are these integrations API-based or database-query based?
   - Have you identified equivalent Intune integration methods? (Graph API / PowerShell / Connectors)
   - What is the business impact if integrations are unavailable during migration?

10. **Legacy Device Support**
    - What percentage of devices do not meet Windows 10/11 minimum requirements?
    - Are there business-critical legacy applications that require older OS versions?
    - What is the plan for devices that cannot be managed by Intune? (Replace / Retain SCCM / Isolate / Retire)
    - Are there embedded or special-purpose devices that require custom management?

11. **Mobile Device Management (MDM) Existing Footprint**
    - Is MDM authority currently set? (Intune / SCCM / Co-management / None)
    - If using co-management, what is current MDM authority setting?
    - Have you migrated MDM authority to Intune for any workloads?
    - Are there mobile devices (iOS/Android) already managed by Intune?

12. **Disaster Recovery and Business Continuity**
    - What is your Recovery Time Objective (RTO) for endpoint management capability?
    - What is your Recovery Point Objective (RPO) for endpoint configuration?
    - How does Intune fit into business continuity planning compared to SCCM?
    - What is the backup and recovery strategy for Intune configuration?
    - Have you documented rollback procedures if migration encounters critical issues?

> **Why This Matters**
> Constraints define the boundaries of what is possible. Regulatory compliance may dictate security controls, data residency, or audit trails that must be proven before migration. Network bandwidth limits affect content delivery strategy and migration pace. Air-gapped environments cannot use cloud management and require alternative solutions. Budget constraints affect licensing choices, training investment, and external assistance. Third-party tool dependencies may be the long pole in the migration tent — if alternatives are not available, SCCM cannot be decommissioned. Understanding constraints early prevents late-stage surprises and project failure.

---

## Next Steps After Completing This Questionnaire

1. **Consolidate responses** — Compile answers into a single document with evidence and supporting data
2. **Populate Organisation Template** — Transfer responses into the Organisation Template structure
3. **Conduct Capability Assessment** — Use responses to complete detailed capability assessments for each of the 7 areas
4. **Identify gaps** — Document capability gaps between current state (SCCM) and target state (Intune)
5. **Prioritise gaps** — Rank gaps by business impact, migration blocking risk, and effort to close
6. **Develop migration roadmap** — Create phased migration plan addressing gaps in priority order
7. **Define pilot scope** — Use organisational readiness responses to select pilot groups and success criteria
8. **Secure approval** — Present findings and proposed approach to stakeholders for approval and budget confirmation

---

## Document Control

| Attribute | Value |
|-----------|-------|
| **Owner** | IT Architecture / Endpoint Management Team |
| **Review Frequency** | At migration milestones or quarterly during migration |
| **Related Documents** | Organisation Template, SCCM-to-Intune Assessment Framework, Intune Capability Assessments |
| **Version History** | 1.0 (2026-02-19) — Initial release |

---

**End of Questionnaire**
