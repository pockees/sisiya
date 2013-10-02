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
############################################################################################################
### service id
$serviceid=$serviceid_raid
if(! $serviceid_raid) {
	Write-Output "Error : serviceid_raid is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
############################################################################################################
### HP Array Configuration Utility Software
### the default values
$cli_prog="C:\Program Files\Compaq\Hpacucli\Bin\hpacucli.exe"
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
if([System.IO.File]::Exists($cli_prog) -eq $False) {
	Write-Output $prog_name ":Errror: The HP Array configuration utility " $cli_prog "does not exist!" | eventlog_error
	exit
}

$message_str=""
$error_message_str=""
$warning_message_str=""
$ok_message_str=""
$info_message_str=""

$str=& $cli_prog ctrl all show status
if(! $str) {
	$statusid=$status_warning
	$message_str="WARNING: Program " + $cli_prog + " returned nothing!"
	if($output_file.Length -eq 0) {
		. $send_message_prog $client_conf_file $sisiya_hostname $serviceid $statusid $expire $message_str
	}
	else {
		$str="$sisiya_hostname $serviceid $statusid $expire $message_str"
		Out-String -inputobject $str | Out-File -filepath $output_file -append
	}
	exit
}

#$str
[array]$ctrls=$str | FindStr Slot
#$ctrls
#Write-Host "Number of controllers: " $ctrls.Count

foreach($ctrl in $ctrls) {
	$ctrl_id=$ctrl.Split()[5]
	$str=& $cli_prog ctrl slot=$ctrl_id show detail

	$ctrl_status=($str | findstr /C:"Controller Status").Split()[5]
	$cache_status=($str | findstr /C:"Cache Status").Split()[5]
	# there are not always battery present
	#	$battery_status=($str | findstr /C:"Battery Status").Split()[5]
	$battery_status=$str | findstr /C:"Battery Status"
	if($ctrl_status -ne "OK") {
		$error_message_str=$error_message_str + " ERROR: Controller status (" + $ctrl_status + ") for the controller in slot=" + $ctrl_id + " is not OK!"
	}
	else {
		$ok_message_str=$ok_message_str + " OK: Controller status for the controller in slot=" + $ctrl_id + " is OK."
	}
	if($cache_status -ne "OK") {
		$error_message_str=$error_message_str + " ERROR: Cache status (" + $cache_status + ") for the controller in slot=" + $ctrl_id + " is not OK!"
	}
	else {
		$ok_message_str=$ok_message_str + " OK: Cache status for the controller in slot=" + $ctrl_id + " is OK."
	}

	if($battery_status) {
		if($battery_status -eq "OK") {
			$ok_message_str=$ok_message_str + " OK: Battery/Capasitor status for the controller in slot=" + $ctrl_id + " is OK."
		}
		elseif($battery_status -eq "Recharging") {
			$warning_message_str=$warning_message_str + " WARNING: Battery/Capasitor status for the controller in slot=" + $ctrl_id + " is Recharging!."
		}
		else {
			$error_message_str=$error_message_str + " ERROR: Battery/Capasitor status (" + $battery_status + ") for the controller in slot=" + $ctrl_id + " is not OK!."

		}
	}

	### info about the controller
	$ctrl_info=[system.string]::Join(" ",$str)
	$info_message_str=$info_message_str + " Info: " + $ctrl_info

	#
	[array]$logical_drives=& $cli_prog ctrl slot=$ctrl_id logicaldrive all show | findstr "logicaldrive"
	[int]$i=1
	while($i -le $logical_drives.Count) {
		$str=& $cli_prog ctrl slot=$ctrl_id logicaldrive $i show
#$str
		$raid_level=($str | findstr /C:"Fault Tolerance").Split(":")[1].Trim() 
		$logicaldrive_size=($str | findstr /C:"  Size").Split(":")[1].Trim() 
		$logicaldrive_stripe_size=($str | findstr /C:"Stripe Size").Split(":")[1].Trim() 
		$mount_points=($str | findstr /C:"Mount Points").Split(":")[1].Trim()
		$logicaldrive_status=($str | findstr /C:"  Status").Split(":")[1].Trim() 
		$multidomain_status=($str | findstr /C:"MultiDomain Status").Split(":")[1].Trim() 
 

#		Write-Host "raid level=" $raid_level " logicaldrive_size=" $logicaldrive_size " logicaldrive_stripe_size=" $logicaldrive_stripe_size
#		Write-Host "mount_points=" $mount_points " logicaldrive_status=" $logicaldrive_status " multidomain_status=" $multidomain_status

		if($logicaldrive_status -eq "OK") {
			$ok_message_str=$ok_message_str + " OK: Logical drive " + $i + " (with RAID level=" + $raid_level + ", size=" + $logicaldrive_size + ", stripe size=" + $logicaldrive_stripe_size + ", mount poinst=" + $mount_points + ", multi domain status=" + $multidomain_status + ") in controller slot " + $ctrl_id + " is OK."
		}
		else {
			$error_message_str=$error_message_str + " ERROR: Logical drive " + $i + " (with RAID level=" + $raid_level + ", size=" + $logicaldrive_size + ", stripe size=" + $logicaldrive_stripe_size + ", mount poinst=" + $mount_points + ", multi domain status=" + $multidomain_status + ") in controller slot " + $ctrl_id + " has status " + $logicaldrive_status + "!"
		}

		### check physical drive status on this logical drive
		[array]$ld_str=$str | findstr "physicaldrive"
		### hpacucli does not list physical drives for RAID5 and maybe for other RAID levels, exept for RAID1 and RAID10
		### Find another way to check physical drives for a particular logical drive.
		if($ld_str) {
			$total_physical_drives=$ld_str.Count
			$faulty_drives=$ld_str | where {$_.Split(",")[3].Split(")")[0].Trim() | findstr  /V "OK" }
			$faulty_physical_drives=0
			if($faulty_drives.Count -gt 0) {
				$faulty_physical_drives=$faulty_drives.Count
			}
	#		Write-Host "total drives=" $total_physical_drives " faulty_physical_drives=" $faulty_physical_drives
			if($faulty_physical_drives -ne 0) {
				### find out which drives have problems and their location (bay number)
				foreach($faulty_drive in $faulty_drives) {
					$drive_bay=$faulty_drive.Split(",")[0].Split(":")[4].Split()[1]
					$drive_status=$faulty_drive.Split(",")[3].Split(")")[0]
					$error_message_str=$error_message_str + " ERROR: The hard disk (controller in slot " + $ctrl_id + ", logical drive=" + $i + ") in the bay " + $drive_bay + " has status " + $drive_status + "!"
				}
				$error_message_str=$error_message_str + " ERROR: " + $faulty_physical_drives + " out of " + $total_physical_drives + " physical drives on the controller in slot " + $ctrl_id + " are not OK!"			
			}
			else {
				$ok_message_str=$ok_message_str + " OK: " + $total_physical_drives + " physical drives on the controller in slot=" + $ctrl_id + " and logical drive=" + $i + "are OK."			
			}
		}
		$i=$i+1
	}
	
	
}
### check individual logical and physical drives
$str=& $cli_prog ctrl all show config

$total_physical_drives=([array]($str | findstr "physicaldrive")).Count
$total_logical_drives=([array]($str | findstr "logicaldrive")).Count

$faulty_drives=$str | findstr "logicaldrive" | where {$_.Split(",")[2].Split(")")[0].Trim() | findstr  /V "OK" }
$faulty_logical_drive_count=0
if($faulty_drives) {
	$faulty_logical_drive_count=$faulty_drives.Count
}

if($faulty_logical_drive_count -gt 0) {
	$error_message_str=$error_message_str + " ERROR: " + $faulty_logical_drive_count + " out of " + $total_logical_drives + " logical drives are not OK!"	
}
else {
	$ok_message_str=$ok_message_str + " OK: All " + $total_logical_drives + " logical drives are OK."	
}

$faulty_drives=$str | findstr "physicaldrive" | where {$_.Split(",")[3].Split(")")[0].Trim() | findstr  /V "OK" }
$faulty_physical_drive_count=0
if($faulty_drives) {
	$faulty_physical_drive_count=$faulty_drives.Count
}

if($faulty_physical_drive_count -gt 0) {
	### find out which drives have problems and their location (bay number)
	foreach($faulty_drive in $faulty_drives) {
		$drive_bay=$faulty_drive.Split(",")[0].Split(":")[4].Split()[1]
		$drive_status=$faulty_drive.Split(",")[3].Split(")")[0]
		$error_message_str=$error_message_str + " ERROR: The hard disk in the bay " + $drive_bay + " has status " + $drive_status + "!"
	}
	$error_message_str=$error_message_str + " ERROR: " + $faulty_physical_drive_count + " out of " + $total_physical_drives + " logical drives are not OK!"	
}
else {
	$ok_message_str=$ok_message_str + " OK: All " + $total_physical_drives + " physical drives are OK."	
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
