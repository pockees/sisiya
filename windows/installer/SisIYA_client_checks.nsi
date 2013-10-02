;#
;# This file is NSISI install script forr SisIYA for MS Windows.
;#
;#    Copyright (C) 2003 - 2010  Erdal Mutlu
;#
;#    This program is free software; you can redistribute it and/or modify
;#    it under the terms of the GNU General Public License as published by
;#    the Free Software Foundation; either version 2 of the License, or
;#    (at your option) any later version.
;#
;#    This program is distributed in the hope that it will be useful,
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;#    GNU General Public License for more details.
;#
;#    You should have received a copy of the GNU General Public License
;#    along with this program; if not, write to the Free Software
;#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;#
;#
;#################################################################################
;======================================================
; Define your application name
!define APP_NAME "SisIYA_client_checks"
!define SISIYA_RELEASE 1
!define SISIYA_VERSION "0.5"
!define SISIYA_CLIENT_CHECKS_VERSION 1 
!define APP_VERSION "${SISIYA_VERSION}.${SISIYA_CLIENT_CHECKS_VERSION}-${SISIYA_RELEASE}"
!define APP_NAME_AND_VERSION "${APP_NAME}-${APP_VERSION}"
!define SOURCE_DIR "..\sisiya_client_checks"
#!define JAVA_FILE "..\..\src\SisIYASendMessage.class"

;======================================================
; Installer Information

;Name "${APP_NAME_AND_VERSION}"
InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey HKLM "Software\${APP_NAME}" ""
OutFile "${APP_NAME_AND_VERSION}_general.exe"

XPStyle on


RequestExecutionLevel admin

  
;--------------------------------
Page license 	skipIfSilent
Page directory 	skipIfSilent
Page instfiles	skipIfSilent
;--------------------------------

; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Turkish.nlf"
;--------------------------------
Function skipIfSilent
	IfSilent 0 no
		Abort
	no:
FunctionEnd
	
Function .onInit
        # the plugins dir is automatically deleted when the installer exits
        InitPluginsDir
		
	IfSilent +4 0
        File /oname=$PLUGINSDIR\splash.bmp "SisIYA_splash.bmp"
		advsplash::show 1000 600 400 0x04025C $PLUGINSDIR\splash
        Pop $0 

		
	;Language selection dialog

	IfSilent 0 +2
		goto end_of_onInit
	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_TURKISH}
	Push Turkish
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain
	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort
	end_of_onInit:
FunctionEnd

		
;--------------------------------
LicenseLangString myLicenseData ${LANG_ENGLISH} "GPL.txt"
LicenseLangString myLicenseData ${LANG_TURKISH} "GPL_tr.txt"
;--------------------------------

LicenseData $(myLicenseData)

; Set name using the normal interface (Name command)
LangString Name ${LANG_ENGLISH} "SisIYA System Monitoring and Managment Tools"
LangString Name ${LANG_TURKISH} "SisIYA Sistem Ýzleme ve Yönetim Araçlarý"

; Set name using the normal interface (Name command)
;LangString Name ${LANG_ENGLISH} ${APP_NAME}
;LangString Name ${LANG_TURKISH} ${APP_NAME}

Name $(Name)

LangString Sec1Name ${LANG_ENGLISH} "English section #1"
LangString Sec1Name ${LANG_TURKISH} "Turkish section #1"


;======================================================
; Sections
Section "SisIYA" Section1
	; Set Section properties
	SetOverwrite on

	; Set Section Files and Shortcuts
	SetOutPath "$INSTDIR\"
	File "${SOURCE_DIR}\*.*"
	; files for bin directory
	SetOutPath "$INSTDIR\bin\"
	File "${SOURCE_DIR}\bin\*.*"
	;File "${JAVA_FILE}"
	; files for conf directory
	SetOutPath "$INSTDIR\conf\"
	SetOverwrite off
	File "${SOURCE_DIR}\conf\sisiya_client_conf.ps1"
	SetOverwrite on
	File "${SOURCE_DIR}\conf\sisiya_common_conf.ps1"
	; files for common directory
	SetOutPath "$INSTDIR\common\"
	File "${SOURCE_DIR}\common\*.ps1"

	; files for special directory
	SetOutPath "$INSTDIR\special\"
	File "${SOURCE_DIR}\special\*.ps1"

	; files for systems directory
	SetOutPath "$INSTDIR\systems\server1\"
	File "${SOURCE_DIR}\systems\server1\*.*"
	SetOutPath "$INSTDIR\systems\server1\conf"
	File "${SOURCE_DIR}\systems\server1\conf\*.*"
	; tmp directory
	SetOutPath "$INSTDIR\tmp\"
	File "${SOURCE_DIR}\tmp\version.txt"

	;CreateShortCut "$DESKTOP\SisIYA.lnk" "$INSTDIR\SisIYA.exe"
	;CreateDirectory "$SMPROGRAMS\SisIYA"
	;CreateShortCut "$SMPROGRAMS\SisIYA\SisIYA.lnk" "$INSTDIR\SisIYA.exe"
	;CreateShortCut "$SMPROGRAMS\SisIYA\Uninstall.lnk" "$INSTDIR\uninstall.exe"

	; create a registry string for the installation directory
	WriteRegStr HKLM "Software\${APP_NAME}" "Path" "$INSTDIR"
SectionEnd



Section -FinishSection

	WriteRegStr HKLM "Software\${APP_NAME}" "" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

;======================================================
;Uninstall section
Section Uninstall

	;Remove from registry...
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
	DeleteRegKey HKLM "SOFTWARE\${APP_NAME}"

	; Delete self
	Delete "$INSTDIR\uninstall.exe"

	; Delete Shortcuts
	;Delete "$DESKTOP\SisIYA.lnk"
	;Delete "$SMPROGRAMS\SisIYA\SisIYA.lnk"
	;Delete "$SMPROGRAMS\SisIYA\Uninstall.lnk"

	; delete tasks from the scheduler
	Exec "powershell -command $\"& $INSTDIR\bin\sisiya_remove_tasks.ps1$\""
	
	; Clean up SisIYA
	;Delete "$INSTDIR\sisiya_client_conf.ps1"
	;Delete "$INSTDIR\README.txt"
	Delete "$INSTDIR\*.*"
	Delete "$INSTDIR\bin\*.*"
	Delete "$INSTDIR\conf\*.*"
	Delete "$INSTDIR\common\*.*"
	Delete "$INSTDIR\special\*.*"
	Delete "$INSTDIR\systems\server1\conf\*.*"
	Delete "$INSTDIR\systems\server1\*.*"
	Delete "$INSTDIR\tmp\*.*"
	
	; Remove remaining directories
	RMDir "$INSTDIR\bin"
	RMDir "$INSTDIR\common"
	RMDir "$INSTDIR\conf"
	RMDir "$INSTDIR\special"
	RMDir "$INSTDIR\systems\server1\conf"
	RMDir "$INSTDIR\systems\server1"
	RMDir "$INSTDIR\systems"
	RMDir "$INSTDIR\tmp"
	RMDir "$INSTDIR\"

SectionEnd

; On initialization


Function .onInstSuccess
	;# put create task into the scheduler
	;# Exec "powershell -command $\"& {Set-ExecutionPolicy Unrestricted}$\""
	ExecWait "powershell -command $\"& $INSTDIR\bin\sisiya_set_execution_policy.ps1$\""
	ExecWait "powershell -command $\"& $INSTDIR\bin\sisiya_create_tasks.ps1$\""
FunctionEnd

; eof
