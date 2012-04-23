function Install-ChocolateyPowershellCommand {
param(
  [string] $packageName,
  [string] $psFileFullPath, 
  [string] $url,
  [string] $url64bit
)

  $script:install_chocolateypowershellcommand_was_called = $true
  $script:packageName = $packageName
  $script:psFileFullPath = $psFileFullPath
  $script:url = $url
  $script:url64bit = $url64bit
  
  if ($script:exec_install_chocolateypowershellcommand_actual) { Install-ChocolateyPowershellCommand-Actual @PSBoundParameters}
}