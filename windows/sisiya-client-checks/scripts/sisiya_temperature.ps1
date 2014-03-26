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
############################################################################################################
### service id
$serviceid=$serviceid_temperature
if(! $serviceid_temperature) {
	Write-Output "Error : serviceid_temperature is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
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
$statusid=$status_ok
$message_str=""

$info_message_str=""
$ok_message_str=""
$warning_message_str=""
$error_message_str=""


### get temperature information
$sensors=Get-WmiObject -NameSpace "root\WMI" -Class "MSAcpi_ThermalZoneTemperature" 2> $null
if($sensors) {
	foreach($sensor in $sensors) {
		$current_temperature=($sensor.CurrentTemperature -2732)/10
		$critical_temperature=($sensor.CriticalTripPoint -2732)/10
		$sensor_name=$sensor.__relpath.Split("\")[4].Split("`"")[0]
		if($sensor.CurrentTemperature -ge $sensor.CriticalTripPoint) {
			#MSAcpi_ThermalZoneTemperature.InstanceName="ACPI\\ThermalZone\\TZ5__0"
			$error_message_str=$error_message_str + " ERROR: The temperature of the " + $sensore_name + " has reached the critical value (" + $current_temperature + ">=" + $critical_temperature +" degree celsius)!"
		}
		else { 
			$ok_message_str=$ok_message_str + " OK: The temperature of the sensor " + $sensor_name + " is " + $current_temperature +" degree celsius." 
		}	
	}
}
else {
	### do nothing, this system does not support ACPI temperature
	exit

	$error_message_str="ERROR: Could not get temperature software information!"
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
