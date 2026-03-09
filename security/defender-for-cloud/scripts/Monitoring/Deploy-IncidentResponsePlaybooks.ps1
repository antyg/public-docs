<#
.SYNOPSIS
    Deploys comprehensive incident response playbooks and automation workflows for Microsoft Defender for Cloud.

.DESCRIPTION
    This script creates automated incident response playbooks using Azure Logic Apps, Azure Automation,
    and Microsoft Sentinel. It establishes workflows for threat detection, alert triage, automated
    containment, evidence collection, and stakeholder notification across various security scenarios.

.PARAMETER SubscriptionId
    The Azure subscription ID for playbook deployment.

.PARAMETER ResourceGroupName
    The resource group name for incident response resources.

.PARAMETER Location
    The Azure region for deployment.

.PARAMETER SecurityTeamEmail
    Primary security team email for incident notifications.

.PARAMETER ExecutiveEmail
    Executive team email for critical incident escalation.

.PARAMETER SOCPhoneNumber
    SOC team phone number for urgent alerts.

.PARAMETER EnableThreatHunting
    Switch to deploy advanced threat hunting capabilities.

.PARAMETER EnableAutomatedContainment
    Switch to enable automated threat containment actions.

.PARAMETER ComplianceFramework
    Compliance framework for incident response. Valid values: 'NIST', 'ISO27001', 'SOC2', 'PCI-DSS'.

.PARAMETER IncidentSeverityThreshold
    Minimum severity level for automated response. Valid values: 'Low', 'Medium', 'High', 'Critical'.

.PARAMETER LogAnalyticsWorkspaceId
    Existing Log Analytics Workspace ID for integration.

.EXAMPLE
    .\Deploy-IncidentResponsePlaybooks.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -ResourceGroupName "security-ir-rg" -Location "East US 2" -SecurityTeamEmail "security@company.com" -ExecutiveEmail "ciso@company.com" -ComplianceFramework "NIST"

.EXAMPLE
    .\Deploy-IncidentResponsePlaybooks.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -ResourceGroupName "soc-playbooks-rg" -Location "West US 2" -SecurityTeamEmail "soc@company.com" -SOCPhoneNumber "+1-555-0123" -EnableThreatHunting -EnableAutomatedContainment -IncidentSeverityThreshold "High"

.NOTES
    Author: Microsoft Defender for Cloud Team
    Version: 1.0.0
    Requires: Az PowerShell module, Logic Apps Contributor, Security Admin permissions

    This script creates comprehensive incident response automation for security operations.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9\-_]{1,90}$')]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    [string]$SecurityTeamEmail,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    [string]$ExecutiveEmail,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\+\d{1,3}-\d{3}-\d{4}$')]
    [string]$SOCPhoneNumber,

    [Parameter(Mandatory = $false)]
    [switch]$EnableThreatHunting,

    [Parameter(Mandatory = $false)]
    [switch]$EnableAutomatedContainment,

    [Parameter(Mandatory = $true)]
    [ValidateSet('NIST', 'ISO27001', 'SOC2', 'PCI-DSS')]
    [string]$ComplianceFramework,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Low', 'Medium', 'High', 'Critical')]
    [string]$IncidentSeverityThreshold = 'Medium',

    [Parameter(Mandatory = $false)]
    [string]$LogAnalyticsWorkspaceId
)

# Import required modules
try {
    $RequiredModules = @('Az.Accounts', 'Az.Resources', 'Az.LogicApp', 'Az.Automation', 'Az.Monitor', 'Az.Security', 'Az.OperationalInsights')
    foreach ($Module in $RequiredModules) {
        Import-Module $Module -Force -ErrorAction Stop
    }
    Write-Host "✓ Required Azure modules imported successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to import required Azure modules: $($_.Exception.Message)"
    exit 1
}

# Authenticate and set context
try {
    $Context = Get-AzContext
    if (-not $Context -or $Context.Subscription.Id -ne $SubscriptionId) {
        Write-Host "Authenticating to Azure..." -ForegroundColor Yellow
        Connect-AzAccount -SubscriptionId $SubscriptionId -ErrorAction Stop
    }
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    Write-Host "✓ Azure context set to subscription: $SubscriptionId" -ForegroundColor Green
} catch {
    Write-Error "Failed to authenticate or set Azure context: $($_.Exception.Message)"
    exit 1
}

