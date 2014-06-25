$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "Chocolatey-Update" {
  Context "When updating a folder that has a prerelease version" {
    Mock Chocolatey-Version {return @{}} -Verifiable -ParameterFilter {$packageName -eq 'sake'}
    Mock Chocolatey-NuGet {}

    $packageName = 'sake'
    $packageVersion = '0.1.3-alpha1'
    Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''


    # It "should call Chocolatey-Version with the proper package name" {
    #   Assert-VerifiableMocks
    # }

    $returnValue = Chocolatey-Update $packageName
    $expectedValue = "$packageName.$packageVersion"

    It "should not error" {}

    # It "should return a package folder back" {
    #   $returnValue  | should Be $expectedValue
    # }
  }

  Context "when updating a folder that has a prerelease version with multiple dashes" {
    Mock Chocolatey-Version {return @{}} -Verifiable -ParameterFilter {$packageName -eq 'sake'}
    Mock Chocolatey-NuGet {}

    $packageName = 'sake'
    $packageVersion = '0.1.3-alpha-1'
    Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''
    $returnValue = Chocolatey-Update $packageName
    $expectedValue = "$packageName.$packageVersion"

    It "should not error" {}

    # It "should return a package folder back" {
    #   $returnValue  | should Be $expectedValue
    # }
  }
}
