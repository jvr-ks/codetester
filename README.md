# Codetester ![Icon](https://github.com/jvr-ks/codetester/blob/main/codetester.ico?raw=true)  
 
#### Description  
**Codetester is UNDER CONSTRUCTION!**  
  
Simple App (Windows &gt; 10, 64 bit only) to quickly test an Autohotkey script (called "CUT" = "Code under test").  
I use it to quickly tryout code or parts of code.  
  
Needs an installed [Autohotkey](https://www.autohotkey.com/download/) version 1+ and/or version 2+!  
  
Writes the code to the temporary file "_tmp.ahk" and executes it via Autohotkey.  
The code is saved as "_codetester.txt" and restored on restart.  
  
Special features of **Codetester** are:  
* Can observe variable content via the "showvar()" function \*1),  
* Automatically switches to AHK2 if "#Requires AutoHotkey v2" is found,  
* Copy code to the clipboard (from a webpage etc.) and press \[F7]-Key or (\[F8]-Key to run it as an AHK1- or AHK2-Script,  
* CUT is interruptible by pressing the \[Escape]-key,  
* Store the code to one of three files (1, 2, 3).  
* Quick exchange the code with one of three (a, b, c) "shadowareas"
  
If you need a good editor to be used with autohotkey-scripts, 
give [SciTE4AutoHotkey](https://www.autohotkey.com/scite4ahk) a try!  
   
Uses the [Scintilla](https://www.scintilla.org/) Textcontrol (Scintilla.dll).  
Block move with tab: Indentation is 2 spaces (fixed).  
  
Code based on: [https://autohotkey.com/board/topic/72566-code-tester-test-your-code/](https://autohotkey.com/board/topic/72566-code-tester-test-your-code/frudimentary)  
   
**Codetester uses the clipboard, clipboard-content is not saved!**  

\*1) Codetester does not support breakpoints,  
     use [SciTE4AutoHotkey](https://www.autohotkey.com/scite4ahk), if breakpoints are required.  
     "showvar()": run Codetester.exe, mark a variable, press \[Ctrl] + \[c] and then the Insert: \[Showvari]-button.   
 
#### Download via Updater (preferred method)  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!** 
  
To download **codetester.exe** 64 bit Windows from Github please use:   
  
**[updater.exe 64bit](https://github.com/jvr-ks/codetester/raw/main/updater.exe)**  
  
(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater))  
  
* From time to time there are some false positiv virus detections  
[Virusscan](#virusscan) at Virustotal see below.  
  
#### Start:  
* Run "updater.exe", example: "C:\jvrks\codetester\updater.exe" once to download/update Codetester.  
* Then start "codetester.exe", example: "C:\jvrks\codetester\codetester.exe" !  
(Create a dektop-icon or a taskbar entry).  
If your Autohotkey is not installed in the default directories,  
change the entries:  
Configuration-file -&gt; \[setup] -&gt; ahk1exepath="C:\Program Files\AutoHotkey\AutoHotkey.exe"  
Configuration-file -&gt; \[setup] -&gt; ahk2exepath="C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"  
accordingly (A restart of Codetester is required).  
  
Example (AHK 1/2):  
````  
; Example AHK1 / 2

#Warn All, Off

a := "test finished"

loop 3 {
  s := A_Index . " hello 😃 "
  showvari("i",  s ) 
  sleep 1000
}

showvari("A_AhkVersion",  A_AhkVersion ) 

version := A_AhkVersion

toDisplay := a . " 🚴"


if (!InStr(version,"1."))
  msgbox toDisplay
else
  ;not valid in AHK 2, so use #Warn All, Off
  msgbox test finished  🚴

exitApp
````  
  
Codetester itself uses "UTF-8-RAW" file encoding.  
**The CUT uses "UTF-8-RAW" as default file encoding also!** (v 0.168+),  
set by Configuration-file -&gt; cutFileEncoding.  
  
#### Codetester Hotkeys  
Are defined in the Configuration-file.  
   
Hotkey | Operation  |  Remarks  
------------ | ------------- | -------------  
\[CTRL] + \[u] | test selected-code-only | Testing selected-code-only      
\[ESC] | stop the script under test | unnecessary if the script under test has an "exitApp"-command.   
\[F7] | run the current content of the clipboard as AHK v1 script  \*1)  
\[F8] | run the current content of the clipboard as AHK v2 script \*1)  
\[F1] | if UnicodeList is active only: show quick-help  
\[F2] | if UnicodeList is active only: show clipboard contents as UTF-8 and copies it to the clipboard  
\[F3] | if UnicodeList is active only: show clipboard contents as URI and copies it to the clipboard  
  
\*1)  
- Codetester must be running,  
- directives are used,  
- no codemodifications are made (Codetester builtin functions are not usable),  
- "#Requires AutoHotkey vX" is prepended.  
- code can be inspected, toggle-button: "Controlarea" -&gt; "Show: _tmp.ahk".  
  
Example show current AHK version (AHK version independant):
````  
DllCall("MessageBox", "Uint", 0, "Str", A_AhkVersion, "Str", "Current used Autohotkey version", "Uint", "0x0000000")
````  
  
#### Build-in functions  
Description | Operation | Usage  
------------ | ------------- | -------------  
showvari("Variable-name", variable) | Displayed in Debug-window | To generate the code mark a variable, then press the button "showvari"  \*2) 
 
\*2)  
If a "showvari" function is used, the codetester-gui stays in front!  
"showvari" logs to the file "debug.log" too.  
You may run the script (AHK 1 or 2) "_tmp.ahk" by doubleclicking on the file.  
If "showvari()" is used, leave the Codetester window open to receive debugging messages!  
  
  
#### Configuration-file   
The Configuration-file ("codetester_&lt;ComputerName&gt;.ini") is generated automatically, if it does not exist already.  
There is a menu-button to edit the Configuration-file.  
Hotkeys can be set to "off" by adding the word "off" to the definition.  
  
