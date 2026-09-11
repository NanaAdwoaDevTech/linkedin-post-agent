<#
.SYNOPSIS
    Production-Grade Active Directory Provisioning Framework
.DESCRIPTION
    Dynamically generates secure passwords, enforces strict error handling,
    logs actions to an enterprise audit file, and provisions users dynamically.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "C:\Config\AD_Config.json",
    
    [Parameter(Mandatory = $false)]
    [string]$CSVPath = "C:\AD_Users_Import.csv",
    
    [Parameter(Mandatory = $false)]
    [string]$LogPath = "C:\Logs\AD_Provisioning_$(Get-Date -Format 'yyyyMMdd').log"
)

# 1. Helper Function: Cryptographically Secure Random Password Generator
function New-SecureRandomPassword {
    param ([int]$length = 16)
    $assembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Web")
    $charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $rnd = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
    $rnd.GetBytes($bytes)
    $result = New-Object System.Text.StringBuilder
    foreach ($b in $bytes) {
        [void]$result.Append($charSet[$b % $charSet.Length])
    }
    return $result.ToString()
}

# 2. Start Auditing & Logging
Start-Transcript -Path $LogPath -Append -ErrorAction SilentlyContinue

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $DomainDN = (Get-ADDomain).DistinguishedName
    $BaseOU = "OU=Lab_Employees,$DomainDN"

    # Ensure Target Base OU Exists
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Lab_Employees'")) {
        New-ADOrganizationalUnit -Name "Lab_Employees" -Path $DomainDN
    }

    if (Test-Path $CSVPath) {
        $users = Import-Csv -Path $CSVPath
        
        foreach ($user in $users) {
            try {
                $dept = $user.Department
                $deptOU = "OU=$dept,$BaseOU"
                
                # Dynamic OU & Group Creation
                if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'" -SearchBase $BaseOU)) {
                    New-ADOrganizationalUnit -Name $dept -Path $BaseOU
                    New-ADGroup -Name "GRP_$dept" -GroupScope Global -GroupCategory Security -Path $deptOU
                }

                # Check for Duplicate Account
                if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.Username)'")) {
                    # Generate Unique Temp Password
                    $plainTempPassword = New-SecureRandomPassword -length 16
                    $securePassword = ConvertTo-SecureString $plainTempPassword -AsPlainText -Force

                    # Create AD Account
                    New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                               -GivenName $user.FirstName `
                               -Surname $user.LastName `
                               -SamAccountName $user.Username `
                               -UserPrincipalName "$($user.Username)@$((Get-ADDomain).DNSRoot)" `
                               -Department $user.Department `
                               -Title $user.JobTitle `
                               -Path $deptOU `
                               -AccountPassword $securePassword `
                               -Enabled $true `
                               -ChangePasswordAtLogon $true `
                               -ErrorAction Stop

                    Add-ADGroupMember -Identity "GRP_$dept" -Members $user.Username -ErrorAction Stop
                    
                    Write-Host "SUCCESS: Created $($user.Username) | Temp Key: $plainTempPassword" -ForegroundColor Green
                } else {
                    Write-Warning "SKIP: User $($user.Username) already exists."
                }
            }
            catch {
                Write-Error "FAILED: Could not provision $($user.Username). Reason: $_"
            }
        }
    }
}
catch {
    Write-Error "CRITICAL: Script execution halted. Reason: $_"
}
finally {
    Stop-Transcript
}
