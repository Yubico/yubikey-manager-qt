; Version of win-installer.nsi that doesn't sign the uninstaller, 
; to be used by build servers like appveyor.
;
; win-installer.nsi should be considered the source of truth


!include "MUI2.nsh"
!include "nsProcess.nsh"

!define MUI_ICON "../../resources/icons/ykman.ico"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Yubico\Yubikey Manager"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Yubico\Yubikey Manager"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_ABORTWARNING

Var STARTMENU_FOLDER
  
Name "YubiKey Manager"
OutFile "..\..\yubikey-manager-${VERSION}-win.exe"
InstallDir "$PROGRAMFILES\Yubico\YubiKey Manager"
InstallDirRegKey HKLM "Software\Yubico\yubikey-manager" "Install_Dir"
SetCompressor /SOLID lzma
ShowInstDetails show

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Start Menu"
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetShellVarContext all
    SetOutPath "$SMPROGRAMS\$STARTMENU_FOLDER"
    CreateShortCut "YubiKey Manager.lnk" "$INSTDIR\ykman-gui.exe" "" "$INSTDIR\ykman-gui.exe" 0
    CreateShortCut "Uninstall YubiKey Manager.lnk" "$INSTDIR\ykman-uninstall.exe" "" "$INSTDIR\ykman-uninstall.exe" 1
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Kill process" KillProcess
${nsProcess::FindProcess} "ykman-gui.exe" $R0
${If} $R0 == 0
  DetailPrint "YubiKey Manager (CLI) is running. Closing..."
  ${nsProcess::CloseProcess} "ykman-gui.exe" $R0
  Sleep 2000
${EndIf}
${nsProcess::FindProcess} "ykman-gui.exe" $R0
${If} $R0 == 0
  DetailPrint "YubiKey Manager is running. Closing..."
  ${nsProcess::CloseProcess} "ykman-gui.exe" $R0
  Sleep 2000
${EndIf}
 ${nsProcess::Unload}
SectionEnd

Var MYTMP

Section "YubiKey Manager"
  SectionIn RO
  SetOutPath $INSTDIR
  FILE /r "..\..\ykman-gui\release\*"
  WriteRegStr HKLM "Software\Yubico\yubikey-manager" "Install_Dir" "$INSTDIR"
  StrCpy $MYTMP "Software\Microsoft\Windows\CurrentVersion\Uninstall\yubikey-manager"
  WriteRegStr       HKLM $MYTMP "DisplayName"     "YubiKey Manager"
  WriteRegExpandStr HKLM $MYTMP "UninstallString" '"$INSTDIR\ykman-uninstall.exe"'
  WriteRegExpandStr HKLM $MYTMP "InstallLocation" "$INSTDIR"
  WriteRegStr       HKLM $MYTMP "DisplayVersion"  "${VERSION}"
  WriteRegStr       HKLM $MYTMP "Publisher"       "Yubico AB"
  WriteRegStr       HKLM $MYTMP "URLInfoAbout"    "https://www.yubico.com"
  WriteRegDWORD     HKLM $MYTMP "NoModify"        "1"
  WriteRegDWORD     HKLM $MYTMP "NoRepair"        "1"
  
  WriteUninstaller "$INSTDIR\ykman-uninstall.exe"
SectionEnd
  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

Var MUI_TEMP

Section "Uninstall"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\yubikey-manager"
  DeleteRegKey HKLM "Software\Yubico\yubikey-manager"
  ${nsProcess::FindProcess} "ykman.exe" $R0
  ${If} $R0 == 0
    DetailPrint "YubiKey Manager (CLI) is running. Closing..."
    ${nsProcess::CloseProcess} "ykman.exe" $R0
    Sleep 2000
  ${EndIf}
  ${nsProcess::FindProcess} "ykman-gui.exe" $R0
  ${If} $R0 == 0
    DetailPrint "YubiKey Manager (GUI) is running. Closing..."
    ${nsProcess::CloseProcess} "ykman-gui.exe" $R0
    Sleep 2000
  ${EndIf}
  ${nsProcess::Unload}
  RMDir /r "$INSTDIR"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
  SetShellVarContext all
  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall YubiKey Manager.lnk"
  Delete "$SMPROGRAMS\$MUI_TEMP\YubiKey Manager.lnk"
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"

  startMenuDeleteLoop:
    ClearErrors
    RMDir $MUI_TEMP
    GetFullPathName $MUI_TEMP "$MUI_TEMP\.."
    IfErrors startMenuDeleteLoopDone
    StrCmp $MUI_TEMP $SMPROGRAMS startMenuDeleteLoopDone startMenuDeleteLoop
  startMenuDeleteLoopDone:

  DeleteRegKey /ifempty HKCU "Software\Yubico\yubikey-manager"
SectionEnd
