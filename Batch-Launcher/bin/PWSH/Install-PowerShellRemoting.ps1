# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#####################################################################################################
#
# Registers the WinRM endpoint for this instance of PowerShell.
#
# If the parameters '-PowerShellHome' were specified, it means that the script will be registering
# an instance of PowerShell from another instance of PowerShell.
#
# If no parameter is specified, it means that this instance of PowerShell is registering itself.
#
# Assumptions:
#     1. The CoreCLR and the the PowerShell assemblies are side-by-side in $PSHOME
#     2. Plugins are registered by version number. Only one plugin can be automatically registered
#        per PowerShell version. However, multiple endpoints may be manually registered for a given
#        plugin.
#
#####################################################################################################
[CmdletBinding(DefaultParameterSetName = "NotByPath")]
param
(
    [parameter(Mandatory = $true, ParameterSetName = "ByPath")]
    [switch]$Force,
    [string]
    $PowerShellHome
)

Set-StrictMode -Version Latest

if (! ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "WinRM registration requires Administrator rights. To run this cmdlet, start PowerShell with the `"Run as administrator`" option."
    return
}
function Register-WinRmPlugin
{
    param
    (
        #
        # Expected Example:
        # %windir%\\system32\\PowerShell\\6.0.0\\pwrshplugin.dll
        #
        [string]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $pluginAbsolutePath,

        #
        # Expected Example: powershell.6.0.0-beta.3
        #
        [string]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $pluginEndpointName
    )

    $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\$pluginEndpointName"

    $pluginArchitecture = "64"
    if ($env:PROCESSOR_ARCHITECTURE -match "x86" -or $env:PROCESSOR_ARCHITECTURE -eq "ARM")
    {
        $pluginArchitecture = "32"
    }
    $regKeyValueFormatString = @"
<PlugInConfiguration xmlns="http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration" Name="{0}" Filename="{1}"
    SDKVersion="2" XmlRenderingType="text" Enabled="True" OutputBufferingMode="Block" ProcessIdleTimeoutSec="0" Architecture="{2}"
    UseSharedProcess="false" RunAsUser="" RunAsPassword="" AutoRestart="false">
    <InitializationParameters>
        <Param Name="PSVersion" Value="6.0"/>
    </InitializationParameters>
    <Resources>
        <Resource ResourceUri="http://schemas.microsoft.com/powershell/{0}" SupportsOptions="true" ExactMatch="true">
            <Security Uri="http://schemas.microsoft.com/powershell/{0}" ExactMatch="true"
            Sddl="O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"/>
            <Capability Type="Shell"/>
        </Resource>
    </Resources>
    <Quotas IdleTimeoutms="7200000" MaxConcurrentUsers="5" MaxProcessesPerShell="15" MaxMemoryPerShellMB="1024" MaxShellsPerUser="25"
    MaxConcurrentCommandsPerShell="1000" MaxShells="25" MaxIdleTimeoutms="43200000"/>
</PlugInConfiguration>
"@
    $valueString = $regKeyValueFormatString -f $pluginEndpointName, $pluginAbsolutePath, $pluginArchitecture

    New-Item $regKey -Force > $null
    New-ItemProperty -Path $regKey -Name ConfigXML -Value $valueString > $null
}

function New-PluginConfigFile
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
    param
    (
        [string]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $pluginFile,

        [string]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $targetPsHomeDir
    )

    # This always overwrites the file with a new version of it if the
    # script is invoked multiple times.
    Set-Content -Path $pluginFile -Value "PSHOMEDIR=$targetPsHomeDir" -ErrorAction Stop
    Add-Content -Path $pluginFile -Value "CORECLRDIR=$targetPsHomeDir" -ErrorAction Stop

    Write-Verbose "Created Plugin Config File: $pluginFile" -Verbose
}

function Install-PluginEndpoint {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
    param (
        [Parameter()] [bool] $Force,
        [switch]
        $VersionIndependent
    )

    ######################
    #                    #
    # Install the plugin #
    #                    #
    ######################

    if ($PowerShellHome -ne $null)
    {
        $targetPsHome = $PowerShellHome
        $targetPsVersion = & "$targetPsHome\pwsh" -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
    }
    else
    {
        ## Get the PSHome and PSVersion using the current powershell instance
        $targetPsHome = $PSHOME
        $targetPsVersion = $PSVersionTable.PSVersion.ToString()
    }
    Write-Verbose "PowerShellHome: $targetPsHome" -Verbose

    # For default, not tied to the specific version endpoint, we apply
    # only first number in the PSVersion string to the endpoint name.
    # Example name: 'PowerShell.6'.
    if ($VersionIndependent) {
        $dotPos = $targetPsVersion.IndexOf(".")
        if ($dotPos -ne -1) {
            $targetPsVersion = $targetPsVersion.Substring(0, $dotPos)
        }
    }

    Write-Verbose "Using PowerShell Version: $targetPsVersion" -Verbose

    $pluginEndpointName = "PowerShell.$targetPsVersion"

    $endPoint = Get-PSSessionConfiguration $pluginEndpointName -Force:$Force -ErrorAction silentlycontinue 2>&1

    # If endpoint exists and -Force parameter was not used, the endpoint would not be overwritten.
    if ($endpoint -and !$Force)
    {
        Write-Error -Category ResourceExists -ErrorId "PSSessionConfigurationExists" -Message "Endpoint $pluginEndpointName already exists."
        return
    }

    if (!$PSCmdlet.ShouldProcess($pluginEndpointName)) {
        return
    }

    if ($PSVersionTable.PSVersion -lt "6.0")
    {
        # This script is primarily used from Windows PowerShell for Win10 IoT and NanoServer to setup PSCore6 remoting endpoint
        # so it's ok to hardcode to 'C:\Windows' for those systems
        $pluginBasePath = Join-Path "C:\Windows\System32\PowerShell" $targetPsVersion
    }
    else
    {
        $pluginBasePath = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows) + "\System32\PowerShell") $targetPsVersion
    }

    $resolvedPluginAbsolutePath = ""
    if (! (Test-Path $pluginBasePath))
    {
        Write-Verbose "Creating $pluginBasePath"
        $resolvedPluginAbsolutePath = New-Item -Type Directory -Path $pluginBasePath
    }
    else
    {
        $resolvedPluginAbsolutePath = Resolve-Path $pluginBasePath
    }

    $pluginPath = Join-Path $resolvedPluginAbsolutePath "pwrshplugin.dll"

    # This is forced to ensure the the file is placed correctly
    Copy-Item $targetPsHome\pwrshplugin.dll $resolvedPluginAbsolutePath -Force -Verbose -ErrorAction Stop

    $pluginFile = Join-Path $resolvedPluginAbsolutePath "RemotePowerShellConfig.txt"
    New-PluginConfigFile $pluginFile (Resolve-Path $targetPsHome)

    # Register the plugin
    Register-WinRmPlugin $pluginPath $pluginEndpointName

    ####################################################################
    #                                                                  #
    # Validations to confirm that everything was registered correctly. #
    #                                                                  #
    ####################################################################

    if (! (Test-Path $pluginFile))
    {
        throw "WinRM Plugin configuration file not created. Expected = $pluginFile"
    }

    if (! (Test-Path $resolvedPluginAbsolutePath\pwrshplugin.dll))
    {
        throw "WinRM Plugin DLL missing. Expected = $resolvedPluginAbsolutePath\pwrshplugin.dll"
    }

    try
    {
        Write-Host "`nGet-PSSessionConfiguration $pluginEndpointName" -foregroundcolor "green"
        Get-PSSessionConfiguration $pluginEndpointName -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Commands.WriteErrorException]
    {
        throw "No remoting session configuration matches the name $pluginEndpointName."
    }
}

