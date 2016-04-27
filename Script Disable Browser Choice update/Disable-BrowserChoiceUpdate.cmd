@ECHO OFF
REM Disable the Browser Choice update if it's installed

REM Resources
REM http://support.microsoft.com/kb/2019411/

REG ADD HKLM\Software\BrowserChoice /v Enable /d 0 /t REG_DWORD /f
REG ADD HKLM\Software\BrowserChoice /v Shortcut /d 0 /t REG_DWORD /f
