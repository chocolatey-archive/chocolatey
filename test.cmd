@echo off

SET DIR=%~dp0%

%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "$Error.Clear();& '%DIR%test.ps1' %*;Exit $Error.Count + $LastExitCode"

if %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%