$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here) '_Common.ps1'
. $common

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that exists" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}
  Mock Chocolatey-NuGet {}
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
 
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
   
  It "should not call Chocolatey-NuGet" {
    Assert-mockCalled Chocolatey-Nuget 0
  }

}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that does not exist" {
  Mock Chocolatey-Install {}
  Mock Chocolatey-NuGet {}
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"

  It "should do nothing" {}  
  
  It "should not call Chocolatey-Install" {
    Assert-mockCalled Chocolatey-Install 0
  }
  
  It "should not call Chocolatey-NuGet" {
    Assert-mockCalled Chocolatey-Nuget 0
  }

}

Describe "When calling Chocolatey-PackagesConfig with a .config manifest that is named MyChocolateyPackages.config" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}
  Mock Chocolatey-NuGet {}

  Setup -File 'MyChocolateyPackages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\MyChocolateyPackages.config"
  
  It "should treat it like a packages.config" {}
    
  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
  
  It "should not call Chocolatey-Nuget" {
    Assert-mockCalled Chocolatey-Nuget 0
  }
}

Describe "When calling Chocolatey-PackagesConfig with a package name ending with .config without a '\' in the name" {
  Mock Chocolatey-Install {}
  Mock Chocolatey-NuGet {} -Verifiable {$packageName -eq 'win.config' -and $version -eq ''}
  
  Chocolatey-PackagesConfig 'win.config'
  
  It "should treat it like a regular package" {}
  
  It "should not call Chocolatey-Install" {
    Assert-mockCalled Chocolatey-Install 0
  }
  
  It "should call Chocolatey-NuGet" {
    Assert-VerifiableMocks
  }
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest missing package id" {
  Mock Chocolatey-Install {}
  Mock Chocolatey-NuGet {}

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package version="0.1" />
</packages>  
"@

  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should only call Chocolatey-Install on packages that have specified an Id" {}
  
  It "should not call Chocolatey-Install" {
    Assert-mockCalled Chocolatey-Install 0
  }
  
  It "should not call Chocolatey-NuGet" {
    Assert-mockCalled Chocolatey-Nuget 0
  }
   
  #
  # depends on the malformation, really
  #  1. element (like `<pakage ... />`)
  #     The xml object for loop will skip it.
  #  2. attribute (like `<package ... verion="0.1" />`)
  #     A null/empty value will be passed on.
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest with badly formed xml" {
  Mock Chocolatey-Install {}
  Mock Chocolatey-NuGet {}

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
  
  It "should not call Chocolatey-Install" {
    Assert-mockCalled Chocolatey-Install 0
  }
  
  It "should not call Chocolatey-NuGet" {
    Assert-mockCalled Chocolatey-Nuget 0
  }
 
  #
  # depends on the malformation, really
  #  1. element (like `<pakage ... />`)
  #     The xml object for loop will skip it.
  #  2. attribute (like `<package ... verion="0.1" />`)
  #     A null/empty value will be passed on.
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest with no versions" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq 'chocolateytestpackage' -and $version -eq ''}
  Mock Chocolatey-NuGet {} 
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
    
  It "should not call Chocolatey-Nuget" {
    Assert-mockCalled Chocolatey-Nuget 0
  }
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that has ruby packages" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq 'chocolateytestpackage' -and $version -eq '0.1' -and $source -eq 'ruby'}
  Mock Chocolatey-NuGet {} 
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" source="ruby" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}

  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
    
  It "should not call Chocolatey-Nuget" {
    Assert-mockCalled Chocolatey-Nuget 0
  }
}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that has webpi packages" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq 'chocolateytestpackage' -and $source -eq 'webpi'}
  Mock Chocolatey-NuGet {} 
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" source="webpi" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
  
  It "should not call Chocolatey-Nuget" {
    Assert-mockCalled Chocolatey-Nuget 0
  }

}

Describe "When calling Chocolatey-PackagesConfig with a packages.config manifest that has windowsfeatures packages" {
  Mock Chocolatey-Install {} -Verifiable {$packageName -eq 'chocolateytestpackage' -and $source -eq 'windowsfeatures'}
  Mock Chocolatey-NuGet {} 
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" source="windowsfeatures" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should execute the contents of the packages.config" {}
  
  It "should call Chocolatey-Install" {
    Assert-VerifiableMocks
  }
  
  It "should not call Chocolatey-Nuget" {
    Assert-mockCalled Chocolatey-Nuget 0
  }

}