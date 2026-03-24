---
title: "PowerShell Error Handling and Debugging Standards"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Module Authors"
document_type: "reference"
domain: "development"
---

# PowerShell Error Handling and Debugging Standards

22 error handling standards governing comprehensive requirements for exception management, error reporting, debugging capabilities, and resilience patterns. Derived from [Microsoft's error handling documentation](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-error-reporting) and [about_Try_Catch_Finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally).

---

## Exception Handling Standards

### ERR-001: Try-Catch Implementation

**Category**: Critical | **Scope**: Function, Module, Repository

All functions must implement comprehensive `try-catch` blocks for error-prone operations with appropriate exception handling.

**Requirements:**

- `try-catch` blocks wrap all error-prone operations (network calls, file I/O, external service calls)
- Specific exception types caught and handled appropriately
- `finally` blocks used for resource cleanup (connections, file handles, temporary objects)
- Nested `try-catch` blocks avoided where possible — extract to helper functions instead
- Exception context preserved for debugging

**Compliance criteria:**

- [ ] `try-catch` blocks implemented for error-prone operations
- [ ] Specific exception types handled
- [ ] `finally` blocks used for cleanup
- [ ] Exception context preserved
- [ ] Nested blocks minimised

```powershell
function Connect-RemoteService {
    [CmdletBinding()]
    param([string]$Endpoint)
    process {
        $connection = $null
        try {
            $connection = [RemoteServiceClient]::new($Endpoint)
            $connection.Connect()
            $connection
        }
        catch [System.Net.WebException] {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                $_.Exception,
                'ConnectionFailed',
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $Endpoint
            )
            $PSCmdlet.WriteError($errorRecord)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally {
            if ($connection -and -not $connection.IsConnected) {
                $connection.Dispose()
            }
        }
    }
}
```

---

### ERR-002: Error Record Construction

**Category**: Critical | **Scope**: Function, Module

Error records must be constructed with complete information including proper categorisation and target objects.

**Requirements:**

- `[System.Management.Automation.ErrorRecord]` objects created with all required parameters:
  1. `Exception` — the underlying .NET exception
  2. `ErrorId` — unique, descriptive error identifier string
  3. `ErrorCategory` — appropriate [`ErrorCategory`](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.errorcategory) enum value
  4. `TargetObject` — the object being acted upon when the error occurred
- Error categories assigned appropriately
- Error IDs are descriptive and unique within the module
- Recommended actions provided when applicable

**Compliance criteria:**

- [ ] `ErrorRecord` objects properly constructed with all 4 required parameters
- [ ] Error categories appropriate (see table below)
- [ ] Target objects included
- [ ] Error IDs descriptive and unique
- [ ] Recommended actions provided where helpful

**Common error categories:**

| Category | When to Use |
|---|---|
| `ObjectNotFound` | Target object does not exist |
| `ConnectionError` | Network or service connection failure |
| `AuthenticationError` | Authentication or authorisation failure |
| `InvalidArgument` | Parameter value is invalid |
| `OperationTimeout` | Operation exceeded time limit |
| `PermissionDenied` | Insufficient permissions |
| `ResourceUnavailable` | Required resource not available |
| `WriteError` | Write operation failed |
| `ReadError` | Read operation failed |

```powershell
# Compliant — full error record construction
$errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [System.IO.FileNotFoundException]::new("Configuration file not found: $Path"),
    'ConfigurationFileNotFound',
    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
    $Path
)
$PSCmdlet.WriteError($errorRecord)
```

---

### ERR-003: Exception Type Specificity

**Category**: Important | **Scope**: Function

Catch blocks must handle specific exception types rather than using generic exception handling.

**Requirements:**

- Specific exception types caught individually
- Most specific exceptions caught first (before parent types)
- Generic `catch` blocks used only as fallback for truly unexpected exceptions
- Exception type hierarchy respected
- Custom exceptions created and used when appropriate

**Compliance criteria:**

- [ ] Specific exception types caught
- [ ] Most specific exceptions first
- [ ] Generic `catch` as fallback only
- [ ] Exception hierarchy respected
- [ ] Custom exceptions used appropriately

```powershell
try {
    Invoke-RestMethod -Uri $Uri -Credential $Credential
}
catch [System.Net.Http.HttpRequestException] {
    # HTTP-specific handling
    Write-Error "HTTP request failed: $($_.Exception.Message)"
}
catch [System.UnauthorizedAccessException] {
    # Auth-specific handling
    Write-Error "Authentication failed for URI: $Uri"
}
catch [System.TimeoutException] {
    # Timeout-specific handling
    Write-Error "Request timed out after $TimeoutSeconds seconds"
}
catch {
    # Generic fallback — unexpected errors
    $PSCmdlet.ThrowTerminatingError($_)
}
```

---

## Error Reporting and Logging

### ERR-004: Error Message Quality

**Category**: Important | **Scope**: Function, Module

Error messages must be clear, actionable, and provide sufficient context for troubleshooting.

**Requirements:**

- Error messages written in clear, professional language
- Specific details included about what failed and why
- Actionable guidance provided when possible ("Check that the file exists and you have read access")
- Technical jargon explained or avoided
- Context information sufficient for troubleshooting (what was attempted, what the target was, what the expected state was)

**Compliance criteria:**

- [ ] Messages clear and professional
- [ ] Specific failure details included
- [ ] Actionable guidance provided
- [ ] Technical terms explained
- [ ] Context sufficient for troubleshooting

---

### ERR-005: Centralised Error Management

**Category**: Important | **Scope**: Module, Repository

Modules should implement centralised error management for consistent error handling and logging:

- Centralised error management function or class implemented
- Consistent error logging across all module functions
- Error correlation and tracking implemented
- Error statistics and metrics collected
- Configuration options for error handling behaviour provided

---

### ERR-006: Security-Safe Error Reporting

**Category**: Critical | **Scope**: Function, Module

Error messages and logs must not expose sensitive information or security details. This is mandatory — security information leakage through error messages is a common vulnerability.

**Requirements:**

- Sensitive data excluded from all error messages and logs
- Credentials never logged or exposed in any output stream
- File paths sanitised in error messages (avoid exposing infrastructure paths)
- Stack traces filtered for security information before user-facing output
- Error details appropriate for the intended audience (detailed internal logs, sanitised user-facing messages)

**Compliance criteria:**

- [ ] Sensitive data excluded from errors
- [ ] Credentials never exposed
- [ ] File paths appropriately sanitised
- [ ] Stack traces filtered
- [ ] Error details audience-appropriate

```powershell
# Non-compliant — exposes credentials and internal paths
catch {
    Write-Error "Failed to connect with password: $Password to \\internal-server\admin$"
}

# Compliant — sanitised error message
catch {
    Write-Error "Failed to connect to remote service. Check credentials and network connectivity."
    Write-Verbose "Connection target: $Endpoint"  # Path info in Verbose only
}
```

---

## Resilience and Recovery Patterns

### ERR-007: Retry Logic Implementation

**Category**: Important | **Scope**: Function, Module

Functions performing operations that may fail transiently should implement appropriate retry logic.

**Requirements:**

- Retry logic implemented for transient failures (network timeouts, rate limiting, temporary service unavailability)
- Exponential backoff used for retry delays (e.g., 1s, 2s, 4s, 8s)
- Maximum retry attempts configurable (parameter or configuration value)
- Retry conditions clearly defined — not all errors are retriable
- Non-retryable errors identified and handled immediately without retry

**Compliance criteria:**

- [ ] Retry logic implemented appropriately
- [ ] Exponential backoff used
- [ ] Maximum retries configurable
- [ ] Retry conditions clearly defined
- [ ] Non-retryable errors identified

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$InitialDelaySeconds = 1
    )
    $attempt  = 0
    $delay    = $InitialDelaySeconds
    do {
        try {
            & $ScriptBlock
            return
        }
        catch [System.Net.WebException] {
            $attempt++
            if ($attempt -ge $MaxRetries) { throw }
            Write-Verbose "Attempt $attempt failed. Retrying in $delay seconds..."
            Start-Sleep -Seconds $delay
            $delay = $delay * 2   # Exponential backoff
        }
    } while ($attempt -lt $MaxRetries)
}
```

---

### ERR-008: Circuit Breaker Pattern

**Category**: Recommended | **Scope**: Module

Modules accessing external resources should implement [circuit breaker patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker) for resilience:

- Circuit breaker implemented for external dependencies
- Failure thresholds configurable
- Recovery mechanisms implemented (half-open state)
- Fallback operations provided where possible
- Circuit state monitoring available

---

### ERR-009: Graceful Degradation

**Category**: Important | **Scope**: Function, Module

Functions should provide graceful degradation when full functionality cannot be achieved:

- Partial functionality maintained under error conditions
- Degraded operation mode clearly communicated to the user
- Essential functions prioritised over optional ones
- User informed of reduced functionality with `Write-Warning`
- Recovery to full functionality supported when conditions improve

---

## Debugging and Diagnostic Standards

### ERR-010: Verbose and Debug Output

**Category**: Important | **Scope**: Function, Module

Functions must provide comprehensive verbose and debug output to support troubleshooting. These are available through common parameters — no custom mechanism required.

**Requirements:**

- [`Write-Verbose`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-verbose) used for operation progress (visible with `-Verbose`)
- [`Write-Debug`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-debug) used for detailed diagnostic information (visible with `-Debug`)
- Debug output includes variable states and flow control decisions
- Verbose output meaningful for end users (not raw debug noise)
- Debug/verbose output performance-optimised (avoid expensive operations in verbose strings)

**Compliance criteria:**

- [ ] `Write-Verbose` used for progress reporting
- [ ] `Write-Debug` used for diagnostics
- [ ] Debug output includes state information
- [ ] Verbose output user-meaningful
- [ ] Performance impact minimised

```powershell
process {
    Write-Verbose "Processing user: $Identity"
    Write-Debug "UserObject state: $($user | ConvertTo-Json -Compress)"

    try {
        $result = Get-RemoteUser -Identity $Identity
        Write-Verbose "Successfully retrieved user '$Identity'"
        $result
    }
    catch {
        Write-Debug "Exception type: $($_.Exception.GetType().FullName)"
        $PSCmdlet.WriteError($_)
    }
}
```

---

### ERR-011: Error Context Preservation

**Category**: Important | **Scope**: Function

Error handling must preserve complete context information for effective debugging:

- Original exceptions preserved as inner exception when wrapping
- Call stack information maintained
- Variable states captured at error time (via `Write-Debug`)
- Execution context preserved
- Error correlation IDs used for complex multi-step operations

---

### ERR-012: Performance Monitoring Integration

**Category**: Recommended | **Scope**: Function, Module

Error handling should integrate with performance monitoring:

- Performance metrics collected during error conditions
- Timeout-related errors specifically identified and categorised
- Resource exhaustion errors tracked
- Performance degradation patterns monitored
- Performance-related error prevention implemented

---

## Testing and Validation Integration

### ERR-013: Error Condition Testing

**Category**: Important | **Scope**: Function, Module

All error handling paths must be thoroughly tested. Refer to [standards-testing.md](standards-testing.md) for testing framework requirements.

**Requirements:**

- Error conditions explicitly tested with [Pester](https://pester.dev/)
- Exception handling paths covered by tests
- Error message accuracy validated
- Recovery mechanisms tested
- Edge cases included in error testing

```powershell
# Pester test example
Describe 'Get-UserAccount' {
    Context 'When user does not exist' {
        It 'writes a non-terminating error' {
            Mock Get-RemoteUser { throw [System.IO.FileNotFoundException]::new('User not found') }
            $errors = @()
            Get-UserAccount -Identity 'nonexistent' -ErrorVariable errors -ErrorAction SilentlyContinue
            $errors.Count | Should -Be 1
            $errors[0].CategoryInfo.Category | Should -Be 'ObjectNotFound'
        }
    }
}
```

---

### ERR-014: Mock and Simulation Testing

**Category**: Important | **Scope**: Function, Module

Error conditions should be testable through mocking and simulation:

- External dependencies mockable for error testing (via `Mock` in Pester)
- Error conditions simulatable in test environment
- Timeout and resource exhaustion testable
- Network and service failures simulatable
- Recovery scenarios testable through mocking

---

## Advanced Error Handling Patterns

### ERR-015: Error Aggregation

**Category**: Recommended | **Scope**: Function, Module

Functions processing multiple items should aggregate errors for batch operations:

- Multiple errors collected during batch processing (using `-ErrorVariable`)
- Error aggregation does not stop processing of remaining items
- Individual item failures reported separately
- Batch completion status accurately reported
- Error summary provided at completion

```powershell
# Aggregation pattern for batch processing
$batchErrors = [System.Collections.Generic.List[System.Management.Automation.ErrorRecord]]::new()
foreach ($item in $InputItems) {
    try {
        Process-Item $item
    }
    catch {
        $batchErrors.Add($_)
        Write-Warning "Failed to process item '$($item.Id)': $($_.Exception.Message)"
    }
}
if ($batchErrors.Count -gt 0) {
    Write-Warning "$($batchErrors.Count) item(s) failed during batch processing."
}
```

---

### ERR-016: Error Recovery Strategies

**Category**: Important | **Scope**: Function, Module

Functions should implement multiple recovery strategies for different failure types:

- Multiple recovery strategies implemented
- Recovery strategy selection based on error type
- Automatic recovery attempted when safe (idempotent operations)
- Manual recovery options provided (e.g., `-Force` parameter)
- Recovery success monitored and reported

---

### ERR-017: Error Event Handling

**Category**: Recommended | **Scope**: Module

Modules should support error event handling for integration with monitoring systems:

- Error events published for external consumption
- Event data structured and comprehensive
- Event publishing configurable
- Multiple event subscribers supported
- Event publishing does not impact core functionality

---

## Integration with PowerShell Error System

### ERR-018: ErrorAction Parameter Support

**Category**: Important | **Scope**: Function

Functions must properly support and respect the [`ErrorAction`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters) common parameter.

**Requirements:**

- `ErrorAction` parameter behaviour implemented correctly through `[CmdletBinding()]`
- `Stop`, `Continue`, `SilentlyContinue`, and `Ignore` all supported
- Function behaviour consistent with `ErrorAction` setting
- Non-terminating errors handled per `ErrorAction` preference
- Terminating errors thrown appropriately regardless of `ErrorAction`

**Compliance criteria:**

- [ ] `ErrorAction` parameter supported (via `[CmdletBinding()]`)
- [ ] All `ErrorAction` values handled
- [ ] Behaviour consistent with setting
- [ ] Non-terminating errors follow preference
- [ ] Terminating errors thrown appropriately

---

### ERR-019: Error Stream Integration

**Category**: Important | **Scope**: Function

Functions must properly integrate with PowerShell's [error stream](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams):

- Errors written to error stream via `$PSCmdlet.WriteError()` (non-terminating) or `$PSCmdlet.ThrowTerminatingError()` (terminating)
- Error stream redirection supported (`2>`)
- `$Error` automatic variable populated correctly
- Error stream formatting appropriate
- Error stream performance optimised

---

### ERR-020: Error Provider Integration

**Category**: Recommended | **Scope**: Module

Modules with custom providers should integrate error handling with PowerShell's provider error system:

- Provider errors follow PowerShell error conventions
- Provider error categories appropriate
- Provider-specific error handling implemented
- Error information sufficient for provider debugging
- Provider error recovery mechanisms available

---

## Error Handling Documentation and Training

### ERR-021: Error Handling Documentation

**Category**: Important | **Scope**: Function, Module

Error handling approaches and common error scenarios must be documented:

- Error handling patterns documented in module README or About topic
- Common error scenarios explained with resolution steps
- Troubleshooting guidance provided
- Error IDs catalogued for reference
- Recovery procedures documented

---

### ERR-022: Error Analysis and Improvement

**Category**: Important | **Scope**: Module, Repository, Enterprise

Error patterns should be analysed systematically to drive continuous improvement:

- Error data collected and analysed
- Error trends identified and tracked
- Root cause analysis performed for recurring errors
- Improvement opportunities identified
- Error prevention measures implemented

---

## Related Resources

- [Microsoft — Cmdlet Error Reporting](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-error-reporting)
- [Microsoft — about_Try_Catch_Finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally)
- [Microsoft — about_CommonParameters (ErrorAction)](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters)
- [Microsoft — about_Output_Streams](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams)
- [Microsoft — ErrorCategory Enum](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.errorcategory)
- [Azure Architecture — Circuit Breaker Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker)
- [Write-Verbose](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-verbose)
- [Write-Debug](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-debug)
- [Pester Testing Framework](https://pester.dev/)
- [standards-overview.md](standards-overview.md)
- [standards-functions.md](standards-functions.md)
- [standards-testing.md](standards-testing.md)