[Sourecode at Github](https://github.com/jvr-ks/codetester), "codetester.ahk" an [Autohotkey](https://www.autohotkey.com) script.  
  
Put your test-code in the box (via the clipboardor or the \[Get code from Notepad++] button).  
Then click the Button or the hotkey to execute your test-code.  
  
Click on the End-Button or use the hotkey to stop execution of your test-code.  
You can also mark a part of your test-code with the mouse to execute this part only.  
Use the hotkey to start in case of selected test-code.  
   
You can put any function as an ahk-file in the Lib subdirectory,  
(it's the Autohotkey mechanismen for ahk-files with function-names),  
or us the standard #Include mechanism.  

#### Configuration-file backup / autorestore
If the directory "C:\Users\&lt;UserName&gt;\AppData\Roaming\codetester\" is usable,
the app saves a copy of the Configuration-file to this backup-directory.  
If the Configuration-file is missing,  
an attempt is made to restore the file from the backup directory.  
Otherwise a new Configuration-file is created, containing default-values.  
  
#### Configuration-file empty directives-entries  
If a configuration parameter is not contained in the Configuration-file  
or is contained but has a blank value, a default value is used.  
  
To force directives-entries to become empty, use the value "#empty!".
  
#### Directives  
Can be used as usual and/or set in the Configuration-file -&gt; \[directives] -&gt; directive1= ... directive6=  
(6 max.).  
If Authokey 2 is selected (the code contains "#Requires AutoHotkey v2 ..."),  
Configuration-file -&gt; \[directives2] are used.  
Directives defined in the Configuration-file are prepended to directives contained in the code,  
hence those contained in the code take precedence.  
  
Example:  
Configuration-file setting:  
```` 
\[directives1]  
directive1="#SingleInstance Force"
directive2="#Warn, All, MsgBox"  
directive3="#NoEnv"  
...  
directive6=  

\[directives2]
directive21="#SingleInstance Force"
directive22="#Warn"
directive23=""
...  
directive26=""
````  
#### Button "Show: _tmp.ahk" 
Use the button "Show: _tmp.ahk" / "Close: _tmp.ahk"  
to show the content of the file "_tmp.ahk".  
This file is executed, if a run-button is pressed (or F7/F8).    
Changes to the content are not saved, the file is overwritten by any Run-command. 
  
#### Get from NP++ / Copy to NP++  
The "Get from NP++"-button selects \*3) the complete text of the topmost Notepad++ window  
an **overwrites** the Codetester content,  
"Copy to NP++"-button inserts the text from the Codetester window at the current cursor (caret) position,  
or replaces the currently seleted text (uses the clipboard and a "Ctrl + v" command).  
  
\*3)
The selection keeps activated so that the next "Copy to NP++" operation  
is not an insert but an overwrite operation (a desired behavior).   

  
#### Disable code mods  
If checked the following code modifications are disabled during a test run:  
- no additional code to use the "showvari-function" is included,  
- replacing "exitApp" by sendInput,{ESCAPE} is disabled,  
- FileEncoding is not set to "UTF-16" (keeping default fileencoding),  
- Debug Area is not auto-shown if code contains a "showvari-function".  
- Including directives from the Configuration-file is NOT disabled.  
  
