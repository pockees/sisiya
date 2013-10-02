#
# This file is the config for SisIYA check programs.
#
#    Copyright (C) 2003  Erdal Mutlu
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
	$a=Get-ItemProperty $sisiya_registry_key
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
		$event_error=[System.Diagnostics.EventLogEntryType]::Error
		$str=$MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str=$str + " " + $_
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
		$event_warning=[System.Diagnostics.EventLogEntryType]::Warning
		$str=$MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str=$str + " " + $_
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
		$event_info=[System.Diagnostics.EventLogEntryType]::Information
		$str=$MyInvocation.ScriptName + ": " + $msg_str
	}
	Process {
		if($_) {
			$str=$str + " " + $_
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
$SISIYA_SERVER="127.0.0.1"
### SisIYA server port on which the SisIYA daemon is listenening 
$SISIYA_PORT=8888
### SisIYA update server
$SISIYA_UPDATE_SERVER="www.sisiya.net"
### SisIYA packages directory
$SISIYA_PACKAGES_DIR="/packages"
### Package name
$SISIYA_PACKAGE_NAME="SisIYA_client_checks_MSWindows"
### Versions XML file
$SISIYA_VERSIONS_XML_FILE="versions.xml"
#################################################################################
### This is the system name in SisIYA for this client
$sisiya_hostname=hostname
###
### Event Log definitions
$event_log=new-object System.Diagnostics.EventLog("Application")
$event_log.Source="SisIYA_client_checks"
#
#$sisiya_base_dir is defined via the getPathFromRegistry function. ###$sisiya_base_dir="c:\Program Files\SisIYA_client_checks"
$sisiya_registry_key="HKLM:\SOFTWARE\SisIYA_client_checks"
$sisiya_base_dir=getPathFromRegistry
$sisiya_conf_dir=$sisiya_base_dir + "\conf"
$sisiya_common_conf=$sisiya_conf_dir + "\sisiya_common_conf.ps1"
