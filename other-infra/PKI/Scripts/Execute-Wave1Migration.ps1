# Execute-Wave1Migration.ps1
# Production Wave 1 migration script

param(
    [string]$Wave1ListFile = "C:\Migration\Wave1\DeviceList.csv",
    [int]$BatchSize = 100,
    [int]$ParallelJobs = 10
)

# Load Wave 1 devices (4,000 systems)
$wave1Devices = Import-Csv $Wave1ListFile

Write-Host "Starting Production Wave 1 Migration" -ForegroundColor Cyan
Write-Host "Total devices: $($wave1Devices.Count)" -ForegroundColor Gray
Write-Host "Expected duration: 7 days" -ForegroundColor Gray

# Group devices by criticality
$deviceGroups = $wave1Devices | Group-Object -Property Criticality

foreach ($group in $deviceGroups | Sort-Object Name) {
    Write-Host "`nMigrating $($group.Name) criticality devices ($($group.Count) devices)" -ForegroundColor Yellow

    # Create maintenance window for critical systems
    if ($group.Name -eq "High") {
        $maintenanceWindow = New-MaintenanceWindow `
            -Start (Get-Date "22:00") `
            -Duration "06:00:00" `
            -Description "PKI Migration - Critical Systems"

        # Wait for maintenance window
        while ((Get-Date) -lt $maintenanceWindow.Start) {
            Write-Host "Waiting for maintenance window..." -ForegroundColor Gray
            Start-Sleep -Seconds 300
        }
    }

    # Process devices in parallel batches
    $devices = $group.Group
    for ($i = 0; $i -lt $devices.Count; $i += $BatchSize) {
        $batch = $devices[$i..[Math]::Min($i + $BatchSize - 1, $devices.Count - 1)]

        Write-Host "Processing batch $([Math]::Floor($i/$BatchSize) + 1) of $([Math]::Ceiling($devices.Count/$BatchSize))" -ForegroundColor Gray

        # Create parallel jobs
        $jobs = @()
        foreach ($device in $batch) {
            while ((Get-Job -State Running).Count -ge $ParallelJobs) {
                Start-Sleep -Seconds 5
            }

            $jobs += Start-Job -ScriptBlock {
                param($device)
                . "C:\Migration\Scripts\MigrationFunctions.ps1"

                # Pre-migration health check
                $healthCheck = Test-DeviceHealth -ComputerName $device.ComputerName
                if (-not $healthCheck.Healthy) {
                    return @{
                        Device = $device.ComputerName
                        Status = "Skipped"
                        Reason = "Failed health check: $($healthCheck.Issues)"
                    }
                }

                # Execute migration
                $result = Start-CertificateMigration `
                    -ComputerName $device.ComputerName `
                    -Wave "Production1"

                # Post-migration validation
                if ($result.Success) {
                    $validation = Test-PostMigrationHealth -ComputerName $device.ComputerName
                    $result.ValidationPassed = $validation.Success
                }

                return $result
            } -ArgumentList $device
        }

        # Monitor job progress
        while ($jobs | Where-Object { $_.State -eq "Running" }) {
            $completed = ($jobs | Where-Object { $_.State -eq "Completed" }).Count
            $running = ($jobs | Where-Object { $_.State -eq "Running" }).Count
            Write-Progress -Activity "Migrating Batch" `
                -Status "$completed completed, $running running" `
                -PercentComplete (($completed / $jobs.Count) * 100)

            Start-Sleep -Seconds 10
        }

        # Collect results
        $batchResults = @()
        foreach ($job in $jobs) {
            $batchResults += Receive-Job -Job $job
            Remove-Job -Job $job
        }

        # Update migration database
        foreach ($result in $batchResults) {
            Update-MigrationTracking -Result $result
        }

        # Check success rate
        $successRate = ($batchResults | Where-Object { $_.Status -eq "Completed" }).Count / $batchResults.Count
        if ($successRate -lt 0.95) {
            # Less than 95% success
            Write-Warning "Low success rate in batch: $([Math]::Round($successRate * 100, 2))%"

            # Pause for investigation
            $continue = Read-Host "Continue migration? (Y/N)"
            if ($continue -ne "Y") {
                Write-Host "Migration paused by operator" -ForegroundColor Red
                break
            }
        }

        # Brief pause between batches
        Start-Sleep -Seconds 60
    }
}

# Generate Wave 1 report
Generate-MigrationReport -Wave "Production1" -OutputPath "C:\Migration\Wave1\Report.html"
