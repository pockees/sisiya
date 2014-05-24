############################################################################################################
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
############################################################################################################
$prog_name = $MyInvocation.MyCommand.Name
if ($Args.Length -lt 2) {
	Write-Host "Usage: " $prog_name " SisIYA_Config.ps1 expire" 
	Write-Host "Usage: " $prog_name " SisIYA_Config.ps1 expire output_file" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$conf_file = $Args[0]
$expire = $Args[1]
if ([System.IO.File]::Exists($conf_file) -eq $False) {
	Write-Host $prog_name ": SisIYA configuration file " $conf_file " does not exist!"
	exit
}
[string]$output_file = ""
if ($Args.Length -eq 3) {
	$output_file = $Args[2]
}
### get configuration file included
. $conf_file 

if([System.IO.File]::Exists($local_conf_file) -eq $False) {
	Write-Output "SisIYA local configurations file " $local_conf_file " does not exist!" | eventlog_error
	exit
}
### get SisIYA local configurations file included
. $local_conf_file 

if ([System.IO.File]::Exists($sisiya_functions) -eq $False) {
#if(test-path $conf_file -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions
### Module configuration file name. It has the same name as the script, because of powershell's include system, but 
### it is located under the $conf_d_dir directory.
$module_conf_file = $conf_d_dir + "\" + $prog_name
$data_message_str = ''
############################################################################################################
############################################################################################################
$service_name = "system"
############################################################################################################
### because serviceids.Item("system") = 0 if(! $serviceids.Item("system")) is always true
#if (! $serviceids.Item("system")) {
#	Write-Host $prog_name " Error : serviceids.Item("system is not defined in the SisIYA client configuration file " $client_conf_file "!"
#	exit
#}
############################################################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
############################################################################################################
### the default values
$error_uptime = "1"
$warning_uptime = "3"
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if ([System.IO.File]::Exists($module_conf_file) -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
### get a wmi object
$wmi = Get-WmiObject -Class Win32_OperatingSystem
### get uptime
$uptime = $wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime)

$error_in_minutes = getTimeInMinutes($error_uptime)
$warning_in_minutes = getTimeInMinutes($warning_uptime)

$uptime_str = formatDateTime $uptime.Days $uptime.Hours $uptime.Minutes
if ($uptime.TotalMinutes -le $error_in_minutes) {
	$statusid = $statusids.Item("error")
	$error_uptime_str = formatDateTime2 $error_uptime
	$message_str = "ERROR: The system was restarted $uptime_str (<= $error_uptime_str) ago!" 
}
elseif ($uptime.TotalMinutes -le $warning_in_minutes) {
	$statusid = $statusids.Item("warning")
	$warning_uptime_str = formatDateTime2 $warning_uptime
	$message_str = "WARNING: The system was restarted  $uptime_str (<=  $warning_uptime_str) ago!"
}
else {
	$statusid = $statusids.Item("ok")
	$message_str = "OK: The system is up since $uptime_str."
}

### get system info
$sys_info = getSystemInfo
$sisiya_client_version = getInstalledVersion
$ip_info = getIPInfo($hostname)
$message_str = "$message_str INFO: $sys_info IP: $ip_info SisIYA: $sisiya_client_version"
###############################################################################################################################################
print_and_exit "$FS" "$service_name" $statusid "$message_str" "$data_str"
###############################################################################################################################################
