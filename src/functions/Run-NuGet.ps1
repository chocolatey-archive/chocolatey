function Run-NuGet {
param(
  [string] $packageName, 
  [string] $source = '',
  [string] $version = ''
)
  Write-Debug "Running 'Run-NuGet' for $packageName with source: `'$source`', version:`'$version`'";
  Write-Debug "___ NuGet ____"

  	$srcArgs = Get-SourceArguments $source

  $packageArgs = "install $packageName -Outputdirectory `"$nugetLibPath`" $srcArgs"
  if ($version -notlike '') {
    $packageArgs = $packageArgs + " -Version $version";
  }
  
  if ($prerelease -eq $true) {
    $packageArgs = $packageArgs + " -Prerelease";
  }
  $logFile = Join-Path $nugetChocolateyPath 'install.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  Write-Debug "Calling NuGet.exe $packageArgs"

  $process = New-Object system.Diagnostics.Process
  $process.StartInfo = new-object System.Diagnostics.ProcessStartInfo($nugetExe, $packageArgs)
  $process.StartInfo.RedirectStandardOutput = $true
  $process.StartInfo.RedirectStandardError = $true
  $process.StartInfo.UseShellExecute = $false

  $process.Start() | Out-Null
  $process.WaitForExit()

  $nugetOutput = $process.StandardOutput.ReadToEnd()
  $errors = $process.StandardError.ReadToEnd()


  $nugetOutput | Out-File $logFile
  $errors | Out-File $errorLogFile

  foreach ($line in $nugetOutput) {
    if ($line -ne $null) {Write-Debug $line;}
  }

  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #Throw $errors
  }
  
  if (($nugetOutput -eq '' -or $nugetOutput -eq $null) -and ($errors -eq '' -or $errors -eq $null)) {
    $noExecution = 'Execution of NuGet not detected. Please make sure you have .NET Framework 4.0 installed and are passing arguments to the install command.'
    #write-host  -BackgroundColor Red -ForegroundColor White
    Throw $noExecution
  }
  
  return $nugetOutput
}
