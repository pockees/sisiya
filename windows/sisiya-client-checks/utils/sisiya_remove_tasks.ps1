#######################################################################################
#
# This script is used to remove the tasks for SisIYA client checks.
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
#######################################################################################
function deleteScheduledTask
{
	Param (
		[string]$task_name	# the Scheduled Task name
	)

	# query the task schedler
	$command_str = "schtasks /Query | findstr " + $task_name 
	#Write-Host $command_str
	$ret = Invoke-Expression $command_str
	if($?) {
		$command_str = "schtasks /Delete /TN " + $task_name + " /F"
		#Write-Host $command_str
		Invoke-Expression $command_str > $null
	}
}

#######################################################################################
deleteScheduledTask "SisIYA_client_checks"
deleteScheduledTask "SisIYA_client_update"
deleteScheduledTask "SisIYA_eventlog_isuptodate" 
deleteScheduledTask "windows_update"
