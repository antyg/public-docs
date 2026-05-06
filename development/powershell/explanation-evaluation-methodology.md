---
title: "Understanding the PSEval Compliance Methodology"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Engineering Managers, QA Engineers"
document_type: "explanation"
domain: "development"
---

# Understanding the PSEval Compliance Methodology

The PSEval framework provides a structured approach to evaluating PowerShell code quality across an enterprise. This document explains the conceptual underpinning of that methodology — what it measures, why it is weighted the way it is, and how evaluation at different organisational levels produces actionable quality intelligence.

---

## Why a Structured Evaluation Framework?

PowerShell modules vary enormously in quality. Without a shared evaluation framework, quality assessments are subjective, inconsistent across teams, and unable to surface systemic problems. The PSEval methodology addresses this by:

- Defining **147 discrete, verifiable standards** across six categories
- Assigning **priority weights** that reflect the real-world cost of non-compliance
- Enabling **automated evaluation** so quality is measured consistently on every code change
- Producing **quantitative compliance scores** that can be tracked, compared, and acted upon

The framework is derived from [Microsoft's PowerShell development guidelines](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines), PSScriptAnalyzer rules, and Pester testing standards, with pragmatic enterprise overlays.

---

## Evaluation Scope Levels

Evaluation can be applied at six scope levels. Each level examines a different surface area and is appropriate for different purposes.

| Scope | What It Examines | Typical Evaluator |
|---|---|---|
| **Enterprise** | Cross-module consistency, shared standards adoption, organisational patterns | Architecture Review Board |
| **Repository** | Module portfolio, CI/CD integration, repository-level practices | Platform Engineering |
| **Module** | Complete module: manifest, structure, all public functions | Module Author, Code Reviewer |
| **Function** | Individual function design, parameters, pipeline support | Code Reviewer |
| **Component** | Subsystem within a module (e.g., authentication layer) | Module Author |
| **Script** | Standalone scripts outside module context | Script Author |

### When to Use Each Level

**Enterprise-level evaluation** is used for governance: identifying which modules have adopted mandatory standards, comparing compliance rates across teams, and detecting when organisation-wide patterns have drifted from baseline. It does not deep-inspect individual functions.

**Repository-level evaluation** examines whether the repository structure, CI/CD configuration, and module portfolio meet baseline requirements. This is the appropriate scope for platform engineering reviews and DevOps audits.

**Module-level evaluation** is the most commonly used scope. It produces a comprehensive compliance report covering architecture, coding standards, documentation coverage, error handling patterns, and test coverage — everything needed to determine whether a module is ready for production release.

**Function-level evaluation** is used when deep-inspecting a specific area of concern — for example, verifying that a newly added function meets all Critical standards before merging.

---

## The Standards Priority System

Not all standards carry equal weight. The PSEval methodology uses a three-tier priority system that reflects the severity of non-compliance.

### Priority Tiers

| Priority | Weight | Rationale |
|---|---|---|
| **Critical** | 60% | Non-compliance causes security vulnerabilities, data loss, pipeline failures, or fundamentally broken cmdlet behaviour. These standards have zero tolerance. |
| **Important** | 30% | Non-compliance degrades quality, maintainability, and interoperability. A small number of failures is acceptable but should be remediated. |
| **Recommended** | 10% | Best-practice guidance. Non-compliance does not constitute a defect, but adoption improves the codebase over time. |

The weight distribution is intentionally asymmetric. Critical standards account for 60% of the score because a module with perfect documentation but exposed credentials or no error handling is not a safe module to ship.

### Critical Standards Behaviour

Critical standards have a special property in the scoring model: **100% of Critical standards must pass** for a module to achieve a passing score, regardless of the overall weighted percentage. A module that fails even one Critical standard cannot achieve "Pass" status, even if its overall score is high.

This design prevents a common failure mode in quality frameworks where teams optimise for aggregate score by maximising easy wins while ignoring hard Critical violations.

---

## Compliance Scoring Methodology

The compliance score is a weighted calculation across all evaluated standards.

### Score Calculation

```
ComplianceScore = (CriticalPassed / CriticalTotal × 0.6) +
                  (ImportantPassed / ImportantTotal × 0.3) +
                  (RecommendedPassed / RecommendedTotal × 0.1)
```

The result is a value between 0.0 and 1.0, expressed as a percentage in reports.

### Pass and Excellence Thresholds

| Threshold | Score Required | Critical Requirement |
|---|---|---|
| **Pass** | ≥ 75% overall | ≥ 80% of Critical standards pass |
| **Excellence** | ≥ 90% overall | ≥ 95% of Critical standards pass |

A module achieving Pass status is considered production-ready. Excellence status indicates a module suitable for use as a reference implementation.

### Interpreting Scores

A score below 75% overall indicates that the module has significant quality gaps that should be addressed before release. The most actionable path is to first examine all failing Critical standards, then address Important standards in order of remediation cost.

A module may achieve a passing overall score while failing the Critical threshold. In this case, the result is still a failure — the Critical constraint overrides the aggregate percentage. This situation typically arises when a module has comprehensive documentation and testing but has skipped security-critical standards such as credential handling or input validation.

### Score Calculation Example

```powershell
# Example compliance score calculation
$criticalPassed    = 18
$criticalTotal     = 20
$importantPassed   = 42
$importantTotal    = 50
$recommendedPassed = 12
$recommendedTotal  = 20

$criticalScore    = ($criticalPassed / $criticalTotal) * 0.6
$importantScore   = ($importantPassed / $importantTotal) * 0.3
$recommendedScore = ($recommendedPassed / $recommendedTotal) * 0.1

$overallScore = $criticalScore + $importantScore + $recommendedScore
# Result: 0.54 + 0.252 + 0.06 = 0.852 = 85.2%

# Critical check: 18/20 = 90% >= 80% threshold → PASS
# Overall: 85.2% >= 75% threshold → PASS
```

---

## Evaluation Approaches

### Automated Evaluation

Automated evaluation applies static analysis to measure compliance without human review. It is fast, repeatable, and appropriate for CI/CD integration.

Automated evaluation covers:

- **Architecture standards** — manifest existence, required fields, directory structure, module versioning, no wildcard exports
- **Coding standards** — approved verb validation via AST analysis, PSScriptAnalyzer rule compliance, naming convention verification
- **Documentation standards** — `Get-Help` output validation, comment-based help coverage, example presence
- **Security standards** — static analysis for credential exposure patterns, PSScriptAnalyzer security rules

Automated evaluation cannot fully assess:

- Semantic correctness of documentation (whether descriptions are accurate)
- Test quality (whether tests genuinely validate behaviour or are trivially passing)
- Architecture intent (whether the module structure reflects good design decisions)
- Error message quality (whether messages are helpful to end users)

Automated evaluation is designed to provide a fast, objective baseline. It should be supplemented by manual review for critical or high-risk modules.

### Manual Review

Manual review applies human judgement to areas where automated analysis is insufficient. Manual review is appropriate for:

- **Pre-release evaluation** of production modules
- **Architecture review** of new modules entering the portfolio
- **Security review** of modules handling credentials or sensitive data
- **Documentation quality** assessment

Manual review uses the compliance checklists provided in [how-to-evaluate-module-compliance.md](how-to-evaluate-module-compliance.md) to ensure consistent coverage.

### Continuous Evaluation

Continuous evaluation integrates PSEval into the CI/CD pipeline so that compliance is measured on every code change. This approach provides:

- **Regression detection** — compliance scores are tracked over time; a decline triggers a failing build
- **PR gates** — pull requests that reduce compliance scores below threshold are blocked from merging
- **Trend visibility** — compliance history is visible in build dashboards, enabling teams to identify drift before it accumulates

See [how-to-automate-evaluation.md](how-to-automate-evaluation.md) for CI/CD integration patterns.

---

## Quality Metrics Framework

Beyond the compliance score, the methodology tracks several supporting metrics.

### Coverage Metrics

| Metric | Description | Target |
|---|---|---|
| **Documentation coverage** | Ratio of public functions with complete comment-based help | 100% |
| **Test coverage** | Code coverage percentage measured by Pester | ≥ 80% for Critical functions |
| **Standards coverage** | Ratio of standards evaluated (automated + manual) | 100% at module level |

### Trend Metrics

Trend metrics are only meaningful when evaluation history exists. At enterprise scale, the following trends are tracked:

- **Compliance score delta per release** — whether quality is improving or degrading over time
- **Critical standard failure rate** — whether critical violations are being introduced by new code
- **Remediation velocity** — how quickly identified violations are resolved

### Quality Gate Integration

Quality gates are checkpoints in the delivery pipeline that prevent advancement when compliance thresholds are not met. The PSEval framework defines gates at:

- **PR merge** — minimum score threshold enforced before merge
- **Release build** — full evaluation required before artefact promotion
- **Enterprise registration** — modules entering the shared module gallery must meet Excellence threshold

---

## The Relationship Between Automated and Manual Evaluation

Automated and manual evaluation are complementary, not substitutes. The expected workflow is:

1. **Automated evaluation** runs on every commit — provides fast feedback on measurable violations
2. **Developer remediation** — violations are fixed before PR submission
3. **PR automated gate** — automated evaluation confirms compliance before review is requested
4. **Manual code review** — reviewers focus on semantic quality, not mechanical violations (which are already handled)
5. **Pre-release manual evaluation** — comprehensive checklist review for production releases

This separation of concerns means that automated tools handle the mechanical, objective aspects of quality — freeing human reviewers to focus on judgement-intensive concerns that tools cannot assess.

---

## Standards Evolution

The PSEval standards are versioned alongside the modules that use them. When standards are updated:

- **New standards** enter at Recommended priority and may be promoted to Important or Critical in subsequent major versions
- **Retired standards** are marked `[Deprecated]` before removal, giving teams a migration window
- **Priority changes** (e.g., Recommended to Critical) are announced at least one major version in advance
- **Threshold changes** are communicated with rationale in the standards changelog

Standards versioning ensures that a module's compliance score remains stable between releases unless the module itself changes.

---

## Related Resources

- [PSEval Standards Overview](reference-standards-overview.md)
- [how-to: Evaluate Module Compliance](how-to-evaluate-module-compliance.md)
- [how-to: Automate Evaluation in CI/CD](how-to-automate-evaluation.md)
- [reference: Evaluation Automation API](reference-evaluation-automation-api.md)
- [Microsoft — Cmdlet Development Guidelines](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
- [Pester Testing Framework](https://pester.dev/)
