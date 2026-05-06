---
title: "PowerShell Documentation and Help Standards"
status: "published"
last_updated: "2026-03-16"
audience: "PowerShell Developers, Technical Writers"
document_type: "reference"
domain: "development"
---

# PowerShell Documentation and Help Standards

24 documentation standards governing comprehensive requirements for PowerShell module documentation — comment-based help, external help files, API documentation, examples, and cross-referencing. Derived from [Microsoft's PowerShell help system documentation](https://learn.microsoft.com/en-us/powershell/scripting/developer/help/writing-help-for-windows-powershell-cmdlets) and [about_Comment_Based_Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help).

---

## Comment-Based Help Standards

### DOC-001: Comment-Based Help Required

**Category**: Critical | **Scope**: Function, Module, Repository

All public functions must include comprehensive [comment-based help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help) that integrates with PowerShell's help system.

**Required sections:**

| Section | Purpose |
|---|---|
| `.SYNOPSIS` | Clear, concise single-sentence description |
| `.DESCRIPTION` | Detailed explanation of functionality and behaviour |
| `.PARAMETER <name>` | Usage guidance for each parameter |
| `.EXAMPLE` | Minimum one working usage example |
| `.INPUTS` | Pipeline input types |
| `.OUTPUTS` | Output object types |
| `.NOTES` | Important usage information, prerequisites |
| `.LINK` | Cross-references to related functions and documentation |

**Compliance criteria:**

- [ ] `.SYNOPSIS` present and descriptive
- [ ] `.DESCRIPTION` comprehensive
- [ ] `.PARAMETER` section present for all parameters
- [ ] At least one `.EXAMPLE` with working code
- [ ] `.INPUTS` and `.OUTPUTS` accurate
- [ ] `.NOTES` with relevant information
- [ ] `.LINK` with appropriate references

```powershell
function Get-UserAccount {
    <#
    .SYNOPSIS
        Retrieves a user account by identity.

    .DESCRIPTION
        Retrieves a user account object from the identity store by the specified
        identity. Supports pipeline input for batch retrieval.

    .PARAMETER Identity
        The user identity (username, UPN, or object ID) to retrieve.
        Accepts pipeline input by value.

    .EXAMPLE
        Get-UserAccount -Identity 'jdoe'

        Retrieves the user account for username 'jdoe'.

    .EXAMPLE
        'jdoe', 'asmith' | Get-UserAccount

        Retrieves user accounts for multiple identities via pipeline.

    .INPUTS
        System.String. Identity values can be piped to this function.

    .OUTPUTS
        PSCustomObject. Returns a user account object with Identity and Status properties.

    .NOTES
        Requires read access to the identity store.
        Use Set-UserAccount to modify account properties.

    .LINK
        Set-UserAccount
        New-UserAccount
        Remove-UserAccount
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

### DOC-002: Help Content Quality

**Category**: Important | **Scope**: Function, Module

Help content must be accurate, comprehensive, and written for the target audience.

**Requirements:**

- Language clear and professional
- Technical accuracy verified against actual implementation
- Examples tested and confirmed to execute without modification
- Parameter descriptions include validation requirements and constraints
- Usage scenarios reflect real-world applications

**Compliance criteria:**

- [ ] Language clear and professional
- [ ] Technical content accurate
- [ ] Examples executable and relevant
- [ ] Parameter descriptions comprehensive
- [ ] Usage scenarios realistic

---

## API Documentation Standards

### DOC-003: API Reference Completeness

**Category**: Important | **Scope**: Module, Repository

Modules must provide comprehensive API reference documentation covering all public interfaces.

**Requirements:**

- All public functions documented in API reference
- Function signatures accurately represented
- Parameter details include types and validation constraints
- Return values specified with types and structure
- Cross-references between related functions provided

**Compliance criteria:**

- [ ] All public functions included
- [ ] Function signatures accurate
- [ ] Parameter details comprehensive
- [ ] Return values specified
- [ ] Cross-references accurate and helpful

---

### DOC-004: Type Documentation

**Category**: Important | **Scope**: Module

Custom types and objects must be documented with their properties, methods, and usage patterns.

**Requirements:**

- Custom object types documented with property descriptions
- Object methods documented with parameters and return values
- Type relationships and inheritance documented
- Usage examples provided for complex types
- Type conversion and coercion behaviour documented

---

## Example and Usage Documentation

### DOC-005: Example Quality and Coverage

**Category**: Important | **Scope**: Function, Module

Examples must be practical, executable, and cover common usage scenarios comprehensively.

**Requirements:**

- Examples executable without modification
- Common usage patterns demonstrated
- Pipeline usage examples included
- Error handling examples provided
- Complex scenarios broken down into steps
- Output examples show expected results

**Compliance criteria:**

- [ ] Examples execute without modification
- [ ] Common patterns covered
- [ ] Pipeline usage demonstrated
- [ ] Error scenarios included
- [ ] Complex examples properly explained
- [ ] Expected outputs shown

---

### DOC-006: Integration Examples

**Category**: Recommended | **Scope**: Module, Repository

Modules should provide examples of integration with other modules and systems — cross-module integration patterns, system integration examples, configuration examples, and automation scenario examples.

---

## External Documentation Standards

### DOC-007: README Documentation

**Category**: Important | **Scope**: Module, Repository

README files must provide comprehensive module overview and getting-started information.

**Required sections:**

- Module purpose and overview
- Installation instructions
- Prerequisites and dependencies
- Quick start examples
- Feature overview
- Support and contribution information

**Compliance criteria:**

- [ ] Module purpose clearly explained
- [ ] Installation instructions complete
- [ ] Prerequisites documented
- [ ] Quick start examples provided
- [ ] Feature overview comprehensive
- [ ] Support information included

---

### DOC-008: Change Documentation

**Category**: Important | **Scope**: Module, Repository

`CHANGELOG.md` must follow the [Keep a Changelog](https://keepachangelog.com/) format.

**Requirements:**

- All changes categorised appropriately (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`)
- Breaking changes clearly identified with `BREAKING` label
- Migration guidance provided for major changes
- Version history maintained consistently
- Unreleased section maintained during development

