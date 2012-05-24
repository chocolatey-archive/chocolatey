function Chocolatey-WebPI {
param(
  [string] $packageName, 
  [string] $installerArguments
)
  $script:chocolatey_cygwin_was_called = $true
  $script:packageName = $packageName
  $script:installerArguments = $installerArguments
  
  if ($script:exec_chocolatey_cygwinc_actual) { Chocolatey-Cygwin-Actual @PSBoundParameters}
}