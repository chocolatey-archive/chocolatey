function Chocolatey-RubyGem {
param(
  [string] $packageName, 
  [string] $version, 
  [string] $installerArguments
)

  $script:chocolatey_rubygem_was_called = $true
  $script:packageName = $packageName
  $script:version = $version
  $script:installerArguments = $installerArguments
  
  if ($script:exec_chocolatey_rubygem_actual) { Chocolatey-RubyGem-Actual @PSBoundParameters}
  
}