---

## Help System Integration

### DOC-009: Updateable Help Support

**Category**: Recommended | **Scope**: Module

Modules should support [PowerShell's updateable help system](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/update-help):

- `HelpInfoURI` configured in module manifest
- Help content available at specified URI
- Help versioning aligned with module versions
- Multiple language support where applicable

---

### DOC-010: About Topics

**Category**: Recommended | **Scope**: Module

Complex modules should include [About topics](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules) that explain concepts, workflows, and advanced usage:

- About topics in `en-US/` directory under module root
- Topics follow PowerShell About topic format (`about_<ModuleName>_<Topic>.help.txt`)
- Cross-references to related functions included
- Conceptual information clearly explained
- Workflow examples provided

---

## Cross-Reference and Linking Standards

### DOC-011: Internal Cross-References

**Category**: Important | **Scope**: Function, Module

Documentation must include comprehensive cross-references to related functions and concepts.

**Requirements:**

- Related functions linked in `.LINK` sections
- Parameter types cross-referenced to relevant functions
- Concept relationships documented
- Workflow connections established
- Cross-reference accuracy maintained

**Compliance criteria:**

- [ ] Related functions appropriately linked
- [ ] Parameter types cross-referenced
- [ ] Concept relationships documented
- [ ] Workflow connections clear
- [ ] Cross-references accurate and current

---

### DOC-012: External References

**Category**: Recommended | **Scope**: Function, Module

Documentation should reference relevant external resources:

- [Microsoft documentation](https://learn.microsoft.com/en-us/powershell/) linked where relevant
- Industry standards referenced appropriately
- Third-party integration documentation linked
- Related PowerShell modules referenced
- Community resources acknowledged

---

## Documentation Maintenance Standards

### DOC-013: Documentation Currency

**Category**: Important | **Scope**: Function, Module, Repository

- Documentation updated with each code change
- Examples verified with each release
- Cross-references validated regularly
- Deprecated features marked with `[Obsolete]` notice and removal timeline
- Documentation versioning aligned with module versions

---

### DOC-014: Documentation Review Process

**Category**: Important | **Scope**: Repository, Enterprise

- Documentation changes peer-reviewed
- Review criteria established and followed
- Standards compliance verified
- Technical accuracy validated against implementation
- User experience impact assessed

---

## Accessibility and Localisation

### DOC-015: Documentation Accessibility

**Category**: Recommended | **Scope**: Module, Repository

- Clear, simple language used
- Technical jargon explained on first use
- Multiple learning styles accommodated (examples, diagrams, code)
- Alternative text provided for visual elements
- Language consistent with en-AU spelling conventions

---

### DOC-016: Localisation Support

**Category**: Recommended | **Scope**: Module, Repository

International modules should consider localisation requirements:

- Documentation structure supports localisation (language subdirectories)
- Cultural considerations addressed
- Date/time formats localised appropriately
- Translation-friendly formatting (avoid text in images, short line lengths)

---

## Quality Assurance Standards

### DOC-017: Documentation Testing

**Category**: Important | **Scope**: Function, Module

- Examples tested for executability before publication
- Links verified for accuracy
- Step-by-step procedures validated end-to-end
- Documentation reviewed by target audience representative
- Feedback incorporated systematically

---

### DOC-018: Documentation Metrics

**Category**: Recommended | **Scope**: Module, Repository, Enterprise

- Documentation coverage tracked (ratio of documented to undocumented public functions)
- Help system integration verified (`Get-Help <function>` returns content)
- Documentation completeness assessed per release

---

## Advanced Documentation Patterns

### DOC-019: Interactive Documentation

**Category**: Recommended | **Scope**: Module, Repository

For complex modules, consider interactive documentation formats:

- Jupyter notebooks with PowerShell kernel for exploratory examples
- Plaster templates for module scaffolding that include documentation stubs
- PlatyPS for generating external MAML help from comment-based help

---

### DOC-020: Documentation Architecture

**Category**: Recommended | **Scope**: Repository, Enterprise

Large documentation sets should follow architectural principles:

- Documentation architecture planned before content is written
- Information hierarchy established (overview → guide → reference)
- Navigation structure intuitive
- Content relationships mapped
- Maintenance workflows defined

---

## Integration with Development Process

### DOC-021: Documentation in CI/CD

**Category**: Important | **Scope**: Repository, Enterprise

- Documentation builds automated (e.g., [Platyps](https://github.com/PowerShell/platyPS) external help generation)
- Documentation testing integrated (`Get-Help` validation)
- Documentation deployment automated
- Quality gates include documentation coverage checks
- Documentation changes tracked alongside code changes

---

### DOC-022: Documentation as Code

**Category**: Important | **Scope**: Repository, Enterprise

- Documentation stored in version control alongside code
- Branching strategies applied to documentation
- Pull requests used for documentation changes
- Code review principles applied to documentation
- Documentation merged with code changes in the same commit

---

## Security and Compliance Documentation

### DOC-023: Security Documentation

**Category**: Important | **Scope**: Module, Repository

Security-related functionality must be documented with appropriate warnings and guidance:

- Security implications documented clearly
- Risk warnings provided appropriately
- Best practices included
- Compliance requirements addressed
- Security configuration examples provided

---

### DOC-024: Compliance Documentation

**Category**: Important | **Scope**: Module, Repository, Enterprise

Modules must include documentation supporting organisational compliance requirements:

- Regulatory compliance addressed
- Audit trail documentation provided
- Data handling practices documented
- Privacy implications explained
- Compliance validation procedures included

---

## Related Resources

- [Microsoft — about_Comment_Based_Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help)
- [Microsoft — Writing Help for PowerShell Cmdlets](https://learn.microsoft.com/en-us/powershell/scripting/developer/help/writing-help-for-windows-powershell-cmdlets)
- [Microsoft — Update-Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/update-help)
- [Platyps — Markdown help authoring for PowerShell](https://github.com/PowerShell/platyPS)
- [Keep a Changelog](https://keepachangelog.com/)
- [standards-overview.md](standards-overview.md)
- [standards-functions.md](standards-functions.md)
- [standards-error-handling.md](standards-error-handling.md)
