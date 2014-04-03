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
### service id
if(! $serviceids.Item("progs")) {
	Write-Output " Error : progs serviceid is not defined!" | eventlog_error
	exit
}
$serviceid = $serviceids.Item("progs")
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
$statusid=$statusids.Item("ok")

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
	$statusid=$statusids.Item("error")
	$error_message_str="ERROR: "+ $error_message_str + "!"
}
if($ok_message_str.Length -gt 0) {
	$ok_message_str="OK: "+$ok_message_str + "."
}
$message_str=$error_message_str + " " + $ok_message_str
$message_str=$message_str.Trim()
###############################################################################################################################################
#Write-Host "hostname=$hostname serviceid=$serviceid statusid=$statusid expire=$expire message=$message_str data_message_str=$data_message_str"
if($output_file.Length -eq 0) {
	. $send_message_prog $conf_file $hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
}
else {
	$str="$hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	Out-String -inputobject $str | Out-File -filepath $output_file -append
}
###############################################################################################################################################
