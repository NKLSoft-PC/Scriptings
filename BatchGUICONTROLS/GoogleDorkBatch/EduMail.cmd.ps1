#TODO: Place custom script here
	


	Add-Type -assembly System.Windows.Forms
	$main_form = New-Object System.Windows.Forms.Form
	$main_form.Text = 'Education Mail Generator'
	$main_form.Width = 800
	$main_form.Height = 800
	$main_form.AutoSize = $true
	$Label = New-Object System.Windows.Forms.Label
	$Webbrowser = New-Object System.Windows.Forms.Webbrowser
	$Webbrowser.Navigate("https://xkx.me/" )
	$Label.Text = "AD users"
	
	$Webbrowser.Size = New-Object System.Drawing.Point(800, 800)
	
	$Label.AutoSize = $true
	
	$main_form.Controls.Add($Webbrowser)
	Now you can display the form on the screen.
	$main_form.ShowDialog()
	exit