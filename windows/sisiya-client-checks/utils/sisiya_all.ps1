# This script executes all client checks in common and systems\hostname\ directories.
#
#    Copyright (C) 2003  - 2010  Erdal Mutlu
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
$prog_name=$MyInvocation.MyCommand.Name
if($Args.Length -ne 1) {
	Write-Host "Usage: " $prog_name " expire" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$expire = $Args[0]

function getPathFromRegistry
{
	[string]$sisiya_registry_key = "HKLM:\SOFTWARE\SisIYA_client_checks"
	$a=Get-ItemProperty $sisiya_registry_key
	if($a) {
		return $a.Path
	}
	else {
		Write-Host $prog_name ":Error: Could not get Path from " $sisiya_registry_key " registry!"
		exit
	}
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

$path_str = getPathFromRegistry 
$conf_file = $path_str + "\conf\SisIYA_Config.ps1"
if([System.IO.File]::Exists($sisiya_conf_file) -eq $False) {
	Write-Host $prog_name ":ERROR: SisIYA configuration file $sisiya_conf_file does not exist!"
	exit
}
### get SisIYA client configurations file included
. $conf_file
if([System.IO.File]::Exists($local_conf_file) -eq $Ture) {
	### get SisIYA client local configurations file included
	. $local_conf_file 
}

if([System.IO.File]::Exists($mon_conf) -eq $False) {
	Write-Output "SisIYA common configurations file " $sisiya_common_conf " does not exist!" | eventlog_error
	exit
}
### get SisIYA common configurations file included
. $sisiya_common_conf 


if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions

### check the send message prog
if([System.IO.File]::Exists($send_message2_prog) -eq $False) {
	Write-Output "SisIYA send message program " $send_message2_prog " does not exist!" | eventlog_error
	exit
}

### check base directories
foreach($d in $sisiya_base_dir, $sisiya_common_dir, $sisiya_special_dir, $sisiya_tmp_dir) {
	if([System.IO.Directory]::Exists($d) -eq $False) {
		Write-Host $prog_name ": Directory " $d " does not exist!"
		exit
	}
}
###
$output_file = makeTempFile
### execute common scripts
cd $sisiya_common_dir
$files = Get-ChildItem sisiya_*.ps1
foreach($f in $files) {
	if(! $f) {
		continue
	}
	#Write-Host "common file=" $f " fullname=" $f.FullName
	#Write-Host $f $sisiya_conf_file $expire
	#Write-Output "running " $f | eventlog_info
	. $f $sisiya_conf_file $expire $output_file
	#Write-Output "finished " $f | eventlog_info
}

### execute special scripts
if([System.IO.Directory]::Exists($sisiya_host_dir) -eq $True) {
	cd $sisiya_host_dir
	### for scripts
	$files=Get-ChildItem sisiya_*.ps1
	foreach($f in $files) {
		if(! $f) {
			continue
		}
		#Write-Output "running " $f | eventlog_info
		. $f $sisiya_conf_file $expire $output_file
		#Write-Output "finished " $f | eventlog_info
	}
	### for linked scripts
	$wsh_shell=New-Object -ComObject WScript.Shell
	$files=Get-ChildItem *.lnk
	foreach($link_file in $files) {
		if(! $link_file) {
			continue
		}
		#Write-Output "running " $link_file $x | eventlog_info
		$link=$wsh_shell.CreateShortcut($link_file)
		. $link.TargetPath $sisiya_conf_file $expire $output_file
		#Write-Output "finished " $link_file $x | eventlog_info
	}
}
### send all messages
. $send_message2_prog $sisiya_conf_file $output_file
### remove the tmp file
Remove-Item $output_file
###
cd $sisiya_base_dir
