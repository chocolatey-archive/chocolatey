function Chocolatey-Pack {
param(
  [string] $packageName
)
  Write-Debug "Running 'Chocolatey-Pack' for $packageName. If nuspec name is not passed, it will find the nuspec file in the current working directory";

  $packageArgs = "pack $packageName -NoPackageAnalysis -NonInteractive"
  $logFile = Join-Path $nugetChocolateyPath 'pack.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'

  Write-Host "Calling `'$nugetExe $packageArgs`'."

  $process = Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile -PassThru
  if ($host.Version.Major -ge 3) { Wait-Process -InputObject $process }

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
