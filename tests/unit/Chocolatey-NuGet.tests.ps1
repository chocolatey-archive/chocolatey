$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

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

  Context "with packageName 'all'" {
    Mock Update-SessionEnvironment
    Mock Chocolatey-InstallAll {} -Verifiable -ParameterFilter {$source -eq 'source'}
    Chocolatey-NuGet 'all' 'source'

    It "should call Chocolatey-InstallAll" {
      Assert-VerifiableMocks
    }
  }
}
