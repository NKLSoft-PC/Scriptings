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


	Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Demo Batch Hybrid PowerShell Gui-Menu'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true
$Label = New-Object System.Windows.Forms.Label

$Label.Text = "AD users"

$Label.Location  = New-Object System.Drawing.Point(0,10)

$Label.AutoSize = $true

$main_form.Controls.Add($Label)
Now you can display the form on the screen.
$main_form.ShowDialog()

}