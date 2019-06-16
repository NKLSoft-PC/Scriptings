ECHO OFF
set "folder=%cd%"
cd /d "%folder%"
CLS
:WMICHELP
cls
echo WMIC is deprecated. >color 0c
ECHO.
ECHO ...............................................
ECHO Get Help WMIC Launcher By NKLSoft-pc %username%~:~%folder%
ECHO ...............................................
ECHO.
ECHO 1 - Download Or Repair WMIC Command Prompt
ECHO 2 - Launching WMIC Console Command
ECHO 3 - Get ALL Command for WMIC Launcher
ECHO 4 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO NOTE

:NOTE
cd %windir%\system32\notepad.exe
start notepad.exe
GOTO MENU
:MENU
ECHO.
ECHO ...............................................
ECHO Welcome to WMIC Launcher By NKLSoft-pc %username%~:~%folder%
ECHO ...............................................
ECHO.
ECHO 1 - Download Or Repair WMIC Command Prompt
ECHO 2 - Launching WMIC Console Command
ECHO 3 - Get ALL Command for WMIC Launcher
ECHO 4 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO NOTE
IF %M%==2 GOTO CALC
IF %M%==3 GOTO help
IF %M%==4 GOTO EOF
:NOTE
cd %windir%\system32\notepad.exe
start notepad.exe
GOTO MENU
:CALC
cd %windir%\system32\calc.exe
START "" /W CMD /C WMIC
GOTO MENU
:help
cd %windir%\system32\notepad.exe
start notepad.exe
cd %windir%\system32\calc.exe
start calc.exe
GOTO MENU
