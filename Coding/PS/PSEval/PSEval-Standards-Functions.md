# PowerShell Function and Cmdlet Design Standards

## Metadata

- **Document Type**: Function Design Standards
- **Version**: 1.0.0
- **Last Updated**: 2025-08-24
- **Standards Count**: 28 Function Design Standards
- **Cross-References**: [Overview](PSEval-Standards-Overview.md) | [Architecture](PSEval-Standards-Architecture.md) | [Coding](PSEval-Standards-Coding.md)

## Executive Summary

Function design standards define the requirements for PowerShell function and cmdlet development, covering advanced function patterns, parameter design, pipeline integration, input/output management, and processing methods. These standards ensure functions are reliable, intuitive, and integrate seamlessly with PowerShell's command ecosystem.

## Advanced Function Architecture Standards

### FUNC-001: CmdletBinding Required

**Category**: Critical
**Level**: Function, Module, Repository
**Cross-References**: [CODE-001](PSEval-Standards-Coding.md#CODE-001), [ARCH-004](PSEval-Standards-Architecture.md#ARCH-004)

#### Description

All public functions must use the CmdletBinding attribute to enable advanced function capabilities and common parameters.

#### Explicit Standard Definition

- [CmdletBinding()] attribute present on all public functions
- DefaultParameterSetName specified when multiple parameter sets exist
- SupportsShouldProcess used for functions that make changes
- ConfirmImpact specified appropriately for destructive operations
- Common parameters (Verbose, Debug, ErrorAction) automatically available

#### Evaluation Methods

##### Enterprise Level

- Organization-wide CmdletBinding usage analysis
- Common parameter availability verification across modules
- Parameter set consistency assessment

##### Function Level

- Individual function CmdletBinding presence verification
- Parameter set configuration evaluation
- SupportsShouldProcess usage assessment

#### Compliance Criteria

- [ ] [CmdletBinding()] attribute present
- [ ] DefaultParameterSetName specified when applicable
- [ ] SupportsShouldProcess used for change operations
- [ ] ConfirmImpact appropriate for operation risk level
- [ ] Common parameters function correctly

#### Examples

```powershell
# Good example - Proper CmdletBinding usage
function Set-UserAccount {
    [CmdletBinding(
        DefaultParameterSetName = 'Identity',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Identity')]
        [string]$Identity
    )

    if ($PSCmdlet.ShouldProcess($Identity, "Modify User Account")) {
        # Implementation here
    }
}

# Bad example - Missing CmdletBinding
function Set-UserAccount {
    param([string]$Identity)
    # No access to common parameters or ShouldProcess
}
```

### FUNC-002: Parameter Validation Implementation

**Category**: Critical
**Level**: Function, Module, Repository
**Cross-References**: [CODE-014](PSEval-Standards-Coding.md#CODE-014)

#### Description

Function parameters must include comprehensive validation attributes to ensure data integrity and provide clear error messages.

#### Explicit Standard Definition

- Mandatory parameters marked with [Parameter(Mandatory = $true)]
- String parameters use ValidateNotNullOrEmpty where appropriate
- Numeric parameters use ValidateRange for bounds checking
- Enumerated values use ValidateSet for allowed options
- Complex validation implemented with ValidateScript
- File/path parameters validated for existence when required

#### Evaluation Methods

##### Function Level

- Parameter validation attribute presence assessment
- Validation appropriateness for parameter type and usage
- Custom validation logic evaluation for complex scenarios

#### Compliance Criteria

- [ ] Mandatory parameters properly marked
- [ ] String validation prevents null/empty where appropriate
- [ ] Numeric ranges validated
- [ ] Enumerated values constrained with ValidateSet
- [ ] Complex validation implemented correctly
- [ ] File/path validation present when needed

#### Examples

```powershell
# Good example - Comprehensive parameter validation
function New-UserAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 20)]
        [ValidatePattern('^[a-zA-Z0-9._-]+$')]
        [string]$UserName,

        [Parameter()]
        [ValidateRange(18, 120)]
        [int]$Age,

        [Parameter()]
        [ValidateSet('Active', 'Inactive', 'Suspended')]
        [string]$Status = 'Active',

        [Parameter()]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) { $true }
            else { throw "Path '$_' must be a valid directory" }
        })]
        [string]$HomeDirectory
    )
}

# Bad example - No parameter validation
function New-UserAccount {
    param(
        [string]$UserName,    # No validation - could be empty or invalid
        [int]$Age,           # No range checking
        [string]$Status,     # No constraint on valid values
        [string]$HomeDirectory  # No path validation
    )
}
```

### FUNC-003: Pipeline Input Support

**Category**: Important
**Level**: Function, Module, Repository
**Cross-References**: [CODE-002](PSEval-Standards-Coding.md#CODE-002)

#### Description

Functions should support pipeline input through ValueFromPipeline or ValueFromPipelineByPropertyName where semantically appropriate.

#### Explicit Standard Definition

- Functions accepting single objects support ValueFromPipeline
- Functions accepting properties support ValueFromPipelineByPropertyName
- Pipeline input parameters use appropriate aliases for flexibility
- Process block implemented for pipeline input handling
- Pipeline input validated consistently with direct parameter input

#### Evaluation Methods

##### Function Level

- Pipeline support appropriateness assessment
- Pipeline parameter configuration evaluation
- Process block implementation verification

#### Compliance Criteria

- [ ] Pipeline input support appropriate for function purpose
- [ ] ValueFromPipeline or ValueFromPipelineByPropertyName used correctly
- [ ] Appropriate aliases provided for pipeline properties
- [ ] Process block handles pipeline input properly
- [ ] Pipeline validation consistent with direct input

#### Examples

```powershell
# Good example - Pipeline input support
function Get-UserDetails {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('SamAccountName', 'UserPrincipalName')]
        [string[]]$Identity
    )

    process {
        foreach ($user in $Identity) {
            # Process each user from pipeline
            Get-ADUser -Identity $user
        }
    }
}

# Usage examples:
'user1', 'user2' | Get-UserDetails
Get-ADUser -Filter * | Get-UserDetails
Get-UserDetails -Identity 'user1'

# Bad example - No pipeline support
function Get-UserDetails {
    param([string[]]$Identity)

    # Cannot be used in pipeline effectively
    foreach ($user in $Identity) {
        Get-ADUser -Identity $user
    }
}
```

### FUNC-004: Output Type Declaration

**Category**: Important
**Level**: Function, Module
**Cross-References**: [DOC-004](PSEval-Standards-Documentation.md#DOC-004)

#### Description

Functions must declare their output types using the OutputType attribute for better pipeline integration and help generation.

#### Explicit Standard Definition

- [OutputType()] attribute specifies expected return types
- Multiple output types declared when function returns different types
- Custom object types used for complex return values
- Output type matches actual function return behavior
- Generic types avoided in favor of specific types when possible

#### Evaluation Methods

##### Function Level

- OutputType attribute presence verification
- Output type accuracy assessment against actual returns
- Custom object type usage evaluation

#### Compliance Criteria

- [ ] OutputType attribute present and accurate
- [ ] Multiple output types declared when applicable
- [ ] Custom object types used appropriately
- [ ] Output type matches actual function behavior
- [ ] Specific types preferred over generic types

#### Examples

```powershell
# Good example - Proper output type declaration
function Get-SystemInventory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    process {
        foreach ($computer in $ComputerName) {
            [PSCustomObject]@{
                ComputerName = $computer
                OperatingSystem = (Get-CimInstance Win32_OperatingSystem -ComputerName $computer).Caption
                TotalMemoryGB = [Math]::Round((Get-CimInstance Win32_ComputerSystem -ComputerName $computer).TotalPhysicalMemory / 1GB, 2)
                PSTypeName = 'SystemInventory'
            }
        }
    }
}

# Good example - Multiple output types
function Get-UserAccountStatus {
    [CmdletBinding()]
    [OutputType([Microsoft.ActiveDirectory.Management.ADUser], [System.String])]
    param(
        [Parameter(Mandatory)]
        [string]$Identity,

        [switch]$Summary
    )

    if ($Summary) {
        return "User $Identity status: Enabled"  # String output
    } else {
        return Get-ADUser -Identity $Identity    # ADUser output
    }
}
```

## Parameter Design Standards

### FUNC-005: Standard Parameter Names

**Category**: Important
**Level**: Function, Module, Repository
**Cross-References**: [CODE-004](PSEval-Standards-Coding.md#CODE-004)

#### Description

Functions must use standardized parameter names that are consistent across PowerShell and align with user expectations.

#### Explicit Standard Definition

- ComputerName for target computer specification
- Name or Identity for primary object identifiers
- Path for file system paths
- Credential for authentication objects
- Force for override protection mechanisms
- PassThru for returning modified objects
- WhatIf and Confirm automatically available through SupportsShouldProcess

#### Evaluation Methods

##### Module Level

- Parameter naming consistency assessment across functions
- Standard parameter usage verification
- Alternative naming justification evaluation

#### Compliance Criteria

- [ ] Standard parameter names used consistently
- [ ] ComputerName used for computer targets
- [ ] Name/Identity used for object identifiers
- [ ] Path used for file system locations
- [ ] Credential used for authentication
- [ ] Force used for override scenarios
- [ ] PassThru used for object return scenarios

### FUNC-006: Parameter Set Design

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-001](#FUNC-001)

#### Description

Functions with multiple operation modes must use parameter sets to provide clear and mutually exclusive parameter combinations.

#### Explicit Standard Definition

- Parameter sets used for mutually exclusive operations
- DefaultParameterSetName specified in CmdletBinding
- Each parameter set provides complete functionality
- Parameter set names are descriptive and meaningful
- Mandatory parameters present in each applicable parameter set

#### Evaluation Methods

##### Function Level

- Parameter set design appropriateness assessment
- Parameter set completeness verification
- Parameter set naming evaluation

#### Compliance Criteria

- [ ] Parameter sets used for mutually exclusive operations
- [ ] DefaultParameterSetName specified appropriately
- [ ] Each parameter set functionally complete
- [ ] Parameter set names descriptive
- [ ] Mandatory parameters correct per set

#### Examples

```powershell
# Good example - Well-designed parameter sets
function Get-SystemInfo {
    [CmdletBinding(DefaultParameterSetName = 'ByComputerName')]
    param(
        # Parameter Set 1: By Computer Name
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByComputerName',
            ValueFromPipeline = $true
        )]
        [string[]]$ComputerName,

        # Parameter Set 2: By IP Address
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByIPAddress'
        )]
        [System.Net.IPAddress[]]$IPAddress,

        # Parameter Set 3: Local Computer
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Local'
        )]
        [switch]$Local,

        # Common parameters across all sets
        [Parameter()]
        [PSCredential]$Credential,

        [Parameter()]
        [int]$TimeoutSeconds = 30
    )

    # Implementation handles different parameter sets
    switch ($PSCmdlet.ParameterSetName) {
        'ByComputerName' {
            # Process by computer name
        }
        'ByIPAddress' {
            # Process by IP address
        }
        'Local' {
            # Process local computer
        }
    }
}
```

### FUNC-007: Dynamic Parameters

**Category**: Recommended
**Level**: Function
**Cross-References**: [FUNC-006](#FUNC-006)

#### Description

Dynamic parameters should be used when parameter availability depends on other parameter values or runtime conditions.

#### Explicit Standard Definition

- Dynamic parameters created only when runtime conditions require them
- Dynamic parameter creation efficient and well-performing
- Dynamic parameters properly typed and validated
- Dynamic parameter help documentation provided
- Dynamic parameters integrate seamlessly with tab completion

#### Evaluation Methods

##### Function Level

- Dynamic parameter appropriateness assessment
- Performance impact evaluation of dynamic parameter creation
- Integration quality with PowerShell parameter system

#### Compliance Criteria

- [ ] Dynamic parameters justified by runtime conditions
- [ ] Creation process efficient
- [ ] Dynamic parameters properly typed and validated
- [ ] Help documentation included
- [ ] Tab completion integration working

## Processing Method Standards

### FUNC-008: Begin-Process-End Implementation

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-003](#FUNC-003)

#### Description

Functions handling pipeline input must implement appropriate begin, process, and end blocks for proper pipeline behavior.

#### Explicit Standard Definition

- Begin block used for initialization and validation
- Process block used for pipeline input handling
- End block used for cleanup and summary operations
- Resource management properly handled across all blocks
- Error handling consistent across all processing blocks

#### Evaluation Methods

##### Function Level

- Processing block implementation appropriateness
- Resource management across blocks verification
- Error handling consistency assessment

#### Compliance Criteria

- [ ] Begin block used for initialization
- [ ] Process block handles pipeline input correctly
- [ ] End block performs cleanup and summary
- [ ] Resources managed properly across blocks
- [ ] Error handling consistent across blocks

#### Examples

```powershell
# Good example - Proper begin-process-end implementation
function Process-UserBatch {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [PSCustomObject[]]$UserData,

        [Parameter()]
        [string]$OutputPath
    )

    begin {
        Write-Verbose "Starting user batch processing"
        $processedCount = 0
        $results = [System.Collections.Generic.List[PSCustomObject]]::new()

        # Validate output path
        if ($OutputPath -and -not (Test-Path (Split-Path $OutputPath))) {
            throw "Output directory does not exist"
        }
    }

    process {
        foreach ($user in $UserData) {
            try {
                Write-Verbose "Processing user: $($user.Name)"
                $result = Process-SingleUser -UserData $user
                $results.Add($result)
                $processedCount++
            }
            catch {
                Write-Error "Failed to process user $($user.Name): $($_.Exception.Message)"
            }
        }
    }

    end {
        Write-Verbose "Processed $processedCount users"

        if ($OutputPath) {
            $results | Export-Csv -Path $OutputPath -NoTypeInformation
            Write-Information "Results exported to: $OutputPath"
        }

        Write-Output $results
    }
}
```

### FUNC-009: State Management

**Category**: Important
**Level**: Function
**Cross-References**: [CODE-006](PSEval-Standards-Coding.md#CODE-006)

#### Description

Functions must properly manage state across pipeline processing and function calls.

#### Explicit Standard Definition

- Function-scoped variables properly initialized
- State preserved correctly across process block iterations
- Module-level state managed through script-scoped variables
- Temporary state cleaned up appropriately
- State modifications tracked for debugging purposes

#### Evaluation Methods

##### Function Level

- State management implementation assessment
- Variable scope usage evaluation
- State cleanup verification

#### Compliance Criteria

- [ ] Function-scoped variables initialized properly
- [ ] State preserved across process iterations
- [ ] Module state managed through script scope
- [ ] Temporary state cleaned up
- [ ] State modifications tracked appropriately

## Input Validation and Processing Standards

### FUNC-010: Input Sanitization

**Category**: Critical
**Level**: Function
**Cross-References**: [CODE-014](PSEval-Standards-Coding.md#CODE-014)

#### Description

All function inputs must be sanitized and validated to prevent security vulnerabilities and ensure data integrity.

#### Explicit Standard Definition

- String inputs validated for format and content
- File paths validated for existence and security
- Network addresses validated for format
- Script blocks validated before execution
- SQL parameters properly escaped or parameterized
- Regular expressions validated for safety

#### Evaluation Methods

##### Function Level

- Input sanitization implementation assessment
- Security vulnerability testing
- Validation completeness evaluation

#### Compliance Criteria

- [ ] String inputs properly validated
- [ ] File paths secured and validated
- [ ] Network addresses format-checked
- [ ] Script blocks validated before execution
- [ ] SQL parameters secured
- [ ] Regular expressions safety-checked

### FUNC-011: Type Coercion Handling

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-002](#FUNC-002)

#### Description

Functions must handle PowerShell's type coercion appropriately and provide explicit type conversion where needed.

#### Explicit Standard Definition

- Strong typing used for parameters where appropriate
- Type conversion performed explicitly for critical operations
- Type coercion failures handled gracefully
- Numeric conversions validated for range and precision
- Date/time parsing uses culture-appropriate methods

#### Evaluation Methods

##### Function Level

- Type handling implementation assessment
- Type coercion failure handling evaluation
- Conversion safety verification

#### Compliance Criteria

- [ ] Strong typing used appropriately
- [ ] Explicit type conversion implemented
- [ ] Coercion failures handled gracefully
- [ ] Numeric conversions validated
- [ ] Date/time parsing culture-aware

## Output Formatting and Management Standards

### FUNC-012: Structured Output Creation

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-004](#FUNC-004)

#### Description

Functions should return structured objects rather than formatted strings to support pipeline operations.

#### Explicit Standard Definition

- PSCustomObject used for complex return values
- Object properties named consistently across functions
- Type names assigned to custom objects using PSTypeName
- Object methods added only when beneficial for usability
- Formatting handled by PowerShell's formatting system, not in functions

#### Evaluation Methods

##### Function Level

- Output structure assessment
- Object property naming consistency evaluation
- Type naming implementation verification

#### Compliance Criteria

- [ ] PSCustomObject used for complex outputs
- [ ] Object properties consistently named
- [ ] Type names assigned appropriately
- [ ] Object methods justified and useful
- [ ] Formatting delegated to PowerShell system

#### Examples

```powershell
# Good example - Structured output
function Get-NetworkAdapter {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    process {
        foreach ($computer in $ComputerName) {
            $adapters = Get-CimInstance -ClassName Win32_NetworkAdapter -ComputerName $computer

            foreach ($adapter in $adapters) {
                [PSCustomObject]@{
                    ComputerName = $computer
                    AdapterName = $adapter.Name
                    MACAddress = $adapter.MACAddress
                    Speed = $adapter.Speed
                    AdapterType = $adapter.AdapterType
                    Enabled = $adapter.NetEnabled
                    PSTypeName = 'NetworkAdapter.Information'
                }
            }
        }
    }
}

# Bad example - String output
function Get-NetworkAdapter {
    param([string[]]$ComputerName = $env:COMPUTERNAME)

    foreach ($computer in $ComputerName) {
        "Network Adapters for $computer"
        "=========================="
        # Returns formatted strings instead of objects
        Get-CimInstance -ClassName Win32_NetworkAdapter -ComputerName $computer |
            ForEach-Object { "$($_.Name): $($_.MACAddress)" }
    }
}
```

### FUNC-013: Progress Indication

**Category**: Recommended
**Level**: Function
**Cross-References**: [FUNC-008](#FUNC-008)

#### Description

Long-running functions should provide progress indication to improve user experience.

#### Explicit Standard Definition

- Write-Progress used for operations longer than 2 seconds
- Progress percentage calculated accurately
- Activity and status descriptions provided
- Progress completed properly at operation end
- Nested progress used for complex operations

#### Evaluation Methods

##### Function Level

- Progress indication implementation assessment
- Progress accuracy and completeness evaluation
- User experience impact assessment

#### Compliance Criteria

- [ ] Write-Progress used for long operations
- [ ] Progress percentage accurate
- [ ] Descriptive activity and status messages
- [ ] Progress completed at operation end
- [ ] Nested progress used appropriately

## Error Handling Integration Standards

### FUNC-014: Function-Level Error Handling

**Category**: Critical
**Level**: Function
**Cross-References**: [ERR-001](PSEval-Standards-ErrorHandling.md#ERR-001)

#### Description

Functions must implement comprehensive error handling that integrates with PowerShell's error management system.

#### Explicit Standard Definition

- Try-catch blocks used for error-prone operations
- Specific exception types caught and handled appropriately
- Error records created with proper categorization
- Non-terminating errors written using Write-Error
- Terminating errors thrown using appropriate mechanisms

#### Evaluation Methods

##### Function Level

- Error handling implementation comprehensiveness
- Exception handling specificity assessment
- Error record quality evaluation

#### Compliance Criteria

- [ ] Try-catch blocks implemented for error-prone operations
- [ ] Specific exception types handled appropriately
- [ ] Error records properly categorized
- [ ] Non-terminating errors handled with Write-Error
- [ ] Terminating errors thrown appropriately

### FUNC-015: Error Context Preservation

**Category**: Important
**Level**: Function
**Cross-References**: [ERR-002](PSEval-Standards-ErrorHandling.md#ERR-002)

#### Description

Error handling must preserve context information to support troubleshooting and debugging.

#### Explicit Standard Definition

- Original exceptions preserved in error records
- Target objects included in error records
- Function call context maintained in error messages
- Stack trace information preserved when relevant
- Error correlation IDs used for complex operations

#### Evaluation Methods

##### Function Level

- Error context preservation assessment
- Debugging information quality evaluation
- Error traceability verification

#### Compliance Criteria

- [ ] Original exceptions preserved
- [ ] Target objects included in errors
- [ ] Function call context maintained
- [ ] Stack trace preserved when relevant
- [ ] Error correlation implemented for complex operations

## Performance and Optimization Standards

### FUNC-016: Function Performance Optimization

**Category**: Important
**Level**: Function
**Cross-References**: [CODE-010](PSEval-Standards-Coding.md#CODE-010)

#### Description

Functions must be optimized for performance to support enterprise-scale operations.

#### Explicit Standard Definition

- Efficient algorithms selected for data processing
- Unnecessary object creation minimized
- Pipeline processing preferred over collection accumulation
- Expensive operations cached when beneficial
- Memory usage optimized for large datasets

#### Evaluation Methods

##### Function Level

- Performance characteristics assessment
- Algorithm efficiency evaluation
- Memory usage pattern analysis

#### Compliance Criteria

- [ ] Efficient algorithms implemented
- [ ] Object creation minimized
- [ ] Pipeline processing utilized
- [ ] Expensive operations cached appropriately
- [ ] Memory usage optimized

### FUNC-017: Scalability Considerations

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-016](#FUNC-016)

#### Description

Functions must be designed to handle enterprise-scale data volumes and concurrent operations.

#### Explicit Standard Definition

- Batch processing implemented for large datasets
- Throttling mechanisms included for API calls
- Parallel processing used where beneficial
- Resource consumption monitored and managed
- Graceful degradation under load conditions

#### Evaluation Methods

##### Function Level

- Scalability design assessment
- Large dataset handling evaluation
- Resource management verification

#### Compliance Criteria

- [ ] Batch processing implemented
- [ ] Throttling mechanisms included
- [ ] Parallel processing utilized appropriately
- [ ] Resource consumption managed
- [ ] Graceful degradation implemented

## Integration and Compatibility Standards

### FUNC-018: Pipeline Integration

**Category**: Important
**Level**: Function
**Cross-References**: [FUNC-003](#FUNC-003), [FUNC-012](#FUNC-012)

#### Description

Functions must integrate seamlessly with PowerShell's pipeline architecture and other cmdlets.

#### Explicit Standard Definition

- Functions work correctly in pipeline chains
- Object properties align with downstream cmdlet expectations
- Pipeline streaming implemented for large datasets
- Pipeline termination handled appropriately
- Compatible input/output types with related cmdlets

#### Evaluation Methods

##### Function Level

- Pipeline integration testing
- Downstream compatibility assessment
- Pipeline performance evaluation

#### Compliance Criteria

- [ ] Functions work correctly in pipelines
- [ ] Object properties align with expectations
- [ ] Pipeline streaming implemented
- [ ] Pipeline termination handled
- [ ] Input/output types compatible

### FUNC-019: Module Integration

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ARCH-007](PSEval-Standards-Architecture.md#ARCH-007)

#### Description

Functions must integrate properly with their containing module and related modules.

#### Explicit Standard Definition

- Shared module resources accessed consistently
- Module-level configuration respected
- Dependencies on other modules handled gracefully
- Module versioning considerations addressed
- Cross-module functionality coordinated appropriately

#### Evaluation Methods

##### Module Level

- Cross-function integration assessment
- Module resource usage evaluation
- Dependency handling verification

#### Compliance Criteria

- [ ] Shared resources accessed consistently
- [ ] Module configuration respected
- [ ] Dependencies handled gracefully
- [ ] Versioning considerations addressed
- [ ] Cross-module coordination implemented

## Advanced Function Patterns

### FUNC-020: Factory Function Patterns

**Category**: Recommended
**Level**: Function
**Cross-References**: [CODE-019](PSEval-Standards-Coding.md#CODE-019)

#### Description

Factory functions should be used to create complex objects or provide abstraction over object creation.

#### Explicit Standard Definition

- Factory functions encapsulate complex object creation logic
- Multiple creation methods provided through parameter sets
- Object validation performed during creation
- Default values and configuration applied consistently
- Created objects follow standard patterns and types

#### Evaluation Methods

##### Function Level

- Factory pattern implementation assessment
- Object creation consistency evaluation
- Validation and configuration verification

#### Compliance Criteria

- [ ] Complex creation logic encapsulated
- [ ] Multiple creation methods available
- [ ] Object validation performed
- [ ] Default configuration applied
- [ ] Created objects follow standards

### FUNC-021: Decorator Function Patterns

**Category**: Recommended
**Level**: Function
**Cross-References**: [CODE-020](PSEval-Standards-Coding.md#CODE-020)

#### Description

Decorator functions should be used to extend or modify the behavior of existing objects or functions.

#### Explicit Standard Definition

- Decorator functions preserve original object functionality
- Additional properties or methods added transparently
- Decoration reversible when appropriate
- Performance impact minimized
- Decoration behavior documented clearly

#### Evaluation Methods

##### Function Level

- Decorator pattern appropriateness assessment
- Original functionality preservation verification
- Performance impact evaluation

#### Compliance Criteria

- [ ] Original functionality preserved
- [ ] Additional features added transparently
- [ ] Decoration reversible when appropriate
- [ ] Performance impact minimized
- [ ] Behavior documented clearly

## Testing Integration Standards

### FUNC-022: Testability Design

**Category**: Important
**Level**: Function
**Cross-References**: [Testing Standards](PSEval-Standards-Testing.md)

#### Description

Functions must be designed to support comprehensive automated testing.

#### Explicit Standard Definition

- Dependencies injectable for testing isolation
- Side effects minimized and controllable
- Deterministic behavior ensured for testing
- Mock-friendly interfaces provided
- Test data generation supported

#### Evaluation Methods

##### Function Level

- Testability design assessment
- Dependency injection capability evaluation
- Side effect controllability verification

#### Compliance Criteria

- [ ] Dependencies injectable for isolation
- [ ] Side effects controllable
- [ ] Deterministic behavior ensured
- [ ] Mock-friendly interfaces provided
- [ ] Test data generation supported

### FUNC-023: Unit Test Integration

**Category**: Important
**Level**: Function
**Cross-References**: [Testing Standards](PSEval-Standards-Testing.md)

#### Description

Functions should have comprehensive unit tests that validate all aspects of functionality.

#### Explicit Standard Definition

- Unit tests cover all code paths
- Parameter validation tested thoroughly
- Error conditions tested explicitly
- Pipeline behavior tested comprehensively
- Performance characteristics validated

#### Evaluation Methods

##### Function Level

- Test coverage assessment
- Test quality evaluation
- Test maintenance verification

#### Compliance Criteria

- [ ] All code paths covered by tests
- [ ] Parameter validation tested
- [ ] Error conditions tested
- [ ] Pipeline behavior tested
- [ ] Performance characteristics validated

## Documentation Integration Standards

### FUNC-024: Help System Integration

**Category**: Important
**Level**: Function
**Cross-References**: [DOC-001](PSEval-Standards-Documentation.md#DOC-001)

#### Description

Functions must integrate properly with PowerShell's help system through comprehensive comment-based help.

#### Explicit Standard Definition

- Complete comment-based help provided
- Examples demonstrate common usage scenarios
- Parameter help describes validation and usage
- Input/output types documented clearly
- Related functions cross-referenced

#### Evaluation Methods

##### Function Level

- Help completeness assessment
- Example quality and coverage evaluation
- Cross-reference accuracy verification

#### Compliance Criteria

- [ ] Complete comment-based help provided
- [ ] Examples demonstrate common scenarios
- [ ] Parameter help comprehensive
- [ ] Input/output types documented
- [ ] Related functions cross-referenced

### FUNC-025: Example Quality

**Category**: Important
**Level**: Function
**Cross-References**: [DOC-005](PSEval-Standards-Documentation.md#DOC-005)

#### Description

Function examples must be practical, accurate, and demonstrate real-world usage scenarios.

#### Explicit Standard Definition

- Examples executable without modification
- Common usage scenarios covered
- Advanced usage patterns demonstrated
- Pipeline usage examples included
- Error handling scenarios shown

#### Evaluation Methods

##### Function Level

- Example executability testing
- Usage scenario coverage assessment
- Example accuracy verification

#### Compliance Criteria

- [ ] Examples executable without modification
- [ ] Common scenarios covered
- [ ] Advanced patterns demonstrated
- [ ] Pipeline usage included
- [ ] Error scenarios shown

## Security Integration Standards

### FUNC-026: Function-Level Security

**Category**: Critical
**Level**: Function
**Cross-References**: [CODE-013](PSEval-Standards-Coding.md#CODE-013)

#### Description

Functions must implement appropriate security measures based on their functionality and access requirements.

#### Explicit Standard Definition

- Credential parameters use PSCredential type
- Sensitive data handling follows security best practices
- Input validation prevents injection attacks
- Access controls implemented where appropriate
- Security events logged for auditing

#### Evaluation Methods

##### Function Level

- Security implementation assessment
- Vulnerability testing
- Access control verification

#### Compliance Criteria

- [ ] PSCredential used for credentials
- [ ] Sensitive data handled securely
- [ ] Input validation prevents injection
- [ ] Access controls implemented
- [ ] Security events logged

### FUNC-027: Data Protection Implementation

**Category**: Important
**Level**: Function
**Cross-References**: [CODE-015](PSEval-Standards-Coding.md#CODE-015)

#### Description

Functions handling sensitive data must implement appropriate data protection measures.

#### Explicit Standard Definition

- Sensitive data encrypted in transit and at rest
- Data sanitization performed before logging
- Temporary data cleaned up securely
- Data access tracked and audited
- Privacy requirements respected

#### Evaluation Methods

##### Function Level

- Data protection implementation assessment
- Privacy compliance verification
- Audit trail completeness evaluation

#### Compliance Criteria

- [ ] Sensitive data encrypted appropriately
- [ ] Data sanitized before logging
- [ ] Temporary data cleaned securely
- [ ] Data access tracked
- [ ] Privacy requirements met

## Legacy and Migration Standards

### FUNC-028: Backward Compatibility

**Category**: Important
**Level**: Function, Module
**Cross-References**: [ARCH-013](PSEval-Standards-Architecture.md#ARCH-013)

#### Description

Functions must maintain backward compatibility within major version boundaries and provide migration paths for breaking changes.

#### Explicit Standard Definition

- Function signatures preserved within major versions
- Deprecated parameters supported with warnings
- Migration guidance provided for breaking changes
- Alternative implementations maintained when necessary
- Compatibility testing performed across versions

#### Evaluation Methods

##### Module Level

- Backward compatibility verification across versions
- Migration path validation
- Compatibility testing assessment

#### Compliance Criteria

- [ ] Function signatures preserved in major versions
- [ ] Deprecated parameters warn but function
- [ ] Migration guidance provided
- [ ] Alternative implementations maintained
- [ ] Compatibility testing performed

---

## Cross-References

### Related Standards Documents

- **[PSEval-Standards-Overview.md](PSEval-Standards-Overview.md)** - Complete standards framework overview
- **[PSEval-Standards-Architecture.md](PSEval-Standards-Architecture.md)** - Module architecture and structure standards
- **[PSEval-Standards-Coding.md](PSEval-Standards-Coding.md)** - Coding standards and conventions
- **[PSEval-Standards-Documentation.md](PSEval-Standards-Documentation.md)** - Documentation and help standards
- **[PSEval-Standards-ErrorHandling.md](PSEval-Standards-ErrorHandling.md)** - Error handling standards
- **[PSEval-Standards-Testing.md](PSEval-Standards-Testing.md)** - Testing and validation standards

### Evaluation Documents

- **[PSEval-Evaluation-Methods.md](PSEval-Evaluation-Methods.md)** - Evaluation methodologies
- **[PSEval-Evaluation-Checklists.md](PSEval-Evaluation-Checklists.md)** - Practical checklists
- **[PSEval-Evaluation-Automation.md](PSEval-Evaluation-Automation.md)** - Automated evaluation tools

---

_This document contains 28 function design standards for PowerShell module evaluation. For complete evaluation framework, reference all standards documents and evaluation tools._
