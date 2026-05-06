---
title: "PSEval Evaluation Automation API Reference"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, DevOps Engineers"
document_type: "reference"
domain: "development"
---

# PSEval Evaluation Automation API Reference

Function reference for the PSEval evaluation automation engine. For usage examples and CI/CD integration patterns, see [how-to-automate-evaluation.md](how-to-automate-evaluation.md).

---

## Invoke-PSEvaluation

**Synopsis:** Runs the full PSEval compliance evaluation against a module or repository path.

**Syntax:**

```powershell
Invoke-PSEvaluation
    -Path <string>
    [-Level <string>]
    [-Standards <string[]>]
    [-OutputPath <string>]
    [-Configuration <PSEvalConfiguration>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Path` | `string` | Yes | Absolute path to the module root or repository to evaluate. |
| `Level` | `string` | No | Evaluation scope: `Module`, `Repository`, `Enterprise`, `Function`, `Component`, `Script`. Default: `Module`. |
| `Standards` | `string[]` | No | Array of standard IDs to evaluate (e.g., `@('ARCH-001', 'CODE-001')`). When omitted, all standards applicable to the level are evaluated. |
| `OutputPath` | `string` | No | Absolute path for the output report file. Format is inferred from the file extension (`.html`, `.json`, `.xml`, `.csv`). When omitted, no file is written. |
| `Configuration` | `PSEvalConfiguration` | No | Configuration object from `New-PSEvalConfiguration` or `Get-PSEvalDefaultConfiguration`. When omitted, default configuration is used. |

**Output:** `PSEvalResult` object with the following properties:

| Property | Type | Description |
|---|---|---|
| `ModuleName` | `string` | Name of the evaluated module. |
| `ModuleVersion` | `string` | Version string from the module manifest. |
| `EvaluationDate` | `datetime` | UTC timestamp of evaluation. |
| `Level` | `string` | Scope level used for this evaluation. |
| `Score.Overall` | `decimal` | Weighted overall compliance score (0–100). |
| `Score.Critical` | `decimal` | Critical standards score (0–100). |
| `Score.Important` | `decimal` | Important standards score (0–100). |
| `Score.Recommended` | `decimal` | Recommended standards score (0–100). |
| `Score.CriticalPassed` | `int` | Count of Critical standards that passed. |
| `Score.CriticalTotal` | `int` | Total Critical standards evaluated. |
| `Score.ImportantPassed` | `int` | Count of Important standards that passed. |
| `Score.ImportantTotal` | `int` | Total Important standards evaluated. |
| `Score.RecommendedPassed` | `int` | Count of Recommended standards that passed. |
| `Score.RecommendedTotal` | `int` | Total Recommended standards evaluated. |
| `Status` | `string` | `Pass`, `Fail`, or `Excellence`. |
| `FailedStandards` | `PSEvalStandardResult[]` | Array of standards that did not pass. |
| `PassedStandards` | `PSEvalStandardResult[]` | Array of standards that passed. |

**Notes:**

- The function imports the target module during evaluation to validate documentation and exported functions. The module must load without errors.
- When `Standards` is specified, only those standards are evaluated; the compliance score reflects only the evaluated subset.
- Exit code is `0` on Pass, `1` on Fail. Use this in CI/CD scripts to gate builds.

---

## Test-PSArchitectureStandards

**Synopsis:** Evaluates architecture standards (ARCH-001 through ARCH-025) for a module.

**Syntax:**

```powershell
Test-PSArchitectureStandards
    -Path <string>
    [-Standards <string[]>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Path` | `string` | Yes | Absolute path to the module root directory. |
| `Standards` | `string[]` | No | Specific ARCH standard IDs to evaluate. When omitted, all ARCH standards are evaluated. |

**Output:** `PSEvalStandardResult[]` — one result object per evaluated standard.

**Evaluated checks:**

- Manifest existence and validity (`Test-ModuleManifest`)
- Required directory structure presence (`src/Public/`, `src/Private/`, `tests/Unit/`, `tests/Integration/`, `docs/`)
- `FunctionsToExport` — explicit list, no wildcard
- Semantic versioning compliance of `ModuleVersion`
- `RootModule` points to `.psm1` file
- `Author`, `Description`, `CompanyName` fields populated
- `CompatiblePSEditions` declared
- `PowerShellVersion` minimum declared
- Private functions absent from exports
- Module loads without errors
- `RequiredModules` covers all dependencies

