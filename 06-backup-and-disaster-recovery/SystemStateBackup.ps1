# Automated Windows Server System State Backup Script

$BackupTarget = "E:\WindowsServerBackup"
$Date = Get-Date -Format "yyyy-MM-dd"
$LogPath = "C:\Logs\Backup_$Date.log"

Start-Transcript -Path $LogPath -Append

Write-Host "Starting Active Directory System State Backup..."
wbadmin start systemstatebackup -backupTarget:$BackupTarget -quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup completed successfully."
} else {
    Write-Warning "Backup failed with exit code $LASTEXITCODE."
}

Stop-Transcript
