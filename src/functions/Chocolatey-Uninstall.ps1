function Chocolatey-Uninstall { 
param(
  [string] $packageName,
  [string] $version = '',
  [string] $installerArguments = ''
)
  Write-Debug "Running 'Chocolatey-Uninstall' for $packageName with version:`'$version`', installerArguments: `'$installerArguments`'";

  if ($packageName -eq 'all') { 
    write-host "Uninstalling all packages is not yet supported in this version. "  
	# by default this should prompt user 2x.  Also can provide a -nuke switch for prompt bypass
    return
  }

@"
$h1
Chocolatey ($chocVer) is uninstalling $packageName from "$nugetLibPath". 
$h1
"@ | Write-Host
	
	$packages = $packageName
	foreach ($package in $packages) {
		$versions = Chocolatey-Version $package $source
		if ($versions.found -eq "no version") {
		  write-host "not installed"
		}
		else {
		  Write-Debug "Looking for $($package).$($versions.found)"
          $packageFolder = Join-Path $nugetLibPath "$($package).$($versions.found)" 
          Run-ChocolateyPS1 $packageFolder $package "uninstall"
		  Remove-Item -Recurse -Force $packageFolder
		}
	}
}
