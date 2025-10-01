# PowerShell Evaluation Automation Scripts and Tools

## Metadata

- **Document Type**: Evaluation Automation
- **Version**: 1.0.0
- **Last Updated**: 2025-08-24
- **Cross-References**: [Overview](PSEval-Standards-Overview.md) | [Methods](PSEval-Evaluation-Methods.md) | [Checklists](PSEval-Evaluation-Checklists.md)

## Executive Summary

This document provides automated tools and scripts for PowerShell module evaluation, enabling systematic assessment of standards compliance, code quality, and enterprise readiness through programmatic evaluation approaches.

## Core Automation Framework

### PSEval Module Structure

```powershell
# PSEval Module Manifest
@{
    RootModule = 'PSEval.psm1'
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'PowerShell Evaluation Framework'
    Description = 'Automated PowerShell module evaluation and standards compliance assessment'

    FunctionsToExport = @(
        'Invoke-PSEvaluation',
        'Test-PSModuleCompliance',
        'Get-PSEvalReport',
        'New-PSEvalConfiguration'
    )

    RequiredModules = @('PSScriptAnalyzer')
}
```

### Main Evaluation Engine

```powershell
function Invoke-PSEvaluation {
    <#
    .SYNOPSIS
    Performs comprehensive PowerShell module evaluation against established standards.

    .DESCRIPTION
    Executes automated evaluation of PowerShell modules including architecture analysis,
    code quality assessment, documentation validation, and compliance reporting.

    .PARAMETER Path
    Path to the module or repository to evaluate.

    .PARAMETER Level
    Evaluation level: Enterprise, Repository, Module, Function, or Component.

    .PARAMETER Standards
    Standards categories to evaluate: Architecture, Coding, Functions, Documentation,
    ErrorHandling, Testing, or All.

    .PARAMETER OutputPath
    Path for evaluation report output.

    .PARAMETER Configuration
    Custom evaluation configuration object.

    .EXAMPLE
    Invoke-PSEvaluation -Path 'C:\Modules\MyModule' -Level Module -Standards All

    .EXAMPLE
    Invoke-PSEvaluation -Path 'C:\Repository' -Level Repository -Standards @('Architecture', 'Coding') -OutputPath 'C:\Reports'
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter()]
        [ValidateSet('Enterprise', 'Repository', 'Module', 'Function', 'Component')]
        [string]$Level = 'Module',

        [Parameter()]
        [ValidateSet('Architecture', 'Coding', 'Functions', 'Documentation', 'ErrorHandling', 'Testing', 'All')]
        [string[]]$Standards = @('All'),

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [PSCustomObject]$Configuration
    )

    begin {
        Write-Verbose "Starting PSEval assessment for: $Path"
        $evaluationId = New-Guid
        $startTime = Get-Date

        # Load configuration
        if (-not $Configuration) {
            $Configuration = Get-PSEvalDefaultConfiguration -Level $Level
        }

        # Initialize results structure
        $results = [PSCustomObject]@{
            EvaluationId = $evaluationId
            Path = $Path
            Level = $Level
            Standards = $Standards
            StartTime = $startTime
            Results = @{}
            Summary = $null
        }
    }

    process {
        try {
            # Execute evaluations based on standards selection
            if ($Standards -contains 'All' -or $Standards -contains 'Architecture') {
                Write-Verbose \"Evaluating Architecture Standards\"
                $results.Results.Architecture = Test-PSArchitectureStandards -Path $Path -Configuration $Configuration.Architecture
            }

            if ($Standards -contains 'All' -or $Standards -contains 'Coding') {
                Write-Verbose \"Evaluating Coding Standards\"
                $results.Results.Coding = Test-PSCodingStandards -Path $Path -Configuration $Configuration.Coding
            }

            if ($Standards -contains 'All' -or $Standards -contains 'Functions') {
                Write-Verbose \"Evaluating Function Standards\"
                $results.Results.Functions = Test-PSFunctionStandards -Path $Path -Configuration $Configuration.Functions
            }

            if ($Standards -contains 'All' -or $Standards -contains 'Documentation') {
                Write-Verbose \"Evaluating Documentation Standards\"
                $results.Results.Documentation = Test-PSDocumentationStandards -Path $Path -Configuration $Configuration.Documentation
            }

            if ($Standards -contains 'All' -or $Standards -contains 'ErrorHandling') {
                Write-Verbose \"Evaluating Error Handling Standards\"
                $results.Results.ErrorHandling = Test-PSErrorHandlingStandards -Path $Path -Configuration $Configuration.ErrorHandling
            }

            if ($Standards -contains 'All' -or $Standards -contains 'Testing') {
                Write-Verbose \"Evaluating Testing Standards\"
                $results.Results.Testing = Test-PSTestingStandards -Path $Path -Configuration $Configuration.Testing
            }

            # Calculate summary scores
            $results.Summary = Calculate-PSEvalSummary -Results $results.Results -Configuration $Configuration

        }
        catch {
            Write-Error \"Evaluation failed: $($_.Exception.Message)\"
            throw
        }
    }

    end {
        $results.EndTime = Get-Date
        $results.Duration = $results.EndTime - $results.StartTime

        Write-Verbose \"Evaluation completed in $($results.Duration.TotalSeconds) seconds\"

        # Output results
        if ($OutputPath) {
            Export-PSEvalResults -Results $results -OutputPath $OutputPath
        }

        Write-Output $results
    }
}
```

