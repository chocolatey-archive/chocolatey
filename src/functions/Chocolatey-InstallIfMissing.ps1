function Chocolatey-InstallIfMissing {
param(
  [string] $packageName, 
  [string] $source = '',
  [string] $version = ''
)
  
  Write-Debug "Running 'Chocolatey-InstallIfMissing' for $packageName with source:`'$source`', version: `'$version`'";

  if($version -eq '')  {
    $packageFolder = (Get-PackageFoldersForPackage $packageName)
    if($packageFolder){return}
  }

  $versions = Chocolatey-Version $packageName $source

  if ($versions.'found' -contains 'no version' -or ($version -ne '' -and $versions.'found' -ne $version)) {
    Invoke-ChocolateyFunction "Chocolatey-Nuget" @($packageName,$source,$version) 
  }
}