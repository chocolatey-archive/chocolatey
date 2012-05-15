$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Get-LongPackageVersion normally" {
  Initialize-Variables
  $script:exec_get_longpackageversion_actual = $true
  $shortVersion = '0.1.3'
  $packageVersions = @($shortVersion)
  $returnValue = Get-LongPackageVersion $packageVersions
  $expectedValue = '00000000.00000001.00000003'
  
  It "should call Get-LongPackageVersion-Actual" {
    $script:get_longpackageversion_actual_was_called.should.be($true)
  }  
  
  It "should return a long version string with 8 fields of padding back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-LongPackageVersion with a version that has a date value" {
  Initialize-Variables
  $script:exec_get_longpackageversion_actual = $true
  $shortVersion = '2.0.1.20120225'
  $packageVersions = @($shortVersion)
  $returnValue = Get-LongPackageVersion $packageVersions
  $expectedValue = '00000002.00000000.00000001.20120225'
  
  It "should not error" {}
  
  It "should return a long version string that includes all of the date string" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-LongPackageVersion with prerelease package version" {
  Initialize-Variables
  $script:exec_get_longpackageversion_actual = $true
  $shortVersion = '2.0.1.3-alpha1'
  $packageVersions = @($shortVersion)
  $returnValue = Get-LongPackageVersion $packageVersions
  $expectedValue = '00000002.00000000.00000001.00000003.alpha1'
  
  It "should not error" {}
  
  It "should return a long version string that includes the prerelease information as the last element" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-LongPackageVersion with prerelease package version that contains multiple dashes" {
  Initialize-Variables
  $script:exec_get_longpackageversion_actual = $true
  $shortVersion = '2.0.1.3-alpha-1'
  $packageVersions = @($shortVersion)
  $returnValue = Get-LongPackageVersion $packageVersions
  $expectedValue = '00000002.00000000.00000001.00000003.alpha-1'
  
  It "should not error" {}
  
  It "should return a long version string that includes the prerelease information as the last element" {
    $returnValue.should.be($expectedValue)
  }  
}