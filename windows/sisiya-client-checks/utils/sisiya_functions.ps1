# This script contains commonly used functions.
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
function sisiya_Try
{
    param
    (
        [ScriptBlock]$Command = $(throw "The parameter -Command is required."),
        [ScriptBlock]$Catch   = { throw $_ },
        [ScriptBlock]$Finally = {}
    )
   
    & {
        $local:ErrorActionPreference = "SilentlyContinue"
       
        trap
        {
            trap
            {
                & {
                    trap { throw $_ }
                    &$Finally
                }
               
                throw $_
            }
           
            $_ | & { &$Catch }
        }
       
        &$Command
    }

    & {
        trap { throw $_ }
        &$Finally
    }
}

#################################################################################
### Extract days, hours and minutes from a string with the following format :
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) If the value is of the form hh:mm, then it is hh hours mm is minutes.
function extractDaysHoursMinutes
{
	Param ([string]$d_str)

	$s=$d_str.Split(":")
	$time_days=0
	$time_hours=0
	$time_minutes=0

	if($s.Length -eq 1) {
		$time_days=$s[0]
	}
	elseif($s.Length -eq 2) {
		$time_hours=$s[0]
		$time_minutes=$s[1]
	}
	elseif($s.Length -eq 3) {
		$time_days=$s[0]
		$time_hours=$s[1]
		$time_minutes=$s[2]
	}
	
	Write-Output $time_days $time_hours $time_minutes
}

### Returns a string formed of day,hour,minute
function formatDateTime
{
	Param (
		[int]$d, 
		[int]$h, 
		[int]$m
	)
	[string]$str=""
	if($d -ne 0) {
		$str=$d.toString() + " day"
		if($d -gt 1) {
			$str=$str + "s"
		}
	}
	if($h -ne 0) {
		if($str.Length -eq 0) {
			$str=$h.toString() + " hour"
		}
		else {
			$str=$str + " " + $h.toString() + " hour"
		}
		if($h -ne 1) {
			$str=$str + "s"
		}          
	}
        if($m -ne 0) {
                if($str.Length -eq 0) {
			$str=$m.toString() +" minute"
		}
                else {
			$str=$str + " " + $m.toString() +" minute"
                }
		if($m -gt 1) {
			$str=$str + "s"
		}
	}
        Write-Output $str
}

### Returns a string formed of day,hour,minute
function formatDateTime2
{
	Param ([string]$d_str)

	$times=extractDaysHoursMinutes $d_str
	$str=formatDateTime $times[0] $times[1] $times[2]
	Write-Output $str
}


### Calculate time in minutes. Converts days, hours and minutes to minutes
function getTimeInMinutes
{
	Param ([string]$d_str)

	$times=extractDaysHoursMinutes $d_str	
	$time_in_minutes=[int]$times[0] * 1440 + [int]$times[1] * 60 + [int]$times[2]
	Write-Output $time_in_minutes
}

### Outputs system information.
function getSystemInfo
{
	$a=Get-WmiObject -query "select * from Win32_ComputerSystem"
	$b=Get-WmiObject -query "select * from Win32_OperatingSystem"
	$c = Get-WMIObject "Win32_BIOS"
	
	Write-Output "OS:"$b.Caption", Service Pack:"  $b.CSDVersion ", Model: " $a.Model ", Manufacturer:" $a.Manufacturer ", System Type:" $a.SystemType ",BIOS: " $c.SMBIOSBIOSVersion " " $c.Version
}

function getIPInfo()
{
	Param ([string]$Computer)

	$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | ? {$_.IPEnabled}
	$ip_static_address_str = ""
	$ip_dhcp_address_str = ""
	foreach ($Network in $Networks) {
		$IPAddress = $Network.IpAddress[0]
		$SubnetMask = $Network.IPSubnet[0]
		$DefaultGateway = $Network.DefaultIPGateway
		$DNSServers  = $Network.DNSServerSearchOrder
		$IsDHCPEnabled = $false
		If($network.DHCPEnabled) {
			$IsDHCPEnabled = $true
			if($ip_dhcp_address_str -eq "") {
				$ip_dhcp_address_str = $IPAddress
			}
			else {
				$ip_dhcp_address_str = $ip_dhcp_address_str + " ," + $IPAddress
			}
		}
		else {
			if($ip_static_address_str -eq "") {
				$ip_static_address_str = $IPAddress
			}
			else {
				$ip_static_address_str = $ip_static_address_str + " ," + $IPAddress
			}
		}
		
	}
	$str = ""
	if($ip_static_address_str -ne "") {
		$str = "Static: " + $ip_static_address_str
	}
	if($ip_dhcp_address_str -ne "") {
		$str = $str + " DHCP: " + $ip_dhcp_address_str
	}
	Write-Output $str 
}

### Outputs the installed SisIYA client version
function getInstalledVersion()
{
	$version_file = $tmp_dir + "\version.txt"
	if([System.IO.File]::Exists($version_file) -eq $False) {
		Write-Output ""
	}
	$str = get-content $version_file
	Write-Output $str
}

