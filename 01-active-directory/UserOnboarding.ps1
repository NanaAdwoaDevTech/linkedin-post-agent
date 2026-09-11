# Active Directory Automated Bulk Provisioning Script
# Creates OUs, Security Groups, and Accounts from CSV

Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$BaseOU = "OU=Lab_Employees,$DomainDN"

# 1. Create Base and Department OUs
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Lab_Employees'")) {
    New-ADOrganizationalUnit -Name "Lab_Employees" -Path $DomainDN
}

$Departments = @("Engineering", "Finance", "HR", "IT", "Sales")
foreach ($dept in $Departments) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'" -SearchBase $BaseOU)) {
        New-ADOrganizationalUnit -Name $dept -Path $BaseOU
        New-ADGroup -Name "GRP_$dept" -GroupScope Global -GroupCategory Security -Path "OU=$dept,$BaseOU"
    }
}

# 2. Bulk Provision Users
$csvPath = "C:\AD_Users_Import.csv"
if (Test-Path $csvPath) {
    $users = Import-Csv -Path $csvPath
    foreach ($user in $users) {
        $SecurePassword = ConvertTo-SecureString "P@ssw0rd2026!" -AsPlainText -Force
        $OUPath = "OU=$($user.Department),$BaseOU"
        
        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -SamAccountName $user.Username `
                   -UserPrincipalName "$($user.Username)@enterprise.local" `
                   -Path $OUPath `
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true
                   
        Add-ADGroupMember -Identity "GRP_$($user.Department)" -Members $user.Username
    }
}
