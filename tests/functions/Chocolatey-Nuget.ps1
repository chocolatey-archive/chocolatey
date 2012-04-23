function Chocolatey-NuGet {
param(
  [string] $packageName,
  [string] $source,
  [string] $version
)

  $script:chocolatey_nuget_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  
  if ($script:exec_chocolatey_nuget_actual) { Chocolatey-NuGet-Actual @PSBoundParameters}
}