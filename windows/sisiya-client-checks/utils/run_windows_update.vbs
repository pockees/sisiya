'######################################################################################
'
' This VB script is used to launch windows_update.ps1, so that its window does not show up.
' Run this script with the following command: wscript run_sisiya_all_ps1.vbs
'
'    Copyright (C) 2003 - 2014  Erdal Mutlu
'
'    This program is free software; you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation; either version 2 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program; if not, write to the Free Software
'    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'
'
'######################################################################################
Dim objShell
Dim objFso

Set objFso=CreateObject("Scripting.FileSystemObject")
Set objShell=CreateObject("Wscript.Shell")
'if Wscript.Arguments.Count <> 1 Then
'	WScript.Echo "You must specify the powershell script to be executed!"
'	WScript.Quit
'End If
 
'prog_str=WScript.Arguments(0)

const HKEY_LOCAL_MACHINE = &H80000002 
strComputer = "." 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv") 
strKeyPath = "SOFTWARE\SisIYA_client_checks"
strValueName = "Path"
' read the SisIYA installation PATH from the registry
oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,path_str 
prog_str=path_str & "\utils\windows_update.ps1"


'wscript.echo "prog_str=" & prog_str
if Not (objFso.FileExists(prog_str)) Then
	WScript.Echo "The powershell script: " & prog_str & " does not exist!"
	WScript.Quit
End If	

' chr(34) is " (double quote)

'check for 64 bit systems and use 32 bit version of powershell
'powershell_prog="powershell.exe"
'powershell32_prog="%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
'powershell64_prog="%SystemRoot%\sysWOW64\WindowsPowerShell\v1.0\powershell.exe"
'if (objFso.FileExists(powershell64_prog)) Then
'	powershell_prog=powershell64_prog
'end if

powershell_prog="c:\windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass"
'WScript.Echo "powershell_prog=" & powershell_prog

strCmd=powershell_prog & " " & chr(34) & "& '" & prog_str & "'" & chr(34)
'strCmd="powershell.exe " & chr(34) & "& '" & prog_str & "'" & chr(34)
' uncomment the next line for debugging
'WScript.Echo strCmd

' use 0 to hide the window
objShell.Run strCmd,0
