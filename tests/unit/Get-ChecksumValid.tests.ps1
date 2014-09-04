$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

# When trying to find checksum.exe, it is looking in the chocolateyinstall folder, so we need to fake that out somehow
$originalChocolateyInstall = $env:ChocolateyInstall


Describe "Get-ChecksumValid" {

  function setup-testfile {
    $filePath = 'some\file.txt'
    Setup -File "$filePath" 'yo yo'

    Join-Path (Join-Path $env:Temp 'pester') "$filePath"
  }

  Context "When a good checksum is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Get-ChecksumValid -file "$filePath" -checksum 'E855365208A4CCB9C7FF4B67321DA89B'
      } catch {
        Write-Host "$_"
        $script:error_message = $($_.Exception.Message)
      }

      It "should not return an error" {
        $script:error_message | should BeNullOrEmpty
      }
    }
  }

  Context "When a good checksum and checksum type sha1 is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      try {
        Get-ChecksumValid -file "$filePath" -checksum '0FBD35FFD7EC40CB99D13DB2E759BEAE88512C4C' -checksumType 'sha1'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should not return an error" {
        $script:error_message | should BeNullOrEmpty
      }
    }
  }

  Context "When a good checksum and bad checksum type is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile

      try {
        Get-ChecksumValid -file "$filePath" -checksum 'E855365208A4CCB9C7FF4B67321DA89B' -checksumType 'wewsha1'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should default to md5 and validate against that" {}

      It "should not return an error" {
        $script:error_message | should BeNullOrEmpty
      }
    }
  }

  Context "When a bad checksum is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Get-ChecksumValid -file "$filePath" -checksum '234'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should error" {
        $script:error_message | should not BeNullOrEmpty
      }

      It "should error with the correct message" {
        $script:error_message | should be "Checksum for `'$filePath'` did not meet `'234`' for checksum type `'md5`'."
      }
    }
  }

  Context "When a bad checksum with checksum type sha1 is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Get-ChecksumValid -file "$filePath" -checksum '234' -checksumType 'sha1'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should error" {
        $script:error_message | should not BeNullOrEmpty
      }

      It "should error with the correct message" {
        $script:error_message | should be "Checksum for `'$filePath'` did not meet `'234`' for checksum type `'sha1`'."
      }
    }
  }

  Context "When an invalid checksum type is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Get-ChecksumValid -file "$filePath" -checksum '234' -checksumType 'wewsha1'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should error" {
        $script:error_message | should not BeNullOrEmpty
      }

      It "should error with message containing checksum type 'md5'" {
        $script:error_message | should be "Checksum for `'$filePath'` did not meet `'234`' for checksum type `'md5`'."
      }
    }
  }

  Context "When no checksum is provided" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Get-ChecksumValid -file "$filePath"
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should not error" {
        $script:error_message | should BeNullOrEmpty
      }

      It "should not call checksum to verify" {
        Assert-MockCalled Start-Process 0
      }
    }
  }

  Context "When no checksum is provided and the file does not exist" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Remove-Item $filePath -force
        Get-ChecksumValid -file "$filePath" -checksum ''
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should not error" {
        $script:error_message | should BeNullOrEmpty
      }

      It "should not call checksum to verify" {
        Assert-MockCalled Start-Process 0
      }
    }
  }

  Context "When a checksum is provided but the file doesn't exist" {
    Execute-WithEnvironmentProtection {
      Set-ChocolateyInstallToSrcFolder $here
      $script:error_message = ""
      $filePath = setup-testfile
      Mock Start-Process {} #{} -Verifiable {$packageName -eq "chocolateytestpackage" -and $version -eq "0.1"}

      try {
        Remove-Item $filePath -force
        Get-ChecksumValid -file "$filePath" -checksum '234'
      } catch {
        $script:error_message = $($_.Exception.Message)
      }

      It "should error" {
        $script:error_message | should not BeNullOrEmpty
      }

      It "should error with the correct message" {
        $script:error_message | should be "Unable to checksum a file that doesn't exist - Could not find file `'$filePath`'"
      }
    }
  }
}
