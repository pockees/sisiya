; Script generated with the Venis Install Wizard

; Define your application name
!define APPNAME "SisIYAws"
!define APPNAMEANDVERSION "SisIYAws 0.4-24-1"

; Main Install settings
Name "${APPNAMEANDVERSION}"
InstallDir "$PROGRAMFILES\SisIYAws"
InstallDirRegKey HKLM "Software\${APPNAME}" ""
OutFile "sisiyawsinstaller_general-0-4-24-1.exe"

; Modern interface settings
!include "MUI.nsh"

!define MUI_ABORTWARNING
;!define MUI_FINISHPAGE_RUN "$INSTDIR\SisIYAws.exe"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "GPL.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section "SisIYAws" Section1

	; Set Section properties
	SetOverwrite on

	; Set Section Files and Shortcuts
	SetOutPath "$INSTDIR\"
	File "sisiya_client.conf"
	File "Release\SisIYAws.exe"
	SetOutPath "$INSTDIR\systems\server1\"
	File "systems\server1\sisiya_progs.conf"
	File "systems\server1\README.txt"
	File "systems\server1\sisiya_defaults.conf"
	;CreateShortCut "$DESKTOP\SisIYAws.lnk" "$INSTDIR\SisIYAws.exe"
	;CreateDirectory "$SMPROGRAMS\SisIYAws"
	;CreateShortCut "$SMPROGRAMS\SisIYAws\SisIYAws.lnk" "$INSTDIR\SisIYAws.exe"
	;CreateShortCut "$SMPROGRAMS\SisIYAws\Uninstall.lnk" "$INSTDIR\uninstall.exe"

SectionEnd

Section -FinishSection

	WriteRegStr HKLM "Software\${APPNAME}" "" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${Section1} ""
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;Uninstall section
Section Uninstall

	;Remove from registry...
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
	DeleteRegKey HKLM "SOFTWARE\${APPNAME}"

	; Delete self
	Delete "$INSTDIR\uninstall.exe"

	; Delete Shortcuts
	;Delete "$DESKTOP\SisIYAws.lnk"
	;Delete "$SMPROGRAMS\SisIYAws\SisIYAws.lnk"
	;Delete "$SMPROGRAMS\SisIYAws\Uninstall.lnk"

	; Remove the SisIYAws service from the service control manager
	Exec "$INSTDIR\SisIYAws.exe -Install /u"
	
	; Clean up SisIYAws
	Delete "$INSTDIR\SisIYAws.exe"
	Delete "$INSTDIR\sisiya_client.conf"
	Delete "$INSTDIR\systems\apollo\sisiya_progs.conf"
	Delete "$INSTDIR\systems\apollo\README.txt"
	Delete "$INSTDIR\systems\apollo\sisiya_defaults.conf"
	
	; Remove remaining directories
	;RMDir "$SMPROGRAMS\SisIYAws"
	RMDir "$INSTDIR\systems\server1\"
	RMDir "$INSTDIR\systems\"
	RMDir "$INSTDIR\"

SectionEnd

; On initialization
Function .onInit

	!insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;Function un.onInit
;    MessageBox MB_YESNO "This will uninstall. Continue?" IDYES NoAbort
;      Abort ; causes uninstaller to quit.
;    NoAbort:
;			
;FunctionEnd

Function .onInstSuccess
		; Install the SisIYAws service
    Exec "$INSTDIR\SisIYAws.exe -Install"
FunctionEnd

BrandingText "SisIYA Windows Service Client"

; eof
