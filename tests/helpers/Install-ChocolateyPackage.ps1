function Install-ChocolateyPackage {
param(
  [string] $packageName, 
  [string] $fileType,
  [string] $silentArgs,
  [string] $url,
  [string] $url64bit,
  $validExitCodes = @(0)
)
 
  $script:install_chocolateypackage_was_called = $true
  $script:packageName = $packageName
  $script:fileType = $fileType
  $script:silentArgs = $silentArgs
  $script:url = $url
  $script:url64bit = $url64bit
  $script:validExitCodes = $validExitCodes
  
  if ($script:exec_install_chocolateypackage_actual) { Install-ChocolateyPackage-Actual @PSBoundParameters}
}