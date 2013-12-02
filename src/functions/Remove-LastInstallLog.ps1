function Remove-LastInstallLog{
param(
  [string] $chocoInstallLog = ''
)

  if ($chocoInstallLog -eq '') {
    $chocoInstallLog = (Join-Path $nugetChocolateyPath 'chocolateyInstall.log')
  }

  Write-Debug "Running 'Remove-LastInstallLog' with chocoInstallLog:`'$chocoInstallLog`'";

  try {
    if ([System.IO.File]::Exists($chocoInstallLog)) {[System.IO.File]::Delete($chocoInstallLog)}
  } catch {
    Write-Error "Could not delete `'$chocoInstallLog`': $($_.Exception.Message)"
  }
}
