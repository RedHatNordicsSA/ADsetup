#Super admin will get this password
$myPassword = "Password1!"
$Secure_String_Pwd = ConvertTo-SecureString $myPassword -AsPlainText -Force
$myDomain = "hger.org"
$myNetbios = "HGER"
$myScript = "c:\usersgrops.ps1"

#Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
#Set-ItemProperty -Path . -Name addusers -Value $myScript


New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name "addusers" -Value "%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $myScript" -PropertyType ExpandString
$daScript = @'
Import-module ActiveDirectory
$Secure_String_Pwd = ConvertTo-SecureString "Password1!" -AsPlainText -Force
New-ADUser -Name "Hakan Hagenrud" -SamAccountName "hger" -UserPrincipalName "hger@hger.org" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "Daniel Svensson" -SamAccountName "vsda" -UserPrincipalName "vsda@hger.org" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "Mister Manager" -SamAccountName "mgmt" -UserPrincipalName "mgmt@hger.org" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "Mister Intern" -SamAccountName "intr" -UserPrincipalName "intr@hger.org" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
New-ADGroup "Managers" -GroupCategory Security -GroupScope Global
New-ADGroup "Minions" -GroupCategory Security -GroupScope Global
Add-ADGroupMember -Identity "Minions" -Members "CN=Hakan Hagenrud,CN=Users,DC=hger,DC=org", "CN=Daniel Svensson,CN=Users,DC=hger,DC=org"
Add-ADGroupMember -Identity "Managers" -Members "CN=Mister Manager,CN=Users,DC=hger,DC=org"
'@

echo $daScript > $myScript

Install-Windowsfeature AD-Domain-Services
Install-WindowsFeature RSAT-ADDS
Import-Module ADDSDeployment

Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName $myDomain -DomainNetbiosName $myNetbios -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword:$Secure_String_Pwd ` 