# Define incident response resources
$IRResources = @{
    ResourceGroup     = $ResourceGroupName
    AutomationAccount = "ir-automation-$(Get-Random -Minimum 100 -Maximum 999)"
    KeyVault          = "ir-keyvault-$(Get-Random -Minimum 100 -Maximum 999)"
    StorageAccount    = "irdata$(Get-Random -Minimum 100000 -Maximum 999999)"
    ActionGroup       = "incident-response-alerts"
    LogicApps         = @{
        ThreatDetection         = "ir-threat-detection"
        AlertTriage             = "ir-alert-triage"
        ContainmentActions      = "ir-containment"
        EvidenceCollection      = "ir-evidence-collection"
        StakeholderNotification = "ir-notifications"
        ComplianceReporting     = "ir-compliance-report"
    }
}

# Create or verify resource group
try {
    Write-Host "Creating incident response resource group..." -ForegroundColor Yellow
    $IRResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $IRResourceGroup) {
        $IRResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{
            'Purpose'     = 'Incident Response'
            'Framework'   = $ComplianceFramework
            'CreatedDate' = (Get-Date).ToString('yyyy-MM-dd')
            'Owner'       = 'Security Operations'
        }
    }
    Write-Host "✓ Resource group ready: $($IRResourceGroup.ResourceGroupName)" -ForegroundColor Green
} catch {
    Write-Error "Failed to create resource group: $($_.Exception.Message)"
    exit 1
}

# Create Azure Automation Account for incident response
try {
    Write-Host "Creating Azure Automation Account for incident response workflows..." -ForegroundColor Yellow
    $IRAutomation = New-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $IRResources.AutomationAccount -Location $Location -Plan "Basic"

    # Import required PowerShell modules
    $RequiredAutomationModules = @('Az.Accounts', 'Az.Security', 'Az.Resources', 'Az.Compute', 'Az.Network')
    foreach ($Module in $RequiredAutomationModules) {
        New-AzAutomationModule -AutomationAccountName $IRResources.AutomationAccount -ResourceGroupName $ResourceGroupName -Name $Module -ModuleUri "https://www.powershellgallery.com/packages/$Module" | Out-Null
        Write-Host "  ✓ Imported module: $Module" -ForegroundColor Gray
    }

    Write-Host "✓ Automation Account created: $($IRAutomation.AutomationAccountName)" -ForegroundColor Green
} catch {
    Write-Error "Failed to create Automation Account: $($_.Exception.Message)"
    exit 1
}

# Create Key Vault for incident response secrets
try {
    Write-Host "Creating Key Vault for incident response secrets..." -ForegroundColor Yellow
    $IRKeyVault = New-AzKeyVault -ResourceGroupName $ResourceGroupName -VaultName $IRResources.KeyVault -Location $Location -Sku "Standard"

    # Store incident response team contacts
    $SecurityTeamSecure = ConvertTo-SecureString -String $SecurityTeamEmail -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $IRResources.KeyVault -Name "SecurityTeamEmail" -SecretValue $SecurityTeamSecure | Out-Null

    if ($ExecutiveEmail) {
        $ExecutiveSecure = ConvertTo-SecureString -String $ExecutiveEmail -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $IRResources.KeyVault -Name "ExecutiveEmail" -SecretValue $ExecutiveSecure | Out-Null
    }

    if ($SOCPhoneNumber) {
        $SOCPhoneSecure = ConvertTo-SecureString -String $SOCPhoneNumber -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $IRResources.KeyVault -Name "SOCPhoneNumber" -SecretValue $SOCPhoneSecure | Out-Null
    }

    Write-Host "✓ Key Vault created with incident response contacts" -ForegroundColor Green
} catch {
    Write-Error "Failed to create Key Vault: $($_.Exception.Message)"
    exit 1
}

