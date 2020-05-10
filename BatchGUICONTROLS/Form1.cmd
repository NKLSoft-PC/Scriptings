@@echo off
@@findstr/v "^@@.*" "%~f0" > "%~f0.ps1" & powershell -ExecutionPolicy ByPass "%~f0.ps1" %* & del "%~f0.ps1" & goto:
param ($FormText, $FormHeight='Odyessy')
$FormText = Read-Host Entrez Le nom de votre Project
$FormHeight = Read-Host Entrez La Dimention de haut en bas
$FormWidth = Read-Host Entrez La Dimention de gauche a droit
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = $FormText
$main_form.Width = $FormHeight
$main_form.Height = $FormWidth
$main_form.AutoSize = $true
$main_form.ShowDialog()
exit
