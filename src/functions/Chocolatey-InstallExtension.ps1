function Chocolatey-InstallExtension {
param(
  [string] $packageName,
  [string] $packageFolder
)

  $packageExtensionPath = Join-Path $extensionsPath $packageName
  $packageExtensionsFromPath = Join-Path $packageFolder 'extensions'

  if(Test-Path($packageExtensionPath)) {
    Write-Debug "We are removing the contents of `'$packageExtensionPath`'"
    Remove-Item $packageExtensionPath  -recurse -force -EA SilentlyContinue
  }

  if(!(Test-Path($packageExtensionPath))) { md $packageExtensionPath | out-null} 

  if (!(Test-Path($packageExtensionsFromPath))) {
    Write-Host "The package `'$packageName`' seems to be missing the extensions folder at `'$packageExtensionsFromPath`'."
  } else {
    Write-Host "Installing extension `'$packageName`'. You will be able to use it next time you run chocolatey."
    Copy-Item $packageExtensionsFromPath $packageExtensionPath -recurse -force
  }
}