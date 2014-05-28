Cleanup     # Pester does not clean up in case of an exception

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

$7zip = Join-Path -Resolve $env:ChocolateyInstall chocolateyinstall\tools\7za.exe
$testContent = 'nothing important'

function Exec
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ScriptBlock] $cmd
  )
  $global:LastExitCode = 0
  & $cmd
  if ($LastExitCode -ne 0) {
    throw "The command '$cmd' failed with code $LastExitCode"
  }
}

function Setup-TestFile {
  $filePathRelative = 'some\file.txt'
  Setup -File "$filePathRelative" $testContent
  return $filePathRelative
}

function Setup-InvalidTestZipFile {
  $filePathRelative = 'invalidzipfile.zip'
  Setup -File "$filePathRelative" $testContent
  return $filePathRelative
}

function Setup-TestZipFile($sourceFile) {
  $zipFilePathRelative = [IO.Path]::ChangeExtension($sourceFile, '.zip')
  $sourceFileFullPath = Join-Path $TestDrive $sourceFile
  $zipFileFullPath = Join-Path $TestDrive $zipFilePathRelative
  Exec { & $7zip a $zipFileFullPath $sourceFileFullPath } | Write-Host
  return $zipFilePathRelative
}

function Setup-DestinationDirectory {
  $dir = 'dest'
  Setup -Dir $dir
  return $dir
}

Describe "Get-ChocolateyUnzip" {

  Context "When a valid zip file is provided" {
    $testFilePath = Setup-TestFile
    $zipPath = Join-Path $TestDrive (Setup-TestZipFile $testFilePath)
    $destPath = Join-Path $TestDrive (Setup-DestinationDirectory)
    $error = $null

    try {
      Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
    } catch {
      Write-Host "$_"
      $error = $_
    }

    It "should not return an error" {
      $error | Should Be $null
    }

    $extractedFile = Join-Path $destPath (Split-Path -Leaf $testFilePath)

    It "should extract files from the archive" {
      $extractedFile | Should Exist
    }

    It "should extract files with correct content" {
      (Get-Content $extractedFile) | Should Be $testContent
    }
  }

  Context "When a nonexistent destination path is provided" {
    $testFilePath = Setup-TestFile
    $zipPath = Join-Path $TestDrive (Setup-TestZipFile $testFilePath)
    $destPath = Join-Path $TestDrive nonexistentdir
    $error = $null

    try {
      Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
    } catch {
      Write-Host "$_"
      $error = $_
    }

    It "should not return an error" {
      $error | Should Be $null
    }

    It "should create the destination directory" {
      $destPath | Should Exist
    }

    It "should extract files from the archive" {
      $extractedFile = Join-Path $destPath (Split-Path -Leaf $testFilePath)
      $extractedFile | Should Exist
    }
  }

  Context "When a nonexistent archive file is specified" {
    $zipPath = Join-Path $TestDrive nonexistentfile.zip
    $destPath = Join-Path $TestDrive (Setup-DestinationDirectory)
    $error = $null

    try {
      Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
    } catch {
      Write-Host "$_"
      $error = $_
    }

    It "should throw an exception" {
      $error | Should Not Be $null
      $error.Exception | Should Not Be $null
    }
  }

  Context "When an invalid/corrupted zip file is provided" {
    $zipPath = Join-Path $TestDrive (Setup-InvalidTestZipFile)
    $destPath = Join-Path $TestDrive (Setup-DestinationDirectory)
    $error = $null

    try {
      Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
    } catch {
      Write-Host "$_"
      $error = $_
    }

    It "should throw an exception" {
      $error | Should Not Be $null
      $error.Exception | Should Not Be $null
    }
  }

  Context "When the archive is under System32" {
    if ([IntPtr]::Size -eq 4) {
      Write-Warning 'This test is not conclusive on a 32-bit system/process. It should be executed using 64-bit Powershell on a 64-bit OS in order to verify immunity to WOW redirection.'
    }

    $testFilePath = Setup-TestFile
    # this is the value of TEMP when running as SYSTEM
    $systemTempPath = Join-Path $Env:SystemRoot System32\config\systemprofile\AppData\Local\Temp
    New-Item -Type Directory $systemTempPath -Force | Out-Null
    $zipPathOnTestDrive = Join-Path $TestDrive (Setup-TestZipFile $testFilePath)
    Copy-Item $zipPathOnTestDrive $systemTempPath -Force
    $zipPath = Join-Path $systemTempPath (Split-Path -Leaf $zipPathOnTestDrive)
    try
    {
      $destPath = Join-Path $TestDrive (Setup-DestinationDirectory)
      $error = $null

      try {
        Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
      } catch {
        Write-Host "$_"
        $error = $_
      }

      It "should not return an error" {
        $error | Should Be $null
      }

      $extractedFile = Join-Path $destPath (Split-Path -Leaf $testFilePath)

      It "should extract files from the archive" {
        $extractedFile | Should Exist
      }
    }
    finally
    {
      Remove-Item $zipPath -Recurse -Force -ErrorAction SilentlyContinue
    }
  }

  Context "When the destination path is inside System32" {
    if ([IntPtr]::Size -eq 4) {
      Write-Warning 'This test is not conclusive on a 32-bit system/process. It should be executed using 64-bit Powershell on a 64-bit OS in order to verify immunity to WOW redirection.'
    }

    $testFilePath = Setup-TestFile
    $zipPath = Join-Path $TestDrive (Setup-TestZipFile $testFilePath)
    # this is the value of TEMP when running as SYSTEM
    $systemTempPath = Join-Path $Env:SystemRoot System32\config\systemprofile\AppData\Local\Temp
    New-Item -Type Directory $systemTempPath -Force | Out-Null
    $destPath = Join-Path $systemTempPath chocolatey-test
    $error = $null

    try
    {
      try {
        Get-ChocolateyUnzip -fileFullPath $zipPath -destination $destPath
      } catch {
        Write-Host "$_"
        $error = $_
      }

      It "should not return an error" {
        $error | Should Be $null
      }

      $extractedFile = Join-Path $destPath (Split-Path -Leaf $testFilePath)

      It "should extract files from the archive" {
        $extractedFile | Should Exist
      }
    }
    finally
    {
      Remove-Item $destPath -Recurse -Force -ErrorAction SilentlyContinue
    }
  }

}
