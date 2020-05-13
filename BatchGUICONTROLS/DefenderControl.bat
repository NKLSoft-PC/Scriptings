ECHO OFF
CLS
:: ### START UAC SCRIPT ###

if "%2"=="firstrun" exit
cmd /c "%0" null firstrun

if "%1"=="skipuac" goto skipuacstart

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges

setlocal & pushd .

cd /d %~dp0
cmd /c "%0" skipuac firstrun
cd /d %~dp0

:skipuacstart

if "%2"=="firstrun" exit

:: ### END UAC SCRIPT ###

:: ### START OF YOUR OWN BATCH SCRIPT BELOW THIS LINE ###
:MENU
ECHO.
ECHO ...............................................
ECHO PRESS 1, 2 OR 3 to select your task, or 4 to EXIT.
ECHO ...............................................
ECHO.
ECHO 1 - disable real-time monitoring of Windows Defender
ECHO 2 - enable real-time monitoring of Windows Defender
ECHO 3 - disable Windows Defender
ECHO 4 - enable Windows Defender
ECHO 5 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO 1
IF %M%==2 GOTO 2
IF %M%==3 GOTO 3
IF %M%==4 GOTO 4
IF %M%==5 GOTO 5
:1
call %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command Set-MpPreference -DisableRealtimeMonitoring $true
GOTO MENU
:2
call %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command Set-MpPreference -DisableRealtimeMonitoring $false
GOTO MENU
:3
call %SystemRoot%\system32\cmd.exe /k C:\Windows\System32\reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
GOTO MENU
:4
call %SystemRoot%\system32\cmd.exe /k C:\Windows\System32\reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 0 /f
GOTO MENU
:5
exit

