function Write-ChocolateyFailure {
param(
  [string] $packageName,
  [string] $failureMessage
)

  $script:write_chocolateyfailure_was_called = $true
  $script:packageName = $packageName
  $script:failureMessage = $failureMessage
  
  if ($script:exec_write_chocolateyfailure_actual) { Write-ChocolateyFailure-Actual @PSBoundParameters}
}