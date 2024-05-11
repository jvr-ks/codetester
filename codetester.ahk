;------------------------------ codetester.ahk ------------------------------
; from: https://autohotkey.com/board/topic/72566-code-tester-test-your-code/
; modified by jvr 2020

#Requires AutoHotkey v1.1+

#NoEnv
#SingleInstance Force

#include, codetesterLib\codetesterLib_SCI.ahk

FileEncoding, UTF-8-RAW

clipboardKeepDefault := 0
clipboardKeep := clipboardKeepDefault

quickHelpVisible := 0

;-------------------------------- read cmdline param --------------------------------
Loop % A_Args.Length() {
  if(eq(A_Args[A_index],"remove")){
    ExitApp
  }
}

SetTitleMatchMode, 2
DetectHiddenWindows, On

wrkDir := A_ScriptDir . "\"

appName := "Codetester"
appnameLower := "codetester"
extension := ".exe"
appVersion := "0.195"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

title := appName . " " . appVersion 

configFileOld := appnameLower . ".ini"
configFile := appnameLower . "_" . A_ComputerName . ".ini"
localConfigDir :=  A_AppData . "\" . appnameLower . "\"
localConfigFile := localConfigDir . configFile

syncAppDataRead()

if (FileExist(configFileOld)){
  msgbox, The old Configuration-file "%configFileOld%" was found, but is ignored!`nUsing "%configFile%" as the Configuration-file now!
}

;---------------------------------- buttons ----------------------------------
buttonWidth := 105
buttonWidthSmall := 66
buttonWidthLarge := 220
buttonHeight := 35

;--------------------------- config default values ---------------------------
; [setup]
ahk1exepathDefault := "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe"
ahk2exepathDefault := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"
localVersionFileDefault := "version.txt"

texteditorpathDefault := "C:\Program Files\Notepad++\notepad++.exe"

; [config]
saveDirDefault := "_saved\"
fontNameDefault := "Segoe UI"
fontsizeDefault := 9
fontControlAreaDefault := "Segoe UI"
fontsizeControlAreaDefault := 9
fontSCIDefault := "Consolas"
fontsizeSCIDefault := 9
fontSCIUnicodeTab := "Consolas"
cutFileEncodingDefault := "UTF-8-RAW" ; cut == code-under-test
disableCodeModificationsDefault := 0
lastSavedNameDefault := "Current file has no name!"
testSelectedCodeHotkeyDefault := "^u"
showDebugAreaDefault := 1
controlAreaAOTDefault := 1
testExternalCode1HotkeyDefault := "F7"
testExternalCode2HotkeyDefault := "F8"

; [directives]
directive1Default := "#SingleInstance Force"
directive2Default := "#Warn"
directive3Default := "#NoEnv"
directive4Default := ""
directive5Default := ""
directive6Default := ""

; [directives2]
directive21Default := "#SingleInstance Force"
directive22Default := "#Warn"
directive23Default := ""
directive24Default := ""
directive25Default := ""
directive26Default := ""

; gui default values:
dpiScaleDefault := 96
dpiScale := dpiScaleDefault

if ((0 + A_ScreenDPI == 0) || (A_ScreenDPI == 96))
  dpiCorrect := 1
else
  dpiCorrect := A_ScreenDPI / dpiScale
  
clientWidthDefault := coordsScreenToApp(A_ScreenWidth * 0.5)
clientHeightDefault := coordsScreenToApp(A_ScreenHeight * 0.5) 

windowPosXDefault := coordsAppToScreen(10) 
windowPosYDefault := coordsAppToScreen(10)

controlAreaXPosDefault := coordsAppToScreen(clientWidthDefault + 10)
controlAreaYPosDefault := coordsAppToScreen(10)

debugAreaXPosDefault := controlAreaXPosDefault + coordsAppToScreen(buttonWidthLarge + 40)
debugAreaYPosDefault := coordsAppToScreen(10)

; config variables:
testSelectedCodeHotkey := testSelectedCodeHotkeyDefault
testExternalCode1Hotkey := testExternalCode1HotkeyDefault
testExternalCode2Hotkey := testExternalCode2HotkeyDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault
texteditorpath := texteditorpathDefault
saveDir := saveDirDefault
fontName := fontNameDefault
fontsize := fontsizeDefault
fontControlArea := fontControlAreaDefault
fontsizeControlArea := fontsizeControlAreaDefault
fontSCI := fontSCIDefault
fontsizeSCI := fontsizeSCIDefault
cutFileEncoding := cutFileEncodingDefault
disableCodeModifications := disableCodeModificationsDefault
lastSavedName := lastSavedNameDefault
showDebugArea := showDebugAreaDefault
controlAreaAOT := controlAreaAOTDefault

maxDirectives := 6
directive1 := directive1Default
directive2 := directive2Default
directive3 := directive3Default
directive4 := directive4Default
directive5 := directive5Default
directive6 := directive6Default

directive21 := directive21Default
directive22 := directive22Default
directive23 := directive23Default
directive24 := directive24Default
directive25 := directive25Default
directive26 := directive26Default

ahk1exepath := ahk1exepathDefault
ahk2exepath := ahk2exepathDefault

; config gui variables:
clientWidth := clientWidthDefault
clientHeight := clientHeightDefault

windowPosX := windowPosXDefault
windowPosY := windowPosYDefault

controlAreaPosX := controlAreaXPosDefault
controlAreaPosY := controlAreaYPosDefault

debugAreaPosX := debugAreaXPosDefault
debugAreaPosY := debugAreaYPosDefault
  

; runtime variables:
mainHwnd := 0
controlAreaHwnd := 0
sciHwnd := 0
hwndControlArea := 0

actualContent := ""
contentIsTemporary := 0
tmpIsOpen := 0
useAhkVersion2 := 0

controlAreaAOT := 1

isUniCodeTable := 0

debugText := ""
debugTextAll := ""
  
widthSCI := 0
heightSCI := 0

saveFile := "__codetester_save"
saveFileExtension := ".ahk.txt"

exchFile := "__codetester_exch"
exch := []
  
server := serverURL . appnameLower . serverURLExtension

sci := {}
sciDebug := {}

showUnicodeTableIsStart := 0
showUnicodeTableIsShown := 0

foundPos := 0

; start global
if (FileExist(configFile)){
  readConfig()
  readGuiData()
} else {
  msgbox, No Config-file found`, using default-values!
}

