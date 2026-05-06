# Execute-PilotMigration.ps1
# Executes pilot migration with comprehensive logging and validation

param(
    [string]$PilotGroupFile = "C:\Migration\Pilot\PilotGroup.csv",
    [int]$BatchSize = 50,
    [int]$DelayBetweenBatches = 300  # 5 minutes
)

# Import pilot group
$pilotDevices = Import-Csv $PilotGroupFile

# Initialize migration tracking database
$migrationDb = @{
    Server   = "SQL-PKI-DB"
    Database = "PKI_Migration"
    Table    = "MigrationTracking"
}

# Create migration tracking table
Invoke-SqlCmd -ServerInstance $migrationDb.Server -Query @"
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PKI_Migration')
    CREATE DATABASE PKI_Migration;
GO

USE PKI_Migration;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MigrationTracking')
CREATE TABLE MigrationTracking (
    MigrationId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    DeviceName NVARCHAR(100),
    Wave NVARCHAR(20),
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status NVARCHAR(20),
    OldCertThumbprint NVARCHAR(100),
    NewCertThumbprint NVARCHAR(100),
    ErrorMessage NVARCHAR(MAX),
    RollbackRequired BIT DEFAULT 0,
    ValidationPassed BIT,
    INDEX IX_DeviceName (DeviceName),
    INDEX IX_Status (Status),
    INDEX IX_Wave (Wave)
);
"@

# Migration functions
function Start-CertificateMigration {
    param(
        [string]$ComputerName,
        [string]$Wave
    )

    $migrationResult = @{
        DeviceName = $ComputerName
        Wave       = $Wave
        StartTime  = Get-Date
        Status     = "InProgress"
        Success    = $false
    }

    try {
        Write-Host "Starting migration for $ComputerName" -ForegroundColor Yellow

        # Step 1: Backup current certificates
        Write-Host "  Backing up current certificates..." -ForegroundColor Gray
        $backupPath = "\\FileServer\PKI-Backup\$Wave\$ComputerName"
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            param($path)

            # Export all certificates
            $certs = Get-ChildItem Cert:\LocalMachine\My
            foreach ($cert in $certs) {
                $exportPath = "$path\$($cert.Thumbprint).pfx"
                $password = ConvertTo-SecureString -String "TempP@ss123" -Force -AsPlainText
                Export-PfxCertificate -Cert $cert -FilePath $exportPath -Password $password
            }
        } -ArgumentList $backupPath

        # Step 2: Request new certificates
        Write-Host "  Requesting new certificates..." -ForegroundColor Gray
        $newCerts = @()

        # Computer authentication certificate
        $computerCert = Request-NewCertificate `
            -ComputerName $ComputerName `
            -Template "Company-Computer-Authentication" `
            -CA "PKI-ICA-01.company.local\Company Issuing CA 01"

        $newCerts += $computerCert

        # Additional certificates based on role
        $additionalTemplates = Get-RequiredTemplates -ComputerName $ComputerName
        foreach ($template in $additionalTemplates) {
            $cert = Request-NewCertificate `
                -ComputerName $ComputerName `
                -Template $template `
                -CA "PKI-ICA-01.company.local\Company Issuing CA 01"

            $newCerts += $cert
        }

        # Step 3: Install new certificates
        Write-Host "  Installing new certificates..." -ForegroundColor Gray
        foreach ($cert in $newCerts) {
            Install-Certificate -ComputerName $ComputerName -Certificate $cert
        }

        # Step 4: Update trust stores
        Write-Host "  Updating trust stores..." -ForegroundColor Gray
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            # Import new root CA
            $rootCert = "\\FileServer\PKI\Certificates\RootCA-G2.crt"
            Import-Certificate -FilePath $rootCert -CertStoreLocation Cert:\LocalMachine\Root

            # Import intermediate CAs
            $intermediateCerts = @(
                "\\FileServer\PKI\Certificates\IssuingCA01.crt",
                "\\FileServer\PKI\Certificates\IssuingCA02.crt"
            )

            foreach ($certPath in $intermediateCerts) {
                Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\CA
            }
        }

        # Step 5: Validate migration
        Write-Host "  Validating migration..." -ForegroundColor Gray
        $validation = Test-CertificateMigration -ComputerName $ComputerName

        if ($validation.Success) {
            # Step 6: Remove old certificates (mark for removal, don't delete yet)
            Write-Host "  Marking old certificates for removal..." -ForegroundColor Gray
            Mark-OldCertificatesForRemoval -ComputerName $ComputerName

            $migrationResult.Status = "Completed"
            $migrationResult.Success = $true
            $migrationResult.NewCertThumbprint = $computerCert.Thumbprint
            $migrationResult.ValidationPassed = $true

            Write-Host "Migration completed for $ComputerName" -ForegroundColor Green
        } else {
            throw "Validation failed: $($validation.Error)"
        }

    } catch {
        Write-Host "Migration failed for $ComputerName : $_" -ForegroundColor Red
        $migrationResult.Status = "Failed"
        $migrationResult.ErrorMessage = $_.Exception.Message

        # Attempt rollback
        if (Test-Path $backupPath) {
            Write-Host "  Attempting rollback..." -ForegroundColor Yellow
            Start-MigrationRollback -ComputerName $ComputerName -BackupPath $backupPath
            $migrationResult.RollbackRequired = $true
        }
    } finally {
        $migrationResult.EndTime = Get-Date

        # Log to database
        Log-MigrationResult -Result $migrationResult
    }

    return $migrationResult
}

