$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'
$functionRenames = Join-Path $here '_FunctionRenameActuals.ps1'
$setup = Join-Path $here '_Setup.ps1'
$initializeVariables = Join-Path $here '_Initialize-Variables.ps1'
$installModule = Join-Path (Join-Path $src 'helpers') 'chocolateyInstaller.psm1'

Import-Module $installModule -Function Start-ChocolateyProcessAsAdmin, Install-ChocolateyPackage, Install-ChocolateyZipPackage, Install-ChocolateyPowershellCommand, Get-ChocolateyWebFile, Install-ChocolateyInstallPackage, Get-ChocolateyUnzip, Write-ChocolateySuccess, Write-ChocolateyFailure, Install-ChocolateyPath, Install-ChocolateyDesktopLink

Import-Module $script 
Import-Module $functionRenames

# grab functions from files
Resolve-Path $here\functions\*.ps1 | % { . $_.ProviderPath }
Resolve-Path $here\helpers\*.ps1 | % { . $_.ProviderPath }

Import-Module $setup
Import-Module $initializeVariables