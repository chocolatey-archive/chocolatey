$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyDesktopLink.ps1"

Describe "Install-ChocolateyDesktopLink" {
	Context "When no TargetFilePath parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyDesktopLink
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing TargetFilePath input parameter." }
		}
	}
	
	Context "When TargetFilePath is to a location that does not exist" {
	    Mock Write-ChocolateyFailure

		Install-ChocolateyDesktopLink -targetFilePath "C:\TestTargetPath.txt"

		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter {$failureMessage -eq "TargetPath does not exist, so can't create shortcut."}
		}		
	}
	
		
	Context "When valid targetpath is provided" {
		$targetPath="C:\test.txt"
		
		Set-Content $targetPath -value "my test text."
		
		Install-ChocolateyDesktopLink -targetFilePath $targetPath
		
		$desktop = $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))
    	$shortcutPath = Join-Path $desktop "$([System.IO.Path]::GetFileName($targetPath)).lnk"
	
		$result = Test-Path($shortcutPath)
		
		It "should succeed, and desktop shortcut is created." {
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
}