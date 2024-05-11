; example2.ahk (AHK 1)
; to be used inside codetester only 1

; Example 2

loop,3 {
  a := A_Index . " Hello world!"
  showvari("a",a)
  b := A_Index . " 😃"
  showvari("b",b)
}

exitApp
