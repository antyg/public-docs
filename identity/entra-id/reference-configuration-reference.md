---
title: "Microsoft Entra ID — Configuration Reference"
status: "published"
last_updated: "2026-03-08"
audience: "Identity engineers, Azure administrators"
document_type: "reference"
domain: "identity"
---

# Microsoft Entra ID — Configuration Reference

---

## Tenant Settings Reference

| Setting                        | Location                                                 | Recommended Value                                           | Notes                                       |
| ------------------------------ | -------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------- |
| Security defaults              | Identity → Overview → Properties                         | Disabled if using Conditional Access; Enabled for free tier | Mutually exclusive with Conditional Access  |
| Password expiration            | M365 admin centre → Security & privacy → Password policy | Never expire                                                | See [password-policy/](../../password-policy/README.md) |
| App registration by non-admins | Identity → Users → User settings                         | No                                                          | Prevents uncontrolled app proliferation     |
| LinkedIn account connections   | Identity → Users → User settings                         | No                                                          | Disable unless business need                |
| Guest invite permissions       | External Collaboration settings                          | Admins and users in specific roles                          | Avoid "Any user can invite"                 |

---

## Authentication Methods Reference

| Method                            | Protocol       | Phishing Resistant                    | ACSC E8 Compliant | Notes                                                  |
| --------------------------------- | -------------- | ------------------------------------- | ----------------- | ------------------------------------------------------ |
| Microsoft Authenticator (push)    | Proprietary    | No (but number matching reduces risk) | ML1+              | Recommended default                                    |
| Microsoft Authenticator (passkey) | FIDO2/WebAuthn | Yes                                   | ML2+              | Passwordless; hardware-backed                          |
| FIDO2 security key                | FIDO2/WebAuthn | Yes                                   | ML2+              | Strongest phishing resistance                          |
| Windows Hello for Business        | FIDO2/WebAuthn | Yes                                   | ML2+              | Device-bound; enterprise deployment                    |
| TOTP (third-party authenticator)  | TOTP RFC 6238  | No                                    | ML1+              | Acceptable; not phishing-resistant                     |
| SMS OTP                           | SMS            | No                                    | Not recommended   | Susceptible to SIM-swap; avoid for privileged accounts |
| Voice call OTP                    | PSTN           | No                                    | Not recommended   | As above                                               |
| Temporary Access Pass             | None           | N/A                                   | N/A               | Onboarding/recovery only                               |

Microsoft Learn: [Authentication methods in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)

