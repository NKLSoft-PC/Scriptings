@@echo off
@@findstr/v "^@@.*" "%~f0" > "%~f0.ps1" & powershell -ExecutionPolicy ByPass "%~f0.ps1" %* & del "%~f0.ps1" & goto:
#TODO: Place custom script here
	


	Add-Type -assembly System.Windows.Forms
	$main_form = New-Object System.Windows.Forms.Form
	$main_form.Text = 'NKLBrowser Generator'
	$main_form.Width = 800
	$main_form.Height = 800
	$main_form.AutoSize = $true
	$Label = New-Object System.Windows.Forms.Label
	$Webbrowser = New-Object System.Windows.Forms.Webbrowser
	$Webbrowser.Navigate("https://www.google.com/search?q=site:.edu%20|%20.gov%20ext:bkf%20|%20ext:bkp%20|%20ext:bak%20|%20ext:old%20|%20ext:backup" )
	$Label.Text = "AD users"
	
	$Webbrowser.Size = New-Object System.Drawing.Point(800, 800)
	
	$Label.AutoSize = $true
	
	$main_form.Controls.Add($Webbrowser)
	Now you can display the form on the screen.
	$main_form.ShowDialog()
	exit