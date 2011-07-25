@echo off

SET DIR=%~dp0%

%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& '%DIR%InstallChocolatey.ps1' %*"