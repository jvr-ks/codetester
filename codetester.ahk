;------------------------------ codetester.ahk ------------------------------
; from: https://autohotkey.com/board/topic/72566-code-tester-test-your-code/
; modified by jvr 2020

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
#Persistent

FileEncoding, UTF-8-RAW

appName := "Codetester"
appVersion := "0.040"
app := appName . " " . appVersion
iniFileName := A_ScriptDir . "codetester.ini"

ahkexepathDefault := "C:\Program Files\AutoHotkey\AutoHotkey.exe"
ahkexepath := ahkexepathDefault

FileCreateDir, %A_ScriptDir%\saved

theCode := ""
if (FileExist(A_ScriptDir . "\_codetester.txt") != ""){
	f := FileOpen("_codetester.txt","r")
	theCode := f.Read()
	f.Close()
}


TempCode := ""

testMarkedCodeHotkeyDefault := "^u"
testMarkedCodeHotkey := testMarkedCodeHotkeyDefault

SetTitleMatchMode, 2 

;OnExit("exit") ; On exit, clean up

readIni()
showMenu()

return

;------------------------------- showMenuReset -------------------------------
showMenuReset(){
	readIni()
	showMenu()
	
	return
}
;--------------------------------- showMenu ---------------------------------
showMenu() {
	global testMarkedCodeHotkey
	global theCode
	global TempCode
	global app
	global appVersion
	
	xStart := 3
	yStart := 3
	
	editWidth := 500
	editHeight := 400
	
	buttoAreaStart := editHeight + 5
	guiHeight := buttoAreaStart + 100
	
	buttonWidth := 100
	buttonWidthSmall := 50
	buttonHeight := 35
	
	deltaX1 := 105
	deltaX2 := 55
	
	Gui, Destroy
	Gui,New, +LastFound

	Gui, Add, Edit, w0 h0 ; focus dummy
	
	Gui, Add, Edit, x%xStart% y%yStart% w%editWidth% h%editHeight% t8 t16 t24 t32 t40 t48 WantTab vTempCode, %theCode%

	Gui, Font, S10 CDefault Bold, Times New Roman

	Gui, Add, Button, x%xStart% yp+%buttoAreaStart% w%buttonWidth% h%buttonHeight% gstartTestTempCode, Test code

	testMarkedCodeHotkeyText := hotkeyToText(testMarkedCodeHotkey)

	Gui, Add, Text, xp+%deltaX1% yp+0 w%buttonWidth% h%buttonHeight%, Test marked code`r%testMarkedCodeHotkeyText%

	Gui, Add, Button, xp+%deltaX1% yp+0 w%buttonWidth% h%buttonHeight% gEndTest, End test

	Gui, Add, Button, xp+%deltaX1% yp+0 w%buttonWidthSmall% h%buttonHeight% gClearTempCode, Clear

	Gui, Add, Button, xp+%deltaX2% yp+0 w%buttonWidthSmall% h%buttonHeight% gopenGithubPage, Git

	Gui, Add, Button, xp+%deltaX2% yp+0 w%buttonWidthSmall% h%buttonHeight% gexit, Exit
	
	Gui, Add, Button, x%xStart% yp+%buttonHeight%+%yStart% w%buttonWidth% h%buttonHeight% gsave, Save
	
	Gui, Add, Button, xp+%buttonWidth% yp+0 w%buttonWidth% h%buttonHeight% gopenFilemanager, Filemanager`nin saved\
	
	Gui, Add, Button, xp+%buttonWidth% yp+0 w%buttonWidth% h%buttonHeight% ggetFromNotepad, Get code from notepad++
	
	Gui, Add, Button, xp+%buttonWidth% yp+0 w%buttonWidth% h%buttonHeight% gOpenAwesome, Awesome Autohotkey web

	Gui, Add, StatusBar,,

	mem := GetProcessMemoryUsage()
	SB_SetText(" Tip: Use SciTE4AutoHotkey for advanced editing and debugging! [" . mem " MB]",1,1)
	
	versname := app
	vers := getVersionFromGithub()
	if (vers != "unknown!"){
		if (vers != appVersion){
			SB_SetText(" New version available!",1,1)
		}
	}		
	
	setTimer,showPid,-1000
	
	Gui, Show, xCenter yCenter AutoSize, %app%

	return
}
;-------------------------------- OpenAwesome --------------------------------
OpenAwesome(){

	run,http://ahkscript.org/joedf/awesome-autohotkey/
	
	return
}
;---------------------------------- showPid ----------------------------------
showPid(){
	global app
	
	WinGet, thePID, PID, A

	t := app . " (pid: " . thePID ")"
	;WinSetTitle, WinTitle, WinText, NewTitle 
	WinSetTitle,ahk_pid %thePID%,, %t%
	
	return
}
;------------------------------ getFromNotepad ------------------------------
getFromNotepad(){
	global TempCode
	
	DetectHiddenWindows, On

	notepadID := WinExist("ahk_class Notepad++")
	
	if(notepadID > 0){
		Winactivate,ahk_id %notepadID%
		sleep,1000
		send, ^a^c{Click}
	} else {
		msgbox, Notepad++ not open!
	}

	codetesterID := WinExist("ahk_exe codetester.exe")
	
	if(codetesterID > 0){
		Winactivate,ahk_id %codetesterID%
		sleep,1000
		
		s := clipboard
	
		MsgBox, 1,, Overwrite all the current code? (press OK or Cancel)
		IfMsgBox OK
			GuiControl,,TempCode,%s%
		else
			MsgBox You pressed Cancel.

	} else {
		msgbox, codetester.exe not running!
	}

	return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
	global appName
	
	StringLower, name, appName
	Run https://github.com/jvr-ks/%name%
	return
}
;--------------------------- getVersionFromGithub ---------------------------
getVersionFromGithub(){
	global appName
	
	r := "unknown!"
	StringLower, name, appName
	url := "https://github.com/jvr-ks/" . name . "/raw/master/version.txt"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", url)
	whr.Send()
	Sleep 500
	status := whr.Status
	if (status == 200)
		r := whr.ResponseText

	return r
}
;---------------------------------- readIni ----------------------------------
readIni(){
	global iniFileName
	global testMarkedCodeHotkeyDefault
	global testMarkedCodeHotkey
	global ahkexepathDefault
	global ahkexepath
	
	IniRead, testMarkedCodeHotkey, %iniFileName%, hotkeys, testMarkedCodeHotkey, %testMarkedCodeHotkeyDefault%
	if (InStr(testMarkedCodeHotkey, "off") > 0){
		sIni := StrReplace(testMarkedCodeHotkey, "off" , "")
		Hotkey, %sIni%, testMarkedCode, off
	} else {
		Hotkey, %testMarkedCodeHotkey%, testMarkedCode
	}
	
	IniRead, ahkexepath, %iniFileName%, external, ahkexepath, %ahkexepathDefault%
	
	return
}
;---------------------------------- EndTest ----------------------------------
EndTest(){
	global app
	
	mem := GetProcessMemoryUsage()
	SB_SetText(" Tip: Use SciTE4AutoHotkey for advanced editing and debugging! [" . mem " MB]",1,1)

	PostMessage("Slave script", 1)   ; exits/deletes slave script
	Gui, Show, xCenter yCenter AutoSize, %app%
	TrayTip, Status:, Test code ended and deleted.
	sleep, 2000
	
	return
}
;------------------------------- ClearTempCode -------------------------------
ClearTempCode(){
	
	GuiControl,, TempCode,
	return
}
;------------------------------ testMarkedCode ------------------------------
testMarkedCode(){
	mem := GetProcessMemoryUsage()
	SB_SetText(" Tip: Use SciTE4AutoHotkey for advanced editing and debugging! [" . mem " MB]",1,1)
	
	Clipsave := ClipboardAll
	sleep, 500
	
	clipboard := ""
	sleep, 500
	
	Send, ^c
	ClipWait, 1
	markedCode := ""
	markedCode := clipboard
	sleep, 1000
	
	if(StrLen(markedCode) > 1){
		testTempCode(markedCode)
	} else {
		showHint("ERROR, Nothing marked!",2000)
	}
	clipboard := Clipsave
	
	return
}
;----------------------------- startTestTempCode -----------------------------
startTestTempCode(){
	global TempCode
	
	Gui, Submit, NoHide

	testTempCode(TempCode)
}
;------------------------------- testTempCode -------------------------------
testTempCode(code){
	global app
	global ahkexepath
	
	WinMove, %app%,, 0, 0

	DetectHiddenWindows, On
	If Winexist("TempTestCode.ahk") ; If the test code is running close it before running a new one.
	{
		PostMessage("Slave script", 1)   ; exits/deletes slave script
	}
	DetectHiddenWindows, Off

FileAppend, 
(
#Persistent
#SingleInstance, Force

Progress, m2 b fs13 Y0 zh0 WMn700, Test script is running
Gui 99: show, hide, Slave script ; hidden message receiver window
OnMessage(0x1001,"ReceiveMessage")
%code%

WinActivate, %app%
return

ReceiveMessage(Message) {
	if Message = 1
	ExitApp
}
), %A_ScriptDir%\TempTestCode.ahk

FileDelete, %A_ScriptDir%\_codetester.txt
FileAppend,
(
%code%
), %A_ScriptDir%\_codetester.txt

Run, %ahkexepath% "TempTestCode.ahk" ; run script
Sleep, 100

IfWinExist, ahk_class #32770		; IF THERE IS AN ERROR LOADING THE SCRIPT SHOW THE USER
{
	Sleep 20
	WinActivate, ahk_class #32770
	Clipsave := ClipboardAll
	Send, ^c
	CheckWin := Clipboard
	Clipboard := Clipsave
	IfInString, CheckWin, The program will exit.
	{

	if (FileExist(A_ScriptDir . "\TempTestCode.ahk") != "")
		FileDelete, %A_ScriptDir%\TempTestCode.ahk
	TrayTip, ERROR, Error executing the code properly
	return
	}
}

TrayTip, Status:, Test code is now running on your machine.

return
} ; end testTempCode()
;-------------------------------- PostMessage --------------------------------
PostMessage(Receiver, Message) {
	oldTMM := A_TitleMatchMode
	oldDHW := A_DetectHiddenWindows
	SetTitleMatchMode, 3
	DetectHiddenWindows, on
	PostMessage, 0x1001,%Message%,,, %Receiver% ahk_class AutoHotkeyGUI
	SetTitleMatchMode, %oldTMM%                                              ; POST MESSAGE TO END THE TEST SCRIPT AND DELETE IT
	DetectHiddenWindows, %oldDHW%                                                ; Thank you to learning one for this example function
	if (FileExist(A_ScriptDir . "\TempTestCode.ahk") != "")
		FileDelete, %A_ScriptDir%\TempTestCode.ahk
		
	return
}
;----------------------------------- save -----------------------------------
save(){
	global TempCode
	
	Gui, Submit, NoHide
	
	FormatTime, filename, %A_Now% T8, 'codetesterSource'_yyyy_MM_dd_hh_mm_ss
	
	FileAppend,
	(
;************************ %filename% ************************

%TempCode%

;********************** END %filename% **********************



	), %A_ScriptDir%\saved\codetesterAllSources.txt
	
	
	
	FileAppend,
	(
#Persistent
#SingleInstance, Force

%TempCode%

esc::
exitApp

	), %A_ScriptDir%\saved\%filename%.ahk
	
	mem := GetProcessMemoryUsage()
	msg = Saved to saved\%filename%.ahk [%mem% MB]
	SB_SetText(msg,1,1)
	return
}
;--------------------------------- showHint ---------------------------------
showHint(s, n){
	Gui, hint:Font, s14, Calibri
	Gui, hint:Add, Text,, %s%
	Gui, hint:-Caption
	Gui, hint:+ToolWindow
	Gui, hint:+AlwaysOnTop
	Gui, hint:Show
	sleep, n
	Gui, hint:Destroy
	return
}
;------------------------------ openFilemanager ------------------------------
openFilemanager(){
	run,%A_ScriptDir%\saved\,%A_ScriptDir%\saved\
}
; *********************************** hotkeyToText.ahk ******************************
hotkeyToText(h) {
	isOff := ""
	if (InStr(h, "off") > 0){
		h := StrReplace(h, "off" , "")
		isOff := " (is off!)"
	}
	
	hk := StrSplit(StrRev(h))
	s := ""
	l := hk.Length() - 1
	
	Loop, % l
	{
		s := hkToDescription(hk[A_Index + 1]) . " + " . s
	}
	s := s  . "[" . hkToDescription(hk[1]) . "]"
	
	return s . isOff
}
; *********************************** StrRev ******************************
StrRev(in) {
	DllCall("msvcrt\_" (A_IsUnicode ? "wcs":"str") "rev", "UInt",&in, "CDecl")
	return in
}
; *********************************** hkToDescription.ahk ******************************
; TODO

hkToDescription(c) {
	s := c
	if (c == "^") {
		s := "[CTRL]"
	}
	if (c == "!") {
		s := "[ALT]"
	}
	if (c == "#") {
		s := "[WIN]"
	}
	if (c == "+") {
		s := "[SHIFT]"
	}
	if (c == "o") {
		s := "o"
	}
	if (c == ">") {
		s := "Right"
	}
	if (c == "<") {
		s := "Left"
	}
	return s
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage()
{
	ProcessID := DllCall("GetCurrentProcessId")
	static PMC_EX, size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

	if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID)) {
		if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
			if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
				return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
		DllCall("CloseHandle", "ptr", hProcess)
		return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
	}
	return (ErrorLevel := 1) & 0
}
;------------------------------------ esc ------------------------------------
esc::
	exit()
return
;----------------------------------- Exit -----------------------------------
exit(){
	global app
	
	PostMessage("Slave script", 1)   ; exits/deletes slave script
	ToolTip,Exiting %app% ...
	sleep, 2000
	ExitApp
}





















