$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "When calling Chocolatey-InstallIfMissing with no version and package exists" {
  Initialize-Variables
  $script:exec_chocolatey_installifmissing_actual = $true
  $script:exec_get_packagefoldersforpackage_actual = $false
  $script:get_packagefoldersforpackage_return_value = 'dude'
  Chocolatey-InstallIfMissing 'testpackage'

  It "should not call Chocolatey-Version" {
    $script:chocolatey_version_was_called.should.be($false)
  } 
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }    
}

Describe "When calling Chocolatey-InstallIfMissing with no version and package does not exists" {
  Initialize-Variables
  $script:exec_chocolatey_installifmissing_actual = $true
  $script:exec_get_packagefoldersforpackage_actual = $false
  $script:exec_chocolatey_nuget_actual = $false  
  $script:get_packagefoldersforpackage_return_value = ''
  Chocolatey-InstallIfMissing 'testpackage'

  It "should call Chocolatey-Version" {
    $script:chocolatey_version_was_called.should.be($true)
  } 
}

Describe "When calling Chocolatey-InstallIfMissing with a version and the package does not exists" {
  Initialize-Variables
  $script:exec_chocolatey_installifmissing_actual = $true
  $script:exec_chocolatey_version_actual = $false
  $script:exec_chocolatey_nuget_actual = $false  
  $versionsObj = @{found = "no version"}
  $script:chocolatey_version_return_value = $versionsObj
  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($true)
  } 

}

Describe "When calling Chocolatey-InstallIfMissing with a version and version different than the one in the repo" {
  Initialize-Variables
  $script:exec_chocolatey_installifmissing_actual = $true
  $script:exec_chocolatey_version_actual = $false
  $script:exec_chocolatey_nuget_actual = $false  
  $versionsObj = @{found = "0.3"}
  $script:chocolatey_version_return_value = $versionsObj
  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($true)
  } 

}

Describe "When calling Chocolatey-InstallIfMissing with a version that is the same as the one in the repo" {
  Initialize-Variables
  $script:exec_chocolatey_installifmissing_actual = $true
  $script:exec_chocolatey_version_actual = $false
  $script:exec_chocolatey_nuget_actual = $false  
  $versionsObj = @{found = 1.0}
  $script:chocolatey_version_return_value = $versionsObj
  Chocolatey-InstallIfMissing 'testpackage' -version 1.0

  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  } 

}