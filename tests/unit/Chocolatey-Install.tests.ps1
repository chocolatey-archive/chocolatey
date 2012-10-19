$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common


#now this is cool
Describe "When calling Chocolatey-Install with parameters" {
  Mock Chocolatey-NuGet {} -Verifiable -ParameterFilter {$packageName -eq 'testpackage' -and $source -eq 'bob' -and $version -eq '2.0' -and $installerArguments -eq '1.2.3aasf'}

  Chocolatey-Install 'testpackage' -source 'bob' -version '2.0' -installerArguments '1.2.3aasf'

  It "should send params to Chocolatey-NuGet" {
    Assert-VerifiableMocks
  }
}

Describe "When calling Chocolatey-Install normally" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install 'testpackage'
  
  It "should not call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 0
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet -Exactly 1
  }
  
}

Describe "When calling Chocolatey-Install with .config in the name but not ending in .config" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install 'win.config.something'
  
   It "should not call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 0
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 1 -Exactly
  }
  
}

Describe "When calling Chocolatey-Install from a manifest named packages.config" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install "TestDrive:\packages.config"

   It "should call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 1 -Exactly
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should not call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 0
  }
}

Describe "When calling Chocolatey-Install from a manifest named MyChocolateyPackages.config" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install "TestDrive:\MyChocolateyPackages.config"

   It "should call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 1 -Exactly
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should not call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 0
  }
}

Describe "When calling Chocolatey-Install with ruby as the source" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install "dude" -source 'ruby'

   It "should not call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 0
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 1 -Exactly
  }

  It "should not call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 0
  }
}

Describe "When calling Chocolatey-Install with webpi as the source" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install "dude" -source 'webpi'

   It "should not call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 0
  }
  
  It "should call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 1 -Exactly
  }
  
  It "should not call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 0
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should not call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 0
  }
}

Describe "When calling Chocolatey-Install with windowsfeatures as the source" {
  Mock Chocolatey-PackagesConfig {}
  Mock Chocolatey-WebPI {}
  Mock Chocolatey-WindowsFeatures {}
  Mock Chocolatey-RubyGem {}
  Mock Chocolatey-NuGet {}

  Chocolatey-Install "dude" -source 'windowsfeatures'

   It "should not call Chocolatey-PackagesConfig" {
    Assert-MockCalled Chocolatey-PackagesConfig 0
  }
  
  It "should not call Chocolatey-WebPI" {
    Assert-MockCalled Chocolatey-WebPI 0
  }
  
  It "should call Chocolatey-WindowsFeatures" {
    Assert-MockCalled Chocolatey-WindowsFeatures 1 -Exactly
  }

  It "should not call Chocolatey-RubyGem" {
    Assert-MockCalled Chocolatey-RubyGem 0
  }

  It "should not call Chocolatey-NuGet" {
    Assert-MockCalled Chocolatey-NuGet 0
  }
}