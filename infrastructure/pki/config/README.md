---
title: "PKI Configuration Files Collection"
status: "draft"
last_updated: "2026-03-16"
audience: "Infrastructure Engineers"
document_type: "readme"
domain: "infrastructure"
---

# PKI Configuration Files Collection

## Purpose

This directory contains 10 configuration file templates for PKI components, including CA policy, CRL distribution, OCSP responders, monitoring, HSM integration, governance, and appliance integration. These files were developed as part of the PKI modernisation project (February–April 2025).

---

## Configuration Files

| File | Format | Purpose |
|------|--------|---------|
| `Android-SCEP-Configuration.yaml` | YAML | SCEP enrolment profile for Android devices via Intune |
| `appliance-config.json` | JSON | Certificate binding configuration for network appliances (NetScaler, F5) |
| `configure-f5-ssl.tcl` | Tcl | F5 BIG-IP iControl Tcl script for SSL profile and certificate configuration |
| `DR-Configuration.yaml` | YAML | Disaster recovery configuration: failover targets, RTO/RPO parameters, backup locations |
| `Enrollment-Monitoring-Configuration.yaml` | YAML | Certificate enrolment monitoring thresholds, alert channels, and reporting schedules |
| `EST-Server-Configuration.yaml` | YAML | EST (Enrollment over Secure Transport) server parameters including TLS settings and CA binding |
| `Handover-Checklist.yaml` | YAML | Structured project handover checklist covering operational readiness criteria |
| `monitoring-config.yaml` | YAML | PKI health monitoring configuration: targets, check intervals, alert thresholds |
| `PKI-API-Configuration.yaml` | YAML | REST API service configuration for PKI operations gateway |
| `PKI-Infrastructure-Governance-Policy.json` | JSON | Governance policy document defining CA roles, approval workflows, and certificate issuance constraints |

---

## File Descriptions

### Android-SCEP-Configuration.yaml

SCEP enrolment profile template for Android devices managed through Microsoft Intune. Specifies the NDES URL, challenge password rotation, certificate template name, subject name format, and renewal threshold. Import into Intune as a SCEP certificate profile.

### appliance-config.json

JSON template for certificate binding configuration across network appliances including Citrix NetScaler and F5 BIG-IP. Contains SSL profile definitions, cipher suite selections, certificate thumbprints, and binding port assignments. Consumed by `Deploy-CertificateToAppliances.ps1`.

### configure-f5-ssl.tcl

Tcl script executed within the F5 BIG-IP iControl TMOS shell environment. Configures SSL client and server profiles, assigns certificates to virtual servers, and applies cipher string policies. Deploy using the F5 Advanced Shell (TMSH) or iControl REST API.

### DR-Configuration.yaml

Disaster recovery configuration specifying failover targets in Azure Australia Southeast, recovery time objectives (RTO), recovery point objectives (RPO), backup storage locations, and the sequence of recovery steps. Referenced by the disaster recovery runbook.

### Enrollment-Monitoring-Configuration.yaml

Monitoring configuration for certificate enrolment telemetry. Defines success rate thresholds, alert escalation paths, dashboard data sources, and reporting schedule. Consumed by `Monitor-PilotMigration.ps1` and `Monitor-SCCMCertificates.ps1`.

### EST-Server-Configuration.yaml

Configuration template for the EST (Enrollment over Secure Transport, [RFC 7030](https://datatracker.ietf.org/doc/html/rfc7030)) server. Specifies TLS certificate binding, CA connector settings, client authentication requirements, and rate limiting. Used by `est.company.com.au` service.

### Handover-Checklist.yaml

Structured YAML checklist for project operational handover. Each item specifies the owner, acceptance criteria, and verification method. Used by `Complete-ProjectClosure.ps1` to generate the final handover report.

### monitoring-config.yaml

Top-level PKI health monitoring configuration. Defines check targets (CA availability, CRL freshness age, OCSP response time, certificate expiry windows), polling intervals, and alert thresholds. Consumed by `daily-pki-health-check.ps1` and `perform-weekly-maintenance.ps1`.

### PKI-API-Configuration.yaml

Configuration for the PKI operations REST API service (`pki-api-service.py`). Specifies listening address, TLS certificate, authentication method, rate limits, and allowed operations (enrol, revoke, renew, status). Deployed on the PKI API gateway.

### PKI-Infrastructure-Governance-Policy.json

JSON document encoding the PKI governance policy. Defines CA roles and responsibilities, certificate approval workflows by template type, key ceremony procedures, audit requirements, and compliance alignment with the [ACSC Information Security Manual](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/ism). Referenced during compliance audits.

---

## Format Reference

| Format | Count | Tooling |
|--------|-------|---------|
| YAML (.yaml) | 7 | Parsed by PowerShell `ConvertFrom-Yaml` (powershell-yaml module) or Python `PyYAML` |
| JSON (.json) | 2 | Parsed by PowerShell `ConvertFrom-Json` or any JSON library |
| Tcl (.tcl) | 1 | Executed within F5 BIG-IP iControl TMOS shell |

---

## Usage Notes

- YAML files use UTF-8 encoding without BOM. Validate with a YAML linter before deployment.
- JSON files must be valid JSON. Validate with `ConvertFrom-Json` in PowerShell before use.
- The Tcl file (`configure-f5-ssl.tcl`) is not a standalone configuration — it must be executed within the F5 TMOS environment.
- Template values enclosed in angle brackets (e.g., `<CA_SERVER_HOSTNAME>`) must be substituted before deployment.
- Do not commit substituted (filled-in) copies containing real hostnames, thumbprints, or credentials. Maintain templates only.

---

## Navigation

- [PKI README](../README.md)
- [Configuration reference](../reference-configuration.md)
- Parent: [infrastructure/pki/](../)