#### Reserved names   
The following limitations apply with the code-under-test (CUT):  
  
Name | remarks  
------------ | -------------
_codetester* | some variable-names reserved by Codetester  
**showvari** | reserved by Codetester  
  
#### Msgboxes are automatically moved  
All msgboxes are moved to the top left, to prevent them to be hidden by the Codetester Controlbox!  
Repetive msgboxes are shifted a little bit right-down.  
  
#### EXCH buttons  
By pressing one of the EXCH-buttons, the current content is exchanged with a second content-storage,   
(Using the file "_saved\__codetester_exchNUMBER.ahk.txt", NUMBER = 1,2 or 3),  
independantly from the other Read1...3/Save1...3 buttons.  
(Code text must contain at least one newline character!)  
Only one EXCH can be active at a time.  
On closing the app, the EXCH status is reset.  
  
#### Codetester Controlarea  
Press "Escape" to show the Controlarea (if hidden).  
  
##### AOT button  
If enabled the Codetester Controlarea stays **A**lways **O**n **T**op.  
If the Codetester code-edit-area is hidden, press the ESCAPE key.  

##### ESCAPE key  
Pressing the ESCAPE key  
- stops any running code.  
- reactivates the Codetester code-edit-area.  
  
#### Hotkeys  
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/codetester/blob/main/hotkeys.md)  
  
#### Hotkey Converter button  
Simple tool to get the hotkey from pressed keys.  
  
#### UnicodeTable  
A basic UnicodeTable using UTF-16 row and column indexes, but each characters is UTF-8 encoded,  
UTF-8 support must be enabled -&gt; "Enable Unicode UTF-8" below.  
Use \[Alt] + \[Down] or \[Alt] + \[Up] to scroll the pages,  and  
**\[Alt] + \[Enter] to close the table** or the "Controlarea"  buttons.  
  
Hints:  
- Non-Breaking-Space character is displayed as a blank,  
  but is NBSP (UTF-8: 0xC2 0xA0) UTF-16: 0x00A0, i. e. row 0000A0, column 00

