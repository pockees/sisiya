# This script executes all client checks which are set to auto mode
# in the SisIYA_Config.ps1 and SisIYA_Config_local.ps1 configuration files.
# The default values are set in the SisIYA_Config.ps1 and overwritten in
# the SisIYA_Client_local.ps1.
#
#    Copyright (C) 2003  - 2014  Erdal Mutlu
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
$prog_name = $MyInvocation.MyCommand.Name
if ($Args.Length -lt 2 -or $Args.Length -gt 3) {
	Write-Host "Usage  : " $prog_name " client_conf expire" 
	Write-Host "Example: " $prog_name " c:\Program Files\conf\SisIYA_Client.ps1 check_script 15" 
	Write-Host "The expire parameter must be given in minutes."
	Write-Host "When run without check_script parameter all checks which are";
	Write-Host "set auto mode in the SisIYA_Config are excecuted.";
	exit
} 

function getPathFromRegistry
{
	[string]$registry_key = "HKLM:\SOFTWARE\SisIYA_client_checks"
	$a = Get-ItemProperty $registry_key
	if($a) {
		return $a.Path
	}
	else {
		Write-Host $prog_name ":Error: Could not get Path from " $registry_key " registry!"
		exit
	}
}

# Parameter	: script name, expire
# Return	: xml message string
function run_script
{
	param
	(
		[string]$script_name,
		[int]$expire
	)
	#Write-Host "run_script: script_name=" $script_name "expire=" $expire
	#$checks.Keys
	#Write-Host "run_script: auto =" $checks.Item($script_name).Item("auto") "script =" $checks.Item($script_name).Item("script")
	$script_file = $scripts_dir + "\" + $checks.Item($script_name).Item("script")
	#Write-Host "run_script: Executing $script_file ..."
	[string]$s = . $script_file $conf_file $expire
	#$status_id = $?
	$status_id = $LastExitCode
	#$service_id = get_serviceid $s
	$a = $s.split($FS)
	$service_name = $a[0]
	$service_id = $serviceids[$service_name]
	$s = $a[1]
	# replace ' with \', because it is a problem in the SQL statemnet
	$s = '<message><serviceid>' + $service_id + '</serviceid><statusid>' + $status_id + '</statusid><expire>' + $expire + '</expire><data>' + $s + '</data></message>'

	return $s
}

function process_checks
{
	param ( [int]$expire )

	[string]$s = ''
	#Write-Host "process_checks: expire=" $expire
	foreach ($script_name in $checks.Keys) {
		if ($checks.Item($script_name).Item("auto") -eq 1) {
			#Write-Host "process_checks: Executing $script_name ..."
			$s += run_script $script_name $expire
		} #else {
			#Write-Host "process_checks: Skiping $script_name ..."
		#}
	}
	return $s
}

### get the installation path from registry
#$sisiya_conf_file="C:\Program Files\SisIYA_client_checks\sisiya_client_conf.ps1"
#$a=Get-ItemProperty HKLM:\SOFTWARE\SisIYA_client_checks
#if($a) {
#	$sisiya_conf_file=$a.Path + "\sisiya_client_conf.ps1"
#}
#else {
#	Write-Host $prog_name ":Error: Could not get Path from HKLM:\SOFTWARE\SisIYA_client_checks registry! The sisiya_conf_file is not defined!"
#	exit
#}

#$path_str = getPathFromRegistry 
#$conf_file = $path_str + "\conf\SisIYA_Config.ps1"

$conf_file = $Args[0]
if ([System.IO.File]::Exists($conf_file) -eq $False) {
	Write-Host $prog_name ":ERROR: SisIYA configuration file $conf_file does not exist!"
	exit
}
### include the SisIYA client configurations file
. $conf_file
if ([System.IO.File]::Exists($local_conf_file) -eq $True) {
	### include the SisIYA client local configurations file
	. $local_conf_file 
}

if ([System.IO.File]::Exists($sisiya_functions) -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions

### check the send message prog
#if ([System.IO.File]::Exists($send_message2_prog) -eq $False) {
#	Write-Output "SisIYA send message program " $send_message2_prog " does not exist!" | eventlog_error
#	exit
#}

### check directories
foreach($d in $base_dir, $conf_dir, $conf_d_dir, $scripts_dir, $tmp_dir) {
	if([System.IO.Directory]::Exists($d) -eq $False) {
		Write-Host $prog_name ": Directory " $d " does not exist!"
		exit
	}
}

if ($Args.Length -eq 3) {
	$expire = $Args[2]
	$xml_s_str = run_script $Args[1] $expire
} else {
	$expire = $Args[1]
	$xml_s_str = process_checks $expire
}

### get current timestamp
$timestamp_str = getSisIYA_Timestamp

$xml_str = '<?xml version="1.0" encoding="utf-8"?>'
$xml_str += '<sisiya_messages><timestamp>' + $timestamp_str + '</timestamp>'
$xml_str += '<system><name>' + $hostname + '</name>'
$xml_str += $xml_s_str
$xml_str += '</system></sisiya_messages>'

if ($export_to_xml -eq 1) {
	$output_file = makeTempFile
	Write-Output $xml_str > $output_file
	### remove the tmp file
	Remove-Item $output_file
}
if ($send_to_server -eq 1) {
	$retcode = sendSisIYAMessage $SISIYA_SERVER $SISIYA_PORT $xml_str
}
write-host $xml_str
