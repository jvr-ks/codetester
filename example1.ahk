; example1.ahk (AHK 1)
; to be used inside codetester only 1

; Example 1 

text := "😀"
FileAppend, %text%, test.txt
MsgBox, % "text: " . text
run,test.txt

exitApp
