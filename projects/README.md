# Projects

## Purpose

This domain houses documentation for bounded project initiatives, modernisation assessments, and time-bound programmes of work. It provides a structured location for initiative-scoped planning, assessment frameworks, and project-specific deliverables that don't belong in the technology reference domains.

## What This Folder Holds

Project-focused documentation organised by initiative. Each project gets its own subfolder containing planning documents, assessment frameworks, findings, decisions, and project-specific artefacts.

## Current Structure

### Subfolders

- **modernisation-assessment/** — Technology stack modernisation assessment template (substantive content migrated from initiatives/)

## Planned Expansion

Future project areas to be added as initiatives are undertaken:

- **cloud-migration-2026/** — Example: Azure migration programme documentation
- **zero-trust-implementation/** — Example: Zero trust security architecture rollout
- **intune-deployment/** — Example: Microsoft Intune deployment project
- **identity-consolidation/** — Example: Multi-forest Active Directory consolidation

## Project Structure

Each project subfolder follows a flexible structure based on project complexity:

### Single-File Projects

Small, focused initiatives may have just one document in their folder:
- **README.md** — Complete project documentation in a single file

### Multi-File Projects

Larger initiatives may contain multiple documents organised loosely around common project artefacts:
- **README.md** — Project overview and navigation
- **charter.md** — Project charter, objectives, scope, stakeholders
- **assessment.md** or **discovery.md** — Current state assessment and findings
- **design.md** or **architecture.md** — Target state design and architecture decisions
- **plan.md** — Implementation plan, timeline, milestones
- **risks.md** — Risk register and mitigation strategies
- **decisions.md** — Architectural Decision Records (ADRs) and key decisions
- **outcomes.md** or **lessons-learned.md** — Project outcomes and retrospective

**Note:** The exact structure for multi-file projects is flexible and project-specific. A formal template structure may be defined in a later planning phase, but projects are not required to follow a rigid template. The structure should serve the project, not constrain it.

### Assessment Projects

Technology transition assessments follow a specialised structure designed for capability-by-capability analysis. The [SCCM-to-Intune Transition Assessment](modernisation-assessment/sccm-to-intune/) established this pattern:

- **README.md** — Master index with reading order, document inventory, methodology, and cross-references
- **executive-summary.md** — Consolidated RAG ratings, top gaps, top advantages, licensing summary, recommended next steps
- **{capability-area}.md** — One document per capability area, each following an 8-section template (metadata, executive summary, feature parity matrix, key findings, licensing impact, migration considerations, sources, footer)
- **co-management.md** (or equivalent transition appendix) — Implementation guidance for gradual migration
- **org-template.md** — Organisation-specific planning worksheet for consumers to fill in

Assessment projects are designed as external-facing deliverables — organisations use them directly to plan their own technology transitions. See [Capability Assessment Template](modernisation-assessment/capability-assessment-template.md) for the reusable document structure.

## Relationship to Technology Domains

Projects and technology domains have a complementary relationship:

### Technology Domains

Technology domains (security, identity, endpoints, mail, etc.) contain **reference material** — the enduring knowledge that applies beyond any single project:
- How technologies work
- Configuration patterns and best practices
- Standard operating procedures
- Integration patterns and API usage

### Projects

Projects contain **initiative-scoped work** — the time-bound planning, assessment, and implementation documentation specific to a programme of work:
- Project charters and objectives
- Current state assessments for a specific environment
- Design decisions made in the context of specific constraints
- Implementation plans and timelines
- Risks, issues, and mitigation strategies specific to the initiative

### Example: Intune Deployment Project

- **projects/intune-deployment/** would contain:
  - Current state assessment of existing device management
  - Target state design for Intune deployment
  - Phased rollout plan and timeline
  - Pilot group selection and success criteria
  - Project-specific risks and decisions

- **endpoints/intune/** would contain:
  - Intune (MEM) architecture and capabilities reference
  - Configuration policy patterns and templates
  - Compliance policy design guidance
  - Integration with Autopilot and Defender
  - Ongoing operational procedures

The project folder documents **this specific Intune deployment initiative**; the technology domain documents **Intune as a technology** for ongoing reference.

## Relationship to Operations

The `operations/` domain contains **ongoing operational procedures** — runbooks, maintenance tasks, monitoring procedures, and business-as-usual activities.

Projects contain **implementation activities** — the one-time or phased work to deliver a capability or achieve a transformation.

Once a project completes, operational artefacts may be extracted and moved to `operations/` or the relevant technology domain for ongoing use.

## Project Lifecycle

1. **Initiation** — Create project folder, write charter or overview README
2. **Discovery/Assessment** — Document current state, findings, constraints
3. **Design** — Document target state, architecture decisions, design choices
4. **Planning** — Create implementation plan, timeline, resource requirements
5. **Execution** — Track progress, document decisions, manage risks
6. **Closure** — Document outcomes, lessons learned, extract operational artefacts to permanent homes
7. **Archive** — Project folder remains in projects/ as historical reference

## Scope

This domain covers:
- Project charters and initiative scoping
- Current state assessments and discovery findings
- Target state designs and architecture decisions
- Implementation plans and timelines
- Risk registers and mitigation strategies
- Project-specific decisions and trade-offs
- Modernisation assessment frameworks
- Initiative outcomes and lessons learned

This domain does **not** cover:
- Enduring technology reference material (belongs in technology domains)
- Ongoing operational procedures (belongs in `operations/`)
- General development standards (belongs in `development/`)
- API integration patterns (belongs in `integrations/`)

## Audience

- Project managers and programme leads
- Technical architects designing solutions for specific initiatives
- IT leaders evaluating modernisation opportunities
- Implementation teams executing project plans
- Stakeholders tracking project progress
- Future teams learning from past project decisions and outcomes

## Using This Documentation

### For New Projects

Create a project folder and start with a README.md that outlines the initiative. Expand to additional documents as the project complexity requires.

### For Assessments

Use existing assessment templates (like modernisation-assessment) as starting points. Customise to fit your specific assessment needs.

### For Historical Reference

Review past project folders to understand decisions made, approaches taken, and lessons learned. Project folders serve as institutional memory.

### For Knowledge Transfer

When projects complete, extract reusable patterns, procedures, and reference material to technology domains or operations for ongoing use.

## Future Expansion

Planned additions to this domain:

- Project template guidance for common initiative types (deployment, migration, consolidation)
- Assessment framework templates for various technology areas
- Decision record templates and ADR patterns
- Risk and issue management templates
- Project closure and lessons learned templates
