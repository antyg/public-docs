---
title: "Password Policy Standards and Templates"
status: "published"
last_updated: "2026-03-08"
audience: "Security architects, compliance officers, IT administrators"
document_type: "reference"
domain: "identity"
---

# Password Policy Standards and Templates

---

## Standards Reference

### NIST SP 800-63B-4 (July 2025) — Key Requirements

Source: [NIST SP 800-63B-4 Authentication Guidelines](https://pages.nist.gov/800-63-4/sp800-63b.html)

| Requirement                    | SHALL / SHALL NOT | Detail                                                                  |
| ------------------------------ | ----------------- | ----------------------------------------------------------------------- |
| Periodic password changes      | SHALL NOT require | Verifiers shall not require memorised secrets to be changed arbitrarily |
| Composition rules              | SHALL NOT impose  | No requirements for mixed character types                               |
| Minimum length                 | SHALL enforce     | 8 characters minimum; 12–16 strongly recommended                        |
| Maximum length                 | SHALL support     | At least 64 characters                                                  |
| Password hints                 | SHALL NOT permit  | No hints or knowledge-based security questions                          |
| Compromised password screening | SHALL implement   | Check against known breached password lists                             |
| Password manager support       | SHALL support     | Must not block paste or auto-fill                                       |
| Password visibility            | SHALL support     | Option to show password during entry                                    |
| Mandatory changes              | SHALL require     | Only when evidence of compromise                                        |

---

### Microsoft Entra ID — Default Behaviour

Source: [Microsoft: Password Policy Recommendations](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations)

| Setting              | Microsoft Default (post-2021 tenants) | Microsoft Recommendation                   |
| -------------------- | ------------------------------------- | ------------------------------------------ |
| Password expiration  | Never expires                         | Never expire unless compromised            |
| Minimum length       | 8 characters                          | 14 characters                              |
| Complexity rules     | Enabled by default                    | Remove — use length instead                |
| Banned password list | Global list enabled                   | Enable custom list with org-specific terms |
| Password Protection  | Available                             | Enable for all environments                |

Source: [Entra ID Default Password Expiration](https://learn.microsoft.com/en-us/answers/questions/2137658/entra-id-user-default-password-expiration-policy)

---

### ACSC / ISM (Australian Context)

Source: [ACSC Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)

| Aspect              | ACSC / ISM Position                                            |
| ------------------- | -------------------------------------------------------------- |
| Password expiration | Not mandated as a standalone control                           |
| MFA                 | Mandated — Essential Eight Maturity Level 1+                   |
| Passphrase          | Supported — ISM recommends passphrases of 4+ words             |
| Password length     | Minimum 14 characters for privileged accounts per ISM guidance |
| Banned passwords    | Recommended as part of credential hygiene                      |

The [Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) does not include periodic password expiration as a control. MFA is the identity-related Essential Eight control.

---

## Glossary

| Term                                 | Definition                                                                            | Source                                                                                                                          |
| ------------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| AAL (Authentication Assurance Level) | NIST framework levels (1–3) defining confidence in authentication processes           | [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html)                                                             |
| Banned Password List                 | Collections of commonly compromised or weak passwords prohibited from use             | [Microsoft: Password Protection](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-password-ban-bad)      |
| Conditional Access                   | Microsoft Entra feature applying access controls based on conditions and risk         | [Microsoft: Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)                   |
| Essential Eight                      | ACSC's eight prioritised mitigation strategies                                        | [ACSC: Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)    |
| Identity Protection                  | Microsoft Entra cloud service detecting identity-based risks                          | [Microsoft: Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)            |
| ISM                                  | Australian Government Information Security Manual                                     | [ACSC: ISM](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)                            |
| MFA (Multi-Factor Authentication)    | Authentication using two or more different factors                                    | [Microsoft: MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks)                        |
| Passphrase                           | A longer password composed of multiple words                                          | [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html)                                                             |
| Password Normalisation               | The tendency for policies to reduce password variety and increase predictability      | [Microsoft: Policy Recommendations](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations) |
| Passwordless Authentication          | Authentication without memorised secrets (biometrics, hardware tokens)                | [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html)                                                             |
| Risk-Based Authentication            | Dynamic authentication requirements based on assessed risk factors                    | [Microsoft: Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)            |
| Security Theatre                     | Measures providing the appearance of security without meaningful protection           | [TechCrunch: Windows Password Expiry](https://techcrunch.com/2019/04/24/windows-password-expiry/)                               |
| SSPR (Self-Service Password Reset)   | System allowing users to reset their own passwords without administrator intervention | [Microsoft: SSPR](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-policy)                          |

---

## Regulatory and Compliance Acronyms

| Term                                    | Definition                                                                    | Source                                                                                                              |
| --------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| ACSC (Australian Cyber Security Centre) | Australian government agency providing cybersecurity guidance                 | [Cyber.gov.au](https://www.cyber.gov.au/)                                                                           |
| ASD (Australian Signals Directorate)    | Australian intelligence agency responsible for signals intelligence and cyber | [ASD.gov.au](https://www.asd.gov.au/)                                                                               |
| Essential Eight                         | Australian government's prioritised mitigation strategies                     | [Cyber.gov.au](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight) |
| ISM (Information Security Manual)       | Australian government's framework for protecting information                  | [Cyber.gov.au](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)             |
| NIST                                    | US National Institute of Standards and Technology — publishes SP 800-63B-4    | [NIST.gov](https://www.nist.gov/)                                                                                   |
| OAIC                                    | Office of the Australian Information Commissioner                             | [OAIC.gov.au](https://www.oaic.gov.au/)                                                                             |
| PCI-DSS                                 | Payment Card Industry Data Security Standard                                  | [PCISecurityStandards.org](https://www.pcisecuritystandards.org/)                                                   |
| PSPF                                    | Protective Security Policy Framework                                          | [ProtectiveSecurity.gov.au](https://www.protectivesecurity.gov.au/)                                                 |

---

## Decision Framework

```text
START: Review current password expiration policy
  │
  ├─ Does your organisation have specific regulatory requirements?
  │   ├─ YES → Can you justify longer expiration periods?
  │   │         ├─ YES → Set to longest acceptable period (730 days max)
  │   │         └─ NO  → Maintain; document risk acceptance; implement all compensating controls
  │   └─ NO  → Remove password expiration
  │
  ├─ Is MFA enabled for all users?
  │   ├─ YES → Proceed
  │   └─ NO  → STOP — enable MFA first; this is a prerequisite
  │
  ├─ Is Entra Password Protection configured?
  │   ├─ YES → Proceed
  │   └─ NO  → Enable banned password lists before removing expiration
  │
  └─ Is risk-based authentication (Entra ID Protection) configured?
      ├─ YES → Policy implementation complete — monitor quarterly
      └─ NO  → Configure Identity Protection risk policies
```

---

## Related Resources

### Australian Regulatory

- [ACSC — Essential Eight Maturity Model](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [ACSC — Information Security Manual (ISM)](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism)
- [OAIC — Privacy Act 1988](https://www.oaic.gov.au/privacy/the-privacy-act)

### Microsoft Documentation

- [Password Policy Recommendations](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations)
- [Set Password Expiration Policy](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy)
- [Entra ID Password Protection](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-password-ban-bad)
- [Conditional Access Overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Identity Protection Overview](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- [Microsoft Password Guidance Research Paper](https://www.microsoft.com/en-us/research/publication/password-guidance/)
- [Authentication Methods Policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-authentication-methods-manage)

### NIST Publications

- [SP 800-63B-4 Authentication Guidelines (July 2025)](https://pages.nist.gov/800-63-4/sp800-63b.html)
- [SP 800-63-4 Digital Identity Guidelines](https://pages.nist.gov/800-63-4/sp800-63.html)
- [NIST SP 800-63B-4 FAQ](https://pages.nist.gov/800-63-FAQ/)
