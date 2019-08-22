#Super admin will get this password
$myPassword = "Password1!"
$Secure_String_Pwd = ConvertTo-SecureString $myPassword -AsPlainText -Force
$myDomain = "hger.org"
$myNetbios = "HGER"
$myScript = "c:\usersgrops.ps1"

New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name "Run" -Value '%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $myScript' -PropertyType ExpandString
$daScript = @'
$Secure_String_Pwd = ConvertTo-SecureString "Password1!" -AsPlainText -Force
New-ADUser -Name "Hakan Hagenrud" -SamAccountName "hger" -Company "Purple Hat" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
New-ADUser -Name "Daniel Svensson" -SamAccountName "vsda" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd -Enabled $true -ChangePasswordAtLogon $false
'@

echo $daScript > $myScript


Install-Windowsfeature AD-Domain-Services
Install-WindowsFeature RSAT-ADDS
Import-Module ADDSDeployment


Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName $myDomain -DomainNetbiosName $myNetbios -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword:$Secure_String_Pwd ` 