function Test-CertificateMigration {
    param([string]$ComputerName)

    $tests = @()

    # Test 1: New certificates present
    $newCerts = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem Cert:\LocalMachine\My |
        Where-Object { $_.Issuer -like "*Company Issuing CA 0*" }
    }

    $tests += @{
        Test   = "New Certificates Present"
        Passed = ($newCerts.Count -gt 0)
    }

    # Test 2: Certificate chain validation
    foreach ($cert in $newCerts) {
        $chainValid = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            param($thumbprint)
            $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
            $chain.Build($cert)
        } -ArgumentList $cert.Thumbprint

        $tests += @{
            Test   = "Chain Validation - $($cert.Subject)"
            Passed = $chainValid
        }
    }

    # Test 3: Service connectivity
    $services = @("RDP", "SMB", "WinRM")
    foreach ($service in $services) {
        $connected = Test-ServiceConnectivity -ComputerName $ComputerName -Service $service
        $tests += @{
            Test   = "$service Connectivity"
            Passed = $connected
        }
    }

    # Test 4: Application functionality
    $apps = Get-CriticalApplications -ComputerName $ComputerName
    foreach ($app in $apps) {
        $working = Test-ApplicationFunctionality -ComputerName $ComputerName -Application $app
        $tests += @{
            Test   = "$app Functionality"
            Passed = $working
        }
    }

    $allPassed = ($tests | Where-Object { -not $_.Passed }).Count -eq 0

    return @{
        Success = $allPassed
        Tests   = $tests
        Error   = if (-not $allPassed) {
            "Failed tests: " + (($tests | Where-Object { -not $_.Passed }).Test -join ", ")
        } else { $null }
    }
}

function Start-MigrationRollback {
    param(
        [string]$ComputerName,
        [string]$BackupPath
    )

    Write-Host "Performing rollback for $ComputerName" -ForegroundColor Yellow

    try {
        # Remove new certificates
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Get-ChildItem Cert:\LocalMachine\My |
            Where-Object { $_.Issuer -like "*Company Issuing CA 0*" } |
            Remove-Item -Force
        }

        # Restore old certificates
        $backupFiles = Get-ChildItem -Path $BackupPath -Filter "*.pfx"
        foreach ($file in $backupFiles) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                param($pfxPath)
                $password = ConvertTo-SecureString -String "TempP@ss123" -Force -AsPlainText
                Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\LocalMachine\My -Password $password
            } -ArgumentList $file.FullName
        }

        Write-Host "Rollback completed for $ComputerName" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "Rollback failed for $ComputerName : $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
