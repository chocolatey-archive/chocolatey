function Chocolatey-InstallIfMissing {
param(
  [string] $packageName, 
  [string] $source,
  [string] $version
)
 
  $script:chocolatey_installifmissing_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  
  if ($script:exec_chocolatey_installifmissing_actual) { Chocolatey-InstallIfMissing-Actual @PSBoundParameters}
}