$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Setup -File 'userprofile\_crapworkaround.txt'
$env:USERPROFILE = Join-Path 'TestDrive:' 'userProfile'

Describe "When calling Get-ConfigValue normally" {
  Initialize-Variables
  #$script:exec_get_configvalue_actual = $true
  $script:get_configvalue_return_value = 'dude'
  $result = Get-ConfigValue 'useNuGetForSources'
  
  It "should call Get-ConfigValue" {
    $script:get_configvalue_was_called.should.be($true)
  }
  
  It "should return the result of what we specified" {
    $result.should.be($script:get_configvalue_return_value)
  }
  
}

Describe "When calling Get-ConfigValue for a simple return value" {
  Initialize-Variables
  $script:exec_get_configvalue_actual = $true
  
  Setup -File 'chocolatey\chocolateyInstall\chocolatey.config' @"
<?xml version="1.0"?>
<chocolatey>
    <useNuGetForSources>true</useNuGetForSources>
</chocolatey>
"@
  
  $result = Get-ConfigValue 'useNuGetForSources'
  
  It "should not be null" {
    $true.should.be($result -ne $null)
  }
  
  It "should return the result of what we specified" {
    $result.should.be('true')
  }
  
}

Describe "When calling Get-ConfigValue for a list" {
  Initialize-Variables
  $script:exec_get_configvalue_actual = $true
  
  Setup -File 'chocolatey\chocolateyInstall\chocolatey.config' @"
<?xml version="1.0"?>
<chocolatey>
    <sources>
        <source id="chocolatey" value="http://chocolatey.org/api/v2/" />
        <source id="nuget" value="https://go.microsoft.com/fwlink/?LinkID=230477" />
    </sources>
</chocolatey>
"@
  
  $result = Get-ConfigValue 'sources'
  
  It "should not be null" {
    $true.should.be($result -ne $null)
  }
  
  It "should return a type of what we specified" {
    $result.GetType().should.be('System.Xml.XmlElement')
  }
  
  It "should contain the same number of sources as specified" {
    $result.ChildNodes.Count.should.be(2)
  }
  
  It "should contain source IDs that are not null" {
     foreach ($source in $result.source) {
        write-host $source.id
        $true.should.be($source.id -ne $null)
     }
  }  
  
  It "should contain source IDs that are not empty" {
     foreach ($source in $result.source) {
        $true.should.be($source.id -ne '')
     }
  }
  
  It "should contain source values that are not null" {
     foreach ($source in $result.source) {
        $true.should.be($source.value -ne $null)
     }
  }

  It "should contain source values that are not empty" {
     foreach ($source in $result.source) {
        $true.should.be($source.value -ne '')
     }
  }

  It "should contain a source for chocolatey" {
    $found = $false
    foreach ($source in $result.source) {
        if ($source.id -eq 'chocolatey') { $found = $true }
    }
    
    $found.should.be($true)
  }
}
