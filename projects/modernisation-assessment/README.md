# Technology Stack Modernisation Assessments

Comprehensive assessment resources for organisations evaluating technology transitions from legacy and hybrid environments to cloud-native architectures. Each assessment provides structured capability mapping, gap analysis, licensing guidance, and migration planning tools designed for enterprise IT teams to use directly.

---

## Available Assessments

### [SCCM-to-Intune Transition Assessment](sccm-to-intune/)

A 14-document, 200+ feature-comparison assessment evaluating Microsoft Intune as a replacement for on-premises Configuration Manager (SCCM Current Branch 2403+).

| Aspect | Detail |
|--------|--------|
| **Scope** | 10 capability areas: Software Deployment, Patch Management, OS Deployment, Compliance Baselines, Device Inventory, Endpoint Protection, Reporting & Analytics, Remote Tools, Infrastructure, Scripting & Automation |
| **Methodology** | SCCM-centric capability mapping with 5-level parity scale (Full Parity → No Equivalent) |
| **Deliverables** | Executive summary with RAG ratings, 10 capability assessments with feature parity matrices, co-management transition guide, organisation-specific planning template |
| **Key Findings** | 7/10 areas achieve Near Parity or better; 3 areas have Significant Gaps requiring remediation planning |
| **Start Here** | [Executive Summary](sccm-to-intune/executive-summary.md) for leadership, [Master Index](sccm-to-intune/) for full navigation |

**Document set**: Executive Summary → 10 Capability Assessments → Co-Management Appendix → Organisation Template → Master Index

---

## Getting Started

Whether you're an IT leader evaluating a transition or a technical team planning migration, follow this path:

### Step 1: Read the Executive Summary

Start with the [Executive Summary](sccm-to-intune/executive-summary.md) for consolidated RAG ratings, top gaps, top advantages, licensing impact, and recommended next steps. This gives you the strategic picture in 30–60 minutes.

### Step 2: Review Capability Areas Relevant to Your Environment

Work through the capability area assessments most relevant to your organisation. Each assessment includes a Feature Parity Matrix with every source-platform feature mapped to its target equivalent, parity rating, and licensing tier. Priority reading order for SCCM-to-Intune:

1. **[OS Deployment](sccm-to-intune/os-deployment.md)** — Significant Gap (read first if you do bare-metal imaging)
2. **[Patch Management](sccm-to-intune/patch-management.md)** — Near Parity for Microsoft; Significant Gap for third-party
3. **[Endpoint Protection](sccm-to-intune/endpoint-protection.md)** — Full Parity to Intune Advantage (biggest win)

See the [Master Index](sccm-to-intune/) for the full prioritised reading order across all 10 capability areas.

### Step 3: Complete the Organisation Template

Use the [Organisation Template](sccm-to-intune/org-template.md) to capture your environment-specific configuration — application inventory, custom hardware classes, collection queries, task sequences, and more. This drives your migration complexity estimate and timeline.

### Step 4: Build Your Migration Roadmap

Each capability assessment includes migration strategies (parallel deployment, clean cutover, selective migration) with practical checklists. Combine these with your organisation template findings to build a phased roadmap tailored to your environment.

---

## Assessment Framework

All assessments in this folder evaluate technology transitions using a structured discovery and analysis approach. The general framework covers seven areas of inquiry:

1. **Current State Infrastructure** — On-premises and hybrid architecture, technical debt, hardware lifecycle
2. **Identity and Authentication** — Authentication mechanisms, MFA coverage, legacy auth dependencies
3. **Device Management** — Endpoint management tools, co-management maturity, policy enforcement
4. **Security and Compliance** — Endpoint protection, DLP, compliance monitoring, audit requirements
5. **Applications and Workloads** — Application portfolio, cloud readiness, licensing models
6. **Organisational Readiness** — Skills, change management, stakeholder engagement, cultural readiness
7. **Technical Constraints** — Regulatory requirements, data residency, bandwidth, budget, timeline

Each specific assessment adapts this framework to the technology being evaluated, using capability-specific methodology appropriate to the transition. For a detailed discovery questionnaire tailored to the SCCM-to-Intune transition, see [SCCM-to-Intune Discovery Questionnaire](sccm-to-intune-discovery-questionnaire.md).

---

## Assessment Resources

