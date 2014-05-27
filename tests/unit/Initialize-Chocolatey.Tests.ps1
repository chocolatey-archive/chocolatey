$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$base = Split-Path -Parent (Split-Path -Parent $here)
. (Join-Path (Split-Path -Parent $here) '_TestHelpers.ps1')

function Add-ChocolateyInstall($path, $targetScope)
{
    Add-EnvironmentVariable 'ChocolateyInstall' $path $targetScope
}

function Setup-ChocolateyInstall($path, $targetScope)
{
    Remove-EnvironmentVariable 'ChocolateyInstall'
    if ($path -ne $null) {
        Add-ChocolateyInstall $path $targetScope
    }
}

function Verify-ExpectedContentInstalled($installDir)
{
    It "should create installation directory" {
      $installDir | Should Exist
    }

    It "should create expected subdirectories" {
      "$installDir\bin" | Should Exist
      "$installDir\chocolateyInstall" | Should Exist
      "$installDir\lib" | Should Exist
    }

    It "should copy files to expected locations" {
      "$installDir\bin\choco.exe" | Should Exist
      "$installDir\chocolateyInstall\chocolatey.ps1" | Should Exist
      "$installDir\chocolateyInstall\helpers\functions\Install-ChocolateyPackage.ps1" | Should Exist
    }
}

function Assert-ChocolateyInstallIs($value, $scope)
{
    "$([Environment]::GetEnvironmentVariable('ChocolateyInstall', $scope))" | Should Be $value
}

function Assert-ChocolateyInstallIsNull($scope)
{
    "$([Environment]::GetEnvironmentVariable('ChocolateyInstall', $scope))" | Should BeNullOrEmpty
}

function Setup-ChocolateyInstallationPackage
{
    Setup -Dir 'chocotmp'
    Setup -Dir 'chocotmp\chocolateyInstall'
    $script:tmpDir = 'TestDrive:\chocotmp'

    Get-ChildItem "$base\nuget\tools" | Copy-Item -Destination $script:tmpDir -Recurse -Force
    Get-ChildItem "$base\src" | Copy-Item -Destination "$script:tmpDir\chocolateyInstall" -Recurse -Force

    $script:installDir = Join-Path (Resolve-Path 'TestDrive:\').ProviderPath chocoinstall

    Get-Module chocolateysetup | Remove-Module
    Import-Module "$tmpDir\chocolateysetup.psm1"
}

Describe "Initialize-Chocolatey" {
    # note: the specs below are correct when installing with administrative permissions with UAC enabled
    # the test suite is always run elevated, so no easy way to test limited user install for now

    Context "When installing with `$Env:ChocolateyInstall not set, with explicit chocolateyPath" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $null

            Initialize-Chocolatey -chocolateyPath $installDir

            Verify-ExpectedContentInstalled $installDir

            It "should create ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs $installDir 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Process scope, with same explicit chocolateyPath" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'Process'

            Initialize-Chocolatey -chocolateyPath $installDir

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            # this is unexpected - different behavior than both when chocolateyPath is not passed and when passed chocolateyPath is different than environment
            It "should create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs $installDir 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Process scope, with different explicit chocolateyPath" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'Process'

            Initialize-Chocolatey -chocolateyPath 'X:\nonexistent'

            # Is this really desired behavior - giving precedence to environment over explicit argument?
            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should not create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIsNull 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Machine scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'Machine'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should not create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIsNull 'User'
            }

            It "should preserve value of ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIs $installDir 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at User scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'User'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should preserve value of ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs $installDir 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Process scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'Process'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should not create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIsNull 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Machine scope and same at User scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'Machine'
            Add-ChocolateyInstall $installDir 'User'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should preserve value of ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs $installDir 'User'
            }

            It "should preserve value of ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIs $installDir 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Machine scope and different at User scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall 'X:\nonexistent' 'Machine'
            Add-ChocolateyInstall $installDir 'User'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should preserve value of ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs $installDir 'User'
            }

            It "should preserve value of ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIs 'X:\nonexistent' 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at Machine scope and different at Process scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall 'X:\nonexistent' 'Machine'
            Add-ChocolateyInstall $installDir 'Process'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should not create ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIsNull 'User'
            }

            It "should preserve value of ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIs 'X:\nonexistent' 'Machine'
            }
        }
    }

    Context "When installing with `$Env:ChocolateyInstall set at User scope and different at Process scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall 'X:\nonexistent' 'User'
            Add-ChocolateyInstall $installDir 'Process'

            Initialize-Chocolatey

            Verify-ExpectedContentInstalled $installDir

            It "should preserve value of ChocolateyInstall at Process scope" {
                Assert-ChocolateyInstallIs $installDir 'Process'
            }

            It "should preserve value of ChocolateyInstall at User scope" {
                Assert-ChocolateyInstallIs 'X:\nonexistent' 'User'
            }

            It "should not create ChocolateyInstall at Machine scope" {
                Assert-ChocolateyInstallIsNull 'Machine'
            }
        }
    }

    Context "When installing with bin directory not on PATH" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'User'
            Remove-DirectoryFromPath "$installDir\bin"

            Initialize-Chocolatey

            $binDir = "$installDir\bin"

            It "should add bin to PATH at Process scope" {
                Assert-OnPath $binDir 'Process'
            }

            It "should add bin to PATH at User scope" {
                Assert-OnPath $binDir 'User'
            }

            It "should not add bin to PATH at Machine scope" {
                Assert-NotOnPath $binDir 'Machine'
            }
        }
    }

    Context "When installing with bin directory on PATH at Machine scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'User'
            Remove-DirectoryFromPath "$installDir\bin"
            Add-DirectoryToPath "$installDir\bin" 'Machine'

            Initialize-Chocolatey

            $binDir = "$installDir\bin"

            It "should retain bin on PATH at Process scope" {
                Assert-OnPath $binDir 'Process'
            }

            It "should not add bin to PATH at User scope" {
                Assert-NotOnPath $binDir 'User'
            }

            It "should retain bin on PATH at Machine scope" {
                Assert-OnPath $binDir 'Machine'
            }
        }
    }

    Context "When installing with bin directory on PATH at User scope" {
        Setup-ChocolateyInstallationPackage

        Execute-WithEnvironmentBackup {
            Setup-ChocolateyInstall $installDir 'User'
            Remove-DirectoryFromPath "$installDir\bin"
            Add-DirectoryToPath "$installDir\bin" 'User'

            Initialize-Chocolatey

            $binDir = "$installDir\bin"

            It "should retain bin on PATH at Process scope" {
                Assert-OnPath $binDir 'Process'
            }

            It "should retain bin on PATH at User scope" {
                Assert-OnPath $binDir 'User'
            }

            It "should not add bin to PATH at Machine scope" {
                Assert-NotOnPath $binDir 'Machine'
            }
        }
    }
}
