Notes:

- Needs powershell.
- This is done automatically in the install package: For powershell scripts to run, execute the following 
	command in the powershell: Set-ExecutionPlicy Unrestricted
- Schedule a task to every 10 minutes the 
	"c:\WINDOWS\system32\wscript.exe c:\Program Files\SisIYA_client_checks\bin\run_sisiya_all_ps1.vbs"
