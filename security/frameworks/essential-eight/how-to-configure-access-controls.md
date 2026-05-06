---
title: "How to Configure Access Controls"
status: "draft"
last_updated: "2026-03-23"
audience: "Security Engineers"
document_type: "how-to"
domain: "security"
---

# How to Configure Access Controls

---

## Overview

This guide covers the practical configuration of access controls in the context of the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight). It addresses four implementation areas: multi-factor authentication (MFA), role-based access control (RBAC), privileged access management (PAM), and just-in-time (JIT) access elevation.

Access control underpins two Essential Eight strategies directly:

- **Strategy 5 — Restrict Administrative Privileges**: Limit who holds administrative rights, and under what conditions those rights are active.
- **Strategy 7 — Multi-Factor Authentication**: Require strong authentication across user and privileged account classes.

For authoritative requirements and maturity level thresholds, refer to the [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model).

---

## Before You Begin

This guide assumes:

- You have an identity provider in place (such as Microsoft Entra ID, Active Directory, or an equivalent directory service).
- You have administrative access to configure authentication policies, group assignments, and conditional access rules.
- You have identified the maturity level (ML1, ML2, or ML3) your organisation is targeting.

If you are working in a Microsoft environment, Microsoft Entra ID and Privileged Identity Management (PIM) are used as implementation examples throughout. The same principles apply to equivalent products from other vendors.

---

## Part 1 — Configure Multi-Factor Authentication

MFA is a Strategy 7 requirement. The ACSC [Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model) defines MFA requirements at each level as follows:

| Maturity Level | MFA Scope |
| -------------- | --------- |
| ML1 | Privileged accounts and remote access |
| ML2 | All users; minimum two factors from distinct categories |
| ML3 | All users; phishing-resistant methods only (FIDO2, smartcard, Windows Hello for Business) |

### Step 1.1 — Select MFA methods by account class

Choose MFA methods appropriate to the account class and target maturity level. The table below ranks available methods by phishing resistance:

| Method | Phishing Resistant | Recommended Use |
| ------ | ------------------ | --------------- |
| FIDO2 hardware security key | Yes | Privileged accounts (ML3) |
| Windows Hello for Business | Yes | Workstation authentication (ML3) |
| Smartcard / certificate-based | Yes | Privileged access (ML2–ML3) |
| Authenticator app (TOTP or push) | No | Standard users (ML2) |
| Push notification | No | Standard users (ML2) |
| SMS one-time code | No | Fallback only — not recommended above ML1 |
| Email one-time code | No | Not recommended at any level |

At ML3, only phishing-resistant methods satisfy the ACSC requirement. SMS and email OTP do not qualify.

### Step 1.2 — Enforce MFA via Conditional Access (Microsoft Entra ID)

If your identity provider is Microsoft Entra ID, use Conditional Access policies to enforce MFA. The following policy logic covers the minimum ML2 baseline:

1. In the [Microsoft Entra admin centre](https://entra.microsoft.com), navigate to **Protection > Conditional Access > Policies**.
2. Create a new policy targeting **All users** (or the appropriate user scope).
3. Under **Conditions**, set **Cloud apps** to **All cloud apps**.
4. Under **Grant**, select **Require multifactor authentication**.
5. Set the policy state to **On**.

For privileged accounts, create a separate, stricter policy:

- Target the policy at **Directory roles** (e.g., Global Administrator, Privileged Role Administrator, Security Administrator).
- Under **Grant**, select **Require authentication strength** and choose **Phishing-resistant MFA** to enforce FIDO2 or Windows Hello at ML3.

> Do not create a blanket exclusion for emergency access accounts (break-glass accounts). Instead, exclude them specifically by account object and monitor their sign-in logs separately.

### Step 1.3 — Configure password policy by account class

Password policy must be calibrated to account class. The following thresholds align with ACSC guidance and the [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism):

| Requirement | Standard Users | Privileged Users | Service Accounts |
| ----------- | -------------- | ---------------- | ---------------- |
| Minimum length | 14 characters | 16 characters | 128 characters |
| Complexity | Required | Required | Required |
| Maximum age | 90 days | 60 days | Never (rotate manually) |
| Password history | 24 remembered | 24 remembered | N/A |
| Account lockout threshold | 5 failed attempts | 3 failed attempts | Disabled |
| Lockout duration | 30 minutes | 60 minutes | N/A |
| Session timeout | 15 minutes idle | 10 minutes idle | N/A |

In Active Directory environments, apply fine-grained password policies to privileged user groups to enforce stricter thresholds without affecting standard users. In Entra ID, use Authentication Methods policies and Conditional Access session controls to enforce equivalent behaviour.

---

## Part 2 — Design and Implement Role-Based Access Control

RBAC assigns permissions to roles, then assigns users to roles. This enforces least privilege by ensuring users receive only the access their function requires.

### Step 2.1 — Define role tiers

Establish a role hierarchy that reflects your organisational structure. A common baseline for Essential Eight environments:

| Role Tier | Typical Permissions | Notes |
| --------- | ------------------- | ----- |
| End User | Department file shares, email, approved business applications | Default for all staff |
| Power User | End User permissions plus local admin on assigned workstation | Grant only where operationally required |
| Application Administrator | Manage a specific application, provision users within that application | Scoped to a single application |
| System Administrator | Server management, OS patching, backup management — no access to sensitive data | Separated from security admin function |
| Security Administrator | Security tooling, access reviews, incident response — no day-to-day system admin | Separation of duties with system admin |
| Database Administrator | Database management, limited data access, audited extensively | Extensive logging required |

> Separation of duties is a core access control principle. No individual should hold both System Administrator and Security Administrator privileges simultaneously.

### Step 2.2 — Build a group structure

Use security groups — not individual user accounts — as the unit of permission assignment. This simplifies auditing and reduces administrative overhead.

**Naming convention (Active Directory example):**

```
[Scope]-[Type]-[Resource]-[Permission]

Scope:   GG (Global Group), DL (Domain Local), UG (Universal)
Type:    SEC (Security)
Example: GG-SEC-FileShare-Finance-Read
         DL-SEC-App-Salesforce-Admin
```

In Microsoft Entra ID, use Entra security groups with the same intent. Assign roles to groups using [Entra role-assignable groups](https://learn.microsoft.com/entra/identity/role-based-access-control/groups-concept) where directory roles are involved.

**Group nesting strategy (Active Directory):**

```
Universal Groups (user collections)
    └─> Global Groups (department or team collections)
          └─> Domain Local Groups (permission assignments)
                └─> Resource permissions
```

### Step 2.3 — Assign permissions to resources

Apply permissions at the group level against the resources you are protecting:

**Windows file shares (NTFS):**

- Assign NTFS permissions to security groups, not individual users.
- Apply permissions at the folder level; avoid per-file assignments.
- Disable inheritance explicitly when defining a permission boundary.
- Set share-level permissions to **Everyone: Full Control** and control access exclusively via NTFS permissions.

**SQL Server:**

- Use Windows Authentication rather than SQL Server Authentication where possible.
- Create database roles scoped to schemas, then add groups to those roles.
- Avoid granting direct permissions to user accounts.

**REST APIs and cloud services:**

- Define OAuth 2.0 scopes at minimum required privilege (e.g., `api.read` separately from `api.write`).
- Store API keys and secrets in a key vault (such as Azure Key Vault or HashiCorp Vault), not in configuration files or code.
- Rotate API credentials on a defined schedule (90-day maximum).

### Step 2.4 — Conduct access reviews on schedule

Access rights must be reviewed regularly. Standing access that is not reviewed becomes standing risk.

| Account Type | Review Frequency | Reviewer | Approval Required |
| ------------ | ---------------- | -------- | ----------------- |
| Standard users | Quarterly | Direct manager | Manager |
| Privileged users | Monthly | IT Manager | Security Manager |
| Service accounts | Quarterly | Application owner | IT Manager |
| Emergency accounts | Monthly | Security team | CISO equivalent |
| External users | Monthly | Business sponsor | IT Manager |

For each review cycle:

1. Extract current access rights with last-logon dates and group memberships.
2. Flag accounts with no logon activity in the past 90 days as stale.
3. Route to the relevant reviewer for attestation.
4. Remove access for accounts that fail attestation within the agreed remediation window.
5. Archive attestation records for audit purposes.

---

## Part 3 — Configure Privileged Access Management

PAM reduces the risk of privilege abuse by limiting when and how elevated access is available. This section covers password vaulting, privileged access workstations, and the operational separation of administrative from standard use.

### Step 3.1 — Separate administrative accounts from standard accounts

Privileged users must hold two distinct accounts:

- A **standard account** for day-to-day activities such as email, web browsing, and productivity applications.
- A **dedicated administrative account** used exclusively for administrative tasks.

The administrative account must not be used for internet browsing, email access, or any activity that exposes it to untrusted content.

**Account naming convention:**

| Account Type | Convention | Example |
| ------------ | ---------- | ------- |
| Standard user | `firstname.lastname` | `alex.smith` |
| Administrative account | `firstname.lastname-admin` | `alex.smith-admin` |
| Service account | `svc-[application]-[function]` | `svc-sql-backup` |
| Emergency (break-glass) account | `emergency-admin-01`, `emergency-admin-02` | — |

### Step 3.2 — Deploy Privileged Access Workstations

A Privileged Access Workstation (PAW) is a dedicated, hardened device used exclusively for administrative tasks. It must not be a general-purpose workstation.

**PAW requirements:**

- Separate physical or virtual machine from the user's standard workstation.
- Hardened OS configuration — disable unnecessary services, applications, and features.
- No internet browsing permitted from the PAW.
- No email client on the PAW.
- Access to production systems via jump server or bastion host only.
- MFA required for all sessions.
- Enhanced session logging enabled.

**Administrative access flow:**

```
Standard workstation (daily use)
    └─> PAW (administrative tasks only)
            └─> Jump server / bastion host
                    └─> Production systems
```

### Step 3.3 — Deploy a password vault

A password vault stores and manages privileged credentials with controlled access and a full audit trail. Required capabilities:

- Encrypted credential storage at rest.
- Role-based access to vault contents.
- Check-out / check-in workflow (credentials are borrowed, not copied).
- Automatic password rotation after check-in.
- Session recording for interactive privileged sessions.
- MFA required to authenticate to the vault itself.
- Audit log of every access event.

Available solutions include CyberArk Privileged Access Manager, BeyondTrust Password Safe, Delinea Secret Server, HashiCorp Vault, and Microsoft Azure Key Vault (for non-interactive credentials).

### Step 3.4 — Manage service accounts

Service accounts authenticate applications and automated processes. They require different controls from user accounts:

- Disable interactive logon on all service accounts.
- Use 128-character randomly generated passwords.
- Do not set password expiry — rotate manually on a schedule or use managed service accounts (MSA/gMSA) where supported.
- Dedicate each service account to a single service or application.
- Document all service dependencies before any credential rotation.
- In Active Directory, prefer Group Managed Service Accounts (gMSA) to eliminate manual password management entirely.

### Step 3.5 — Configure emergency access accounts

Break-glass accounts provide last-resort access when normal administrative paths are unavailable. They require the highest level of protection:

- Create a minimum of two emergency accounts per tenant or domain.
- Store credentials in a physical safe or separately vaulted location, not in the same system they protect.
- Assign the highest required privilege level (e.g., Global Administrator in Entra ID).
- Configure MFA using a method that does not depend on the same identity infrastructure (e.g., a FIDO2 key stored with the credential).
- Log and alert on every use — any sign-in by an emergency account must generate an immediate alert.
- Test emergency accounts regularly (at minimum quarterly) to confirm access works before it is needed.
- Exclude emergency accounts from Conditional Access policies that could block them; monitor their sign-in logs separately.

---

## Part 4 — Configure Just-in-Time Access

JIT access grants elevated privileges only when requested, for a defined duration, and removes them automatically when the duration expires. This eliminates standing administrative privilege, which is a core ML3 requirement for Strategy 5.

### Step 4.1 — Define elevation tiers

Not every elevation request carries the same risk. Define tiers to calibrate the approval workflow:

| Tier | Risk | Approval Requirement | Maximum Duration |
| ---- | ---- | -------------------- | ---------------- |
| Low (standard admin tasks) | Low | Auto-approved with justification | 8 hours |
| High (sensitive or production changes) | High | Manager or peer approval | 24 hours |
| Emergency | Critical | Post-hoc review | 4 hours |

### Step 4.2 — Implement JIT using Microsoft Entra PIM

Microsoft Entra Privileged Identity Management (PIM) provides JIT access for Entra directory roles and Azure resource roles.

1. In the [Microsoft Entra admin centre](https://entra.microsoft.com), navigate to **Identity governance > Privileged Identity Management**.
2. Select **Entra roles** (for directory roles) or **Azure resources** (for Azure RBAC roles).
3. For each role requiring JIT, select the role and configure **Settings**:
   - Set **Activation maximum duration** (e.g., 8 hours for standard, 4 hours for high-sensitivity roles).
   - Enable **Require justification on activation**.
   - Enable **Require approval** for high-sensitivity roles and designate approvers.
   - Enable **Require MFA on activation** for all roles.
   - Enable **Require ticket information** if your organisation uses a change management system.
4. Assign users as **Eligible** (not **Active**) for roles that should be JIT-only.
5. Configure email notifications for activation events and approvals.

Eligible assignments mean the user holds no active privilege until they explicitly activate the role, provide justification, complete MFA, and (where required) receive approval.

### Step 4.3 — Verify JIT activation and audit logs

After configuration:

1. Test activation as an eligible user — confirm the role activates correctly and expires on schedule.
2. Confirm the activation appears in **PIM > Audit history**.
3. Confirm alerts and approval emails are received by the designated approvers and administrators.
4. Schedule a quarterly review of PIM settings to confirm no roles have been silently converted from Eligible to Active assignment.

For non-Microsoft environments, the same pattern applies using your PAM product's request-and-approve workflow (e.g., CyberArk's Just-in-Time Access, BeyondTrust's Password Safe session management).

---

## Part 5 — Network Access Controls

Network-level access controls reduce the blast radius of a compromised credential by preventing lateral movement between segments.

### Step 5.1 — Segment the network by trust zone

Divide the network into zones with explicit allow-rules between them and an implicit deny default:

| Zone | Contents | Access Rules |
| ---- | -------- | ------------ |
| Internet / DMZ | Public-facing servers (web, email gateway) | Inbound on defined ports only |
| Corporate users | Standard workstations, user devices | Outbound to approved services; no direct server access |
| Server VLAN | Application and file servers | Allow from corporate users on specific application ports; no direct internet |
| Management network | Domain controllers, PAWs, backup systems | Allow from PAWs and management tools only |
| Secure zone | Security appliances, domain controllers | Strictly restricted; no general user access |

Firewall rules must follow the pattern: **Source → Destination : Protocol/Port : Action**, with a default-deny implicit rule at the end of every rule set.

### Step 5.2 — Enforce MFA and controls for remote access

Remote access (VPN or equivalent) must meet these requirements at ML2 and above:

- MFA is mandatory for all remote access sessions.
- Split tunnelling must be disabled — all traffic routes through the VPN.
- Certificate-based authentication should be combined with MFA.
- Sessions must time out after a maximum of 8 hours of inactivity.
- All VPN connections must be logged with user identity, source IP, and session duration.

### Step 5.3 — Apply wireless access controls

Wireless networks used for corporate access must use 802.1X authentication:

- WPA3-Enterprise is required at ML3.
- WPA2-Enterprise is the minimum acceptable standard at ML1 and ML2.
- Guest networks must be fully isolated — no path from the guest SSID to internal resources.
- Per-user encryption (opportunistic wireless encryption) should be enabled where supported.

---

## Responding to Access Control Incidents

### Compromised account

| Timeframe | Actions |
| --------- | ------- |
| 0–15 minutes | Disable account; reset password; revoke all active sessions; alert the security team |
| 15 minutes – 4 hours | Review audit logs; identify accessed resources; determine scope of compromise; check for lateral movement |
| 4–24 hours | Reset credentials for all systems the account touched; remove any unauthorised changes; enhance monitoring |
| 24–72 hours | Re-enable account with new credentials after investigation; restore legitimate access; document findings |

### Unauthorised access detected

1. Preserve evidence before taking any containment action.
2. Block the access path immediately (disable the account, revoke the session, or block the source IP).
3. Notify affected parties and the security team.
4. Conduct a root-cause investigation.
5. Implement additional controls to prevent recurrence.
6. Report the incident as required under your organisation's incident management obligations and, where applicable, to the [ACSC](https://www.cyber.gov.au/report-and-recover/report).

---

## Validation Checklist

Use this checklist to confirm access controls meet the baseline before claiming compliance.

### Monthly

- [ ] Review all privileged account access and confirm no accounts have accumulated unnecessary rights.
- [ ] Verify MFA enrolment for all user accounts — identify and remediate gaps.
- [ ] Check for new administrative accounts created outside the provisioning process.
- [ ] Review and approve or reject any active access exceptions.

### Quarterly

- [ ] Complete the full access review cycle for all account types.
- [ ] Audit security group memberships against role definitions.
- [ ] Review service account dependencies and confirm passwords have been rotated or gMSA is in use.
- [ ] Validate role definitions — confirm no role has accumulated permissions beyond its documented scope.
- [ ] Test emergency (break-glass) accounts to confirm they function as expected.
- [ ] Review JIT activation logs — confirm no eligible assignments have been silently converted to active.

---

## Related Resources

### ACSC Authoritative References

- [ACSC Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/essential-eight-maturity-model)
- [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [ACSC — Implementing Multi-Factor Authentication](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/implementing-multi-factor-authentication)
- [ACSC — Restricting Administrative Privileges](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight/restricting-administrative-privileges)
- [Report a Cyber Incident — ACSC](https://www.cyber.gov.au/report-and-recover/report)

### Related Guides in This Library

- [How to Implement Restrict Administrative Privileges](how-to-implement-restrict-admin-privileges.md) — Strategy 5 implementation detail
- [How to Implement Multi-Factor Authentication](how-to-implement-multi-factor-authentication.md) — Strategy 7 implementation detail
- [Essential Eight Maturity Model Reference](reference-maturity-model.md) — Maturity level requirements and definitions
- [Essential Eight Glossary](reference-glossary.md) — Term definitions for the Essential Eight framework

### Microsoft Implementation References

- [Microsoft Entra Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-configure)
- [Conditional Access — Microsoft Entra](https://learn.microsoft.com/entra/identity/conditional-access/overview)
- [Authentication Methods — Microsoft Entra](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-methods)
- [Phishing-resistant MFA — Microsoft Learn](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)
- [Group Managed Service Accounts — Microsoft Learn](https://learn.microsoft.com/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview)
- [Emergency Access Accounts — Microsoft Learn](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access)