---

## Test-PSCodingStandards

**Synopsis:** Evaluates coding standards (CODE-001 through CODE-031) for a module.

**Syntax:**

```powershell
Test-PSCodingStandards
    -Path <string>
    [-Standards <string[]>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Path` | `string` | Yes | Absolute path to the module source directory. |
| `Standards` | `string[]` | No | Specific CODE standard IDs to evaluate. When omitted, all CODE standards are evaluated. |

**Output:** `PSEvalStandardResult[]` — one result object per evaluated standard.

**Evaluated checks:**

- Approved verb validation — uses PowerShell AST to extract function names and validates each verb against `Get-Verb` output
- `Verb-Noun` naming pattern compliance — PascalCase, singular noun, hyphen separator
- PSScriptAnalyzer execution — runs with `Error` and `Warning` severity rules
- Credential handling — detects `[string]$Password` patterns in parameter blocks
- Variable naming conventions — camelCase for locals, `$script:` prefix for script-scoped
- Parameter naming — PascalCase, standard names

**Notes:**

- Verb validation uses the PowerShell AST `ParseFile` method. Pre-declare token and error variables before passing as `[ref]` arguments:

```powershell
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
```

---

## Test-PSDocumentationStandards

**Synopsis:** Evaluates documentation standards (DOC-001 through DOC-024) for a module.

**Syntax:**

```powershell
Test-PSDocumentationStandards
    -Path <string>
    [-ModuleName <string>]
    [-Standards <string[]>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Path` | `string` | Yes | Absolute path to the module root directory. |
| `ModuleName` | `string` | No | Name of the module. When omitted, derived from the manifest file name. |
| `Standards` | `string[]` | No | Specific DOC standard IDs to evaluate. When omitted, all DOC standards are evaluated. |

**Output:** `PSEvalStandardResult[]` — one result object per evaluated standard.

**Evaluated checks:**

- Module is imported and `Get-Command -Module <ModuleName>` returns functions
- For each exported function, `Get-Help <FunctionName>` output is inspected for:
  - `.Synopsis` — non-empty
  - `.Description` — non-empty, minimum 20 characters
  - `.Parameters` — entry present for each declared parameter
  - `.Examples` — at least one example present
  - `.InputTypes` — present (may be `None`)
  - `.ReturnValues` — present (may be `None`)
- `README.md` present at module root
- `CHANGELOG.md` present at module root

**Notes:**

- The module must be importable in the current session. If the module is not installed, use `Import-Module -Path <path>` before calling this function.
- The function does not execute examples — it validates their presence only.

---

## Export-PSEvalResults

**Synopsis:** Exports a `PSEvalResult` or array of results to a file in the specified format.

**Syntax:**

```powershell
Export-PSEvalResults
    -Results <PSEvalResult | PSEvalResult[]>
    -Path <string>
    -Format <string>
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Results` | `PSEvalResult` or `PSEvalResult[]` | Yes | Result object(s) from `Invoke-PSEvaluation`. |
| `Path` | `string` | Yes | Absolute path for the output file. Directory must exist. |
| `Format` | `string` | Yes | Output format: `JSON`, `HTML`, `XML`, `CSV`. |

**Output:** None. Writes file to `Path`.

**Format details:**

| Format | Use Case | Notes |
|---|---|---|
| `JSON` | Machine-readable, API integration | Full result object including all standard results |
| `HTML` | Human review, build artefact | Styled report with compliance score, pass/fail table, failing standards |
| `XML` | Legacy system integration | Structured XML matching the PSEvalResult schema |
| `CSV` | Spreadsheet analysis, trend tracking | One row per standard result; module metadata repeated per row |

---

## ConvertTo-PSEvalHTMLReport

**Synopsis:** Converts a `PSEvalResult` to a styled HTML report string.

**Syntax:**

```powershell
ConvertTo-PSEvalHTMLReport
    -Results <PSEvalResult>
    [-Title <string>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `Results` | `PSEvalResult` | Yes | Result object from `Invoke-PSEvaluation`. |
| `Title` | `string` | No | Report title displayed in the HTML `<title>` and `<h1>` elements. Default: `"PSEval Compliance Report — <ModuleName>"`. |

**Output:** `string` — complete HTML document.

**Notes:**

- The HTML report includes: compliance score summary, pass/fail badge, score breakdown by priority tier, full table of evaluated standards with pass/fail status, failing standards detail section with standard IDs and descriptions.
- The output can be written to a file with the `Write` tool or passed to `Export-PSEvalResults -Format HTML`.

---

## Get-PSEvalDefaultConfiguration

**Synopsis:** Returns the default PSEval configuration object.

**Syntax:**

```powershell
Get-PSEvalDefaultConfiguration
    [<CommonParameters>]
