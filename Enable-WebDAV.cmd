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
# This script file has to be executed on the Azure VM.
# If you want to automatically create an Azure VM, install IIS and WebDAV
# DO NOT execute this file. Instead use the script in file Create-WebDavVm.ps1.

# Install IIS.
Install-WindowsFeature -Name Web-Server, Web-DAV-Publishing, Web-Windows-Auth, Web-Mgmt-Tools

# Configure IIS.
Set-WebConfigurationProperty -Filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites" -Location "Default Web Site" -Name Enabled -Value False
Set-WebConfigurationProperty -Filter system.webServer/security/authentication/windowsAuthentication -PSPath "IIS:\Sites" -Location "Default Web Site" -Name Enabled -Value True
Set-WebConfigurationProperty -Filter system.webServer/webdav/authoring -PSPath "MACHINE/WEBROOT/APPHOST" -Location "Default Web Site" -Name Enabled -Value True

$newRule = @{
    users="*"
    path="*"
    access="Read, Write, Source"
}

Add-WebConfiguration -Filter system.webServer/webdav/authoringRules -PSPath "MACHINE/WEBROOT/APPHOST" -Location "Default Web Site" -Value $newRule