#
# This file is the config for SisIYA check programs.
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
function getPathFromRegistry
{
	$a = Get-ItemProperty $sisiya_registry_key
	if($a) {
		return $a.Path
	}
	else {
		Write-Output "Error: Could not get Path from " $sisiya_registry_key " registry!" | eventlog_error
		exit
	}
}

function eventlog_error()
{
	Param([string]$msg_str)

	Begin {
		$event_error = [System.Diagnostics.EventLogEntryType]::Error
		$str = $MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str = $str + " " + $_
		}
	}
	End {
		### write to Eventlog
		$event_log.WriteEntry($str,$event_error)
		### write to the console
		Write-Host $str
	}
}

function eventlog_warning()
{
	Param([string]$msg_str)

	Begin {
		$event_warning = [System.Diagnostics.EventLogEntryType]::Warning
		$str = $MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str = $str + " " + $_
		}
	}
	End {
		### write to Eventlog
		$event_log.WriteEntry($str,$event_warning)
		### write to the console
		Write-Host $str
	}
}

function eventlog_info()
{
	Param([string]$msg_str)

	Begin {
		$event_info = [System.Diagnostics.EventLogEntryType]::Information
		$str = $MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str = $str + " " + $_
		}
	}
	End {
		### write to Eventlog
		$event_log.WriteEntry($str,$event_info)
		### write to the console
		Write-Host $str
	}
}
#################################################################################
### SisIYA Server's name or IP address
$SISIYA_SERVER = "127.0.0.1"
### SisIYA server port on which the SisIYA daemon is listenening 
$SISIYA_PORT = 8888
#################################################################################
### SisIYA update server configuration
#################################################################################
$SISIYA_UPDATE_SERVER	= "www.sisiya.org"
### SisIYA packages directory
$SISIYA_PACKAGES_DIR	= "/packages"
### Package name
$SISIYA_PACKAGE_NAME	= "SisIYA_client_checks_MSWindows"
### Versions XML file
$SISIYA_VERSIONS_XML_FILE = "versions.xml"
#################################################################################
### This is the system name in SisIYA for this client
$sisiya_hostname = hostname
###
### Event Log definitions
$event_log		= new-object System.Diagnostics.EventLog("Application")
$event_log.Source	= "SisIYA_client_checks"
#
#$sisiya_base_dir is defined via the getPathFromRegistry function. ###$sisiya_base_dir = "c:\Program Files\SisIYA_client_checks"
$sisiya_osname		= "Windows"
$sisiya_registry_key	= "HKLM:\SOFTWARE\SisIYA_client_checks"
$sisiya_base_dir	= getPathFromRegistry
$sisiya_conf_dir	= $sisiya_base_dir + "\conf"
$sisiya_common_conf	= $sisiya_conf_dir + "\sisiya_common_conf.ps1"
$sisiya_tmp_dir		= $sisiya_base_dir + "\tmp"
$sisiya_scripts_dir 	= $sisiya_base_dir + "\scripts"
$sisiya_utils_dir 	= $sisiya_base_dir + "\utils"
$send_message_prog 	= $sisiya_utils_dir + "\sisiya_send_message_xml.ps1"
$send_message2_prog 	= $sisiya_utils_dir + "\sisiya_send_message2_xml.ps1"
$sisiya_functions 	= $sisiya_utils_dir + "\sisiya_functions.ps1"
$sisiya_latest_results 	= $sisiya_tmp_dir + "\latest_results.txt"
#################################################################################
### status ids
$statusid = @{
	'info'		= 1;	# 2^0
	'ok'		= 2;	# 2^1
	'warning'	= 4;	# 2^2
	'error'		= 8;	# 2^3
	'noreport'	= 16;	# 2^4
	'unavailable'	= 32;	# 2^5
	'mwarning'	= 64;	# 2^6
	'merror'	= 128;	# 2^7
	'mnoreport'	= 256;	# 2^8
	'munavailable'	= 512;	# 2^9
}
#################################################################################
### service ids, these IDs must be identical with IDs in the SisIYA database
$serviceids = @{
	'system'			= 0;
	'filesystem'			= 1;
	'cpu'				= 2;
	'swap'				= 3;
	'load'				= 4;
	'smtp'				= 5;
	'smb'				= 6;
	'nmb'				= 7;
	'postgresql'			= 8;
	'mysql'				= 9;
	'oracle'			= 10;
	'imap'				= 11;
	'pop3'				= 12;
	'lotus'				= 13;
	'printer'			= 14;
	'ftp'				= 15;
	'squid'				= 16;
	'dns'				= 17;
	'nfs'				= 18;
	'dhcpd'				= 19;
	'httpd'				= 20;
	'httpsd'			= 21;
	'ping'				= 22;
	'telnet'			= 23;
	'postfix'			= 24;
	'xinetd'			= 25;
	'sshd'				= 26;
	'xfs'				= 27;
	'kdm'				= 28;
	'portmap'			= 29;
	'atalkd'			= 30;
	'afpd'				= 31;
	'papd'				= 32;
	'ram'				= 33;
	'nmbd'				= 34;
	'solstice_disksuite'		= 35;
	'rpcstatd'			= 36;
	'rpcrquotad'			= 37;
	'rpcmountd'			= 38;
	'nfsd'				= 39;
	'lockd'				= 40;
	'rpciod'			= 41;
	'slapd'				= 42;
	'sun_cluster'			= 43;
	'inetd'				= 44;
	'users'				= 45;
	'veritas_volume_manager'	= 46;
	'netstat'			= 47;
	'progs'				= 48;
	'progs_count'			= 49;
	'ssh_attack'			= 50;
	'oracle_tablespace'		= 51;
	'domino_webaccount'		= 52;
	'netbackup_jobs'		= 53;
	'netbackup_debug'		= 54;
	'netbackup_drives'		= 55;
	'netbackup_clients'		= 56;
	'netbackup_library'		= 57;
	'oracle_hitratios'		= 58;
	'netbackup_robots'		= 59;
	'ups_battery'			= 60;
	'temperature'			= 61;
	'ups_status'			= 62;
	'ups_output'			= 63;
	'ups_timeonbattery'		= 64;
	'pdu_output'			= 65;
	'battery'			= 66;
	'netbackup_scratch'		= 67;
	'netbackup_notify'		= 68;
	'printer_pagecounts'		= 69;
	'batchjob_notify'		= 70;
	'netbackup_media'		= 71;
	'daemon_childs'			= 72;
	'dmesg'				= 73;
	'test'				= 74;
	'listening_socket'		= 75;
	'ntpstat'			= 76;
	'ipconntrack'			= 77;
	'mysql_table_status'		= 78;
	'established_connections'	= 79;
	'hddtemp'			= 80;
	'raid'				= 81;
	'fanspeed'			= 82;
	'baan_jobs'			= 83;
	'baan_warehouse'		= 84;
	'lpstat'			= 85;
	'smart'				= 90;
	'mssql'				= 91;
	'linestatus'			= 92;
	'portstatus'			= 93;
	'snmptrap'			= 94;
	'softraid'			= 95;
	'mailq'				= 96;
	'powersupply'			= 97;
	'vmware'			= 98;
	'mswindows_eventlog'		= 99;
	'isuptodate'			= 100;
	'antivirus'			= 101;
	'services'			= 102;
	'brightstore_jobs'		= 103;
	'brightstore_devices'		= 104;
	'brightstore_scratch'		= 105;
	'msexchange_servicehealth'	= 120;
	'msexchange_mapiconnectivity'	= 121;
	'msexchange_mailflow'		= 122;
	'msexchange_mailqueue'		= 123;
	'baan_users'			= 5000;
	'baan_edi'			= 5001;
	'baan_message'			= 5002;
}