$totalDevices = $pilotDevices.Count
$batches = [Math]::Ceiling($totalDevices / $BatchSize)

Write-Host "Starting Pilot Migration" -ForegroundColor Cyan
Write-Host "Total devices: $totalDevices" -ForegroundColor Gray
Write-Host "Batch size: $BatchSize" -ForegroundColor Gray
Write-Host "Number of batches: $batches" -ForegroundColor Gray

$results = @()
$batchNumber = 1

for ($i = 0; $i -lt $totalDevices; $i += $BatchSize) {
    $batch = $pilotDevices[$i..[Math]::Min($i + $BatchSize - 1, $totalDevices - 1)]

    Write-Host "`nProcessing Batch $batchNumber of $batches" -ForegroundColor Cyan

    # Process batch in parallel
    $jobs = @()
    foreach ($device in $batch) {
        $jobs += Start-Job -ScriptBlock {
            param($computerName, $wave)
            . "C:\Migration\Scripts\MigrationFunctions.ps1"
            Start-CertificateMigration -ComputerName $computerName -Wave $wave
        } -ArgumentList $device.ComputerName, "Pilot"
    }

    # Wait for batch to complete
    $jobs | Wait-Job -Timeout 1800  # 30 minute timeout

    # Collect results
    foreach ($job in $jobs) {
        if ($job.State -eq "Completed") {
            $results += Receive-Job -Job $job
        } else {
            Write-Host "Job timeout for device" -ForegroundColor Red
            Stop-Job -Job $job
        }
        Remove-Job -Job $job
    }

    # Validation checkpoint
    $batchSuccess = ($results | Where-Object { $_.Status -eq "Completed" }).Count
    $batchFailed = ($results | Where-Object { $_.Status -eq "Failed" }).Count

    Write-Host "Batch $batchNumber Results: Success=$batchSuccess, Failed=$batchFailed" -ForegroundColor Yellow

    # Check failure threshold
    if ($batchFailed -gt ($batch.Count * 0.1)) {
        # >10% failure rate
        Write-Host "High failure rate detected. Pausing migration for investigation." -ForegroundColor Red
        Send-AlertEmail -Subject "Pilot Migration Paused" -Body "Batch $batchNumber exceeded failure threshold"
        break
    }

    # Delay before next batch
    if ($i + $BatchSize -lt $totalDevices) {
        Write-Host "Waiting $($DelayBetweenBatches/60) minutes before next batch..." -ForegroundColor Gray
        Start-Sleep -Seconds $DelayBetweenBatches
    }

    $batchNumber++
}

# Generate pilot report
$report = @{
    TotalDevices     = $totalDevices
    Successful       = ($results | Where-Object { $_.Status -eq "Completed" }).Count
    Failed           = ($results | Where-Object { $_.Status -eq "Failed" }).Count
    RollbackRequired = ($results | Where-Object { $_.RollbackRequired -eq $true }).Count
    SuccessRate      = [Math]::Round((($results | Where-Object { $_.Status -eq "Completed" }).Count / $totalDevices) * 100, 2)
}

Write-Host "`nPilot Migration Summary" -ForegroundColor Cyan
Write-Host "Total: $($report.TotalDevices)" -ForegroundColor Gray
Write-Host "Successful: $($report.Successful)" -ForegroundColor Green
Write-Host "Failed: $($report.Failed)" -ForegroundColor Red
Write-Host "Success Rate: $($report.SuccessRate)%" -ForegroundColor Yellow

# Export detailed results
$results | Export-Csv -Path "C:\Migration\Pilot\PilotResults-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
