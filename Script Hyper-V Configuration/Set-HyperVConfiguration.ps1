## Hyper-V network and system configuration ##

# Path to the PowerShell Management Library for Hyper-V
$HyperVLibrary = "$env:ProgramFiles\modules\HyperV"

# Virtual switch name
$SwitchName = "External"

# List of MAC addresses for the adapter in each server to be bound to a virtual switch
# HV1=00:1C:C4:D8:36:BA; HV2=00:19:BB:C9:63:04; 
$MACAddressList = "00:1C:C4:D8:36:BA", "00:19:BB:C9:63:04"

# If the PowerShell Management Library for Hyper-V exist, we're good to go
If (Test-Path $HyperVLibrary) {

    # Match a MAC address to a local adapter and return the adapter description
    $Adapters = get-wmiobject -query "Select * From Win32_NetworkAdapterConfiguration"
    For ($n=0; $n -le $MACAddressList.Count -1; $n++) {
        For ($i=0; $i -le $Adapters.Count -1; $i++) {
            If ($MACAddressList[$n] -eq $Adapters[$i].MACAddress) {
                $AdapterDecription = $Adapters[$i].Description
            }
        }
    }

    # Configure Hyper-V networking with the supplied MAC Address
    If ($AdapterDecription) {
    
        # Import the PowerShell Management Library for Hyper-V
	    Import-Module $HyperVLibrary

        # Create the Hyper-V network and remove the option 'Allow management operating system to share this network adapter'
        New-VMExternalSwitch -VirtualSwitchName $SwitchName -ExternalEthernet $AdapterDecription -force
        Remove-VMSwitchNic -Name $SwitchName -Force
    }
    Else {
        Write-Warning "Unable to match a local adapter from the list of supplied MAC addresses."
    }
    
    
    ## Set Hyper-V system locations
    
    # Get local drives with more than 25GB free space
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ge 25 }
    
    # If more than one drive is returned $Drives will be an array
    If (!($Drives.Count -eq $Null)) {
        
        # If there is more than one drive, use the last drive in the list
        # $Drive = $Drives[$Drives.Count -1].Root <- need to work out how to determine largest drive that is not the system drive
	    $Drive = $Drives[0].Root
    }
    Else {
        $Drive = $Drives.Root
    }
    
    # Create the system paths
    $PathVHD = $Drive + "Hyper-V\HardDisks"
    If (!(Test-Path $PathVHD)) { New-Item -Type Directory -Path $PathVHD }
    $PathMachines = $Drive + "Hyper-V\Machines"
    If (!(Test-Path $PathMachines)) { New-Item -Type Directory -Path $PathMachines }
    If (Test-Path $PathMachines) {
        Set-VMHost -ExtDataPath $PathMachines -VHDPath $PathVHD -Force
    }
    Else {
        Write-Warning "Failed to create system paths, unable to make system changes."
    }
}
Else {
    Write-Error "'$HyperVLibrary' doesn't exist. Unable to continue without the PowerShell Management Library for Hyper-V."
}


## Configure the page file ##

# Disable automatic page file management
$c = Get-WmiObject Win32_computersystem -EnableAllPrivileges
$c.AutomaticManagedPagefile = $false
$c.Put()

# Set the existing page file minimum and maximum sizes to 8GB
$PageFile = Get-WmiObject -Class Win32_PageFileSetting -EnableAllPrivileges
$PageFile.InitialSize = 8192
$PageFile.MaximumSize = 8192
$PageFile.Put()
