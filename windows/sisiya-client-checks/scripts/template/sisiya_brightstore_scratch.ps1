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
if (! $serviceids.Item("brightstore_scratch")) {
	Write-Output "Error : brightstore_scratch serviceid is not defined!" | eventlog_error
	exit
}
$serviceid = $serviceids.Item("brightstore_scratch")
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
$ca_dbmgr_prog = $external_progs.Item('ca_dbmgr')
if([System.IO.File]::Exists($ca_dbmgr_prog) -eq $False) {
	Write-Output $prog_name ":Error: The CA DB manager command line utility " $ca_dbmgr_prog "does not exist!" | eventlog_error
	exit
}

$message_str=""
$error_message_str=""
$warning_message_str=""
$ok_message_str=""
$info_message_str=""

###############################################################################################################################################
#ca_dbmgr.exe -cahost server1 -show pools
#
# NO.           POOL NAME     OWNER              CREATE DATE  SAVE RETENTION   NEXT SERIAL
#----------------------------------------------------------------------------------------------
#   1         ASDBPROTJOB                                N/A     0         6       1100000
#   2               POOL1                                N/A     0         6       1000013
#   3             DEFAULT                                N/A     0         0           N/A
#
###############################################################################################################################################
#
###############################################################################################################################################
#ca_dbmgr.exe -cahost server1 -show scratchmedia
#
#SCRATCH SET:
#
# NO.           TAPE NAME     SERIAL NO      ID SEQ.     FORMAT DATE      EXPIRES ON     POOL
#----------------------------------------------------------------------------------------------------
#   1      08.12.09 18:30       1000014    88cf    1  08.12.2009 18:30:06  31.10.2010 01:45:08    POOL1
#   2      14.12.09 18:30       1100004    6ccd    1  14.12.2009 18:30:08  04.10.2010 00:45:32    POOL1
#   3      15.12.09 18:30       1100005    ce80    1  15.12.2009 18:30:10  05.10.2010 00:45:30    POOL1
#   4      16.12.09 08:39       1000001    9e1c    1  16.12.2009 08:39:22  08.10.2010 18:05:24    POOL1
#   5      16.12.09 18:30       1000017    27ab    1  16.12.2009 18:30:10  08.11.2010 23:45:10    POOL1
#   6      17.12.09 08:26       1000002    e6ba    1  17.12.2009 08:26:56  11.10.2010 00:45:06    POOL1
#   7      17.12.09 18:30       1000003    72e9    1  17.12.2009 18:30:08  15.10.2010 00:45:08    POOL1
#   8      18.12.09 18:30       1000004    ba51    1  18.12.2009 18:30:12  16.10.2010 00:45:08    POOL1
#   9      21.12.09 18:30       1000019    c023    1  21.12.2009 18:30:14  30.07.2011 20:14:06    POOL1
#  10      22.12.09 18:30       1000006     9ed    1  22.12.2009 18:30:04  18.10.2010 00:45:10    POOL1
#  11      23.12.09 18:30       1000007    5ea5    1  23.12.2009 18:30:08  19.10.2010 00:45:08    POOL1
#  12      28.12.09 16:53       1000009    e258    1  28.12.2009 16:53:02  23.10.2010 00:45:08    POOL1
#  13      29.12.09 18:30       1000010    3352    1  29.12.2009 18:30:04  24.10.2010 00:45:08    POOL1
#  14      30.12.09 18:30       1000011    82f5    1  30.12.2009 18:30:08  25.10.2010 00:45:08    POOL1
###############################################################################################################################################
#
###############################################################################################################################################
#ca_dbmgr.exe -cahost server1 -show savemedia
#
#SAVE SET:
#
# NO.           TAPE NAME     SERIAL NO      ID SEQ.     FORMAT DATE      EXPIRES ON     POOL
#----------------------------------------------------------------------------------------------------
#   1      04.01.10 18:30       1000013    26ec    1  04.01.2010 18:30:02  30.10.2010 01:45:06    POOL1
#   2      07.01.10 08:12       1100003    914e    1  07.01.2010 08:12:12  03.10.2010 00:45:24    POOL1
#   3              MONDAY       1000015    3e65    1  05.01.2010 13:48:36  31.10.2010 23:45:10    POOL1
#   4              MONDAY       1000016    5713    1  06.01.2010 11:00:10  01.11.2010 23:45:08    POOL1
###############################################################################################################################################

[array]$pool_list=& $ca_dbmgr_prog -show pools 
if($? -eq $false) {
	$error_message_str="ERROR: Could not execute ca_dbmgr.exe command!"
}
else {
	if($pool_list) {
		# skip header, the first 3 rows
		[int]$i=3
		while($i -lt $pool_list.Count) {
			$pool_name=$pool_list[$i].Substring(4,20).Trim()
			[array]$save_list= & $ca_dbmgr_prog -show savemedia | where {$_ -match $pool_name}
			### Get save set media count. This is only for info.
			$save_list_info_str=""
			if($save_list) {
				if($save_list.Count -gt 0) {
					$is_are="is"
					if($save_list.Count -gt 0) {
						$is_are="are"
					}
					$save_list_info_str="There " + $is_are + " " + $save_list.Count + " tapes in the save set of the media pool " + $pool_name + "."
				}
			}
			[array]$scratch_list= & $ca_dbmgr_prog -show scratchmedia | where {$_ -match $pool_name}
			if($scratch_list) {
				if($scratch_list.Count -gt 0) {
					$is_are="is"
					if($scratch_list.Count -gt 0) {
						$is_are="are"
					}
					$ok_message_str=$ok_message_str + " OK: There " + $is_are + " " + $scratch_list.Count + " tapes in the scratch set of the media pool " + $pool_name + ". " + $save_list_info_str
				}
				else {
					$warning_message_str=$warning_message_str + " WARNING: There are no tapes in the scratch set of the media pool " + $pool_name + "! " + $save_list_info_str
				}
			}
			else {
				$warning_message_str=$warning_message_str + " WARNING: There are no tapes in the media pool " + $pool_name + "!"
			}
	
	#		$error_message_str=$error_message_str + " ERROR: The drive (adapter:" + $device_adapter_number + ", scsi_id:" + $device_scsi_id + ", lun:" + $device_lun +") has status " + $device_status + "!=Enabled! " + $info_str
	#			}
	#			else {
					$ok_message_str=$ok_message_str + " OK: Media pool " + $pool_name + " is Ok."
	#			}
				$i++
		}
	}
	else {
		$error_message_str="ERROR: No media pool information!"
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
#Write-Host "hostname=$hostname serviceid=$serviceid statusid=$statusid expire=$expire message=$message_str data_message_str=$data_message_str"
if($output_file.Length -eq 0) {
	. $send_message_prog $conf_file $hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
}
else {
	$str="$hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	Out-String -inputobject $str | Out-File -filepath $output_file -append
}
###############################################################################################################################################
