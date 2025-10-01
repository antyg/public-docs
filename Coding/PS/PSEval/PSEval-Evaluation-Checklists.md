# PowerShell Evaluation Checklists

## Metadata

- **Document Type**: Evaluation Checklists
- **Version**: 1.0.0
- **Last Updated**: 2025-08-24
- **Cross-References**: [Overview](PSEval-Standards-Overview.md) | [Methods](PSEval-Evaluation-Methods.md) | [Automation](PSEval-Evaluation-Automation.md)

## Executive Summary

This document provides practical, actionable checklists for evaluating PowerShell codebases at different organizational levels. These checklists enable systematic assessment and ensure comprehensive coverage of all evaluation standards.

## Enterprise Level Checklist

### Organizational Assessment Checklist

#### Module Portfolio Analysis

- [ ] **Module Inventory Complete**: All organizational modules catalogued and classified
- [ ] **Architecture Consistency**: Standard patterns adopted across business units
- [ ] **Security Compliance**: Enterprise security policies enforced uniformly
- [ ] **Performance Standards**: Acceptable performance across all critical systems
- [ ] **Documentation Standards**: Consistent documentation approach organization-wide

#### Governance and Compliance

- [ ] **Policy Enforcement**: Automated policy compliance monitoring implemented
- [ ] **Quality Gates**: Enterprise quality standards enforced in development pipelines
- [ ] **Training Programs**: Developer training programs aligned with standards
- [ ] **Audit Trails**: Comprehensive audit logging for compliance requirements
- [ ] **Risk Management**: Security and operational risks identified and mitigated

#### Strategic Alignment

- [ ] **Business Alignment**: PowerShell strategy aligned with business objectives
- [ ] **Resource Allocation**: Adequate resources for quality and compliance initiatives
- [ ] **Technology Roadmap**: Clear migration paths for legacy systems
- [ ] **Vendor Management**: Third-party integrations meet organizational standards
- [ ] **Innovation Balance**: Standards support rather than hinder innovation

### Enterprise Metrics Dashboard

- [ ] **Compliance Trending**: Organization-wide compliance metrics tracked over time
- [ ] **Quality Indicators**: Code quality metrics aggregated and reported
- [ ] **Security Posture**: Security compliance status monitored and reported
- [ ] **Performance Monitoring**: System performance tracked and optimized
- [ ] **Cost Management**: Development and maintenance costs tracked and optimized

## Repository Level Checklist

### Multi-Module Assessment Checklist

#### Cross-Module Consistency

- [ ] **Naming Conventions**: Consistent naming across all modules in repository
- [ ] **Architecture Patterns**: Standard patterns used consistently
- [ ] **Error Handling**: Uniform error handling approaches
- [ ] **Documentation Formats**: Consistent documentation structure and quality
- [ ] **Testing Approaches**: Standardized testing frameworks and coverage

#### Integration and Dependencies

- [ ] **Dependency Management**: Module dependencies properly declared and managed
- [ ] **Version Compatibility**: Compatible versions across dependent modules
- [ ] **Interface Consistency**: Compatible interfaces between related modules
- [ ] **Data Exchange**: Standard data formats used between modules
- [ ] **Configuration Management**: Unified configuration approaches

#### Development Process Integration

- [ ] **Code Review Process**: Mandatory code reviews with quality criteria
- [ ] **CI/CD Integration**: Automated building, testing, and deployment
- [ ] **Quality Gates**: Automated quality checks prevent substandard code progression
- [ ] **Release Management**: Systematic release processes with quality validation
- [ ] **Change Management**: Controlled change processes with impact assessment

### Repository Quality Gates

- [ ] **Static Analysis**: PSScriptAnalyzer passes without critical errors
- [ ] **Test Coverage**: Minimum test coverage thresholds met
- [ ] **Documentation Coverage**: All public functions documented
- [ ] **Security Scanning**: No high-severity security issues detected
- [ ] **Performance Validation**: Performance regression tests pass

## Module Level Checklist

