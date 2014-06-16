@echo off

SET DIR=%~dp0%

if '%1'=='/?' goto usage
if '%1'=='-?' goto usage
if '%1'=='?' goto usage
if '%1'=='/help' goto usage
if '%1'=='help' goto usage
if '%1'=='--help' goto usage

SET PS_ARGS=%*
IF NOT '%1'=='' SET PS_ARGS=%PS_ARGS:"=\"%
IF NOT '%1'=='' SET PS_ARGS=%PS_ARGS:\\"=\"%

@PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' %PS_ARGS%"
SET ErrLvl=%ERRORLEVEL%
goto :exit

:exit
exit /b %ErrLvl%

goto :eof
:usage

@PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' help"
