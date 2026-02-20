# {Capability Name} — {Source}-to-{Target} Assessment

<!--
TEMPLATE INSTRUCTIONS:
Replace all placeholder markers:
- {Capability Name}: e.g., "Application Deployment", "Device Configuration", "Security Baseline Management"
- {Source}: Legacy platform name, e.g., "SCCM", "Active Directory", "Exchange Server"
- {Target}: Modern platform name, e.g., "Intune", "Entra ID", "Microsoft 365"
- {version}: Document version (e.g., "1.0.0")
- {date}: Assessment or research date in YYYY-MM-DD format
- {rating}: Overall parity rating from the scale below

Delete all instructional comments (lines starting with <!--) before publishing.
-->

**Document Version**: {version}
**Assessment Date**: {date}
**{Source} Version Assessed**: {version details}
**{Target} Version Assessed**: {version details}
**Overall Parity Rating**: **{rating}**

---

## Executive Summary

<!--
INSTRUCTIONS:
Write 3-5 sentences summarising:
1. Overall parity rating and approximate percentage coverage
2. Top 2-3 critical gaps (if any)
3. Top 1-2 advantages of the target platform (if any)
4. High-level migration complexity assessment

This section is written for stakeholders who will only read this summary.
Example format:

"{Target} provides {Near/Partial/Full} parity with {Source} for {capability area}, covering approximately {X}% of core functionality. Critical gaps exist in {area 1} and {area 2}, requiring {workaround description or retention of source platform}. However, {Target} offers significant advantages in {area 3}, including {specific benefit}. Migration complexity is rated {Low/Medium/High} due to {primary factor}."
-->

[Write executive summary here]

---

## Feature Parity Matrix

<!--
INSTRUCTIONS:
This is the PRIMARY DELIVERABLE of the assessment document.

Create a comprehensive table listing:
- Every known feature of the source platform for this capability area
- Its equivalent in the target platform (or "No equivalent" if none exists)
- Parity rating using the scale defined at the end of this template
- Licensing tier required for the target feature
- Brief contextual notes

Group features into logical subcategories using subheadings where appropriate.

For each feature:
1. State the source feature name clearly
2. Identify the target equivalent (be specific — include feature names, portal locations, or API names)
3. Apply parity rating with justification
4. Note licensing tier (Base/Premium/Add-on/N/A)
5. Add brief notes explaining differences, limitations, or advantages

Example row:
| Software Update Deployment | Update Rings (Windows Update for Business) | 🟡 Near Parity | Intune Plan 1 (Base) | Intune provides scheduled deployment and ring-based targeting but lacks the granular approval workflow of SCCM Update Lists |
-->

### {Feature Category 1}

| {Source} Feature | {Target} Equivalent | Parity Rating | Licensing | Notes |
|-----------------|---------------------|---------------|-----------|-------|
| [Feature 1] | [Equivalent or "No equivalent"] | [Rating symbol] | [Tier] | [Brief note] |
| [Feature 2] | [Equivalent or "No equivalent"] | [Rating symbol] | [Tier] | [Brief note] |

### {Feature Category 2}

| {Source} Feature | {Target} Equivalent | Parity Rating | Licensing | Notes |
|-----------------|---------------------|---------------|-----------|-------|
| [Feature 1] | [Equivalent or "No equivalent"] | [Rating symbol] | [Tier] | [Brief note] |

<!-- Add additional feature categories as needed -->

---

## Key Findings

<!--
INSTRUCTIONS:
This section provides narrative detail for the Feature Parity Matrix.
Always include all four subsections, even if one is brief.
Use comparison tables, code examples, configuration screenshots, or architecture diagrams where they add clarity.
-->

### Full/Near Parity Areas

<!--
INSTRUCTIONS:
Document features where the target platform meets or exceeds source platform capabilities.
Include:
- Detailed comparison of implementation approaches
- Configuration examples (code blocks, JSON, PowerShell, etc.)
- Comparison tables showing source vs target approaches
- Architectural differences that don't impact functionality

Example structure:
"The {Source} {feature name} capability maps directly to {Target} {feature name}. Both platforms support {key capability}, though the implementation differs:

[Comparison table or side-by-side code examples]

