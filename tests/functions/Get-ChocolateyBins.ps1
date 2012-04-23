function Get-ChocolateyBins {
param(
  [string] $packageFolder
)
  
  $script:get_chocolateybins_was_called = $true
  $script:packageFolder = $packageFolder
  
  if ($script:exec_get_chocolateybins_actual) { Get-ChocolateyBins-Actual @PSBoundParameters}
}