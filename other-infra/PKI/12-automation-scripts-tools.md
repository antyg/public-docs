# PKI Modernization - Automation Scripts and Tools

[← Previous: Disaster Recovery](11-disaster-recovery.md) | [Back to Index](00-index.md)

## Executive Summary

This document provides a comprehensive collection of automation scripts, tools, and utilities developed for managing the enterprise PKI infrastructure. These tools enable efficient operations, reduce manual effort, ensure consistency, and minimize human error in PKI management tasks.

## Table of Contents

1. [Certificate Lifecycle Automation](#certificate-lifecycle-automation)
2. [Monitoring and Health Check Tools](#monitoring-and-health-check-tools)
3. [Bulk Operations Scripts](#bulk-operations-scripts)
4. [Security and Compliance Automation](#security-and-compliance-automation)
5. [Migration and Deployment Tools](#migration-and-deployment-tools)
6. [Integration Scripts](#integration-scripts)
7. [Reporting and Analytics](#reporting-and-analytics)
8. [Emergency Response Automation](#emergency-response-automation)
9. [PowerShell Module: PKIManager](#powershell-module-pkimanager)
10. [REST API Client Libraries](#rest-api-client-libraries)

## Certificate Lifecycle Automation

### Auto-Enrollment Engine

```powershell
# Start-PKIAutoEnrollment.ps1
# Automated certificate enrollment engine with intelligent retry logic

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "C:\PKI\Config\AutoEnrollment.json",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 3,
    
    [Parameter(Mandatory=$false)]
    [int]$BatchSize = 50,
    
    [Parameter(Mandatory=$false)]
    [switch]$ForceRenewal
)

class AutoEnrollmentEngine {
    [string]$ConfigPath
    [hashtable]$Config
    [array]$EnrollmentQueue
    [array]$Results
    [int]$MaxRetries
    [int]$BatchSize
    
    AutoEnrollmentEngine([string]$configPath, [int]$maxRetries, [int]$batchSize) {
        $this.ConfigPath = $configPath
        $this.Config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
        $this.MaxRetries = $maxRetries
        $this.BatchSize = $batchSize
        $this.Results = @()
        $this.EnrollmentQueue = @()
    }
    
    [void] BuildEnrollmentQueue() {
        Write-Host "Building enrollment queue..." -ForegroundColor Cyan
        
        # Get all computers requiring certificates
        $computers = Get-ADComputer -Filter * -Properties @(
            'OperatingSystem',
            'LastLogonDate',
            'MemberOf',
            'ServicePrincipalName'
        )
        
        foreach ($computer in $computers) {
            $templates = $this.GetRequiredTemplates($computer)
            
            foreach ($template in $templates) {
                $needsEnrollment = $this.CheckEnrollmentNeeded(
                    $computer.Name, 
                    $template
                )
                
                if ($needsEnrollment) {
                    $this.EnrollmentQueue += @{
                        ComputerName = $computer.Name
                        Template = $template
                        Priority = $this.CalculatePriority($computer)
                        RetryCount = 0
                        Status = "Pending"
                    }
                }
            }
        }
        
        # Sort by priority
        $this.EnrollmentQueue = $this.EnrollmentQueue | 
            Sort-Object -Property Priority -Descending
        
        Write-Host "Queue built: $($this.EnrollmentQueue.Count) enrollments pending" -ForegroundColor Green
    }
    
    [array] GetRequiredTemplates([object]$computer) {
        $templates = @()
        
        # Base computer template
        $templates += "Company-Computer-Authentication"
        
        # Role-based templates
        if ($computer.OperatingSystem -like "*Server*") {
            if ($computer.ServicePrincipalName -match "HTTP/") {
                $templates += "Company-Web-Server"
            }
            if ($computer.ServicePrincipalName -match "MSSQLSvc/") {
                $templates += "Company-SQL-Server"
            }
            if ($computer.Name -match "DC\d+") {
                $templates += "Company-Domain-Controller"
            }
        }
        
        # Group-based templates
        foreach ($group in $computer.MemberOf) {
            $groupName = ($group -split ',')[0] -replace 'CN=', ''
            
            switch -Wildcard ($groupName) {
                "*Code-Signing*" { $templates += "Company-Code-Signing" }
                "*VPN-Servers*" { $templates += "Company-VPN-Server" }
                "*WiFi-Auth*" { $templates += "Company-802.1x" }
            }
        }
        
        return $templates | Select-Object -Unique
    }
    
    [bool] CheckEnrollmentNeeded([string]$computerName, [string]$template) {
        try {
            $existingCert = Invoke-Command -ComputerName $computerName -ScriptBlock {
                param($tpl)
                Get-ChildItem Cert:\LocalMachine\My | Where-Object {
                    $_.Extensions | Where-Object {
                        $_.Oid.Value -eq "1.3.6.1.4.1.311.21.7" -and
                        $_.Format(0) -match $tpl
                    }
                }
            } -ArgumentList $template -ErrorAction Stop
            
            if ($existingCert) {
                $daysUntilExpiry = ($existingCert.NotAfter - (Get-Date)).Days
                
                # Check renewal threshold
                $renewalThreshold = $this.Config.Templates.$template.RenewalDays
                if ($daysUntilExpiry -le $renewalThreshold) {
                    Write-Verbose "$computerName : Certificate expiring in $daysUntilExpiry days"
                    return $true
                }
                
                return $false
            }
            
            return $true
            
        } catch {
            Write-Warning "Could not check $computerName : $_"
            return $true  # Assume enrollment needed if we can't check
        }
    }
    
    [int] CalculatePriority([object]$computer) {
        $priority = 0
        
        # Critical servers get highest priority
        if ($computer.Name -match "DC\d+") { $priority += 1000 }
        if ($computer.ServicePrincipalName -match "HTTP/") { $priority += 500 }
        if ($computer.OperatingSystem -like "*Server*") { $priority += 100 }
        
        # Recently active computers get higher priority
        if ($computer.LastLogonDate) {
            $daysSinceLogon = ((Get-Date) - $computer.LastLogonDate).Days
            if ($daysSinceLogon -le 1) { $priority += 50 }
            elseif ($daysSinceLogon -le 7) { $priority += 25 }
        }
        
        return $priority
    }
    
    [void] ProcessEnrollments() {
        Write-Host "Processing enrollments..." -ForegroundColor Cyan
        
        $batches = @()
        for ($i = 0; $i -lt $this.EnrollmentQueue.Count; $i += $this.BatchSize) {
            $batches += ,@($this.EnrollmentQueue[$i..([Math]::Min($i + $this.BatchSize - 1, $this.EnrollmentQueue.Count - 1))])
        }
        
        $batchNumber = 1
        foreach ($batch in $batches) {
            Write-Host "Processing batch $batchNumber of $($batches.Count)" -ForegroundColor Yellow
            
            $jobs = @()
            foreach ($enrollment in $batch) {
                if ($enrollment.Status -eq "Pending") {
                    $jobs += Start-Job -ScriptBlock {
                        param($enrollment, $config)
                        
                        . C:\PKI\Scripts\Certificate-Functions.ps1
                        
                        try {
                            $result = Request-CertificateEnrollment `
                                -ComputerName $enrollment.ComputerName `
                                -Template $enrollment.Template `
                                -CAServer $config.CAServer
                            
                            return @{
                                Success = $true
                                Enrollment = $enrollment
                                Certificate = $result
                            }
                        } catch {
                            return @{
                                Success = $false
                                Enrollment = $enrollment
                                Error = $_.Exception.Message
                            }
                        }
                    } -ArgumentList $enrollment, $this.Config
                }
            }
            
            # Wait for batch to complete
            $timeout = New-TimeSpan -Minutes 10
            $jobs | Wait-Job -Timeout $timeout.TotalSeconds | Out-Null
            
            # Process results
            foreach ($job in $jobs) {
                if ($job.State -eq "Completed") {
                    $result = Receive-Job -Job $job
                    
                    if ($result.Success) {
                        $result.Enrollment.Status = "Completed"
                        Write-Host "  ✓ $($result.Enrollment.ComputerName) - $($result.Enrollment.Template)" -ForegroundColor Green
                    } else {
                        $result.Enrollment.RetryCount++
                        
                        if ($result.Enrollment.RetryCount -ge $this.MaxRetries) {
                            $result.Enrollment.Status = "Failed"
                            Write-Host "  ✗ $($result.Enrollment.ComputerName) - Max retries exceeded" -ForegroundColor Red
                        } else {
                            $result.Enrollment.Status = "Retry"
                            Write-Host "  ↻ $($result.Enrollment.ComputerName) - Will retry" -ForegroundColor Yellow
                        }
                    }
                    
                    $this.Results += $result
                } else {
                    Write-Warning "Job timeout for enrollment"
                    Stop-Job -Job $job
                }
                
                Remove-Job -Job $job
            }
            
            $batchNumber++
            
            # Brief pause between batches
            if ($batchNumber -le $batches.Count) {
                Start-Sleep -Seconds 30
            }
        }
        
        # Process retries
        $retryItems = $this.EnrollmentQueue | Where-Object { $_.Status -eq "Retry" }
        if ($retryItems.Count -gt 0) {
            Write-Host "Processing $($retryItems.Count) retries..." -ForegroundColor Yellow
            $this.ProcessRetries($retryItems)
        }
    }
    
    [void] ProcessRetries([array]$retryItems) {
        foreach ($item in $retryItems) {
            Start-Sleep -Seconds 60  # Wait before retry
            
            try {
                $result = Request-CertificateEnrollment `
                    -ComputerName $item.ComputerName `
                    -Template $item.Template `
                    -CAServer $this.Config.CAServer
                
                $item.Status = "Completed"
                Write-Host "  ✓ Retry successful: $($item.ComputerName)" -ForegroundColor Green
                
            } catch {
                $item.Status = "Failed"
                Write-Host "  ✗ Retry failed: $($item.ComputerName)" -ForegroundColor Red
            }
        }
    }
    
    [void] GenerateReport() {
        $report = @{
            Timestamp = Get-Date
            TotalEnrollments = $this.EnrollmentQueue.Count
            Successful = ($this.EnrollmentQueue | Where-Object { $_.Status -eq "Completed" }).Count
            Failed = ($this.EnrollmentQueue | Where-Object { $_.Status -eq "Failed" }).Count
            Pending = ($this.EnrollmentQueue | Where-Object { $_.Status -eq "Pending" }).Count
        }
        
        $report.SuccessRate = if ($report.TotalEnrollments -gt 0) {
            [Math]::Round(($report.Successful / $report.TotalEnrollments) * 100, 2)
        } else { 0 }
        
        # Export detailed results
        $this.EnrollmentQueue | Export-Csv -Path "C:\PKI\Reports\AutoEnrollment-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
        
        # Display summary
        Write-Host "`n=== Auto-Enrollment Summary ===" -ForegroundColor Cyan
        Write-Host "Total Enrollments: $($report.TotalEnrollments)" -ForegroundColor Gray
        Write-Host "Successful: $($report.Successful)" -ForegroundColor Green
        Write-Host "Failed: $($report.Failed)" -ForegroundColor Red
        Write-Host "Success Rate: $($report.SuccessRate)%" -ForegroundColor Yellow
    }
}

# Main execution
$engine = [AutoEnrollmentEngine]::new($ConfigFile, $MaxRetries, $BatchSize)
$engine.BuildEnrollmentQueue()
$engine.ProcessEnrollments()
$engine.GenerateReport()
```

### Certificate Renewal Automation

```powershell
# Start-CertificateRenewalAutomation.ps1
# Intelligent certificate renewal with predictive scheduling

function Start-CertificateRenewalAutomation {
    [CmdletBinding()]
    param(
        [int]$DaysBeforeExpiry = 30,
        [int]$MaxConcurrentRenewals = 10,
        [switch]$PredictiveMode,
        [switch]$WhatIf
    )
    
    begin {
        $renewalPlan = @{
            Immediate = @()
            Scheduled = @()
            Deferred = @()
        }
        
        # Load ML model for predictive renewal if enabled
        if ($PredictiveMode) {
            $mlModel = Import-MLModel -Path "C:\PKI\ML\RenewalPredictor.model"
        }
    }
    
    process {
        # Scan all certificates
        Write-Host "Scanning for certificates requiring renewal..." -ForegroundColor Cyan
        
        $allCertificates = Get-EnterpriseCertificates
        
        foreach ($cert in $allCertificates) {
            $daysRemaining = ($cert.NotAfter - (Get-Date)).Days
            
            if ($PredictiveMode) {
                # Use ML model to predict optimal renewal time
                $optimalRenewalDays = Invoke-MLPrediction -Model $mlModel -Certificate $cert
                $shouldRenew = $daysRemaining -le $optimalRenewalDays
            } else {
                $shouldRenew = $daysRemaining -le $DaysBeforeExpiry
            }
            
            if ($shouldRenew) {
                $priority = Get-RenewalPriority -Certificate $cert
                
                switch ($priority) {
                    "Critical" { $renewalPlan.Immediate += $cert }
                    "High" { $renewalPlan.Scheduled += $cert }
                    "Normal" { $renewalPlan.Deferred += $cert }
                }
            }
        }
        
        Write-Host "Found $($renewalPlan.Immediate.Count) immediate renewals needed" -ForegroundColor Yellow
        Write-Host "Found $($renewalPlan.Scheduled.Count) scheduled renewals" -ForegroundColor Yellow
        Write-Host "Found $($renewalPlan.Deferred.Count) deferred renewals" -ForegroundColor Yellow
        
        if ($WhatIf) {
            Write-Host "`nWhat-If Mode: No renewals will be performed" -ForegroundColor Cyan
            return $renewalPlan
        }
        
        # Process immediate renewals
        if ($renewalPlan.Immediate.Count -gt 0) {
            Write-Host "`nProcessing immediate renewals..." -ForegroundColor Red
            
            $throttle = New-Object System.Threading.Semaphore($MaxConcurrentRenewals, $MaxConcurrentRenewals)
            $jobs = @()
            
            foreach ($cert in $renewalPlan.Immediate) {
                $throttle.WaitOne()
                
                $jobs += Start-ThreadJob -ScriptBlock {
                    param($certificate, $semaphore)
                    
                    try {
                        $newCert = Invoke-CertificateRenewal -Certificate $certificate
                        
                        # Update bindings
                        Update-CertificateBindings -OldCert $certificate -NewCert $newCert
                        
                        return @{
                            Success = $true
                            OldCert = $certificate.Thumbprint
                            NewCert = $newCert.Thumbprint
                        }
                    } catch {
                        return @{
                            Success = $false
                            OldCert = $certificate.Thumbprint
                            Error = $_.Exception.Message
                        }
                    } finally {
                        $semaphore.Release()
                    }
                } -ArgumentList $cert, $throttle
            }
            
            # Wait for all jobs
            $results = $jobs | Wait-Job | Receive-Job
            $jobs | Remove-Job
            
            # Report results
            $successful = ($results | Where-Object { $_.Success }).Count
            $failed = ($results | Where-Object { -not $_.Success }).Count
            
            Write-Host "Immediate renewals: $successful successful, $failed failed" -ForegroundColor $(if ($failed -eq 0) {"Green"} else {"Yellow"})
        }
        
        # Schedule future renewals
        if ($renewalPlan.Scheduled.Count -gt 0) {
            Write-Host "`nScheduling future renewals..." -ForegroundColor Yellow
            
            foreach ($cert in $renewalPlan.Scheduled) {
                $scheduledDate = $cert.NotAfter.AddDays(-$DaysBeforeExpiry)
                
                Register-ScheduledJob -Name "Renew-$($cert.Thumbprint)" `
                    -ScriptBlock {
                        param($certThumbprint)
                        . C:\PKI\Scripts\Certificate-Functions.ps1
                        $cert = Get-Certificate -Thumbprint $certThumbprint
                        Invoke-CertificateRenewal -Certificate $cert
                    } -ArgumentList $cert.Thumbprint `
                    -Trigger (New-JobTrigger -Once -At $scheduledDate)
                
                Write-Host "  Scheduled renewal for $($cert.Subject) on $($scheduledDate.ToString('yyyy-MM-dd'))" -ForegroundColor Gray
            }
        }
    }
    
    end {
        # Generate renewal report
        $report = @{
            RunDate = Get-Date
            ImmediateRenewals = $renewalPlan.Immediate.Count
            ScheduledRenewals = $renewalPlan.Scheduled.Count
            DeferredRenewals = $renewalPlan.Deferred.Count
            Results = $results
        }
        
        $report | ConvertTo-Json -Depth 5 | Out-File "C:\PKI\Reports\RenewalAutomation-$(Get-Date -Format 'yyyyMMdd').json"
        
        return $report
    }
}
```

## Monitoring and Health Check Tools

### Comprehensive Health Monitor

```powershell
# Start-PKIHealthMonitor.ps1
# Real-time PKI health monitoring with predictive analytics

class PKIHealthMonitor {
    [hashtable]$Config
    [System.Collections.ArrayList]$MetricsHistory
    [hashtable]$Thresholds
    [bool]$IsRunning
    
    PKIHealthMonitor() {
        $this.Config = @{
            CheckInterval = 300  # 5 minutes
            MetricRetention = 168  # hours
            AlertChannels = @("Email", "Teams", "SIEM")
        }
        
        $this.MetricsHistory = [System.Collections.ArrayList]::new()
        
        $this.Thresholds = @{
            CAResponseTime = 5000  # ms
            CertIssuanceRate = 100  # per minute
            ErrorRate = 0.05  # 5%
            CRLSize = 10  # MB
            DiskSpace = 20  # GB minimum
            CPUUsage = 80  # percent
        }
        
        $this.IsRunning = $false
    }
    
    [void] Start() {
        $this.IsRunning = $true
        Write-Host "PKI Health Monitor started" -ForegroundColor Green
        
        while ($this.IsRunning) {
            $metrics = $this.CollectMetrics()
            $this.AnalyzeMetrics($metrics)
            $this.MetricsHistory.Add($metrics)
            $this.PruneHistory()
            
            Start-Sleep -Seconds $this.Config.CheckInterval
        }
    }
    
    [hashtable] CollectMetrics() {
        $metrics = @{
            Timestamp = Get-Date
            Services = @{}
            Performance = @{}
            Certificates = @{}
            Security = @{}
        }
        
        # Service health
        $caServers = @("PKI-ICA-01", "PKI-ICA-02")
        foreach ($server in $caServers) {
            $metrics.Services[$server] = @{
                CertSvc = (Get-Service -ComputerName $server -Name CertSvc).Status
                IIS = (Get-Service -ComputerName $server -Name W3SVC -ErrorAction SilentlyContinue).Status
                ResponseTime = (Measure-Command {
                    Test-NetConnection -ComputerName $server -Port 135
                }).TotalMilliseconds
            }
        }
        
        # Performance metrics
        $metrics.Performance = @{
            IssuanceRate = $this.GetIssuanceRate()
            OCSPResponseTime = $this.MeasureOCSPResponse()
            CRLSize = $this.GetCRLSize()
            DatabaseSize = $this.GetDatabaseSize()
            DiskSpace = $this.GetDiskSpace()
            CPUUsage = $this.GetCPUUsage()
        }
        
        # Certificate metrics
        $metrics.Certificates = @{
            ExpiringIn7Days = $this.CountExpiringCertificates(7)
            ExpiringIn30Days = $this.CountExpiringCertificates(30)
            IssuedToday = $this.CountIssuedToday()
            RevokedToday = $this.CountRevokedToday()
            PendingRequests = $this.CountPendingRequests()
        }
        
        # Security metrics
        $metrics.Security = @{
            FailedRequests = $this.CountFailedRequests()
            SuspiciousActivity = $this.DetectSuspiciousActivity()
            ComplianceStatus = $this.CheckCompliance()
        }
        
        return $metrics
    }
    
    [void] AnalyzeMetrics([hashtable]$metrics) {
        $alerts = @()
        
        # Check service health
        foreach ($server in $metrics.Services.Keys) {
            if ($metrics.Services[$server].CertSvc -ne "Running") {
                $alerts += @{
                    Severity = "Critical"
                    Message = "Certificate Service down on $server"
                    Action = "Restart service immediately"
                }
            }
            
            if ($metrics.Services[$server].ResponseTime -gt $this.Thresholds.CAResponseTime) {
                $alerts += @{
                    Severity = "Warning"
                    Message = "Slow response from $server : $($metrics.Services[$server].ResponseTime)ms"
                    Action = "Investigate performance"
                }
            }
        }
        
        # Check performance
        if ($metrics.Performance.CPUUsage -gt $this.Thresholds.CPUUsage) {
            $alerts += @{
                Severity = "Warning"
                Message = "High CPU usage: $($metrics.Performance.CPUUsage)%"
                Action = "Check for runaway processes"
            }
        }
        
        if ($metrics.Performance.DiskSpace -lt $this.Thresholds.DiskSpace) {
            $alerts += @{
                Severity = "Critical"
                Message = "Low disk space: $($metrics.Performance.DiskSpace)GB remaining"
                Action = "Free up disk space immediately"
            }
        }
        
        # Check certificates
        if ($metrics.Certificates.ExpiringIn7Days -gt 0) {
            $alerts += @{
                Severity = "High"
                Message = "$($metrics.Certificates.ExpiringIn7Days) certificates expiring within 7 days"
                Action = "Initiate renewal process"
            }
        }
        
        # Check security
        if ($metrics.Security.SuspiciousActivity) {
            $alerts += @{
                Severity = "Critical"
                Message = "Suspicious activity detected"
                Action = "Review security logs immediately"
            }
        }
        
        # Send alerts
        if ($alerts.Count -gt 0) {
            $this.SendAlerts($alerts)
        }
        
        # Predictive analysis
        if ($this.MetricsHistory.Count -gt 24) {  # Need 24 hours of data
            $prediction = $this.PredictIssues()
            if ($prediction.IssuesPredicted) {
                $this.SendPredictiveAlert($prediction)
            }
        }
    }
    
    [hashtable] PredictIssues() {
        # Simple trend analysis - could be enhanced with ML
        $recentMetrics = $this.MetricsHistory[-24..-1]
        
        $cpuTrend = $recentMetrics | ForEach-Object { $_.Performance.CPUUsage } | 
            Measure-Object -Average -Maximum
        
        $diskTrend = $recentMetrics | ForEach-Object { $_.Performance.DiskSpace } |
            Measure-Object -Average -Minimum
        
        $prediction = @{
            IssuesPredicted = $false
            Predictions = @()
        }
        
        # CPU trending up
        if ($cpuTrend.Average -gt 60 -and $cpuTrend.Maximum -gt $cpuTrend.Average * 1.2) {
            $prediction.IssuesPredicted = $true
            $prediction.Predictions += "CPU usage trending upward - may hit threshold soon"
        }
        
        # Disk space decreasing
        if ($diskTrend.Minimum -lt $diskTrend.Average * 0.8) {
            $prediction.IssuesPredicted = $true
            $hoursUntilFull = $diskTrend.Minimum / (($diskTrend.Average - $diskTrend.Minimum) / 24)
            $prediction.Predictions += "Disk space decreasing - estimated full in $([Math]::Round($hoursUntilFull, 1)) hours"
        }
        
        return $prediction
    }
    
    [void] SendAlerts([array]$alerts) {
        foreach ($alert in $alerts) {
            # Log to Event Log
            Write-EventLog -LogName "PKI-Monitoring" -Source "HealthMonitor" `
                -EventId 5000 -EntryType $(
                    switch ($alert.Severity) {
                        "Critical" { "Error" }
                        "High" { "Warning" }
                        default { "Information" }
                    }
                ) -Message "$($alert.Message)`n`nAction: $($alert.Action)"
            
            # Send to configured channels
            if ($this.Config.AlertChannels -contains "Email") {
                Send-PKIAlert -Channel "Email" -Alert $alert
            }
            
            if ($this.Config.AlertChannels -contains "Teams") {
                Send-PKIAlert -Channel "Teams" -Alert $alert
            }
            
            if ($this.Config.AlertChannels -contains "SIEM") {
                Send-PKIAlert -Channel "SIEM" -Alert $alert
            }
        }
    }
    
    [void] Stop() {
        $this.IsRunning = $false
        Write-Host "PKI Health Monitor stopped" -ForegroundColor Yellow
    }
}

# Start the monitor
$monitor = [PKIHealthMonitor]::new()
$monitor.Start()
```

## Bulk Operations Scripts

### Mass Certificate Deployment

```powershell
# Deploy-BulkCertificates.ps1
# Deploy certificates to multiple targets simultaneously

function Deploy-BulkCertificates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TargetListFile,
        
        [Parameter(Mandatory)]
        [string]$Template,
        
        [int]$ParallelJobs = 20,
        
        [string]$LogPath = "C:\PKI\Logs\BulkDeploy"
    )
    
    # Import target list
    $targets = Import-Csv $TargetListFile
    
    Write-Host "Starting bulk certificate deployment" -ForegroundColor Cyan
    Write-Host "Targets: $($targets.Count)" -ForegroundColor Gray
    Write-Host "Template: $Template" -ForegroundColor Gray
    
    # Create deployment packages
    $deploymentPackages = foreach ($target in $targets) {
        @{
            ComputerName = $target.ComputerName
            Template = $Template
            Subject = $target.Subject
            SAN = $target.SAN -split ';'
            KeySize = if ($target.KeySize) { $target.KeySize } else { 2048 }
            Exportable = if ($target.Exportable) { [bool]$target.Exportable } else { $false }
        }
    }
    
    # Deploy in parallel
    $results = $deploymentPackages | ForEach-Object -Parallel {
        $package = $_
        
        try {
            # Generate CSR on target
            $csr = Invoke-Command -ComputerName $package.ComputerName -ScriptBlock {
                param($subject, $keySize)
                
                $inf = @"
[NewRequest]
Subject = "$subject"
KeyLength = $keySize
Exportable = TRUE
MachineKeySet = TRUE
SMIME = FALSE
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@
                
                $inf | Out-File "$env:TEMP\request.inf"
                certreq -new "$env:TEMP\request.inf" "$env:TEMP\request.csr"
                Get-Content "$env:TEMP\request.csr" -Raw
                
            } -ArgumentList $package.Subject, $package.KeySize
            
            # Submit to CA
            $response = certreq -submit -config "PKI-ICA-01\Company Issuing CA 01" `
                -attrib "CertificateTemplate:$($package.Template)" `
                $csr
            
            if ($response -match "Issued") {
                $requestId = $response | Select-String -Pattern "RequestId: (\d+)" | 
                    ForEach-Object { $_.Matches[0].Groups[1].Value }
                
                # Retrieve and install certificate
                Invoke-Command -ComputerName $package.ComputerName -ScriptBlock {
                    param($reqId)
                    certreq -retrieve -config "PKI-ICA-01\Company Issuing CA 01" $reqId "$env:TEMP\cert.cer"
                    certreq -accept "$env:TEMP\cert.cer"
                } -ArgumentList $requestId
                
                return @{
                    ComputerName = $package.ComputerName
                    Status = "Success"
                    RequestId = $requestId
                }
            } else {
                throw "Certificate request failed: $response"
            }
            
        } catch {
            return @{
                ComputerName = $package.ComputerName
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
    } -ThrottleLimit $ParallelJobs
    
    # Generate report
    $successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
    $failCount = ($results | Where-Object { $_.Status -eq "Failed" }).Count
    
    Write-Host "`nDeployment Complete" -ForegroundColor Green
    Write-Host "Success: $successCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) {"Red"} else {"Gray"})
    
    # Export results
    $results | Export-Csv -Path "$LogPath\BulkDeploy-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
    
    return $results
}
```

## Security and Compliance Automation

### Compliance Scanner

```python
#!/usr/bin/env python3
# pki_compliance_scanner.py
# Automated PKI compliance scanning and reporting

import json
import datetime
import asyncio
import aiohttp
from typing import Dict, List, Any
from dataclasses import dataclass, asdict
from enum import Enum

class ComplianceLevel(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"

@dataclass
class ComplianceCheck:
    name: str
    category: str
    description: str
    level: ComplianceLevel
    passed: bool
    details: str
    remediation: str = ""

class PKIComplianceScanner:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        self.checks = []
        self.results = {
            'timestamp': datetime.datetime.now().isoformat(),
            'overall_compliance': 0,
            'checks_performed': 0,
            'checks_passed': 0,
            'critical_issues': [],
            'recommendations': []
        }
    
    async def run_compliance_scan(self) -> Dict[str, Any]:
        """Run all compliance checks"""
        print("Starting PKI Compliance Scan...")
        
        # Run checks in parallel
        tasks = [
            self.check_certificate_validity(),
            self.check_key_strength(),
            self.check_algorithm_compliance(),
            self.check_crl_validity(),
            self.check_ocsp_availability(),
            self.check_audit_logging(),
            self.check_access_controls(),
            self.check_backup_compliance(),
            self.check_template_security(),
            self.check_network_security()
        ]
        
        await asyncio.gather(*tasks)
        
        # Calculate compliance score
        self.calculate_compliance_score()
        
        # Generate recommendations
        self.generate_recommendations()
        
        return self.results
    
    async def check_certificate_validity(self):
        """Check certificate validity periods"""
        check = ComplianceCheck(
            name="Certificate Validity Periods",
            category="Certificate Management",
            description="Verify certificate validity periods comply with policy",
            level=ComplianceLevel.HIGH,
            passed=True,
            details=""
        )
        
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config['api_endpoint']}/certificates") as resp:
                certificates = await resp.json()
        
        non_compliant = []
        for cert in certificates:
            validity_days = (cert['not_after'] - cert['not_before']).days
            max_validity = self.config['max_validity_days'].get(cert['template'], 365)
            
            if validity_days > max_validity:
                non_compliant.append({
                    'subject': cert['subject'],
                    'validity': validity_days,
                    'max_allowed': max_validity
                })
        
        if non_compliant:
            check.passed = False
            check.details = f"Found {len(non_compliant)} certificates exceeding validity limits"
            check.remediation = "Review and reissue certificates with appropriate validity periods"
        else:
            check.details = "All certificates within validity limits"
        
        self.checks.append(check)
    
    async def check_key_strength(self):
        """Verify minimum key strength requirements"""
        check = ComplianceCheck(
            name="Cryptographic Key Strength",
            category="Cryptography",
            description="Ensure all keys meet minimum strength requirements",
            level=ComplianceLevel.CRITICAL,
            passed=True,
            details=""
        )
        
        weak_keys = []
        
        # Check RSA keys
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config['api_endpoint']}/keys") as resp:
                keys = await resp.json()
        
        for key in keys:
            if key['algorithm'] == 'RSA' and key['size'] < 2048:
                weak_keys.append({
                    'id': key['id'],
                    'algorithm': key['algorithm'],
                    'size': key['size']
                })
            elif key['algorithm'] == 'ECC' and key['curve'] not in ['P-256', 'P-384', 'P-521']:
                weak_keys.append({
                    'id': key['id'],
                    'algorithm': key['algorithm'],
                    'curve': key['curve']
                })
        
        if weak_keys:
            check.passed = False
            check.details = f"Found {len(weak_keys)} keys below minimum strength"
            check.remediation = "Replace weak keys with stronger alternatives (RSA ≥2048, ECC P-256+)"
            self.results['critical_issues'].append("Weak cryptographic keys detected")
        else:
            check.details = "All keys meet minimum strength requirements"
        
        self.checks.append(check)
    
    async def check_algorithm_compliance(self):
        """Check for deprecated or non-compliant algorithms"""
        check = ComplianceCheck(
            name="Algorithm Compliance",
            category="Cryptography",
            description="Verify only approved algorithms are in use",
            level=ComplianceLevel.HIGH,
            passed=True,
            details=""
        )
        
        deprecated_algorithms = ['MD5', 'SHA1', 'DES', '3DES', 'RC4']
        found_deprecated = []
        
        # Check certificates
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config['api_endpoint']}/certificates/algorithms") as resp:
                algorithms_in_use = await resp.json()
        
        for algo in algorithms_in_use:
            if algo['name'] in deprecated_algorithms:
                found_deprecated.append(algo)
        
        if found_deprecated:
            check.passed = False
            check.details = f"Found {len(found_deprecated)} deprecated algorithms in use"
            check.remediation = "Migrate to approved algorithms (SHA256+, AES, RSA, ECC)"
        else:
            check.details = "Only approved algorithms in use"
        
        self.checks.append(check)
    
    async def check_audit_logging(self):
        """Verify audit logging is properly configured"""
        check = ComplianceCheck(
            name="Audit Logging",
            category="Security",
            description="Ensure comprehensive audit logging is enabled",
            level=ComplianceLevel.CRITICAL,
            passed=True,
            details=""
        )
        
        required_events = [
            'certificate_issued',
            'certificate_revoked',
            'ca_configuration_changed',
            'failed_authentication',
            'template_modified',
            'key_archived',
            'key_recovered'
        ]
        
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.config['api_endpoint']}/audit/config") as resp:
                audit_config = await resp.json()
        
        missing_events = []
        for event in required_events:
            if event not in audit_config['logged_events']:
                missing_events.append(event)
        
        if missing_events:
            check.passed = False
            check.details = f"Missing audit logging for: {', '.join(missing_events)}"
            check.remediation = "Enable logging for all security-relevant events"
        else:
            check.details = "All required events are being logged"
        
        self.checks.append(check)
    
    def calculate_compliance_score(self):
        """Calculate overall compliance score"""
        total_checks = len(self.checks)
        passed_checks = sum(1 for check in self.checks if check.passed)
        
        # Weight by severity
        weighted_score = 0
        weights = {
            ComplianceLevel.CRITICAL: 5,
            ComplianceLevel.HIGH: 3,
            ComplianceLevel.MEDIUM: 2,
            ComplianceLevel.LOW: 1,
            ComplianceLevel.INFO: 0.5
        }
        
        total_weight = sum(weights[check.level] for check in self.checks)
        passed_weight = sum(weights[check.level] for check in self.checks if check.passed)
        
        self.results['overall_compliance'] = round((passed_weight / total_weight) * 100, 2)
        self.results['checks_performed'] = total_checks
        self.results['checks_passed'] = passed_checks
        self.results['checks'] = [asdict(check) for check in self.checks]
    
    def generate_recommendations(self):
        """Generate compliance recommendations"""
        for check in self.checks:
            if not check.passed:
                self.results['recommendations'].append({
                    'category': check.category,
                    'issue': check.name,
                    'severity': check.level.value,
                    'recommendation': check.remediation
                })
        
        # Sort by severity
        severity_order = ['critical', 'high', 'medium', 'low', 'info']
        self.results['recommendations'].sort(
            key=lambda x: severity_order.index(x['severity'])
        )
    
    def export_report(self, format: str = 'json'):
        """Export compliance report"""
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        
        if format == 'json':
            with open(f'compliance_report_{timestamp}.json', 'w') as f:
                json.dump(self.results, f, indent=2, default=str)
        
        elif format == 'html':
            html_report = self.generate_html_report()
            with open(f'compliance_report_{timestamp}.html', 'w') as f:
                f.write(html_report)
    
    def generate_html_report(self) -> str:
        """Generate HTML compliance report"""
        compliance_color = 'green' if self.results['overall_compliance'] >= 90 else \
                          'orange' if self.results['overall_compliance'] >= 70 else 'red'
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>PKI Compliance Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background: #333; color: white; padding: 20px; }}
                .score {{ font-size: 48px; color: {compliance_color}; }}
                .critical {{ color: red; }}
                .high {{ color: orange; }}
                .medium {{ color: yellow; }}
                .low {{ color: blue; }}
                .passed {{ color: green; }}
                .failed {{ color: red; }}
                table {{ width: 100%; border-collapse: collapse; }}
                th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background: #f2f2f2; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>PKI Compliance Report</h1>
                <p>Generated: {self.results['timestamp']}</p>
                <div class="score">{self.results['overall_compliance']}%</div>
            </div>
            
            <h2>Summary</h2>
            <p>Checks Performed: {self.results['checks_performed']}</p>
            <p>Checks Passed: {self.results['checks_passed']}</p>
            
            <h2>Compliance Checks</h2>
            <table>
                <tr>
                    <th>Category</th>
                    <th>Check</th>
                    <th>Level</th>
                    <th>Status</th>
                    <th>Details</th>
                </tr>
        """
        
        for check in self.results['checks']:
            status_class = 'passed' if check['passed'] else 'failed'
            status_text = '✓' if check['passed'] else '✗'
            
            html += f"""
                <tr>
                    <td>{check['category']}</td>
                    <td>{check['name']}</td>
                    <td class="{check['level']}">{check['level']}</td>
                    <td class="{status_class}">{status_text}</td>
                    <td>{check['details']}</td>
                </tr>
            """
        
        html += """
            </table>
            
            <h2>Recommendations</h2>
            <ol>
        """
        
        for rec in self.results['recommendations']:
            html += f"<li class='{rec['severity']}'>{rec['recommendation']}</li>"
        
        html += """
            </ol>
        </body>
        </html>
        """
        
        return html

# Run compliance scan
async def main():
    scanner = PKIComplianceScanner('pki_compliance_config.json')
    results = await scanner.run_compliance_scan()
    scanner.export_report('html')
    print(f"Compliance Score: {results['overall_compliance']}%")

if __name__ == "__main__":
    asyncio.run(main())
```

## PowerShell Module: PKIManager

### Complete PKI Management Module

```powershell
# PKIManager.psm1
# Comprehensive PKI management PowerShell module

#region Module Variables

$script:ModuleRoot = $PSScriptRoot
$script:ConfigPath = "$ModuleRoot\Config"
$script:LogPath = "$ModuleRoot\Logs"

#endregion

#region Core Functions

function Connect-PKIManagement {
    <#
    .SYNOPSIS
    Establishes connection to PKI management infrastructure
    
    .DESCRIPTION
    Connects to PKI servers, validates credentials, and initializes session
    
    .EXAMPLE
    Connect-PKIManagement -CAServer "PKI-ICA-01" -Credential (Get-Credential)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CAServer,
        
        [Parameter()]
        [PSCredential]$Credential,
        
        [switch]$UseSSL
    )
    
    # Implementation here
    $script:PKISession = @{
        CAServer = $CAServer
        Credential = $Credential
        UseSSL = $UseSSL
        Connected = $true
        ConnectionTime = Get-Date
    }
    
    Write-Verbose "Connected to PKI infrastructure"
    return $script:PKISession
}

function Get-PKICertificate {
    <#
    .SYNOPSIS
    Retrieves certificates from PKI infrastructure
    
    .DESCRIPTION
    Gets certificates based on various filter criteria
    
    .EXAMPLE
    Get-PKICertificate -Subject "CN=*.company.com" -ExpiringInDays 30
    #>
    [CmdletBinding()]
    param(
        [string]$Subject,
        [string]$Issuer,
        [string]$SerialNumber,
        [string]$Thumbprint,
        [int]$ExpiringInDays,
        [datetime]$IssuedAfter,
        [datetime]$IssuedBefore,
        [string]$Template,
        [ValidateSet('Issued', 'Revoked', 'Pending', 'Failed')]
        [string]$Status
    )
    
    # Build filter
    $filter = @{}
    if ($Subject) { $filter.Subject = $Subject }
    if ($Issuer) { $filter.Issuer = $Issuer }
    if ($SerialNumber) { $filter.SerialNumber = $SerialNumber }
    if ($Template) { $filter.Template = $Template }
    if ($Status) { $filter.Status = $Status }
    
    # Query certificates
    $certificates = Invoke-PKIQuery -Filter $filter
    
    # Apply additional filters
    if ($ExpiringInDays) {
        $expiryDate = (Get-Date).AddDays($ExpiringInDays)
        $certificates = $certificates | Where-Object {
            $_.NotAfter -le $expiryDate -and $_.NotAfter -gt (Get-Date)
        }
    }
    
    return $certificates
}

function New-PKICertificateRequest {
    <#
    .SYNOPSIS
    Creates a new certificate request
    
    .DESCRIPTION
    Generates certificate request and submits to CA
    
    .EXAMPLE
    New-PKICertificateRequest -Template "WebServer" -Subject "CN=www.company.com"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Template,
        
        [Parameter(Mandatory)]
        [string]$Subject,
        
        [string[]]$SAN,
        
        [int]$KeySize = 2048,
        
        [switch]$Exportable,
        
        [string]$CAServer = $script:PKISession.CAServer
    )
    
    # Generate CSR
    $csr = New-CertificateSigningRequest @PSBoundParameters
    
    # Submit to CA
    $result = Submit-CertificateRequest -CSR $csr -CAServer $CAServer -Template $Template
    
    if ($result.Status -eq 'Issued') {
        return Get-PKICertificate -SerialNumber $result.SerialNumber
    } else {
        throw "Certificate request failed: $($result.Status)"
    }
}

function Revoke-PKICertificate {
    <#
    .SYNOPSIS
    Revokes a certificate
    
    .DESCRIPTION
    Revokes certificate with specified reason
    
    .EXAMPLE
    Revoke-PKICertificate -SerialNumber "1234567890" -Reason "KeyCompromise"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$SerialNumber,
        
        [Parameter(Mandatory)]
        [ValidateSet('Unspecified', 'KeyCompromise', 'CACompromise', 
                    'AffiliationChanged', 'Superseded', 'CessationOfOperation')]
        [string]$Reason,
        
        [string]$Comments
    )
    
    process {
        if ($PSCmdlet.ShouldProcess($SerialNumber, "Revoke certificate")) {
            $result = Invoke-CertificateRevocation -SerialNumber $SerialNumber -Reason $Reason
            
            # Log revocation
            Write-PKIAuditLog -Action "Revocation" -Target $SerialNumber -Details $Comments
            
            return $result
        }
    }
}

function Test-PKIHealth {
    <#
    .SYNOPSIS
    Tests PKI infrastructure health
    
    .DESCRIPTION
    Performs comprehensive health check of PKI components
    
    .EXAMPLE
    Test-PKIHealth -Verbose
    #>
    [CmdletBinding()]
    param()
    
    $healthChecks = @{
        CAServices = Test-CAServices
        OCSPResponders = Test-OCSPResponders
        CRLValidity = Test-CRLValidity
        CertificateChains = Test-CertificateChains
        NetworkConnectivity = Test-PKINetworkConnectivity
        DatabaseHealth = Test-CADatabaseHealth
    }
    
    $overallHealth = if (($healthChecks.Values | Where-Object { -not $_ }).Count -eq 0) {
        "Healthy"
    } else {
        "Degraded"
    }
    
    return [PSCustomObject]@{
        Timestamp = Get-Date
        OverallHealth = $overallHealth
        Details = $healthChecks
    }
}

#endregion

#region Export Members

Export-ModuleMember -Function @(
    'Connect-PKIManagement',
    'Get-PKICertificate',
    'New-PKICertificateRequest',
    'Revoke-PKICertificate',
    'Test-PKIHealth',
    'Get-PKITemplate',
    'Set-PKITemplate',
    'Export-PKICertificate',
    'Import-PKICertificate',
    'Get-PKIStatistics',
    'Start-PKIBackup',
    'Restore-PKIBackup',
    'Get-PKIAuditLog',
    'New-PKIReport',
    'Invoke-PKIMaintenance'
)

#endregion
```

## REST API Client Libraries

### Python PKI Client

```python
# pki_client.py
# Python client library for PKI REST API

import requests
import json
from typing import Optional, Dict, List, Any
from datetime import datetime, timedelta
import jwt
import base64
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa

class PKIClient:
    """Python client for PKI management API"""
    
    def __init__(self, api_url: str, api_key: str = None):
        self.api_url = api_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        
        if api_key:
            self.session.headers['X-API-Key'] = api_key
    
    def authenticate(self, username: str, password: str) -> str:
        """Authenticate and get JWT token"""
        response = self.session.post(
            f"{self.api_url}/auth",
            json={'username': username, 'password': password}
        )
        response.raise_for_status()
        
        token = response.json()['access_token']
        self.session.headers['Authorization'] = f'Bearer {token}'
        return token
    
    def request_certificate(
        self,
        template: str,
        subject: str,
        san: Optional[List[str]] = None,
        key_size: int = 2048
    ) -> Dict[str, Any]:
        """Request a new certificate"""
        
        # Generate private key
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=key_size
        )
        
        # Build CSR
        builder = x509.CertificateSigningRequestBuilder()
        builder = builder.subject_name(x509.Name([
            x509.NameAttribute(x509.NameOID.COMMON_NAME, subject)
        ]))
        
        if san:
            san_list = [x509.DNSName(name) for name in san]
            builder = builder.add_extension(
                x509.SubjectAlternativeName(san_list),
                critical=False
            )
        
        csr = builder.sign(private_key, hashes.SHA256())
        
        # Submit CSR
        csr_pem = csr.public_bytes(serialization.Encoding.PEM)
        
        response = self.session.post(
            f"{self.api_url}/certificate/request",
            json={
                'template': template,
                'csr': base64.b64encode(csr_pem).decode(),
                'subject': subject,
                'san': san
            }
        )
        response.raise_for_status()
        
        result = response.json()
        result['private_key'] = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode()
        
        return result
    
    def get_certificate(self, serial: str) -> Optional[Dict[str, Any]]:
        """Retrieve certificate by serial number"""
        response = self.session.get(f"{self.api_url}/certificate/{serial}")
        
        if response.status_code == 404:
            return None
        
        response.raise_for_status()
        return response.json()
    
    def revoke_certificate(self, serial: str, reason: str = 'unspecified') -> bool:
        """Revoke a certificate"""
        response = self.session.post(
            f"{self.api_url}/certificate/{serial}/revoke",
            json={'reason': reason}
        )
        response.raise_for_status()
        return response.json()['success']
    
    def list_certificates(
        self,
        template: Optional[str] = None,
        status: Optional[str] = None,
        expiring_days: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """List certificates with optional filters"""
        params = {}
        if template:
            params['template'] = template
        if status:
            params['status'] = status
        if expiring_days:
            params['expiring_days'] = expiring_days
        
        response = self.session.get(
            f"{self.api_url}/certificates",
            params=params
        )
        response.raise_for_status()
        return response.json()
    
    def validate_certificate(self, certificate_pem: str) -> Dict[str, Any]:
        """Validate a certificate"""
        response = self.session.post(
            f"{self.api_url}/certificate/validate",
            json={'certificate': certificate_pem}
        )
        response.raise_for_status()
        return response.json()
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get PKI statistics"""
        response = self.session.get(f"{self.api_url}/statistics")
        response.raise_for_status()
        return response.json()

# Example usage
if __name__ == "__main__":
    client = PKIClient("https://pki-api.company.com.au")
    client.authenticate("admin", "password")
    
    # Request certificate
    cert = client.request_certificate(
        template="WebServer",
        subject="www.example.com",
        san=["example.com", "api.example.com"]
    )
    
    print(f"Certificate issued: {cert['serial']}")
    
    # List expiring certificates
    expiring = client.list_certificates(expiring_days=30)
    print(f"Found {len(expiring)} expiring certificates")
```

## Summary

This automation toolkit provides:

1. **Certificate Lifecycle Automation**: Auto-enrollment, renewal, and revocation automation
2. **Monitoring Tools**: Real-time health monitoring with predictive analytics
3. **Bulk Operations**: Mass deployment and management capabilities
4. **Security Automation**: Compliance scanning and security monitoring
5. **PowerShell Module**: Comprehensive PKI management cmdlets
6. **API Clients**: Multi-language support for PKI operations

These tools significantly reduce manual effort, improve consistency, and enhance the security and reliability of the PKI infrastructure.

---

**Document Control**
- Version: 1.0
- Last Updated: April 2025
- Next Review: Quarterly
- Owner: PKI Automation Team
- Classification: Internal Use

---
[← Previous: Disaster Recovery](11-disaster-recovery.md) | [Back to Index](00-index.md)