; aaa_demo_2.ahk
; to be used inside codetester only
; AHK v 1.0

Gui, demo:new,+E0x08000000 -Caption -Border -SysMenu +Owner +AlwaysOnTop +ToolWindow
Gui, demo:Add, Progress, Vertical h200 w20 cBlue BackgroundFFFF33 vMyProgress,
Gui, demo:show,autosize


loop, 100
  {
    v := A_Index
    GuiControl,, MyProgress , %v%
    sleep,10
  }

Gui, demoMessage:new,+E0x08000000 -Caption -Border -SysMenu +Owner +AlwaysOnTop +ToolWindow
Gui, demoMessage:Font,s25
Gui, demoMessage:Add, Text, cRed, Code-run finished!
Gui, demoMessage:show,autosize

sleep, 4000
exitApp