function downloadFile()
{
	Param([string]$url, [string]$path)

	if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) {
  		$path = Join-Path $pwd (Split-Path -leaf $path)
	}

	#Downloading [$url]`nSaving at [$path]"

	$client = new-object System.Net.WebClient
	$policy = new-object System.Net.Cache.RequestCachePolicy("BypassCache")
	$client.CachePolicy=$policy
	sisiya_Try {
		$client.DownloadFile($url,$path)
	} -Catch {
		Write-Output "downloadFile: Error occured during download of " $url_str " Error:" $_ | eventlog_error
		return $False
	}
	return $True

#	trap [Exception] {
#		Write-Output "downloadFile: Caught exception! Type:" $_.Exception.GetType().FullName " Message:" $_.Exception.Message | eventlog_error
#		return $false 
#	}
#	return $true
}

function sisiya_Try
{
    param
    (
        [ScriptBlock]$Command = $(throw "The parameter -Command is required."),
        [ScriptBlock]$Catch   = { throw $_ },
        [ScriptBlock]$Finally = {}
    )
   
    & {
        $local:ErrorActionPreference = "SilentlyContinue"
       
        trap
        {
            trap
            {
                & {
                    trap { throw $_ }
                    &$Finally
                }
               
                throw $_
            }
           
            $_ | & { &$Catch }
        }
       
        &$Command
    }

    & {
        trap { throw $_ }
        &$Finally
    }
}

### Outputs the given number and if it is less than 10, prefixes it with 0.
function getFormatedValue
{
	Param([int]$x)

	if($x -lt 10) {
		Write-Output "0$x"
	}
	else {
		Write-Output "$x"
	}
}

### This is YYYYMMDDHHMMSS formated timestamp, which is used in the SisIYA messages.
function getSisIYA_Timestamp
{
	$now=Get-Date
	[string]$year_str=$now.Year
	[string]$month_str=getFormatedValue $now.Month
#	if($now.Month -lt 10) { $month_str="0$month_str" }
	$day_str=getFormatedValue $now.Day
#	if($now.Day -lt 10) { $day_str="0$day_str" }
	$hour_str=getFormatedValue $now.Hour
#	if($now.hour -lt 10) { $hour_str="0$hour_str" }
	$minute_str=getFormatedValue $now.Minute
#	if($now.Minute -lt 10) { $minute_str="0$minute_str" }
	$second_str=getFormatedValue $now.Second
#	if($now.Second -lt 10) { $second_str="0$second_str" }

	$str=$year_str + $month_str + $day_str + $hour_str + $minute_str + $second_str
	Write-Output $str
}

function makeTempFile
{
	$random_file_name=[System.IO.Path]::GetRandomFileName()
	$file_name=$sisiya_tmp_dir + "\" + $random_file_name
	set-content -Path ($file_name) -Value ($null)
	Write-Output $file_name
}

### send SisIYA messages from a file to the SisIYA server
function sendSisIYAMessage
{
	Param (
		[string]$sisiya_server,	# the SisIYA server name or IP
		[int]$sisiya_port,	# the SisIYA server's port
		[string]$msg_str	# formated SisIYA message
	)

	#	Write-Host $my_prog "sendSisIYAMessage: msg_str=" $msg_str
	### get a TCP/IP socket
	$socket = New-Object System.Net.Sockets.TcpClient($sisiya_server, $sisiya_port)
	if ($socekt.Connected -eq $False) {
		Write-Host "Error connecting to SisIYA server " $sisiya_server " at port " $sisiya_port "!"
		Write-Host "Could not connect TCP/IP socket!"
		return $false
	}
	### get stream
	$stream = $socket.GetStream()
	if (! $stream) {
		Write-Host "Error connecting to SisIYA server " $sisiya_server " at port " $sisiya_port "!"
		Write-Host "Could not create stream from the TCP/IP socket!"
		return $false
	}
	### get a writer stream
	$writer = new-object System.IO.StreamWriter($stream)
	if (! $writer) {
		Write-Host "Error connecting to SisIYA server " $sisiya_server " at port " $sisiya_port "!"
		Write-Host "Could not create writer from stream writer!"
		return $false
	}
	#	$msg_str=$msg_str + [char]10
	#	Write-Host $my_prog "sendSisIYAMessage: msg_str=[" $msg_str "]"
	### change the default 'r'n (\r\n) to 'n (\n)
	$writer.NewLine=[char]10
	if ([System.IO.File]::Exists($msg_str) -eq $True) {
		$lines=Get-Content $msg_str 
		for ($i=0; $i -lt $lines.Length; $i++) {
			### skip empty lines
			if ($lines[$i].Length -eq 0) {
				continue
			}
			$str=$lines[$i]
			$writer.Write($str)
		}
	}
	else {
		### write the message
		$writer.Write($msg_str)
	}	
	$writer.Flush()
	$writer.Close()
	$stream.Close()
	$socket.Close()
	return $true
}

### checks and adds MS Exchange management shell capabilities
function addMSExcangeSupport
{
	$b=Get-PSSnapin| where {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.Admin"}
	if(!$b) {
		Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
	}
}
