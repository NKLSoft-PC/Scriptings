'>nul 2>&1||@copy /Y %windir%\System32\doskey.exe '.exe >nul
'& @echo off
'& setlocal
'& set "frm=%SystemRoot%\Microsoft.NET\Framework\"
'& for /f "tokens=* delims=" %%v in ('dir /b /a:d  /o:n "%SystemRoot%\Microsoft.NET\Framework\v*"') do set netver=%%v
'& set vbc=%frm%%netver%\vbc.exe
'& call %vbc% /nologo /out:"%~n0.exe" "%~dpsfnx0" 
'& %~n0.exe
'& endlocal
'& pause

Imports System

Public Module modmain
   ' Main is the application's entry point.
   Sub Main()
     ' Write text to the console.
     Console.WriteLine ("Hello World using Visual Basic!")
   End Sub
End Module
