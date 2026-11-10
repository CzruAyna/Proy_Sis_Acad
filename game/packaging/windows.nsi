; SPDX-License-Identifier: GPL-3.0-or-later
Unicode true
RequestExecutionLevel user
!include "MUI2.nsh"
!include "x64.nsh"

Name "SIS-INF ${VERSION}"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\Programs\SIS-INF"
Icon "${ICON}"
UninstallIcon "${ICON}"
SetCompressor /SOLID zlib

!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\SIS-INF"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\SIS-INF.exe"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

Function .onInit
  ${IfNot} ${IsNativeAMD64}
    MessageBox MB_OK|MB_ICONSTOP "Esta versión de SIS-INF requiere Windows x64." /SD IDOK
    Abort
  ${EndIf}
  SetShellVarContext current
FunctionEnd

Section "SIS-INF"
  SetOutPath "$INSTDIR"
  File "${PAYLOAD}\SIS-INF.exe"
  File "${PAYLOAD}\SIS-INF.pck"
  File "${PAYLOAD}\LICENSE"
  File "${PAYLOAD}\GODOT-NOTICES.txt"
  File "${PAYLOAD}\NSIS-NOTICE.txt"
  File "${PAYLOAD}\LEEME.md"
  File "${PAYLOAD}\fni_osm.json"
  WriteUninstaller "$INSTDIR\Desinstalar.exe"
  CreateShortcut "$SMPROGRAMS\SIS-INF.lnk" "$INSTDIR\SIS-INF.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "SIS-INF"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\SIS-INF.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Desinstalar.exe"'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  SetOutPath "$TEMP"
  StrCpy $0 0
retry_game:
  Delete "$INSTDIR\SIS-INF.exe"
  IfFileExists "$INSTDIR\SIS-INF.exe" 0 remove_package
  IntOp $0 $0 + 1
  IntCmp $0 20 game_locked 0 game_locked
  Sleep 250
  Goto retry_game
game_locked:
  MessageBox MB_OK|MB_ICONEXCLAMATION "Cierra SIS-INF y vuelve a intentar la desinstalación." /SD IDOK
  SetErrorLevel 1
  Abort
remove_package:
  Delete "$SMPROGRAMS\SIS-INF.lnk"
  Delete "$INSTDIR\SIS-INF.pck"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\GODOT-NOTICES.txt"
  Delete "$INSTDIR\NSIS-NOTICE.txt"
  Delete "$INSTDIR\LEEME.md"
  Delete "$INSTDIR\fni_osm.json"
  Delete "$INSTDIR\Desinstalar.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
SectionEnd
