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
$service_name = "swap"
############################################################################################################
### the default values
$warning_percent=30
$error_percent=50
### end of the default values
############################################################################################################
### If there is a module conf file then override these default values
if([System.IO.File]::Exists($module_conf_file) -eq $True) {
#if(test-path $module_conf_file -eq $True) {
	. $module_conf_file
}
###############################################################################################################################################
$message_str=""

### get page file
$pf=Get-WmiObject -Class Win32_PageFileUsage

### get RAM
$a=Get-WmiObject -Class Win32_ComputerSystem
$total_ram=$a.TotalPhysicalMemory / 1MB
$total_ram="{0:N0}" -f $total_ram
$rams=Get-WmiObject -Class Win32_PhysicalMemory | where{$_.MemoryType -eq 0}
$ram_str="RAM: total=" + $total_ram + "MB"
$i=1
foreach($ram in $rams) {
	#$ram_str=$ram_str + "capacity=" + $ram.Capacity / 1MB + " speed=" + $ram.Speed + " status=" + $ram.Status + " model=" + $ram.Model + " type=" + $ram.MemoryType + " bank label=" + $ram.BankLabel + " name=" + $ram.Name
	if($i -gt 1) {
		$ram_str=$ram_str + ","
	}
	$ram_capacity=$ram.Capacity / 1MB
	$ram_capacity="{0:N0}" -f $ram_capacity
	$ram_str=$ram_str + " " + $i + ": capacity=" + $ram_capacity + "MB speed=" + $ram.Speed 
	$i=$i+1
}

$total_swap=$pf.AllocatedBaseSize
$used_swap=$pf.CurrentUsage
$free_swap=$total_swap - $used_swap
$used_percent=100 * $used_swap / $total_swap 
$info_str="SWAP: total="+$total_swap + "MB used=" + $used_swap + "MB free=" + $free_swap + "MB. " + $ram_str

if($used_percent -ge $error_percent) {
	$statusid=$statusids.Item("error")
	$message_str="ERROR: Swap usage is " + $used_percent + "% (>=" + $error_percent + ")!"  
}
elseif($used_percent -ge $warning_percent) {
	$statusid=$statusids.Item("warning")
	$message_str="WARNING: Swap usage is " + $used_percent + "% (>=" + $warning_percent + ")!"  
}
else {
	$statusid=$statusids.Item("ok")
	$message_str="OK: Swap usage is " + $used_percent + "%."  
}
$message_str=$message_str + " " + $info_str
###############################################################################################################################################
print_and_exit "$FS" "$service_name" $statusid "$message_str" "$data_message_str"
###############################################################################################################################################
