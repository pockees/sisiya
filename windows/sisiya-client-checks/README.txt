Notes:

- Needs powershell.
- For powershell scripts to run, execute the following 
	command in the powershell (on 64 systems, do not forget to execute the command both on 32 bit ad 64 bit powershell): Set-ExecutionPlicy Unrestricted
- Schedule a task to every 10 minutes the 
	"c:\WINDOWS\system32\wscript.exe c:\Program Files\SisIYA_client_checks\utils\run_sisiya_all_ps1.vbs"
- Schedule a task to every 30 minutes the 
	"c:\WINDOWS\system32\wscript.exe c:\Program Files\SisIYA_client_checks\utils\run_eventlog_isuptodate.vbs"
- Local configurations are in the c:\Program Files\SisIYA_client_checks\conf\SisIYA_Config_local.ps1
