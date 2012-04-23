function Chocolatey-InstallAll {
param(
  [string] $source
)
  
  $script:chocolatey_installall_was_called = $true
  $script:source = $source
  
  if ($script:exec_chocolatey_installall_actual) { Chocolatey-InstallAll-Actual @PSBoundParameters}
}