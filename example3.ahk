; example3.ahk (AHK 1/2)
; to be used inside codetester only

; Example 3

a := "test finished"

; AHK 1: "a: test finished", AHK 2: not implemented yet

loop 5 {
  s := A_Index . " hello 😃😃😃 "
  ; showvari outputs to use debugview only (using AHK 2, no UTF-character-support in debugview)
  showvari("i",  s ) 
  sleep 1000
}

; AHK 1: "a", AHK 2: "test finished"
msgbox a 

exitApp

