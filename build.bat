@echo off
SET baseDir=%~dp0%

IF "%1"=="" (
	SET Target=Go
)  ELSE (
	SET Target="%1"
)

SET MSBUILD="%windir%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
%MSBUILD% %baseDir%\build.proj /v:normal /nologo /clp:Summary;ShowTimestamp /t:%Target%
if %ERRORLEVEL% NEQ 0 goto errors

goto :eof

:errors
EXIT /B %ERRORLEVEL%