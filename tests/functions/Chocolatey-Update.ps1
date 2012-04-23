function Chocolatey-Update {
param(
  [string] $packageName, 
  [string] $source
)

  $script:chocolatey_update_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  
  if ($script:exec_chocolatey_update_actual) { Chocolatey-Update-Actual @PSBoundParameters}
}
