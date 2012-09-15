function Chocolatey-Version {
param(
  [string] $packageName,
  [string] $source
)
  $script:chocolatey_version_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  
  if ($script:exec_chocolatey_version_actual) { 
    Chocolatey-Version-Actual @PSBoundParameters
  }
  else {
    return $script:chocolatey_version_return_value
  }
}