@ECHO OFF
REM Set the exeuction policy to unrestricted
powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted

REM Run the PowerShell script to configure Hyper-V network and system settings and other 
REM settings such as the page file size
COPY Set-HyperVConfiguration.ps1 %TEMP%
PUSHD %TEMP%
powershell -NonInteractive .\Set-HyperVConfiguration.ps1
POPD

REM Enable remote Server Manager connections to this machine
powershell -NonInteractive %SystemRoot%\System32\Configure-SMRemoting.ps1 -Force -Enable

REM Set the exeuction policy back to restricted
powershell Set-ExecutionPolicy -ExecutionPolicy Restricted


REM Additional configuration:
REM Services
sc config vds start=  auto
net start vds
sc config msiscsi start=  auto
net start msiscsi

REM Windows Firewall management
netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
netsh advfirewall firewall set rule group="Remote Administration" new enable= yes
netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable=yes
netsh advfirewall firewall set icmpsetting 8
