# PowerShell Coding Standards and Conventions

## Metadata

- **Document Type**: Coding Standards
- **Version**: 1.0.0
- **Last Updated**: 2025-08-24
- **Standards Count**: 31 Coding Standards
- **Cross-References**: [Overview](PSEval-Standards-Overview.md) | [Architecture](PSEval-Standards-Architecture.md) | [Functions](PSEval-Standards-Functions.md)

## Executive Summary

Coding standards define the implementation requirements for PowerShell code including naming conventions, variable management, flow control patterns, performance optimization, and security practices. These standards ensure code consistency, maintainability, and enterprise compliance.

## Naming Convention Standards

### CODE-001: Microsoft Approved Verbs Only

**Category**: Critical
**Level**: Function, Module, Repository, Enterprise
**Cross-References**: [FUNC-001](PSEval-Standards-Functions.md#FUNC-001)

#### Description

All PowerShell functions must use only Microsoft-approved verbs to ensure consistency across the PowerShell ecosystem.

#### Explicit Standard Definition

- Function names must begin with approved PowerShell verb
- Verb must be from Get-Verb output or Microsoft-approved extensions
- No custom or non-standard verbs permitted
- Verb usage must align with intended function behavior

#### Evaluation Methods

##### Enterprise Level

- Organization-wide verb compliance scanning
- Custom verb detection and reporting
- Verb usage pattern analysis

##### Function Level

- Individual function name validation against Get-Verb
- Verb appropriateness assessment for function behavior
- Alternative approved verb recommendations

#### Compliance Criteria

- [ ] Function verb appears in Get-Verb output
- [ ] Verb semantically matches function behavior
- [ ] No deprecated or non-standard verbs used
- [ ] Verb follows Microsoft verb guidelines

#### Examples

```powershell
# Good examples - Approved verbs
Get-UserAccount     # 'Get' is approved for data retrieval
Set-UserPassword    # 'Set' is approved for property modification
New-UserProfile     # 'New' is approved for object creation
Remove-UserAccount  # 'Remove' is approved for deletion

# Bad examples - Non-approved verbs
Fetch-UserAccount   # 'Fetch' not approved, use 'Get'
Create-UserProfile  # 'Create' not approved, use 'New'
Delete-UserAccount  # 'Delete' not approved, use 'Remove'
Display-UserInfo    # 'Display' not approved, use 'Show'
```

### CODE-002: Verb-Noun Naming Pattern

**Category**: Critical
**Level**: Function, Module, Repository
**Cross-References**: [CODE-001](#CODE-001)

#### Description

PowerShell functions must follow the Verb-Noun naming pattern with specific formatting requirements.

#### Explicit Standard Definition

- Function names use Verb-Noun pattern separated by hyphen
- Verbs and nouns use PascalCase capitalization
- Nouns are singular, not plural
- Compound nouns use PascalCase without separators
- Organizational prefixes included when appropriate

#### Evaluation Methods

##### Function Level

- Function name pattern validation
- Capitalization compliance verification
- Singular vs plural noun analysis
- Organizational prefix consistency checking

#### Compliance Criteria

- [ ] Function follows Verb-Noun pattern with hyphen separation
- [ ] Both verb and noun use PascalCase
- [ ] Noun is singular form
- [ ] Compound nouns properly formatted
- [ ] Organizational prefix included when required

#### Examples

```powershell
# Good examples - Proper Verb-Noun pattern
Get-UserAccount          # Singular noun, PascalCase
Set-DatabaseConnection   # Compound noun, PascalCase
New-SecurityPolicy       # Proper prefix integration
Remove-EmailAddress      # Singular noun

# Bad examples - Incorrect patterns
Get-UserAccounts        # Plural noun should be singular
get-userAccount         # Incorrect capitalization
Get_User_Account        # Underscores instead of PascalCase
GetUserAccount          # Missing hyphen separator
```

### CODE-003: Variable Naming Standards

**Category**: Important
**Level**: Function, Script
**Cross-References**: [CODE-004](#CODE-004)

#### Description

Variables must follow consistent naming conventions that clearly indicate their purpose and scope.

#### Explicit Standard Definition

- Variables use camelCase for local and parameter variables
- Script-scoped variables use $script: prefix
- Global variables use $global: prefix and descriptive names
- Boolean variables use descriptive predicates (Is, Has, Can, Should)
- Collection variables use plural nouns

#### Evaluation Methods

##### Function Level

- Variable naming pattern analysis
- Scope prefix compliance verification
- Boolean variable naming assessment
- Collection variable naming validation

#### Compliance Criteria

- [ ] Local variables use camelCase
- [ ] Script-scoped variables properly prefixed
- [ ] Boolean variables use descriptive predicates
- [ ] Collection variables appropriately named
- [ ] Variable names are descriptive and meaningful

#### Examples

```powershell
# Good examples - Proper variable naming
$userName = 'jdoe'                    # camelCase for local
$script:moduleConfiguration = @{}      # Script scope prefix
$isUserEnabled = $true                # Boolean predicate
$userAccounts = @()                   # Plural for collection
$connectionString = 'Server=...'      # Descriptive name

# Bad examples - Incorrect naming
$UserName = 'jdoe'                    # Should be camelCase
$module_config = @{}                  # Underscores, missing scope
$userEnabled = $true                  # Missing boolean predicate
$account = @()                        # Singular for collection
$cs = 'Server=...'                    # Non-descriptive abbreviation
```

### CODE-004: Parameter Naming Consistency

**Category**: Important
**Level**: Function, Module
**Cross-References**: [FUNC-003](PSEval-Standards-Functions.md#FUNC-003)

#### Description

Function parameters must use standardized names that are consistent across modules and align with PowerShell conventions.

#### Explicit Standard Definition

- Standard parameter names used consistently (Name, Path, ComputerName, Credential)
- Parameters use PascalCase capitalization
- Boolean parameters use Switch type with descriptive names
- Collection parameters use singular names but accept arrays
- Alternative parameter names provided through Alias attribute

#### Evaluation Methods

##### Module Level

- Cross-function parameter name consistency analysis
- Standard parameter usage verification
- Parameter naming convention compliance

#### Compliance Criteria

- [ ] Standard parameter names used consistently
- [ ] Parameters use PascalCase capitalization
- [ ] Switch parameters descriptively named
- [ ] Aliases provided for common alternative names
- [ ] Parameter names align with PowerShell conventions

#### Examples

```powershell
# Good examples - Standard parameter naming
param(
    [Parameter(Mandatory)]
    [string]$ComputerName,           # Standard name

    [Parameter()]
    [Alias('UserName', 'Identity')]
    [string]$Name,                   # Standard with aliases

    [Parameter()]
    [switch]$Force,                  # Standard switch name

    [Parameter()]
    [PSCredential]$Credential        # Standard credential parameter
)

# Bad examples - Non-standard naming
param(
    [string]$computer,               # Should be ComputerName
    [string]$user_name,             # Underscores, should be Name
    [switch]$override,              # Should be Force
    [PSCredential]$creds            # Should be Credential
)
```

### CODE-005: File and Directory Naming

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [ARCH-008](PSEval-Standards-Architecture.md#ARCH-008)

#### Description

Files and directories must follow consistent naming conventions that support organization and automation.

#### Explicit Standard Definition

- PowerShell files use .ps1, .psm1, .psd1 extensions appropriately
- Function files named exactly as contained function
- Directory names use PascalCase without spaces or special characters
- Test files include .Tests.ps1 suffix for identification
- Documentation files use standard names (README.md, CHANGELOG.md)

#### Evaluation Methods

##### Module Level

- File extension compliance verification
- File-to-function name mapping validation
- Directory naming convention assessment
- Test file naming pattern verification

#### Compliance Criteria

- [ ] Appropriate file extensions used
- [ ] Function files match contained function names
- [ ] Directory names follow PascalCase convention
- [ ] Test files properly suffixed
- [ ] Documentation files use standard names

## Variable Scope and Context Standards

### CODE-006: Scope Management

**Category**: Important
**Level**: Function, Module
**Cross-References**: [CODE-003](#CODE-003)

#### Description

Variable scope must be explicitly managed to prevent unintended side effects and maintain code reliability.

#### Explicit Standard Definition

- Script-scoped variables explicitly declared with $script: prefix
- Global variables used sparingly and explicitly prefixed
- Local variables contained within function scope
- Module-level variables properly initialized and managed
- Scope pollution avoided through proper variable containment

#### Evaluation Methods

##### Function Level

- Variable scope declaration analysis
- Global variable usage assessment
- Scope pollution detection

#### Compliance Criteria

- [ ] Script-scoped variables explicitly prefixed
- [ ] Global variables justified and properly prefixed
- [ ] Local variables properly contained
- [ ] No unintended scope pollution
- [ ] Module variables appropriately managed

### CODE-007: Variable Initialization

**Category**: Important
**Level**: Function, Script
**Cross-References**: [ERR-002](PSEval-Standards-ErrorHandling.md#ERR-002)

#### Description

Variables must be properly initialized to prevent runtime errors and ensure predictable behavior.

#### Explicit Standard Definition

- Variables initialized before use
- Default values provided for optional parameters
- Collections initialized as empty arrays or hashtables when applicable
- Boolean variables explicitly set to $true or $false
- Null checks implemented before variable usage in critical paths

#### Evaluation Methods

##### Function Level

- Variable initialization pattern analysis
- Uninitialized variable usage detection
- Default value implementation verification

#### Compliance Criteria

- [ ] Variables initialized before use
- [ ] Default values provided appropriately
- [ ] Collections properly initialized
- [ ] Boolean variables explicitly set
- [ ] Null checks implemented where needed

## Flow Control Standards

### CODE-008: Conditional Logic Patterns

**Category**: Important
**Level**: Function, Script
**Cross-References**: [CODE-009](#CODE-009)

#### Description

Conditional statements must follow consistent patterns that enhance readability and maintainability.

#### Explicit Standard Definition

- If-elseif-else statements preferred over nested if statements
- Switch statements used for multiple discrete conditions
- Boolean conditions use explicit comparisons where appropriate
- Complex conditions broken into readable segments
- Early return patterns used to reduce nesting

#### Evaluation Methods

##### Function Level

- Conditional logic complexity analysis
- Nesting depth assessment
- Boolean condition clarity evaluation

#### Compliance Criteria

- [ ] Appropriate conditional constructs selected
- [ ] Excessive nesting avoided
- [ ] Boolean conditions clearly expressed
- [ ] Complex conditions properly structured
- [ ] Early return patterns used effectively

#### Examples

```powershell
# Good example - Clear conditional structure
if ($UserStatus -eq 'Active') {
    Enable-UserAccount -Identity $UserName
}
elseif ($UserStatus -eq 'Disabled') {
    Disable-UserAccount -Identity $UserName
}
else {
    Write-Warning "Unknown user status: $UserStatus"
    return
}

# Good example - Switch for multiple conditions
switch ($OutputFormat) {
    'JSON' { ConvertTo-Json $Data }
    'XML'  { ConvertTo-Xml $Data }
    'CSV'  { ConvertTo-Csv $Data }
    default { Write-Error "Unsupported format: $OutputFormat" }
}

# Bad example - Excessive nesting
if ($User) {
    if ($User.Enabled) {
        if ($User.Department -eq 'IT') {
            if ($User.Role -eq 'Admin') {
                # Deep nesting makes code hard to follow
            }
        }
    }
}
```

### CODE-009: Loop Construction Standards

**Category**: Important
**Level**: Function, Script
**Cross-References**: [CODE-010](#CODE-010)

#### Description

Loop constructs must be chosen appropriately and implemented efficiently for the specific use case.

#### Explicit Standard Definition

- ForEach-Object used for pipeline processing
- foreach loops used for array iteration
- while/do-while loops used for condition-based iteration
- for loops used for counter-based iteration
- Break and Continue used appropriately for flow control

#### Evaluation Methods

##### Function Level

- Loop construct appropriateness assessment
- Loop efficiency evaluation
- Flow control usage validation

#### Compliance Criteria

- [ ] Appropriate loop construct selected for use case
- [ ] Efficient iteration patterns implemented
- [ ] Break and Continue used properly
- [ ] Loop termination conditions clearly defined
- [ ] Performance considerations addressed

#### Examples

```powershell
# Good example - Pipeline processing with ForEach-Object
$users | ForEach-Object {
    Get-UserDetails -Identity $_.SamAccountName
}

# Good example - Array iteration with foreach
foreach ($computer in $computerList) {
    Test-Connection -ComputerName $computer
}

# Good example - Conditional loop with while
while ($retryCount -lt $maxRetries -and -not $success) {
    $success = Invoke-Operation
    $retryCount++
}

# Bad example - Inefficient pipeline usage
$results = @()
$users | ForEach-Object {
    $results += Get-UserDetails -Identity $_.SamAccountName
}
# Should use pipeline output directly
```

## Performance Standards

### CODE-010: Memory Management

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ARCH-017](PSEval-Standards-Architecture.md#ARCH-017)

#### Description

Code must implement efficient memory management patterns to prevent memory leaks and optimize performance.

#### Explicit Standard Definition

- Large objects disposed explicitly when no longer needed
- Collections use appropriate .NET types for performance
- String concatenation uses efficient methods for multiple operations
- Pipeline processing preferred over array accumulation
- Temporary files and connections cleaned up properly

#### Evaluation Methods

##### Function Level

- Memory usage pattern analysis
- Resource disposal verification
- Collection usage efficiency assessment
- String manipulation pattern evaluation

#### Compliance Criteria

- [ ] Large objects explicitly disposed
- [ ] Efficient collection types used
- [ ] String operations optimized
- [ ] Pipeline processing utilized
- [ ] Resources properly cleaned up

#### Examples

```powershell
# Good example - Efficient collection usage
$results = New-Object System.Collections.Generic.List[PSCustomObject]
foreach ($item in $inputData) {
    $results.Add((Process-Item $item))
}

# Good example - Resource disposal
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    # Use connection
}
finally {
    if ($connection) {
        $connection.Dispose()
    }
}

# Bad example - Inefficient array accumulation
$results = @()
foreach ($item in $inputData) {
    $results += Process-Item $item  # Creates new array each time
}
```

### CODE-011: Algorithm Efficiency

**Category**: Important
**Level**: Function
**Cross-References**: [CODE-010](#CODE-010)

#### Description

Algorithms and data processing patterns must be implemented efficiently to handle enterprise-scale data volumes.

#### Explicit Standard Definition

- O(n) or better complexity for data processing where possible
- Lookup operations use hashtables for O(1) performance
- Batch processing used for large datasets
- Expensive operations cached when appropriate
- Parallel processing considered for CPU-intensive tasks

#### Evaluation Methods

##### Function Level

- Algorithm complexity analysis
- Performance bottleneck identification
- Optimization opportunity assessment

#### Compliance Criteria

- [ ] Efficient algorithms selected for data processing
- [ ] Lookup operations optimized
- [ ] Batch processing implemented for large datasets
- [ ] Caching used appropriately
- [ ] Parallelization considered for intensive operations

### CODE-012: Resource Usage Optimization

**Category**: Important
**Level**: Function, Module
**Cross-References**: [CODE-010](#CODE-010)

#### Description

System resources must be used efficiently to support scalable operations in enterprise environments.

#### Explicit Standard Definition

- File handles opened and closed promptly
- Network connections managed efficiently
- External processes properly started and terminated
- Registry keys closed after use
- Temporary resources cleaned up automatically

#### Evaluation Methods

##### Function Level

- Resource usage pattern analysis
- Resource leak detection
- Cleanup implementation verification

#### Compliance Criteria

- [ ] File handles managed properly
- [ ] Network connections optimized
- [ ] External processes controlled
- [ ] Registry access properly managed
- [ ] Temporary resources cleaned up

## Security Standards

### CODE-013: Credential Handling

**Category**: Critical
**Level**: Function, Module, Enterprise
**Cross-References**: [ARCH-019](PSEval-Standards-Architecture.md#ARCH-019)

#### Description

Credentials and sensitive data must be handled securely throughout the application lifecycle.

#### Explicit Standard Definition

- PSCredential objects used for credential parameters
- SecureString used for password storage and transmission
- No plaintext passwords in code or logs
- Credential validation performed before use
- Credentials not stored in variables longer than necessary

#### Evaluation Methods

##### Enterprise Level

- Credential handling pattern assessment across modules
- Security vulnerability scanning
- Compliance with organizational security policies

##### Function Level

- Individual function credential usage analysis
- Sensitive data exposure detection
- Security best practice implementation verification

#### Compliance Criteria

- [ ] PSCredential objects used for credentials
- [ ] SecureString used for passwords
- [ ] No plaintext credentials in code
- [ ] Credential validation implemented
- [ ] Credential lifetime minimized

#### Examples

```powershell
# Good example - Proper credential handling
param(
    [Parameter()]
    [PSCredential]$Credential = [PSCredential]::Empty
)

if ($Credential -eq [PSCredential]::Empty) {
    $Credential = Get-Credential -Message "Enter credentials"
}

# Use credential securely
$connection = Connect-Service -Credential $Credential

# Bad example - Insecure credential handling
param(
    [string]$UserName,
    [string]$Password    # Plaintext password parameter
)

Write-Verbose "Connecting with password: $Password"  # Password in logs
$connection = Connect-Service -UserName $UserName -Password $Password
```

### CODE-014: Input Validation and Sanitization

**Category**: Critical
**Level**: Function, Script
**Cross-References**: [FUNC-004](PSEval-Standards-Functions.md#FUNC-004)

#### Description

All user input must be validated and sanitized to prevent security vulnerabilities and ensure data integrity.

#### Explicit Standard Definition

- Parameter validation attributes used extensively
- Input data validated against expected formats
- Special characters escaped or rejected appropriately
- File paths validated before use
- SQL injection and command injection prevention implemented

#### Evaluation Methods

##### Function Level

- Input validation implementation analysis
- Vulnerability assessment for injection attacks
- Validation attribute usage verification

#### Compliance Criteria

- [ ] Parameter validation attributes present
- [ ] Input format validation implemented
- [ ] Special character handling appropriate
- [ ] File path validation performed
- [ ] Injection attack prevention implemented

#### Examples

```powershell
# Good example - Comprehensive input validation
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

# Additional runtime validation
if ($UserName -match '[<>"|&]') {
    throw "Username contains invalid characters"
}

# Bad example - No input validation
param(
    [string]$UserName,    # No validation
    [string]$Command      # Could contain injection
)

Invoke-Expression $Command  # Dangerous without validation
```

### CODE-015: Data Protection Standards

**Category**: Important
**Level**: Function, Module
**Cross-References**: [CODE-013](#CODE-013)

#### Description

Sensitive data must be protected during processing, storage, and transmission.

#### Explicit Standard Definition

- Sensitive data encrypted when stored
- Secure transmission protocols used for network operations
- Data sanitized before logging or output
- Temporary files containing sensitive data protected
- Memory containing sensitive data cleared when possible

#### Evaluation Methods

##### Function Level

- Sensitive data handling pattern analysis
- Encryption implementation verification
- Data exposure risk assessment

#### Compliance Criteria

- [ ] Sensitive data encrypted appropriately
- [ ] Secure protocols used for transmission
- [ ] Data sanitized for logging
- [ ] Temporary files protected
- [ ] Memory cleanup implemented

## Code Quality Standards

### CODE-016: Code Readability

**Category**: Important
**Level**: Function, Script
**Cross-References**: [DOC-003](PSEval-Standards-Documentation.md#DOC-003)

#### Description

Code must be written for readability and maintainability by development teams.

#### Explicit Standard Definition

- Consistent indentation using spaces (4 spaces per level)
- Logical code organization with clear separation of concerns
- Meaningful variable and function names
- Comments used to explain complex logic
- Code blocks properly formatted and spaced

#### Evaluation Methods

##### Function Level

- Code formatting consistency assessment
- Readability metric evaluation
- Comment quality and placement review

#### Compliance Criteria

- [ ] Consistent indentation used
- [ ] Logical code organization implemented
- [ ] Meaningful names throughout
- [ ] Appropriate comments included
- [ ] Proper formatting and spacing

### CODE-017: Code Reusability

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ARCH-002](PSEval-Standards-Architecture.md#ARCH-002)

#### Description

Code should be designed for reusability across different contexts and projects.

#### Explicit Standard Definition

- Functions designed for single responsibility
- Hard-coded values externalized as parameters
- Dependencies minimized and clearly declared
- Common functionality extracted to shared functions
- Platform and environment assumptions avoided

#### Evaluation Methods

##### Module Level

- Reusability assessment across functions
- Dependency analysis
- Code duplication detection

#### Compliance Criteria

- [ ] Single responsibility maintained
- [ ] Hard-coded values parametrized
- [ ] Dependencies minimized
- [ ] Common functionality shared
- [ ] Platform assumptions avoided

### CODE-018: Static Analysis Compliance

**Category**: Important
**Level**: Function, Module, Repository
**Cross-References**: [ARCH-020](PSEval-Standards-Architecture.md#ARCH-020)

#### Description

Code must pass static analysis tools without violations that could impact quality or security.

#### Explicit Standard Definition

- PSScriptAnalyzer rules satisfied without exceptions
- Custom organizational rules compliance maintained
- Security-focused analysis rules addressed
- Performance-related warnings resolved
- Best practice recommendations implemented

#### Evaluation Methods

##### Repository Level

- Automated static analysis execution
- Rule compliance verification across modules
- Violation trending and resolution tracking

##### Module Level

- Individual module static analysis validation
- Rule violation assessment and remediation
- Best practice implementation verification

#### Compliance Criteria

- [ ] PSScriptAnalyzer passes without errors
- [ ] Custom rules satisfied
- [ ] Security warnings addressed
- [ ] Performance recommendations implemented
- [ ] Best practices followed

## Advanced Coding Patterns

### CODE-019: Object-Oriented Patterns

**Category**: Recommended
**Level**: Function, Module
**Cross-References**: [FUNC-007](PSEval-Standards-Functions.md#FUNC-007)

#### Description

Object-oriented programming principles should be applied where appropriate in PowerShell development.

#### Explicit Standard Definition

- Custom objects created with meaningful type names
- Object methods implemented for complex behaviors
- Inheritance used appropriately for related object types
- Encapsulation maintained for object properties
- Polymorphism leveraged for flexible implementations

#### Evaluation Methods

##### Module Level

- Object-oriented design assessment
- Type hierarchy evaluation
- Encapsulation implementation review

#### Compliance Criteria

- [ ] Custom objects properly typed
- [ ] Methods implemented appropriately
- [ ] Inheritance used effectively
- [ ] Encapsulation maintained
- [ ] Polymorphism leveraged

### CODE-020: Design Pattern Implementation

**Category**: Recommended
**Level**: Module
**Cross-References**: [ERR-008](PSEval-Standards-ErrorHandling.md#ERR-008)

#### Description

Common design patterns should be implemented to solve recurring problems consistently.

#### Explicit Standard Definition

- Factory patterns for object creation
- Observer patterns for event handling
- Strategy patterns for algorithm selection
- Decorator patterns for functionality extension
- Singleton patterns for shared resources

#### Evaluation Methods

##### Module Level

- Design pattern usage assessment
- Pattern implementation quality review
- Appropriateness of pattern selection

#### Compliance Criteria

- [ ] Appropriate design patterns selected
- [ ] Patterns implemented correctly
- [ ] Pattern usage enhances maintainability
- [ ] Patterns solve actual problems
- [ ] Pattern complexity justified

## Configuration and Environment Standards

### CODE-021: Configuration Management

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [ARCH-015](PSEval-Standards-Architecture.md#ARCH-015)

#### Description

Configuration must be externalized and managed consistently across different environments.

#### Explicit Standard Definition

- Configuration values externalized from code
- Environment-specific configuration supported
- Configuration validation implemented
- Default configuration values provided
- Configuration changes tracked and versioned

#### Evaluation Methods

##### Module Level

- Configuration externalization assessment
- Environment handling evaluation
- Configuration validation verification

#### Compliance Criteria

- [ ] Configuration externalized from code
- [ ] Environment-specific support implemented
- [ ] Configuration validation present
- [ ] Default values provided
- [ ] Configuration versioning implemented

### CODE-022: Environment Detection

**Category**: Important
**Level**: Function, Module
**Cross-References**: [CODE-021](#CODE-021)

#### Description

Code must detect and adapt to different execution environments appropriately.

#### Explicit Standard Definition

- PowerShell version detection and handling
- Operating system detection when relevant
- Execution context awareness (ISE, console, automation)
- Module dependency availability checking
- Network connectivity assessment when required

#### Evaluation Methods

##### Function Level

- Environment detection implementation analysis
- Adaptation logic assessment
- Compatibility testing across environments

#### Compliance Criteria

- [ ] PowerShell version detection implemented
- [ ] OS detection used appropriately
- [ ] Execution context handled properly
- [ ] Dependencies verified before use
- [ ] Network requirements assessed

## Integration Standards

### CODE-023: API Integration Patterns

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ERR-005](PSEval-Standards-ErrorHandling.md#ERR-005)

#### Description

External API integrations must follow consistent patterns for reliability and maintainability.

#### Explicit Standard Definition

- REST API calls use appropriate HTTP methods
- Authentication handled securely and consistently
- Rate limiting and throttling implemented
- Error handling specific to API responses
- Response data validation performed

#### Evaluation Methods

##### Function Level

- API integration pattern assessment
- Authentication implementation review
- Error handling evaluation for API calls

#### Compliance Criteria

- [ ] Appropriate HTTP methods used
- [ ] Authentication handled securely
- [ ] Rate limiting implemented
- [ ] API-specific error handling present
- [ ] Response validation performed

### CODE-024: Database Integration Standards

**Category**: Important
**Level**: Function, Module
**Cross-References**: [CODE-013](#CODE-013)

#### Description

Database operations must follow secure and efficient patterns.

#### Explicit Standard Definition

- Parameterized queries used to prevent SQL injection
- Connection strings secured and managed properly
- Database connections opened and closed efficiently
- Transaction handling implemented for data integrity
- Database-specific error handling implemented

#### Evaluation Methods

##### Function Level

- Database operation security assessment
- Connection management evaluation
- Transaction handling review

#### Compliance Criteria

- [ ] Parameterized queries used exclusively
- [ ] Connection strings secured
- [ ] Connections managed efficiently
- [ ] Transactions used appropriately
- [ ] Database errors handled specifically

## Logging and Monitoring Standards

### CODE-025: Logging Implementation

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ERR-006](PSEval-Standards-ErrorHandling.md#ERR-006)

#### Description

Comprehensive logging must be implemented to support troubleshooting and monitoring.

#### Explicit Standard Definition

- Structured logging format used consistently
- Log levels implemented appropriately (Error, Warning, Information, Debug)
- Sensitive data excluded from logs
- Log rotation and management considered
- Performance impact of logging minimized

#### Evaluation Methods

##### Module Level

- Logging implementation consistency assessment
- Log level usage evaluation
- Sensitive data exposure detection in logs

#### Compliance Criteria

- [ ] Structured logging format used
- [ ] Appropriate log levels implemented
- [ ] Sensitive data excluded from logs
- [ ] Log management considered
- [ ] Performance impact minimized

### CODE-026: Performance Monitoring

**Category**: Recommended
**Level**: Function, Module
**Cross-References**: [CODE-025](#CODE-025)

#### Description

Performance monitoring should be built into functions to support optimization and troubleshooting.

#### Explicit Standard Definition

- Execution time measurement for critical operations
- Memory usage monitoring for resource-intensive functions
- Performance metrics exposed through standard interfaces
- Performance thresholds defined and monitored
- Performance degradation alerting implemented

#### Evaluation Methods

##### Function Level

- Performance monitoring implementation assessment
- Metrics collection evaluation
- Threshold definition review

#### Compliance Criteria

- [ ] Execution time measured
- [ ] Memory usage monitored
- [ ] Metrics exposed appropriately
- [ ] Thresholds defined
- [ ] Alerting implemented

## Compatibility Standards

### CODE-027: PowerShell Version Compatibility

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [ARCH-001](PSEval-Standards-Architecture.md#ARCH-001)

#### Description

Code must maintain compatibility with specified PowerShell versions and handle version differences appropriately.

#### Explicit Standard Definition

- Minimum PowerShell version specified in manifest
- Version-specific features used conditionally
- Compatibility testing performed across target versions
- Alternative implementations provided for version differences
- Version compatibility documented clearly

#### Evaluation Methods

##### Module Level

- Version compatibility testing
- Conditional feature usage assessment
- Documentation review for version requirements

#### Compliance Criteria

- [ ] Minimum version specified in manifest
- [ ] Version-specific features handled conditionally
- [ ] Compatibility testing performed
- [ ] Alternative implementations provided
- [ ] Version compatibility documented

### CODE-028: Cross-Platform Considerations

**Category**: Recommended
**Level**: Module, Repository
**Cross-References**: [ARCH-023](PSEval-Standards-Architecture.md#ARCH-023)

#### Description

Code should consider cross-platform compatibility where applicable and handle platform differences appropriately.

#### Explicit Standard Definition

- Platform-specific code isolated and conditional
- File path operations use platform-appropriate separators
- Registry operations handled platform-specifically
- WMI operations replaced with CIM where possible
- Platform limitations documented clearly

#### Evaluation Methods

##### Module Level

- Cross-platform compatibility assessment
- Platform-specific code identification
- Path handling evaluation

#### Compliance Criteria

- [ ] Platform-specific code isolated
- [ ] Path operations platform-appropriate
- [ ] Registry operations handled properly
- [ ] CIM used instead of WMI where possible
- [ ] Platform limitations documented

## Maintenance and Evolution Standards

### CODE-029: Code Versioning Integration

**Category**: Important
**Level**: Function, Module, Repository
**Cross-References**: [ARCH-003](PSEval-Standards-Architecture.md#ARCH-003)

#### Description

Code must integrate properly with version control systems and support change tracking.

#### Explicit Standard Definition

- Meaningful commit messages following organizational standards
- Code changes aligned with semantic versioning principles
- Breaking changes clearly identified and documented
- Backward compatibility maintained within major versions
- Migration paths provided for breaking changes

#### Evaluation Methods

##### Repository Level

- Version control integration assessment
- Change tracking evaluation
- Backward compatibility verification

#### Compliance Criteria

- [ ] Meaningful commit messages used
- [ ] Changes align with semantic versioning
- [ ] Breaking changes identified
- [ ] Backward compatibility maintained
- [ ] Migration paths provided

### CODE-030: Refactoring Support

**Category**: Recommended
**Level**: Function, Module
**Cross-References**: [CODE-017](#CODE-017)

#### Description

Code should be structured to support refactoring and continuous improvement.

#### Explicit Standard Definition

- Modular design supports component replacement
- Dependencies minimized to reduce refactoring impact
- Interface consistency maintained during refactoring
- Automated tests protect against regression during refactoring
- Refactoring tracked and documented appropriately

#### Evaluation Methods

##### Module Level

- Refactoring support assessment
- Dependency impact analysis
- Test coverage evaluation for refactoring safety

#### Compliance Criteria

- [ ] Modular design supports refactoring
- [ ] Dependencies minimized
- [ ] Interface consistency maintained
- [ ] Automated tests provide regression protection
- [ ] Refactoring properly documented

### CODE-031: Technical Debt Management

**Category**: Important
**Level**: Module, Repository, Enterprise
**Cross-References**: [CODE-018](#CODE-018)

#### Description

Technical debt must be identified, tracked, and addressed systematically.

#### Explicit Standard Definition

- Code quality metrics tracked over time
- Technical debt items identified and prioritized
- Remediation plans created for significant debt
- Code quality degradation prevented through quality gates
- Technical debt impact on maintenance documented

#### Evaluation Methods

##### Enterprise Level

- Organization-wide technical debt assessment
- Quality trend analysis
- Remediation progress tracking

##### Module Level

- Individual module debt identification
- Quality metric evaluation
- Remediation priority assessment

#### Compliance Criteria

- [ ] Quality metrics tracked
- [ ] Technical debt identified and prioritized
- [ ] Remediation plans created
- [ ] Quality gates prevent degradation
- [ ] Debt impact documented

---

## Cross-References

### Related Standards Documents

- **[PSEval-Standards-Overview.md](PSEval-Standards-Overview.md)** - Complete standards framework overview
- **[PSEval-Standards-Architecture.md](PSEval-Standards-Architecture.md)** - Module architecture and structure standards
- **[PSEval-Standards-Functions.md](PSEval-Standards-Functions.md)** - Function and cmdlet design standards
- **[PSEval-Standards-Documentation.md](PSEval-Standards-Documentation.md)** - Documentation and help standards
- **[PSEval-Standards-ErrorHandling.md](PSEval-Standards-ErrorHandling.md)** - Error handling standards
- **[PSEval-Standards-Testing.md](PSEval-Standards-Testing.md)** - Testing and validation standards

### Evaluation Documents

- **[PSEval-Evaluation-Methods.md](PSEval-Evaluation-Methods.md)** - Evaluation methodologies
- **[PSEval-Evaluation-Checklists.md](PSEval-Evaluation-Checklists.md)** - Practical checklists
- **[PSEval-Evaluation-Automation.md](PSEval-Evaluation-Automation.md)** - Automated evaluation tools

---

_This document contains 31 coding standards for PowerShell module evaluation. For complete evaluation framework, reference all standards documents and evaluation tools._