Key differences:
- {Difference 1 and why it doesn't impact parity}
- {Difference 2 and why it doesn't impact parity}

The target approach offers {advantage if any}."
-->

[Write full/near parity analysis here]

### Partial Parity / Gaps

<!--
INSTRUCTIONS:
Document features where workarounds exist but add overhead or complexity.
For each gap:
1. State what's missing clearly
2. Document the workaround (be specific — scripts, third-party tools, manual processes)
3. Assess overhead (time, cost, complexity)
4. Rate practical impact: Low/Medium/High

Example structure:
"**Gap**: {Source} supports {feature}, but {Target} requires {workaround description}.

**Workaround**: {Detailed workaround steps or reference to tool/script}

**Overhead**: {Time cost, licensing cost, or complexity added}

**Impact Rating**: {Low/Medium/High} — {Justification}"
-->

[Write partial parity analysis here]

### Significant Gaps / No Equivalent

<!--
INSTRUCTIONS:
Document critical missing capabilities with no practical workaround.
For each significant gap:
1. State clearly what's missing
2. Explain why it matters (business/technical impact)
3. Document remediation options:
   - Third-party tools (name specific products with links)
   - Retention of source platform for this capability
   - Business process change to eliminate need
   - Acceptance of gap with compensating controls

Example structure:
"**Missing Capability**: {Feature name and description}

**Impact**: {Who is affected and how. Quantify if possible.}

**Remediation Options**:
1. **Third-party tool**: {Tool name and link} provides {coverage description}. Cost: {pricing model}.
2. **Retain {Source}**: Continue using {Source} for this capability in hybrid model.
3. **Accept gap**: {Describe compensating control or business process change}."
-->

[Write significant gaps analysis here]

### {Target} Advantages

<!--
INSTRUCTIONS:
Document areas where the target platform exceeds the source platform.
Focus on cloud-native capabilities, modern architecture advantages, or features that reduce operational overhead.

For each advantage:
1. Name the capability
2. Explain why source platform cannot match it (architectural, licensing, or design limitation)
3. Quantify business value where possible (cost savings, time savings, risk reduction)

Example structure:
"**{Feature name}**: {Target} provides {capability description}, which has no equivalent in {Source} due to {architectural reason}.

**Business Value**: {Quantified benefit — e.g., "Eliminates need for X, saving approximately $Y annually" or "Reduces deployment time from X hours to Y minutes"}"
-->

[Write target advantages analysis here]

---

## Licensing Impact

<!--
INSTRUCTIONS:
Document licensing requirements for this capability area.
Create tables showing:
1. What's included in base licensing
2. What requires premium licensing
3. What requires optional add-ons
4. Cost comparison (source vs target for representative organisation size)

Use 3-year TCO where possible to account for migration costs.
-->

### {Target} Licensing Tiers

| Feature Group | Base License | Premium License | Add-on Required | Notes |
|---------------|--------------|-----------------|-----------------|-------|
| [Feature group 1] | ✓ / — | ✓ / — | [Add-on name] / — | [Notes] |
| [Feature group 2] | ✓ / — | ✓ / — | [Add-on name] / — | [Notes] |

<!--
Base License examples: "Intune Plan 1", "Microsoft 365 E3", "Entra ID Free"
Premium License examples: "Intune Plan 2", "Microsoft 365 E5", "Entra ID P1/P2"
Add-on examples: "Advanced Threat Protection", "Cloud PKI"
-->

### Cost Comparison

<!--
INSTRUCTIONS:
Provide 3-year TCO comparison for a representative organisation size.
Include:
- Source platform licensing and infrastructure costs
- Target platform licensing costs
- Migration project costs
- Net difference

Example:
"For a 5,000-device organisation migrating from {Source} to {Target}:"
-->

| Cost Component | {Source} (3-year TCO) | {Target} (3-year TCO) | Notes |
|----------------|----------------------|----------------------|-------|
| Licensing | [Amount] | [Amount] | [Notes on tier/SKU] |
| Infrastructure | [Amount] | [Amount] | [Server, storage, networking] |
| Migration Project | — | [Amount] | [Consulting, internal labour] |
| **Total** | **[Amount]** | **[Amount]** | **Net: [Difference]** |

---

## Migration Considerations

<!--
INSTRUCTIONS:
Provide actionable guidance for migrating this capability area.
Include all four subsections.
-->

### Pre-Migration Assessment

<!--
INSTRUCTIONS:
Document what to audit/inventory before migrating this capability area.
Include:
- SQL queries for source platform inventory (if applicable)
- PowerShell scripts for data collection
- Configuration exports needed
- Dependency mapping steps

Example:
"Before migrating {capability}, inventory the following from {Source}:
1. {Item 1} — Use the following SQL query against the {Source} database:
   ```sql
   [Query]
   ```
2. {Item 2} — Export configuration using:
   ```powershell
   [Script]
   ```"
-->

[Write pre-migration assessment guidance here]

### Migration Strategies

<!--
INSTRUCTIONS:
Document 2-3 migration strategies with pros/cons.
Standard strategies:
1. Parallel/Co-existence (gradual migration, both platforms active)
2. Clean Cutover (fast migration, source platform decommissioned)
3. Selective/Hybrid (permanent split, some workloads stay on source)

For each strategy:
- Describe the approach
- List prerequisites
- Provide timeline estimate
- Document pros and cons
- State ideal use case
-->

#### Strategy 1: Parallel/Co-existence

**Approach**: [Description]

**Prerequisites**:
- [Prerequisite 1]
- [Prerequisite 2]

**Timeline**: [Estimate]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Ideal For**: [Use case description]

#### Strategy 2: Clean Cutover

**Approach**: [Description]

**Prerequisites**:
- [Prerequisite 1]
- [Prerequisite 2]

**Timeline**: [Estimate]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Ideal For**: [Use case description]

#### Strategy 3: Selective/Hybrid

**Approach**: [Description]

**Prerequisites**:
- [Prerequisite 1]
- [Prerequisite 2]

**Timeline**: [Estimate]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Ideal For**: [Use case description]

### Migration Checklist

<!--
INSTRUCTIONS:
Provide a per-item checklist for migrating individual configurations.
Use checkbox format.
Group into phases: Pre-migration, Migration, Post-migration, Validation.

Example:
"For each {configuration item} being migrated:

**Pre-migration**
- [ ] Export {item} configuration from {Source}
- [ ] Document dependencies and targeting rules
- [ ] Identify licensing requirements in {Target}

**Migration**
- [ ] Recreate configuration in {Target}
- [ ] Map targeting rules to {Target} groups
- [ ] Configure deployment settings

**Post-migration**
- [ ] Assign to pilot group
- [ ] Monitor deployment status
- [ ] Validate functionality

**Validation**
- [ ] Compare {Source} and {Target} reporting
- [ ] Verify compliance/success rates match
- [ ] Document any discrepancies"
-->

[Write migration checklist here]

### Common Migration Issues and Resolutions

<!--
INSTRUCTIONS:
Document known issues encountered during migration with root causes and fixes.
Table format preferred.

Example:
| Issue | Cause | Resolution |
|-------|-------|------------|
| {Description of problem} | {Root cause} | {Step-by-step fix} |
-->

| Issue | Cause | Resolution |
|-------|-------|------------|
| [Issue 1] | [Cause] | [Resolution] |
| [Issue 2] | [Cause] | [Resolution] |

---

## Sources

<!--
INSTRUCTIONS:
Cite all sources using the hierarchy defined below.
Provide hyperlinks for all references.
Group into two subsections: Official documentation and community resources.
-->

### Official Documentation

<!--
INSTRUCTIONS:
List official vendor documentation (e.g., Microsoft Learn, vendor product docs).
Use descriptive link text, not raw URLs.

Example:
- [Microsoft Learn: {Feature name}](https://learn.microsoft.com/...)
- [{Vendor} Documentation: {Topic}](https://...)
-->

- [Official doc 1](URL)
- [Official doc 2](URL)

### Community and Technical Resources

<!--
INSTRUCTIONS:
List verified third-party technical blogs, tools, and community resources.
Only include sources that are:
1. Technically accurate (verified by cross-reference)
2. Reputable (established authors/organisations)
3. Current (published or updated within last 2 years for cloud services)

Example:
- [Author Name: "Article Title"](URL) — Brief description of value added
- [Tool Name](URL) — Description of tool purpose and vendor
-->

- [Resource 1](URL) — [Description]
- [Resource 2](URL) — [Description]

---

**Research Date**: {date}
**Primary Sources**: {source description — e.g., "Microsoft Learn documentation, official Microsoft Tech Community blogs, and vendor product documentation current as of {date}"}

---

# TEMPLATE APPENDIX: Assessment Standards and Guidelines

<!--
INSTRUCTIONS:
The following sections define the standards used in this template.
Include them as an appendix in the published assessment, or remove them if your organisation maintains these definitions in a separate style guide.
-->

## Source Hierarchy

Use sources in this order of preference:

1. **Official vendor documentation** (e.g., Microsoft Learn, AWS Documentation, vendor product docs)
2. **Official vendor blogs and announcements** (e.g., Microsoft Tech Community, vendor engineering blogs)
3. **Community technical resources** (verified, reputable third-party blogs and tools)

All feature comparisons must cite sources with hyperlinks.

## Citation Standards

- **Feature comparisons**: Cite official documentation for both source and target features
- **Code examples**: Include contextual note: *"The following is a conceptual example illustrating the pattern. Adapt for your environment and test thoroughly before production use."*
- **SQL queries**: Note the source platform version they target (e.g., *"Query tested against SCCM 2203 database schema"*)
- **Configuration exports**: Note the tool version and export format

## Parity Rating Scale

| Rating | Symbol | Definition |
|--------|--------|------------|
| **Full Parity** | 🟢 | Target platform is functionally equivalent. No capability loss. Migration is straightforward. |
| **Near Parity** | 🟡 | ≥80% coverage. Minor functional differences that don't impact core use cases. Workarounds are trivial. |
| **Partial Parity** | 🟠 | 40-79% coverage. Core functionality exists but requires workarounds that add overhead (time, cost, complexity). |
| **Significant Gap** | 🔴 | <40% coverage. Core functionality missing or severely limited. Major workarounds required. |
| **No Equivalent** | ⬛ | Zero counterpart in target platform. Architectural or design difference makes feature impossible to replicate. |
| **Target Advantage** | 🔵 | Target platform exceeds source platform. Cloud-native features or capabilities impossible in source. |

### Rating Application Guidelines

**Feature-Level Rating**:
- Rate each individual feature independently
- Provide brief rationale in the Notes column
- Range ratings allowed when feature spans multiple ratings (e.g., "🟠 to 🔴 Partial to Significant Gap depending on use case")

**Area-Level Rating** (overall rating for the capability area):
- Weight by feature criticality: critical features weighted more heavily than convenience features
- Consider combined impact of all gaps
- Document weighting rationale in Executive Summary

Example weighting:
- If 90% of features are Full/Near Parity but the 10% gap is a critical blocker, overall rating may be Partial Parity
- If 70% of features are Partial Parity but all are convenience features and core capabilities are Full Parity, overall rating may be Near Parity

## Diátaxis Classification

Assessment documents intentionally blend three Diátaxis modes:

- **Reference**: Feature Parity Matrices, licensing tables, configuration examples, API references
- **How-to**: Migration strategies, checklists, pre-migration assessment scripts, troubleshooting guides
- **Explanation**: Paradigm shift narratives, architectural comparisons, impact analysis, strategic recommendations

This blending is by design. Each capability assessment serves as a **complete resource** for decision-making about that capability area, combining:
- Reference data for feature comparison
- Practical guidance for migration execution
- Conceptual explanation for understanding architectural shifts

This approach optimises for the assessment's primary audience: technical decision-makers who need to understand "what's different", "how to migrate", and "why it matters" in a single coherent document.

## Australian English Spelling

Use Australian English spelling conventions throughout:
- Colour (not color)
- Analyse (not analyze)
- Organisation (not organization)
- Licence (noun), license (verb)
- Categorise (not categorize)

---

**Template Version**: 1.0.0
**Template Author**: antyg
**Last Updated**: 2026-02-19
**Template Purpose**: Codifies the 8-section structure used in modernisation assessment capability area documents to ensure consistency across future assessments.
