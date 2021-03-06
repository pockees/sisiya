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
service_name = "brightstore_devices"
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
$ca_devmgr_prog = $external_progs.Item('ca_devmgr')
if([System.IO.File]::Exists($ca_devmgr_prog) -eq $False) {
	Write-Output $prog_name ":Errror: The CA queue manager command line utility " $ca_devmgr_prog "does not exist!" | eventlog_error
	exit
}

$message_str=""
$error_message_str=""
$warning_message_str=""
$ok_message_str=""
$info_message_str=""

##############################################################
### ca_devmgr.exe -cahost machine1 -deviceinfo -all
### ca_devmgr.exe -deviceinfo -all
#
#     Type:                   Drive
#     Adapter Number:         2
#     SCSI id:                3
#     LUN:                    0
#     Vendor:                 HP
#     Product:                Ultrium 2-SCSI
#     Firmware:               S63D
#     Status:                 Enabled
#     Device Sharing:         Disabled
#
##############################################################
[int]$number_of_deviceinfo_rows=9
[int]$number_of_empty_rows=2

[array]$d=& $ca_devmgr_prog -deviceinfo -all | where {$_ -match "Type:" -and $_ -match "Drive"}
if($? -eq $fale) {
	$error_message_str="ERROR: Could not execute ca_qmgr.exe command!"
}
else {
	if($d.Count -gt 0) {
	#	write-host "Total number of drives:" $d.Count
		[array]$list=& $ca_devmgr_prog -deviceinfo -all
	#	$list
		[int]$i=0
		while($i -lt $d.Count) {
			## the first 2 lines are empty, foolowed by $number_of_deviceinfo_rows info lines
	#		$offset=($i + 1) * $number_of_empty_rows + $i * $number_of_deviceinfo_rows
			$offset=$i * ($number_of_deviceinfo_rows + $number_of_empty_rows) + $number_of_empty_rows
			$device_type		=$list[$offset].Split(":")[1].Trim()
			$device_adapter_number	=$list[$offset + 1].Split(":")[1].Trim()
			$device_scsi_id		=$list[$offset + 2].Split(":")[1].Trim()
			$device_lun		=$list[$offset + 3].Split(":")[1].Trim()
			$device_vendor		=$list[$offset + 4].Split(":")[1].Trim()
			$device_product		=$list[$offset + 5].Split(":")[1].Trim()
			$device_firmware	=$list[$offset + 6].Split(":")[1].Trim()
			$device_status		=$list[$offset + 7].Split(":")[1].Trim()
			$device_device_sharing	=$list[$offset + 8].Split(":")[1].Trim()
	#		write-host "device_type:" $device_type "device_adapter_number:" $device_adapter_number "device_scsi_id:" $device_scsi_id "device_lun:" $device_lun "device_vendor:" $device_vendor "device_product:" $device_product "device_firmware:" $device_firmware "device_status:" $device_status "device_device_sharing:" $device_device_sharing
			$info_str="Device details: Type: " + $device_type + ", Vendor: " + $device_vendor + ", Product: " + $device_product + ", Firmware: " + $device_firmware
			if($device_status -ne "Enabled") {
				$error_message_str=$error_message_str + " ERROR: The drive (adapter:" + $device_adapter_number + ", scsi_id:" + $device_scsi_id + ", lun:" + $device_lun +") has status " + $device_status + "!=Enabled! " + $info_str
			}
			else {
				$ok_message_str=$ok_message_str + " OK: The drive (adapter:" + $device_adapter_number + ", scsi_id:" + $device_scsi_id + ", lun:" + $device_lun +") status is Ok. " + $info_str
			}
			$i++
		}
	}
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
