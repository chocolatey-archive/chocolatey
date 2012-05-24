function Chocolatey-Install {
param(
  [string] $packageName, 
  [string] $source = 'https://go.microsoft.com/fwlink/?LinkID=230477', 
  [string] $version = '',
  [string] $installerArguments = ''
)
  
  if($($packageName).EndsWith('.config')) {
    Chocolatey-PackagesConfig $packageName
    return
  }
  
  switch -wildcard ($source) 
  {
    "webpi" { Chocolatey-WebPI $packageName $installerArguments; }
	"cygwin" { Chocolatey-Cygwin $packageName $installerArguments; }
    "ruby" { Chocolatey-RubyGem $packageName $version $installerArguments; }
    default { Chocolatey-NuGet $packageName $source $version; }
  }
}