#### Enable Unicode UTF-8  
Windows uses Unicode UTF-16 as the default,  
but the Scintilla control uses UTF-8.  
To use the full Unicode characterset, enable UTF-8 support in Windows:  
[Enable Unicode UTF-8 (Windows 10)](https://www.jvr.de/2022/07/30/unicode-in-console-windows-10-en_us/)
  
#### Hints  
Maximum size of code is 60 MB!  
  
#### Fonts  
Default is "Consolas" but I prefer ["Source Code Pro"](https://github.com/adobe-fonts/source-code-pro/releases)  
Configuration-file -&gt; \[config]  
fontSCI="Source Code Pro"  
fontsizeSCI=11  
  
#### Make \*.exe   
A standard Autohotkey (64 bit) installation is required (C:\Program Files\AutoHotkey ...).  
The code is used to create an executable-file named "_codeToExe.exe" (64 bit) or "_codeToExe32.exe" (32 bit).  
- Functions supplied by Codetester are not usable (besides the directives-mechanism),  
  "showvari()" is automatically commented out therefor.  
- "sendInput,{ESCAPE}" is replaced by "exitApp".  
  
The sourcecode can be inspected in the file "_codeToExe.ahk"!  
Feel free to rename the executable-file to any name you want ... :-)  
Hint: use UPX to compress the EXE-file!  
  
#### Using Scintilla  
Codetester Scintilla.dll may be used in CUT with:  
AHK 1 (turn off warnings, i.e. set Config-file -&gt; \[directives1] -&gt; directive2 to "#empty!"):  
#include, codetesterLib\codetesterLib_SCI.ahk  
AHK 2:  
(Download  
* "scintilla.dll",  
* "scintilla.ahk" and  
* "CustomLexer.dll",  
from [AHK v2 Script Converter](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip)  
to the "_sci2Lib/..." directory!  
  
Example (AHK 2):  
````
; is supplied by codetester config #SingleInstance Force
; is supplied by codetester config #Warn  
#Requires AutoHotKey v2.0+

#Include _sci2Lib/scintilla.ahk

FileEncoding "UTF-8-RAW"


guiMain := Gui("+Resize")
guiMain.Title := "Test Scintilla AHK V2"
guiMain.MarginX := "0", guiMain.MarginY := "0"

SB := guiMain.Add("StatusBar")
SB.SetParts(300, 300)

edit1 := guiMain.AddScintilla("x10 y10 w800 h600 VtheCode DefaultOpt LightTheme")
edit1.callback := sci_Change
edit1.Doc.ptr := edit1.Doc.Create(500000+100)

edit1.Tab.Use := false
edit1.Tab.Width := 2

guiMain.Show()

return
;-------------------------------- sci_Change --------------------------------
sci_Change(*){
  global guiMain, SB, edit1

  guiCtrlObj := guiMain.FocusedCtrl
  if (IsObject(guiCtrlObj)){
    CurrentCol := EditGetCurrentCol(guiCtrlObj)
    CurrentLine := EditGetCurrentLine(guiCtrlObj)
    oSaved := guiMain.Submit(0)
    currentLineContent := edit1.Text
    tooltip currentLineContent
    SB.SetText("Line: " CurrentLine " Column: " CurrentCol , 2, 1)
  }
}

````
  
#### Menu -&gt; Allfiles -&gt; Update Allfiles  
Generates a single file including all sources found in the "saved" directory by using "allfilesBetter.exe"  
from the github project [AllfilesBetter](https://github.com/jvr-ks/allfilesBetter).  
If Codetester is installed via Updater "allfilesBetter.exe" is already downloaded.  

#### Menu -&gt; Allfiles -&gt; Open Allfiles  
Uses the default editor associated with *.txt-files or  
the app defined in Configuration-file -&gt; \[setup] -&gt; texteditorpath="&lt;path to the editor.exe&gt;"  
to open the file generated by Update Allfiles (= allfilesBetter.exe).  
The benefits are:  
* Easy search of code fragments  
* A kind of "backup"  
  
"allfilesBetter.exe" needs an installed Java (&gt; 8) runtime!  

#### Contextsensitiv Help  
Removed from Codetester, please use the new  
[AutohotkeyHelp2](https://github.com/jvr-ks/simpletools?tab=readme-ov-file#AutohotkeyHelp2)  
which has identical functionality!
  
#### Known issues / bugs  
Issue / Bug | Type | fixed in version  
------------ | ------------- | -------------  
Edit Configuration-file: empty entries are filled with default value | bug | 0.167
Scripts do not terminate | bug | 0.161  
Builtin "editor" has no "Find"-function | issue | --- 
The font "`Source Code Pro" fails with Codetester, but is ok with aottext, very strange!| issue | was just a typo  
Showvari() does not support AHK 2 (besides view with Sysinternals debugview) | issue | 0.118  
Showvari() cannot display unicode characters | issue | 0.118  
Showvari() displays only a few characters | issue | 0.118  
Line-numbers limited to 99 | issue | 0.109 (increased to 999)  
  
#### Latest changes:  
  
Version (&gt;=)| Change  
------------ | -------------  
0.195 | Controlarea buttons rearranged
0.194 | Contextsensitiv Help removed
0.190 | Automatic insertion of "#Requires AutoHotkey v2" into a new file  
0.189 | Button "ext." to start [Unicodetable.exe](https://github.com/jvr-ks/UnicodeTable)
0.188 | Contextsensitiv Help (using "ContextSensitiveHelp2.exe" an AHK2 script)  
0.183 | Copy to/from SciTE
0.182 | Button "Hotkey Converter", uses external "hotkeyConverter2.exe" from my [simpletools](https://github.com/jvr-ks/simpletools?) repository.  
0.181 | Buttons "showvari" and "msgbox" fixed
0.171 | Run code from any app (supporting the clipboard and copy via CTRL+c), default Hotkeys are F7 = run as AHK1 and F8 = run as AHK 2
0.170 | Configuration-file -&gt; \[config] -&gt; "clipboardKeep=0|1", "0" is default now, clipboard is not restored if app is closed!
0.169 | Code under Test file encoding changed to UTF-8-RAW as default  
0.168 | AHK2 detection bug fixed
0.167 | Configuration-file: empty entries behavior changed
0.166 | If AOT is disabled, the Controlarea is shown in the tasklist  
0.165 | UnicodeTable: Navigation + Exit buttons, font fixed to "Consolas" (to keep the tabs-formatting)
0.164 | forced  use of non-proportional font (Consolas) in the unicode table
0.163 | directives2 default values fixed, Requires AutoHotkey mechanism changed
0.158 | maxDirectives fixed to 6, directives read from config precede others
0.157 | Configuration-file -&gt; "exeIgnore="  removed
0.147 | Complete change of the Gui! (Please delete the section \[Gui] in the Configuration-file!)  
0.146 | Fixes a bug introduced in the last version  
0.142 | Window postion etc. is now saved in the Configuration-file too.  
0.140 | Configuration-file changed! Delete the old one, a corrected new one will be created automatically!  
0.125 | Code unde test filename changed from "TempTestCode.ahk" to "_tmp.ahk"  
0.124 | Detached button panel "Controlbox"  
0.123 | Tagged version 123 (source codetester123.ahk)  
0.120 | Debugger removed, use build in showvari() function or AHK "OutputDebug" command  
0.115 | Experimental AHK 2 support, function showvari("a",a) not usable with AHK v2 (TODO)  
0.108 | "#" as WIN-key usable (interfered with "#"-directives before), using "Scintilla.dll" again  
0.105 | Width of Debug-Window fixed to 30% (Configuration-file -&gt; \[config] -&gt; "widthDebugtext=" removed)  
0.100 | Code under Test uses UTF-16 LE-BOM as default (files: "TempTestCode.ahk" and "_codeToExe.ahk") Configuration-file -&gt; cutFileEncoding.  
0.094 | showvari() sends to Debugger too, format is: Codetester (DATETIME): showvari-info  
0.093 | Generated *.exe-files -&gt; showvari() is commented out, exch1..3 buttons behave like radio-buttons  
0.091 | Files to store Save1...3 renamed to "__codetester_save1...3.ahk.txt" (in the "_saved"-subdirectory)  
0.090 | During test-run "exitApp is automaticaly replaced by "sendInput,{ESCAPE}", so "exitApp" can be used as usual. Buttons changed accordingly.  
0.088 | The file "TempTestCode.ahk" holding the code-under-test is not deleted after a run, can be used for debugging.    
0.072 | Clear Button: the code is saved to "_codetester.tmp.txt" as a "last chance".  
0.052 | Scintilla Textcontrol usable, Scintilla Wrapper for AHK generates a lot of warnings, #Warn disabled.  
  
#### License: MIT  
Permission is hereby granted, free of charge,  
to any person obtaining a copy of this software and associated documentation files (the "Software"),  
to deal in the Software without restriction,  
including without limitation the rights to use,  
copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software,  
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies  
or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
  
Copyright (c) 2020 J. v. Roos
  
Other parts License  
"SCI.ahk" from:  
https://github.com/RaptorX/scintilla-wrapper  
Copyright by Isaias Baez  
Has no License information!  
  
<a name="virusscan">


##### Virusscan at Virustotal 
[Virusscan at Virustotal, codetester.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/e127696ef1914ed369901ebcdd5b1f722d9ad40fab65b454297ef21a2a8b2173/detection/u-e127696ef1914ed369901ebcdd5b1f722d9ad40fab65b454297ef21a2a8b2173-1715417159
)  
