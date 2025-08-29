# Configure-BaseServers.ps1
# Base configuration for all PKI servers

$servers = @("PKI-ICA-01", "PKI-ICA-02", "PKI-NDES-01", "PKI-OCSP-01", "PKI-OCSP-02")

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        
        # Set timezone
        Set-TimeZone -Id "AUS Eastern Standard Time"
        
        # Configure Windows Firewall
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
        
        # Enable RDP
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        
        # Configure Windows Update
        Install-Module PSWindowsUpdate -Force
        Set-WUSettings -NoAutoUpdate -NoAutoRebootWithLoggedOnUsers
        
        # Install required features
        Install-WindowsFeature -Name Web-Server, Web-Common-Http, Web-Mgmt-Tools -IncludeManagementTools
        Install-WindowsFeature -Name RSAT-AD-PowerShell, RSAT-DNS-Server
        
        # Initialize data disk
        Get-Disk | Where-Object PartitionStyle -eq 'raw' | 
            Initialize-Disk -PartitionStyle GPT -PassThru |
            New-Partition -AssignDriveLetter -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel "CA-Data" -Confirm:$false
        
        # Create PKI directories
        $directories = @(
            "E:\CertData",
            "E:\CertData\Database",
            "E:\CertData\Logs",
            "E:\CertData\Backup",
            "E:\CertData\Templates",
            "E:\CertData\CRL"
        )
        
        foreach ($dir in $directories) {
            New-Item -ItemType Directory -Path $dir -Force
        }
        
        # Configure auditing
        auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable
        auditpol /set /subcategory:"Logon" /success:enable /failure:enable
        auditpol /set /subcategory:"Object Access" /success:enable /failure:enable
        
        # Configure event log sizes
        wevtutil sl Security /ms:4194240
        wevtutil sl Application /ms:1048576
        wevtutil sl System /ms:1048576
        
        # Install monitoring agent
        # Download and install Azure Monitor agent
        $agentUrl = "https://aka.ms/AMAWindows64"
        Invoke-WebRequest -Uri $agentUrl -OutFile "C:\Temp\AMASetup.exe"
        Start-Process -FilePath "C:\Temp\AMASetup.exe" -ArgumentList "/S" -Wait
    }
}

Write-Host "Base server configuration complete!" -ForegroundColor Green