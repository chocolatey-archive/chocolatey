function Run-ChocolateyPS1 {
param(
  [string] $packageFolder, 
  [string] $packageName
)

  $script:run_chocolateyps1_was_called = $true
  $script:packageFolder = $packageFolder
  $script:packageName = $packageName
  
  if ($script:exec_run_chocolateyps1_actual) { Run-ChocolateyPS1-Actual @PSBoundParameters}
}