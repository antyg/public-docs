---
title: "PowerShell Function Design Standards"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Module Authors"
document_type: "reference"
domain: "development"
---

# PowerShell Function Design Standards

28 function design standards governing advanced function architecture, parameter design and validation, pipeline integration patterns, input/output type management, and processing method implementation. Derived from [Microsoft's advanced function documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced) and [cmdlet design guidelines](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines).

---

## Core Function Standards

### FUNC-001: CmdletBinding Required

**Category**: Critical | **Scope**: Function, Module, Repository

All PowerShell functions must use the `[CmdletBinding()]` attribute to enable advanced function capabilities.

**Requirements:**

- `[CmdletBinding()]` attribute present on all public functions
- `SupportsShouldProcess` set to `$true` for functions that modify state
- `ConfirmImpact` set appropriately for destructive operations
- Common parameters available through `CmdletBinding`
- `DefaultParameterSetName` specified when multiple parameter sets exist

**Compliance criteria:**

- [ ] `[CmdletBinding()]` attribute present
- [ ] `SupportsShouldProcess` implemented for state-modifying functions
- [ ] `ConfirmImpact` appropriate for the function's impact level
- [ ] Common parameters available (`Verbose`, `Debug`, `ErrorAction`, etc.)
- [ ] Default parameter set specified when applicable

```powershell
# Compliant — state-modifying function
function Remove-UserAccount {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Identity
    )
    process {
        if ($PSCmdlet.ShouldProcess($Identity, 'Remove user account')) {
            # Perform removal
        }
    }
}

# Compliant — read-only function
function Get-UserAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Identity
    )
    process {
        # Retrieve and return user
    }
}
```

---

### FUNC-002: Parameter Validation

**Category**: Critical | **Scope**: Function, Module, Repository

All function parameters must include appropriate validation attributes to ensure data integrity and prevent invalid input.

**Requirements:**

- `[Parameter()]` attribute applied to all parameters
- `Mandatory` specified for required parameters
- Appropriate [validation attributes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters) applied:
  - `[ValidateNotNullOrEmpty()]` for string parameters
  - `[ValidateRange()]` for numeric parameters
  - `[ValidateSet()]` for enumerated values
  - `[ValidatePattern()]` for format validation
  - `[ValidateScript()]` for complex validation logic
- `Position` attributes used for positional parameters

**Compliance criteria:**

- [ ] `[Parameter()]` attribute applied to all parameters
- [ ] `Mandatory` specified for required parameters
- [ ] Appropriate validation attributes applied
- [ ] Type declarations present for all parameters
- [ ] Position specified for positional parameters

```powershell
function Set-UserStatus {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Identity,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Active', 'Disabled', 'Locked')]
        [string]$Status,

        [Parameter()]
        [ValidateRange(1, 365)]
        [int]$ExpiryDays
    )
}
```

---

### FUNC-003: Pipeline Input Support

**Category**: Important | **Scope**: Function, Module, Repository

Functions should support pipeline input to enable composability with other PowerShell commands.

**Requirements:**

- `ValueFromPipeline` or `ValueFromPipelineByPropertyName` specified on pipeline parameters
- `begin`, `process`, and `end` blocks implemented when pipeline processing is required
- Pipeline processing does not accumulate all input in memory before processing
- Output emitted in `process` block, not accumulated and returned at end

**Compliance criteria:**

- [ ] Appropriate pipeline input attributes present
- [ ] `process` block handles pipeline input
- [ ] No unnecessary buffering of pipeline objects
- [ ] Output emitted per-object in `process` block

---

### FUNC-004: Output Type Declaration

**Category**: Important | **Scope**: Function, Module, Repository

Functions must declare their output types using the `[OutputType()]` attribute.

**Requirements:**

- `[OutputType()]` attribute present for all functions that produce output
- Declared output types are accurate and complete
- Output types align with actual returned objects
- Multiple output types declared when function output varies by parameter set

**Compliance criteria:**

- [ ] `[OutputType()]` attribute present
- [ ] Declared types match actual output
- [ ] Multiple output types declared when applicable
- [ ] `[OutputType([void])]` used for functions with no output

```powershell
function Get-UserAccount {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param([string]$Identity)
    process {
        [PSCustomObject]@{
            Identity = $Identity
            Enabled  = $true
        }
    }
}
```

---

### FUNC-005: Parameter Sets

**Category**: Important | **Scope**: Function

Functions with mutually exclusive parameter groups must use parameter sets.

**Requirements:**

- Parameter sets defined for mutually exclusive parameters
- `DefaultParameterSetName` specified in `[CmdletBinding()]`
- `ParameterSetName` assigned to each parameter in the set
- Help documentation covers all parameter set combinations

---

### FUNC-006: Dynamic Parameters

**Category**: Recommended | **Scope**: Function, Module

Dynamic parameters used when parameter availability depends on runtime conditions. `DynamicParam` block implemented when required. Dynamic parameters integrated with parameter validation.

---

## Processing Method Standards

### FUNC-007: Begin-Process-End Implementation

**Category**: Important | **Scope**: Function

Functions processing pipeline input must implement appropriate `begin`/`process`/`end` blocks.

**Requirements:**

- `begin` block used for one-time initialisation (connections, setup)
- `process` block handles per-object pipeline processing
- `end` block used for final cleanup and aggregated output
- Resources acquired in `begin` are released in `end`

```powershell
function Get-RemoteData {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$ComputerName
    )
    begin {
        $connection = Connect-RemoteService
    }
    process {
        Get-DataFromRemote -Connection $connection -Computer $ComputerName
    }
    end {
        Disconnect-RemoteService -Connection $connection
    }
}
```

---

### FUNC-008: State Management

**Category**: Important | **Scope**: Function, Module

- Script-level state explicitly managed with `$script:` prefix
- State initialised in module load or function `begin` block
- State cleaned up in module `OnRemove` or function `end` block
- Thread safety considered for concurrent usage

---

## Input and Output Standards

### FUNC-009: Input Sanitisation

**Category**: Important | **Scope**: Function

- All input sanitised before processing
- Path inputs validated with `Test-Path` before use
- String inputs trimmed and normalised where appropriate
- Type coercion handled explicitly rather than relying on implicit conversion

---

### FUNC-010: Structured Output

**Category**: Important | **Scope**: Function, Module

- Custom output objects use `[PSCustomObject]` with named properties
- Property names use PascalCase
- Objects typed with `PSTypeName` for formatting support
- Pipeline-friendly output design (one object per item, not arrays)

```powershell
function Get-ProcessInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param([string]$Name)
    process {
        [PSCustomObject]@{
            PSTypeName  = 'MyModule.ProcessInfo'
            Name        = $Name
            Id          = (Get-Process $Name).Id
            Status      = 'Running'
            LastChecked = [datetime]::UtcNow
        }
    }
}
```

---

### FUNC-011: Progress Indication

**Category**: Recommended | **Scope**: Function, Module

- [`Write-Progress`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress) used for long-running operations
- Progress activity and status descriptive
- Percentage completion calculated where possible
- Progress cleaned up on completion or error
- Progress disabled when `-Verbose` is not active (performance optimisation)

---

## Error Handling Standards

### FUNC-012: Non-Terminating Error Handling

**Category**: Important | **Scope**: Function

- `Write-Error` used for non-terminating errors
- `ErrorRecord` constructed with appropriate category and target
- `ErrorAction` preference respected

---

### FUNC-013: Terminating Error Handling

**Category**: Important | **Scope**: Function

- `throw` or `$PSCmdlet.ThrowTerminatingError()` used for terminating errors
- Terminating errors reserved for unrecoverable situations
- Exception types match the failure category

---

### FUNC-014: ErrorRecord Construction

**Category**: Critical | **Scope**: Function, Module

Error records must be constructed with complete information for effective debugging. See [standards-error-handling.md](standards-error-handling.md) for detailed requirements.

```powershell
$errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [System.Exception]::new("User '$Identity' not found"),
    'UserNotFound',
    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
    $Identity
)
$PSCmdlet.WriteError($errorRecord)
```

---

### FUNC-015: Exception Wrapping

**Category**: Important | **Scope**: Function

- Original exceptions preserved in inner exception
- Exception wrapping adds context without losing original information
- Exception type hierarchy respected

---

## Performance Standards

### FUNC-016: Pipeline Efficiency

**Category**: Important | **Scope**: Function

- Objects emitted as processed, not accumulated
- Memory footprint minimised during pipeline execution
- Streaming processing preferred over buffered processing

---

### FUNC-017: Scalability

**Category**: Important | **Scope**: Module

- Functions handle both single-item and large-batch scenarios
- Batch processing implemented for bulk operations
- Resource limits respected during large-scale processing

---

## Integration Standards

### FUNC-018: Module Integration

**Category**: Important | **Scope**: Module

Functions integrate properly with the parent module. Internal helper functions use private scope. Public functions exported through manifest. Module variables shared appropriately between functions.

---

### FUNC-019: Factory Patterns

**Category**: Recommended | **Scope**: Module

Factory functions create objects with consistent property sets. Factory pattern reduces duplication in object creation logic. Factory output types declared with `[OutputType()]`.

---

### FUNC-020: Decorator Patterns

**Category**: Recommended | **Scope**: Module

Decorator functions extend or wrap existing functionality. Decorator functions accept and pass through pipeline objects. Decorator output maintains compatibility with wrapped function output.

---

## Testability Standards

### FUNC-021: Testable Design

**Category**: Important | **Scope**: Function, Module

- External dependencies abstracted for mocking with [Pester](https://pester.dev/)
- Pure functions preferred over stateful functions where possible
- Side effects isolated and minimised
- Dependency injection patterns enable test substitution

---

### FUNC-022: Unit Test Support

**Category**: Critical | **Scope**: Function, Module

All public functions must have corresponding unit tests. Code coverage minimum 80% for critical functions. All parameter combinations tested. Error conditions explicitly tested. Refer to [standards-testing.md](standards-testing.md).

---

## Documentation Standards

### FUNC-023: Function Documentation

**Category**: Important | **Scope**: Function, Module

All public functions must include complete comment-based help. Refer to [standards-documentation.md](standards-documentation.md) for detailed requirements.

---

### FUNC-024: Comment-Based Help Completeness

**Category**: Critical | **Scope**: Function

```powershell
function Get-UserAccount {
    <#
    .SYNOPSIS
        Retrieves a user account by identity.

    .DESCRIPTION
        Retrieves a user account object from the identity store by the specified identity.
        Supports pipeline input for batch retrieval operations.

    .PARAMETER Identity
        The user identity (username, UPN, or object ID) to retrieve.

    .EXAMPLE
        Get-UserAccount -Identity 'jdoe'

        Retrieves the user account for 'jdoe'.

    .EXAMPLE
        'jdoe', 'asmith' | Get-UserAccount

        Retrieves user accounts for multiple identities via pipeline.

    .INPUTS
        System.String. Identity values can be piped to this function.

    .OUTPUTS
        PSCustomObject. Returns a user account object with identity and status properties.

    .NOTES
        Requires read access to the identity store.
        See Set-UserAccount for modification operations.

    .LINK
        Set-UserAccount
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Identity
    )
}
```

---

### FUNC-025: Usage Examples

**Category**: Important | **Scope**: Function, Module

- Examples are executable without modification
- Common usage patterns demonstrated
- Pipeline usage examples included
- Error handling examples provided
- Expected output shown in comments

---

## Security Standards

### FUNC-026: Credential Security

**Category**: Critical | **Scope**: Function, Module

Credential parameters use `[PSCredential]` type. `[SecureString]` used for password values. No plaintext credentials in any output stream. Credentials not logged at any verbosity level. Refer to [standards-coding.md CODE-013](standards-coding.md).

---

### FUNC-027: Data Protection

**Category**: Important | **Scope**: Function, Module

Sensitive data sanitised before any output stream. Temporary storage of sensitive data minimised. Secure disposal patterns applied for sensitive objects.

---

## Compatibility Standards

### FUNC-028: Backward Compatibility

**Category**: Important | **Scope**: Function, Module, Repository

- New parameters added as optional with defaults
- Existing parameter behaviour not changed in minor versions
- Breaking changes reserved for major version increments
- Deprecated parameters marked with `[Obsolete()]` attribute before removal
- Migration notes included in `CHANGELOG.md` for breaking changes

---

## Related Resources

- [Microsoft — about_Functions_Advanced](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced)
- [Microsoft — about_Functions_Advanced_Parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters)
- [Microsoft — Cmdlet Development Guidelines](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [Microsoft — Write-Progress](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress)
- [Pester Testing Framework](https://pester.dev/)
- [standards-overview.md](standards-overview.md)
- [standards-coding.md](standards-coding.md)
- [standards-documentation.md](standards-documentation.md)
- [standards-error-handling.md](standards-error-handling.md)
- [standards-testing.md](standards-testing.md)
