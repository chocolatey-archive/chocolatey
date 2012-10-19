$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Chocolatey-InstallIfMissing with no version and package exists" {
  Mock Chocolatey-Version {}
  Mock Chocolatey-Nuget {}
  Mock Get-PackageFoldersForPackage { return 'dude' }

  Chocolatey-InstallIfMissing 'testpackage'

  It "should not call Chocolatey-Version" {
    Assert-MockCalled Chocolatey-Version 0
  } 
  It "should not call Chocolatey-Nuget" {
    Assert-MockCalled Chocolatey-Nuget 0
  }    
}

Describe "When calling Chocolatey-InstallIfMissing with no version and package does not exists" {
  Mock Chocolatey-Version {}
  Mock Chocolatey-Nuget {}
  Mock Get-PackageFoldersForPackage {}

  Chocolatey-InstallIfMissing 'testpackage'

  It "should call Chocolatey-Version" {
    Assert-MockCalled Chocolatey-Version 1 {$packageName -eq 'testpackage'}
  } 
}

Describe "When calling Chocolatey-InstallIfMissing with a version and the package does not exists" {
  Mock Chocolatey-Version { return @{found = "no version"} }
  Mock Chocolatey-Nuget {}

  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should call Chocolatey-Nuget" {
    Assert-MockCalled Chocolatey-Nuget 1 {$packageName -eq 'testpackage' -and $version -eq '1.0' }
  } 

}

Describe "When calling Chocolatey-InstallIfMissing with a version and version different than the one in the repo" {
  Mock Chocolatey-Version { return @{found = "0.3"} }
  Mock Chocolatey-Nuget {}

  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should call Chocolatey-Nuget" {
    Assert-MockCalled Chocolatey-Nuget 1 {$packageName -eq 'testpackage' -and $version -eq '1.0' }
  } 

}

Describe "When calling Chocolatey-InstallIfMissing with a version that is the same as the one in the repo" {
  Mock Chocolatey-Version { return @{found = "1.0"} }
  Mock Chocolatey-Nuget {}

  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should not call Chocolatey-Nuget" {
    Assert-MockCalled Chocolatey-Nuget 0
  } 

}