## Standards-Specific Evaluation Functions

### Architecture Standards Evaluation

```powershell
function Test-PSArchitectureStandards {
    [CmdletBinding()]
    param(
        [string]$Path,
        [PSCustomObject]$Configuration
    )

    $results = [PSCustomObject]@{
        Standards = @{}
        Score = 0
        Issues = @()
    }

    # ARCH-001: Module Manifest Required
    $manifestPath = Get-ChildItem -Path $Path -Filter '*.psd1' | Select-Object -First 1
    if ($manifestPath) {
        $manifestValid = $null -ne (Test-ModuleManifest -Path $manifestPath.FullName -ErrorAction SilentlyContinue)
        $results.Standards['ARCH-001'] = [PSCustomObject]@{
            ID = 'ARCH-001'
            Name = 'Module Manifest Required'
            Status = if ($manifestValid) { 'Pass' } else { 'Fail' }
            Details = if ($manifestValid) { 'Valid manifest found' } else { 'Invalid or missing manifest' }
        }
    } else {
        $results.Standards['ARCH-001'] = [PSCustomObject]@{
            ID = 'ARCH-001'
            Name = 'Module Manifest Required'
            Status = 'Fail'
            Details = 'No module manifest (.psd1) file found'
        }
        $results.Issues += 'Missing module manifest file'
    }

    # ARCH-002: Standard Directory Structure
    $requiredDirs = @('Public', 'Tests', 'docs')
    $missingDirs = @()
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path (Join-Path $Path $dir))) {
            $missingDirs += $dir
        }
    }

    $results.Standards['ARCH-002'] = [PSCustomObject]@{
        ID = 'ARCH-002'
        Name = 'Standard Directory Structure'
        Status = if ($missingDirs.Count -eq 0) { 'Pass' } else { 'Fail' }
        Details = if ($missingDirs.Count -eq 0) { 'All required directories present' } else { \"Missing directories: $($missingDirs -join ', ')\" }
    }

    if ($missingDirs.Count -gt 0) {
        $results.Issues += \"Missing required directories: $($missingDirs -join ', ')\"
    }

    # Calculate architecture score
    $passCount = ($results.Standards.Values | Where-Object Status -eq 'Pass').Count
    $totalCount = $results.Standards.Count
    $results.Score = if ($totalCount -gt 0) { [Math]::Round(($passCount / $totalCount) * 100, 2) } else { 0 }

    return $results
}
```

### Coding Standards Evaluation

