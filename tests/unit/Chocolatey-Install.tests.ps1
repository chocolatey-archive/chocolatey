$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common


#now this is cool
Describe "When calling Chocolatey-Install for return value" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true
  $script:chocolatey_nuget_return_value = 'dude'
  $returnv = Chocolatey-Install 'testpackage' -source 'bob' -version '2.0' -installerArguments '1.2.3aasf'

  It "should return appropriately" {
    $returnv.should.be($script:chocolatey_nuget_return_value)
  }
  
  It "should return as the type that was passed in" {
    $true.should.be($returnv.GetType().Name -eq 'String')
  }  
}

Describe "When calling Chocolatey-Install with parameters" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true
  Chocolatey-Install 'testpackage' -source 'bob' -version '2.0' -installerArguments '1.2.3aasf'

  It "should set packageName appropriately" {
    $script:packageName.should.be('testpackage')
  }

  It "should set source appropriately" {
    $script:source.should.be('bob')
  }
  
  It "should set version appropriately" {
    $script:version.should.be('2.0')
  }
  
  It "should set installerArguments appropriately" {
    $script:installerArguments.should.be('1.2.3aasf')
  }
}

Describe "When calling Chocolatey-Install normally" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true
  Chocolatey-Install 'testpackage'
  
  It "should not call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($false)
  }

  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
}

Describe "When calling Chocolatey-Install with .config in the name but not ending in .config" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true
  Chocolatey-Install 'win.config.something'
  
   It "should not call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($false)
  }

  It "should call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($true)
  }
  
}

Describe "When calling Chocolatey-Install from a manifest named packages.config" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true

  Chocolatey-Install "TestDrive:\packages.config"

   It "should call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($true)
  }
  
  It "should not call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($false)
  }

  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-Install from a manifest named MyChocolateyPackages.config" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true

  Chocolatey-Install "TestDrive:\MyChocolateyPackages.config"

   It "should call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($true)
  }
  
  It "should not call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($false)
  }

  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-Install with ruby as the source" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true

  Chocolatey-Install "dude" -source 'ruby'

   It "should not call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($false)
  }
  
  It "should not call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($false)
  }
  
  It "should call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($true)
  }

  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}

Describe "When calling Chocolatey-Install with webpi as the source" {
  Initialize-Variables
  $script:exec_chocolatey_install_actual = $true

  Chocolatey-Install "dude" -source 'webpi'

   It "should not call Chocolatey-PackagesConfig" {
    $script:chocolatey_packagesconfig_was_called.should.be($false)
  }
  
  It "should call Chocolatey-WebPI" {
    $script:chocolatey_webpi_was_called.should.be($true)
  }
  
  It "should not call Chocolatey-RubyGem" {
    $script:chocolatey_rubygem_was_called.should.be($false)
  }

  It "should not call Chocolatey-NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }
}