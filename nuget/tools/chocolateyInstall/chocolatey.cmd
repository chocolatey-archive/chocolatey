@echo off

SET DIR=%~dp0%

if '%1'=='/?' goto usage
if '%1'=='-?' goto usage
if '%1'=='?' goto usage
if '%1'=='/help' goto usage
if '%1'=='help' goto usage

%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& '%DIR%chocolatey.ps1' %*"

goto :eof
:usage

%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& '%DIR%chocolatey.ps1'"