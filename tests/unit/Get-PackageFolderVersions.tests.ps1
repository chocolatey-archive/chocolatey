$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Get-PackageFolderVersion normally" {
  $longVersion1 = '00000000.00000001.00000003'
  $longVersion2 = '00000000.00000001.00000003.00000001'
  $longVersion3 = '00000000.00000001.00000004'
  $returnedVersions =  @{$longVersion1='0.1.3';$longVersion2='0.1.3.1';$longVersion3='0.1.4'}
  $packageName = 'sake'
  Mock Get-PackageFoldersForPackage { return @(@{Name="$packageName.0.1.3"},@{Name="$packageName.0.1.3.1"},@{Name="$packageName.0.1.4"})} -ParameterFilter {$packageName -eq 'sake'}
  Mock Get-VersionsForComparison { return $returnedVersions } -ParameterFilter { $packageVersions.Length -eq 3 -and ($packageVersions | ? {@("0.1.3","0.1.3.1","0.1.4") -contains $_ }).Length -eq 3 }
  
  $returnValue = Get-PackageFolderVersions $packageName

  It "should return the output of Get-VersionsForComparison" {
    $returnValue.should.be($returnedVersions)
  }  
}
