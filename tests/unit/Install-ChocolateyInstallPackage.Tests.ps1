$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)

. $common
. "$base\src\helpers\functions\Install-ChocolateyInstallPackage.ps1"

Describe "Install-ChocolateyInstallPackage" {
    Context "When file type is msu" { 
    Mock Start-ChocolateyProcessAsAdmin

    Install-ChocolateyInstallPackage "package" "msu"
    It "should be installed" {
        Assert-MockCalled Start-ChocolateyProcessAsAdmin
    }
  }

}