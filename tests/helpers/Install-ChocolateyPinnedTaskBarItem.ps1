function Install-ChocolateyPinnedTaskBarItem {
param(
  [string] $targetFilePath
)

  $script:install_chocolateypinnedtaskbaritem_was_called = $true
  $script:targetFilePath = $targetFilePath
  
  if ($script:exec_install_ChocolateyPinnedTaskBarItem_actual) { Install-ChocolateyPinnedTaskBarItem-Actual @PSBoundParameters}
}