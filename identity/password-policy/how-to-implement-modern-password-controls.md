---
title: "How to Implement Modern Password Controls"
status: "published"
last_updated: "2026-03-08"
audience: "IT administrators, identity engineers"
document_type: "how-to"
domain: "identity"
---

# How to Implement Modern Password Controls

**Prerequisite**: Read [Why Mandatory Password Expiration Is Counterproductive](explanation-why-expiration-is-counterproductive.md) before making changes.

---

## Overview

This guide covers the steps to remove mandatory password expiration from Microsoft Entra ID and enable the compensating controls that replace it. MFA and banned password protection must be in place before expiration requirements are removed.

---

## Prerequisites

Before removing password expiration:

- [ ] MFA is enabled for all user accounts (critical — do not proceed without this)
- [ ] Microsoft Entra ID Password Protection is configured
- [ ] Conditional Access policies are in place for risk-based authentication
- [ ] Stakeholders and compliance team are informed
- [ ] Risk acceptance is documented if any compliance mandate remains

---

## Step 1: Remove or Extend Password Expiration

### Via Microsoft 365 Admin Centre

Navigate to: **Admin centre → Settings → Org settings → Security & privacy → Password policy**

Set the password expiration policy to **Passwords never expire**.

Microsoft Learn: [Set the password expiration policy for your organisation](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)

### Via Microsoft Graph PowerShell

```powershell
# Set password to never expire for all users
Connect-MgGraph -Scopes "User.ReadWrite.All"

Get-MgUser -All | ForEach-Object {
    Update-MgUser -UserId $_.Id -PasswordPolicies DisablePasswordExpiration
}
```

### Via Microsoft Graph PowerShell (per-user)

```powershell
# Set password to never expire for a specific user
Update-MgUser -UserId "user@contoso.com" -PasswordPolicies DisablePasswordExpiration
```

Microsoft Learn: [Set password expiration policy](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)

---

## Step 2: Enable Microsoft Entra Password Protection

Password Protection blocks the use of commonly compromised passwords and organisation-specific terms.

### Configure via Entra admin centre

Navigate to: **Microsoft Entra admin centre → Protection → Authentication methods → Password protection**

Configure:

- **Lockout threshold**: 10 failed attempts
- **Lockout duration**: 60 seconds (minimum)
- **Custom banned passwords**: Add your organisation name, product names, and common internal patterns
- **Enable password protection on Windows Server Active Directory**: Yes (if hybrid)

Microsoft Learn: [Configure Entra ID Password Protection](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-password-ban-bad)

---

## Step 3: Enable and Configure MFA

MFA is the critical compensating control. If not already deployed, enable it before removing password expiration.

### Enable MFA via Conditional Access (recommended approach)

Create a Conditional Access policy that requires MFA for all users:

Navigate to: **Microsoft Entra admin centre → Protection → Conditional Access → New policy**

Configure:

- **Users**: All users
- **Cloud apps**: All cloud apps
- **Grant**: Require multi-factor authentication

Microsoft Learn: [Conditional Access: Require MFA for all users](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-all-users-mfa)

### Enable Microsoft Authenticator (recommended primary method)

Navigate to: **Microsoft Entra admin centre → Protection → Authentication methods → Policies**

Enable **Microsoft Authenticator** for all users. Authenticator app push notifications provide phishing-resistant MFA superior to SMS.

Microsoft Learn: [Enable the Microsoft Authenticator app](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-authenticator-app)

---

## Step 4: Configure Risk-Based Authentication (Entra ID Protection)

Entra ID Protection provides risk-based authentication that triggers step-up verification for suspicious sign-ins.

Navigate to: **Microsoft Entra admin centre → Protection → Identity Protection**

Configure two policies:

### Sign-in risk policy

- **Sign-in risk level**: Medium and above
- **Action**: Require multi-factor authentication

### User risk policy

- **User risk level**: High
- **Action**: Require password change

Microsoft Learn: [Configure and enable risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Step 5: Set Minimum Password Length

Remove complexity rules (mixed case/symbols) and set a minimum length of 14 characters, aligned with [Microsoft guidance](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations) and [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html).

For hybrid environments, configure via Group Policy:

```text
Computer Configuration → Windows Settings → Security Settings → Account Policies → Password Policy
  Minimum password length: 14
  Password must meet complexity requirements: Disabled
  Maximum password age: 0 (never)
```

---

## Step 6: Communicate the Change to Users

Explain to users:

- Why the change is happening (evidence-based security improvement)
- That their current password will not expire
- That they should use a password manager
- That MFA is now required and how to set it up

---

## Step 7: Monitor and Validate

After implementation, validate:

- All user accounts have `DisablePasswordExpiration` set
- MFA registration rate is approaching 100%
- Password Protection is blocking weak/banned passwords
- Entra ID Protection risk events are being generated and actioned

### Check MFA registration status

Navigate to: **Microsoft Entra admin centre → Reports → Authentication methods → User registration details**

---

## When Expiration Cannot Be Fully Removed

If a compliance mandate requires retention of expiration:

1. Set the longest permitted period: up to 730 days via [Set-MsolUser](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)
2. Implement all compensating controls listed in this guide
3. Document the risk acceptance rationale in writing
4. Schedule regular reviews as compliance frameworks evolve — most are moving toward alignment with NIST SP 800-63B-4

---

## Related Resources

- [Microsoft: Password Policy Recommendations](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations)
- [Microsoft: Set Password Expiration Policy](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)
- [Microsoft: Entra ID Password Protection](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-password-ban-bad)
- [Microsoft: Entra ID Protection Overview](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- [Microsoft: Conditional Access Overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [NIST SP 800-63B-4 (July 2025)](https://pages.nist.gov/800-63-4/sp800-63b.html)
- [ACSC — Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
