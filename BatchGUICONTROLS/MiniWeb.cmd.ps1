#TODO: Place custom script here
	$GOOGLEURL = Read-Host Entrez Google Recherche !!
	Add-Type -assembly System.Windows.Forms
	$main_form = New-Object System.Windows.Forms.Form
	$main_form.Text = 'NKLBrowser Generator'
	$main_form.Width = 950
	$main_form.Height = 950
	$main_form.AutoSize = $true
	$Label = New-Object System.Windows.Forms.Label
	$Webbrowser = New-Object System.Windows.Forms.Webbrowser
	$Webbrowser.Navigate("https://www.google.com/search?q=" + $GOOGLEURL)
	$Label.Text = "AD users"
	
	$Webbrowser.Size = New-Object System.Drawing.Point(950, 950)
	$Label.AutoSize = $true
	
	$main_form.Controls.Add($Webbrowser)
	Now you can display the form on the screen.
	$main_form.ShowDialog()
	exit