if (!FileExist("Scintilla.dll")){
  msgbox, SEVERE ERROR file "Scintilla.dll" not found`, exiting %appname%!
  exitApp
}
 
checkDirectories()
 
mainWindow()

if (FileExist("_codetester.txt")){
  f := FileOpen("_codetester.txt","r")
  actualContent  := f.Read()
  f.Close()
  
  sci.clearAll()
    
  sciSetText(actualContent)
    
  preview()
  sci.GrabFocus()
  
  sci.GOTOLINE(sci.GETLINECOUNT())
}

OnMessage(0x44, "center_MsgBox")
OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA


Hotkey, ESC, endTest  


Hotkey, IfWinActive, Codetester
Hotkey, ^s, saveViaHotkey, T1

Hotkey, !Up, showUnicodeTableUp, T1
Hotkey, !Down, showUnicodeTableDown, T1
Hotkey, !Enter, showUnicodeTableStop, T1
Hotkey, F1, showQuickHelp
Hotkey, F2, showClipboardAs_UTF8
Hotkey, F3, showClipboardAs_URI

hotkey, !Up, Off
hotkey, !Down, Off
hotkey, !Enter, Off
hotkey, F1, Off
hotkey, F2, Off
hotkey, F3, Off

Hotkey, ^f, findText

return

;--------------------------------- findText ---------------------------------
findText(){

  msgbox, Sorry, a text search is not available!

  return 
}
;------------------------------ syncAppDataRead ------------------------------
syncAppDataRead(){
  global configFile, localConfigFile
  
  if (!(FileExist(configFile))){
    if ((FileExist(localConfigFile))){
      FileCopy, %localConfigFile%, %configFile%, 1
      msgbox, Copied configuration-data from:`n%localConfigFile% !
    }
  }

  return 
}
;----------------------------- syncAppDataWrite -----------------------------
syncAppDataWrite(){
  global configFile, localConfigDir
  
  if (!(FileExist(localConfigDir))){
    try {
      FileCreateDir, %localConfigDir%
    } catch e {
      msgbox, Could not create directory: %localConfigDir%
    }
  }
  
  if (FileExist(configFile)){
    if ((FileExist(localConfigDir))){
      FileCopy, %configFile%, %localConfigDir%*.*, 1
    }
  }

  return 
}
;----------------------------- checkDirectories -----------------------------
checkDirectories(){
  global saveDir
  
  dir := pathToAbsolut(saveDir)
  if (!FileExist(dir))
    FileCreateDir, %dir%

  return 
}
;------------------------------- saveViaHotkey -------------------------------
saveViaHotkey(){
  global lastSavedName, contentIsTemporary
  
  if (contentIsTemporary){
    msgbox, Cannot save a temporary content via hotkey!
  } else {
    if (lastSavedName != ""){
      saveToLast()
    } else {
      msgbox, Code was not previously saved, use "Save with name" first!
    }
  }
    
  return
}
;----------------------------- coordsScreenToApp -----------------------------
coordsScreenToApp(n){
  global dpiCorrect
  
  r := 0
  if (dpiCorrect > 0)
    r := round(n / dpiCorrect)

  return r
}
;----------------------------- coordsAppToScreen -----------------------------
coordsAppToScreen(n){
  global dpiCorrect

  r := round(n * dpiCorrect)

  return r
}
;--------------------------------- mainWindow ---------------------------------
mainWindow() {
  global mainHwnd, sciHwnd, controlAreaHwnd, windowPosX, windowPosY, clientWidth, clientHeight, widthSCIScale, widthDEBUGScale, heightSCIScale
  global configFile, fontName, fontsize, fontNameDefault, fontsizeDefault
  global fontControlArea, fontsizeControlArea, fontControlAreaDefault, fontsizeControlAreaDefault
  global fontSCI, fontsizeSCI, fontSCIDefault, fontsizeSCIDefault

  global testSelectedCodeHotkey, TempCodeEditHwnd, sci, sciDebug

  global sciX, sciY, widthDEBUG, saveFile, saveFileExtension, saveDir, exchFile, title 

  global dpiCorrect, widthSCI, heightSCI

  global sci, sciDebug
  
  global widthSCIScale, heightSCIScale
  global widthDEBUGScale, controlAreaWidth

  global debugAreaPosX, debugAreaPosY, debugAreaXPosDefault, debugAreaYPosDefault
  global exch1P, exch2P, exch3P
  global DebugText, showDebugArea, controlAreaAOT
  
  global hEnterFindText, enterFindText, theTextToFind, foundPos, searchResult
    
  sciX := 5
  sciY := 2

  calcSciSize()

;---------------------------------- guiMain ----------------------------------
  gui, guiMain:Destroy
  gui, guiMain:New, +Lastfound +OwnDialogs HWNDmainHwnd +Resize, %title%
  
  gui, guiMain:font, s%fontsize%, %fontName%
  
  menu, MainMenuUpdate, add, Check if new version is available, startCheckUpdate
  menu, MainMenuUpdate, add, Start updater, startUpdate
  
  menu, MainMenuFilemanager, add, Filemanager in %saveDir%, openFilemanager
  menu, MainMenuFilemanager, add, Filemanager in .\, openFilemanageHome
  
  menu, MainMenuMake, add, Make exe (64 bit`, .\_codeToExe64.exe), makeExe64
  menu, MainMenuMake, add, Run exe (64 bit`, .\_codeToExe64.exe), runExe64
  menu, MainMenuMake, add, Make exe (32 bit`, .\_codeToExe32.exe), makeExe32
  menu, MainMenuMake, add, Run exe (32 bit`, .\_codeToExe32.exe), runExe32
  menu, MainMenuMake, add, Edit _codeToExe.ahk, editCodeToExe
  menu, MainMenuMake, add, Filemanager in .\, openFilemanageHome
  
  menu, MainMenuAllfiles, add, Open Allfiles, openAllfilesBetter
  menu, MainMenuAllfiles, add, Update Allfiles, runAllfilesBetter
  
  menu, MainMenuHelp, add, Short-help offline,htmlViewerOffline
  menu, MainMenuHelp, add, Short-help online,htmlViewerOnline
  menu, MainMenuHelp, add, README online, htmlViewerOnlineReadme
  menu, MainMenuHelp, add, Open Github,openGithubPage
  
  menu, Mainmenu, add, Config,editConfigFile
  
  menu, Mainmenu, add, Filemanager,:MainMenuFilemanager
  menu, Mainmenu, add, Make EXE,:MainMenuMake
  menu, Mainmenu, add, Update,:MainMenuUpdate
  menu, Mainmenu, add, Allfiles,:MainMenuAllfiles

  menu, Mainmenu, add, ♒ UnicodeTable ext., unicodeTableExt
  menu, Mainmenu, add, ♒ int., selectStartValue
  menu, Mainmenu, add, Help,:MainMenuHelp
  ;menu, Mainmenu, add, Refresh Statusbar, refreshStatusBar
  
  menu, Mainmenu, add,🗙 Exit, exit
  
  gui, guiMain:menu, MainMenu
  
  gui, guiMain:add, StatusBar
  
  gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  
  SB_SetParts(400,300)
  refreshStatusBar()
  
  if(controlAreaAOT)
    controlAreaSetAOT()
  else
    settimer, controlAreaSetAOT, -500
  
;------------------------------------ SCI ------------------------------------
  sci := new scintilla(handle, sciX, sciY, widthSCI, heightSCI, A_Scriptdir "\Scintilla.dll")
  sci.StyleClearAll()
  sci.SetCodePage(65001)
  
  sci.SetMarginWidthN(0, coordsAppToScreen(30)) ; Line number
  ; sci.SetMarginWidthN(1, 20) ; Foldemargin
  
  sci.SetMarginTypeN(0x1, 0x2)

  sci.SetWrapMode(0x0)
  sci.SetCaretLineBack(0xFFFF80)
  sci.SetCaretLineVisible(true)
  sci.SetCaretLineVisibleAlways(true)

  sci.SETINDENTATIONGUIDES(SC_IV_LOOKBOTH)
  
  sci.SETUSETABS(0)
  sci.SETTABWIDTH(4)
  sci.SETINDENT(2)
  sci.SETTABINDENTS(1)
  sci.SETBACKSPACEUNINDENTS(1)
  sci.SETVIEWWS(3)
  sci.SETINDENTATIONGUIDES(4)
  
  sci.StyleSetBold()
  
  setfontSCI := fontSCI
  sci.StyleSetFont(32, setfontSCI)
  sci.StyleSetSize(32, fontsizeSCI)
  
  sci.StyleClearAll()
  
  sciSetText(theCode)
    
  sciHwnd := sci.hwnd

  controlAreaCreate()

  
;--------------------------------- debugArea ---------------------------------
  gui, debugArea:Destroy
  gui, debugArea:new, HWNDhdebugArea +AlwaysOnTop +resize -0x30000 +E0x08000000, Codetester Debug
  gui, debugArea:font, s%fontsizeControlArea%, %fontControlArea%
    
  gui, debugArea:add, Text, xm ym w200 r20 vdebugText,
  
  ; debugArea show
  gui, debugArea:Show, x%debugAreaPosX% y%debugAreaPosY%
  
  if (!showDebugArea)
    gui, debugArea:Hide
    
  sci.GrabFocus()
  
  return
}
;----------------------------- controlAreaCreate -----------------------------
controlAreaCreate(){
  global controlAreaHwnd, fontsizeControlArea, fontControlArea, saveDir
  global controlAreaPosX, controlAreaPosY
  global buttonWidth, buttonWidthSmall, buttonWidthLarge, buttonHeight
  global ButtonRun, ButtonRunSel, ButtonExit, ButtonAOT, ButtonDebugAreaToggle
  global disableCodeModifications
  
  global ButtonShow
  global Button2, Button3, Button4, Button5
  global Button7, Button8, Button9,
  global Button12, Button13, Button14, Button15, Button16, Button17, Button18, Button19, Button20, Button21
  global Button22, Button23, Button24, Button25, Button26, Button27, Button28, Button29, Button30, Button31
  global Button33, Button34, Button35, Button36, Button37, Button38, Button39
  global Button61, Button62, ButtonhotkeyConverter
  
  global showDebugArea, controlAreaAOT
  
  ; Button2, Button3, Button6, Button23, Button61, Button62 not used

  arrow := Chr(0x21A7)
  separatorWidth := buttonWidth * 2 + 10
  
  gui, controlArea:Destroy
  if(controlAreaAOT)
    gui, controlArea:new, HWNDcontrolAreaHwnd -sysMenu +AlwaysOnTop +E0x08000008, Controlarea
  else
    gui, controlArea:new, HWNDcontrolAreaHwnd -sysMenu ,Codetester Control

  gui, controlArea:font, s%fontsizeControlArea%, %fontControlArea%
   
;------------------------------------
  gui, controlArea:add, Button, xm ym w%buttonWidth% vButtonRun GrunButtonOperation, Run
  gui, controlArea:add, Button, x+m yp+0 vButton34 w%buttonWidth% GnewFile, New file
    
  gui, controlArea:add, Button, xm vButtonExit w%buttonWidth%  GexitButtonOperation, 🗙 Exit 
  
  if(controlAreaAOT)
    gui, controlArea:add, Button, x+m yp+0 w%buttonWidth% vButtonAOT gcontrolAreaToggleAOT,✔ AOT
  else
    gui, controlArea:add, Button, x+m yp+0 w%buttonWidth% vButtonAOT gcontrolAreaToggleAOT,☹ AOT
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2
  
  gui, controlArea:add, Text, xm, Save (to "_saved\..." subdirectory):
  
  gui, controlArea:add, Button, xs vButton30 %buttonHeight% w%buttonWidth% gsaveWithName, New name
  
  gui, controlArea:add, Button, x+m yp+0 vButton4 %buttonHeight% w%buttonWidth% gsave, "cS" + DateTime
  
  gui, controlArea:add, Button, xs vButton22 %buttonHeight% w%buttonWidth% gsaveToLast, Last used
  
  gui, controlArea:add, Button, x+m yp+0 vButton31 %buttonHeight% w%buttonWidthSmall%  gsaveToDir, Directory
  
 ;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2 
 
  gui, controlArea:add, Button, xm vButtonShow w%buttonWidth% GshowTmpfileOperation, Show: _tmp.ahk
  gui, controlArea:add, Button, x+m yp+0 vButtonhotkeyConverter w%buttonWidth% GhotkeyConverter, Hotkey converter
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2
  
  saveDirShow := saveDir
  if (StrLen(saveDir) > 10){
    saveDirShow := "… " . SubStr(saveDir,-25,25)
  }
  gui, controlArea:add, Text, xm w%buttonWidthSmall%, Open from:
  gui, controlArea:add, Button, x+m yp+0 vButton20 w%buttonWidthSmall% gloadFileFromSaved, %saveDirShow%
  gui, controlArea:add, Button, x+m yp+0 vButton21 w%buttonWidthSmall% gloadFile,  .\
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2
  
  gui, controlArea:add, Text, xm w%buttonWidthSmall%, Insert:
  gui, controlArea:add, Button, x+m yp+0 vButton33 w%buttonWidth% GinsRequiresAHK2, #Requires AHK2
  gui, controlArea:add, Button, x+m yp+0 vButton39 GinsRequiresAHK1, 1
    
  gui, controlArea:add, Button, xm vButton8 w%buttonWidthSmall%  ginsShowvari, Showvari
  gui, controlArea:add, Button, x+m yp+0 vButton18 w%buttonWidthSmall% GinsMsgbox, Msgbox
  gui, controlArea:add, Button, x+m yp+0 vButton24 w%buttonWidthSmall% GinsExitApp, ExitApp
  
  gui, controlArea:add, Button, xm vButton9 w%buttonWidthLarge% GinsSleepExitApp, Sleep 2000 + exitApp
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2
  
  gui, controlArea:add, Text, xm w%buttonWidthSmall%, Get from:
  gui, controlArea:add, Button, x+m yp+0 vButton35 %buttonHeight% w%buttonWidthSmall% GgetFromNPPP, NP++
  gui, controlArea:add, Button, x+m yp+0 vButton37 %buttonHeight% w%buttonWidthSmall% GgetFromSciTE,  SciTE
  
  gui, controlArea:add, Text, xm w%buttonWidthSmall%, Copy to:
  gui, controlArea:add, Button, x+m yp+0 vButton36 %buttonHeight% w%buttonWidthSmall% GcopyToNPPP, NP++
  gui, controlArea:add, Button, x+m yp+0 vButton38 %buttonHeight% w%buttonWidthSmall% GcopyToSciTE, SciTE
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2
  
  gui, controlArea:add, Button, xm section vButton15 w%buttonWidthSmall%  Gread123, Open 1
  gui, controlArea:add, Button, x+m yp+0 vButton16 w%buttonWidthSmall%  Gread123, Open 2
  gui, controlArea:add, Button, x+m yp+0 vButton17 w%buttonWidthSmall%  Gread123, Open 3
  
  gui, controlArea:add, Button, xm vButton12 w%buttonWidthSmall% Gsave123, Save 1
  gui, controlArea:add, Button, x+m yp+0 vButton13 w%buttonWidthSmall% Gsave123, Save 2
  gui, controlArea:add, Button, x+m yp+0 vButton14 w%buttonWidthSmall% Gsave123, Save 3
  
  gui, controlArea:add, Progress, xm w%buttonWidthSmall% h3 cRed Vexch1P, 0
  gui, controlArea:add, Progress, x+m yp+0 w%buttonWidthSmall% h3 cRed Vexch2P, 0
  gui, controlArea:add, Progress, x+m yp+0 w%buttonWidthSmall% h3 cRed Vexch3P, 0
  
  gui, controlArea:add, Button, xm vButton27 w%buttonWidthSmall% Gexch123, EXCH 1-a
  gui, controlArea:add, Button, x+m yp+0 vButton28 w%buttonWidthSmall% Gexch123, EXCH 1-b
  gui, controlArea:add, Button, x+m yp+0 vButton29 w%buttonWidthSmall% Gexch123, EXCH 1-c
  
;------------------------------------
  gui, controlArea:add, Text, xm w%separatorWidth% 0x7 h2

  gui, controlArea:add, Button, xm vButton7 w%buttonWidth%  Gexit, 🗙 Exit
  if(showDebugArea)
    gui, controlArea:add, Button, x+m yp+0 vButtonDebugAreaToggle w%buttonWidth% GdebugAreaToggle,✔ Debug Area
  else
    gui, controlArea:add, Button, x+m yp+0 vButtonDebugAreaToggle w%buttonWidth% GdebugAreaToggle,☹ Debug Area

;------------------------------------    
  ; checkbox row:
  
  chkCodeMod := disableCodeModifications ? "checked" : ""
  gui, controlArea:add, Checkbox, xm VdisableCodeModifications GdisableCodeModifications %chkCodeMod%, Disable code modifications
  
  ; controlArea show
  gui, controlArea:Show, x%controlAreaPosX% y%controlAreaPosY%
  
  return
}
;------------------------------ guiMainGuiClose ------------------------------
guiMainGuiClose() {
  exit()
  return 1
}
;---------------------------- controlAreaGuiClose ----------------------------
controlAreaGuiClose() {
  exit()
  return
}
;----------------------------- debugAreaGuiClose -----------------------------
debugAreaGuiClose(){
  global configFile, showDebugArea, controlArea, ButtonDebugAreaToggle
  
  showDebugArea := 0
  guicontrol, controlArea:, ButtonDebugAreaToggle,☹ Debug Area
  IniWrite, %showDebugArea%, %configFile%, gui, showDebugArea
  
  return
}
;------------------------------- setUseIndents -------------------------------
setUseIndents(){
  global sci

  sci.SETUSETABS(0)
  sci.SETTABWIDTH(4)
  sci.SETINDENT(2)
  sci.SETTABINDENTS(1)
  sci.SETBACKSPACEUNINDENTS(1)
  sci.SETVIEWWS(3)
  sci.SETINDENTATIONGUIDES(4)
  
  return
}
;-------------------------------- setUseTabs --------------------------------
setUseTabs(){
  global sci

  sci.SETUSETABS(1)
  sci.SETTABWIDTH(8)
  sci.SETINDENT(0)
  sci.SETTABINDENTS(0)
  sci.SETBACKSPACEUNINDENTS(0)
  
  return
}
;------------------------------- debugAreaShow -------------------------------
debugAreaShow(){
 global showDebugArea, ButtonDebugAreaToggle, configFile
 
  if (showDebugArea){
    gui, debugArea:Show
    guicontrol, controlArea:, ButtonDebugAreaToggle,✔ Debug Area
    } else {
    gui, debugArea:Hide
    guicontrol, controlArea:, ButtonDebugAreaToggle,☹ Debug Area
  }
  IniWrite, %showDebugArea%, %configFile%, gui, showDebugArea
}
;------------------------------ debugAreaToggle ------------------------------
debugAreaToggle(){
  global showDebugArea, ButtonDebugAreaToggle
  
  showDebugArea := !showDebugArea
  
  debugAreaShow()

  return
}
;----------------------------- controlAreaToggleAOT -----------------------------
controlAreaToggleAOT(){
  global controlAreaHwnd, controlAreaAOT, ButtonAOT

  controlAreaAOT := !controlAreaAOT
  
  controlAreaSetAOT()
  ; WinSet, Redraw,, ahk_id %controlAreaHwnd%
  controlAreaCreate()
  
  return
}
;----------------------------- controlAreaSetAOT -----------------------------
controlAreaSetAOT(){
  global controlAreaHwnd, controlAreaAOT, ButtonAOT
  
  if (controlAreaAOT){
    WinSet, AlwaysOnTop , On, ahk_id %controlAreaHwnd%
    WinSet, ExStyle, +0x80, ahk_id %controlAreaHwnd%
    guicontrol,, ButtonAOT, AOT ✔
  } else {
    WinSet, AlwaysOnTop , Off, ahk_id %controlAreaHwnd%
    WinSet, ExStyle, -0x80,, ahk_id %controlAreaHwnd%
    guicontrol,, ButtonAOT, AOT ☹
  }
  
  gui, controlArea:show

  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global sciHwnd, widthSCI, heightSCI, clientWidth, clientHeight
  global sci, sciX, sciY

  if (A_EventInfo != 1) {
    ; not minimized
    clientWidth := A_GuiWidth
    clientHeight := A_GuiHeight
    
    calcSciSize()

    WinMove, ahk_id %sciHwnd%,, sciX, sciY, widthSCI, heightSCI
    refreshStatusBar()
  }
  
  return
}

