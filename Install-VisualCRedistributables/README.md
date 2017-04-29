# Install-VisualCRedistributables.ps1
This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture.

*NOTE:* some validation of the Redistributables listed in the XML file is required, as not all need to be installed.

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

## Parameters
### File
The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

Example - Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml.

```.\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"```

### Path
Specify a target folder to download the Redistributables to, otherwise use the current folder.

Example - Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

```.\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist```


### Install
By default the script will only download the Redistributables. Add -Install to install each of the Redistributables as well.

Example - Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.

```.\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install:$True```



