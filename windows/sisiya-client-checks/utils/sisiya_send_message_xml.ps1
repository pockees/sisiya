# This script is used to send a message to the SisIYA server.
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
#################################################################################
$prog_name = $MyInvocation.MyCommand.Name
if($Args.Length -ne 6) {
	Write-Host "Usage: " $prog_name " SisIYA_Config.ps1 system_name service_id status_id expire message" 
	Write-Host "statusid: 1-Info, 2-OK, 4-Warning, 8-Error, 16-No Report, 32-Unavailable" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$conf_file	= $Args[0]
$system_name	= $Args[1]
$serviceid	= $Args[2]
$statusid	= $Args[3]
$expire		= $Args[4]
$data_str	= $Args[5]

if([System.IO.File]::Exists($conf_file) -eq $False) {
	Write-Host $prog_name ": SisIYA configuration file " $conf_file " does not exist!"
	exit
}
### get SisIYA client configurations file included
. $conf_file
if ([System.IO.File]::Exists($local_conf_file) -eq $True) {
	### get SisIYA client local configurations file included
	. $local_conf_file 
}

if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions

$timestamp_str = getSisIYA_Timestamp
$message_str='<?xml version="1.0" encoding="utf-8"?><sisiya_messages><timestamp>' + $timestamp_str + "</timestamp><system><name>${system_name}</name><message><serviceid>${serviceid}</serviceid><statusid>${statusid}</statusid><expire>${expire}</expire><data>${data_str}</data></message></system></sisiya_messages>"

Write-Host $SISIYA_SERVER $SISIYA_PORT $message_str

### send the message
$retcode = sendSisIYAMessage $SISIYA_SERVER $SISIYA_PORT "$message_str"
