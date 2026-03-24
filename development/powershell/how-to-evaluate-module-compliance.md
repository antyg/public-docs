---
title: "How to Evaluate Module Compliance"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Code Reviewers, Engineering Managers"
document_type: "how-to"
domain: "development"
---

# How to Evaluate Module Compliance

This guide provides practical checklists and procedures for evaluating PowerShell module compliance against the PSEval standards framework. Use it when conducting code reviews, pre-release assessments, or periodic quality audits.

For the conceptual background behind the scoring model and priority tiers, see [explanation-evaluation-methodology.md](explanation-evaluation-methodology.md).

---

## Prerequisites

- Access to the module source code
- PowerShell 7.x installed (for running `Invoke-PSEvaluation` and `Invoke-ScriptAnalyzer`)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) installed (`Install-Module PSScriptAnalyzer`)
- [Pester](https://pester.dev/) 5.x installed (`Install-Module Pester -MinimumVersion 5.0`)
- The module loadable in the current session

---

## Scope Selection

Choose the evaluation scope appropriate for your purpose.

| Purpose | Recommended Scope |
|---|---|
| Pre-release sign-off | Module |
| Code review of a single function | Function |
| Onboarding a module into shared gallery | Module + Repository |
| Architecture review of a new module | Module |
| Enterprise portfolio audit | Enterprise |
| CI/CD gate | Module (automated) |

---

## Module-Level Evaluation

### Step 1 — Run Automated Analysis

Before using the manual checklists, run automated analysis to identify mechanical violations quickly.

```powershell
# Run PSScriptAnalyzer against the module source
$results = Invoke-ScriptAnalyzer -Path 'D:\modules\MyModule\src' -Recurse -Severity Error, Warning
if ($results.Count -gt 0) {
    $results | Format-Table RuleName, Severity, Message, ScriptName, Line -AutoSize
}
```

```powershell
# Run Pester with code coverage
$config = New-PesterConfiguration
$config.Run.Path = 'D:\modules\MyModule\tests\Unit'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = 'D:\modules\MyModule\src'
$config.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $config
```

Address any PSScriptAnalyzer errors before proceeding to the manual checklist.

---

### Step 2 — Architecture Standards Checklist (ARCH)

Work through each item. Mark Pass, Fail, or N/A.

#### Critical — Must all pass

| ID | Standard | Check |
|---|---|---|
| ARCH-001 | Module manifest (`.psd1`) present and passes `Test-ModuleManifest` | `Test-ModuleManifest .\MyModule.psd1` returns without error |
| ARCH-002 | Directory structure present: `src/Public/`, `src/Private/`, `tests/Unit/`, `tests/Integration/`, `docs/` | Verify directories exist |
| ARCH-004 | `FunctionsToExport` lists explicit function names — no wildcard `'*'` | Read `.psd1`, check `FunctionsToExport` value |

#### Important — Must ≥ 80% pass

| ID | Standard | Check |
|---|---|---|
| ARCH-003 | Module versioning follows [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`) | Read `ModuleVersion` in `.psd1` |
| ARCH-005 | `RootModule` points to `.psm1` file, not `.ps1` | Read `RootModule` in `.psd1` |
| ARCH-006 | `Author`, `Description`, `CompanyName` fields populated | Read `.psd1` fields |
| ARCH-007 | `CompatiblePSEditions` declared (`Desktop`, `Core`, or both) | Read `.psd1` |
| ARCH-008 | `PowerShellVersion` minimum declared | Read `.psd1` |
| ARCH-010 | Private functions not exported (absent from `FunctionsToExport`) | Cross-reference `src/Private/` with `.psd1` exports |
| ARCH-011 | Module loads without errors (`Import-Module` succeeds) | `Import-Module .\MyModule.psd1 -Force -ErrorAction Stop` |
| ARCH-012 | No circular dependencies between functions | Review `$PSScriptRoot` imports in `.psm1` |
| ARCH-015 | `RequiredModules` declared for all dependencies | Read `.psd1`; verify all `Import-Module` calls are in manifest |

---

### Step 3 — Coding Standards Checklist (CODE)

#### Critical

| ID | Standard | Check |
|---|---|---|
| CODE-001 | All function verbs are [Microsoft-approved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) | `Get-Command -Module MyModule \| Where-Object { -not (Get-Verb $_.Verb) }` — must return empty |
| CODE-002 | All function names follow `Verb-Noun` pattern with PascalCase singular noun | Review exported function names |
| CODE-013 | Credential parameters use `[PSCredential]` type; no plaintext password parameters | Search source for `[string]$Password` patterns |
| CODE-014 | Input validation attributes present on all parameters accepting user input | Spot-check 5 representative functions |

#### Important

| ID | Standard | Check |
|---|---|---|
| CODE-003 | Local variables use camelCase | Spot-check function bodies |
| CODE-004 | Parameter names use PascalCase; standard names (`Name`, `Path`, `ComputerName`) used consistently | Review parameter blocks |
| CODE-018 | PSScriptAnalyzer passes without Error or Warning violations | Review automated output from Step 1 |
| CODE-025 | Log levels used correctly (`Write-Error`, `Write-Warning`, `Write-Verbose`, `Write-Debug`) | Spot-check verbose/debug output in functions |

---

### Step 4 — Function Design Standards Checklist (FUNC)

Evaluate a representative sample of public functions (minimum 20% of exported functions, or all if fewer than 10).

#### Critical

| ID | Standard | Check |
|---|---|---|
| FUNC-001 | `[CmdletBinding()]` present on all public functions | Grep for functions missing `[CmdletBinding()]` |
| FUNC-001 | `SupportsShouldProcess` set for all state-modifying functions | Identify `Set-`, `New-`, `Remove-`, `Add-` functions; verify attribute |
| FUNC-002 | All parameters have `[Parameter()]` attribute | Review param blocks |
| FUNC-002 | `Mandatory` specified for required parameters | Review param blocks for required inputs |
| FUNC-022 | Unit tests present for all public functions | Verify `tests/Unit/<FunctionName>.Tests.ps1` exists for each exported function |

#### Important

| ID | Standard | Check |
|---|---|---|
| FUNC-003 | Pipeline input supported via `ValueFromPipeline` or `ValueFromPipelineByPropertyName` | Review key functions |
| FUNC-004 | `[OutputType()]` declared on all output-producing functions | Search for missing `[OutputType()]` |
| FUNC-007 | `begin`/`process`/`end` blocks used for pipeline-accepting functions | Review functions accepting pipeline input |
| FUNC-010 | Custom output uses `[PSCustomObject]` with named PascalCase properties | Review output construction patterns |
| FUNC-012 | `$PSCmdlet.WriteError()` used for non-terminating errors (not bare `Write-Error`) | Spot-check error handling |
| FUNC-013 | `$PSCmdlet.ThrowTerminatingError()` used for terminating errors | Spot-check catch blocks |

---

### Step 5 — Documentation Standards Checklist (DOC)

#### Critical

| ID | Standard | Check |
|---|---|---|
| DOC-001 | Comment-based help present on all public functions | `Get-Help <FunctionName>` returns content for each exported function |
| DOC-001 | `.SYNOPSIS` present and non-empty | Review help output |
| DOC-001 | `.DESCRIPTION` present and comprehensive | Review help output |
| DOC-001 | `.PARAMETER` section present for all parameters | `(Get-Help <FunctionName>).Parameters` returns entries for all params |
| DOC-001 | At least one `.EXAMPLE` with working code | Review `.Examples` in help output |
| DOC-001 | `.INPUTS` and `.OUTPUTS` present | Review help output |

#### Important

| ID | Standard | Check |
|---|---|---|
| DOC-002 | Examples execute without modification | Run one example from each checked function |
| DOC-007 | `README.md` present with installation instructions, prerequisites, and quick-start example | Read module root `README.md` |
| DOC-008 | `CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com/) format | Read `CHANGELOG.md` |

---

### Step 6 — Error Handling Standards Checklist (ERR)

#### Critical

| ID | Standard | Check |
|---|---|---|
| ERR-001 | `try-catch` blocks wrap all error-prone operations (network calls, file I/O, external calls) | Spot-check functions with external dependencies |
| ERR-002 | `ErrorRecord` objects constructed with all 4 required parameters: `Exception`, `ErrorId`, `ErrorCategory`, `TargetObject` | Search for `[System.Management.Automation.ErrorRecord]::new(` — verify 4 args |
| ERR-006 | No credentials or sensitive data in error messages or logs | Search for `Write-Error.*Password`, `Write-Verbose.*Credential` patterns |

#### Important

| ID | Standard | Check |
|---|---|---|
| ERR-003 | Specific exception types caught before generic catch | Review catch block ordering in functions |
| ERR-010 | `Write-Verbose` used for operation progress; `Write-Debug` for diagnostic state | Spot-check verbose/debug output |
| ERR-018 | `[CmdletBinding()]` present ensures `ErrorAction` is supported | Covered by FUNC-001 check |
| ERR-019 | Errors written via `$PSCmdlet.WriteError()` or `$PSCmdlet.ThrowTerminatingError()` | Spot-check error write patterns |

---

### Step 7 — Testing Standards Checklist (TEST)

#### Critical

| ID | Standard | Check |
|---|---|---|
| TEST-001 | Unit tests present for all public functions | Verify test file existence from FUNC-022 check |
| TEST-001 | Code coverage ≥ 80% for Critical functions | Review Pester coverage report from Step 1 |
| TEST-010 | Security/injection tests present | Search test files for injection test patterns |
| TEST-016 | Quality gate (PSScriptAnalyzer) passes | Review automated output from Step 1 |

#### Important

| ID | Standard | Check |
|---|---|---|
| TEST-002 | Test files named `<FunctionName>.Tests.ps1` | List files in `tests/Unit/` |
| TEST-002 | Pester 5.x structure used (`Describe` → `Context` → `It`) | Review test file structure |
| TEST-003 | Test data externalised to `tests/Fixtures/` | Check for fixture files |
| TEST-005 | Mock verification uses `Should -Invoke` | Search test files for `Should -Invoke` |
| TEST-013 | Tests integrated into CI/CD pipeline | Review pipeline configuration |

---

### Step 8 — Calculate Compliance Score

After working through the checklists, tally results and calculate the weighted score.

```powershell
# Score calculation
$criticalTotal     = <count of Critical standards evaluated>
$criticalPassed    = <count of Critical standards that passed>
$importantTotal    = <count of Important standards evaluated>
$importantPassed   = <count of Important standards that passed>
$recommendedTotal  = <count of Recommended standards evaluated>
$recommendedPassed = <count of Recommended standards that passed>

$score = ($criticalPassed / $criticalTotal * 0.6) +
         ($importantPassed / $importantTotal * 0.3) +
         ($recommendedPassed / $recommendedTotal * 0.1)

"Overall compliance score: $([Math]::Round($score * 100, 1))%"

# Pass/fail determination
$criticalThreshold  = $criticalPassed / $criticalTotal -ge 0.80
$overallThreshold   = $score -ge 0.75

if ($criticalThreshold -and $overallThreshold) {
    "Result: PASS"
} elseif (-not $criticalThreshold) {
    "Result: FAIL (Critical threshold not met: $([Math]::Round($criticalPassed / $criticalTotal * 100, 1))% < 80%)"
} else {
    "Result: FAIL (Overall score insufficient: $([Math]::Round($score * 100, 1))% < 75%)"
}
```

---

## Repository-Level Evaluation

Repository-level evaluation adds checks beyond individual module quality.

### Repository Checklist

| Area | Check |
|---|---|
| **CI/CD** | Tests run automatically on PR and merge |
| **CI/CD** | Build fails when tests fail |
| **CI/CD** | PSScriptAnalyzer runs in pipeline |
| **CI/CD** | Code coverage report generated and published |
| **Structure** | All modules follow consistent directory layout |
| **Structure** | Shared utilities in a common module, not duplicated |
| **Versioning** | All modules follow Semantic Versioning |
| **Documentation** | Repository `README.md` present with module inventory |
| **Security** | No credentials or secrets in version control |
| **Security** | `.gitignore` excludes log files, credential files |

---

## Enterprise-Level Evaluation

Enterprise evaluation assesses standards adoption across the module portfolio.

### Enterprise Checklist

| Area | Check |
|---|---|
| **Adoption** | All production modules evaluated within last 90 days |
| **Adoption** | All new modules evaluated before release |
| **Consistency** | Module naming conventions consistent across teams |
| **Consistency** | Shared authentication patterns used consistently |
| **Compliance** | All production modules meet Pass threshold (≥ 75% + ≥ 80% Critical) |
| **Governance** | Quality gate enforced in CI/CD for all repositories |
| **Governance** | Excellence threshold (≥ 90%) required for shared module gallery |
| **Tracking** | Compliance scores tracked over time |
| **Tracking** | Declining scores trigger remediation workflow |

---

## Remediation Planning

When a module fails evaluation, prioritise remediation in this order:

### Priority 1 — Critical Violations (Fix Immediately)

Address all failing Critical standards before any other work. Common Critical failures and their remediation:

| Failing Standard | Typical Cause | Remediation |
|---|---|---|
| ARCH-001 | Missing or invalid manifest | Create manifest with `New-ModuleManifest`; validate with `Test-ModuleManifest` |
| ARCH-004 | Wildcard `FunctionsToExport = '*'` | List all public function names explicitly |
| CODE-001 | Unapproved verbs | Rename functions to use approved verbs; update all call sites |
| CODE-013 | Plaintext credential parameters | Replace `[string]$Password` with `[PSCredential]$Credential` |
| FUNC-001 | Missing `[CmdletBinding()]` | Add `[CmdletBinding()]` to all public functions |
| ERR-002 | Incomplete ErrorRecord construction | Add all 4 required parameters to `ErrorRecord` constructor |
| ERR-006 | Credentials in error messages | Sanitise all `Write-Error`/`Write-Verbose` strings |
| TEST-001 | Missing unit tests | Write tests for all public functions before next release |

### Priority 2 — Important Violations (Fix Before Release)

After all Critical violations are resolved, address Important violations with the highest remediation return on investment.

### Priority 3 — Recommended Violations (Schedule for Backlog)

Log Recommended violations as technical debt items. Address in routine maintenance cycles rather than blocking releases.

---

## Recording Evaluation Results

Document the evaluation outcome for audit and tracking purposes.

**Minimum record per evaluation:**

- Date of evaluation
- Module name and version evaluated
- Evaluator name
- Scope level (Module, Repository, Enterprise)
- Standards evaluated (count by priority)
- Standards passed (count by priority)
- Overall compliance score
- Pass/Fail result
- Failing standards list (ID and description)
- Remediation actions agreed

---

## Related Resources

- [explanation: Understanding the PSEval Compliance Methodology](explanation-evaluation-methodology.md)
- [how-to: Automate Evaluation in CI/CD](how-to-automate-evaluation.md)
- [reference: Evaluation Automation API](reference-evaluation-automation-api.md)
- [reference: Standards Overview](reference-standards-overview.md)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
- [Pester Documentation](https://pester.dev/docs/quick-start)
- [Microsoft — Approved Verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
