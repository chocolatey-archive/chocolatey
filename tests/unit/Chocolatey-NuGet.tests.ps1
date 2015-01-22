$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common
$chocolateyErrored = $false

Describe "Chocolatey-NuGet" {
  Context "under normal circumstances" {
    Mock Update-SessionEnvironment
    Mock Run-NuGet {""} -Verifiable -ParameterFilter {$packageName -eq 'somepackage'}
    Chocolatey-NuGet 'somepackage'

    It "should call Run-NuGet" {
      Assert-VerifiableMocks
    }

    It "should call Update-SessionEnvironment" {
      Assert-MockCalled Update-SessionEnvironment
    }
  }

  Context "chocolateyPS1 throws an error" {
    $nugetLibPath = "c:\fake-lib"
    Mock Update-SessionEnvironment
    Mock Run-NuGet {"Successfully installed 'somepackage 1.0.0'"} -Verifiable -ParameterFilter {$packageName -eq 'somepackage'}
    Mock Run-ChocolateyPS1 { throw "big bad error" }
    Mock Test-Path { $true } -ParameterFilter {$path -eq 'c:\fake-lib\somepackage.1.0.0'}
    Mock Move-BadInstall
    Mock Write-Error

    Chocolatey-NuGet 'somepackage'

    It "should set chocolateyErrored to true" {
      $chocolateyErrored | should be $true
    }
  }

  Context "with packageName 'all'" {
    Mock Update-SessionEnvironment
    Mock Chocolatey-InstallAll {} -Verifiable -ParameterFilter {$source -eq 'source'}
    Chocolatey-NuGet 'all' 'source'

    It "should call Chocolatey-InstallAll" {
      Assert-VerifiableMocks
    }
  }
}
