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
  # this is here for specific cases in Posh v3 where -Wait is not honored
  try { if (!($process.HasExited)) { Wait-Process -Id $process.Id } } catch { }

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line
  }
  $errors = Get-Content $errorLogFile
  if ($process.ExitCode -ne 0) {
    throw $errors
  }
}
