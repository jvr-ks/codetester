@rem restart.bat
@rem !file is overwritten by update process!

@cd %~dp0


@echo no news available!
@echo.
@echo Please press a key to restart codetester (%1 bit)!
@echo.
@pause

@echo off

@set version=%1
@if [%1]==[64] set version=

@if [%2]==[noupdate] goto noupdate

@copy /Y codetester.exe.tmp codetester%version%.exe

:noupdate
@del codetester.exe.tmp
@start codetester%version%.exe

:end
@exit