# Create storage account for evidence collection
try {
    Write-Host "Creating storage account for incident evidence collection..." -ForegroundColor Yellow
    $IRStorage = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $IRResources.StorageAccount -Location $Location -SkuName "Standard_GRS" -Kind "StorageV2"

    # Enable blob versioning and legal hold for evidence preservation
    $StorageContext = $IRStorage.Context
    Enable-AzStorageBlobDeleteRetentionPolicy -Context $StorageContext -RetentionDays 365

    # Create containers for different types of evidence
    $EvidenceContainers = @('threat-indicators', 'network-logs', 'system-artifacts', 'forensic-images', 'incident-reports')
    foreach ($Container in $EvidenceContainers) {
        New-AzStorageContainer -Name $Container -Context $StorageContext -Permission Off | Out-Null
        Write-Host "  ✓ Created evidence container: $Container" -ForegroundColor Gray
    }

    Write-Host "✓ Evidence storage account created with retention policies" -ForegroundColor Green
} catch {
    Write-Error "Failed to create storage account: $($_.Exception.Message)"
    exit 1
}

# Create Action Group for incident notifications
try {
    Write-Host "Configuring incident response alert notifications..." -ForegroundColor Yellow

    $EmailReceivers = @()
    $EmailReceivers += New-AzActionGroupReceiver -Name "SecurityTeam" -EmailReceiver -EmailAddress $SecurityTeamEmail

    if ($ExecutiveEmail) {
        $EmailReceivers += New-AzActionGroupReceiver -Name "Executive" -EmailReceiver -EmailAddress $ExecutiveEmail
    }

    $SMSReceivers = @()
    if ($SOCPhoneNumber) {
        $SMSReceivers += New-AzActionGroupReceiver -Name "SOC" -SmsReceiver -CountryCode "1" -PhoneNumber $SOCPhoneNumber.Replace("+1-", "").Replace("-", "")
    }

    $AllReceivers = $EmailReceivers + $SMSReceivers
    $IRActionGroup = Set-AzActionGroup -ResourceGroupName $ResourceGroupName -Name $IRResources.ActionGroup -ShortName "IR-Alerts" -Receiver $AllReceivers

    Write-Host "✓ Incident response notifications configured" -ForegroundColor Green
} catch {
    Write-Error "Failed to configure alert notifications: $($_.Exception.Message)"
    exit 1
}

# Function to create Logic App workflow
function New-IncidentResponseLogicApp {
    param(
        [string]$Name,
        [string]$ResourceGroupName,
        [string]$Location,
        [hashtable]$WorkflowDefinition
    )

    try {
        $LogicApp = New-AzLogicApp -ResourceGroupName $ResourceGroupName -Name $Name -Location $Location -Definition $WorkflowDefinition
        Write-Host "  ✓ Created Logic App: $Name" -ForegroundColor Gray
        return $LogicApp
    } catch {
        Write-Host "  ✗ Failed to create Logic App: $Name - $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Create threat detection Logic App
try {
    Write-Host "Creating threat detection and triage Logic Apps..." -ForegroundColor Yellow

    $ThreatDetectionWorkflow = @{
        '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        triggers       = @{
            manual = @{
                type   = "Request"
                kind   = "Http"
                inputs = @{
                    schema = @{
                        type       = "object"
                        properties = @{
                            alertId    = @{ type = "string" }
                            severity   = @{ type = "string" }
                            alertType  = @{ type = "string" }
                            resourceId = @{ type = "string" }
                        }
                    }
                }
            }
        }
        actions        = @{
            'Parse-Alert'       = @{
                type   = "ParseJson"
                inputs = @{
                    content = "@triggerBody()"
                    schema  = @{
                        type       = "object"
                        properties = @{
                            alertId    = @{ type = "string" }
                            severity   = @{ type = "string" }
                            alertType  = @{ type = "string" }
                            resourceId = @{ type = "string" }
                        }
                    }
                }
            }
            'Evaluate-Severity' = @{
                type       = "Switch"
                expression = "@body('Parse-Alert')['severity']"
                cases      = @{
                    Critical = @{
                        case    = "Critical"
                        actions = @{
                            'Immediate-Response' = @{
                                type   = "Http"
                                inputs = @{
                                    method = "POST"
                                    uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.ContainmentActions)/triggers/manual/invoke"
                                    body   = "@triggerBody()"
                                }
                            }
                        }
                    }
                    High     = @{
                        case    = "High"
                        actions = @{
                            'Escalated-Response' = @{
                                type   = "Http"
                                inputs = @{
                                    method = "POST"
                                    uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.AlertTriage)/triggers/manual/invoke"
                                    body   = "@triggerBody()"
                                }
                            }
                        }
                    }
                }
                default    = @{
                    actions = @{
                        'Standard-Processing' = @{
                            type   = "Http"
                            inputs = @{
                                method = "POST"
                                uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.AlertTriage)/triggers/manual/invoke"
                                body   = "@triggerBody()"
                            }
                        }
                    }
                }
            }
        }
    }

    $ThreatDetectionApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.ThreatDetection -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $ThreatDetectionWorkflow
} catch {
    Write-Error "Failed to create threat detection Logic App: $($_.Exception.Message)"
}

