function Chocolatey-InstallIfMissing {
param(
  [string] $packageName,
  [string] $source = '',
  [string] $version = ''
)

  Write-Debug "Running 'Chocolatey-InstallIfMissing' for $packageName with source:`'$source`', version: `'$version`'";
  Write-Warning "installmissing command is deprecated and will be removed. Install provides the same functionality now."

  if($version -eq '')  {
    $packageFolder = (Get-PackageFoldersForPackage $packageName)
    if($packageFolder){return}
  }

  $versions = Chocolatey-Version $packageName $source

  if ($versions.'found' -contains 'no version' -or ($version -ne '' -and $versions.'found' -ne $version)) {
    Chocolatey-Nuget $packageName $source $version
  }
}
