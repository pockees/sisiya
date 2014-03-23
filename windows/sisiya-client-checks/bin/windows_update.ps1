############################################################################################################
#
#    Copyright (C) 2010  Erdal Mutlu
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

function getDownloadMessage()
{
	Param([int]$code)

	switch($code) {
		0 { $message_str="Not started" }
		1 { $message_str="In progress" }
		2 { $message_str="Succeeded" }
		3 { $message_str="Secceeded with errors" }
		4 { $message_str="Failed" }
		5 { $message_str="Aborted" }
		default { $message_str="Unknown" }
	}
	return $message_str
}

##################################################################
#Show Windows Updates activity status

$event_log=new-object System.Diagnostics.EventLog("Application")
if($event_log -eq $null) {
	Write-Host "Could not create System.Diagnostics.EventLog object!"
	exit
}
$event_log.Source="windows_update"

$objInstaller=New-Object -com "Microsoft.Update.Installer"
if($objInstaller -eq $null) {
	Write-Output "Could not get a Microsoft.Update.Installer object!" | eventlog_error
	exit
}
if($objInstaller.IsBusy -eq $False) {
	if($objInstaller.RebootRequiredBeforeInstallation -eq $False) {
		$objSession= New-Object -com "Microsoft.Update.SystemInfo"
		if($objSession -eq $null) {
			Write-Output "Could not get a Microsoft.Update.SystemInfo object!" | eventlog_error
			exit
		}
		if($objsession.RebootRequired -eq $True) {
			Write-Output "MS Windows Updates the system needs restart before installation! Exiting..." | eventlog_error
			exit
		}
		else {
			$updateSession=New-Object -com "Microsoft.Update.Session"
			if($updateSession -eq $null) {
				Write-Output "Could not get a Microsoft.Update.Session object!" | eventlog_error
				exit
			}
			$updateSearcher=$updateSession.CreateUpdateSearcher()
			if($updateSearcher -eq $null) {
				Write-Output "Could not create UpdateSearcher from the updateSession object!" | eventlog_error
				exit
			}
			$searchResults=$updateSearcher.Search("IsInstalled=0 and Type='Software' and IsAssigned=1 and IsHidden=0")
			if($searchResults -ne $null -and $searchResults.Updates.Count -gt 0) {
				Write-Output "There are " $searchResults.Updates.Count " updates available!" | eventlog_info
				foreach($Update in $searchResults.Updates) {
					# Add Update to Collection
					$UpdatesCollection=New-Object -ComObject Microsoft.Update.UpdateColl
					if($UpdatesCollection -eq $null) {
						Write-Output "Could not create Microsoft.Update.UpdateColl object!" | eventlog_error
						exit
					}
					# accept the license if there is one
					if($Update.EulaAccepted -eq 0 ) { 
						$Update.AcceptEula() 
					}
					if($UpdatesCollection.Add($Update) -ne 0) {
						Write-Output "Could not add the update to the update collection!" | eventlog_error
						exit
					}
 					#download
					#Write-Host " + Downloading Update $($Update.Title)"
					Write-Output "Downloading Update $($Update.Title)" | eventlog_info
					$UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()
					if($UpdatesDownloader -eq $null) {
						Write-Output "Could not create UpdateDownloader from the update session!" | eventlog_error
						exit
					}
					$UpdatesDownloader.Updates=$UpdatesCollection
					$DownloadResult=$UpdatesDownloader.Download()
					#$message = "   - Download {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
					#
					$x=getDownloadMessage $DownloadResult.ResultCode
					$message="Download result for $($Update.Title) : $x" 
					#Write-Host $message   
					if($DownloadResult.ResultCode -eq 2) {
						Write-Output $message | eventlog_info
					}
					else {
						Write-Output $message | eventlog_error
					}

					# install
					#Write-Host "   - Installing Update"
					Write-Output "Installing Update : $($Update.Title)" | eventlog_info
					$UpdatesInstaller=$UpdateSession.CreateUpdateInstaller()
					if($UpdatesInstaller -eq $null) {
						Write-Output "Could not create update installer from the update session!" | eventlog_error
						exit
					}
					$UpdatesInstaller.Updates=$UpdatesCollection
					$InstallResult=$UpdatesInstaller.Install()
					$x=getDownloadMessage $InstallResult.ResultCode
					$message="Install result for $($Update.Title) : $x"
					#Write-Host $message
					if($InstallResult.ResultCode -eq 2) {
						Write-Output $message | eventlog_info
					}
					else {
						Write-Output $message | eventlog_error
					}
					$needsReboot=$installResult.rebootRequired   
				}
				if($needsReboot) {
					 #shutdown -r 
					Write-Output "Windows update is done. Need reboot to complete the update." | eventlog_info
				}
			}
			else {
				#Write-Host "The system is uptodate."
				Write-Output "The system is uptodate." | eventlog_info
			}
		}


	}
	else {
		#Write-Host "MS Windows Updates reboot is required before installation! Exiting..."
		Write-Output "MS Windows Updates reboot is required before installation! Exiting..." | eventlog_error
	}
}
else {
	#Write-Host "MS Windows Updates is already running! Exiting..." 
	Write-Output "MS Windows Updates is already running! Exiting..." | eventlog_error
}


