function Run-NuGet {
param(
  [string] $packageName, 
  [string] $source = '',
  [string] $version = ''
)
@"
$h2
NuGet
$h2
"@ | Write-Debug

  	$srcArgs = Get-SourceArgument $source

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
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    if ($line -ne $null) {Write-Debug $line;}
  }
  $errors = Get-Content $errorLogFile
  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #Throw $errors
  }
  
  if (($nugetOutput -eq '' -or $nugetOutput -eq $null) -and ($errors -eq '' -or $errors -eq $null)) {
    $noExecution = 'Execution of NuGet not detected. Please make sure you have .NET Framework 4.0 installed.'
    #write-host  -BackgroundColor Red -ForegroundColor White
    Throw $noExecution
  }
  
  return $nugetOutput
}