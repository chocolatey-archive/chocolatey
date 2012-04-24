$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path $here '_Common.ps1'
. $common

Describe "When calling Chocolatey-NuGet normally" {
  Initialize-Variables
  $script:exec_chocolatey_nuget_actual = $true
  Chocolatey-NuGet 'somepackage'
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should call Run-NuGet" {
    $script:run_nuget_was_called.should.be($true)
  }
  It "should call Start-Process function to run NuGet.exe" {
    #$script:start_process_was_called.should.be($true)
  }
  
}

Describe "when calling Chocolatey-NuGet with packageName 'all'" {
  Initialize-Variables
  $script:exec_chocolatey_nuget_actual = $true
  Chocolatey-NuGet 'all'

  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should call Chocolatey-InstallAll" {
    $script:chocolatey_installall_was_called.should.be($true)
  }
  
  It "should set packageName appropriately" {
    $script:packageName.should.be('all')
  }
  
}