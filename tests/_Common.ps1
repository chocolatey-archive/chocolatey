$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'
$installModule = Join-Path (Join-Path $src 'helpers') 'chocolateyInstaller.psm1'

#Set-Alias Actual-Chocolatey-NuGet Chocolatey-NuGet  -Scope Script -Option AllScope
#Set-Alias Actual-Chocolatey-PackagesConfig Chocolatey-PackagesConfig  -Scope Global #-Option AllScope


Import-Module $installModule -Function Start-ChocolateyProcessAsAdmin, Install-ChocolateyPackage, Install-ChocolateyZipPackage, Install-ChocolateyPowershellCommand, Get-ChocolateyWebFile, Install-ChocolateyInstallPackage, Get-ChocolateyUnzip, Write-ChocolateySuccess, Write-ChocolateyFailure, Install-ChocolateyPath, Install-ChocolateyDesktopLink

Import-Module $script

function Initialize-Variables {
  $script:chocolatey_nuget_was_called = $false  
  $script:chocolatey_rubygem_was_called = $false
  $script:chocolatey_webpi_was_called = $false
  $script:chocolatey_packages_was_called = $false
  $script:packageName = ''
  $script:version = ''
}

function Chocolatey-NuGet {
  param(
    $packageName = '',
    $source = 'https://go.microsoft.com/fwlink/?LinkID=206669',
    $version = ''
  )

  $script:chocolatey_nuget_was_called = $true
  $script:packageName = $packageName
  $script:version = $version
}

# function Chocolatey-PackagesConfig {
  # param(
    # [Parameter(Mandatory = $true)]
    # [ValidateNotNullOrEmpty()]
    # [string] $packagesConfigPath
  # )
  
  # write-host 'test'
  # $script:chocolatey_packages_was_called = $true
  
  # Write-host "testd $(Get-Command -Module $script)"
  # #$oc = Get-Command 'Chocolatey-PackagesConfig' -Module $script
  # #$oc = Get-Command -Name 'Chocolatey-PackagesConfig' -Scope 1
  # #& $oc @PSBoundParameters
# }

function Chocolatey-WebPI {
  $script:chocolatey_webpi_was_called = $true
}

function Chocolatey-RubyGem {
  $script:chocolatey_rubygem_was_called = $true
}