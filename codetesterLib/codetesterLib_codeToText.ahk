/*
 *********************************************************************************
 * 
 * GNU GENERAL PUBLIC LICENSE
 * 
 * A copy is included in the file "license.txt"
 *
 * AutoHotkey v2
 *
  *********************************************************************************
*/

;-------------------------------- codeToText --------------------------------
codeToText(p1, useMarkdown:= 0) {
  
  toParse := p1
  theText := ""

  c := 0x00A1 ; using unused characters as "special strings" placeholders
  toParse := RegExReplace(toParse, "i)F12",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F11",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F10",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F9",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F8",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F7",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F6",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F5",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F4",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F3",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F2",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)F1",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Home",Chr(c),&rest,1,1) ; 0x00AD
  c += 1
  toParse := RegExReplace(toParse, "i)End",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)PgUp",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)PgDn",Chr(c),&rest,1,1) ; 0x00B0
  c += 1
  toParse := RegExReplace(toParse, "i)Pause",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)CapsLock",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Up",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Down",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Left",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Right",Chr(c),&rest,1,1)
  c += 1
  toParse := RegExReplace(toParse, "i)Pause",Chr(c),&rest,1,1) ; 0x00B7

  openBracket := "["
  closeBracket := "]"
  
  if (useMarkdown)
    openBracket := "\["
  
  
  Loop Parse, toParse, "", "`n`r"
  {
    switch A_LoopField
    {
      case "+": 
        theText .= openBracket . "SHIFT" . closeBracket . " + "
        
      case "^": 
        theText .= openBracket . "CTRL" . closeBracket . " + "
        
      case "!": 
        theText .= openBracket . "ALT" . closeBracket . " + "
        
      case "#": 
        theText .= openBracket . "WIN" . closeBracket . " + "
        
      case " ": 
        theText .= " "
      
      case Chr(0x00A1): 
        theText .= openBracket . "F12" . closeBracket . " + "
        
      case Chr(0x00A2): 
        theText .= openBracket . "F11" . closeBracket . " + "
        
      case Chr(0x00A3): 
        theText .= openBracket . "F10" . closeBracket . " + "
        
      case Chr(0x00A4): 
        theText .= openBracket . "F9" . closeBracket . " + "

      case Chr(0x00A5): 
        theText .= openBracket . "F8" . closeBracket . " + " 

      case Chr(0x00A6): 
        theText .= openBracket . "F7" . closeBracket . " + " 

      case Chr(0x00A7): 
        theText .= openBracket . "F6" . closeBracket . " + "        
        
      case Chr(0x00A8): 
        theText .= openBracket . "F5" . closeBracket . " + "    
        
      case Chr(0x00A9): 
        theText .= openBracket . "F4" . closeBracket . " + "  
        
      case Chr(0x00AA): 
        theText .= openBracket . "F3" . closeBracket . " + "        
        
      case Chr(0x00AB): 
        theText .= openBracket . "F2" . closeBracket . " + "        
        
      case Chr(0x00AC): 
        theText .= openBracket . "F1" . closeBracket . " + "
        
      case Chr(0x00AC): 
        theText .= openBracket . "F1" . closeBracket . " + "

      case Chr(0x00AD): 
        theText .= openBracket . "Home" . closeBracket . " + "

      case Chr(0x00AE): 
        theText .= openBracket . "End" . closeBracket . " + "

      case Chr(0x00AF): 
        theText .= openBracket . "PgUp" . closeBracket . " + "

      case Chr(0x00B0): 
        theText .= openBracket . "PgDn" . closeBracket . " + "

      case Chr(0x00B1): 
        theText .= openBracket . "Pause" . closeBracket . " + "

      case Chr(0x00B2): 
        theText .= openBracket . "CapsLock" . closeBracket . " + "

      case Chr(0x00B3): 
        theText .= openBracket . "Up" . closeBracket . " + "

      case Chr(0x00B4): 
        theText .= openBracket . "Down" . closeBracket . " + "

      case Chr(0x00B5): 
        theText .= openBracket . "Left" . closeBracket . " + "

      case Chr(0x00B6): 
        theText .= openBracket . "Right" . closeBracket . " + "
        
      case Chr(0x00B7): 
        theText .= openBracket . "Pause" . closeBracket . " + "

      default:
        theText .= openBracket . "" . A_LoopField . "" . closeBracket
    }
  }
  ; StringCaseSense, Off
  if (SubStr(theText, -3, 3) == " + ")
    theText := SubStr(theText, 1, -3)

  return theText
}