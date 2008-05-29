;--------------------------------
;Include Modern UI

!include "MUI2.nsh"

;SetCompress off ; Useful to disable compression under development

;--------------------------------
;General

;Name and file
Name "Numpy super installer"
OutFile "numpy-1.1.0-win32-superpack-python2.4.exe"

;Default installation folder
InstallDir "$TEMP"

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING

;--------------------------------
;Pages

;!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
;!insertmacro MUI_PAGE_COMPONENTS
;!insertmacro MUI_PAGE_DIRECTORY
;!insertmacro MUI_PAGE_INSTFILES
  
;!insertmacro MUI_UNPAGE_CONFIRM
;!insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Component Sections

!include 'Sections.nsh'
!include LogicLib.nsh

Var HasSSE2
Var HasSSE3
Var CPUSSE

Section "Core" SecCore

  ;SectionIn RO
  SetOutPath "$INSTDIR"
    
  ;Create uninstaller
  ;WriteUninstaller "$INSTDIR\Uninstall.exe"

  DetailPrint "Install dir for actual installers is $INSTDIR"

  StrCpy $CPUSSE "0"
  CpuCaps::hasSSE2
  Pop $0
  StrCpy $HasSSE2 $0

  CpuCaps::hasSSE3
  Pop $0
  StrCpy $HasSSE3 $0

  ; Debug
  StrCmp $HasSSE2 "Y" include_sse2 no_include_sse2
  include_sse2:
    DetailPrint '"Target CPU handles SSE2"'
    StrCpy $CPUSSE "2"
    goto done_sse2
  no_include_sse2:
    DetailPrint '"Target CPU does NOT handle SSE2"'
    goto done_sse2
  done_sse2:

  StrCmp $HasSSE3 "Y" include_sse3 no_include_sse3
  include_sse3:
    DetailPrint '"Target CPU handles SSE3"'
    StrCpy $CPUSSE "3"
    goto done_sse3
  no_include_sse3:
    DetailPrint '"Target CPU does NOT handle SSE3"'
    goto done_sse3
  done_sse3:
  
  ClearErrors
  
  ; Install files conditionaly on detected cpu 
  ${Switch} $CPUSSE
    ${Case} "3"
      DetailPrint '"Install SSE 3"'
      File "numpy-1.1.0-sse3.exe"
      ExecWait '"$INSTDIR\numpy-1.1.0-sse3.exe"'
      ${Break}
    ${Case} "2"
      DetailPrint '"Install SSE 2"'
      File "numpy-1.1.0-sse2.exe"
      ExecWait '"$INSTDIR\numpy-1.1.0-sse2.exe"'
      ${Break}
   ${Default}
      DetailPrint '"Install NO SSE"'
      File "numpy-1.1.0-nosse.exe"
      ExecWait '"$INSTDIR\numpy-1.1.0-nosse.exe"'
      ${Break}
  ${EndSwitch}
  
  ; Handle errors when executing installers
  IfErrors error no_error
  
  error:
    messageBox MB_OK "Executing numpy installer failed" 
	goto done
  no_error:
    goto done
  done:
    
SectionEnd