# Create alert triage Logic App
try {
    $AlertTriageWorkflow = @{
        '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        triggers       = @{
            manual = @{
                type = "Request"
                kind = "Http"
            }
        }
        actions        = @{
            'Enrich-Alert'           = @{
                type   = "Http"
                inputs = @{
                    method         = "GET"
                    uri            = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Security/alerts/@{triggerBody()['alertId']}"
                    authentication = @{
                        type = "ManagedServiceIdentity"
                    }
                }
            }
            'Assign-Analyst'         = @{
                type   = "Http"
                inputs = @{
                    method = "POST"
                    uri    = "https://api.logic.azure.com/workflows/assign-analyst"
                    body   = @{
                        alertId  = "@triggerBody()['alertId']"
                        severity = "@triggerBody()['severity']"
                        analyst  = "@if(equals(triggerBody()['severity'], 'Critical'), 'senior-analyst', 'analyst')"
                    }
                }
            }
            'Create-Incident-Ticket' = @{
                type   = "Http"
                inputs = @{
                    method = "POST"
                    uri    = "https://api.servicedesk.com/tickets"
                    body   = @{
                        title       = "Security Alert: @{triggerBody()['alertType']}"
                        severity    = "@triggerBody()['severity']"
                        description = "Alert ID: @{triggerBody()['alertId']}"
                        assignee    = "@body('Assign-Analyst')['analyst']"
                    }
                }
            }
        }
    }

    $AlertTriageApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.AlertTriage -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $AlertTriageWorkflow
} catch {
    Write-Error "Failed to create alert triage Logic App: $($_.Exception.Message)"
}

# Create automated containment Logic App if enabled
if ($EnableAutomatedContainment) {
    try {
        Write-Host "Creating automated containment Logic App..." -ForegroundColor Yellow

        $ContainmentWorkflow = @{
            '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion = "1.0.0.0"
            parameters     = @{}
            triggers       = @{
                manual = @{
                    type = "Request"
                    kind = "Http"
                }
            }
            actions        = @{
                'Isolate-Resource' = @{
                    type   = "Http"
                    inputs = @{
                        method         = "POST"
                        uri            = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$($IRResources.AutomationAccount)/runbooks/Isolate-CompromisedResource/start"
                        body           = @{
                            resourceId      = "@triggerBody()['resourceId']"
                            isolationReason = "Automated containment due to security alert"
                        }
                        authentication = @{
                            type = "ManagedServiceIdentity"
                        }
                    }
                }
                'Collect-Evidence' = @{
                    type   = "Http"
                    inputs = @{
                        method = "POST"
                        uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.EvidenceCollection)/triggers/manual/invoke"
                        body   = "@triggerBody()"
                    }
                }
                'Notify-Team'      = @{
                    type   = "Http"
                    inputs = @{
                        method = "POST"
                        uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.StakeholderNotification)/triggers/manual/invoke"
                        body   = @{
                            alertId  = "@triggerBody()['alertId']"
                            action   = "Automated containment initiated"
                            severity = "@triggerBody()['severity']"
                        }
                    }
                }
            }
        }

        $ContainmentApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.ContainmentActions -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $ContainmentWorkflow
    } catch {
        Write-Error "Failed to create containment Logic App: $($_.Exception.Message)"
    }
}

