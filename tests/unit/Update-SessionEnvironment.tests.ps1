$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Update-SessionEnvironment.ps1"

Describe "Update-SessionEnvironment" {

  Context "under normal circumstances" {

    $mkey = 'choc' + [Guid]::NewGuid().ToString('n')
    $mvalue = [Guid]::NewGuid().ToString('n')
    $ukey = 'choc' + [Guid]::NewGuid().ToString('n')
    $uvalue = [Guid]::NewGuid().ToString('n')

    Execute-WithEnvironmentProtection {

      Get-EnvironmentVariableNames Machine | % { Set-EnvironmentVariable $_ $null Machine }
      Get-EnvironmentVariableNames User | % { Set-EnvironmentVariable $_ $null User }
      Set-EnvironmentVariable $mkey $mvalue Machine
      Set-EnvironmentVariable $ukey 'someval' Machine
      Set-EnvironmentVariable 'PATH' 'someval2' Machine
      Set-EnvironmentVariable $ukey $uvalue User
      Set-EnvironmentVariable 'PATH' 'someval1' User
      Set-EnvironmentVariable $mkey $null Process
      Set-EnvironmentVariable $ukey $null Process
      Set-EnvironmentVariable 'PATH' $null Process

      Update-SessionEnvironment

      $mlocalSession = Get-ChildItem "Env:$($mkey)"
      $ulocalSession = Get-ChildItem "Env:$($ukey)"
      $plocalSession = Get-ChildItem "Env:$('Path')"

      It "should properly refresh MACHINE variables set outside this session" {
        $mlocalSession.Value | should Be $mvalue
      }
      It "should properly refresh USER variables set outside this session overriding Machine vars with same key" {
        $ulocalSession.Value | should Be $uvalue
      }
      It "should properly refresh the PATH variable concatenating MACHINE and USER" {
        $plocalSession.Value | should Be 'someval2;someval1'
      }
    }
  }
}
