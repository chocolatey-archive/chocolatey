function Chocolatey-WebPI {
param(
  [string] $packageName, 
  [string] $installerArguments
)
  $script:chocolatey_webpi_was_called = $true
  $script:packageName = $packageName
  $script:installerArguments = $installerArguments
  
  if ($script:exec_chocolatey_webpi_actual) { Chocolatey-WebPI-Actual @PSBoundParameters}
}