$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "Chocolatey-Uninstall" {
  Context "When no PackageName parameter is passed to this function" {
    Mock Write-ChocolateyFailure
    
    Chocolatey-Uninstall
  
    It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "Missing PackageName input parameter."}
    }
  }
}