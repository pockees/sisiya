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
if($Args.Length -lt 2) {
	Write-Host "Usage: " $prog_name " SisIYA_Config.ps1 expire" 
	Write-Host "Usage: " $prog_name " SisIYA_Config.ps1 expire output_file" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$client_conf_file = $Args[0]
$expire = $Args[1]
if ([System.IO.File]::Exists($client_conf_file) -eq $False) {
	Write-Host $prog_name ": SisIYA configuration file " $client_conf_file " does not exist!"
	exit
}
[string]$output_file = ""
if ($Args.Length -eq 3) {
	$output_file = $Args[2]
}
### get configuration file included
. $client_conf_file 

if([System.IO.File]::Exists($local_conf) -eq $False) {
	Write-Output "SisIYA common configurations file " $sisiya_common_conf " does not exist!" | eventlog_error
	exit
}
### get SisIYA local configurations file included
. $local_conf 

if ([System.IO.File]::Exists($sisiya_functions) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions
### Module configuration file name. It has the same name as the script, because of powershell's include system, but 
### it is located under the $sisiya_base_dir\systems\hostname\conf directory.
$module_conf_file = $sisiya_host_conf_dir + "\" + $prog_name
$data_message_str = ''
############################################################################################################
### service id
$serviceid=$serviceid_mswindows_eventlog
if(! $serviceid_mswindows_eventlog) {
	Write-Output "Error : serviceid_mswindows_eventlog is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
############################################################################################################
### The warning_time and error_time values are used for interpreting eventlogs as follows:
### error_time=3 -> Eventlog error entries withing 1 day are treated as errors. If there are
### error eventlog entries older than 1 day are not counted as errors.
### warning_time=3 -> Eventlog warning entries withing 3 days are treated as warnings. If there are
### warning eventlog entries older than 3 days are not counted as warnings.
### The format of error and warning times is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
############################################################################################################
### the default values
$error_time="1:00"
$warning_time="1:00"
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
$statusid=$status_ok
$message_str=""

$ok_message_str=""
$warning_message_str=""
$error_message_str=""

$error_in_minutes=getTimeInMinutes($error_time)
$warning_in_minutes=getTimeInMinutes($warning_time)

### get calculate error and warning dates
$error_date=[DateTime]::Now.AddMinutes(-1 * $error_in_minutes)
$warning_date=[DateTime]::Now.AddMinutes(-1 * $warning_in_minutes)
#Write-Host "error_date=" $error_date "warning_date=" $warning_date

$now_date=Get-Date
$error_diff_date=New-TimeSpan -Start $error_date -End $now_date
$error_date_str=formatDateTime $error_diff_date.Days $error_diff_date.Hours $error_diff_date.Minutes
$warning_diff_date=New-TimeSpan -Start $warning_date -End $now_date
$warning_date_str=formatDateTime $warning_diff_date.Days $warning_diff_date.Hours $warning_diff_date.Minutes

### get event logs
$eventlogs=Get-EventLog -List
$i=0
while($i -lt $eventlogs.Length) {
	$current_statusid=$status_ok
	$error_events=Get-EventLog   -LogName $eventlogs[$i].Log | where {$error_date -le $_.TimeWritten -and $_.EntryType -match "Error"}
	$warning_events=Get-EventLog -LogName $eventlogs[$i].Log | where {$warning_date -le $_.TimeWritten -and $_.EntryType -match "Warning"}

	if($error_events.Count -gt 0) {
		$current_statusid=$status_error
		$error_message_str=$error_message_str + " ERROR: There are " + $error_events.Count + " errors in the event log for " + $eventlogs[$i].Log + " within " + $error_date_str + "!"
	}
	if($warning_events.Count -gt 0) {
		if($current_statusid -lt $status_warning) {
			$current_statusid=$status_warning
		}
		$warning_message_str=$message_str + " WARNING: There are " + $warning_events.Count + " warnings in the event log for " + $eventlogs[$i].Log + " within " + $warning_date_str + "!" 
	}
	if($current_statusid -eq $status_ok) {
		$ok_message_str=$ok_message_str + " OK: No errors " +  " within " + $error_date_str + " or warnings within " + $warning_date_str + " in the event log for " + $eventlogs[$i].Log + "."
	}
	$i=$i+1
}

$statusid=$status_ok
if($error_message_str.Length -gt 0) {
	$statusid=$status_error
}
elseif($warning_message_str.Length -gt 0) {
	$statusid=$status_warning
}
$error_message_str=$error_message_str.Trim()
$warning_message_str=$warning_message_str.Trim()
$ok_message_str=$ok_message_str.Trim()
$info_message_str=$info_message_str.Trim()
$message_str=$error_message_str + " " + $warning_message_str + " " + $ok_message_str + " " + $info_message_str
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
