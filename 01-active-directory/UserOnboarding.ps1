<#
.SYNOPSIS
    Automated Active Directory Provisioning Script for Enterprise Hybrid IT Lab.
.DESCRIPTION
    Creates organizational units (OUs), department security groups (GRP_*), 
    and bulk provisions users from CSV while enforcing AGDLP role-based access.
#>

# 1. Environment & Active Directory Connection Verification
Import-Module ActiveDirectory -ErrorAction Stop

$DomainDN = (Get-ADDomain).DistinguishedName
$BaseOUName = "Lab_Employees"
$BaseOUPath = "OU=$BaseOUName,$DomainDN"

Write-Host "Connected to AD Domain: $DomainDN" -ForegroundColor Green

# 2. Base OU & Department Sub-OU Creation
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$BaseOUName'")) {
    New-ADOrganizationalUnit -Name $BaseOUName -Path $DomainDN
    Write-Host "Created Base OU: $BaseOUName" -ForegroundColor Cyan
}

$Departments = @("Engineering", "Finance", "HR", "IT", "Sales")

foreach ($dept in $Departments) {
    $DeptOUPath = "OU=$dept,$BaseOUPath"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'" -SearchBase $BaseOUPath)) {
        New-ADOrganizationalUnit -Name $dept -Path $BaseOUPath
        Write-Host "Created Department OU: $dept" -ForegroundColor Cyan
    }
    
    # Create AGDLP Global Security Group
    $GroupName = "GRP_$dept"
    if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'")) {
        New-ADGroup -Name $GroupName `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $DeptOUPath `
                    -Description "Global Security Group for $dept department members"
        Write-Host "Created Security Group: $GroupName" -ForegroundColor Yellow
    }
}

# 3. Bulk User Provisioning from CSV
$csvPath = "C:\AD_Users_Import.csv"

if (Test-Path $csvPath) {
    $users = Import-Csv -Path $csvPath
    
    foreach ($user in $users) {
        $OUPath = "OU=$($user.Department),$BaseOUPath"
        $UserUPN = "$($user.Username)@$((Get-ADDomain).DNSRoot)"
        
        # Enforce secure default password meeting complexity requirements
        $SecurePassword = ConvertTo-SecureString "P@ssw0rd2026!" -AsPlainText -Force
        
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.Username)'")) {
            New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                       -GivenName $user.FirstName `
                       -Surname $user.LastName `
                       -SamAccountName $user.Username `
                       -UserPrincipalName $UserUPN `
                       -Title $user.JobTitle `
                       -Department $user.Department `
                       -Path $OUPath `
                       -AccountPassword $SecurePassword `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true
                       
            # Add user to department Global Security Group
            Add-ADGroupMember -Identity "GRP_$($user.Department)" -Members $user.Username
            Write-Host "Provisioned User: $($user.Username) into $OUPath" -ForegroundColor Green
        } else {
            Write-Warning "User $($user.Username) already exists. Skipping..."
        }
    }
} else {
    Write-Error "CSV import file not found at $csvPath. Please verify path."
}
