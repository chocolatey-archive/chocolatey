$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Get-VersionsForComparison normally" {
  Initialize-Variables
  $script:exec_get_versionsforcomparison_actual = $true
  $longVersion = '00000000.00000001.00000003'
  $shortVersion = '0.1.3'
  $script:get_longpackageversion_return_value = $longVersion
  $packageVersions = @($shortVersion)
  $returnValue = Get-VersionsForComparison $packageVersions
  $expectedValue = @{$longVersion=$shortVersion}
  
  It "should call Get-LongPackageVersion" {
    $script:get_longpackageversion_was_called.should.be($true)
  }  
  
  It "should call Get-VersionsForComparison-Actual" {
    $script:get_versionsforcomparison_actual_was_called.should.be($true)
  }
  
  It "should have one item returned" {
    $returnValue.Count.should.be(1)
  }
  
  It "should return both versions back as the first element in a hash" {
    $returnValue."$longVersion".should.be($expectedValue."$longVersion")
  }  
  
  It "should return the short version back as the value of the first element in the hash" {
    $returnValue."$longVersion".should.be($shortVersion)
  }
}

Describe "When calling Get-VersionsForComparison to add multiple of the same item" {
  Initialize-Variables
  $script:exec_get_versionsforcomparison_actual = $true
  $longVersion = '00000000.00000001.00000003'
  $shortVersion = '0.1.3'
  $script:get_longpackageversion_return_value = $longVersion
  $packageVersions = @($shortVersion,$shortVersion)
  $returnValue = Get-VersionsForComparison $packageVersions
  $expectedValue = @{$longVersion=$shortVersion}
  
  It "should work appropriately" {}
  
  It "should only have one item returned" {
    $returnValue.Count.should.be(1)
  }
}

Describe "When calling Get-VersionsForComparison with a prerelease package" {
  Initialize-Variables
  $script:exec_get_versionsforcomparison_actual = $true
  $longVersion = '00000000.00000001.00000003.alpha1'
  $shortVersion = '0.1.3-alpha1'
  $script:get_longpackageversion_return_value = $longVersion
  $packageVersions = @($shortVersion)
  $returnValue = Get-VersionsForComparison $packageVersions
  $expectedValue = @{$longVersion=$shortVersion}
  
  It "should work appropriately" {}

  It "should return versions in the first element" {
    $returnValue."$longVersion".should.be($expectedValue."$longVersion")
  }
  
}

Describe "When calling Get-VersionsForComparison with multiple prerelease packages of the same underlying version" {
  Initialize-Variables
  $script:exec_get_versionsforcomparison_actual = $true
  $script:exec_get_longpackageversion_actual = $true
  
  $shortVersion1 = '0.1.3-alpha1'
  $longVersion1 = '00000000.00000001.00000003.alpha1'
  $shortVersion2 = '0.1.3-alpha2'
  $longVersion2 = '00000000.00000001.00000003.alpha2'
  
  $packageVersions = @($shortVersion1,$shortVersion2)
  $returnValue = Get-VersionsForComparison $packageVersions
  $expectedValue = @{$longVersion1=$shortVersion1;$longVersion2=$shortVersion2}
  
  It "should work appropriately" {}
  
  It "should return the long version of the first short version" {
    $returnValue."$longVersion1".should.be($expectedValue."$longVersion1")
  }
  
  It "should return the long version of the second short version" {
    $returnValue."$longVersion2".should.be($expectedValue."$longVersion2")
  }
  
}