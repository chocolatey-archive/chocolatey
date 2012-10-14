function Run-ChocolateyPS1 {
param(
  [string] $packageFolder, 
  [string] $packageName,
  [string] $action,
  [string] $installerArguments
)

  $script:run_chocolateyps1_was_called = $true
  $script:packageFolder = $packageFolder
  $script:packageName = $packageName
  $script:action = $action
  $script:installerArguments = $installerArguments
  
  if ($script:exec_run_chocolateyps1_actual) { Run-ChocolateyPS1-Actual @PSBoundParameters}
}