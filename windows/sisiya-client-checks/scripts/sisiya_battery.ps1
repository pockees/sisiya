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
$service_name = "battery"
############################################################################################################
### the default values
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if ([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
$statusid = $statusids.Item("ok")
$message_str = ''

$info_message_str = ''
$ok_message_str = ''
$warning_message_str = ''
$error_message_str = ''

### get temperature information
$batteries=Get-WmiObject -NameSpace "root\WMI" -Class "BatteryStatus" 2> $null
if($batteries) {
	$data_str = ''
	foreach ($battery in $batteries) {
		### RemainingCapacity > 0 is a real battery. I could not find another info to distinguish between real battery.
		if($battery.RemainingCapacity -gt 0 -and $battery.Active -eq $True) {
			### find a to distinguish
			$battery_full = Get-WmiObject -NameSpace "root\WMI" -Class "BatteryFullChargedCapacity" | where-object {$_.InstanceName -match $battery.InstanceName.Replace("\","\\")} 2> $null
			[int]$charged_percent = 100 * $battery.RemainingCapacity / $battery_full.FullChargedCapacity
			if ($battery.Critical -eq $True) {
				$error_message_str += " ERROR: The battery " + $battery.InstanceName + " (" + $charged_percent + "%)" + " is in critical state!"
			}
			else {
				if ($battery.Discharging -eq $True) {
					$ok_message_str += " OK: Battery " + $battery.InstanceName + ": Discharging, " + $charged_percent + "%. Running on battery." 
				}
				else {
					$ok_message_str += " OK: Battery " + $battery.InstanceName + ": Charged " + $charged_percent + "%" + ". Running on AC power." 
				}
			}
			$data_str += '<entry name="' + $battery.InstanceName + '" type="percent">' + $charged_percent + '</entry>'
		}
	}
	if ($data_str -ne '') {
		$data_str = '<entries>' + $data_str + '</entries>'
	}
}
else {
	### do nothing, this system does not support ACPI batteries
	exit
	#$error_message_str = "ERROR: Could not get battery software information!"
}

$statusid = $statusids.Item("ok")
if ($error_message_str.Length -gt 0) {
	$statusid = $statusids.Item("error")
}
elseif ($warning_message_str.Length -gt 0) {
	$statusid = $statusids.Item("warning")
}
$error_message_str = $error_message_str.Trim()
$warning_message_str = $warning_message_str.Trim()
$ok_message_str = $ok_message_str.Trim()
$info_message_str = $info_message_str.Trim()
$message_str = $error_message_str + " " + $warning_message_str + " " + $ok_message_str + " " + $info_message_str

#######################################################################################
#Get-WmiObject -NameSpace "root\WMI" -Class "BatteryStatus"
#######################################################################################
#__GENUS            : 2
#__CLASS            : BatteryStatus
#__SUPERCLASS       : MSBatteryClass
#__DYNASTY          : CIM_StatisticalInformation
#__RELPATH          : BatteryStatus.InstanceName="ACPI\\PNP0C0A\\1_0"
#__PROPERTY_COUNT   : 20
#__DERIVATION       : {MSBatteryClass, Win32_PerfRawData, Win32_Perf, CIM_StatisticalInformation}
#__SERVER           : YAKOBICACO-DU
#__NAMESPACE        : root\WMI
#__PATH             : \\YAKOBICACO-DU\root\WMI:BatteryStatus.InstanceName="ACPI\\PNP0C0A\\1_0"
#Active             : True
#Caption            :
#ChargeRate         : 0
#Charging           : False
#Critical           : False
#Description        :
#DischargeRate      : 0
#Discharging        : False
#Frequency_Object   :
#Frequency_PerfTime :
#Frequency_Sys100NS :
#InstanceName       : ACPI\PNP0C0A\1_0
#Name               :
#PowerOnline        : True
#RemainingCapacity  : 55152
#Tag                : 1
#Timestamp_Object   :
#Timestamp_PerfTime :
#Timestamp_Sys100NS :
#Voltage            : 16447
#######################################################################################

#######################################################################################
#Get-WmiObject -NameSpace "root\WMI" -class "BatteryFullChargedCapacity"
#
#
#__GENUS             : 2
#__CLASS             : BatteryFullChargedCapacity
#__SUPERCLASS        : MSBatteryClass
#__DYNASTY           : CIM_StatisticalInformation
#__RELPATH           : BatteryFullChargedCapacity.InstanceName="ACPI\\PNP0C0A\\1_0"
#__PROPERTY_COUNT    : 13
#__DERIVATION        : {MSBatteryClass, Win32_PerfRawData, Win32_Perf, CIM_StatisticalInformation}
#__SERVER            : OMERCUNBUL-DU
#__NAMESPACE         : root\WMI
#__PATH              : \\OMERCUNBUL-DU\root\WMI:BatteryFullChargedCapacity.InstanceName="ACPI\\PNP0C0A\\1_0"
#Active              : True
#Caption             :
#Description         :
#Frequency_Object    :
#Frequency_PerfTime  :
#Frequency_Sys100NS  :
#FullChargedCapacity : 52304
#InstanceName        : ACPI\PNP0C0A\1_0
#Name                :
#Tag                 : 1
#Timestamp_Object    :
#Timestamp_PerfTime  :
#Timestamp_Sys100NS  :
#######################################################################################


###############################################################################################################################################
print_and_exit "$FS" "$service_name" $statusid "$message_str" "$data_str"
###############################################################################################################################################
