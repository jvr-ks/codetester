# Codetester

Simple App (Windows > 10 only) to quickly test an Autohotkey script.   
Needs an installed Autohotkey!  
Writes the code to the temporary file "TempTestCode.ahk" and executes it via Autohotkey.  
Code is saved as "_codetester.txt" and restored on restart.  
  
I use it to quickly tryout parts of code.  
The builtin editor is very rudimentary,  
but \[Get code from notepad++] can be used!
  
Based on: [https://autohotkey.com/board/topic/72566-code-tester-test-your-code/](https://autohotkey.com/board/topic/72566-code-tester-test-your-code/frudimentary)
  
#### Latest changes:  
\[Get code from notepad++] button, gets text from notepad++ (topmost instance window).  

#### Start:
"codetester.exe"  

[Download from github](https://github.com/jvr-ks/codetester/raw/master/codetester.exe)  
Viruscheck see below.  


Code based on:  
[https://autohotkey.com/board/topic/72566-code-tester-test-your-code/](https://autohotkey.com/board/topic/72566-code-tester-test-your-code/)

#### Hotkeys:  
Defined in the \[Ini-file].  
  
Hotkey | Operation
------------ | -------------
\[CTRL] + \[u] | test marked code only
\[ESC] | close app and remove from memory (not changeable)

##### \[Ini-file] "codetester.ini"
Hotkeys can be set to "off" by adding the word "off" to the definition.  

[Sourecode at Github](https://github.com/jvr-ks/codetester), "codetester.ahk" an [Autohotkey](https://www.autohotkey.com) script.


Put your test-code in the box (via the clipboardor or the \[Get code from notepad++] button).  
Then click the Button or the hotkey to execute your test-code.  
  
Click on the End-Button or use the hotkey to stop execution of your test-code.  
You can also mark a part of your test-code with the mouse to execute this part only.  
Use the hotkey to start in case of marked test-code.  
  
The app window is moved to top left while executing your test-code.  
You can put any function as an ahk-file in the Lib subdirectory,  
(it's the Autohotkey mechanismen for ahk-files with function-names),
or us the standard #Include mechanism.    
  
**The code is only saved if you push the \[Test Code"] button once!**  
  
Example:  
  
Enter this code into the Textarea:  
>   
> a := "%comspec%"  
>   
> MsgBox, % envVariConvert(a)  
>   
>   
> envVariConvert(s){  
> 	r := s  
> 	if (SubStr(s,1,1) == "%") {  
> 		s := StrReplace(s,"`%","")  
> 		EnvGet, v, %s%  
> 		Transform, r, Deref, %v%  
> 	}  
> 	return r  
> }  
>   
  
Click \[Test code] button  
Result probably: "C:\windows\cmd.exe"  
Click \[End test] button  
  
##### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
  
  
##### License: MIT
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2020 J. v. Roos


##### Viruscheck at Virustotal 
[Check here](https://www.virustotal.com/gui/url/e231cef54e678d9b8b86ac6f1c3c4b45e842c75ae47cebf657cd495e11de2192/detection/u-e231cef54e678d9b8b86ac6f1c3c4b45e842c75ae47cebf657cd495e11de2192-1615112579
)  
Use [CTRL] + Click to open in a new window! 
