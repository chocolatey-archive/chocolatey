$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Describe "Get-ProcessorBits" {

  Context "when calling with no arguments" {
    $expectedValue = 64
    if ([System.IntPtr]::Size -eq 4) {
      $expectedValue = 32
    }
    $returnValue =  Get-ProcessorBits

    It "should return the correct bitness" {
      $returnValue  | should Be $expectedValue
    }
  }

  Context "when comparing against the bitness and they are equal" {
    $actualBits = 64
    if ([System.IntPtr]::Size -eq 4) {
      $actualBits = 32
    }
    $returnValue =  Get-ProcessorBits $actualBits

    It "should return true" {
      $returnValue  | should Be $true
    }
  }

  Context "when comparing against the bitness are not equal" {
    $actualBits = 32
    if ([System.IntPtr]::Size -eq 4) {
      $actualBits = 64
    }
    $returnValue =  Get-ProcessorBits $actualBits

    It "should return false" {
      $returnValue  | should Be $false
    }
  }
}
