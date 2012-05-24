Setup -File 'chocolatey\chocolateyInstall\_crapworkaround.txt'
Setup -File 'chocolatey\lib\_crapworkaround.txt'
Setup -File 'chocolatey\bin\_crapworkaround.txt'
Setup -File 'chocolatey\chocolateyInstall\chocolateyInstall.log'
Setup -File 'chocolatey\chocolateyInstall\chocolateyWebPiInstall.log'
Setup -File 'chocolatey\chocolateyInstall\chocolateyCygwinInstall.log'
Setup -File 'chocolatey\chocolateyInstall\error.log'
Setup -File 'chocolatey\chocolateyInstall\install.log'
Setup -File 'chocolatey\chocolateyInstall\list.log'
Setup -File 'chocolatey\chocolateyInstall\pack.log'
Setup -File 'chocolatey\chocolateyInstall\push.log'

$nugetChocolateyPath = "TestDrive:\chocolatey\chocolateyInstall"
$nugetPath = (Split-Path -Parent $nugetChocolateyPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$nugetLibPath = Join-Path $nuGetPath 'lib'
$chocInstallVariableName = "ChocolateyInstall"
$nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'