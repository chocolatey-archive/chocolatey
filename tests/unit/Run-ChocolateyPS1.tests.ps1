$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Run-Chocolatey.ps1 with Installer Arguments" {
  Initialize-Variables
  $script:exec_run_chocolateyps1_actual = $true
  $global:installArgsInEnvironment = 'fake args'
  mkdir $env:temp\test | Out-Null
  new-item $env:temp\test\ChocolateyInstall.ps1 -ItemType file -value "`$global:installArgsInEnvironment=`$env:chocolateyInstallArguments" | Out-Null
  Run-ChocolateyPS1 $env:temp\test 'testPackage' 'install' 'real args'
  Remove-Item $env:temp\test -Recurse -Force

  It "should set chocolateyInstallArguments env var to Installer Arguments" {
    $global:installArgsInEnvironment.should.be('real args')
  }
}
