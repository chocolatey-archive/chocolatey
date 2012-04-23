function Chocolatey-Pack {
param(
  [string] $packageName
)

  $packageArgs = "pack $packageName -NoPackageAnalysis"
  $logFile = Join-Path $nugetChocolateyPath 'pack.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  
  Write-Host "Calling `'$nugetExe $packageArgs`'."
  
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line
  }
  $errors = Get-Content $errorLogFile
  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #throw $errors
  }
}