```

**Output:** `PSEvalConfiguration` object with default values.

**Default values:**

| Property | Default Value |
|---|---|
| `PassThreshold` | `0.75` (75%) |
| `ExcellenceThreshold` | `0.90` (90%) |
| `CriticalPassThreshold` | `0.80` (80%) |
| `CriticalExcellenceThreshold` | `0.95` (95%) |
| `CriticalWeight` | `0.60` |
| `ImportantWeight` | `0.30` |
| `RecommendedWeight` | `0.10` |
| `Standards` | All 147 standards (full suite) |
| `IncludeRecommended` | `$true` |

---

## New-PSEvalConfiguration

**Synopsis:** Creates a custom PSEval configuration object with user-specified thresholds and standards subset.

**Syntax:**

```powershell
New-PSEvalConfiguration
    [-PassThreshold <decimal>]
    [-ExcellenceThreshold <decimal>]
    [-CriticalPassThreshold <decimal>]
    [-CriticalWeight <decimal>]
    [-ImportantWeight <decimal>]
    [-RecommendedWeight <decimal>]
    [-Standards <string[]>]
    [-IncludeRecommended <bool>]
    [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `PassThreshold` | `decimal` | No | Minimum overall score (0.0–1.0) for Pass status. Default: `0.75`. |
| `ExcellenceThreshold` | `decimal` | No | Minimum overall score (0.0–1.0) for Excellence status. Default: `0.90`. |
| `CriticalPassThreshold` | `decimal` | No | Minimum Critical score (0.0–1.0) for Pass status. Default: `0.80`. |
| `CriticalWeight` | `decimal` | No | Weight applied to the Critical score component. Default: `0.60`. |
| `ImportantWeight` | `decimal` | No | Weight applied to the Important score component. Default: `0.30`. |
| `RecommendedWeight` | `decimal` | No | Weight applied to the Recommended score component. Default: `0.10`. |
| `Standards` | `string[]` | No | Array of standard IDs to include. When omitted, the full 147-standard suite is used. |
| `IncludeRecommended` | `bool` | No | Whether Recommended standards contribute to score calculation. Default: `$true`. |

**Output:** `PSEvalConfiguration` object.

**Notes:**

- Weight parameters must sum to `1.0`. Passing weights that do not sum to `1.0` raises an `InvalidArgument` exception.
- The `Standards` parameter accepts standard IDs in the format `CATEGORY-NNN` (e.g., `ARCH-001`, `CODE-013`, `TEST-016`).
- Passing a `Standards` subset does not change the weight distribution — weights still apply proportionally within the evaluated subset.

---

## PSEvalStandardResult Object

Each element of `FailedStandards` and `PassedStandards` in a `PSEvalResult` is a `PSEvalStandardResult` object.

| Property | Type | Description |
|---|---|---|
| `Id` | `string` | Standard identifier (e.g., `ARCH-001`). |
| `Name` | `string` | Short human-readable name of the standard. |
| `Priority` | `string` | `Critical`, `Important`, or `Recommended`. |
| `Category` | `string` | Standards category (e.g., `Architecture`, `Coding`, `Testing`). |
| `Scope` | `string` | Applicable scopes (e.g., `Function, Module, Repository`). |
| `Passed` | `bool` | `$true` if the standard passed, `$false` if it failed. |
| `Evidence` | `string` | Description of the check performed and its outcome. |
| `Remediation` | `string` | Suggested remediation action when `Passed` is `$false`. |

---

## Related Resources

- [how-to: Automate Evaluation in CI/CD](how-to-automate-evaluation.md)
- [how-to: Evaluate Module Compliance](how-to-evaluate-module-compliance.md)
- [explanation: Understanding the PSEval Compliance Methodology](explanation-evaluation-methodology.md)
- [reference: Standards Overview](reference-standards-overview.md)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
- [Pester Documentation](https://pester.dev/docs/quick-start)
- [Microsoft — Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines)
- [GitHub Actions](https://docs.github.com/en/actions)
- [standards-testing.md](standards-testing.md)
