function Chocolatey-Install {
param(
  [string] $packageName, 
  [string] $source = '', 
  [string] $version = '',
  [string] $installerArguments = ''
)
  Write-Debug "Running 'Chocolatey-Install' for $packageName with source: `'$source`', version: `'$version`', installerArguments:`'$installerArguments`'";

  if($($packageName).EndsWith('.config')) {
    Write-Debug "Chocolatey-Install has determined that package $packageName ends with `'.config`' - calling Chocolatey-PackagesConfig"
    Chocolatey-PackagesConfig $packageName
    return
  }
  
  switch -wildcard ($source) 
  {
    "webpi" { Chocolatey-WebPI $packageName $installerArguments; }
    "cygwin" { Chocolatey-Cygwin $packageName $installerArguments; }
    "python" { Chocolatey-Python $packageName $version $installerArguments; }
    "ruby" { Chocolatey-RubyGem $packageName $version $installerArguments; }
    default { Chocolatey-NuGet $packageName $source $version; }
  }
}