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
$serviceid=$serviceid_progs
if(! $serviceid_progs) {
	Write-Output " Error : serviceid_progs is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
############################################################################################################
### the default values
$prog_list=@("System","svchost")
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
#else {
#	Write-Host $prog_name ": ERROR: This script must have the module configuration file :" $module_conf_file
#	Write-Host "There is no default values for this script. The module_conf_file must contain a list of "
#	Write-Host "programs that must be running all the time."
#	Write-Host 'The list must be of the form: $prog_list=@("prog1","prog2","prog3",...)'
#	exit
#}
###############################################################################################################################################
################################
$message_str=""
$error_message_str=""
$ok_message_str=""
$statusid=$status_ok

### get processes
$processes=Get-Process
foreach($p in $prog_list) {
	$r=$processes | FindStr $p
	if(! $r) {
		if($error_message_str.Length -eq 0) {
			$error_message_str=$p 
		}
		else {
			$error_message_str=$error_message_str + ", " + $p 
		}
	}
	else {
		if($ok_message_str.Length -eq 0) {
			$ok_message_str=$p 
		}
		else {
			$ok_message_str=$ok_message_str + ", " + $p 
		}

	}
}

if($error_message_str.Length -gt 0) {
	$statusid=$status_error
	$error_message_str="ERROR: "+ $error_message_str + "!"
}
if($ok_message_str.Length -gt 0) {
	$ok_message_str="OK: "+$ok_message_str + "."
}
$message_str=$error_message_str + " " + $ok_message_str
$message_str=$message_str.Trim()
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