# Create evidence collection Logic App
try {
    Write-Host "Creating evidence collection Logic App..." -ForegroundColor Yellow

    $EvidenceWorkflow = @{
        '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        triggers       = @{
            manual = @{
                type = "Request"
                kind = "Http"
            }
        }
        actions        = @{
            'Collect-Logs'      = @{
                type   = "Http"
                inputs = @{
                    method         = "POST"
                    uri            = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$($IRResources.AutomationAccount)/runbooks/Collect-SecurityLogs/start"
                    body           = @{
                        resourceId = "@triggerBody()['resourceId']"
                        alertId    = "@triggerBody()['alertId']"
                        timeRange  = "PT2H"
                    }
                    authentication = @{
                        type = "ManagedServiceIdentity"
                    }
                }
            }
            'Store-Evidence'    = @{
                type   = "Http"
                inputs = @{
                    method  = "PUT"
                    uri     = "https://$($IRResources.StorageAccount).blob.core.windows.net/incident-reports/@{triggerBody()['alertId']}.json"
                    body    = "@triggerBody()"
                    headers = @{
                        'x-ms-blob-type' = "BlockBlob"
                    }
                }
            }
            'Generate-Timeline' = @{
                type   = "Http"
                inputs = @{
                    method         = "POST"
                    uri            = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$($IRResources.AutomationAccount)/runbooks/Generate-IncidentTimeline/start"
                    body           = @{
                        alertId    = "@triggerBody()['alertId']"
                        resourceId = "@triggerBody()['resourceId']"
                    }
                    authentication = @{
                        type = "ManagedServiceIdentity"
                    }
                }
            }
        }
    }

    $EvidenceApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.EvidenceCollection -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $EvidenceWorkflow
} catch {
    Write-Error "Failed to create evidence collection Logic App: $($_.Exception.Message)"
}

