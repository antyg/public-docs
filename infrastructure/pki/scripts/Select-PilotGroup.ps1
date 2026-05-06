# Select-PilotGroup.ps1
# Identifies and prepares pilot migration group

param(
    [int]$PilotSize = 1000,
    [string]$OutputPath = "C:\Migration\Pilot"
)

# Connect to AD and SCCM
Import-Module ActiveDirectory
Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"

# Define pilot selection criteria
$pilotCriteria = @{
    # IT Department (tech-savvy users)
    ITDepartment = @{
        OU         = "OU=IT,OU=Users,DC=company,DC=local"
        Percentage = 50  # 500 users
        Priority   = 1
    }

    # Volunteers from other departments
    Volunteers   = @{
        Group      = "PKI-Pilot-Volunteers"
        Percentage = 20  # 200 users
        Priority   = 2
    }

    # Representative sample from each department
    RandomSample = @{
        Departments = @("Sales", "Finance", "HR", "Operations")
        Percentage  = 30  # 300 users
        Priority    = 3
    }
}

# Get current certificate inventory
function Get-CertificateInventory {
    param([string]$ComputerName)

    $inventory = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $certs = @()
        F
        # Machine certificates
        $machineCerts = Get-ChildItem Cert:\LocalMachine\My
        foreach ($cert in $machineCerts) {
            $certs += @{
                Store        = "LocalMachine\My"
                Subject      = $cert.Subject
                Issuer       = $cert.Issuer
                Thumbprint   = $cert.Thumbprint
                SerialNumber = $cert.SerialNumber
                NotBefore    = $cert.NotBefore
                NotAfter     = $cert.NotAfter
                Template     = ($cert.Extensions | Where-Object { $_.Oid.Value -eq "1.3.6.1.4.1.311.21.7" }).Format(0)
                Type         = "Machine"
            }
        }

        # User certificates
        $userCerts = Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue
        foreach ($cert in $userCerts) {
            $certs += @{
                Store        = "CurrentUser\My"
                Subject      = $cert.Subject
                Issuer       = $cert.Issuer
                Thumbprint   = $cert.Thumbprint
                SerialNumber = $cert.SerialNumber
                NotBefore    = $cert.NotBefore
                NotAfter     = $cert.NotAfter
                Template     = ($cert.Extensions | Where-Object { $_.Oid.Value -eq "1.3.6.1.4.1.311.21.7" }).Format(0)
                Type         = "User"
            }
        }

        return $certs
    }

    return $inventory
}

# Select pilot devices
$pilotDevices = @()

# IT Department selection
$itComputers = Get-ADComputer -Filter * -SearchBase $pilotCriteria.ITDepartment.OU |
Select-Object -First 500

foreach ($computer in $itComputers) {
    $pilotDevices += @{
        ComputerName        = $computer.Name
        DN                  = $computer.DistinguishedName
        Group               = "IT Department"
        Wave                = "Pilot"
        CurrentCertificates = Get-CertificateInventory -ComputerName $computer.Name
    }
}

# Volunteer selection
$volunteers = Get-ADGroupMember -Identity $pilotCriteria.Volunteers.Group |
Where-Object { $_.objectClass -eq "computer" } |
Select-Object -First 200

foreach ($computer in $volunteers) {
    $pilotDevices += @{
        ComputerName        = $computer.Name
        DN                  = $computer.DistinguishedName
        Group               = "Volunteers"
        Wave                = "Pilot"
        CurrentCertificates = Get-CertificateInventory -ComputerName $computer.Name
    }
}

# Random sample selection
foreach ($dept in $pilotCriteria.RandomSample.Departments) {
    $deptComputers = Get-ADComputer -Filter * -SearchBase "OU=$dept,OU=Computers,DC=company,DC=local" |
    Get-Random -Count 75

    foreach ($computer in $deptComputers) {
        $pilotDevices += @{
            ComputerName        = $computer.Name
            DN                  = $computer.DistinguishedName
            Group               = $dept
            Wave                = "Pilot"
            CurrentCertificates = Get-CertificateInventory -ComputerName $computer.Name
        }
    }
}

# Export pilot group
$pilotDevices | Export-Csv -Path "$OutputPath\PilotGroup.csv" -NoTypeInformation

# Create pilot collection in SCCM
$collectionName = "PKI Migration - Pilot Group"
New-CMDeviceCollection -Name $collectionName -LimitingCollectionName "All Systems"

foreach ($device in $pilotDevices) {
    Add-CMDeviceCollectionDirectMembershipRule `
        -CollectionName $collectionName `
        -ResourceId (Get-CMDevice -Name $device.ComputerName).ResourceID
}

Write-Host "Pilot group selected: $($pilotDevices.Count) devices" -ForegroundColor Green
