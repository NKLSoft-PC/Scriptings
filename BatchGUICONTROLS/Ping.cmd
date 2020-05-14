@@echo off
@@findstr/v "^@@.*" "%~f0" > "%~f0.ps1" & powershell -ExecutionPolicy ByPass "%~f0.ps1" %* & del "%~f0.ps1" & goto:

#TODO: Place custom script here
	Add-Type -assembly System.Windows.Forms
	$main_form = New-Object System.Windows.Forms.Form
	$main_form.Text = 'NKLConsole'
	$main_form.Width = 650
	$main_form.Height = 750
	$main_form.AutoSize = $true
	$Textbox = New-Object System.Windows.Forms.Textbox
	$Webbrowser = New-Object System.Windows.Forms.Webbrowser
	$Webbrowser.Navigate("https://www.google.com/search?q=" + $GOOGLEURL)
	$Textbox.Text = "8.8.8.8"
	$Textbox.Width = 50
	$Textbox.Height = 350
	#::$Webbrowser.Size = New-Object System.Drawing.Point(800, 800)
		$GOOGLEURL = $Textbox.Text
	$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "ping.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "$GOOGLEURL"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host "stdout: $stdout"
Write-Host "stderr: $stderr"
	$Label.AutoSize = $true
	$Textbox.Size = New-Object System.Drawing.Point(250, 300)
	$main_form.Controls.Add($Textbox)
	Now you can display the form on the screen.
	$main_form.ShowDialog()

pause