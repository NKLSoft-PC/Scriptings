@if (@X)==(@Y) @end /* Harmless hybrid line that begins a JScript comment
@echo off
setlocal
set "frm=%SystemRoot%\Microsoft.NET\Framework\"

for /f "tokens=* delims=" %%v in ('dir /b /a:d  /o:-n "%SystemRoot%\Microsoft.NET\Framework\v*"') do (
   set netver=%%v
   goto :break_loop
)
:break_loop
set jsc=%frm%%netver%\jsc.exe
call %jsc% /nologo /out:"%~n0.exe" "%~dpsfnx0" 
%~n0.exe
endlocal
exit /b 0
*/
print("Hello World!");
