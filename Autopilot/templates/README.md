# Windows Autopilot Templates

This folder contains reusable templates, scripts, and configuration files for Microsoft Windows Autopilot deployments.

## Template Categories

### 📊 CSV Import Templates
- **device-import-template.csv** - Device registration format for bulk imports with comprehensive field mapping

### 🔧 PowerShell Scripts
- **hardware-hash-collection.ps1** - Automated hardware hash collection script with dual collection methods
- **profile-assignment.ps1** - Bulk profile assignment automation with validation and reporting
- **network-connectivity-test.ps1** - Network endpoint connectivity verification with DNS resolution testing
- **firewall-rules.ps1** - Windows Firewall configuration for Autopilot endpoints with connectivity testing
- **device-registration-script.ps1** - Comprehensive device registration script for collecting hardware information
- **bulk-profile-assignment.ps1** - Bulk assignment of Autopilot deployment profiles to multiple device groups
- **proxy-configuration.ps1** - Configure system proxy settings for Autopilot endpoints

### ⚙️ JSON Configuration Templates
- **corporate-profile-template.json** - Standard corporate user-driven profile with comprehensive ESP settings
- **kiosk-profile-template.json** - Self-deploying kiosk configuration with extended timeout settings

### 📋 Dynamic Group Rules
- **autopilot-group-rules.txt** - Comprehensive collection of Azure AD dynamic group membership rules with examples and limitations

## Usage Instructions

### Template Customization
1. Copy the relevant template file to your working directory
2. Replace placeholder values with your environment-specific settings
3. Test in a development environment before production deployment
4. Maintain version control for customized templates

### Script Execution
Most PowerShell scripts require:
- **Execution Policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Microsoft Graph PowerShell SDK**: Install via `Install-Module Microsoft.Graph`
- **Administrative Privileges**: Run PowerShell as Administrator where indicated

### Security Considerations
- Review all scripts before execution in production environments
- Use service accounts with minimal required permissions
- Store sensitive configuration data securely (Azure Key Vault recommended)
- Implement logging and audit trails for template usage

## Template Maintenance

### Version Control
Each template includes:
- **Creation Date**: When the template was first created
- **Last Updated**: Most recent modification date  
- **Version Number**: Semantic versioning (major.minor.patch)
- **Compatibility**: Supported Windows and PowerShell versions

### Support Matrix
| Template Category | Windows 10 | Windows 11 | PowerShell 5.1 | PowerShell 7.x |
|------------------|------------|------------|----------------|-----------------|
| CSV Templates | ✅ | ✅ | ✅ | ✅ |
| PowerShell Scripts | ✅ | ✅ | ✅ | ✅ |
| JSON Configurations | ✅ | ✅ | N/A | N/A |
| Network Templates | ✅ | ✅ | ✅ | ✅ |

## Integration with Documentation

These templates are referenced throughout the Autopilot documentation:

- **[Complete Setup Guide](../setup-guides/)** - Implementation procedures using templates
- **[Administrator Quick Reference](../quick-reference/)** - Daily operations with template shortcuts  
- **[Cloud Migration Framework](../cloud-migration/)** - Migration-specific template usage
- **[Troubleshooting Guide](../limitations-and-solutions/)** - Diagnostic template applications

## Contributing

When adding new templates:
1. Follow the established naming convention: `category-purpose-template.ext`
2. Include comprehensive inline documentation
3. Test across multiple environments
4. Update this README with the new template information
5. Cross-reference in relevant documentation sections

## Template Support

For template-specific questions:
- Review inline comments and documentation first
- Check the related documentation sections
- Consult Microsoft official documentation
- Engage with the community via Microsoft Tech Community

---

**Last Updated**: 2025-08-27  
**Template Count**: 12 configuration examples  
**Compatibility**: Windows 10/11, PowerShell 5.1+, Microsoft Graph SDK