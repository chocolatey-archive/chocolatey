function Chocolatey-NuGet {
param(
  [string] $packageName,
  [string] $source,
  [string] $version,
  [string] $installerArguments
)

  $script:chocolatey_nuget_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  $script:installerArguments = $installerArguments  

  if ($script:exec_chocolatey_nuget_actual) {
    Chocolatey-NuGet-Actual @PSBoundParameters
  } else {
    return $script:chocolatey_nuget_return_value
  }
}
