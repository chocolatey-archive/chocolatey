$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path $here '_Common.ps1'
. $common

Describe "When installing packages from a packages.config manifest" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call Chocolatey-NuGet with each package name" {
    $script:packageName.should.be('chocolateytestpackage')
    $script:version.should.be('0.1')
  }  
  
  It "should call Chocolatey-NuGet with each package version" {
    $script:version.should.be('0.1')
  }
  
  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
}

Describe "When installing packages from a .config manifest that is named MyChocolateyPackages.config" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'MyChocolateyPackages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\MyChocolateyPackages.config"
  
  It "should call Chocolatey-NuGet with each package name" {
    $script:packageName.should.be('chocolateytestpackage')
  }  
  
  It "should call Chocolatey-NuGet with each package version" {
    $script:version.should.be('0.1')
  }
  
  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
}

Describe "When installing a package name ending with .config" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Chocolatey-PackagesConfig 'win.config'
  
  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should call Chocolatey-NuGet with package name" {
    $script:packageName.should.be('win.config')
  }
  
}

Describe "When installing packages from a packages.config manifest that doesn't exist" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true

  Chocolatey-PackagesConfig "TestDrive:\packages.config"

  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
  
  It "should not have a package name" {
    $true.should.be($script:packageName -eq '')
  }  
  
  It "should not have a package version" {
    $true.should.be($script:version -eq '')
  }

}

Describe "When installing packages from a packages.config manifest missing package id" {
  Initialize-Variables
  $script:exec_chocolatey_packagesconfig_actual = $true

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package version="0.1" />
</packages>  
"@

  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

  It "should I dunno like do something" {
  
    #
    # depends on the malformation, really
    #  1. element (like `<pakage ... />`)
    #     The xml object for loop will skip it.
    #  2. attribute (like `<package ... verion="0.1" />`)
    #     A null/empty value will be passed on.
  }

}

Describe "When installing packages from a manifest with no versions" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
  It "should call Chocolatey-NuGet with a package name" {
    $script:packageName.should.be('chocolateytestpackage')
  }
  
  It "should call Chocolatey-NuGet without a version specified" {
    $true.should.be(($script:version -eq ''))
  }

}

Describe "When installing ruby packages from a manifest" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" source="ruby" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey rubygem" {
    $script:chocolatey_rubygem_was_called.should.be($true)
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When installing webpi packages from a manifest" {
  Initialize-Variables  
  $script:exec_chocolatey_packagesconfig_actual = $true
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" source="webpi" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey webpi" {
    $script:chocolatey_webpi_was_called.should.be($true)
  }
  
  It "should not call Chocolatey-Nuget" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

}