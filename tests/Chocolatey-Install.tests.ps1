$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path $here '_Common.ps1'
. $common

function Chocolatey-PackagesConfig {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $packagesConfigPath
  )
  
  write-host 'test'
  $script:chocolatey_packages_was_called = $true
}

Describe "When installing a package" {
  Initialize-Variables
  $script:run_chocolatey_nuget_actual = $true
  Chocolatey-NuGet 'somepackage'
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }

  It "should not call the Chocolatey-PackagesConfig function" {
    $script:chocolatey_packages_was_called.should.be($false)
  }

  It "should call Start-Process function to run NuGet.exe" {
    $script:start_process_was_called.should.be($true)
  }
  
}

Describe "When installing a package that is already installed without using the force command" {
  Initialize-Variables
  Chocolatey-Install 'testpackage'
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }

  It "should not call the Chocolatey-PackagesConfig function" {
    $script:chocolatey_packages_was_called.should.be($false)
  }

#todo: finish this up
}

Describe "When installing a package with .config in the name but not ending in .config" {
  Initialize-Variables
  Chocolatey-Install 'win.config.something'
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should not call the Chocolatey-PackagesConfig function" {
    $script:chocolatey_packages_was_called.should.be($false)
  }
  
}

Describe "When installing packages from a manifest named packages.config" {
  Initialize-Variables

  Chocolatey-Install "TestDrive:\packages.config"

  It "should call the Chocolatey-PackagesConfig function" {
    $script:chocolatey_packages_was_called.should.be($true)
  }
}

Describe "When installing packages from a manifest named MyChocolateyPackages.config" {
  Initialize-Variables

  Chocolatey-Install "TestDrive:\MyChocolateyPackages.config"

  It "should call the Chocolatey-PackagesConfig function" {
    $script:chocolatey_packages_was_called.should.be($true)
  }

}
