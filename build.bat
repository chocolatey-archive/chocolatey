@echo off

SET MSBUILD="%windir%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
%MSBUILD% build.proj /v:normal /nologo /clp:Summary;ShowTimestamp
if %ERRORLEVEL% NEQ 0 goto errors

goto :eof

:errors
EXIT /B %ERRORLEVEL%