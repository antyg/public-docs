---
title: "PowerShell Coding Standards and Conventions"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Code Reviewers"
document_type: "reference"
domain: "development"
---

# PowerShell Coding Standards and Conventions

31 coding standards governing the implementation requirements for PowerShell code — naming conventions, variable management, flow control, performance optimisation, and security practices. Derived from [Microsoft's PowerShell coding standards](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) and the [PSScriptAnalyzer rule set](https://github.com/PowerShell/PSScriptAnalyzer).

---

## Naming Convention Standards

### CODE-001: Microsoft Approved Verbs Only

**Category**: Critical | **Scope**: Function, Module, Repository, Enterprise

All PowerShell functions must use only [Microsoft-approved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) to ensure ecosystem consistency.

**Requirements:**

- Function names must begin with an approved PowerShell verb
- Verb must appear in `Get-Verb` output or Microsoft-approved extensions
- No custom or non-standard verbs permitted
- Verb usage must align with intended function behaviour

**Compliance criteria:**

- [ ] Function verb appears in `Get-Verb` output
- [ ] Verb semantically matches function behaviour
- [ ] No deprecated or non-standard verbs used

```powershell
# Compliant — approved verbs
Get-UserAccount     # 'Get' — data retrieval
Set-UserPassword    # 'Set' — property modification
New-UserProfile     # 'New' — object creation
Remove-UserAccount  # 'Remove' — deletion

# Non-compliant — unapproved verbs
Fetch-UserAccount   # Use 'Get'
Create-UserProfile  # Use 'New'
Delete-UserAccount  # Use 'Remove'
Display-UserInfo    # Use 'Show'
```

---

### CODE-002: Verb-Noun Naming Pattern

**Category**: Critical | **Scope**: Function, Module, Repository

PowerShell functions must follow the `Verb-Noun` naming pattern with specific formatting requirements.

**Requirements:**

- Function names use `Verb-Noun` pattern separated by hyphen
- Both verb and noun use PascalCase capitalisation
- Nouns are singular, not plural
- Compound nouns use PascalCase without separators
- Organisational prefixes included when appropriate (e.g., `Get-SimaApplication`)

**Compliance criteria:**

- [ ] Function follows `Verb-Noun` pattern with hyphen
- [ ] Both verb and noun use PascalCase
- [ ] Noun is singular
- [ ] Compound nouns properly formatted
- [ ] Organisational prefix included when required

```powershell
# Compliant
Get-UserAccount          # Singular noun, PascalCase
Set-DatabaseConnection   # Compound noun
Remove-EmailAddress      # Singular noun

# Non-compliant
Get-UserAccounts        # Plural noun
get-userAccount         # Incorrect capitalisation
Get_User_Account        # Underscores instead of PascalCase
GetUserAccount          # Missing hyphen
```

---

### CODE-003: Variable Naming Standards

**Category**: Important | **Scope**: Function, Script

Variables must follow consistent naming conventions indicating purpose and scope.

**Requirements:**

- Local and parameter variables use `camelCase`
- Script-scoped variables use `$script:` prefix
- Global variables use `$global:` prefix with descriptive names
- Boolean variables use descriptive predicates (`Is`, `Has`, `Can`, `Should`)
- Collection variables use plural nouns

**Compliance criteria:**

- [ ] Local variables use camelCase
- [ ] Script-scoped variables properly prefixed
- [ ] Boolean variables use descriptive predicates
- [ ] Collection variables appropriately named
- [ ] Variable names are descriptive and meaningful

```powershell
# Compliant
$userName              = 'jdoe'          # camelCase for local
$script:moduleConfig   = @{}             # Script scope prefix
$isUserEnabled         = $true           # Boolean predicate
$userAccounts          = @()             # Plural for collection

# Non-compliant
$UserName              = 'jdoe'          # Should be camelCase
$module_config         = @{}             # Underscores, missing scope
$userEnabled           = $true           # Missing boolean predicate
$account               = @()             # Singular for collection
$cs                    = 'Server=...'    # Non-descriptive abbreviation
```

---

### CODE-004: Parameter Naming Consistency

**Category**: Important | **Scope**: Function, Module

Function parameters must use standardised names consistent with PowerShell conventions.

**Requirements:**

- Standard parameter names used consistently (`Name`, `Path`, `ComputerName`, `Credential`)
- Parameters use PascalCase capitalisation
- Boolean parameters use `[switch]` type with descriptive names
- Collection parameters use singular names but accept arrays
- Alternative parameter names provided through `[Alias()]` attribute

**Compliance criteria:**

- [ ] Standard parameter names used consistently
- [ ] Parameters use PascalCase
- [ ] Switch parameters descriptively named
- [ ] Aliases provided for common alternative names

```powershell
# Compliant
param(
    [Parameter(Mandatory)]
    [string]$ComputerName,                       # Standard name

    [Parameter()]
    [Alias('UserName', 'Identity')]
    [string]$Name,                               # Standard with aliases

    [Parameter()]
    [switch]$Force,                              # Standard switch name

    [Parameter()]
    [PSCredential]$Credential                    # Standard credential parameter
)
```

---

### CODE-005: File and Directory Naming

**Category**: Important | **Scope**: Module, Repository

- PowerShell files use `.ps1`, `.psm1`, `.psd1` extensions appropriately
- Function files named exactly as the contained function
- Directory names use PascalCase without spaces or special characters
- Test files include `.Tests.ps1` suffix
- Documentation files use standard names (`README.md`, `CHANGELOG.md`)

---

## Variable Scope and Context Standards

### CODE-006: Scope Management

**Category**: Important | **Scope**: Function, Module

- Script-scoped variables explicitly declared with `$script:` prefix
- Global variables used sparingly and explicitly prefixed
- Local variables contained within function scope
- Module-level variables properly initialised and managed
- Scope pollution avoided through proper variable containment

---

### CODE-007: Variable Initialisation

**Category**: Important | **Scope**: Function, Script

- Variables initialised before use
- Default values provided for optional parameters
- Collections initialised as empty arrays (`@()`) or lists (`[System.Collections.Generic.List[T]]::new()`)
- Boolean variables explicitly set to `$true` or `$false`
- Null checks implemented before variable usage in critical paths

---

## Flow Control Standards

### CODE-008: Conditional Logic Patterns

**Category**: Important | **Scope**: Function, Script

- `if-elseif-else` preferred over deeply nested `if` statements
- `switch` statements used for multiple discrete conditions
- Early return patterns used to reduce nesting
- Complex conditions broken into readable named segments

```powershell
# Compliant — switch for multiple conditions
switch ($OutputFormat) {
    'JSON' { ConvertTo-Json $Data }
    'XML'  { ConvertTo-Xml $Data }
    'CSV'  { ConvertTo-Csv $Data }
    default { Write-Error "Unsupported format: $OutputFormat" }
}
```

---

### CODE-009: Loop Construction Standards

**Category**: Important | **Scope**: Function, Script

- `ForEach-Object` used for pipeline processing
- `foreach` statements used for array iteration
- `while`/`do-while` for condition-based iteration
- `for` loops for counter-based iteration
- `break` and `continue` used appropriately

```powershell
# Compliant — efficient pipeline processing
$users | ForEach-Object {
    Get-UserDetails -Identity $_.SamAccountName
}

# Compliant — array iteration
foreach ($computer in $computerList) {
    Test-Connection -ComputerName $computer
}
```

---

## Performance Standards

### CODE-010: Memory Management

**Category**: Important | **Scope**: Function, Module

- Large objects disposed explicitly when no longer needed
- Collections use `[System.Collections.Generic.List[T]]` for performance over `@()` accumulation
- String concatenation uses efficient methods for multiple operations
- Pipeline processing preferred over array accumulation
- Temporary files and connections cleaned up

```powershell
# Compliant — efficient collection
$results = [System.Collections.Generic.List[PSCustomObject]]::new()
foreach ($item in $inputData) {
    $results.Add((Process-Item $item))
}

# Non-compliant — inefficient array accumulation (creates new array per iteration)
$results = @()
foreach ($item in $inputData) {
    $results += Process-Item $item
}
```

---

### CODE-011: Algorithm Efficiency

**Category**: Important | **Scope**: Function

- O(n) or better complexity for data processing where possible
- Lookup operations use hashtables for O(1) performance
- Batch processing used for large datasets
- Expensive operations cached when appropriate
- Parallel processing considered for CPU-intensive tasks

---

### CODE-012: Resource Usage Optimisation

**Category**: Important | **Scope**: Function, Module

File handles opened and closed promptly. Network connections managed efficiently. External processes properly started and terminated. Registry keys closed after use. Temporary resources cleaned up automatically.

---

## Security Standards

### CODE-013: Credential Handling

**Category**: Critical | **Scope**: Function, Module, Enterprise

Credentials and sensitive data must be handled securely throughout the application lifecycle. See [Microsoft guidance on credential security](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential).

**Requirements:**

- `[PSCredential]` objects used for credential parameters
- `[SecureString]` used for password storage and transmission
- No plaintext passwords in code or logs
- Credential validation performed before use
- Credentials not retained in variables longer than necessary

**Compliance criteria:**

- [ ] `PSCredential` objects used for credentials
- [ ] `SecureString` used for passwords
- [ ] No plaintext credentials in code
- [ ] Credential validation implemented
- [ ] Credential lifetime minimised

```powershell
# Compliant
param(
    [Parameter()]
    [PSCredential]$Credential = [PSCredential]::Empty
)

if ($Credential -eq [PSCredential]::Empty) {
    $Credential = Get-Credential -Message "Enter credentials"
}

# Non-compliant — plaintext password parameter
param(
    [string]$Password    # Never use plaintext password parameters
)
Write-Verbose "Connecting with password: $Password"  # Never log credentials
```

---

### CODE-014: Input Validation and Sanitisation

**Category**: Critical | **Scope**: Function, Script

All user input must be validated and sanitised to prevent security vulnerabilities and ensure data integrity.

**Requirements:**

- [Parameter validation attributes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters) used extensively
- Input data validated against expected formats
- Special characters escaped or rejected appropriately
- File paths validated before use
- SQL injection and command injection prevention implemented

**Compliance criteria:**

- [ ] Parameter validation attributes present
- [ ] Input format validation implemented
- [ ] Special character handling appropriate
- [ ] File path validation performed
- [ ] Injection attack prevention implemented

```powershell
# Compliant — comprehensive input validation
param(
    [Parameter(Mandatory)]
    [ValidateLength(1, 50)]
    [ValidatePattern('^[a-zA-Z0-9._-]+$')]
    [string]$UserName,

    [Parameter()]
    [ValidateScript({
        if (Test-Path $_ -PathType Container) { $true }
        else { throw "Path must be a valid directory" }
    })]
    [string]$OutputPath
)
```

---

### CODE-015: Data Protection Standards

**Category**: Important | **Scope**: Function, Module

Sensitive data encrypted when stored. Secure transmission protocols used for network operations. Data sanitised before logging or output. Temporary files containing sensitive data protected. Memory containing sensitive data cleared when possible.

---

## Code Quality Standards

### CODE-016: Code Readability

**Category**: Important | **Scope**: Function, Script

- Consistent indentation using 4 spaces per level
- Logical code organisation with clear separation of concerns
- Meaningful variable and function names
- Comments used to explain complex logic
- Code blocks properly formatted and spaced

---

### CODE-017: Code Reusability

**Category**: Important | **Scope**: Function, Module

- Functions designed for single responsibility
- Hard-coded values externalised as parameters
- Dependencies minimised and clearly declared
- Common functionality extracted to shared functions
- Platform and environment assumptions avoided

---

### CODE-018: Static Analysis Compliance

**Category**: Important | **Scope**: Function, Module, Repository

Modules must pass [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) without violations that impact quality or security. Custom organisational rules must be satisfied. Security-focused analysis rules addressed. Performance-related warnings resolved.

---

## Advanced Coding Patterns

### CODE-019: Object-Oriented Patterns

**Category**: Recommended | **Scope**: Function, Module

Custom objects created with meaningful type names. Object methods implemented for complex behaviours. Inheritance used appropriately for related object types. Encapsulation maintained.

---

### CODE-020: Design Pattern Implementation

**Category**: Recommended | **Scope**: Module

Factory patterns for object creation. Observer patterns for event handling. Strategy patterns for algorithm selection. Decorator patterns for functionality extension. Singleton patterns for shared resources.

---

## Configuration and Environment Standards

### CODE-021: Configuration Management

**Category**: Important | **Scope**: Module, Repository

Configuration values externalised from code. Environment-specific configuration supported. Configuration validation implemented. Default configuration values provided. Configuration changes tracked and versioned.

---

### CODE-022: Environment Detection

**Category**: Important | **Scope**: Function, Module

- [PowerShell version detection](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables) and handling (`$PSVersionTable`)
- Operating system detection when relevant (`$IsWindows`, `$IsLinux`, `$IsMacOS`)
- Execution context awareness (ISE, console, automation)
- Module dependency availability checking
- Network connectivity assessment when required

---

## Integration Standards

### CODE-023: API Integration Patterns

**Category**: Important | **Scope**: Function, Module

REST API calls use appropriate HTTP methods. Authentication handled securely and consistently. Rate limiting and throttling implemented. Error handling specific to API responses. Response data validation performed.

---

### CODE-024: Database Integration Standards

**Category**: Important | **Scope**: Function, Module

Parameterised queries used to prevent SQL injection. Connection strings secured and managed. Database connections opened and closed efficiently. Transaction handling implemented for data integrity. Database-specific error handling implemented.

---

## Logging and Monitoring Standards

### CODE-025: Logging Implementation

**Category**: Important | **Scope**: Function, Module

- Structured logging format used consistently
- Log levels implemented appropriately (`Write-Error`, `Write-Warning`, `Write-Information`, `Write-Verbose`, `Write-Debug`)
- Sensitive data excluded from logs
- Log rotation and management considered
- Performance impact of logging minimised

---

### CODE-026: Performance Monitoring

**Category**: Recommended | **Scope**: Function, Module

Execution time measurement for critical operations. Memory usage monitoring for resource-intensive functions. Performance metrics exposed through standard interfaces. Performance thresholds defined and monitored.

---

## Compatibility Standards

### CODE-027: PowerShell Version Compatibility

**Category**: Important | **Scope**: Module, Repository

- Minimum PowerShell version specified in manifest (`PowerShellVersion`)
- Version-specific features used conditionally (`$PSVersionTable.PSVersion.Major`)
- Compatibility testing performed across target versions
- Alternative implementations provided for version differences
- Version compatibility documented clearly

Note: PowerShell 5.1 (Windows PowerShell) and PowerShell 7+ (PowerShell Core) have significant differences. Modules targeting both must account for behaviour differences in error handling, parallel processing (`ForEach-Object -Parallel`), and ternary operators.

---

### CODE-028: Cross-Platform Considerations

**Category**: Recommended | **Scope**: Module, Repository

Platform-specific code isolated and conditional. File path operations use platform-appropriate separators (`[System.IO.Path]::Combine()`). Use [CIM cmdlets](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/) instead of deprecated WMI cmdlets where possible. Platform limitations documented clearly.

---

## Maintenance and Evolution Standards

### CODE-029: Code Versioning Integration

**Category**: Important | **Scope**: Function, Module, Repository

Meaningful commit messages following organisational standards. Code changes aligned with semantic versioning principles. Breaking changes clearly identified and documented. Backward compatibility maintained within major versions. Migration paths provided for breaking changes.

---

### CODE-030: Refactoring Support

**Category**: Recommended | **Scope**: Function, Module

Modular design supports component replacement. Dependencies minimised to reduce refactoring impact. Interface consistency maintained during refactoring. Automated tests protect against regression.

---

### CODE-031: Technical Debt Management

**Category**: Important | **Scope**: Module, Repository, Enterprise

Code quality metrics tracked over time. Technical debt items identified and prioritised. Remediation plans created for significant debt. Quality gates prevent code quality degradation. Technical debt impact on maintenance documented.

---

## Related Resources

- [Microsoft — Approved Verbs for PowerShell Commands](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [Microsoft — about_Functions_Advanced_Parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters)
- [Microsoft — Get-Credential](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential)
- [Microsoft — CIM Cmdlets](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/)
- [PSScriptAnalyzer Rules Reference](https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/README.md)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [standards-overview.md](standards-overview.md)
- [standards-architecture.md](standards-architecture.md)
- [standards-functions.md](standards-functions.md)
