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
        Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.
#>

[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low")]
PARAM (
    [Parameter(Mandatory=$True, HelpMessage="The path to the XML document describing the Redistributables.")]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [string]$File,

    [Parameter(Mandatory=$False, HelpMessage="Specify a target path to download the Redistributables to.")]
    [string]$Path = ".\",

    [Parameter(Mandatory=$False, HelpMessage="Enable the installation of the Redistributables after download.")]
    [bool]$Install = $False    
)

BEGIN {
    # Variables
    # $build = [Environment]::OSVersion.Version

    # Get script elevation status
    # [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
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
    $xmlContent = ( Select-Xml -Path $File -XPath "/Redistributables/Platform" ).Node

    # Loop through each setting in the XML structure to set the registry value
    ForEach ( $platform in $xmlContent ) {

        # Create variables from the content to simplify references below
        $plat = $platform | Select-Object -ExpandProperty Architecture
        $rel = $platform | Select-Object -ExpandProperty Release
        $arg = $platform | Select-Object -ExpandProperty Install
        
        ForEach ($redistributable in $platform.Redistributable ) {
            
            # Create variables from the content to simplify references below
            $uri = $redistributable.Download
            $filename = $uri.Substring($uri.LastIndexOf("/") + 1)
            $target= "$((Get-Item $Path).FullName)\$rel\$plat\$($redistributable.Name)"

            # Create the folder to store the downloaded file
            If (!(Test-Path -Path $target)) {
                If ($pscmdlet.ShouldProcess($target, "Create")) {
                    New-Item -Path $target -Type Directory -Force
                }
            }

            # Download the Redistributable to the target path
            If ($pscmdlet.ShouldProcess("$uri", "Download")) {
                Invoke-WebRequest -Uri $uri -OutFile "$target\$filename"
            }
        }
    }

}