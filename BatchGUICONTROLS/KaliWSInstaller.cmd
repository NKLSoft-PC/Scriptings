@@echo off
@@findstr/v "^@@.*" "%~f0" > "%~f0.ps1" & powershell -ExecutionPolicy ByPass "%~f0.ps1" %* & del "%~f0.ps1" & goto:
<#
.SYNOPSIS
Installs Windows subsystem for linux (WSL) option if not already configured. Also downloads and starts the distro setup.
.DESCRIPTION
Installs Windows subsystem for linux (WSL) option if not already configured. Also downloads and starts the distro setup. Supports kali-linux, sles, and opensuse.
.PARAMETER InstallPath
Path to install chosen WSL distribution
.PARAMETER Distro
Distro to attempt to download and install
.EXAMPLE
.\Install-WSL.ps1

Configures the WSL feature if required then attempts to install the kali-linux wsl distribution to C:\WSLDistros\kali-linux
.NOTES
Author: Zachary Loeber
- The downloads are skipped if already found in the $env:temp directory. 
- The installer process may fail without a reboot between the feature install and the distro installer running.
- Unregister or manage the default distro install via wslconfig.exe
.LINK
https://docs.microsoft.com/en-us/windows/wsl/install-on-server
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage = 'Path to save and install WSL distro to.')]
    [string]$InstallPath = 'C:\WSLDistros\kali-linux',
    [Parameter(HelpMessage = 'Distro to attempt to download and install')]
    [ValidateSet('kali-linux', 'opensuse', 'sles')]
    [string]$Distro = 'kali-linux'
)

Begin {
    $WSLDownloadPath = Join-Path $ENV:TEMP "$Distro.zip"
    $DistroURI = @{
        'kali-linux'   = 'https://aka.ms/wsl-kali-linux'
      
    }
    $DistroEXE = @{
        'kali-linux'   = 'kali-linux.exe'
      
    }

    function Start-Proc {
        param([string]$Exe = $(Throw "An executable must be specified"),
            [string]$Arguments,
            [switch]$Hidden,
            [switch]$waitforexit)

        $startinfo = New-Object System.Diagnostics.ProcessStartInfo
        $startinfo.FileName = $Exe
        $startinfo.Arguments = $Arguments
        if ($Hidden) {
            $startinfo.WindowStyle = 'Hidden'
            $startinfo.CreateNoWindow = $True
        }
        $process = [System.Diagnostics.Process]::Start($startinfo)
        if ($waitforexit) { $process.WaitForExit() }
    }

    Function ReRunScriptElevated {
        if ( -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') ) {
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
            Exit
        }
    }

    ReRunScriptElevated
}
end {
    if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -ne 'Enabled') {
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
			Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        }
        catch {
            Write-Warning 'Unable to install the WSL feature!'
        }
    }
    else {
        Write-Output 'Windows subsystem for Linux optional feature already installed!'
    }

    $InstalledWSLDistros = @((Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' -ErrorAction:SilentlyContinue | ForEach-Object { Get-ItemProperty $_.pspath }).DistributionName)

    $WSLExe = Join-Path $InstallPath $DistroEXE[$Distro]

    if ($InstalledWSLDistros -notcontains $Distro) {
        Write-Output "WSL distro $Distro is not found to be installed on this system, attempting to download and install it now..."    

        if (-not (Test-Path $WSLDownloadPath)) {
            Invoke-WebRequest -Uri $DistroURI[$Distro] -OutFile $WSLDownloadPath -UseBasicParsing
        }
        else {
            Write-Warning "The $Distro zip file appears to already be downloaded."
        }

        Expand-Archive $WSLDownloadPath $InstallPath -Force

        if (Test-Path $WSLExe) {
            Write-Output "Starting $WSLExe"
            Start-Proc -Exe $WSLExe -waitforexit
        }
        else {
            Write-Warning "  $WSLExe was not found for whatever reason"
        }
    }
    else {
        Write-Warning "Found $Distro is already installed on this system. Enter it simply by typing bash.exe"
    }
}
exit