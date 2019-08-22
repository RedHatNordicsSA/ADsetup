#Super admin will get this password
$myPassword = "Password1!"
$Secure_String_Pwd = ConvertTo-SecureString $myPassword -AsPlainText -Force
$myDomain = "hger.org"
$myNetbios = "HGER"
$myScript = "c:\usersgrops.ps1"

Set-Runonce -command '%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $myScript' 

$daScript = @'
$Secure_String_Pwd = ConvertTo-SecureString $myPassword -AsPlainText -Force
New-ADUser -Name "Hakan Hagenrud" -SamAccountName "hger" -Company "Purple Hat" -AccountPassword $Secure_String_Pwd
New-ADUser -Name "Daniel Svensson" -SamAccountName "vsda" -Company "Furniture Heaven" -AccountPassword $Secure_String_Pwd
'@

echo $daScript > $myScript


install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment

Install-ADDSForest -CreateDnsDelegation:$false ` 
                   -DatabasePath "C:\Windows\NTDS" `
                   -DomainMode "Win2012R2" `
                   -DomainName $myDomain `
                   -DomainNetbiosName $myNetbios `
                   -ForestMode "Win2012R2" `
                   -InstallDns:$true `
                   -LogPath "C:\Windows\NTDS" `
                   -NoRebootOnCompletion:$false `
                   -SysvolPath "C:\Windows\SYSVOL" `
                   -Force:$true `
                   -SafeModeAdministratorPassword:$Secure_String_Pwd