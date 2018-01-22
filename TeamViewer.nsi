; DiaTeamViewer.nsi
;
; NSIS 3.0b1
;--------------------------------

!include LogicLib.nsh
!include WinMessages.nsh
!include x64.nsh

!define ConfigurationID asdf ;Put TeamViewer config ID here
!define APItoken 13371337-ASDFdSAsDFdSaf ;Put TeamViewer API token here

 
!macro ExecShellWait verb app param workdir show exitoutvar ;only app and show must be != "", every thing else is optional
#define SEE_MASK_NOCLOSEPROCESS 0x40 
System::Store S
System::Call '*(&i60)i.r0'
System::Call '*$0(i 60,i 0x40,i $hwndparent,t "${verb}",t $\'${app}$\',t $\'${param}$\',t "${workdir}",i ${show})i.r0'
System::Call 'shell32::ShellExecuteEx(ir0)i.r1 ?e'
${If} $1 <> 0
	System::Call '*$0(is,i,i,i,i,i,i,i,i,i,i,i,i,i,i.r1)' ;stack value not really used, just a fancy pop ;)
	System::Call 'kernel32::WaitForSingleObject(ir1,i-1)'
	System::Call 'kernel32::GetExitCodeProcess(ir1,*i.s)'
	System::Call 'kernel32::CloseHandle(ir1)'
${EndIf}
System::Free $0
!if "${exitoutvar}" == ""
	pop $0
!endif
System::Store L
!if "${exitoutvar}" != ""
	pop ${exitoutvar}
!endif
!macroend

; The name of the installer
Name "Dialect TeamViewer"

; The file to write
OutFile "DialectTV.exe"

; The default installation directory
InstallDir $TEMP\DiaTV

; The text to prompt the user to enter a directory
;DirText "Välkommen till Dialect Service!"

;--------------------------------

Section /o "optional"
SectionEnd

; The stuff to install
Section "" ;No components page, name is not important

; Set output path to the installation directory.
SetOutPath $INSTDIR

; Put file there
File "TeamViewer_Host-idc${ConfigurationID}.msi"
File "TeamViewer_Settings.reg"
File "CustomSettings.reg"
File "TeamViewer_Assignment.exe"

DetailPrint "Importing custom TeamViewer settings"
!insertmacro ExecShellWait "open" "regedit" "/s $INSTDIR\CustomSettings.reg" "" "" ""
DetailPrint "Installing TeamViewer"
!insertmacro ExecShellWait "open" "msiexec" "/i $INSTDIR\TeamViewer_Host-idc${ConfigurationID}.msi /quiet /norestart" "" "" ""

DetailPrint "Starting TeamViewer and assigning host to account"
${If} ${RunningX64}
    ExecShell "open" "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
    !insertmacro ExecShellWait "open" "$INSTDIR\TeamViewer_Assignment.exe" "-apitoken ${APItoken} -datafile $\"C:\Program Files (x86)\TeamViewer\AssignmentData.json$\"" "" "" ""
${Else}
    ExecShell "open" "C:\Program Files\TeamViewer\TeamViewer.exe"
    !insertmacro ExecShellWait "open" "$INSTDIR\TeamViewer_Assignment.exe" "-apitoken ${APItoken} -datafile $\"C:\Program Files\TeamViewer\AssignmentData.json$\"" "" "" ""
${EndIf} 

SetAutoClose true

SectionEnd ; end the section