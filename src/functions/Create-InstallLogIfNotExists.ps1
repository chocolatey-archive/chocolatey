function Create-InstallLogIfNotExists{
param(
  [string] $chocoInstallLog = ''
)
  Write-Debug "Running 'Create-InstallLog' with chocoInstallLog:`'$chocoInstallLog`'";
  
  if ($chocoInstallLog -eq '') {
    $chocoInstallLog = (Join-Path $nugetChocolateyPath 'chocolateyInstall.log')
  }
	try {
    if (![System.IO.File]::Exists("$chocoInstallLog")) {
      New-Item "$chocoInstallLog" -type file | out-null
      #Start-Sleep 2
    }
  } catch {
    Write-Error "Could not create `'$chocoInstallLog`': $($_.Exception.Message)"
  }
}