```powershell
function Test-PSCodingStandards {
    [CmdletBinding()]
    param(
        [string]$Path,
        [PSCustomObject]$Configuration
    )

    $results = [PSCustomObject]@{
        Standards = @{}
        Score = 0
        Issues = @()
    }

    # Get all PowerShell files
    $psFiles = Get-ChildItem -Path $Path -Recurse -Include '*.ps1', '*.psm1'

    foreach ($file in $psFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        # CODE-001: Microsoft Approved Verbs Only
        $functions = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
        $functionDefs = $functions.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

        $unapprovedVerbs = @()
        $approvedVerbs = (Get-Verb).Verb

        foreach ($func in $functionDefs) {
            if ($func.Name -match '^([A-Za-z]+)-') {
                $verb = $matches[1]
                if ($verb -notin $approvedVerbs) {
                    $unapprovedVerbs += \"$($func.Name) (verb: $verb)\"
                }
            }
        }

        if ($unapprovedVerbs.Count -gt 0) {
            $results.Issues += \"Unapproved verbs in $($file.Name): $($unapprovedVerbs -join ', ')\"
        }
    }

    # CODE-001 Standard Result
    $results.Standards['CODE-001'] = [PSCustomObject]@{
        ID = 'CODE-001'
        Name = 'Microsoft Approved Verbs Only'
        Status = if ($results.Issues.Count -eq 0) { 'Pass' } else { 'Fail' }
        Details = if ($results.Issues.Count -eq 0) { 'All functions use approved verbs' } else { \"$($results.Issues.Count) functions use unapproved verbs\" }
    }

    # PSScriptAnalyzer Integration
    $analyzerResults = Invoke-ScriptAnalyzer -Path $Path -Severity @('Error', 'Warning')
    $criticalIssues = $analyzerResults | Where-Object Severity -eq 'Error'

    $results.Standards['CODE-018'] = [PSCustomObject]@{
        ID = 'CODE-018'
        Name = 'Static Analysis Compliance'
        Status = if ($criticalIssues.Count -eq 0) { 'Pass' } else { 'Fail' }
        Details = \"PSScriptAnalyzer found $($criticalIssues.Count) critical issues\"
    }

    # Calculate coding score
    $passCount = ($results.Standards.Values | Where-Object Status -eq 'Pass').Count
    $totalCount = $results.Standards.Count
    $results.Score = if ($totalCount -gt 0) { [Math]::Round(($passCount / $totalCount) * 100, 2) } else { 0 }

    return $results
}
```

### Documentation Standards Evaluation

```powershell
function Test-PSDocumentationStandards {
    [CmdletBinding()]
    param(
        [string]$Path,
        [PSCustomObject]$Configuration
    )

    $results = [PSCustomObject]@{
        Standards = @{}
        Score = 0
        Issues = @()
    }

    # Import module to analyze functions
    $module = Import-Module $Path -PassThru -Force
    if (-not $module) {
        $results.Issues += 'Cannot import module for documentation analysis'
        return $results
    }

    try {
        $functions = Get-Command -Module $module.Name -CommandType Function

        $undocumentedFunctions = @()
        $insufficientHelp = @()

        foreach ($function in $functions) {
            $help = Get-Help $function.Name -ErrorAction SilentlyContinue

            if (-not $help -or [string]::IsNullOrEmpty($help.Synopsis) -or $help.Synopsis -eq $function.Name) {
                $undocumentedFunctions += $function.Name
            } elseif ([string]::IsNullOrEmpty($help.Description.Text) -or $help.Examples.Example.Count -eq 0) {
                $insufficientHelp += $function.Name
            }
        }

        # DOC-001: Comment-Based Help Required
        $results.Standards['DOC-001'] = [PSCustomObject]@{
            ID = 'DOC-001'
            Name = 'Comment-Based Help Required'
            Status = if ($undocumentedFunctions.Count -eq 0) { 'Pass' } else { 'Fail' }
            Details = if ($undocumentedFunctions.Count -eq 0) { 'All functions have comment-based help' } else { \"$($undocumentedFunctions.Count) functions lack proper help: $($undocumentedFunctions -join ', ')\" }
        }

        if ($undocumentedFunctions.Count -gt 0) {
            $results.Issues += \"Functions without proper help: $($undocumentedFunctions -join ', ')\"
        }

        # DOC-002: Help Content Quality
        $results.Standards['DOC-002'] = [PSCustomObject]@{
            ID = 'DOC-002'
            Name = 'Help Content Quality'
            Status = if ($insufficientHelp.Count -eq 0) { 'Pass' } else { 'Fail' }
            Details = if ($insufficientHelp.Count -eq 0) { 'All functions have quality help content' } else { \"$($insufficientHelp.Count) functions have insufficient help content\" }
        }

        if ($insufficientHelp.Count -gt 0) {
            $results.Issues += \"Functions with insufficient help: $($insufficientHelp -join ', ')\"
        }

    } finally {
        Remove-Module $module.Name -Force -ErrorAction SilentlyContinue
    }

    # Calculate documentation score
    $passCount = ($results.Standards.Values | Where-Object Status -eq 'Pass').Count
    $totalCount = $results.Standards.Count
    $results.Score = if ($totalCount -gt 0) { [Math]::Round(($passCount / $totalCount) * 100, 2) } else { 0 }

    return $results
}
```

## Reporting and Output Functions

### Results Export Function

