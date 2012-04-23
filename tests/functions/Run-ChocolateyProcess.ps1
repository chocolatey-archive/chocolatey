function Run-ChocolateyProcess {
param(
  [string] $file, 
  [string] $arguments, 
  [switch] $elevated
)

  $script:run_chocolateyprocess_was_called = $true
  $script:file = $file
  $script:arguments = $arguments
  $script:elevated = $elevated
  
  if ($script:exec_run_chocolateyprocess_actual) { Run-ChocolateyProcess-Actual @PSBoundParameters}
}