Install-PluginEndpoint -Force $Force
Install-PluginEndpoint -Force $Force -VersionIndependent

Write-Host "Restarting WinRM to ensure that the plugin configuration change takes effect.`nThis is required for WinRM running on Windows SKUs prior to Windows 10." -foregroundcolor Magenta
Restart-Service winrm


# SIG # Begin signature block
# MIIkXwYJKoZIhvcNAQcCoIIkUDCCJEwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCQ4Eq0Be395yvx
# gX00w5wRLlMV6VkjXjwho5yqga81i6CCDYUwggYDMIID66ADAgECAhMzAAABBGni
# 27n7ig2DAAAAAAEEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMTgwNzEyMjAwODQ5WhcNMTkwNzI2MjAwODQ5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCbxZXyl/b/I2psnXNZczib07TjhK2NuD4l56C4IFpKkXA42BSovZrA/Q1rHuzh
# /P8EPOJhYK5VamGS+9cAfZ7qaTbW/Vd5GZf+hJH2x1Wtpq4Ciu2xkUdWzUqHZkWn
# MBsa7ax7awXSM4JzvsZvHMzU6BoFFQAukZe2S8hhZyKL5xMSaMIXFK8mWrbuVXN8
# 9USzIScGAOu1Nvn8JoqtP39EFMN6uyPIi96+ForBIaICAdl/mJLiMVOPh7GQJJsX
# +hVNygFsEGxSAqKTX2IDQSSMcKdwLI1LL9czWVz9XeA/1+SEF7t9PnnTgkNiVEDI
# m17PcBQ7YDxpP5835/gWkjOLAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuhfjJWj0u9V7I6a4tnznpoKrV64w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQzNzk2NjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# ACnFggs5mSAM6CRbiTs4UJKDlduR8jvSpPDagVtzjmdIGrbJigd5WmzOw/xmmBey
# u9emFrUDVoV7Kn0vQAZOnmnXaRQVjmP7zID12xGcUO5LAnFMawcF/mdT8Rm2bm4s
# 8o/URSnhNgiyHHiBJ5aHmUIYd5TcxrydpNtWpjbQQ0hfQAR+Z+mI2ADH6zL/3gp3
# YANz/p6hxx3zwLMtYYfI8TeF3PxtPEsTShJ2tVBKTedd808h5JgSgYH+6Vyo/BSM
# 0QKfZft2dbdiU8d92se6QuJueyZKI4Iy2I11HhFvi396BtWqHxilcBPn7midB7wG
# 6YkDlgxq4iGrJQPYtwER4cQilikxfMNVTtAc50XGZgCKFSHExQFwHeJoATkPIiHJ
# qHN/cNgs9PVp5UlsOaWiqcp7OdX5d28wc4OWwKOLruV/3WNN2hXLe/kd5Y7EOqpK
# 9C1FZp/yXrhJFznj3x1JiWGLujOvXkLqGtT1UVPxpV2Sm4dnuHarBlXhrtWDrzn/
# IDGLXOb6tQfPhifHQQIjOW1ZTi7AeK86SWNs4njgI3bUK6hnADxlUlgw0njpeO3t
# uyl9oh845exZx5OZRfkAiMpEekfWJkfN1AnCtXqQDD0WFn63lNtGUgBKHrk9aclR
# ZWrVPxHELTeXX5LCDTEMmtZZd/BQSIeJdpPY831KsCLYMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCFjAwghYsAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAEEaeLbufuKDYMAAAAA
# AQQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIAN8
# oa7954bQx31Epf+Makz8nbnaXb2qNKqFSEePic+8MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAR+rDZtsoX2DJR0uWp5dOe3brpNZgnfMub9Ac
# /OxpnqcZ1r8IcxwgDa4LSSSUTMxuePKc0CjfMdQ+NJuFZdUVkCA873uzDaFt5ERy
# gu+hXfN2dPHIkpQCXcojodhQLpEUz3c5yMidkERonRh5oW3TwQ14LVRuw0PFW0VE
# jILxdrpIVZwrNXyLpsaW//r5l9no/iyA1lOt6Wa8VlK3Mea3P56mH6tsg+d6ph63
# azEWUFpdJyaDTP7FFlBYgZZVKHoxhyEoTf+G66rzAdNih9HBOCtlO4kIG9zKw5LN
# U6Y0SiRYmsaVQwexCvcLmyrAVe5GTWlOk0YRk7slud9nwHDILaGCE7owghO2Bgor
# BgEEAYI3AwMBMYITpjCCE6IGCSqGSIb3DQEHAqCCE5MwghOPAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFYBgsqhkiG9w0BCRABBKCCAUcEggFDMIIBPwIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCAT9cj4QQs4tye73v8KuEkyTcw7P5nJNrTL
# VQebSpibkwIGXMHIRtIuGBMyMDE5MDUxNjIwMjk0MC42NDZaMAcCAQGAAgH0oIHU
# pIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYD
# VQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMd
# VGhhbGVzIFRTUyBFU046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFNlcnZpY2Wggg8iMIIE9TCCA92gAwIBAgITMwAAANAcamBh
# wufhrQAAAAAA0DANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
# Q0EgMjAxMDAeFw0xODA4MjMyMDI2MjhaFw0xOTExMjMyMDI2MjhaMIHOMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3Nv
# ZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCbPoY211rO
# +8Z9zCo8IAYVmps5IDy61+pDNMYTp0m8huVorXo5SKMmKAYnE0C1sg6srmX5Q0s4
# a64HYRinDv2ly2HM2cU36hva3Ey1ZXtNkas6jSudX1Idqe3NuICGkOTGtydhBeSL
# WQ57tWx4c0/eFPyRb56B93OVe35gMirnNNUxG13+Z0PV52SRjGTZ+zUPZy7crK1U
# P8RNbKfHWd2PYZK6WSRv37Vd7ocqC79HbP1xJb8pZLxTVCqWlfPokE1oZfKxmHTt
# BDlPyT1rGkqCgV97H/KWaAeXsy/WReXaWuaPVxJVCnpcEsRrgtfFmnSiNoEzu+fg
# 7FIIBPXOkkYrAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQUA4Mol6hrJfLEUzIfma06
# vHcYxXEwHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8w
# TTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVj
# dHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
# BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9N
# aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEApbwklmQJ31r0v5RTfzYZ
# kW48IPXgYF18spdGCVoMGD7qK1GR5IXN0eTzTWNJTRpOkR4726dJ9trulEfwTDe9
# owtngVnUTTZco4j1Ba1hLnc0rcT1wZfbQc9bXWmhEI3KLobATjK7Stfz49VV9QvR
# gr3ldnqGGbY5miHg5CKOIGOr9XDFtT3ve9jTqJZl8qxJVoKfHcUidYdGwfAKj8zc
# MIrt0+aE9V7G00wTNV9duDIA5vazZAUkJh6vs+H2Hmsl0SreztcnLOuSGL5HwSJr
# enGPlBT4mEeZqRhdJWunQdNWfEGmN1ovQZs7KayRu9l5Oia8rM7wkXDVF9cE+cCB
# LDCCBnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jv
# c29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIx
# MzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX
# 9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkT
# jnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG
# 8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGK
# r0tkiVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6
# Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEF
# TyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6
# XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
# VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxi
# aNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMu
# Y3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQw
# gaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRt
# MEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0
# AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/
# gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtU
# VwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9
# Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9
# BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOd
# eyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1
# JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4Ttx
# Cd9ddJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5
# u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9U
# JyH3yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Z
# ta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa
# 7wknHNWzfjUeCLraNtvTX4/edIhJEqGCA7AwggKYAgEBMIH+oYHUpIHRMIHOMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNy
# b3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRT
# UyBFU046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFNlcnZpY2WiJQoBATAJBgUrDgMCGgUAAxUAKSkfi3FxMlc3Nr+9neHTozE+
# jpWggd4wgdukgdgwgdUxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMScw
# JQYDVQQLEx5uQ2lwaGVyIE5UUyBFU046NERFOS0wQzVFLTNFMDkxKzApBgNVBAMT
# Ik1pY3Jvc29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJKoZIhvcNAQEF
# BQACBQDgh5GKMCIYDzIwMTkwNTE2MTUzNjQyWhgPMjAxOTA1MTcxNTM2NDJaMHcw
# PQYKKwYBBAGEWQoEATEvMC0wCgIFAOCHkYoCAQAwCgIBAAICIR8CAf8wBwIBAAIC
# GnswCgIFAOCI4woCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAK
# MAgCAQACAxbjYKEKMAgCAQACAwehIDANBgkqhkiG9w0BAQUFAAOCAQEAPlJReCNU
# /dF0812CQRAy3Z+tmoCfzt4kYzUIDkYn0sk1SKTpKV+Iyfpu30Xy49Wq5jl6r0iQ
# ZdjmfANgFhPqP7g8NzV8yTpfjBm0AbQbvBSTG3bCFSjQULpbGJLzyyatt+pKGiIF
# STXKGfR2pr8WbuWeN8UElxypg1qSP6wfdNqfWVPwzCLJLJYva+thhxu/WmsQvuH3
# 0+a3KOxdG6d543ElbKNB6yYNzy9K9xjFzqgVJHJzvcVtMHfOn2d1/jAmRc2chWlM
# 1CWxRZOqp8209SMsY3+IAPsVZGYgaMv823jLTgPS0sekU7JRyZp5tuG+pUqQ46AV
# 6fS45U9hI6pJfTGCAvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAA0BxqYGHC5+GtAAAAAADQMA0GCWCGSAFlAwQCAQUAoIIBMjAa
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIPj+0mDC
# uLZDPpjihrlIDsi62wdKMogCHwMamZaNRWSPMIHiBgsqhkiG9w0BCRACDDGB0jCB
# zzCBzDCBsQQUKSkfi3FxMlc3Nr+9neHTozE+jpUwgZgwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAANAcamBhwufhrQAAAAAA0DAWBBSCS6E2
# bdRCOu3IeSEMqeazn6F7ODANBgkqhkiG9w0BAQsFAASCAQASRBbuJAAVf4QHx3SM
# +Q3+OugOL/Zb58QsuvfvqJvG1PU1KD1XyYUl2YXXy9rgASuM2mH0S898cdc6rgvH
# 8i5z9nLa2Pudp9KD93YyRDkRW3fEDMayTbN9oTx/VP9yd69YdNJWQJxxvnQjYnqU
# A4ayKs5g65u2Ideoq4fLyu7zFE13Ob0BVVvf8mx9G+p1t996cB1zCs5snqN3GrxL
# jFVMCXZ+mohj12zGoPd24Ro4r8R9gBUl9s2QrQw8oLzqCQqLPTXN6B+0fpwcvAMq
# 4vkGa1wRo+qoLXpgpzoM3Y5P/YhODv0AbjF6Bkz8qQvkXRzDbwggTaNrSGyXWrRe
# eQh0
# SIG # End signature block
