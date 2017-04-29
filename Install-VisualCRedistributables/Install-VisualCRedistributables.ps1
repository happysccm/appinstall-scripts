<#
    .Synopsis
        Installs and/or downloads the Visual C++ Redistributables listed in an external XML file.

    .DESCRIPTION
        This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture.

        This can be run to download and optionally install the Visual C++ (2005 - 2015) Redistributables as specified in the external XML file passed to the script.

        The basic structure of the XML file should be:

        <Redistributables>
        <Platform Architecture="x64" Release="" Install="">
            <Redistributable>
                <Name></Name>
                <URL></URL>
                <Download></Download>
        </Platform>
        <Platform Architecture="x86" Release="" Install="">
            <Redistributable>
                <Name></Name>
                <URL></URL>
                <Download></Download>
            </Redistributable>
        </Platform>
    </Redistributables>

    .NOTES   
        Name: Install-VisualCRedistributables.ps1
        Author: Aaron Parker
        Version: 1.0
        DateUpdated: 2017-04-29

    .LINK
        http://stealthpuppy.com

    .PARAMETER File
        The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .PARAMETER Path
        Specify a target folder to download the Redistributables to, otherwise use the current folder.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .PARAMETER Install
        By default the script will only download the Redistributables. Add -Install to install each of the Redistributables as well.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install

        Description:
        Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.
#>

[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low")]
PARAM (
    [Parameter(Mandatory=$True, HelpMessage="The path to the XML document describing the Redistributables.")]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [string]$File,

    [Parameter(Mandatory=$False, HelpMessage="Specify a target path to download the Redistributables to.")]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
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
        param ([string]$Path, [string]$Entry)
        Write-Log -Path $logPath -Entry "[$(Get-Date)] $Entry" | Out-File -FilePath $Path -Append
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
        
        # Step through each redistributable defined in the XML
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
            } Else {
                Write-Verbose "Folder '$($redistributable.Name)' exists. Skipping."
            }

            # Download the Redistributable to the target path
            If (!(Test-Path -Path "$target\$filename" -PathType 'Leaf')) {
                If ($pscmdlet.ShouldProcess("$uri", "Download")) {
                    Invoke-WebRequest -Uri $uri -OutFile "$target\$filename"
                }
            } Else {
                Write-Verbose "Redistributable exists. Skipping."
            }

            # Install the Redistributable if the -Install switch is specified
            If ($Install) {
                If ($pscmdlet.ShouldProcess("'$target\$filename $arg'", "Installing")) {
                    Start-Process -FilePath "$target\$filename" -ArgumentList $arg -Wait
                }
            }
        }
    }
}

#end