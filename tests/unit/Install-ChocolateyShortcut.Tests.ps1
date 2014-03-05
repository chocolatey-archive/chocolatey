$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyShortcut.ps1"

Describe "Install-ChocolateyShortcut" {
	Context "When no ShortCutFilePath parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyShortcut -targetPath "TestTargetPath" -workingDirectory "TestWorkingDiectory" -arguments "TestArguments" -iconLocation "TestIconLocation" -description "TestDescription"
	
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "Missing ShortCutFilePath input parameter."}
		}
	}
	
	Context "When no TargetPath parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyShortcut -shortcutFilePath "TestShortcutFilePath" -workingDirectory "TestWorkingDiectory" -arguments "TestArguments" -iconLocation "TestIconLocation" -description "TestDescription"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "Missing TargetPath input parameter."}
		}
	}
	
	Context "When TargetPath is a location that does not exist" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyShortcut -targetPath "C:\TestTargetPath.txt" -shortcutFilePath "TestShortcutFilePath"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "TargetPath does not exist, so can't create shortcut."}
		}
	}
	
	Context "When a Working Directory is provided, and this parth doesn't exist" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyShortcut -shortcutFilePath "TestShortcutFilePath" -targetPath "C:\Chocolatey\chocolateyinstall\LICENSE.txt" -workingDirectory "C:\TestWorkingDiectory" -arguments "TestArguments" -description "TestDescription"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "WorkingDirectory does not exist, so can't create shortcut."}
		}
	}
	
	Context "When an IconLocation is provided, and the path doesn't exist" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyShortcut -shortcutFilePath "TestShortcutFilePath" -targetPath "C:\Chocolatey\chocolateyinstall\LICENSE.txt" -arguments "TestArguments" -iconLocation "c:\iconlocation.ico" -description "TestDescription"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "IconLocation does not exist, so can't create shortcut."}
		}
    }

    Context "When valid shortcutpath and targetpath are provided" {
        $shortcutPath = "c:\test.lnk"
        $targetPath="C:\test.txt"

        Set-Content $targetPath -value "my test text."

		Install-ChocolateyShortcut -shortcutFilePath $shortcutPath -targetPath $targetPath

        $result = Test-Path($shortcutPath)

		It "should succeed." {
			$result | should Be $true
		}

        # Tidy up items that were created as part of this test
        if(Test-Path($shortcutPath)) {
            Remove-Item $shortcutPath
        }

        if(Test-Path($targetPath)) {
            Remove-Item $targetPath
        }
	}
	
	Context "When all parameters are passed with valid values" {
		$shortcutPath = "c:\test.lnk"
        $targetPath = "C:\test.txt"
		$workingDirectory = "C:\"
		$arguments = "args"
		$iconLocation = "C:\test.ico"
		$description = "Description"

        Set-Content $targetPath -value "my test text."
		Set-Content $iconLocation -Value "icon"

		Install-ChocolateyShortcut -shortcutFilePath $shortcutPath -targetPath $targetPath -workDirectory $workingDirectory -arguments $arguments -iconLocation $iconLocation -description $description

        $result = Test-Path($shortcutPath)
		
		It "should succeed." {
		}
		
        # Tidy up items that were created as part of this test
        if(Test-Path($shortcutPath)) {
            Remove-Item $shortcutPath
        }

        if(Test-Path($targetPath)) {
            Remove-Item $targetPath
        }		
		
		if(Test-Path($iconLocation)) {
			Remove-Item $iconLocation
		}
	}
}