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
$service_name = "ntpstat"
############################################################################################################
### the default values
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
$message_str=""
$error_message_str=""
$warning_message_str=""
$ok_message_str=""
$info_message_str=""

###############################################################
### Example output of the w32tm /query /status command
#Leap Indicator: 0(no warning)
#Stratum: 4 (secondary reference - syncd by (S)NTP)
#Precision: -6 (15.625ms per tick)
#Root Delay: 0.1409302s
#Root Dispersion: 0.1794360s
#ReferenceId: 0xC8000003 (source IP:  200.0.0.3)
#Last Successful Sync Time: 12/30/2009 12:12:01 PM
#Source: ALT.altin.com
#Poll Interval: 15 (32768s)
###############################################################

[array]$list=w32tm /query /status
if($? -eq $True) {
	$status=$list[0].Split(":")[1].Split("(")[0].Trim()
	if($status -eq 0) {
		$ntp_server=$list[5].Split(":")[2].Split(")")[0].Trim()
		$stratum=$list[1].Split(":")[1].Split("(")[0].Trim()
		$last_sync_time=$list[6].Split(" ")[4] + " " + $list[6].Split(" ")[5] + " " + $list[6].Split(" ")[6]
		$poll_interval=$list[8].Split(":")[1].Trim()
		$info_str="(stratum: " + $stratum + ", last sync time: " + $last_sync_time + ", poll interval: " + $poll_interval + ")"
		$ok_message_str=$ok_message_str + " OK: The system clock is synchronized to " + $ntp_server + ". " + $info_str 
	}
	else {
		$error_message_str=$error_message_str + " ERROR: The system clock is not synchronized! status=" + $status + "(!=0)!"
	}
}
else {
	### try using the w32tm /monitor /computers:localhost #/nowarn

	[array]$list=w32tm /monitor /computers:localhost
	$status=$list | findstr /C:"NTP:" | findstr /C:"error"
	if(!$status) {
		$ntp_server=($list | findstr /C:"RefID:").Split(":")[1].Trim()
		$ok_message_str=$ok_message_str + " OK: The system clock is synchronized to " + $ntp_server + "." 
	}
	else {
		$error_message_str=$error_message_str + " ERROR: The system clock is not synchronized! status=" + $status
	}
	#$error_message_str=$error_message_str + " ERROR: Could not execute w32tm command!"
}

$statusid=$statusids.Item("ok")
if($error_message_str.Length -gt 0) {
	$statusid=$statusids.Item("error")
}
elseif($warning_message_str.Length -gt 0) {
	$statusid=$statusids.Item("warning")
}
$error_message_str=$error_message_str.Trim()
$warning_message_str=$warning_message_str.Trim()
$ok_message_str=$ok_message_str.Trim()
$info_message_str=$info_message_str.Trim()
$message_str=$error_message_str + " " + $warning_message_str + " " + $ok_message_str + " " + $info_message_str
###############################################################################################################################################
print_and_exit "$FS" "$service_name" $statusid "$message_str" "$data_str"
###############################################################################################################################################
