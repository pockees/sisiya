############################################################################################################
#
#    Copyright (C) 2003 - 2010  Erdal Mutlu
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
$prog_name=$MyInvocation.MyCommand.Name
if($Args.Length -lt 2) {
	Write-Host "Usage: " $prog_name " sisiya_client_conf.ps1 expire" 
	Write-Host "Usage: " $prog_name " sisiya_client_conf.ps1 expire output_file" 
	Write-Host "The expire parameter must be given in minutes."
	exit
} 

$client_conf_file=$Args[0]
$expire=$Args[1]
if([System.IO.File]::Exists($client_conf_file) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Host $prog_name ": SisIYA configuration file " $client_conf_file " does not exist!"
	exit
}
[string]$output_file=""
if($Args.Length -eq 3) {
	$output_file=$Args[2]
}
### get configuration file included
. $client_conf_file 

if([System.IO.File]::Exists($sisiya_common_conf) -eq $False) {
	Write-Output "SisIYA common configurations file " $sisiya_common_conf " does not exist!" | eventlog_error
	exit
}
### get SisIYA common configurations file included
. $sisiya_common_conf 

if([System.IO.File]::Exists($sisiya_functions) -eq $False) {
#if(test-path $client_conf_file -eq $False) {
	Write-Output "SisIYA functions file " $sisiya_functions " does not exist!" | eventlog_error
	exit
}
### get common functions
. $sisiya_functions
### Module configuration file name. It has the same name as the script, because of powershell's include system, but 
### it is located under the $sisiya_base_dir\systems\hostname\conf directory.
$module_conf_file=$sisiya_host_conf_dir + "\" + $prog_name
$data_message_str=''
############################################################################################################
############################################################################################################
###
function getAdditionalInfo()
{
	$info_str=""
	###
	$info_str = getAntivirusInfoForMSForefront
	if($info_str -ne "") {
		return $info_str
	}
	$info_str = getAntivirusInfoForMSSecurityClient
	if($info_str -ne "") {
		return $info_str
	}
	$info_str = getAntivirusInfoForAvira
	if($info_str -ne "") {
		return $info_str
	}
	return $info_str
}
function getAntivirusInfoForMSForefront()
{
	# Namespace
	#EE98922AA7EA8F240A0CC999FC6B44BF
	
	$info_str=""
	$a=Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Forefront\Client Security\1.0\AM" -ErrorAction "SilentlyContinue"
	if(! $a) {
			return ""
	}
	$pupdate=$a.ProductUpdateAvailable
	
	$a=Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Forefront\Client Security\1.0\AM\Signature Updates" 2> $null
	if(! $a) {
		return ""
	}
	$avSignatureVersion=$a.AVSignatureVersion
	$asSignatureVersion=$a.ASSignatureVersion
	$engineVersion=$a.EngineVersion
	$info_str="Engine version $engineVersion Antivirus signature version $avSignatureVersion Antispyware signature version $asSignatureVersion"
#	write-host "pupdate=$pupdate info_str=$info_str"
	if($pupdate -eq "") { ### if($pupdate -eq 0) {
		$info_str+=" No available product update."
	}
	else {
		$info_str+=" This product needs update!"
	}
	$a=Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\EE98922AA7EA8F240A0CC999FC6B44BF\InstallProperties"
	if($a) {
		$info_str=$a.DisplayName + " : Client version " + $a.DisplayVersion + " " + $info_str
	}
	#write-host "info_str=$info_str"
	return $info_str
	
}

function getAntivirusInfoForMSSecurityClient()
{
	$info_str=""
	$a=Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft Antimalware\Signature Updates" 2> $null
	if(! $a) {
		return $info_str
	}
	$info_str="Engine version: " + $a.EngineVersion + " Antivirus signature: " +  $a.AVSignatureVersion 
	$info_str += " Antispyware signature: " +  $a.ASSignatureVersion 
	$info_str += " Network Inspection System Engine: " + $a.NISEngineVersion + " Network Inspection System Signature: " + $a.NISSignatureVersion 

	#write-host "info_str=$info_str"
	return $info_str
	
}

function getAntivirusInfoForAvira()
{
	# Namespace
	#305CA226-D286-468e-B848-2B2E8E697B74
	### 32 bit systems
	$str = ""
	$key_str = "HKLM:\SOFTWARE" + $str + "\Avira\AntiVir Desktop"
	$info_str=""
	$a=Get-ItemProperty "$key_str" -ErrorAction "SilentlyContinue"
	if(! $a) {
		# check the 32 bit software on 64 bit system
		$str = "\Wow6432Node"
		$key_str = "HKLM:\SOFTWARE" + $str + "\Avira\AntiVir Desktop"
		$a=Get-ItemProperty "$key_str" -ErrorAction "SilentlyContinue"
		if(! $a) {
			return $info_str
		}
	}
	$pupdate=$a.ProductUpdateAvailable
	$avSignatureVersion=$a.VdfVersion
	$engineVersion=$a.EngineVersion
	$info_str="Engine version $engineVersion Antivirus signature version $avSignatureVersion"
	#write-host $info_str
	return $info_str
	
}
############################################################################################################

### service id
$serviceid=$serviceid_antivirus
if(! $serviceid_antivirus) {
	Write-Output "Error : serviceid_antivirus is not defined in the SisIYA client configuration file " $client_conf_file "!" | eventlog_error
	exit
}
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
### get antivirus information
$a=Get-WmiObject -NameSpace root\SecurityCenter -Class AntivirusProduct 2> $null
if($a) {
	#$name_str=$a.DisplayName
	#$version_str=$a.VersionNumber
	#$on_access_scanning_enabled=$a.onAccessScanningEnabled

	$info_str=$a.DisplayName + ", version=" + $a.VersionNumber + ", on access scanning enabled=" + $a.onAccessScanningEnabled + "."
	if($a.productUptoDate -eq $False) {
		$statusid=$status_error
		$message_str="ERROR: The antivirus software is not uptodate!"
	}
	else { 
		$statusid=$status_ok
		$message_str="OK: The antivirus software is uptodate."
	}	
	$message_str = $message_str + " " + $info_str
}
else {
	$a=Get-WmiObject -NameSpace "root\SecurityCenter2" -Class AntivirusProduct 2> $null
		
	$statusid=$status_error
	$message_str = "ERROR:"
	$str1 = "not uptodate!"
	$str2 = "disabled!"
	$up2date_status = $False
	$realtime_protection_status = $False
		
	$up2date_array = @("262144", "266240", "393216", "397312")
	$realtime_protectionarray = @("397312", "266240", "266256", "397328" )
	if($up2date_array -contains $a.productState) { 
		$str1 = "uptodate."
		$up2date_status = $True		
	}
	if($realtime_protectionarray -contains $a.productState) {
		$str2 = "enabled."
		$realtime_protection_status = $True 
	}
	if($up2date_status -eq $True -and $realtime_protection_status -eq $True) {
		$statusid=$status_ok
		$message_str = "OK:"
	}
	$message_str +=" " + $a.displayName + " is " + $str1 + " The realtime protection is " + $str2
}
$info_str=getAdditionalInfo
if($info_str -ne "") {
	$message_str += " " + $info_str
}
###############################################################################################################################################
#Write-Host "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire message=$message_str data_message_str=$data_message_str"
if($output_file.Length -eq 0) {
	. $send_message_prog $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
}
else {
	$str="$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	Out-String -inputobject $str | Out-File -filepath $output_file -append
}
###############################################################################################################################################
