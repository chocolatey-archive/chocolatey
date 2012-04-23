function Install-ChocolateyInstallPackage {
param(
  [string] $packageName, 
  [string] $fileType,
  [string] $silentArgs,
  [string] $file,
  $validExitCodes = @(0)
)
  
  $script:install_chocolateyinstallpackage_was_called = $true
  $script:packageName = $packageName
  $script:fileType = $fileType
  $script:silentArgs = $silentArgs
  $script:file = $file
  $script:validExitCodes = $validExitCodes
  
  if ($script:exec_install_chocolateyinstallpackage_actual) { Install-ChocolateyInstallPackage-Actual @PSBoundParameters}
}