### Critical Standards (Must Have) - Module Assessment

#### Architecture Standards

- [ ] **ARCH-001**: Module manifest present and valid (`Test-ModuleManifest` passes)
- [ ] **ARCH-002**: Standard directory structure implemented (Public/, Private/, Tests/, docs/)
- [ ] **ARCH-004**: Explicit export declarations in manifest (no wildcard exports)

#### Coding Standards

- [ ] **CODE-001**: All functions use Microsoft-approved verbs only
- [ ] **CODE-002**: All functions follow Verb-Noun naming pattern with PascalCase
- [ ] **CODE-014**: Comprehensive input validation implemented on all parameters

#### Function Standards

- [ ] **FUNC-001**: All public functions have [CmdletBinding()] attribute
- [ ] **FUNC-002**: Parameter validation attributes present (Mandatory, ValidateNotNullOrEmpty, etc.)
- [ ] **FUNC-003**: Pipeline input support implemented where appropriate

#### Documentation Standards

- [ ] **DOC-001**: Comment-based help present for all public functions
- [ ] **DOC-002**: Help quality meets standards (Synopsis, Description, Examples)

#### Error Handling Standards

- [ ] **ERR-001**: Try-catch blocks implemented for all error-prone operations
- [ ] **ERR-002**: Error records constructed with proper categorization

### Important Standards (Should Have) - Module Assessment

#### Architecture Enhancements

- [ ] **ARCH-003**: Semantic versioning compliance implemented
- [ ] **ARCH-006**: Essential files present (README.md, CHANGELOG.md)
- [ ] **ARCH-007**: Dependencies properly declared in RequiredModules

#### Coding Enhancements

- [ ] **CODE-003**: Variable naming follows camelCase conventions
- [ ] **CODE-006**: Variable scope explicitly managed
- [ ] **CODE-013**: Secure credential handling implemented

#### Function Enhancements

- [ ] **FUNC-004**: Output types declared with [OutputType()] attribute
- [ ] **FUNC-008**: Begin-Process-End blocks implemented for pipeline functions

#### Documentation Enhancements

- [ ] **DOC-003**: API reference documentation complete
- [ ] **DOC-005**: Examples are executable and cover common scenarios

#### Error Handling Enhancements

- [ ] **ERR-003**: Specific exception types caught and handled
- [ ] **ERR-005**: Centralized error management implemented

### Recommended Standards (Nice to Have) - Module Assessment

#### Advanced Features

- [ ] **ARCH-009**: Resources organized in dedicated subdirectories
- [ ] **CODE-019**: Object-oriented patterns used appropriately
- [ ] **FUNC-020**: Factory patterns implemented for complex object creation
- [ ] **DOC-015**: Documentation accessibility considerations addressed
- [ ] **ERR-008**: Circuit breaker patterns implemented for external dependencies

## Function Level Checklist

### Individual Function Assessment

#### Basic Function Requirements

- [ ] **Function Declaration**: Uses `function` keyword with proper Verb-Noun naming
- [ ] **CmdletBinding**: [CmdletBinding()] attribute present
- [ ] **Parameters**: Parameter block properly defined with appropriate attributes
- [ ] **Help Documentation**: Complete comment-based help included
- [ ] **Error Handling**: Try-catch blocks for error-prone operations

#### Parameter Design Validation

- [ ] **Mandatory Parameters**: [Parameter(Mandatory)] used appropriately
- [ ] **Validation Attributes**: ValidateSet, ValidatePattern, ValidateScript used where needed
- [ ] **Type Specification**: Strong typing used for all parameters
- [ ] **Default Values**: Sensible defaults provided where appropriate
- [ ] **Pipeline Support**: ValueFromPipeline/ValueFromPipelineByPropertyName used correctly

#### Function Implementation Quality

- [ ] **Single Responsibility**: Function does one thing well
- [ ] **Appropriate Complexity**: Cyclomatic complexity under 15
- [ ] **Error Messages**: Clear, actionable error messages
- [ ] **Resource Management**: Proper cleanup of resources
- [ ] **Performance**: Efficient implementation for expected usage