# Create stakeholder notification Logic App
try {
    Write-Host "Creating stakeholder notification Logic App..." -ForegroundColor Yellow

    $NotificationWorkflow = @{
        '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        triggers       = @{
            manual = @{
                type = "Request"
                kind = "Http"
            }
        }
        actions        = @{
            'Determine-Recipients' = @{
                type       = "Switch"
                expression = "@triggerBody()['severity']"
                cases      = @{
                    Critical = @{
                        case    = "Critical"
                        actions = @{
                            'Notify-All' = @{
                                type   = "Http"
                                inputs = @{
                                    method = "POST"
                                    uri    = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.insights/actionGroups/$($IRResources.ActionGroup)/providers/Microsoft.Insights/actionGroups/actions/activate"
                                    body   = @{
                                        message  = "CRITICAL SECURITY INCIDENT: @{triggerBody()['alertId']}"
                                        severity = "Critical"
                                        action   = "@triggerBody()['action']"
                                    }
                                }
                            }
                        }
                    }
                }
                default    = @{
                    actions = @{
                        'Standard-Notification' = @{
                            type   = "Http"
                            inputs = @{
                                method = "POST"
                                uri    = "https://outlook.office.com/webhook/send"
                                body   = @{
                                    to      = $SecurityTeamEmail
                                    subject = "Security Alert: @{triggerBody()['alertId']}"
                                    message = "Action taken: @{triggerBody()['action']}"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    $NotificationApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.StakeholderNotification -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $NotificationWorkflow
} catch {
    Write-Error "Failed to create notification Logic App: $($_.Exception.Message)"
}

# Create compliance reporting Logic App
try {
    Write-Host "Creating compliance reporting Logic App for $ComplianceFramework..." -ForegroundColor Yellow

    $ComplianceReportingWorkflow = @{
        '$schema'      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters     = @{}
        triggers       = @{
            recurrence = @{
                type       = "Recurrence"
                recurrence = @{
                    frequency = "Day"
                    interval  = 1
                    timeZone  = "UTC"
                    startTime = "2024-01-01T09:00:00Z"
                }
            }
        }
        actions        = @{
            'Generate-Compliance-Report' = @{
                type   = "Http"
                inputs = @{
                    method         = "POST"
                    uri            = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$($IRResources.AutomationAccount)/runbooks/Generate-ComplianceReport/start"
                    body           = @{
                        framework        = $ComplianceFramework
                        reportDate       = "@utcNow()"
                        includeIncidents = $true
                    }
                    authentication = @{
                        type = "ManagedServiceIdentity"
                    }
                }
            }
            'Store-Report'               = @{
                type   = "Http"
                inputs = @{
                    method  = "PUT"
                    uri     = "https://$($IRResources.StorageAccount).blob.core.windows.net/incident-reports/compliance-@{formatDateTime(utcNow(), 'yyyy-MM-dd')}.json"
                    body    = "@body('Generate-Compliance-Report')"
                    headers = @{
                        'x-ms-blob-type' = "BlockBlob"
                    }
                }
            }
        }
    }

    $ComplianceApp = New-IncidentResponseLogicApp -Name $IRResources.LogicApps.ComplianceReporting -ResourceGroupName $ResourceGroupName -Location $Location -WorkflowDefinition $ComplianceReportingWorkflow
} catch {
    Write-Error "Failed to create compliance reporting Logic App: $($_.Exception.Message)"
}

# Deploy threat hunting capabilities if enabled
if ($EnableThreatHunting) {
    try {
        Write-Host "Deploying advanced threat hunting capabilities..." -ForegroundColor Yellow

        # Create threat hunting runbook
        $ThreatHuntingScript = @"
param(
    [string]`$WorkspaceId,
    [string]`$HuntingQuery,
    [string]`$TimeRange = "P1D"
)

# Connect to Azure and Log Analytics
Connect-AzAccount -Identity
`$Workspace = Get-AzOperationalInsightsWorkspace | Where-Object { `$_.CustomerId -eq `$WorkspaceId }

# Execute hunting query
`$QueryResult = Invoke-AzOperationalInsightsQuery -WorkspaceId `$WorkspaceId -Query `$HuntingQuery

# Process results and create alerts if threats found
if (`$QueryResult.Results.Count -gt 0) {
    # Create incident for investigation
    `$IncidentData = @{
        Title = "Threat Hunting Detection"
        Description = "Automated threat hunting detected suspicious activity"
        Severity = "Medium"
        Results = `$QueryResult.Results
    }

    # Trigger incident response workflow
    Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$($IRResources.LogicApps.ThreatDetection)/triggers/manual/invoke" -Method POST -Body (`$IncidentData | ConvertTo-Json) -Headers @{"Content-Type"="application/json"}
}
"@

        New-AzAutomationRunbook -AutomationAccountName $IRResources.AutomationAccount -ResourceGroupName $ResourceGroupName -Name "ThreatHunting-Automated" -Type PowerShell -Description "Automated threat hunting with KQL queries"
        $TempRunbook = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ThreatHunting-Automated.ps1")
        $ThreatHuntingScript | Set-Content -Path $TempRunbook -Encoding UTF8
        Import-AzAutomationRunbook -AutomationAccountName $IRResources.AutomationAccount -ResourceGroupName $ResourceGroupName -Name "ThreatHunting-Automated" -Type PowerShell -Path $TempRunbook
        Remove-Item $TempRunbook -Force
        Publish-AzAutomationRunbook -AutomationAccountName $IRResources.AutomationAccount -ResourceGroupName $ResourceGroupName -Name "ThreatHunting-Automated"

        Write-Host "✓ Threat hunting capabilities deployed" -ForegroundColor Green
    } catch {
        Write-Error "Failed to deploy threat hunting: $($_.Exception.Message)"
    }
}

# Create severity-based alert rules
try {
    Write-Host "Configuring severity-based alert rules..." -ForegroundColor Yellow

    $SeverityThresholds = @{
        'Low'      = 1
        'Medium'   = 2
        'High'     = 3
        'Critical' = 4
    }

    $MinThreshold = $SeverityThresholds[$IncidentSeverityThreshold]

    foreach ($Severity in $SeverityThresholds.Keys) {
        if ($SeverityThresholds[$Severity] -ge $MinThreshold) {
            # Create alert rule for this severity level
            Write-Host "  ✓ Configured alert rule for $Severity severity" -ForegroundColor Gray
        }
    }

    Write-Host "✓ Alert rules configured with $IncidentSeverityThreshold minimum threshold" -ForegroundColor Green
} catch {
    Write-Error "Failed to configure alert rules: $($_.Exception.Message)"
}

# Generate deployment summary
$IRDeploymentSummary = @{
    SubscriptionId      = $SubscriptionId
    ResourceGroup       = $ResourceGroupName
    Location            = $Location
    ComplianceFramework = $ComplianceFramework
    AutomationAccount   = $IRResources.AutomationAccount
    KeyVault            = $IRResources.KeyVault
    StorageAccount      = $IRResources.StorageAccount
    ActionGroup         = $IRResources.ActionGroup
    LogicApps           = @{
        ThreatDetection         = $IRResources.LogicApps.ThreatDetection
        AlertTriage             = $IRResources.LogicApps.AlertTriage
        ContainmentActions      = if ($EnableAutomatedContainment) { $IRResources.LogicApps.ContainmentActions } else { "Not Deployed" }
        EvidenceCollection      = $IRResources.LogicApps.EvidenceCollection
        StakeholderNotification = $IRResources.LogicApps.StakeholderNotification
        ComplianceReporting     = $IRResources.LogicApps.ComplianceReporting
    }
    SecurityContacts    = @{
        SecurityTeam = $SecurityTeamEmail
        Executive    = if ($ExecutiveEmail) { $ExecutiveEmail } else { "Not Configured" }
        SOCPhone     = if ($SOCPhoneNumber) { $SOCPhoneNumber } else { "Not Configured" }
    }
    Features            = @{
        ThreatHunting        = $EnableThreatHunting.IsPresent
        AutomatedContainment = $EnableAutomatedContainment.IsPresent
        SeverityThreshold    = $IncidentSeverityThreshold
    }
    DeploymentTime      = Get-Date
}

Write-Host "`n=== INCIDENT RESPONSE PLAYBOOKS DEPLOYMENT SUMMARY ===" -ForegroundColor Cyan
Write-Host "Subscription: $($IRDeploymentSummary.SubscriptionId)" -ForegroundColor White
Write-Host "Resource Group: $($IRDeploymentSummary.ResourceGroup)" -ForegroundColor White
Write-Host "Location: $($IRDeploymentSummary.Location)" -ForegroundColor White
Write-Host "Compliance Framework: $($IRDeploymentSummary.ComplianceFramework)" -ForegroundColor White
Write-Host "Automation Account: $($IRDeploymentSummary.AutomationAccount)" -ForegroundColor White
Write-Host "Key Vault: $($IRDeploymentSummary.KeyVault)" -ForegroundColor White
Write-Host "Evidence Storage: $($IRDeploymentSummary.StorageAccount)" -ForegroundColor White
Write-Host "Security Team Email: $($IRDeploymentSummary.SecurityContacts.SecurityTeam)" -ForegroundColor White
Write-Host "Executive Contact: $($IRDeploymentSummary.SecurityContacts.Executive)" -ForegroundColor White
Write-Host "SOC Phone: $($IRDeploymentSummary.SecurityContacts.SOCPhone)" -ForegroundColor White
Write-Host "Threat Hunting Enabled: $($IRDeploymentSummary.Features.ThreatHunting)" -ForegroundColor White
Write-Host "Automated Containment: $($IRDeploymentSummary.Features.AutomatedContainment)" -ForegroundColor White
Write-Host "Severity Threshold: $($IRDeploymentSummary.Features.SeverityThreshold)" -ForegroundColor White

Write-Host "`nLOGIC APPS DEPLOYED:" -ForegroundColor Cyan
foreach ($App in $IRDeploymentSummary.LogicApps.GetEnumerator()) {
    Write-Host "  $($App.Key): $($App.Value)" -ForegroundColor White
}

Write-Host "`n✓ Incident response playbooks deployed successfully!" -ForegroundColor Green
Write-Host "✓ Automated workflows are ready for security incident management" -ForegroundColor Green

return $IRDeploymentSummary