;-------------------------------- calcSciSize --------------------------------
calcSciSize(){
  global widthSCI, heightSCI, clientWidth, clientHeight, dpiCorrect
  global widthSCIScale, heightSCIScale
  global sci, sciX, sciY
  
  sciX := coordsAppToScreen(5)
  sciY := coordsAppToScreen(5)
  
  paddingBottom := 20
  paddingRight := 10

  widthSCI := coordsAppToScreen(clientWidth  - paddingRight)
  heightSCI := coordsAppToScreen(clientHeight - paddingBottom) - sciY

  return
}
;-------------------------------- saveContent --------------------------------
saveContent(savePath){
  global mainHwnd, saveDir, configFile, lastSavedName
  global actualContent, contentIsTemporary
  global exch
  
  if (exch[1] || exch[2] || exch[3]){
    msgbox, ERROR`, a save operation is prohibited`, if EXCH1, EXCH2 or EXCH3 are active!
  } else {
    theCode := ""
    if (contentIsTemporary)
      theCode := actualContent
    else
      theCode := getTextFromSCI()
      
    contentIsTemporary := 0
    
    savePath := pathToAbsolut(saveDir) . lastSavedName
    
    file := FileOpen(savePath,"w")
    file.Write(theCode)
    file.Close()
      
    IniWrite, "%lastSavedName%", %configFile%, config, lastSavedName
    
    showHintColoredRefresh(mainHwnd, "Saved to " . savePath, 3000,1)
  }

  return
}
;------------------------------- saveWithName -------------------------------
saveWithName(){
  global sci, saveDir, configFile, lastSavedName
  global exch
  
  if (exch[1] || exch[2] || exch[3]){
    msgbox, ERROR`, a save operation is prohibited`, if EXCH1, EXCH2 or EXCH3 are active!
  } else {
    InputBox, lastSavedName, Save to named file:, Please enter the name:,,,130,,,,,%lastSavedName%
    
    if (!ErrorLevel && lastSavedName != ""){
      savePath := pathToAbsolut(saveDir) . lastSavedName

      if (FileExist(savePath)){
        MsgBox, 4, , File already exists, overwrite it?
        IfMsgBox, Yes
        {
          FileDelete, %savePath%
          saveContent(lastSavedName)
        }
      } else {
        saveContent(lastSavedName)
      }
    }
  }
  
  return
}
;-------------------------------- saveToDir --------------------------------
saveToDir(){
  global mainHwnd, sci, wrkdir, saveDir, configFile, lastSavedName
  global exch
  
  if (exch[1] || exch[2] || exch[3]){
    msgbox, ERROR`, a save operation is prohibited`, if EXCH1, EXCH2 or EXCH3 are active!
  } else {
    startDir := pathToAbsolut(wrkdir)
    
    FileSelectFolder, savedDirNew , %startDir%, 3, Please select a directory!
    
    if (!ErrorLevel && savedDirNew != ""){
      InputBox, lastSavedName, Save to %savedDirNew%, Please enter the name:,,,130,,,,,%lastSavedName%
      
      if (!ErrorLevel){
        savePath := resolvePath(savedDirNew) . lastSavedName
        if (FileExist(savePath)){
          MsgBox, 4, , File already exists, overwrite it?
          IfMsgBox, No
          {
            return
          } else {
            FileDelete, %savePath%
          }
        }
        saveDir := savedDirNew
        saveContent(savePath)
        showHintColoredRefresh(mainHwnd, "Saved to " . savePath)
      } else {
        msgbox, Not saved !
      }
    } else {
        msgbox, Not saved !
    }
  }
  
  return
}
;----------------------------------- save -----------------------------------
save(){
  global mainHwnd, configFile, sci, lastSavedName, saveDir
  global actualContent, contentIsTemporary
  global exch
  
  if (exch[1] || exch[2] || exch[3]){
    msgbox, ERROR`, a save operation is prohibited`, if EXCH1, EXCH2 or EXCH3 are active!
  } else {
    theCode := ""
    if (contentIsTemporary)
      theCode := actualContent
    else
      theCode := getTextFromSCI()
      
    contentIsTemporary := 0
    
    FormatTime, filename, %A_Now% T8, 'codetesterSource'_yyyy_MM_dd_hh_mm_ss
    
    lastSavedName := filename . ".ahk.txt"
    
    savePath := pathToAbsolut(saveDir) . lastSavedName

    if (FileExist(savePath))
      FileDelete, %savePath%
    
    FileAppend,
      (
%theCode%

    ), %savePath%
    
    IniWrite, "%lastSavedName%", %configFile%, config, lastSavedName
    
    showHintColoredRefresh(mainHwnd, "Saved to " . savePath, 3000,1)
  }
  
  return
}
;-------------------------------- saveToLast --------------------------------
saveToLast(){
  global mainHwnd, sci, lastSavedName, saveDir
  global actualContent, contentIsTemporary
  global exch
  
  if (exch[1] || exch[2] || exch[3]){
    msgbox, ERROR`, a save operation is prohibited`, if EXCH1, EXCH2 or EXCH3 are active!
  } else {
    theCode := ""
    if (contentIsTemporary)
      theCode := actualContent
    else
      theCode := getTextFromSCI()
      
    contentIsTemporary := 0

    if (StrLen(lastSavedName) > 0){
      ; lastSavedName is constructed from date_time
      if (saveDir != ""){
        savePath := pathToAbsolut(saveDir) . lastSavedName

        if (FileExist(savePath))
          FileDelete, %savePath%
        
        FileAppend,
(
%theCode%

), %savePath%
    
        showHintColoredRefresh(mainHwnd, "Saved to " . savePath . " again!")
      } else {
        save()
      }
    } else {
      msgbox, Code was not previously saved, use "Save with name" first!
    }
  }
  
  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  if (r == "#empty!")
    r := ""
    
  return r
}
;-------------------------------- readConfig --------------------------------
readConfig() {
  global saveDir, saveDirDefault, fontName, fontNameDefault, fontsize, fontsizeDefault
  global fontControlArea, fontControlAreaDefault
  global fontsizeControlArea, fontsizeControlAreaDefault
  global fontSCI, fontSCIDefault, fontsizeSCI, fontsizeSCIDefault
  global cutFileEncoding, cutFileEncodingDefault
  global disableCodeModifications, disableCodeModificationsDefault
  global lastSavedName, lastSavedNameDefault
  global testSelectedCodeHotkey, testSelectedCodeHotkeyDefault
  global testExternalCode1Hotkey, testExternalCode1HotkeyDefault, testExternalCode2Hotkey, testExternalCode2HotkeyDefault
  global ahk1exepath, ahk1exepathDefault, ahk2exepath, ahk2exepathDefault
  global serverURL, serverURLDefault 
  global serverURLExtension, serverURLExtensionDefault 
  global texteditorpath, texteditorpathDefault
  global clipboardKeep, clipboardKeepDefault

  global directive1, directive2, directive3, directive4, directive5, directive6
  global directive21, directive22, directive23, directive24, directive25, directive26
  
  global directive1Default, directive2Default, directive3Default, directive4Default, directive5Default, directive6Default
  global directive21Default, directive22Default, directive23Default, directive24Default, directive25Default, directive26Default
  
  
  ; config:
  saveDir := iniReadSave("saveDir", "config", saveDirDefault)
  fontName := iniReadSave("font", "config", fontNameDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)
  fontControlArea := iniReadSave("fontControlArea", "config", fontControlAreaDefault)
  fontsizeControlArea := iniReadSave("fontsizeControlArea", "config", fontsizeControlAreaDefault)

  fontSCI := iniReadSave("fontSCI", "config", fontSCIDefault)
  fontsizeSCI := iniReadSave("fontsizeSCI", "config", fontsizeSCIDefault)
  cutFileEncoding := iniReadSave("cutFileEncoding", "config", cutFileEncodingDefault)
  lastSavedName := iniReadSave("lastSavedName", "config", lastSavedNameDefault)
  disableCodeModifications := iniReadSave("disableCodeModifications", "config", disableCodeModificationsDefault)
  testSelectedCodeHotkey := iniReadSave("testSelectedCodeHotkey", "config", testSelectedCodeHotkeyDefault)
  testExternalCode1Hotkey := iniReadSave("testExternalCode1Hotkey", "config", testExternalCode1HotkeyDefault)
  testExternalCode2Hotkey := iniReadSave("testExternalCode2Hotkey", "config", testExternalCode2HotkeyDefault)

  clipboardKeep := iniReadSave("clipboardKeep", "config", clipboardKeepDefault)
  
  ; setup:
  ahk1exepath := iniReadSave("ahk1exepath", "setup", ahk1exepathDefault)
  ahk2exepath := iniReadSave("ahk2exepath", "setup", ahk2exepathDefault)
  serverURL := iniReadSave("serverURL", "setup", serverURLDefault)
  serverURLExtension := iniReadSave("serverURLExtension", "setup", serverURLExtensionDefault)
  texteditorpath := iniReadSave("texteditorpath", "setup", texteditorpathDefault)
  
  ; directives1:
  directive1 := iniReadSave("directive1", "directives1", directive1Default)
  directive2 := iniReadSave("directive2", "directives1", directive2Default)
  directive3 := iniReadSave("directive3", "directives1", directive3Default)
  directive4 := iniReadSave("directive4", "directives1", directive4Default)
  directive5 := iniReadSave("directive5", "directives1", directive5Default)
  directive6 := iniReadSave("directive6", "directives1", directive6Default)
  
  ; directives2:
  directive21 := iniReadSave("directive21", "directives2", directive21Default)
  directive22 := iniReadSave("directive22", "directives2", directive22Default)
  directive23 := iniReadSave("directive23", "directives2", directive23Default)
  directive24 := iniReadSave("directive24", "directives2", directive24Default)
  directive25 := iniReadSave("directive25", "directives2", directive25Default)
  directive26 := iniReadSave("directive26", "directives2", directive26Default)
  
  ; external
  filemanager := iniReadSave("filemanager", "external", "")
  

  if (InStr(testSelectedCodeHotkey, "off")){
    sIni := StrReplace(testSelectedCodeHotkey, "off" , "")
    Hotkey, %sIni%, runButtonSelOperation, off
  } else {
    Hotkey, %testSelectedCodeHotkey%, runButtonSelOperation, T1
  }
  
  if (InStr(testExternalCode1Hotkey, "off")){
    testExternalCode1HotkeyIni := StrReplace(testExternalCode1Hotkey, "off" , "")
    Hotkey, %testExternalCode1HotkeyIni%, testExternalCode1Hotkey, off
  } else {
    Hotkey, %testExternalCode1Hotkey%, testExternalCode1, T1
  }

  if (InStr(testExternalCode2Hotkey, "off")){
    testExternalCode2HotkeyIni := StrReplace(testExternalCode2Hotkey, "off" , "")
    Hotkey, %testExternalCode2HotkeyIni%, testExternalCode2Hotkey, off
  } else {
    Hotkey, %testExternalCode2Hotkey%, testExternalCode2, T1
  }
   
  return
}
;-------------------------------- saveConfig --------------------------------
saveConfig(){
  global configFile, configFileOld
  global saveDir, fontName, fontsize
  global fontControlArea, fontsizeControlArea
  global fontSCI, fontsizeSCI
  global cutFileEncoding, lastSavedName
  global disableCodeModifications, testSelectedCodeHotkeyDefault, testSelectedCodeHotkey
  global ahk1exepath, ahk2exepath,serverURL, serverURLExtension, texteditorpath
  global testExternalCode1HotkeyDefault, testExternalCode1Hotkey, testExternalCode2HotkeyDefault, testExternalCode2Hotkey
  global clipboardKeep
    
  global maxDirectives
  global directive1, directive2, directive3, directive4, directive5, directive6
  global directive21, directive22, directive23, directive24, directive25, directive26
  
  if (configFile == configFileOld){
    msgbox, ERROR`, old configfile (%configFile%)used!
  }
  
  ; config:
  IniWrite, %saveDir%, %configFile%, config, saveDir
  IniWrite, "%fontName%", %configFile%, config, font
  IniWrite, %fontsize%, %configFile%, config, fontsize

  IniWrite, "%fontControlArea%", %configFile%, config, fontControlArea
  IniWrite, %fontsizeControlArea%, %configFile%, config, fontsizeControlArea

  IniWrite, "%fontSCI%", %configFile%, config, fontSCI
  IniWrite, %fontsizeSCI%, %configFile%, config, fontsizeSCI
  
  IniWrite, "%cutFileEncoding%", %configFile%, config, cutFileEncoding
  IniWrite, "%lastSavedName%", %configFile%, config, lastSavedName
  
  IniWrite, %disableCodeModifications%, %configFile%, config, disableCodeModifications
  
  IniWrite, "%testSelectedCodeHotkey%", %configFile%, config, testSelectedCodeHotkey
  IniWrite, "%testExternalCode1Hotkey%", %configFile%, config, testExternalCode1Hotkey
  IniWrite, "%testExternalCode2Hotkey%", %configFile%, config, testExternalCode2Hotkey
  IniWrite, "%clipboardKeep%", %configFile%, config, clipboardKeep 
  
  ; setup:
  IniWrite, "%ahk1exepath%", %configFile%, setup, ahk1exepath
  IniWrite, "%ahk2exepath%", %configFile%, setup, ahk2exepath
  IniWrite, "%serverURL%", %configFile%, setup, serverURL
  IniWrite, "%serverURLExtension%", %configFile%, setup, serverURLExtension
  IniWrite, "%texteditorpath%", %configFile%, setup, texteditorpath
  
  ; directives1:
  loop, 6
  {
    if (!InStr(directive%A_Index%, "#"))
      directive%A_Index% := "#empty!"
    if (!InStr(directive2%A_Index%, "#"))
      directive2%A_Index% := "#empty!"
  }
  IniWrite, "%directive1%", %configFile%, directives1, directive1
  IniWrite, "%directive2%", %configFile%, directives1, directive2
  IniWrite, "%directive3%", %configFile%, directives1, directive3
  IniWrite, "%directive4%", %configFile%, directives1, directive4
  IniWrite, "%directive5%", %configFile%, directives1, directive5
  IniWrite, "%directive6%", %configFile%, directives1, directive6
  
  ; directives2:
  IniWrite, "%directive21%", %configFile%, directives2, directive21
  IniWrite, "%directive22%", %configFile%, directives2, directive22
  IniWrite, "%directive23%", %configFile%, directives2, directive23
  IniWrite, "%directive24%", %configFile%, directives2, directive24
  IniWrite, "%directive25%", %configFile%, directives2, directive25
  IniWrite, "%directive26%", %configFile%, directives2, directive26
  
  return
}
;------------------------------- readGuiData -------------------------------
readGuiData() {
  global configFile, dpiCorrect, dpiScale, dpiScaleDefault
  global windowPosX, windowPosY, windowPosXDefault, windowPosYDefault
  global clientWidth, clientHeight, clientWidthDefault, clientHeightDefault
  global controlAreaPosX, controlAreaPosY, controlAreaXPosDefault, controlAreaYPosDefault
  global debugAreaPosX, debugAreaPosY, debugAreaXPosDefault, debugAreaYPosDefault
  global showDebugArea, showDebugAreaDefault
  global controlAreaAOT, controlAreaAOTDefault
  
  dpiScale := iniReadSave("dpiScale", "gui", dpiScaleDefault)
  windowPosX := iniReadSave("windowPosX", "gui", windowPosXDefault)
  windowPosY := iniReadSave("windowPosY", "gui", windowPosYDefault)
  clientWidth := iniReadSave("clientWidth", "gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight", "gui", clientHeightDefault)
  
  controlAreaPosX := iniReadSave("controlAreaPosX", "gui", controlAreaXPosDefault)
  controlAreaPosY := iniReadSave("controlAreaPosY", "gui", controlAreaYPosDefault)
  
  debugAreaPosX := iniReadSave("debugAreaPosX", "gui", debugAreaXPosDefault)
  debugAreaPosY := iniReadSave("debugAreaPosY", "gui", debugAreaYPosDefault)
  
  showDebugArea := iniReadSave("showDebugArea", "gui", showDebugAreaDefault)
  controlAreaAOT := iniReadSave("controlAreaAOT", "gui", controlAreaAOTDefault)
  
  dpiCorrect := A_ScreenDPI / dpiScale
  
  windowPosX := max(windowPosX,-50)
  windowPosY := max(windowPosY,-50)
  
  controlAreaPosX := max(controlAreaPosX,-50)
  controlAreaPosY := max(controlAreaPosY,-50)
  
  debugAreaPosX := max(debugAreaPosX,-50)
  debugAreaPosY := max(debugAreaPosY,-50)

  return
}
;-------------------------------- saveGuiData --------------------------------
saveGuiData(){
  global mainHwnd, controlAreaHwnd, hdebugArea, configFile, dpiScale
  global windowPosX, windowPosY, clientWidth, clientHeight
  global controlAreaPosX, controlAreaPosY
  global debugAreaPosX, debugAreaPosY, showDebugArea, controlAreaAOT
  
  WinGetPos, windowPosX, windowPosY,,, ahk_id %mainHwnd%
  WinGetPos, controlAreaPosX, controlAreaPosY,,, ahk_id %controlAreaHwnd%
  WinGetPos, debugAreaPosX, debugAreaPosY,,, ahk_id %hdebugArea%

  windowPosX := max(windowPosX, -100)
  windowPosY := max(windowPosY, -100)
  controlAreaPosX := max(controlAreaPosX, -100)
  controlAreaPosY := max(controlAreaPosY, -100)
  debugAreaPosX := max(debugAreaPosX, -100)
  debugAreaPosY := max(debugAreaPosY, -100)
    
  IniWrite, %dpiScale%, %configFile%, gui, dpiScale
  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY
  
  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight
  
  IniWrite, %controlAreaPosX%, %configFile%, gui, controlAreaPosX
  IniWrite, %controlAreaPosY%, %configFile%, gui, controlAreaPosY
  
  IniWrite, %debugAreaPosX%, %configFile%, gui, debugAreaPosX
  IniWrite, %debugAreaPosY%, %configFile%, gui, debugAreaPosY
  
  IniWrite, %showDebugArea%, %configFile%, gui, showDebugArea
  IniWrite, %controlAreaAOT%, %configFile%, gui, controlAreaAOT

  return
}
;-------------------------------- wrkPath --------------------------------
wrkPath(p){
  global wrkdir
  
  r := wrkdir . p
    
  return r
}
;------------------------------- pathToAbsolut -------------------------------
pathToAbsolut(p){
  
  r := p
  if (!InStr(p, ":"))
    r := wrkPath(p)
    
  if (SubStr(r,0,1) != "\")
    r .= "\"
    
  return r
}
;-------------------------------- resolvePath --------------------------------
resolvePath(p){
  
  r := p
    
  if (SubStr(r,0,1) != "\")
    r .= "\"

  return r
}
;------------------------------- debugSetText -------------------------------
debugSetText(s){
global DebugText

  guicontrol, debugArea:, DebugText, %s%

  return
}
;-------------------------------- sciSetText --------------------------------
sciSetText(t := ""){
  global sci
  global sciDebug
  
  sci.SETUNDOCOLLECTION(0)
  sci.SetText(0, t)
  sci.SETUNDOCOLLECTION(1)
  sci.BEGINUNDOACTION(1)

  return
}
;------------------------------- RETURN hotkey -------------------------------
~*RETURN::
ControlGetFocus, hasFocusVar , A
if (hasFocusVar == "Scintilla1"){
  sci.ENDUNDOACTION(1)
  sci.BEGINUNDOACTION(1)
}
return
;--------------------------------- disableCodeModifications ---------------------------------
disableCodeModifications(){
  global configFile, disableCodeModifications
  
  gui, controlArea:submit, NoHide
  IniWrite, %disableCodeModifications%, %configFile%, config, disableCodeModifications
  
  return
}
;--------------------------------- makeExe64 ---------------------------------
makeExe64(){
  makeExe("64")
  return
}
;--------------------------------- runExe64 ---------------------------------
runExe64(){
  run "_codeToExe64.exe"
  return
}
;--------------------------------- makeExe32 ---------------------------------
makeExe32(){
  makeExe("32")
  return
}
;--------------------------------- runExe32 ---------------------------------
runExe32(){
  run "_codeToExe32.exe"
  return
}
;---------------------------------- makeExe ----------------------------------
makeExe(makeBit){
  global mainHwnd, sci, configFile, cutFileEncoding, useAhkVersion2, disableCodeModifications
  
  sci.GetText(sci.getLength(), theCode)
  
  autoSelectAHKversion(theCode)
  
  ;comment out showvari() etc.
  theCode := RegExReplace(theCode,"i)(showvari\(.*\))", "; $1")
  
  filename := "_codeToExe.ahk"
  fnEXE := "_codeToExe"

  allDirectives := ""
  theCodeCleaned := handleDirectives(theCode, allDirectives)
  
  fEncoding := ""
  if (!disableCodeModifications){
    if(useAhkVersion2)
      fEncoding := "FileEncoding """ . cutFileEncoding . """`n"
    else
      fEncoding := "FileEncoding, " . cutFileEncoding . "`n"
  }
  
  theCode := allDirectives . fEncoding . theCodeCleaned
  
  Try
  {
    if (FileExist(filename))
      FileDelete, %filename%
      
    FileAppend,
(
%theCode%
), %filename%, %cutFileEncoding%
  }
  catch e
  {
    eMsg  := e.Message
    msgArr := {}
    msgArr.push("Error: " . eMsg)
    msgArr.push("Closing Updater due to an error!")
    
    errorExit(msgArr, url)
  }

  if (FileExist(filename)){
    if(useAhkVersion2){
      cmd := """C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"""
      cmd .= " /in " . filename . " /out " . fnEXE . makeBit . ".exe /base "
      cmd .= """C:\Program Files\AutoHotkey\v2\AutoHotkey" . makeBit . ".exe"""
    } else {
      cmd := """C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"""
      cmd .= " /in " . filename . " /out " . fnEXE . makeBit . ".exe /bin "
      cmd .= """C:\Program Files\AutoHotkey\Compiler\Unicode " . makeBit . "-bit.bin"""
    }
    run, %cmd%
    
    ahkVersion := useAhkVersion2?"AHK 2":"AHK 1"
    showHintColoredRefresh(mainHwnd, "Created file: " . fnEXE . makeBit . ".exe (" . ahkVersion . ")")
  } else {
    msgbox,Please run your code once before!
  }

  return 
}
;------------------------------ getTextFromSCI ------------------------------
getTextFromSCI(){
  global configFile, sci 
  
  contentFromSCILen := sci.getLength()
  contentFromSCI := ""
  
  if (contentFromSCILen > 0)
    sci.GetText(contentFromSCILen, contentFromSCI)
  
  ; compensate sporadic read-errors
  if (StrLen(contentFromSCI) == 1)
    contentFromSCI := ""
  
  if (!InStr(contentFromSCI,"`n"))
    contentFromSCI := contentFromSCI . "`n" 

  return contentFromSCI
}
;------------------------------ handleDirectives ------------------------------
handleDirectives(theCode, ByRef allDirectives){
  global useAhkVersion2, configFile, maxDirectives
  
  ; read directives and check for duplicates
  
  directives := []
  
  loop, %maxDirectives% {
    if(useAhkVersion2)
      directive := iniReadSave("directive2" . A_Index, "directives2", "")
    else
      directive := iniReadSave("directive" . A_Index, "directives1", "")
    
    if (directive != "")
      directives.push(directive)
  }
  
  ; extract directives from code
  lines := StrSplit(theCode,"`n")
  theCodeChanged := ""

  l := lines.Length()
  loop, %l%
  {
    line := lines[A_Index]
    fPos := RegExMatch(line,"i)^#.+", found)
    if (fPos){
      directives.push(line)
    } else {
      theCodeChanged .= line . "`n"
    }
  }
  
  l := directives.Length()

  loop, %l%
  {
    allDirectives .= directives[A_Index] . "`n"
  } 
  allDirectives .= "`n"

  return (theCodeChanged)
}
;--------------------------- showTmpfileOperation ---------------------------
showTmpfileOperation(){
  global mainHwnd, sci, clientWidth, clientHeight
  global actualContent, contentIsTemporary, tmpIsOpen, showDebugArea
  
  if (tmpIsOpen){
    ; close
    
    gui, guiMain:Show
    gui, controlArea:Show

    if (showDebugArea)
      gui, debugArea:Show
      
    sciSetText(actualContent)
    guicontrol,controlArea:, ButtonShow, Show: _tmp.ahk
    tmpIsOpen := 0
    contentIsTemporary := 0

  } else {
    ;Open
    
    file := "_tmp.ahk"
    if (FileExist(file)){
      actualContent := getTextFromSCI()
      
      exch123Reset()
      makePerma()
      saveConfig()
      saveGuiData()
      syncAppDataWrite()

      tmpIsOpen := 1
      contentIsTemporary := 1
      guicontrol,controlArea:, ButtonShow, Close: _tmp.ahk
      
      FileRead, data, % file
      sciSetText(data)
    }
  }
  
  return
}
;------------------------------ editCodeToExe ------------------------------
editCodeToExe(){
  ; content is overwitten by all "make"-commands
  
  global mainHwnd, sci, clientWidth, clientHeight
  global actualContent, contentIsTemporary, showDebugArea

  w := clientWidth - 100
  h := clientHeight - 100
  
  actualContent := getTextFromSCI()
  
  exch123Reset()
  makePerma()
  saveConfig()
  saveGuiData()
  syncAppDataWrite()

  contentIsTemporary := 1
  file := "_codeToExe.ahk"
  if (FileExist(file)){
    FileRead, data, % file
    sciSetText(data)
    
    settimer, moveMessageBoxAbove,-300
    MsgBox, 1,, If editing has finished to save please press the "OK"-button!`n(Content is overwitten by all "make"-commands!)
    
    IfMsgBox, OK
    {
      data := getTextFromSCI()
      FileDelete, %file%
      FileAppend, %data%, %file%
    }
    
    gui, guiMain:Show
    gui, controlArea:Show
  
    if (showDebugArea)
      gui, debugArea:Show
    
  } else {
    showHintColoredRefresh(mainHwnd, "ERROR, file """ . file . """ not found!")
  }
  
  sciSetText(actualContent)
  contentIsTemporary := 0

  return
}
;------------------------------ moveMessageBoxAbove ------------------------------
moveMessageBoxAbove(){
  global controlAreaHwnd, controlAreaPosX, controlAreaPosY
  
  ownPID := DllCall("GetCurrentProcessId")
  if WinExist("ahk_class #32770 ahk_pid " . ownPID) {
    WinMove, controlAreaPosX, % controlAreaPosY
  }
  gui, controlArea:Hide
  gui, debugArea:Hide
  
  return
}
;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found!
  }

  return
}
;-------------------------------- OpenAwesome --------------------------------
OpenAwesome(){
  
  run,http://ahkscript.org/joedf/awesome-autohotkey/
  
  return
}
;---------------------------- runButtonOperation ----------------------------
runButtonOperation(){
  global isUniCodeTable, contentIsTemporary

  if(!isUniCodeTable){
    if (contentIsTemporary){
      msgbox, Please close the temporary content first!
    } else {
      startTestTempCode(0)
    }
  } else {
    showUnicodeTableUp()
  }
  
  return
}
;--------------------------- runButtonSelOperation ---------------------------
runButtonSelOperation(){
  global isUniCodeTable, contentIsTemporary

  if(!isUniCodeTable){
    if (contentIsTemporary){
      msgbox, Please close the temporary content first!
    } else {
      startTestTempCode(1)
    }
  } else {
    showUnicodeTableUp()
  }
  
  return
}
;---------------------------- exitButtonOperation ----------------------------
exitButtonOperation(){
  global isUniCodeTable

  if(!isUniCodeTable){
    exit()
  } else {
    showUnicodeTableStop()
  }

  return
}

;----------------------------- startTestTempCode -----------------------------
startTestTempCode(selectedOnly := 0){
  global sci, debugTextAll, sciDebug, mainHwnd, useAhkVersion2, fontsize
  
  debugTextAll := ""
  makePerma()
  
  theCode := ""
  if (!selectedOnly){
    theCode := getTextFromSCI()
  } else {
    theCode := GetSelectedText()

    if(!StrLen(theCode) > 0){
      showHintColoredRefresh(mainHwnd, "ERROR, Nothing selected!")
      return
    }
  }
  
  ; max runtime
  if (!InStr(theCode,"exitApp", 0)){
    settimer, showhintcoloredDelayed, -10000
  }
  
  autoSelectAHKversion(theCode)
  
  testTempCode(theCode)
  
  endtest()
  
  return
}
;--------------------------- autoSelectAHKversion ---------------------------
autoSelectAHKversion(theCode){
 global useAhkVersion2

  fPos := RegExMatch(theCode,"i)#Requires AutoHotkey[ ><=v]*2.*") 
  if (fPos){
    useAhkVersion2 := 1
  } else {
    useAhkVersion2 := 0
  }
  
  return
}
;------------------------------ GetSelectedText ------------------------------
GetSelectedText() {
  global sci
  
  selLength := sci.GetSelText()
  VarSetCapacity(SelText, selLength, 0)
  sci.GetSelText(0, &SelText)
  Return StrGet(&SelText, selLength, "utf-8")
}
;------------------------------- testTempCode -------------------------------
testTempCode(theCodeParam){
  global mainHwnd, ahk1exepath, configFile, cutFileEncoding, useAhkVersion2, disableCodeModifications
  global ahk1exepath, ahk2exepath, showDebugArea
  
  allDirectives := ""
  theCode := handleDirectives(theCodeParam, allDirectives)
  
  if (FileExist("debug.log"))
    FileDelete, debug.log

  if (!disableCodeModifications){
    gui, guiMain:Hide
    gui, controlArea:Hide
    fPos := RegExMatch(theCode,"O)(.*?)(showvari\(.+\))", match)
    if (fPos){
      if (!InStr(match.Value(1),";")){
        showDebugArea := 1
        IniWrite, %showDebugArea%, %configFile%, gui, showDebugArea
        gui, debugArea:Show
      }
    }
  }
  
  DetectHiddenWindows, On
  If Winexist("_tmp.ahk") ; If the test code is running close it before running a new one.
  {
    PostMessage("Slave script", 0x0001) ; exits/deletes slave script
    sleep,500
  }
  
  if (!disableCodeModifications){
    ;replace "exitApp" by sendInput,{ESCAPE}
    if (useAhkVersion2){
      theCode := RegExReplace(theCode,"i)exitApp","sendInput ""{Esc}"" ")
    } else {
      theCode := RegExReplace(theCode,"i)exitApp","sendInput,{ESCAPE}")
    }
  }
  
  ; create "_tmp.ahk"
  if (FileExist("_tmp.ahk"))
    FileDelete, %A_ScriptDir%\_tmp.ahk
  
  ; append all directives
  FileAppend,%allDirectives%, %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%


  if (!disableCodeModifications){
    if(useAhkVersion2)
      FileAppend, FileEncoding "%cutFileEncoding%"`n`n, %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%
    else
      FileAppend, FileEncoding`, %cutFileEncoding%`n`n, %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%
  }

; start of if (!disableCodeModifications) *******************************************************************
  if (!disableCodeModifications){
  ; start of if(useAhkVersion2) *******************************************************************
  
    if(useAhkVersion2){
      FileAppend,
(

;--------------------------- _codetester_b64Encode2 ---------------------------
; AHK 2

; https://www.autohotkey.com/boards/viewtopic.php?t=81968

_codetester_b64Encode2(sInput,encoding:="UTF-8") {
    If (sInput != "") {
        codetester_funcName := (encoding = "UTF-8") ? "CryptBinaryToStringA" : "CryptBinaryToStringW"
        
        codetester_bin := Buffer(StrPut(sInput, encoding),0)
        StrPut(sInput, codetester_bin, encoding)
        
        if !(DllCall("crypt32\" codetester_funcName, "Ptr", codetester_bin.ptr, "UInt", codetester_bin.size, "uint", 0x1, "ptr", 0, "uint*", &chars:=0)) ; param 2 was len
            throw Error(codetester_funcName " failed to determine size.", -1)
        
        codetester_buf := Buffer(chars * ((encoding="UTF-16") ? 2 : 1), 0)
        
        if !(DllCall("crypt32\" codetester_funcName, "ptr", codetester_bin.ptr, "uint", codetester_bin.size, "uint", 0x1, "ptr", codetester_buf.ptr, "uint*", &chars))
            throw Error(codetester_funcName " failed to execute", -1)

        return StrGet(codetester_buf,encoding)
    } Else
        return ""
}
;--------------------------------- showvari ---------------------------------
; AHK 2
showvari(variName := "", variText := ""){

  TargetScriptTitle := "Codetester ahk_class AutoHotkeyGUI"
  
  codetester_showvariMessage := variName . ": " . variText
  codetester_toSend := _codetester_b64Encode2(codetester_showvariMessage, "UTF-8")
  codetester_result := _codetester_Send_WM_COPYDATA(codetester_toSend)
  
  if (codetester_result == "FAIL"){
    MsgBox("SendMessage failed. Does the following WinTitle exist?: " . TargetScriptTitle)
  } else if (codetester_result == 0){
    tooltip "showvari: Codetester responded with Error!",,,19
  }

  OutputDebug variName . ": " . variText
  
  return
}
;----------------------------- _codetester_Send_WM_COPYDATA -----------------------------
; AHK 2

_codetester_Send_WM_COPYDATA(message) {
  DetectHiddenWindows True
  SetTitleMatchMode 2
  
  codetester_buf := StrLen(message)

  codetester_bin := Buffer(A_PtrSize * 3)
  NumPut("Ptr", 4194305, codetester_bin, 0)
  NumPut("UInt", codetester_buf * 2, codetester_bin, A_PtrSize)
  NumPut("Ptr", StrPtr(message), codetester_bin, A_PtrSize * 2)
  SendMessage 0x4a, 0, codetester_bin, , "Codetester ahk_class AutoHotkeyGUI",,,20000
}
;------------------------- _codetester_ReceiveMessage -------------------------
_codetester_ReceiveMessage(wParam, lParam, Mld, Hwnd) {
  global _codetester_slave_guiText, _codetester_slave_gui

  if (wParam == 1){
    _codetester_slave_gui.show
    _codetester_slave_guiText.Text := "Received exitApp message! (" . wParam . ")"
    sleep 2000
    _codetester_slave_gui.hide
    exitApp
  }
}
;--------------------------- codetester_slave_gui ---------------------------
_openCodetester_slave_gui(){
  global _codetester_slave_guiText, _codetester_slave_gui
  
  ; hidden message receiver window
  _codetester_slave_gui := Gui(, "Slave script")
  _codetester_slave_gui.addText("w350")
  _codetester_slave_guiText := _codetester_slave_gui.add("text", "xm w300")
  _codetester_slave_gui.Opt("AlwaysOnTop +ToolWindow")
  _codetester_slave_gui.show("w300 h100")
  _codetester_slave_gui.hide
  
  OnMessage 0x1001, _codetester_ReceiveMessage

  return
}
;------------------------- _codetester_moveMsgBoxes -------------------------
; AHK 2
_codetester_moveMsgBoxes(P, *) {
  static coord := 20

  if (P == 1027) {
    OwnPID := DllCall("GetCurrentProcessId")
    DetectHiddenWindows True
    if WinExist("ahk_class #32770 ahk_pid " . ownPID) {
      WinMove coord, coord
      coord += 20
    }
  }
}

OnMessage(0x44, _codetester_moveMsgBoxes)

_openCodetester_slave_gui()

%theCode%

), %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%
; end of if(useAhkVersion2) *******************************************************************

} else {

  FileAppend, 
(
; AHK 1
;--------------------------- _codetester_b64Encode ---------------------------
_codetester_b64Encode(inputStr) {
    codetester_size := 0
    VarSetCapacity(codetester_bin, StrPut(inputStr, "UTF-8")) && codetester_len := StrPut(inputStr, &codetester_bin, "UTF-8") - 1 
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &codetester_bin, "uint", codetester_len, "uint", 0x1, "ptr", 0, "uint*", codetester_size))
        throw Exception("CryptBinaryToString failed to measure the output", -1)
    VarSetCapacity(codetester_buf, codetester_size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &codetester_bin, "uint", codetester_len, "uint", 0x1, "ptr", &codetester_buf, "uint*", codetester_size))
        throw Exception("CryptBinaryToString failed to create the output", -1)
    return StrGet(&codetester_buf)
}
;----------------------------- _codetester_Send_WM_COPYDATA -----------------------------
; AHK 1
_codetester_Send_WM_COPYDATA(StringToSend, TargetScriptTitle) {
  DetectHiddenWindows, On
  SetTitleMatchMode, 2
  
  VarSetCapacity(datastruct, A_PtrSize * 3, 0)
  NumPut(0x4567, datastruct)
  NumPut(StrLen(StringToSend) * 2 + 1, datastruct, A_PtrSize)
  NumPut(&StringToSend, datastruct, A_PtrSize * 2)
  
  SendMessage, 0x4a,, &datastruct,, `%`TargetScriptTitle`%` ,,,,20000
}
;--------------------------------- showvari ---------------------------------
; AHK 1
showvari(variName := "", variText := ""){

  TargetScriptTitle := "Codetester ahk_class AutoHotkeyGUI"
  
  codetester_showvariMessage := variName . ": " . variText
  codetester_toSend := _codetester_b64Encode(codetester_showvariMessage)
  codetester_result := _codetester_Send_WM_COPYDATA(codetester_toSend, TargetScriptTitle)

  if (codetester_result == "FAIL"){
    MsgBox SendMessage failed. Does the following WinTitle exist?: `%`TargetScriptTitle`%`
  } else if (codetester_result == 0){
    tooltip, showvari: Codetester responded with Error!,,,19
  }
  
  OutputDebug `%variName`%: `%variText`%
  
  return
}

;------------------------- _codetester_ReceiveMessage -------------------------
_codetester_ReceiveMessage(Message) {
  if (Message == 1)
    exitApp
}
;------------------------- _openCodetester_slave_gui -------------------------
_openCodetester_slave_gui(){
  ; hidden message receiver window
  gui, _codetester_slave_gui: show, hide,Slave script
  OnMessage(0x1001,"_codetester_ReceiveMessage")
  return
}
;------------------------- _codetester_moveMsgBoxes -------------------------
_codetester_moveMsgBoxes(P) {
  static coord := 20
  
  if (P == 1027) {
    OwnPID := DllCall("GetCurrentProcessId")
    DetectHiddenWindows, On
    if WinExist("ahk_class #32770 ahk_pid " . ownPID) {
      WinMove, coord, coord
      coord += 20
    }
  }
}

OnMessage(0x44, "_codetester_moveMsgBoxes")

_openCodetester_slave_gui()

%theCode%

), %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%

    }
    ; end of if else(useAhkVersion2) **********************************************************
  } else {

  FileAppend,
(
%theCode%

), %A_ScriptDir%\_tmp.ahk, %cutFileEncoding%
  }
  ; end of if (!disableCodeModifications) **********************************************************
  
  cmd := ""
  if(useAhkVersion2)
    cmd := """" . ahk2exepath . """" . " " . "_tmp.ahk" 
  else
    cmd := """" . ahk1exepath . """" . " " . "_tmp.ahk" 
  
  Run, %comspec% /c %cmd% , ,Min
  
  IfWinExist, ahk_class #32770 ; IF THERE IS AN ERROR LOADING THE SCRIPT SHOW THE USER
  {
    Sleep 20
    WinActivate, ahk_class #32770
    
    Send, ^c
    CheckWin := Clipboard
    Clipboard := Clipsave
    IfInString, CheckWin, The program will exit.
    {

    TrayTip, ERROR, Error executing the code properly!
    
    return
    }
  }
  
  return
} ; end testTempCode()
;-------------------------- showhintcoloredDelayed --------------------------
showhintcoloredDelayed(){
  global mainHwnd

  showHintColoredRefresh(mainHwnd, "Please press the ESCAPE-key, to finish the code under test!", 6000,0, "c000000", "cF3E7D9")

  return
}
;-------------------------------- PostMessage --------------------------------
PostMessage(Receiver, Message) {
  oldTMM := A_TitleMatchMode
  oldDHW := A_DetectHiddenWindows
  SetTitleMatchMode, 3
  DetectHiddenWindows, On
  PostMessage, 0x1001,%Message%,,, %Receiver% ahk_class AutoHotkeyGUI
  SetTitleMatchMode, %oldTMM%
  DetectHiddenWindows, %oldDHW%
    
  return
}
;------------------------------ openFilemanager ------------------------------
openFilemanager(){
  global saveDir, filemanager
  
  dir := pathToAbsolut(saveDir)
  
  if (filemanager == "" || filemanager == "ERROR"){
    Run, explore %dir%
  } else {
    if (InStr(filemanager, "dopusrt")){
      cmd := """" . filemanager . """" . " /cmd go "  . """" . dir . """"
      ; hideWindow()
      RunWait, %cmd%  
    } else {
      msgbox, Unknown Filemanager:`n%filemanager%
    }
  }

  return
}
;---------------------------- openFilemanageHome ----------------------------
openFilemanageHome(){
  global wrkDir
  
  run,%wrkDir%,%wrkDir%
  
  return
}
;---------------------------------- EndTest ----------------------------------
endTest(){
  global mainHwnd, showDebugArea

  DetectHiddenWindows, On
  PostMessage("Slave script", 0x0001) ; message to start exits 

  settimer, showhintcoloredDelayed, delete

  gui, guiMain:Show
  gui, controlArea:Show
  
  debugAreaShow()
   
  return
}
;--------------------------------- makePerma ---------------------------------
makePerma(){
  global sci, actualContent, contentIsTemporary
  
  theCode := ""
  if (contentIsTemporary)
    theCode := actualContent
  else
    theCode := getTextFromSCI()
    
  contentIsTemporary := 0
  
  if (FileExist("_codetester.txt"))
    FileDelete, _codetester.txt
  
  FileAppend,
  (
  %theCode%
  ), _codetester.txt
  
  return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appnameLower
  
  Run https://github.com/jvr-ks/%appnameLower%
  return
}
;--------------------------- guiMainGuiContextMenu ---------------------------
guiMainGuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){
  isr := IsRightClick ? "yes" : "no"
  msgBox, 
  (
  A contextmenu is not defined at the moment!
  Parameters are
  GuiHwnd: %GuiHwnd%
  CtrlHwnd: %CtrlHwnd%
  EventInfo: %EventInfo%
  IsRightClick: %isr%
  X: %X%
  Y: %Y%
  )

  return
}
;-------------------------------- insShowvari --------------------------------
insShowvari(){
  global sci

  ; cps := clipboard
  ; clipboard := ""
  
  sci.COPY()
  theInsert := clipboard
  
  if (theInsert != ""){
    t := "`nshowvari(""" . theInsert . """," . theInsert . ")`n"
    sci.LINEDOWN()
    sci.INSERTTEXT(-1,t)
  } else {
    msgbox, Mark a variable first!
  }
  
  ; clipboard := cps
  return
}
;------------------------------ insRequiresAHK2 ------------------------------
insRequiresAHK2(){
  global sci, mainHwnd, sciHwnd
  
  pos := sci.GETCURRENTPOS()
  
  theCode := ""
  sci.GetText(sci.getLength(), theCode)

  theCode := RegExReplace(theCode, "i)#Requires AutoHotkey.*`n", "")
  
  sciSetText(theCode)
  
  sci.GOTOLINE(0)

  sci.INSERTTEXT(-1, "#Requires AutoHotkey v2`n")
  sci.SCROLLCARET()
  sleep, 1000
  
  sci.SETCURRENTPOS(pos)
  sci.SETANCHOR(pos)
  sci.SCROLLCARET()

  WinActivate, ahk_id %mainHwnd%
  
  return
}
;------------------------------ insRequiresAHK1 ------------------------------
insRequiresAHK1(){
  global sci, mainHwnd, sciHwnd

  pos := sci.GETCURRENTPOS()
  
  theCode := ""
  sci.GetText(sci.getLength(), theCode)

  theCode := RegExReplace(theCode, "i)#Requires AutoHotkey.*`n", "")
  
  sciSetText(theCode)
  
  sci.GOTOLINE(0)

  sci.INSERTTEXT(-1, "#Requires AutoHotkey v1`n")
  sci.SCROLLCARET()
  sleep, 1000
  
  sci.SETCURRENTPOS(pos)
  sci.SETANCHOR(pos)
  sci.SCROLLCARET()

  WinActivate, ahk_id %mainHwnd%
  
  return
}
;------------------------------ insSleepExitApp ------------------------------
insSleepExitApp(){
  global sci, useAhkVersion2

  sci.GetText(sci.getLength(), s)
  autoSelectAHKversion(s)
  
  if(useAhkVersion2){
    t := "`nsleep 2000`nexitApp`n"
  } else {
    t := "`nsleep, 2000`nexitApp`n"
  }
  
  sci.INSERTTEXT(-1,t)

  return
}
;--------------------------------- insExitApp ---------------------------------
insExitApp(){
  global sci

  t := "`nexitApp`n"
  
  sci.INSERTTEXT(-1,t)

  return
}
;--------------------------------- insMsgbox ---------------------------------
insMsgbox(){
  global sci, useAhkVersion2

  sci.COPY()
  theInsert := clipboard
  
  sci.GetText(sci.getLength(), s)
  autoSelectAHKversion(s)

  if (theInsert != ""){
    if(useAhkVersion2)
      t := "msgbox(" . theInsert . ")"
    else
      t := "msgbox`,%" . theInsert . "%`n"
    
    pos := sci.GETSELECTIONEND()
    line := sci.LINEFROMPOSITION(pos)
    lineEndPos := sci.GETLINEENDPOSITION(line)
    sci.INSERTTEXT(lineEndPos, "`n`n")
    sci.INSERTTEXT(lineEndPos + 2, t)
  } else {
    msgbox, Mark a variable first!
  }
  
  ;clipboard := cps
  ;cps := ""
  return
}
;----------------------------- runAllfilesBetter -----------------------------
runAllfilesBetter(){
  global saveDir

  dir := pathToAbsolut(saveDir)
  run, allfilesbetter.exe %dir%

  return
}
;------------------------------ refreshStatusBar ------------------------------
refreshStatusBar(){
  global mainHwnd, lastSavedName, configFile, appName, appVersion, title
  static stbOld := ""
  
  if WinExist("ahk_id " . mainHwnd) {
    WinActivate
  
    SB_SetText(" " . lastSavedName, 1, 1)
    SB_SetText(" " . configFile , 2, 1)
      
    memory := "[" . GetProcessMemoryUsage() . " MB]      "
    SB_SetText("`t`t" . memory, 3, 2)
    
    title := appName . " " . appVersion . " (" . lastSavedName . ")"
    WinSetTitle, %title%
    
  } else {
    msgbox, StatusBar Error!
  }
  
  return
}
;---------------------------- openAllfilesBetter ----------------------------
openAllfilesBetter(){
  global texteditorpath, wrkDir

  if (texteditorpath != ""){
    filename := StrReplace(StrReplace(wrkDir,":","_"),"\","_") . "_saved.txt"
    run,%texteditorpath% "%filename%"
  } else {
    run, "%filename%"
  }
  
  return
}
;------------------------------- insertString -------------------------------
insertString(insert_string){
; from https://www.autohotkey.com/boards/viewtopic.php?t=60146

  global TempCodeEdit, TempCodeEditHwnd
  
  gui, Submit, NoHide ; Get the info entered in the GUI
  
  VarSetCapacity( StartPos, 4, 0 ), VarSetCapacity( EndPos, 4, 0 )

  SendMessage, 0xB0, &StartPos, &EndPos,, "ahk_id " . %TempCodeEditHwnd% ; EM_GETSEL := 0xB0
  StartPos     := NumGet( &StartPos, 0, "UInt"), EndPos := NumGet( &EndPos, 0, "UInt")
  InsertEndPos   := EndPos+StrLen( insert_string ), StrReplace( SubStr( TempCodeEdit, 1, EndPos ), "`n",, nlCnt ) ; pre-count newlines

  guicontrol, Text, TempCodeEdit, % SubStr( TempCodeEdit, 1, EndPos-nlCnt ) . insert_string . SubStr( TempCodeEdit, (EndPos+1)-nlCnt ) ; Write text back to Edit control
  guicontrol, Focus, TempCodeEdit
  SendMessage, 0xB1, InsertEndPos, InsertEndPos,, "ahk_id " . %TempCodeEditHwnd% ; EM_SETSEL := 0xB1

  return
}
;--------------------------------- HexToDec ---------------------------------
HexToDec(hex) {
    VarSetCapacity(dec, 66, 0)
    , val := DllCall("msvcrt.dll\_wcstoui64", "Str", hex, "UInt", 0, "UInt", 16, "CDECL Int64")
    , DllCall("msvcrt.dll\_i64tow", "Int64", val, "Str", dec, "UInt", 10, "CDECL")
    
    return dec
}
;------------------------------ unicodeTableExt ------------------------------
unicodeTableExt(){

  if (FileExist("..\UnicodeTable\UnicodeTable.exe")){
      run, ..\UnicodeTable\UnicodeTable.exe
    } else {
      msgbox, 16, Error`, an external app is missing!, "..\UnicodeTable\UnicodeTable.exe" not found!
  }
  
  return
}
;----------------------------- selectStartValue -----------------------------
selectStartValue(){
  global mainHwnd, entryListBox, entriesList, wrkdir, hChild
    
  start := 0
  
  file := pathToAbsolut( "unicodesections.txt")
  if (FileExist(file)){
    FileRead, data, % file
    lines := StrSplit(data, "`n")
    entriesList := ""
    for index,line in lines {
      entriesList .= line . "|" 
    }
  } else {
    entriesList := "Enter own value,?|ASCII punctuation and symbols,0x000020|Smileys,0x01F600|Dingbats, 0x002500|"
  }

  gui,unicodeTableSelect:new, +OwnDialogs HwndhChild, Select startvalue
  gui,unicodeTableSelect:add, ListBox, 0x100 x3 y3 r10 w300 ventryListBox gentryListBoxSelected, %entriesList%
  gui,unicodeTableSelect:show, AutoSize
  
  Win_Center(mainHwnd, hChild, 1)
  
  return
}
;--------------------------- entryListBoxSelected ---------------------------
entryListBoxSelected(){
  global mainHwnd, entryListBox, showUnicodeTableIsStart, screenDPI, startValue

  gui,unicodeTableSelect:submit
  gui,unicodeTableSelect:destroy
  
  valueArr := StrSplit(entryListBox,",")
  startValue := valueArr[2]
  
  
  gui,unicodeentryListBox:new, +OwnDialogs HwndhChild2, Start-value: Use %startValue% or enter another (0x0 to 0x10FFFF)
  gui,unicodeentryListBox:add, edit, xm r1 VstartValue w500,%startValue%
  gui,unicodeentryListBox:add, button, xm GunicodeentryListBoxContinue w200, OK

  gui,unicodeentryListBox:show, AutoSize
  
  Win_Center(mainHwnd, hChild2, 1)
  
  return
} 
  
;------------------------ unicodeentryListBoxContinue ------------------------
unicodeentryListBoxContinue(){
  global startValue, showUnicodeTableIsStart
  
  gui,unicodeentryListBox:submit
  gui,unicodeentryListBox:destroy

  v := Min(HexToDec(startValue),1114111)
  
  showUnicodeTableIsStart := Max(v,0)
  
  showUnicodeTable()
  
  return
}
;-------------------------- SetRunButtonUniCodeable --------------------------
SetRunButtonUniCodeable(){
  global isUniCodeTable, ButtonRun, ButtonRunSel, ButtonExit
  
  isUniCodeTable := 1
  
  downArrow := chr(0x25BC)
  upArrow := chr(0x25B2)
  guicontrol,controlArea:, ButtonRun, Down %downArrow%
  guicontrol,controlArea:, ButtonRunSel, Up %upArrow%
  guicontrol,controlArea:, ButtonExit,🗙 Exit UC Table
  
  return
}
;------------------------------ SetRunButtonStd ------------------------------
SetRunButtonStd(){
  global isUniCodeTable, ButtonRun, ButtonRunSel, ButtonExit
  
  isUniCodeTable := 0
  
  guicontrol,controlArea:, ButtonRun, Run
  guicontrol,controlArea:, ButtonRunSel, Run selected
  guicontrol,controlArea:, ButtonExit,🗙 Exit

  return
}
;-------------------------------- showUnicodeTable --------------------------------
showUnicodeTable(){
  global entryListBox, showUnicodeTableIsStart, showUnicodeTableIsShown
  global actualContent, contentIsTemporary
  
  SetRunButtonUniCodeable()
  
  actualContent := getTextFromSCI()
  contentIsTemporary := 1
  showUnicodeTableIsShown := 1
  
  hotkey, !Up, On
  hotkey, !Down, On
  hotkey, !Enter, On
  hotkey, F1, On
  hotkey, F2, On
  hotkey, F3, On
  
  showUnicodeTableFunc()
  
  return
}

;------------------------------ showQuickHelp ------------------------------
showQuickHelp(){
  global mainHwnd, quickHelpVisible
  
  if (!quickHelpVisible){
    quickHelpVisible := 1

    helpText := "
(
Besides the buttons you may use:
F1 to toggle this quick-help

Alt +  Up/Down to jump a block
Alt + ENTER to close UnicodeTable
Use CTRL + mousewheel to zoom!

F2 shows the clipboard contents as UTF-8
F3 shows the clipboard contents as URI
)"

    showHintColoredRefresh(mainHwnd, helpText, 0)
  } else {
    gui, hintColored:Destroy
    quickHelpVisible := 0
  }
  
  return
}
;--------------------------- showClipboardAs_UTF8 ---------------------------
showClipboardAs_UTF8(){
; based on: https://rosettacode.org/wiki/UTF-8_encode_and_decode#AutoHotkey
  global mainHwnd
  
  UTFCode8 := ""
  result := ""
  s := clipboard
  
  loop, parse, s, `n, `r
  {
    UTFCode8 := ""
    hex := format("{1:#6.6X}", Ord(A_LoopField))
    Bytes :=  hex>=0x10000 ? 4 : hex>=0x0800 ? 3 : hex>=0x0080 ? 2 : hex>=0x0001 ? 1 : 0
    Prefix := [0, 0xC0, 0xE0, 0xF0]

    loop, %Bytes%
    {
      if (A_Index < Bytes)
        UTFCode8 := Format("{:X}", (hex&0x3F) + 0x80) . UTFCode8    ; 3F=00111111, 80=10000000
      else
        UTFCode8 := Format("{:X}", hex + Prefix[Bytes]) . UTFCode8  ; C0=11000000, E0=11100000, F0=11110000
      hex := hex>>6
    }
    result .= UTFCode8
  }
  output := "Character: " s "`nUTF-8 (Clipboard): " result
  clipboard := result
  showHintColoredRefresh(mainHwnd, output, 10000)
  
  return
}
;---------------------------- showClipboardAs_URI ----------------------------
showClipboardAs_URI(){
; based on: https://rosettacode.org/wiki/UTF-8_encode_and_decode#AutoHotkey
  global mainHwnd
  
  UTFCode8 := ""
  result := ""
  s := clipboard
  
  sBasic := StrReplace(s, "%", "%25")
  
  loop, Parse, sBasic, `n, `r
  {
    hex := format("{1:#6.6X}", Ord(A_LoopField))
    Bytes :=  hex>=0x10000 ? 4 : hex>=0x0800 ? 3 : hex>=0x0080 ? 2 : hex>=0x0001 ? 1 : 0
    Prefix := [0, 0xC0, 0xE0, 0xF0]
    if (hex>=0x0080){
      UTFCode8 := ""
      loop, %Bytes%
      {
        if (A_Index < Bytes)
          UTFCode8 := "%" Format("{:X}", (hex&0x3F) + 0x80) . UTFCode8    ; 3F=00111111, 80=10000000
        else
          UTFCode8 := "%" Format("{:X}", hex + Prefix[Bytes]) . UTFCode8  ; C0=11000000, E0=11100000, F0=11110000
        hex := hex>>6
      }
    } else {
      UTFCode8 := A_LoopField
    }
    result .= UTFCode8
  }

  result := StrReplace(result, " ", "%20")
  result := StrReplace(result, "`n", "%0A")
  result := StrReplace(result, "`r`n", "%0A")
  
  result := StrReplace(result, "?", "%3F")
  result := StrReplace(result, "&", "%26")


  output := "Character: " . s . "`nURI (Clipboard): " . result
  clipboard := result
  showHintColoredRefresh(mainHwnd, output, 10000)
  
  return
}
;--------------------------- showUnicodeTableFunc ---------------------------
showUnicodeTableFunc(){
  global mainHwnd, showUnicodeTableIsStart, sci, fontsizeSCI, fontSCIUnicodeTab
  
  ; force a non proportional font
  setfontSCI := fontSCIUnicodeTab
  sci.StyleSetFont(32, setfontSCI)
  sci.StyleSetSize(32, fontsizeSCI)
  sci.StyleClearAll()

  allUniStrings := "Help:F1 "
  
  loop, 16
  {
    n := A_Index - 1
    allUniStrings .= Format("{:02.2X}",n) . "`t"
  }

  allUniStrings .= "`n"
  
  loop, 32
  {
    i := A_Index - 1
    h := showUnicodeTableIsStart + i * 16
    allUniStrings .= Format("{:06.6X}",h) . "`t"
    loop, 16
    {
      j := A_Index - 1
      uniString := Chr(showUnicodeTableIsStart + (i * 16 + j))
      allUniStrings .= uniString . "`t"
    }
    allUniStrings .= "`n"
  }

  sciSetText(allUniStrings)
    
  ;end := showUnicodeTableIsStart + i * 16 + j
 
  return
}
;---------------------------- showUnicodeTableUp ----------------------------
showUnicodeTableUp(){
  global showUnicodeTableIsStart
  
  showUnicodeTableIsStart -= 512
  showUnicodeTableIsStart := Max(showUnicodeTableIsStart,1)
  showUnicodeTableFunc()

  return
}
;--------------------------- showUnicodeTableDown ---------------------------
showUnicodeTableDown(){
  global showUnicodeTableIsStart
  
  showUnicodeTableIsStart += 512
  showUnicodeTableIsStart := Min(showUnicodeTableIsStart,1114111) ; => 0X10FFFF max
  showUnicodeTableFunc()

  return
}
;--------------------------- showUnicodeTableStop ---------------------------
showUnicodeTableStop(){
  global actualContent , showUnicodeTableIsShown, contentIsTemporary, sci, fontSCI, fontsizeSCI

  hotkey, !Up, Off
  hotkey, !Down, Off
  hotkey, !Enter, Off
  hotkey, F1, Off
  hotkey, F2, Off
  hotkey, F3, Off
  
  tooltip,
  
  sci.clearAll()
    
  sciSetText(actualContent)
  
  showUnicodeTableIsShown := 0
  contentIsTemporary := 0
  
  ; reset font
  setfontSCI := fontSCI
  sci.StyleSetFont(32, setfontSCI)
  sci.StyleSetSize(32, fontsizeSCI)
  sci.StyleClearAll()
  
  SetRunButtonStd()
  
  return
}
;---------------------------------- preview ----------------------------------
preview(){
  global sciDebug, saveFile, saveFileExtension, saveDir, exchFile
  
  s := ""
  
  loop, 3
  {
    Try
    {
      line1 := ""
      dir := pathToAbsolut(saveDir)
      FileReadLine, line1, %dir%%exchFile%%A_Index%%saveFileExtension%, 1
     }
    catch e
    {
    }
    if (ErrorLevel)
      s .= "Exch " . A_Index . ":`n`n`n"
    else
      s .= "Exch " . A_Index . ":`n" . SubStr(line1,1,20) . "`n`n"
  }
  
  s .= "`n"
  loop, 3
  {
    Try
    {
      line1 := ""
      dir := pathToAbsolut(saveDir)
      FileReadLine, line1, %dir%%saveFile%%A_Index%%saveFileExtension%, 1
    }
    catch e
    {
    }
    if (ErrorLevel)
      s .= "Save " . A_Index . ":`n`n`n" 
    else
      s .= "Save " . A_Index . ":`n" . SubStr(line1,1,20) . "`n`n" 
    
  }
  
  debugSetText(s)
  
  return 
}
;---------------------------------- save123 ----------------------------------
save123(){
  global mainHwnd, sci, saveFile, saveFileExtension, saveDir
  
  number := 1
  if (eq(A_guicontrol,"Button12"))
    number := 1
  if (eq(A_guicontrol,"Button13"))
    number := 2
  if (eq(A_guicontrol,"Button14"))
    number := 3
    
  sci.GetText(sci.getLength(), theCode) 

  Try
  {
    filename := pathToAbsolut(saveDir) . saveFile . number . saveFileExtension
    if (FileExist(filename))
      FileDelete, %filename%
      
    FileAppend,
(
%theCode%
), %filename%
  }
  catch e
  {
    eMsg  := e.Message
    msgArr := {}
    msgArr.push("Error: " . eMsg)
    msgArr.push("Closing Updater due to an error!")
    
    errorExit(msgArr, url)
  }

  msg := "Saved to " . filename
  showHintColoredRefresh(mainHwnd, msg)
   
  
  preview()
  
  return
}
;---------------------------------- read123 ----------------------------------
read123(){
  global sci, saveFile, saveFileExtension, saveDir
  
  ; using hard-coded button-names
  number := 1
  if (eq(A_guicontrol,"Button15"))
    number := 1
  if (eq(A_guicontrol,"Button16"))
    number := 2
  if (eq(A_guicontrol,"Button17"))
    number := 3

  filename := pathToAbsolut(saveDir) . saveFile . number . saveFileExtension
  
  if (FileExist(filename)){
    if (!forced){
      msgbox,49,ATTENTION, Opening the file: %filename%`n`n*** Overwrites your actual code! ***
      IfMsgBox Cancel
        return
    }
      
    filenhandle := FileOpen(filename,"r")
    theCode := filenhandle.Read()
    filenhandle.Close()
    
    sci.clearAll()
    
    sciSetText(theCode)

    sci.GrabFocus()

    Winset, Redraw, , A
  } else {
    msgbox,48,ERROR,File %filename% not found!
  }
  
  return
}
;----------------------------- exchSignalActive -----------------------------
exchSignalActive(number){
  global mainHwnd

  if (number == 1 || number == 2 || number == 3){
    exchSignalLightActive(number)
  } else {
    exchSignalLightActive(0)
  }
  
  return
}
;--------------------------- exchSignalLightActive ---------------------------
exchSignalLightActive(number){
  global exch1P, exch2P, exch3P

  if (number == 1 || number == 2 || number == 3){
    guicontrol,controlArea:,exch%number%P,+100
  } else {
    guicontrol,controlArea:,exch1P,0
    guicontrol,controlArea:,exch2P,0
    guicontrol,controlArea:,exch3P,0
  }
    
  return
}
;---------------------------------- exch123 ----------------------------------
exch123(){
  ; using hard-coded button-names
  global exch, contentIsTemporary
  
  if (contentIsTemporary){
    msgbox, Cannot use exchange while a temporary content is loaded!
  } else {
    number := 0
    previousExch := []
    
    loop,3 {
      previousExch[A_Index] := exch[A_Index]
    }
   
    exch123Reset()
    
    if (eq(A_guicontrol,"Button27")){
      number := 1
    }
    if (eq(A_guicontrol,"Button28")){
      number := 2
    }
    if (eq(A_guicontrol,"Button29")){
      number := 3
    }
    
    if (!previousExch[number])
      exch[number] := true 
    
    if (exch[number]){
      exch123SaveExchanged(number)
      exchSignalActive(number)
    }
  }
  
  return
}
;------------------------------- exch123Reset -------------------------------
exch123Reset(){
  global exch
  
  number := 0
  
  if (!exch[1] && !exch[2] && !exch[3])
    return
  
  ; only one can be active at a time
  loop, 3 {
    if (exch[A_Index]){
      exch123SaveExchanged(A_Index)
      exch[A_Index] := false
    }
  }
  
  exchSignalActive(0)

  return
}
;--------------------------- exch123SaveExchanged ---------------------------
exch123SaveExchanged(number){
  global sci, saveFile, saveFileExtension, saveDir, exchFile, exch
  
  ; save current
  codeSave := ""
  l := sci.getLength()
  if (l > 0)
    sci.GetText(sci.getLength(), codeSave) 
  
  ; read exchFile%number%
  filename := pathToAbsolut(saveDir) . exchFile . number . saveFileExtension
  if (FileExist(filename)){  
    filenhandle := FileOpen(filename,"r")
    theCode := filenhandle.Read()
    filenhandle.Close()
    
    sci.clearAll()
    
    sciSetText(theCode)
    
    sci.GrabFocus()
  } else {
    sci.SETUNDOCOLLECTION(0)
    sci.clearAll()
    sci.SETUNDOCOLLECTION(1)
    theCode := ""
  }
           
  Winset, Redraw, , A
  
  ; save "old" content to exchFile%number%
  Try
  {
    if (FileExist(filename))
      FileDelete, %filename%
      
    FileAppend,
(
%codeSave%
), %filename%
  }
  catch e
  {
    eMsg  := e.Message
    msgArr := {}
    msgArr.push("Error: " . eMsg)
    msgArr.push("Closing Updater due to an error!")
    
    errorExit(msgArr, url)
  }    
    
  preview()

  return
}
;----------------------------- loadFileFromSaved -----------------------------
loadFileFromSaved(){
  global sci, lastSavedName, theCode
    
  FileSelectFile, filename , 3, _saved\, Open a file from _saved\

  if (!ErrorLevel){
    msgbox,49,ATTENTION, Open the file: %filename%`n`n*** Overwrites your actual code! ***
    IfMsgBox Cancel
        return
      
    file := FileOpen(filename, "r")
    theCode := file.Read()
    file.Close()
    
    sciSetText(theCode)
    sci.GrabFocus()
    
    SplitPath, filename , lastSavedName
    
    restart()
  }
  
  return
}
;--------------------------------- loadFile ---------------------------------
loadFile(){
  global sci, wrkDir, lastSavedName, theCode

  FileSelectFile, filename , 3,%wrkDir%, Open a file from .\

  if (!ErrorLevel){
    msgbox,49,ATTENTION, Open the file: %filename%`n`n*** Overwrites your actual code! ***
    IfMsgBox Cancel
        return
      
    file := FileOpen(filename, "r")
    theCode := file.Read()
    file.Close()
    
    sciSetText(theCode)
    sci.GrabFocus()
        
    SplitPath, filename , lastSavedName
    
    restart()
  }

  return
}
;----------------------------- startCheckUpdate -----------------------------
startCheckUpdate(){
  global mainHwnd, appname, appnameLower, localVersionFile, server

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(server . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showHintColoredRefresh(mainHwnd, msg1)
      
    } else {
      msg2 := "No new version available (" . localVersion . " -> " . remoteVersion . ")"
      showHintColoredRefresh(mainHwnd, msg2)
    }
  } else {
    showHintColoredRefresh(mainHwnd, "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")")
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){
  
  versionLocal := 0.000
  if (FileExist(file)){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  { 
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push("URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
}
;---------------------------- Receive_WM_COPYDATA ----------------------------
; from: https://www.autohotkey.com/boards/viewtopic.php?t=9598

Receive_WM_COPYDATA(wParam, lParam) {
  global debugTextAll

  gui, guiMain:show
    
  DataReceived := StrGet(NumGet(lParam + A_PtrSize * 2),(NumGet(lParam + A_PtrSize)-1)/2)
  s := b64Decode(DataReceived)
  debugTextAll .= s . "`n"
  FileAppend, %s%`n, debug.log, UTF-8-RAW
  
  settimer,show_it, -1

  return true
}
;---------------------------------- show_it ----------------------------------
show_it(){
  global sciDebug, debugTextAll
  
  FileRead, s, debug.log

  debugSetText(s)

  sciDebug.SCROLLTOEND()
  
  return
}
;-------------------------- showHintColoredRefresh --------------------------
showHintColoredRefresh(handle, s := "", n := 3000, refresh := 0, fg := "cFFFFFF", bg := "a900ff", newfont := "", newfontsize := ""){
  global font, fontsize
  
  if (newfont == "")
    newfont := font
    
  if (newfontsize == "")
    newfontsize := fontsize
  
  gui, hintColored:new, hwndhHintColored +parentGuiMain +ownerGuiMain +0x80000000
  gui, hintColored:font, s%newfontsize%, %newfont%
  gui, hintColored:font, c%fg%
  gui, hintColored:Color, %bg%
  gui, hintColored:add, Text,, %s%
  gui, hintColored:-Caption
  gui, hintColored:+ToolWindow
  gui, hintColored:+AlwaysOnTop
  gui, hintColored:Show

  WinCenter(handle, hHintColored, 1)
  if (n > 0){
    WinActivate, ahk_id %handle%
    sleep, n
    gui, hintColored:Destroy
  }
  
  if (refresh){
    restart()
  }
  
  WinActivate, ahk_id %handle%
  
  return
}
;--------------------------------- WinCenter ---------------------------------
; from: https://www.autohotkey.com/board/topic/92757-win-center/
WinCenter(handle, hChild, Visible := 1) {
    DetectHiddenWindows On
    WinGetPos, X, Y, W, H, ahk_ID %handle%
    WinGetPos, _X, _Y, _W, _H, ahk_ID %hChild%
    If Visible {
        SysGet, MWA, MonitorWorkArea, % WinMonitor(handle)
        X := X+(W-_W)//2, X := X < MWALeft ? MWALeft+5 : X, X := (X + _W) > MWARight ? MWARight-_W-5 : X
        Y := Y+(H-_H)//2, Y := Y < MWATop ? MWATop+5 : Y, Y := (Y + _H) > MWABottom ? MWABottom-_H-5 : Y
    } Else X := X+(W-_W)//2, Y := Y+(H-_H)//2
    WinMove, ahk_ID %hChild%,, %X%, %Y%
    WinShow, ahk_ID %hChild%
    }
;-------------------------------- WinMonitor --------------------------------
WinMonitor(hwnd, Center := 1) {
    SysGet, MonitorCount, 80
    WinGetPos, X, Y, W, H, ahk_ID %hwnd%
    Center ? (X := X+(W//2), Y := Y+(H//2))
    loop %MonitorCount% {
      SysGet, Mon, Monitor, %A_Index%
      if (X >= MonLeft && X <= MonRight && Y >= MonTop && Y <= MonBottom)
          Return A_Index
    }
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}
;------------------------------- stringToNativ -------------------------------
stringToNativ(s){
  vSize := StrPut(s, "CP0")
  VarSetCapacity(vUtf8, vSize)
  vSize := StrPut(s, &vUtf8, vSize, "CP0")
  ; returns native coding
  return StrGet(&vUtf8, "utf-8") 
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;--------------------------------- b64Decode ---------------------------------
b64Decode(b64_string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &b64_string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", b64_size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(b64_buf, b64_size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &b64_string, "uint", 0, "uint", 0x1, "ptr", &b64_buf, "uint*", b64_size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&b64_buf, b64_size, "UTF-8")
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {
 
  PostMessage("Slave script", 0x0001) ; exits/deletes slave script
  exch123Reset()
  makePerma()
  
  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%
  
  exit()
}
;------------------------------- center_MsgBox -------------------------------
; OnMessage(0x44, "center_MsgBox")

center_MsgBox(P) {
  global mainHwnd, windowPosX, windowPosY, clientWidth, clientHeight

  if (P == 1027) {
    ownPID := DllCall("GetCurrentProcessId")
    if WinExist("ahk_pid " . ownPID) {
      WinGet, State, MinMax
      if !(State == -1) {
        DetectHiddenWindows, On
        if WinExist("ahk_class #32770 ahk_pid " . ownPID) {
          WinGetPos,,,mW,mH
          WinMove,(clientWidth - mW) / 2 + windowPosX, (clientHeight - mH) / 2 + windowPosY
        }
      }
    }
  }
  
  return true
}
;-------------------------------- Win_Center --------------------------------
Win_Center(handle, hChild, Visible := 0) {
  DetectHiddenWindows On
  WinGetPos, X, Y, W, H, ahk_ID %handle%
  WinGetPos, _X, _Y, _W, _H, ahk_ID %hChild%
  If Visible {
    SysGet, MWA, MonitorWorkArea, % Win_Monitor(handle)
    X := X+(W-_W)//2, X := X < MWALeft ? MWALeft+5 : X, X := (X + _W) > MWARight ? MWARight-_W-5 : X
    Y := Y+(H-_H)//2, Y := Y < MWATop ? MWATop+5 : Y, Y := (Y + _H) > MWABottom ? MWABottom-_H-5 : Y
} Else X := X+(W-_W)//2, Y := Y+(H-_H)//2
  WinMove, ahk_ID %hChild%,, %X%, %Y%
  WinShow, ahk_ID %hChild%
  return
}
;-------------------------------- Win_Monitor --------------------------------
Win_Monitor(handle, Center := 1) {
  SysGet, MonitorCount, 80
  WinGetPos, X, Y, W, H, ahk_ID %handle%
  Center ? (X := X+(W//2), Y := Y+(H//2))
  loop %MonitorCount% {
    SysGet, Mon, Monitor, %A_Index%
    if (X >= MonLeft && X <= MonRight && Y >= MonTop && Y <= MonBottom)
        Return A_Index
    }
    
  return
}
;----------------------------- htmlViewerOffline -----------------------------
htmlViewerOffline(){
  htmlViewer(0)

  return
}
;----------------------------- htmlViewerOnline -----------------------------
htmlViewerOnline(){
  htmlViewer(1)

  return
}
;-------------------------- htmlViewerOnlineReadme --------------------------
htmlViewerOnlineReadme(){
  global appnameLower
  
  htmlViewer(1, "https://xit.jvr.de/" . appnameLower . "_readme.html")

  return
}
;------------------------------- htmlViewer -------------------------------
htmlViewer(forceOnline := 0, url := ""){
  global mainHwnd, winIsHidden
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB
  global appnameLower
  
  clientWidthHtmlViewer := coordsScreenToApp(A_ScreenWidth * 0.6)
  clientHeightHtmlViewer := coordsScreenToApp(A_ScreenHeight * 0.6)

  WinSet, Style, -alwaysOnTop, ahk_id %mainHwnd% 
  winIsHidden := 1
  gui,guiMain:Hide

  gui, htmlViewer:Destroy
  gui, htmlViewer:new,-0x100000 -0x200000 +alwaysOnTop +resize +E0x08000000 hwndhHtmlViewer,Short Help
  gui, htmlViewer:add, ActiveX, x0 y0 w%clientWidthHtmlViewer% h%clientHeightHtmlViewer%  +VSCROLL +HSCROLL vWB, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge">

  gui, htmlViewer:add, StatusBar
  SB_SetParts(400,300)
  SB_SetText("Use CTRL + mousewheel to zoom in/out!", 1, 1)

  htmlFile := "shorthelp.html"
  
  if (url == "")
    url := "https://xit.jvr.de/" . appnameLower . "_shorthelp.html"

  failed := 0
  if (!forceOnline){
    if (FileExist(htmlFile)){
      FileEncoding, UTF-8
      FileRead, data, %htmlFile%
      if (!ErrorLevel){
        doc := wb.document
        doc.write(data)
      } else {
        failed := 1
      }
    } else {
      failed := 1
    }
    if (failed){
      WB.Navigate(url)
      SB_SetText("(Local help-file not found, using online version) Use CTRL + mousewheel to zoom in/out!", 1, 1)
    }
  } else {
    WB.Navigate(url)
  }

  gui, htmlViewer:Show, center
  
  guicontrol, -HScroll -VScroll, ahk_id %htmlViewer%
  
  return
}
;----------------------------- htmlViewerGuiSize -----------------------------
htmlViewerGuiSize(){
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB

  if (A_EventInfo != 1) {
    statusBarSize := 20
    clientWidthHtmlViewer := A_GuiWidth
    clientHeightHtmlViewer := A_GuiHeight - statusBarSize

    guicontrol, Move, WB, % "w" clientWidthHtmlViewer " h" clientHeightHtmlViewer
  }
  
  return
}
;---------------------------- htmlViewerGuiClose ----------------------------
htmlViewerGuiClose(){
  global mainHwnd, winIsHidden

  WinSet, Style, +alwaysOnTop, ahk_id %mainHwnd% 
  winIsHidden := 0
  gui,guiMain:show

  return
}
;------------------------------- editConfigFile -------------------------------
; non SCI version
editConfigFile(){
  global configFile, configFileContent, clientWidth, clientHeight, localConfigDir
  
  saveConfig()
  
  gui,guiMain:Hide

  if (FileExist(configFile)){
    theFile := FileOpen(configFile,"r")
    
    if !IsObject(theFile) {
        msgbox, Error, can't open "%configFile%" for reading, exiting to prevent a data loss!
        exitApp
    } else {
      data := theFile.Read()
      theFile.Close()
      
      configFileContent := data
      
      borderX := 10
      borderY := 50
      
      h := clientHeight - borderY
      w := clientWidth - borderX
      
      gui, editConfigFile:new, +resize +AlwaysOnTop,Edit: %configFile%`, (autosaved on close`, copied to %localConfigDir%%configFile% also!)
      gui, editConfigFile:font, s9, Segoe UI
      gui, editConfigFile:add, edit, x0 y0 w0 h0
      gui, editConfigFile:add, edit, h%h% w%w% VconfigFileContent,%data%
      
      gui, editConfigFile:show,center autosize
    }
  } else {
    msgbox, Error, file not found: %theFile% !
  }
  
  return
}
;--------------------------- editConfigFileGuiClose ---------------------------
editConfigFileGuiClose(){
  global appname, configFile, configFileContent
  global directive2
  
  gui,editConfigFile:submit,nohide
  
  theFile := FileOpen(configFile,"w")
  
  if (!IsObject(theFile)) {
      msgbox, Error`, can't open "%configFile%" for writing!
  } else {
    theFile.Write(configFileContent)
    theFile.Close()
    
    syncAppDataWrite()

    gui, editConfigFile:Destroy
    
    readConfig()
    
    restart()
  }
  
  return
}
;---------------------------- editConfigFileGuiSize ----------------------------
editConfigFileGuiSize(){

   if (A_EventInfo != 1) {
    editConfigFileWidth := A_GuiWidth
    editConfigFileHeight := A_GuiHeight

    borderX := 10
    borderY := 50
    
    w := editConfigFileWidth - borderX
    h := editConfigFileHeight - borderY

    guicontrol, Move, configFileContent, h%h% w%w%
  }

  return
}
;---------------------------- activateCodeTester ----------------------------
activateCodeTester(){
  gui, guiMain:Show
}
;-------------------------------- copyToNPPP --------------------------------
copyToNPPP(){
; uses the clipboard

  s := getTextFromSCI()

  clipboard := s
  ClipWait, 5000
  sleep, 1000
  
  DetectHiddenWindows, ON
  If(WinExist("Notepad++")){
    StringReplace, s, s, `n, `r`n, All
    
    ControlGet, isVisble2, Visible ,, Scintilla2, Notepad++
    if(isVisble2){
      ControlSend, Scintilla2,{CTRL down}{v}{CTRL up}, Notepad++
    } else {
      ControlGet, isVisble1, Visible,, Scintilla1, Notepad++
      if(isVisble1){
        ControlSend, Scintilla1,{CTRL down}{v}{CTRL up}, Notepad++
      } else {
        msgbox, Notepad++ control "Scintilla1" is not accessible!
      }
    }
  } else {
    msgbox, Notepad++ is not running!
  }
  
  WinActivate, ahk_class Notepad++
  WinSet, AlwaysOnTop , On, ahk_class Notepad++
  WinSet, AlwaysOnTop , Off, ahk_class Notepad++
  
  return
}
;------------------------------- getFromNPPP -------------------------------
getFromNPPP(){

  s := ""
  
  ControlGet, isVisble2, Visible ,, Scintilla2, Notepad++
  if(isVisble2){
    ControlSend, Scintilla2,{CTRL down}{a}{CTRL up}, Notepad++
    ControlGetText, s, Scintilla2, Notepad++
  } else {
    ControlGet, isVisble1, Visible ,, Scintilla1, Notepad++
    if(isVisble1){
      ControlSend, Scintilla1,{CTRL down}{a}{CTRL up}, Notepad++
      ControlGetText, s, Scintilla1, Notepad++
    }
  }
  
  sciSetText(s)

  activateCodeTester()

  return
}
;------------------------------ copyToScintilla ------------------------------
copyToSciTE(){
; uses the clipboard

  s := getTextFromSCI()

  clipboard := s

  sleep, 1000
  
  DetectHiddenWindows, ON
  If(WinExist("Notepad++")){
    StringReplace, s, s, `n, `r`n, All
    
    ControlGet, isVisble1, Visible ,, Scintilla1, ahk_class SciTEWindow
    if(isVisble1){
      ControlSend, Scintilla1, {CTRL down}{v}{CTRL up}, ahk_class SciTEWindow
    }
  } else {
    msgbox, SciTE is not running!
  }
  
  WinActivate, ahk_class SciTEWindow
  WinSet, AlwaysOnTop , On, ahk_class SciTEWindow
  WinSet, AlwaysOnTop , Off, ahk_class SciTEWindow
  
  return
}
;----------------------------- getFromScintilla -----------------------------
getFromSciTE(){
  
  s := ""
  
  ControlGet, isVisble1, Visible ,, Scintilla1, ahk_class SciTEWindow
  if(isVisble1){
    ControlSend, Scintilla1,{CTRL down}{a}{CTRL up}, ahk_class SciTEWindow
    ControlGetText, s, Scintilla1, ahk_class SciTEWindow
  }
  
  sciSetText(s)
  
  activateCodeTester()

  return
}
;---------------------------------- newFile ----------------------------------
newFile(){
  global clipboardSave, lastSavedName
  global clipboardKeep

  PostMessage("Slave script", 0x0001) ; exits/deletes slave script
  exch123Reset()
  
  lastSavedName := ""
  
  saveConfig()
  saveGuiData()
  syncAppDataWrite()
  
  if (FileExist("_codetester.txt"))
    FileDelete, _codetester.txt
    
  FileAppend, #Requires AutoHotkey v2`n`n, _codetester.txt
  
  if (clipboardKeep)
    clipboard := clipboardSave

  reload

  exitApp
}
;---------------------------------- restart ----------------------------------
restart(){
  global clipboardSave, clipboardKeep
  
    PostMessage("Slave script", 0x0001) ; exits/deletes slave script
    exch123Reset()
    makePerma()
    saveConfig()
    saveGuiData()
    syncAppDataWrite()
    if (clipboardKeep)
      clipboard := clipboardSave

    reload
    
    exitApp
}
;----------------------------------- Exit -----------------------------------
exit(){
  global clipboardSave, clipboardKeep
  
  PostMessage("Slave script", 0x0001) ; exits/deletes slave script
  exch123Reset()
  makePerma()
  saveConfig()
  saveGuiData()
  syncAppDataWrite()
  if (clipboardKeep)
    clipboard := clipboardSave
  
  ExitApp
}

;----------------------------- testExternalCode1 -----------------------------
testExternalCode1(){
  global disableCodeModifications, useAhkVersion2
  
  c := clipboard
  selectedCode := "#Requires AutoHotkey v1`n`n" . c
  ; msgbox,%selectedCode%
  disableCodeModificationsSave := disableCodeModifications
  useAhkVersion2Save := useAhkVersion2
  disableCodeModifications := 1
  useAhkVersion2 := 0
  testTempCode(selectedCode)
  disableCodeModifications := disableCodeModificationsSave
  useAhkVersion2 := useAhkVersion2Save

return
}
;----------------------------- testExternalCode2 -----------------------------
testExternalCode2(){
  global disableCodeModifications, useAhkVersion2
  
  c := clipboard
  selectedCode := "#Requires AutoHotkey v2`n`n" . c
  ; msgbox,%selectedCode%
  disableCodeModificationsSave := disableCodeModifications
  useAhkVersion2Save := useAhkVersion2
  disableCodeModifications := 1
  useAhkVersion2 := 1
  testTempCode(selectedCode)
  disableCodeModifications := disableCodeModificationsSave
  useAhkVersion2 := useAhkVersion2Save

return
}

;------------------------------ hotkeyConverter ------------------------------
hotkeyConverter(){

  run, hotkeyConverter2.exe
  
 return
}
;----------------------------------------------------------------------------
