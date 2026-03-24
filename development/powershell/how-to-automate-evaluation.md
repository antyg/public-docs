---
title: "How to Automate PSEval Evaluation in CI/CD"
status: "published"
last_updated: "2026-03-16"
audience: "DevOps Engineers, PowerShell Developers"
document_type: "how-to"
domain: "development"
---

# How to Automate PSEval Evaluation in CI/CD

This guide covers how to integrate PSEval automated evaluation into your CI/CD pipeline so that compliance is measured on every code change. For the full function reference, see [reference-evaluation-automation-api.md](reference-evaluation-automation-api.md).

---

## Prerequisites

- PSEval evaluation module available in your pipeline environment
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) installed
- [Pester](https://pester.dev/) 5.x installed
- Azure Pipelines or GitHub Actions configured for the repository

---

## Basic Module Evaluation

The simplest integration runs `Invoke-PSEvaluation` against a module path and outputs a report.

```powershell
# Evaluate a single module with default configuration
$results = Invoke-PSEvaluation -Path 'D:\modules\MyModule' -Level Module

# Display summary
Write-Host "Overall Score: $($results.Score.Overall)%"
Write-Host "Critical: $($results.Score.Critical)% ($($results.Score.CriticalPassed)/$($results.Score.CriticalTotal))"
Write-Host "Result: $($results.Status)"

# Export results
Export-PSEvalResults -Results $results -Path 'D:\reports\MyModule-compliance.html' -Format HTML
```

---

## Custom Configuration

Use `New-PSEvalConfiguration` to tailor evaluation thresholds and scope.

```powershell
# Create a custom configuration
$config = New-PSEvalConfiguration -PassThreshold 0.80 -ExcellenceThreshold 0.95 -Standards @(
    'ARCH-001', 'ARCH-002', 'ARCH-004',
    'CODE-001', 'CODE-002', 'CODE-013', 'CODE-014',
    'FUNC-001', 'FUNC-002', 'FUNC-003',
    'DOC-001', 'DOC-002',
    'ERR-001', 'ERR-002', 'ERR-006',
    'TEST-001', 'TEST-002', 'TEST-016'
)

# Run evaluation with custom config
$results = Invoke-PSEvaluation -Path 'D:\modules\MyModule' -Level Module -Configuration $config

# Fail the script if evaluation fails (for CI/CD use)
if ($results.Status -ne 'Pass') {
    Write-Error "Module compliance evaluation failed. Score: $($results.Score.Overall)%"
    exit 1
}
```

---

## Enterprise-Wide Assessment

Evaluate all modules in a repository in a single pass.

```powershell
# Discover all modules in the repository
$modulePaths = Get-ChildItem -Path 'D:\modules' -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName '*.psd1') }

# Run enterprise evaluation
$enterpriseResults = @()
foreach ($modulePath in $modulePaths) {
    $result = Invoke-PSEvaluation -Path $modulePath.FullName -Level Module
    $enterpriseResults += [PSCustomObject]@{
        ModuleName    = $modulePath.Name
        Score         = $result.Score.Overall
        CriticalScore = $result.Score.Critical
        Status        = $result.Status
        FailedCount   = $result.FailedStandards.Count
    }
}

# Display enterprise summary
$enterpriseResults | Sort-Object Score | Format-Table -AutoSize

# Export consolidated report
Export-PSEvalResults -Results $enterpriseResults -Path 'D:\reports\enterprise-compliance.html' -Format HTML
```

---

## Azure Pipelines Integration

Add PSEval evaluation as a pipeline stage. The following YAML runs unit tests with code coverage, then evaluates compliance and publishes results.

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - feature/*

pool:
  vmImage: 'windows-latest'

stages:
  - stage: Test
    displayName: 'Test and Evaluate'
    jobs:
      - job: PesterTests
        displayName: 'Pester Unit Tests'
        steps:
          - task: PowerShell@2
            displayName: 'Install Dependencies'
            inputs:
              targetType: 'inline'
              script: |
                Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
                Install-Module Pester -MinimumVersion 5.0 -Force -Scope CurrentUser

          - task: PowerShell@2
            displayName: 'Run Pester Tests with Coverage'
            inputs:
              targetType: 'inline'
              script: |
                $config = New-PesterConfiguration
                $config.Run.Path = '$(Build.SourcesDirectory)/tests/Unit'
                $config.TestResult.Enabled = $true
                $config.TestResult.OutputPath = '$(Build.ArtifactStagingDirectory)/pester-results.xml'
                $config.TestResult.OutputFormat = 'NUnitXml'
                $config.CodeCoverage.Enabled = $true
                $config.CodeCoverage.Path = '$(Build.SourcesDirectory)/src'
                $config.CodeCoverage.OutputPath = '$(Build.ArtifactStagingDirectory)/coverage.xml'
                $config.CodeCoverage.OutputFormat = 'JaCoCo'
                Invoke-Pester -Configuration $config

          - task: PublishTestResults@2
            displayName: 'Publish Test Results'
            inputs:
              testResultsFormat: 'NUnit'
              testResultsFiles: '$(Build.ArtifactStagingDirectory)/pester-results.xml'

          - task: PublishCodeCoverageResults@2
            displayName: 'Publish Code Coverage'
            inputs:
              codeCoverageTool: 'JaCoCo'
              summaryFileLocation: '$(Build.ArtifactStagingDirectory)/coverage.xml'

      - job: PSEvalCompliance
        displayName: 'PSEval Compliance Evaluation'
        dependsOn: PesterTests
        steps:
          - task: PowerShell@2
            displayName: 'Run PSEval Evaluation'
            inputs:
              targetType: 'inline'
              script: |
                $results = Invoke-PSEvaluation `
                    -Path '$(Build.SourcesDirectory)' `
                    -Level Module `
                    -OutputPath '$(Build.ArtifactStagingDirectory)/pseval-report.html'

                Write-Host "##vso[task.setvariable variable=ComplianceScore]$($results.Score.Overall)"
                Write-Host "Compliance Score: $($results.Score.Overall)%"

                if ($results.Status -ne 'Pass') {
                    Write-Host "##vso[task.logissue type=error]Compliance evaluation failed."
                    Write-Host "##vso[task.complete result=Failed;]Compliance gate not met."
                }

          - task: PublishBuildArtifacts@1
            displayName: 'Publish Compliance Report'
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)/pseval-report.html'
              ArtifactName: 'ComplianceReport'
```

---

## GitHub Actions Integration

The following workflow runs PSEval evaluation on pull requests and pushes to main.

```yaml
# .github/workflows/pseval.yml
name: PSEval Compliance

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  evaluate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Dependencies
        shell: pwsh
        run: |
          Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
          Install-Module Pester -MinimumVersion 5.0 -Force -Scope CurrentUser

      - name: Run Pester Tests
        shell: pwsh
        run: |
          $config = New-PesterConfiguration
          $config.Run.Path = './tests/Unit'
          $config.TestResult.Enabled = $true
          $config.TestResult.OutputPath = './pester-results.xml'
          $config.TestResult.OutputFormat = 'NUnitXml'
          $config.CodeCoverage.Enabled = $true
          $config.CodeCoverage.Path = './src'
          Invoke-Pester -Configuration $config

      - name: Publish Test Results
        uses: dorny/test-reporter@v1
        if: always()
        with:
          name: Pester Tests
          path: pester-results.xml
          reporter: java-junit

      - name: Run PSEval Evaluation
        shell: pwsh
        run: |
          $results = Invoke-PSEvaluation -Path '.' -Level Module
          Write-Host "Compliance Score: $($results.Score.Overall)%"
          Write-Host "Critical: $($results.Score.Critical)%"

          if ($results.Status -ne 'Pass') {
            Write-Error "Compliance gate failed: $($results.Score.Overall)%"
            exit 1
          }

      - name: Upload Compliance Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: compliance-report
          path: '*.html'
```

---

## Setting Quality Gates

A quality gate blocks the build or merge when compliance falls below threshold. Configure gates at the points in your pipeline where you want enforcement.

### PR Gate — Block Merge Below Threshold

In Azure Pipelines, use a Branch Policy to require the compliance evaluation job to succeed before a PR can merge.

In GitHub Actions, mark the `evaluate` job as a required status check in the branch protection rules for `main`.

### Release Gate — Require Pass Before Artefact Promotion

```powershell
# Release gate script — run before publishing to module gallery
$config   = Get-PSEvalDefaultConfiguration
$results  = Invoke-PSEvaluation -Path $ModulePath -Level Module -Configuration $config

if ($results.Status -ne 'Pass') {
    $failing = $results.FailedStandards | Where-Object { $_.Priority -eq 'Critical' }
    Write-Error "Release blocked. $($failing.Count) Critical standard(s) failing:"
    $failing | ForEach-Object { Write-Error "  - $($_.Id): $($_.Name)" }
    exit 1
}

Write-Host "Release gate passed. Score: $($results.Score.Overall)%"
```

### Gallery Gate — Require Excellence Threshold

```powershell
# Shared module gallery gate — requires Excellence threshold
$config = New-PSEvalConfiguration -PassThreshold 0.90

$results = Invoke-PSEvaluation -Path $ModulePath -Level Module -Configuration $config

if ($results.Status -ne 'Pass') {
    Write-Error "Gallery submission requires Excellence threshold (90%). Score: $($results.Score.Overall)%"
    exit 1
}
```

---

## Tracking Compliance Over Time

To detect trends, persist compliance scores and compare them across builds.

```powershell
# Append score to tracking file after each evaluation
$evaluation = [PSCustomObject]@{
    Date           = (Get-Date -Format 'yyyy-MM-dd')
    BuildId        = $env:BUILD_BUILDID
    ModuleVersion  = (Import-PowerShellDataFile '.\MyModule.psd1').ModuleVersion
    OverallScore   = $results.Score.Overall
    CriticalScore  = $results.Score.Critical
    Status         = $results.Status
    FailedStandards = ($results.FailedStandards | Select-Object -ExpandProperty Id) -join ', '
}

$trackingPath = '.\compliance-history.json'
$history = if (Test-Path $trackingPath) {
    Get-Content $trackingPath | ConvertFrom-Json
} else {
    @()
}

$history += $evaluation
$history | ConvertTo-Json -Depth 5 | Set-Content $trackingPath
```

---

## Troubleshooting

### Evaluation reports no functions found

Verify the module manifest is valid and the module loads successfully:

```powershell
Test-ModuleManifest -Path '.\MyModule.psd1'
Import-Module '.\MyModule.psd1' -Force -PassThru
```

### PSScriptAnalyzer rules not running

Confirm PSScriptAnalyzer is installed in the pipeline agent's PowerShell session:

```powershell
Get-Module -Name PSScriptAnalyzer -ListAvailable
```

### Coverage below threshold despite passing tests

Verify the `CodeCoverage.Path` in your Pester configuration points to `src/` not `tests/`. Coverage measures source files, not test files.

### Pipeline agent cannot install modules

Use a private feed or pre-install modules in a custom agent image. Alternatively, include the module files in the repository under a `lib/` directory and load them with `Import-Module` from a relative path.

---

## Related Resources

- [reference: Evaluation Automation API](reference-evaluation-automation-api.md)
- [how-to: Evaluate Module Compliance](how-to-evaluate-module-compliance.md)
- [explanation: Understanding the PSEval Compliance Methodology](explanation-evaluation-methodology.md)
- [Microsoft — Azure Pipelines Test Reporting](https://learn.microsoft.com/en-us/azure/devops/pipelines/test/review-continuous-test-results-after-build)
- [Microsoft — What is Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines)
- [GitHub Actions — Testing PowerShell](https://docs.github.com/en/actions/automating-builds-and-tests)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
- [Pester Documentation](https://pester.dev/docs/quick-start)
