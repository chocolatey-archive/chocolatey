$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

function ChocolateyInstall {
    $global:installArgsInEnvironment=$env:chocolateyInstallArguments
}

Describe "When calling Run-Chocolatey.ps1 with Installer Arguments" {
  $cmd=(Get-Command ChocolateyInstall)
  Mock Get-ChildItem {return @{Name="chocolateyinstall.ps1";FullName=$cmd}} -ParameterFilter {$path -eq "$env:temp\test"}

  Run-ChocolateyPS1 "$env:temp\test" 'testPackage' 'install' 'real args'

  It "should set chocolateyInstallArguments env var to Installer Arguments" {
    $global:installArgsInEnvironment.should.be('real args')
  }
}
    