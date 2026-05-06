---
title: "Future Projects Framework"
status: "draft"
last_updated: "2026-03-16"
audience: "IT Managers"
document_type: "readme"
domain: "projects"
---

# Future Projects Framework

This framework establishes the methodological foundation for planning, executing, and closing bounded projects within the antyg documentation library. It draws on established process engineering methodologies — [PDCA](https://asq.org/quality-resources/pdca-cycle), [process maturity assessment](https://cmmiinstitute.com/cmmi), and [quality gates](https://www.iso.org/standard/62085.html) — to provide a consistent, repeatable approach to technology projects.

---

## Project Lifecycle Model

Projects in this library follow a phased lifecycle based on the [Plan-Do-Check-Act (PDCA)](https://asq.org/quality-resources/pdca-cycle) cycle, adapted from the continuous improvement methodology originally described by [W. Edwards Deming](https://deming.org/explore/pdsa/). Each phase maps to a concrete set of project activities:

| Phase | PDCA Mapping | Activities | Key Deliverables |
|-------|-------------|------------|------------------|
| **Initiation** | Plan | Problem identification, scope definition, stakeholder mapping, success criteria | Project charter, scope statement |
| **Discovery** | Plan | Current state assessment, gap analysis, constraint identification, baseline data collection | Assessment report, findings register |
| **Design** | Plan → Do | Target state architecture, solution evaluation, risk assessment, implementation approach | Design document, risk register |
| **Implementation** | Do | Phased execution, pilot deployment, controlled rollout, change management | Implementation records, change logs |
| **Validation** | Check | Results evaluation against success criteria, data analysis, variance assessment | Validation report, lessons learned |
| **Closure** | Act | Standardisation of successful outcomes, operational handover, documentation extraction | Closure report, operational artefacts |

The PDCA cycle is iterative — validation findings feed back into planning for subsequent phases or follow-on projects, ensuring continuous improvement across the project portfolio.

### When to Use This Framework

This framework applies to **bounded, time-limited initiatives** — technology transitions, platform migrations, security implementations, and similar programmes of work. It does not apply to:

- Ongoing operational procedures (see `operations/` domain)
- Enduring technology reference material (see technology domains)
- Development standards and tooling (see `development/` domain)

---

## Assessment Methodology

Project assessments follow a structured approach derived from [process maturity assessment methodology](https://cmmiinstitute.com/cmmi), which evaluates organisational capabilities against defined maturity levels. The core assessment cycle:

1. **Current state inventory** — Systematically document existing capabilities, configurations, and dependencies
2. **Maturity evaluation** — Assess each capability against a defined scale (see [Parity Rating Scale](../modernisation-assessment/README.md#parity-rating-scale) for the assessment-specific implementation)
3. **Gap analysis** — Identify differences between current and target states, quantify effort and risk
4. **Improvement roadmap** — Prioritise gaps by business impact and migration-blocking risk, define phased remediation

The [SCCM-to-Intune Transition Assessment](../modernisation-assessment/sccm-to-intune/) demonstrates this methodology in practice across 10 capability areas with 200+ feature comparisons.

### Assessment Resources

| Resource | Purpose | Location |
|----------|---------|----------|
| Capability Assessment Template | 8-section document structure for capability area assessments | [`capability-assessment-template.md`](../modernisation-assessment/capability-assessment-template.md) |
| Discovery Questionnaire | Structured environment inventory covering 7 assessment areas | [`sccm-to-intune-discovery-questionnaire.md`](../modernisation-assessment/sccm-to-intune-discovery-questionnaire.md) |
| Organisation Template | Environment-specific planning worksheet | [`org-template.md`](../modernisation-assessment/sccm-to-intune/org-template.md) |

---

## Quality Gates

Project delivery phases are punctuated by quality gates — go/no-go decision points that ensure work meets defined standards before proceeding. This approach aligns with [quality gates frameworks](https://www.iso.org/standard/62085.html) used in software development and process engineering, adapted for documentation and technology transition projects.

### Standard Project Gates

| Gate | Phase Transition | Criteria |
|------|-----------------|----------|
| **G1: Scope Approval** | Initiation → Discovery | Scope statement approved, stakeholders identified, success criteria defined |
| **G2: Assessment Complete** | Discovery → Design | Current state documented, gaps identified, findings validated by subject matter experts |
| **G3: Design Approval** | Design → Implementation | Target state approved, risks assessed, implementation approach agreed |
| **G4: Pilot Validation** | Implementation (pilot) → Implementation (rollout) | Pilot success criteria met, no blocking issues, rollback procedures tested |
| **G5: Delivery Validation** | Implementation → Closure | All success criteria verified with evidence, operational handover complete |

### Gate Evidence Requirements

Each gate requires documented evidence that criteria have been met. Evidence follows [ALCOA-C principles](https://www.beckman.com/resources/industry-standards/alcoa) — attributable, legible, contemporaneous, original, accurate, complete, and consistent.

---

## Planned Content

The following content areas will be developed as projects are undertaken:

### Templates and Frameworks

- **Project charter template** — Standardised project initiation document
- **Risk register template** — Risk identification, assessment, and mitigation tracking
- **Decision record template** — Architectural Decision Records (ADRs) for key project decisions
- **Closure report template** — Outcomes, lessons learned, operational handover checklist

### Methodology Guides

- **Conducting a technology transition assessment** — Step-by-step guide for using the assessment methodology
- **Project retrospective guide** — How to capture and apply lessons learned using [root cause analysis](https://asq.org/quality-resources/root-cause-analysis) techniques
- **Stakeholder communication patterns** — Communication templates for different project phases and audiences

### Reference Material

- **Assessment methodology reference** — Detailed reference for the maturity-based assessment approach, including maturity levels, scoring criteria, and evidence requirements
- **Quality gates reference** — Comprehensive gate definitions, evidence standards, and escalation procedures
- **Project metrics catalogue** — Standard KPIs and success metrics for common project types

---

## Related Resources

### Methodological Foundations

- [ASQ — Plan-Do-Check-Act Cycle](https://asq.org/quality-resources/pdca-cycle) — PDCA methodology overview and application guidance
- [The W. Edwards Deming Institute — PDSA Cycle](https://deming.org/explore/pdsa/) — Original PDSA (Plan-Do-Study-Act) cycle description
- [CMMI Institute — CMMI Model](https://cmmiinstitute.com/cmmi) — Capability Maturity Model Integration for process improvement
- [ISO 9001:2015 — Quality Management Systems](https://www.iso.org/standard/62085.html) — International standard for quality management including quality gates
- [ASQ — Root Cause Analysis](https://asq.org/quality-resources/root-cause-analysis) — Root cause analysis methodology for project retrospectives

### Internal References

- [Projects Domain Index](../README.md) — Parent domain overview and project structure guidance
- [Modernisation Assessment Hub](../modernisation-assessment/README.md) — Assessment resources and completed assessments
- [SCCM-to-Intune Assessment](../modernisation-assessment/sccm-to-intune/) — Worked example of the assessment methodology
