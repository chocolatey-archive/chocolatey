$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'
$setup = Join-Path $here '_Setup.ps1'

if(Get-Module chocolatey){Remove-Module chocolatey}
Import-Module $script 

if(Get-Module _Setup){Remove-Module _Setup}
Import-Module $setup
