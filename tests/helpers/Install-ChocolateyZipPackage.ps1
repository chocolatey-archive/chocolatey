function Install-ChocolateyZipPackage {
param(
  [string] $packageName, 
  [string] $url,
  [string] $unzipLocation,
  [string] $url64bit
)

  $script:install_chocolateyzippackage_was_called = $true
  $script:packageName = $packageName
  $script:url = $url
  $script:unzipLocation = $unzipLocation
  $script:url64bit = $url64bit
  
  if ($script:exec_install_chocolateyzippackage_actual) { Install-ChocolateyZipPackage-Actual @PSBoundParameters}
}