```powershell
function Export-PSEvalResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Results,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('JSON', 'HTML', 'XML', 'CSV')]
        [string]$Format = 'JSON'
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $fileName = \"PSEval-Results-$timestamp\"

    switch ($Format) {
        'JSON' {
            $filePath = Join-Path $OutputPath \"$fileName.json\"
            $Results | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Encoding UTF8
        }
        'HTML' {
            $filePath = Join-Path $OutputPath \"$fileName.html\"
            $htmlReport = ConvertTo-PSEvalHTMLReport -Results $Results
            $htmlReport | Set-Content -Path $filePath -Encoding UTF8
        }
        'XML' {
            $filePath = Join-Path $OutputPath \"$fileName.xml\"
            $Results | ConvertTo-Xml -Depth 10 -As String | Set-Content -Path $filePath -Encoding UTF8
        }
        'CSV' {
            $filePath = Join-Path $OutputPath \"$fileName.csv\"
            $flattenedResults = ConvertTo-PSEvalFlatResults -Results $Results
            $flattenedResults | Export-Csv -Path $filePath -NoTypeInformation
        }
    }

    Write-Output \"Results exported to: $filePath\"
    return $filePath
}
```

### HTML Report Generation

```powershell
function ConvertTo-PSEvalHTMLReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Results
    )

    $html = @\"
<!DOCTYPE html>
<html>
<head>
    <title>PowerShell Evaluation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #2f4f4f; color: white; padding: 20px; border-radius: 5px; }
        .summary { background-color: #f0f8ff; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .standards { margin: 20px 0; }
        .standard { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .pass { border-left-color: #28a745; }
        .fail { border-left-color: #dc3545; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class=\"header\">
        <h1>PowerShell Evaluation Report</h1>
        <p>Path: $($Results.Path)</p>
        <p>Level: $($Results.Level)</p>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>

    <div class=\"summary\">
        <h2>Summary</h2>
        <p><strong>Overall Score:</strong> $($Results.Summary.OverallScore)%</p>
        <p><strong>Status:</strong> $($Results.Summary.Status)</p>
        <p><strong>Duration:</strong> $($Results.Duration.TotalSeconds) seconds</p>
    </div>

    <div class=\"standards\">
        <h2>Standards Results</h2>
\"@

    foreach ($category in $Results.Results.PSObject.Properties.Name) {
        $categoryResults = $Results.Results.$category
        $html += \"<h3>$category Standards (Score: $($categoryResults.Score)%)</h3>\"

        foreach ($standard in $categoryResults.Standards.PSObject.Properties.Value) {
            $statusClass = $standard.Status.ToLower()
            $html += @\"
            <div class=\"standard $statusClass\">
                <h4>$($standard.ID): $($standard.Name)</h4>
                <p><strong>Status:</strong> $($standard.Status)</p>
                <p><strong>Details:</strong> $($standard.Details)</p>
            </div>
\"@
        }
    }

    $html += @\"
    </div>
</body>
</html>
\"@

    return $html
}
```

## Configuration Management

### Default Configuration Generator

```powershell
function Get-PSEvalDefaultConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Enterprise', 'Repository', 'Module', 'Function', 'Component')]
        [string]$Level = 'Module'
    )

    $config = [PSCustomObject]@{
        Level = $Level
        Weights = @{
            Critical = 0.6
            Important = 0.3
            Recommended = 0.1
        }
        Thresholds = @{
            Pass = 75
            Excellence = 90
            CriticalMinimum = 80
        }
        Architecture = @{
            RequiredDirectories = @('Public', 'Tests', 'docs')
            OptionalDirectories = @('Private', 'Classes', 'Data')
            RequiredFiles = @('*.psd1', 'README.md')
        }
        Coding = @{
            MaxComplexity = 15
            MaxFunctionLength = 50
            RequireInputValidation = $true
        }
        Functions = @{
            RequireCmdletBinding = $true
            RequireHelp = $true
            RequireExamples = $true
            RequirePipelineSupport = $false
        }
        Documentation = @{
            RequireReadme = $true
            RequireChangelog = $true
            RequireExamples = $true
        }
        ErrorHandling = @{
            RequireTryCatch = $true
            RequireSpecificExceptions = $true
            RequireErrorRecords = $true
        }
        Testing = @{
            MinimumCoverage = 80
            RequireUnitTests = $true
            RequireIntegrationTests = $false
        }
    }

    return $config
}
```

### Custom Configuration Support

