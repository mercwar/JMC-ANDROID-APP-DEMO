@echo off
setlocal enabledelayedexpansion

:: [AVIS_COORD: C:\Apache24\htdocs\android | FILE: install_android.bat]
:: AVIS_COMMENT: ANDROID_SDK_INSTALL_SEQUENCE

REM C:
set "FIRE_PATH=android"
cd "\Apache24\htdocs\%FIRE_PATH%"

set "EXE_FILE=install_android"
set "MSYS_CMD=C:\msys64\msys2_shell.cmd"

set "LOG_FILE=C:\Apache24\htdocs\%FIRE_PATH%\%EXE_FILE%.log"
set "SH_PATH=/c/Apache24/htdocs/%FIRE_PATH%/%EXE_FILE%.sh"

type nul > "%LOG_FILE%"

"%MSYS_CMD%" -ucrt64 -defterm -no-start -here -c "\"%SH_PATH%\"" >> "%LOG_FILE%" 2>&1

pause
exit

