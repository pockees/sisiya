# This script is used to send messages stored in a file to the SisIYA server.
#
#    Copyright (C) 2003 - 2010 Erdal Mutlu
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
#
Write-Output '<?xml version="1.0" encoding="utf-8"?>'	| Out-File -filepath $tmp_file -append
Write-Output '<sisiya_messages>' 			| Out-File -filepath $tmp_file -append
Write-Output "<timestamp>${timestamp_str}</timestamp>"	| Out-File -filepath $tmp_file -append
#get-content $messages_file

# get uniq system names in an array
$system_names=$(foreach ($line in Get-Content $messages_file) { $line.split(" ")[0]}) | sort | get-unique
#Write-Host "System names: " $system_names
#write-host "count=" $system_names.count
foreach ($system_name in $system_names)
{
	#	write-host "system_name=" $system_name
	# skip empty system name
	if($system_name.length -eq 0) {
		#	write-host "skipping system=$system_name"
		continue
	}
	#	Write-Output "<system><name>${system_name}</name>" 
	Write-Output "<system><name>${system_name}</name>" | Out-File -filepath $tmp_file -append
	### read, format and write all messages into the tmp_file
	$lines=Get-Content $messages_file | findstr /B $system_name
	#	write-host "lines count=" $lines.count
	for($i=0;$i -lt $lines.Length;$i++) {
		#	Write-Host "SP=$SP i=" $i " line=" $lines[$i]
		$a=$lines[$i].Split()
		$serviceid=$a[1]
		$statusid=$a[2]
		$expire=$a[3]
		$message_str=""
		for($j=4;$j -lt $a.length;$j++) {
			$message_str+=" " + $a[$j]
		}
		#	Write-Host "message_str=$message_str"
		$str="<message><serviceid>${serviceid}</serviceid><statusid>${statusid}</statusid><expire>${expire}</expire><data>${message_str}</data></message>"
		Out-String -inputobject $str | Out-File -filepath $tmp_file -append	
	}
	Write-Output "</system>" | Out-File -filepath $tmp_file -append
}
Write-Output "</sisiya_messages>" | Out-File -filepath $tmp_file -append
#
### copy for use with client only SisIYA viewer application
Copy-Item $tmp_file $sisiya_latest_results -force
### send all messages at once
#write-host "Sending the messages to $SISIYA_SERVER $SISIYA_PORT :"
#Write-Host "Contents of the tmp file:"
#cat $tmp_file
#get-content $tmp_file
#Write-Host "END of Contents of the tmp file:"

#sendSisIYAMessage $SISIYA_SERVER $SISIYA_PORT $tmp_file

$message_str=(Get-Content $tmp_file | out-string) -replace "`r","" -replace "`n",""
### remove the tmp file
Remove-Item $tmp_file

sendSisIYAMessage $SISIYA_SERVER $SISIYA_PORT $message_str

