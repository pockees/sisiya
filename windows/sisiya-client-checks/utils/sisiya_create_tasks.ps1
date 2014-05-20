# This script creates SisIYA tasks.
#
#    Copyright (C) 2003 - 2014  Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#################################################################################
function getPathFromRegistry
{
	[string]$sisiya_registry_key="HKLM:\SOFTWARE\SisIYA_client_checks"
	$a=Get-ItemProperty $sisiya_registry_key
	if($a) {
		return $a.Path
	}
	else {
		Write-Host $prog_name ":Error: Could not get Path from " $sisiya_registry_key " registry!"
		exit
	}
}
#################################################################################
function deleteScheduledTask
{
	Param (
		[string]$task_name	# the Scheduled Task name
	)

	# query the task schedler
	$command_str = "schtasks /Query | findstr " + $task_name 
	#Write-Host $command_str
	$ret = Invoke-Expression $command_str
	if($?) {
		$command_str = "schtasks /Delete /TN " + $task_name + " /F"
		#Write-Host $command_str
		Invoke-Expression $command_str 2> $null
	}
}

# get system language
$QueryString=Get-WmiObject Win32_OperatingSystem
$language_code=$QueryString.OSLanguage
$computer_name=$QueryString.CSName
$os_version=$QueryString.Version.Substring(0,3)

# get credential "for local computer"
#$local_credential = Get-Credential(".")

# Select minute variable depending on the OS language
$minute_str = "MINUTE"
if($os_version -ne 6.1)	{
	if($language_code -eq 1055)	{
		$minute_str = "DAKÝKA"
	}
}
# MS Windows 8 and above do not have language dependent parameters to the schtasks command
if($os_version -gt 6.2)	{
	$minute_str = "MINUTE"
}

### get installation path
$path_str=getPathFromRegistry 
################################################################################################################

################################################################################################################
$prog_str=$path_str + "\utils\run_sisiya_all.vbs"
$task_name="SisIYA_client_checks"
$interval=10
#$user_and_password="/RU sisiya /RP password"
$user_and_password=""

deleteScheduledTask $task_name

$command_str = "schtasks /Create " + $user_and_password + " /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#$command_str = "schtasks /Create /S `"" + $computer_name + "`" " + "/RU `"" + $local_credential.UserName + "`" /RP `"" + $local_credential.Password + "`" /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#Write-Host $command_str

Invoke-Expression $command_str > $null
################################################################################################################

################################################################################################################
$prog_str=$path_str + "\utils\run_eventlog_isuptodate.vbs"
$task_name="SisIYA_eventlog_isuptodate"
$interval=30

deleteScheduledTask $task_name

$command_str = "schtasks /Create " + $user_and_password + " /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#$command_str = "schtasks /Create /S `"" + $computer_name + "`" " + "/RU `"" + $local_credential.UserName + "`" /RP `"" + $local_credential.Password + "`" /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#Write-Host $command_str

Invoke-Expression $command_str > $null
################################################################################################################

################################################################################################################
$prog_str=$path_str + "\utils\run_sisiya_client_update.vbs"
$task_name="SisIYA_client_update"
$interval=60

deleteScheduledTask $task_name > $null

$command_str = "schtasks /Create " + $user_and_password + " /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#$command_str = "schtasks /Create /S `"" + $computer_name + "`" " + "/RU `"" + $local_credential.UserName + "`" /RP `"" + $local_credential.Password + "`" /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#Write-Host $command_str

Invoke-Expression $command_str > $null
################################################################################################################

################################################################################################################
$prog_str=$path_str + "\utils\run_windows_update.vbs"
$task_name="windows_update"
$interval=120

deleteScheduledTask $task_name > $null

$command_str = "schtasks /Create " + $user_and_password + " /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#$command_str = "schtasks /Create /S `"" + $computer_name + "`" " + "/RU `"" + $local_credential.UserName + "`" /RP `"" + $local_credential.Password + "`" /SC " + [CHAR]34 + $minute_str + [CHAR]34 + " /MO " + $interval + " /TN " + [CHAR]34 + $task_name + [CHAR]34 + " /ST 00:00:00 /SD 01/01/2007" + " /TR "+ "'C:\WINDOWS\System32\wscript.exe` `"`"`"" + $prog_str + "`"`"'" 
#Write-Host $command_str

Invoke-Expression $command_str > $null
################################################################################################################