| Resource | Purpose |
|----------|---------|
| **[Capability Assessment Template](capability-assessment-template.md)** | Reusable 8-section document template for writing capability area assessments with feature parity matrices, key findings, licensing, and migration guidance |
| **[SCCM-to-Intune Discovery Questionnaire](sccm-to-intune-discovery-questionnaire.md)** | Structured environment discovery questionnaire covering 7 areas with specific questions for SCCM-to-Intune transition planning |
| **[SCCM-to-Intune Organisation Template](sccm-to-intune/org-template.md)** | Fill-in worksheet for capturing your SCCM environment specifics (applications, baselines, collections, task sequences) to estimate migration complexity |

---

## Target Environments

These assessments are most relevant for organisations with:

- **500+ managed devices** — Enterprise-scale device management complexity
- **Active Directory domains** — On-premises identity infrastructure
- **Hybrid or co-managed state** — Some cloud adoption, not fully cloud-native
- **Regulatory requirements** — Compliance obligations influencing architecture decisions

---

## Parity Rating Scale

All capability assessments use a five-level parity scale plus one supplementary tag:

| Rating | Symbol | Definition |
|--------|--------|------------|
| **Full Parity** | 🟢 | Target platform is functionally equivalent. No capability loss. |
| **Near Parity** | 🟡 | ≥80% capability coverage. Minor functional differences. |
| **Partial** | 🟠 | 40–79% coverage. Workarounds exist but add overhead. |
| **Significant Gap** | 🔴 | <40% coverage. Core functionality missing. Third-party tools or source platform retention required. |
| **No Equivalent** | ⬛ | Zero counterpart. Architectural or design difference prevents coverage. |
| **Target Advantage** | 🔵 | Target platform exceeds source. Cloud-native features with no source equivalent. |

---

## Scope

This folder covers:

- Capability-by-capability technology transition assessments
- Feature parity analysis with structured rating scales
- Licensing impact analysis for transition planning
- Migration strategies with practical checklists
- Discovery questionnaires and environment inventory tools
- Organisation-specific planning templates

This folder does **not** cover:

- Enduring technology reference material (see technology domains: `security/`, `identity/`, `endpoints/`, etc.)
- Ongoing operational procedures
- Project management methodology (see `projects/README.md` for project structure guidance)

---

## Planned Assessments

| Assessment | Status | Description |
|------------|--------|-------------|
| **SCCM-to-Intune** | ✅ Published | 14 documents, 10 capability areas, 200+ feature comparisons |
| **AD-to-Entra ID** | 📋 Planned | Active Directory to Entra ID identity transition |
| **Exchange-to-M365** | 📋 Planned | On-premises Exchange to Exchange Online / M365 |
| **On-Prem-to-Azure** | 📋 Planned | On-premises infrastructure to Azure cloud services |

### Available Assessment Resources

| Resource | Status | Notes |
|----------|--------|-------|
| Capability assessment template | ✅ Available | Codified from SCCM-to-Intune pattern |
| Parity rating scale | ✅ Available | 5-level scale used across all assessments |
| Migration strategy patterns | ✅ Available | 3 standard patterns (Parallel, Cutover, Selective) documented in capability assessments |
| Discovery questionnaire framework | ✅ Available | 7-area questionnaire with SCCM-to-Intune tailored version |
| Target state reference architectures | 📋 Planned | Cloud-native architecture patterns for common scenarios |
| Vendor evaluation criteria | 📋 Planned | Framework for evaluating third-party tools and services |
| Cost modelling templates | 📋 Planned | TCO and ROI calculation templates for transition business cases |

---

## Audience

- **IT Leaders and Executives** — Evaluating transition business case and strategic direction
- **Enterprise Architects** — Designing target state architecture and migration approach
- **Project Managers** — Planning transition initiatives and coordinating workstreams
- **Technical Consultants** — Conducting assessments for clients or internal stakeholders
- **Infrastructure and Identity Teams** — Providing current state information and evaluating readiness
- **Security and Compliance Teams** — Assessing risk and compliance implications of transitions

---

## Relationship to Technology Domains

Assessment findings reference capabilities documented in the technology domain folders:

| Domain | Relationship |
|--------|-------------|
| `identity/entra-id/` | Modern identity architecture, authentication protocols, Conditional Access |
| `endpoints/intune/` | Cloud-native endpoint management, compliance policies, app deployment |
| `security/defender/` | Endpoint detection and response, threat protection, security posture |

Assessments identify **what to transition and where the gaps are**. Technology domains document **how to implement the modern capabilities**.
