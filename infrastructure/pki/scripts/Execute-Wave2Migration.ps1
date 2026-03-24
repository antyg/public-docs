# Execute-Wave2Migration.ps1
# Production Wave 2 migration - Final wave

param(
    [string]$Wave2ListFile = "C:\Migration\Wave2\DeviceList.csv"
)

# This wave includes all remaining systems
$wave2Devices = Import-Csv $Wave2ListFile

Write-Host "Starting Production Wave 2 Migration (Final Wave)" -ForegroundColor Cyan
Write-Host "Total devices: $($wave2Devices.Count)" -ForegroundColor Gray

# Enhanced monitoring for final wave
$monitoringConfig = @{
    AlertThreshold     = 0.98  # 98% success rate required
    RollbackThreshold  = 50  # Max devices to rollback
    CheckpointInterval = 250  # Create checkpoint every 250 devices
}

# Create pre-migration snapshot
Write-Host "Creating pre-migration snapshot..." -ForegroundColor Yellow
$snapshot = New-EnvironmentSnapshot -Scope "Wave2"

# Execute migration with checkpoints
$checkpointCount = 0
$migratedDevices = @()

foreach ($device in $wave2Devices) {
    try {
        # Migrate device
        $result = Start-CertificateMigration `
            -ComputerName $device.ComputerName `
            -Wave "Production2" `
            -ValidateImmediately $true

        $migratedDevices += $result

        # Create checkpoint if needed
        if ($migratedDevices.Count % $monitoringConfig.CheckpointInterval -eq 0) {
            $checkpointCount++
            Write-Host "Creating checkpoint $checkpointCount..." -ForegroundColor Gray

            New-MigrationCheckpoint `
                -CheckpointName "Wave2_CP$checkpointCount" `
                -DeviceList $migratedDevices

            # Validate checkpoint
            $validation = Test-CheckpointHealth -CheckpointName "Wave2_CP$checkpointCount"
            if (-not $validation.Healthy) {
                Write-Warning "Checkpoint validation failed. Investigating..."
                Investigate-MigrationIssues -Checkpoint "Wave2_CP$checkpointCount"
            }
        }

    } catch {
        Write-Error "Migration failed for $($device.ComputerName): $_"

        # Check if we should continue
        $failureCount = ($migratedDevices | Where-Object { $_.Status -eq "Failed" }).Count
        if ($failureCount -gt $monitoringConfig.RollbackThreshold) {
            Write-Host "Failure threshold exceeded. Initiating rollback..." -ForegroundColor Red
            Start-MassRollback -Devices $migratedDevices -Snapshot $snapshot
            throw "Wave 2 migration aborted due to excessive failures"
        }
    }
}

# Final validation
Write-Host "`nPerforming final validation..." -ForegroundColor Cyan
$finalValidation = Test-EnterprisePKIHealth -Comprehensive $true

if ($finalValidation.AllTestsPassed) {
    Write-Host "Wave 2 migration completed successfully!" -ForegroundColor Green

    # Mark old PKI for decommission
    Set-LegacyPKIStatus -Status "PendingDecommission"

} else {
    Write-Warning "Final validation detected issues:"
    $finalValidation.Issues | ForEach-Object {
        Write-Warning "  - $_"
    }
}
