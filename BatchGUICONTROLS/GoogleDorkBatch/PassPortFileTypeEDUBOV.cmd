@@echo off
@@findstr/v "^@@.*" "%~f0" > "%~f0.ps1" & powershell -ExecutionPolicy ByPass "%~f0.ps1" %* & del "%~f0.ps1" & goto:
#TODO: Place custom script here
	


	Add-Type -assembly System.Windows.Forms
	$main_form = New-Object System.Windows.Forms.Form
	$main_form.Text = 'inurl:login.do intext:government'
	$main_form.Width = 800
	$main_form.Height = 800
	$main_form.AutoSize = $true
	$Label = New-Object System.Windows.Forms.Label
	$Webbrowser = New-Object System.Windows.Forms.Webbrowser
	$Webbrowser.Navigate("https://www.google.com/search?q=%22passport%22%20filetype:xls%20site:%22*.edu.*%22%20|%20site:%22*.gov.*%22%20|%20site:%22*.com.*%22%20|%20site:%22*.org.*%22%20|%20site:%22*.net.*%22%20|%20site:%22*.mil.*%22" )
	$Label.Text = "AD users"
	
	$Webbrowser.Size = New-Object System.Drawing.Point(800, 800)
	
	$Label.AutoSize = $true
	
	$main_form.Controls.Add($Webbrowser)
	Now you can display the form on the screen.
	$main_form.ShowDialog()
	exit