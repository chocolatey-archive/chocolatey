$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyVsixPackage.ps1"

Describe "Install-ChocolateyVsixPackage" {
  Context "When not Specifying a version and version 10 and 11 is installed" {
    Mock Get-ChildItem {@(@{Name="path\10.0";Property=@("InstallDir");PSPath="10"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile
    Mock Write-Debug
    Mock Write-ChocolateySuccess
    Mock Install-Vsix

    Install-ChocolateyVsixPackage "package" "url"
    It "should install for version 11" {
        Assert-MockCalled Write-Debug -ParameterFilter {$message -like "*11\VsixInstaller.exe" }
    }
  }

  Context "When not Specifying a version and only 10 is installed" {
    Mock Get-ChildItem {@{Name="path\10.0";Property=@("InstallDir");PSPath="10";Length=$false}}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile
    Mock Write-Debug
    Mock Write-ChocolateySuccess
    Mock Write-ChocolateyFailure
    Mock Install-Vsix

    Install-ChocolateyVsixPackage "package" "url"
    It "should install for version 10" {
        Assert-MockCalled Write-Debug -ParameterFilter {$message -like "*10\VsixInstaller.exe" }
    }
  }

  Context "When Specifying a specific version that version is installed" {
    Mock Get-ChildItem {@(@{Name="path\10.0";Property=@("InstallDir");PSPath="10"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile
    Mock Write-Debug
    Mock Write-ChocolateySuccess
    Mock Install-Vsix

    Install-ChocolateyVsixPackage "package" "url" "10"
    It "should install for version 10 if 10 is specified" {
        Assert-MockCalled Write-Debug -ParameterFilter {$message -like "*10\VsixInstaller.exe" }
    }
  }

  Context "When VS is not installed" {
    Mock Get-ChildItem
    Mock Write-Debug
    Mock Write-ChocolateyFailure

    Install-ChocolateyVsixPackage "package" "url" "10"
    It "should fail" {
        Assert-MockCalled Write-ChocolateyFailure -ParameterFilter {$failureMessage -eq "Visual Studio is not installed or the specified version is not present." }
    }
  }

  Context "When the specified version of VS is not installed" {
    Mock Get-ChildItem {@(@{Name="path\12.0";Property=@("InstallDir");PSPath="12"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Write-Debug
    Mock Write-ChocolateyFailure

    Install-ChocolateyVsixPackage "package" "url" "10"
    It "should fail" {
        Assert-MockCalled Write-ChocolateyFailure -ParameterFilter {$failureMessage -eq "Visual Studio is not installed or the specified version is not present." }
    }
  }

  Context "When something goes wrong downloading the file" {
    Mock Get-ChildItem {@(@{Name="path\10.0";Property=@("InstallDir");PSPath="10"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile { throw "something went wrong"}
    Mock Write-ChocolateyFailure 

    Install-ChocolateyVsixPackage "package" "url"
    It "should fail" {
        Assert-MockCalled Write-ChocolateyFailure -ParameterFilter {$failureMessage -eq "There were errors attempting to retrieve the vsix from url. The error message was 'something went wrong'." }
    }
  }

  Context "When Installed VS version is less than 10" {
    Mock Get-ChildItem {@(@{Name="path\8.0";Property=@("InstallDir");PSPath="path\8.0"},@{Name="path\9.0";Property=@("InstallDir");PSPath="path\9.0"})}
    Mock Write-ChocolateyFailure 

    Install-ChocolateyVsixPackage "package" "url"
    It "should fail" {
        Assert-MockCalled Write-ChocolateyFailure -ParameterFilter {$failureMessage -eq "This installed VS version, 9.0, does not support installing VSIX packages. Version 10 is the minimum acceptable version."}
    }
  }

  Context "When Installer returns an exit code error" {
    Mock Get-ChildItem {@(@{Name="path\10.0";Property=@("InstallDir");PSPath="10"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile
    Mock Write-Debug
    Mock Write-ChocolateyFailure
    Mock Install-Vsix {return 1}

    Install-ChocolateyVsixPackage "package" "url"
    It "should fail" {
        Assert-MockCalled Write-ChocolateyFailure -ParameterFilter {$failureMessage -eq "There was an error installing 'package'. The exit code returned was 1."}
    }
  }

  Context "When VSIX is already installed" {
    Mock Get-ChildItem {@(@{Name="path\10.0";Property=@("InstallDir");PSPath="10"},@{Name="path\11.0";Property=@("InstallDir");PSPath="11"})}
    Mock get-itemproperty {@{InstallDir=$Path}}
    Mock Get-ChocolateyWebFile
    Mock Write-Debug
    Mock Write-ChocolateySuccess
    Mock Write-ChocolateyFailure
    Mock Install-Vsix {return 1001}

    Install-ChocolateyVsixPackage "package" "url"
    It "should succeed" {
        Assert-MockCalled Write-ChocolateySuccess
    }
  }
}
