# Configure-PKIBackup.ps1
# Sets up comprehensive backup for PKI infrastructure

# Create Recovery Services Vault
$vault = New-AzRecoveryServicesVault `
    -Name "RSV-PKI-AustraliaEast" `
    -ResourceGroupName "RG-PKI-Core-Production" `
    -Location "australiaeast"

# Set vault context
Set-AzRecoveryServicesVaultContext -Vault $vault

# Configure backup storage redundancy
Set-AzRecoveryServicesBackupProperty `
    -Vault $vault `
    -BackupStorageRedundancy GeoRedundant

# Create backup policy for PKI
$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureVM
$schPol.ScheduleRunTimes.Clear()
$schPol.ScheduleRunTimes.Add("2025-02-10T02:00:00Z")
$schPol.ScheduleRunFrequency = "Daily"

$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM
$retPol.DailySchedule.DurationCountInDays = 30
$retPol.WeeklySchedule.DurationCountInWeeks = 12
$retPol.MonthlySchedule.DurationCountInMonths = 12
$retPol.YearlySchedule.DurationCountInYears = 10

$policy = New-AzRecoveryServicesBackupProtectionPolicy `
    -Name "PKI-Backup-Policy" `
    -WorkloadType AzureVM `
    -RetentionPolicy $retPol `
    -SchedulePolicy $schPol `
    -VaultId $vault.ID

# Backup Key Vault
$keyVaultBackup = @{
    VaultName  = "KV-PKI-RootCA-Prod"
    BackupFile = "https://pkibackupstorage.blob.core.windows.net/backups/keyvault-backup.blob"
    SasToken   = $sasToken
}

Backup-AzKeyVault @keyVaultBackup

# Configure automated backup for CA database
$sqlBackupConfig = @{
    ServerName            = "sql-pki-cadb"
    DatabaseName          = "PKI_CA_Database"
    ResourceGroupName     = "RG-PKI-Core-Production"
    StorageAccountUrl     = "https://pkibackupstorage.blob.core.windows.net"
    StorageAccessKey      = $storageKey
    RetentionDays         = 35
    BackupScheduleType    = "Automated"
    FullBackupFrequency   = "Weekly"
    FullBackupStartTime   = 2
    FullBackupWindowHours = 2
    LogBackupFrequency    = 60  # minutes
}

Set-AzSqlDatabaseBackupShortTermRetentionPolicy @sqlBackupConfig

Write-Host "Backup configuration complete!" -ForegroundColor Green
