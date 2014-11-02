function Generate-BinFile {
param(
  [string] $name,
  [string] $path,
  [switch] $useStart,
  [string] $command = ''
)
  Write-Debug "Running 'Generate-BinFile' for $name with path:`'$path`'|`$useStart:$useStart|`$command:$command";

  $packageBatchFileName = Join-Path $nugetExePath "$name.bat"
  $packageBashFileName = Join-Path $nugetExePath "$name"
  $packageShimFileName = Join-Path $nugetExePath "$name.exe"

  if (Test-Path ($packageBatchFileName)) {Remove-Item $packageBatchFileName -force}
  if (Test-Path ($packageBashFileName)) {Remove-Item $packageBashFileName -force}
  $path = $path.ToLower().Replace($nugetPath.ToLower(), "..\").Replace("\\","\")

  $ShimGenArgs = "-o `"$packageShimFileName`" -p `"$path`""
  if ($command -ne $null -and $command -ne '') {
    $ShimGenArgs +=" -c $command"
  }
  if ($useStart) {
    $ShimGenArgs +=" -gui"
  }

  Write-Debug "Calling $ShimGen $ShimGenArgs"

  if (Test-Path ("$ShimGen")) {
    #Start-Process "$ShimGen" -ArgumentList "$ShimGenArgs" -Wait -WindowStyle Hidden
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = new-object System.Diagnostics.ProcessStartInfo($ShimGen, $ShimGenArgs)
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $process.Start() | Out-Null
    $process.WaitForExit()
  }

  if (Test-Path ($packageShimFileName)) {
    Write-Host "Added $packageShimFileName shim pointed to `'$path`'." -ForegroundColor $Note
  } else {
    Write-Warning "An error occurred generating shim, using old method."

    $path = "%DIR%$($path)"
    $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
    Write-Host "Adding $packageBatchFileName and pointing to `'$path`'." -ForegroundColor $Note
    Write-Host "Adding $packageBashFileName and pointing to `'$path`'." -ForegroundColor $Note
    if ($useStart) {
      Write-Host "Setting up $name as a non-command line application."  -ForegroundColor $Note
"@echo off
SET DIR=%~dp0%
start """" ""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII

      $sw = New-Object IO.StreamWriter "$packageBashFileName"
      $sw.Write("#!/bin/sh`nDIR=`${0%/*}`n""$pathBash"" ""`$@"" &`n")
      $sw.Close()
      $sw.Dispose()
    } else {

"@echo off
SET DIR=%~dp0%
cmd /c """"$path"" %*""
exit /b %ERRORLEVEL%" | Out-File $packageBatchFileName -encoding ASCII

      $sw = New-Object IO.StreamWriter "$packageBashFileName"
      $sw.Write("#!/bin/sh`nDIR=`${0%/*}`n""$pathBash"" ""`$@""`nexit `$?`n")
      $sw.Close()
      $sw.Dispose()

    }
  }
}