```powershell
function New-PSEvalConfiguration {
    <#
    .SYNOPSIS
    Creates a custom evaluation configuration for specific organizational needs.

    .DESCRIPTION
    Generates customizable evaluation configuration that can be modified for
    specific organizational standards and requirements.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigurationName = 'Custom',

        [Parameter()]
        [hashtable]$CustomWeights,

        [Parameter()]
        [hashtable]$CustomThresholds,

        [Parameter()]
        [string]$OutputPath
    )

    $config = Get-PSEvalDefaultConfiguration

    if ($CustomWeights) {
        foreach ($key in $CustomWeights.Keys) {
            $config.Weights.$key = $CustomWeights[$key]
        }
    }

    if ($CustomThresholds) {
        foreach ($key in $CustomThresholds.Keys) {
            $config.Thresholds.$key = $CustomThresholds[$key]
        }
    }

    $config | Add-Member -Name 'ConfigurationName' -Value $ConfigurationName -MemberType NoteProperty

    if ($OutputPath) {
        $config | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Output \"Configuration saved to: $OutputPath\"
    }

    return $config
}
```

## CI/CD Pipeline Integration

### Azure DevOps Pipeline Integration

```yaml
# azure-pipelines.yml
trigger:
  - main
  - develop

pool:
  vmImage: 'windows-latest'

steps:
  - task: PowerShell@2
    displayName: 'Install PSEval Module'
    inputs:
      targetType: 'inline'
      script: |
        Install-Module PSEval -Force -Scope CurrentUser
        Import-Module PSEval

  - task: PowerShell@2
    displayName: 'Run PowerShell Evaluation'
    inputs:
      targetType: 'inline'
      script: |
        $results = Invoke-PSEvaluation -Path '$(Build.SourcesDirectory)' -Level Repository -Standards All

        # Export results for artifact
        Export-PSEvalResults -Results $results -OutputPath '$(Build.ArtifactStagingDirectory)' -Format HTML
        Export-PSEvalResults -Results $results -OutputPath '$(Build.ArtifactStagingDirectory)' -Format JSON

        # Fail build if quality gates not met
        if ($results.Summary.Status -ne 'Pass') {
          Write-Host \"##vso[task.logissue type=error]Evaluation failed: $($results.Summary.Status)\"
          exit 1
        }

  - task: PublishBuildArtifacts@1
    displayName: 'Publish Evaluation Results'
    inputs:
      PathtoPublish: '$(Build.ArtifactStagingDirectory)'
      ArtifactName: 'PSEvalResults'
```

### GitHub Actions Integration

```yaml
# .github/workflows/pslint.yml
name: PowerShell Evaluation

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  evaluate:
    runs-on: windows-latest

    steps:
      - uses: actions/checkout@v3

      - name: Install PSEval Module
        shell: pwsh
        run: |
          Install-Module PSEval -Force -Scope CurrentUser
          Import-Module PSEval

      - name: Run PowerShell Evaluation
        shell: pwsh
        run: |
          $results = Invoke-PSEvaluation -Path '${{ github.workspace }}' -Level Repository -Standards All

          Export-PSEvalResults -Results $results -OutputPath 'results' -Format HTML
          Export-PSEvalResults -Results $results -OutputPath 'results' -Format JSON

          if ($results.Summary.Status -ne 'Pass') {
            Write-Error \"Evaluation failed: $($results.Summary.Status)\"
            exit 1
          }

      - name: Upload Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: evaluation-results
          path: results/
```

## Usage Examples

### Basic Module Evaluation

```powershell
# Simple module evaluation
$results = Invoke-PSEvaluation -Path 'C:\MyModule' -Level Module -Standards All

# View summary
$results.Summary

# Export detailed report
Export-PSEvalResults -Results $results -OutputPath 'C:\Reports' -Format HTML
```

### Enterprise-Wide Assessment

```powershell
# Evaluate multiple repositories
$repositories = @(
    'C:\Source\UserManagement',
    'C:\Source\DeviceManagement',
    'C:\Source\SecurityTools'
)

$enterpriseResults = @()
foreach ($repo in $repositories) {
    $result = Invoke-PSEvaluation -Path $repo -Level Repository -Standards All
    $enterpriseResults += $result
}

# Aggregate enterprise metrics
$overallCompliance = ($enterpriseResults.Summary.OverallScore | Measure-Object -Average).Average
Write-Host \"Enterprise-wide compliance: $overallCompliance%\"
```

### Custom Configuration Usage

```powershell
# Create custom configuration with stricter requirements
$customConfig = New-PSEvalConfiguration -ConfigurationName 'Strict' -CustomThresholds @{
    Pass = 85
    Excellence = 95
    CriticalMinimum = 90
}

# Use custom configuration for evaluation
$results = Invoke-PSEvaluation -Path 'C:\CriticalModule' -Configuration $customConfig
```

---

_These automation scripts provide comprehensive PowerShell module evaluation capabilities. Customize and extend based on specific organizational requirements and standards._
