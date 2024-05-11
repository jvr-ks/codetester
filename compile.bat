@rem compile.bat

@echo off

SET appname=codetester

rem call codetester.exe remove

call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

UPX --best %appname%.exe

