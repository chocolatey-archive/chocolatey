function Chocolatey-Pack {
param(
  [string] $packageName
)

  $script:chocolatey_pack_was_called = $true
  $script:packageName = $packageName
  
  if ($script:exec_chocolatey_pack_actual) { Chocolatey-Pack-Actual @PSBoundParameters}
}