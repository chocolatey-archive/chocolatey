function Install-ChocolateyDesktopLink {
param(
  [string] $targetFilePath
)

  $script:install_chocolateydesktoplink_was_called = $true
  $script:targetFilePath = $targetFilePath
  
  if ($script:exec_install_chocolateydesktoplink_actual) { Install-ChocolateyDesktopLink-Actual @PSBoundParameters}
}