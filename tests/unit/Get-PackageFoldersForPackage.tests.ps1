$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Get-PackageFoldersForPackage normally" {
  $packageName = 'sake'
  $packageVersion = '0.1.3'
  Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''
  $pathExists = Test-Path("TestDrive:\chocolatey\lib\$packageName.$packageVersion")
  $expectedValue = "$packageName.$packageVersion"
  
  $returnValue = Get-PackageFoldersForPackage $packageName

  It "should find that the folder path actually exists" {
    $pathExists.should.be($true)
  }
  
  It "should return a package folder back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-PackageFoldersForPackage against a folder version that has a date value" {
  $packageName = 'sake'
  $packageVersion = '0.1.3.20120225'
  Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''
  $returnValue = Get-PackageFoldersForPackage $packageName
  $expectedValue = "$packageName.$packageVersion"
  
  It "should not error" {}
  
  It "should return a package folder back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-PackageFoldersForPackage against a folder that has a prerelease version" {
  $packageName = 'sake'
  $packageVersion = '0.1.3-alpha1'
  Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''
  $returnValue = Get-PackageFoldersForPackage $packageName
  $expectedValue = "$packageName.$packageVersion"
  
  It "should not error" {}
  
  It "should return a package folder back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-PackageFoldersForPackage against a folder that has a prerelease version with multiple dashes" {
  $packageName = 'sake'
  $packageVersion = '0.1.3-alpha-1'
  Setup -File "chocolatey\lib\$packageName.$packageVersion\sake.nuspec" ''
  $returnValue = Get-PackageFoldersForPackage $packageName
  $expectedValue = "$packageName.$packageVersion"
  
  It "should not error" {}
  
  It "should return a package folder back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-PackageFoldersForPackage against multiple versions" {
  $packageName = 'sake'
  $packageVersion1 = '0.1.3'
  $packageVersion2 = '0.1.3.1'
  $packageVersion3 = '0.1.4'
  Setup -File "chocolatey\lib\$packageName.$packageVersion1\sake.nuspec" ''
  Setup -File "chocolatey\lib\$packageName.$packageVersion2\sake.nuspec" ''
  Setup -File "chocolatey\lib\$packageName.$packageVersion3\sake.nuspec" ''
  $returnValue = Get-PackageFoldersForPackage $packageName
  $expectedValue = "$packageName.$packageVersion1 $packageName.$packageVersion2 $packageName.$packageVersion3"
  
  It "should return multiple package folders back" {
    $returnValue.should.be($expectedValue)
  }  
}

Describe "When calling Get-PackageFoldersForPackage against multiple versions and other packages" {
  $packageName = 'sake'
  $packageVersion1 = '0.1.3'
  $packageVersion2 = '0.1.3.1'
  $packageVersion3 = '0.1.4'
  Setup -File "chocolatey\lib\$packageName.$packageVersion1\sake.nuspec" ''
  Setup -File "chocolatey\lib\$packageName.$packageVersion2\sake.nuspec" ''
  Setup -File "chocolatey\lib\sumo.$packageVersion3\sake.nuspec" ''
  $returnValue = Get-PackageFoldersForPackage $packageName
  $expectedValue = "$packageName.$packageVersion1 $packageName.$packageVersion2"
  
  It "should return multiple package folders back" {
    $returnValue.should.be($expectedValue)
  }    
  
  It "should not return the package that is not the same name" {
    foreach ($item in $returnValue) {
      $item.Name.Contains("sumo.$packageVersion3").should.be($false)
    }
  }  
}
