function Write-ChocolateySuccess {
param(
  [string] $packageName
)

  $script:write_chocolateysuccess_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_write_chocolateysuccess_actual) { Write-ChocolateySuccess-Actual @PSBoundParameters}
}