#### Help Documentation Quality

- [ ] **.SYNOPSIS**: Clear, concise function description
- [ ] **.DESCRIPTION**: Detailed explanation of function behavior
- [ ] **.PARAMETER**: Every parameter documented with usage guidance
- [ ] **.EXAMPLE**: At least one working example provided
- [ ] **.INPUTS/.OUTPUTS**: Pipeline types specified correctly

### Function Security Checklist

- [ ] **Input Validation**: All input parameters validated appropriately
- [ ] **Credential Handling**: PSCredential type used for credentials
- [ ] **Path Validation**: File paths validated before use
- [ ] **SQL Injection Prevention**: Parameterized queries used for database operations
- [ ] **Script Injection Prevention**: User input not passed directly to Invoke-Expression

## Component Level Checklist

### Parameter Block Assessment

- [ ] **Type Declarations**: All parameters have explicit type declarations
- [ ] **Validation Attributes**: Appropriate validation for parameter requirements
- [ ] **Help Messages**: HelpMessage attribute used for complex parameters
- [ ] **Aliases**: Common alternative parameter names provided via Alias attribute
- [ ] **Parameter Sets**: Multiple parameter sets used appropriately for different usage patterns

### Error Handling Assessment

- [ ] **Exception Specificity**: Specific exception types caught rather than generic exceptions
- [ ] **Error Records**: Complete ErrorRecord objects created with appropriate categories
- [ ] **Target Objects**: Target objects included in error records for context
- [ ] **Recommended Actions**: Error messages include guidance on resolution
- [ ] **Non-Terminating Errors**: Write-Error used for non-terminating errors

### Pipeline Integration Assessment

- [ ] **Begin Block**: Initialization logic in begin block where appropriate
- [ ] **Process Block**: Pipeline input processed in process block
- [ ] **End Block**: Cleanup and summary logic in end block
- [ ] **Pipeline Streaming**: Objects output individually for efficient streaming
- [ ] **Pipeline Termination**: Proper handling of pipeline termination scenarios

## Quality Scoring Guidelines

### Scoring Framework

- **Critical Standards**: 60% of total score (Must pass 80% for overall pass)
- **Important Standards**: 30% of total score
- **Recommended Standards**: 10% of total score

### Pass/Fail Thresholds

- **Pass**: 75% overall score with 80% critical standards compliance
- **Excellence**: 90% overall score with 95% critical standards compliance
- **Needs Improvement**: Below 60% overall score or below 70% critical standards compliance

### Checklist Completion Guidelines

- **Complete**: All applicable checklist items addressed
- **Not Applicable**: Items not relevant to specific module type documented as N/A
- **Partial**: Items partially implemented noted with specific gaps
- **Missing**: Items not implemented noted with priority for remediation

## Remediation Planning

### Priority Classification

1. **Critical Issues**: Security vulnerabilities, compliance violations
2. **Important Issues**: Quality issues impacting maintainability or reliability
3. **Recommended Issues**: Enhancement opportunities for best practices

### Remediation Templates

- **Issue Description**: Clear description of the gap or violation
- **Impact Assessment**: Potential impact if not addressed
- **Recommended Solution**: Specific remediation steps
- **Implementation Timeline**: Realistic timeline for resolution
- **Validation Criteria**: How to verify successful remediation

---

## Usage Instructions

1. **Select Appropriate Checklist**: Choose the evaluation level matching your scope
2. **Complete Systematic Review**: Work through checklist items systematically
3. **Document Findings**: Record compliance status and specific gaps
4. **Calculate Scores**: Apply scoring framework to determine overall compliance
5. **Plan Remediation**: Prioritize and plan remediation for identified gaps
6. **Track Progress**: Monitor remediation progress and re-evaluate

_These checklists provide practical tools for systematic PowerShell module evaluation. Use with automated tools for comprehensive assessment._
