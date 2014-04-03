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
if(! $serviceids.Item("services")) {
	Write-Output "Error : services serviceid is not defined!" | eventlog_error
	exit
}
$serviceid = $serviceids.Item("services")
############################################################################################################
### the default values
#$exceptions = @("clr_optimization_v4.0.30319_32", "SkypeUpdate")
$exceptions=""
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
$error_services_str=""
$info_services_str=""

#write-output "exceptions : count " + $exceptions.count + " exceptions = " + $exceptions

function isException()
{
	Param([String]$service_str)
	
	for($i = 0; $i -lt $exceptions.Count; $i++) {
		if($service_str -eq $exceptions[$i]) {
			return $True
		}
	}
	return $False
}

### get services
$services=Get-WmiObject Win32_Service
$n=0
foreach($service in $services) {
	if($service.StartMode -eq "Auto" -and $service.Started -eq 0) {
		if(($exceptions.Count -gt 0) -and (isException($service.Name) -eq $True)) {
			if($info_services_str.Length -eq 0) {
				$info_services_str=$service.Name +"(" + $service.Caption + ")"
			}
			else {
				$info_services_str=$info_services_str+ "," + $service.Name +"(" + $service.Caption + ")"
			}
			continue
		}	
		$n=$n+1
		if($error_services_str.Length -eq 0) {
			$error_services_str=$service.Name +"(" + $service.Caption + ")"
		}
		else {
			$error_services_str=$error_services_str+ "," + $service.Name +"(" + $service.Caption + ")"
		}
	}
}
if($n -gt 0) {
	$statusid=$statusids.Item("error")
	if($n -eq 1) {
		$message_str="ERROR: The following service: " + $error_services_str + " is set to auto start, but is not started!"
	}
	else {
		$message_str="ERROR: The following " + $n + " services: " + $error_services_str + " are set to auto start, but are not started!"
	}
}
else {
	$statusid=$statusids.Item("ok")
	$message_str="OK: All services set to be auto started are started."
}
if($info_services_str -ne "") {
	$message_str = $message_str + " INFO: The following service(s): " + $info_services_str + " is/are set to auto start, but is/are not started!"
}
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
