function Chocolatey-Install {
param(
  [string] $packageName, 
  [string] $source, 
  [string] $version,
  [string] $installerArguments
)
  
  $script:chocolatey_install_was_called = $true
  $script:packageName = $packageName
  $script:source = $source
  $script:version = $version
  $script:installerArguments = $installerArguments
  
  if ($script:exec_chocolatey_install_actual) { 
    Chocolatey-Install-Actual @PSBoundParameters
  } else {
    return $script:chocolatey_install_return_value
  }
}