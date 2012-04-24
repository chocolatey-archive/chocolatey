$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here) '_Common.ps1'
. $common

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that exists" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
 
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($true)
  }
 
  It "should set package name appropriately" {
    $script:packageName.should.be('chocolateytestpackage')
  }  
  
  It "should set package version appropriately" {
    $script:version.should.be('0.1')
  }
  
    It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that does not exist" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"

  It "should do nothing" {}  
  
  It "should not call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($false)
  }
  
  It "should not set package name" {
    $script:packageName.should.be('')
  }  
  
  It "should not set package version" {
    $script:version.should.be('')
  }
  
    It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

}

Describe "When calling Chocolatey-PackagesConfig with a .config manifest that is named MyChocolateyPackages.config" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'MyChocolateyPackages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\MyChocolateyPackages.config"
  
  It "should treat it like a packages.config" {}
    
  It "should call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($true)
  }
  
  It "should set package name appropriately" {
    $script:packageName.should.be('chocolateytestpackage')
  }  
  
  It "should set package version appropriately" {
    $script:version.should.be('0.1')
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-PackagesConfig with a package name ending with .config without a '\' in the name" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Chocolatey-PackagesConfig 'win.config'
  
  It "should treat it like a regular package" {}
  
  It "should not call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($false)
  }
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should set package name appropriately" {
    $script:packageName.should.be('win.config')
  }
  
  It "should not set package version since it was not specified" {
    $script:version.should.be('')
  }
  
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest missing package id" {
  Initialize-Variables
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package version="0.1" />
</packages>  
"@

  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should only call Chocolatey-Install on packages that have specified an Id" {}
  
  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

    It "should not call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($false)
  }
  
  It "should not set version since Chocolatey-Install is not called" {
    $script:version.should.be('')
  }
  
  It "should not set packageName since it doesn't have one" {
    $script:packageName.should.be('')
  }
 
  #
  # depends on the malformation, really
  #  1. element (like `<pakage ... />`)
  #     The xml object for loop will skip it.
  #  2. attribute (like `<package ... verion="0.1" />`)
  #     A null/empty value will be passed on.
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest with badly formed xml" {
  Initialize-Variables
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package version="0.1" />
</packageDDDDD>  
"@

  try {
    Chocolatey-PackagesConfig "TestDrive:\packages.config"
  } catch {
    $script:error_message = $($_.Exception.Message)
  }
    
  It "should error upon getting content" {}
  
  It "should return an error" {
    $true.should.be($script:error_message -ne '')
  }
  
  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

  It "should not call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($false)
  }
 
  #
  # depends on the malformation, really
  #  1. element (like `<pakage ... />`)
  #     The xml object for loop will skip it.
  #  2. attribute (like `<package ... verion="0.1" />`)
  #     A null/empty value will be passed on.
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest with no versions" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($true)
  }
  
  It "should set package name appropriately" {
    $script:packageName.should.be('chocolateytestpackage')
  }  
  
  It "should not set version since it was not specified" {
    $script:version.should.be('')
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that has ruby packages" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" source="ruby" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}

  It "should call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($true)
  }
  
  It "should set the source to ruby" {
    $script:source.should.be('ruby')
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that has webpi packages" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" source="webpi" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    $script:chocolatey_install_was_called.should.be($true)
  }
  
  It "should set the source to webpi" {
    $script:source.should.be('webpi')
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

}