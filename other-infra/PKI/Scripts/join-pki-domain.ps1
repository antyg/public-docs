# Join-PKIDomain.ps1
# Joins PKI servers to Active Directory domain

$domain = "company.local"
$ouPath = "OU=PKI-Servers,OU=Infrastructure,DC=company,DC=local"
$credential = Get-Credential -Message "Enter Domain Admin credentials"

$servers = @(
    @{Name = "PKI-ICA-01"; IP = "10.50.1.10" },
    @{Name = "PKI-ICA-02"; IP = "10.50.1.11" },
    @{Name = "PKI-NDES-01"; IP = "10.50.1.20" },
    @{Name = "PKI-OCSP-01"; IP = "10.50.1.30" },
    @{Name = "PKI-OCSP-02"; IP = "10.50.1.31" }
)

foreach ($server in $servers) {
    Write-Host "Joining $($server.Name) to domain..." -ForegroundColor Yellow

    Invoke-Command -ComputerName $server.IP -Credential $credential -ScriptBlock {
        param($domain, $ou, $cred, $name)

        # Set DNS servers
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.10.10.10", "10.10.10.11"

        # Join domain
        Add-Computer -DomainName $domain -OUPath $ou -Credential $cred -NewName $name -Restart -Force

    } -ArgumentList $domain, $ouPath, $credential, $server.Name
}

Write-Host "Domain join initiated. Servers will restart." -ForegroundColor Green
Start-Sleep -Seconds 180  # Wait for restart

# Verify domain join
foreach ($server in $servers) {
    $result = Test-ComputerSecureChannel -Server $server.Name
    if ($result) {
        Write-Host "$($server.Name) successfully joined to domain" -ForegroundColor Green
    } else {
        Write-Host "$($server.Name) domain join FAILED" -ForegroundColor Red
    }
}
