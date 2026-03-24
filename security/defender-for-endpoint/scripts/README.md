---
title: "Scripts — Microsoft Defender for Endpoint"
status: "published"
last_updated: "2026-03-09"
audience: "Security Engineers"
document_type: "readme"
domain: "security"
platform: "Microsoft Defender for Endpoint"
---

# Scripts — Microsoft Defender for Endpoint

## About This Section

Production-ready PowerShell scripts for validating, inventorying, and troubleshooting Microsoft Defender for Endpoint deployments. All scripts target PowerShell 5.1+ for broad Windows compatibility.

---

## Active Scripts

| Script | Purpose | Auth Required |
|--------|---------|---------------|
| [Get-MDEStatus.ps1](Get-MDEStatus.ps1) | Intelligent multi-method MDE validation with automatic fallback (CIM → WMI → Registry → Service) | Windows Auth / PSCredential |
| [Export-MDEInventoryFromGraph.ps1](Export-MDEInventoryFromGraph.ps1) | Export MDE onboarding status for all devices from the Security Center API | App Registration (client credentials) |
| [Test-MDEConnectivity.ps1](Test-MDEConnectivity.ps1) | Test DNS, TCP, and HTTPS connectivity to MDE regional cloud endpoints | None |
| [Get-MDEClientAnalyzer.ps1](Get-MDEClientAnalyzer.ps1) | Download and extract the official MDE Client Analyser diagnostic tool | None (downloads from aka.ms) |
| [Test-MDEStatusPrerequisites.ps1](Test-MDEStatusPrerequisites.ps1) | Comprehensive 16-category pre-flight validation of network, DNS, VPN, ports, and auth prerequisites before running Get-MDEStatus.ps1 against remote devices | Windows Auth / PSCredential |

`Get-MDEStatus.ps1` consolidates all previous single-method validation scripts (CIM, WMI, Registry, and Service) into a single script with automatic fallback ordering. Use `Get-MDEStatus.ps1` with the `-PreferredMethod` parameter for targeted single-method validation.

---

## Quick Reference

### Validate a single device

```powershell
.\Get-MDEStatus.ps1 -ComputerName WORKSTATION01
```

### Validate devices from a CSV list

```powershell
.\Get-MDEStatus.ps1 -CsvPath "C:\devices.csv" -OutputPath "C:\mde-status.csv"
```

### Export full tenant inventory via Graph API

```powershell
.\Export-MDEInventoryFromGraph.ps1 `
    -TenantId "your-tenant-id" `
    -ClientId "your-client-id" `
    -ClientSecret "your-client-secret"
```

### Test network connectivity to MDE endpoints (Australian region)

```powershell
.\Test-MDEConnectivity.ps1 -Region AU
```

### Download the MDE Client Analyzer

```powershell
.\Get-MDEClientAnalyzer.ps1
```

---

## CSV Input Format

All scripts that accept CSV input require a `Hostname` column:

```csv
Hostname,Notes
WORKSTATION01,Finance Department
WORKSTATION02,HR Department
SERVER01,Domain Controller
```

---

## Related Sections

- [PowerShell Validation Tutorial](../tutorial-powershell-validation.md) — Step-by-step local and remote PowerShell validation exercises
- [Graph API Validation Tutorial](../tutorial-graph-api-validation.md) — Step-by-step Graph Security API inventory tutorial
- [Console Validation How-to](../how-to-console-validation.md) — Portal-based verification via Microsoft Defender portal
- [Configuration Artefacts](../config/README.md) — Azure Monitor workbook and policy baseline for MDE deployment
