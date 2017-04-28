<#
    .Synopsis
        Installs or downloads the Visual C++ Redistributables listed in an external XML file.

    .DESCRIPTION
        Installs or downloads the Visual C++ Redistributables listed in an external XML file.

    .NOTES   
        Name: Install-VisualCRedistributables.ps1
        Author: Aaron Parker
        Version: 1.0
        DateUpdated: 2017-04-28

    .LINK
        http://stealthpuppy.com

    .PARAMETER Xml
        The XML file that contains the details about the Visual C++ Redistributables.

    .PARAMETER DownloadOnly
        Only download the redistributables and do not install them.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"

        Description:
        Specifies the path to the XMl file containing the registry values to set and file actions and records to a log file at $env:SystemRoot\Temp\Set-Customisations.log.
#>

[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low")]
PARAM (
    [Parameter(Mandatory=$True, HelpMessage="The path to the XML document describing the Redistributables.")]
    # [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$Xml,

    [Parameter(Mandatory=$False, HelpMessage="Specify to download the Redistributables and not install them.")]
    [bool]$DownloadOnly = $False
)

BEGIN {
    # Variables
    $build = [Environment]::OSVersion.Version

    # Get script elevation status
    [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

PROCESS {
    
    Function Write-Log {
        param (
        [string]$Path,
        [string]$Entry)

        Write-Log -Path $logPath -Entry "$Entry" | Out-File -FilePath $Path -Append
        Return $?
    }

    # Read the specifed XML document
    $xmlDocument = ( Select-Xml -Path $Xml -XPath / ).Node

    # Select settings from the document for the current OS
    $customisations = $xmlDocument.SelectNodes("/Redistributables")

    # Testing
    # ForEach ( $setting in $customisations.SelectNodes("DefaultUser/Registry/*[@Path]") ) {
    #     Write-Host "$default\$($setting.Path)"
    #     ForEach ( $value in $setting.SelectNodes("Values/*[@Name]") ) {
    #         Write-Host "Value: $($value.Name); Data: $($value.InnerText)"
    #     }
    # }

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Default Profile
        # Set defaut profile
        # Loop through each setting in the XML structure to set the registry value
        ForEach ( $platform in $customisations.SelectNodes("Platform") ) {
            
            # Set specified registry values specified in the XML
            ForEach ( $value in $setting.SelectNodes("Values/*[@Name]") ) {
                If ($pscmdlet.ShouldProcess("$($value.Name) in $default\$($setting.Path)", "Create value")) {

                    # Convert values to an integer where required (fix with an xsd?)
                    If ($value.Data.Type -eq "Int") {  
                        $val = $value.InnerText.ToInt32($Null)
                    } Else {
                        $val = $value.InnerText
                    }

                    # Add or set the registry value
                    New-ItemProperty -Path "$default\$($setting.Path)" -Name $($value.Name) -Value $val -Force
                }
            }
        }

}