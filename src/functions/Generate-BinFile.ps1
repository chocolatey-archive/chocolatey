function Generate-BinFile {
param(
  [string] $name, 
  [string] $path,
  [switch] $useStart
)
  Write-Debug "Running 'Generate-BinFile' for $name with path:`'$path`'";

  $packageBatchFileName = Join-Path $nugetExePath "$name.bat"
  $packageBashFileName = Join-Path $nugetExePath "$name"
  $path = $path.ToLower().Replace($nugetPath.ToLower(), "%DIR%..\").Replace("\\","\")
  $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
  Write-Host "Adding $packageBatchFileName and pointing to `'$path`'." -ForegroundColor $Note
  Write-Host "Adding $packageBashFileName and pointing to `'$path`'." -ForegroundColor $Note
  if ($useStart) {
    Write-Host "Setting up $name as a non-command line application."  -ForegroundColor $Note
"@echo off
SET DIR=%~dp0%
start """" ""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII    

"#!/bin/sh
DIR=`${0%/*}
""$pathBash"" ""`$*"" &" | Out-File $packageBashFileName -encoding ASCII
 
  } else {
"@echo off
SET DIR=%~dp0%
""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII
  
"#!/bin/sh
DIR=`${0%/*}
""$pathBash"" ""`$*""" | Out-File $packageBashFileName -encoding ASCII
  }
}