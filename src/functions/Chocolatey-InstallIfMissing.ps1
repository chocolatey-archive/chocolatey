function Chocolatey-InstallIfMissing {
param(
  [string] $packageName, 
  [string] $source = 'https://go.microsoft.com/fwlink/?LinkID=230477',
  [string] $version = ''
)
  
  $versions = Chocolatey-Version $packageName $source
  
  if ($versions.'found' -contains 'no version' -or ($version -ne '' -and $versions.'found' -ne $version)) {
    Chocolatey-NuGet $packageName $source $version
  }
}