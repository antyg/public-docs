# PowerShell Module Architecture Standards

## Metadata

- **Document Type**: Architecture Standards
- **Version**: 1.0.0
- **Last Updated**: 2025-08-24
- **Standards Count**: 25 Architecture Standards
- **Cross-References**: [Overview](PSEval-Standards-Overview.md) | [Coding](PSEval-Standards-Coding.md) | [Functions](PSEval-Standards-Functions.md)

## Executive Summary

Architecture standards define the structural requirements for PowerShell modules, covering organization, manifests, file hierarchies, and deployment patterns. These standards ensure modules are maintainable, discoverable, and follow enterprise-grade organizational principles.

## Module Structure Standards

### ARCH-001: Module Manifest Required

**Category**: Critical
**Level**: Module, Repository, Enterprise
**Cross-References**: [DOC-001](PSEval-Standards-Documentation.md#DOC-001)

#### Description

Every PowerShell module must include a properly formatted module manifest (.psd1) file with required metadata and configuration.

#### Explicit Standard Definition

- Module manifest file must be present with same name as module
- Manifest must contain minimum required fields: ModuleVersion, GUID, Author, Description
- Manifest must validate successfully with Test-ModuleManifest
- Manifest version must follow semantic versioning (Major.Minor.Patch)

#### Evaluation Methods

##### Enterprise Level

- Automated scan of all module directories for .psd1 files
- Manifest validation across entire module inventory
- Version compliance reporting by organizational unit

##### Repository Level

- Repository-wide manifest presence verification
- Cross-module manifest consistency checking
- Automated manifest validation in CI/CD pipelines

##### Module Level

- Individual module manifest validation
- Required field presence verification
- Semantic version format compliance

#### Compliance Criteria

- [ ] Module manifest file exists and matches module name
- [ ] Test-ModuleManifest passes without errors
- [ ] ModuleVersion follows semantic versioning format
- [ ] GUID is present and valid format
- [ ] Author field is populated
- [ ] Description is meaningful and non-empty

#### Examples

```powershell
# Good example - Complete manifest
@{
    RootModule = 'MyModule.psm1'
    ModuleVersion = '1.2.3'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Development Team'
    Description = 'Comprehensive user management module for enterprise environments'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-UserAccount', 'Set-UserAccount')
}

# Bad example - Missing required fields
@{
    RootModule = 'MyModule.psm1'
    # Missing ModuleVersion, GUID, Author, Description
}
```

### ARCH-002: Standard Directory Structure

**Category**: Critical
**Level**: Module, Repository, Enterprise
**Cross-References**: [CODE-005](PSEval-Standards-Coding.md#CODE-005)

#### Description

Modules must follow standardized directory structure for consistent organization and maintainability.

#### Explicit Standard Definition

- Root module directory contains manifest (.psd1) and primary module (.psm1)
- Public functions in dedicated Public/ subdirectory
- Private functions in dedicated Private/ subdirectory
- Documentation in docs/ or Docs/ subdirectory
- Tests in Tests/ subdirectory with Unit/ and Integration/ subfolders

#### Evaluation Methods

##### Enterprise Level

- Organization-wide directory structure compliance analysis
- Standardization metrics across all modules
- Best practice adoption trending

##### Module Level

- Directory presence verification
- File placement compliance checking
- Structure consistency assessment

#### Compliance Criteria

- [ ] Public/ directory exists and contains public function files
- [ ] Private/ directory exists (if private functions present)
- [ ] Tests/ directory exists with appropriate test files
- [ ] Documentation directory exists (docs/ or Docs/)
- [ ] Root directory contains only manifest, main module, and required files

#### Examples

```plaintext
# Good example - Standard structure
MyModule/
├── scripts/               # business logic scripts directory.. Used for orchestration scripts that call module functions.
├── src/
│   ├── MyModule.psd1          # Module manifest
│   ├── MyModule.psm1          # Main module file
│   ├── Public/                # Public functions
│   │   ├── Get-Something.ps1
│   │   └── Set-Something.ps1
│   ├── Private/               # Private functions
│   │   └── Invoke-Helper.ps1
│   └── Tests/                 # Test files
│       ├── Fixtures/          # Test fixtures, samples, and mock data
│       ├── Unit/
│       └── Integration/
├── docs/                      # Documentation
│   ├── Design.md              # Design documentation
│   ├── UserGuide.md           # User guide documentation
│   └── APIReference.md        # API reference documentation
└── README.md                  # Root README file

# Bad example - Disorganized structure
MyModule/
├── MyModule.psd1
├── MyModule.psm1
├── SomeFunction.ps1      # Should be in Public/
├── helper.ps1           # Should be in Private/
└── test.ps1             # Should be in Tests/
```

### ARCH-003: Semantic Version Compliance

**Category**: Important
**Level**: Module, Repository, Enterprise
**Cross-References**: [ARCH-001](#ARCH-001)

#### Description

Module versions must follow semantic versioning specification for consistent version management and dependency resolution.

#### Explicit Standard Definition

- Version format must be MAJOR.MINOR.PATCH (e.g., 1.2.3)
- MAJOR version incremented for breaking changes
- MINOR version incremented for backward-compatible functionality additions
- PATCH version incremented for backward-compatible bug fixes
- Pre-release versions use MAJOR.MINOR.PATCH-prerelease format

#### Evaluation Methods

##### Enterprise Level

- Organization-wide version format compliance
- Breaking change tracking across major versions
- Dependency compatibility analysis

##### Module Level

- Individual module version format validation
- Version increment appropriateness review
- Change documentation alignment with version changes

#### Compliance Criteria

- [ ] Version follows MAJOR.MINOR.PATCH format
- [ ] Version increments align with change types
- [ ] Breaking changes documented with major version updates
- [ ] Pre-release versions properly formatted when applicable

### ARCH-004: Module Export Declaration

**Category**: Critical
**Level**: Module, Repository, Enterprise
**Cross-References**: [FUNC-001](PSEval-Standards-Functions.md#FUNC-001)

#### Description

Modules must explicitly declare which functions, cmdlets, variables, and aliases to export rather than using wildcard exports.

#### Explicit Standard Definition

- FunctionsToExport explicitly lists all public functions
- CmdletsToExport explicitly lists all cmdlets (typically empty for script modules)
- VariablesToExport explicitly lists exported variables (typically empty)
- AliasesToExport explicitly lists exported aliases
- No wildcard (\*) exports permitted

#### Evaluation Methods

##### Module Level

- Manifest export section analysis
- Comparison of declared exports with actual Public/ directory contents
- Wildcard export detection

#### Compliance Criteria

- [ ] FunctionsToExport contains specific function names, not wildcards
- [ ] All public functions are declared in FunctionsToExport
- [ ] No unlisted functions are exported from Public/ directory
- [ ] CmdletsToExport, VariablesToExport, AliasesToExport are explicitly defined

#### Examples

```powershell
# Good example - Explicit exports
@{
    FunctionsToExport = @('Get-UserAccount', 'Set-UserPassword', 'New-UserProfile')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}

# Bad example - Wildcard exports
@{
    FunctionsToExport = '*'
    CmdletsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
}
```

### ARCH-005: Module Loading Pattern

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [ERR-001](PSEval-Standards-ErrorHandling.md#ERR-001)

#### Description

Main module file (.psm1) must implement proper loading patterns with error handling and validation.

#### Explicit Standard Definition

- Module file dot-sources all public and private function files
- Loading includes error handling for missing or invalid files
- Module exports only intended public functions
- Loading process includes verbose logging for troubleshooting
- Module cleanup handler is implemented for proper resource management

#### Evaluation Methods

##### Module Level

- Module file loading pattern analysis
- Error handling presence verification
- Export mechanism validation

#### Compliance Criteria

- [ ] Dot-sourcing of function files includes error handling
- [ ] Verbose logging present during module loading
- [ ] Export-ModuleMember used correctly or manifest export declarations followed
- [ ] Module cleanup handler implemented (OnRemove)

### ARCH-006: Required Files Presence

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [DOC-002](PSEval-Standards-Documentation.md#DOC-002)

#### Description

Modules must include essential documentation and metadata files for enterprise environments.

#### Explicit Standard Definition

- README.md file present with module description and usage
- CHANGELOG.md file present with version history
- LICENSE file present with appropriate license information
- Examples directory or file with usage examples

#### Evaluation Methods

##### Module Level

- Required file presence verification
- File content quality assessment
- Documentation completeness evaluation

#### Compliance Criteria

- [ ] README.md exists and contains meaningful content
- [ ] CHANGELOG.md exists and tracks version changes
- [ ] LICENSE file exists with appropriate license
- [ ] Examples are provided in dedicated location

### ARCH-007: Dependency Management

**Category**: Important
**Level**: Module, Repository, Enterprise
**Cross-References**: [ARCH-001](#ARCH-001)

#### Description

Module dependencies must be properly declared and managed through manifest RequiredModules section.

#### Explicit Standard Definition

- All module dependencies declared in RequiredModules
- Dependency versions specified with minimum required version
- PowerShell version requirement specified
- .NET Framework version specified when applicable
- No undeclared dependencies used in module code

#### Evaluation Methods

##### Module Level

- Manifest RequiredModules analysis
- Code analysis for undeclared module usage
- Version requirement validation

#### Compliance Criteria

- [ ] RequiredModules section populated with all dependencies
- [ ] Dependency versions specified appropriately
- [ ] PowerShellVersion requirement specified
- [ ] No Import-Module commands for undeclared dependencies

## File Organization Standards

### ARCH-008: Function File Naming

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [CODE-002](PSEval-Standards-Coding.md#CODE-002)

#### Description

Individual function files must follow consistent naming conventions matching the contained function.

#### Explicit Standard Definition

- Each public function in separate file named exactly as function
- File names use Verb-Noun pattern matching function names
- Files contain only one primary function
- File extension is .ps1 for all function files

#### Evaluation Methods

##### Module Level

- File naming consistency verification
- Function-to-file mapping validation
- Single-function-per-file compliance

#### Compliance Criteria

- [ ] Function files named identically to contained functions
- [ ] One primary function per file
- [ ] Verb-Noun naming pattern followed
- [ ] .ps1 extension used consistently

### ARCH-009: Resource Organization

**Category**: Recommended
**Level**: Module

#### Description

Static resources and data files should be organized in dedicated subdirectories.

#### Explicit Standard Definition

- Data files in Data/ subdirectory
- Type extensions in Types/ subdirectory
- Format files in Formats/ subdirectory
- Binary resources in Resources/ subdirectory

#### Evaluation Methods

##### Module Level

- Resource directory presence evaluation
- File type appropriate placement verification

#### Compliance Criteria

- [ ] Data files organized in appropriate subdirectory
- [ ] Type and format files in dedicated locations
- [ ] Binary resources properly organized

## Module Types and Patterns

### ARCH-010: Script Module Standards

**Category**: Important
**Level**: Module
**Cross-References**: [ARCH-001](#ARCH-001)

#### Description

Script modules must follow specific patterns for proper functionality and maintainability.

#### Explicit Standard Definition

- RootModule in manifest points to .psm1 file
- Primary module file implements proper loading patterns
- Module uses #Requires statements for dependencies
- Module version matches manifest version

#### Evaluation Methods

##### Module Level

- Script module structure validation
- Loading pattern compliance verification
- Version consistency checking

#### Compliance Criteria

- [ ] RootModule correctly references .psm1 file
- [ ] Loading patterns follow standards
- [ ] #Requires statements present for major dependencies
- [ ] Version consistency maintained

### ARCH-011: Binary Module Support

**Category**: Recommended
**Level**: Module, Repository

#### Description

When binary modules are used, they must include proper metadata and integration.

#### Explicit Standard Definition

- Binary modules include comprehensive manifest
- Help files included for all cmdlets
- Type and format files provided when applicable
- Assembly loading handled properly

#### Evaluation Methods

##### Module Level

- Binary module manifest completeness
- Help file presence verification
- Assembly integration assessment

#### Compliance Criteria

- [ ] Comprehensive manifest for binary modules
- [ ] Help documentation for all cmdlets
- [ ] Proper assembly loading implementation

## Deployment and Distribution Standards

### ARCH-012: Installation Path Standards

**Category**: Important
**Level**: Enterprise
**Cross-References**: [ARCH-002](#ARCH-002)

#### Description

Modules must be deployable to standard PowerShell module paths without conflicts.

#### Explicit Standard Definition

- Module structure compatible with PowerShell module paths
- No hardcoded paths in module code
- Module self-contained without external file dependencies
- Installation works in both user and system scopes

#### Evaluation Methods

##### Enterprise Level

- Deployment testing across different scopes
- Path independence verification
- Installation conflict detection

#### Compliance Criteria

- [ ] Module deploys successfully to standard paths
- [ ] No hardcoded paths in module files
- [ ] Module functions properly in different installation scopes

### ARCH-013: Module Versioning Strategy

**Category**: Important
**Level**: Repository, Enterprise
**Cross-References**: [ARCH-003](#ARCH-003)

#### Description

Module versioning must support side-by-side installation and proper upgrade paths.

#### Explicit Standard Definition

- Version directories used for side-by-side installations
- Backward compatibility maintained within major versions
- Breaking changes require major version increments
- Clear migration documentation for breaking changes

#### Evaluation Methods

##### Repository Level

- Version compatibility analysis
- Breaking change documentation review
- Side-by-side installation testing

#### Compliance Criteria

- [ ] Side-by-side version installation supported
- [ ] Backward compatibility maintained appropriately
- [ ] Breaking changes properly documented and versioned

### ARCH-014: Manifest Metadata Completeness

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [ARCH-001](#ARCH-001), [DOC-001](PSEval-Standards-Documentation.md#DOC-001)

#### Description

Module manifests must include comprehensive metadata for discoverability and management.

#### Explicit Standard Definition

- Author and CompanyName fields populated
- Copyright information included
- Description is comprehensive and searchable
- Tags array includes relevant keywords
- ProjectUri and LicenseUri provided when applicable
- HelpInfoURI configured for updateable help

#### Evaluation Methods

##### Module Level

- Manifest metadata completeness assessment
- Searchability and discoverability evaluation
- External URI validation

#### Compliance Criteria

- [ ] Author and CompanyName specified
- [ ] Copyright information present
- [ ] Description comprehensive and meaningful
- [ ] Tags array populated with relevant terms
- [ ] External URIs valid when provided

### ARCH-015: Configuration Management

**Category**: Recommended
**Level**: Module, Repository

#### Description

Modules requiring configuration should implement standardized configuration patterns.

#### Explicit Standard Definition

- Configuration files in Data/ subdirectory
- Default configuration embedded in module
- Configuration override mechanisms provided
- Configuration validation implemented

#### Evaluation Methods

##### Module Level

- Configuration pattern implementation review
- Default configuration presence verification
- Override mechanism testing

#### Compliance Criteria

- [ ] Configuration files properly organized
- [ ] Default configuration available
- [ ] Configuration override mechanisms work correctly
- [ ] Configuration validation prevents invalid settings

## Performance and Scalability Standards

### ARCH-016: Module Loading Performance

**Category**: Important
**Level**: Module, Repository

#### Description

Modules must load efficiently without causing significant startup delays.

#### Explicit Standard Definition

- Module loading completes within 2 seconds on standard hardware
- Lazy loading used for expensive operations
- Minimal external module dependencies at load time
- No network calls during module loading

#### Evaluation Methods

##### Module Level

- Module loading time measurement
- Dependency analysis during loading
- Network activity monitoring during import

#### Compliance Criteria

- [ ] Module loads within acceptable time limits
- [ ] No unnecessary operations during loading
- [ ] External dependencies minimized at load time

### ARCH-017: Memory Management

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [CODE-010](PSEval-Standards-Coding.md#CODE-010)

#### Description

Modules must implement proper memory management and resource cleanup.

#### Explicit Standard Definition

- Module cleanup handler removes module-scoped variables
- Large objects properly disposed when no longer needed
- Event handlers properly unregistered
- Temporary files cleaned up appropriately

#### Evaluation Methods

##### Module Level

- Memory usage analysis during module lifecycle
- Resource cleanup verification
- Memory leak detection

#### Compliance Criteria

- [ ] Module cleanup handler implemented
- [ ] Resource disposal patterns followed
- [ ] No memory leaks during normal operations

## Security and Compliance Standards

### ARCH-018: Code Signing Requirements

**Category**: Important
**Level**: Enterprise
**Cross-References**: [Evaluation Methods](PSEval-Evaluation-Methods.md)

#### Description

Enterprise modules should be digitally signed for security and authenticity.

#### Explicit Standard Definition

- Module files digitally signed with appropriate certificate
- Signature verification passes on target systems
- Certificate chain valid and trusted
- Timestamp included in signatures

#### Evaluation Methods

##### Enterprise Level

- Code signature verification across module inventory
- Certificate validity and trust chain analysis
- Signature policy compliance assessment

#### Compliance Criteria

- [ ] Module files properly signed
- [ ] Signatures verify successfully
- [ ] Certificate trust chain valid
- [ ] Timestamps present in signatures

### ARCH-019: Execution Policy Compliance

**Category**: Important
**Level**: Enterprise

#### Description

Modules must work within enterprise execution policy constraints.

#### Explicit Standard Definition

- Modules function under RemoteSigned execution policy
- No bypass mechanisms or policy circumvention
- Clear documentation of execution policy requirements
- Alternative installation methods for restricted environments

#### Evaluation Methods

##### Enterprise Level

- Execution policy compatibility testing
- Policy compliance verification
- Restricted environment deployment testing

#### Compliance Criteria

- [ ] Functions under standard execution policies
- [ ] No policy circumvention mechanisms
- [ ] Execution policy requirements documented
- [ ] Alternative deployment options available

## Quality Assurance Standards

### ARCH-020: Static Analysis Compliance

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [Evaluation Automation](PSEval-Evaluation-Automation.md)

#### Description

Modules must pass static analysis tools without critical violations.

#### Explicit Standard Definition

- PSScriptAnalyzer rules pass without errors
- Custom organizational rules compliance
- Security-focused analysis rules satisfied
- Performance analysis recommendations addressed

#### Evaluation Methods

##### Module Level

- PSScriptAnalyzer execution and results analysis
- Custom rule compliance verification
- Security and performance analysis

#### Compliance Criteria

- [ ] PSScriptAnalyzer passes without errors
- [ ] Custom organizational rules satisfied
- [ ] Security analysis findings addressed
- [ ] Performance recommendations implemented

### ARCH-021: Automated Testing Integration

**Category**: Important
**Level**: Module, Repository
**Cross-References**: [Testing Standards](PSEval-Standards-Testing.md)

#### Description

Module structure must support automated testing and CI/CD integration.

#### Explicit Standard Definition

- Tests directory structure supports automated discovery
- Test files follow naming conventions for automation
- Build and deployment scripts included
- CI/CD pipeline configuration provided

#### Evaluation Methods

##### Repository Level

- Automated testing pipeline verification
- Test discovery and execution validation
- CI/CD integration assessment

#### Compliance Criteria

- [ ] Test structure supports automation
- [ ] Build scripts present and functional
- [ ] CI/CD configuration appropriate
- [ ] Automated testing integrates successfully

## Documentation Integration Standards

### ARCH-022: Help System Integration

**Category**: Important
**Level**: Module
**Cross-References**: [Documentation Standards](PSEval-Standards-Documentation.md)

#### Description

Module architecture must support PowerShell's built-in help system.

#### Explicit Standard Definition

- Comment-based help or external XML help provided
- About topics included for complex modules
- Updateable help supported when applicable
- Help content integrated with module structure

#### Evaluation Methods

##### Module Level

- Help system integration verification
- Help content accessibility testing
- Updateable help configuration validation

#### Compliance Criteria

- [ ] Help content available through Get-Help
- [ ] About topics provided when appropriate
- [ ] Updateable help configured correctly
- [ ] Help integrates with module architecture

### ARCH-023: Cross-Platform Compatibility

**Category**: Recommended
**Level**: Module, Repository

#### Description

Modules should consider cross-platform compatibility where applicable.

#### Explicit Standard Definition

- Path separators use PowerShell-appropriate methods
- Platform-specific functionality properly abstracted
- Cross-platform testing performed when relevant
- Platform limitations documented clearly

#### Evaluation Methods

##### Module Level

- Cross-platform compatibility assessment
- Platform-specific code identification
- Compatibility testing results review

#### Compliance Criteria

- [ ] Platform-appropriate path handling
- [ ] Platform-specific code properly abstracted
- [ ] Cross-platform testing performed
- [ ] Platform limitations documented

### ARCH-024: Module Discoverability

**Category**: Recommended
**Level**: Module, Repository
**Cross-References**: [ARCH-014](#ARCH-014)

#### Description

Modules must be easily discoverable through standard PowerShell mechanisms.

#### Explicit Standard Definition

- Module appears in Get-Module -ListAvailable
- Appropriate tags and metadata for searching
- Description supports keyword-based discovery
- Module integrates with PowerShell Gallery when applicable

#### Evaluation Methods

##### Module Level

- Discoverability testing through standard cmdlets
- Metadata appropriateness evaluation
- Search result optimization assessment

#### Compliance Criteria

- [ ] Module discoverable through standard mechanisms
- [ ] Metadata optimized for searching
- [ ] Description supports keyword discovery
- [ ] Gallery integration appropriate

### ARCH-025: Module Lifecycle Management

**Category**: Important
**Level**: Repository, Enterprise
**Cross-References**: [ARCH-013](#ARCH-013)

#### Description

Module architecture must support complete lifecycle management including updates and removal.

#### Explicit Standard Definition

- Clean uninstallation process available
- Update mechanisms preserve user data
- Version migration paths documented
- Deprecation process clearly defined

#### Evaluation Methods

##### Enterprise Level

- Lifecycle management process validation
- Update and migration testing
- Deprecation process compliance verification

#### Compliance Criteria

- [ ] Clean uninstallation available
- [ ] Update processes preserve data
- [ ] Migration paths documented
- [ ] Deprecation process defined

---

## Cross-References

### Related Standards Documents

- **[PSEval-Standards-Overview.md](PSEval-Standards-Overview.md)** - Complete standards framework overview
- **[PSEval-Standards-Coding.md](PSEval-Standards-Coding.md)** - Coding standards and conventions
- **[PSEval-Standards-Functions.md](PSEval-Standards-Functions.md)** - Function and cmdlet design standards
- **[PSEval-Standards-Documentation.md](PSEval-Standards-Documentation.md)** - Documentation and help standards
- **[PSEval-Standards-ErrorHandling.md](PSEval-Standards-ErrorHandling.md)** - Error handling standards
- **[PSEval-Standards-Testing.md](PSEval-Standards-Testing.md)** - Testing and validation standards

### Evaluation Documents

- **[PSEval-Evaluation-Methods.md](PSEval-Evaluation-Methods.md)** - Evaluation methodologies
- **[PSEval-Evaluation-Checklists.md](PSEval-Evaluation-Checklists.md)** - Practical checklists
- **[PSEval-Evaluation-Automation.md](PSEval-Evaluation-Automation.md)** - Automated evaluation tools

---

_This document contains 25 architecture standards for PowerShell module evaluation. For complete evaluation framework, reference all standards documents and evaluation tools._
