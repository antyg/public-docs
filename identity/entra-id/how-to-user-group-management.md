---
title: "How to Manage Users and Groups in Entra ID"
status: "published"
last_updated: "2026-03-08"
audience: "Azure administrators, M365 administrators, identity engineers"
document_type: "how-to"
domain: "identity"
---

# How to Manage Users and Groups in Entra ID

---

## Overview

This guide covers user provisioning and lifecycle management, group types, dynamic membership rules, and role assignment in Microsoft Entra ID.

---

## User Provisioning

### Create a cloud-only user

**Navigate to**: Microsoft Entra admin centre → Identity → Users → All users → New user → Create new user

Required fields:

- **User principal name** — e.g., `jsmith@contoso.com.au`
- **Display name** — e.g., `Jane Smith`
- **Password** — Auto-generate or set manually

Microsoft Learn: [Add or delete users](https://learn.microsoft.com/en-us/entra/fundamentals/add-users-azure-active-directory)

### Invite a guest user (B2B)

**Navigate to**: Microsoft Entra admin centre → Identity → Users → All users → New user → Invite external user

Guest users authenticate with their own identity provider (Microsoft account, Google, or any SAML/OIDC IdP). Guest access is governed by [External Collaboration settings](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure).

Microsoft Learn: [B2B collaboration overview](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)

### Bulk provisioning via CSV

For large-scale provisioning, use the bulk create or bulk invite options:

**Navigate to**: Microsoft Entra admin centre → Identity → Users → All users → Bulk operations → Bulk create

Microsoft Learn: [Bulk create users](https://learn.microsoft.com/en-us/entra/identity/users/users-bulk-add)

---

## User Lifecycle Management

### Disable a user account

**Navigate to**: Microsoft Entra admin centre → Identity → Users → All users → select user → Edit properties → Account status: Blocked

Via Microsoft Graph PowerShell:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
Update-MgUser -UserId "jsmith@contoso.com.au" -AccountEnabled:$false
```

Microsoft Learn: [Disable or delete a user account](https://learn.microsoft.com/en-us/entra/fundamentals/users-revoke-access)

### Revoke all active sessions

When disabling a compromised account, revoke all active sessions immediately:

```powershell
Revoke-MgUserSignInSession -UserId "jsmith@contoso.com.au"
```

Microsoft Learn: [Revoke user access in an emergency](https://learn.microsoft.com/en-us/entra/identity/users/users-revoke-access)

---

## Group Types

Entra ID supports three main group types:

| Group Type              | Description                                                     | Membership          | Licensing             |
| ----------------------- | --------------------------------------------------------------- | ------------------- | --------------------- |
| **Security group**      | Controls access to resources and applications                   | Assigned or dynamic | Free                  |
| **Microsoft 365 group** | Collaboration group with shared mailbox, Teams, SharePoint site | Assigned or dynamic | Requires M365 licence |
| **Distribution group**  | Email distribution only — Exchange Online                       | Assigned            | Free                  |

Microsoft Learn: [Learn about groups and access rights in Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/concept-learn-about-groups)

### Create a security group

**Navigate to**: Microsoft Entra admin centre → Identity → Groups → All groups → New group

Configure:

- **Group type**: Security
- **Group name**: Use a consistent naming convention (e.g., `SG-AppName-Role`)
- **Membership type**: Assigned or Dynamic User

Microsoft Learn: [Create a basic group and add members](https://learn.microsoft.com/en-us/entra/fundamentals/groups-view-azure-portal)

---

## Dynamic Membership Rules

Dynamic groups automatically add and remove members based on user or device attributes. This is particularly useful for automating access provisioning at scale.

**Navigate to**: Microsoft Entra admin centre → Identity → Groups → New group → Membership type: Dynamic User

Example rules:

```text
# All users in the Sydney office
(user.officeLocation -eq "Sydney")

# All full-time employees (not guests)
(user.userType -eq "Member") and (user.department -eq "Engineering")

# All users with a specific licence attribute
(user.assignedPlans -any (assignedPlan.servicePlanId -eq "efb87545-963c-4e0d-99df-69c6916d9eb0" -and assignedPlan.capabilityStatus -eq "Enabled"))
```

Microsoft Learn: [Dynamic membership rules for groups](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership)

**Note**: Dynamic group membership updates can take up to 24 hours. For time-sensitive provisioning, use assigned groups.

---

## Administrative Units

Administrative units (AUs) enable scoped administration — delegating management of a subset of users or groups to a regional or department-level administrator without granting full tenant admin rights.

**Navigate to**: Microsoft Entra admin centre → Identity → Administrative units → Add

Example use cases:

- Australia region administrators manage only AU-based users
- HR team manages only HR department groups
- IT helpdesk resets passwords only for their site's users

Microsoft Learn: [Administrative units in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/administrative-units)

---

## Role Assignment

### Assign a built-in Entra ID role

**Navigate to**: Microsoft Entra admin centre → Identity → Roles & admins → select role → Add assignments

Common roles:

| Role                             | Purpose                                                     |
| -------------------------------- | ----------------------------------------------------------- |
| Global Administrator             | Full tenant control — restrict to break-glass accounts only |
| User Administrator               | Create and manage users and groups                          |
| Helpdesk Administrator           | Reset passwords for non-admins                              |
| Application Administrator        | Manage app registrations and enterprise apps                |
| Security Administrator           | Manage security policies and review security alerts         |
| Conditional Access Administrator | Manage Conditional Access policies                          |

Microsoft Learn: [Built-in Entra ID roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)

### Use Privileged Identity Management (PIM) for just-in-time access

For P2-licensed tenants, use [Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) to make privileged role assignments eligible (time-limited, approval-gated, MFA-enforced) rather than permanent.

This aligns with the [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) — Restrict Administrative Privileges control and [ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) requirements for privileged access management.

---

## Related Resources

- [Add or delete users](https://learn.microsoft.com/en-us/entra/fundamentals/add-users-azure-active-directory)
- [B2B collaboration](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)
- [Groups and access rights](https://learn.microsoft.com/en-us/entra/fundamentals/concept-learn-about-groups)
- [Dynamic membership rules](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership)
- [Administrative units](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/administrative-units)
- [Built-in Entra ID roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)
- [Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [ACSC — Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
