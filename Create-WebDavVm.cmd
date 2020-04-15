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
# Warning: This script is only for demo purposes.
#          The connection to the WebDAV server is not secured.
#          Content and user credentials are transmitted unencrypted.

# Before using this script, you need the PowerShell commandlets installed, have already an Azure 
# subscription imported and the first three settings in this file changed. (See region Settings.)
# How to do this, you can read here (in German): 
#     http://blogs.msdn.com/b/pkirchner/archive/2015/01/13/grundlagen-powershell-f-252-r-microsoft-azure-installieren.aspx
#     http://blogs.msdn.com/b/pkirchner/archive/2015/01/19/grundlagen-azure-amp-powershell-verwaltungszertifikate-installieren.aspx

#region Settings - enter your settings here

# Must change:
# Your subscription name.
$subscriptionName = "MSFT MVA Stage"
# Change this service name to a unique name. If the name is not unique, creation will fail.
$serviceName = "webdavservertest54191"
# Change the path to the Enable-WebDAV.ps1 file. Should be the folder where you unpacked the current file.
$scriptFile = New-Object System.IO.FileInfo ("C:\Users\pkirch\OneDrive @ Microsoft\FY15\Content\2014-11-28 New Era Day 3\Enable-WebDAV.ps1")

# Can change:
$adminUsername = "adm_demo"
$adminPassword = "Azureisttoll!"
$storageAccountName = $serviceName
$vmName = "webdavserver"
$instanceSize = "Small" # Get-AzureRoleSize

# No need to change:
$imageFamily = "Windows Server 2012 R2 Datacenter"
$location = "West Europe" # Get-AzureLocation

#endregion

# In case you have more than one Azure subscription, select one.
Select-AzureSubscription -SubscriptionName $subscriptionName

# Get latest image for defined image family.
$imageName = Get-AzureVMImage | 
                Where-Object -Property ImageFamily -eq $imageFamily | 
                Sort-Object -Property PublishedDate -Descending | 
                Select-Object -ExpandProperty ImageName -First 1

# Create storage account and set is as current.
New-AzureStorageAccount -Location $location -StorageAccountName $storageAccountName -Type Standard_LRS
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountName $storageAccountName

# Create destination container in storage if it does not exist.
New-AzureStorageContainer -Name customscripts -Permission Off -ErrorAction Ignore

# Upload PowerShell file
Set-AzureStorageBlobContent -Container customscripts -File $scriptFile.FullName -Force

# Create new VM configuration, add provisioning data to it, and start it.
New-AzureVMConfig -ImageName $imageName -InstanceSize $instanceSize -Name $vmName |
    Add-AzureProvisioningConfig -Windows -AdminUsername $adminUsername -Password $adminPassword |
    Add-AzureEndpoint -LocalPort 80 -Name HTTP -Protocol tcp -PublicPort 80 |
    Add-AzureEndpoint -LocalPort 443 -Name HTTPS -Protocol tcp |
    Set-AzureVMCustomScriptExtension -ContainerName customscripts -FileName $scriptFile.Name -Run $scriptFile.Name |
    New-AzureVM -ServiceName $serviceName -Location $location

Write-Host "Your action: Map network drive via Windows Explorer to: http://$serviceName.cloudapp.net/" -ForegroundColor DarkGreen