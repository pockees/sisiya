# This script is used to send messages stored in a file to the SisIYA server.
#
#    Copyright (C) 2009  Erdal Mutlu
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
if($Args.Length -ne 2) {
	Write-Host "Usage: " $prog_name " sisiya_client_conf.ps1 messages_file" 
	Write-Host "The messages_file contains the messages to be send. Every line contains one message of the format:"
	Write-Host "host_name serviceid statusid expire message_string"
	exit
} 

$sisiya_conf_file=$Args[0]
$messages_file=$Args[1]

foreach($f in $sisiya_conf_file,$messages_file) {
	if([System.IO.File]::Exists($f) -eq $False) {
		Write-Host $prog_name ": File " $f " does not exist!"
		exit
	}
}
### get configuration file included
. $sisiya_conf_file
 
if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
	Write-Host $prog_name ": SisIYA functions file " $sisiya_functions " does not exist!"
	exit
}
### get common functions
. $sisiya_functions


### get current timestamp
$timestamp_str=getSisIYA_Timestamp

### create a tmp file for storing the formated messages
$tmp_file=makeTempFile
#Write-Host "tmp_file=" $tmp_file
### read, format and write all messages into the tmp_file
$lines=Get-Content $messages_file 
[int]$i=0
while($i -lt $lines.Length) {
	### skip empty lines
	if($lines[$i].Length -eq 0) {
		$i=$i+1
		continue
	}
	#Write-Host "i=" $i " line=" $lines[$i]
	$a=$lines[$i].Split($SP)
	$str=$SP + $a[2] + $SP + $a[3] + $SP + $a[1] + $SP + $timestamp_str + $SP + $a[4] + $SP
	[int]$j=5
	while($j -lt $a.Length) {
		$str=$str + " " + $a[$j]
		$j=$j+1
	}
#	Write-Host "str=" $str
	Out-String -inputobject $str | Out-File -filepath $tmp_file -append	
	$i=$i+1
}

#Write-Host "Contents of the tmp file:"
#cat $tmp_file
#Write-Host "END of Contents of the tmp file:"

#
### copy for use with client only SisIYA viewer application
Copy-Item $tmp_file $sisiya_latest_results -force
### send all messages at once
sendSisIYAMessage $SISIYA_SERVER $SISIYA_PORT $tmp_file
### remove the tmp file
Remove-Item $tmp_file
