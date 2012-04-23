function Run-NuGet {
param(
  [string] $packageName, 
  [string] $source,
  [string] $version
)
  Setup -File 'chocolatey\chocolateyInstall\install.log' @"
  Successfully installed '$packageName 1.0'.
"@

  $script:run_nuget_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  
  if ($script:exec_run_nuget_actual) { Run-NuGet-Actual @PSBoundParameters}
}