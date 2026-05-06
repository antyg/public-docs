---
title: "How to Configure Directory Synchronisation with Entra Connect"
status: "published"
last_updated: "2026-03-08"
audience: "Identity engineers, Azure administrators, hybrid identity architects"
document_type: "how-to"
domain: "identity"
---

# How to Configure Directory Synchronisation with Entra Connect

---

## Overview

This guide covers deploying Microsoft Entra Connect to synchronise identities from on-premises Active Directory to Microsoft Entra ID, selecting an authentication method for hybrid environments, and configuring sync filtering.

---

## Prerequisites

Before deploying Entra Connect:

- [ ] On-premises Active Directory forest is healthy (no critical replication errors)
- [ ] A dedicated service account is created for Entra Connect with appropriate AD permissions
- [ ] The Entra Connect server is a domain-joined Windows Server 2016 or later (not a domain controller)
- [ ] Entra Connect server has outbound HTTPS access to Microsoft endpoints
- [ ] Entra ID tenant has a Global Administrator account available for initial configuration
- [ ] UPN suffixes in on-premises AD match verified custom domains in Entra ID

Microsoft Learn: [Prerequisites for Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-prerequisites)

---

## 1. Choose an Authentication Method

Select the authentication method before installing Entra Connect. This is the most significant architectural decision for hybrid identity.

| Method                                | How It Works                                                                                    | Pros                                                                                               | Cons                                                                                            |
| ------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| **Password Hash Sync (PHS)**          | Hash of the on-premises password hash is synced to Entra ID; authentication occurs in the cloud | Highest resilience; no on-premises dependency for auth; enables Identity Protection leak detection | Password hashes leave on-premises environment                                                   |
| **Pass-Through Authentication (PTA)** | Authentication request forwarded to on-premises AD via lightweight agent                        | No password hashes in cloud; on-premises password policy enforced                                  | Requires on-premises agent availability; no Identity Protection leaked credential detection     |
| **Federation (AD FS)**                | Authentication redirected entirely to on-premises AD FS                                         | Supports complex claims transformation; on-premises password policy enforced                       | Most complex; high availability AD FS infrastructure required; significant maintenance overhead |

**Recommendation for most organisations**: Password Hash Sync. It provides the highest resilience and enables the full Entra ID Protection feature set including leaked credential detection. The [ACSC ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism) does not prohibit PHS — the password hash sync is a hash of a hash, not the original password.

Microsoft Learn: [Choose the right authentication method for your hybrid identity solution](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/choose-ad-authn)

---

## 2. Install Microsoft Entra Connect

Download the Entra Connect installer from: [Microsoft Download Centre — Entra Connect](https://www.microsoft.com/en-au/download/details.aspx?id=47594)

Run the installer on the dedicated Entra Connect server.

### Express installation (single forest, no customisation needed)

Select **Express Settings** if:

- You have a single on-premises AD forest
- You want Password Hash Sync
- You want to sync all users and groups

Microsoft Learn: [Express installation of Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-express)

### Custom installation

Select **Customize** if:

- You have multiple forests
- You want Pass-Through Authentication or Federation
- You need to configure sync filtering
- You need to customise attribute flow

Microsoft Learn: [Custom installation of Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-custom)

---

## 3. Configure Sync Filtering

By default, Entra Connect syncs all users, groups, contacts, and devices from all domains in the forest. Use filtering to scope the sync to only required objects.

### Domain and OU filtering

**In Entra Connect configuration wizard**: Synchronization Options → Filter sync by domain and OU

Exclude OUs that contain service accounts, computer objects, or other objects not required in Entra ID.

### Attribute-based filtering

Attribute-based filtering uses an on-premises AD attribute (e.g., `extensionAttribute1`) to include or exclude objects:

```
# Include rule: sync only objects with extensionAttribute1 = "SyncToCloud"
(extensionAttribute1 -eq "SyncToCloud")
```

Microsoft Learn: [Configure filtering for Microsoft Entra Connect Sync](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-configure-filtering)

---

## 4. Configure Entra Connect Staging Mode

Deploy a second Entra Connect server in **staging mode** for disaster recovery. A staging server runs the full sync engine and imports from AD and Entra ID but does not export changes.

To promote a staging server to active:

1. Disable the current active server
2. Open Entra Connect configuration on the staging server
3. Deselect **Staging mode** and complete the wizard

Microsoft Learn: [Staging server and disaster recovery](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-staging-server)

---

## 5. Enable Password Writeback (SSPR)

Password Writeback enables self-service password reset (SSPR) to write password changes back to on-premises AD.

**In Entra Connect configuration**: Optional Features → Password writeback → Enable

**In Entra admin centre**: Protection → Password reset → On-premises integration → Enable writeback

This is required for hybrid users to use cloud-initiated SSPR with their on-premises AD password.

Microsoft Learn: [Enable password writeback in Microsoft Entra Connect](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr-writeback)

---

## 6. Monitor Sync Health

### Entra Connect Health

Install the [Entra Connect Health agent](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-health-agent-install) on the Entra Connect server to monitor:

- Sync errors and attribute-level errors
- Replication status
- Performance counters

**Navigate to**: Microsoft Entra admin centre → Identity → Hybrid management → Entra Connect Health

### Check sync status via PowerShell

```powershell
# Check last sync time
Get-MgOrganization | Select-Object -ExpandProperty OnPremisesLastSyncDateTime

# Check for sync errors
Get-MgUser -Filter "onPremisesSyncEnabled eq true" -All |
    Where-Object { $_.OnPremisesProvisioningErrors.Count -gt 0 } |
    Select-Object UserPrincipalName, OnPremisesProvisioningErrors
```

Microsoft Learn: [Monitor Microsoft Entra Connect Sync](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-health-sync)

---

## Related Resources

- [Entra Connect prerequisites](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-prerequisites)
- [Choose authentication method](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/choose-ad-authn)
- [Express installation](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-express)
- [Custom installation](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-custom)
- [Configure filtering](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-configure-filtering)
- [Password writeback](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr-writeback)
- [Entra Connect Health](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/whatis-azure-ad-connect-health)
- [ACSC — ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
