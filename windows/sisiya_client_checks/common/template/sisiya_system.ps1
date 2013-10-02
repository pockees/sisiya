############################################################################################################
#
#    Copyright (C) 2003 - 2010  Erdal Mutlu
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
$prog_name=$MyInvocation.MyCommand.Name
if($Args.Length -lt 2) {
	Write-Host "Usage: " $prog_name " sisiya_client_conf.ps1 expire" 
	Write-Host "Usage: " $prog_name " sisiya_client_conf.ps1 expire output_file" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$client_conf_file=$Args[0]
$expire=$Args[1]
if([System.IO.File]::Exists($client_conf_file) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Host $prog_name ": SisIYA configuration file " $client_conf_file " does not exist!"
	exit
}
[string]$output_file=""
if($Args.Length -eq 3) {
	$output_file=$Args[2]
}
### get configuration file included
. $client_conf_file 

if([System.IO.File]::Exists($sisiya_common_conf) -eq $False) {
	Write-Output "SisIYA common configurations file " $sisiya_common_conf " does not exist!" | eventlog_error
	exit
}
### get SisIYA common configurations file included
. $sisiya_common_conf 

if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions
### Module configuration file name. It has the same name as the script, because of powershell's include system, but 
### it is located under the $sisiya_base_dir\systems\hostname\conf directory.
$module_conf_file=$sisiya_host_conf_dir + "\" + $prog_name
$data_message_str=''
############################################################################################################
### service id
$serviceid=$serviceid_system
### because serviceid_system=0 if(! $serviceid_system) is always true
#if(! $serviceid_system) {
#	Write-Host $prog_name " Error : serviceid_system is not defined in the SisIYA client configuration file " $client_conf_file "!"
#	exit
#}
############################################################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
############################################################################################################
### the default values
$error_uptime="1"
$warning_uptime="3"
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
### get a wmi object
$wmi=Get-WmiObject -Class Win32_OperatingSystem
### get uptime
$uptime=$wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime)

$error_in_minutes=getTimeInMinutes($error_uptime)
$warning_in_minutes=getTimeInMinutes($warning_uptime)

$uptime_str=formatDateTime $uptime.Days $uptime.Hours $uptime.Minutes
if($uptime.TotalMinutes -le $error_in_minutes) {
	$statusid=$status_error
	$error_uptime_str=formatDateTime2 $error_uptime
	$message_str="ERROR: The system was restarted $uptime_str (<= $error_uptime_str) ago!" 
}
elseif($uptime.TotalMinutes -le $warning_in_minutes) {
	$statusid=$status_warning
	$warning_uptime_str=formatDateTime2 $warning_uptime
	$message_str="WARNING: The system was restarted  $uptime_str (<=  $warning_uptime_str) ago!"
}
else {
	$statusid=$status_ok
	$message_str="OK: The system is up since $uptime_str."
}

### get system info
$sys_info=getSystemInfo
$sisiya_client_version=getInstalledVersion
$ip_info = getIpInfo($sisiya_hostname)
$message_str="$message_str INFO: $sys_info IP: $ip_info SisIYA: $sisiya_client_version"
###############################################################################################################################################
#Write-Host "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire message=$message_str data_message_str=$data_message_str"
if($output_file.Length -eq 0) {
	. $send_message_prog $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
}
else {
	$str="$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	Out-String -inputobject $str | Out-File -filepath $output_file -append
}
###############################################################################################################################################