ACSC Essential Eight: [MFA requirements by maturity level](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

---

## Built-In Role Reference (Identity Administration)

| Role                                    | Key Permissions                                       | Least-Privilege Use Case             |
| --------------------------------------- | ----------------------------------------------------- | ------------------------------------ |
| Global Administrator                    | Full tenant control                                   | Break-glass account only; use PIM    |
| Global Reader                           | Read-only across all services                         | Auditing, review                     |
| User Administrator                      | Create/manage users and groups                        | Day-to-day identity administration   |
| Helpdesk Administrator                  | Reset passwords (non-admins), manage service requests | L1 support                           |
| Authentication Administrator            | Reset MFA for non-admins                              | MFA helpdesk                         |
| Privileged Authentication Administrator | Reset MFA for all users including admins              | Escalated MFA helpdesk               |
| Application Administrator               | Manage app registrations and enterprise apps          | Application onboarding team          |
| Cloud Application Administrator         | As above, excluding App Proxy                         | Application onboarding (no hybrid)   |
| Security Administrator                  | Manage security policies, view Security Centre        | Security team                        |
| Security Reader                         | Read-only security access                             | Security monitoring                  |
| Conditional Access Administrator        | Create and modify Conditional Access policies         | IAM engineer                         |
| Directory Readers                       | Read basic directory information                      | Service accounts needing read access |

Microsoft Learn: [Built-in Entra ID roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)

---

## Entra Connect — Sync Attribute Reference

Key attributes synchronised from on-premises AD to Entra ID:

| Entra ID Attribute            | Source AD Attribute                | Notes                               |
| ----------------------------- | ---------------------------------- | ----------------------------------- |
| `userPrincipalName`           | `userPrincipalName`                | Must match a verified custom domain |
| `displayName`                 | `displayName`                      |                                     |
| `mail`                        | `mail`                             |                                     |
| `mailNickname`                | `mailNickname` or `sAMAccountName` | Used for proxy address generation   |
| `objectId` (cloud)            | `objectGUID`                       | Source anchor by default            |
| `onPremisesSamAccountName`    | `sAMAccountName`                   | Read-only in cloud                  |
| `onPremisesDistinguishedName` | `distinguishedName`                | Read-only in cloud                  |
| `department`                  | `department`                       | Useful for dynamic group rules      |
| `officeLocation`              | `physicalDeliveryOfficeName`       | Useful for dynamic group rules      |
| `jobTitle`                    | `title`                            |                                     |
| `mobilePhone`                 | `mobile`                           | Used for SSPR and MFA               |
| `manager`                     | `manager`                          |                                     |

Microsoft Learn: [Attributes synchronised by Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-sync-attributes-synchronized)

---

## Key Microsoft Graph API Endpoints

| Operation               | HTTP Method | Endpoint                                                                              |
| ----------------------- | ----------- | ------------------------------------------------------------------------------------- |
| List all users          | GET         | `https://graph.microsoft.com/v1.0/users`                                              |
| Get specific user       | GET         | `https://graph.microsoft.com/v1.0/users/{userId}`                                     |
| Update user             | PATCH       | `https://graph.microsoft.com/v1.0/users/{userId}`                                     |
| Disable user            | PATCH       | `https://graph.microsoft.com/v1.0/users/{userId}` (body: `{"accountEnabled": false}`) |
| Revoke sign-in sessions | POST        | `https://graph.microsoft.com/v1.0/users/{userId}/revokeSignInSessions`                |
| List all groups         | GET         | `https://graph.microsoft.com/v1.0/groups`                                             |
| Create group            | POST        | `https://graph.microsoft.com/v1.0/groups`                                             |
| List app registrations  | GET         | `https://graph.microsoft.com/v1.0/applications`                                       |
| List service principals | GET         | `https://graph.microsoft.com/v1.0/servicePrincipals`                                  |
| List sign-in logs       | GET         | `https://graph.microsoft.com/v1.0/auditLogs/signIns`                                  |
| List audit logs         | GET         | `https://graph.microsoft.com/v1.0/auditLogs/directoryAudits`                          |

Microsoft Learn: [Microsoft Graph API reference](https://learn.microsoft.com/en-us/graph/api/overview)

---

## Common PowerShell Commands (Microsoft Graph PowerShell)

```powershell
# Connect
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"

# List all users
Get-MgUser -All | Select-Object DisplayName, UserPrincipalName, AccountEnabled

# Disable a user
Update-MgUser -UserId "user@contoso.com.au" -AccountEnabled:$false

# Revoke all sessions
Revoke-MgUserSignInSession -UserId "user@contoso.com.au"

# Set password to never expire
Update-MgUser -UserId "user@contoso.com.au" -PasswordPolicies DisablePasswordExpiration

# List members of a group
Get-MgGroupMember -GroupId "group-object-id" | Select-Object Id

# List assigned roles for a user
Get-MgUserMemberOf -UserId "user@contoso.com.au" | Where-Object { $_.ODataType -eq "#microsoft.graph.directoryRole" }

# Get last sync time (hybrid)
Get-MgOrganization | Select-Object -ExpandProperty OnPremisesLastSyncDateTime
```

Microsoft Learn: [Microsoft Graph PowerShell overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)

---

## Related Resources

- [Microsoft Entra admin centre](https://entra.microsoft.com/)
- [Microsoft Entra ID documentation hub](https://learn.microsoft.com/en-us/entra/identity/)
- [Authentication methods reference](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)
- [Built-in Entra ID roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference)
- [Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Microsoft Graph API reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Entra Connect sync attributes](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-sync-attributes-synchronized)
- [ACSC — Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
