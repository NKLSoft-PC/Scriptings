$FormText = Read-Host Entrez Le nom de votre Project
$FormHeight = Read-Host Entrez La Dimention de haut en bas
$FormWidth = Read-Host Entrez La Dimention de gauche a droit
param ($FormText, $FormHeight='Odyessy')
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = $FormText
$main_form.Width = $FormHeight
$main_form.Height = $FormWidth
$main_form.AutoSize = $true
$main_form.ShowDialog()
exit
