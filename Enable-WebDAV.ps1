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