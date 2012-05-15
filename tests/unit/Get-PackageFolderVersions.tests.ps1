$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Get-PackageFolderVersion normally" {
  Initialize-Variables
  $script:exec_get_packagefolderversions_actual = $true
  $packageName = 'sake'
  $script:get_packagefoldersforpackage_return_value = @("$packageName.0.1.3","$packageName.0.1.3.1","$packageName.0.1.4")
  
  $longVersion1 = '00000000.00000001.00000003'
  $longVersion2 = '00000000.00000001.00000003.00000001'
  $longVersion3 = '00000000.00000001.00000004'
  $script:get_versionsforcomparison_return_value =  @{$longVersion1='0.1.3';$longVersion2='0.1.3.1';$longVersion3='0.1.4'}
  $returnValue = Get-PackageFolderVersions $packageName
  $expectedValue = $script:get_versionsforcomparison_return_value
  
  It "should call Get-PackageFolderVersions-Actual" {
    $script:get_packagefolderversions_actual_was_called.should.be($true)
  } 
  
  It "should call Get-PackageFoldersForPackage" {
    $script:get_packagefoldersforpackage_was_called.should.be($true)
  }  
  
  It "should call Get-VersionsForComparison" {
    $script:get_versionsforcomparison_was_called.should.be($true)
  }
  
  It "should return the output of Get-VersionsForComparison" {
    $returnValue.should.be($expectedValue)
  }  
}
