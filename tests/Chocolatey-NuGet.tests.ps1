$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path $here '_Common.ps1'
. $common

Describe "When calling Chocolatey-NuGet normally" {
  Mock Run-NuGet {""} -Verifiable -ParameterFilter {$packageName -eq 'somepackage'}
  
  Chocolatey-NuGet 'somepackage'
  
  It "should call Run-NuGet" {
    Assert-VerifiableMocks
  }  
}

Describe "when calling Chocolatey-NuGet with packageName 'all'" {
  Mock Chocolatey-InstallAll {} -Verifiable -ParameterFilter {$source -eq 'source'}

  Chocolatey-NuGet 'all' 'source'

  It "should call Chocolatey-InstallAll" {
    Assert-VerifiableMocks
  }
  
}