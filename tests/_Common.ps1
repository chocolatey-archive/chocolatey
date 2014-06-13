$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'
$setup = Join-Path $here '_Setup.ps1'

. (Join-Path $here '_TestHelpers.ps1')

Get-Module ChocolateyInstaller -All | Remove-Module
Get-Module chocolatey | Remove-Module
Import-Module $script 

Get-Module _Setup | Remove-Module
Import-Module $setup
