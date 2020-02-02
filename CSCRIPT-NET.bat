//>nul 2>nul||@goto :batch
/*
:batch
@echo off
setlocal

:: find csc.exe
set "frm=%SystemRoot%\Microsoft.NET\Framework\"
for /f "tokens=* delims=" %%v in ('dir /b /a:d  /o:-n "%SystemRoot%\Microsoft.NET\Framework\v*"') do (
   set netver=%%v
   goto :break_loop
)
:break_loop
set csc=%frm%%netver%\csc.exe
:: csc.exe found

call %csc% /nologo /out:"%~n0.exe" "%~dpsfnx0" 
%~n0.exe
endlocal
exit /b 0
*/
public class Hello
{
   public static void Main()
   {
      System.Console.WriteLine("Hello, C# World!");
   }
}
