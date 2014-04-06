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
############################################################################################################
$prog_name = $MyInvocation.MyCommand.Name
if ($Args.Length -lt 1) {
	Write-Host "Usage  : " $prog_name " client_conf" 
	Write-Host "Example: " $prog_name " c:\Program Files\conf\SisIYA_Client.ps1" 
	exit
} 

$client_conf_file = $Args[0]
if ([System.IO.File]::Exists($client_conf_file) -eq $False) {
	Write-Host $prog_name ": SisIYA client configurations file " $client_conf_file " does not exist!"
	exit
}

### include the SisIYA client configurations file
. $conf_file
if ([System.IO.File]::Exists($local_conf_file) -eq $True) {
	### include the SisIYA client local configurations file
	. $local_conf_file 
}

if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions

### check the tmp directory
if([System.IO.Directory]::Exists($sisiya_tmp_dir) -eq $False) {
	Write-Output "SisIYA tmp directory " $sisiya_tmp_dir " does not exist!" | eventlog_error
	exit
}

### check for SISIYA_UPDATE_SERVER
if(! $SISIYA_UPDATE_SERVER) {
	Write-Output "Error : SISIYA_UPDATE_SERVER is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
### check for SISIYA_PACKAGE_NAME
if(! $SISIYA_PACKAGE_NAME) {
	Write-Output "Error : SISIYA_PACKAGE_NAME is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
### check for SISIYA_PACKAGES_DIR
if(! $SISIYA_PACKAGES_DIR) {
	Write-Output "Error : SISIYA_PACKAGES_DIR is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
### check for SISIYA_VERSIONS_XML_FILE
if(! $SISIYA_VERSIONS_XML_FILE) {
	Write-Output "Error : SISIYA_VERSIONS_XML_FILE is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
############################################################################################################
############################################################################################################
############################################################################################################
#Write-Host "SISIYA_UPDATE_SERVER=" $SISIYA_UPDATE_SERVER "SISIYA_PACKAGE_NAME=" $SISIYA_PACKAGE_NAME "SISIYA_PACKAGES_DIR=" $SISIYA_PACKAGES_DIR "SISIYA_VERSIONS_XML_FILE=" $SISIYA_VERSIONS_XML_FILE

$url_str="http://" + $SISIYA_UPDATE_SERVER + $SISIYA_PACKAGES_DIR + "/" + $SISIYA_VERSIONS_XML_FILE
[System.Xml.XmlDocument] $xd = new-object System.Xml.XmlDocument
sisiya_Try {
	#Write-Host "Trying to download..."
	$xd.Load($url_str) 
} -Catch {
	Write-Output "Error occured during download of " $url_str " Error:" $_ | eventlog_error
	exit
}	# -Finally {
	#   * if a finally clause is included, it's statements are executed after all other try-catch processing is complete
	#   * the finally clause executes wether or not an exception is thrown or a break or continue are encountered 
	#	Write-Host "Clean up and exit"
	#}

$nodes = $xd.packages.package

foreach ($p in $nodes) {
	$package_name = $p.name
	#write-host "package_name" $package_name 
	if($package_name -eq $SISIYA_PACKAGE_NAME) {
		$installed_version = getInstalledVersion
		#write-host "BULDUM: package_name" $package_name 
		$package_version = $p.version
		$package_file = $p.file
		write-host "Installed version: [${installed_version}] package version: [${package_version}] file: [${package_file}]"
		if($package_version.CompareTo($installed_version) -eq 0) {
			Write-Output "Installed version: [${installed_version}] is the same as package version: [${package_version}]." | eventlog_info
			break
		}
		$url_str = "http://" + $SISIYA_UPDATE_SERVER + $SISIYA_PACKAGES_DIR + "/" + $package_file
		$installer_prog = $sisiya_tmp_dir + "/install.exe"
		$x=downloadFile $url_str $installer_prog
		if ($x -eq $False) {
			Write-Output "Could not download $url_str" | eventlog_error
			exit
		}
		### now update the software
		#Write-Host "Executing : " $installer_prog "..."

		#& $installer_prog /S
		sisiya_Try {
			$p = [Diagnostics.Process]::Start($installer_prog,'/S')
			$p.WaitForExit()
		} -Catch { 
			Write-Host "Could not install the software!" 
		}

		#Write-Host "Executing : " $installer_prog "...OK"
		Write-Output "Updated $SISIYA_PACKAGE_NAME to version $package_version" | eventlog_info
		$version_file = $sisiya_tmp_dir + "\version.txt"
		Write-Output "$package_version" > $version_file
		exit
	}
}
Write-Output "No need to update $SISIYA_PACKAGE_NAME" | eventlog_info
