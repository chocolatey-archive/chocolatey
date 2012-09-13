function Install-ChocolateyExplorerMenuItem {
param(
  [string]$menuKey, 
  [string]$menuLabel, 
  [string]$command, 
  [ValidateSet('file','directory')]
  [string]$type = "file"
)

  $script:install_ChocolateyExplorerMenuItem_was_called = $true
  $script:menuKey = $menuKey
  $script:menuLabel = $menuLabel
  $script:command = $command
  $script:type = $type

  if ($script:exec_install_ChocolateyExplorerMenuItem_actual) { Install-ChocolateyExplorerMenuItem-Actual @PSBoundParameters}
}