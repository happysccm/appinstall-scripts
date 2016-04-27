@ECHO OFF
powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted
powershell -NonInteractive .\Enable-EnableNetFramework.ps1
powershell Set-ExecutionPolicy -ExecutionPolicy Restricted
exit 0