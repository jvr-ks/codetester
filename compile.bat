@rem compile.bat

@echo off

SET appname=codetester

rem call codetester.exe remove

call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

UPX --best %appname%.exe


rem is AHK 2!
SET appname=ContextSensitiveHelp2

set autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set autohotkeyCompiler=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe

rem call %appname%.exe remove

call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /base "%autohotkeyCompiler%

UPX --best %appname%.exe
