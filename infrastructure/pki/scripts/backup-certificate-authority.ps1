# Backup-CertificateAuthority.ps1
# Comprehensive CA backup procedure

function Backup-CertificateAuthority {
    param(
        [string]$CAServer = "PKI-ICA-01",
        [string]$BackupPath = "\\Backup\PKI\CA",
        [switch]$IncludeDatabase = $true,
        [switch]$IncludePrivateKey = $false
    )

    $backupDate = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFolder = "$BackupPath\$CAServer-$backupDate"

    Write-Host "Starting CA backup for $CAServer..." -ForegroundColor Cyan

    # Create backup folder
    New-Item -ItemType Directory -Path $backupFolder -Force

    Invoke-Command -ComputerName $CAServer -ScriptBlock {
        param($backup, $includeDB, $includeKey)

        # Stop CA service for consistent backup
        Write-Host "Stopping CA service..." -ForegroundColor Yellow
        Stop-Service CertSvc

        try {
            # Backup CA configuration
            Write-Host "Backing up CA configuration..." -ForegroundColor Yellow
            certutil -backup "$backup\CAConfig" -p "BackupPassword123!"

            # Backup CA database
            if ($includeDB) {
                Write-Host "Backing up CA database..." -ForegroundColor Yellow
                Backup-CARoleService -Path "$backup\Database" -DatabaseOnly
            }

            # Backup private key (if requested and authorized)
            if ($includeKey) {
                Write-Host "Backing up CA private key..." -ForegroundColor Yellow
                certutil -backupkey "$backup\PrivateKey" -p "KeyBackupPassword123!"
            }

            # Export registry settings
            Write-Host "Exporting registry settings..." -ForegroundColor Yellow
            reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc" "$backup\CertSvc-Registry.reg" /y

            # Export templates
            Write-Host "Exporting certificate templates..." -ForegroundColor Yellow
            Get-CATemplate | Export-Csv -Path "$backup\Templates.csv"

            # Export CA certificate
            $caCert = Get-ChildItem Cert:\LocalMachine\My |
            Where-Object { $_.Subject -like "*Issuing CA*" }

            foreach ($cert in $caCert) {
                Export-Certificate -Cert $cert -FilePath "$backup\CACert-$($cert.Thumbprint).cer"
            }

        } finally {
            # Restart CA service
            Write-Host "Restarting CA service..." -ForegroundColor Yellow
            Start-Service CertSvc
        }

    } -ArgumentList $backupFolder, $IncludeDatabase, $IncludePrivateKey

    # Verify backup
    Write-Host "Verifying backup..." -ForegroundColor Yellow

    $backupValid = Test-CABackup -BackupPath $backupFolder

    if ($backupValid) {
        # Compress backup
        Compress-Archive -Path $backupFolder -DestinationPath "$backupFolder.zip"

        # Encrypt backup
        Protect-BackupArchive -Archive "$backupFolder.zip" -Password (Get-BackupPassword)

        # Log backup
        @{
            Date             = Get-Date
            Server           = $CAServer
            BackupPath       = "$backupFolder.zip"
            Size             = (Get-Item "$backupFolder.zip").Length
            IncludedDatabase = $IncludeDatabase
            IncludedKey      = $IncludePrivateKey
            Status           = "Success"
        } | Export-Csv -Path "C:\PKI\Backup\BackupLog.csv" -Append

        Write-Host "Backup completed successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Backup verification failed!" -ForegroundColor Red
        return $false
    }
}
