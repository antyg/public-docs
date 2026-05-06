---
title: "PowerShell Module Architecture Standards"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Module Authors, Technical Leads"
document_type: "reference"
domain: "development"
---

# PowerShell Module Architecture Standards

25 architecture standards governing the structural requirements for PowerShell modules — covering organisation, manifests, file hierarchies, versioning, and deployment patterns. Derived from [Microsoft's Module Authoring Guidelines](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/writing-a-windows-powershell-module) and enterprise best practices.

---

## Module Structure Standards

### ARCH-001: Module Manifest Required

**Category**: Critical | **Scope**: Module, Repository, Enterprise

Every PowerShell module must include a properly formatted module manifest (`.psd1`) file with required metadata and configuration.

**Requirements:**

- Manifest file present with the same name as the module
- Manifest contains minimum required fields: `ModuleVersion`, `GUID`, `Author`, `Description`
- Manifest validates successfully with [`Test-ModuleManifest`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/test-modulemanifest)
- Manifest version follows semantic versioning (`Major.Minor.Patch`)

**Compliance criteria:**

- [ ] Manifest file exists and matches module name
- [ ] `Test-ModuleManifest` passes without errors
- [ ] `ModuleVersion` follows semantic versioning format
- [ ] `GUID` is present and valid
- [ ] `Author` field is populated
- [ ] `Description` is meaningful and non-empty

```powershell
# Compliant — complete manifest
@{
    RootModule        = 'MyModule.psm1'
    ModuleVersion     = '1.2.3'
    GUID              = '12345678-1234-1234-1234-123456789012'
    Author            = 'Development Team'
    Description       = 'Comprehensive user management module for enterprise environments'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-UserAccount', 'Set-UserAccount')
}
```

---

### ARCH-002: Standard Directory Structure

**Category**: Critical | **Scope**: Module, Repository, Enterprise

Modules must follow a standardised directory structure for consistent organisation and maintainability.

**Requirements:**

- Root module directory contains manifest (`.psd1`) and primary module file (`.psm1`)
- Public functions in dedicated `Public/` subdirectory
- Private functions in dedicated `Private/` subdirectory
- Documentation in `docs/` subdirectory
- Tests in `tests/` subdirectory with `Unit/` and `Integration/` subfolders
- Test fixtures in `tests/Fixtures/`

**Compliance criteria:**

- [ ] `Public/` directory exists and contains public function files
- [ ] `Private/` directory exists (if private functions are present)
- [ ] `tests/` directory exists with `Unit/` and `Integration/` subdirectories
- [ ] `docs/` directory exists
- [ ] Root directory contains only manifest, main module file, and required top-level files

```
MyModule/
├── src/
│   ├── MyModule.psd1          # Module manifest
│   ├── MyModule.psm1          # Main module file
│   ├── Public/                # Exported functions
│   │   ├── Get-Something.ps1
│   │   └── Set-Something.ps1
│   └── Private/               # Internal helpers
│       └── Invoke-Helper.ps1
├── tests/
│   ├── Fixtures/              # Test fixtures and mock data
│   ├── Unit/
│   └── Integration/
├── docs/
│   ├── Design.md
│   └── APIReference.md
└── README.md
```

---

### ARCH-003: Semantic Version Compliance

**Category**: Important | **Scope**: Module, Repository, Enterprise

Module versions must follow the [Semantic Versioning 2.0.0 specification](https://semver.org/) for consistent version management and dependency resolution.

**Requirements:**

- Version format: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- `MAJOR` incremented for breaking changes
- `MINOR` incremented for backward-compatible feature additions
- `PATCH` incremented for backward-compatible bug fixes
- Pre-release versions use `MAJOR.MINOR.PATCH-prerelease` format

**Compliance criteria:**

- [ ] Version follows `MAJOR.MINOR.PATCH` format
- [ ] Version increments align with change types
- [ ] Breaking changes documented with major version updates
- [ ] Pre-release versions properly formatted when applicable

---

### ARCH-004: Module Export Declaration

**Category**: Critical | **Scope**: Module, Repository, Enterprise

Modules must explicitly declare which functions, cmdlets, variables, and aliases to export. Wildcard exports are prohibited.

**Requirements:**

- `FunctionsToExport` explicitly lists all public functions
- `CmdletsToExport` explicitly lists all cmdlets (typically `@()` for script modules)
- `VariablesToExport` explicitly lists exported variables (typically `@()`)
- `AliasesToExport` explicitly lists exported aliases
- No wildcard (`*`) exports

**Compliance criteria:**

- [ ] `FunctionsToExport` contains specific function names, not wildcards
- [ ] All public functions declared in `FunctionsToExport`
- [ ] No unlisted functions exported from `Public/`
- [ ] `CmdletsToExport`, `VariablesToExport`, `AliasesToExport` are explicitly defined

```powershell
# Compliant — explicit exports
@{
    FunctionsToExport = @('Get-UserAccount', 'Set-UserPassword', 'New-UserProfile')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}

# Non-compliant — wildcard exports
@{
    FunctionsToExport = '*'   # Prohibited
}
```

---

### ARCH-005: Module Loading Pattern

**Category**: Important | **Scope**: Module, Repository

The main module file (`.psm1`) must implement proper loading patterns with error handling and validation.

**Requirements:**

- Module file dot-sources all public and private function files
- Loading includes error handling for missing or invalid files
- Module exports only intended public functions
- Loading process includes verbose logging for troubleshooting
- Module cleanup handler (`$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove`) is implemented

**Compliance criteria:**

- [ ] Dot-sourcing of function files includes error handling
- [ ] Verbose logging present during module loading
- [ ] `Export-ModuleMember` used correctly or manifest export declarations followed
- [ ] Module cleanup handler implemented

---

### ARCH-006: Required Files Presence

**Category**: Important | **Scope**: Module, Repository

Modules must include essential documentation and metadata files for enterprise environments.

**Requirements:**

- `README.md` present with module description and usage
- `CHANGELOG.md` present with version history
- `LICENSE` file present with appropriate licence information
- Examples directory or file with usage examples

**Compliance criteria:**

- [ ] `README.md` exists and contains meaningful content
- [ ] `CHANGELOG.md` exists and tracks version changes
- [ ] `LICENSE` file exists with appropriate licence
- [ ] Examples are provided in a dedicated location

---

### ARCH-007: Dependency Management

**Category**: Important | **Scope**: Module, Repository, Enterprise

Module dependencies must be properly declared and managed through the manifest `RequiredModules` section.

**Requirements:**

- All module dependencies declared in `RequiredModules`
- Dependency versions specified with minimum required version
- PowerShell version requirement specified in `PowerShellVersion`
- `.NET Framework` version specified when applicable
- No undeclared dependencies used in module code

**Compliance criteria:**

- [ ] `RequiredModules` populated with all dependencies
- [ ] Dependency versions specified appropriately
- [ ] `PowerShellVersion` requirement specified
- [ ] No `Import-Module` calls for undeclared dependencies

---

## File Organisation Standards

### ARCH-008: Function File Naming

**Category**: Important | **Scope**: Module, Repository

Individual function files must follow consistent naming conventions matching the contained function.

**Requirements:**

- Each public function in a separate file named exactly as the function
- File names use `Verb-Noun` pattern matching function names
- Files contain only one primary function
- File extension is `.ps1` for all function files

**Compliance criteria:**

- [ ] Function files named identically to contained functions
- [ ] One primary function per file
- [ ] `Verb-Noun` naming pattern followed
- [ ] `.ps1` extension used consistently

---

### ARCH-009: Resource Organisation

**Category**: Recommended | **Scope**: Module

Static resources and data files should be organised in dedicated subdirectories: `Data/` for data files, `Types/` for type extensions, `Formats/` for format files, `Resources/` for binary resources.

---

## Module Types and Patterns

### ARCH-010: Script Module Standards

**Category**: Important | **Scope**: Module

`RootModule` in the manifest must point to the `.psm1` file. The primary module file implements the standard loading pattern. `#Requires` statements declare major dependencies. Module version must match manifest version.

---

### ARCH-011: Binary Module Support

**Category**: Recommended | **Scope**: Module, Repository

Binary modules must include a comprehensive manifest, help files for all cmdlets, type and format files where applicable, and proper assembly loading.

---

## Deployment and Distribution Standards

### ARCH-012: Installation Path Standards

**Category**: Important | **Scope**: Enterprise

Modules must be deployable to standard [PowerShell module paths](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath) without conflicts. No hardcoded paths in module code. Module is self-contained. Installation works in both user and system scopes.

---

### ARCH-013: Module Versioning Strategy

**Category**: Important | **Scope**: Repository, Enterprise

Version directories used for side-by-side installation. Backward compatibility maintained within major versions. Breaking changes require major version increments. Clear migration documentation provided for breaking changes.

---

### ARCH-014: Manifest Metadata Completeness

**Category**: Important | **Scope**: Module, Repository

Manifests must include comprehensive metadata for discoverability:

- `Author` and `CompanyName` populated
- `Copyright` information included
- `Description` is comprehensive and searchable
- `Tags` array includes relevant keywords
- `ProjectUri` and `LicenseUri` provided when applicable
- `HelpInfoURI` configured for updateable help

---

### ARCH-015: Configuration Management

**Category**: Recommended | **Scope**: Module, Repository

Configuration files stored in `Data/` subdirectory. Default configuration embedded in module. Configuration override mechanisms provided. Configuration validation implemented.

---

## Performance and Scalability Standards

### ARCH-016: Module Loading Performance

**Category**: Important | **Scope**: Module, Repository

Module loading must complete within 2 seconds on standard hardware. Lazy loading used for expensive operations. No network calls during module loading. Minimal external module dependencies at load time.

---

### ARCH-017: Memory Management

**Category**: Important | **Scope**: Module, Repository

Module cleanup handler removes module-scoped variables. Large objects properly disposed when no longer needed. Event handlers properly unregistered. Temporary files cleaned up.

---

## Security and Compliance Standards

### ARCH-018: Code Signing Requirements

**Category**: Important | **Scope**: Enterprise

Enterprise modules should be [digitally signed](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing) with an appropriate certificate. Signature verification passes on target systems. Certificate chain is valid and trusted. Timestamp included in signatures.

---

### ARCH-019: Execution Policy Compliance

**Category**: Important | **Scope**: Enterprise

Modules must function under `RemoteSigned` [execution policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies). No bypass mechanisms or policy circumvention. Execution policy requirements are documented.

---

## Quality Assurance Standards

### ARCH-020: Static Analysis Compliance

**Category**: Important | **Scope**: Module, Repository

Modules must pass [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) without critical violations. Custom organisational rules must be satisfied. Security-focused analysis rules must pass. Performance analysis recommendations addressed.

---

### ARCH-021: Automated Testing Integration

**Category**: Important | **Scope**: Module, Repository

Test directory structure supports automated discovery. Test files follow naming conventions (`*.Tests.ps1`). Build and deployment scripts are included. CI/CD pipeline configuration is provided.

---

## Documentation Integration Standards

### ARCH-022: Help System Integration

**Category**: Important | **Scope**: Module

Comment-based help or external XML help is provided. About topics included for complex modules. Updateable help supported where applicable. Help content integrates with PowerShell's built-in [`Get-Help`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) system.

---

### ARCH-023: Cross-Platform Compatibility

**Category**: Recommended | **Scope**: Module, Repository

Path separators use PowerShell-appropriate methods (`[System.IO.Path]::Combine()`). Platform-specific functionality properly abstracted. Cross-platform testing performed when relevant. Platform limitations documented clearly.

---

### ARCH-024: Module Discoverability

**Category**: Recommended | **Scope**: Module, Repository

Module appears in `Get-Module -ListAvailable`. Appropriate tags and metadata support searching. Description supports keyword-based discovery. Module integrates with [PowerShell Gallery](https://www.powershellgallery.com/) when applicable.

---

### ARCH-025: Module Lifecycle Management

**Category**: Important | **Scope**: Repository, Enterprise

Clean uninstallation process available. Update mechanisms preserve user data. Version migration paths documented. Deprecation process clearly defined.

---

## Related Resources

- [Microsoft — Writing a Windows PowerShell Module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/writing-a-windows-powershell-module)
- [Microsoft — Module Manifest Guidelines](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-modulemanifest)
- [Microsoft — about_PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)
- [Microsoft — about_Signing](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [standards-overview.md](standards-overview.md)
- [standards-coding.md](standards-coding.md)
- [standards-functions.md](standards-functions.md)
