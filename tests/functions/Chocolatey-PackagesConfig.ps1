function Chocolatey-PackagesConfig {
param(
  [string] $packagesConfigPath
)

  $script:chocolatey_packagesconfig_was_called = $true
  $script:packagesConfigPath = $packagesConfigPath
 
  if ($script:exec_chocolatey_packagesconfig_actual) { Chocolatey-PackagesConfig-Actual @PSBoundParameters}
}
