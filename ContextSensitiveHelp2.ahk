#Requires AutoHotkey v2

; From https://www.autohotkey.com/docs/v2/scripts/
; Context Sensitive Help in Any Editor (based on the v1 script by Rajat)
; https://www.autohotkey.com
; This script makes (Ctrl+2) (or another hotkey of your choice) F4 (-> AHK 2) and Shift F4 (-> AHK 1) show the help file
; page for the selected AutoHotkey function or keyword. If nothing is selected,
; the function name will be extracted from the beginning of the current line.

; The hotkey below uses the clipboard to provide compatibility with the maximum
; number of editors (since ControlGet doesn't work with most advanced editors).
; It restores the original clipboard contents afterward, but as plain text,
; which seems better than nothing.

; This version is a companion to Codetester only and controlled by Codetester, can not run standalone therefore!
#Warn
#SingleInstance

if (!WinExist("Codetester")){
  msg := "ContextSensitiveHelp is a companion to Codetester only and controlled by Codetester.`n`n"
  msg .= "If you run it standalone, to stop it start it again an press cancel!"
  result := msgbox(msg, "ContextSensitiveHelp", 0x2001)
  if (result != "Ok"){
    tooltip "ContextSensitiveHelp stopped!"
    sleep 2000
    exitApp
  } 
}


cshGui := Gui("+OwnDialogs +Resize", "ContextSensitiveHelp2")
cshGui.Add("Edit", "x2 y2 r0 w0 h0", "") ; Focus dummy
cshGui.Add("Edit","w300 h100 x10 y10","ContextSensitiveHelp2 started (AHK 2 only!), hotkey is F4!")
cshGui.show("Center autosize")
cshGui.Hide()

cshGui.onEvent("Close", cshGui_close)

OnMessage(0x1001, receiveMessage)

hotkey("F4", cshAction.Bind("2"), "On")
hotkey("+F4", cshAction.Bind("1"), "On")

;settimer () => cshGui_hide(), -5000

return

;------------------------------- cshGui_close -------------------------------
cshGui_close(*){
  exitAction()
}
;------------------------------ receiveMessage ------------------------------
receiveMessage(wParam, *){
  if (wParam == 1){
    exitAction()
  }
  return
}
;--------------------------------- cshAction ---------------------------------
cshAction(selectAHK,*) {
  local title, ahk_dir
  
  SetWinDelay 10
  SetKeyDelay 0

  title := ""
  ahk_dir := ""
  
  C_ClipboardPrev := A_Clipboard
  A_Clipboard := ""
  ; Use the highlighted word if there is one (since sometimes the user might
  ; intentionally highlight something that isn't a function):
  Send "^c"
  if !ClipWait(0.1) {
      ; Get the entire line because editors treat cursor navigation keys differently:
      Send "{home}+{end}^c"
      if !ClipWait(0.2) {
          A_Clipboard := C_ClipboardPrev
          return
      }
  }
  C_Cmd := Trim(A_Clipboard)
  A_Clipboard := C_ClipboardPrev
  Loop Parse, C_Cmd, "`s" {
      C_Cmd := A_LoopField
      break ; i.e. we only need one interation.
  }
  
  if (selectAHK = 1){
    ahk_dir := A_ProgramFiles "\AutoHotkey"
    title := "AutoHotkey Help"
  }
  if (selectAHK = 2){
    ahk_dir := A_ProgramFiles "\AutoHotkey\v2"
    title := "AutoHotkey v2 Help"
  }
    
  if !WinExist(title) {
    Run ahk_dir "\AutoHotkey.chm"
    WinWait(title)
  }
  WinActivate(title)
  WinWaitActive(title,,10)
  C_Cmd := StrReplace(C_Cmd, "#", "{#}")
  Send "!n{home}+{end}" C_Cmd "{enter}"
}
;-------------------------------- exitAction --------------------------------
exitAction(*){
  exitApp
}
;----------------------------------------------------------------------------




