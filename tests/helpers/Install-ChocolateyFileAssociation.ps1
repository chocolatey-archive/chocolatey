function Install-ChocolateyFileAssociation {
param(
  [string] $extension,
  [string] $executable
)

  $script:install_ChocolateyFileAssociation_was_called = $true
  $script:extension = $extension
  $script:executable = $executable  
  
  if ($script:exec_install_ChocolateyFileAssociation_actual) { Install-ChocolateyFileAssociation-Actual @PSBoundParameters}
}