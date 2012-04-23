function Install-ChocolateyPath {
param(
  [string] $pathToInstall,
  [System.EnvironmentVariableTarget] $pathType
)

  $script:install_chocolateypath_was_called = $true
  $script:pathToInstall = $pathToInstall
  $script:pathType = $pathType
  
  if ($script:exec_install_chocolateypath_actual) { Install-ChocolateyPath-Actual @PSBoundParameters}
}